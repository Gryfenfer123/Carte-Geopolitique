// ---------------------------------------------------------------------------
// Groupes géopolitiques — porté de l'artifact source (realistic_final.html) :
// ORG_GROUP_CATEGORIES/ORG_GROUPS_SEED (~3601-3622), loadGroupCategories/
// addGroupCategory/groupCategoryName (~3537-3548, 4374-4402), buildGroupRow/
// renderGroupsPanel/newGroupId/deleteGroup (~8640-8776), renderFicheGroups/
// toggleCountryInGroup (~8801-8879), renderGroupHighlights/gGroups
// (~2835, 8941-8957), et le formulaire d'édition d'un groupe existant
// (nom/couleur/catégorie, ~8378-8383, 8492-8511) + le mode "cliquer un pays
// sur la carte pour l'ajouter/le retirer du groupe" (enterGroupAddMode/
// exitGroupAddMode/resolveEntitySelection, ~8973-9012, 8417-8424) — l'un et
// l'autre vérifiés dans le source : l'artifact garde BEL ET BIEN les deux
// façons d'ajouter un membre en même temps (champ de recherche + clic sur
// la carte), toutes deux portées ci-dessous dans l'éditeur repliable de
// chaque ligne du panneau Groupes (qui tient ici lieu de "fiche groupe",
// l'app n'ayant pas de panneau latéral séparé pour les groupes).
//
// Chaque groupe peut aussi avoir son propre dossier (owner_type='group'),
// réutilisant intégralement src/dossier.ts (bouton "Dossier" sur sa ligne).
// ---------------------------------------------------------------------------

import type { SupabaseClient, Session } from "@supabase/supabase-js";
import * as d3 from "d3";
import { frenchCountryName, flagSvgSpan } from "./countryNames";

export type CountryLite = {
  isoA3: string;
  slug: string;
  name: string;
  continent: string;
  iso2: string | null;
};

type GroupCategory = { id: string; name: string };
type Group = { id: string; name: string; color: string; category_id: string | null; created_by: string | null; members: Set<string> };

const GROUP_CATEGORY_DEFAULTS: { id: string; name: string }[] = [
  { id: "gcat-institutions", name: "Institutions politiques" },
  { id: "gcat-securite", name: "Alliances militaires et sécurité" },
  { id: "gcat-economie", name: "Organisations économiques et commerciales" },
  { id: "gcat-puissances", name: "Puissances et ressources" },
];

type OrgGroupSeedEntry = {
  id: string;
  name: string;
  color: string;
  categoryId: string;
  members: string[]; // slugs Natural Earth (ex. "france")
  body?: string;
  sources?: { label: string; url: string }[];
};

function normalize(s: string): string {
  return (s || "")
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase();
}

export function initGroupsSystem(deps: {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  getProfile: () => { id: string; role: string } | null;
  getAllCountries: () => CountryLite[];
  // Calque D3 sur lequel dessiner les contours des pays membres des groupes
  // visibles — même principe que gGroups dans l'artifact (contours colorés,
  // superposés à gLand, recalculés à chaque zoom/déplacement).
  gGroupsLayer: d3.Selection<SVGGElement, unknown, HTMLElement | null, unknown>;
  geoPath: (f: GeoJSON.GeoJSON) => string | null;
  getFeatureByIsoA3: () => Map<string, GeoJSON.Feature>;
  openGroupDossier: (id: string, name: string, color: string) => void;
  onVisibleGroupsChanged?: () => void;
  // Bascule la classe CSS de curseur sur la carte pendant le mode "cliquer
  // un pays sur la carte pour l'ajouter" — porté de
  // stage.classList.add/remove('group-add-cursor') (~8992/9003).
  setMapAddCursor?: (active: boolean) => void;
  // Coordination avec le mode "création de lien" (src/links.ts) — porté de
  // enterGroupAddMode() qui appelle exitLinkMode() en tout premier (~8984) :
  // un seul mode "clic sur la carte" actif à la fois.
  onBeforeMapAddMode?: () => void;
  // Fermeture de l'éditeur d'un groupe (repli de la ligne, ~8408 côté fiche
  // pays) — utilisé par src/links.ts pour effacer le tracé de ses liens sur
  // la carte quand l'éditeur qui les affichait se referme.
  onEditorClosed?: (groupId: string) => void;
  // Sélection d'un groupe comme extrémité d'un lien en cours de création
  // (src/links.ts) — porté de resolveEntitySelection() (~8417-8441), qui
  // consomme le clic sur un élément « liable » (pays OU groupe) plutôt que
  // d'ouvrir sa fiche/son dossier tant qu'un lien est en attente. Renvoie
  // true si le clic a été consommé.
  resolveGroupClickForLink?: (id: string, name: string) => boolean;
  // Widget "Liens" (src/links.ts), injecté dans l'éditeur repliable d'un
  // groupe — même principe que renderFicheGroups côté fiche pays.
  renderGroupLinks?: (container: HTMLElement, groupId: string, name: string) => void;
}) {
  const { supabase } = deps;

  // --- DOM ------------------------------------------------------------------
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="groups-panel" class="panel side-panel">
      <button class="close-x" id="groups-close" aria-label="Fermer">&times;</button>
      <h2>Groupes de pays</h2>
      <p class="muted">Cochez un groupe pour surligner ses pays membres sur la carte. Cliquez la flèche pour modifier son nom, sa couleur, sa catégorie et ses membres ; cliquez son nom pour ouvrir son dossier.</p>
      <div id="groups-list"></div>
      <div class="groups-new">
        <input type="text" id="group-new-name" placeholder="Nom du groupe (ex. UE, OPEP...)">
        <input type="color" id="group-new-color" value="#e8b34a" title="Couleur du groupe">
        <select id="group-new-category"><option value="">— aucune catégorie —</option></select>
        <button id="group-new-add" class="btn-small">&#43; Ajouter</button>
      </div>
      <div id="group-new-status" class="muted" style="min-height:14px;margin-top:4px;"></div>
    </div>
  `;
  while (root.firstChild) document.body.appendChild(root.firstChild);
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;
  const banner = document.getElementById("group-add-banner");
  function showBanner(text: string) {
    if (!banner) return;
    banner.textContent = text;
    banner.classList.add("open");
  }
  function hideBanner() {
    banner?.classList.remove("open");
  }

  const groupCategoryDocs = new Map<string, GroupCategory>();
  const groupDocs = new Map<string, Group>();
  const visibleGroups = new Set<string>();
  let expandedGroupId: string | null = null;

  // -------------------------------------------------------------------------
  // Mode "Ajouter pays sur la carte" (édition d'un groupe) — porté de
  // enterGroupAddMode/exitGroupAddMode/resolveEntitySelection (~8973-9012,
  // 8417-8424) : une fois activé pour un groupe, cliquer un pays SUR LA
  // CARTE l'ajoute (ou le retire, s'il est déjà membre) de ce groupe, au
  // lieu d'ouvrir sa fiche/son dossier. On en sort via le bouton (bascule),
  // Échap, ou la fermeture de l'éditeur de ce groupe.
  // -------------------------------------------------------------------------
  let mapAddModeGroupId: string | null = null;

  function enterMapAddMode(groupId: string) {
    deps.onBeforeMapAddMode?.();
    mapAddModeGroupId = groupId;
    deps.setMapAddCursor?.(true);
    const gr = groupDocs.get(groupId);
    showBanner(
      'Cliquez des pays sur la carte pour les ajouter (ou les retirer) de « ' + ((gr && gr.name) || groupId) + ' ». Échap pour arrêter.'
    );
    renderGroupsPanel();
  }
  function exitMapAddMode() {
    if (!mapAddModeGroupId) return;
    mapAddModeGroupId = null;
    deps.setMapAddCursor?.(false);
    hideBanner();
    renderGroupsPanel();
  }
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && mapAddModeGroupId) exitMapAddMode();
  });

  // Retour de Martin (2026-10-01) : tout compte connecté peut éditer
  // directement (plus de restriction admin-only ni "créateur seul" —
  // voir supabase/schema_v8.sql pour le pendant côté policies RLS).
  function isAdmin(): boolean {
    return !!deps.getSession();
  }
  function canModify(_row: { created_by: string | null }): boolean {
    return isAdmin();
  }

  // -------------------------------------------------------------------------
  // Chargement
  // -------------------------------------------------------------------------
  async function loadGroupCategories() {
    const { data } = await supabase.from("group_categories").select("id, name");
    groupCategoryDocs.clear();
    (data || []).forEach((row) => groupCategoryDocs.set(row.id, row as GroupCategory));
  }
  function groupCategoryName(id: string | null): string | null {
    if (!id) return null;
    const cat = groupCategoryDocs.get(id);
    return cat ? cat.name : null;
  }
  // Nouvelle catégorie de groupes créée depuis l'éditeur d'un groupe — porté
  // de addGroupCategory() (~4374-4383).
  async function addGroupCategory(name: string): Promise<string | null> {
    const session = deps.getSession();
    if (!session) return null;
    const id = "gcat-" + Date.now().toString(36) + "-" + Math.random().toString(36).slice(2, 8);
    groupCategoryDocs.set(id, { id, name });
    try {
      await supabase.from("group_categories").insert({ id, name, created_by: session.user.id });
    } catch {
      /* best-effort : la catégorie reste utilisable pour la session en cours */
    }
    return id;
  }
  async function loadGroups() {
    const [{ data: groupRows }, { data: memberRows }] = await Promise.all([
      supabase.from("groups").select("id, name, color, category_id, created_by"),
      supabase.from("group_members").select("group_id, country_id"),
    ]);
    groupDocs.clear();
    (groupRows || []).forEach((row) => {
      groupDocs.set(row.id, {
        id: row.id,
        name: row.name,
        color: row.color || "#e8b34a",
        category_id: row.category_id,
        created_by: row.created_by,
        members: new Set(),
      });
    });
    (memberRows || []).forEach((row) => {
      const g = groupDocs.get(row.group_id);
      if (g) g.members.add(row.country_id);
    });
  }

  // -------------------------------------------------------------------------
  // Semis initial (une seule fois) — porté de seedOrgGroups() : 4 catégories
  // + 14 groupes institutionnels/géopolitiques sourcés, chacun avec une
  // entrée "texte" dans son propre dossier reprenant le corps/les sources
  // documentés dans l'artifact.
  // -------------------------------------------------------------------------
  async function ensureSeed() {
    const { count } = await supabase.from("groups").select("id", { count: "exact", head: true });
    if (count && count > 0) return;
    const session = deps.getSession();
    if (!session) return;
    try {
      const seedRes = await fetch(import.meta.env.BASE_URL + "data/raw/ORG_GROUPS_SEED.json");
      const seed: OrgGroupSeedEntry[] = await seedRes.json();
      const slugToIsoA3 = new Map<string, string>();
      deps.getAllCountries().forEach((c) => slugToIsoA3.set(c.slug, c.isoA3));

      await supabase.from("group_categories").insert(
        GROUP_CATEGORY_DEFAULTS.map((c) => ({ id: c.id, name: c.name, created_by: session.user.id }))
      );
      for (const gDef of seed) {
        const { error: gErr } = await supabase.from("groups").insert({
          id: gDef.id,
          name: gDef.name,
          color: gDef.color,
          category_id: gDef.categoryId,
          created_by: session.user.id,
        });
        if (gErr) continue;
        const memberIsoA3 = gDef.members.map((slug) => slugToIsoA3.get(slug)).filter((x): x is string => !!x);
        for (const iso3 of memberIsoA3) await ensureCountryRow(iso3);
        if (memberIsoA3.length) {
          await supabase.from("group_members").insert(memberIsoA3.map((country_id) => ({ group_id: gDef.id, country_id })));
        }
        if (gDef.body) {
          await supabase.from("dossier_entries").insert({
            owner_type: "group",
            owner_id: gDef.id,
            type: "text",
            title: gDef.name,
            body_html: gDef.body,
            sources: gDef.sources || [],
            tags: ["Sourcé"],
            status: "published",
            created_by: session.user.id,
          });
        }
      }
    } catch {
      /* best-effort : en cas d'échec partiel, on retentera (count === 0) à la prochaine ouverture */
    }
  }

  // Un membre de groupe référence public.countries(id) — on garantit qu'une
  // ligne minimale existe avant l'insertion (la plupart des pays n'ont pas
  // encore de ligne dans `countries`, créée seulement à la première
  // sauvegarde de leur fiche).
  async function ensureCountryRow(isoA3: string) {
    const c = deps.getAllCountries().find((x) => x.isoA3 === isoA3);
    try {
      await supabase
        .from("countries")
        .upsert({ id: isoA3, name_fr: c ? frenchCountryName(c.name) : isoA3, continent: c?.continent || null }, { onConflict: "id", ignoreDuplicates: true });
    } catch {
      /* best-effort */
    }
  }

  // -------------------------------------------------------------------------
  // Panneau Groupes
  // -------------------------------------------------------------------------
  function populateNewGroupCategorySelect() {
    const sel = $("group-new-category") as HTMLSelectElement;
    const prev = sel.value;
    sel.innerHTML = '<option value="">— aucune catégorie —</option>';
    Array.from(groupCategoryDocs.entries())
      .sort((a, b) => a[1].name.localeCompare(b[1].name, "fr"))
      .forEach(([id, cat]) => {
        const opt = document.createElement("option");
        opt.value = id;
        opt.textContent = cat.name;
        sel.appendChild(opt);
      });
    sel.value = groupCategoryDocs.has(prev) ? prev : "";
  }

  // Sauvegarde différée (nom/couleur/catégorie) — même principe que
  // scheduleFicheSave() (~8572-8576, 400 ms de silence après la dernière
  // frappe/changement avant l'écriture).
  const saveMetaTimers = new Map<string, number>();
  function saveGroupMeta(groupId: string) {
    const existing = saveMetaTimers.get(groupId);
    if (existing) window.clearTimeout(existing);
    saveMetaTimers.set(
      groupId,
      window.setTimeout(async () => {
        saveMetaTimers.delete(groupId);
        const gr = groupDocs.get(groupId);
        if (!gr) return;
        try {
          await supabase.from("groups").update({ name: gr.name, color: gr.color, category_id: gr.category_id }).eq("id", groupId);
        } catch {
          /* best-effort */
        }
      }, 400)
    );
  }

  function populateGroupCategorySelect(sel: HTMLSelectElement, selectedId: string | null) {
    sel.innerHTML = '<option value="">— aucune —</option>';
    Array.from(groupCategoryDocs.entries())
      .sort((a, b) => a[1].name.localeCompare(b[1].name, "fr"))
      .forEach(([id, cat]) => {
        const opt = document.createElement("option");
        opt.value = id;
        opt.textContent = cat.name;
        sel.appendChild(opt);
      });
    sel.value = selectedId && groupCategoryDocs.has(selectedId) ? selectedId : "";
  }

  // Éditeur repliable d'un groupe existant — porté à la fois du formulaire
  // "fiche groupe" (nom/couleur/catégorie, ~1684-1694, 8378-8383, 8492-8511)
  // et de la gestion de ses membres (recherche + clic sur la carte,
  // ~1696-1700, 8881-9012).
  function renderGroupEditor(container: HTMLElement, groupId: string) {
    const gr = groupDocs.get(groupId);
    if (!gr) return;

    // --- Nom / couleur / catégorie -----------------------------------------
    const metaRow = document.createElement("div");
    metaRow.className = "group-editor-meta";
    const colorInput = document.createElement("input");
    colorInput.type = "color";
    colorInput.value = gr.color || "#e8b34a";
    colorInput.title = "Couleur du groupe";
    const nameInput = document.createElement("input");
    nameInput.type = "text";
    nameInput.value = gr.name || "";
    nameInput.placeholder = "Nom du groupe";
    const catSelect = document.createElement("select");
    populateGroupCategorySelect(catSelect, gr.category_id);
    const catNewBtn = document.createElement("button");
    catNewBtn.type = "button";
    catNewBtn.className = "btn-small";
    catNewBtn.title = "Nouvelle catégorie de groupes";
    catNewBtn.textContent = "+ nouvelle";
    const editable = canModify(gr);
    colorInput.disabled = nameInput.disabled = catSelect.disabled = catNewBtn.disabled = !editable;
    colorInput.addEventListener("input", () => {
      gr.color = colorInput.value;
      renderGroupsPanel();
      renderGroupHighlights();
      saveGroupMeta(groupId);
    });
    nameInput.addEventListener("input", () => {
      gr.name = nameInput.value;
      saveGroupMeta(groupId);
    });
    nameInput.addEventListener("blur", () => renderGroupsPanel());
    catSelect.addEventListener("change", () => {
      gr.category_id = catSelect.value || null;
      renderGroupsPanel();
      saveGroupMeta(groupId);
    });
    catNewBtn.addEventListener("click", async () => {
      // eslint-disable-next-line no-alert
      const name = (window.prompt("Nom de la nouvelle catégorie de groupes :") || "").trim();
      if (!name) return;
      const id = await addGroupCategory(name);
      gr.category_id = id;
      renderGroupsPanel();
      saveGroupMeta(groupId);
    });
    const nameLabel = document.createElement("label");
    nameLabel.className = "field-label";
    nameLabel.textContent = "Couleur & nom";
    const catLabel = document.createElement("label");
    catLabel.className = "field-label";
    catLabel.textContent = "Catégorie";
    metaRow.appendChild(nameLabel);
    const colorNameRow = document.createElement("div");
    colorNameRow.style.display = "flex";
    colorNameRow.style.gap = "6px";
    colorNameRow.appendChild(colorInput);
    colorNameRow.appendChild(nameInput);
    metaRow.appendChild(colorNameRow);
    metaRow.appendChild(catLabel);
    const catRow = document.createElement("div");
    catRow.style.display = "flex";
    catRow.style.gap = "6px";
    catRow.style.alignItems = "center";
    catSelect.style.flex = "1";
    catRow.appendChild(catSelect);
    catRow.appendChild(catNewBtn);
    metaRow.appendChild(catRow);
    container.appendChild(metaRow);

    // --- Membres -------------------------------------------------------------
    const membersLabel = document.createElement("label");
    membersLabel.className = "field-label";
    membersLabel.textContent = "Membres";
    container.appendChild(membersLabel);
    const chips = document.createElement("div");
    chips.className = "group-members-list";
    gr.members.forEach((iso3) => {
      const c = deps.getAllCountries().find((x) => x.isoA3 === iso3);
      const chip = document.createElement("span");
      chip.className = "member-chip";
      if (c) {
        const flagNode = flagSvgSpan(c.slug, c.iso2);
        if (flagNode) chip.appendChild(flagNode);
        chip.appendChild(document.createTextNode((flagNode ? " " : "") + frenchCountryName(c.name)));
      } else {
        chip.appendChild(document.createTextNode(iso3));
      }
      const rm = document.createElement("button");
      rm.type = "button";
      rm.textContent = "×";
      rm.title = "Retirer du groupe";
      rm.addEventListener("click", () => toggleMember(groupId, iso3, false));
      chip.appendChild(rm);
      chips.appendChild(chip);
    });
    container.appendChild(chips);

    // Mode "cliquer un pays sur la carte" — porté de #fiche-group-map-add
    // (~1698, 8981-9011).
    const mapAddBtn = document.createElement("button");
    mapAddBtn.type = "button";
    mapAddBtn.className = "btn-small" + (mapAddModeGroupId === groupId ? " active-mode" : "");
    mapAddBtn.style.marginBottom = "8px";
    mapAddBtn.textContent =
      mapAddModeGroupId === groupId ? "Terminé (cliquez des pays sur la carte)" : "\u{1F5FA} Ajouter pays sur la carte";
    mapAddBtn.addEventListener("click", () => {
      if (mapAddModeGroupId === groupId) exitMapAddMode();
      else enterMapAddMode(groupId);
    });
    container.appendChild(mapAddBtn);

    const input = document.createElement("input");
    input.type = "text";
    input.placeholder = "…ou rechercher un pays par nom";
    input.autocomplete = "off";
    container.appendChild(input);
    const results = document.createElement("div");
    results.id = "group-add-results-" + groupId;
    container.appendChild(results);
    input.addEventListener("input", () => {
      const q = normalize(input.value.trim());
      results.innerHTML = "";
      if (!q) return;
      const matches = deps
        .getAllCountries()
        .filter((c) => !gr.members.has(c.isoA3) && normalize(frenchCountryName(c.name)).includes(q))
        .slice(0, 8);
      matches.forEach((c) => {
        const btn = document.createElement("button");
        btn.type = "button";
        const flagNode = flagSvgSpan(c.slug, c.iso2);
        if (flagNode) btn.appendChild(flagNode);
        btn.appendChild(document.createTextNode((flagNode ? " " : "") + frenchCountryName(c.name)));
        btn.addEventListener("click", () => {
          toggleMember(groupId, c.isoA3, true);
          input.value = "";
          results.innerHTML = "";
        });
        results.appendChild(btn);
      });
    });

    // --- Liens (src/links.ts) -------------------------------------------
    // Même widget que celui injecté dans la fiche pays (deps.renderGroupLinks),
    // porté du bloc "Liens" de la fiche unifiée de l'artifact (~1730-1747),
    // les groupes faisant partie de LINKABLE_KINDS au même titre que les pays.
    const linksHost = document.createElement("div");
    container.appendChild(linksHost);
    deps.renderGroupLinks?.(linksHost, groupId, gr.name || groupId);
  }

  function buildGroupRow(id: string, gr: Group): HTMLElement {
    const wrap = document.createElement("div");
    wrap.className = "group-row-wrap";
    const row = document.createElement("div");
    row.className = "group-row";
    const cb = document.createElement("input");
    cb.type = "checkbox";
    cb.checked = visibleGroups.has(id);
    cb.addEventListener("change", (e) => {
      e.stopPropagation();
      if (cb.checked) visibleGroups.add(id);
      else visibleGroups.delete(id);
      renderGroupHighlights();
      deps.onVisibleGroupsChanged?.();
    });
    const dot = document.createElement("span");
    dot.className = "group-dot";
    dot.style.background = gr.color || "#999";
    const name = document.createElement("span");
    name.className = "group-name";
    name.style.cursor = "pointer";
    name.textContent = (gr.name || id) + " (" + gr.members.size + ")";
    name.title = "Ouvrir le dossier de ce groupe";
    name.addEventListener("click", (e) => {
      e.stopPropagation();
      if (deps.resolveGroupClickForLink?.(id, gr.name || id)) return;
      deps.openGroupDossier(id, gr.name || id, gr.color);
    });
    const toggle = document.createElement("button");
    toggle.type = "button";
    toggle.className = "group-members-toggle";
    toggle.title = "Modifier (nom, couleur, catégorie, membres)";
    toggle.textContent = expandedGroupId === id ? "▴" : "▾";
    toggle.addEventListener("click", (e) => {
      e.stopPropagation();
      if (expandedGroupId === id) {
        expandedGroupId = null;
        if (mapAddModeGroupId === id) exitMapAddMode();
        deps.onEditorClosed?.(id);
      } else {
        if (mapAddModeGroupId && mapAddModeGroupId !== id) exitMapAddMode();
        expandedGroupId = id;
      }
      renderGroupsPanel();
    });
    row.appendChild(cb);
    row.appendChild(dot);
    row.appendChild(name);
    row.appendChild(toggle);
    if (canModify(gr)) {
      const del = document.createElement("button");
      del.className = "group-del";
      del.textContent = "×";
      del.title = "Supprimer ce groupe";
      del.addEventListener("click", (e) => {
        e.stopPropagation();
        deleteGroup(id);
      });
      row.appendChild(del);
    }
    wrap.appendChild(row);
    if (expandedGroupId === id) {
      const editor = document.createElement("div");
      editor.className = "group-members-editor";
      renderGroupEditor(editor, id);
      wrap.appendChild(editor);
    }
    return wrap;
  }

  function renderGroupsPanel() {
    const list = $("groups-list");
    list.innerHTML = "";
    if (!groupDocs.size) {
      list.innerHTML = '<p class="muted">Aucun groupe. Créez-en un ci-dessous (ex. UE, OTAN, OPEP...).</p>';
      return;
    }
    const byCategory = new Map<string | null, [string, Group][]>();
    groupDocs.forEach((gr, id) => {
      const catId = gr.category_id && groupCategoryDocs.has(gr.category_id) ? gr.category_id : null;
      if (!byCategory.has(catId)) byCategory.set(catId, []);
      byCategory.get(catId)!.push([id, gr]);
    });
    const catIds = Array.from(byCategory.keys())
      .filter((c): c is string => c !== null)
      .sort((a, b) => (groupCategoryName(a) || "").localeCompare(groupCategoryName(b) || "", "fr"));
    const hasCategories = catIds.length > 0;
    catIds.forEach((catId) => {
      const header = document.createElement("div");
      header.className = "groups-cat-header";
      header.textContent = groupCategoryName(catId) || "";
      list.appendChild(header);
      byCategory.get(catId)!.forEach(([id, gr]) => list.appendChild(buildGroupRow(id, gr)));
    });
    if (byCategory.has(null)) {
      if (hasCategories) {
        const header = document.createElement("div");
        header.className = "groups-cat-header";
        header.textContent = "Sans catégorie";
        list.appendChild(header);
      }
      byCategory.get(null)!.forEach(([id, gr]) => list.appendChild(buildGroupRow(id, gr)));
    }
  }

  function newGroupId(): string {
    return "grp-" + Date.now().toString(36) + "-" + Math.random().toString(36).slice(2, 8);
  }

  // Appelé par main.ts au clic sur un pays de la carte, AVANT d'ouvrir sa
  // fiche/son dossier — porté de resolveEntitySelection() (~8417-8424) :
  // si le mode "ajouter sur la carte" est actif, le clic bascule
  // l'appartenance du pays au groupe édité et n'ouvre PAS sa fiche.
  function handleMapCountryClick(iso3: string): boolean {
    if (!mapAddModeGroupId) return false;
    const gr = groupDocs.get(mapAddModeGroupId);
    if (!gr) {
      exitMapAddMode();
      return false;
    }
    toggleMember(mapAddModeGroupId, iso3, !gr.members.has(iso3));
    return true;
  }

  async function toggleMember(groupId: string, iso3: string, add: boolean) {
    const gr = groupDocs.get(groupId);
    if (!gr) return;
    if (add) gr.members.add(iso3);
    else gr.members.delete(iso3);
    renderGroupsPanel();
    renderGroupHighlights();
    try {
      if (add) {
        await ensureCountryRow(iso3);
        await supabase.from("group_members").insert({ group_id: groupId, country_id: iso3 });
      } else {
        await supabase.from("group_members").delete().eq("group_id", groupId).eq("country_id", iso3);
      }
    } catch {
      /* best-effort : le retrait/ajout reste actif pour la session en cours */
    }
  }

  async function deleteGroup(id: string) {
    // eslint-disable-next-line no-alert
    if (!window.confirm("Supprimer ce groupe ?")) return;
    groupDocs.delete(id);
    visibleGroups.delete(id);
    if (expandedGroupId === id) expandedGroupId = null;
    if (mapAddModeGroupId === id) exitMapAddMode();
    renderGroupsPanel();
    renderGroupHighlights();
    try {
      await supabase.from("groups").delete().eq("id", id);
    } catch {
      /* ignore */
    }
  }

  $("groups-close").addEventListener("click", () => $("groups-panel").classList.remove("open"));
  $("group-new-add").addEventListener("click", async () => {
    const nameInput = $("group-new-name") as HTMLInputElement;
    const colorInput = $("group-new-color") as HTMLInputElement;
    const catSelect = $("group-new-category") as HTMLSelectElement;
    const status = $("group-new-status");
    const name = nameInput.value.trim();
    if (!name) return;
    const session = deps.getSession();
    if (!session) {
      status.textContent = "Connectez-vous pour créer un groupe.";
      return;
    }
    const color = colorInput.value || "#e8b34a";
    const categoryId = catSelect.value || null;
    const id = newGroupId();
    groupDocs.set(id, { id, name, color, category_id: categoryId, created_by: session.user.id, members: new Set() });
    visibleGroups.add(id);
    nameInput.value = "";
    renderGroupsPanel();
    status.textContent = "Enregistrement…";
    try {
      await supabase.from("groups").insert({ id, name, color, category_id: categoryId, created_by: session.user.id });
      status.textContent = "";
    } catch {
      status.textContent = "Non sauvegardé — réessayez plus tard (le groupe reste utilisable dans cette session).";
    }
  });

  // -------------------------------------------------------------------------
  // Calque carte — porté de renderGroupHighlights()/gGroups (~8941-8957).
  // -------------------------------------------------------------------------
  function renderGroupHighlights() {
    type Item = { id: string; color: string; feature: GeoJSON.Feature };
    const byIso = deps.getFeatureByIsoA3();
    const items: Item[] = [];
    groupDocs.forEach((gr, id) => {
      if (!visibleGroups.has(id)) return;
      gr.members.forEach((iso3) => {
        const f = byIso.get(iso3);
        if (f) items.push({ id: id + "__" + iso3, color: gr.color || "#e8b34a", feature: f });
      });
    });
    deps.gGroupsLayer
      .selectAll<SVGPathElement, Item>("path")
      .data(items, (d) => d.id)
      .join("path")
      .attr("class", "group-highlight")
      .attr("d", (d) => deps.geoPath(d.feature as unknown as GeoJSON.GeoJSON) || "")
      .style("fill", (d) => d.color)
      .style("stroke", (d) => d.color);
  }

  // -------------------------------------------------------------------------
  // Widget "Groupes" injecté dans la fiche pays (deps.renderFicheGroups de
  // dossier.ts) — porté de renderFicheGroups()/toggleCountryInGroup()
  // (~8801-8879), sans le repli/dépli séparé (toujours visible ici, la
  // fiche étant déjà scrollable) ni le mode "ajouter sur la carte".
  // -------------------------------------------------------------------------
  function renderFicheGroupsWidget(container: HTMLElement, country: { isoA3: string }) {
    container.innerHTML = "";
    const label = document.createElement("label");
    label.className = "field-label";
    label.textContent = "Groupes";
    container.appendChild(label);
    const chipsWrap = document.createElement("div");
    chipsWrap.className = "fiche-groups";
    const memberOf: [string, Group][] = [];
    groupDocs.forEach((gr, id) => {
      if (gr.members.has(country.isoA3)) memberOf.push([id, gr]);
    });
    memberOf.forEach(([id, gr]) => {
      const chip = document.createElement("span");
      chip.className = "member-chip";
      const dot = document.createElement("span");
      dot.className = "group-dot";
      dot.style.background = gr.color || "#999";
      chip.appendChild(dot);
      chip.appendChild(document.createTextNode(gr.name || id));
      const rm = document.createElement("button");
      rm.type = "button";
      rm.textContent = "×";
      rm.title = "Retirer de ce groupe";
      rm.addEventListener("click", () => {
        toggleMember(id, country.isoA3, false);
        renderFicheGroupsWidget(container, country);
      });
      chip.appendChild(rm);
      chipsWrap.appendChild(chip);
    });
    container.appendChild(chipsWrap);
    const select = document.createElement("select");
    const placeholder = document.createElement("option");
    placeholder.value = "";
    placeholder.textContent = groupDocs.size ? "— ajouter à un groupe —" : "Aucun groupe créé pour l’instant";
    select.appendChild(placeholder);
    groupDocs.forEach((gr, id) => {
      if (gr.members.has(country.isoA3)) return;
      const opt = document.createElement("option");
      opt.value = id;
      opt.textContent = gr.name || id;
      select.appendChild(opt);
    });
    select.disabled = !groupDocs.size;
    select.addEventListener("change", () => {
      if (!select.value) return;
      toggleMember(select.value, country.isoA3, true);
      renderFicheGroupsWidget(container, country);
    });
    container.appendChild(select);
  }

  // Le semis a besoin de traduire les slugs Natural Earth du fichier seed en
  // codes ISO A3 via deps.getAllCountries() — qui ne se peuple qu'après la
  // résolution asynchrone de SOV.json dans main.ts. On patiente (avec une
  // limite raisonnable) plutôt que de semer des groupes à 0 membre.
  async function waitForCountries() {
    for (let i = 0; i < 40 && deps.getAllCountries().length === 0; i++) {
      await new Promise((r) => setTimeout(r, 150));
    }
  }

  // -------------------------------------------------------------------------
  // Bootstrap
  // -------------------------------------------------------------------------
  const ready = (async () => {
    await loadGroupCategories();
    await waitForCountries();
    await ensureSeed();
    await loadGroups();
    if (groupCategoryDocs.size === 0) {
      // Seed n'a pas pu poser les catégories de base (hors-ligne / non connecté)
      GROUP_CATEGORY_DEFAULTS.forEach((c) => groupCategoryDocs.set(c.id, { id: c.id, name: c.name }));
    }
    populateNewGroupCategorySelect();
    renderGroupsPanel();
    renderGroupHighlights();
  })();

  return {
    ready,
    openPanel: () => {
      $("groups-panel").classList.add("open");
      populateNewGroupCategorySelect();
      renderGroupsPanel();
    },
    closePanel: () => $("groups-panel").classList.remove("open"),
    redrawHighlights: renderGroupHighlights,
    renderFicheGroups: renderFicheGroupsWidget,
    // Pour la recherche unifiée (src/search.ts) — porté de
    // buildGroupSearchEntries() : liste plate {id,name,color,members}.
    getGroupsList: (): { id: string; name: string; color: string; members: Set<string> }[] =>
      Array.from(groupDocs.entries()).map(([id, gr]) => ({ id, name: gr.name, color: gr.color, members: gr.members })),
    // Mode "ajouter pays sur la carte" — appelé par main.ts avant d'ouvrir la
    // fiche/le dossier d'un pays cliqué sur la carte (voir handleMapCountryClick
    // ci-dessus) ; renvoie true si le clic a été consommé par ce mode.
    handleMapCountryClick,
    isMapAddModeActive: () => mapAddModeGroupId !== null,
    exitMapAddMode,
  };
}
