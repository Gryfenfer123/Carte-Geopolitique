// ---------------------------------------------------------------------------
// Frises — accès à la base pour les événements et leurs PLACEMENTS.
//
// Rappel du modèle (docs/specs/frises-chronologiques.md §3, §4, §8) :
// - un événement (timeline_events) est un objet unique (titre + date) lié à au
//   moins une fiche (timeline_event_fiches) ;
// - un PLACEMENT (timeline_placements) dit sur quelle frise il apparaît : c'est
//   une RÉFÉRENCE, jamais une copie. Un même événement peut donc figurer sur
//   plusieurs frises (générale + thématique, pays différents, frise parente
//   d'une sous-frise).
//
// Ce module ne touche pas au DOM. Il est utilisé par friseMulti.ts (dialogue
// « Frises de ce point »), friseAutoPlace.ts (fiche créée à la main dans une
// période) et frise.ts. Aucune migration n'est nécessaire : les tables et les
// droits (administrateur seul, schema_v28/v29) existent déjà.
// ---------------------------------------------------------------------------

import type { SupabaseClient } from "@supabase/supabase-js";
import { formatFriseDate, periodFromColumns, segmentForDate, type FriseDate, type Period, type PeriodColumns } from "./friseModel";

export type FriseRef = { id: string; title: string | null; ownerType: string; ownerId: string };
export type EventInfo = { id: string; title: string; date: FriseDate; end: FriseDate | null };
export type PlacementOptions = { side: "up" | "down"; categoryId: string | null; color: string | null };

const PERIOD_COLUMNS =
  "id, title, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa, period_color, period_is_transition";

/** Périodes d'une frise (les trous de transition ne sont pas des périodes). */
export async function fetchPeriods(supabase: SupabaseClient, friseId: string): Promise<Period[]> {
  const { data } = await supabase.from("dossier_sections").select(PERIOD_COLUMNS).eq("period_frise_id", friseId);
  const rows = ((data as (PeriodColumns & { period_is_transition: boolean | null })[] | null) ?? []).filter(
    (r) => r.period_start_year != null && !r.period_is_transition
  );
  return rows.map(periodFromColumns);
}

type FriseRow = { id: string; title: string | null; owner_type: string; owner_id: string };
const toRef = (r: FriseRow): FriseRef => ({ id: r.id, title: r.title, ownerType: r.owner_type, ownerId: r.owner_id });

export async function fetchFriseRefs(supabase: SupabaseClient, ids: string[]): Promise<FriseRef[]> {
  if (!ids.length) return [];
  const { data } = await supabase.from("dossier_entries").select("id, title, owner_type, owner_id").eq("type", "frise").in("id", ids);
  return ((data as FriseRow[] | null) ?? []).map(toRef);
}

/** Recherche de frises par titre (toutes, tous dossiers confondus). */
export async function searchFrises(supabase: SupabaseClient, query: string): Promise<FriseRef[]> {
  const q = query.trim().replace(/[%,]/g, " ");
  if (q.length < 2) return [];
  const { data } = await supabase
    .from("dossier_entries")
    .select("id, title, owner_type, owner_id")
    .eq("type", "frise")
    .ilike("title", "%" + q + "%")
    .limit(12);
  return ((data as FriseRow[] | null) ?? []).map(toRef);
}

type EventRow = {
  id: string;
  title: string;
  date_year: number;
  date_month: number | null;
  date_day: number | null;
  date_circa: boolean | null;
  date_end_year: number | null;
  date_end_month: number | null;
  date_end_day: number | null;
  date_end_circa: boolean | null;
};

export async function fetchEvent(supabase: SupabaseClient, eventId: string): Promise<EventInfo | null> {
  const { data } = await supabase
    .from("timeline_events")
    .select("id, title, date_year, date_month, date_day, date_circa, date_end_year, date_end_month, date_end_day, date_end_circa")
    .eq("id", eventId)
    .maybeSingle();
  const e = data as EventRow | null;
  if (!e) return null;
  return {
    id: e.id,
    title: e.title,
    date: { year: e.date_year, month: e.date_month, day: e.date_day, circa: !!e.date_circa },
    end:
      e.date_end_year != null
        ? { year: e.date_end_year, month: e.date_end_month, day: e.date_end_day, circa: !!e.date_end_circa }
        : null,
  };
}

/** Texte « 843 » ou « 1337 → 1453 » pour un événement. */
export function eventDateText(ev: { date: FriseDate; end: FriseDate | null }): string {
  return formatFriseDate(ev.date) + (ev.end ? " → " + formatFriseDate(ev.end) : "");
}

/** Placements d'un événement : frise, côté, catégorie, couleur. */
export async function fetchPlacements(
  supabase: SupabaseClient,
  eventId: string
): Promise<{ friseId: string; options: PlacementOptions }[]> {
  const { data } = await supabase
    .from("timeline_placements")
    .select("frise_entry_id, side, category_id, color")
    .eq("event_id", eventId);
  return (
    (data as { frise_entry_id: string; side: string | null; category_id: string | null; color: string | null }[] | null) ?? []
  ).map((r) => ({
    friseId: r.frise_entry_id,
    options: { side: r.side === "down" ? "down" : "up", categoryId: r.category_id, color: r.color },
  }));
}

/** Événement lié à une fiche (null si la fiche n'est reliée à aucun événement). */
export async function eventIdOfFiche(supabase: SupabaseClient, entryId: string): Promise<string | null> {
  const { data } = await supabase.from("timeline_event_fiches").select("event_id").eq("entry_id", entryId).maybeSingle();
  return (data as { event_id: string } | null)?.event_id ?? null;
}

/**
 * Vérifie qu'une date (et la fin éventuelle) tombe bien dans la frise visée.
 * Renvoie un message d'erreur en français, ou null si c'est bon.
 * Une frise sans période propre (sous-frise d'un événement avec durée) ne peut
 * pas être contrôlée ici : on laisse passer, le point n'y sera simplement
 * affiché que si sa date est dans la frise (frise.ts le signale).
 */
export async function checkDateFitsFrise(
  supabase: SupabaseClient,
  friseId: string,
  friseTitle: string | null,
  date: FriseDate,
  end: FriseDate | null
): Promise<string | null> {
  const periods = await fetchPeriods(supabase, friseId);
  if (!periods.length) return null;
  const inside = (d: FriseDate) => segmentForDate(periods, d) !== null;
  if (inside(date) && (!end || inside(end))) return null;
  return "Cette date est en dehors de la frise « " + (friseTitle || "Frise") + " » : le point n'y serait pas visible.";
}

/** Place un événement existant sur une frise (référence). Renvoie un message d'erreur ou null. */
export async function addPlacement(
  supabase: SupabaseClient,
  friseId: string,
  eventId: string,
  userId: string,
  opts: PlacementOptions
): Promise<string | null> {
  const { error } = await supabase.from("timeline_placements").insert({
    frise_entry_id: friseId,
    event_id: eventId,
    side: opts.side,
    category_id: opts.categoryId,
    color: opts.color,
    created_by: userId,
  });
  if (!error) return null;
  // Clé primaire (frise, événement) : déjà placé sur cette frise.
  if (error.code === "23505") return "Ce point est déjà sur cette frise.";
  return "Échec : " + error.message;
}

/**
 * Retire un événement d'UNE frise. La fiche, l'événement et ses autres
 * placements ne bougent pas. Refuse de retirer le dernier placement : il
 * faudrait alors supprimer le point lui-même (bouton prévu dans frise.ts).
 */
export async function removePlacement(supabase: SupabaseClient, friseId: string, eventId: string): Promise<string | null> {
  const { data } = await supabase.from("timeline_placements").select("frise_entry_id").eq("event_id", eventId);
  if (((data as unknown[] | null) ?? []).length < 2) {
    return "C'est la seule frise de ce point : pour l'enlever, utilise « Modifier » puis « Supprimer le point ».";
  }
  const { error } = await supabase.from("timeline_placements").delete().eq("frise_entry_id", friseId).eq("event_id", eventId);
  return error ? "Échec : " + error.message : null;
}

export type NewEventInput = {
  entryId: string; // fiche (déjà existante) à relier
  title: string;
  date: FriseDate;
  end: FriseDate | null;
  friseId: string;
  userId: string;
  placement: PlacementOptions;
};

/**
 * Crée un événement pour une fiche existante, relie la fiche et place
 * l'événement sur une frise. En cas d'échec à une étape, l'événement créé est
 * supprimé (la liaison et le placement partent avec, en cascade) : on ne laisse
 * jamais d'événement à moitié créé. La fiche, elle, n'est jamais touchée.
 */
export async function createEventForFiche(
  supabase: SupabaseClient,
  input: NewEventInput
): Promise<{ ok: true; eventId: string } | { ok: false; error: string }> {
  const { date, end } = input;
  const ev = await supabase
    .from("timeline_events")
    .insert({
      title: input.title,
      date_year: date.year,
      date_month: date.month,
      date_day: date.day,
      date_circa: date.circa,
      date_end_year: end ? end.year : null,
      date_end_month: end ? end.month : null,
      date_end_day: end ? end.day : null,
      date_end_circa: end ? end.circa : false,
      created_by: input.userId,
    })
    .select("id")
    .single();
  if (ev.error || !ev.data) return { ok: false, error: "Échec de la création du point : " + (ev.error?.message || "erreur inconnue.") };
  const eventId = ev.data.id as string;
  const link = await supabase.from("timeline_event_fiches").insert({ entry_id: input.entryId, event_id: eventId, created_by: input.userId });
  if (link.error) {
    await supabase.from("timeline_events").delete().eq("id", eventId);
    return {
      ok: false,
      error:
        link.error.code === "23505"
          ? "Cette fiche est déjà reliée à un autre événement."
          : "Échec de la liaison avec la fiche : " + link.error.message,
    };
  }
  const placeError = await addPlacement(supabase, input.friseId, eventId, input.userId, input.placement);
  if (placeError) {
    await supabase.from("timeline_events").delete().eq("id", eventId);
    return { ok: false, error: placeError };
  }
  return { ok: true, eventId };
}
