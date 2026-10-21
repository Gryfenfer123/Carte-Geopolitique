// ---------------------------------------------------------------------------
// Frises chronologiques — NOUVEAU MODÈLE (schema_v27.sql, 2026-10-21).
// Spécification : document de projet « frises-chronologiques-specification ».
//
// - Une frise est une ENTRÉE de dossier de type "frise", placée n'importe où
//   (pays, groupe, catégorie, sous-catégorie à toute profondeur).
// - Une PÉRIODE EST une sous-catégorie (dossier_sections) qui porte une date
//   de début : renommer / déplacer la période = renommer / déplacer la
//   sous-catégorie, rien à synchroniser. Les périodes d'une frise sont les
//   sous-catégories dont period_frise_id = id de la frise ; elles sont
//   rangées sous la section où la frise est posée.
// - Bornes partagées : seule la date de début est stockée, la fin d'une
//   période est le début de la suivante. Une fin explicite crée un trou de
//   transition grisé (texte libre). Voir friseModel.ts.
// - Une SOUS-FRISE est une frise posée dans la sous-catégorie d'une période.
//   Profondeur illimitée.
// - Les événements (étape 3) et leur lien avec les fiches (étape 4) viennent
//   ensuite : l'écran réserve la place au-dessus et au-dessous de la bande.
//
// Écriture réservée aux administrateurs (même régime que le reste de
// l'appli, voir dossier.ts::isAdmin et schema_v13/v28).
// ---------------------------------------------------------------------------

import type { SupabaseClient, Session } from "@supabase/supabase-js";
import { customConfirm } from "./dossier";
import {
  computeLinearWidths,
  dateSortKey,
  dateToDecimal,
  formatFriseDate,
  layoutPeriods,
  locateSegment,
  niceTicks,
  parseDateFields,
  xForDecimal,
  type FriseDate,
  type Period,
  type Segment,
} from "./friseModel";

// --- Types -------------------------------------------------------------------

type FriseEntry = {
  id: string;
  title: string | null;
  owner_type: string;
  owner_id: string;
  category_id: string | null;
  section_id: string | null;
};

type SectionRow = {
  id: string;
  title: string;
  category_id: string;
  parent_section_id: string | null;
  position: number | null;
  period_frise_id: string | null;
  period_start_year: number | null;
  period_start_month: number | null;
  period_start_day: number | null;
  period_start_circa: boolean | null;
  period_end_year: number | null;
  period_end_month: number | null;
  period_end_day: number | null;
  period_end_circa: boolean | null;
  period_color: string | null;
  period_is_transition: boolean | null;
  transition_after_id: string | null;
};

type Ancestor = { id: string; title: string };
type FriseContext = { periodName: string; from: string; to: string };
type Point = {
  eventId: string;
  title: string;
  date: FriseDate;
  side: "up" | "down";
  color: string;
  stem: number | null; // hauteur de la tige en px, réglée à la main (null = automatique)
  entryId: string | null;
  stemEl?: HTMLElement; // élément de tige affiché (rendu courant)
};

const SECTION_COLUMNS =
  "id, title, category_id, parent_section_id, position, period_frise_id, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa, period_color, period_is_transition, transition_after_id";

const PALETTE = ["#c0392b", "#e67e22", "#d4ac0d", "#27ae60", "#16a085", "#2980b9", "#8e44ad", "#7f8c8d"];
const DEFAULT_POINT_COLOR = "#2980b9";

function esc(s: string): string {
  return s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c] as string);
}

function rowToPeriod(r: SectionRow): Period {
  const start: FriseDate = {
    year: r.period_start_year ?? 0,
    month: r.period_start_month,
    day: r.period_start_day,
    circa: !!r.period_start_circa,
  };
  const end: FriseDate | null =
    r.period_end_year != null
      ? { year: r.period_end_year, month: r.period_end_month, day: r.period_end_day, circa: !!r.period_end_circa }
      : null;
  return { id: r.id, name: r.title, start, end, color: r.period_color };
}

function dateColumns(prefix: "period_start" | "period_end", d: FriseDate | null): Record<string, unknown> {
  return {
    [prefix + "_year"]: d ? d.year : null,
    [prefix + "_month"]: d ? d.month : null,
    [prefix + "_day"]: d ? d.day : null,
    [prefix + "_circa"]: d ? d.circa : false,
  };
}

let measureCtx: CanvasRenderingContext2D | null = null;
function textWidth(text: string): number {
  try {
    if (!measureCtx) {
      measureCtx = document.createElement("canvas").getContext("2d");
      if (measureCtx) measureCtx.font = '600 13px "IBM Plex Sans", sans-serif';
    }
    if (measureCtx) return measureCtx.measureText(text).width;
  } catch {
    /* repli ci-dessous */
  }
  return text.length * 7.2;
}

export function initTimelineSystem(deps: {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  getProfile: () => { id: string; role: string } | null;
  openAuthPanel: () => void;
  showBanner?: (msg: string) => void;
  // Ouvre la page de la sous-catégorie (dossier.ts::revealSection).
  revealSection: (sectionId: string, categoryId: string | null) => void;
  // Ouvre une fiche dans le dossier (dossier.ts::revealEntry).
  revealEntry: (entryId: string, categoryId: string | null) => void;
  // Recharge sous-catégories et entrées du dossier affiché (dossier.ts).
  refreshDossier: () => Promise<void>;
}) {
  const { supabase } = deps;

  function isAdmin(): boolean {
    return deps.getProfile()?.role === "admin" && !document.body.classList.contains("read-only-mode");
  }
  function requireAdminOr(action: () => void) {
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
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

  // --- État --------------------------------------------------------------------
  let frise: FriseEntry | null = null;
  let periodRows: SectionRow[] = [];
  let transitionRows: SectionRow[] = [];
  let periods: Period[] = [];
  let points: Point[] = [];
  let subFrises = new Map<string, { id: string; title: string | null }>();
  let ancestors: Ancestor[] = [];
  let context: FriseContext | null = null;
  let loadToken = 0;
  let suppressPointClick = false;
  let history: string[] = []; // frises visitées avant la frise courante (retour sans repasser par le dossier)
  let zoom = 1;
  // Dialogue période / transition
  let editingPeriodId: string | null = null;
  let dialogGapAfter: string | null = null; // non nul = on édite la transition après cette période
  let periodColor: string | null = null;
  // Dialogue point
  let editingPoint: Point | null = null;
  let pointColor = DEFAULT_POINT_COLOR;
  let pointSide: "up" | "down" = "up";

  // --- DOM (construit une fois) --------------------------------------------------
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="timeline-view">
      <div id="timeline-topbar">
        <button id="timeline-prev" class="btn-small" style="display:none;" aria-label="Frise précédente" title="Revenir à la frise précédente">&larr;</button>
        <button id="timeline-back" class="btn-small">Retour au dossier</button>
        <nav id="timeline-breadcrumb" aria-label="Frises parentes"></nav>
        <div id="timeline-toolbar">
          <button id="timeline-add-point" class="btn-small edit-control">&#43; Point</button>
          <button id="timeline-add-period" class="btn-small edit-control">&#43; P&eacute;riode</button>
          <button id="timeline-zoom-out" class="btn-small" aria-label="Dézoomer">&minus;</button>
          <button id="timeline-zoom-in" class="btn-small" aria-label="Zoomer">&#43;</button>
          <button id="timeline-zoom-reset" class="btn-small">Recentrer</button>
        </div>
      </div>
      <div id="timeline-subtitle"></div>
      <div id="timeline-scroll">
        <div id="timeline-stage"></div>
        <p id="timeline-empty-hint" class="muted" style="display:none;"></p>
      </div>
      <div id="tl-point-card" role="dialog" style="display:none;"></div>
    </div>

    <div id="tl-period-overlay">
      <div id="tl-period-box" role="dialog" aria-modal="true">
        <h3 id="tl-period-heading">Nouvelle p&eacute;riode</h3>
        <label class="tl-field" id="tl-period-source-row">Sous-cat&eacute;gorie
          <select id="tl-period-source"></select>
        </label>
        <label class="tl-field">Nom
          <input type="text" id="tl-period-name" maxlength="120" placeholder="ex. Antiquit&eacute;">
        </label>
        <p id="tl-period-gapinfo"></p>
        <div id="tl-period-dates">
          <fieldset class="tl-date" id="tl-start-fields">
            <legend>D&eacute;but</legend>
            <input type="text" inputmode="numeric" id="tl-start-year" placeholder="Ann&eacute;e" aria-label="Ann&eacute;e de d&eacute;but">
            <label class="tl-inline"><input type="checkbox" id="tl-start-bc"> av. J.-C.</label>
            <input type="text" inputmode="numeric" id="tl-start-month" placeholder="Mois" aria-label="Mois de d&eacute;but">
            <input type="text" inputmode="numeric" id="tl-start-day" placeholder="Jour" aria-label="Jour de d&eacute;but">
            <label class="tl-inline"><input type="checkbox" id="tl-start-circa"> vers</label>
          </fieldset>
          <fieldset class="tl-date" id="tl-end-fields">
            <legend>Fin</legend>
            <input type="text" inputmode="numeric" id="tl-end-year" placeholder="Ann&eacute;e" aria-label="Ann&eacute;e de fin">
            <label class="tl-inline"><input type="checkbox" id="tl-end-bc"> av. J.-C.</label>
            <input type="text" inputmode="numeric" id="tl-end-month" placeholder="Mois" aria-label="Mois de fin">
            <input type="text" inputmode="numeric" id="tl-end-day" placeholder="Jour" aria-label="Jour de fin">
            <label class="tl-inline"><input type="checkbox" id="tl-end-circa"> vers</label>
          </fieldset>
        </div>
        <div class="tl-field">Couleur
          <div class="tl-swatches" id="tl-period-colors"></div>
        </div>
        <p id="tl-period-error" class="tl-error" role="alert"></p>
        <div class="tl-actions">
          <button type="button" class="btn-small" id="tl-period-remove">Retirer de la frise</button>
          <span class="tl-spacer"></span>
          <button type="button" class="btn-small" id="tl-period-cancel">Annuler</button>
          <button type="button" class="btn-small tl-primary" id="tl-period-save">Enregistrer</button>
        </div>
      </div>
    </div>

    <div id="tl-point-overlay">
      <div id="tl-point-box" role="dialog" aria-modal="true">
        <h3 id="tl-point-heading">Nouveau point</h3>
        <label class="tl-field">Titre
          <input type="text" id="tl-point-title" maxlength="160" placeholder="ex. Trait&eacute; de Verdun">
        </label>
        <fieldset class="tl-date">
          <legend>Date</legend>
          <input type="text" inputmode="numeric" id="tl-point-year" placeholder="Ann&eacute;e" aria-label="Ann&eacute;e">
          <label class="tl-inline"><input type="checkbox" id="tl-point-bc"> av. J.-C.</label>
          <input type="text" inputmode="numeric" id="tl-point-month" placeholder="Mois" aria-label="Mois">
          <input type="text" inputmode="numeric" id="tl-point-day" placeholder="Jour" aria-label="Jour">
          <label class="tl-inline"><input type="checkbox" id="tl-point-circa"> vers</label>
        </fieldset>
        <div class="tl-field">Position
          <div class="tl-sides">
            <button type="button" class="btn-small" id="tl-side-up">&uarr; Au-dessus</button>
            <button type="button" class="btn-small" id="tl-side-down">&darr; En dessous</button>
          </div>
        </div>
        <div class="tl-field">Couleur
          <div class="tl-swatches" id="tl-point-colors"></div>
        </div>
        <p id="tl-point-note" class="tl-note">Une fiche vide, au nom du point, est cr&eacute;&eacute;e dans le dossier o&ugrave; se trouve cette frise.</p>
        <p id="tl-point-error" class="tl-error" role="alert"></p>
        <div class="tl-actions">
          <button type="button" class="btn-small" id="tl-point-delete">Supprimer le point</button>
          <span class="tl-spacer"></span>
          <button type="button" class="btn-small" id="tl-point-cancel">Annuler</button>
          <button type="button" class="btn-small tl-primary" id="tl-point-save">Enregistrer</button>
        </div>
      </div>
    </div>
  `;
  while (root.firstChild) document.body.appendChild(root.firstChild);

  // --- Pastilles de couleur --------------------------------------------------------
  function buildSwatches(containerId: string, allowNone: boolean, get: () => string | null, set: (c: string | null) => void) {
    const box = $(containerId);
    box.innerHTML = "";
    // Sélecteur de couleur complet (même palette que les autres couleurs de l'atlas).
    const picker = document.createElement("input");
    picker.type = "color";
    picker.className = "tl-color-input";
    picker.value = get() || "#2980b9";
    picker.title = "Choisir une couleur";
    box.appendChild(picker);
    const choices: (string | null)[] = allowNone ? [null, ...PALETTE] : [...PALETTE];
    const buttons: HTMLButtonElement[] = [];
    const refresh = () => buttons.forEach((el, i) => el.classList.toggle("selected", choices[i] === get()));
    for (const c of choices) {
      const b = document.createElement("button");
      b.type = "button";
      b.className = "tl-swatch" + (c === null ? " none" : "");
      if (c) b.style.background = c;
      b.title = c ?? "Aucune couleur";
      b.setAttribute("aria-label", c ?? "Aucune couleur");
      b.addEventListener("click", () => {
        set(c);
        if (c) picker.value = c;
        refresh();
      });
      buttons.push(b);
      box.appendChild(b);
    }
    picker.addEventListener("input", () => {
      set(picker.value);
      refresh();
    });
    refresh();
  }

  // --- Chargement ----------------------------------------------------------------
  async function fetchEntry(id: string): Promise<FriseEntry | null> {
    const { data } = await supabase
      .from("dossier_entries")
      .select("id, title, owner_type, owner_id, category_id, section_id")
      .eq("id", id)
      .maybeSingle();
    return (data as FriseEntry | null) ?? null;
  }
  async function fetchSection(id: string): Promise<SectionRow | null> {
    const { data } = await supabase.from("dossier_sections").select(SECTION_COLUMNS).eq("id", id).maybeSingle();
    return (data as SectionRow | null) ?? null;
  }
  async function fetchSectionRows(friseId: string): Promise<SectionRow[]> {
    const { data } = await supabase.from("dossier_sections").select(SECTION_COLUMNS).eq("period_frise_id", friseId);
    return ((data as SectionRow[] | null) ?? []).filter((r) => r.period_start_year != null);
  }

  async function loadPoints(friseId: string): Promise<Point[]> {
    const { data: pl } = await supabase
      .from("timeline_placements")
      .select("event_id, side, color, stem_length")
      .eq("frise_entry_id", friseId);
    const placements = (pl as { event_id: string; side: string | null; color: string | null; stem_length: number | null }[] | null) ?? [];
    if (!placements.length) return [];
    const ids = placements.map((p) => p.event_id);
    const { data: ev } = await supabase
      .from("timeline_events")
      .select("id, title, date_year, date_month, date_day, date_circa")
      .in("id", ids);
    const { data: fi } = await supabase.from("timeline_event_fiches").select("entry_id, event_id").in("event_id", ids);
    const fiche = new Map<string, string>();
    for (const f of (fi as { entry_id: string; event_id: string }[] | null) ?? []) {
      if (!fiche.has(f.event_id)) fiche.set(f.event_id, f.entry_id);
    }
    const out: Point[] = [];
    for (const e of (ev as { id: string; title: string; date_year: number; date_month: number | null; date_day: number | null; date_circa: boolean }[] | null) ?? []) {
      const p = placements.find((x) => x.event_id === e.id);
      out.push({
        eventId: e.id,
        title: e.title,
        date: { year: e.date_year, month: e.date_month, day: e.date_day, circa: !!e.date_circa },
        side: p?.side === "up" ? "up" : "down",
        color: p?.color || DEFAULT_POINT_COLOR,
        stem: p?.stem_length ?? null,
        entryId: fiche.get(e.id) ?? null,
      });
    }
    return out;
  }

  async function load(entryId: string): Promise<boolean> {
    const token = ++loadToken;
    const entry = await fetchEntry(entryId);
    if (!entry || token !== loadToken) return false;
    const rows = await fetchSectionRows(entry.id);
    if (token !== loadToken) return false;
    const pRows = rows.filter((r) => !r.period_is_transition);
    const tRows = rows.filter((r) => r.period_is_transition);

    // Sous-frises : frises posées dans la sous-catégorie d'une période ou d'une transition.
    const subs = new Map<string, { id: string; title: string | null }>();
    if (rows.length) {
      const { data } = await supabase
        .from("dossier_entries")
        .select("id, title, section_id, created_at")
        .eq("type", "frise")
        .in("section_id", rows.map((r) => r.id))
        .order("created_at", { ascending: true });
      for (const e of (data as { id: string; title: string | null; section_id: string }[] | null) ?? []) {
        if (!subs.has(e.section_id)) subs.set(e.section_id, { id: e.id, title: e.title });
      }
    }
    const pts = await loadPoints(entry.id);

    // Ancêtres : si cette frise est posée dans une période / transition d'une frise parente.
    const chain: Ancestor[] = [];
    let ctx: FriseContext | null = null;
    let cur: FriseEntry = entry;
    for (let depth = 0; depth < 12 && cur.section_id; depth++) {
      const sec = await fetchSection(cur.section_id);
      if (!sec || !sec.period_frise_id) break;
      const parent = await fetchEntry(sec.period_frise_id);
      if (!parent) break;
      if (depth === 0) {
        const sibRows = (await fetchSectionRows(parent.id)).filter((r) => !r.period_is_transition);
        const { segments } = layoutPeriods(sibRows.map(rowToPeriod));
        const idx = sec.period_is_transition
          ? segments.findIndex((s) => s.kind === "gap" && s.afterPeriodId === sec.transition_after_id)
          : segments.findIndex((s) => s.kind === "period" && s.period.id === sec.id);
        ctx = idx >= 0 ? describeBounds(segments, idx, sec.title) : { periodName: sec.title, from: "", to: "" };
      }
      chain.unshift({ id: parent.id, title: parent.title || "Frise" });
      cur = parent;
    }
    if (token !== loadToken) return false;

    frise = entry;
    periodRows = pRows;
    transitionRows = tRows;
    periods = pRows.map(rowToPeriod);
    subFrises = subs;
    points = pts;
    ancestors = chain;
    context = ctx;
    return true;
  }

  function describeBounds(segments: Segment[], index: number, name: string): FriseContext {
    const seg = segments[index];
    const prev = segments[index - 1];
    const next = segments[index + 1];
    if (seg.kind === "gap") {
      const from = prev && prev.kind === "period" && prev.period.end ? formatFriseDate(prev.period.end) : "";
      const to = next && next.kind === "period" ? formatFriseDate(next.period.start) : "";
      return { periodName: name, from, to };
    }
    const p = seg.period;
    let to: string;
    if (p.end && !seg.openEnded) to = formatFriseDate(p.end);
    else if (next && next.kind === "period") to = formatFriseDate(next.period.start);
    else to = "aujourd'hui";
    return { periodName: name, from: formatFriseDate(p.start), to };
  }

  // --- Rendu -----------------------------------------------------------------------
  const STEM_BASE = 26;
  const STEM_STEP = 30;
  const LABEL_PAD = 14;

  // Les points dont la hauteur est réglée à la main gardent leur hauteur ; les autres
  // sont rangés automatiquement en branches empilées (niveaux).
  const RULER_H = 26;
  type Placed = { p: Point; x: number; len: number; w: number };
  function placeSide(items: { p: Point; x: number }[], side: "up" | "down"): Placed[] {
    const base = STEM_BASE + (side === "down" ? RULER_H : 0);
    const sorted = [...items].sort((a, b) => a.x - b.x || dateSortKey(a.p.date) - dateSortKey(b.p.date));
    const lastRight: number[] = [];
    const out: Placed[] = [];
    for (const it of sorted) {
      const w = Math.min(textWidth(it.p.title) + LABEL_PAD, 260);
      if (it.p.stem != null) {
        out.push({ p: it.p, x: it.x, len: it.p.stem, w });
        continue;
      }
      let level = 0;
      while (level < lastRight.length && lastRight[level] > it.x - 2) level++;
      lastRight[level] = it.x + 6 + w;
      out.push({ p: it.p, x: it.x, len: base + level * STEM_STEP, w });
    }
    return out;
  }

  function render() {
    if (!frise) return;
    const admin = isAdmin();
    document.body.classList.toggle("tl-can-edit", admin);
    closePointCard();

    const bc = $("timeline-breadcrumb");
    bc.innerHTML = "";
    for (const a of ancestors) {
      const b = document.createElement("button");
      b.type = "button";
      b.className = "tl-crumb";
      b.textContent = a.title;
      b.addEventListener("click", () => void goTo(a.id));
      bc.appendChild(b);
      const sep = document.createElement("span");
      sep.className = "tl-crumb-sep";
      sep.textContent = "›";
      bc.appendChild(sep);
    }
    const here = document.createElement("h2");
    here.id = "timeline-title";
    here.textContent = frise.title || "Frise chronologique";
    bc.appendChild(here);

    const sub = $("timeline-subtitle");
    if (context && context.from) {
      sub.innerHTML = "« <strong>" + esc(context.periodName) + "</strong> » · " + esc(context.from) + " → " + esc(context.to);
      sub.style.display = "";
    } else if (context) {
      sub.innerHTML = "« <strong>" + esc(context.periodName) + "</strong> »";
      sub.style.display = "";
    } else {
      sub.style.display = "none";
    }

    const stage = $("timeline-stage");
    stage.innerHTML = "";
    const hint = $("timeline-empty-hint");
    if (!periods.length) {
      hint.style.display = "";
      hint.textContent = admin
        ? "Cette frise n'a pas encore de période. Utilise « + Période » : chaque période devient une sous-catégorie du dossier."
        : "Cette frise n'a pas encore de période.";
      return;
    }
    hint.style.display = "none";

    const { segments, issues } = layoutPeriods(periods);
    const scroll = $("timeline-scroll");
    const baseWidth = Math.max(scroll.clientWidth - 200, 320);
    const widths = computeLinearWidths(segments, baseWidth * zoom);
    const total = widths.reduce((s, w) => s + w, 0);

    // Points : position x, niveaux (branches empilées) de chaque côté.
    const placedItems: { p: Point; x: number }[] = [];
    let outside = 0;
    for (const p of points) {
      const x = xForDecimal(dateToDecimal(p.date), segments, widths);
      if (x === null) outside++;
      else placedItems.push({ p, x });
    }
    const up = placeSide(placedItems.filter((i) => i.p.side === "up"), "up");
    const down = placeSide(placedItems.filter((i) => i.p.side === "down"), "down");
    const zoneH = (pl: Placed[]) => Math.max(80, (pl.length ? Math.max(...pl.map((i) => i.len)) : 0) + 40);

    const wrap = document.createElement("div");
    wrap.className = "tl-band-wrap";
    wrap.style.width = total + "px";

    const upH = zoneH(up);
    const upZone = document.createElement("div");
    upZone.className = "tl-zone tl-zone-up";
    upZone.style.height = upH + "px";
    wrap.appendChild(upZone);

    const band = document.createElement("div");
    band.className = "tl-band";
    segments.forEach((seg, i) => {
      const cell = document.createElement("div");
      cell.style.width = widths[i] + "px";
      cell.tabIndex = 0;
      cell.setAttribute("role", "button");
      let sectionRow: SectionRow | undefined;
      let name: string;
      let startText: string;
      let color: string | null;
      let onEdit: () => void;
      if (seg.kind === "gap") {
        sectionRow = transitionRows.find((r) => r.transition_after_id === seg.afterPeriodId);
        const prevP = periods.find((p) => p.id === seg.afterPeriodId);
        name = sectionRow ? sectionRow.title : "";
        startText = prevP?.end ? formatFriseDate(prevP.end) : "";
        color = sectionRow?.period_color ?? null;
        cell.className = "tl-gap tl-cell";
        onEdit = () => requireAdminOr(() => void openPeriodDialog(null, seg.afterPeriodId));
      } else {
        const p = seg.period;
        sectionRow = periodRows.find((r) => r.id === p.id);
        name = p.name;
        startText = formatFriseDate(p.start);
        color = p.color;
        cell.className = "tl-period tl-cell";
        onEdit = () => requireAdminOr(() => void openPeriodDialog(p.id, null));
      }
      const subFrise = sectionRow ? subFrises.get(sectionRow.id) : undefined;
      cell.title = subFrise
        ? "Ouvrir la sous-frise « " + (subFrise.title || name) + " »"
        : admin
          ? "Cliquer pour créer la sous-frise"
          : name;
      if (color) {
        cell.style.setProperty("--tl-color", color);
        cell.classList.add("colored");
      }
      const nameEl = document.createElement("span");
      nameEl.className = "tl-cell-name";
      nameEl.textContent = name;
      cell.appendChild(nameEl);
      if (startText) {
        const d = document.createElement("span");
        d.className = "tl-date-start";
        d.textContent = startText;
        cell.appendChild(d);
      }
      if (i === segments.length - 1 && seg.kind === "period") {
        const d = document.createElement("span");
        d.className = "tl-date-end";
        d.textContent = seg.period.end && !seg.openEnded ? formatFriseDate(seg.period.end) : "aujourd'hui";
        cell.appendChild(d);
      }
      const tools = document.createElement("span");
      tools.className = "tl-cell-tools";
      if (sectionRow) {
        const row = sectionRow;
        const open = document.createElement("button");
        open.type = "button";
        open.className = "tl-tool";
        open.textContent = "Sous-catégorie";
        open.title = "Ouvrir la sous-catégorie « " + row.title + " » dans le dossier";
        open.addEventListener("click", (ev) => {
          ev.stopPropagation();
          closeView();
          deps.revealSection(row.id, row.category_id);
        });
        tools.appendChild(open);
      }
      if (admin) {
        const edit = document.createElement("button");
        edit.type = "button";
        edit.className = "tl-tool edit-control";
        edit.textContent = "Modifier";
        edit.addEventListener("click", (ev) => {
          ev.stopPropagation();
          onEdit();
        });
        tools.appendChild(edit);
      }
      cell.appendChild(tools);
      const go = () => void onCellActivate(seg);
      cell.addEventListener("click", go);
      cell.addEventListener("keydown", (ev) => {
        if (ev.key === "Enter" || ev.key === " ") {
          ev.preventDefault();
          go();
        }
      });
      band.appendChild(cell);
    });
    wrap.appendChild(band);

    const downZone = document.createElement("div");
    downZone.className = "tl-zone tl-zone-down";
    downZone.style.height = zoneH(down) + "px";
    wrap.appendChild(downZone);

    // Règle graduée (échelle constante : mêmes pixels par année sur toute la frise).
    const startDec = segments[0].startDec;
    const endDec = segments[segments.length - 1].endDec;
    const ppy = total / Math.max(endDec - startDec, 1e-6);
    const ruler = document.createElement("div");
    ruler.className = "tl-ruler";
    for (const t of niceTicks(startDec, endDec, ppy)) {
      const x = xForDecimal(t.dec, segments, widths);
      if (x === null) continue;
      const tick = document.createElement("span");
      tick.className = "tl-tick" + (t.month === 1 ? " year" : "");
      tick.style.left = x + "px";
      const lab = document.createElement("span");
      lab.className = "tl-tick-label";
      lab.textContent = t.label;
      tick.appendChild(lab);
      ruler.appendChild(tick);
    }
    downZone.appendChild(ruler);

    // Tiges et branches : les plus longues d'abord pour que, à date égale,
    // chaque segment de tige prenne la couleur de sa propre branche.
    // Couche unique pour les tiges, points et pastilles (coordonnées absolues) : un point
    // glissé de l'autre côté de la bande ne change jamais de parent DOM (sinon le glissement
    // serait interrompu).
    const layer = document.createElement("div");
    layer.className = "tl-layer";
    wrap.appendChild(layer);
    const bandEl = band;
    const BAND_H = 84;
    const drawSide = (list: Placed[], side: "up" | "down") => {
      [...list].sort((a, b) => b.len - a.len).forEach((it) => {
        const stem = document.createElement("span");
        stem.className = "tl-stem";
        stem.style.left = it.x - 1 + "px";
        stem.style.background = it.p.color;
        layer.appendChild(stem);
        it.p.stemEl = stem;
      });
      list.forEach((it) => {
        const lab = document.createElement("button");
        lab.type = "button";
        lab.className = "tl-point" + (admin ? " movable" : "");
        lab.textContent = it.p.title;
        lab.title = it.p.title + " — " + formatFriseDate(it.p.date) + (admin ? " (glisser verticalement pour régler la hauteur)" : "");
        lab.style.left = it.x + 3 + "px";
        lab.style.maxWidth = "260px";
        lab.style.borderColor = it.p.color;
        layer.appendChild(lab);
        const dot = document.createElement("span");
        dot.className = "tl-dot";
        dot.style.left = it.x + "px";
        dot.style.background = it.p.color;
        layer.appendChild(dot);
        const place = (s: "up" | "down", len: number) => {
          const stem = it.p.stemEl as HTMLElement;
          const stemTop = s === "up" ? upH - len : upH + BAND_H;
          const centerY = s === "up" ? stemTop : stemTop + len;
          stem.style.top = stemTop + "px";
          stem.style.height = len + "px";
          lab.style.top = centerY + "px";
          dot.style.top = centerY + "px";
        };
        place(side, it.len);

        // Hauteur à la main : on glisse le point verticalement (jamais horizontalement,
        // la date ne change pas). Passer de l'autre côté de la bande le fait changer de côté.
        let press: { moved: boolean; side: "up" | "down"; len: number } | null = null;
        lab.addEventListener("pointerdown", (ev) => {
          if (!admin || ev.button !== 0) return;
          ev.stopPropagation();
          lab.setPointerCapture(ev.pointerId);
          press = { moved: false, side: side, len: it.len };
          closePointCard();
        });
        lab.addEventListener("pointermove", (ev) => {
          if (!press) return;
          const r = bandEl.getBoundingClientRect();
          let s: "up" | "down";
          let len: number;
          if (ev.clientY <= r.top - 8) {
            s = "up";
            len = r.top - ev.clientY;
          } else if (ev.clientY >= r.bottom + 8) {
            s = "down";
            len = ev.clientY - r.bottom;
          } else {
            s = (ev.clientY < (r.top + r.bottom) / 2 ? "up" : "down") as "up" | "down";
            len = 8;
          }
          len = Math.round(Math.min(900, Math.max(8, len)));
          if (!press.moved && s === press.side && Math.abs(len - press.len) < 4) return;
          press.moved = true;
          press.side = s;
          press.len = len;
          lab.classList.add("dragging");
          place(s, len);
        });
        const finish = async () => {
          const pr = press;
          press = null;
          lab.classList.remove("dragging");
          if (!pr || !pr.moved || !frise) return;
          suppressPointClick = true;
          setTimeout(() => (suppressPointClick = false), 0);
          const { error } = await supabase
            .from("timeline_placements")
            .update({ side: pr.side, stem_length: pr.len })
            .eq("frise_entry_id", frise.id)
            .eq("event_id", it.p.eventId);
          if (error) deps.showBanner?.("Échec de l'enregistrement de la hauteur : " + error.message);
          await reload();
        };
        lab.addEventListener("pointerup", () => void finish());
        lab.addEventListener("pointercancel", () => void finish());
        lab.addEventListener("click", (ev) => {
          ev.stopPropagation();
          if (suppressPointClick) return;
          openPointCard(it.p, lab);
        });
      });
    };
    drawSide(up, "up");
    drawSide(down, "down");

    const notes: string[] = issues.map((i) => i.message);
    if (outside) notes.push(outside + " point(s) ont une date en dehors de la frise et ne sont pas affichés.");
    if (notes.length) {
      const warn = document.createElement("p");
      warn.className = "tl-issues";
      warn.textContent = notes.join(" ");
      wrap.appendChild(warn);
    }
    stage.appendChild(wrap);
  }

  // --- Navigation ------------------------------------------------------------------
  async function ensureTransitionRow(afterPeriodId: string): Promise<SectionRow | null> {
    const existing = transitionRows.find((r) => r.transition_after_id === afterPeriodId);
    if (existing) return existing;
    const session = deps.getSession();
    if (!frise || !frise.category_id || !session) {
      deps.showBanner?.("Cette frise doit être dans une catégorie du dossier pour accueillir une transition.");
      return null;
    }
    const { segments } = layoutPeriods(periods);
    const idx = segments.findIndex((s) => s.kind === "gap" && s.afterPeriodId === afterPeriodId);
    const prev = periods.find((p) => p.id === afterPeriodId);
    const nextSeg = segments[idx + 1];
    if (idx < 0 || !prev || !nextSeg || nextSeg.kind !== "period") return null;
    return createTransitionRow(afterPeriodId, "Transition", prev.end ?? prev.start, nextSeg.period.start, null);
  }

  async function createTransitionRow(
    afterPeriodId: string,
    title: string,
    from: FriseDate,
    to: FriseDate,
    color: string | null
  ): Promise<SectionRow | null> {
    const session = deps.getSession();
    if (!frise || !frise.category_id || !session) return null;
    const { data, error } = await supabase
      .from("dossier_sections")
      .insert({
        owner_type: frise.owner_type,
        owner_id: frise.owner_id,
        category_id: frise.category_id,
        parent_section_id: frise.section_id,
        title,
        position: 1000 + periods.length,
        created_by: session.user.id,
        period_frise_id: frise.id,
        period_is_transition: true,
        transition_after_id: afterPeriodId,
        period_color: color,
        ...dateColumns("period_start", from),
        ...dateColumns("period_end", to),
      })
      .select(SECTION_COLUMNS)
      .single();
    if (error || !data) {
      deps.showBanner?.("Échec de la création de la transition : " + (error?.message || "erreur inconnue."));
      return null;
    }
    const row = data as SectionRow;
    transitionRows.push(row);
    return row;
  }

  async function onCellActivate(seg: Segment) {
    let row: SectionRow | undefined;
    let name: string;
    if (seg.kind === "gap") {
      row = transitionRows.find((r) => r.transition_after_id === seg.afterPeriodId);
      name = row ? row.title : "cette transition";
    } else {
      row = periodRows.find((r) => r.id === seg.period.id);
      name = seg.period.name;
    }
    const sub = row ? subFrises.get(row.id) : undefined;
    if (sub) {
      await goTo(sub.id);
      return;
    }
    if (!isAdmin()) {
      deps.showBanner?.("Pas de sous-frise pour « " + name + " ».");
      return;
    }
    const ok = await customConfirm("« " + name + " » n'a pas encore de sous-frise.\nEn créer une ici ?");
    if (!ok) return;
    if (!row && seg.kind === "gap") {
      row = (await ensureTransitionRow(seg.afterPeriodId)) ?? undefined;
      name = row ? row.title : name;
    }
    const session = deps.getSession();
    if (!row || !frise || !session) return;
    const { data, error } = await supabase
      .from("dossier_entries")
      .insert({
        owner_type: frise.owner_type,
        owner_id: frise.owner_id,
        type: "frise",
        title: row.title,
        category_id: row.category_id,
        section_id: row.id,
        tags: [],
        sources: [],
        status: "published",
        created_by: session.user.id,
      })
      .select("id")
      .single();
    if (error || !data) {
      deps.showBanner?.("Échec de la création de la sous-frise : " + (error?.message || "erreur inconnue."));
      return;
    }
    await deps.refreshDossier();
    await goTo(data.id as string);
  }

  // Navigation DANS les frises (clic sur une période, fil d'Ariane) : on garde la frise
  // quittée pour pouvoir y revenir avec la flèche en haut à gauche.
  async function goTo(entryId: string) {
    const from = frise ? frise.id : null;
    if (from && from !== entryId) history.push(from);
    await openForEntry(entryId);
  }
  function updatePrevButton() {
    $("timeline-prev").style.display = history.length ? "" : "none";
  }

  async function openFromDossier(entryId: string) {
    history = [];
    frise = null;
    await openForEntry(entryId);
  }

  async function openForEntry(entryId: string) {
    $("timeline-view").classList.add("open");
    const fresh = !frise || frise.id !== entryId;
    const ok = await load(entryId);
    if (!ok) {
      deps.showBanner?.("Frise introuvable.");
      if (!frise) closeView();
      return;
    }
    if (fresh) zoom = 1;
    updatePrevButton();
    render();
    if (fresh) centerView();
  }

  function centerView() {
    const sc = $("timeline-scroll");
    sc.scrollLeft = 0;
    sc.scrollTop = Math.max(0, (sc.scrollHeight - sc.clientHeight) / 2);
  }

  function closeView() {
    $("timeline-view").classList.remove("open");
    closePeriodDialog();
    closePointDialog();
    closePointCard();
    document.body.classList.remove("tl-can-edit");
    history = [];
  }

  // --- Déplacement (glisser) et zoom (molette), comme l'arbre généalogique ------------
  const scrollEl = $("timeline-scroll");
  let drag: { x: number; y: number; sl: number; st: number; moved: boolean } | null = null;
  let suppressClick = false;
  scrollEl.addEventListener("pointerdown", (ev) => {
    if (ev.button !== 0) return;
    if ((ev.target as HTMLElement).closest("input, select, textarea")) return;
    drag = { x: ev.clientX, y: ev.clientY, sl: scrollEl.scrollLeft, st: scrollEl.scrollTop, moved: false };
  });
  window.addEventListener("pointermove", (ev) => {
    if (!drag) return;
    const dx = ev.clientX - drag.x;
    const dy = ev.clientY - drag.y;
    if (!drag.moved && Math.hypot(dx, dy) > 5) {
      drag.moved = true;
      scrollEl.classList.add("dragging");
      closePointCard();
    }
    if (drag.moved) {
      scrollEl.scrollLeft = drag.sl - dx;
      scrollEl.scrollTop = drag.st - dy;
    }
  });
  const endDrag = () => {
    if (drag && drag.moved) {
      suppressClick = true;
      setTimeout(() => (suppressClick = false), 0);
    }
    drag = null;
    scrollEl.classList.remove("dragging");
  };
  window.addEventListener("pointerup", endDrag);
  window.addEventListener("pointercancel", endDrag);
  scrollEl.addEventListener(
    "click",
    (ev) => {
      if (suppressClick) {
        ev.stopPropagation();
        ev.preventDefault();
        suppressClick = false;
      }
    },
    true
  );

  function setZoom(newZoom: number, anchorClientX?: number) {
    if (!frise || !periods.length) return;
    const z = Math.min(10, Math.max(0.4, newZoom));
    if (z === zoom) return;
    const wrapEl = document.querySelector<HTMLElement>(".tl-band-wrap");
    const rect = scrollEl.getBoundingClientRect();
    const cx = (anchorClientX ?? rect.left + rect.width / 2) - rect.left;
    const oldTotal = wrapEl ? wrapEl.offsetWidth : 1;
    const left = wrapEl ? wrapEl.offsetLeft : 0;
    const frac = (scrollEl.scrollLeft + cx - left) / oldTotal;
    zoom = z;
    render();
    const nw = document.querySelector<HTMLElement>(".tl-band-wrap");
    if (nw) scrollEl.scrollLeft = frac * nw.offsetWidth + nw.offsetLeft - cx;
  }
  scrollEl.addEventListener(
    "wheel",
    (ev) => {
      if (!$("timeline-view").classList.contains("open") || !periods.length) return;
      ev.preventDefault();
      setZoom(zoom * Math.exp(-ev.deltaY * 0.0015), ev.clientX);
    },
    { passive: false }
  );
  $("timeline-zoom-in").addEventListener("click", () => setZoom(zoom * 1.4));
  $("timeline-zoom-out").addEventListener("click", () => setZoom(zoom / 1.4));
  $("timeline-zoom-reset").addEventListener("click", () => {
    zoom = 1;
    render();
    centerView();
  });

  // --- Dialogue période / transition ------------------------------------------------------
  function fieldValue(id: string): string {
    return ($(id) as HTMLInputElement).value;
  }
  function setField(id: string, v: string) {
    ($(id) as HTMLInputElement).value = v;
  }
  function checked(id: string): boolean {
    return ($(id) as HTMLInputElement).checked;
  }
  function setChecked(id: string, v: boolean) {
    ($(id) as HTMLInputElement).checked = v;
  }
  function fillDate(prefix: string, d: FriseDate | null) {
    setField(prefix + "-year", d ? String(Math.abs(d.year)) : "");
    setChecked(prefix + "-bc", !!d && d.year < 0);
    setField(prefix + "-month", d?.month ? String(d.month) : "");
    setField(prefix + "-day", d?.day ? String(d.day) : "");
    setChecked(prefix + "-circa", !!d?.circa);
  }
  function readDate(prefix: string) {
    return parseDateFields({
      year: fieldValue(prefix + "-year"),
      bc: checked(prefix + "-bc"),
      month: fieldValue(prefix + "-month"),
      day: fieldValue(prefix + "-day"),
      circa: checked(prefix + "-circa"),
    });
  }
  function showPeriodError(msg: string) {
    $("tl-period-error").textContent = msg;
  }

  async function openPeriodDialog(periodId: string | null, gapAfterId: string | null) {
    if (!frise) return;
    editingPeriodId = periodId;
    dialogGapAfter = gapAfterId;
    showPeriodError("");
    const sourceRow = $("tl-period-source-row");
    const sel = $("tl-period-source") as HTMLSelectElement;
    const dates = $("tl-period-dates");
    const gapInfo = $("tl-period-gapinfo");
    if (gapAfterId) {
      // Transition : seuls le nom et la couleur se modifient, les dates viennent des périodes voisines.
      const row = transitionRows.find((r) => r.transition_after_id === gapAfterId);
      const { segments } = layoutPeriods(periods);
      const idx = segments.findIndex((s) => s.kind === "gap" && s.afterPeriodId === gapAfterId);
      const b = idx >= 0 ? describeBounds(segments, idx, "") : { from: "", to: "" };
      $("tl-period-heading").textContent = "Transition";
      sourceRow.style.display = "none";
      dates.style.display = "none";
      gapInfo.style.display = "";
      gapInfo.textContent = "De " + b.from + " à " + b.to + " (calculée d'après les périodes voisines)." ;
      setField("tl-period-name", row ? row.title : "");
      periodColor = row?.period_color ?? null;
      $("tl-period-remove").style.display = row ? "" : "none";
    } else if (periodId) {
      const p = periods.find((x) => x.id === periodId);
      if (!p) return;
      $("tl-period-heading").textContent = "Modifier la période";
      sourceRow.style.display = "none";
      dates.style.display = "";
      gapInfo.style.display = "none";
      setField("tl-period-name", p.name);
      fillDate("tl-start", p.start);
      fillDate("tl-end", p.end);
      periodColor = p.color;
      $("tl-period-remove").style.display = "";
    } else {
      $("tl-period-heading").textContent = "Nouvelle période";
      sourceRow.style.display = "";
      dates.style.display = "";
      gapInfo.style.display = "none";
      let q = supabase
        .from("dossier_sections")
        .select("id, title")
        .eq("owner_type", frise.owner_type)
        .eq("owner_id", frise.owner_id)
        .is("period_frise_id", null);
      q = frise.category_id ? q.eq("category_id", frise.category_id) : q;
      q = frise.section_id ? q.eq("parent_section_id", frise.section_id) : q.is("parent_section_id", null);
      const { data } = await q.order("position", { ascending: true });
      sel.innerHTML = '<option value="">Nouvelle sous-catégorie</option>';
      for (const s of (data as { id: string; title: string }[] | null) ?? []) {
        const o = document.createElement("option");
        o.value = s.id;
        o.textContent = "Utiliser l'existante : " + s.title;
        o.dataset.title = s.title;
        sel.appendChild(o);
      }
      setField("tl-period-name", "");
      // Début proposé : la fin de la dernière période.
      const { sorted } = layoutPeriods(periods);
      const last = sorted[sorted.length - 1];
      fillDate("tl-start", last ? (last.end ?? last.start) : null);
      fillDate("tl-end", null);
      periodColor = null;
      $("tl-period-remove").style.display = "none";
    }
    buildSwatches("tl-period-colors", true, () => periodColor, (c) => (periodColor = c));
    $("tl-period-overlay").classList.add("open");
    ($("tl-period-name") as HTMLInputElement).focus();
  }
  function closePeriodDialog() {
    $("tl-period-overlay").classList.remove("open");
    editingPeriodId = null;
    dialogGapAfter = null;
  }

  async function savePeriod() {
    if (!frise) return;
    const name = fieldValue("tl-period-name").trim();
    ($("tl-period-save") as HTMLButtonElement).disabled = true;
    try {
      // Transition : nom + couleur seulement.
      if (dialogGapAfter) {
        const afterId = dialogGapAfter;
        const row = transitionRows.find((r) => r.transition_after_id === afterId);
        if (row) {
          const { error } = await supabase
            .from("dossier_sections")
            .update({ title: name || "Transition", period_color: periodColor })
            .eq("id", row.id);
          if (error) return showPeriodError("Échec de l'enregistrement : " + error.message);
        } else {
          const { segments } = layoutPeriods(periods);
          const idx = segments.findIndex((s) => s.kind === "gap" && s.afterPeriodId === afterId);
          const prev = periods.find((p) => p.id === afterId);
          const nxt = segments[idx + 1];
          if (idx < 0 || !prev || !nxt || nxt.kind !== "period") return showPeriodError("Transition introuvable.");
          const created = await createTransitionRow(afterId, name || "Transition", prev.end ?? prev.start, nxt.period.start, periodColor);
          if (!created) return showPeriodError("Impossible de créer la transition (la frise doit être dans une catégorie).");
        }
        closePeriodDialog();
        await deps.refreshDossier();
        await reload();
        return;
      }

      if (!name) return showPeriodError("Donne un nom à la période.");
      const start = readDate("tl-start");
      if (!start.ok) return showPeriodError("Début : " + start.error);
      const end = readDate("tl-end");
      if (!end.ok) return showPeriodError("Fin : " + end.error);
      if (dateSortKey(end.date) < dateSortKey(start.date)) {
        return showPeriodError("La fin ne peut pas être avant le début.");
      }

      // Aucune NOUVELLE anomalie (chevauchement...) ne doit apparaître.
      const before = new Set(layoutPeriods(periods).issues.map((i) => i.periodId + i.message));
      const targetId = editingPeriodId ?? "__new__";
      const candidate: Period = { id: targetId, name, start: start.date, end: end.date, color: periodColor };
      const hypothetical = periods.filter((p) => p.id !== editingPeriodId).concat(candidate);
      const fresh = layoutPeriods(hypothetical).issues.filter((i) => !before.has(i.periodId + i.message));
      if (fresh.length) return showPeriodError(fresh[0].message);

      const cols = {
        title: name,
        period_frise_id: frise.id,
        period_is_transition: false,
        period_color: periodColor,
        ...dateColumns("period_start", start.date),
        ...dateColumns("period_end", end.date),
      };
      if (editingPeriodId) {
        const { error } = await supabase.from("dossier_sections").update(cols).eq("id", editingPeriodId);
        if (error) return showPeriodError("Échec de l'enregistrement : " + error.message);
      } else {
        const chosen = ($("tl-period-source") as HTMLSelectElement).value;
        if (chosen) {
          const { error } = await supabase.from("dossier_sections").update(cols).eq("id", chosen);
          if (error) return showPeriodError("Échec de l'enregistrement : " + error.message);
        } else {
          const session = deps.getSession();
          if (!session) return showPeriodError("Connexion requise.");
          if (!frise.category_id) {
            return showPeriodError("Cette frise n'est dans aucune catégorie : place-la d'abord dans une catégorie du dossier.");
          }
          const { data: sibs } = await supabase
            .from("dossier_sections")
            .select("position")
            .eq("owner_type", frise.owner_type)
            .eq("owner_id", frise.owner_id)
            .eq("category_id", frise.category_id);
          const maxPos = Math.max(-1, ...((sibs as { position: number | null }[] | null) ?? []).map((s) => s.position ?? 0));
          const { error } = await supabase.from("dossier_sections").insert({
            owner_type: frise.owner_type,
            owner_id: frise.owner_id,
            category_id: frise.category_id,
            parent_section_id: frise.section_id,
            position: maxPos + 1,
            created_by: session.user.id,
            ...cols,
          });
          if (error) return showPeriodError("Échec de l'enregistrement : " + error.message);
        }
      }
      closePeriodDialog();
      await deps.refreshDossier();
      await reload();
    } finally {
      ($("tl-period-save") as HTMLButtonElement).disabled = false;
    }
  }

  async function removePeriod() {
    let rowId: string | null = null;
    let label = "";
    if (dialogGapAfter) {
      const row = transitionRows.find((r) => r.transition_after_id === dialogGapAfter);
      if (!row) return;
      rowId = row.id;
      label = row.title;
    } else if (editingPeriodId) {
      const p = periods.find((x) => x.id === editingPeriodId);
      if (!p) return;
      rowId = p.id;
      label = p.name;
    }
    if (!rowId) return;
    const ok = await customConfirm(
      "Retirer « " + label + " » de la frise ?\nLa sous-catégorie et tout son contenu sont conservés dans le dossier ; elle cesse seulement d'apparaître dans la frise."
    );
    if (!ok) return;
    const { error } = await supabase
      .from("dossier_sections")
      .update({
        period_frise_id: null,
        period_is_transition: false,
        transition_after_id: null,
        period_color: null,
        ...dateColumns("period_start", null),
        ...dateColumns("period_end", null),
      })
      .eq("id", rowId);
    if (error) return showPeriodError("Échec : " + error.message);
    closePeriodDialog();
    await deps.refreshDossier();
    await reload();
  }

  async function reload() {
    if (!frise) return;
    if (await load(frise.id)) render();
  }

  // --- Points -------------------------------------------------------------------------------
  function showPointError(msg: string) {
    $("tl-point-error").textContent = msg;
  }
  function setSide(side: "up" | "down") {
    pointSide = side;
    $("tl-side-up").classList.toggle("tl-primary", side === "up");
    $("tl-side-down").classList.toggle("tl-primary", side === "down");
  }

  function openPointDialog(point: Point | null) {
    if (!frise) return;
    if (!periods.length) {
      deps.showBanner?.("Crée d'abord au moins une période : les points se posent sur la bande.");
      return;
    }
    editingPoint = point;
    showPointError("");
    $("tl-point-heading").textContent = point ? "Modifier le point" : "Nouveau point";
    setField("tl-point-title", point ? point.title : "");
    const pre = point ? point.date : null;
    setField("tl-point-year", pre ? String(Math.abs(pre.year)) : "");
    setChecked("tl-point-bc", !!pre && pre.year < 0);
    setField("tl-point-month", pre?.month ? String(pre.month) : "");
    setField("tl-point-day", pre?.day ? String(pre.day) : "");
    setChecked("tl-point-circa", !!pre?.circa);
    setSide(point ? point.side : "up");
    pointColor = point ? point.color : DEFAULT_POINT_COLOR;
    buildSwatches("tl-point-colors", false, () => pointColor, (c) => (pointColor = c || DEFAULT_POINT_COLOR));
    $("tl-point-delete").style.display = point ? "" : "none";
    $("tl-point-note").style.display = point ? "none" : "";
    $("tl-point-overlay").classList.add("open");
    ($("tl-point-title") as HTMLInputElement).focus();
  }
  function closePointDialog() {
    $("tl-point-overlay").classList.remove("open");
    editingPoint = null;
  }

  async function savePoint() {
    if (!frise) return;
    const title = fieldValue("tl-point-title").trim();
    if (!title) return showPointError("Donne un titre au point.");
    const d = parseDateFields({
      year: fieldValue("tl-point-year"),
      bc: checked("tl-point-bc"),
      month: fieldValue("tl-point-month"),
      day: fieldValue("tl-point-day"),
      circa: checked("tl-point-circa"),
    });
    if (!d.ok) return showPointError(d.error);
    const { segments } = layoutPeriods(periods);
    const dec = dateToDecimal(d.date);
    const segIdx = locateSegment(dec, segments);
    if (segIdx < 0) {
      const first = layoutPeriods(periods).sorted[0];
      const last = segments[segments.length - 1];
      const lastEnd = last.kind === "period" && last.period.end && !last.openEnded ? formatFriseDate(last.period.end) : "aujourd'hui";
      return showPointError("Cette date est en dehors de la frise (de " + formatFriseDate(first.start) + " à " + lastEnd + ").");
    }
    const session = deps.getSession();
    if (!session) return showPointError("Connexion requise.");
    const ev = {
      title,
      date_year: d.date.year,
      date_month: d.date.month,
      date_day: d.date.day,
      date_circa: d.date.circa,
    };
    ($("tl-point-save") as HTMLButtonElement).disabled = true;
    try {
      if (editingPoint) {
        const pt = editingPoint;
        const r1 = await supabase.from("timeline_events").update({ ...ev, updated_at: new Date().toISOString() }).eq("id", pt.eventId);
        if (r1.error) return showPointError("Échec : " + r1.error.message);
        const r2 = await supabase
          .from("timeline_placements")
          .update({ side: pointSide, color: pointColor })
          .eq("frise_entry_id", frise.id)
          .eq("event_id", pt.eventId);
        if (r2.error) return showPointError("Échec : " + r2.error.message);
            } else {
        // La fiche va dans le dossier où se trouve CETTE frise (pas dans celui d'une période) :
        // une sous-frise est posée dans le dossier de sa période, ses fiches y sont donc rangées.
        const secId = frise.section_id;
        const catId = frise.category_id;
        const fiche = await supabase
          .from("dossier_entries")
          .insert({
            owner_type: frise.owner_type,
            owner_id: frise.owner_id,
            type: "text",
            title,
            category_id: catId,
            section_id: secId,
            tags: [],
            sources: [],
            status: "published",
            created_by: session.user.id,
          })
          .select("id")
          .single();
        if (fiche.error || !fiche.data) return showPointError("Échec de la création de la fiche : " + (fiche.error?.message || "erreur inconnue."));
        const entryId = fiche.data.id as string;
        const evRes = await supabase
          .from("timeline_events")
          .insert({ ...ev, created_by: session.user.id })
          .select("id")
          .single();
        if (evRes.error || !evRes.data) {
          await supabase.from("dossier_entries").delete().eq("id", entryId);
          return showPointError("Échec de la création du point : " + (evRes.error?.message || "erreur inconnue."));
        }
        const eventId = evRes.data.id as string;
        const link = await supabase.from("timeline_event_fiches").insert({ entry_id: entryId, event_id: eventId, created_by: session.user.id });
        const place = link.error
          ? link
          : await supabase
              .from("timeline_placements")
              .insert({ frise_entry_id: frise.id, event_id: eventId, side: pointSide, color: pointColor, created_by: session.user.id });
        if (place.error) {
          await supabase.from("timeline_events").delete().eq("id", eventId);
          await supabase.from("dossier_entries").delete().eq("id", entryId);
          return showPointError("Échec : " + place.error.message);
        }
      }
    } finally {
      ($("tl-point-save") as HTMLButtonElement).disabled = false;
    }
    closePointDialog();
    await deps.refreshDossier();
    await reload();
  }

  async function deletePoint() {
    const pt = editingPoint;
    if (!pt || !frise) return;
    const ok = await customConfirm("Supprimer le point « " + pt.title + " » de la frise ?\nSa fiche reste dans le dossier.");
    if (!ok) return;
    const r = await supabase.from("timeline_placements").delete().eq("frise_entry_id", frise.id).eq("event_id", pt.eventId);
    if (r.error) return showPointError("Échec : " + r.error.message);
    const { data: rest } = await supabase.from("timeline_placements").select("event_id").eq("event_id", pt.eventId);
    if (!((rest as unknown[] | null) ?? []).length) await supabase.from("timeline_events").delete().eq("id", pt.eventId);
    closePointDialog();
    await reload();
  }

  // Petite carte au clic sur un point : titre, date, ouvrir la fiche, modifier.
  function openPointCard(p: Point, anchor: HTMLElement) {
    const card = $("tl-point-card");
    card.innerHTML = "";
    const h = document.createElement("strong");
    h.textContent = p.title;
    const d = document.createElement("div");
    d.className = "tl-card-date";
    d.textContent = formatFriseDate(p.date);
    card.append(h, d);
    const row = document.createElement("div");
    row.className = "tl-card-actions";
    if (p.entryId) {
      const entryId = p.entryId;
      const open = document.createElement("button");
      open.type = "button";
      open.className = "btn-small tl-primary";
      open.textContent = "Ouvrir la fiche";
      open.addEventListener("click", async () => {
        const e = await fetchEntry(entryId);
        closeView();
        deps.revealEntry(entryId, e ? e.category_id : null);
      });
      row.appendChild(open);
    }
    if (isAdmin() && p.stem != null) {
      const auto = document.createElement("button");
      auto.type = "button";
      auto.className = "btn-small";
      auto.textContent = "Hauteur auto";
      auto.addEventListener("click", async () => {
        closePointCard();
        if (!frise) return;
        await supabase.from("timeline_placements").update({ stem_length: null }).eq("frise_entry_id", frise.id).eq("event_id", p.eventId);
        await reload();
      });
      row.appendChild(auto);
    }
    if (isAdmin()) {
      const edit = document.createElement("button");
      edit.type = "button";
      edit.className = "btn-small";
      edit.textContent = "Modifier";
      edit.addEventListener("click", () => {
        closePointCard();
        openPointDialog(p);
      });
      row.appendChild(edit);
    }
    card.appendChild(row);
    card.style.display = "block";
    const r = anchor.getBoundingClientRect();
    const cw = card.offsetWidth;
    card.style.left = Math.max(8, Math.min(window.innerWidth - cw - 8, r.left)) + "px";
    const below = r.bottom + 8;
    card.style.top = (below + card.offsetHeight > window.innerHeight ? Math.max(8, r.top - card.offsetHeight - 8) : below) + "px";
  }
  function closePointCard() {
    const card = document.getElementById("tl-point-card");
    if (card) card.style.display = "none";
  }
  document.addEventListener("pointerdown", (ev) => {
    const card = document.getElementById("tl-point-card");
    if (card && card.style.display !== "none" && !card.contains(ev.target as Node) && !(ev.target as HTMLElement).closest(".tl-point")) {
      closePointCard();
    }
  });

  // --- Événements de l'interface ------------------------------------------------------------
  $("timeline-back").addEventListener("click", closeView);
  $("timeline-prev").addEventListener("click", () => {
    const prev = history.pop();
    if (prev) void openForEntry(prev);
    updatePrevButton();
  });
  $("timeline-add-period").addEventListener("click", () => requireAdminOr(() => void openPeriodDialog(null, null)));
  $("timeline-add-point").addEventListener("click", () => requireAdminOr(() => openPointDialog(null)));
  $("tl-period-cancel").addEventListener("click", closePeriodDialog);
  $("tl-period-save").addEventListener("click", () => void savePeriod());
  $("tl-period-remove").addEventListener("click", () => void removePeriod());
  $("tl-period-source").addEventListener("change", () => {
    const sel = $("tl-period-source") as HTMLSelectElement;
    const opt = sel.selectedOptions[0];
    if (opt && opt.dataset.title && !fieldValue("tl-period-name").trim()) setField("tl-period-name", opt.dataset.title);
  });
  $("tl-period-overlay").addEventListener("click", (ev) => {
    if (ev.target === $("tl-period-overlay")) closePeriodDialog();
  });
  $("tl-point-cancel").addEventListener("click", closePointDialog);
  $("tl-point-save").addEventListener("click", () => void savePoint());
  $("tl-point-delete").addEventListener("click", () => void deletePoint());
  $("tl-side-up").addEventListener("click", () => setSide("up"));
  $("tl-side-down").addEventListener("click", () => setSide("down"));
  $("tl-point-overlay").addEventListener("click", (ev) => {
    if (ev.target === $("tl-point-overlay")) closePointDialog();
  });
  window.addEventListener("resize", () => {
    if ($("timeline-view").classList.contains("open") && frise) render();
  });

  return {
    openForEntry: openFromDossier,
    closeView,
  };
}
