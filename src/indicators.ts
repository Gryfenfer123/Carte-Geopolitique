// ---------------------------------------------------------------------------
// Indicateurs Our World in Data — porté de l'artifact source
// (realistic_final.html) : formatOwidNumber (~2815), deriveGradientFromBaseColor/
// gradientToColorFn (~4426-4450), populateCategorySelect/populateIndicatorSelect/
// applyIndicatorToMap/setSelectedIndicator (~4460-4605), updateFicheIndicatorValue
// (~4555-4568).
//
// Panneau "Apparence" — porté de applyAppearance/loadAppearance/saveAppearance/
// colorRow/renderAppearancePanel (~4614-4877) : personnalisation des couleurs
// de dégradé de chaque catégorie d'indicateur, des couleurs de liens et des
// couleurs de la carte, persistée dans public.app_settings (id='appearance',
// schema_v6.sql — équivalent du document settings/appearance de l'artifact).
//
// OWID_CATEGORIES.json/OWID_DATA.json sont des données de référence figées
// (non modifiées par Martin en session live), chargées directement en
// statique — même principe que SOV.json/FR_NAMES.json pour les frontières et
// les noms de pays. DEFAULT_APPEARANCE.json/MAP_COLOR_META.json, déjà
// extraits du même artifact, sont chargés de la même façon.
// ---------------------------------------------------------------------------

import * as d3 from "d3";
import type { SupabaseClient } from "@supabase/supabase-js";

type OwidIndicatorMeta = { id: string; label: string; unit: string; decimals: number };
type OwidCategory = { id: string; label: string; indicators: OwidIndicatorMeta[] };
type OwidEntry = { v: number; y: number };
type OwidCountryData = Record<string, OwidEntry>;

type MapColorMeta = { id: string; label: string; cssVar: string };
type Appearance = {
  indicatorGradients: Record<string, string>;
  linkColors: Record<string, string>;
  mapColors: Record<string, string>;
};

// Couleurs de la légende des liens (diplomatie/conflit/économie/culture/
// autre) — porté de LINK_CATEGORY_META (~4615), petite liste figée non
// extraite en JSON à part dans l'artifact source.
export const LINK_CATEGORY_META: { id: string; label: string }[] = [
  { id: "diplomatie", label: "Diplomatie / accord" },
  { id: "conflit", label: "Conflit" },
  { id: "economie", label: "Économie" },
  { id: "culture", label: "Culture" },
  { id: "autre", label: "Autre" },
];

// Ancien format sauvegardé (3 couleurs [claire, médiane, foncée]) : on
// dégrade proprement vers le nouveau format à une seule couleur de base en
// reprenant la teinte médiane, plutôt que de planter — porté à l'identique
// de normalizeGradientBase() (~4454).
function normalizeGradientBase(entry: unknown, fallback: string): string {
  if (Array.isArray(entry)) return entry[1] || entry[0] || entry[2] || fallback;
  if (typeof entry === "string" && entry) return entry;
  return fallback;
}

// Complète l'ISO_A3 de Natural Earth quand il vaut "-99" (pays souverains
// avec territoires d'outre-mer rattachés) — porté de ISO3_OVERRIDES (~2806).
const ISO3_OVERRIDES: Record<string, string> = {
  "United States of America": "USA",
  "United Kingdom": "GBR",
  Norway: "NOR",
  "New Zealand": "NZL",
  Netherlands: "NLD",
  Israel: "ISR",
  Georgia: "GEO",
  France: "FRA",
  Finland: "FIN",
  Denmark: "DNK",
  China: "CHN",
  Australia: "AUS",
};

export type SovFeatureLike = GeoJSON.Feature<GeoJSON.Geometry, { name: string; iso_a3: string } & Record<string, unknown>>;

function countryIso3(props: { name?: string; iso_a3?: string; ISO_A3?: unknown }): string | null {
  const raw = (props.iso_a3 as string) || (props.ISO_A3 as string) || "";
  if (raw && raw !== "-99") return raw;
  return ISO3_OVERRIDES[props.name || ""] || null;
}

function formatOwidNumber(v: number, decimals: number): string {
  return v.toLocaleString("fr-FR", { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
}

function deriveGradientFromBaseColor(hexColor: string, steps = 7): string[] {
  let c: d3.HSLColor;
  try {
    c = d3.hsl(hexColor);
  } catch {
    c = d3.hsl("#5b9fe0");
  }
  const hue = isNaN(c.h) ? 0 : c.h;
  const baseSat = isNaN(c.s) || c.s < 0.35 ? 0.55 : c.s;
  const stops: string[] = [];
  for (let i = 0; i < steps; i++) {
    const t = i / (steps - 1);
    const lightness = 0.93 - t * 0.7;
    const saturation = Math.min(0.95, baseSat + t * 0.22);
    stops.push(d3.hsl(hue, saturation, lightness).formatHex());
  }
  return stops;
}
function gradientToColorFn(stops: string[]): (t: number) => string {
  const scale = d3
    .scaleLinear<string>()
    .domain(stops.map((_s, i) => i / (stops.length - 1)))
    .range(stops)
    .interpolate(d3.interpolateRgb)
    .clamp(true);
  return (t: number) => scale(t);
}

export function initIndicatorsSystem(deps: {
  supabase: SupabaseClient;
  getSession: () => { user: { id: string } } | null;
  gIndicatorLayer: d3.Selection<SVGGElement, unknown, HTMLElement | null, unknown>;
  geoPath: (f: GeoJSON.GeoJSON) => string | null;
  getSovFeatures: () => SovFeatureLike[];
  // Rejoue le calque de liens (gLinks) avec les nouvelles couleurs — porté de
  // l'appel à applyAppearance() en fin d'enregistrement (~4655). Optionnel :
  // le calque de liens n'est pas encore porté dans cette version de l'app.
  onLinkColorsChanged?: () => void;
}) {
  const { supabase } = deps;

  // --- DOM --------------------------------------------------------------
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="indicators-panel" class="panel side-panel">
      <button class="close-x" id="indicators-close" aria-label="Fermer">&times;</button>
      <h2>Indicateurs sur la carte</h2>
      <p class="muted">Colore chaque pays selon un indicateur (données Our World in Data). Un seul indicateur actif à la fois sur la carte.</p>
      <label class="field-label">Catégorie</label>
      <select id="indicator-category-select"></select>
      <label class="field-label">Indicateur</label>
      <select id="indicator-select"></select>
      <div id="indicator-legend" style="display:none;">
        <div id="indicator-legend-title" style="font-weight:600;font-size:12.5px;margin-top:16px;"></div>
        <div id="indicator-legend-gradient" style="height:10px;border-radius:5px;margin:8px 0 4px;"></div>
        <div id="indicator-legend-ticks" style="display:flex;justify-content:space-between;font-size:11px;color:var(--text-dim);"></div>
        <div id="indicator-legend-note" class="muted" style="margin-top:6px;"></div>
      </div>
      <button id="indicator-clear" class="btn-small" style="margin-top:16px;">Retirer de la carte</button>
    </div>
    <div id="appearance-panel" class="panel side-panel">
      <button class="close-x" id="appearance-close" aria-label="Fermer">&times;</button>
      <h2>Apparence</h2>
      <p class="muted">Toutes les couleurs et dégradés utilisés sur la carte, personnalisables. Les changements s'appliquent immédiatement et sont sauvegardés.</p>
      <div id="appearance-body"></div>
      <button id="appearance-reset" class="btn-small" style="margin-top:16px;">Réinitialiser toutes les couleurs</button>
    </div>
  `;
  while (root.firstChild) document.body.appendChild(root.firstChild);
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

  let categories: OwidCategory[] = [];
  let owidData: Record<string, OwidCountryData> = {};
  let selected: { cat: string | null; ind: string | null } = { cat: null, ind: null };

  // -------------------------------------------------------------------------
  // Panneau "Apparence" — porté de applyAppearance/loadAppearance/
  // saveAppearance/colorRow/renderAppearancePanel (~4614-4877).
  // -------------------------------------------------------------------------
  let mapColorMeta: MapColorMeta[] = [];
  let defaultAppearance: Appearance = { indicatorGradients: {}, linkColors: {}, mapColors: {} };
  let appearance: Appearance = { indicatorGradients: {}, linkColors: {}, mapColors: {} };

  function applyAppearance() {
    const root = document.documentElement.style;
    mapColorMeta.forEach((m) => root.setProperty(m.cssVar, appearance.mapColors[m.id] || defaultAppearance.mapColors[m.id]));
    LINK_CATEGORY_META.forEach((m) =>
      root.setProperty("--link-" + m.id, appearance.linkColors[m.id] || defaultAppearance.linkColors[m.id])
    );
    // Rejoue la coloration en cours (carte + légende) avec les nouvelles teintes.
    if (selected.cat) applyIndicatorToMap();
    deps.onLinkColorsChanged?.();
  }

  let saveAppearanceTimer: number | null = null;
  function saveAppearance() {
    const session = deps.getSession();
    if (!session) return;
    if (saveAppearanceTimer) window.clearTimeout(saveAppearanceTimer);
    saveAppearanceTimer = window.setTimeout(async () => {
      try {
        await supabase.from("app_settings").upsert({ id: "appearance", value: appearance, updated_by: session.user.id });
      } catch {
        /* best-effort */
      }
    }, 400);
  }

  async function loadAppearance() {
    try {
      const { data } = await supabase.from("app_settings").select("value").eq("id", "appearance").maybeSingle();
      if (data && data.value) {
        const saved = data.value as Partial<Appearance>;
        const savedGrad = saved.indicatorGradients || {};
        const mergedGrad: Record<string, string> = {};
        Object.keys(defaultAppearance.indicatorGradients).forEach((catId) => {
          mergedGrad[catId] = Object.prototype.hasOwnProperty.call(savedGrad, catId)
            ? normalizeGradientBase(savedGrad[catId], defaultAppearance.indicatorGradients[catId])
            : defaultAppearance.indicatorGradients[catId];
        });
        appearance = {
          indicatorGradients: mergedGrad,
          linkColors: Object.assign({}, defaultAppearance.linkColors, saved.linkColors || {}),
          mapColors: Object.assign({}, defaultAppearance.mapColors, saved.mapColors || {}),
        };
      }
    } catch {
      /* garde les valeurs par défaut */
    }
    applyAppearance();
    renderAppearancePanel();
  }

  function colorRow(label: string, value: string, onChange: (v: string) => void): HTMLElement {
    const row = document.createElement("div");
    row.className = "appearance-row";
    const span = document.createElement("span");
    span.textContent = label;
    const input = document.createElement("input");
    input.type = "color";
    input.value = value;
    input.addEventListener("input", () => onChange(input.value));
    row.appendChild(span);
    row.appendChild(input);
    return row;
  }

  function renderAppearancePanel() {
    const body = $("appearance-body");
    body.innerHTML = "";

    const gradTitle = document.createElement("div");
    gradTitle.className = "appearance-section-title";
    gradTitle.textContent = "Dégradés des indicateurs";
    body.appendChild(gradTitle);
    const gradHint = document.createElement("p");
    gradHint.className = "appearance-hint";
    gradHint.textContent = "Une seule couleur par catégorie : le dégradé clair → foncé est généré automatiquement à partir d’elle.";
    body.appendChild(gradHint);
    categories.forEach((cat) => {
      const base = normalizeGradientBase(appearance.indicatorGradients[cat.id], defaultAppearance.indicatorGradients.demographie);
      body.appendChild(
        colorRow(cat.label, base, (v) => {
          appearance.indicatorGradients[cat.id] = v;
          applyAppearance();
          saveAppearance();
        })
      );
    });

    const linkTitle = document.createElement("div");
    linkTitle.className = "appearance-section-title";
    linkTitle.textContent = "Couleurs des liens";
    body.appendChild(linkTitle);
    LINK_CATEGORY_META.forEach((m) => {
      body.appendChild(
        colorRow(m.label, appearance.linkColors[m.id] || defaultAppearance.linkColors[m.id], (v) => {
          appearance.linkColors[m.id] = v;
          applyAppearance();
          saveAppearance();
        })
      );
    });

    const mapTitle = document.createElement("div");
    mapTitle.className = "appearance-section-title";
    mapTitle.textContent = "Couleurs de la carte";
    body.appendChild(mapTitle);
    mapColorMeta.forEach((m) => {
      body.appendChild(
        colorRow(m.label, appearance.mapColors[m.id] || defaultAppearance.mapColors[m.id], (v) => {
          appearance.mapColors[m.id] = v;
          applyAppearance();
          saveAppearance();
        })
      );
    });
  }

  $("appearance-reset").addEventListener("click", () => {
    // eslint-disable-next-line no-alert
    if (!window.confirm("Réinitialiser toutes les couleurs et dégradés par défaut ?")) return;
    appearance = JSON.parse(JSON.stringify(defaultAppearance));
    applyAppearance();
    renderAppearancePanel();
    saveAppearance();
  });
  $("appearance-close").addEventListener("click", () => $("appearance-panel").classList.remove("open"));

  function owidIndicatorMeta(catId: string | null, indId: string | null): OwidIndicatorMeta | null {
    if (!catId || !indId) return null;
    const cat = categories.find((c) => c.id === catId);
    return cat ? cat.indicators.find((i) => i.id === indId) || null : null;
  }
  function owidEntry(iso3: string | null, indId: string | null): OwidEntry | null {
    if (!iso3 || !indId) return null;
    const c = owidData[iso3];
    return (c && c[indId]) || null;
  }

  function populateCategorySelect(sel: HTMLSelectElement) {
    sel.innerHTML = "";
    categories.forEach((cat) => {
      const opt = document.createElement("option");
      opt.value = cat.id;
      opt.textContent = cat.label + (cat.indicators.length ? "" : " (bientôt)");
      sel.appendChild(opt);
    });
  }
  function populateIndicatorSelect(sel: HTMLSelectElement, catId: string | null) {
    sel.innerHTML = "";
    const cat = categories.find((c) => c.id === catId);
    const none = document.createElement("option");
    none.value = "";
    none.textContent = "— Aucun —";
    sel.appendChild(none);
    if (!cat || !cat.indicators.length) return;
    cat.indicators.forEach((ind) => {
      const opt = document.createElement("option");
      opt.value = ind.id;
      opt.textContent = ind.label;
      sel.appendChild(opt);
    });
  }

  const indicatorCategorySelect = $("indicator-category-select") as HTMLSelectElement;
  const indicatorSelect = $("indicator-select") as HTMLSelectElement;

  function applyIndicatorToMap() {
    const { cat: catId, ind: indId } = selected;
    const meta = owidIndicatorMeta(catId, indId);
    const legend = $("indicator-legend");
    if (!meta) {
      deps.gIndicatorLayer.style("display", "none");
      legend.style.display = "none";
      return;
    }
    const features = deps.getSovFeatures();
    const values: number[] = [];
    features.forEach((f) => {
      const e = owidEntry(countryIso3(f.properties), indId);
      if (e) values.push(e.v);
    });
    if (!values.length) {
      deps.gIndicatorLayer.style("display", "none");
      legend.style.display = "none";
      return;
    }
    const min = Math.min(...values);
    const max = Math.max(...values);
    const baseColor = normalizeGradientBase(appearance.indicatorGradients[catId || ""], defaultAppearance.indicatorGradients.demographie || "#5b9fe0");
    const stops = deriveGradientFromBaseColor(baseColor, 7);
    const colorFn = gradientToColorFn(stops);
    const valueToT = max === min ? () => 0.5 : d3.scaleSqrt().domain([min, max]).range([0, 1]).clamp(true);
    $("indicator-legend-gradient").style.background = "linear-gradient(90deg, " + stops.join(", ") + ")";
    deps.gIndicatorLayer
      .selectAll<SVGPathElement, SovFeatureLike>("path")
      .data(features)
      .join("path")
      .classed("no-data", (d) => !owidEntry(countryIso3(d.properties), indId))
      .attr("d", (d) => deps.geoPath(d as unknown as GeoJSON.GeoJSON) || "")
      .attr("fill", (d) => {
        const e = owidEntry(countryIso3(d.properties), indId);
        return e ? colorFn(valueToT(e.v)) : null;
      });
    deps.gIndicatorLayer.style("display", null);
    $("indicator-legend-title").textContent = meta.label;
    $("indicator-legend-ticks").innerHTML =
      "<span>" + formatOwidNumber(min, meta.decimals) + "</span><span>" + formatOwidNumber(max, meta.decimals) + "</span>";
    $("indicator-legend-note").textContent =
      "Unité : " + meta.unit + " · dernière année disponible par pays (source : Our World in Data) · zones grisées = pas de donnée.";
    legend.style.display = "block";
  }

  const ficheValueBoxes = new Set<HTMLElement>();
  function updateFicheIndicatorValues(iso3: string | null) {
    ficheValueBoxes.forEach((box) => {
      const meta = owidIndicatorMeta(selected.cat, selected.ind);
      if (!meta) {
        box.innerHTML = "";
        return;
      }
      const e = owidEntry(iso3, selected.ind);
      if (!e) {
        box.innerHTML = '<span class="muted">Pas de donnée disponible pour ce pays.</span>';
        return;
      }
      box.innerHTML =
        '<span class="val">' +
        formatOwidNumber(e.v, meta.decimals) +
        '</span> <span class="unit">' +
        meta.unit +
        '</span><br><span class="year">données ' +
        e.y +
        "</span>";
    });
  }

  let currentFicheIso3: string | null = null;
  function setSelectedIndicator(catId: string | null, indId: string | null) {
    selected = { cat: catId, ind: indId };
    indicatorCategorySelect.value = catId || "";
    populateIndicatorSelect(indicatorSelect, catId);
    indicatorSelect.value = indId || "";
    document.querySelectorAll<HTMLSelectElement>(".fiche-indicator-category").forEach((s) => (s.value = catId || ""));
    document.querySelectorAll<HTMLSelectElement>(".fiche-indicator-select").forEach((s) => {
      populateIndicatorSelect(s, catId);
      s.value = indId || "";
    });
    applyIndicatorToMap();
    updateFicheIndicatorValues(currentFicheIso3);
  }

  indicatorCategorySelect.addEventListener("change", () => {
    populateIndicatorSelect(indicatorSelect, indicatorCategorySelect.value);
    setSelectedIndicator(indicatorCategorySelect.value, null);
  });
  indicatorSelect.addEventListener("change", () => setSelectedIndicator(indicatorCategorySelect.value, indicatorSelect.value || null));
  $("indicator-clear").addEventListener("click", () => setSelectedIndicator(indicatorCategorySelect.value, null));
  $("indicators-close").addEventListener("click", () => $("indicators-panel").classList.remove("open"));

  // -------------------------------------------------------------------------
  // Widget injecté dans la fiche pays (deps.renderFicheIndicator de
  // dossier.ts) — porté de la section "Indicateur (Our World in Data)" du
  // panneau fiche + updateFicheIndicatorValue().
  // -------------------------------------------------------------------------
  function renderFicheIndicatorWidget(container: HTMLElement, country: { isoA3: string }) {
    const staleBox = container.querySelector(".fiche-indicator-value") as HTMLElement | null;
    if (staleBox) ficheValueBoxes.delete(staleBox);
    container.innerHTML = "";
    const label = document.createElement("label");
    label.className = "field-label";
    label.textContent = "Indicateur (Our World in Data)";
    container.appendChild(label);
    const picker = document.createElement("div");
    picker.className = "owid-picker";
    const catSel = document.createElement("select");
    catSel.className = "fiche-indicator-category";
    const indSel = document.createElement("select");
    indSel.className = "fiche-indicator-select";
    picker.appendChild(catSel);
    picker.appendChild(indSel);
    container.appendChild(picker);
    const valueBox = document.createElement("div");
    valueBox.className = "fiche-indicator-value";
    container.appendChild(valueBox);
    ficheValueBoxes.add(valueBox);

    populateCategorySelect(catSel);
    catSel.value = selected.cat || (categories[0] && categories[0].id) || "";
    populateIndicatorSelect(indSel, catSel.value);
    indSel.value = selected.ind || "";
    catSel.addEventListener("change", () => {
      populateIndicatorSelect(indSel, catSel.value);
      setSelectedIndicator(catSel.value, null);
    });
    indSel.addEventListener("change", () => setSelectedIndicator(catSel.value, indSel.value || null));

    currentFicheIso3 = country.isoA3;
    updateFicheIndicatorValues(country.isoA3);
  }

  // -------------------------------------------------------------------------
  // Bootstrap
  // -------------------------------------------------------------------------
  const ready = Promise.all([
    fetch(import.meta.env.BASE_URL + "data/raw/OWID_CATEGORIES.json").then((r) => r.json()) as Promise<OwidCategory[]>,
    fetch(import.meta.env.BASE_URL + "data/raw/OWID_DATA.json").then((r) => r.json()) as Promise<Record<string, OwidCountryData>>,
    fetch(import.meta.env.BASE_URL + "data/raw/DEFAULT_APPEARANCE.json").then((r) => r.json()) as Promise<Appearance>,
    fetch(import.meta.env.BASE_URL + "data/raw/MAP_COLOR_META.json").then((r) => r.json()) as Promise<MapColorMeta[]>,
  ]).then(async ([cats, data, defAppearance, colorMeta]) => {
    categories = cats;
    owidData = data;
    defaultAppearance = defAppearance;
    appearance = JSON.parse(JSON.stringify(defAppearance));
    mapColorMeta = colorMeta;
    populateCategorySelect(indicatorCategorySelect);
    if (categories[0]) {
      indicatorCategorySelect.value = categories[0].id;
      populateIndicatorSelect(indicatorSelect, categories[0].id);
    }
    await loadAppearance();
  });

  // -------------------------------------------------------------------------
  // Comparateur de pays (src/compareExport.ts) — une ligne par indicateur
  // (toutes catégories confondues) pour un pays donné, dans l'ordre déjà
  // chargé (categories/indicators), pas de liste figée : si Martin ajoute un
  // indicateur côté JSON, il apparaît automatiquement ici aussi.
  // -------------------------------------------------------------------------
  function getCountryIndicatorRows(
    nameOrIso: { name?: string; iso_a3?: string } | string
  ): { category: string; label: string; unit: string; decimals: number; value: number | null; year: number | null }[] {
    const iso3 = typeof nameOrIso === "string" ? nameOrIso : countryIso3(nameOrIso);
    const rows: { category: string; label: string; unit: string; decimals: number; value: number | null; year: number | null }[] = [];
    categories.forEach((cat) => {
      cat.indicators.forEach((ind) => {
        const e = owidEntry(iso3, ind.id);
        rows.push({
          category: cat.label,
          label: ind.label,
          unit: ind.unit,
          decimals: ind.decimals,
          value: e ? e.v : null,
          year: e ? e.y : null,
        });
      });
    });
    return rows;
  }
  function formatCountryIndicatorValue(v: number | null, decimals: number): string {
    return v === null ? "—" : formatOwidNumber(v, decimals);
  }

  return {
    ready,
    openPanel: () => $("indicators-panel").classList.add("open"),
    closePanel: () => $("indicators-panel").classList.remove("open"),
    openAppearancePanel: () => $("appearance-panel").classList.add("open"),
    closeAppearancePanel: () => $("appearance-panel").classList.remove("open"),
    redrawOnMapChange: () => applyIndicatorToMap(),
    renderFicheIndicator: renderFicheIndicatorWidget,
    onFicheClose: () => {
      currentFicheIso3 = null;
    },
    getCountryIndicatorRows,
    formatCountryIndicatorValue,
  };
}
