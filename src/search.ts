// ---------------------------------------------------------------------------
// Recherche — barre unifiée du haut de carte (#search-input/#search-results),
// TOUJOURS visible, un menu déroulant de 10 résultats maximum, à plat (pas
// groupés par type), cherchant sur le NOM/libellé des pays, groupes,
// sous-catégories/notions de dossier, ports/détroits/pipelines/bases/câbles/
// capitales, les liens (country_links) ET le contenu des dossiers (texte/
// titres/étiquettes) — searchIndexAll() fusionne tout. Cliquer un résultat
// vole vers l'entité et ouvre sa fiche/son dossier (selectResult).
//
// Historique (demande de Martin, 2026-10-02) : cette barre couvrait déjà
// presque tout (voir ancien commentaire d'en-tête) sauf les liens et une
// partie des sous-sections/étiquettes. La seconde interface qui existait en
// parallèle — la loupe "Recherche dans les dossiers" (#dossier-search-btn/
// #dossier-search-view), une modale plein écran séparée qui ne cherchait que
// le contenu des dossiers, avec un onglet "★ Favoris uniquement" et le
// filtre "#étiquette" — a été RETIRÉE à cette occasion : la barre unifiée
// couvre maintenant tout ce qu'elle cherchait (liens, sous-catégories/
// sections de tout owner_type, étiquettes en texte libre), sauf le filtre
// "Favoris uniquement" (abandonné délibérément — un filtre de session de
// recherche n'a pas vraiment de sens sur une barre "aller à" toujours
// visible ; voir PORT_STATUS.md).
// ---------------------------------------------------------------------------

import type { SupabaseClient } from "@supabase/supabase-js";
import type { DossierOwnerKind, MiniDossierKind } from "./dossier";
import { LINK_CATEGORY_META } from "./indicators";
import { ensureLinkIndexLoaded, getLinkIndexCache, isLinkIndexLoaded } from "./linkIndex";

export function normalizeSearch(s: string): string {
  return (s || "")
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase();
}

export type StaticSearchKind = "country" | "port" | "strait" | "pipeline" | "base" | "cable" | "capital";
export type StaticSearchEntry = {
  kind: StaticSearchKind;
  id: string; // slug
  label: string;
  sub: string;
  matchText: string;
};

type GroupLite = { id: string; name: string; color: string; members: Set<string> };
type LinkEntityKindLite = "country" | "group";

const ENTRY_TYPE_LABEL_FR: Record<string, string> = { text: "Texte", photo: "Photo", link: "Lien", hemicycle: "Hémicycle" };

// Texte affiché comme titre d'une entrée de dossier — porté à l'identique
// de dossierEntryDisplayTitle() (~10186).
function entryDisplayTitle(entry: {
  type: string;
  title: string | null;
  caption: string | null;
  link_label: string | null;
  link_url: string | null;
}): string {
  if (entry.type === "text" || entry.type === "hemicycle") return entry.title || "Sans titre";
  if (entry.type === "photo") return entry.caption || "Photo sans légende";
  if (entry.type === "link") return entry.link_label || entry.link_url || "Lien";
  return entry.title || entry.caption || entry.link_label || "Entrée";
}

// Texte brut « recherchable » d'une entrée, quel que soit son type — même
// principe qu'entryPlainText() de sanitize.ts, mais opérant directement sur
// les colonnes brutes renvoyées par Supabase.
function rowPlainText(row: DossierEntryRow): string {
  if (row.type === "text") {
    const tmp = document.createElement("div");
    tmp.innerHTML = row.body_html || "";
    return (tmp.textContent || "").replace(/\s+/g, " ").trim();
  }
  if (row.type === "link") return [row.link_label, row.link_url].filter(Boolean).join(" ");
  if (row.type === "photo") return row.caption || "";
  if (row.type === "hemicycle") {
    const h = row.hemicycle_data || { parties: [] as { name: string }[] };
    return [row.title, (h.parties || []).map((p) => p.name).join(" "), h.source].filter(Boolean).join(" ");
  }
  return "";
}

type DossierEntryRow = {
  id: string;
  owner_type: DossierOwnerKind;
  owner_id: string;
  type: "text" | "photo" | "link" | "hemicycle";
  title: string | null;
  body_html: string | null;
  caption: string | null;
  link_label: string | null;
  link_url: string | null;
  hemicycle_data: { title?: string; parties?: { name: string }[]; source?: string } | null;
  category_id: string | null;
  section_id: string | null;
  tags: string[];
  favorite: boolean;
  status: "draft" | "published";
  sources: SourceRefLite[];
};
// Même forme que SourceRef (dossier.ts) — redéfini ici sans import pour ne
// pas créer de dépendance croisée entre les deux modules, juste pour cette
// page Sources (demande de Martin, 2026-10-14) qui agrège
// dossier_entries.sources de TOUS les dossiers.
type SourceRefLite = { label: string; url: string };
type DossierSectionRow = { id: string; owner_type: DossierOwnerKind; owner_id: string; category_id: string | null; parent_section_id: string | null; title: string };
type DossierCategoryRow = { id: string; name: string; space: "country" | "encyclopedie" };
// Lignes country_links utiles à l'indexation — mêmes colonnes que
// loadLinks() dans src/links.ts. Les libellés a/b sont déjà dénormalisés sur
// chaque ligne (schema_v7.sql) : pas besoin de résoudre pays/groupe ici.
type CountryLinkRow = {
  id: string;
  entity_a_kind: LinkEntityKindLite;
  entity_a_id: string | null;
  entity_a_label: string | null;
  entity_b_kind: LinkEntityKindLite;
  entity_b_id: string | null;
  entity_b_label: string | null;
  category: string;
  description: string | null;
  start_date: string | null;
  end_date: string | null;
};

export type UnifiedSearchResult =
  | ({ kind: StaticSearchKind } & StaticSearchEntry)
  | { kind: "group"; id: string; label: string; sub: string; matchText: string; color: string }
  | {
      kind: "section";
      id: string;
      label: string;
      sub: string;
      matchText: string;
      ownerType: DossierOwnerKind;
      ownerId: string;
      categoryId: string | null;
      sectionId: string;
    }
  | {
      kind: "link";
      id: string;
      label: string;
      sub: string;
      matchText: string;
      a: { kind: LinkEntityKindLite; id: string };
      b: { kind: LinkEntityKindLite; id: string };
    }
  | {
      kind: "dossier-entry";
      id: string;
      label: string;
      sub: string;
      matchText: string;
      ownerType: DossierOwnerKind;
      ownerId: string;
      ownerLabel: string;
      categoryId: string | null;
      sectionId: string | null;
      entryId: string;
      snippet: string;
      status: "draft" | "published";
    }
  | {
      // Personne d'un arbre généalogique (demande de Martin, 2026-10-03 :
      // "recherche globale couvrant absolument tout, personne dans les
      // arbres etc.") — jusqu'ici invisible de la recherche unifiée (voir
      // search.ts, en-tête de fichier).
      kind: "genealogy-member";
      id: string;
      label: string;
      sub: string;
      matchText: string;
      ownerType: string;
      ownerId: string;
      memberId: string;
    };

export function initSearchSystem(deps: {
  supabase: SupabaseClient;
  getSession: () => { user: { id: string } } | null;
  getProfile: () => { id: string; role: string } | null;
  getStaticEntries: () => StaticSearchEntry[];
  getGroups: () => GroupLite[];
  // Résout le libellé d'un propriétaire de dossier (pays/groupe/mini-
  // dossier) pour l'affichage des résultats "dossier-entry"/"section" —
  // évite à ce module de dupliquer les données déjà détenues par
  // main.ts/groups.ts.
  getOwnerLabel: (ownerType: DossierOwnerKind, ownerId: string) => string | null;
  selectStatic: (entry: StaticSearchEntry) => void;
  openGroupDossier: (id: string, label: string, color?: string) => Promise<void>;
  openEncyclopedieDossier: () => Promise<void>;
  openCountryDossierByIso: (isoA3: string) => Promise<void>;
  openMiniDossier: (kind: MiniDossierKind, id: string, label: string) => Promise<void>;
  revealEntry: (entryId: string, categoryId: string | null) => void;
  revealSection: (sectionId: string, categoryId: string | null) => void;
  // Ouvre l'arbre généalogique propriétaire du membre ET sélectionne sa
  // fiche — même fonction que ficheDeps.openGenealogyMember (src/main.ts),
  // réutilisée ici pour le résultat de recherche "genealogy-member".
  openGenealogyMember: (ownerType: string, ownerId: string, memberId: string) => Promise<void> | void;
}) {
  const { supabase } = deps;
  function isAdmin(): boolean {
    return deps.getProfile()?.role === "admin" && !document.body.classList.contains("read-only-mode");
  }

  // -------------------------------------------------------------------------
  // Index du contenu des dossiers + des liens — porté de
  // ensureDossierSearchIndexLoaded() (~10869), étendu à country_links pour
  // que les liens entre pays/groupes soient eux aussi cherchables depuis la
  // barre unifiée (demande de Martin, 2026-10-02 : "tout rechercher — un
  // dossier, une catégorie, un lien, un pays, un groupe..."). L'artifact
  // énumère chaque entité connue puis lit son propre dossier ; ici, faute de
  // "collectionGroup", on lit directement TOUTES les lignes des tables
  // concernées, tous owner_type confondus, en une requête chacune.
  // -------------------------------------------------------------------------
  type DossierIndex = {
    entries: DossierEntryRow[];
    sections: DossierSectionRow[];
    categories: Map<string, DossierCategoryRow>;
    links: CountryLinkRow[];
  };
  let dossierIndexCache: DossierIndex | null = null;
  let dossierIndexLoading: Promise<DossierIndex | null> | null = null;
  // force=true (page Favoris, demande de Martin, 2026-10-14) : re-télécharge
  // l'index même s'il est déjà en cache — la barre de recherche tolère un
  // index un peu daté (on le reconstruit silencieusement en tâche de fond,
  // voir runTopSearch), mais une page Favoris ouverte exprès par l'usager
  // doit refléter les favoris/retraits tout juste faits (ex. on vient de
  // cliquer l'étoile d'une entrée puis on ouvre directement la page Favoris).
  async function ensureDossierIndexLoaded(force = false) {
    if (force) dossierIndexCache = null;
    if (dossierIndexCache) return dossierIndexCache;
    if (dossierIndexLoading) return dossierIndexLoading;
    dossierIndexLoading = (async () => {
      const [entriesRes, sectionsRes, categoriesRes, linksRes] = await Promise.all([
        supabase
          .from("dossier_entries")
          .select(
            "id, owner_type, owner_id, type, title, body_html, caption, link_label, link_url, hemicycle_data, category_id, section_id, tags, favorite, status, sources"
          )
          .in("type", ["text", "photo", "link", "hemicycle"]),
        supabase.from("dossier_sections").select("id, owner_type, owner_id, category_id, parent_section_id, title"),
        supabase.from("dossier_categories").select("id, name, space"),
        supabase
          .from("country_links")
          .select(
            "id, entity_a_kind, entity_a_id, entity_a_label, entity_b_kind, entity_b_id, entity_b_label, category, description, start_date, end_date"
          ),
      ]);
      const categories = new Map<string, DossierCategoryRow>();
      (categoriesRes.data || []).forEach((c) => categories.set(c.id, c as DossierCategoryRow));
      dossierIndexCache = {
        entries: (entriesRes.data || []) as DossierEntryRow[],
        sections: (sectionsRes.data || []) as DossierSectionRow[],
        categories,
        links: (linksRes.data || []) as CountryLinkRow[],
      };
      return dossierIndexCache;
    })();
    const out = await dossierIndexLoading;
    dossierIndexLoading = null;
    return out;
  }
  function categoryName(categoryId: string | null): string {
    if (categoryId && dossierIndexCache?.categories.has(categoryId)) return dossierIndexCache.categories.get(categoryId)!.name;
    return "Non classé";
  }
  function ownerLabelFor(ownerType: DossierOwnerKind, ownerId: string): string {
    return ownerType === "encyclopedie" ? "Encyclopédie" : deps.getOwnerLabel(ownerType, ownerId) || ownerId;
  }
  // Sous-catégories ("sections") de TOUT owner_type — généralise l'ancien
  // buildNotionSearchEntries() (~10157), qui ne couvrait que les sections
  // encyclopédie de premier niveau. Chaque section, quel que soit le dossier
  // auquel elle appartient, devient ici un résultat cliquable à part entière
  // (même une section sans aucune entrée dedans, ce qui n'était pas le cas
  // avant : seul le CONTENU d'une section la rendait indirectement
  // trouvable via buildDossierEntryEntries).
  function buildSectionEntries(): UnifiedSearchResult[] {
    if (!dossierIndexCache) return [];
    return dossierIndexCache.sections.map((s) => {
      const catName = categoryName(s.category_id);
      const ownerLabel = ownerLabelFor(s.owner_type, s.owner_id);
      const locParts = [ownerLabel];
      if (catName && catName !== "Non classé") locParts.push(catName);
      return {
        kind: "section" as const,
        id: s.id,
        label: s.title || s.id,
        sub: "Sous-catégorie · " + locParts.join(" / "),
        matchText: normalizeSearch([s.title || "", ownerLabel, catName].filter(Boolean).join(" ")),
        ownerType: s.owner_type,
        ownerId: s.owner_id,
        categoryId: s.category_id,
        sectionId: s.id,
      };
    });
  }
  // Liens entre pays/groupes (country_links) — nouveau : ces lignes étaient
  // jusqu'ici invisibles de la recherche. Les libellés a/b sont déjà
  // dénormalisés sur chaque ligne (schema_v7.sql), donc pas besoin de
  // résoudre pays/groupe ici (plus simple qu'un dep `getEntityLabel`
  // supplémentaire — voir le commentaire de PORT_STATUS.md).
  const linkCategoryLabel = new Map(LINK_CATEGORY_META.map((m) => [m.id, m.label]));
  function buildLinkEntries(): UnifiedSearchResult[] {
    if (!dossierIndexCache) return [];
    return dossierIndexCache.links
      .filter((r) => !!r.entity_a_id && !!r.entity_b_id) // lignes pré-v7 non migrées
      .map((r) => {
        const aLabel = r.entity_a_label || r.entity_a_id!;
        const bLabel = r.entity_b_label || r.entity_b_id!;
        const catLabel = linkCategoryLabel.get(r.category) || "Autre";
        const dateRange = r.start_date ? " (" + r.start_date + "–" + (r.end_date || "présent") + ")" : "";
        return {
          kind: "link" as const,
          id: r.id,
          label: aLabel + " ↔ " + bLabel,
          sub: "Lien · " + catLabel + dateRange,
          matchText: normalizeSearch([aLabel, bLabel, catLabel, r.description || ""].filter(Boolean).join(" ")),
          a: { kind: r.entity_a_kind, id: r.entity_a_id! },
          b: { kind: r.entity_b_kind, id: r.entity_b_id! },
        };
      });
  }
  // Contenu des dossiers — porté de buildFolderEntrySearchEntries() (~10193).
  // `tags` est désormais inclus dans matchText : porte la capacité de
  // recherche "#étiquette" de l'ancienne modale "Recherche dans les
  // dossiers" (retirée) — en texte libre plutôt qu'avec une syntaxe `#`
  // dédiée (un mot d'étiquette tape simplement comme le reste).
  function dossierEntryRowToResult(row: DossierEntryRow): UnifiedSearchResult & { kind: "dossier-entry" } {
    const title = entryDisplayTitle(row);
    const catName = categoryName(row.category_id);
    const secName = dossierIndexCache!.sections.find((s) => s.id === row.section_id)?.title || null;
    const excerpt = rowPlainText(row).slice(0, 160);
    const ownerLabel = ownerLabelFor(row.owner_type, row.owner_id);
    const typeLabel = ENTRY_TYPE_LABEL_FR[row.type] || "Entrée";
    const locParts = [ownerLabel];
    if (catName && catName !== "Non classé") locParts.push(catName);
    if (secName) locParts.push(secName);
    const tagsText = (row.tags || []).join(" ");
    return {
      kind: "dossier-entry" as const,
      id: row.id,
      label: title,
      sub: typeLabel + " · dans " + locParts.join(" / "),
      matchText: normalizeSearch([title, excerpt, ownerLabel, catName, secName || "", tagsText].filter(Boolean).join(" ")),
      ownerType: row.owner_type,
      ownerId: row.owner_id,
      ownerLabel,
      categoryId: row.category_id,
      sectionId: row.section_id,
      entryId: row.id,
      snippet: excerpt,
      status: row.status,
    };
  }
  function buildDossierEntryEntries(): UnifiedSearchResult[] {
    if (!dossierIndexCache) return [];
    return dossierIndexCache.entries.map(dossierEntryRowToResult);
  }
  // Page Favoris (bouton du bandeau global, à côté de "Mode lecture" —
  // demande de Martin, 2026-10-14) : liste de TOUTES les entrées marquées
  // favorites (étoile ⭐, entry.favorite), tous dossiers confondus — jusqu'ici
  // il n'existait aucun endroit pour les retrouver une fois ajoutées (seul
  // le bouton étoile sur l'entrée elle-même existait). Regroupées par
  // dossier d'origine pour rester lisibles (voir renderFavoritesPanel).
  function buildFavoriteEntries(): (UnifiedSearchResult & { kind: "dossier-entry" })[] {
    if (!dossierIndexCache) return [];
    return dossierIndexCache.entries.filter((row) => row.favorite).map(dossierEntryRowToResult);
  }
  // Page Sources, partie "agrégation automatique" (demande de Martin,
  // 2026-10-14, confirmée "les deux") : une ligne par source citée dans une
  // entrée de texte (dossier_entries.sources, schema_v1, déjà saisi entrée
  // par entrée dans l'éditeur de texte — voir renderSourcesEditor/
  // dossier.ts), tous dossiers confondus. Une entrée avec plusieurs sources
  // donne plusieurs lignes (une par source), chacune cliquable vers
  // l'entrée qui la cite.
  type SourceCitation = { entry: UnifiedSearchResult & { kind: "dossier-entry" }; source: SourceRefLite };
  function buildSourceCitations(): SourceCitation[] {
    if (!dossierIndexCache) return [];
    const out: SourceCitation[] = [];
    dossierIndexCache.entries.forEach((row) => {
      (row.sources || []).forEach((source) => {
        if (!source?.label) return;
        out.push({ entry: dossierEntryRowToResult(row), source });
      });
    });
    return out;
  }
  function buildGroupEntries(): UnifiedSearchResult[] {
    return deps.getGroups().map((g) => ({
      kind: "group" as const,
      id: g.id,
      label: g.name || g.id,
      sub: "Groupe (" + g.members.size + " pays)",
      matchText: normalizeSearch(g.name || g.id),
      color: g.color,
    }));
  }

  // Personnes des arbres généalogiques, TOUS arbres confondus (demande de
  // Martin, 2026-10-03 : "recherche globale couvrant absolument tout,
  // personne dans les arbres etc.") — réutilise le cache de
  // src/linkIndex.ts (déjà chargé pour l'auto-lien de texte/le rattachement
  // bidirectionnel), pas de requête Supabase dédiée ici.
  function buildGenealogyMemberEntries(): UnifiedSearchResult[] {
    return getLinkIndexCache().members.map((m) => {
      const ownerLabel = deps.getOwnerLabel(m.owner_type as DossierOwnerKind, m.owner_id) || "Arbre généalogique";
      return {
        kind: "genealogy-member" as const,
        id: m.id,
        label: m.name || "Sans nom",
        sub: "Personne · arbre de " + ownerLabel,
        matchText: normalizeSearch([m.name || "", ownerLabel].filter(Boolean).join(" ")),
        ownerType: m.owner_type,
        ownerId: m.owner_id,
        memberId: m.id,
      };
    });
  }

  // searchIndexAll() — fusionne TOUT (statique + groupes + sections + liens +
  // contenu des dossiers + personnes des arbres) pour la barre du haut. Les
  // catégories de dossier (dossier_categories) ne sont volontairement PAS
  // indexées à part : elles sont globales/partagées par tous les dossiers
  // d'un même espace (pas une entité navigable unique — "Histoire" n'est
  // pas UN endroit précis), alors que chaque section qu'elle contient l'est
  // déjà via buildSectionEntries().
  function searchIndexAll(): UnifiedSearchResult[] {
    const staticEntries = deps.getStaticEntries() as unknown as UnifiedSearchResult[];
    return staticEntries
      .concat(buildGroupEntries())
      .concat(buildSectionEntries())
      .concat(buildLinkEntries())
      .concat(buildDossierEntryEntries())
      .concat(buildGenealogyMemberEntries());
  }

  async function selectResult(entry: UnifiedSearchResult) {
    if (entry.kind === "genealogy-member") {
      await deps.openGenealogyMember(entry.ownerType, entry.ownerId, entry.memberId);
      return;
    }
    if (entry.kind === "dossier-entry") {
      if (entry.ownerType === "country") await deps.openCountryDossierByIso(entry.ownerId);
      else if (entry.ownerType === "group") await deps.openGroupDossier(entry.ownerId, entry.ownerLabel);
      else if (entry.ownerType === "encyclopedie") await deps.openEncyclopedieDossier();
      else await deps.openMiniDossier(entry.ownerType as MiniDossierKind, entry.ownerId, entry.ownerLabel);
      deps.revealEntry(entry.entryId, entry.categoryId);
      return;
    }
    if (entry.kind === "section") {
      const ownerLabel = ownerLabelFor(entry.ownerType, entry.ownerId);
      if (entry.ownerType === "country") await deps.openCountryDossierByIso(entry.ownerId);
      else if (entry.ownerType === "group") await deps.openGroupDossier(entry.ownerId, ownerLabel);
      else if (entry.ownerType === "encyclopedie") await deps.openEncyclopedieDossier();
      else await deps.openMiniDossier(entry.ownerType as MiniDossierKind, entry.ownerId, ownerLabel);
      deps.revealSection(entry.sectionId, entry.categoryId);
      return;
    }
    if (entry.kind === "link") {
      // Ouvre le dossier du premier élément du lien (a) — même choix que
      // pour un résultat "groupe" ci-dessous : on ouvre le dossier complet
      // plutôt qu'un simple survol de carte.
      if (entry.a.kind === "country") await deps.openCountryDossierByIso(entry.a.id);
      else await deps.openGroupDossier(entry.a.id, entry.label.split(" ↔ ")[0] || entry.a.id);
      return;
    }
    if (entry.kind === "group") {
      await deps.openGroupDossier(entry.id, entry.label, entry.color);
      return;
    }
    deps.selectStatic(entry as StaticSearchEntry);
  }

  // ===========================================================================
  // Barre de recherche unifiée du haut de carte — #search-input/
  // #search-results, déjà présents dans le DOM (main.ts, panneau flottant
  // "#search"). Menu déroulant à plat, 10 résultats max, toujours actif.
  // ===========================================================================
  const topInput = document.getElementById("search-input") as HTMLInputElement | null;
  const topResults = document.getElementById("search-results");
  const topWrap = document.getElementById("search");

  function runTopSearch() {
    if (!topInput || !topResults) return;
    const q = normalizeSearch(topInput.value.trim());
    topResults.innerHTML = "";
    if (!q) {
      topResults.classList.remove("open");
      return;
    }
    if (!dossierIndexCache && !dossierIndexLoading) {
      ensureDossierIndexLoaded().then(() => {
        if (normalizeSearch(topInput.value.trim()) === q) runTopSearch();
      });
    }
    if (!isLinkIndexLoaded()) {
      void ensureLinkIndexLoaded(supabase).then(() => {
        if (normalizeSearch(topInput.value.trim()) === q) runTopSearch();
      });
    }
    const matches = searchIndexAll()
      .filter((e) => e.matchText.includes(q))
      .slice(0, 10);
    if (!matches.length) {
      topResults.classList.remove("open");
      return;
    }
    matches.forEach((entry) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.appendChild(document.createTextNode(entry.label));
      const sub = document.createElement("span");
      sub.className = "search-sub";
      sub.textContent = entry.sub;
      btn.appendChild(sub);
      btn.addEventListener("click", () => {
        selectResult(entry);
        topResults.classList.remove("open");
        topInput.value = entry.label;
      });
      topResults.appendChild(btn);
    });
    topResults.classList.add("open");
  }

  if (topInput && topResults) {
    let topSearchTimer: number | null = null;
    topInput.addEventListener("input", () => {
      if (topSearchTimer) window.clearTimeout(topSearchTimer);
      topSearchTimer = window.setTimeout(runTopSearch, 180);
    });
    topInput.addEventListener("keydown", (e) => {
      if (e.key === "Escape") topResults.classList.remove("open");
    });
    document.addEventListener("click", (e) => {
      if (topWrap && !topWrap.contains(e.target as Node)) topResults.classList.remove("open");
    });
    // Préchauffe l'index du contenu des dossiers + des liens dès le
    // chargement — même esprit que le préchargement en arrière-plan de
    // l'artifact.
    ensureDossierIndexLoaded().catch(() => {});
    ensureLinkIndexLoaded(supabase).catch(() => {});
  }

  // ===========================================================================
  // Page Favoris — panneau latéral (#favorites-panel), ouvert depuis le
  // bouton du bandeau global juste à côté de "Mode lecture" (main.ts). Même
  // motif d'injection que les autres panneaux (#indicators-panel, etc.) :
  // on construit le HTML dans un conteneur temporaire puis on déplace ses
  // enfants dans <body> (voir initIndicatorsSystem pour le même geste).
  // ===========================================================================
  const favRoot = document.createElement("div");
  favRoot.innerHTML = `
    <div id="favorites-panel" class="panel side-panel">
      <button class="close-x" id="favorites-close" aria-label="Fermer">&times;</button>
      <h2>Favoris</h2>
      <p class="muted" id="favorites-empty">Aucun favori pour le moment — cliquez sur l'étoile ⭐ d'une entrée de texte, photo ou lien pour l'ajouter ici.</p>
      <div id="favorites-list"></div>
    </div>
  `;
  while (favRoot.firstChild) document.body.appendChild(favRoot.firstChild);
  document.getElementById("favorites-close")!.addEventListener("click", () => {
    document.getElementById("favorites-panel")!.classList.remove("open");
  });

  async function renderFavoritesPanel() {
    const list = document.getElementById("favorites-list")!;
    const empty = document.getElementById("favorites-empty")!;
    list.innerHTML = '<p class="muted">Chargement…</p>';
    await ensureDossierIndexLoaded(true);
    const favs = buildFavoriteEntries();
    list.innerHTML = "";
    empty.style.display = favs.length ? "none" : "";
    const byOwner = new Map<string, { label: string; items: (UnifiedSearchResult & { kind: "dossier-entry" })[] }>();
    favs.forEach((f) => {
      const key = f.ownerType + ":" + f.ownerId;
      if (!byOwner.has(key)) byOwner.set(key, { label: f.ownerLabel, items: [] });
      byOwner.get(key)!.items.push(f);
    });
    Array.from(byOwner.values())
      .sort((a, b) => a.label.localeCompare(b.label, "fr"))
      .forEach((group) => {
        const title = document.createElement("div");
        title.className = "dossier-cat-section-title";
        title.textContent = group.label;
        list.appendChild(title);
        group.items.forEach((item) => {
          const btn = document.createElement("button");
          btn.type = "button";
          btn.className = "favorite-item";
          const titleEl = document.createElement("span");
          titleEl.className = "favorite-item-title";
          titleEl.textContent = item.label;
          const subEl = document.createElement("span");
          subEl.className = "favorite-item-sub";
          subEl.textContent = item.sub;
          btn.appendChild(titleEl);
          btn.appendChild(subEl);
          btn.addEventListener("click", () => {
            document.getElementById("favorites-panel")!.classList.remove("open");
            void selectResult(item);
          });
          list.appendChild(btn);
        });
      });
  }
  async function openFavoritesPanel() {
    document.getElementById("favorites-panel")!.classList.add("open");
    await renderFavoritesPanel();
  }

  // ===========================================================================
  // Page Sources (#sources-panel, déjà présent dans le DOM — main.ts) :
  // sources générales (public.site_sources, schema_v25.sql, éditables par un
  // admin) + agrégation automatique des sources citées dans les dossiers
  // (dossier_entries.sources, voir buildSourceCitations ci-dessus). Demande
  // de Martin, 2026-10-14 : "Ajouter un page pour pouvoir mettre nos sources
  // (a mettre avec les éléments en bas à droite)", confirmé "les deux".
  // ===========================================================================
  type SiteSource = { id: string; label: string; url: string | null; note: string | null; position: number };
  let siteSources: SiteSource[] = [];
  async function loadSiteSources() {
    const { data } = await supabase.from("site_sources").select("id, label, url, note, position").order("position", { ascending: true });
    siteSources = (data as SiteSource[] | null) || [];
  }
  async function addSiteSource(label: string, url: string | null) {
    if (!isAdmin()) return;
    const session = deps.getSession();
    const position = siteSources.length ? Math.max(...siteSources.map((s) => s.position)) + 1 : 0;
    const { data } = await supabase
      .from("site_sources")
      .insert({ label, url: url || null, position, created_by: session?.user.id || null })
      .select("id, label, url, note, position")
      .single();
    if (data) siteSources.push(data as SiteSource);
  }
  async function deleteSiteSource(id: string) {
    if (!isAdmin()) return;
    siteSources = siteSources.filter((s) => s.id !== id);
    await supabase.from("site_sources").delete().eq("id", id);
  }

  async function renderSourcesPanel() {
    const manualList = document.getElementById("sources-manual-list")!;
    const entriesList = document.getElementById("sources-entries-list")!;
    manualList.innerHTML = '<p class="muted">Chargement…</p>';
    entriesList.innerHTML = "";
    await Promise.all([loadSiteSources(), ensureDossierIndexLoaded(true)]);
    manualList.innerHTML = "";
    siteSources.forEach((s) => {
      const row = document.createElement("div");
      row.className = "source-row-item";
      const left = document.createElement("span");
      if (s.url) {
        const a = document.createElement("a");
        a.href = s.url;
        a.target = "_blank";
        a.rel = "noopener noreferrer";
        a.textContent = s.label;
        left.appendChild(a);
      } else {
        left.textContent = s.label;
      }
      if (s.note) {
        const sub = document.createElement("span");
        sub.className = "source-row-sub";
        sub.textContent = s.note;
        left.appendChild(sub);
      }
      row.appendChild(left);
      if (isAdmin()) {
        const del = document.createElement("button");
        del.type = "button";
        del.title = "Supprimer cette source";
        del.textContent = "✕";
        del.addEventListener("click", async () => {
          await deleteSiteSource(s.id);
          void renderSourcesPanel();
        });
        row.appendChild(del);
      }
      manualList.appendChild(row);
    });
    if (!siteSources.length) manualList.innerHTML = '<p class="muted">Aucune source générale pour le moment.</p>';

    const citations = buildSourceCitations();
    citations.forEach(({ entry, source }) => {
      const row = document.createElement("div");
      row.className = "source-row-item";
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "source-row-entry-btn";
      const a = document.createElement("span");
      a.textContent = source.label;
      const sub = document.createElement("span");
      sub.className = "source-row-sub";
      sub.textContent = "Cité dans « " + entry.label + " » · " + entry.ownerLabel;
      btn.appendChild(a);
      btn.appendChild(sub);
      btn.addEventListener("click", () => {
        document.getElementById("sources-panel")!.classList.remove("open");
        void selectResult(entry);
      });
      row.appendChild(btn);
      if (source.url) {
        const link = document.createElement("a");
        link.href = source.url;
        link.target = "_blank";
        link.rel = "noopener noreferrer";
        link.textContent = "↗";
        link.title = source.url;
        row.appendChild(link);
      }
      entriesList.appendChild(row);
    });
    if (!citations.length) entriesList.innerHTML = '<p class="muted">Aucune source citée dans les dossiers pour le moment.</p>';

    const addWrap = document.getElementById("sources-manual-add") as HTMLElement;
    addWrap.style.display = isAdmin() ? "flex" : "none";
  }
  document.getElementById("sources-manual-add-btn")?.addEventListener("click", async () => {
    const labelInput = document.getElementById("sources-manual-label") as HTMLInputElement;
    const urlInput = document.getElementById("sources-manual-url") as HTMLInputElement;
    const label = labelInput.value.trim();
    if (!label) return;
    await addSiteSource(label, urlInput.value.trim() || null);
    labelInput.value = "";
    urlInput.value = "";
    void renderSourcesPanel();
  });

  return { openFavoritesPanel, renderSourcesPanel };
}
