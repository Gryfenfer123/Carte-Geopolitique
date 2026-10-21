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
  computeWidths,
  formatFriseDate,
  layoutPeriods,
  parseDateFields,
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
  transition_label: string | null;
};

type Ancestor = { id: string; title: string };

type FriseContext = { periodName: string; from: string; to: string };

const SECTION_COLUMNS =
  "id, title, category_id, parent_section_id, position, period_frise_id, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa, transition_label";

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
  return { id: r.id, name: r.title, start, end, transitionLabel: r.transition_label };
}

function dateColumns(prefix: "period_start" | "period_end", d: FriseDate | null): Record<string, unknown> {
  return {
    [prefix + "_year"]: d ? d.year : null,
    [prefix + "_month"]: d ? d.month : null,
    [prefix + "_day"]: d ? d.day : null,
    [prefix + "_circa"]: d ? d.circa : false,
  };
}

export function initTimelineSystem(deps: {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  getProfile: () => { id: string; role: string } | null;
  openAuthPanel: () => void;
  showBanner?: (msg: string) => void;
  // Ouvre la page de la sous-catégorie (dossier.ts::revealSection).
  revealSection: (sectionId: string, categoryId: string | null) => void;
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
  let periods: Period[] = [];
  let subFrises = new Map<string, { id: string; title: string | null }>();
  let ancestors: Ancestor[] = [];
  let context: FriseContext | null = null;
  let editingPeriodId: string | null = null;
  let loadToken = 0;

  // --- DOM (construit une fois) --------------------------------------------------
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="timeline-view">
      <div id="timeline-topbar">
        <button id="timeline-back" class="btn-small">&larr; Retour au dossier</button>
        <nav id="timeline-breadcrumb" aria-label="Frises parentes"></nav>
        <div id="timeline-toolbar">
          <button id="timeline-add-period" class="btn-small edit-control">&#43; P&eacute;riode</button>
        </div>
      </div>
      <div id="timeline-subtitle"></div>
      <div id="timeline-scroll">
        <div id="timeline-stage"></div>
        <p id="timeline-empty-hint" class="muted" style="display:none;"></p>
      </div>
    </div>

    <div id="tl-period-overlay">
      <div id="tl-period-box" role="dialog" aria-modal="true">
        <h3 id="tl-period-heading">Nouvelle p&eacute;riode</h3>
        <label class="tl-field" id="tl-period-source-row">Sous-cat&eacute;gorie
          <select id="tl-period-source"></select>
        </label>
        <label class="tl-field">Nom de la p&eacute;riode
          <input type="text" id="tl-period-name" maxlength="120" placeholder="ex. Antiquit&eacute;">
        </label>
        <fieldset class="tl-date" id="tl-start-fields">
          <legend>D&eacute;but</legend>
          <input type="text" inputmode="numeric" id="tl-start-year" placeholder="Ann&eacute;e" aria-label="Ann&eacute;e de d&eacute;but">
          <label class="tl-inline"><input type="checkbox" id="tl-start-bc"> av. J.-C.</label>
          <input type="text" inputmode="numeric" id="tl-start-month" placeholder="Mois" aria-label="Mois de d&eacute;but">
          <input type="text" inputmode="numeric" id="tl-start-day" placeholder="Jour" aria-label="Jour de d&eacute;but">
          <label class="tl-inline"><input type="checkbox" id="tl-start-circa"> vers</label>
        </fieldset>
        <label class="tl-inline tl-end-toggle"><input type="checkbox" id="tl-end-enabled"> Cette p&eacute;riode a une fin propre (transition avant la suivante, ou fin de la derni&egrave;re)</label>
        <div id="tl-end-block">
          <fieldset class="tl-date" id="tl-end-fields">
            <legend>Fin</legend>
            <input type="text" inputmode="numeric" id="tl-end-year" placeholder="Ann&eacute;e" aria-label="Ann&eacute;e de fin">
            <label class="tl-inline"><input type="checkbox" id="tl-end-bc"> av. J.-C.</label>
            <input type="text" inputmode="numeric" id="tl-end-month" placeholder="Mois" aria-label="Mois de fin">
            <input type="text" inputmode="numeric" id="tl-end-day" placeholder="Jour" aria-label="Jour de fin">
            <label class="tl-inline"><input type="checkbox" id="tl-end-circa"> vers</label>
          </fieldset>
          <label class="tl-field">Texte du trou de transition (facultatif)
            <input type="text" id="tl-transition-label" maxlength="200" placeholder="ex. Invasions et effondrement de l'Empire">
          </label>
        </div>
        <p id="tl-period-error" role="alert"></p>
        <div id="tl-period-actions">
          <button type="button" class="btn-small" id="tl-period-remove">Retirer de la frise</button>
          <span class="tl-spacer"></span>
          <button type="button" class="btn-small" id="tl-period-cancel">Annuler</button>
          <button type="button" class="btn-small tl-primary" id="tl-period-save">Enregistrer</button>
        </div>
      </div>
    </div>
  `;
  while (root.firstChild) document.body.appendChild(root.firstChild);

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
  async function fetchPeriodRows(friseId: string): Promise<SectionRow[]> {
    const { data } = await supabase.from("dossier_sections").select(SECTION_COLUMNS).eq("period_frise_id", friseId);
    return ((data as SectionRow[] | null) ?? []).filter((r) => r.period_start_year != null);
  }

  async function load(entryId: string): Promise<boolean> {
    const token = ++loadToken;
    const entry = await fetchEntry(entryId);
    if (!entry || token !== loadToken) return false;
    const rows = await fetchPeriodRows(entry.id);
    if (token !== loadToken) return false;

    // Sous-frises : frises posées dans la sous-catégorie d'une période.
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

    // Ancêtres : si cette frise est posée dans une période d'une frise parente,
    // on remonte (fil d'Ariane + bornes de la période, calculées depuis la parente).
    const chain: Ancestor[] = [];
    let ctx: FriseContext | null = null;
    let cur: FriseEntry = entry;
    for (let depth = 0; depth < 12 && cur.section_id; depth++) {
      const sec = await fetchSection(cur.section_id);
      if (!sec || !sec.period_frise_id) break;
      const parent = await fetchEntry(sec.period_frise_id);
      if (!parent) break;
      if (depth === 0) {
        const sibRows = await fetchPeriodRows(parent.id);
        const { segments } = layoutPeriods(sibRows.map(rowToPeriod));
        const idx = segments.findIndex((s) => s.kind === "period" && s.period.id === sec.id);
        if (idx >= 0) ctx = describeBounds(segments, idx);
        else ctx = { periodName: sec.title, from: "", to: "" };
      }
      chain.unshift({ id: parent.id, title: parent.title || "Frise" });
      cur = parent;
    }
    if (token !== loadToken) return false;

    frise = entry;
    periodRows = rows;
    periods = rows.map(rowToPeriod);
    subFrises = subs;
    ancestors = chain;
    context = ctx;
    return true;
  }

  function describeBounds(segments: Segment[], index: number): FriseContext {
    const seg = segments[index] as Extract<Segment, { kind: "period" }>;
    const p = seg.period;
    const after = segments[index + 1];
    let to: string;
    if (after && after.kind === "gap" && p.end) to = formatFriseDate(p.end);
    else if (after && after.kind === "period") to = formatFriseDate(after.period.start);
    else if (p.end && !seg.openEnded) to = formatFriseDate(p.end);
    else to = "aujourd'hui";
    return { periodName: p.name, from: formatFriseDate(p.start), to };
  }

  // --- Rendu -----------------------------------------------------------------------
  function render() {
    if (!frise) return;
    const admin = isAdmin();
    document.body.classList.toggle("tl-can-edit", admin);

    // Fil d'Ariane des frises : parentes cliquables > frise courante.
    const bc = $("timeline-breadcrumb");
    bc.innerHTML = "";
    for (const a of ancestors) {
      const b = document.createElement("button");
      b.type = "button";
      b.className = "tl-crumb";
      b.textContent = a.title;
      b.addEventListener("click", () => void openForEntry(a.id));
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
      sub.innerHTML = "Période « <strong>" + esc(context.periodName) + "</strong> » · " + esc(context.from) + " → " + esc(context.to);
      sub.style.display = "";
    } else if (context) {
      sub.innerHTML = "Période « <strong>" + esc(context.periodName) + "</strong> »";
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
    const widths = computeWidths(segments, Math.max(scroll.clientWidth - 64, 320));
    const total = widths.reduce((s, w) => s + w, 0);

    const wrap = document.createElement("div");
    wrap.className = "tl-band-wrap";
    wrap.style.width = total + "px";

    // Repères de dates (bornes partagées) au-dessus de la bande.
    const marks = document.createElement("div");
    marks.className = "tl-marks";
    let x = 0;
    segments.forEach((seg, i) => {
      const date = seg.kind === "period" ? seg.period.start : periods.find((p) => p.id === seg.afterPeriodId)?.end;
      if (date) addMark(marks, x, formatFriseDate(date), false);
      x += widths[i];
    });
    const last = segments[segments.length - 1];
    if (last.kind === "period") {
      addMark(marks, total, last.period.end && !last.openEnded ? formatFriseDate(last.period.end) : "aujourd'hui", true);
    }
    wrap.appendChild(marks);

    // La bande : deux lignes (haut/bas) entre lesquelles s'écrivent les périodes.
    const band = document.createElement("div");
    band.className = "tl-band";
    segments.forEach((seg, i) => {
      const cell = document.createElement("div");
      cell.style.width = widths[i] + "px";
      if (seg.kind === "gap") {
        cell.className = "tl-gap";
        cell.title = seg.label || "Transition";
        const t = document.createElement("span");
        t.className = "tl-gap-label";
        t.textContent = seg.label || "";
        cell.appendChild(t);
      } else {
        cell.className = "tl-period";
        const p = seg.period;
        const sub = subFrises.get(p.id);
        cell.classList.toggle("has-sub", !!sub);
        cell.tabIndex = 0;
        cell.setAttribute("role", "button");
        cell.title = sub ? "Ouvrir la sous-frise « " + (sub.title || p.name) + " »" : admin ? "Créer la sous-frise de cette période" : p.name;
        cell.innerHTML =
          '<span class="tl-period-name">' + esc(p.name) + "</span>" +
          '<span class="tl-period-sub">' + (sub ? "sous-frise ›" : "") + "</span>";
        const tools = document.createElement("span");
        tools.className = "tl-period-tools";
        const open = document.createElement("button");
        open.type = "button";
        open.className = "tl-tool";
        open.textContent = "Sous-catégorie";
        open.title = "Ouvrir la sous-catégorie « " + p.name + " » dans le dossier";
        open.addEventListener("click", (ev) => {
          ev.stopPropagation();
          const row = periodRows.find((r) => r.id === p.id);
          closeView();
          deps.revealSection(p.id, row ? row.category_id : null);
        });
        tools.appendChild(open);
        if (admin) {
          const edit = document.createElement("button");
          edit.type = "button";
          edit.className = "tl-tool edit-control";
          edit.textContent = "Modifier";
          edit.addEventListener("click", (ev) => {
            ev.stopPropagation();
            requireAdminOr(() => openPeriodDialog(p.id));
          });
          tools.appendChild(edit);
        }
        cell.appendChild(tools);
        const go = () => void onPeriodActivate(p);
        cell.addEventListener("click", go);
        cell.addEventListener("keydown", (ev) => {
          if (ev.key === "Enter" || ev.key === " ") {
            ev.preventDefault();
            go();
          }
        });
      }
      band.appendChild(cell);
    });
    wrap.appendChild(band);

    if (issues.length) {
      const warn = document.createElement("p");
      warn.className = "tl-issues";
      warn.textContent = issues.map((i) => i.message).join(" ");
      wrap.appendChild(warn);
    }
    stage.appendChild(wrap);
  }

  function addMark(container: HTMLElement, x: number, text: string, atEnd: boolean) {
    const m = document.createElement("span");
    m.className = "tl-mark" + (atEnd ? " at-end" : "");
    m.style.left = x + "px";
    m.textContent = text;
    container.appendChild(m);
  }

  // --- Navigation -----------------------------------------------------------------
  async function onPeriodActivate(p: Period) {
    const sub = subFrises.get(p.id);
    if (sub) {
      await openForEntry(sub.id);
      return;
    }
    if (!isAdmin()) {
      deps.showBanner?.("Pas de sous-frise pour « " + p.name + " ».");
      return;
    }
    const ok = await customConfirm("« " + p.name + " » n'a pas encore de sous-frise.\nEn créer une dans cette période ?");
    if (!ok) return;
    const row = periodRows.find((r) => r.id === p.id);
    const session = deps.getSession();
    if (!row || !frise || !session) return;
    const { data, error } = await supabase
      .from("dossier_entries")
      .insert({
        owner_type: frise.owner_type,
        owner_id: frise.owner_id,
        type: "frise",
        title: p.name,
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
    await openForEntry(data.id as string);
  }

  async function openForEntry(entryId: string) {
    $("timeline-view").classList.add("open");
    const ok = await load(entryId);
    if (!ok) {
      deps.showBanner?.("Frise introuvable.");
      if (!frise) closeView();
      return;
    }
    render();
  }

  function closeView() {
    $("timeline-view").classList.remove("open");
    closePeriodDialog();
    document.body.classList.remove("tl-can-edit");
    void deps.refreshDossier();
  }

  // --- Dialogue de période ---------------------------------------------------------
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
  function fillDate(prefix: "tl-start" | "tl-end", d: FriseDate | null) {
    setField(prefix + "-year", d ? String(Math.abs(d.year)) : "");
    setChecked(prefix + "-bc", !!d && d.year < 0);
    setField(prefix + "-month", d?.month ? String(d.month) : "");
    setField(prefix + "-day", d?.day ? String(d.day) : "");
    setChecked(prefix + "-circa", !!d?.circa);
  }
  function readDate(prefix: "tl-start" | "tl-end") {
    return parseDateFields({
      year: fieldValue(prefix + "-year"),
      bc: checked(prefix + "-bc"),
      month: fieldValue(prefix + "-month"),
      day: fieldValue(prefix + "-day"),
      circa: checked(prefix + "-circa"),
    });
  }
  function showError(msg: string) {
    $("tl-period-error").textContent = msg;
  }
  function syncEndBlock() {
    $("tl-end-block").style.display = checked("tl-end-enabled") ? "" : "none";
  }

  async function openPeriodDialog(periodId: string | null) {
    if (!frise) return;
    editingPeriodId = periodId;
    showError("");
    const sourceRow = $("tl-period-source-row");
    const sel = $("tl-period-source") as HTMLSelectElement;
    if (periodId) {
      const p = periods.find((x) => x.id === periodId);
      if (!p) return;
      $("tl-period-heading").textContent = "Modifier la période";
      sourceRow.style.display = "none";
      setField("tl-period-name", p.name);
      fillDate("tl-start", p.start);
      fillDate("tl-end", p.end);
      setChecked("tl-end-enabled", !!p.end);
      setField("tl-transition-label", p.transitionLabel || "");
      $("tl-period-remove").style.display = "";
    } else {
      $("tl-period-heading").textContent = "Nouvelle période";
      sourceRow.style.display = "";
      // Sous-catégories existantes du même niveau, pas encore des périodes.
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
      fillDate("tl-start", null);
      fillDate("tl-end", null);
      setChecked("tl-end-enabled", false);
      setField("tl-transition-label", "");
      $("tl-period-remove").style.display = "none";
    }
    syncEndBlock();
    $("tl-period-overlay").classList.add("open");
    ($("tl-period-name") as HTMLInputElement).focus();
  }
  function closePeriodDialog() {
    $("tl-period-overlay").classList.remove("open");
    editingPeriodId = null;
  }

  async function savePeriod() {
    if (!frise) return;
    const name = fieldValue("tl-period-name").trim();
    if (!name) return showError("Donne un nom à la période.");
    const start = readDate("tl-start");
    if (!start.ok) return showError("Début : " + start.error);
    let end: FriseDate | null = null;
    if (checked("tl-end-enabled")) {
      const e = readDate("tl-end");
      if (!e.ok) return showError("Fin : " + e.error);
      end = e.date;
    }
    const label = fieldValue("tl-transition-label").trim() || null;

    // Contrôle de cohérence sur la liste hypothétique : aucune nouvelle anomalie
    // (chevauchement, même date de début) ne doit apparaître.
    const before = new Set(layoutPeriods(periods).issues.map((i) => i.periodId + i.message));
    const targetId = editingPeriodId ?? "__new__";
    const candidate: Period = { id: targetId, name, start: start.date, end, transitionLabel: end ? label : null };
    const hypothetical = periods.filter((p) => p.id !== editingPeriodId).concat(candidate);
    const fresh = layoutPeriods(hypothetical).issues.filter((i) => !before.has(i.periodId + i.message));
    if (fresh.length) return showError(fresh[0].message);

    const cols = {
      title: name,
      period_frise_id: frise.id,
      ...dateColumns("period_start", start.date),
      ...dateColumns("period_end", end),
      transition_label: end ? label : null,
    };

    ($("tl-period-save") as HTMLButtonElement).disabled = true;
    try {
      if (editingPeriodId) {
        const { error } = await supabase.from("dossier_sections").update(cols).eq("id", editingPeriodId);
        if (error) return showError("Échec de l'enregistrement : " + error.message);
      } else {
        const chosen = ($("tl-period-source") as HTMLSelectElement).value;
        if (chosen) {
          const { error } = await supabase.from("dossier_sections").update(cols).eq("id", chosen);
          if (error) return showError("Échec de l'enregistrement : " + error.message);
        } else {
          const session = deps.getSession();
          if (!session) return showError("Connexion requise.");
          if (!frise.category_id) {
            return showError("Cette frise n'est dans aucune catégorie : place-la d'abord dans une catégorie du dossier.");
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
          if (error) return showError("Échec de l'enregistrement : " + error.message);
        }
      }
    } finally {
      ($("tl-period-save") as HTMLButtonElement).disabled = false;
    }
    closePeriodDialog();
    await deps.refreshDossier();
    await reload();
  }

  async function removePeriod() {
    if (!editingPeriodId) return;
    const p = periods.find((x) => x.id === editingPeriodId);
    if (!p) return;
    const ok = await customConfirm(
      "Retirer « " + p.name + " » de la frise ?\nLa sous-catégorie et tout son contenu sont conservés dans le dossier ; elle cesse seulement d'être une période."
    );
    if (!ok) return;
    const { error } = await supabase
      .from("dossier_sections")
      .update({
        period_frise_id: null,
        ...dateColumns("period_start", null),
        ...dateColumns("period_end", null),
        transition_label: null,
      })
      .eq("id", editingPeriodId);
    if (error) return showError("Échec : " + error.message);
    closePeriodDialog();
    await deps.refreshDossier();
    await reload();
  }

  async function reload() {
    if (!frise) return;
    if (await load(frise.id)) render();
  }

  // --- Événements de l'interface ------------------------------------------------------
  $("timeline-back").addEventListener("click", closeView);
  $("timeline-add-period").addEventListener("click", () => requireAdminOr(() => void openPeriodDialog(null)));
  $("tl-period-cancel").addEventListener("click", closePeriodDialog);
  $("tl-period-save").addEventListener("click", () => void savePeriod());
  $("tl-period-remove").addEventListener("click", () => void removePeriod());
  $("tl-end-enabled").addEventListener("change", syncEndBlock);
  $("tl-period-source").addEventListener("change", () => {
    const sel = $("tl-period-source") as HTMLSelectElement;
    const opt = sel.selectedOptions[0];
    if (opt && opt.dataset.title && !fieldValue("tl-period-name").trim()) setField("tl-period-name", opt.dataset.title);
  });
  $("tl-period-overlay").addEventListener("click", (ev) => {
    if (ev.target === $("tl-period-overlay")) closePeriodDialog();
  });
  window.addEventListener("resize", () => {
    if ($("timeline-view").classList.contains("open") && frise) render();
  });

  return {
    openForEntry,
    closeView,
  };
}
