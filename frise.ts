// ---------------------------------------------------------------------------
// Frises chronologiques — demande de Martin, 2026-10-06 : "Rajouter la
// possibilité de créer des frises chronologiques, un peu sur le même
// système que les arbres généalogiques, mais donc une frise. Chaque frise
// avec ses dates, et très important, l'intérêt est de rajouter des étapes
// sur la frise, soit un point (ex : traité de Verdun) ou une période entre
// 2 dates (ex : Saint Empire germanique) [...] les éléments des frises
// doivent êtres reliés à la fiche ou catégorie correspondante."
//
// Schéma : supabase/schema_v19.sql (timeline_items) — PAS ENCORE EXÉCUTÉ en
// production au moment de ce portage.
//
// Organisation (confirmée par Martin, clarification 2026-10-06) : "Possibilité
// de faire une frise par entrée, MAIS une frise globale se construit, en
// mettant tout bout à bout, et si je clique sur la partie d'une frise dans
// la frise globale, je suis amené vers la frise de l'entrée spécifique" —
// EXACTEMENT la même organisation que les arbres généalogiques
// (src/genealogy.ts) : une frise = tous les timeline_items qui partagent le
// même (owner_type="entry", owner_id=l'id de l'entrée dossier de type
// "frise"). La "frise globale" (vue fusionnée, tâche séparée) est une
// requête sur TOUTE la table, triée chronologiquement.
//
// Lien élément ↔ fiche/catégorie (confirmé "Les deux") :
// - AUTOMATIQUE : le titre de l'item est comparé (nom exact, insensible à
//   la casse) aux entités connues (pays, groupes, sous-catégories, entrées
//   texte) via deps.getLinkSearchEntries() — même esprit que
//   linkIndex.ts::findLinkTargetForName, mais étendu ici aux pays/groupes
//   (utile pour un item comme "Saint Empire romain" → pays "Allemagne").
//   Jamais stocké en base : recalculé à chaque rendu, donc "rétroactif"
//   comme le reste de l'auto-lien de l'app.
// - MANUEL : un override explicite, choisi via un petit sélecteur de
//   recherche (#tl-link-picker-modal, même pattern que la recherche de
//   membre étranger en généalogie), stocké dans timeline_items.link_target
//   (jsonb). Prioritaire sur l'automatique quand présent.
//
// Pattern du fichier : initTimelineSystem(deps) à l'identique de
// src/genealogy.ts/src/dossier.ts — DOM construit une fois et injecté dans
// document.body, jamais de framework.
// ---------------------------------------------------------------------------

import type { SupabaseClient, Session } from "@supabase/supabase-js";
import * as d3 from "d3";
import type { DossierOwnerRef } from "./dossier";
import { customConfirm } from "./dossier";
import { ensureLinkIndexLoaded, type LinkTarget, type LinkIndexEntry } from "./linkIndex";

// --- Types -------------------------------------------------------------

type ItemKind = "point" | "period";

type TimelineItemRow = {
  id: string;
  owner_type: string;
  owner_id: string;
  kind: ItemKind;
  title: string;
  description: string | null;
  start_year: number;
  end_year: number | null;
  date_label: string | null;
  color: string | null;
  link_target: LinkTarget | null;
  position: number;
  created_by: string | null;
};

// Pixels par année sur le canevas, à zoom 1 (voir GENERATION_GAP/PX_PER_YEAR
// de genealogy.ts pour l'équivalent) — assez large pour distinguer des
// événements à quelques années d'écart, raisonnable pour une frise courant
// sur plusieurs siècles sans dézoomer à l'extrême.
const PX_PER_YEAR = 6;
const LANE_HEIGHT = 92;
const POINT_W = 26;
const ITEM_MIN_W = 36;
const STAGE_TOP_PADDING = 70; // place pour la règle des années au-dessus des items

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function formatYear(y: number): string {
  const r = Math.round(y);
  return r < 0 ? Math.abs(r) + " av. J.-C." : String(r);
}

function parseYearInput(raw: string): number | null {
  const s = raw.trim().toLowerCase();
  if (!s) return null;
  const bc = /av\.?\s*j\.?-?c\.?/.test(s);
  const digits = s.replace(/[^0-9.-]/g, "");
  if (!digits) return null;
  const n = parseFloat(digits);
  if (Number.isNaN(n)) return null;
  return bc ? -Math.abs(n) : n;
}

function dateLabelOrYears(it: TimelineItemRow): string {
  if (it.date_label && it.date_label.trim()) return it.date_label.trim();
  if (it.kind === "period" && it.end_year != null) return formatYear(it.start_year) + " – " + formatYear(it.end_year);
  return formatYear(it.start_year);
}

export function initTimelineSystem(deps: {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  getProfile: () => { id: string; role: string } | null;
  openAuthPanel: () => void;
  showBanner?: (msg: string) => void;
  // Rattachement bidirectionnel item de frise ↔ fiche/sous-catégorie/pays/
  // groupe (demande de Martin, "Les deux") — résolution de navigation
  // déléguée à dossier.ts, même fonction que genealogy.ts::openLinkedFiche.
  openLinkedFiche: (target: LinkTarget) => Promise<void>;
  // Toutes les entités nommées connues (pays, groupes, sous-catégories,
  // entrées texte) — pour le lien automatique par nom ET pour le picker de
  // lien manuel (recherche). Même construction que dossier.ts::autoLinkEntryBody
  // (buildLinkIndexEntries), fournie par main.ts.
  getLinkSearchEntries: () => LinkIndexEntry[];
}) {
  const { supabase } = deps;
  function isAdmin(): boolean {
    return deps.getProfile()?.role === "admin" && !document.body.classList.contains("read-only-mode");
  }
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

  // --- DOM : construit une seule fois -------------------------------------
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="timeline-view">
      <div id="timeline-topbar">
        <button id="timeline-back" class="btn-small">&larr; Retour au dossier</button>
        <h2 id="timeline-title"></h2>
        <div id="timeline-toolbar">
          <button id="timeline-add-point" class="btn-small edit-control">&#43; Point</button>
          <button id="timeline-add-period" class="btn-small edit-control">&#43; P&eacute;riode</button>
          <button id="timeline-zoom-reset" class="btn-small">Recentrer</button>
        </div>
      </div>
      <div id="timeline-canvas-wrap">
        <div id="timeline-stage">
          <svg id="timeline-ruler-svg"></svg>
          <div id="timeline-items"></div>
        </div>
        <div id="timeline-empty-hint" class="muted">Aucune étape pour le moment. Utilisez "&#43; Point" ou "&#43; Période" pour commencer la frise.</div>
      </div>
    </div>

    <div id="tl-item-panel" class="panel side-panel">
      <button class="close-x" id="tl-item-close" aria-label="Fermer">&times;</button>
      <button type="button" id="tl-item-link-banner" class="genealogy-link-banner" style="display:none;"></button>
      <h2 id="tl-item-heading">Étape</h2>
      <label class="field-label">Titre</label>
      <input type="text" id="tl-i-title" maxlength="200" placeholder="ex. Traité de Verdun">
      <div id="tl-i-kind-row" class="dossier-form-actions">
        <label><input type="radio" name="tl-i-kind" id="tl-i-kind-point" value="point"> Point (une date)</label>
        <label><input type="radio" name="tl-i-kind" id="tl-i-kind-period" value="period"> Période (début &rarr; fin)</label>
      </div>
      <label class="field-label">Date de début (année, négatif = av. J.-C., ex. -753)</label>
      <input type="text" id="tl-i-start" inputmode="numeric" placeholder="ex. 843">
      <label class="field-label" id="tl-i-end-label">Date de fin (année)</label>
      <input type="text" id="tl-i-end" inputmode="numeric" placeholder="ex. 1806">
      <label class="field-label">Libellé de date affiché (optionnel, ex. "Août 843")</label>
      <input type="text" id="tl-i-date-label" maxlength="120" placeholder="laisser vide = dates ci-dessus">
      <label class="field-label">Couleur</label>
      <input type="color" id="tl-i-color" value="#5aa9e6">
      <label class="field-label">Description</label>
      <textarea id="tl-i-desc" rows="6"></textarea>
      <div id="tl-i-save-status" class="muted"></div>
      <div class="field-label" style="margin-top:8px;">Lien vers une fiche / catégorie</div>
      <div id="tl-i-link-auto" class="muted"></div>
      <div id="tl-i-link-manual" class="dossier-form-actions"></div>
      <div class="dossier-form-actions" style="margin-top:10px;">
        <button id="tl-i-delete" class="btn-small">Supprimer</button>
      </div>
    </div>

    <div id="tl-link-picker-modal" class="poi-overlay">
      <div class="poi-overlay-box">
        <h3>Choisir le lien de cette &eacute;tape</h3>
        <input type="text" id="tl-link-picker-input" placeholder="Rechercher un pays, un groupe, une fiche…" autocomplete="off">
        <div id="tl-link-picker-results"></div>
        <button id="tl-link-picker-cancel" class="btn-small" style="margin-top:10px;">Annuler</button>
      </div>
    </div>
  `;
  document.body.appendChild(root);

  // --- État ----------------------------------------------------------------
  let currentOwner: DossierOwnerRef | null = null;
  let items: TimelineItemRow[] = [];
  const laneOf = new Map<string, number>();
  let editingItemId: string | null = null;
  let pendingNewKind: ItemKind | null = null;

  let zoomTransform = d3.zoomIdentity;
  const stage = $("timeline-stage");
  const canvasWrap = $("timeline-canvas-wrap");
  const ruler = $("timeline-ruler-svg") as unknown as SVGSVGElement;
  const itemsLayer = $("timeline-items");

  const zoomBehavior = d3
    .zoom<HTMLDivElement, unknown>()
    .scaleExtent([0.08, 6])
    .filter((event: Event) => {
      if (event.type === "mousedown" || event.type === "touchstart") {
        return !(event.target as HTMLElement).closest(".tl-item");
      }
      return true;
    })
    .on("zoom", (event: d3.D3ZoomEvent<HTMLDivElement, unknown>) => {
      zoomTransform = event.transform;
      stage.style.transform = "translate(" + zoomTransform.x + "px," + zoomTransform.y + "px) scale(" + zoomTransform.k + ")";
      renderRuler();
    });
  d3.select(canvasWrap as unknown as HTMLDivElement).call(zoomBehavior);

  function resetView() {
    // Centre la vue sur l'année actuelle si rien n'a de date proche, sinon
    // sur la moyenne des dates existantes — plus utile que de toujours
    // repartir de l'an 0.
    let centerYear = new Date().getFullYear();
    if (items.length) {
      const sum = items.reduce((acc, it) => acc + (it.start_year + (it.end_year ?? it.start_year)) / 2, 0);
      centerYear = sum / items.length;
    }
    const x = canvasWrap.clientWidth / 2 - centerYear * PX_PER_YEAR;
    const y = STAGE_TOP_PADDING + 20;
    zoomTransform = d3.zoomIdentity.translate(x, y);
    d3.select(canvasWrap as unknown as HTMLDivElement).call(zoomBehavior.transform, zoomTransform);
  }

  function requireAuthOr(action: () => void) {
    if (!deps.getSession()) {
      deps.openAuthPanel();
      return;
    }
    if (!isAdmin()) {
      deps.showBanner?.("Tu n'as pas les droits d'édition sur cet atlas.");
      return;
    }
    action();
  }

  // --- Chargement ------------------------------------------------------------
  async function loadData(owner: DossierOwnerRef) {
    itemsLayer.innerHTML = "";
    ruler.innerHTML = "";
    $("timeline-empty-hint").style.display = "none";
    items = [];
    try {
      const { data, error } = await supabase
        .from("timeline_items")
        .select("id, owner_type, owner_id, kind, title, description, start_year, end_year, date_label, color, link_target, position, created_by")
        .eq("owner_type", owner.type)
        .eq("owner_id", owner.id)
        .order("start_year", { ascending: true });
      if (error) throw error;
      items = (data as TimelineItemRow[] | null) || [];
    } catch (err) {
      console.error("Échec du chargement de la frise (schema_v19.sql exécutée ? réseau indisponible ?) :", err);
      items = [];
    }
    assignLanes();
    renderAll();
    if (!items.length) $("timeline-empty-hint").style.display = "";
  }

  // Évite que deux étapes qui se chevauchent en années se superposent à
  // l'écran : greedy, items triés par début, chaque item va dans la
  // première "voie" (lane) libre à ce moment-là (comme un diagramme de
  // Gantt simple).
  function assignLanes() {
    laneOf.clear();
    const laneEndYear: number[] = [];
    const sorted = items.slice().sort((a, b) => a.start_year - b.start_year);
    sorted.forEach((it) => {
      const endY = it.kind === "period" && it.end_year != null ? it.end_year : it.start_year;
      let lane = 0;
      for (; lane < laneEndYear.length; lane++) {
        if (laneEndYear[lane] + 6 < it.start_year) break;
      }
      laneEndYear[lane] = endY;
      laneOf.set(it.id, lane);
    });
  }

  function xForYear(year: number): number {
    return year * PX_PER_YEAR;
  }
  function yearForX(x: number): number {
    return x / PX_PER_YEAR;
  }

  // --- Rendu -----------------------------------------------------------------
  function renderAll() {
    renderItems();
    renderRuler();
  }

  function autoLinkFor(title: string): LinkTarget | null {
    const key = (title || "").trim().toLowerCase();
    if (key.length < 2) return null;
    const entry = deps.getLinkSearchEntries().find((e) => e.label.trim().toLowerCase() === key);
    return entry ? entry.target : null;
  }
  function effectiveLink(it: TimelineItemRow): LinkTarget | null {
    return it.link_target || autoLinkFor(it.title);
  }
  function linkLabelFor(target: LinkTarget): string {
    const found = deps.getLinkSearchEntries().find((e) => JSON.stringify(e.target) === JSON.stringify(target));
    return found ? found.label : "Fiche liée";
  }

  function renderItems() {
    itemsLayer.innerHTML = "";
    items.forEach((it) => {
      const lane = laneOf.get(it.id) || 0;
      const top = lane * LANE_HEIGHT;
      const link = effectiveLink(it);
      const card = document.createElement("div");
      card.dataset.itemId = it.id;
      card.style.top = top + "px";
      card.style.borderColor = it.color || "var(--accent)";
      if (it.kind === "point") {
        const x = xForYear(it.start_year);
        card.className = "tl-item tl-item-point" + (link ? " tl-item-linked" : "");
        card.style.left = x - POINT_W / 2 + "px";
        card.style.width = POINT_W + "px";
        card.innerHTML =
          '<div class="tl-point-dot" style="background:' + escapeHtml(it.color || "var(--accent)") + ';"></div>' +
          '<div class="tl-point-label">' + escapeHtml(it.title) + '<span class="tl-item-date">' + escapeHtml(dateLabelOrYears(it)) + "</span></div>";
      } else {
        const x1 = xForYear(it.start_year);
        const x2 = xForYear(it.end_year ?? it.start_year);
        const w = Math.max(ITEM_MIN_W, x2 - x1);
        card.className = "tl-item tl-item-period" + (link ? " tl-item-linked" : "");
        card.style.left = x1 + "px";
        card.style.width = w + "px";
        card.innerHTML =
          '<div class="tl-period-bar" style="background:' + escapeHtml(it.color || "var(--accent)") + ';"></div>' +
          '<div class="tl-period-label">' + escapeHtml(it.title) + '<span class="tl-item-date">' + escapeHtml(dateLabelOrYears(it)) + "</span></div>" +
          '<div class="tl-handle tl-handle-l" data-handle="start"></div>' +
          '<div class="tl-handle tl-handle-r" data-handle="end"></div>';
      }
      itemsLayer.appendChild(card);
      attachItemInteractions(card, it);
    });
  }

  // Règle des années — recalculée à chaque pan/zoom (voir le callback de
  // zoomBehavior plus haut) : convertit les bords visibles de l'écran en
  // années via l'inverse de zoomTransform, choisit un pas "rond" selon le
  // niveau de zoom, dessine une ligne verticale + le libellé d'année à
  // chaque graduation.
  function renderRuler() {
    ruler.innerHTML = "";
    const w = canvasWrap.clientWidth || 800;
    const h = canvasWrap.clientHeight || 600;
    ruler.setAttribute("width", String(w));
    ruler.setAttribute("height", String(h));
    const k = zoomTransform.k;
    const screenToDataX = (sx: number) => (sx - zoomTransform.x) / k;
    const yearLeft = yearForX(screenToDataX(0));
    const yearRight = yearForX(screenToDataX(w));
    const pxPerYearEff = PX_PER_YEAR * k;
    const steps = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000];
    let step = steps[steps.length - 1];
    for (const s of steps) {
      if (s * pxPerYearEff >= 90) {
        step = s;
        break;
      }
    }
    const first = Math.floor(yearLeft / step) * step;
    const NS = "http://www.w3.org/2000/svg";
    for (let y = first; y <= yearRight + step; y += step) {
      const sx = xForYear(y) * k + zoomTransform.x;
      const line = document.createElementNS(NS, "line");
      line.setAttribute("x1", String(sx));
      line.setAttribute("x2", String(sx));
      line.setAttribute("y1", "0");
      line.setAttribute("y2", String(h));
      line.setAttribute("class", "tl-ruler-line");
      ruler.appendChild(line);
      const label = document.createElementNS(NS, "text");
      label.setAttribute("x", String(sx + 4));
      label.setAttribute("y", "18");
      label.setAttribute("class", "tl-ruler-label");
      label.textContent = formatYear(y);
      ruler.appendChild(label);
    }
    // Ligne "aujourd'hui"
    const todaySx = xForYear(new Date().getFullYear()) * k + zoomTransform.x;
    if (todaySx >= -50 && todaySx <= w + 50) {
      const line = document.createElementNS(NS, "line");
      line.setAttribute("x1", String(todaySx));
      line.setAttribute("x2", String(todaySx));
      line.setAttribute("y1", "0");
      line.setAttribute("y2", String(h));
      line.setAttribute("class", "tl-ruler-today");
      ruler.appendChild(line);
    }
  }

  // --- Interactions (clic / glisser) ------------------------------------------
  function attachItemInteractions(card: HTMLDivElement, item: TimelineItemRow) {
    let moved = false;
    let dragMode: "move" | "start" | "end" | null = null;
    let startScreenX = 0;
    let startYearStart = 0;
    let startYearEnd = 0;

    function beginDrag(e: MouseEvent | TouchEvent, mode: "move" | "start" | "end") {
      if (!isAdmin()) return;
      moved = false;
      dragMode = mode;
      const p = "touches" in e ? e.touches[0] : e;
      startScreenX = p.clientX;
      startYearStart = item.start_year;
      startYearEnd = item.end_year ?? item.start_year;
      document.addEventListener("mousemove", onMove);
      document.addEventListener("mouseup", onEnd);
      document.addEventListener("touchmove", onMove, { passive: true });
      document.addEventListener("touchend", onEnd);
    }
    function onMove(e: MouseEvent | TouchEvent) {
      const p = "touches" in e ? e.touches[0] : e;
      const dx = (p.clientX - startScreenX) / zoomTransform.k;
      const dYears = dx / PX_PER_YEAR;
      if (Math.abs(dx) > 3) moved = true;
      if (dragMode === "move") {
        const dur = startYearEnd - startYearStart;
        item.start_year = startYearStart + dYears;
        if (item.kind === "period") item.end_year = item.start_year + dur;
      } else if (dragMode === "start") {
        item.start_year = Math.min(startYearStart + dYears, startYearEnd - 1);
      } else if (dragMode === "end") {
        item.end_year = Math.max(startYearEnd + dYears, item.start_year + 1);
      }
      assignLanes();
      renderItems();
    }
    async function onEnd() {
      document.removeEventListener("mousemove", onMove);
      document.removeEventListener("mouseup", onEnd);
      document.removeEventListener("touchmove", onMove);
      document.removeEventListener("touchend", onEnd);
      if (moved) {
        item.start_year = Math.round(item.start_year * 100) / 100;
        if (item.end_year != null) item.end_year = Math.round(item.end_year * 100) / 100;
        await supabase.from("timeline_items").update({ start_year: item.start_year, end_year: item.end_year ?? null }).eq("id", item.id);
        renderItems();
        if (editingItemId === item.id) {
          ($("tl-i-start") as HTMLInputElement).value = formatYear(item.start_year);
          if (item.end_year != null) ($("tl-i-end") as HTMLInputElement).value = formatYear(item.end_year);
        }
      }
      dragMode = null;
    }
    card.addEventListener("mousedown", (e) => {
      const handle = (e.target as HTMLElement).closest(".tl-handle") as HTMLElement | null;
      beginDrag(e, handle ? (handle.dataset.handle as "start" | "end") : "move");
    });
    card.addEventListener("touchstart", (e) => {
      const handle = (e.target as HTMLElement).closest(".tl-handle") as HTMLElement | null;
      beginDrag(e, handle ? (handle.dataset.handle as "start" | "end") : "move");
    });
    card.addEventListener("click", () => {
      if (moved) return;
      openItemPanel(item.id);
    });
  }

  // --- Panneau étape (création / édition) -------------------------------------
  let manualLinkDraft: LinkTarget | null = null;
  function renderLinkSections(it: TimelineItemRow | null) {
    // Le titre vient toujours du champ (pas de it.title) : pour une étape
    // PAS ENCORE créée (it === null, premières frappes dans un nouveau
    // panneau), it.title n'existe pas, mais le lien automatique doit déjà
    // pouvoir se calculer sur ce qui est tapé.
    const autoTarget = autoLinkFor(($("tl-i-title") as HTMLInputElement).value || it?.title || "");
    const autoEl = $("tl-i-link-auto");
    autoEl.textContent = autoTarget && !manualLinkDraft ? "Lien automatique (par nom) → " + linkLabelFor(autoTarget) : autoTarget ? "(lien automatique disponible, mais un lien manuel est actif)" : "Aucun lien automatique trouvé pour ce titre.";
    const manualEl = $("tl-i-link-manual");
    manualEl.innerHTML = "";
    const pickBtn = document.createElement("button");
    pickBtn.className = "btn-small";
    pickBtn.textContent = manualLinkDraft ? "Changer le lien manuel (" + linkLabelFor(manualLinkDraft) + ")" : "Choisir un lien manuel";
    pickBtn.addEventListener("click", () => openLinkPicker());
    manualEl.appendChild(pickBtn);
    if (manualLinkDraft) {
      const clearBtn = document.createElement("button");
      clearBtn.className = "btn-small";
      clearBtn.textContent = "Retirer le lien manuel";
      clearBtn.addEventListener("click", () => {
        manualLinkDraft = null;
        void persistField("link_target", null);
        renderLinkSections(editingItemId ? items.find((x) => x.id === editingItemId) || null : null);
      });
      manualEl.appendChild(clearBtn);
    }
    const bannerBtn = $("tl-item-link-banner") as HTMLButtonElement;
    const effective = manualLinkDraft || autoTarget;
    if (effective) {
      bannerBtn.style.display = "flex";
      bannerBtn.textContent = "📄 Voir « " + linkLabelFor(effective) + " » →";
      bannerBtn.onclick = () => void deps.openLinkedFiche(effective);
    } else {
      bannerBtn.style.display = "none";
      bannerBtn.onclick = null;
    }
  }
  function openLinkPicker() {
    const modal = $("tl-link-picker-modal");
    const input = $("tl-link-picker-input") as HTMLInputElement;
    const results = $("tl-link-picker-results");
    input.value = "";
    function renderResults() {
      const q = input.value.trim().toLowerCase();
      const entries = deps.getLinkSearchEntries();
      const matches = (q.length >= 1 ? entries.filter((e) => e.label.toLowerCase().includes(q)) : entries.slice(0, 40)).slice(0, 40);
      results.innerHTML = "";
      matches.forEach((e) => {
        const row = document.createElement("button");
        row.type = "button";
        row.className = "btn-small gen-foreign-result";
        row.style.cssText = "display:block;width:100%;text-align:left;margin-top:4px;";
        row.textContent = e.label;
        row.addEventListener("click", () => {
          manualLinkDraft = e.target;
          void persistField("link_target", e.target);
          modal.classList.remove("open");
          renderLinkSections(editingItemId ? items.find((x) => x.id === editingItemId) || null : null);
        });
        results.appendChild(row);
      });
      if (!matches.length) results.innerHTML = '<p class="muted">Aucun résultat.</p>';
    }
    input.oninput = renderResults;
    renderResults();
    modal.classList.add("open");
    setTimeout(() => input.focus(), 30);
  }
  $("tl-link-picker-cancel").addEventListener("click", () => $("tl-link-picker-modal").classList.remove("open"));

  function setKindUI(kind: ItemKind) {
    (($("tl-i-kind-point") as HTMLInputElement)).checked = kind === "point";
    (($("tl-i-kind-period") as HTMLInputElement)).checked = kind === "period";
    $("tl-i-end-label").style.display = kind === "period" ? "" : "none";
    ($("tl-i-end") as HTMLInputElement).style.display = kind === "period" ? "" : "none";
  }

  // Enregistrement en temps réel, champ par champ (demande constante de
  // Martin dans les autres modules de cet atlas : "tout doit se faire en
  // temps réel à chaque modification") — crée l'étape à la première
  // modification si elle n'existe pas encore (voir autoCreateIfNeeded).
  async function autoCreateIfNeeded(): Promise<string | null> {
    if (editingItemId) return editingItemId;
    if (!currentOwner || !isAdmin() || !pendingNewKind) return null;
    const session = deps.getSession();
    const title = ($("tl-i-title") as HTMLInputElement).value.trim() || (pendingNewKind === "point" ? "Nouveau point" : "Nouvelle période");
    const startYear = parseYearInput(($("tl-i-start") as HTMLInputElement).value) ?? new Date().getFullYear();
    const endYear = pendingNewKind === "period" ? parseYearInput(($("tl-i-end") as HTMLInputElement).value) ?? startYear + 10 : null;
    const { data, error } = await supabase
      .from("timeline_items")
      .insert({
        owner_type: currentOwner.type,
        owner_id: currentOwner.id,
        kind: pendingNewKind,
        title,
        description: null,
        start_year: startYear,
        end_year: endYear,
        date_label: null,
        color: ($("tl-i-color") as HTMLInputElement).value,
        link_target: null,
        position: items.length,
        created_by: session?.user.id || null,
      })
      .select("id, owner_type, owner_id, kind, title, description, start_year, end_year, date_label, color, link_target, position, created_by")
      .single();
    if (error || !data) {
      deps.showBanner?.("Erreur lors de la création de l'étape.");
      return null;
    }
    const row = data as TimelineItemRow;
    items.push(row);
    editingItemId = row.id;
    pendingNewKind = null;
    assignLanes();
    renderAll();
    return row.id;
  }
  async function persistField(field: string, value: unknown) {
    const id = await autoCreateIfNeeded();
    if (!id || !isAdmin()) return;
    const it = items.find((x) => x.id === id);
    if (!it) return;
    (it as unknown as Record<string, unknown>)[field] = value;
    try {
      await supabase.from("timeline_items").update({ [field]: value }).eq("id", id);
      $("tl-i-save-status").textContent = "Enregistré ✓";
    } catch {
      $("tl-i-save-status").textContent = "Erreur d'enregistrement";
    }
    assignLanes();
    renderAll();
  }
  function wireAutosaveText(id: string, field: string, parse?: (raw: string) => unknown) {
    const el = $(id) as HTMLInputElement | HTMLTextAreaElement;
    el.addEventListener("blur", () => {
      const raw = el.value;
      void persistField(field, parse ? parse(raw) : raw.trim() || null);
    });
  }

  function openItemPanel(id: string | null, presetKind?: ItemKind) {
    editingItemId = id;
    pendingNewKind = id ? null : presetKind || "point";
    manualLinkDraft = null;
    const it = id ? items.find((x) => x.id === id) || null : null;
    if (it) manualLinkDraft = it.link_target;
    $("tl-item-heading").textContent = it ? "Modifier l'étape" : pendingNewKind === "period" ? "Nouvelle période" : "Nouveau point";
    ($("tl-i-title") as HTMLInputElement).value = it?.title || "";
    const kind = it?.kind || pendingNewKind || "point";
    setKindUI(kind);
    ($("tl-i-start") as HTMLInputElement).value = it ? formatYear(it.start_year) : "";
    ($("tl-i-end") as HTMLInputElement).value = it?.end_year != null ? formatYear(it.end_year) : "";
    ($("tl-i-date-label") as HTMLInputElement).value = it?.date_label || "";
    ($("tl-i-color") as HTMLInputElement).value = it?.color || "#5aa9e6";
    ($("tl-i-desc") as HTMLTextAreaElement).value = it?.description || "";
    $("tl-i-save-status").textContent = "";
    const canEdit = isAdmin();
    ([
      "tl-i-title", "tl-i-start", "tl-i-end", "tl-i-date-label", "tl-i-color", "tl-i-desc",
    ] as const).forEach((fid) => (($(fid) as HTMLInputElement | HTMLTextAreaElement).disabled = !canEdit));
    (($("tl-i-kind-point") as HTMLInputElement)).disabled = !canEdit;
    (($("tl-i-kind-period") as HTMLInputElement)).disabled = !canEdit;
    ($("tl-i-delete") as HTMLButtonElement).style.display = it && canEdit ? "" : "none";
    renderLinkSections(it);
    $("tl-item-panel").classList.add("open");
  }
  function closeItemPanel() {
    $("tl-item-panel").classList.remove("open");
    editingItemId = null;
    pendingNewKind = null;
    manualLinkDraft = null;
  }
  $("tl-item-close").addEventListener("click", closeItemPanel);

  // Rafraîchit le lien automatique affiché À CHAQUE frappe (pas seulement
  // au blur, qui déclenche l'enregistrement réel) — sinon le libellé
  // "Lien automatique..." reste basé sur le titre tel qu'il était à
  // l'ouverture du panneau (vide pour une nouvelle étape) jusqu'au départ
  // du focus, ce qui donnait l'impression à tort qu'aucun lien n'existe.
  ($("tl-i-title") as HTMLInputElement).addEventListener("input", () => {
    renderLinkSections(editingItemId ? items.find((x) => x.id === editingItemId) || null : null);
  });
  wireAutosaveText("tl-i-title", "title");
  wireAutosaveText("tl-i-start", "start_year", (raw) => parseYearInput(raw) ?? 0);
  wireAutosaveText("tl-i-end", "end_year", (raw) => parseYearInput(raw));
  wireAutosaveText("tl-i-date-label", "date_label", (raw) => raw.trim() || null);
  wireAutosaveText("tl-i-desc", "description", (raw) => raw.trim() || null);
  ($("tl-i-color") as HTMLInputElement).addEventListener("change", (e) => {
    void persistField("color", (e.target as HTMLInputElement).value);
  });
  ($("tl-i-kind-point") as HTMLInputElement).addEventListener("change", () => {
    setKindUI("point");
    void persistField("kind", "point").then(() => persistField("end_year", null));
  });
  ($("tl-i-kind-period") as HTMLInputElement).addEventListener("change", () => {
    setKindUI("period");
    const it = editingItemId ? items.find((x) => x.id === editingItemId) : null;
    const startY = it ? it.start_year : parseYearInput(($("tl-i-start") as HTMLInputElement).value) ?? new Date().getFullYear();
    void persistField("kind", "period").then(() => persistField("end_year", startY + 10));
  });
  $("tl-i-delete").addEventListener("click", async () => {
    if (!editingItemId || !isAdmin()) return;
    if (!(await customConfirm("Supprimer cette étape de la frise ?"))) return;
    await supabase.from("timeline_items").delete().eq("id", editingItemId);
    items = items.filter((x) => x.id !== editingItemId);
    closeItemPanel();
    assignLanes();
    renderAll();
    if (!items.length) $("timeline-empty-hint").style.display = "";
  });

  $("timeline-add-point").addEventListener("click", () => requireAuthOr(() => openItemPanel(null, "point")));
  $("timeline-add-period").addEventListener("click", () => requireAuthOr(() => openItemPanel(null, "period")));
  $("timeline-zoom-reset").addEventListener("click", () => resetView());
  $("timeline-back").addEventListener("click", () => {
    $("timeline-view").classList.remove("open");
    closeItemPanel();
  });

  async function openForOwner(owner: DossierOwnerRef) {
    currentOwner = owner;
    $("timeline-title").textContent = "Frise — " + owner.label;
    $("timeline-view").classList.add("open");
    closeItemPanel();
    // Rafraîchit l'index de liens (voir le même appel dans
    // genealogy.ts::openForOwner/dossier.ts::openDossierForOwner) — pour
    // que le lien automatique par nom tienne compte des sections/entrées
    // créées ailleurs depuis la dernière ouverture d'une frise.
    void ensureLinkIndexLoaded(supabase, true);
    await loadData(owner);
    resetView();
  }
  function focusItem(itemId: string) {
    openItemPanel(itemId);
  }
  function closeView() {
    $("timeline-view").classList.remove("open");
    closeItemPanel();
  }

  return {
    openForOwner,
    focusItem,
    closeView,
  };
}
