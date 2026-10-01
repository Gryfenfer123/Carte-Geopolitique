// ---------------------------------------------------------------------------
// Recherche — portée de l'artifact source (realistic_final.html) comme DEUX
// interfaces séparées, fidèles à l'original (voir vérification du rapport de
// portage précédent : les deux existent bel et bien dans le source, avec des
// périmètres et comportements différents — la fusion en une seule modale
// tentée dans une étape antérieure de ce portage était une simplification à
// corriger) :
//
// 1. La barre de recherche unifiée du haut de carte (#search-input/
//    #search-results, ~10065-10259 + SEARCH_INDEX_STATIC ~10075-10126) :
//    TOUJOURS visible, un menu déroulant de 10 résultats maximum, à plat
//    (pas groupés par type), cherchant sur le NOM/libellé des pays, groupes,
//    notions, ports/détroits/pipelines/bases/câbles/capitales, ET (une fois
//    l'index préchargé) le contenu des dossiers — searchIndexAll() fusionne
//    tout. Cliquer un résultat vole vers l'entité et ouvre sa fiche/son
//    dossier (selectSearchEntry, ~10261-10313).
//
// 2. La loupe "Recherche dans les dossiers" (#dossier-search-btn/
//    #dossier-search-view, ~2060-2072, runDossierSearch ~11018-11052) : une
//    modale plein écran séparée, qui ne cherche QUE dans le contenu des
//    dossiers (texte/titres/thèmes/sous-sections de TOUS les dossiers,
//    jamais les pays/groupes/ports/etc. par leur nom seul), avec un onglet
//    "★ Favoris uniquement" (dossierSearchFavOnly) et le filtre "#étiquette"
//    (isTagQuery), résultats groupés PAR ENTITÉ (renderDossierSearchResults,
//    byEntity), sans limite à 10 (8 par entité).
// ---------------------------------------------------------------------------

import type { SupabaseClient } from "@supabase/supabase-js";
import type { DossierOwnerKind, MiniDossierKind } from "./dossier";

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
};
type DossierSectionRow = { id: string; owner_type: DossierOwnerKind; owner_id: string; category_id: string | null; parent_section_id: string | null; title: string };
type DossierCategoryRow = { id: string; name: string; space: "country" | "encyclopedie" };

export type UnifiedSearchResult =
  | ({ kind: StaticSearchKind } & StaticSearchEntry)
  | { kind: "group"; id: string; label: string; sub: string; matchText: string; color: string }
  | { kind: "notion"; id: string; label: string; sub: string; matchText: string; categoryId: string | null; sectionId: string }
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
    };

function escapeHtml(str: string): string {
  return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");
}

// Extrait ~110 caractères autour de la 1ère occurrence de `q` dans `text`,
// avec le fragment trouvé mis en évidence — porté de buildDossierSnippetEl()
// (~10939), construit ici en HTML (via un <span> déjà échappé).
function buildSnippetHtml(text: string, q: string): string {
  if (!q) return escapeHtml(text.slice(0, 130));
  const lower = text.toLowerCase();
  const idx = lower.indexOf(q);
  if (idx === -1) return escapeHtml(text.slice(0, 130));
  const start = Math.max(0, idx - 40);
  const end = Math.min(text.length, idx + q.length + 70);
  return (
    (start > 0 ? "…" : "") +
    escapeHtml(text.slice(start, idx)) +
    '<strong class="dossier-search-hit">' +
    escapeHtml(text.slice(idx, idx + q.length)) +
    "</strong>" +
    escapeHtml(text.slice(idx + q.length, end)) +
    (end < text.length ? "…" : "")
  );
}

export function initSearchSystem(deps: {
  supabase: SupabaseClient;
  getStaticEntries: () => StaticSearchEntry[];
  getGroups: () => GroupLite[];
  // Résout le libellé d'un propriétaire de dossier (pays/groupe/mini-
  // dossier) pour l'affichage des résultats "dossier-entry" — évite à ce
  // module de dupliquer les données déjà détenues par main.ts/groups.ts.
  getOwnerLabel: (ownerType: DossierOwnerKind, ownerId: string) => string | null;
  selectStatic: (entry: StaticSearchEntry) => void;
  openGroupDossier: (id: string, label: string, color?: string) => Promise<void>;
  openEncyclopedieDossier: () => Promise<void>;
  openCountryDossierByIso: (isoA3: string) => Promise<void>;
  openMiniDossier: (kind: MiniDossierKind, id: string, label: string) => Promise<void>;
  revealEntry: (entryId: string, categoryId: string | null) => void;
  revealSection: (sectionId: string, categoryId: string | null) => void;
}) {
  const { supabase } = deps;

  // -------------------------------------------------------------------------
  // Index du contenu des dossiers — partagé par les deux interfaces — porté
  // de ensureDossierSearchIndexLoaded() (~10869). L'artifact énumère chaque
  // entité connue puis lit son propre dossier ; ici, faute de
  // "collectionGroup", on lit directement TOUTES les lignes des 3 tables
  // concernées (dossier_categories/dossier_sections/dossier_entries), tous
  // owner_type confondus, en une requête chacune.
  // -------------------------------------------------------------------------
  type DossierIndex = { entries: DossierEntryRow[]; sections: DossierSectionRow[]; categories: Map<string, DossierCategoryRow> };
  let dossierIndexCache: DossierIndex | null = null;
  let dossierIndexLoading: Promise<DossierIndex | null> | null = null;
  async function ensureDossierIndexLoaded() {
    if (dossierIndexCache) return dossierIndexCache;
    if (dossierIndexLoading) return dossierIndexLoading;
    dossierIndexLoading = (async () => {
      const [entriesRes, sectionsRes, categoriesRes] = await Promise.all([
        supabase
          .from("dossier_entries")
          .select(
            "id, owner_type, owner_id, type, title, body_html, caption, link_label, link_url, hemicycle_data, category_id, section_id, tags, favorite, status"
          )
          .in("type", ["text", "photo", "link", "hemicycle"]),
        supabase.from("dossier_sections").select("id, owner_type, owner_id, category_id, parent_section_id, title"),
        supabase.from("dossier_categories").select("id, name, space"),
      ]);
      const categories = new Map<string, DossierCategoryRow>();
      (categoriesRes.data || []).forEach((c) => categories.set(c.id, c as DossierCategoryRow));
      dossierIndexCache = {
        entries: (entriesRes.data || []) as DossierEntryRow[],
        sections: (sectionsRes.data || []) as DossierSectionRow[],
        categories,
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
  function sectionName(sectionId: string | null): string | null {
    if (!sectionId || !dossierIndexCache) return null;
    const sec = dossierIndexCache.sections.find((s) => s.id === sectionId);
    return sec ? sec.title : null;
  }
  // Notions de l'Encyclopédie — porté de buildNotionSearchEntries() (~10157).
  function buildNotionEntries(): UnifiedSearchResult[] {
    if (!dossierIndexCache) return [];
    return dossierIndexCache.sections
      .filter((s) => s.owner_type === "encyclopedie" && !s.parent_section_id)
      .map((s) => {
        const catName = categoryName(s.category_id);
        return {
          kind: "notion" as const,
          id: s.id,
          label: s.title || s.id,
          sub: "Notion (Encyclopédie)" + (catName && catName !== "Non classé" ? " · " + catName : ""),
          matchText: normalizeSearch(s.title || s.id),
          categoryId: s.category_id,
          sectionId: s.id,
        };
      });
  }
  // Contenu des dossiers — porté de buildFolderEntrySearchEntries() (~10193).
  function buildDossierEntryEntries(): UnifiedSearchResult[] {
    if (!dossierIndexCache) return [];
    return dossierIndexCache.entries.map((row) => {
      const title = entryDisplayTitle(row);
      const catName = categoryName(row.category_id);
      const secName = sectionName(row.section_id);
      const excerpt = rowPlainText(row).slice(0, 160);
      const ownerLabel =
        row.owner_type === "encyclopedie" ? "Encyclopédie" : deps.getOwnerLabel(row.owner_type, row.owner_id) || row.owner_id;
      const typeLabel = ENTRY_TYPE_LABEL_FR[row.type] || "Entrée";
      const locParts = [ownerLabel];
      if (catName && catName !== "Non classé") locParts.push(catName);
      if (secName) locParts.push(secName);
      return {
        kind: "dossier-entry" as const,
        id: row.id,
        label: title,
        sub: typeLabel + " · dans " + locParts.join(" / "),
        matchText: normalizeSearch([title, excerpt, ownerLabel, catName, secName || ""].filter(Boolean).join(" ")),
        ownerType: row.owner_type,
        ownerId: row.owner_id,
        ownerLabel,
        categoryId: row.category_id,
        sectionId: row.section_id,
        entryId: row.id,
        snippet: excerpt,
        status: row.status,
      };
    });
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

  // searchIndexAll() — porté à l'identique (~10221) : fusionne TOUT (statique
  // + groupes + notions + contenu des dossiers) pour la barre du haut.
  function searchIndexAll(): UnifiedSearchResult[] {
    const staticEntries = deps.getStaticEntries() as unknown as UnifiedSearchResult[];
    return staticEntries.concat(buildGroupEntries()).concat(buildNotionEntries()).concat(buildDossierEntryEntries());
  }

  async function selectResult(entry: UnifiedSearchResult) {
    if (entry.kind === "dossier-entry") {
      if (entry.ownerType === "country") await deps.openCountryDossierByIso(entry.ownerId);
      else if (entry.ownerType === "group") await deps.openGroupDossier(entry.ownerId, entry.ownerLabel);
      else if (entry.ownerType === "encyclopedie") await deps.openEncyclopedieDossier();
      else await deps.openMiniDossier(entry.ownerType as MiniDossierKind, entry.ownerId, entry.ownerLabel);
      deps.revealEntry(entry.entryId, entry.categoryId);
      return;
    }
    if (entry.kind === "notion") {
      await deps.openEncyclopedieDossier();
      deps.revealSection(entry.sectionId, entry.categoryId);
      return;
    }
    if (entry.kind === "group") {
      await deps.openGroupDossier(entry.id, entry.label, entry.color);
      return;
    }
    deps.selectStatic(entry as StaticSearchEntry);
  }

  // ===========================================================================
  // 1. Barre de recherche unifiée du haut de carte — #search-input/
  //    #search-results, déjà présents dans le DOM (main.ts, panneau flottant
  //    "#search"). Menu déroulant à plat, 10 résultats max, toujours actif.
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
    // Préchauffe l'index du contenu des dossiers dès le chargement — même
    // esprit que le préchargement en arrière-plan de l'artifact.
    ensureDossierIndexLoaded().catch(() => {});
  }

  // ===========================================================================
  // 2. Loupe "Recherche dans les dossiers" — modale plein écran séparée,
  //    contenu des dossiers UNIQUEMENT, onglets Tout/Favoris, filtre
  //    "#étiquette", résultats groupés par entité — porté de
  //    #dossier-search-view/runDossierSearch/renderDossierSearchResults
  //    (~2060-2072, 10961-11087).
  // ===========================================================================
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="dossier-search-view">
      <div id="dossier-search-inner">
        <button id="dossier-search-close" class="close-x" aria-label="Fermer">&times;</button>
        <h1 id="dossier-search-title">Recherche dans les dossiers</h1>
        <div id="dossier-search-subtitle">Cherche dans le texte, les titres, les thèmes et les sous-sections de tous les dossiers (pays, groupes, points d'intérêt, Encyclopédie).</div>
        <div class="dossier-search-tabs">
          <button type="button" id="dossier-search-tab-all" class="btn-small active-mode">Tout</button>
          <button type="button" id="dossier-search-tab-fav" class="btn-small">&#9733; Favoris uniquement</button>
        </div>
        <input type="text" id="dossier-search-input" placeholder="Rechercher un mot, une phrase… (ou #étiquette)" autocomplete="off">
        <div id="dossier-search-results"></div>
      </div>
    </div>
  `;
  while (root.firstChild) document.body.appendChild(root.firstChild);
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;
  const dInput = $("dossier-search-input") as HTMLInputElement;
  const dResults = $("dossier-search-results");

  type DossierMatch = {
    row: DossierEntryRow;
    ownerType: DossierOwnerKind;
    ownerId: string;
    ownerLabel: string;
    text: string;
    catName: string;
    secName: string | null;
  };

  function renderDossierSearchResults(matches: DossierMatch[], q: string) {
    dResults.innerHTML = "";
    if (!matches.length) {
      dResults.innerHTML = '<p class="muted">Aucun résultat.</p>';
      return;
    }
    const byEntity = new Map<string, { label: string; items: DossierMatch[] }>();
    matches.forEach((m) => {
      const key = m.ownerType + ":" + m.ownerId;
      if (!byEntity.has(key)) byEntity.set(key, { label: m.ownerLabel, items: [] });
      byEntity.get(key)!.items.push(m);
    });
    byEntity.forEach((group) => {
      const groupEl = document.createElement("div");
      groupEl.className = "dossier-search-group";
      const h = document.createElement("div");
      h.className = "dossier-search-entity";
      h.textContent = group.label;
      groupEl.appendChild(h);
      group.items.slice(0, 8).forEach((m) => {
        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "dossier-search-result";
        const meta = document.createElement("div");
        meta.className = "dossier-search-result-meta";
        meta.textContent = m.catName + (m.secName ? " › " + m.secName : "") + (m.row.title ? " · " + m.row.title : "");
        if (m.row.status === "draft") {
          const badge = document.createElement("span");
          badge.className = "entry-draft-badge";
          badge.style.marginLeft = "6px";
          badge.textContent = "Brouillon";
          meta.appendChild(badge);
        }
        btn.appendChild(meta);
        const snippet = document.createElement("span");
        snippet.className = "dossier-search-result-snippet";
        snippet.innerHTML = buildSnippetHtml(m.text, q);
        btn.appendChild(snippet);
        btn.addEventListener("click", () => {
          closeDossierSearch();
          selectResult({
            kind: "dossier-entry",
            id: m.row.id,
            label: entryDisplayTitle(m.row),
            sub: "",
            matchText: "",
            ownerType: m.ownerType,
            ownerId: m.ownerId,
            ownerLabel: m.ownerLabel,
            categoryId: m.row.category_id,
            sectionId: m.row.section_id,
            entryId: m.row.id,
            snippet: m.text.slice(0, 160),
            status: m.row.status,
          });
        });
        groupEl.appendChild(btn);
      });
      dResults.appendChild(groupEl);
    });
  }

  // Favoris (item 13 de l'artifact) : filtre du panneau existant, même cache.
  let dossierSearchFavOnly = false;
  async function runDossierSearch() {
    const raw = dInput.value.trim();
    const isTagQuery = raw.startsWith("#") && raw.length > 1;
    const tagQuery = isTagQuery ? raw.slice(1).toLowerCase() : null;
    if (!raw && !dossierSearchFavOnly) {
      dResults.innerHTML = "";
      return;
    }
    dResults.innerHTML = '<p class="muted">Recherche…</p>';
    const cache = await ensureDossierIndexLoaded();
    if (dInput.value.trim() !== raw) return; // retapé entre-temps : ce résultat est obsolète
    const q = raw.toLowerCase();
    const matches: DossierMatch[] = [];
    (cache?.entries || []).forEach((row) => {
      if (dossierSearchFavOnly && row.favorite !== true) return;
      if (isTagQuery) {
        if (!(row.tags || []).some((t) => t.toLowerCase() === tagQuery)) return;
      } else if (raw) {
        const text = rowPlainText(row);
        const catName = categoryName(row.category_id);
        const secName = sectionName(row.section_id);
        const haystack = (text + " " + (row.title || "") + " " + catName + " " + (secName || "")).toLowerCase();
        if (!haystack.includes(q)) return;
      }
      const ownerLabel =
        row.owner_type === "encyclopedie" ? "Encyclopédie" : deps.getOwnerLabel(row.owner_type, row.owner_id) || row.owner_id;
      matches.push({
        row,
        ownerType: row.owner_type,
        ownerId: row.owner_id,
        ownerLabel,
        text: rowPlainText(row),
        catName: categoryName(row.category_id),
        secName: sectionName(row.section_id),
      });
    });
    if (dInput.value.trim() !== raw) return;
    renderDossierSearchResults(matches, isTagQuery ? "" : q);
  }

  let dossierSearchTimer: number | null = null;
  dInput.addEventListener("input", () => {
    if (dossierSearchTimer) window.clearTimeout(dossierSearchTimer);
    dossierSearchTimer = window.setTimeout(runDossierSearch, 280);
  });
  $("dossier-search-tab-all").addEventListener("click", () => {
    dossierSearchFavOnly = false;
    $("dossier-search-tab-all").classList.add("active-mode");
    $("dossier-search-tab-fav").classList.remove("active-mode");
    runDossierSearch();
  });
  $("dossier-search-tab-fav").addEventListener("click", () => {
    dossierSearchFavOnly = true;
    $("dossier-search-tab-fav").classList.add("active-mode");
    $("dossier-search-tab-all").classList.remove("active-mode");
    runDossierSearch();
  });

  function openDossierSearch() {
    $("dossier-search-view").classList.add("open");
    dInput.value = "";
    dResults.innerHTML = "";
    dossierSearchFavOnly = false;
    $("dossier-search-tab-all").classList.add("active-mode");
    $("dossier-search-tab-fav").classList.remove("active-mode");
    setTimeout(() => dInput.focus(), 30);
    ensureDossierIndexLoaded(); // préchauffe le cache dès l'ouverture, avant la première frappe
  }
  function closeDossierSearch() {
    $("dossier-search-view").classList.remove("open");
  }
  $("dossier-search-close").addEventListener("click", closeDossierSearch);
  dInput.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeDossierSearch();
  });

  return { openDossierSearch, closeDossierSearch };
}
