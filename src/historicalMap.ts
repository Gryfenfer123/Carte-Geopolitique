// ---------------------------------------------------------------------------
// Carte historique "à la GeAcron" — demande de Martin, 2026-10-06 :
// "Possibilité de faire la carte historique, à la gaecron. Rajout d'un
// bouton en bas qui fait basculer en 'vue historique' et qui permet ensuite
// avec un curseur d'afficher l'époque souhaitée."
//
// HISTORIQUE DE CE FICHIER (pour comprendre pourquoi c'est écrit ainsi) :
// v1 (2026-10-06) : OpenHistoricalMap (OHM) en tuiles vectorielles
// continues (Leaflet.VectorGrid). Deux problèmes réels remontés par
// Martin : (a) un bug d'affichage (couches non filtrées de la tuile OHM
// dessinées en centaines de petits cercles, corrigé une première fois)
// puis (b) un problème de FOND : "c'est le fond de carte des pays
// actuels" (le fond Esri Dark Gray montrait les frontières modernes sous
// les tracés historiques) ET surtout "OpenHistoricalMap est incomplet
// niveau frontière" — un problème de SOURCE DE DONNÉES, pas de code :
// OHM est un projet communautaire façon OpenStreetMap, et sa couverture
// en tracés de frontières historiques est pleine de trous.
//
// v2 (ce fichier) : recherche menée (voir la conversation) pour trouver
// une alternative plus complète. Euratlas (dataset professionnel très
// précis) a été écarté : Europe uniquement, et payant à l'unité (160€ PAR
// SIÈCLE acheté séparément — des milliers d'euros pour couvrir l'an 1 à
// 2000 sur le monde entier, inenvisageable). La seule alternative
// gratuite, à l'échelle mondiale et avec des tracés propres et fiables
// (contrairement à OHM) est le jeu de données "historical-basemaps"
// (github.com/aourednik/historical-basemaps, licence GPL-3.0) — en
// contrepartie, ce n'est PAS un curseur continu année par année : les
// données n'existent que pour 54 années fixes (de -123000 à 2010,
// réparties ci-dessous dans HISTORICAL_YEARS), listées dans le
// index.json du dépôt. Martin a validé cette bascule explicitement
// ("Bon on part sur historical basemap pour le moment en version test",
// 2026-10-06) en connaissance de cette limite.
//
// Conséquence sur l'UI : le curseur n'est plus un <input type=range> en
// unité "année" (ça donnerait l'illusion d'un choix continu alors que la
// donnée ne l'est pas) mais en unité "INDEX dans la liste des 54 années
// disponibles" — l'étiquette affiche l'année réelle correspondante. Plus
// honnête pour l'utilisateur, et ça évite d'avoir à calculer/afficher un
// "repli sur l'année la plus proche" invisible.
//
// "Version test" (mot de Martin) : les fichiers GeoJSON sont chargés à la
// volée depuis raw.githubusercontent.com (CDN de GitHub, CORS ouvert,
// pas de clé requise) plutôt que copiés dans ce dépôt — rapide à mettre
// en place, facile à remplacer par une autre source plus tard sans
// toucher au reste du code (toute la logique de ce fichier ne dépend que
// de HISTORICAL_YEARS[i].filename et du format GeoJSON standard
// {NAME, SUBJECTO, BORDERPRECISION, PARTOF} de ce dataset).
//
// Fond de carte : remplacé par un fond "physique" (relief/océans, SANS
// frontières ni noms de pays modernes — Esri World_Physical_Map, même
// famille Esri déjà utilisée ailleurs dans l'app, gratuit, sans clé),
// conformément au retour de Martin ("fond neutre océan/relief").
//
// Reste de l'architecture (page plein écran séparée avec sa propre carte
// Leaflet, indépendante de la carte principale) inchangée depuis la
// refonte précédente — voir l'historique Git/les livraisons précédentes
// pour le détail de ce choix.
// ---------------------------------------------------------------------------

import L from "leaflet";

// Les 54 années disponibles dans historical-basemaps (lues depuis
// index.json du dépôt le 2026-10-06, triées croissant) — chaque fichier
// est un GeoJSON de polygones de territoires pour cette année-là.
// Propriétés de chaque feature : NAME (nom affiché), SUBJECTO (puissance
// coloniale/rattachement, utile pour une future carte choroplèthe),
// PARTOF (aire culturelle), BORDERPRECISION (1=approximatif,
// 2=moyennement précis, 3=déterminé par le droit international) — on
// n'utilise pour l'instant que NAME (affichage + survol).
const HISTORICAL_YEARS: { year: number; filename: string }[] = [
  { year: -123000, filename: "world_bc123000.geojson" },
  { year: -10000, filename: "world_bc10000.geojson" },
  { year: -8000, filename: "world_bc8000.geojson" },
  { year: -5000, filename: "world_bc5000.geojson" },
  { year: -4000, filename: "world_bc4000.geojson" },
  { year: -3000, filename: "world_bc3000.geojson" },
  { year: -2000, filename: "world_bc2000.geojson" },
  { year: -1500, filename: "world_bc1500.geojson" },
  { year: -1000, filename: "world_bc1000.geojson" },
  { year: -700, filename: "world_bc700.geojson" },
  { year: -500, filename: "world_bc500.geojson" },
  { year: -400, filename: "world_bc400.geojson" },
  { year: -323, filename: "world_bc323.geojson" },
  { year: -300, filename: "world_bc300.geojson" },
  { year: -200, filename: "world_bc200.geojson" },
  { year: -100, filename: "world_bc100.geojson" },
  { year: -1, filename: "world_bc1.geojson" },
  { year: 100, filename: "world_100.geojson" },
  { year: 200, filename: "world_200.geojson" },
  { year: 300, filename: "world_300.geojson" },
  { year: 400, filename: "world_400.geojson" },
  { year: 500, filename: "world_500.geojson" },
  { year: 600, filename: "world_600.geojson" },
  { year: 700, filename: "world_700.geojson" },
  { year: 800, filename: "world_800.geojson" },
  { year: 900, filename: "world_900.geojson" },
  { year: 1000, filename: "world_1000.geojson" },
  { year: 1100, filename: "world_1100.geojson" },
  { year: 1200, filename: "world_1200.geojson" },
  { year: 1279, filename: "world_1279.geojson" },
  { year: 1300, filename: "world_1300.geojson" },
  { year: 1400, filename: "world_1400.geojson" },
  { year: 1492, filename: "world_1492.geojson" },
  { year: 1500, filename: "world_1500.geojson" },
  { year: 1530, filename: "world_1530.geojson" },
  { year: 1600, filename: "world_1600.geojson" },
  { year: 1650, filename: "world_1650.geojson" },
  { year: 1700, filename: "world_1700.geojson" },
  { year: 1715, filename: "world_1715.geojson" },
  { year: 1783, filename: "world_1783.geojson" },
  { year: 1800, filename: "world_1800.geojson" },
  { year: 1815, filename: "world_1815.geojson" },
  { year: 1878, filename: "world_1878.geojson" },
  { year: 1880, filename: "world_1880.geojson" },
  { year: 1900, filename: "world_1900.geojson" },
  { year: 1914, filename: "world_1914.geojson" },
  { year: 1920, filename: "world_1920.geojson" },
  { year: 1930, filename: "world_1930.geojson" },
  { year: 1938, filename: "world_1938.geojson" },
  { year: 1945, filename: "world_1945.geojson" },
  { year: 1960, filename: "world_1960.geojson" },
  { year: 1994, filename: "world_1994.geojson" },
  { year: 2000, filename: "world_2000.geojson" },
  { year: 2010, filename: "world_2010.geojson" },
];
const HISTORICAL_DATA_BASE_URL = "https://raw.githubusercontent.com/aourednik/historical-basemaps/master/geojson/";

type HistoricalFeatureProps = {
  NAME?: string;
  SUBJECTO?: string;
  PARTOF?: string;
  BORDERPRECISION?: number;
};

const TERRITORY_STYLE = { color: "#e8b34a", weight: 1.1, fillColor: "#e8b34a", fillOpacity: 0.22, opacity: 0.85 };
const TERRITORY_HOVER_STYLE = { fillOpacity: 0.4, weight: 1.8 };

export function initHistoricalMapSystem() {
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

  const root = document.createElement("div");
  root.innerHTML = `
    <div id="historical-toggle" class="panel">
      <button id="historical-toggle-btn" title="Vue historique" aria-label="Vue historique"><svg class="icon-svg" style="width:17px;height:17px;" viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3.5 2"/></svg></button>
    </div>
    <div id="historical-view">
      <div id="historical-topbar">
        <h2 id="historical-title">Vue historique</h2>
        <div id="historical-toolbar">
          <input type="range" id="historical-slider" min="0" max="${HISTORICAL_YEARS.length - 1}" value="${HISTORICAL_YEARS.length - 1}" step="1">
          <span id="historical-slider-year"></span>
        </div>
        <button id="historical-view-close" class="close-x" aria-label="Fermer la vue historique">&times;</button>
      </div>
      <div id="historical-map-container"></div>
      <p id="historical-slider-hint" class="muted">Données : <a href="https://github.com/aourednik/historical-basemaps" target="_blank" rel="noopener">historical-basemaps</a> (A. Ourednik et contributeurs, licence GPL-3.0) — version test. ${HISTORICAL_YEARS.length} années disponibles (le curseur saute d'une année documentée à l'autre, pas de continuité totale).</p>
    </div>
  `;
  document.body.appendChild(root);

  let active = false;
  let yearIndex = HISTORICAL_YEARS.length - 1;
  let hMap: L.Map | null = null;
  let layer: L.GeoJSON | null = null;
  let loadToken = 0; // évite qu'une réponse réseau en retard (vieux curseur) n'écrase un affichage plus récent
  // Cache par nom de fichier — glisser le curseur en va-et-vient entre deux
  // années déjà vues doit être instantané, pas re-télécharger ~1 Mo à
  // chaque fois.
  const dataCache = new Map<string, Promise<GeoJSON.FeatureCollection>>();

  function formatYear(y: number): string {
    return y < 0 ? Math.abs(y) + " av. J.-C." : String(y);
  }

  function fetchYearData(filename: string): Promise<GeoJSON.FeatureCollection> {
    const cached = dataCache.get(filename);
    if (cached) return cached;
    const p = fetch(HISTORICAL_DATA_BASE_URL + filename).then((r) => {
      if (!r.ok) throw new Error("HTTP " + r.status);
      return r.json() as Promise<GeoJSON.FeatureCollection>;
    });
    dataCache.set(filename, p);
    return p;
  }

  // Carte Leaflet dédiée à la vue historique, totalement séparée de la
  // carte principale — créée paresseusement à la première ouverture, puis
  // réutilisée (jamais détruite, juste cachée/affichée via
  // #historical-view.open).
  function ensureMap(): L.Map {
    if (hMap) return hMap;
    hMap = L.map("historical-map-container", { zoomControl: true, worldCopyJump: true, minZoom: 2 }).setView([25, 10], 3);
    // Fond "physique" (relief + océans, SANS frontières ni noms de pays
    // modernes) — corrige le retour de Martin ("c'est le fond de carte
    // des pays actuelles") : même famille Esri déjà utilisée ailleurs
    // dans l'app (gratuit, sans clé), mais la couche World_Physical_Map
    // au lieu de World_Dark_Gray_Base/World_Imagery (celles-ci montrent
    // les frontières/noms politiques actuels).
    L.tileLayer(
      "https://services.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}",
      {
        attribution:
          '&copy; <a href="https://www.esri.com">Esri</a> — Esri, US National Park Service',
        maxZoom: 8,
      }
    ).addTo(hMap);
    return hMap;
  }

  function showLoading(on: boolean) {
    $("historical-slider-year").classList.toggle("loading", on);
  }

  async function renderYear(index: number) {
    const entry = HISTORICAL_YEARS[index];
    const token = ++loadToken;
    showLoading(true);
    try {
      const data = await fetchYearData(entry.filename);
      if (token !== loadToken) return; // une sélection plus récente a entre-temps pris le dessus
      const m = ensureMap();
      if (layer) m.removeLayer(layer);
      layer = L.geoJSON(data, {
        style: () => TERRITORY_STYLE,
        onEachFeature: (feature, lyr) => {
          const props = (feature.properties || {}) as HistoricalFeatureProps;
          const name = props.NAME || props.SUBJECTO || "";
          if (name) lyr.bindTooltip(name, { sticky: true, className: "historical-tooltip" });
          lyr.on("mouseover", () => (lyr as L.Path).setStyle(TERRITORY_HOVER_STYLE));
          lyr.on("mouseout", () => (lyr as L.Path).setStyle(TERRITORY_STYLE));
        },
      }).addTo(m);
      $("historical-slider-hint-error")?.remove();
    } catch (err) {
      if (token !== loadToken) return;
      console.error("Vue historique : échec du chargement de " + entry.filename, err);
      const hint = $("historical-slider-hint");
      if (hint && !document.getElementById("historical-slider-hint-error")) {
        const errEl = document.createElement("div");
        errEl.id = "historical-slider-hint-error";
        errEl.textContent = "Impossible de charger les données pour cette année (connexion réseau ?).";
        hint.prepend(errEl);
      }
    } finally {
      if (token === loadToken) showLoading(false);
    }
  }

  function activate() {
    if (active) return;
    active = true;
    $("historical-view").classList.add("open");
    $("historical-toggle-btn").classList.add("active");
    const m = ensureMap();
    // La carte était masquée (display:none) à sa création : Leaflet a
    // besoin qu'on lui redise la taille réelle de son conteneur une fois
    // visible, sans quoi elle ne couvre souvent qu'un coin de l'écran.
    window.setTimeout(() => m.invalidateSize(), 50);
    if (!layer) void renderYear(yearIndex);
  }
  function deactivate() {
    if (!active) return;
    active = false;
    $("historical-view").classList.remove("open");
    $("historical-toggle-btn").classList.remove("active");
  }

  function setYearIndex(index: number) {
    yearIndex = Math.max(0, Math.min(HISTORICAL_YEARS.length - 1, Math.round(index)));
    ($("historical-slider") as HTMLInputElement).value = String(yearIndex);
    $("historical-slider-year").textContent = formatYear(HISTORICAL_YEARS[yearIndex].year);
    if (active) void renderYear(yearIndex);
  }

  $("historical-toggle-btn").addEventListener("click", () => {
    if (active) deactivate();
    else activate();
  });
  $("historical-view-close").addEventListener("click", deactivate);
  $("historical-slider").addEventListener("input", (e) => {
    setYearIndex(parseInt((e.target as HTMLInputElement).value, 10));
  });
  setYearIndex(yearIndex);

  // openAt : point d'extension pour le lien bidirectionnel date ↔ vue
  // historique (demande de Martin : "si dans une fiche ou une frise on
  // met une date... quand je clique sur la date j'arrive sur la vue
  // historique") — câblage depuis les fiches/frises prévu dans une
  // prochaine étape. Avec des années fixes (voir en-tête), "year" est ici
  // mappé sur l'année disponible la plus proche plutôt qu'affiché tel
  // quel.
  function openAt(year: number) {
    let closestIdx = 0;
    let closestDist = Infinity;
    HISTORICAL_YEARS.forEach((entry, i) => {
      const dist = Math.abs(entry.year - year);
      if (dist < closestDist) {
        closestDist = dist;
        closestIdx = i;
      }
    });
    activate();
    setYearIndex(closestIdx);
  }

  return {
    openAt,
    isActive: () => active,
  };
}
