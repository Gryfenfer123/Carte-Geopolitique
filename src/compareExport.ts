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
// 2. exportMapAsPng() — capture #map (tuiles Leaflet + overlay SVG D3) en
//    PNG via html2canvas, avec repli en export SVG seul si le canvas est
//    "taint" par les tuiles Esri (voir le commentaire au-dessus de la
//    fonction pour le détail de ce qui est garanti vs. best-effort).
// 3. exportAllData() — un unique fichier JSON regroupant tout ce que
//    l'application connaît (groupes, liens, POI, dossiers, indicateurs),
//    via des requêtes Supabase fraîches plutôt qu'en allant lire les caches
//    internes (privés) des autres modules.
// ---------------------------------------------------------------------------

import type { SupabaseClient } from "@supabase/supabase-js";
import html2canvas from "html2canvas";
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
// Chemin principal : html2canvas(#map, {useCORS:true}) — fonctionne SI les
// tuiles Esri (services.arcgisonline.com/server.arcgisonline.com) sont
// servies avec un en-tête Access-Control-Allow-Origin permissif (ce qui est
// documenté comme étant le cas pour les services REST publics d'Esri) ET
// que les <img> de tuiles Leaflet sont chargées avec crossOrigin="anonymous"
// (voir vectorLayer/satelliteLayer dans main.ts, option ajoutée pour cette
// session). Ceci n'a PAS été vérifié dans un navigateur réel (aucun outil de
// capture d'écran dans cet environnement) : c'est le chemin "best effort"
// documenté comme tel dans PORT_STATUS.md.
//
// Si le canvas est malgré tout "tainted" par une image cross-origin
// (SecurityError à la lecture des pixels), on se rabat sur un export du
// tracé SVG seul (frontières/ports/etc., sans le fond de carte Esri), en
// fichier .svg téléchargé directement — pas de perte silencieuse.
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

function downloadSvgFallback(svgEl: SVGSVGElement, showBanner: (text: string) => void) {
  const clone = svgEl.cloneNode(true) as SVGSVGElement;
  if (!clone.getAttribute("xmlns")) clone.setAttribute("xmlns", "http://www.w3.org/2000/svg");
  const serializer = new XMLSerializer();
  const svgString = serializer.serializeToString(clone);
  downloadBlob(new Blob([svgString], { type: "image/svg+xml" }), "carte-geopolitique.svg");
  showBanner("Export PNG impossible (tuiles satellite/plan protégées) — export SVG des tracés uniquement.");
}

export async function exportMapAsPng(opts: {
  mapEl: HTMLElement;
  svgEl: SVGSVGElement;
  showBanner: (text: string) => void;
}) {
  try {
    const canvas = await html2canvas(opts.mapEl, {
      useCORS: true,
      backgroundColor: null,
      // Exclut tout contrôle Leaflet résiduel qui pourrait traîner dans
      // #map (attribution, etc.) — les vrais boutons/panneaux de l'UI sont
      // des frères de #map dans le DOM, déjà hors du sous-arbre capturé.
      ignoreElements: (el) => el.classList.contains("leaflet-control-container"),
    });
    const blob: Blob | null = await new Promise((resolve) => canvas.toBlob(resolve, "image/png"));
    if (!blob) throw new Error("toBlob a renvoyé null");
    downloadBlob(blob, "carte-geopolitique.png");
  } catch (err) {
    console.error("Export PNG échoué, repli sur l'export SVG :", err);
    downloadSvgFallback(opts.svgEl, opts.showBanner);
  }
}

// ---------------------------------------------------------------------------
// 3. Export complet des données (JSON)
// ---------------------------------------------------------------------------

export async function exportAllData(supabase: SupabaseClient) {
  const [
    groups,
    groupMembers,
    groupCategories,
    countryLinks,
    mapFeatures,
    dossierCategories,
    dossierSections,
    dossierEntries,
    indicatorCategories,
    indicators,
    indicatorValues,
  ] = await Promise.all([
    supabase.from("groups").select("*"),
    supabase.from("group_members").select("*"),
    supabase.from("group_categories").select("*"),
    supabase.from("country_links").select("*"),
    supabase.from("map_features").select("*"),
    supabase.from("dossier_categories").select("*"),
    supabase.from("dossier_sections").select("*"),
    supabase.from("dossier_entries").select("*"),
    supabase.from("indicator_categories").select("*"),
    supabase.from("indicators").select("*"),
    supabase.from("indicator_values").select("*"),
  ]);

  const payload = {
    exportedAt: new Date().toISOString(),
    groups: groups.data ?? [],
    groupMembers: groupMembers.data ?? [],
    groupCategories: groupCategories.data ?? [],
    countryLinks: countryLinks.data ?? [],
    mapFeatures: mapFeatures.data ?? [],
    dossiers: {
      categories: dossierCategories.data ?? [],
      sections: dossierSections.data ?? [],
      entries: dossierEntries.data ?? [],
    },
    indicators: {
      categories: indicatorCategories.data ?? [],
      indicators: indicators.data ?? [],
      values: indicatorValues.data ?? [],
    },
  };

  downloadBlob(
    new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" }),
    "carte-geopolitique-export.json"
  );

  const errors = [groups, groupMembers, groupCategories, countryLinks, mapFeatures, dossierCategories, dossierSections, dossierEntries, indicatorCategories, indicators, indicatorValues]
    .map((r) => r.error)
    .filter(Boolean);
  if (errors.length) console.error("Export complet : certaines tables n'ont pas pu être lues :", errors);
  return errors.length === 0;
}
