// ---------------------------------------------------------------------------
// Comparateur de pays + export PNG de la carte + export complet des données
// — nouveau système (session du 2026-10-02, voir PORT_STATUS.md). Trois
// fonctionnalités indépendantes regroupées dans un seul fichier (elles
// partagent peu de code mais sont toutes les trois de petits ajouts isolés,
// pas de raison de multiplier les modules) :
//
// 1. initCompareSystem() — panneau latéral #compare-panel : deux champs de
//    recherche de pays (même principe que #search mais local au panneau,
//    pas de réutilisation directe de src/search.ts qui est câblé sur sa
//    propre modale plein écran) + un tableau comparatif réutilisant les
//    indicateurs déjà chargés par src/indicators.ts (getCountryIndicatorRows,
//    ajouté dans ce fichier pour cette session) plutôt qu'un second modèle
//    de données.
// 2. exportMapAsPng() — assemble #map (tuiles Leaflet + overlay SVG D3) sur
//    un <canvas> puis le télécharge en PNG, avec repli en export SVG seul si
//    le canvas est "taint" par les tuiles Esri (voir le commentaire au-dessus
//    de la fonction pour le détail).
// 3. exportAllData() — un unique fichier JSON regroupant tout ce que
//    l'application connaît (groupes, liens, POI, dossiers, indicateurs),
//    via des requêtes Supabase fraîches plutôt qu'en allant lire les caches
//    internes (privés) des autres modules.
// ---------------------------------------------------------------------------

import { frenchCountryName, flagSvgSpan } from "./countryNames";
import { normalizeSearch } from "./search";

export type CompareCountry = { isoA3: string; slug: string; name: string; continent: string; iso2: string | null };

type IndicatorRow = { category: string; label: string; unit: string; decimals: number; value: number | null; year: number | null };

// ---------------------------------------------------------------------------
// 1. Comparateur
// ---------------------------------------------------------------------------

export function initCompareSystem(deps: {
  getAllCountries: () => CompareCountry[];
  getCountryIndicatorRows: (c: { name: string; iso_a3: string }) => IndicatorRow[];
  formatIndicatorValue: (v: number | null, decimals: number) => string;
}) {
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

  const root = document.createElement("div");
  root.innerHTML = `
    <div id="compare-panel" class="panel side-panel">
      <button class="close-x" id="compare-close" aria-label="Fermer">&times;</button>
      <h2>Comparer deux pays</h2>
      <p class="muted">Choisissez deux pays pour comparer leurs indicateurs (Our World in Data) côte à côte.</p>
      <div class="compare-pickers">
        <div class="compare-picker">
          <input type="text" id="compare-input-a" placeholder="Premier pays…" autocomplete="off">
          <div class="compare-results" id="compare-results-a"></div>
        </div>
        <div class="compare-picker">
          <input type="text" id="compare-input-b" placeholder="Second pays…" autocomplete="off">
          <div class="compare-results" id="compare-results-b"></div>
        </div>
      </div>
      <div id="compare-table-wrap"></div>
    </div>
  `;
  while (root.firstChild) document.body.appendChild(root.firstChild);

  let countryA: CompareCountry | null = null;
  let countryB: CompareCountry | null = null;

  function setupPicker(inputId: string, resultsId: string, onPick: (c: CompareCountry) => void) {
    const input = $(inputId) as HTMLInputElement;
    const results = $(resultsId);
    function render() {
      const q = normalizeSearch(input.value.trim());
      results.innerHTML = "";
      if (!q) {
        results.classList.remove("open");
        return;
      }
      const matches = deps
        .getAllCountries()
        .map((c) => ({ c, label: frenchCountryName(c.name) }))
        .filter(({ c, label }) => normalizeSearch(label).includes(q) || normalizeSearch(c.name).includes(q))
        .slice(0, 8);
      if (!matches.length) {
        results.classList.remove("open");
        return;
      }
      matches.forEach(({ c, label }) => {
        const btn = document.createElement("button");
        btn.type = "button";
        const flag = flagSvgSpan(c.slug, c.iso2);
        if (flag) btn.appendChild(flag);
        btn.appendChild(document.createTextNode(" " + label));
        btn.addEventListener("click", () => {
          input.value = label;
          results.classList.remove("open");
          onPick(c);
        });
        results.appendChild(btn);
      });
      results.classList.add("open");
    }
    input.addEventListener("input", render);
    input.addEventListener("focus", render);
    document.addEventListener("click", (e) => {
      if (!results.contains(e.target as Node) && e.target !== input) results.classList.remove("open");
    });
  }

  setupPicker("compare-input-a", "compare-results-a", (c) => {
    countryA = c;
    renderTable();
  });
  setupPicker("compare-input-b", "compare-results-b", (c) => {
    countryB = c;
    renderTable();
  });

  function renderTable() {
    const wrap = $("compare-table-wrap");
    wrap.innerHTML = "";
    if (!countryA || !countryB) return;

    const rowsA = deps.getCountryIndicatorRows({ name: countryA.name, iso_a3: countryA.isoA3 });
    const rowsB = deps.getCountryIndicatorRows({ name: countryB.name, iso_a3: countryB.isoA3 });

    const table = document.createElement("table");
    table.className = "compare-table";

    const head = document.createElement("tr");
    head.innerHTML = `<th></th><th>${escapeHtml(frenchCountryName(countryA.name))}</th><th>${escapeHtml(
      frenchCountryName(countryB.name)
    )}</th>`;
    table.appendChild(head);

    let lastCategory = "";
    rowsA.forEach((rowA, i) => {
      const rowB = rowsB[i];
      if (rowA.category !== lastCategory) {
        lastCategory = rowA.category;
        const catTr = document.createElement("tr");
        catTr.className = "compare-cat-row";
        const td = document.createElement("td");
        td.colSpan = 3;
        td.textContent = rowA.category;
        catTr.appendChild(td);
        table.appendChild(catTr);
      }
      const tr = document.createElement("tr");
      const labelTd = document.createElement("td");
      labelTd.textContent = rowA.label + (rowA.unit ? " (" + rowA.unit + ")" : "");
      const aTd = document.createElement("td");
      aTd.textContent = deps.formatIndicatorValue(rowA.value, rowA.decimals);
      const bTd = document.createElement("td");
      bTd.textContent = deps.formatIndicatorValue(rowB ? rowB.value : null, rowA.decimals);
      // Petite barre comparative inline quand les deux valeurs sont des
      // nombres positifs — simple indication visuelle, pas un graphique.
      if (rowA.value !== null && rowB && rowB.value !== null && rowA.value >= 0 && rowB.value >= 0) {
        const max = Math.max(rowA.value, rowB.value) || 1;
        aTd.appendChild(compareBar(rowA.value / max));
        bTd.appendChild(compareBar(rowB.value / max));
      }
      tr.append(labelTd, aTd, bTd);
      table.appendChild(tr);
    });

    wrap.appendChild(table);
  }

  function compareBar(ratio: number): HTMLElement {
    const bar = document.createElement("div");
    bar.className = "compare-bar";
    const fill = document.createElement("div");
    fill.className = "compare-bar-fill";
    fill.style.width = Math.max(2, Math.round(ratio * 100)) + "%";
    bar.appendChild(fill);
    return bar;
  }

  $("compare-close").addEventListener("click", () => $("compare-panel").classList.remove("open"));

  return {
    openPanel: () => $("compare-panel").classList.add("open"),
    closePanel: () => $("compare-panel").classList.remove("open"),
  };
}

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

// ---------------------------------------------------------------------------
// 2. Export de la carte en PNG
// ---------------------------------------------------------------------------
//
// Assemblage direct sur un <canvas>, SANS html2canvas (2026-10-21) :
// html2canvas plaçait mal le calque SVG des pays (frontières, couleurs des
// indicateurs, ports...) par rapport aux tuiles dès que la carte avait été
// déplacée ou zoomée — le tracé se retrouvait décalé de plusieurs centaines
// de pixels sur le fond satellite. On dessine donc nous-mêmes, dans l'ordre :
//   1. les tuiles <img class="leaflet-tile">, à leur position réelle mesurée
//      par getBoundingClientRect() (qui inclut déjà les transformations
//      CSS du pane Leaflet) ;
//   2. le SVG de superposition, sérialisé avec ses styles calculés recopiés
//      en ligne (une image SVG autonome ne voit pas style.css), à sa propre
//      position réelle mesurée de la même façon.
// Les deux sont donc forcément alignés comme à l'écran.
//
// Les tuiles Esri sont servies avec un en-tête CORS permissif et chargées en
// crossOrigin="anonymous" (voir main.ts) : le canvas n'est pas "taint". Si
// malgré tout il l'était (SecurityError à toBlob), on se rabat sur un export
// du tracé SVG seul (sans fond de carte), pas de perte silencieuse.
function downloadBlob(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 2000);
}

// Propriétés de présentation SVG recopiées en ligne sur chaque élément du
// clone : tout ce que style.css ou D3 peut avoir fixé et qui change le rendu.
const SVG_STYLE_PROPS = [
  "display",
  "visibility",
  "opacity",
  "fill",
  "fill-opacity",
  "fill-rule",
  "stroke",
  "stroke-width",
  "stroke-opacity",
  "stroke-dasharray",
  "stroke-dashoffset",
  "stroke-linecap",
  "stroke-linejoin",
  "stroke-miterlimit",
  "paint-order",
  "vector-effect",
  "font-family",
  "font-size",
  "font-weight",
  "font-style",
  "letter-spacing",
  "text-anchor",
  "dominant-baseline",
];

// Clone autonome du SVG de superposition : mêmes dimensions que celles
// affichées, styles calculés recopiés en ligne, sans le positionnement CSS
// (left/top) qui ne sert qu'à l'écran.
function buildStyledSvgClone(svgEl: SVGSVGElement): SVGSVGElement {
  const clone = svgEl.cloneNode(true) as SVGSVGElement;
  const srcEls: Element[] = [svgEl, ...Array.from(svgEl.querySelectorAll("*"))];
  const dstEls: Element[] = [clone, ...Array.from(clone.querySelectorAll("*"))];
  for (let i = 0; i < srcEls.length; i++) {
    const cs = getComputedStyle(srcEls[i]);
    const dst = dstEls[i] as SVGElement;
    for (const prop of SVG_STYLE_PROPS) {
      dst.style.setProperty(prop, cs.getPropertyValue(prop));
    }
  }
  const r = svgEl.getBoundingClientRect();
  clone.setAttribute("xmlns", "http://www.w3.org/2000/svg");
  clone.setAttribute("width", String(r.width));
  clone.setAttribute("height", String(r.height));
  clone.style.removeProperty("left");
  clone.style.removeProperty("top");
  clone.style.removeProperty("position");
  return clone;
}

// Opacité effective d'un élément (produit de celles de ses ancêtres jusqu'à
// `stopAt`) ; 0 s'il est masqué. Les couches Satellite/Vectoriel sont
// basculées par opacité côté Leaflet : une couche cachée ne doit pas sortir.
function effectiveOpacity(el: Element, stopAt: Element): number {
  let o = 1;
  for (let n: Element | null = el; n && n !== stopAt; n = n.parentElement) {
    const cs = getComputedStyle(n);
    if (cs.display === "none" || cs.visibility === "hidden") return 0;
    o *= parseFloat(cs.opacity || "1");
  }
  return o;
}

function loadImage(url: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = () => reject(new Error("Chargement de l'image SVG du tracé impossible"));
    img.src = url;
  });
}

async function renderMapToCanvas(mapEl: HTMLElement, svgEl: SVGSVGElement): Promise<HTMLCanvasElement> {
  const rect = mapEl.getBoundingClientRect();
  const scale = Math.min(window.devicePixelRatio || 1, 2);
  const canvas = document.createElement("canvas");
  canvas.width = Math.round(rect.width * scale);
  canvas.height = Math.round(rect.height * scale);
  const ctx = canvas.getContext("2d");
  if (!ctx) throw new Error("Contexte 2D du canvas indisponible");
  ctx.scale(scale, scale);

  // Fond du conteneur (visible là où aucune tuile n'est chargée).
  const bg = getComputedStyle(mapEl).backgroundColor;
  if (bg && bg !== "rgba(0, 0, 0, 0)" && bg !== "transparent") {
    ctx.fillStyle = bg;
    ctx.fillRect(0, 0, rect.width, rect.height);
  }

  // 1. Tuiles, dans l'ordre du DOM (= ordre d'empilement des couches).
  const tiles = Array.from(mapEl.querySelectorAll<HTMLImageElement>("img.leaflet-tile"));
  for (const img of tiles) {
    if (!img.complete || img.naturalWidth === 0) continue;
    const op = effectiveOpacity(img, mapEl);
    if (op <= 0) continue;
    const r = img.getBoundingClientRect();
    // +1px de débordement pour éviter la couture entre tuiles voisines (sauf
    // si la tuile est translucide, où le recouvrement se verrait).
    const grow = op >= 1 ? 1 : 0;
    ctx.globalAlpha = op;
    ctx.drawImage(img, r.left - rect.left, r.top - rect.top, r.width + grow, r.height + grow);
  }
  ctx.globalAlpha = 1;

  // 2. Calque SVG (pays, indicateurs, ports, liens, POI...).
  const clone = buildStyledSvgClone(svgEl);
  const svgString = new XMLSerializer().serializeToString(clone);
  const svgUrl = URL.createObjectURL(new Blob([svgString], { type: "image/svg+xml;charset=utf-8" }));
  try {
    const svgImg = await loadImage(svgUrl);
    const sr = svgEl.getBoundingClientRect();
    ctx.drawImage(svgImg, sr.left - rect.left, sr.top - rect.top, sr.width, sr.height);
  } finally {
    URL.revokeObjectURL(svgUrl);
  }
  return canvas;
}

function downloadSvgFallback(svgEl: SVGSVGElement, showBanner: (text: string) => void) {
  const svgString = new XMLSerializer().serializeToString(buildStyledSvgClone(svgEl));
  downloadBlob(new Blob([svgString], { type: "image/svg+xml" }), "carte-geopolitique.svg");
  showBanner("Export PNG impossible (tuiles satellite/plan protégées) — export SVG des tracés uniquement.");
}

export async function exportMapAsPng(opts: {
  mapEl: HTMLElement;
  svgEl: SVGSVGElement;
  showBanner: (text: string) => void;
}) {
  try {
    const canvas = await renderMapToCanvas(opts.mapEl, opts.svgEl);
    const blob: Blob | null = await new Promise((resolve) => canvas.toBlob(resolve, "image/png"));
    if (!blob) throw new Error("toBlob a renvoyé null");
    downloadBlob(blob, "carte-geopolitique.png");
  } catch (err) {
    console.error("Export PNG échoué, repli sur l'export SVG :", err);
    downloadSvgFallback(opts.svgEl, opts.showBanner);
  }
}

// ---------------------------------------------------------------------------
// Export du planisphère complet (indépendant du zoom et de la position) :
// le monde est redessiné à part sur un canvas, à partir des géométries des
// pays, avec les couleurs d'indicateur actuellement affichées.
// ---------------------------------------------------------------------------
export async function exportWorldAsPng(opts: {
  features: GeoJSON.Feature[];
  isoOf: (f: GeoJSON.Feature) => string;
  // Couleur de remplissage d'indicateur d'un pays (null = pas de donnée / pas d'indicateur).
  indicatorFill: (iso: string) => string | null;
  indicatorActive: boolean;
  land: { fill: string; opacity: number; border: string; background: string; text: string };
  legend: { title: string; gradient: string[]; min: string; max: string } | null;
  showBanner: (text: string) => void;
}) {
  try {
    const d3 = await import("d3");
    const W = 2800;
    const mapH = 1450;
    const legendH = 0;
    const canvas = document.createElement("canvas");
    canvas.width = W;
    canvas.height = mapH + legendH;
    const ctx = canvas.getContext("2d");
    if (!ctx) throw new Error("Contexte 2D indisponible");
    ctx.fillStyle = "#cfe0ee";
    ctx.fillRect(0, 0, W, canvas.height);
    const collection = { type: "FeatureCollection", features: opts.features } as GeoJSON.FeatureCollection;
    const projection = d3.geoNaturalEarth1().fitExtent(
      [
        [10, 10],
        [W - 10, mapH - 10],
      ],
      { type: "Sphere" } as unknown as d3.GeoPermissibleObjects
    );
    const path = d3.geoPath(projection, ctx);
    // Océan.
    ctx.beginPath();
    path({ type: "Sphere" } as d3.GeoPermissibleObjects);
    ctx.fillStyle = "#cfe0ee";
    ctx.fill();
    void collection;
    for (const f of opts.features) {
      const iso = opts.isoOf(f);
      const col = opts.indicatorActive ? opts.indicatorFill(iso) : null;
      ctx.beginPath();
      path(f as d3.GeoPermissibleObjects);
      if (col) {
        ctx.globalAlpha = 1;
        ctx.fillStyle = col;
      } else if (opts.indicatorActive) {
        ctx.globalAlpha = 1;
        ctx.fillStyle = "#d9d9d9";
      } else {
        ctx.globalAlpha = 1;
        ctx.fillStyle = opts.land.fill;
      }
      ctx.fill();
      ctx.globalAlpha = 1;
      ctx.strokeStyle = "#4a4a4a";
      ctx.lineWidth = 1;
      ctx.stroke();
    }
    if (opts.legend) {
      const lw = 640;
      const pw = lw + 70;
      const ph = 160;
      const px = 40;
      const py = mapH - ph - 40;
      ctx.fillStyle = "rgba(255,255,255,0.88)";
      ctx.beginPath();
      ctx.roundRect(px, py, pw, ph, 18);
      ctx.fill();
      const lx = px + 35;
      const ly = py + 20;
      ctx.fillStyle = "#222222";
      ctx.font = "600 34px 'IBM Plex Sans', sans-serif";
      ctx.fillText(opts.legend.title, lx, ly + 34);
      const g = ctx.createLinearGradient(lx, 0, lx + lw, 0);
      opts.legend.gradient.forEach((c, i, a) => g.addColorStop(a.length > 1 ? i / (a.length - 1) : 0, c));
      ctx.fillStyle = g;
      ctx.fillRect(lx, ly + 54, lw, 24);
      ctx.fillStyle = "#222222";
      ctx.font = "28px 'IBM Plex Sans', sans-serif";
      ctx.textAlign = "left";
      ctx.fillText(opts.legend.min, lx, ly + 116);
      ctx.textAlign = "right";
      ctx.fillText(opts.legend.max, lx + lw, ly + 116);
      ctx.textAlign = "left";
    }
    const blob: Blob | null = await new Promise((resolve) => canvas.toBlob(resolve, "image/png"));
    if (!blob) throw new Error("toBlob a renvoyé null");
    downloadBlob(blob, "planisphere-geopolitique.png");
  } catch (err) {
    console.error("Export du planisphère échoué :", err);
    opts.showBanner("Export impossible : " + (err instanceof Error ? err.message : "erreur inconnue"));
  }
}
