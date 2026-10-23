// ---------------------------------------------------------------------------
// Frises — placement automatique d'une fiche créée à la main dans une période.
// Spécification : docs/specs/frises-chronologiques.md §4 :
//   « Quand Martin crée lui-même une fiche dans une sous-catégorie d'Histoire qui
//   correspond à une période, elle se place automatiquement sur la frise, à la
//   bonne période, à la date indiquée (le formulaire de création a donc un champ
//   date dans une période). »
//
// Fonctionnement :
// - le formulaire « + Texte » du dossier reçoit un bloc « Date » (injecté ici,
//   sans toucher à son HTML) qui n'apparaît que si la sous-catégorie choisie est
//   une période (ou un trou de transition) d'une frise ;
// - la date est facultative : sans date, la fiche est créée normalement et ne
//   figure pas sur la frise (elle pourra être placée plus tard avec « Placer sur
//   une frise », voir friseMulti.ts) ;
// - avec une date : elle est contrôlée AVANT la création de la fiche (date valide,
//   titre présent, date bien dans CETTE période). En cas de problème, rien n'est
//   créé et le formulaire reste ouvert avec le texte tapé ;
// - après la création de la fiche, l'événement (titre de la fiche + date) est créé,
//   relié à la fiche et placé sur la frise.
// Une fiche enregistrée en brouillon n'est pas placée (elle n'est pas publique).
//
// Les trois fonctions renvoyées sont appelées par dossier.ts (branchées dans
// main.ts). Les accès à la base sont dans friseEvents.ts.
// ---------------------------------------------------------------------------

import "./friseMulti.css";
import type { SupabaseClient, Session } from "@supabase/supabase-js";
import { buildDateFields } from "./friseDateFields";
import { createEventForFiche, eventDateText, fetchFriseRefs, fetchPeriods } from "./friseEvents";
import { segmentForDate, type FriseDate } from "./friseModel";

type SectionInfo = {
  id: string;
  title: string;
  period_frise_id: string | null;
  period_start_year: number | null;
  period_is_transition: boolean | null;
  transition_after_id: string | null;
};

export function initFriseAutoPlace(deps: {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  showBanner?: (msg: string) => void;
}) {
  const { supabase } = deps;
  const form = document.getElementById("dossier-text-form");
  const sectionSelect = document.getElementById("dossier-text-section") as HTMLSelectElement | null;
  const actions = form?.querySelector(".dossier-form-actions") ?? null;
  if (!form || !sectionSelect || !actions) {
    // Le formulaire du dossier n'existe pas (ne devrait pas arriver) : le placement automatique est désactivé.
    return {
      onFormChange: (_open: boolean) => {},
      checkNewFiche: async (_sectionId: string | null) => true,
      afterFicheCreated: async (_entryId: string, _sectionId: string | null) => {},
    };
  }

  // --- Bloc « Date » injecté dans le formulaire ------------------------------------
  const block = document.createElement("div");
  block.id = "dossier-text-frise-block";
  block.style.display = "none";
  const note = document.createElement("p");
  note.className = "tl-note";
  const date = buildDateFields("Date de l'événement (facultative)");
  const error = document.createElement("p");
  error.className = "tl-error";
  error.setAttribute("role", "alert");
  block.append(note, date.el, error);
  form.insertBefore(block, actions);

  let formOpen = false;
  let current: { section: SectionInfo; friseTitle: string | null } | null = null;
  let lookupSeq = 0;
  // Résultat du dernier contrôle réussi, utilisé juste après la création de la fiche.
  let pending: { friseId: string; friseTitle: string | null; date: FriseDate; title: string } | null = null;

  async function lookupSection(sectionId: string | null): Promise<{ section: SectionInfo; friseTitle: string | null } | null> {
    if (!sectionId) return null;
    const { data } = await supabase
      .from("dossier_sections")
      .select("id, title, period_frise_id, period_start_year, period_is_transition, transition_after_id")
      .eq("id", sectionId)
      .maybeSingle();
    const s = data as SectionInfo | null;
    if (!s || !s.period_frise_id || s.period_start_year == null) return null;
    const [ref] = await fetchFriseRefs(supabase, [s.period_frise_id]);
    return { section: s, friseTitle: ref?.title ?? null };
  }

  async function refresh() {
    const mine = ++lookupSeq;
    error.textContent = "";
    if (!formOpen || !deps.getSession()) {
      current = null;
      block.style.display = "none";
      return;
    }
    const found = await lookupSection(sectionSelect!.value || null);
    if (mine !== lookupSeq) return;
    current = found;
    if (!found) {
      block.style.display = "none";
      return;
    }
    note.textContent =
      "Cette sous-catégorie est " +
      (found.section.period_is_transition ? "un trou de transition" : "une période") +
      " de la frise « " +
      (found.friseTitle || "Frise") +
      " ». Indique la date de la fiche pour qu'elle apparaisse automatiquement sur la frise.";
    block.style.display = "";
  }
  sectionSelect.addEventListener("change", () => void refresh());

  // --- Fonctions appelées par dossier.ts ----------------------------------------------

  /** Le formulaire de création s'ouvre (true) ou se ferme (false). */
  function onFormChange(open: boolean) {
    formOpen = open;
    pending = null;
    if (!open) date.clear();
    void refresh();
  }

  /**
   * Contrôle AVANT la création de la fiche. Renvoie false pour bloquer l'enregistrement
   * (le message est affiché dans le bloc « Date »), true sinon.
   */
  async function checkNewFiche(sectionId: string | null): Promise<boolean> {
    try {
      return await checkNewFicheUnsafe(sectionId);
    } catch (e) {
      // Un incident technique (réseau, base) ne doit jamais empêcher d'enregistrer une fiche :
      // elle est créée sans être placée sur la frise.
      pending = null;
      deps.showBanner?.("Impossible de contrôler la date pour la frise (" + (e instanceof Error ? e.message : "erreur inconnue") + ") : la fiche sera créée sans être placée.");
      return true;
    }
  }
  async function checkNewFicheUnsafe(sectionId: string | null): Promise<boolean> {
    pending = null;
    const found = current && current.section.id === sectionId ? current : await lookupSection(sectionId);
    if (!found) return true; // sous-catégorie ordinaire : rien à contrôler
    const read = date.read();
    if (read.kind === "empty") return true; // pas de date : la fiche est créée sans être placée
    const fail = (m: string) => {
      error.textContent = m;
      block.style.display = "";
      return false;
    };
    if (read.kind === "error") return fail(read.error);
    const title = ((document.getElementById("dossier-text-title") as HTMLInputElement | null)?.value || "").trim();
    if (!title) return fail("Donne un titre à la fiche : c'est le nom du point sur la frise.");
    const friseId = found.section.period_frise_id as string;
    const periods = await fetchPeriods(supabase, friseId);
    const seg = segmentForDate(periods, read.date);
    if (!seg) return fail("Cette date est en dehors de la frise « " + (found.friseTitle || "Frise") + " ».");
    const matches = found.section.period_is_transition
      ? seg.kind === "gap" && seg.afterPeriodId === found.section.transition_after_id
      : seg.kind === "period" && seg.period.id === found.section.id;
    if (!matches) {
      const where = seg.kind === "period" ? "la période « " + seg.period.name + " »" : "un trou de transition entre deux périodes";
      return fail(
        "Cette date (" + eventDateText({ date: read.date, end: null }) + ") tombe dans " + where + ". Choisis la sous-catégorie qui lui correspond, ou change la date."
      );
    }
    error.textContent = "";
    pending = { friseId, friseTitle: found.friseTitle, date: read.date, title };
    return true;
  }

  /** Après la création de la fiche : crée l'événement, le relie à la fiche et le place sur la frise. */
  async function afterFicheCreated(entryId: string, _sectionId: string | null) {
    try {
      await afterFicheCreatedUnsafe(entryId);
    } catch (e) {
      deps.showBanner?.("Fiche créée, mais pas placée sur la frise (" + (e instanceof Error ? e.message : "erreur inconnue") + "). Utilise « Placer sur une frise » depuis la fiche.");
    }
  }
  async function afterFicheCreatedUnsafe(entryId: string) {
    const job = pending;
    pending = null;
    if (!job) return;
    date.clear();
    const draft = (document.getElementById("dossier-text-draft") as HTMLInputElement | null)?.checked;
    if (draft) {
      deps.showBanner?.("Fiche enregistrée en brouillon : elle n'est pas placée sur la frise. Place-la avec « Placer sur une frise » une fois publiée.");
      return;
    }
    const session = deps.getSession();
    if (!session) return;
    const res = await createEventForFiche(supabase, {
      entryId,
      title: job.title,
      date: job.date,
      end: null,
      friseId: job.friseId,
      userId: session.user.id,
      placement: { side: "up", categoryId: null, color: null },
    });
    deps.showBanner?.(
      res.ok
        ? "Fiche créée et placée sur la frise « " + (job.friseTitle || "Frise") + " » (" + eventDateText({ date: job.date, end: null }) + ")."
        : "Fiche créée, mais pas placée sur la frise : " + res.error + " Utilise « Placer sur une frise » depuis la fiche."
    );
  }

  return { onFormChange, checkNewFiche, afterFicheCreated };
}
