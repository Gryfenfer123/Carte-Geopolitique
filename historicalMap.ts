// ---------------------------------------------------------------------------
// Carte historique "à la GeAcron" — demande de Martin, 2026-10-06 :
// "Possibilité de faire la carte historique, à la gaecron. Rajout d'un
// bouton en bas qui fait basculer en 'vue historique' et qui permet ensuite
// avec un curseur d'afficher l'époque souhaitée."
//
// Recherche technique menée avant ce fichier (voir la conversation) :
// plusieurs sources de frontières historiques ont été comparées
// (OpenHistoricalMap, historical-basemaps/aourednik, AtlasPI, Running
// Reality). Martin a choisi explicitement la vraie continuité date par
// date (plutôt que des instantanés figés tous les quelques siècles), ce
// qui ne laisse qu'OpenHistoricalMap (OHM) comme source sérieuse : chaque
// élément y porte un start_date/end_date (ou leur équivalent numérique
// start_decdate/end_decdate) qui couvre n'importe quelle date, pas
// seulement une liste d'années prédéfinies.
//
// Contrainte technique importante : OHM distribue ses données en TUILES
// VECTORIELLES (protobuf/MVT, https://vtiles.openhistoricalmap.org/...),
// pensées pour être affichées avec MapLibre GL JS, qui a son propre plugin
// officiel de filtre par date (maplibre-gl-dates). Cet atlas est construit
// sur Leaflet (pas MapLibre) — migrer tout l'atlas vers MapLibre pour une
// seule couche aurait été un chantier énorme et risqué pour l'existant, on
// reste donc sur Leaflet (confirmé par Martin) via le plugin
// Leaflet.VectorGrid, qui sait afficher des tuiles protobuf dans Leaflet.
// En contrepartie, il n'existe PAS d'équivalent "clé en main" du filtre par
// date pour Leaflet.VectorGrid : toute la logique de filtrage ci-dessous
// (lecture de start_decdate/end_decdate sur chaque feature, masquage de
// celles hors de la date choisie) est donc recodée nous-mêmes à partir de
// la façon dont procède le plugin officiel MapLibre.
//
// Pattern du fichier : initHistoricalMapSystem(deps), même esprit que les
// autres modules (DOM construit une fois, état en closures) mais plus
// léger ici — ce module ne possède pas son propre overlay plein écran, il
// ajoute juste une couche + des contrôles par-dessus la carte Leaflet
// existante (deps.map), gérée par main.ts.
// ---------------------------------------------------------------------------

import L from "leaflet";
// leaflet.vectorgrid n'a pas de types officiels (plugin UMD qui étend la
// globale L) — voir src/leaflet-vectorgrid.d.ts pour la déclaration
// minimale ambient qui permet de l'utiliser sans "any" partout.
import "leaflet.vectorgrid";

const OHM_TILE_URL = "https://vtiles.openhistoricalmap.org/maps/osm/{z}/{x}/{y}.pbf";
// Couche contenant les polygones de territoires/frontières dans les tuiles
// OHM (confirmé par la recherche technique, forum OHM) — les autres
// couches (points, routes, etc.) ne nous intéressent pas pour une "vue
// historique" centrée sur les territoires.
const OHM_TERRITORY_LAYER = "land_ohm_lines";

// Bornes larges par défaut du curseur — l'essentiel de la donnée OHM
// couvre l'Antiquité à aujourd'hui ; au-delà, la couverture devient trop
// clairsemée pour être utile (projet communautaire, comme OpenStreetMap :
// "des trous inévitables là où personne n'a encore contribué", comme
// discuté avec Martin).
const MIN_YEAR = -3000;
const MAX_YEAR = new Date().getFullYear();

type OhmFeatureProps = {
  name?: string;
  start_date?: string;
  end_date?: string;
  start_decdate?: number;
  end_decdate?: number;
};

// Convertit un start_date/end_date texte (format OHM : "YYYY", "YYYY-MM"
// ou "YYYY-MM-DD", éventuellement négatif pour l'avant J.-C.) en année
// décimale approximative — repli utilisé seulement quand
// start_decdate/end_decdate (déjà numériques, prioritaires) sont absents,
// même ordre de priorité que le plugin officiel OHM (maplibre-gl-dates).
function parseDecYear(dateStr: string | undefined): number | null {
  if (!dateStr) return null;
  const m = /^(-?\d+)(?:-(\d{2}))?(?:-(\d{2}))?/.exec(dateStr.trim());
  if (!m) return null;
  const year = parseInt(m[1], 10);
  if (Number.isNaN(year)) return null;
  const month = m[2] ? parseInt(m[2], 10) : 1;
  return year + (month - 1) / 12;
}
function featureStart(props: OhmFeatureProps): number {
  if (typeof props.start_decdate === "number") return props.start_decdate;
  return parseDecYear(props.start_date) ?? -Infinity;
}
function featureEnd(props: OhmFeatureProps): number {
  if (typeof props.end_decdate === "number") return props.end_decdate;
  return parseDecYear(props.end_date) ?? Infinity;
}

// Style des territoires affichés — couleurs neutres (l'essentiel est le
// tracé des frontières, pas un choroplèthe par pays à ce stade ; un
// code-couleur par puissance coloniale/territoire pourra être ajouté plus
// tard si Martin le demande, une fois la V1 validée).
const TERRITORY_STYLE = { color: "#e8b34a", weight: 1.3, fillColor: "#e8b34a", fillOpacity: 0.12, opacity: 0.8 };

export function initHistoricalMapSystem(deps: { map: L.Map }) {
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

  const root = document.createElement("div");
  root.innerHTML = `
    <div id="historical-toggle" class="panel">
      <button id="historical-toggle-btn" title="Vue historique" aria-label="Vue historique"><svg class="icon-svg" style="width:17px;height:17px;" viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3.5 2"/></svg></button>
    </div>
    <div id="historical-slider-panel" class="panel">
      <button id="historical-slider-close" class="close-x" aria-label="Fermer la vue historique">&times;</button>
      <div id="historical-slider-row">
        <input type="range" id="historical-slider" min="${MIN_YEAR}" max="${MAX_YEAR}" value="${MAX_YEAR}" step="1">
        <span id="historical-slider-year"></span>
      </div>
      <div id="historical-slider-hint" class="muted">Données : <a href="https://www.openhistoricalmap.org/" target="_blank" rel="noopener">OpenHistoricalMap</a> (contributeurs OHM et OpenStreetMap, domaine public) — couverture très inégale selon les époques et les régions.</div>
    </div>
  `;
  document.body.appendChild(root);

  let active = false;
  let currentYear = MAX_YEAR;
  let layer: L.Layer | null = null;
  // Cache des tuiles déjà récupérées/décodées (clé "z/x/y") — le plugin
  // Leaflet.VectorGrid refait un fetch réseau + un décodage protobuf à
  // CHAQUE appel de redraw() (nécessaire pour réévaluer le filtre par
  // date), ce qui serait beaucoup trop lourd si on redessinait à chaque
  // frappe/glissement du curseur. On intercepte _getVectorTilePromise
  // (méthode interne du plugin, voir node_modules/leaflet.vectorgrid) pour
  // réutiliser la tuile déjà décodée : seul le STYLE est recalculé à
  // chaque changement de date, jamais le réseau/décodage.
  const tileCache = new Map<string, Promise<unknown>>();

  function formatYear(y: number): string {
    return y < 0 ? Math.abs(y) + " av. J.-C." : String(y);
  }

  function styleForFeature(props: OhmFeatureProps): object[] {
    const start = featureStart(props);
    const end = featureEnd(props);
    if (currentYear < start || currentYear > end) return []; // masqué : hors de la période choisie
    return [TERRITORY_STYLE];
  }

  function createLayer(): L.Layer {
    // leaflet.vectorgrid étend la globale L mais n'a pas de types officiels
    // (voir le commentaire d'en-tête + src/leaflet-vectorgrid.d.ts) — cast
    // ponctuel nécessaire ici pour accéder à L.vectorGrid.protobuf et pour
    // la méthode interne qu'on intercepte juste après.
    const vg = (L as unknown as { vectorGrid: { protobuf: (url: string, opts: Record<string, unknown>) => L.Layer } }).vectorGrid.protobuf(
      OHM_TILE_URL,
      {
        vectorTileLayerStyles: {
          [OHM_TERRITORY_LAYER]: (props: OhmFeatureProps) => styleForFeature(props),
        },
        interactive: true,
        maxNativeZoom: 14,
        // Les tuiles OHM empilent toute l'histoire dans chaque tuile (pour
        // permettre un filtre purement côté client, sans requête par
        // date) — notablement plus lourdes que des tuiles courantes,
        // d'où le cache ci-dessous plutôt qu'un simple TileLayer.
      }
    );
    const vgAny = vg as unknown as { _getVectorTilePromise: (coords: { x: number; y: number; z: number }) => Promise<unknown> };
    const original = vgAny._getVectorTilePromise.bind(vgAny);
    vgAny._getVectorTilePromise = (coords: { x: number; y: number; z: number }) => {
      const key = coords.z + "/" + coords.x + "/" + coords.y;
      const cached = tileCache.get(key);
      if (cached) return cached;
      const p = original(coords);
      tileCache.set(key, p);
      return p;
    };
    return vg;
  }

  let redrawTimer: number | null = null;
  function scheduleRedraw() {
    // Le navigateur envoie un flot continu d'événements "input" pendant
    // qu'on glisse le curseur — redessiner à chaque fois forcerait un
    // recalcul de style (et un nouveau rendu SVG) de centaines de features
    // par frame. Un court débounce (~100ms) garde l'interaction fluide
    // tout en restant quasi instantané pour l'utilisateur.
    if (redrawTimer) window.clearTimeout(redrawTimer);
    redrawTimer = window.setTimeout(() => {
      (layer as unknown as { redraw?: () => void } | null)?.redraw?.();
    }, 100);
  }

  function activate() {
    if (active) return;
    active = true;
    if (!layer) layer = createLayer();
    layer.addTo(deps.map);
    $("historical-toggle-btn").classList.add("active");
    $("historical-slider-panel").classList.add("open");
  }
  function deactivate() {
    if (!active) return;
    active = false;
    if (layer) deps.map.removeLayer(layer);
    $("historical-toggle-btn").classList.remove("active");
    $("historical-slider-panel").classList.remove("open");
  }

  function setYear(year: number) {
    currentYear = Math.max(MIN_YEAR, Math.min(MAX_YEAR, Math.round(year)));
    ($("historical-slider") as HTMLInputElement).value = String(currentYear);
    $("historical-slider-year").textContent = formatYear(currentYear);
    if (active) scheduleRedraw();
  }

  $("historical-toggle-btn").addEventListener("click", () => {
    if (active) deactivate();
    else activate();
  });
  $("historical-slider-close").addEventListener("click", deactivate);
  $("historical-slider").addEventListener("input", (e) => {
    setYear(parseInt((e.target as HTMLInputElement).value, 10));
  });
  setYear(currentYear);

  // setDate/openAt : point d'extension pour le lien bidirectionnel
  // date ↔ vue historique (demande de Martin : "si dans une fiche ou une
  // frise on met une date... quand je clique sur la date j'arrive sur la
  // vue historique") — câblage depuis les fiches/frises prévu dans une
  // prochaine étape (voir le résumé livré avec ce fichier), cette fonction
  // est déjà prête à être appelée depuis main.ts à ce moment-là.
  function openAt(year: number) {
    activate();
    setYear(year);
  }

  return {
    openAt,
    isActive: () => active,
  };
}
