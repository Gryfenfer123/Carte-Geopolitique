// ---------------------------------------------------------------------------
// Fiche pays + système de dossier (catégories / sous-sections / entrées
// texte-photo-lien), porté de l'artifact source (realistic_final.html) :
// openFiche/closeFiche/flushFicheSave (~8319-8579), loadDossierCategories/
// addDossierCategory/deleteDossierCategory (~5353-5514), loadDossierSections/
// addDossierSection/addChildDossierSection/deleteDossierSection
// (~5145-5270, 6343-6351), loadDossierEntries/addDossierEntry/
// updateDossierEntry/deleteDossierEntry + historique (~5671-5694,
// 6395-6491, 6725-6738), buildDossierEntryEl/buildSectionGroupEl
// (~5694-6341), openDossierEntryReadView/closeDossierEntryReadView
// (~6888-6918), et l'éditeur de texte riche (~7846-8299).
//
// Différences assumées par rapport à l'artifact (voir le rapport de
// portage) : pas de groupes/notions/Encyclopédie/hémicycle/recherche/export
// PDF/glisser-déposer/images de couverture — hors périmètre de cette étape
// (indiqué explicitement dans la consigne de portage). Les entrées photo
// sont limitées à UNE photo par entrée (le schéma Supabase n'a qu'une
// colonne photo_url ; la galerie multi-photos de l'artifact n'est pas
// portée). Les entrées de type "file" (pièce jointe) n'existent pas non
// plus : le schéma dossier_entries.type ne les prévoit pas.
// ---------------------------------------------------------------------------

import type { SupabaseClient } from "@supabase/supabase-js";
import type { Session } from "@supabase/supabase-js";
import {
  sanitizeDossierHTML,
  entryPlainText,
  wordCountForEntry,
  readingTimeMinutes,
  extractYouTubeId,
  type DossierEntryLike,
} from "./sanitize";
import { loadCountryNameData, frenchCountryName, flagSvgSpan } from "./countryNames";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type CountryRef = {
  isoA3: string; // owner_id en base (dossier_entries/sections) + clé de public.countries
  slug: string; // pour FR_NAMES / drapeaux (slugify(NAME), ex. "france")
  name: string; // nom anglais Natural Earth (repli si pas de traduction)
  continent: string;
  iso2: string | null;
};

// Propriétaire générique d'un dossier plein écran — porté du concept unique
// de "slug" de dossier dans l'artifact (currentDossierSlug : un nom de pays,
// 'encyclopedie', ou 'group:<id>'), éclaté ici en (type, id) pour coller au
// modèle owner_type/owner_id déjà en place dans dossier_sections/
// dossier_entries (schema_v1). categorySpace choisit l'espace de
// dossier_categories à utiliser : les dossiers pays ET groupes partagent le
// même espace 'country' (comme dans l'artifact, où dossierCategories est une
// collection globale unique) ; l'Encyclopédie a son propre espace
// 'encyclopedie' (catégories Sociologie/Économie/Philosophie/Sciences/
// Histoire des idées/Relations internationales).
// Étendu par rapport aux 3 types initiaux (country/group/encyclopedie) pour
// couvrir les "mini-dossiers" — port/strait/pipeline/base/cable — portés de
// miniDossierId(kind,id) dans l'artifact source (recherche unifiée,
// ~10894-10899) : chaque entité d'infrastructure a elle aussi son propre
// dossier plein écran (owner_type=<kind>, owner_id=<slug>), au même titre
// qu'un pays ou un groupe. Le schéma Supabase (schema_v4.sql,
// dossier_sections_owner_type_check / dossier_entries_owner_type_check)
// accepte déjà ces valeurs.
// "entry" (2026-10-03, point 2) : owner d'un arbre généalogique qui vit
// désormais dans une ENTRÉE du dossier (type "genealogy", voir EntryType
// plus bas) plutôt que d'être unique par pays/groupe — un dossier peut
// ainsi avoir plusieurs arbres indépendants (un par dynastie/section). Le
// genealogy_members.owner_id correspondant est alors l'id de l'entrée.
export type DossierOwnerKind = "country" | "group" | "encyclopedie" | "port" | "strait" | "pipeline" | "base" | "cable" | "entry";
export type MiniDossierKind = "port" | "strait" | "pipeline" | "base" | "cable";
export type DossierOwnerRef = {
  type: DossierOwnerKind;
  id: string;
  label: string;
  categorySpace: "country" | "encyclopedie";
  flagSlug?: string;
  iso2?: string | null;
  colorDot?: string;
};

// image_url/image_position (catégories) et cover_image_url/image_position
// (sections) : schema_v10.sql (2026-10-02) — image + cadrage ("object-
// position" CSS, ex. "50% 30%") sur les bannières de thème et de
// sous-section. image_url n'existait pas avant sur dossier_categories ;
// cover_image_url existait déjà sur dossier_sections depuis schema_v1 mais
// n'était lu/écrit par aucun code applicatif avant cette session.
type Category = { id: string; name: string; builtin: boolean; created_by: string | null; image_url: string | null; image_position: string };
type Section = {
  id: string;
  category_id: string;
  parent_section_id: string | null;
  name: string;
  collapsed: boolean;
  position: number;
  created_by: string | null;
  countries: string[]; // pays de référence associés (notions de l'Encyclopédie uniquement)
  cover_image_url: string | null;
  image_position: string;
};
type SourceRef = { label: string; url: string };
export type HemicycleParty = { name: string; color: string; seats: number };
export type HemicycleData = {
  title?: string;
  parties: HemicycleParty[];
  totalSeats?: number | null;
  source?: string;
};
type HistoryVersion = {
  title?: string;
  body?: string;
  caption?: string;
  label?: string;
  url?: string;
  hemicycle?: HemicycleData;
  archivedAt: number;
};
type EntryType = "text" | "photo" | "link" | "hemicycle" | "genealogy";
type Entry = {
  id: string;
  type: EntryType;
  title: string | null;
  body: string | null;
  photo_url: string | null;
  caption: string | null;
  link_url: string | null;
  label: string | null;
  hemicycle: HemicycleData | null;
  category_id: string | null;
  section_id: string | null;
  tags: string[];
  sources: SourceRef[];
  favorite: boolean;
  status: "draft" | "published";
  history: HistoryVersion[];
  created_by: string | null;
  created_at: string;
  updated_at: string;
};

const DOSSIER_HISTORY_FIELDS: (keyof Entry)[] = ["title", "body", "caption", "label", "url" as keyof Entry, "hemicycle"];
const DOSSIER_HISTORY_MAX = 20;

const DEFAULT_DOSSIER_CATEGORIES: { name: string }[] = [
  { name: "Histoire" },
  { name: "Politique" },
  { name: "Géographie" },
  { name: "Droit" },
  { name: "Actualité" },
  { name: "Culture générale" },
];
// Ordre d'affichage fixe des catégories builtin (point 6, 2026-10-03) —
// demande de Martin : Histoire/Politique/Géographie/Droit/Actualité/Culture
// générale. orderedCategories() trie explicitement selon ce tableau au lieu
// de dépendre de l'ordre renvoyé par Supabase (non garanti sans .order()).
const CATEGORY_ORDER = ["Histoire", "Politique", "Géographie", "Droit", "Actualité", "Culture générale"];
// Catégories par défaut de l'espace 'encyclopedie' — portées de
// ENCYCLOPEDIA_DOSSIER_CATEGORIES.json (mêmes 6 catégories que
// NOTION_CATEGORIES_SEED.json, migrées telles quelles par
// migrateNotionsToEncyclopediaDossier() dans l'artifact source).
const DEFAULT_ENCYCLOPEDIA_CATEGORIES: { name: string }[] = [
  { name: "Sociologie" },
  { name: "Économie" },
  { name: "Philosophie" },
  { name: "Sciences" },
  { name: "Histoire des idées" },
  { name: "Relations internationales" },
];

// ---------------------------------------------------------------------------
// Petites boîtes de dialogue maison (remplacent confirm/prompt/alert) —
// porté à l'identique de customDialog()/customConfirm()/customPrompt()/
// customAlert() dans l'artifact.
// ---------------------------------------------------------------------------

// Exportées pour réutilisation par src/genealogy.ts (mêmes boîtes de
// dialogue que le reste du dossier, au lieu de dupliquer ce code).
export function customDialog(opts: {
  message: string;
  showCancel?: boolean;
  showInput?: boolean;
  defaultValue?: string;
  okLabel?: string;
}): Promise<string | boolean | null> {
  return new Promise((resolve) => {
    const overlay = document.getElementById("custom-dialog-overlay")!;
    const msg = document.getElementById("custom-dialog-message")!;
    const input = document.getElementById("custom-dialog-input") as HTMLInputElement;
    const cancelBtn = document.getElementById("custom-dialog-cancel") as HTMLButtonElement;
    const okBtn = document.getElementById("custom-dialog-ok") as HTMLButtonElement;
    msg.textContent = opts.message || "";
    okBtn.textContent = opts.okLabel || "OK";
    cancelBtn.style.display = opts.showCancel === false ? "none" : "";
    if (opts.showInput) {
      input.style.display = "";
      input.value = opts.defaultValue || "";
    } else {
      input.style.display = "none";
    }
    overlay.classList.add("open");
    function cleanup() {
      overlay.classList.remove("open");
      okBtn.removeEventListener("click", onOk);
      cancelBtn.removeEventListener("click", onCancel);
      overlay.removeEventListener("click", onOverlay);
      document.removeEventListener("keydown", onKey);
    }
    function onOk() {
      cleanup();
      resolve(opts.showInput ? input.value : true);
    }
    function onCancel() {
      cleanup();
      resolve(opts.showInput ? null : false);
    }
    function onOverlay(e: MouseEvent) {
      if (e.target === overlay) onCancel();
    }
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") onCancel();
      else if (e.key === "Enter" && (!opts.showInput || document.activeElement === input)) onOk();
    }
    okBtn.addEventListener("click", onOk);
    cancelBtn.addEventListener("click", onCancel);
    overlay.addEventListener("click", onOverlay);
    document.addEventListener("keydown", onKey);
    if (opts.showInput) setTimeout(() => input.focus(), 30);
    else setTimeout(() => okBtn.focus(), 30);
  });
}
export function customConfirm(message: string): Promise<boolean> {
  return customDialog({ message, showCancel: true }) as Promise<boolean>;
}
export function customPrompt(message: string, defaultValue?: string): Promise<string | null> {
  return customDialog({ message, showInput: true, defaultValue, showCancel: true }) as Promise<string | null>;
}
function customAlert(message: string): Promise<void> {
  return customDialog({ message, showCancel: false }).then(() => undefined);
}

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function dossierEntryDate(ts: string | null | undefined): string {
  if (!ts) return "";
  try {
    return new Date(ts).toLocaleDateString("fr-FR", { year: "numeric", month: "long", day: "numeric" });
  } catch {
    return "";
  }
}
function relativeTimeFr(ts: string | null | undefined): string {
  if (!ts) return "";
  const diff = Date.now() - new Date(ts).getTime();
  const day = 86400000;
  if (diff < day) return "aujourd'hui";
  const days = Math.floor(diff / day);
  if (days === 1) return "hier";
  if (days < 30) return "il y a " + days + " jours";
  const months = Math.floor(days / 30);
  if (months < 12) return "il y a " + months + " mois";
  return "il y a " + Math.floor(months / 12) + " an(s)";
}

const CATEGORY_BANNER_PALETTE: [string, string][] = [
  ["#e8697f", "#c94a63"],
  ["#7d6fd9", "#5b4bc4"],
  ["#f2a63c", "#d4831c"],
  ["#3fbf8f", "#249469"],
  ["#4fa7e8", "#2f7fc0"],
  ["#c283e0", "#9a54c4"],
];
function categoryBannerGradient(id: string): string {
  let h = 0;
  for (let i = 0; i < id.length; i++) h = (h * 31 + id.charCodeAt(i)) >>> 0;
  const pal = CATEGORY_BANNER_PALETTE[h % CATEGORY_BANNER_PALETTE.length];
  return "linear-gradient(135deg," + pal[0] + "," + pal[1] + ")";
}

const CAMERA_ICON_SVG =
  '<svg class="icon-svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2Z"/><circle cx="12" cy="13" r="4"/></svg>';

// Icône de suppression (poubelle) — convention du projet (point 8,
// 2026-10-03) : TOUT bouton de suppression de l'app (entrée de dossier,
// catégorie, dirigeant, membre de groupe, parti d'hémicycle, membre/relation
// d'arbre généalogique, etc.) réutilise CETTE icône via la classe CSS
// `.entry-del` (voir style.css) — NE JAMAIS réintroduire un glyphe "×" texte
// brut nu pour une suppression, même pour un nouvel ajout futur. Exportée
// pour réutilisation par src/genealogy.ts et src/groups.ts.
export const TRASH_ICON_SVG =
  '<svg class="icon-svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/></svg>';

// Cadrage à la souris/au doigt d'une bannière de catégorie ou de section qui
// a une image (schema_v10.sql) — demande de Martin, 2026-10-02 : "pouvoir la
// cadrer". Glisser directement sur la bannière (pas de bouton dédié : c'est
// l'interaction la plus directe pour "cadrer une image") déplace en direct
// son `background-position`, en pourcentage de la bannière elle-même, et
// enregistre la position finale au relâchement. N'entre en action que si la
// bannière affiche déjà une vraie image (pas le dégradé de repli) et que
// l'utilisateur a le droit de modifier cette catégorie/section (même garde
// que les boutons renommer/supprimer/image qui partagent la bannière) —
// cliquer ces boutons ne doit pas aussi déclencher le cadrage (mousedown
// vérifie `closest('button')`) et un vrai glissé ne doit pas, lui, rouvrir
// accidentellement la fiche (la bannière d'une catégorie est un enfant d'un
// <button> qui navigue au clic : on avale le prochain `click` une seule
// fois quand un glissé a eu lieu).
function attachBannerDragReframe(
  banner: HTMLElement,
  getImageUrl: () => string | null,
  getCanEdit: () => boolean,
  savePosition: (pos: string) => void
) {
  function clampPct(n: number): number {
    return Math.max(0, Math.min(100, n));
  }
  function posFromClient(clientX: number, clientY: number): string {
    const rect = banner.getBoundingClientRect();
    const x = rect.width ? clampPct(((clientX - rect.left) / rect.width) * 100) : 50;
    const y = rect.height ? clampPct(((clientY - rect.top) / rect.height) * 100) : 50;
    return Math.round(x) + "% " + Math.round(y) + "%";
  }
  function begin(startX: number, startY: number) {
    if (!getImageUrl() || !getCanEdit()) return;
    let moved = false;
    banner.classList.add("reframing");
    const label = document.createElement("div");
    label.className = "dsc-reframe-label";
    label.textContent = "Glissez pour cadrer l'image";
    banner.appendChild(label);
    function suppressNextClick(e: Event) {
      e.stopPropagation();
      e.preventDefault();
      banner.removeEventListener("click", suppressNextClick, true);
    }
    function move(cx: number, cy: number) {
      if (Math.abs(cx - startX) > 2 || Math.abs(cy - startY) > 2) moved = true;
      banner.style.backgroundPosition = posFromClient(cx, cy);
    }
    function end(cx: number, cy: number) {
      banner.classList.remove("reframing");
      label.remove();
      window.removeEventListener("mousemove", onMouseMove);
      window.removeEventListener("mouseup", onMouseUp);
      window.removeEventListener("touchmove", onTouchMove);
      window.removeEventListener("touchend", onTouchEnd);
      if (moved) {
        savePosition(posFromClient(cx, cy));
        banner.addEventListener("click", suppressNextClick, true);
      }
    }
    function onMouseMove(e: MouseEvent) {
      move(e.clientX, e.clientY);
    }
    function onMouseUp(e: MouseEvent) {
      end(e.clientX, e.clientY);
    }
    function onTouchMove(e: TouchEvent) {
      const t = e.touches[0];
      if (t) move(t.clientX, t.clientY);
    }
    function onTouchEnd(e: TouchEvent) {
      const t = e.changedTouches[0];
      end(t ? t.clientX : startX, t ? t.clientY : startY);
    }
    window.addEventListener("mousemove", onMouseMove);
    window.addEventListener("mouseup", onMouseUp);
    window.addEventListener("touchmove", onTouchMove, { passive: true });
    window.addEventListener("touchend", onTouchEnd);
  }
  banner.addEventListener("mousedown", (e) => {
    if ((e.target as HTMLElement).closest("button")) return;
    if (e.button !== 0) return;
    e.preventDefault();
    begin(e.clientX, e.clientY);
  });
  banner.addEventListener(
    "touchstart",
    (e) => {
      if ((e.target as HTMLElement).closest("button")) return;
      const t = e.touches[0];
      if (t) begin(t.clientX, t.clientY);
    },
    { passive: true }
  );
}

// ---------------------------------------------------------------------------
// Hémicycle — porté à l'identique de HEMICYCLE_PALETTE/defaultHemicyclePartyRow/
// computeHemicycleRows/buildHemicycleWidget dans l'artifact source
// (realistic_final.html, ~7330-7474) : disposition en arcs concentriques du
// centre vers l'extérieur, un jeu de sièges trié par angle (et non arc par
// arc) pour que chaque parti occupe une part angulaire continue de la
// gauche vers la droite.
// ---------------------------------------------------------------------------
export const HEMICYCLE_PALETTE = [
  "#5b9fe0", "#e35c50", "#3fbf8f", "#f2a63c", "#7d6fd9",
  "#c283e0", "#4fa7e8", "#c94a63", "#249469", "#d4831c",
];
export function defaultHemicyclePartyRow(idx: number): HemicycleParty {
  return { name: "", color: HEMICYCLE_PALETTE[idx % HEMICYCLE_PALETTE.length], seats: 0 };
}

function computeHemicycleRows(N: number): { rows: { radius: number; seats: number }[]; dotRadius: number } {
  if (!N || N <= 0) return { rows: [], dotRadius: 3.4 };
  const rMax = 92;
  const minR = 14;
  let dotRadius = 3.6;
  for (let attempt = 0; attempt < 30; attempt++) {
    const rowSpacing = dotRadius * 2 + 1.4;
    const radii: number[] = [];
    for (let r = rMax; r >= minR; r -= rowSpacing) radii.push(r);
    if (!radii.length) radii.push(rMax);
    const seatSpacingArc = dotRadius * 2 + 1.0;
    const capacities = radii.map((r) => Math.max(1, Math.floor((Math.PI * r) / seatSpacingArc) + 1));
    const totalCap = capacities.reduce((a, b) => a + b, 0);
    if (totalCap >= N || dotRadius <= 0.6) {
      const seatsPerRow = capacities.map((c) => Math.floor((N * c) / totalCap));
      let assigned = seatsPerRow.reduce((a, b) => a + b, 0);
      let remainder = N - assigned;
      let i = 0;
      let guard = 0;
      while (remainder > 0 && guard < radii.length * 2000) {
        const idx = i % radii.length;
        if (seatsPerRow[idx] < capacities[idx]) {
          seatsPerRow[idx]++;
          remainder--;
        }
        i++;
        guard++;
      }
      if (remainder > 0) seatsPerRow[seatsPerRow.length - 1] += remainder;
      const rows = radii.map((r, idx) => ({ radius: r, seats: seatsPerRow[idx] })).filter((r) => r.seats > 0);
      rows.sort((a, b) => a.radius - b.radius);
      return { rows, dotRadius };
    }
    dotRadius -= 0.12;
  }
  return { rows: [{ radius: rMax, seats: N }], dotRadius: 0.6 };
}

// Construit le widget complet (SVG + légende + info-bulle locale) à partir
// d'une liste de partis {name,color,seats}. totalOverride (optionnel)
// ajoute des sièges "Non attribué" si supérieur à la somme des partis.
export function buildHemicycleWidget(
  parties: HemicycleParty[],
  totalOverride: number | null | undefined,
  opts: { compact?: boolean } = {}
): HTMLElement {
  const wrap = document.createElement("div");
  wrap.className = "hemicycle-widget";
  const clean = (parties || [])
    .map((p) => ({ name: (p.name || "").trim() || "Sans nom", color: p.color || "#999999", seats: Math.max(0, p.seats || 0) }))
    .filter((p) => p.seats > 0);
  const sumSeats = clean.reduce((a, p) => a + p.seats, 0);
  const totalOv = totalOverride != null ? Math.max(0, totalOverride) : null;
  const total = totalOv && totalOv > sumSeats ? totalOv : sumSeats;
  if (total <= 0) {
    const hint = document.createElement("div");
    hint.className = "hemicycle-empty-hint";
    hint.textContent = "Ajoutez au moins un parti avec des sièges pour voir l’aperçu.";
    wrap.appendChild(hint);
    return wrap;
  }
  const full: (HemicycleParty & { vacant?: boolean })[] = clean.slice();
  if (total > sumSeats) full.push({ name: "Non attribué", color: "#c9bfa9", seats: total - sumSeats, vacant: true });
  const { rows, dotRadius } = computeHemicycleRows(total);
  const cx = 100;
  const cy = 100;
  const seatPositions: { x: number; y: number; angle: number }[] = [];
  rows.forEach((row) => {
    const seats = row.seats;
    if (seats <= 0) return;
    if (seats === 1) {
      seatPositions.push({ x: cx, y: cy - row.radius, angle: Math.PI / 2 });
    } else {
      for (let i = 0; i < seats; i++) {
        const angle = Math.PI - i * (Math.PI / (seats - 1));
        seatPositions.push({ x: cx + row.radius * Math.cos(angle), y: cy - row.radius * Math.sin(angle), angle });
      }
    }
  });
  seatPositions.sort((a, b) => b.angle - a.angle);
  const NS = "http://www.w3.org/2000/svg";
  const svgWrap = document.createElement("div");
  svgWrap.className = "hemicycle-svg-wrap";
  const svg = document.createElementNS(NS, "svg");
  svg.setAttribute("viewBox", "0 0 200 108");
  svg.setAttribute("class", "hemicycle-svg");
  let idx = 0;
  full.forEach((party) => {
    for (let k = 0; k < party.seats; k++) {
      const pos = seatPositions[idx++];
      if (!pos) return;
      const c = document.createElementNS(NS, "circle");
      c.setAttribute("cx", pos.x.toFixed(2));
      c.setAttribute("cy", pos.y.toFixed(2));
      c.setAttribute("r", dotRadius.toFixed(2));
      c.setAttribute("fill", party.color);
      c.setAttribute("class", "hemicycle-seat" + (party.vacant ? " vacant" : ""));
      c.dataset.partyName = party.name;
      c.dataset.partySeats = String(party.seats);
      svg.appendChild(c);
    }
  });
  svgWrap.appendChild(svg);
  const tip = document.createElement("div");
  tip.className = "hemicycle-tooltip";
  svgWrap.appendChild(tip);
  svg.addEventListener("mousemove", (e) => {
    const target = (e.target as Element).closest(".hemicycle-seat") as HTMLElement | null;
    if (!target) {
      tip.classList.remove("open");
      return;
    }
    const rect = svgWrap.getBoundingClientRect();
    const seats = target.dataset.partySeats || "0";
    tip.textContent = target.dataset.partyName + " — " + seats + " siège" + (Number(seats) > 1 ? "s" : "");
    tip.style.left = e.clientX - rect.left + "px";
    tip.style.top = e.clientY - rect.top - 6 + "px";
    tip.classList.add("open");
  });
  svg.addEventListener("mouseleave", () => tip.classList.remove("open"));
  wrap.appendChild(svgWrap);
  const legend = document.createElement("div");
  legend.className = "hemicycle-legend" + (opts.compact ? " compact" : "");
  full.forEach((party) => {
    const row = document.createElement("div");
    row.className = "hemicycle-legend-row";
    const sw = document.createElement("span");
    sw.className = "hl-swatch";
    sw.style.background = party.color;
    row.appendChild(sw);
    const name = document.createElement("span");
    name.textContent = party.name;
    row.appendChild(name);
    const count = document.createElement("span");
    count.className = "hl-count";
    count.textContent = party.seats + (total ? " · " + Math.round((party.seats / total) * 100) + "%" : "");
    row.appendChild(count);
    legend.appendChild(row);
  });
  wrap.appendChild(legend);
  return wrap;
}

// ---------------------------------------------------------------------------
// Système
// ---------------------------------------------------------------------------

export function initFicheDossierSystem(deps: {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  getProfile: () => { id: string; role: string } | null;
  // Toutes les features connues (pour l'auto-lien / le sélecteur de lien
  // interne) — clé = slug.
  getAllCountries: () => CountryRef[];
  // Points d'extension pour les modules groupes/indicateurs (src/groups.ts,
  // src/indicators.ts) : appelés à chaque ouverture/fermeture de la fiche
  // pays pour peupler/vider les deux conteneurs #fiche-extra-indicator et
  // #fiche-extra-groups sans que dossier.ts ait besoin de connaître ces
  // modules (évite une dépendance circulaire).
  renderFicheIndicator?: (container: HTMLElement, country: CountryRef) => void;
  renderFicheGroups?: (container: HTMLElement, country: CountryRef) => void;
  // Widget "Liens" (src/links.ts) — même principe que renderFicheGroups
  // ci-dessus, porté du bloc "Liens" de la fiche unifiée de l'artifact
  // (~1730-1747, kind-country-only + kind-group-only).
  renderFicheLinks?: (container: HTMLElement, country: CountryRef) => void;
  // Widget "Points d'intérêt" (src/poi.ts) — point 5 (2026-10-03), même
  // principe que renderFicheLinks ci-dessus.
  renderFichePoi?: (container: HTMLElement, country: CountryRef) => void;
  onFicheClose?: () => void;
  // Point d'extension pour src/genealogy.ts — appelé au clic sur une
  // carte d'entrée de type "genealogy" (voir buildEntryEl) : dossier.ts
  // ignore tout de genealogy.ts, il se contente de relayer l'entrée
  // cliquée (branché tardivement dans main.ts, cf. ficheDeps). Remplace
  // l'ancien bouton unique "🌳 Généalogie" en haut du dossier (un arbre
  // par pays/groupe) — désormais chaque entrée "genealogy" a son propre
  // arbre indépendant (owner = {type:"entry", id: entry.id}, point 2).
  onOpenGenealogyEntry?: (entry: { id: string; title: string | null }) => void;
}) {
  const { supabase } = deps;
  loadCountryNameData();

  // --- DOM : construit une seule fois, ajouté à document.body -------------
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="fiche-panel" class="panel side-panel">
      <button class="close-x" id="fiche-close" aria-label="Fermer">&times;</button>
      <h2 id="fiche-title">Pays</h2>
      <div id="fiche-subtitle" class="muted fiche-subtitle"></div>
      <button id="fiche-open-dossier" class="btn-small" style="width:100%;margin-bottom:14px;">
        <svg class="icon-svg" viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" style="width:13px;height:13px;vertical-align:-2px;margin-right:5px;"><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7Z"/></svg>
        Ouvrir le dossier complet
      </button>
      <label class="field-label">Dirigeants</label>
      <div id="fiche-leaders-list"></div>
      <button type="button" id="fiche-leaders-add" class="btn-small edit-control">&#43; Ajouter un dirigeant</button>
      <div id="fiche-extra-poi"></div>
      <label class="field-label">Infos clés</label>
      <textarea id="fiche-keyinfo" rows="3" placeholder="Résumé court"></textarea>
      <div id="fiche-extra-indicator"></div>
      <div id="fiche-extra-groups"></div>

      <label class="field-label">Notes</label>
      <textarea id="fiche-notes" rows="7" placeholder="Notes libres, plus détaillées"></textarea>
      <div id="fiche-save-status"></div>
      <div id="fiche-extra-links"></div>
    </div>

    <div id="dossier-view">
      <div id="dossier-inner">
        <button id="dossier-back" class="btn-small">&larr; Retour à la carte</button>
        <h1 id="dossier-title"><span id="dossier-title-flag" style="margin-right:8px;"></span><span id="dossier-title-text">Pays</span></h1>
        <div id="dossier-subtitle" class="muted">Dossier complet</div>

        <div id="dossier-summary">
          <div id="dossier-summary-stats" class="muted"></div>
          <div id="dossier-summary-themes"></div>
        </div>

        <div id="dossier-theme-view" style="display:none;">
          <button id="dossier-summary-back" class="btn-small">&larr; Sommaire</button>
          <button id="dossier-reading-toggle" class="btn-small" style="float:right;">Mode lecture</button>
          <h2 id="dossier-theme-heading"></h2>

          <div class="dossier-add-bar edit-control">
            <select id="dossier-entry-category" class="dossier-cat-select" title="Catégorie pour les nouvelles entrées"></select>
            <select id="dossier-entry-section" class="dossier-cat-select" title="Sous-section (optionnel)"></select>
            <button id="dossier-add-text-btn" class="btn-small">&#43; Texte</button>
            <button id="dossier-add-photo-btn" class="btn-small">&#43; Photo</button>
            <button id="dossier-add-link-btn" class="btn-small">&#43; Lien</button>
            <button id="dossier-add-hemicycle-btn" class="btn-small">&#43; H&eacute;micycle</button>
            <button id="dossier-add-genealogy-btn" class="btn-small">&#43; G&eacute;n&eacute;alogie</button>
            <input type="file" id="dossier-photo-input" accept="image/*" style="display:none;">
            <input type="file" id="dossier-category-image-input" accept="image/*" style="display:none;">
            <input type="file" id="dossier-section-image-input" accept="image/*" style="display:none;">
          </div>
          <div id="dossier-photo-status" class="muted"></div>

          <div id="dossier-text-form" class="dossier-form">
            <input type="text" id="dossier-text-title" placeholder="Titre (optionnel)">
            <div class="dossier-rt-toolbar" id="dossier-rt-toolbar">
              <div class="rt-group">
                <button type="button" data-action="undo" title="Annuler">&#8630;</button>
                <button type="button" data-action="redo" title="Rétablir">&#8631;</button>
              </div>
              <span class="rt-sep"></span>
              <div class="rt-group">
                <button type="button" data-cmd="bold" title="Gras (Ctrl+B)"><b>G</b></button>
                <button type="button" data-cmd="italic" title="Italique (Ctrl+I)"><i>I</i></button>
                <button type="button" data-cmd="underline" title="Souligné (Ctrl+U)"><u>U</u></button>
                <button type="button" data-cmd="strikeThrough" title="Barré">S&#772;</button>
                <button type="button" data-cmd="superscript" title="Exposant">x&sup2;</button>
                <button type="button" data-cmd="subscript" title="Indice">x&#8322;</button>
                <button type="button" data-action="inline-code" title="Code (en ligne)">&lt;/&gt;</button>
              </div>
              <span class="rt-sep"></span>
              <div class="rt-group">
                <span class="rt-color-wrap" title="Couleur du texte">
                  <button type="button" data-action="text-color" class="rt-color-btn" id="dossier-rt-color-btn">A</button>
                  <input type="color" id="dossier-rt-color-input" class="rt-color-input-hidden" value="#e8b34a">
                </span>
                <span class="rt-color-wrap" title="Couleur de surlignage">
                  <button type="button" data-action="hi-color" class="rt-color-btn rt-hi-btn" id="dossier-rt-hicolor-btn">H</button>
                  <input type="color" id="dossier-rt-hicolor-input" class="rt-color-input-hidden" value="#fff59d">
                </span>
                <select id="dossier-rt-fontsize" class="rt-fontsize-select" title="Taille du texte">
                  <option value="">Taille…</option>
                  <option value="rt-fs-sm">Petit</option>
                  <option value="rt-fs-md">Normal</option>
                  <option value="rt-fs-lg">Grand</option>
                  <option value="rt-fs-xl">Très grand</option>
                </select>
              </div>
              <span class="rt-sep"></span>
              <div class="rt-group">
                <button type="button" data-block="h2" title="Titre 2">H2</button>
                <button type="button" data-block="h3" title="Titre 3">H3</button>
                <button type="button" data-block="p" title="Paragraphe normal">P</button>
                <button type="button" data-block="blockquote" title="Citation">&#8220;&#8221;</button>
                <button type="button" data-block="pre" title="Bloc de code">{ }</button>
                <button type="button" data-action="hr" title="Ligne de séparation">&#8213;</button>
              </div>
              <span class="rt-sep"></span>
              <div class="rt-group">
                <button type="button" data-cmd="justifyLeft" title="Aligner à gauche">&#8676;</button>
                <button type="button" data-cmd="justifyCenter" title="Centrer">&#8596;</button>
                <button type="button" data-cmd="justifyRight" title="Aligner à droite">&#8677;</button>
                <button type="button" data-cmd="justifyFull" title="Justifier">&#9776;</button>
                <button type="button" data-cmd="outdent" title="Diminuer le retrait">&#8676;&#9642;</button>
                <button type="button" data-cmd="indent" title="Augmenter le retrait">&#8677;&#9642;</button>
              </div>
              <span class="rt-sep"></span>
              <div class="rt-group">
                <button type="button" data-cmd="insertUnorderedList" title="Liste à puces">&bull; Liste</button>
                <button type="button" data-cmd="insertOrderedList" title="Liste numérotée">1. Liste</button>
                <button type="button" data-action="checklist" title="Liste à cocher">&#9745; Cases</button>
              </div>
              <span class="rt-sep"></span>
              <div class="rt-group">
                <button type="button" data-action="table" title="Insérer un tableau">&#8862; Tableau</button>
                <button type="button" data-action="table-row" title="Ajouter une ligne au tableau">+Ligne</button>
                <button type="button" data-action="table-col" title="Ajouter une colonne au tableau">+Col.</button>
                <button type="button" data-action="internal-link" title="Insérer un lien interne vers un pays">&#128279; Lien</button>
              </div>
              <span class="rt-sep"></span>
              <div class="rt-group">
                <button type="button" data-action="find" title="Rechercher / remplacer" id="dossier-rt-find-btn">&#128269;</button>
              </div>
            </div>
            <div class="dossier-rt-findbar" id="dossier-rt-findbar">
              <input type="text" id="dossier-rt-find-input" placeholder="Rechercher…">
              <input type="text" id="dossier-rt-replace-input" placeholder="Remplacer par…">
              <button type="button" class="btn-small" id="dossier-rt-replace-one">Remplacer</button>
              <button type="button" class="btn-small" id="dossier-rt-replace-all">Tout remplacer</button>
              <span id="dossier-rt-find-status" class="muted"></span>
              <button type="button" class="btn-small" id="dossier-rt-find-close">&times;</button>
            </div>
            <div id="dossier-text-body" class="dossier-rt-editor" contenteditable="true" data-placeholder="Texte…"></div>
            <div id="dossier-text-wordcount" class="dossier-rt-wordcount"></div>
            <select id="dossier-text-category"></select>
            <select id="dossier-text-section"></select>
            <div id="dossier-text-tags-wrap">
              <span class="dossier-sources-label">Étiquettes (optionnel)</span>
              <div id="dossier-text-tags-chips" class="dossier-tags-chips-edit"></div>
              <input type="text" id="dossier-text-tags-input" placeholder="Ajouter une étiquette (Entrée ou virgule)…">
            </div>
            <div id="dossier-text-sources-wrap">
              <span class="dossier-sources-label">Sources / citations (optionnel)</span>
              <div id="dossier-text-sources-list"></div>
              <button type="button" id="dossier-text-source-add" class="btn-small">&#43; Source</button>
            </div>
            <div class="dossier-form-actions">
              <label class="dossier-draft-toggle"><input type="checkbox" id="dossier-text-draft">Brouillon</label>
              <button id="dossier-text-save" class="btn-primary">Ajouter</button>
              <button id="dossier-text-cancel" class="btn-small">Annuler</button>
            </div>
          </div>

          <div id="dossier-link-form" class="dossier-form">
            <input type="text" id="dossier-link-label" placeholder="Libellé (ex. Wikipedia)">
            <input type="text" id="dossier-link-url" placeholder="https://…">
            <select id="dossier-link-category"></select>
            <select id="dossier-link-section"></select>
            <div class="dossier-form-actions">
              <button id="dossier-link-save" class="btn-primary">Ajouter</button>
              <button id="dossier-link-cancel" class="btn-small">Annuler</button>
            </div>
          </div>

          <div id="dossier-hemicycle-form" class="dossier-form">
            <input type="text" id="dossier-hemicycle-title" placeholder="Titre (ex. Assembl&eacute;e nationale — composition 2024)">
            <p class="hemicycle-order-hint">L&rsquo;ordre des partis ci-dessous correspond &agrave; leur position de gauche &agrave; droite dans l&rsquo;h&eacute;micycle (le premier de la liste = le plus &agrave; gauche). Utilisez les fl&egrave;ches &#9664; &#9654; pour les r&eacute;ordonner.</p>
            <div id="dossier-hemicycle-parties"></div>
            <button type="button" id="dossier-hemicycle-add-party" class="btn-small">&#43; Parti</button>
            <div class="dossier-hemicycle-row-fields">
              <input type="text" id="dossier-hemicycle-total" placeholder="Total si&egrave;ges (optionnel, sinon = somme)">
              <input type="text" id="dossier-hemicycle-source" placeholder="Source / date (optionnel)">
            </div>
            <select id="dossier-hemicycle-category"></select>
            <select id="dossier-hemicycle-section"></select>
            <div id="dossier-hemicycle-preview"></div>
            <div class="dossier-form-actions">
              <button id="dossier-hemicycle-save" class="btn-primary">Ajouter</button>
              <button id="dossier-hemicycle-cancel" class="btn-small">Annuler</button>
            </div>
          </div>

          <div id="dossier-genealogy-entry-form" class="dossier-form">
            <input type="text" id="dossier-genealogy-entry-title" placeholder="Titre de l'arbre (ex. Dynastie des Valois)">
            <select id="dossier-genealogy-entry-category"></select>
            <select id="dossier-genealogy-entry-section"></select>
            <div class="dossier-form-actions">
              <button id="dossier-genealogy-entry-save" class="btn-primary">Ajouter</button>
              <button id="dossier-genealogy-entry-cancel" class="btn-small">Annuler</button>
            </div>
          </div>

          <div id="dossier-section-bar" style="display:none;">
            <button id="dossier-add-section-btn" class="btn-small edit-control">&#43; Sous-section dans cet onglet</button>
          </div>

          <div id="dossier-entries"></div>
        </div>

        <div id="dossier-entry-read-view">
          <div class="dossier-read-topbar">
            <button id="dossier-read-back" class="btn-small">&larr; Retour</button>
            <button id="dossier-read-edit" class="btn-small">&#9998; Modifier</button>
          </div>
          <div id="dossier-read-card" class="dossier-entry text">
            <div class="entry-meta" id="dossier-read-meta"></div>
            <div class="entry-title" id="dossier-read-title"></div>
            <div class="entry-body" id="dossier-read-body" style="display:block;"></div>
            <div class="entry-wordcount" id="dossier-read-wordcount" style="display:none;"></div>
          </div>
        </div>
      </div>
    </div>

    <div id="dossier-lightbox">
      <button id="dossier-lightbox-close" aria-label="Fermer">&times;</button>
      <img id="dossier-lightbox-img" src="" alt="">
      <div id="dossier-lightbox-caption"></div>
    </div>

    <div id="dossier-entity-picker">
      <div id="dossier-entity-picker-box">
        <button id="dossier-entity-picker-close" class="close-x" aria-label="Fermer">&times;</button>
        <p id="dossier-entity-picker-label">Choisir un pays…</p>
        <input type="text" id="dossier-entity-picker-input" placeholder="Rechercher…" autocomplete="off">
        <div id="dossier-entity-picker-results"></div>
      </div>
    </div>

    <div id="dossier-history-modal">
      <div id="dossier-history-box">
        <button id="dossier-history-close" class="close-x" aria-label="Fermer">&times;</button>
        <h2>Historique des modifications</h2>
        <div id="dossier-history-list"></div>
      </div>
    </div>

    <div id="custom-dialog-overlay">
      <div id="custom-dialog-box">
        <p id="custom-dialog-message"></p>
        <input type="text" id="custom-dialog-input" style="display:none;">
        <div id="custom-dialog-actions">
          <button id="custom-dialog-cancel" class="btn-small">Annuler</button>
          <button id="custom-dialog-ok" class="btn-primary" style="margin-top:0;">OK</button>
        </div>
      </div>
    </div>
  `;
  while (root.firstChild) document.body.appendChild(root.firstChild);

  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

  // --- État -----------------------------------------------------------------
  // Propriétaire du dossier PLEIN ÉCRAN actuellement ouvert (pays, groupe ou
  // Encyclopédie — voir DossierOwnerRef). Distinct de currentFicheCountry
  // (panneau latéral, pays uniquement) plus bas.
  let currentOwner: DossierOwnerRef | null = null;
  const categoryDocs = new Map<string, Category>();
  let currentCategorySpace: "country" | "encyclopedie" = "country";
  let currentSections: Section[] = [];
  let currentEntries: Entry[] = [];
  let activeCategory = "__all__";
  let editingEntryId: string | null = null;
  let editingSourcesDraft: SourceRef[] = [];
  let editingTagsDraft: string[] = [];
  let editingHemicycleParties: HemicycleParty[] = [];
  let readingEntryId: string | null = null;

  // Retour de Martin (2026-10-03, point 4a) : seul un compte au rôle
  // "admin" (profiles.role) peut éditer — la simple présence d'une session
  // ne suffit plus (voir supabase/schema_v13.sql pour le pendant côté
  // policies RLS, qui restaure l'admin-only sur toutes les tables
  // concernées). canModify() délègue à isAdmin() : il n'y a plus de notion
  // de "créateur seul" dans ce module (déjà le cas avant ce changement).
  // Vérifie aussi le mode lecture global (point 4b, document.body.classList
  // "read-only-mode", posé par main.ts) — même garde que les 5 autres
  // modules (groups.ts/indicators.ts/links.ts/poi.ts/genealogy.ts) : sans
  // elle, un admin qui active "Mode lecture" pour prévisualiser
  // l'expérience d'un visiteur garderait quand même la possibilité
  // d'éditer/glisser-déposer ICI (dossier.ts), incohérent avec tous les
  // autres panneaux de l'app où le mode lecture désactive bien l'édition.
  function isAdmin(): boolean {
    return deps.getProfile()?.role === "admin" && !document.body.classList.contains("read-only-mode");
  }
  function canModify(_row: { created_by: string | null }): boolean {
    return isAdmin();
  }
  // -------------------------------------------------------------------------
  // Catégories
  // -------------------------------------------------------------------------
  async function ensureDefaultCategories(space: "country" | "encyclopedie") {
    const { count } = await supabase
      .from("dossier_categories")
      .select("id", { count: "exact", head: true })
      .eq("space", space);
    if (count && count > 0) return;
    const session = deps.getSession();
    if (!session) return; // best-effort : retentera à la prochaine ouverture par un utilisateur connecté
    const defaults = space === "encyclopedie" ? DEFAULT_ENCYCLOPEDIA_CATEGORIES : DEFAULT_DOSSIER_CATEGORIES;
    try {
      await supabase.from("dossier_categories").insert(
        defaults.map((c) => ({
          name: c.name,
          space,
          builtin: true,
          created_by: session.user.id,
        }))
      );
    } catch {
      /* best-effort */
    }
  }
  function rowToCategory(row: Record<string, unknown>): Category {
    return {
      id: row.id as string,
      name: row.name as string,
      builtin: !!row.builtin,
      created_by: (row.created_by as string) ?? null,
      image_url: (row.image_url as string) ?? null,
      image_position: (row.image_position as string) || "50% 50%",
    };
  }
  async function loadCategories(space: "country" | "encyclopedie") {
    currentCategorySpace = space;
    const { data, error } = await supabase
      .from("dossier_categories")
      .select("id, name, builtin, created_by, image_url, image_position")
      .eq("space", space);
    categoryDocs.clear();
    if (!error && data) {
      data.forEach((row) => categoryDocs.set(row.id as string, rowToCategory(row)));
    }
    if (categoryDocs.size === 0) {
      await ensureDefaultCategories(space);
      const retry = await supabase
        .from("dossier_categories")
        .select("id, name, builtin, created_by, image_url, image_position")
        .eq("space", space);
      if (retry.data) retry.data.forEach((row) => categoryDocs.set(row.id as string, rowToCategory(row)));
    }
  }
  function orderedCategories(): [string, Category][] {
    const builtin = Array.from(categoryDocs.entries())
      .filter(([, c]) => c.builtin)
      .sort((a, b) => {
        const ia = CATEGORY_ORDER.indexOf(a[1].name);
        const ib = CATEGORY_ORDER.indexOf(b[1].name);
        return (ia === -1 ? CATEGORY_ORDER.length : ia) - (ib === -1 ? CATEGORY_ORDER.length : ib);
      });
    const custom = Array.from(categoryDocs.entries()).filter(([, c]) => !c.builtin);
    return builtin.concat(custom);
  }
  async function addCategory(name: string): Promise<string | null> {
    if (!isAdmin()) return null;
    const session = deps.getSession();
    if (!session) return null;
    const { data, error } = await supabase
      .from("dossier_categories")
      .insert({ name, space: currentCategorySpace, builtin: false, created_by: session.user.id })
      .select("id, name, builtin, created_by, image_url, image_position")
      .single();
    if (error || !data) return null;
    categoryDocs.set(data.id, rowToCategory(data));
    return data.id;
  }
  async function renameCategory(id: string) {
    const cat = categoryDocs.get(id);
    if (!cat || cat.builtin || !isAdmin()) return;
    const name = await customPrompt("Renommer la catégorie :", cat.name);
    if (name === null || !name.trim()) return;
    cat.name = name.trim();
    categoryDocs.set(id, cat);
    try {
      await supabase.from("dossier_categories").update({ name: cat.name }).eq("id", id);
    } catch {
      /* ignore */
    }
  }
  async function deleteCategory(id: string) {
    const cat = categoryDocs.get(id);
    if (!cat || cat.builtin || !isAdmin()) return;
    if (
      !(await customConfirm(
        "Supprimer la catégorie « " + cat.name + " » ? Les entrées qu'elle contient resteront dans le dossier, mais sans catégorie."
      ))
    )
      return;
    categoryDocs.delete(id);
    if (activeCategory === id) activeCategory = "__all__";
    try {
      await supabase.from("dossier_categories").delete().eq("id", id);
    } catch {
      /* ignore */
    }
  }

  // -------------------------------------------------------------------------
  // Sous-sections
  // -------------------------------------------------------------------------
  async function loadSections(ownerType: DossierOwnerKind, ownerId: string) {
    const { data } = await supabase
      .from("dossier_sections")
      .select("id, category_id, parent_section_id, title, collapsed, position, created_by, countries, cover_image_url, image_position")
      .eq("owner_type", ownerType)
      .eq("owner_id", ownerId)
      .order("position", { ascending: true });
    currentSections = (data || []).map((row) => ({
      id: row.id,
      category_id: row.category_id,
      parent_section_id: row.parent_section_id,
      name: row.title,
      collapsed: row.collapsed,
      position: row.position,
      created_by: row.created_by,
      countries: (row.countries as string[]) || [],
      cover_image_url: (row.cover_image_url as string) ?? null,
      image_position: (row.image_position as string) || "50% 50%",
    }));
  }
  function canCreateChildSection(sec: Section): boolean {
    return !sec.parent_section_id;
  }
  async function addSection(name: string, categoryId: string, parentSectionId: string | null): Promise<string | null> {
    if (!currentOwner || !isAdmin()) return null;
    const session = deps.getSession();
    if (!session) return null;
    const siblings = currentSections.filter(
      (s) => s.category_id === categoryId && (s.parent_section_id || null) === (parentSectionId || null)
    );
    const position = siblings.length ? Math.max(...siblings.map((s) => s.position || 0)) + 1 : 0;
    const { data, error } = await supabase
      .from("dossier_sections")
      .insert({
        owner_type: currentOwner.type,
        owner_id: currentOwner.id,
        category_id: categoryId,
        parent_section_id: parentSectionId,
        title: name,
        position,
        created_by: session.user.id,
      })
      .select("id")
      .single();
    if (error || !data) return null;
    currentSections.push({
      id: data.id,
      category_id: categoryId,
      parent_section_id: parentSectionId,
      name,
      collapsed: false,
      position,
      created_by: session.user.id,
      countries: [],
      cover_image_url: null,
      image_position: "50% 50%",
    });
    return data.id;
  }
  async function renameSection(id: string) {
    const sec = currentSections.find((s) => s.id === id);
    if (!sec || !canModify(sec)) return;
    const name = await customPrompt("Renommer la sous-section :", sec.name);
    if (name === null || !name.trim()) return;
    sec.name = name.trim();
    renderDossierEntries();
    try {
      await supabase.from("dossier_sections").update({ title: sec.name }).eq("id", id);
    } catch {
      /* ignore */
    }
  }
  async function deleteSection(id: string) {
    const sec = currentSections.find((s) => s.id === id);
    if (!sec || !canModify(sec)) return;
    if (
      !(await customConfirm(
        "Supprimer la sous-section « " + sec.name + " » ? Ses entrées resteront dans le dossier, simplement sans sous-section."
      ))
    )
      return;
    currentSections = currentSections.filter((s) => s.id !== id);
    currentEntries.forEach((e) => {
      if (e.section_id === id) e.section_id = null;
    });
    renderDossierEntries();
    try {
      await supabase.from("dossier_sections").delete().eq("id", id);
    } catch {
      /* ignore */
    }
  }
  // Glisser-déposer d'une sous-section (point 3, 2026-10-03) : dépose
  // `draggedId` juste APRÈS `targetId` dans la liste de frères de ce
  // dernier — ce qui réordonne (a) quand les deux partagent déjà le même
  // parent_section_id, et déplace vers un autre parent (b) sinon (le
  // nouveau parent de `draggedId` devient celui de `targetId`). Renumérote
  // ensuite toute la liste de frères résultante en 0,1,2… et persiste
  // position + parent_section_id de chacun.
  function isSectionDescendantOf(candidateId: string, ancestorId: string): boolean {
    let cur: Section | undefined = currentSections.find((s) => s.id === candidateId);
    while (cur) {
      if (cur.id === ancestorId) return true;
      if (!cur.parent_section_id) return false;
      cur = currentSections.find((s) => s.id === cur!.parent_section_id);
    }
    return false;
  }
  async function moveSectionAfter(draggedId: string, targetId: string) {
    if (draggedId === targetId) return;
    const dragged = currentSections.find((s) => s.id === draggedId);
    const target = currentSections.find((s) => s.id === targetId);
    if (!dragged || !target || !canModify(dragged)) return;
    const newParentId = target.parent_section_id || null;
    // Interdit silencieusement : se déposer sur l'un de ses propres
    // descendants (boucle), ou devenir son propre parent.
    if (newParentId === draggedId || isSectionDescendantOf(targetId, draggedId)) return;
    // Une section qui a elle-même des enfants (niveau 2) ne peut pas
    // devenir l'enfant d'une autre (niveau 3) — la hiérarchie du dossier
    // n'a que 2 niveaux (voir canCreateChildSection) et ses propres
    // enfants se retrouveraient orphelins d'un rendu à 3 niveaux.
    const draggedHasChildren = currentSections.some((s) => s.parent_section_id === draggedId);
    if (draggedHasChildren && newParentId) return;
    dragged.parent_section_id = newParentId;
    dragged.category_id = target.category_id;
    const siblings = currentSections
      .filter((s) => s.id !== draggedId && s.category_id === target.category_id && (s.parent_section_id || null) === (newParentId || null))
      .sort((a, b) => a.position - b.position);
    const targetIdx = siblings.findIndex((s) => s.id === targetId);
    siblings.splice(targetIdx + 1, 0, dragged);
    siblings.forEach((s, idx) => {
      s.position = idx;
    });
    renderDossierEntries();
    try {
      await Promise.all(
        siblings.map((s) =>
          supabase.from("dossier_sections").update({ position: s.position, parent_section_id: s.parent_section_id, category_id: s.category_id }).eq("id", s.id)
        )
      );
    } catch {
      /* ignore */
    }
  }
  async function moveSection(id: string, dir: 1 | -1) {
    const target = currentSections.find((s) => s.id === id);
    if (!target || !canModify(target)) return;
    const siblings = currentSections
      .filter((s) => s.category_id === target.category_id && (s.parent_section_id || null) === (target.parent_section_id || null))
      .sort((a, b) => a.position - b.position);
    const idx = siblings.findIndex((s) => s.id === id);
    const swapIdx = idx + dir;
    if (swapIdx < 0 || swapIdx >= siblings.length) return;
    const a = siblings[idx];
    const b = siblings[swapIdx];
    const tmp = a.position;
    a.position = b.position;
    b.position = tmp;
    renderDossierEntries();
    try {
      await supabase.from("dossier_sections").update({ position: a.position }).eq("id", a.id);
      await supabase.from("dossier_sections").update({ position: b.position }).eq("id", b.id);
    } catch {
      /* ignore */
    }
  }
  async function toggleSectionCollapsed(sec: Section) {
    sec.collapsed = !sec.collapsed;
    renderDossierEntries();
    try {
      await supabase.from("dossier_sections").update({ collapsed: sec.collapsed }).eq("id", sec.id);
    } catch {
      /* ignore */
    }
  }
  async function addChildSection(parentId: string) {
    const name = ((await customPrompt("Nom de la nouvelle sous-sous-catégorie :")) || "").trim();
    if (!name) return;
    const parent = currentSections.find((s) => s.id === parentId);
    if (!parent || !canCreateChildSection(parent)) return;
    await addSection(name, parent.category_id, parentId);
    populateSectionSelects();
    renderDossierEntries();
  }

  // -------------------------------------------------------------------------
  // Entrées
  // -------------------------------------------------------------------------
  function rowToEntry(row: Record<string, unknown>): Entry {
    return {
      id: row.id as string,
      type: row.type as EntryType,
      title: (row.title as string) ?? null,
      body: (row.body_html as string) ?? null,
      photo_url: (row.photo_url as string) ?? null,
      caption: (row.caption as string) ?? null,
      link_url: (row.link_url as string) ?? null,
      label: (row.link_label as string) ?? null,
      hemicycle: (row.hemicycle_data as HemicycleData) ?? null,
      category_id: (row.category_id as string) ?? null,
      section_id: (row.section_id as string) ?? null,
      tags: (row.tags as string[]) || [],
      sources: (row.sources as SourceRef[]) || [],
      favorite: !!row.favorite,
      status: (row.status as "draft" | "published") || "published",
      history: (row.history as HistoryVersion[]) || [],
      created_by: (row.created_by as string) ?? null,
      created_at: row.created_at as string,
      updated_at: row.updated_at as string,
    };
  }
  async function loadEntries(ownerType: DossierOwnerKind, ownerId: string) {
    const { data } = await supabase
      .from("dossier_entries")
      .select("*")
      .eq("owner_type", ownerType)
      .eq("owner_id", ownerId)
      .in("type", ["text", "photo", "link", "hemicycle", "genealogy"])
      .order("created_at", { ascending: true });
    currentEntries = (data || []).map(rowToEntry);
  }
  async function addEntry(input: {
    type: EntryType;
    title?: string | null;
    body?: string | null;
    photo_url?: string | null;
    caption?: string | null;
    link_url?: string | null;
    label?: string | null;
    hemicycle?: HemicycleData | null;
    category_id?: string | null;
    section_id?: string | null;
    tags?: string[];
    sources?: SourceRef[];
    status?: "draft" | "published";
  }): Promise<string | null> {
    if (!currentOwner || !isAdmin()) return null;
    const session = deps.getSession();
    if (!session) return null;
    const payload: Record<string, unknown> = {
      owner_type: currentOwner.type,
      owner_id: currentOwner.id,
      type: input.type,
      title: input.title ?? null,
      body_html: input.body ?? null,
      photo_url: input.photo_url ?? null,
      caption: input.caption ?? null,
      link_url: input.link_url ?? null,
      link_label: input.label ?? null,
      hemicycle_data: input.hemicycle ?? null,
      category_id: input.category_id || null,
      section_id: input.section_id || null,
      tags: input.tags || [],
      sources: input.sources || [],
      status: input.status || "published",
      created_by: session.user.id,
    };
    const { data, error } = await supabase.from("dossier_entries").insert(payload).select("id").single();
    if (error || !data) {
      // Point 1 (2026-10-03) : ne JAMAIS échouer silencieusement un insert —
      // affiche le message d'erreur Supabase dans le statut partagé de la
      // barre d'ajout (même conteneur que les erreurs d'upload de photo,
      // #dossier-photo-status) pour qu'un futur bug similaire (ex. une
      // contrainte CHECK manquante, cf. le fix généalogie de schema_v13.sql)
      // soit visible immédiatement plutôt que de reproduire un échec muet.
      const statusEl = document.getElementById("dossier-photo-status");
      if (statusEl) statusEl.textContent = "Échec de l'ajout : " + (error?.message || "erreur inconnue.");
      return null;
    }
    await loadEntries(currentOwner.type, currentOwner.id);
    return data.id;
  }
  // Champs de CONTENU : une modification de l'un d'eux archive la version
  // précédente dans l'historique — porté de updateDossierEntry().
  async function updateEntry(id: string, data: Partial<Entry>) {
    if (!currentOwner) return;
    const prev = currentEntries.find((e) => e.id === id);
    if (!prev || !canModify(prev)) return;
    const touchesContent = DOSSIER_HISTORY_FIELDS.some(
      (f) => (data as Record<string, unknown>)[f] !== undefined && (data as Record<string, unknown>)[f] !== (prev as Record<string, unknown>)[f]
    );
    let history = prev.history;
    if (touchesContent) {
      const snapshot: HistoryVersion = { archivedAt: Date.now() };
      if (prev.title != null) snapshot.title = prev.title;
      if (prev.body != null) snapshot.body = prev.body;
      if (prev.caption != null) snapshot.caption = prev.caption;
      if (prev.label != null) snapshot.label = prev.label;
      if (prev.link_url != null) snapshot.url = prev.link_url;
      if (prev.hemicycle != null) snapshot.hemicycle = prev.hemicycle;
      history = (prev.history || []).concat([snapshot]).slice(-DOSSIER_HISTORY_MAX);
    }
    const dbPatch: Record<string, unknown> = {};
    if (data.title !== undefined) dbPatch.title = data.title;
    if (data.body !== undefined) dbPatch.body_html = data.body;
    if (data.photo_url !== undefined) dbPatch.photo_url = data.photo_url;
    if (data.caption !== undefined) dbPatch.caption = data.caption;
    if (data.link_url !== undefined) dbPatch.link_url = data.link_url;
    if (data.label !== undefined) dbPatch.link_label = data.label;
    if (data.hemicycle !== undefined) dbPatch.hemicycle_data = data.hemicycle;
    if (data.category_id !== undefined) dbPatch.category_id = data.category_id;
    if (data.section_id !== undefined) dbPatch.section_id = data.section_id;
    if (data.tags !== undefined) dbPatch.tags = data.tags;
    if (data.sources !== undefined) dbPatch.sources = data.sources;
    if (data.status !== undefined) dbPatch.status = data.status;
    if (data.favorite !== undefined) dbPatch.favorite = data.favorite;
    if (touchesContent) dbPatch.history = history;
    dbPatch.updated_at = new Date().toISOString();
    try {
      await supabase.from("dossier_entries").update(dbPatch).eq("id", id);
    } catch {
      /* ignore */
    }
    await loadEntries(currentOwner.type, currentOwner.id);
  }
  async function deleteEntry(id: string) {
    if (!currentOwner) return;
    const entry = currentEntries.find((e) => e.id === id);
    if (!entry || !canModify(entry)) return;
    if (!(await customConfirm("Supprimer cette entrée du dossier ?"))) return;
    try {
      await supabase.from("dossier_entries").delete().eq("id", id);
    } catch {
      /* ignore */
    }
    await loadEntries(currentOwner.type, currentOwner.id);
    renderDossierEntries();
  }

  // -------------------------------------------------------------------------
  // Sanitisation / auto-liens
  // -------------------------------------------------------------------------
  let autoLinkIndex: { slug: string; label: string }[] | null = null;
  function buildAutoLinkIndex() {
    if (autoLinkIndex) return autoLinkIndex;
    const seen = new Map<string, { slug: string; label: string }>();
    deps.getAllCountries().forEach((c) => {
      const label = frenchCountryName(c.name);
      if (label && label.length >= 3 && !seen.has(label.toLowerCase())) seen.set(label.toLowerCase(), { slug: c.slug, label });
    });
    autoLinkIndex = Array.from(seen.values()).sort((a, b) => b.label.length - a.label.length);
    return autoLinkIndex;
  }
  function autoLinkEntryBody(html: string): string {
    const idx = buildAutoLinkIndex();
    if (!idx.length || !html) return html;
    const template = document.createElement("template");
    template.innerHTML = html;
    const frag = template.content;
    const escRe = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const pattern = new RegExp("\\b(" + idx.map((e) => escRe(e.label)).join("|") + ")\\b", "gi");
    const byLower = new Map(idx.map((e) => [e.label.toLowerCase(), e]));
    (function walk(node: Node) {
      Array.from(node.childNodes).forEach((child) => {
        if (child.nodeType === Node.ELEMENT_NODE) {
          if ((child as Element).tagName === "A") return;
          walk(child);
          return;
        }
        if (child.nodeType !== Node.TEXT_NODE) return;
        const text = child.textContent || "";
        pattern.lastIndex = 0;
        if (!pattern.test(text)) return;
        pattern.lastIndex = 0;
        const out = document.createDocumentFragment();
        let last = 0;
        let m: RegExpExecArray | null;
        while ((m = pattern.exec(text))) {
          if (m.index > last) out.appendChild(document.createTextNode(text.slice(last, m.index)));
          const info = byLower.get(m[0].toLowerCase())!;
          const a = document.createElement("a");
          a.dataset.entityKind = "country";
          a.dataset.entityId = info.slug;
          a.textContent = m[0];
          out.appendChild(a);
          last = m.index + m[0].length;
        }
        if (last < text.length) out.appendChild(document.createTextNode(text.slice(last)));
        child.replaceWith(out);
      });
    })(frag);
    const div = document.createElement("div");
    div.appendChild(frag);
    return div.innerHTML;
  }

  $("dossier-entries").addEventListener("click", (e) => {
    const a = (e.target as HTMLElement).closest("a[data-entity-kind]") as HTMLElement | null;
    if (!a) return;
    e.preventDefault();
    e.stopPropagation();
    const slug = a.dataset.entityId!;
    const target = deps.getAllCountries().find((c) => c.slug === slug);
    if (target) {
      closeDossier();
      openFiche(target);
    }
  });
  $("dossier-read-body").addEventListener("click", (e) => {
    const a = (e.target as HTMLElement).closest("a[data-entity-kind]") as HTMLElement | null;
    if (!a) return;
    e.preventDefault();
    const slug = a.dataset.entityId!;
    const target = deps.getAllCountries().find((c) => c.slug === slug);
    if (target) {
      closeDossier();
      openFiche(target);
    }
  });

  // -------------------------------------------------------------------------
  // Rendu des entrées / sections
  // -------------------------------------------------------------------------
  function buildEntryEl(entry: Entry): HTMLElement {
    const div = document.createElement("div");
    div.className = "dossier-entry " + entry.type;
    div.dataset.entryId = entry.id;
    // Glisser-déposer gardé par canModify, comme pour les sections
    // (row.draggable ci-dessous) : avant ce correctif, l'attribut restait
    // à true même en mode lecture (ou pour un non-admin), ce qui laissait
    // l'entrée "se soulever" visuellement au survol/ébauche de glisser
    // sans que rien ne puisse être enregistré ensuite (le serveur refusait
    // déjà le PATCH, mais l'affordance visuelle restait trompeuse —
    // contraire à la demande "tout doit disparaître" en mode lecture).
    if (canModify(entry)) {
      div.draggable = true;
      div.addEventListener("dragstart", (e) => {
        e.dataTransfer!.setData("text/dossier-entry-id", entry.id);
        e.dataTransfer!.effectAllowed = "move";
        div.classList.add("dragging-entry");
      });
      div.addEventListener("dragend", () => div.classList.remove("dragging-entry"));
    }
    div.addEventListener("click", (e) => {
      if ((e.target as HTMLElement).closest("button") || (e.target as HTMLElement).closest("a")) return;
      if (entry.type === "photo") {
        openLightbox(entry);
        return;
      }
      if (entry.type === "text") {
        openEntryReadView(entry);
        return;
      }
      if (entry.type === "genealogy") {
        deps.onOpenGenealogyEntry?.({ id: entry.id, title: entry.title });
        return;
      }
      startEditEntry(entry);
    });

    const canEdit = canModify(entry);
    if (canEdit) {
      const del = document.createElement("button");
      del.className = "entry-del";
      del.innerHTML = TRASH_ICON_SVG;
      del.title = "Supprimer cette entrée";
      del.addEventListener("click", (e) => {
        e.stopPropagation();
        deleteEntry(entry.id);
      });
      div.appendChild(del);
      const edit = document.createElement("button");
      edit.className = "entry-edit";
      edit.innerHTML =
        '<svg class="icon-svg" style="width:14px;height:14px;" viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>';
      edit.title = entry.type === "photo" ? "Modifier le titre / la légende" : "Modifier cette entrée";
      edit.addEventListener("click", (e) => {
        e.stopPropagation();
        startEditEntry(entry);
      });
      div.appendChild(edit);
      if (entry.type === "photo") {
        const replace = document.createElement("button");
        replace.className = "entry-replace-photo";
        replace.innerHTML =
          '<svg class="icon-svg" style="width:14px;height:14px;" viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-5-5L5 21"/></svg>';
        replace.title = "Remplacer la photo";
        replace.addEventListener("click", (e) => {
          e.stopPropagation();
          startReplacePhoto(entry.id);
        });
        div.appendChild(replace);
      }
    }
    const fav = document.createElement("button");
    fav.type = "button";
    fav.className = "entry-fav" + (entry.favorite ? " active" : "");
    fav.title = entry.favorite ? "Retirer des favoris" : "Marquer comme favori";
    fav.innerHTML =
      '<svg class="icon-svg" style="width:14px;height:14px;" viewBox="0 0 24 24" width="14" height="14" fill="' +
      (entry.favorite ? "currentColor" : "none") +
      '" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>';
    fav.addEventListener("click", (e) => {
      e.stopPropagation();
      updateEntry(entry.id, { favorite: !entry.favorite });
    });
    div.appendChild(fav);
    if (entry.history && entry.history.length) {
      const hist = document.createElement("button");
      hist.type = "button";
      hist.className = "entry-history";
      hist.title = "Historique des modifications (" + entry.history.length + ")";
      hist.innerHTML =
        '<svg class="icon-svg" style="width:14px;height:14px;" viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 3"/></svg>';
      hist.addEventListener("click", (e) => {
        e.stopPropagation();
        openHistoryModal(entry);
      });
      div.appendChild(hist);
    }

    const meta = document.createElement("div");
    meta.className = "entry-meta";
    const dateSpan = document.createElement("span");
    dateSpan.className = "entry-date-hover";
    dateSpan.textContent = dossierEntryDate(entry.created_at);
    meta.appendChild(dateSpan);
    if (entry.status === "draft") {
      const draftBadge = document.createElement("span");
      draftBadge.className = "entry-draft-badge";
      draftBadge.textContent = "Brouillon";
      meta.appendChild(draftBadge);
    }
    div.appendChild(meta);

    if (entry.type === "text") {
      const h = document.createElement("div");
      h.className = "entry-title";
      h.textContent = entry.title || entryPlainText(entry as DossierEntryLike).slice(0, 60) || "Sans titre";
      div.appendChild(h);
      const preview = entryPlainText(entry as DossierEntryLike).trim();
      if (preview) {
        const p = document.createElement("div");
        p.className = "entry-preview";
        const cut = preview.slice(0, 140);
        p.textContent = cut + (preview.length > 140 ? "…" : "");
        div.appendChild(p);
      }
      const body = document.createElement("div");
      body.className = "entry-body";
      body.innerHTML = autoLinkEntryBody(sanitizeDossierHTML(entry.body || ""));
      div.appendChild(body);
      const words = wordCountForEntry(entry as DossierEntryLike);
      if (words > 0) {
        const wc = document.createElement("div");
        wc.className = "entry-wordcount";
        wc.textContent = words + " mot" + (words > 1 ? "s" : "") + " · ~" + readingTimeMinutes(words) + " min de lecture";
        div.appendChild(wc);
      }
    } else if (entry.type === "photo") {
      const img = document.createElement("img");
      img.src = entry.photo_url || "";
      img.alt = entry.title || entry.caption || "";
      div.appendChild(img);
      if (entry.title) {
        const h = document.createElement("div");
        h.className = "entry-title";
        h.textContent = entry.title;
        div.appendChild(h);
      }
      if (entry.caption) {
        const cap = document.createElement("div");
        cap.className = "entry-caption";
        cap.textContent = entry.caption;
        div.appendChild(cap);
      }
    } else if (entry.type === "link") {
      const ytId = extractYouTubeId(entry.link_url);
      if (ytId) {
        const a = document.createElement("a");
        a.className = "yt-card";
        a.href = entry.link_url || "#";
        a.target = "_blank";
        a.rel = "noopener noreferrer";
        const thumb = document.createElement("div");
        thumb.className = "yt-thumb-wrap";
        const img = document.createElement("img");
        img.src = "https://img.youtube.com/vi/" + ytId + "/hqdefault.jpg";
        img.alt = entry.label || "Vidéo YouTube";
        thumb.appendChild(img);
        const play = document.createElement("div");
        play.className = "yt-play";
        play.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>';
        thumb.appendChild(play);
        a.appendChild(thumb);
        const cap = document.createElement("div");
        cap.className = "yt-label";
        cap.textContent = entry.label || "Voir sur YouTube";
        a.appendChild(cap);
        div.appendChild(a);
      } else {
        const a = document.createElement("a");
        a.href = entry.link_url || "#";
        a.target = "_blank";
        a.rel = "noopener noreferrer";
        a.textContent = entry.label || entry.link_url || "";
        div.appendChild(a);
      }
    } else if (entry.type === "hemicycle") {
      const h = entry.hemicycle || { parties: [] };
      div.appendChild(buildHemicycleWidget(h.parties || [], h.totalSeats, { compact: true }));
      const title = document.createElement("div");
      title.className = "entry-title";
      title.textContent = h.title || entry.title || "Hémicycle";
      div.appendChild(title);
      if (h.source) {
        const src = document.createElement("div");
        src.className = "entry-caption";
        src.textContent = h.source;
        div.appendChild(src);
      }
    } else if (entry.type === "genealogy") {
      // Petite carte cliquable — pas de rendu du widget généalogie inline,
      // juste un lien vers l'overlay plein écran (src/genealogy.ts),
      // owner = {type:"entry", id: entry.id} (point 2, 2026-10-03).
      const icon = document.createElement("div");
      icon.className = "entry-title";
      icon.textContent = "🌳 " + (entry.title || "Arbre généalogique");
      div.appendChild(icon);
      const hint = document.createElement("div");
      hint.className = "muted";
      hint.textContent = "Cliquer pour ouvrir l'arbre généalogique";
      div.appendChild(hint);
    }

    if (entry.tags && entry.tags.length) {
      const tagsWrap = document.createElement("div");
      tagsWrap.className = "entry-tags";
      entry.tags.forEach((tag) => {
        const chip = document.createElement("span");
        chip.className = "entry-tag-chip";
        chip.textContent = "#" + tag;
        tagsWrap.appendChild(chip);
      });
      div.appendChild(tagsWrap);
    }
    if (entry.sources && entry.sources.length) {
      const srcWrap = document.createElement("div");
      srcWrap.className = "entry-sources";
      const label = document.createElement("span");
      label.className = "entry-sources-label";
      label.textContent = "Sources : ";
      srcWrap.appendChild(label);
      entry.sources.forEach((s, i) => {
        if (i > 0) srcWrap.appendChild(document.createTextNode(" · "));
        if (s.url) {
          const a = document.createElement("a");
          a.href = s.url;
          a.target = "_blank";
          a.rel = "noopener noreferrer";
          a.textContent = s.label || s.url;
          srcWrap.appendChild(a);
        } else {
          srcWrap.appendChild(document.createTextNode(s.label || ""));
        }
      });
      div.appendChild(srcWrap);
    }
    return div;
  }

  function registerSectionDropZone(el: HTMLElement, sectionId: string | null) {
    el.addEventListener("dragover", (e) => {
      if (!e.dataTransfer!.types.includes("text/dossier-entry-id")) return;
      e.preventDefault();
      e.dataTransfer!.dropEffect = "move";
      el.classList.add("drop-target-active");
    });
    el.addEventListener("dragleave", () => el.classList.remove("drop-target-active"));
    el.addEventListener("drop", (e) => {
      const entryId = e.dataTransfer!.getData("text/dossier-entry-id");
      el.classList.remove("drop-target-active");
      if (!entryId) return;
      e.preventDefault();
      updateEntry(entryId, { section_id: sectionId || null });
    });
  }

  function buildSectionGroupEl(sec: Section, allFiltered: Entry[]): HTMLElement {
    const entries = allFiltered.filter((e) => e.section_id === sec.id);
    const level = sec.parent_section_id ? 3 : 2;
    const group = document.createElement("div");
    group.className = "dossier-section-group level-" + level + (sec.collapsed ? " collapsed" : "");
    // data-section-id : cible du défilement de la recherche unifiée
    // (src/search.ts, revealSection) — identique au sélecteur
    // `.dossier-section-group[data-section-id="…"]` de l'artifact source.
    group.dataset.sectionId = sec.id;

    // Glisser-déposer de sous-sections (point 2, fix 2026-10-03) : la zone
    // de dépôt valide est UNIQUEMENT le bandeau-titre (`row` ci-dessous, pas
    // tout le `group`). `group` contient aussi, affiché juste en dessous,
    // les sous-sous-sections (niveau 3) rattachées à cette section, chacune
    // avec SA PROPRE zone de dépôt (son propre `group`/`row`,
    // stopPropagation() inclus) — déposer sur TOUT le bloc `group` rendait
    // donc très facile de toucher en réalité la zone de l'ENFANT plutôt que
    // celle du PARENT : moveSectionAfter(draggedId, targetId=<id de
    // l'enfant>) calcule alors newParentId = parent de cet enfant, et la
    // section déposée (de niveau 2 autonome) DEVENAIT un niveau-3, absorbée
    // comme frère de cet enfant — perçu par l'utilisateur comme "rentrée
    // dans l'autre" alors qu'un simple réordonnancement était voulu. `row`
    // n'est JAMAIS un ancêtre DOM d'un enfant imbriqué (il ne contient que
    // le caret/nom/compteur), donc déposer sur le bandeau d'une section
    // cible précisément CETTE section, jamais un de ses enfants rendus en
    // dessous. Les listeners dragstart/dragend de `row` (poignée de
    // glisser, plus bas) restent inchangés ; ceux-ci s'y ajoutent à côté.

    const banner = document.createElement("div");
    banner.className = "dossier-section-banner dsc-banner";
    banner.style.backgroundImage = categoryBannerGradient(sec.id);
    if (sec.cover_image_url) {
      banner.classList.add("has-image");
      banner.style.backgroundImage = "url('" + sec.cover_image_url + "')";
      banner.style.backgroundSize = "cover";
      banner.style.backgroundPosition = sec.image_position || "50% 50%";
    }
    const pattern = document.createElement("div");
    pattern.className = "dsc-banner-pattern";
    banner.appendChild(pattern);
    const mkIconBtn = (cls: string, title: string, innerHTML: string, fn: () => void) => {
      const b = document.createElement("button");
      b.type = "button";
      b.className = cls;
      b.title = title;
      b.innerHTML = innerHTML;
      b.addEventListener("click", (e) => {
        e.stopPropagation();
        fn();
      });
      return b;
    };
    if (canModify(sec)) {
      const actions = document.createElement("div");
      actions.className = "dsc-banner-actions";
      actions.appendChild(mkIconBtn("dsc-menu-btn", "Renommer", "✎", () => renameSection(sec.id)));
      actions.appendChild(mkIconBtn("dsc-image-btn", "Changer l'image", CAMERA_ICON_SVG, () => startSectionImageUpload(sec.id)));
      actions.appendChild(
        mkIconBtn(
          "dsc-del-btn",
          "Supprimer la sous-section",
          TRASH_ICON_SVG,
          () => deleteSection(sec.id)
        )
      );
      banner.appendChild(actions);
    }
    attachBannerDragReframe(
      banner,
      () => sec.cover_image_url,
      () => canModify(sec),
      (pos) => saveSectionImagePosition(sec, pos)
    );
    group.appendChild(banner);

    const row = document.createElement("div");
    row.className = "dossier-section-row";
    const caret = document.createElement("span");
    caret.className = "sec-caret";
    caret.textContent = "▾";
    const name = document.createElement("span");
    name.className = "sec-name";
    name.textContent = sec.name;
    const count = document.createElement("span");
    count.className = "sec-count";
    count.textContent = "(" + entries.length + ")";
    row.appendChild(caret);
    row.appendChild(name);
    row.appendChild(count);
    row.addEventListener("click", () => toggleSectionCollapsed(sec));
    if (canModify(sec)) {
      row.draggable = true;
      row.title = "Glisser pour réordonner ou déplacer vers une autre sous-section";
      row.addEventListener("dragstart", (e) => {
        e.dataTransfer!.setData("text/dossier-section-id", sec.id);
        e.dataTransfer!.effectAllowed = "move";
        group.classList.add("dragging-section");
      });
      row.addEventListener("dragend", () => group.classList.remove("dragging-section"));
    }
    // Zone de dépôt restreinte au bandeau-titre (voir commentaire plus haut)
    // — ajoutée à CÔTÉ des listeners dragstart/dragend ci-dessus, pas à leur
    // place. Pas de garde canModify(sec) ici : comme avant le fix, c'est
    // moveSectionAfter() qui vérifie les droits sur la section DÉPLACÉE ;
    // row doit rester une cible de dépôt valide même si la section cible
    // elle-même n'est pas modifiable par l'utilisateur courant.
    row.addEventListener("dragover", (e) => {
      if (!e.dataTransfer!.types.includes("text/dossier-section-id")) return;
      e.preventDefault();
      e.stopPropagation();
      e.dataTransfer!.dropEffect = "move";
      group.classList.add("section-drop-target");
    });
    row.addEventListener("dragleave", () => group.classList.remove("section-drop-target"));
    row.addEventListener("drop", (e) => {
      const draggedId = e.dataTransfer!.getData("text/dossier-section-id");
      group.classList.remove("section-drop-target");
      if (!draggedId) return;
      e.preventDefault();
      e.stopPropagation();
      void moveSectionAfter(draggedId, sec.id);
    });
    group.appendChild(row);

    // Point 4a (2026-10-03) : ces boutons (créer une sous-sous-catégorie,
    // réordonner) n'étaient PAS gatés du tout auparavant — n'importe quel
    // visiteur pouvait réordonner les sous-sections. Rendus uniquement si
    // canModify(sec) (donc jamais en mode lecture global, voir point 4b).
    if (canModify(sec)) {
      const actions = document.createElement("div");
      actions.className = "dossier-section-actions edit-control";
      const mkBtn = (label: string, title: string, fn: () => void) => {
        const b = document.createElement("button");
        b.type = "button";
        b.textContent = label;
        b.title = title;
        b.addEventListener("click", (e) => {
          e.stopPropagation();
          fn();
        });
        return b;
      };
      if (canCreateChildSection(sec)) {
        actions.appendChild(mkBtn("+", "Créer une sous-sous-catégorie dans « " + sec.name + " »", () => addChildSection(sec.id)));
      }
      actions.appendChild(mkBtn("↑", "Monter", () => moveSection(sec.id, -1)));
      actions.appendChild(mkBtn("↓", "Descendre", () => moveSection(sec.id, 1)));
      group.appendChild(actions);
    }

    const body = document.createElement("div");
    body.className = "dossier-section-body dossier-drop-zone";
    if (!entries.length && level === 2 && !currentSections.some((s) => s.parent_section_id === sec.id)) {
      const p = document.createElement("p");
      p.className = "muted";
      p.style.margin = "0";
      p.textContent = "Aucune entrée dans cette sous-section pour le moment. Glissez-y une entrée pour la classer ici.";
      body.appendChild(p);
    } else {
      entries.forEach((entry) => body.appendChild(buildEntryEl(entry)));
    }
    group.appendChild(body);
    registerSectionDropZone(body, sec.id);
    registerSectionDropZone(row, sec.id);
    if (level === 2) {
      const children = currentSections
        .filter((s) => s.parent_section_id === sec.id)
        .sort((a, b) => a.position - b.position);
      children.forEach((child) => group.appendChild(buildSectionGroupEl(child, allFiltered)));
    }
    return group;
  }

  function renderDossierEntries() {
    const container = $("dossier-entries");
    container.innerHTML = "";
    const entries = currentEntries;
    if (!entries.length && !currentSections.length) {
      container.innerHTML =
        '<p class="muted">Aucune entrée pour le moment. Utilisez les boutons ci-dessus pour ajouter du texte, une photo ou un lien.</p>';
      return;
    }
    if (activeCategory !== "__all__") {
      const filtered = entries.filter((e) => (e.category_id || null) === activeCategory);
      const allSecsInCat = currentSections.filter((s) => s.category_id === activeCategory);
      const secs = allSecsInCat.filter((s) => !s.parent_section_id).sort((a, b) => a.position - b.position);
      if (!filtered.length && !allSecsInCat.length) {
        container.innerHTML = '<p class="muted">Aucune entrée dans cette catégorie pour le moment.</p>';
        return;
      }
      const unsectioned = filtered.filter((e) => !e.section_id || !allSecsInCat.some((s) => s.id === e.section_id));
      const unWrap = document.createElement("div");
      unWrap.className = "dossier-unsectioned dossier-drop-zone";
      if (unsectioned.length) {
        unsectioned.forEach((entry) => unWrap.appendChild(buildEntryEl(entry)));
      } else if (secs.length && isAdmin()) {
        // Visible seulement si on peut effectivement glisser une entrée
        // (isAdmin()) : en mode lecture / pour un non-admin, les entrées
        // ne sont plus draggable (buildEntryEl), donc ce texte d'aide au
        // glisser-déposer n'a plus de sens et doit disparaître lui aussi.
        const hint = document.createElement("p");
        hint.className = "muted dossier-drop-hint edit-control";
        hint.textContent = "Déposez ici une entrée pour la sortir de ses sous-sections.";
        unWrap.appendChild(hint);
      }
      if (unsectioned.length || secs.length) container.appendChild(unWrap);
      registerSectionDropZone(unWrap, null);
      // Sous-sections de même niveau (level-2) côte à côte dans une grille
      // (.dossier-sections-grid, style.css) plutôt qu'empilées pleine
      // largeur une par une — demande de Martin. Les enfants (level-3) ne
      // sont pas concernés : ils restent ajoutés par buildSectionGroupEl
      // comme descendants du <div> level-2 de leur parent, donc hors de
      // cette grille qui ne reçoit que les sections de niveau 2.
      if (secs.length) {
        const secsGrid = document.createElement("div");
        secsGrid.className = "dossier-sections-grid";
        secs.forEach((sec) => secsGrid.appendChild(buildSectionGroupEl(sec, filtered)));
        container.appendChild(secsGrid);
      }
      return;
    }
    const cats = orderedCategories();
    cats.forEach(([id, cat]) => {
      const inCat = entries.filter((e) => (e.category_id || null) === id);
      if (!inCat.length) return;
      const title = document.createElement("div");
      title.className = "dossier-cat-section-title";
      title.textContent = cat.name;
      container.appendChild(title);
      inCat.forEach((entry) => container.appendChild(buildEntryEl(entry)));
    });
    const uncategorized = entries.filter((e) => !e.category_id || !categoryDocs.has(e.category_id));
    if (uncategorized.length) {
      const title = document.createElement("div");
      title.className = "dossier-cat-section-title";
      title.textContent = "Non classé";
      container.appendChild(title);
      uncategorized.forEach((entry) => container.appendChild(buildEntryEl(entry)));
    }
    if (!container.children.length) {
      container.innerHTML =
        '<p class="muted">Aucune entrée pour le moment. Utilisez les boutons ci-dessus pour ajouter du texte, une photo ou un lien.</p>';
    }
  }

  // Le bouton "+ Hémicycle" n'a de sens que pour les catégories "Politique"
  // et "Histoire" (demande de Martin, 2026-10-03) — masqué (display:none,
  // pas juste désactivé) dans toutes les autres catégories, y compris
  // "Toutes les entrées". Comparaison par NOM (et non par id, qui est un
  // uuid généré par la base) : voir DEFAULT_DOSSIER_CATEGORIES ci-dessus.
  const HEMICYCLE_ALLOWED_CATEGORY_NAMES = ["Politique", "Histoire"];
  function updateHemicycleButtonVisibility() {
    const btn = $("dossier-add-hemicycle-btn") as HTMLButtonElement;
    const cat = activeCategory !== "__all__" ? categoryDocs.get(activeCategory) : null;
    const allowed = !!cat && HEMICYCLE_ALLOWED_CATEGORY_NAMES.includes(cat.name);
    btn.style.display = allowed ? "" : "none";
  }
  function renderCategoryHeading() {
    const heading = $("dossier-theme-heading");
    if (activeCategory === "__all__") {
      heading.textContent = "Toutes les entrées";
    } else {
      const cat = categoryDocs.get(activeCategory);
      heading.textContent = cat ? cat.name : "";
    }
    $("dossier-section-bar").style.display = activeCategory !== "__all__" ? "" : "none";
    updateHemicycleButtonVisibility();
  }

  // -------------------------------------------------------------------------
  // Sommaire (cartes par thème)
  // -------------------------------------------------------------------------
  function buildSummaryCard(id: string, cat: Category, count: number, latest: Entry | null): HTMLElement {
    const card = document.createElement("button");
    card.type = "button";
    card.className = "dossier-summary-card" + (count ? "" : " empty");
    const banner = document.createElement("div");
    banner.className = "dsc-banner";
    banner.style.backgroundImage = categoryBannerGradient(id);
    if (cat.image_url) {
      banner.classList.add("has-image");
      banner.style.backgroundImage = "url('" + cat.image_url + "')";
      banner.style.backgroundSize = "cover";
      banner.style.backgroundPosition = cat.image_position || "50% 50%";
    }
    const pattern = document.createElement("div");
    pattern.className = "dsc-banner-pattern";
    banner.appendChild(pattern);
    // Bouton image : visible pour TOUTE catégorie (builtin ou non) dès
    // qu'un compte est connecté — dossier_categories est une table GLOBALE
    // partagée par "space" (schema_v1.sql), donc changer l'image d'une
    // catégorie builtin comme "Histoire" la change pour tous les dossiers
    // pays à la fois, sans migration ni nouvelle table (demande de Martin,
    // 2026-10-03). Renommer/supprimer restent réservés aux catégories
    // non-builtin (inchangé).
    const catActions = document.createElement("div");
    catActions.className = "dsc-banner-actions";
    let hasCatActions = false;
    if (isAdmin()) {
      const imageBtn = document.createElement("button");
      imageBtn.type = "button";
      imageBtn.className = "dsc-image-btn";
      imageBtn.title = "Changer l'image";
      imageBtn.innerHTML = CAMERA_ICON_SVG;
      imageBtn.addEventListener("click", (e) => {
        e.stopPropagation();
        startCategoryImageUpload(id);
      });
      catActions.appendChild(imageBtn);
      hasCatActions = true;
    }
    if (!cat.builtin && isAdmin()) {
      const menuBtn = document.createElement("button");
      menuBtn.type = "button";
      menuBtn.className = "dsc-menu-btn";
      menuBtn.title = "Renommer ce thème";
      menuBtn.textContent = "✎";
      menuBtn.addEventListener("click", async (e) => {
        e.stopPropagation();
        await renameCategory(id);
        renderDossierSummary();
      });
      catActions.appendChild(menuBtn);
      const delBtn = document.createElement("button");
      delBtn.type = "button";
      delBtn.className = "dsc-del-btn";
      delBtn.title = "Supprimer ce thème";
      delBtn.innerHTML = TRASH_ICON_SVG;
      delBtn.addEventListener("click", async (e) => {
        e.stopPropagation();
        await deleteCategory(id);
        renderDossierSummary();
      });
      catActions.appendChild(delBtn);
      hasCatActions = true;
    }
    if (hasCatActions) banner.appendChild(catActions);
    attachBannerDragReframe(
      banner,
      () => cat.image_url,
      () => isAdmin(),
      (pos) => saveCategoryImagePosition(id, pos)
    );
    card.appendChild(banner);

    const body = document.createElement("div");
    body.className = "dsc-body";
    const nameEl = document.createElement("div");
    nameEl.className = "dsc-name";
    nameEl.textContent = cat.name;
    body.appendChild(nameEl);
    const metaEl = document.createElement("div");
    metaEl.className = "dsc-meta";
    metaEl.textContent = count
      ? count + " entrée" + (count > 1 ? "s" : "") + (latest ? " · " + relativeTimeFr(latest.updated_at || latest.created_at) : "")
      : "Aucune entrée pour le moment";
    body.appendChild(metaEl);
    if (latest) {
      const full = entryPlainText(latest as DossierEntryLike);
      const preview = full.slice(0, 100).trim();
      if (preview) {
        const prevEl = document.createElement("div");
        prevEl.className = "dsc-preview";
        prevEl.textContent = preview + (full.length > 100 ? "…" : "");
        body.appendChild(prevEl);
      }
    }
    card.appendChild(body);
    card.addEventListener("click", () => showThemeView(id));
    return card;
  }

  function renderDossierSummary() {
    const statsEl = $("dossier-summary-stats");
    const themesEl = $("dossier-summary-themes");
    themesEl.innerHTML = "";
    const cats = orderedCategories();
    let totalWords = 0;
    currentEntries.forEach((e) => (totalWords += wordCountForEntry(e as DossierEntryLike)));
    const activeCount = cats.filter(([id]) => currentEntries.some((e) => (e.category_id || null) === id)).length;
    statsEl.textContent =
      activeCount +
      " thème(s) actif(s) · " +
      currentEntries.length +
      " entrée(s) au total" +
      (totalWords ? " · " + totalWords + " mots (~" + readingTimeMinutes(totalWords) + " min de lecture)" : "");
    if (currentEntries.length) {
      const allLink = document.createElement("button");
      allLink.type = "button";
      allLink.className = "btn-small";
      allLink.style.marginLeft = "6px";
      allLink.textContent = "Voir toutes les entrées";
      allLink.addEventListener("click", () => showThemeView("__all__"));
      statsEl.appendChild(allLink);
    }
    cats.forEach(([id, cat]) => {
      const inCat = currentEntries.filter((e) => (e.category_id || null) === id);
      const latest = inCat.length
        ? inCat.reduce((a, b) => ((b.updated_at || b.created_at) > (a.updated_at || a.created_at) ? b : a))
        : null;
      themesEl.appendChild(buildSummaryCard(id, cat, inCat.length, latest));
    });
    if (isAdmin()) {
      const newCard = document.createElement("button");
      newCard.type = "button";
      newCard.className = "dsc-new-card";
      newCard.innerHTML = '<span style="font-size:18px;">+</span> Nouveau thème';
      newCard.addEventListener("click", async () => {
        const name = ((await customPrompt("Nom du nouveau thème :")) || "").trim();
        if (!name) return;
        const id = await addCategory(name);
        renderDossierSummary();
        if (id) showThemeView(id);
      });
      themesEl.appendChild(newCard);
    }
  }

  function showDossierSummary() {
    $("dossier-entry-read-view").style.display = "none";
    $("dossier-summary").style.display = "";
    $("dossier-theme-view").style.display = "none";
    $("dossier-inner").classList.add("dossier-inner-wide");
    renderDossierSummary();
  }
  function showThemeView(catId: string) {
    $("dossier-entry-read-view").style.display = "none";
    $("dossier-summary").style.display = "none";
    $("dossier-theme-view").style.display = "";
    $("dossier-inner").classList.remove("dossier-inner-wide");
    activeCategory = catId || "__all__";
    populateCategorySelects();
    renderCategoryHeading();
    renderDossierEntries();
  }
  $("dossier-summary-back").addEventListener("click", showDossierSummary);

  // -------------------------------------------------------------------------
  // Vue de lecture d'une entrée de texte
  // -------------------------------------------------------------------------
  function openEntryReadView(entry: Entry) {
    readingEntryId = entry.id;
    $("dossier-summary").style.display = "none";
    $("dossier-theme-view").style.display = "none";
    $("dossier-inner").classList.remove("dossier-inner-wide", "dossier-inner-text-editing");
    $("dossier-entry-read-view").style.display = "block";
    $("dossier-read-title").textContent = entry.title || entryPlainText(entry as DossierEntryLike).slice(0, 60) || "Sans titre";
    $("dossier-read-meta").textContent = dossierEntryDate(entry.created_at);
    $("dossier-read-body").innerHTML = autoLinkEntryBody(sanitizeDossierHTML(entry.body || ""));
    const words = wordCountForEntry(entry as DossierEntryLike);
    const wcEl = $("dossier-read-wordcount");
    if (words > 0) {
      wcEl.textContent = words + " mot" + (words > 1 ? "s" : "") + " · ~" + readingTimeMinutes(words) + " min de lecture";
      wcEl.style.display = "";
    } else {
      wcEl.style.display = "none";
    }
    $("dossier-view").scrollTop = 0;
  }
  function closeEntryReadView() {
    readingEntryId = null;
    $("dossier-entry-read-view").style.display = "none";
    $("dossier-theme-view").style.display = "";
  }
  $("dossier-read-back").addEventListener("click", closeEntryReadView);
  $("dossier-read-edit").addEventListener("click", () => {
    const entry = currentEntries.find((e) => e.id === readingEntryId);
    closeEntryReadView();
    if (entry) startEditEntry(entry);
  });

  // -------------------------------------------------------------------------
  // Historique des modifications
  // -------------------------------------------------------------------------
  function openHistoryModal(entry: Entry) {
    const modal = $("dossier-history-modal");
    const list = $("dossier-history-list");
    list.innerHTML = "";
    (entry.history || [])
      .slice()
      .reverse()
      .forEach((version) => {
        const row = document.createElement("div");
        row.className = "dossier-history-row";
        const when = document.createElement("div");
        when.className = "dhr-when";
        when.textContent = dossierEntryDate(new Date(version.archivedAt).toISOString());
        row.appendChild(when);
        if (version.title) {
          const t = document.createElement("div");
          t.className = "dhr-title";
          t.textContent = version.title;
          row.appendChild(t);
        }
        const preview = document.createElement("div");
        preview.className = "dhr-preview";
        preview.textContent = (
          version.body
            ? sanitizeDossierHTML(version.body)
            : version.hemicycle
            ? (version.hemicycle.parties || []).map((p) => p.name + " (" + p.seats + ")").join(", ")
            : version.caption || version.label || version.url || ""
        ).slice(0, 200);
        row.appendChild(preview);
        if (canModify(entry)) {
          const restoreBtn = document.createElement("button");
          restoreBtn.type = "button";
          restoreBtn.className = "btn-small";
          restoreBtn.textContent = "Restaurer cette version";
          restoreBtn.addEventListener("click", async () => {
            if (!(await customConfirm("Restaurer cette version ? La version actuelle sera elle-même archivée dans l'historique."))) return;
            const restoreData: Partial<Entry> = {};
            if (version.title !== undefined) restoreData.title = version.title;
            if (version.body !== undefined) restoreData.body = version.body;
            if (version.caption !== undefined) restoreData.caption = version.caption;
            if (version.label !== undefined) restoreData.label = version.label;
            if (version.url !== undefined) restoreData.link_url = version.url;
            if (version.hemicycle !== undefined) restoreData.hemicycle = version.hemicycle;
            await updateEntry(entry.id, restoreData);
            modal.classList.remove("open");
            renderDossierEntries();
          });
          row.appendChild(restoreBtn);
        }
        list.appendChild(row);
      });
    modal.classList.add("open");
  }
  $("dossier-history-close").addEventListener("click", () => $("dossier-history-modal").classList.remove("open"));
  $("dossier-history-modal").addEventListener("click", (e) => {
    if ((e.target as HTMLElement).id === "dossier-history-modal") $("dossier-history-modal").classList.remove("open");
  });

  // -------------------------------------------------------------------------
  // Lightbox photo
  // -------------------------------------------------------------------------
  function openLightbox(entry: Entry) {
    const box = $("dossier-lightbox");
    ($("dossier-lightbox-img") as HTMLImageElement).src = entry.photo_url || "";
    $("dossier-lightbox-caption").textContent = entry.caption || entry.title || "";
    box.classList.add("open");
  }
  $("dossier-lightbox-close").addEventListener("click", () => $("dossier-lightbox").classList.remove("open"));
  $("dossier-lightbox").addEventListener("click", (e) => {
    if ((e.target as HTMLElement).id === "dossier-lightbox") $("dossier-lightbox").classList.remove("open");
  });

  // -------------------------------------------------------------------------
  // Sélecteurs de catégorie / sous-section (barre d'ajout + formulaires)
  // -------------------------------------------------------------------------
  function populateCategorySelects() {
    const cats = orderedCategories();
    ([$("dossier-entry-category"), $("dossier-text-category"), $("dossier-link-category"), $("dossier-hemicycle-category"), $("dossier-genealogy-entry-category")] as HTMLSelectElement[]).forEach((sel) => {
      const prev = sel.value;
      sel.innerHTML = "";
      cats.forEach(([id, cat]) => {
        const opt = document.createElement("option");
        opt.value = id;
        opt.textContent = cat.name;
        sel.appendChild(opt);
      });
      if (activeCategory !== "__all__" && cats.some(([id]) => id === activeCategory)) sel.value = activeCategory;
      else if (cats.some(([id]) => id === prev)) sel.value = prev;
    });
    populateSectionSelects();
  }
  function populateSectionSelects() {
    const pairs: [string, string][] = [
      ["dossier-entry-category", "dossier-entry-section"],
      ["dossier-text-category", "dossier-text-section"],
      ["dossier-link-category", "dossier-link-section"],
      ["dossier-hemicycle-category", "dossier-hemicycle-section"],
      ["dossier-genealogy-entry-category", "dossier-genealogy-entry-section"],
    ];
    pairs.forEach(([catSelId, secSelId]) => {
      const catSel = $(catSelId) as HTMLSelectElement;
      const secSel = $(secSelId) as HTMLSelectElement;
      const catId = catSel.value;
      const prev = secSel.value;
      const secs = currentSections.filter((s) => s.category_id === catId);
      const top = secs.filter((s) => !s.parent_section_id).sort((a, b) => a.position - b.position);
      const ordered: Section[] = [];
      top.forEach((s) => {
        ordered.push(s);
        secs
          .filter((c) => c.parent_section_id === s.id)
          .sort((a, b) => a.position - b.position)
          .forEach((c) => ordered.push(c));
      });
      secSel.innerHTML = "";
      const noneOpt = document.createElement("option");
      noneOpt.value = "";
      noneOpt.textContent = secs.length ? "Sans sous-section" : "(aucune sous-section dans ce thème)";
      secSel.appendChild(noneOpt);
      ordered.forEach((s) => {
        const opt = document.createElement("option");
        opt.value = s.id;
        opt.textContent = (s.parent_section_id ? "— " : "") + s.name;
        secSel.appendChild(opt);
      });
      if (secs.some((s) => s.id === prev)) secSel.value = prev;
    });
  }
  ["dossier-entry-category", "dossier-text-category", "dossier-link-category", "dossier-hemicycle-category", "dossier-genealogy-entry-category"].forEach((id) => {
    $(id).addEventListener("change", populateSectionSelects);
  });
  $("dossier-add-section-btn").addEventListener("click", async () => {
    const name = ((await customPrompt("Nom de la nouvelle sous-section :")) || "").trim();
    if (!name) return;
    const catId = ($("dossier-entry-category") as HTMLSelectElement).value;
    if (!catId) return;
    await addSection(name, catId, null);
    populateSectionSelects();
    renderDossierEntries();
  });

  // -------------------------------------------------------------------------
  // Sources / étiquettes (éditeur du formulaire texte)
  // -------------------------------------------------------------------------
  function renderSourcesEditor() {
    const wrap = $("dossier-text-sources-list");
    wrap.innerHTML = "";
    editingSourcesDraft.forEach((src, idx) => {
      const row = document.createElement("div");
      row.className = "dossier-source-row";
      const labelInp = document.createElement("input");
      labelInp.type = "text";
      labelInp.placeholder = "Référence (ex. Le Monde, 12 mars 2024)";
      labelInp.value = src.label || "";
      labelInp.addEventListener("input", () => {
        editingSourcesDraft[idx].label = labelInp.value;
        scheduleTextAutosave();
      });
      const urlInp = document.createElement("input");
      urlInp.type = "text";
      urlInp.placeholder = "URL (optionnel)";
      urlInp.value = src.url || "";
      urlInp.addEventListener("input", () => {
        editingSourcesDraft[idx].url = urlInp.value;
        scheduleTextAutosave();
      });
      const rm = document.createElement("button");
      rm.type = "button";
      rm.className = "btn-small entry-del";
      rm.style.cssText = "position:static;opacity:1;";
      rm.innerHTML = TRASH_ICON_SVG;
      rm.title = "Retirer cette source";
      rm.addEventListener("click", () => {
        editingSourcesDraft.splice(idx, 1);
        renderSourcesEditor();
        scheduleTextAutosave();
      });
      row.appendChild(labelInp);
      row.appendChild(urlInp);
      row.appendChild(rm);
      wrap.appendChild(row);
    });
  }
  $("dossier-text-source-add").addEventListener("click", () => {
    editingSourcesDraft.push({ label: "", url: "" });
    renderSourcesEditor();
  });
  function renderTagsEditor() {
    const wrap = $("dossier-text-tags-chips");
    wrap.innerHTML = "";
    editingTagsDraft.forEach((tag, idx) => {
      const chip = document.createElement("span");
      chip.className = "dossier-tag-chip-edit";
      chip.textContent = tag;
      const rm = document.createElement("button");
      rm.type = "button";
      rm.textContent = "×";
      rm.addEventListener("click", () => {
        editingTagsDraft.splice(idx, 1);
        renderTagsEditor();
        scheduleTextAutosave();
      });
      chip.appendChild(rm);
      wrap.appendChild(chip);
    });
  }
  function addTagFromInput() {
    const input = $("dossier-text-tags-input") as HTMLInputElement;
    const raw = input.value.replace(/,+$/, "").trim();
    input.value = "";
    if (!raw) return;
    raw
      .split(",")
      .map((t) => t.trim())
      .filter(Boolean)
      .forEach((t) => {
        if (!editingTagsDraft.some((existing) => existing.toLowerCase() === t.toLowerCase())) editingTagsDraft.push(t);
      });
    renderTagsEditor();
    scheduleTextAutosave();
  }
  const tagsInputEl = $("dossier-text-tags-input") as HTMLInputElement;
  tagsInputEl.addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      addTagFromInput();
    }
  });
  tagsInputEl.addEventListener("input", () => {
    if (tagsInputEl.value.endsWith(",")) addTagFromInput();
  });

  // -------------------------------------------------------------------------
  // Éditeur de texte riche — porté de initDossierRichTextToolbar()
  // -------------------------------------------------------------------------
  const editor = $("dossier-text-body");
  const toolbar = $("dossier-rt-toolbar");
  function focusEditor() {
    editor.focus();
  }
  function captureEditorRange(): Range | null {
    const sel = window.getSelection();
    if (sel && sel.rangeCount && editor.contains(sel.anchorNode)) return sel.getRangeAt(0).cloneRange();
    return null;
  }
  function restoreEditorRange(range: Range | null) {
    focusEditor();
    const sel = window.getSelection();
    if (!sel) return;
    sel.removeAllRanges();
    if (range) {
      try {
        sel.addRange(range);
        return;
      } catch {
        /* fallthrough */
      }
    }
    const fallback = document.createRange();
    fallback.selectNodeContents(editor);
    fallback.collapse(false);
    sel.addRange(fallback);
  }
  function currentTable(): HTMLElement | null {
    const sel = window.getSelection();
    if (!sel || !sel.anchorNode) return null;
    let node: Node | null = sel.anchorNode;
    if (node.nodeType === Node.TEXT_NODE) node = node.parentNode;
    while (node && node !== editor) {
      if ((node as HTMLElement).tagName === "TABLE") return node as HTMLElement;
      node = node.parentNode;
    }
    return null;
  }
  async function insertTable() {
    const savedRange = captureEditorRange();
    focusEditor();
    const rowsStr = await customPrompt("Nombre de lignes du tableau :", "2");
    if (rowsStr === null) return;
    const colsStr = await customPrompt("Nombre de colonnes du tableau :", "2");
    if (colsStr === null) return;
    const rows = Math.max(1, Math.min(20, parseInt(rowsStr, 10) || 2));
    const cols = Math.max(1, Math.min(10, parseInt(colsStr, 10) || 2));
    let html = "<table><tbody>";
    for (let r = 0; r < rows; r++) {
      html += "<tr>";
      for (let c = 0; c < cols; c++) html += "<td>&nbsp;</td>";
      html += "</tr>";
    }
    html += "</tbody></table><p><br></p>";
    restoreEditorRange(savedRange);
    document.execCommand("insertHTML", false, html);
    rtPushHistory();
    scheduleTextAutosave();
  }
  async function addTableRow() {
    const table = currentTable();
    if (!table) {
      await customAlert("Placez le curseur dans un tableau pour lui ajouter une ligne.");
      return;
    }
    const tbody = table.querySelector("tbody") || table;
    const firstRow = tbody.querySelector("tr");
    const cols = firstRow ? firstRow.children.length : 1;
    const tr = document.createElement("tr");
    for (let c = 0; c < cols; c++) {
      const td = document.createElement("td");
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);
    }
    tbody.appendChild(tr);
    scheduleTextAutosave();
  }
  async function addTableCol() {
    const table = currentTable();
    if (!table) {
      await customAlert("Placez le curseur dans un tableau pour lui ajouter une colonne.");
      return;
    }
    table.querySelectorAll("tr").forEach((tr) => {
      const td = document.createElement("td");
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);
    });
    scheduleTextAutosave();
  }
  try {
    document.execCommand("defaultParagraphSeparator", false, "p");
  } catch {
    /* ignore */
  }

  let rtHistory: string[] = [""];
  let rtHistoryIndex = 0;
  let rtHistorySuspend = false;
  let rtHistoryTimer: number | null = null;
  function rtResetHistory() {
    rtHistory = [editor.innerHTML];
    rtHistoryIndex = 0;
  }
  function rtPushHistory() {
    if (rtHistorySuspend) return;
    const html = editor.innerHTML;
    if (rtHistory[rtHistoryIndex] === html) return;
    rtHistory = rtHistory.slice(0, rtHistoryIndex + 1);
    rtHistory.push(html);
    if (rtHistory.length > 60) rtHistory.shift();
    rtHistoryIndex = rtHistory.length - 1;
  }
  function rtPushHistoryDebounced() {
    if (rtHistoryTimer) window.clearTimeout(rtHistoryTimer);
    rtHistoryTimer = window.setTimeout(rtPushHistory, 600);
  }
  function updateWordCountLive() {
    const el = $("dossier-text-wordcount");
    const text = (editor.textContent || "").trim();
    const words = text ? text.split(/\s+/).length : 0;
    el.textContent = words + " mot" + (words > 1 ? "s" : "") + " · " + text.length + " caractère" + (text.length > 1 ? "s" : "");
  }
  function rtUndo() {
    if (rtHistoryTimer) window.clearTimeout(rtHistoryTimer);
    rtPushHistory();
    if (rtHistoryIndex <= 0) return;
    rtHistoryIndex--;
    rtHistorySuspend = true;
    editor.innerHTML = rtHistory[rtHistoryIndex];
    rtHistorySuspend = false;
    updateWordCountLive();
    scheduleTextAutosave();
  }
  function rtRedo() {
    if (rtHistoryIndex >= rtHistory.length - 1) return;
    rtHistoryIndex++;
    rtHistorySuspend = true;
    editor.innerHTML = rtHistory[rtHistoryIndex];
    rtHistorySuspend = false;
    updateWordCountLive();
    scheduleTextAutosave();
  }
  function applyInlineSpan(build: (span: HTMLSpanElement) => void) {
    const sel = window.getSelection();
    if (!sel || !sel.rangeCount || sel.isCollapsed || !editor.contains(sel.anchorNode)) return;
    const range = sel.getRangeAt(0);
    const span = document.createElement("span");
    build(span);
    try {
      range.surroundContents(span);
    } catch {
      const frag = range.extractContents();
      span.appendChild(frag);
      range.deleteContents();
      range.insertNode(span);
    }
    sel.removeAllRanges();
    const newRange = document.createRange();
    newRange.selectNodeContents(span);
    sel.addRange(newRange);
    rtPushHistory();
    scheduleTextAutosave();
  }
  function wrapSelectionTag(tagName: string) {
    const sel = window.getSelection();
    if (!sel || !sel.rangeCount || sel.isCollapsed || !editor.contains(sel.anchorNode)) return;
    const range = sel.getRangeAt(0);
    const wrap = document.createElement(tagName);
    try {
      range.surroundContents(wrap);
    } catch {
      const frag = range.extractContents();
      wrap.appendChild(frag);
      range.insertNode(wrap);
    }
    sel.removeAllRanges();
    const newRange = document.createRange();
    newRange.selectNodeContents(wrap);
    sel.addRange(newRange);
    rtPushHistory();
    scheduleTextAutosave();
  }
  function insertChecklist() {
    focusEditor();
    document.execCommand("insertHTML", false, '<ul class="rt-checklist"><li class="rt-check" data-checked="false"><br></li></ul><p><br></p>');
    rtPushHistory();
    scheduleTextAutosave();
  }

  // --- Recherche / remplacement --------------------------------------------
  const findBar = $("dossier-rt-findbar");
  const findInput = $("dossier-rt-find-input") as HTMLInputElement;
  const replaceInput = $("dossier-rt-replace-input") as HTMLInputElement;
  const findStatus = $("dossier-rt-find-status");
  function clearFindHighlights() {
    editor.querySelectorAll("mark.rt-find-hit").forEach((m) => {
      const parent = m.parentNode!;
      while (m.firstChild) parent.insertBefore(m.firstChild, m);
      parent.removeChild(m);
    });
    editor.normalize();
  }
  function runFindHighlight() {
    clearFindHighlights();
    const term = findInput.value;
    if (!term) {
      findStatus.textContent = "";
      return;
    }
    const walker = document.createTreeWalker(editor, NodeFilter.SHOW_TEXT, null);
    const hits: Text[] = [];
    let node: Node | null;
    while ((node = walker.nextNode())) hits.push(node as Text);
    let count = 0;
    hits.forEach((textNode) => {
      const value = textNode.nodeValue || "";
      const lower = value.toLowerCase();
      const needle = term.toLowerCase();
      let idx = lower.indexOf(needle);
      if (idx === -1) return;
      const frag = document.createDocumentFragment();
      let last = 0;
      while (idx !== -1) {
        if (idx > last) frag.appendChild(document.createTextNode(value.slice(last, idx)));
        const mark = document.createElement("mark");
        mark.className = "rt-find-hit";
        mark.textContent = value.slice(idx, idx + term.length);
        frag.appendChild(mark);
        count++;
        last = idx + term.length;
        idx = lower.indexOf(needle, last);
      }
      if (last < value.length) frag.appendChild(document.createTextNode(value.slice(last)));
      textNode.parentNode!.replaceChild(frag, textNode);
    });
    findStatus.textContent = count ? count + " résultat" + (count > 1 ? "s" : "") : "Aucun résultat";
  }
  function replaceOne() {
    const first = editor.querySelector("mark.rt-find-hit");
    if (!first) {
      runFindHighlight();
      return;
    }
    first.textContent = replaceInput.value;
    first.classList.remove("rt-find-hit");
    const parent = first.parentNode!;
    while (first.firstChild) parent.insertBefore(first.firstChild, first);
    parent.removeChild(first);
    editor.normalize();
    rtPushHistory();
    scheduleTextAutosave();
    runFindHighlight();
  }
  function replaceAll() {
    const hits = Array.from(editor.querySelectorAll("mark.rt-find-hit"));
    hits.forEach((m) => {
      m.textContent = replaceInput.value;
    });
    clearFindHighlights();
    rtPushHistory();
    scheduleTextAutosave();
    findStatus.textContent = hits.length ? "Remplacé (" + hits.length + ")" : "";
  }
  $("dossier-rt-replace-one").addEventListener("click", replaceOne);
  $("dossier-rt-replace-all").addEventListener("click", replaceAll);
  $("dossier-rt-find-close").addEventListener("click", () => {
    findBar.classList.remove("open");
    clearFindHighlights();
  });
  findInput.addEventListener("input", runFindHighlight);

  const colorInput = $("dossier-rt-color-input") as HTMLInputElement;
  const hiColorInput = $("dossier-rt-hicolor-input") as HTMLInputElement;
  colorInput.addEventListener("input", () => {
    $("dossier-rt-color-btn").style.borderBottomColor = colorInput.value;
    applyInlineSpan((span) => {
      span.style.color = colorInput.value;
    });
  });
  hiColorInput.addEventListener("input", () => {
    $("dossier-rt-hicolor-btn").style.borderBottomColor = hiColorInput.value;
    applyInlineSpan((span) => {
      span.style.backgroundColor = hiColorInput.value;
    });
  });
  ($("dossier-rt-fontsize") as HTMLSelectElement).addEventListener("change", (e) => {
    const cls = (e.target as HTMLSelectElement).value;
    if (!cls) return;
    applyInlineSpan((span) => {
      span.className = cls;
    });
    (e.target as HTMLSelectElement).value = "";
  });

  editor.addEventListener("click", (e) => {
    const li = (e.target as HTMLElement).closest("li.rt-check") as HTMLElement | null;
    if (!li || !editor.contains(li)) return;
    e.preventDefault();
    const checked = li.getAttribute("data-checked") === "true";
    li.setAttribute("data-checked", checked ? "false" : "true");
    rtPushHistory();
    scheduleTextAutosave();
  });

  toolbar.addEventListener("mousedown", (e) => {
    if ((e.target as HTMLElement).closest("button")) e.preventDefault();
  });
  toolbar.addEventListener("click", async (e) => {
    const btn = (e.target as HTMLElement).closest("button") as HTMLButtonElement | null;
    if (!btn) return;
    e.preventDefault();
    focusEditor();
    if (btn.dataset.action === "undo") {
      rtUndo();
      return;
    }
    if (btn.dataset.action === "redo") {
      rtRedo();
      return;
    }
    if (btn.dataset.action === "find") {
      findBar.classList.toggle("open");
      if (findBar.classList.contains("open")) findInput.focus();
      else clearFindHighlights();
      return;
    }
    if (btn.dataset.cmd) {
      document.execCommand(btn.dataset.cmd, false);
    } else if (btn.dataset.block) {
      document.execCommand("formatBlock", false, btn.dataset.block === "p" ? "p" : btn.dataset.block);
    } else if (btn.dataset.action === "table") {
      await insertTable();
    } else if (btn.dataset.action === "table-row") {
      await addTableRow();
    } else if (btn.dataset.action === "table-col") {
      await addTableCol();
    } else if (btn.dataset.action === "inline-code") {
      wrapSelectionTag("code");
    } else if (btn.dataset.action === "hr") {
      document.execCommand("insertHorizontalRule");
    } else if (btn.dataset.action === "checklist") {
      insertChecklist();
    } else if (btn.dataset.action === "text-color") {
      colorInput.click();
    } else if (btn.dataset.action === "hi-color") {
      hiColorInput.click();
    } else if (btn.dataset.action === "internal-link") {
      const sel = window.getSelection();
      const range = sel && sel.rangeCount ? sel.getRangeAt(0).cloneRange() : null;
      openCountryPicker("Insérer un lien vers…", (picked) => {
        focusEditor();
        if (range) {
          try {
            sel!.removeAllRanges();
            sel!.addRange(range);
          } catch {
            /* ignore */
          }
        }
        document.execCommand(
          "insertHTML",
          false,
          '<a data-entity-kind="country" data-entity-id="' + picked.slug + '">' + escapeHtml(frenchCountryName(picked.name)) + "</a>&nbsp;"
        );
        rtPushHistory();
        scheduleTextAutosave();
      });
    }
    rtPushHistory();
    updateWordCountLive();
    scheduleTextAutosave();
  });
  editor.addEventListener("keydown", (e) => {
    if ((e.ctrlKey || e.metaKey) && !e.shiftKey && e.key.toLowerCase() === "b") {
      e.preventDefault();
      document.execCommand("bold");
      rtPushHistory();
    }
    if ((e.ctrlKey || e.metaKey) && !e.shiftKey && e.key.toLowerCase() === "i") {
      e.preventDefault();
      document.execCommand("italic");
      rtPushHistory();
    }
    if ((e.ctrlKey || e.metaKey) && !e.shiftKey && e.key.toLowerCase() === "u") {
      e.preventDefault();
      document.execCommand("underline");
      rtPushHistory();
    }
    if ((e.ctrlKey || e.metaKey) && !e.shiftKey && e.key.toLowerCase() === "z") {
      e.preventDefault();
      rtUndo();
    }
    if ((e.ctrlKey || e.metaKey) && (e.key.toLowerCase() === "y" || (e.shiftKey && e.key.toLowerCase() === "z"))) {
      e.preventDefault();
      rtRedo();
    }
  });
  editor.addEventListener("input", () => {
    scheduleTextAutosave();
    updateWordCountLive();
    rtPushHistoryDebounced();
  });
  // --- Conversion automatique "- " -> liste à puces (demande explicite de
  // Martin) : déclenchée sur la frappe de l'ESPACE qui suit un tiret en
  // tout DÉBUT de ligne (le tiret peut lui-même être précédé d'un espace :
  // "- " ou " - " sont acceptés) — porté à l'identique de l'artifact.
  editor.addEventListener("keyup", (e) => {
    if (e.key !== " ") return;
    const sel = window.getSelection();
    if (!sel || !sel.rangeCount || !sel.isCollapsed) return;
    const range = sel.getRangeAt(0);
    const node = range.startContainer;
    if (node.nodeType !== Node.TEXT_NODE) return;
    const textBefore = (node.textContent || "").slice(0, range.startOffset);
    const m = textBefore.match(/^([  ]?-)[  ]$/);
    if (!m) return;
    let prev: Node | null = node.previousSibling;
    let onlyBlankBefore = true;
    while (prev) {
      if (prev.nodeType === Node.TEXT_NODE && (prev.textContent || "").trim() !== "") {
        onlyBlankBefore = false;
        break;
      }
      if (prev.nodeType === Node.ELEMENT_NODE && (prev as Element).tagName !== "BR") {
        onlyBlankBefore = false;
        break;
      }
      prev = prev.previousSibling;
    }
    if (!onlyBlankBefore) return;
    const cut = m[0].length;
    const caretOffset = range.startOffset;
    node.textContent = (node.textContent || "").slice(0, caretOffset - cut) + (node.textContent || "").slice(caretOffset);
    const newRange = document.createRange();
    newRange.setStart(node, caretOffset - cut);
    newRange.collapse(true);
    sel.removeAllRanges();
    sel.addRange(newRange);
    document.execCommand("insertUnorderedList");
    rtPushHistory();
    scheduleTextAutosave();
    updateWordCountLive();
  });
  // Un collage peut apporter du HTML arbitraire depuis l'extérieur : on
  // l'intercepte AVANT toute insertion dans le DOM et on n'insère que la
  // version déjà sanitisée.
  editor.addEventListener("paste", (e) => {
    e.preventDefault();
    const cd = e.clipboardData;
    const html = cd ? cd.getData("text/html") : "";
    const text = cd ? cd.getData("text/plain") : "";
    if (html) {
      document.execCommand("insertHTML", false, sanitizeDossierHTML(html));
    } else if (text) {
      document.execCommand("insertText", false, text);
    }
    rtPushHistory();
    updateWordCountLive();
    scheduleTextAutosave();
  });

  // -------------------------------------------------------------------------
  // Sélecteur de pays (lien interne)
  // -------------------------------------------------------------------------
  function normalize(s: string): string {
    return (s || "")
      .normalize("NFD")
      .replace(/[̀-ͯ]/g, "")
      .toLowerCase();
  }
  function openCountryPicker(label: string, onSelect: (picked: CountryRef) => void) {
    const panel = $("dossier-entity-picker");
    const input = $("dossier-entity-picker-input") as HTMLInputElement;
    const results = $("dossier-entity-picker-results");
    $("dossier-entity-picker-label").textContent = label;
    input.value = "";
    results.innerHTML = "";
    panel.classList.add("open");
    function close() {
      panel.classList.remove("open");
      input.removeEventListener("input", onInput);
      closeBtn.removeEventListener("click", close);
    }
    function onInput() {
      const q = normalize(input.value.trim());
      results.innerHTML = "";
      if (!q) return;
      const matches = deps
        .getAllCountries()
        .filter((c) => normalize(frenchCountryName(c.name)).includes(q))
        .slice(0, 8);
      matches.forEach((m) => {
        const btn = document.createElement("button");
        btn.type = "button";
        const flagNode = flagSvgSpan(m.slug, m.iso2);
        if (flagNode) btn.appendChild(flagNode);
        btn.appendChild(document.createTextNode((flagNode ? " " : "") + frenchCountryName(m.name)));
        btn.addEventListener("click", () => {
          close();
          onSelect(m);
        });
        results.appendChild(btn);
      });
    }
    const closeBtn = $("dossier-entity-picker-close");
    input.addEventListener("input", onInput);
    closeBtn.addEventListener("click", close);
    setTimeout(() => input.focus(), 30);
  }

  // -------------------------------------------------------------------------
  // Formulaires d'ajout / édition (texte, photo, lien)
  // -------------------------------------------------------------------------
  function closeDossierForms() {
    flushTextAutosave();
    $("dossier-text-form").classList.remove("open");
    $("dossier-inner").classList.remove("dossier-inner-text-editing");
    $("dossier-link-form").classList.remove("open");
    $("dossier-hemicycle-form").classList.remove("open");
    $("dossier-genealogy-entry-form").classList.remove("open");
    ($("dossier-text-save") as HTMLButtonElement).textContent = "Ajouter";
    ($("dossier-link-save") as HTMLButtonElement).textContent = "Ajouter";
    ($("dossier-hemicycle-save") as HTMLButtonElement).textContent = "Ajouter";
    editor.innerHTML = "";
    rtResetHistory();
    updateWordCountLive();
    findBar.classList.remove("open");
    ($("dossier-text-draft") as HTMLInputElement).checked = false;
    editingSourcesDraft = [];
    renderSourcesEditor();
    editingTagsDraft = [];
    renderTagsEditor();
    editingHemicycleParties = [];
    editingEntryId = null;
  }
  async function startEditEntry(entry: Entry) {
    closeDossierForms();
    if (!canModify(entry)) {
      if (entry.type === "text") openEntryReadView(entry);
      return;
    }
    editingEntryId = entry.id;
    if (entry.type === "text") {
      ($("dossier-text-title") as HTMLInputElement).value = entry.title || "";
      editor.innerHTML = sanitizeDossierHTML(entry.body || "");
      rtResetHistory();
      updateWordCountLive();
      populateSectionSelects();
      if (entry.category_id) ($("dossier-text-category") as HTMLSelectElement).value = entry.category_id;
      ($("dossier-text-section") as HTMLSelectElement).value = entry.section_id || "";
      editingSourcesDraft = (entry.sources || []).map((s) => ({ ...s }));
      renderSourcesEditor();
      editingTagsDraft = (entry.tags || []).slice();
      renderTagsEditor();
      ($("dossier-text-draft") as HTMLInputElement).checked = entry.status === "draft";
      ($("dossier-text-save") as HTMLButtonElement).textContent = "Enregistrer";
      $("dossier-text-form").classList.add("open");
      $("dossier-inner").classList.add("dossier-inner-text-editing");
    } else if (entry.type === "link") {
      ($("dossier-link-label") as HTMLInputElement).value = entry.label || "";
      ($("dossier-link-url") as HTMLInputElement).value = entry.link_url || "";
      populateSectionSelects();
      if (entry.category_id) ($("dossier-link-category") as HTMLSelectElement).value = entry.category_id;
      ($("dossier-link-section") as HTMLSelectElement).value = entry.section_id || "";
      ($("dossier-link-save") as HTMLButtonElement).textContent = "Enregistrer";
      $("dossier-link-form").classList.add("open");
    } else if (entry.type === "photo") {
      editingEntryId = null;
      const title = await customPrompt("Titre de l'image (optionnel) :", entry.title || "");
      if (title === null) return;
      const caption = await customPrompt("Légende :", entry.caption || "");
      if (caption === null) return;
      await updateEntry(entry.id, { title: title.trim(), caption: caption.trim() });
      renderDossierEntries();
    } else if (entry.type === "hemicycle") {
      const h = entry.hemicycle || { parties: [] };
      ($("dossier-hemicycle-title") as HTMLInputElement).value = h.title || entry.title || "";
      editingHemicycleParties = (h.parties || []).map((p) => ({ ...p }));
      if (!editingHemicycleParties.length) editingHemicycleParties = [defaultHemicyclePartyRow(0)];
      renderHemicyclePartiesEditor();
      ($("dossier-hemicycle-total") as HTMLInputElement).value = h.totalSeats != null ? String(h.totalSeats) : "";
      ($("dossier-hemicycle-source") as HTMLInputElement).value = h.source || "";
      populateSectionSelects();
      if (entry.category_id) ($("dossier-hemicycle-category") as HTMLSelectElement).value = entry.category_id;
      ($("dossier-hemicycle-section") as HTMLSelectElement).value = entry.section_id || "";
      updateHemicyclePreview();
      ($("dossier-hemicycle-save") as HTMLButtonElement).textContent = "Enregistrer";
      $("dossier-hemicycle-form").classList.add("open");
    } else if (entry.type === "genealogy") {
      editingEntryId = null;
      const title = await customPrompt("Titre de l'arbre :", entry.title || "");
      if (title === null) return;
      await updateEntry(entry.id, { title: title.trim() || null });
      renderDossierEntries();
    }
  }

  async function saveTextForm() {
    const title = ($("dossier-text-title") as HTMLInputElement).value.trim();
    const bodyRaw = editor.innerHTML;
    const body = sanitizeDossierHTML(bodyRaw);
    const bodyText = (editor.textContent || "").trim();
    const category = ($("dossier-text-category") as HTMLSelectElement).value || null;
    const sectionId = ($("dossier-text-section") as HTMLSelectElement).value || null;
    const sources = editingSourcesDraft
      .filter((s) => s.label && s.label.trim())
      .map((s) => ({ label: s.label.trim(), url: (s.url || "").trim() }));
    const tags = editingTagsDraft.slice();
    const status: "draft" | "published" = ($("dossier-text-draft") as HTMLInputElement).checked ? "draft" : "published";
    const hasStructuralContent = /<(table|hr|ul class="rt-checklist"|ol|pre)/i.test(body);
    if (!bodyText && !hasStructuralContent) return;
    if (editingEntryId) {
      await updateEntry(editingEntryId, { title, body, category_id: category, section_id: sectionId, sources, tags, status });
    } else {
      await addEntry({ type: "text", title, body, category_id: category, section_id: sectionId, sources, tags, status });
    }
    renderDossierEntries();
  }
  $("dossier-add-text-btn").addEventListener("click", () => {
    closeDossierForms();
    ($("dossier-text-title") as HTMLInputElement).value = "";
    editor.innerHTML = "";
    rtResetHistory();
    updateWordCountLive();
    ($("dossier-text-category") as HTMLSelectElement).value = ($("dossier-entry-category") as HTMLSelectElement).value;
    populateSectionSelects();
    ($("dossier-text-section") as HTMLSelectElement).value = ($("dossier-entry-section") as HTMLSelectElement).value;
    editingSourcesDraft = [];
    renderSourcesEditor();
    editingTagsDraft = [];
    renderTagsEditor();
    $("dossier-text-form").classList.add("open");
    $("dossier-inner").classList.add("dossier-inner-text-editing");
  });
  $("dossier-text-cancel").addEventListener("click", closeDossierForms);
  $("dossier-text-save").addEventListener("click", async () => {
    await saveTextForm();
    ($("dossier-text-title") as HTMLInputElement).value = "";
    editor.innerHTML = "";
    closeDossierForms();
  });
  let textAutosaveTimer: number | null = null;
  function scheduleTextAutosave() {
    if (!editingEntryId) return;
    if (textAutosaveTimer) window.clearTimeout(textAutosaveTimer);
    textAutosaveTimer = window.setTimeout(() => {
      saveTextForm();
    }, 400);
  }
  function flushTextAutosave() {
    if (!editingEntryId) return;
    if (textAutosaveTimer) window.clearTimeout(textAutosaveTimer);
    saveTextForm();
  }
  window.addEventListener("beforeunload", flushTextAutosave);

  $("dossier-add-link-btn").addEventListener("click", () => {
    closeDossierForms();
    ($("dossier-link-label") as HTMLInputElement).value = "";
    ($("dossier-link-url") as HTMLInputElement).value = "";
    ($("dossier-link-category") as HTMLSelectElement).value = ($("dossier-entry-category") as HTMLSelectElement).value;
    populateSectionSelects();
    ($("dossier-link-section") as HTMLSelectElement).value = ($("dossier-entry-section") as HTMLSelectElement).value;
    $("dossier-link-form").classList.add("open");
  });
  $("dossier-link-cancel").addEventListener("click", closeDossierForms);
  $("dossier-link-save").addEventListener("click", async () => {
    const label = ($("dossier-link-label") as HTMLInputElement).value.trim();
    let url = ($("dossier-link-url") as HTMLInputElement).value.trim();
    const category = ($("dossier-link-category") as HTMLSelectElement).value || null;
    const sectionId = ($("dossier-link-section") as HTMLSelectElement).value || null;
    if (!url) return;
    if (!/^https?:\/\//i.test(url)) url = "https://" + url;
    if (editingEntryId) {
      await updateEntry(editingEntryId, { label, link_url: url, category_id: category, section_id: sectionId });
    } else {
      await addEntry({ type: "link", label, link_url: url, category_id: category, section_id: sectionId });
    }
    ($("dossier-link-label") as HTMLInputElement).value = "";
    ($("dossier-link-url") as HTMLInputElement).value = "";
    closeDossierForms();
    renderDossierEntries();
  });
  // -------------------------------------------------------------------------
  // Formulaire hémicycle — porté de renderHemicyclePartiesEditor()/
  // updateHemicyclePreview() dans l'artifact source (~7476-7599).
  // -------------------------------------------------------------------------
  function renderHemicyclePartiesEditor() {
    const holder = $("dossier-hemicycle-parties");
    holder.innerHTML = "";
    editingHemicycleParties.forEach((p, idx) => {
      const row = document.createElement("div");
      row.className = "hemicycle-party-row";
      const nameInp = document.createElement("input");
      nameInp.type = "text";
      nameInp.className = "hp-name";
      nameInp.style.flex = "1";
      nameInp.placeholder = "Nom du parti / groupe";
      nameInp.value = p.name || "";
      nameInp.addEventListener("input", () => {
        editingHemicycleParties[idx].name = nameInp.value;
        updateHemicyclePreview();
      });
      const colorInp = document.createElement("input");
      colorInp.type = "color";
      colorInp.className = "hp-color";
      colorInp.value = p.color || "#999999";
      colorInp.addEventListener("input", () => {
        editingHemicycleParties[idx].color = colorInp.value;
        updateHemicyclePreview();
      });
      const seatsInp = document.createElement("input");
      seatsInp.type = "text";
      seatsInp.inputMode = "numeric";
      seatsInp.className = "hp-seats";
      seatsInp.style.flex = "none";
      seatsInp.style.width = "78px";
      seatsInp.placeholder = "Sièges";
      seatsInp.value = p.seats ? String(p.seats) : "";
      seatsInp.addEventListener("input", () => {
        const digits = seatsInp.value.replace(/[^0-9]/g, "");
        if (seatsInp.value !== digits) seatsInp.value = digits;
        editingHemicycleParties[idx].seats = digits ? parseInt(digits, 10) : 0;
        updateHemicyclePreview();
      });
      const moveLeft = document.createElement("button");
      moveLeft.type = "button";
      moveLeft.className = "hp-move hp-move-left";
      moveLeft.innerHTML = "&#9664;";
      moveLeft.title = "Déplacer vers la gauche de l’hémicycle";
      moveLeft.disabled = idx === 0;
      moveLeft.addEventListener("click", () => {
        if (idx === 0) return;
        const tmp = editingHemicycleParties[idx - 1];
        editingHemicycleParties[idx - 1] = editingHemicycleParties[idx];
        editingHemicycleParties[idx] = tmp;
        renderHemicyclePartiesEditor();
        updateHemicyclePreview();
      });
      const moveRight = document.createElement("button");
      moveRight.type = "button";
      moveRight.className = "hp-move hp-move-right";
      moveRight.innerHTML = "&#9654;";
      moveRight.title = "Déplacer vers la droite de l’hémicycle";
      moveRight.disabled = idx === editingHemicycleParties.length - 1;
      moveRight.addEventListener("click", () => {
        if (idx === editingHemicycleParties.length - 1) return;
        const tmp = editingHemicycleParties[idx + 1];
        editingHemicycleParties[idx + 1] = editingHemicycleParties[idx];
        editingHemicycleParties[idx] = tmp;
        renderHemicyclePartiesEditor();
        updateHemicyclePreview();
      });
      const rm = document.createElement("button");
      rm.type = "button";
      rm.className = "hp-remove entry-del";
      rm.style.cssText = "position:static;opacity:1;";
      rm.innerHTML = TRASH_ICON_SVG;
      rm.title = "Retirer ce parti";
      rm.addEventListener("click", () => {
        editingHemicycleParties.splice(idx, 1);
        renderHemicyclePartiesEditor();
        updateHemicyclePreview();
      });
      row.appendChild(moveLeft);
      row.appendChild(moveRight);
      row.appendChild(nameInp);
      row.appendChild(colorInp);
      row.appendChild(seatsInp);
      row.appendChild(rm);
      holder.appendChild(row);
    });
  }
  $("dossier-hemicycle-add-party").addEventListener("click", () => {
    editingHemicycleParties.push(defaultHemicyclePartyRow(editingHemicycleParties.length));
    renderHemicyclePartiesEditor();
    updateHemicyclePreview();
  });
  function updateHemicyclePreview() {
    const holder = $("dossier-hemicycle-preview");
    holder.innerHTML = "";
    const totalRaw = ($("dossier-hemicycle-total") as HTMLInputElement).value.trim();
    holder.appendChild(buildHemicycleWidget(editingHemicycleParties, totalRaw ? parseInt(totalRaw, 10) || 0 : null, { compact: false }));
  }
  $("dossier-hemicycle-total").addEventListener("input", updateHemicyclePreview);
  $("dossier-add-hemicycle-btn").addEventListener("click", () => {
    closeDossierForms();
    ($("dossier-hemicycle-title") as HTMLInputElement).value = "";
    editingHemicycleParties = [defaultHemicyclePartyRow(0), defaultHemicyclePartyRow(1)];
    renderHemicyclePartiesEditor();
    ($("dossier-hemicycle-total") as HTMLInputElement).value = "";
    ($("dossier-hemicycle-source") as HTMLInputElement).value = "";
    ($("dossier-hemicycle-category") as HTMLSelectElement).value = ($("dossier-entry-category") as HTMLSelectElement).value;
    populateSectionSelects();
    ($("dossier-hemicycle-section") as HTMLSelectElement).value = ($("dossier-entry-section") as HTMLSelectElement).value;
    updateHemicyclePreview();
    $("dossier-hemicycle-form").classList.add("open");
  });
  $("dossier-hemicycle-cancel").addEventListener("click", closeDossierForms);
  $("dossier-hemicycle-save").addEventListener("click", async () => {
    const title = ($("dossier-hemicycle-title") as HTMLInputElement).value.trim();
    const parties = editingHemicycleParties
      .map((p) => ({ name: (p.name || "").trim(), color: p.color || "#999999", seats: Math.max(0, p.seats || 0) }))
      .filter((p) => p.name && p.seats > 0);
    if (!parties.length) return;
    const totalRaw = ($("dossier-hemicycle-total") as HTMLInputElement).value.trim();
    const totalSeats = totalRaw ? Math.max(0, parseInt(totalRaw, 10) || 0) : null;
    const source = ($("dossier-hemicycle-source") as HTMLInputElement).value.trim();
    const category = ($("dossier-hemicycle-category") as HTMLSelectElement).value || null;
    const sectionId = ($("dossier-hemicycle-section") as HTMLSelectElement).value || null;
    const hemicycle: HemicycleData = { title, parties, totalSeats, source };
    if (editingEntryId) {
      await updateEntry(editingEntryId, { title, hemicycle, category_id: category, section_id: sectionId });
    } else {
      await addEntry({ type: "hemicycle", title, hemicycle, category_id: category, section_id: sectionId });
    }
    closeDossierForms();
    renderDossierEntries();
  });

  // -------------------------------------------------------------------------
  // Formulaire "+ Généalogie" — crée une ENTRÉE de type "genealogy" (point 2,
  // 2026-10-03), ouverte ensuite via deps.onOpenGenealogyEntry (son propre
  // arbre indépendant, owner={type:"entry", id: entry.id}).
  // -------------------------------------------------------------------------
  $("dossier-add-genealogy-btn").addEventListener("click", () => {
    closeDossierForms();
    ($("dossier-genealogy-entry-title") as HTMLInputElement).value = "";
    ($("dossier-genealogy-entry-category") as HTMLSelectElement).value = ($("dossier-entry-category") as HTMLSelectElement).value;
    populateSectionSelects();
    ($("dossier-genealogy-entry-section") as HTMLSelectElement).value = ($("dossier-entry-section") as HTMLSelectElement).value;
    $("dossier-genealogy-entry-form").classList.add("open");
  });
  $("dossier-genealogy-entry-cancel").addEventListener("click", closeDossierForms);
  $("dossier-genealogy-entry-save").addEventListener("click", async () => {
    const title = ($("dossier-genealogy-entry-title") as HTMLInputElement).value.trim() || null;
    const category = ($("dossier-genealogy-entry-category") as HTMLSelectElement).value || null;
    const sectionId = ($("dossier-genealogy-entry-section") as HTMLSelectElement).value || null;
    const id = await addEntry({ type: "genealogy", title, category_id: category, section_id: sectionId });
    closeDossierForms();
    renderDossierEntries();
    if (id) deps.onOpenGenealogyEntry?.({ id, title });
  });

  $("dossier-reading-toggle").addEventListener("click", () => {
    const view = $("dossier-theme-view");
    const active = view.classList.toggle("reading-mode");
    ($("dossier-reading-toggle") as HTMLButtonElement).textContent = active ? "Quitter le mode lecture" : "Mode lecture";
  });

  // -------------------------------------------------------------------------
  // Ajout / remplacement de photo (Supabase Storage)
  // -------------------------------------------------------------------------
  let replacingPhotoId: string | null = null;
  async function uploadPhoto(file: File): Promise<string | null> {
    if (!currentOwner || !isAdmin()) return null;
    const session = deps.getSession();
    if (!session) return null;
    const path = currentOwner.type + "-" + currentOwner.id + "/" + Date.now() + "-" + Math.random().toString(36).slice(2, 8) + "-" + file.name.replace(/[^a-zA-Z0-9._-]/g, "_");
    const { error } = await supabase.storage.from("dossier-photos").upload(path, file, { upsert: false });
    if (error) return null;
    const { data } = supabase.storage.from("dossier-photos").getPublicUrl(path);
    return data.publicUrl;
  }
  $("dossier-add-photo-btn").addEventListener("click", () => {
    if (!deps.getSession()) {
      $("dossier-photo-status").textContent = "Connectez-vous pour ajouter une photo.";
      return;
    }
    if (!isAdmin()) {
      $("dossier-photo-status").textContent = "Tu n'as pas les droits d'édition sur cet atlas.";
      return;
    }
    ($("dossier-photo-input") as HTMLInputElement).click();
  });
  function startReplacePhoto(id: string) {
    if (!isAdmin()) return;
    replacingPhotoId = id;
    ($("dossier-photo-input") as HTMLInputElement).click();
  }
  ($("dossier-photo-input") as HTMLInputElement).addEventListener("change", async (e) => {
    const files = Array.from((e.target as HTMLInputElement).files || []);
    (e.target as HTMLInputElement).value = "";
    const replacingId = replacingPhotoId;
    replacingPhotoId = null;
    if (!files.length || !currentOwner) return;
    const status = $("dossier-photo-status");
    status.textContent = replacingId ? "Envoi de la nouvelle photo…" : "Envoi de la photo…";
    try {
      const url = await uploadPhoto(files[0]);
      if (!url) throw new Error("upload failed");
      if (replacingId) {
        await updateEntry(replacingId, { photo_url: url });
      } else {
        const title = ((await customPrompt("Titre de l'image (optionnel) :")) || "").trim();
        const caption = ((await customPrompt("Légende (optionnel) :")) || "").trim();
        const category = ($("dossier-entry-category") as HTMLSelectElement).value || null;
        const sectionId = ($("dossier-entry-section") as HTMLSelectElement).value || null;
        await addEntry({ type: "photo", photo_url: url, title, caption, category_id: category, section_id: sectionId });
      }
      status.textContent = "";
      renderDossierEntries();
    } catch {
      status.textContent = "Échec de l'envoi de la photo — réessayez (fichier trop volumineux ?).";
    }
  });

  // -------------------------------------------------------------------------
  // Image de bannière des catégories/sections (schema_v10.sql) — même motif
  // d'upload que uploadPhoto() ci-dessus, mais vers deux chemins de
  // stockage distincts puisque les catégories sont globales/partagées par
  // "space" (pas de currentOwner à y mêler) alors que les sections
  // appartiennent toujours à un dossier précis.
  // -------------------------------------------------------------------------
  let pendingCategoryImageId: string | null = null;
  let pendingSectionImageId: string | null = null;
  async function uploadCategoryImage(categoryId: string, file: File): Promise<string | null> {
    if (!isAdmin()) return null;
    const path =
      "category-" + categoryId + "/" + Date.now() + "-" + Math.random().toString(36).slice(2, 8) + "-" + file.name.replace(/[^a-zA-Z0-9._-]/g, "_");
    const { error } = await supabase.storage.from("dossier-photos").upload(path, file, { upsert: false });
    if (error) return null;
    const { data } = supabase.storage.from("dossier-photos").getPublicUrl(path);
    return data.publicUrl;
  }
  async function uploadSectionImage(sec: Section, file: File): Promise<string | null> {
    if (!isAdmin() || !currentOwner) return null;
    const path =
      currentOwner.type +
      "-" +
      currentOwner.id +
      "/section-" +
      sec.id +
      "/" +
      Date.now() +
      "-" +
      Math.random().toString(36).slice(2, 8) +
      "-" +
      file.name.replace(/[^a-zA-Z0-9._-]/g, "_");
    const { error } = await supabase.storage.from("dossier-photos").upload(path, file, { upsert: false });
    if (error) return null;
    const { data } = supabase.storage.from("dossier-photos").getPublicUrl(path);
    return data.publicUrl;
  }
  function startCategoryImageUpload(id: string) {
    if (!isAdmin()) return;
    pendingCategoryImageId = id;
    ($("dossier-category-image-input") as HTMLInputElement).click();
  }
  function startSectionImageUpload(id: string) {
    if (!isAdmin()) return;
    pendingSectionImageId = id;
    ($("dossier-section-image-input") as HTMLInputElement).click();
  }
  ($("dossier-category-image-input") as HTMLInputElement).addEventListener("change", async (e) => {
    const files = Array.from((e.target as HTMLInputElement).files || []);
    (e.target as HTMLInputElement).value = "";
    const id = pendingCategoryImageId;
    pendingCategoryImageId = null;
    if (!files.length || !id) return;
    const url = await uploadCategoryImage(id, files[0]);
    if (!url) return;
    const cat = categoryDocs.get(id);
    if (cat) {
      cat.image_url = url;
      categoryDocs.set(id, cat);
    }
    try {
      await supabase.from("dossier_categories").update({ image_url: url }).eq("id", id);
    } catch {
      /* ignore */
    }
    renderDossierSummary();
  });
  ($("dossier-section-image-input") as HTMLInputElement).addEventListener("change", async (e) => {
    const files = Array.from((e.target as HTMLInputElement).files || []);
    (e.target as HTMLInputElement).value = "";
    const id = pendingSectionImageId;
    pendingSectionImageId = null;
    const sec = id ? currentSections.find((s) => s.id === id) : undefined;
    if (!files.length || !sec) return;
    const url = await uploadSectionImage(sec, files[0]);
    if (!url) return;
    sec.cover_image_url = url;
    try {
      await supabase.from("dossier_sections").update({ cover_image_url: url }).eq("id", sec.id);
    } catch {
      /* ignore */
    }
    renderDossierEntries();
  });
  async function saveCategoryImagePosition(id: string, pos: string) {
    const cat = categoryDocs.get(id);
    if (cat) {
      cat.image_position = pos;
      categoryDocs.set(id, cat);
    }
    try {
      await supabase.from("dossier_categories").update({ image_position: pos }).eq("id", id);
    } catch {
      /* ignore */
    }
  }
  async function saveSectionImagePosition(sec: Section, pos: string) {
    sec.image_position = pos;
    try {
      await supabase.from("dossier_sections").update({ image_position: pos }).eq("id", sec.id);
    } catch {
      /* ignore */
    }
  }

  // -------------------------------------------------------------------------
  // Dossier (page plein écran) — généralisé à tout DossierOwnerRef (pays,
  // groupe ou Encyclopédie) : openDossier(country) reste l'API historique
  // pour les pays (fiche + bouton "Ouvrir le dossier complet"),
  // openDossierForOwner() est la fonction interne commune, et
  // openGroupDossier()/openEncyclopedieDossier() (exportées plus bas) sont
  // les nouveaux points d'entrée pour les groupes et l'Encyclopédie.
  // -------------------------------------------------------------------------
  async function openDossierForOwner(owner: DossierOwnerRef) {
    currentOwner = owner;
    currentEntries = [];
    currentSections = [];
    activeCategory = "__all__";
    const flagEl = $("dossier-title-flag");
    flagEl.textContent = "";
    if (owner.type === "country") {
      const flagNode = flagSvgSpan(owner.flagSlug || "", owner.iso2);
      if (flagNode) flagEl.appendChild(flagNode);
    } else if (owner.colorDot) {
      const dot = document.createElement("span");
      dot.className = "group-dot";
      dot.style.cssText = "display:inline-block;width:13px;height:13px;border-radius:50%;margin-right:8px;vertical-align:-1px;";
      dot.style.background = owner.colorDot;
      flagEl.appendChild(dot);
    }
    $("dossier-title-text").textContent = owner.label;
    $("dossier-subtitle").textContent = "Dossier complet";
    $("dossier-entries").innerHTML = '<p class="muted">Chargement…</p>';
    $("dossier-photo-status").textContent = "";
    closeDossierForms();
    closeEntryReadView();
    $("dossier-theme-view").classList.remove("reading-mode");
    ($("dossier-reading-toggle") as HTMLButtonElement).textContent = "Mode lecture";
    $("dossier-view").classList.add("open");
    await loadCategories(owner.categorySpace);
    if (currentOwner !== owner) return;
    await loadSections(owner.type, owner.id);
    if (currentOwner !== owner) return;
    populateCategorySelects();
    await loadEntries(owner.type, owner.id);
    if (currentOwner !== owner) return;
    showDossierSummary();
  }
  async function openDossier(country: CountryRef) {
    await openDossierForOwner({
      type: "country",
      id: country.isoA3,
      label: frenchCountryName(country.name),
      categorySpace: "country",
      flagSlug: country.slug,
      iso2: country.iso2,
    });
  }
  async function openGroupDossier(id: string, name: string, color?: string) {
    await openDossierForOwner({ type: "group", id, label: name, categorySpace: "country", colorDot: color });
  }
  async function openEncyclopedieDossier() {
    await openDossierForOwner({ type: "encyclopedie", id: "encyclopedie", label: "Encyclopédie", categorySpace: "encyclopedie" });
  }
  // Mini-dossier (port/détroit/pipeline/base/câble) — porté de
  // miniDossierId(kind,id) : mêmes catégories que les dossiers pays
  // (categorySpace 'country'), owner_id = slug de l'entité.
  async function openMiniDossier(kind: MiniDossierKind, id: string, label: string) {
    await openDossierForOwner({ type: kind, id, label, categorySpace: "country" });
  }
  function closeDossier() {
    $("dossier-view").classList.remove("open");
  }
  $("dossier-back").addEventListener("click", closeDossier);

  // -------------------------------------------------------------------------
  // Navigation directe depuis la recherche unifiée (src/search.ts) — porté de
  // selectSearchEntry()/renderDossierSearchResults() (ouvre le dossier puis
  // défile jusqu'à l'entrée/la sous-section visée et la met en évidence
  // brièvement). Suppose que le bon dossier vient d'être ouvert (via
  // openDossier/openGroupDossier/openMiniDossier/openEncyclopedieDossier)
  // juste avant l'appel.
  // -------------------------------------------------------------------------
  function revealEntry(entryId: string, categoryId: string | null) {
    showThemeView(categoryId || "__all__");
    setTimeout(() => {
      const el = document.querySelector('.dossier-entry[data-entry-id="' + entryId + '"]');
      if (el) {
        el.scrollIntoView({ behavior: "smooth", block: "center" });
        el.classList.add("search-flash");
        setTimeout(() => el.classList.remove("search-flash"), 1800);
      }
    }, 90);
  }
  function revealSection(sectionId: string, categoryId: string | null) {
    showThemeView(categoryId || "__all__");
    setTimeout(() => {
      const el = document.querySelector('.dossier-section-group[data-section-id="' + sectionId + '"]');
      if (el) el.scrollIntoView({ behavior: "smooth", block: "start" });
    }, 90);
  }

  // -------------------------------------------------------------------------
  // Fiche (panneau latéral)
  // -------------------------------------------------------------------------
  let currentFicheCountry: CountryRef | null = null;
  let ficheSaveTimer: number | null = null;
  const fichePanel = $("fiche-panel");

  // -------------------------------------------------------------------------
  // Dirigeants multiples (point 8, 2026-10-03) — public.country_leaders
  // (schema_v12.sql), remplace le champ texte unique countries.leader.
  // -------------------------------------------------------------------------
  type Leader = { id: string | null; status: string; name: string; position: number };
  let currentLeaders: Leader[] = [];
  async function loadLeaders(isoA3: string): Promise<Leader[]> {
    const { data } = await supabase
      .from("country_leaders")
      .select("id, status, name, position")
      .eq("country_id", isoA3)
      .order("position", { ascending: true });
    return (data || []).map((row) => ({ id: row.id, status: row.status, name: row.name, position: row.position }));
  }
  function renderLeadersList() {
    const wrap = $("fiche-leaders-list");
    wrap.innerHTML = "";
    if (!isAdmin()) {
      // Point 4a/4b (2026-10-03) : lecture seule pour un visiteur non-admin
      // (connecté ou pas) — pas de champs éditables ni de bouton de
      // suppression, juste le statut/nom en texte.
      currentLeaders.forEach((leader) => {
        const row = document.createElement("div");
        row.className = "fiche-leader-row fiche-leader-readonly";
        row.textContent = [leader.status, leader.name].filter(Boolean).join(" — ") || "—";
        wrap.appendChild(row);
      });
      return;
    }
    currentLeaders.forEach((leader, idx) => {
      const row = document.createElement("div");
      row.className = "fiche-leader-row";
      const statusInp = document.createElement("input");
      statusInp.type = "text";
      statusInp.placeholder = "Statut (ex. Président)";
      statusInp.value = leader.status;
      const nameInp = document.createElement("input");
      nameInp.type = "text";
      nameInp.placeholder = "Nom";
      nameInp.value = leader.name;
      const rm = document.createElement("button");
      rm.type = "button";
      rm.className = "entry-del";
      rm.style.cssText = "position:static;opacity:1;";
      rm.innerHTML = TRASH_ICON_SVG;
      rm.title = "Supprimer ce dirigeant";
      async function persist() {
        leader.status = statusInp.value.trim();
        leader.name = nameInp.value.trim();
        if (!leader.status || !leader.name) return;
        const session = deps.getSession();
        if (!session || !currentFicheCountry) return;
        try {
          if (leader.id) {
            await supabase.from("country_leaders").update({ status: leader.status, name: leader.name }).eq("id", leader.id);
          } else {
            const { data } = await supabase
              .from("country_leaders")
              .insert({
                country_id: currentFicheCountry.isoA3,
                status: leader.status,
                name: leader.name,
                position: idx,
                created_by: session.user.id,
              })
              .select("id")
              .single();
            if (data) leader.id = data.id;
          }
        } catch {
          /* best-effort */
        }
      }
      statusInp.addEventListener("blur", persist);
      nameInp.addEventListener("blur", persist);
      rm.addEventListener("click", async () => {
        currentLeaders.splice(idx, 1);
        renderLeadersList();
        if (leader.id) {
          try {
            await supabase.from("country_leaders").delete().eq("id", leader.id);
          } catch {
            /* ignore */
          }
        }
      });
      row.appendChild(statusInp);
      row.appendChild(nameInp);
      row.appendChild(rm);
      wrap.appendChild(row);
    });
  }
  $("fiche-leaders-add").addEventListener("click", () => {
    if (!deps.getSession()) {
      $("fiche-save-status").textContent = "Connectez-vous pour ajouter un dirigeant.";
      return;
    }
    if (!isAdmin()) {
      $("fiche-save-status").textContent = "Tu n'as pas les droits d'édition sur cet atlas.";
      return;
    }
    currentLeaders.push({ id: null, status: "", name: "", position: currentLeaders.length });
    renderLeadersList();
    const inputs = $("fiche-leaders-list").querySelectorAll("input");
    (inputs[inputs.length - 2] as HTMLInputElement)?.focus();
  });

  function fallbackKeyInfo(): string {
    return "";
  }

  async function loadCountryRow(isoA3: string): Promise<{ key_info: string | null; notes: string | null } | null> {
    const { data } = await supabase.from("countries").select("key_info, notes").eq("id", isoA3).maybeSingle();
    return data || null;
  }

  async function openFiche(country: CountryRef) {
    flushFicheSave();
    currentFicheCountry = country;
    fichePanel.classList.add("open");
    const titleEl = $("fiche-title");
    titleEl.textContent = "";
    const flagNode = flagSvgSpan(country.slug, country.iso2);
    if (flagNode) {
      titleEl.appendChild(flagNode);
      titleEl.appendChild(document.createTextNode(" "));
    }
    titleEl.appendChild(document.createTextNode(frenchCountryName(country.name)));
    $("fiche-subtitle").textContent = country.continent || "";
    $("fiche-save-status").textContent = "";
    ($("fiche-keyinfo") as HTMLTextAreaElement).value = "";
    ($("fiche-notes") as HTMLTextAreaElement).value = "";
    currentLeaders = [];
    renderLeadersList();
    const [row, leaders] = await Promise.all([loadCountryRow(country.isoA3), loadLeaders(country.isoA3)]);
    if (currentFicheCountry !== country) return;
    ($("fiche-keyinfo") as HTMLTextAreaElement).value = row?.key_info ?? fallbackKeyInfo();
    ($("fiche-notes") as HTMLTextAreaElement).value = row?.notes ?? "";
    currentLeaders = leaders;
    renderLeadersList();
    deps.renderFicheIndicator?.($("fiche-extra-indicator"), country);
    deps.renderFicheGroups?.($("fiche-extra-groups"), country);
    deps.renderFicheLinks?.($("fiche-extra-links"), country);
    deps.renderFichePoi?.($("fiche-extra-poi"), country);
    ($("fiche-keyinfo") as HTMLTextAreaElement).readOnly = !isAdmin();
    ($("fiche-notes") as HTMLTextAreaElement).readOnly = !isAdmin();
  }
  function closeFiche() {
    flushFicheSave();
    fichePanel.classList.remove("open");
    currentFicheCountry = null;
    deps.onFicheClose?.();
  }
  async function saveFiche() {
    if (!currentFicheCountry) return;
    const session = deps.getSession();
    const status = $("fiche-save-status");
    const country = currentFicheCountry;
    const keyInfo = ($("fiche-keyinfo") as HTMLTextAreaElement).value.trim();
    const notes = ($("fiche-notes") as HTMLTextAreaElement).value.trim();
    if (!session) {
      status.textContent = "Connectez-vous pour enregistrer.";
      return;
    }
    if (!isAdmin()) {
      status.textContent = "Tu n'as pas les droits d'édition sur cet atlas.";
      return;
    }
    status.textContent = "Enregistrement…";
    try {
      await supabase.from("countries").upsert({
        id: country.isoA3,
        name_fr: frenchCountryName(country.name),
        continent: country.continent,
        key_info: keyInfo,
        notes,
        updated_at: new Date().toISOString(),
      });
      status.textContent = "Enregistré ✓";
      setTimeout(() => {
        if (status.textContent === "Enregistré ✓") status.textContent = "";
      }, 2500);
    } catch {
      status.textContent = "Erreur d'enregistrement.";
    }
  }
  function scheduleFicheSave() {
    if (ficheSaveTimer) window.clearTimeout(ficheSaveTimer);
    ficheSaveTimer = window.setTimeout(() => {
      ficheSaveTimer = null;
      saveFiche();
    }, 400);
  }
  function flushFicheSave() {
    if (ficheSaveTimer) {
      window.clearTimeout(ficheSaveTimer);
      ficheSaveTimer = null;
      saveFiche();
    }
  }
  ["fiche-keyinfo", "fiche-notes"].forEach((id) => $(id).addEventListener("input", scheduleFicheSave));
  $("fiche-close").addEventListener("click", closeFiche);
  $("fiche-open-dossier").addEventListener("click", () => {
    if (!currentFicheCountry) return;
    openDossier(currentFicheCountry);
  });

  // Point 4b (2026-10-03) : rafraîchit ce qui est déjà affiché à l'écran
  // (fiche/dossier déjà ouverts) quand le mode lecture global bascule, sans
  // attendre une prochaine ouverture — voir onReadOnlyModeChanged dans
  // main.ts. No-op si rien n'est ouvert.
  function refreshForReadOnlyChange() {
    if (currentFicheCountry) renderLeadersList();
    if (currentOwner) {
      renderDossierSummary();
      renderDossierEntries();
    }
  }

  return {
    openFiche,
    closeFiche,
    openDossier,
    openGroupDossier,
    openEncyclopedieDossier,
    openMiniDossier,
    revealEntry,
    revealSection,
    refreshForReadOnlyChange,
  };
}
