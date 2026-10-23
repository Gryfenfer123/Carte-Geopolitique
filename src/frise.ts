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
import { fetchPlacements } from "./friseEvents";
import { initFriseMulti } from "./friseMulti";
import {
  computeLinearWidths,
  dateSortKey,
  dateToDecimal,
  formatFriseDate,
  layoutPeriods,
  locateSegment,
  niceTicks,
  parseDateFields,
  periodFromColumns,
  segmentForDate,
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
type FriseContext = { periodName: string; from: string; to: string; start?: FriseDate; end?: FriseDate };
type Category = { id: string; name: string; color: string; position: number };
type PointFiche = {
  id: string;
  title: string | null;
  ownerType: string;
  ownerId: string;
  categoryId: string | null;
  photo: string | null;
};
type Point = {
  eventId: string;
  title: string;
  date: FriseDate;
  end: FriseDate | null; // date de fin : point "avec durée" (barre)
  side: "up" | "down";
  color: string; // couleur de la catégorie (ou ancienne couleur libre)
  categoryId: string | null;
  stem: number | null; // hauteur de la tige en px, réglée à la main (null = automatique)
  fiches: PointFiche[];
  subFriseId: string | null; // frise ouverte en cliquant sur un événement avec durée
  friseCount: number; // nombre de frises où ce point apparaît (placements multiples)
  stemEl?: HTMLElement; // élément de tige affiché (rendu courant)
};

const SECTION_COLUMNS =
  "id, title, category_id, parent_section_id, position, period_frise_id, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa, period_color, period_is_transition, transition_after_id";

const PALETTE = ["#c0392b", "#e67e22", "#d4ac0d", "#27ae60", "#16a085", "#2980b9", "#8e44ad", "#7f8c8d"];
const NO_CATEGORY = "__none__";
const DEFAULT_POINT_COLOR = "#2980b9";

function esc(s: string): string {
  return s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c] as string);
}

function rowToPeriod(r: SectionRow): Period {
  return periodFromColumns(r);
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
  // Ouvre une fiche, même d'un autre pays / groupe (dossier.ts::openLinkTarget).
  openFicheEverywhere: (f: { id: string; ownerType: string; ownerId: string; categoryId: string | null }) => Promise<void>;
  // Nom lisible du propriétaire d'une fiche (pays, groupe...).
  getOwnerLabel: (ownerType: string, ownerId: string) => string | null;
  // Pays proposés pour créer la fiche d'un autre pays.
  getCountryChoices: () => { id: string; label: string }[];
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
  let pointEls = new Map<string, HTMLElement>(); // étiquettes affichées (pour la recherche)
  let categories: Category[] = [];
  let hiddenCats = new Set<string>();
  const showDates = false; // l'affichage des dates se fait au survol (voir showHover)
  try {
    hiddenCats = new Set<string>(JSON.parse(localStorage.getItem("tl-hidden-cats") || "[]"));
  } catch {
    /* stockage indisponible : valeurs par défaut */
  }
  let zoom = 1;
  // Dialogue période / transition
  let editingPeriodId: string | null = null;
  let dialogGapAfter: string | null = null; // non nul = on édite la transition après cette période
  let periodColor: string | null = null;
  // Dialogue point
  let editingPoint: Point | null = null;
  let pointSide: "up" | "down" = "up";

  // --- DOM (construit une fois) --------------------------------------------------
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="timeline-view">
      <div id="timeline-topbar">
        <button id="timeline-back" class="btn-small">Retour au dossier</button>
        <nav id="timeline-breadcrumb" aria-label="Frises parentes"></nav>
        <div id="timeline-search-wrap">
          <input id="timeline-search" type="search" placeholder="Chercher un point…" autocomplete="off" aria-label="Chercher un point">
          <div id="timeline-search-results"></div>
        </div>
        <div id="timeline-toolbar">
          <button id="timeline-add-point" class="btn-small edit-control">&#43; Point</button>
          <button id="timeline-add-period" class="btn-small edit-control">&#43; P&eacute;riode</button>
          <button id="timeline-zoom-out" class="btn-small" aria-label="Dézoomer">&minus;</button>
          <button id="timeline-zoom-in" class="btn-small" aria-label="Zoomer">&#43;</button>
          <button id="timeline-zoom-reset" class="btn-small">Recentrer</button>
          <button id="timeline-manage-cats" class="btn-small edit-control">Cat&eacute;gories</button>
          <button id="timeline-export-img" class="btn-small" title="T&eacute;l&eacute;charger toute la frise en image">Image</button>
        </div>
      </div>
      <div id="timeline-subbar">
        <button id="timeline-prev" class="btn-small" style="display:none;" aria-label="Frise mère" title="Revenir à la frise mère">&larr; <span id="timeline-prev-label"></span></button>
        <div id="timeline-subtitle"></div>
      </div>
      <div id="timeline-legend"></div>
      <div id="timeline-scroll">
        <div id="timeline-stage"></div>
        <p id="timeline-empty-hint" class="muted" style="display:none;"></p>
      </div>
      <div id="tl-point-card" role="dialog" style="display:none;"></div>
      <div id="tl-hover-card" style="display:none;"></div>
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
          <legend id="tl-point-start-legend">Date</legend>
          <input type="text" inputmode="numeric" id="tl-point-year" placeholder="Ann&eacute;e" aria-label="Ann&eacute;e">
          <label class="tl-inline"><input type="checkbox" id="tl-point-bc"> av. J.-C.</label>
          <input type="text" inputmode="numeric" id="tl-point-month" placeholder="Mois" aria-label="Mois">
          <input type="text" inputmode="numeric" id="tl-point-day" placeholder="Jour" aria-label="Jour">
          <label class="tl-inline"><input type="checkbox" id="tl-point-circa"> vers</label>
        </fieldset>
        <label class="tl-inline tl-end-toggle"><input type="checkbox" id="tl-point-duration"> Avec dur&eacute;e (barre entre deux dates)</label>
        <fieldset class="tl-date" id="tl-point-end-fields" style="display:none;">
          <legend>Date de fin</legend>
          <input type="text" inputmode="numeric" id="tl-pend-year" placeholder="Ann&eacute;e" aria-label="Ann&eacute;e de fin">
          <label class="tl-inline"><input type="checkbox" id="tl-pend-bc"> av. J.-C.</label>
          <input type="text" inputmode="numeric" id="tl-pend-month" placeholder="Mois" aria-label="Mois de fin">
          <input type="text" inputmode="numeric" id="tl-pend-day" placeholder="Jour" aria-label="Jour de fin">
          <label class="tl-inline"><input type="checkbox" id="tl-pend-circa"> vers</label>
        </fieldset>
        <div class="tl-field">Cat&eacute;gorie
          <div class="tl-catpick" id="tl-point-categories"></div>
        </div>
        <div class="tl-field">Position
          <div class="tl-sides">
            <button type="button" class="btn-small" id="tl-side-up">&uarr; Au-dessus</button>
            <button type="button" class="btn-small" id="tl-side-down">&darr; En dessous</button>
          </div>
        </div>
        <div class="tl-field" id="tl-point-fiche-block">Fiche
          <label class="tl-inline"><input type="radio" name="tl-fiche-mode" id="tl-fiche-new" checked> Cr&eacute;er une fiche vide (rang&eacute;e dans la p&eacute;riode du point)</label>
          <label class="tl-inline"><input type="radio" name="tl-fiche-mode" id="tl-fiche-link"> Relier une fiche existante</label>
          <div id="tl-fiche-search-block" style="display:none;">
            <input type="text" id="tl-fiche-search" placeholder="Chercher une fiche par titre…" autocomplete="off">
            <div id="tl-fiche-results" class="tl-results"></div>
            <div id="tl-fiche-chosen" class="tl-note"></div>
          </div>
        </div>
        <p id="tl-point-error" class="tl-error" role="alert"></p>
        <div class="tl-actions">
          <button type="button" class="btn-small" id="tl-point-delete">Supprimer le point</button>
          <span class="tl-spacer"></span>
          <button type="button" class="btn-small" id="tl-point-cancel">Annuler</button>
          <button type="button" class="btn-small tl-primary" id="tl-point-save">Enregistrer</button>
        </div>
      </div>
    </div>

    <div id="tl-cat-overlay">
      <div id="tl-cat-box" role="dialog" aria-modal="true">
        <h3>Cat&eacute;gories de points</h3>
        <p class="tl-note">Chaque cat&eacute;gorie a une couleur fixe. Elles servent &agrave; colorer les points et &agrave; filtrer la l&eacute;gende.</p>
        <div id="tl-cat-list"></div>
        <button type="button" class="btn-small" id="tl-cat-add">&#43; Ajouter une cat&eacute;gorie</button>
        <p id="tl-cat-error" class="tl-error" role="alert"></p>
        <div class="tl-actions">
          <span class="tl-spacer"></span>
          <button type="button" class="btn-small" id="tl-cat-cancel">Annuler</button>
          <button type="button" class="btn-small tl-primary" id="tl-cat-save">Enregistrer</button>
        </div>
      </div>
    </div>

    <div id="tl-fiches-overlay">
      <div id="tl-fiches-box" role="dialog" aria-modal="true">
        <h3 id="tl-fiches-heading">Fiches de l'&eacute;v&eacute;nement</h3>
        <div id="tl-fiches-list"></div>
        <div id="tl-fiches-admin">
          <div class="tl-field">Relier une fiche existante
            <input type="text" id="tl-fiches-search" placeholder="Chercher une fiche par titre…" autocomplete="off">
            <div id="tl-fiches-results" class="tl-results"></div>
          </div>
          <div class="tl-field">Cr&eacute;er la fiche d'un autre pays
            <div class="tl-sides">
              <select id="tl-fiches-country"></select>
              <button type="button" class="btn-small" id="tl-fiches-create">Cr&eacute;er sa fiche</button>
            </div>
          </div>
        </div>
        <p id="tl-fiches-error" class="tl-error" role="alert"></p>
        <div class="tl-actions">
          <span class="tl-spacer"></span>
          <button type="button" class="btn-small" id="tl-fiches-close">Fermer</button>
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

  async function fetchCategories(): Promise<Category[]> {
    const { data } = await supabase.from("timeline_categories").select("id, name, color, position").order("position", { ascending: true });
    return (data as Category[] | null) ?? [];
  }

  type EventRow = {
    id: string;
    title: string;
    date_year: number;
    date_month: number | null;
    date_day: number | null;
    date_circa: boolean;
    date_end_year: number | null;
    date_end_month: number | null;
    date_end_day: number | null;
    date_end_circa: boolean | null;
    sub_frise_entry_id: string | null;
  };
  const EVENT_COLUMNS =
    "id, title, date_year, date_month, date_day, date_circa, date_end_year, date_end_month, date_end_day, date_end_circa, sub_frise_entry_id";

  async function loadPoints(friseId: string): Promise<Point[]> {
    const { data: pl } = await supabase
      .from("timeline_placements")
      .select("event_id, side, color, stem_length, category_id")
      .eq("frise_entry_id", friseId);
    const placements =
      (pl as { event_id: string; side: string | null; color: string | null; stem_length: number | null; category_id: string | null }[] | null) ?? [];
    if (!placements.length) return [];
    const ids = placements.map((p) => p.event_id);
    const { data: ev } = await supabase.from("timeline_events").select(EVENT_COLUMNS).in("id", ids);
    const { data: fi } = await supabase.from("timeline_event_fiches").select("entry_id, event_id").in("event_id", ids);
    const links = (fi as { entry_id: string; event_id: string }[] | null) ?? [];
    const entryInfo = new Map<string, PointFiche>();
    if (links.length) {
      const { data: en } = await supabase
        .from("dossier_entries")
        .select("id, title, owner_type, owner_id, category_id, photo_url")
        .in("id", links.map((l) => l.entry_id));
      for (const e of (en as { id: string; title: string | null; owner_type: string; owner_id: string; category_id: string | null; photo_url: string | null }[] | null) ?? []) {
        entryInfo.set(e.id, { id: e.id, title: e.title, ownerType: e.owner_type, ownerId: e.owner_id, categoryId: e.category_id, photo: e.photo_url });
      }
    }
    // Nombre de frises où apparaît chaque point (un même événement peut être placé sur plusieurs frises).
    const { data: allPl } = await supabase.from("timeline_placements").select("event_id").in("event_id", ids);
    const friseCounts = new Map<string, number>();
    for (const r of (allPl as { event_id: string }[] | null) ?? []) friseCounts.set(r.event_id, (friseCounts.get(r.event_id) ?? 0) + 1);
    const out: Point[] = [];
    for (const e of (ev as EventRow[] | null) ?? []) {
      const p = placements.find((x) => x.event_id === e.id);
      const cat = categories.find((c) => c.id === p?.category_id);
      out.push({
        eventId: e.id,
        title: e.title,
        date: { year: e.date_year, month: e.date_month, day: e.date_day, circa: !!e.date_circa },
        end:
          e.date_end_year != null
            ? { year: e.date_end_year, month: e.date_end_month, day: e.date_end_day, circa: !!e.date_end_circa }
            : null,
        side: p?.side === "up" ? "up" : "down",
        color: cat?.color || p?.color || DEFAULT_POINT_COLOR,
        categoryId: cat ? cat.id : null,
        stem: p?.stem_length ?? null,
        fiches: links.filter((l) => l.event_id === e.id).map((l) => entryInfo.get(l.entry_id)).filter((x): x is PointFiche => !!x),
        subFriseId: e.sub_frise_entry_id,
        friseCount: friseCounts.get(e.id) ?? 1,
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
    categories = await fetchCategories();
    const pts = await loadPoints(entry.id);

    // Ancêtres : la frise parente, soit parce que celle-ci est posée dans une période / transition
    // d'une frise, soit parce qu'elle est la sous-frise d'un événement avec durée.
    const chain: Ancestor[] = [];
    let ctx: FriseContext | null = null;
    let evBounds: { eventId: string } | null = null;
    let cur: FriseEntry = entry;
    for (let depth = 0; depth < 12; depth++) {
      let parent: FriseEntry | null = null;
      const sec = cur.section_id ? await fetchSection(cur.section_id) : null;
      if (sec && sec.period_frise_id) {
        parent = await fetchEntry(sec.period_frise_id);
        if (parent && depth === 0) {
          const sibRows = (await fetchSectionRows(parent.id)).filter((r) => !r.period_is_transition);
          const { segments } = layoutPeriods(sibRows.map(rowToPeriod));
          const idx = sec.period_is_transition
            ? segments.findIndex((s) => s.kind === "gap" && s.afterPeriodId === sec.transition_after_id)
            : segments.findIndex((s) => s.kind === "period" && s.period.id === sec.id);
          ctx = idx >= 0 ? describeBounds(segments, idx, sec.title) : { periodName: sec.title, from: "", to: "" };
        }
      } else {
        const { data: evs } = await supabase.from("timeline_events").select(EVENT_COLUMNS).eq("sub_frise_entry_id", cur.id);
        const ev = ((evs as EventRow[] | null) ?? [])[0];
        if (ev) {
          const { data: pls } = await supabase.from("timeline_placements").select("frise_entry_id").eq("event_id", ev.id);
          const parentId = ((pls as { frise_entry_id: string }[] | null) ?? [])[0]?.frise_entry_id;
          parent = parentId ? await fetchEntry(parentId) : null;
          if (parent && depth === 0) {
            const start: FriseDate = { year: ev.date_year, month: ev.date_month, day: ev.date_day, circa: !!ev.date_circa };
            const end: FriseDate | null =
              ev.date_end_year != null
                ? { year: ev.date_end_year, month: ev.date_end_month, day: ev.date_end_day, circa: !!ev.date_end_circa }
                : null;
            ctx = {
              periodName: ev.title,
              from: formatFriseDate(start),
              to: end ? formatFriseDate(end) : "",
              start,
              end: end ?? start,
            };
            evBounds = { eventId: ev.id };
          }
        }
      }
      if (!parent) break;
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
    void evBounds;
    return true;
  }

  function describeBounds(segments: Segment[], index: number, name: string): FriseContext {
    const seg = segments[index];
    const prev = segments[index - 1];
    const next = segments[index + 1];
    if (seg.kind === "gap") {
      const start = prev && prev.kind === "period" && prev.period.end ? prev.period.end : undefined;
      const end = next && next.kind === "period" ? next.period.start : undefined;
      return { periodName: name, from: start ? formatFriseDate(start) : "", to: end ? formatFriseDate(end) : "", start, end };
    }
    const p = seg.period;
    let end: FriseDate | undefined;
    if (p.end && !seg.openEnded) end = p.end;
    else if (next && next.kind === "period") end = next.period.start;
    else end = { year: new Date().getFullYear(), month: null, day: null, circa: false };
    const to = p.end && !seg.openEnded ? formatFriseDate(p.end) : next && next.kind === "period" ? formatFriseDate(next.period.start) : "aujourd'hui";
    return { periodName: name, from: formatFriseDate(p.start), to, start: p.start, end };
  }

  // --- Rendu -----------------------------------------------------------------------
  const STEM_BASE = 26;
  const STEM_STEP = 30;
  const LABEL_PAD = 14;

  // Les points dont la hauteur est réglée à la main gardent leur hauteur ; les autres
  // sont rangés automatiquement en branches empilées (niveaux).
  const RULER_H = 26;
  type Placed = { p: Point; x: number; x2: number; len: number; w: number };
  function pointLabel(p: Point): string {
    return showDates ? formatFriseDate(p.date) + (p.end ? " → " + formatFriseDate(p.end) : "") + " · " + p.title : p.title;
  }
  function placeSide(items: { p: Point; x: number; x2: number }[], side: "up" | "down"): Placed[] {
    const base = STEM_BASE + (side === "down" ? RULER_H : 0);
    const sorted = [...items].sort((a, b) => a.x - b.x || dateSortKey(a.p.date) - dateSortKey(b.p.date));
    const lastRight: number[] = [];
    const out: Placed[] = [];
    for (const it of sorted) {
      const w = Math.min(textWidth(pointLabel(it.p)) + LABEL_PAD, 300);
      if (it.p.stem != null) {
        out.push({ p: it.p, x: it.x, x2: it.x2, len: it.p.stem, w });
        continue;
      }
      // Une durée : l'étiquette est centrée sur la barre ; sinon elle part du point.
      const left = it.p.end ? Math.min(it.x, (it.x + it.x2) / 2 - w / 2) : it.x;
      const right = it.p.end ? Math.max(it.x2, (it.x + it.x2) / 2 + w / 2) : it.x + 6 + w;
      let level = 0;
      while (level < lastRight.length && lastRight[level] > left - 2) level++;
      lastRight[level] = Math.max(it.x2, right);
      out.push({ p: it.p, x: it.x, x2: it.x2, len: base + level * STEM_STEP, w });
    }
    return out;
  }

  // Période "virtuelle" : une sous-frise sans période propre affiche la période (ou la durée)
  // dont elle dépend comme bande unique, pour pouvoir y poser des points tout de suite.
  function effectivePeriods(): Period[] {
    if (!context || !context.start || !context.end) return periods;
    // Sous-frise d'un événement avec durée (ex. « Guerre » 500 → 700) : la frise couvre
    // toujours toute la durée. Les périodes créées dedans se posent sur la durée, et les
    // parties non couvertes restent affichées au nom de l'événement (période virtuelle).
    const from = context.start;
    const to = context.end;
    const toKey = dateSortKey(to);
    const real = [...periods].sort((a, b) => dateSortKey(a.start) - dateSortKey(b.start));
    const out: Period[] = [...periods];
    let cursor = from;
    let n = 0;
    const filler = (a: FriseDate, b: FriseDate) =>
      out.push({ id: VIRTUAL_ID + ":" + n++, name: context!.periodName, start: a, end: b, color: null });
    for (const p of real) {
      if (dateSortKey(p.start) > dateSortKey(cursor) && dateSortKey(p.start) <= toKey) filler(cursor, p.start);
      const pEnd = p.end ?? p.start;
      if (dateSortKey(pEnd) > dateSortKey(cursor)) cursor = pEnd;
    }
    if (dateSortKey(cursor) < toKey) filler(cursor, to);
    // Durée sans épaisseur (début = fin) et aucune période : une seule bande, comme avant.
    if (!out.length) out.push({ id: VIRTUAL_ID, name: context.periodName, start: from, end: to, color: null });
    return out;
  }
  const VIRTUAL_ID = "__virtual__";

  // Échelle adaptative : chaque segment garde une échelle linéaire interne (donc des
  // graduations exactes), mais s'élargit tant qu'il contient de nombreux points ou des
  // dates très proches, pour que les étiquettes restent lisibles. Tous les points comptent,
  // filtrés ou non, pour que la mise en page ne bouge pas quand on masque une catégorie.
  function adaptiveWidths(segments: Segment[], totalPx: number): number[] {
    const lin = computeLinearWidths(segments, totalPx);
    const perSeg: number[][] = segments.map(() => []);
    for (const p of points) {
      const dec = dateToDecimal(p.date);
      const i = locateSegment(dec, segments);
      if (i >= 0) perSeg[i].push(dec);
    }
    return segments.map((seg, i) => {
      const decs = perSeg[i].sort((a, b) => a - b);
      if (!decs.length) return lin[i];
      const span = Math.max(seg.endDec - seg.startDec, 1e-6);
      let need = decs.length * 120;
      for (let k = 1; k < decs.length; k++) {
        const gap = Math.max(decs[k] - decs[k - 1], span * 0.002);
        need = Math.max(need, Math.min(decs.length * 260, (70 / gap) * span));
      }
      return Math.max(lin[i], need * zoom);
    });
  }

  function render() {
    if (!frise) return;
    const admin = isAdmin();
    document.body.classList.toggle("tl-can-edit", admin);
    closePointCard();
    hideHover();

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

    updatePrevButton();
    $("timeline-subbar").style.display = ancestors.length || context ? "flex" : "none";
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
    const eff = effectivePeriods();
    if (!eff.length) {
      hint.style.display = "";
      hint.textContent = admin
        ? "Cette frise n'a pas encore de période. Utilise « + Période » : chaque période devient une sous-catégorie du dossier."
        : "Cette frise n'a pas encore de période.";
      return;
    }
    hint.style.display = "none";

    const { segments, issues } = layoutPeriods(eff);
    const scroll = $("timeline-scroll");
    const baseWidth = Math.max(scroll.clientWidth - 200, 320);
    const widths = adaptiveWidths(segments, baseWidth * zoom);
    const total = widths.reduce((s, w) => s + w, 0);

    // Points : position x, niveaux (branches empilées) de chaque côté ; la légende filtre par catégorie.
    renderLegend();
    const placedItems: { p: Point; x: number; x2: number }[] = [];
    let outside = 0;
    for (const p of points) {
      if (hiddenCats.has(p.categoryId ?? NO_CATEGORY)) continue;
      const x = xForDecimal(dateToDecimal(p.date), segments, widths);
      if (x === null) {
        outside++;
        continue;
      }
      const x2 = p.end ? (xForDecimal(dateToDecimal(p.end), segments, widths) ?? x) : x;
      placedItems.push({ p, x, x2: Math.max(x, x2) });
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
      const isVirtual = seg.kind === "period" && seg.period.id.startsWith(VIRTUAL_ID);
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
      if (admin && !isVirtual) {
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
      const go = () => {
        if (!isVirtual) void onCellActivate(seg);
      };
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

    // Règle graduée : échelle constante À L'INTÉRIEUR de chaque période (pixels par année).
    const ruler = document.createElement("div");
    ruler.className = "tl-ruler";
    let segX = 0;
    segments.forEach((seg, i) => {
      const w = widths[i];
      const ppy = w / Math.max(seg.endDec - seg.startDec, 1e-6);
      for (const t of niceTicks(seg.startDec, seg.endDec, ppy)) {
        if (i < segments.length - 1 && t.dec >= seg.endDec - 1e-9) continue;
        const x = segX + ((t.dec - seg.startDec) / Math.max(seg.endDec - seg.startDec, 1e-6)) * w;
        const tick = document.createElement("span");
        tick.className = "tl-tick" + (t.month === 1 ? " year" : "");
        tick.style.left = x + "px";
        const lab = document.createElement("span");
        lab.className = "tl-tick-label";
        lab.textContent = t.label;
        tick.appendChild(lab);
        ruler.appendChild(tick);
      }
      segX += w;
    });
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
    pointEls = new Map();
    type Parts = { stem: HTMLElement; stem2: HTMLElement | null; bar: HTMLElement | null };
    const parts = new Map<string, Parts>();
    const drawSide = (list: Placed[], side: "up" | "down") => {
      [...list].sort((a, b) => b.len - a.len).forEach((it) => {
        const stem = document.createElement("span");
        stem.className = "tl-stem";
        stem.style.left = it.x - 1 + "px";
        stem.style.background = it.p.color;
        layer.appendChild(stem);
        let stem2: HTMLElement | null = null;
        let bar: HTMLElement | null = null;
        if (it.p.end) {
          if (it.x2 - it.x > 12) {
            stem2 = document.createElement("span");
            stem2.className = "tl-stem tl-stem-end";
            stem2.style.left = it.x2 - 1 + "px";
            stem2.style.background = it.p.color;
            layer.appendChild(stem2);
          }
          bar = document.createElement("span");
          bar.className = "tl-bar";
          bar.style.left = it.x + "px";
          bar.style.width = Math.max(it.x2 - it.x, 6) + "px";
          bar.style.background = it.p.color;
          layer.appendChild(bar);
        }
        parts.set(it.p.eventId, { stem, stem2, bar });
      });
      list.forEach((it) => {
        const pt = it.p;
        const pr = parts.get(pt.eventId) as Parts;
        const lab = document.createElement("button");
        lab.type = "button";
        lab.className = "tl-point" + (admin ? " movable" : "") + (pt.end ? " is-duration" : "") + (pt.subFriseId ? " has-sub" : "");
        lab.textContent = pointLabel(pt) + (pt.subFriseId ? "  ›" : "");
        lab.style.left = (pt.end ? (it.x + it.x2) / 2 : it.x + 3) + "px";
        lab.style.maxWidth = "300px";
        lab.style.borderColor = pt.color;
        layer.appendChild(lab);
        pointEls.set(pt.eventId, lab);
        const dot = document.createElement("span");
        dot.className = "tl-dot";
        dot.style.left = it.x + "px";
        dot.style.background = pt.color;
        layer.appendChild(dot);
        const place = (s: "up" | "down", len: number) => {
          const stemTop = s === "up" ? upH - len : upH + BAND_H;
          const centerY = s === "up" ? stemTop : stemTop + len;
          pr.stem.style.top = stemTop + "px";
          pr.stem.style.height = len + "px";
          if (pr.stem2) {
            pr.stem2.style.top = stemTop + "px";
            pr.stem2.style.height = len + "px";
          }
          if (pr.bar) pr.bar.style.top = centerY - 4 + "px";
          // Une durée : la barre est à la hauteur de la tige, l'étiquette juste au-dessus.
          lab.style.top = (pt.end ? centerY - 18 : centerY) + "px";
          dot.style.top = centerY + "px";
        };
        place(side, it.len);

        // Survol : petit volet (dates, catégorie, image de la fiche).
        const hoverTargets = [lab, ...(pr.bar ? [pr.bar] : [])];
        for (const el of hoverTargets) {
          el.addEventListener("mouseenter", () => showHover(pt, lab));
          el.addEventListener("mouseleave", hideHover);
          el.addEventListener("click", (ev) => {
            ev.stopPropagation();
            if (suppressPointClick) return;
            hideHover();
            openPointCard(pt, lab);
          });
        }
        if (pr.bar) pr.bar.style.cursor = "pointer";

        // Hauteur à la main : on glisse le point verticalement (jamais horizontalement,
        // la date ne change pas). Passer de l'autre côté de la bande le fait changer de côté.
        let press: { moved: boolean; side: "up" | "down"; len: number } | null = null;
        lab.addEventListener("pointerdown", (ev) => {
          if (!admin || ev.button !== 0) return;
          ev.stopPropagation();
          lab.setPointerCapture(ev.pointerId);
          press = { moved: false, side: side, len: it.len };
          closePointCard();
          hideHover();
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
          const pressed = press;
          press = null;
          lab.classList.remove("dragging");
          if (!pressed || !pressed.moved || !frise) return;
          suppressPointClick = true;
          setTimeout(() => (suppressPointClick = false), 0);
          const { error } = await supabase
            .from("timeline_placements")
            .update({ side: pressed.side, stem_length: pressed.len })
            .eq("frise_entry_id", frise.id)
            .eq("event_id", pt.eventId);
          if (error) deps.showBanner?.("Échec de l'enregistrement de la hauteur : " + error.message);
          await reload();
        };
        lab.addEventListener("pointerup", () => void finish());
        lab.addEventListener("pointercancel", () => void finish());
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
  // parente reste accessible par la flèche sous le titre.
  async function goTo(entryId: string) {
    await openForEntry(entryId);
  }
  // Flèche vers la frise mère : disponible dès qu'on arrive dans une sous-frise, quelle que
  // soit la façon dont on y est arrivé (depuis le dossier, une période, un point...).
  function updatePrevButton() {
    const parent = ancestors[ancestors.length - 1];
    const btn = $("timeline-prev");
    btn.style.display = parent ? "" : "none";
    $("timeline-prev-label").textContent = parent ? parent.title : "";
  }

  async function openFromDossier(entryId: string) {
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
    hideHover();
    closePeriodDialog();
    closePointDialog();
    closePointCard();
    document.body.classList.remove("tl-can-edit");
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

  // --- Légende et filtres par catégorie ----------------------------------------------------
  function saveFilters() {
    try {
      localStorage.setItem("tl-hidden-cats", JSON.stringify([...hiddenCats]));
    } catch {
      /* ignoré */
    }
  }
  function categoryName(id: string | null): string {
    return categories.find((c) => c.id === id)?.name ?? "Sans catégorie";
  }
  function renderLegend() {
    const box = $("timeline-legend");
    box.innerHTML = "";
    const present = new Map<string, { name: string; color: string; pos: number }>();
    for (const p of points) {
      const key = p.categoryId ?? NO_CATEGORY;
      if (present.has(key)) continue;
      const cat = categories.find((c) => c.id === p.categoryId);
      present.set(key, { name: cat ? cat.name : "Sans catégorie", color: cat ? cat.color : p.color, pos: cat ? cat.position : 9999 });
    }
    if (!present.size) {
      box.style.display = "none";
      return;
    }
    box.style.display = "";
    [...present.entries()]
      .sort((a, b) => a[1].pos - b[1].pos)
      .forEach(([key, info]) => {
        const chip = document.createElement("button");
        chip.type = "button";
        chip.className = "tl-legend-chip" + (hiddenCats.has(key) ? " off" : "");
        chip.title = hiddenCats.has(key) ? "Afficher cette catégorie" : "Masquer cette catégorie";
        const dot = document.createElement("span");
        dot.className = "tl-legend-dot";
        dot.style.background = info.color;
        chip.append(dot, document.createTextNode(info.name));
        chip.addEventListener("click", () => {
          if (hiddenCats.has(key)) hiddenCats.delete(key);
          else hiddenCats.add(key);
          saveFilters();
          render();
        });
        box.appendChild(chip);
      });
    if ([...present.keys()].some((k) => hiddenCats.has(k))) {
      const all = document.createElement("button");
      all.type = "button";
      all.className = "tl-legend-all";
      all.textContent = "Tout afficher";
      all.addEventListener("click", () => {
        for (const k of present.keys()) hiddenCats.delete(k);
        saveFilters();
        render();
      });
      box.appendChild(all);
    }
  }

  // --- Volet au survol -------------------------------------------------------------------------
  let hoverTimer: number | null = null;
  function hideHover() {
    if (hoverTimer) window.clearTimeout(hoverTimer);
    hoverTimer = null;
    const card = document.getElementById("tl-hover-card");
    if (card) card.style.display = "none";
  }
  function dateRangeText(p: Point): string {
    return formatFriseDate(p.date) + (p.end ? " → " + formatFriseDate(p.end) : "");
  }
  function showHover(p: Point, anchor: HTMLElement) {
    if (drag && drag.moved) return;
    if (hoverTimer) window.clearTimeout(hoverTimer);
    hoverTimer = window.setTimeout(() => {
      if (!anchor.isConnected || !anchor.matches(":hover")) return;
      const card = $("tl-hover-card");
      if ($("tl-point-card").style.display !== "none") return;
      card.innerHTML = "";
      const photo = p.fiches.find((f) => f.photo)?.photo;
      if (photo) {
        const img = document.createElement("img");
        img.src = photo;
        img.alt = "";
        card.appendChild(img);
      }
      const body = document.createElement("div");
      body.className = "tl-hover-body";
      const t = document.createElement("strong");
      t.textContent = p.title;
      const d = document.createElement("div");
      d.className = "tl-card-date";
      d.textContent = dateRangeText(p);
      body.append(t, d);
      const cat = document.createElement("div");
      cat.className = "tl-hover-cat";
      const dot = document.createElement("span");
      dot.className = "tl-legend-dot";
      dot.style.background = p.color;
      cat.append(dot, document.createTextNode(categoryName(p.categoryId)));
      body.appendChild(cat);
      if (p.fiches.length > 1) {
        const n = document.createElement("div");
        n.className = "tl-card-date";
        n.textContent = p.fiches.length + " fiches (plusieurs pays)";
        body.appendChild(n);
      }
      card.appendChild(body);
      card.style.display = "block";
      const r = anchor.getBoundingClientRect();
      const cw = card.offsetWidth;
      const ch = card.offsetHeight;
      card.style.left = Math.max(8, Math.min(window.innerWidth - cw - 8, r.left)) + "px";
      const below = r.bottom + 8;
      card.style.top = (below + ch > window.innerHeight ? Math.max(8, r.top - ch - 8) : below) + "px";
    }, 220);
  }

  // --- Points ------------------------------------------------------------------------------------
  let pointCategoryId: string | null = null;
  let chosenFiche: PointFiche | null = null;

  function showPointError(msg: string) {
    $("tl-point-error").textContent = msg;
  }
  function setSide(side: "up" | "down") {
    pointSide = side;
    $("tl-side-up").classList.toggle("tl-primary", side === "up");
    $("tl-side-down").classList.toggle("tl-primary", side === "down");
  }
  function renderCategoryPicker() {
    const box = $("tl-point-categories");
    box.innerHTML = "";
    const choices: { id: string | null; name: string; color: string }[] = [
      ...categories.map((c) => ({ id: c.id, name: c.name, color: c.color })),
      { id: null, name: "Sans catégorie", color: DEFAULT_POINT_COLOR },
    ];
    for (const c of choices) {
      const b = document.createElement("button");
      b.type = "button";
      b.className = "tl-catchip" + (pointCategoryId === c.id ? " selected" : "");
      const dot = document.createElement("span");
      dot.className = "tl-legend-dot";
      dot.style.background = c.color;
      b.append(dot, document.createTextNode(c.name));
      b.addEventListener("click", () => {
        pointCategoryId = c.id;
        renderCategoryPicker();
      });
      box.appendChild(b);
    }
  }
  function syncDurationFields() {
    $("tl-point-end-fields").style.display = checked("tl-point-duration") ? "" : "none";
    $("tl-point-start-legend").textContent = checked("tl-point-duration") ? "Début" : "Date";
  }
  function syncFicheMode() {
    $("tl-fiche-search-block").style.display = checked("tl-fiche-link") ? "" : "none";
  }

  function openPointDialog(point: Point | null) {
    if (!frise) return;
    if (!effectivePeriods().length) {
      deps.showBanner?.("Crée d'abord au moins une période : les points se posent sur la bande.");
      return;
    }
    editingPoint = point;
    showPointError("");
    $("tl-point-heading").textContent = point ? "Modifier le point" : "Nouveau point";
    setField("tl-point-title", point ? point.title : "");
    fillDate("tl-point", point ? point.date : null);
    fillDate("tl-pend", point ? point.end : null);
    setChecked("tl-point-duration", !!point?.end);
    syncDurationFields();
    setSide(point ? point.side : "up");
    pointCategoryId = point ? point.categoryId : (categories[0]?.id ?? null);
    renderCategoryPicker();
    chosenFiche = null;
    setChecked("tl-fiche-new", true);
    setChecked("tl-fiche-link", false);
    setField("tl-fiche-search", "");
    $("tl-fiche-results").innerHTML = "";
    $("tl-fiche-chosen").textContent = "";
    syncFicheMode();
    $("tl-point-fiche-block").style.display = point ? "none" : "";
    $("tl-point-delete").style.display = point ? "" : "none";
    $("tl-point-overlay").classList.add("open");
    ($("tl-point-title") as HTMLInputElement).focus();
  }
  function closePointDialog() {
    $("tl-point-overlay").classList.remove("open");
    editingPoint = null;
  }

  // Recherche de fiches (texte) dans tous les dossiers, par titre.
  async function searchFiches(query: string): Promise<PointFiche[]> {
    const q = query.trim().replace(/[%,]/g, " ");
    if (q.length < 2) return [];
    const { data } = await supabase
      .from("dossier_entries")
      .select("id, title, owner_type, owner_id, category_id, photo_url")
      .eq("type", "text")
      .ilike("title", "%" + q + "%")
      .limit(12);
    return (
      (data as { id: string; title: string | null; owner_type: string; owner_id: string; category_id: string | null; photo_url: string | null }[] | null) ?? []
    ).map((e) => ({ id: e.id, title: e.title, ownerType: e.owner_type, ownerId: e.owner_id, categoryId: e.category_id, photo: e.photo_url }));
  }
  function ficheLabel(f: PointFiche): string {
    const owner = deps.getOwnerLabel(f.ownerType, f.ownerId);
    return (f.title || "Sans titre") + (owner ? " — " + owner : "");
  }
  function renderFicheResults(box: HTMLElement, list: PointFiche[], onPick: (f: PointFiche) => void) {
    box.innerHTML = "";
    if (!list.length) return;
    for (const f of list) {
      const b = document.createElement("button");
      b.type = "button";
      b.className = "tl-result";
      b.textContent = ficheLabel(f);
      b.addEventListener("click", () => onPick(f));
      box.appendChild(b);
    }
  }
  async function ficheAlreadyLinked(entryId: string): Promise<string | null> {
    const { data } = await supabase.from("timeline_event_fiches").select("event_id").eq("entry_id", entryId).maybeSingle();
    return (data as { event_id: string } | null)?.event_id ?? null;
  }

  async function savePoint() {
    if (!frise) return;
    const title = fieldValue("tl-point-title").trim();
    if (!title) return showPointError("Donne un titre au point.");
    const d = readDate("tl-point");
    if (!d.ok) return showPointError(d.error);
    let endDate: FriseDate | null = null;
    if (checked("tl-point-duration")) {
      const e = readDate("tl-pend");
      if (!e.ok) return showPointError("Fin : " + e.error);
      if (dateSortKey(e.date) < dateSortKey(d.date)) return showPointError("La fin ne peut pas être avant le début.");
      endDate = e.date;
    }
    const { segments, sorted } = layoutPeriods(effectivePeriods());
    const outOfBounds = (dt: FriseDate) => locateSegment(dateToDecimal(dt), segments) < 0;
    if (outOfBounds(d.date) || (endDate && outOfBounds(endDate))) {
      const last = segments[segments.length - 1];
      const lastEnd = last && last.kind === "period" && last.period.end && !last.openEnded ? formatFriseDate(last.period.end) : "aujourd'hui";
      return showPointError("Cette date est en dehors de la frise (de " + formatFriseDate(sorted[0].start) + " à " + lastEnd + ").");
    }
    const session = deps.getSession();
    if (!session) return showPointError("Connexion requise.");
    const cat = categories.find((c) => c.id === pointCategoryId) ?? null;
    const color = cat ? cat.color : DEFAULT_POINT_COLOR;
    const ev = {
      title,
      date_year: d.date.year,
      date_month: d.date.month,
      date_day: d.date.day,
      date_circa: d.date.circa,
      date_end_year: endDate ? endDate.year : null,
      date_end_month: endDate ? endDate.month : null,
      date_end_day: endDate ? endDate.day : null,
      date_end_circa: endDate ? endDate.circa : false,
    };
    ($("tl-point-save") as HTMLButtonElement).disabled = true;
    try {
      if (editingPoint) {
        const pt = editingPoint;
        const r1 = await supabase.from("timeline_events").update({ ...ev, updated_at: new Date().toISOString() }).eq("id", pt.eventId);
        if (r1.error) return showPointError("Échec : " + r1.error.message);
        const r2 = await supabase
          .from("timeline_placements")
          .update({ side: pointSide, color, category_id: cat ? cat.id : null })
          .eq("frise_entry_id", frise.id)
          .eq("event_id", pt.eventId);
        if (r2.error) return showPointError("Échec : " + r2.error.message);
      } else {
        const linking = checked("tl-fiche-link");
        let entryId: string;
        let createdFiche = false;
        if (linking) {
          if (!chosenFiche) return showPointError("Choisis la fiche à relier (ou crée une fiche vide).");
          const other = await ficheAlreadyLinked(chosenFiche.id);
          if (other) return showPointError("Cette fiche est déjà reliée à un autre événement.");
          entryId = chosenFiche.id;
        } else {
          // Spec §4 : la fiche se range dans la sous-catégorie de la PÉRIODE qui contient la date
          // du point. Sans période propre (sous-frise sans découpage), elle va dans le dossier où
          // se trouve cette frise : une sous-frise est posée dans le dossier de sa période.
          const seg = periods.length ? segmentForDate(periods, d.date) : null;
          const periodRow = seg
            ? seg.kind === "period"
              ? periodRows.find((r) => r.id === seg.period.id)
              : transitionRows.find((r) => r.transition_after_id === seg.afterPeriodId)
            : undefined;
          const fiche = await supabase
            .from("dossier_entries")
            .insert({
              owner_type: frise.owner_type,
              owner_id: frise.owner_id,
              type: "text",
              title,
              category_id: periodRow ? periodRow.category_id : frise.category_id,
              section_id: periodRow ? periodRow.id : frise.section_id,
              tags: [],
              sources: [],
              status: "published",
              created_by: session.user.id,
            })
            .select("id")
            .single();
          if (fiche.error || !fiche.data) return showPointError("Échec de la création de la fiche : " + (fiche.error?.message || "erreur inconnue."));
          entryId = fiche.data.id as string;
          createdFiche = true;
        }
        const evRes = await supabase.from("timeline_events").insert({ ...ev, created_by: session.user.id }).select("id").single();
        if (evRes.error || !evRes.data) {
          if (createdFiche) await supabase.from("dossier_entries").delete().eq("id", entryId);
          return showPointError("Échec de la création du point : " + (evRes.error?.message || "erreur inconnue."));
        }
        const eventId = evRes.data.id as string;
        const link = await supabase.from("timeline_event_fiches").insert({ entry_id: entryId, event_id: eventId, created_by: session.user.id });
        const place = link.error
          ? link
          : await supabase.from("timeline_placements").insert({
              frise_entry_id: frise.id,
              event_id: eventId,
              side: pointSide,
              color,
              category_id: cat ? cat.id : null,
              created_by: session.user.id,
            });
        if (place.error) {
          await supabase.from("timeline_events").delete().eq("id", eventId);
          if (createdFiche) await supabase.from("dossier_entries").delete().eq("id", entryId);
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

  // --- Sous-frise d'un événement avec durée ------------------------------------------------
  async function openEventSubFrise(p: Point) {
    if (p.subFriseId) {
      closePointCard();
      await goTo(p.subFriseId);
      return;
    }
    if (!isAdmin() || !frise) return;
    const session = deps.getSession();
    if (!session) return;
    if (!frise.category_id) {
      deps.showBanner?.("Cette frise doit être dans une catégorie du dossier pour accueillir une sous-frise.");
      return;
    }
    const ok = await customConfirm("« " + p.title + " » n'a pas encore de frise.\nEn créer une (avec sa sous-catégorie) ?");
    if (!ok) return;
    const { data: sibs } = await supabase
      .from("dossier_sections")
      .select("position")
      .eq("owner_type", frise.owner_type)
      .eq("owner_id", frise.owner_id)
      .eq("category_id", frise.category_id);
    const maxPos = Math.max(-1, ...((sibs as { position: number | null }[] | null) ?? []).map((x) => x.position ?? 0));
    const sec = await supabase
      .from("dossier_sections")
      .insert({
        owner_type: frise.owner_type,
        owner_id: frise.owner_id,
        category_id: frise.category_id,
        parent_section_id: frise.section_id,
        title: p.title,
        position: maxPos + 1,
        created_by: session.user.id,
      })
      .select("id")
      .single();
    if (sec.error || !sec.data) {
      deps.showBanner?.("Échec : " + (sec.error?.message || "erreur inconnue."));
      return;
    }
    const ent = await supabase
      .from("dossier_entries")
      .insert({
        owner_type: frise.owner_type,
        owner_id: frise.owner_id,
        type: "frise",
        title: p.title,
        category_id: frise.category_id,
        section_id: sec.data.id,
        tags: [],
        sources: [],
        status: "published",
        created_by: session.user.id,
      })
      .select("id")
      .single();
    if (ent.error || !ent.data) {
      deps.showBanner?.("Échec : " + (ent.error?.message || "erreur inconnue."));
      return;
    }
    const up = await supabase.from("timeline_events").update({ sub_frise_entry_id: ent.data.id }).eq("id", p.eventId);
    if (up.error) {
      deps.showBanner?.("Échec : " + up.error.message);
      return;
    }
    closePointCard();
    await deps.refreshDossier();
    await goTo(ent.data.id as string);
  }

  // --- Carte au clic sur un point -------------------------------------------------------------
  function openPointCard(p: Point, anchor: HTMLElement) {
    hideHover();
    const card = $("tl-point-card");
    card.innerHTML = "";
    const photo = p.fiches.find((f) => f.photo)?.photo;
    if (photo) {
      const img = document.createElement("img");
      img.className = "tl-card-img";
      img.src = photo;
      img.alt = "";
      card.appendChild(img);
    }
    const h = document.createElement("strong");
    h.textContent = p.title;
    const d = document.createElement("div");
    d.className = "tl-card-date";
    d.textContent = dateRangeText(p) + " · " + categoryName(p.categoryId);
    card.append(h, d);
    const row = document.createElement("div");
    row.className = "tl-card-actions";
    // Fiche à ouvrir en priorité : celle du dossier de cette frise.
    const mine = p.fiches.find((f) => frise && f.ownerType === frise.owner_type && f.ownerId === frise.owner_id) ?? p.fiches[0];
    if (mine) {
      const open = document.createElement("button");
      open.type = "button";
      open.className = "btn-small tl-primary";
      open.textContent = "Ouvrir la fiche";
      open.addEventListener("click", () => {
        closePointCard();
        closeView();
        void deps.openFicheEverywhere({ id: mine.id, ownerType: mine.ownerType, ownerId: mine.ownerId, categoryId: mine.categoryId });
      });
      row.appendChild(open);
    }
    if (p.end && (p.subFriseId || isAdmin())) {
      const sub = document.createElement("button");
      sub.type = "button";
      sub.className = "btn-small tl-primary";
      sub.textContent = p.subFriseId ? "Ouvrir la frise" : "Créer la frise";
      sub.addEventListener("click", () => void openEventSubFrise(p));
      row.appendChild(sub);
    }
    if (p.fiches.length > 1 || isAdmin()) {
      const more = document.createElement("button");
      more.type = "button";
      more.className = "btn-small";
      more.textContent = p.fiches.length > 1 ? "Fiches (" + p.fiches.length + ")" : "Autres pays";
      more.addEventListener("click", () => {
        closePointCard();
        void openFichesDialog(p);
      });
      row.appendChild(more);
    }
    if (p.friseCount > 1 || isAdmin()) {
      // Placements multiples et remontée sur la frise parente (src/friseMulti.ts).
      const frises = document.createElement("button");
      frises.type = "button";
      frises.className = "btn-small";
      frises.textContent = p.friseCount > 1 ? "Frises (" + p.friseCount + ")" : "Frises";
      frises.title = "Voir, ajouter ou retirer les frises où apparaît ce point";
      frises.addEventListener("click", () => {
        closePointCard();
        void multi.openForEvent({
          eventId: p.eventId,
          currentFriseId: frise ? frise.id : null,
          parentFriseId: ancestors.length ? ancestors[ancestors.length - 1].id : null,
        });
      });
      row.appendChild(frises);
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
    const t = ev.target as HTMLElement;
    if (card && card.style.display !== "none" && !card.contains(t) && !t.closest(".tl-point, .tl-bar")) closePointCard();
  });

  // --- Fiches d'un événement (une par pays) -------------------------------------------------------
  let fichesPoint: Point | null = null;
  function showFichesError(msg: string) {
    $("tl-fiches-error").textContent = msg;
  }
  async function openFichesDialog(p: Point) {
    fichesPoint = p;
    showFichesError("");
    $("tl-fiches-heading").textContent = "Fiches de « " + p.title + " »";
    $("tl-fiches-admin").style.display = isAdmin() ? "" : "none";
    setField("tl-fiches-search", "");
    $("tl-fiches-results").innerHTML = "";
    const sel = $("tl-fiches-country") as HTMLSelectElement;
    sel.innerHTML = "";
    const used = new Set(p.fiches.filter((f) => f.ownerType === "country").map((f) => f.ownerId));
    for (const c of deps.getCountryChoices()) {
      if (used.has(c.id)) continue;
      const o = document.createElement("option");
      o.value = c.id;
      o.textContent = c.label;
      sel.appendChild(o);
    }
    renderFichesList();
    $("tl-fiches-overlay").classList.add("open");
  }
  function renderFichesList() {
    const box = $("tl-fiches-list");
    box.innerHTML = "";
    const p = fichesPoint;
    if (!p) return;
    for (const f of p.fiches) {
      const row = document.createElement("div");
      row.className = "tl-fiche-row";
      const name = document.createElement("span");
      name.textContent = ficheLabel(f);
      const open = document.createElement("button");
      open.type = "button";
      open.className = "btn-small";
      open.textContent = "Ouvrir";
      open.addEventListener("click", () => {
        closeFichesDialog();
        closeView();
        void deps.openFicheEverywhere({ id: f.id, ownerType: f.ownerType, ownerId: f.ownerId, categoryId: f.categoryId });
      });
      row.append(name, open);
      if (isAdmin() && p.fiches.length > 1) {
        const un = document.createElement("button");
        un.type = "button";
        un.className = "btn-small";
        un.textContent = "Délier";
        un.title = "Retirer cette fiche de l'événement (la fiche reste dans le dossier)";
        un.addEventListener("click", async () => {
          const r = await supabase.from("timeline_event_fiches").delete().eq("entry_id", f.id);
          if (r.error) return showFichesError("Échec : " + r.error.message);
          p.fiches = p.fiches.filter((x) => x.id !== f.id);
          renderFichesList();
          await reload();
        });
        row.appendChild(un);
      }
      box.appendChild(row);
    }
  }
  function closeFichesDialog() {
    $("tl-fiches-overlay").classList.remove("open");
    fichesPoint = null;
  }
  async function linkFicheToEvent(f: PointFiche) {
    const p = fichesPoint;
    const session = deps.getSession();
    if (!p || !session) return;
    if (p.fiches.some((x) => x.id === f.id)) return showFichesError("Cette fiche est déjà reliée à l'événement.");
    const other = await ficheAlreadyLinked(f.id);
    if (other) return showFichesError("Cette fiche est déjà reliée à un autre événement.");
    const r = await supabase.from("timeline_event_fiches").insert({ entry_id: f.id, event_id: p.eventId, created_by: session.user.id });
    if (r.error) return showFichesError("Échec : " + r.error.message);
    p.fiches.push(f);
    setField("tl-fiches-search", "");
    $("tl-fiches-results").innerHTML = "";
    showFichesError("");
    renderFichesList();
    await reload();
  }
  async function createCountryFiche() {
    const p = fichesPoint;
    const session = deps.getSession();
    const country = ($("tl-fiches-country") as HTMLSelectElement).value;
    if (!p || !session || !country) return;
    const { data, error } = await supabase
      .from("dossier_entries")
      .insert({
        owner_type: "country",
        owner_id: country,
        type: "text",
        title: p.title,
        category_id: p.fiches[0]?.categoryId ?? null,
        section_id: null,
        tags: [],
        sources: [],
        status: "published",
        created_by: session.user.id,
      })
      .select("id")
      .single();
    if (error || !data) return showFichesError("Échec de la création : " + (error?.message || "erreur inconnue."));
    const fiche: PointFiche = { id: data.id as string, title: p.title, ownerType: "country", ownerId: country, categoryId: p.fiches[0]?.categoryId ?? null, photo: null };
    const r = await supabase.from("timeline_event_fiches").insert({ entry_id: fiche.id, event_id: p.eventId, created_by: session.user.id });
    if (r.error) {
      await supabase.from("dossier_entries").delete().eq("id", fiche.id);
      return showFichesError("Échec : " + r.error.message);
    }
    p.fiches.push(fiche);
    const sel = $("tl-fiches-country") as HTMLSelectElement;
    sel.querySelector('option[value="' + country + '"]')?.remove();
    showFichesError("");
    renderFichesList();
    await reload();
  }

  // --- Catégories (gestion) ---------------------------------------------------------------------------
  type CatDraft = { id: string; name: string; color: string; isNew: boolean };
  let catDraft: CatDraft[] = [];
  let catSeq = 0;
  function renderCatList() {
    const box = $("tl-cat-list");
    box.innerHTML = "";
    catDraft.forEach((c) => {
      const row = document.createElement("div");
      row.className = "tl-cat-row";
      const color = document.createElement("input");
      color.type = "color";
      color.className = "tl-color-input";
      color.value = c.color;
      color.addEventListener("input", () => (c.color = color.value));
      const name = document.createElement("input");
      name.type = "text";
      name.maxLength = 60;
      name.value = c.name;
      name.placeholder = "Nom de la catégorie";
      name.addEventListener("input", () => (c.name = name.value));
      const del = document.createElement("button");
      del.type = "button";
      del.className = "btn-small";
      del.textContent = "Supprimer";
      del.addEventListener("click", () => {
        catDraft = catDraft.filter((x) => x !== c);
        renderCatList();
      });
      row.append(color, name, del);
      box.appendChild(row);
    });
  }
  function openCatDialog() {
    catDraft = categories.map((c) => ({ id: c.id, name: c.name, color: c.color, isNew: false }));
    $("tl-cat-error").textContent = "";
    renderCatList();
    $("tl-cat-overlay").classList.add("open");
  }
  function closeCatDialog() {
    $("tl-cat-overlay").classList.remove("open");
  }
  async function saveCategories() {
    const session = deps.getSession();
    if (!session) return;
    const err = (m: string) => ($("tl-cat-error").textContent = m);
    const names = new Set<string>();
    for (const c of catDraft) {
      const n = c.name.trim();
      if (!n) return err("Chaque catégorie doit avoir un nom.");
      if (names.has(n.toLowerCase())) return err("Deux catégories portent le même nom : « " + n + " ».");
      names.add(n.toLowerCase());
    }
    const keep = new Set(catDraft.filter((c) => !c.isNew).map((c) => c.id));
    for (const old of categories) {
      if (!keep.has(old.id)) {
        const r = await supabase.from("timeline_categories").delete().eq("id", old.id);
        if (r.error) return err("Échec : " + r.error.message);
      }
    }
    let pos = 0;
    for (const c of catDraft) {
      const row = { name: c.name.trim(), color: c.color, position: pos++ };
      const r = c.isNew
        ? await supabase.from("timeline_categories").insert({ ...row, created_by: session.user.id })
        : await supabase.from("timeline_categories").update(row).eq("id", c.id);
      if (r.error) return err("Échec : " + r.error.message);
    }
    closeCatDialog();
    await reload();
  }

  // --- Recherche d'un point ---------------------------------------------------------------------------
  const plain = (t: string) => t.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
  function closeSearchResults() {
    const box = $("timeline-search-results");
    box.innerHTML = "";
    box.style.display = "none";
  }
  function focusPoint(p: Point) {
    const key = p.categoryId ?? NO_CATEGORY;
    if (hiddenCats.has(key)) {
      hiddenCats.delete(key);
      saveFilters();
      render();
    }
    const el = pointEls.get(p.eventId);
    if (!el) return;
    el.scrollIntoView({ behavior: "smooth", block: "center", inline: "center" });
    el.classList.add("flash");
    setTimeout(() => el.classList.remove("flash"), 2200);
  }
  function runSearch() {
    const q = plain(($("timeline-search") as HTMLInputElement).value.trim());
    const box = $("timeline-search-results");
    box.innerHTML = "";
    if (!q) return closeSearchResults();
    const hits = points
      .filter((p) => plain(p.title).includes(q))
      .sort((a, b) => dateSortKey(a.date) - dateSortKey(b.date))
      .slice(0, 8);
    box.style.display = "block";
    if (!hits.length) {
      const none = document.createElement("div");
      none.className = "tl-result none";
      none.textContent = "Aucun point trouvé";
      box.appendChild(none);
      return;
    }
    for (const p of hits) {
      const b = document.createElement("button");
      b.type = "button";
      b.className = "tl-result";
      const dot = document.createElement("span");
      dot.className = "tl-legend-dot";
      dot.style.background = p.color;
      b.append(dot, document.createTextNode(p.title + " · " + dateRangeText(p)));
      b.addEventListener("mousedown", (ev) => {
        ev.preventDefault();
        focusPoint(p);
        closeSearchResults();
      });
      box.appendChild(b);
    }
  }

  // --- Export en image de toute la frise (indépendant du zoom courant) --------------------------
  async function exportImage() {
    if (!frise || !effectivePeriods().length) return deps.showBanner?.("Rien à exporter : la frise n'a pas de période.");
    const btn = $("timeline-export-img") as HTMLButtonElement;
    btn.disabled = true;
    const savedZoom = zoom;
    const savedLeft = scrollEl.scrollLeft;
    const savedTop = scrollEl.scrollTop;
    try {
      const { toPng } = await import("html-to-image");
      hideHover();
      closePointCard();
      zoom = 1.5;
      render();
      await new Promise((r) => requestAnimationFrame(() => r(null)));
      const stage = $("timeline-stage");
      const w = Math.max(stage.scrollWidth, stage.offsetWidth);
      const h = Math.max(stage.scrollHeight, stage.offsetHeight);
      const css = getComputedStyle($("timeline-view"));
      const bg = css.backgroundColor || "#ffffff";
      const fg = css.color || "#222222";
      const dataUrl = await toPng(stage, { width: w, height: h, pixelRatio: 2, backgroundColor: bg, cacheBust: true });
      const img = new Image();
      await new Promise((res, rej) => {
        img.onload = () => res(null);
        img.onerror = () => rej(new Error("image illisible"));
        img.src = dataUrl;
      });
      // En-tête : titre, période, légende des catégories affichées.
      const S = 2;
      const headH = 150 * S;
      const canvas = document.createElement("canvas");
      canvas.width = img.width;
      canvas.height = img.height + headH;
      const ctx = canvas.getContext("2d");
      if (!ctx) throw new Error("Contexte 2D indisponible");
      ctx.fillStyle = bg;
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.drawImage(img, 0, headH);
      ctx.fillStyle = fg;
      ctx.font = "600 " + 34 * S + "px 'Fraunces', serif";
      ctx.fillText(frise.title || "Frise chronologique", 30 * S, 52 * S);
      if (context && context.from) {
        ctx.font = 15 * S + "px 'IBM Plex Sans', sans-serif";
        ctx.fillText(context.periodName + " · " + context.from + " → " + context.to, 30 * S, 80 * S);
      }
      ctx.font = 15 * S + "px 'IBM Plex Sans', sans-serif";
      let lx = 30 * S;
      const present = new Map<string, { name: string; color: string }>();
      for (const p of points) {
        const key = p.categoryId ?? NO_CATEGORY;
        if (hiddenCats.has(key) || present.has(key)) continue;
        present.set(key, { name: categoryName(p.categoryId), color: p.color });
      }
      for (const c of present.values()) {
        ctx.fillStyle = c.color;
        ctx.beginPath();
        ctx.arc(lx + 6 * S, 118 * S, 6 * S, 0, Math.PI * 2);
        ctx.fill();
        ctx.fillStyle = fg;
        ctx.fillText(c.name, lx + 18 * S, 123 * S);
        lx += 18 * S + ctx.measureText(c.name).width + 28 * S;
      }
      const blob: Blob | null = await new Promise((resolve) => canvas.toBlob(resolve, "image/png"));
      if (!blob) throw new Error("toBlob a renvoyé null");
      const name = (frise.title || "frise").normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/[^a-zA-Z0-9]+/g, "-").toLowerCase();
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = "frise-" + name + ".png";
      document.body.appendChild(a);
      a.click();
      a.remove();
      setTimeout(() => URL.revokeObjectURL(a.href), 4000);
    } catch (e) {
      deps.showBanner?.("Échec de l'export : " + (e instanceof Error ? e.message : "erreur inconnue."));
    } finally {
      zoom = savedZoom;
      render();
      scrollEl.scrollLeft = savedLeft;
      scrollEl.scrollTop = savedTop;
      btn.disabled = false;
    }
  }
  $("timeline-export-img").addEventListener("click", () => void exportImage());

  // --- Événements de l'interface ------------------------------------------------------------
  $("timeline-back").addEventListener("click", closeView);
  $("timeline-prev").addEventListener("click", () => {
    const parent = ancestors[ancestors.length - 1];
    if (parent) void openForEntry(parent.id);
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
  $("tl-point-duration").addEventListener("change", syncDurationFields);
  $("tl-fiche-new").addEventListener("change", syncFicheMode);
  $("tl-fiche-link").addEventListener("change", syncFicheMode);
  let ficheSearchTimer: number | null = null;
  $("tl-fiche-search").addEventListener("input", () => {
    if (ficheSearchTimer) window.clearTimeout(ficheSearchTimer);
    ficheSearchTimer = window.setTimeout(async () => {
      const list = await searchFiches(fieldValue("tl-fiche-search"));
      renderFicheResults($("tl-fiche-results"), list, (f) => {
        chosenFiche = f;
        $("tl-fiche-chosen").textContent = "Fiche choisie : " + ficheLabel(f);
        $("tl-fiche-results").innerHTML = "";
      });
    }, 250);
  });
  let fichesSearchTimer: number | null = null;
  $("tl-fiches-search").addEventListener("input", () => {
    if (fichesSearchTimer) window.clearTimeout(fichesSearchTimer);
    fichesSearchTimer = window.setTimeout(async () => {
      const list = await searchFiches(fieldValue("tl-fiches-search"));
      renderFicheResults($("tl-fiches-results"), list, (f) => void linkFicheToEvent(f));
    }, 250);
  });
  $("tl-fiches-create").addEventListener("click", () => void createCountryFiche());
  $("tl-fiches-close").addEventListener("click", closeFichesDialog);
  $("tl-fiches-overlay").addEventListener("click", (ev) => {
    if (ev.target === $("tl-fiches-overlay")) closeFichesDialog();
  });
  $("timeline-manage-cats").addEventListener("click", () => requireAdminOr(openCatDialog));
  $("tl-cat-add").addEventListener("click", () => {
    catDraft.push({ id: "new-" + ++catSeq, name: "", color: "#2980b9", isNew: true });
    renderCatList();
  });
  $("tl-cat-cancel").addEventListener("click", closeCatDialog);
  $("tl-cat-save").addEventListener("click", () => void saveCategories());
  $("tl-cat-overlay").addEventListener("click", (ev) => {
    if (ev.target === $("tl-cat-overlay")) closeCatDialog();
  });
  $("timeline-search").addEventListener("input", runSearch);
  $("timeline-search").addEventListener("blur", () => setTimeout(closeSearchResults, 150));
  $("timeline-search").addEventListener("keydown", (ev) => {
    const key = (ev as KeyboardEvent).key;
    if (key === "Escape") {
      setField("timeline-search", "");
      closeSearchResults();
    } else if (key === "Enter") {
      const q = plain(fieldValue("timeline-search").trim());
      const first = points.filter((p) => plain(p.title).includes(q)).sort((a, b) => dateSortKey(a.date) - dateSortKey(b.date))[0];
      if (first) {
        focusPoint(first);
        closeSearchResults();
      }
    }
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

  // Lien fiche -> frise : frise (et point) où apparaît une fiche, s'il y en a une.
  async function friseOfFiche(entryId: string): Promise<{ friseId: string; eventId: string } | null> {
    const { data: link } = await supabase.from("timeline_event_fiches").select("event_id").eq("entry_id", entryId).maybeSingle();
    const eventId = (link as { event_id: string } | null)?.event_id;
    if (!eventId) return null;
    const { data: pls } = await supabase.from("timeline_placements").select("frise_entry_id").eq("event_id", eventId);
    const friseId = ((pls as { frise_entry_id: string }[] | null) ?? [])[0]?.frise_entry_id;
    return friseId ? { friseId, eventId } : null;
  }
  async function openForFiche(entryId: string) {
    const target = await friseOfFiche(entryId);
    if (!target) return;
    // Point placé sur plusieurs frises : on laisse choisir laquelle ouvrir.
    if ((await fetchPlacements(supabase, target.eventId)).length > 1) {
      await multi.openForEvent({ eventId: target.eventId });
      return;
    }
    await openFromDossier(target.friseId);
    const pt = points.find((p) => p.eventId === target.eventId);
    if (pt) setTimeout(() => focusPoint(pt), 80);
  }

  // Ouvre une frise et met un point en évidence (depuis le dialogue des placements).
  async function showFriseAt(friseId: string, eventId: string) {
    if ($("timeline-view").classList.contains("open")) await goTo(friseId);
    else await openFromDossier(friseId);
    const pt = points.find((p) => p.eventId === eventId);
    if (pt) setTimeout(() => focusPoint(pt), 80);
  }
  const multi = initFriseMulti({
    supabase,
    getSession: deps.getSession,
    isAdmin,
    getOwnerLabel: deps.getOwnerLabel,
    showBanner: deps.showBanner,
    openFrise: showFriseAt,
    onChanged: async () => {
      if (frise && $("timeline-view").classList.contains("open")) await reload();
    },
  });

  return {
    openForEntry: openFromDossier,
    openForFiche,
    // « Placer sur une frise » depuis une fiche (dossier.ts) : placements multiples.
    placeFiche: (entryId: string, title: string | null) => multi.openForFiche({ entryId, title }),
    isFicheOnFrise: async (entryId: string) => (await friseOfFiche(entryId)) !== null,
    closeView,
  };
}
