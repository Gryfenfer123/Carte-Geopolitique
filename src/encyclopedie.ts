// ---------------------------------------------------------------------------
// Encyclopédie — semis initial, porté de migrateNotionsToEncyclopediaDossier()
// dans l'artifact source (realistic_final.html, ~5413-5475) : 6 catégories de
// base (Sociologie/Économie/Philosophie/Sciences/Histoire des idées/Relations
// internationales) + les notions de démonstration (NOTIONS_SEED.json),
// chacune devenant une sous-section (niveau 2) du dossier owner_type=
// 'encyclopedie' portant son éventuelle liste de pays de référence associés,
// avec une entrée "texte" reprenant son corps.
//
// L'ouverture du dossier lui-même (catégories/sections/entrées, lecture,
// édition) est intégralement gérée par src/dossier.ts (openEncyclopedieDossier,
// réutilisant le même système que les dossiers pays/groupes) — ce module ne
// fait QUE le semis initial, une fois, en base.
// ---------------------------------------------------------------------------

import type { SupabaseClient, Session } from "@supabase/supabase-js";

type EncCategory = { id: string; name: string };
type NotionCategory = { id: string; name: string };
type Notion = { id: string; name: string; categoryId: string; countries: string[]; body: string };

export async function ensureEncyclopedieSeed(supabase: SupabaseClient, getSession: () => Session | null) {
  const { count } = await supabase
    .from("dossier_sections")
    .select("id", { count: "exact", head: true })
    .eq("owner_type", "encyclopedie")
    .eq("owner_id", "encyclopedie");
  if (count && count > 0) return;
  const session = getSession();
  if (!session) return; // best-effort : retentera à la prochaine ouverture par un utilisateur connecté

  try {
    const [encCats, notionToEnc, notions] = await Promise.all([
      fetch(import.meta.env.BASE_URL + "data/raw/ENCYCLOPEDIA_DOSSIER_CATEGORIES.json").then((r) => r.json()) as Promise<EncCategory[]>,
      fetch(import.meta.env.BASE_URL + "data/raw/NOTION_TO_ENCYCLOPEDIA_CATEGORY.json").then((r) => r.json()) as Promise<Record<string, string>>,
      fetch(import.meta.env.BASE_URL + "data/raw/NOTIONS_SEED.json").then((r) => r.json()) as Promise<Notion[]>,
    ]);
    void notionToEnc; // les 6 catégories de NOTIONS_SEED correspondent 1:1 aux 6 d'ENCYCLOPEDIA_DOSSIER_CATEGORIES (voir NOTION_TO_ENCYCLOPEDIA_CATEGORY.json) : on associe directement par index plutôt que par id de catégorie (uuid généré côté serveur, différent des id texte des fichiers source).

    // 1) Catégories (space='encyclopedie'), si pas déjà posées par
    // ensureDefaultCategories() lors d'une précédente ouverture du dossier.
    const { data: existingCats } = await supabase.from("dossier_categories").select("id, name").eq("space", "encyclopedie");
    const categoryIdByName = new Map<string, string>();
    (existingCats || []).forEach((c) => categoryIdByName.set(c.name, c.id));
    const missing = encCats.filter((c) => !categoryIdByName.has(c.name));
    if (missing.length) {
      const { data: inserted } = await supabase
        .from("dossier_categories")
        .insert(missing.map((c) => ({ name: c.name, space: "encyclopedie", builtin: true, created_by: session.user.id })))
        .select("id, name");
      (inserted || []).forEach((c) => categoryIdByName.set(c.name, c.id));
    }

    // 2) NOTION_CATEGORIES_SEED partage les mêmes 6 noms qu'ENCYCLOPEDIA_DOSSIER_CATEGORIES
    // (vérifié par construction des deux fichiers source) : categoryId d'une
    // notion -> nom -> uuid de catégorie.
    const notionCategories = (await fetch(import.meta.env.BASE_URL + "data/raw/NOTION_CATEGORIES_SEED.json").then((r) => r.json())) as NotionCategory[];
    const notionCatNameById = new Map(notionCategories.map((c) => [c.id, c.name]));

    let position = 0;
    for (const notion of notions) {
      const catName = notionCatNameById.get(notion.categoryId);
      const categoryId = (catName && categoryIdByName.get(catName)) || categoryIdByName.values().next().value;
      if (!categoryId) continue;
      const { data: sectionRow, error: secErr } = await supabase
        .from("dossier_sections")
        .insert({
          owner_type: "encyclopedie",
          owner_id: "encyclopedie",
          category_id: categoryId,
          parent_section_id: null,
          title: notion.name,
          position: position++,
          countries: notion.countries || [],
          created_by: session.user.id,
        })
        .select("id")
        .single();
      if (secErr || !sectionRow) continue;
      await supabase.from("dossier_entries").insert({
        owner_type: "encyclopedie",
        owner_id: "encyclopedie",
        type: "text",
        category_id: categoryId,
        section_id: sectionRow.id,
        title: notion.name,
        body_html: notion.body,
        status: "published",
        created_by: session.user.id,
      });
    }
  } catch {
    /* best-effort : en cas d'échec partiel, on retentera (count === 0) à la prochaine ouverture */
  }
}
