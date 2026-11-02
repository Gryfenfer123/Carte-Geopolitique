// ---------------------------------------------------------------------------
// Frises — règnes : accès à la base (table timeline_reigns, migration
// frises_v2) et recherche des membres des arbres généalogiques. Sans DOM.
// Les dates de règne ne sont PAS dans les arbres : elles sont saisies ici, sur
// la frise, avec leurs sources, puis lisibles par les arbres (lecture publique).
// ---------------------------------------------------------------------------

import type { SupabaseClient } from "@supabase/supabase-js";
import type { FriseDate } from "./friseModel";
import { parseSources, type ReignSource } from "./friseReignModel";

export type MemberRef = {
  id: string;
  name: string;
  title: string | null;
  dynasty: string | null;
  birthYear: number | null;
  deathYear: number | null;
  ownerType: string; // propriétaire de l'arbre (« entry » = une entrée de dossier)
  ownerId: string;
};

export type Reign = {
  id: string;
  friseId: string;
  member: MemberRef;
  title: string | null;
  start: FriseDate;
  end: FriseDate | null; // null = règne en cours ou fin inconnue
  sources: ReignSource[];
};

export type ReignInput = {
  friseId: string;
  memberId: string;
  title: string | null;
  start: FriseDate;
  end: FriseDate | null;
  sources: ReignSource[];
};

type MemberRow = {
  id: string;
  name: string;
  title: string | null;
  dynasty: string | null;
  birth_year: number | null;
  death_year: number | null;
  owner_type: string;
  owner_id: string;
};
const MEMBER_COLUMNS = "id, name, title, dynasty, birth_year, death_year, owner_type, owner_id";
const toMember = (m: MemberRow): MemberRef => ({
  id: m.id,
  name: m.name,
  title: m.title,
  dynasty: m.dynasty,
  birthYear: m.birth_year,
  deathYear: m.death_year,
  ownerType: m.owner_type,
  ownerId: m.owner_id,
});

type ReignRow = {
  id: string;
  frise_entry_id: string;
  member_id: string;
  title: string | null;
  start_year: number;
  start_month: number | null;
  start_day: number | null;
  start_circa: boolean | null;
  end_year: number | null;
  end_month: number | null;
  end_day: number | null;
  end_circa: boolean | null;
  sources: unknown;
};
const REIGN_COLUMNS =
  "id, frise_entry_id, member_id, title, start_year, start_month, start_day, start_circa, end_year, end_month, end_day, end_circa, sources";

function toReign(r: ReignRow, member: MemberRef): Reign {
  return {
    id: r.id,
    friseId: r.frise_entry_id,
    member,
    title: r.title,
    start: { year: r.start_year, month: r.start_month, day: r.start_day, circa: !!r.start_circa },
    end: r.end_year != null ? { year: r.end_year, month: r.end_month, day: r.end_day, circa: !!r.end_circa } : null,
    sources: parseSources(r.sources),
  };
}

/** Règnes affichés sur une frise. Renvoie [] si la table n'existe pas encore (migration frises_v2 non appliquée). */
export async function fetchReigns(supabase: SupabaseClient, friseId: string): Promise<Reign[]> {
  const { data, error } = await supabase.from("timeline_reigns").select(REIGN_COLUMNS).eq("frise_entry_id", friseId);
  if (error || !data) return [];
  const rows = data as ReignRow[];
  if (!rows.length) return [];
  const ids = [...new Set(rows.map((r) => r.member_id))];
  const { data: ms } = await supabase.from("genealogy_members").select(MEMBER_COLUMNS).in("id", ids);
  const byId = new Map(((ms as MemberRow[] | null) ?? []).map((m) => [m.id, toMember(m)]));
  const out: Reign[] = [];
  for (const r of rows) {
    const m = byId.get(r.member_id);
    if (m) out.push(toReign(r, m));
  }
  return out;
}

/**
 * Règnes d'un membre, toutes frises confondues. Point d'entrée prévu pour le
 * chantier « arbres » (afficher les dates de règne dans la fiche d'un membre).
 */
export async function fetchReignsOfMember(supabase: SupabaseClient, memberId: string): Promise<Reign[]> {
  const { data, error } = await supabase.from("timeline_reigns").select(REIGN_COLUMNS).eq("member_id", memberId);
  if (error || !data) return [];
  const { data: m } = await supabase.from("genealogy_members").select(MEMBER_COLUMNS).eq("id", memberId).maybeSingle();
  if (!m) return [];
  const member = toMember(m as MemberRow);
  return (data as ReignRow[]).map((r) => toReign(r, member));
}

/** Recherche de membres d'arbres par nom (ceux au cadre rouge d'abord). */
export async function searchMembers(supabase: SupabaseClient, query: string): Promise<MemberRef[]> {
  const q = query.trim().replace(/[%,]/g, " ");
  if (q.length < 2) return [];
  const { data } = await supabase
    .from("genealogy_members")
    .select(MEMBER_COLUMNS + ", is_leader")
    .ilike("name", "%" + q + "%")
    .order("is_leader", { ascending: false })
    .limit(15);
  return ((data as MemberRow[] | null) ?? []).map(toMember);
}

function columns(prefix: "start" | "end", d: FriseDate | null) {
  return {
    [prefix + "_year"]: d ? d.year : null,
    [prefix + "_month"]: d ? d.month : null,
    [prefix + "_day"]: d ? d.day : null,
    [prefix + "_circa"]: d ? d.circa : false,
  };
}

/** Crée (id absent) ou modifie un règne. Renvoie un message d'erreur en français, ou null. */
export async function saveReign(
  supabase: SupabaseClient,
  input: ReignInput,
  userId: string,
  id?: string
): Promise<string | null> {
  const row = {
    frise_entry_id: input.friseId,
    member_id: input.memberId,
    title: input.title,
    sources: input.sources,
    ...columns("start", input.start),
    ...columns("end", input.end),
  };
  const { error } = id
    ? await supabase.from("timeline_reigns").update(row).eq("id", id)
    : await supabase.from("timeline_reigns").insert({ ...row, created_by: userId });
  return error ? "Échec de l'enregistrement : " + error.message : null;
}

export async function deleteReign(supabase: SupabaseClient, id: string): Promise<string | null> {
  const { error } = await supabase.from("timeline_reigns").delete().eq("id", id);
  return error ? "Échec : " + error.message : null;
}
