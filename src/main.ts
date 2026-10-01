import "./style.css";
import L from "leaflet";
import * as d3 from "d3";
import * as topojson from "topojson-client";
import { supabase } from "./supabase";
import type { Session } from "@supabase/supabase-js";
import { createGeoBridge } from "./geobridge";
import { initFicheDossierSystem, type CountryRef } from "./dossier";
import { initGroupsSystem } from "./groups";
import { initIndicatorsSystem, type SovFeatureLike } from "./indicators";
import { initLinksSystem, type LinkEntityKind } from "./links";
import { ensureEncyclopedieSeed } from "./encyclopedie";
import { initSearchSystem, normalizeSearch, type StaticSearchEntry } from "./search";
import { frenchCountryName } from "./countryNames";

// ---------------------------------------------------------------------------
// App shell
// ---------------------------------------------------------------------------

const app = document.querySelector<HTMLDivElement>("#app")!;
app.innerHTML = `
  <header class="app-header">
    <div class="brand">
      <span class="mark">Carte Géopolitique</span>
      <span class="sub">Prototype moteur tuiles</span>
    </div>
    <div class="header-right">
      <span class="badge">Preview</span>
      <button id="dossier-search-btn" class="auth-trigger" type="button">Recherche dans les dossiers</button>
      <button id="groups-btn" class="auth-trigger" type="button">Groupes</button>
      <button id="indicators-btn" class="auth-trigger" type="button">Indicateurs</button>
      <button id="chronologie-btn" class="auth-trigger" type="button">Chronologie</button>
      <button id="appearance-btn" class="auth-trigger" type="button">Apparence</button>
      <button id="encyclopedie-btn" class="auth-trigger" type="button">Encyclop&eacute;die</button>
      <button id="auth-trigger" class="auth-trigger" type="button">Se connecter</button>
    </div>
  </header>
  <main class="map-wrap">
    <div id="map"></div>
    <div id="search">
      <input id="search-input" type="text" placeholder="Rechercher un pays…" autocomplete="off">
      <div id="search-results"></div>
    </div>
    <div id="map-legend" class="map-legend">
      <span class="legend-chip static"><span class="legend-swatch land"></span>Etats reconnus</span>
      <label class="legend-chip"><input type="checkbox" id="toggle-disputed" /><span class="legend-swatch outline"></span>Statut contesté</label>
      <label class="legend-chip"><input type="checkbox" id="toggle-cities" /><span class="legend-swatch dot-city"></span>Capitales</label>
      <label class="legend-chip"><input type="checkbox" id="toggle-ports" /><span class="legend-swatch dot-port"></span>Grands ports (Top 40)</label>
      <label class="legend-chip"><input type="checkbox" id="toggle-straits" /><span class="legend-swatch diamond"></span>Détroits</label>
      <label class="legend-chip"><input type="checkbox" id="toggle-pipelines" /><span class="legend-swatch line"></span>Pipelines</label>
      <label class="legend-chip"><input type="checkbox" id="toggle-bases" /><span class="legend-swatch dot-base"></span>Bases militaires étrangères</label>
      <label class="legend-chip"><input type="checkbox" id="toggle-cables" /><span class="legend-swatch line cable"></span>Câbles sous-marins</label>
      <label class="legend-chip"><input type="checkbox" id="toggle-rivers-lakes" /><span class="legend-swatch line river"></span>Fleuves &amp; lacs</label>
      <label class="legend-chip"><input type="checkbox" id="toggle-all-links" /><span class="legend-swatch line accent"></span>Tous les liens (historique)</label>
      <div id="timeline-bar">
        <div class="timeline-top">
          <span>Frise chronologique des liens</span>
          <span id="timeline-count" class="muted"></span>
        </div>
        <div class="rs-track" data-rs="track">
          <div class="rs-fill" data-rs="fill"></div>
          <div class="rs-handle rs-handle-start" data-rs="handle-start" tabindex="0"><span class="rs-label" data-rs="label-start"></span></div>
          <div class="rs-handle rs-handle-end" data-rs="handle-end" tabindex="0"><span class="rs-label" data-rs="label-end"></span></div>
        </div>
      </div>
    </div>
    <div id="entity-tooltip" class="entity-tooltip"></div>
    <div id="group-add-banner"></div>
    <aside class="side-panel">
      <h2 id="panel-title">Aucun pays sélectionné</h2>
      <div id="panel-body" class="empty">
        Cliquez sur un pays pour afficher ses informations ici. Ceci est une
        maquette de l'interaction — les fiches complètes seront reliées à
        cette vue plus tard.
      </div>
    </aside>
    <div class="auth-panel" id="auth-panel" hidden>
      <button class="auth-close" id="auth-close" type="button" aria-label="Fermer">&times;</button>
      <div id="auth-panel-body"></div>
    </div>
    <div class="tile-fallback-note" id="tile-fallback">
      Les tuiles de fond de carte n'ont pas pu être chargées (réseau
      indisponible). Les frontières restent affichées sur fond sombre.
    </div>
    <div class="hint">
      <strong>Prototype</strong> — molette pour zoomer, glisser pour
      déplacer. Fond de carte CARTO Dark Matter + frontières des pays en
      superposition.
    </div>
  </main>
`;

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

type Profile = { id: string; username: string | null; role: string };

let currentSession: Session | null = null;
let currentProfile: Profile | null = null;
let authMode: "signin" | "signup" = "signin";

const authTrigger = document.getElementById("auth-trigger")! as HTMLButtonElement;
const authPanel = document.getElementById("auth-panel")! as HTMLDivElement;
const authPanelBody = document.getElementById("auth-panel-body")! as HTMLDivElement;
const authClose = document.getElementById("auth-close")! as HTMLButtonElement;

function frenchAuthError(message: string): string {
  const m = message.toLowerCase();
  if (m.includes("invalid login credentials")) {
    return "Adresse e-mail ou mot de passe incorrect.";
  }
  if (m.includes("user already registered") || m.includes("already registered")) {
    return "Un compte existe déjà avec cette adresse e-mail.";
  }
  if (m.includes("password should be at least") || m.includes("at least 6")) {
    return "Le mot de passe doit contenir au moins 6 caractères.";
  }
  if (m.includes("unable to validate email") || m.includes("invalid email")) {
    return "Adresse e-mail invalide.";
  }
  if (m.includes("email not confirmed")) {
    return "Adresse e-mail non confirmée. Vérifiez votre boîte de réception.";
  }
  return "Une erreur est survenue. Veuillez réessayer.";
}

function renderAuthPanel() {
  if (currentSession) {
    const label = currentProfile?.username || currentSession.user.email || "Compte";
    authPanelBody.innerHTML = `
      <h3>Connecté</h3>
      <p class="auth-user">${label}${
      currentProfile ? ` <span class="role-tag">${currentProfile.role}</span>` : ""
    }</p>
      <button id="auth-signout" class="auth-submit" type="button">Se déconnecter</button>
    `;
    document.getElementById("auth-signout")!.addEventListener("click", async () => {
      await supabase.auth.signOut();
    });
    return;
  }

  const isSignup = authMode === "signup";
  authPanelBody.innerHTML = `
    <h3>${isSignup ? "Créer un compte" : "Se connecter"}</h3>
    <form id="auth-form" class="auth-form">
      <label>
        E-mail
        <input type="email" name="email" required autocomplete="email" />
      </label>
      <label>
        Mot de passe
        <input type="password" name="password" required autocomplete="${
          isSignup ? "new-password" : "current-password"
        }" minlength="6" />
      </label>
      <div class="auth-error" id="auth-error" hidden></div>
      <button type="submit" class="auth-submit">${
        isSignup ? "Créer le compte" : "Se connecter"
      }</button>
    </form>
    <button type="button" class="auth-switch" id="auth-switch">${
      isSignup
        ? "Déjà un compte ? Se connecter"
        : "Pas de compte ? Créer un compte"
    }</button>
  `;

  document.getElementById("auth-switch")!.addEventListener("click", () => {
    authMode = isSignup ? "signin" : "signup";
    renderAuthPanel();
  });

  const form = document.getElementById("auth-form") as HTMLFormElement;
  const errorBox = document.getElementById("auth-error")! as HTMLDivElement;

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    errorBox.hidden = true;
    const data = new FormData(form);
    const email = String(data.get("email") || "").trim();
    const password = String(data.get("password") || "");
    const submitBtn = form.querySelector("button[type=submit]") as HTMLButtonElement;
    submitBtn.disabled = true;
    submitBtn.textContent = "Patientez…";

    const { error } = isSignup
      ? await supabase.auth.signUp({ email, password })
      : await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      errorBox.textContent = frenchAuthError(error.message);
      errorBox.hidden = false;
      submitBtn.disabled = false;
      submitBtn.textContent = isSignup ? "Créer le compte" : "Se connecter";
    }
    // On success, the onAuthStateChange listener updates the UI.
  });
}

async function loadProfile(userId: string) {
  const { data, error } = await supabase
    .from("profiles")
    .select("id, username, role")
    .eq("id", userId)
    .maybeSingle();
  if (error) {
    console.error("Failed to load profile:", error);
    currentProfile = null;
    return;
  }
  currentProfile = data as Profile | null;
}

function updateAuthTrigger() {
  if (currentSession) {
    const label = currentProfile?.username || currentSession.user.email || "Compte";
    authTrigger.textContent = label;
    authTrigger.classList.add("is-authed");
  } else {
    authTrigger.textContent = "Se connecter";
    authTrigger.classList.remove("is-authed");
  }
}

authTrigger.addEventListener("click", () => {
  authPanel.hidden = !authPanel.hidden;
  if (!authPanel.hidden) renderAuthPanel();
});
authClose.addEventListener("click", () => {
  authPanel.hidden = true;
});

supabase.auth.onAuthStateChange(async (_event, session) => {
  currentSession = session;
  if (session) {
    await loadProfile(session.user.id);
  } else {
    currentProfile = null;
  }
  updateAuthTrigger();
  renderAuthPanel();
  // Refresh the selected country panel so the write form appears/disappears.
  if (selectedCountry) showCountry(selectedCountry);
});

supabase.auth.getSession().then(async ({ data }) => {
  currentSession = data.session;
  if (data.session) {
    await loadProfile(data.session.user.id);
  }
  updateAuthTrigger();
});

// ---------------------------------------------------------------------------
// Map init
// ---------------------------------------------------------------------------

const map = L.map("map", {
  center: [20, 10],
  zoom: 3,
  minZoom: 2,
  maxZoom: 12,
  worldCopyJump: true,
  zoomControl: true,
});

// Standard OpenStreetMap tiles — free, no API key required. CARTO's
// previously-free "dark matter" basemap now requires a key, so we use plain
// OSM tiles here and apply a CSS dark-mode filter (see .tile-layer-dark in
// style.css) to approximate the atlas's dark navy theme.
const tileLayer = L.tileLayer(
  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
  {
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    subdomains: "abc",
    maxZoom: 19,
    className: "tile-layer-dark",
  }
);
tileLayer.addTo(map);

// Detect tile load failures (e.g. sandboxed / offline environments) and show
// a small notice instead of failing silently — the country layer underneath
// still renders on the plain dark background either way.
let tileErrorCount = 0;
let tileLoadedOk = false;
tileLayer.on("tileerror", () => {
  tileErrorCount += 1;
  if (tileErrorCount > 3 && !tileLoadedOk) {
    const note = document.getElementById("tile-fallback");
    if (note) note.style.display = "block";
  }
});
tileLayer.on("tileload", () => {
  tileLoadedOk = true;
  const note = document.getElementById("tile-fallback");
  if (note) note.style.display = "none";
});

// ---------------------------------------------------------------------------
// Country borders overlay
// ---------------------------------------------------------------------------

type CountryProps = {
  name: string;
  admin: string;
  iso_a3: string;
  continent: string;
};

const panelTitle = document.getElementById("panel-title")!;
const panelBody = document.getElementById("panel-body")!;

let selectedCountry: CountryProps | null = null;

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

// ---------------------------------------------------------------------------
// Fiche pays + dossier complet — porté de l'artifact source dans
// src/dossier.ts (openFiche/closeFiche/flushFicheSave, catégories/sections/
// entrées texte-photo-lien, éditeur riche, mode lecture). Remplace
// l'ancienne mini-fiche/liste d'entrées ci-dessus pour un pays.
// ---------------------------------------------------------------------------
function slugifyLocal(s: string): string {
  return (
    (s || "")
      .normalize("NFD")
      .replace(/[̀-ͯ]/g, "")
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .slice(0, 120) || "x"
  );
}
function countryPropsToRef(props: CountryProps, iso2: string | null): CountryRef {
  return {
    isoA3: props.iso_a3,
    slug: slugifyLocal(props.name || props.admin),
    name: props.name || props.admin,
    continent: props.continent,
    iso2,
  };
}

function getAllCountryRefs(): CountryRef[] {
  return sovFeatures.map((f) => {
    const p = f.properties as CountryProps & { ISO_A2?: string };
    return countryPropsToRef(p, (p.ISO_A2 as string) || null);
  });
}

// deps est un objet mutable : renderFicheIndicator/renderFicheGroups/
// onFicheClose sont branchés APRÈS coup, une fois les modules groupes/
// indicateurs créés plus bas (qui ont eux-mêmes besoin de
// ficheDossier.openGroupDossier) — dossier.ts relit deps.xxx à chaque appel
// (jamais destructuré en variable locale), donc cette affectation tardive
// est bien prise en compte.
const ficheDeps: Parameters<typeof initFicheDossierSystem>[0] = {
  supabase,
  getSession: () => currentSession,
  getProfile: () => currentProfile,
  getAllCountries: getAllCountryRefs,
};
const ficheDossier = initFicheDossierSystem(ficheDeps);

async function showCountry(props: CountryProps) {
  selectedCountry = props;
  const iso2 = ((props as unknown as Record<string, unknown>).ISO_A2 as string) || null;
  await ficheDossier.openFiche(countryPropsToRef(props, iso2));
}

function getComputedCssVar(name: string): string {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
}

const LAND_FILL = getComputedCssVar("--land-fill") || "#aebcd4";
const LAND_FILL_HOVER = getComputedCssVar("--land-fill-hover") || "#8fa1c2";
const LAND_BORDER = getComputedCssVar("--land-border") || "#1a1714";
const ACCENT = getComputedCssVar("--accent") || "#e8b34a";

// ---------------------------------------------------------------------------
// Frontières — pont D3/Leaflet (voir geobridge.ts)
//
// Ceci remplace le calque GeoJSON simplifié du prototype par les données
// SOURCE de l'artifact (SOV = sovereignty_50m, mêmes tracés au mètre près),
// rendues via D3 sur une couche SVG superposée aux tuiles Leaflet et
// resynchronisée à chaque zoom/déplacement — exactement le même principe
// que le zoom `d3.zoom()` de l'artifact, piloté cette fois par Leaflet.
// ---------------------------------------------------------------------------
const { projection: projectLonLat, path: geoPath } = createGeoBridge(map);
// `projectLonLat` sera utilisé par les prochains calques ponctuels (ports,
// villes, câbles, POI...) — voir la suite du portage.
void projectLonLat;

const overlaySvg = d3
  .select(map.getPanes().overlayPane)
  .append("svg")
  .attr("class", "geo-overlay-svg");
const overlayG = overlaySvg.append("g").attr("class", "leaflet-zoom-hide");
// Calque de coloration choroplèthe (indicateurs OWID) — sous gLand, comme
// gIndicator dans l'artifact (g, gImage, gLandFill, gIndicator, gLand...).
const gIndicatorLayer = overlayG
  .append("g")
  .attr("id", "indicator-layer")
  .style("pointer-events", "none")
  .style("display", "none");
const gLand = overlayG.append("g").attr("id", "land-layer");
// Contours des pays membres des groupes géopolitiques visibles — au-dessus
// de gLand, comme gGroups dans l'artifact.
const gGroupsLayer = overlayG.append("g").attr("id", "group-highlights").style("pointer-events", "none");

// Callbacks de redessin pour les modules groupes/indicateurs (branchés
// juste en dessous, une fois ces modules créés) : une variable mutable
// évite toute dépendance d'ordre d'initialisation avec resetOverlay()
// (définie plus bas, mais seulement APPELÉE une fois la carte prête).
let groupsRedraw: (() => void) | null = null;
let indicatorsRedraw: (() => void) | null = null;
// Assigné plus bas, une fois src/links.ts initialisé (après la création du
// calque gLinksLayer, positionné au-dessus de tous les autres calques —
// voir sa déclaration près de gLakes).
let linksRedraw: (() => void) | null = null;

// ---------------------------------------------------------------------------
// Groupes géopolitiques + Indicateurs OWID + Encyclopédie — src/groups.ts,
// src/indicators.ts, src/encyclopedie.ts (voir ces fichiers pour le détail
// du portage). Câblés ici avec la carte (calques SVG définis ci-dessus) et
// la fiche pays (widgets injectés via ficheDeps, mutable — voir sa
// définition plus haut).
// ---------------------------------------------------------------------------
// Référence mutable vers src/links.ts, créé plus bas : groupsSystem a
// besoin de quelques points d'extension liés au système de liens (mode
// création déclenché depuis un groupe, coordination des modes "clic sur
// la carte"), mais src/links.ts a lui-même besoin de groupsSystem
// (membres d'un groupe pour l'ancre de son tracé) — même schéma que
// ficheDeps plus haut : les callbacks ci-dessous ne sont appelés qu'après
// l'initialisation complète du module (clics utilisateur), donc lire
// `linksSystem` par closure (jamais destructuré) suffit.
let linksSystem: ReturnType<typeof initLinksSystem> | null = null;

const groupsSystem = initGroupsSystem({
  supabase,
  getSession: () => currentSession,
  getProfile: () => currentProfile,
  getAllCountries: getAllCountryRefs,
  gGroupsLayer,
  geoPath: (f) => geoPath(f),
  getFeatureByIsoA3: () => isoA3ToFeature,
  openGroupDossier: (id, name, color) => ficheDossier.openGroupDossier(id, name, color),
  setMapAddCursor: (active) => document.querySelector(".map-wrap")!.classList.toggle("group-add-cursor", active),
  onBeforeMapAddMode: () => linksSystem?.exitLinkMode(),
  resolveGroupClickForLink: (id, name) => linksSystem?.handleGroupClick(id, name) ?? false,
  renderGroupLinks: (container, groupId, name) => linksSystem?.renderFicheLinksWidget(container, "group", groupId, name),
  onEditorClosed: () => linksSystem?.clearEntityLinks(),
});
const indicatorsSystem = initIndicatorsSystem({
  supabase,
  getSession: () => currentSession,
  gIndicatorLayer,
  geoPath: (f) => geoPath(f),
  getSovFeatures: () => sovFeatures as unknown as SovFeatureLike[],
});
groupsRedraw = groupsSystem.redrawHighlights;
indicatorsRedraw = indicatorsSystem.redrawOnMapChange;
ficheDeps.renderFicheIndicator = (container, country) => indicatorsSystem.renderFicheIndicator(container, country);
ficheDeps.renderFicheGroups = (container, country) => groupsSystem.renderFicheGroups(container, country);
ficheDeps.renderFicheLinks = (container, country) => linksSystem?.renderFicheLinksWidget(container, "country", country.isoA3, frenchCountryName(country.name));
ficheDeps.onFicheClose = () => {
  indicatorsSystem.onFicheClose();
  linksSystem?.clearEntityLinks();
};

// Les panneaux latéraux (groupes/indicateurs/apparence) partagent le même
// emplacement à l'écran (haut-droite) : un seul ouvert à la fois, comme
// closeOtherSidePanels() dans l'artifact (~8308).
function closeOtherSidePanels(exceptId: string) {
  ["groups-panel", "indicators-panel", "appearance-panel", "chronologie-panel"].forEach((id) => {
    if (id !== exceptId) document.getElementById(id)?.classList.remove("open");
  });
}
document.getElementById("groups-btn")!.addEventListener("click", () => {
  closeOtherSidePanels("groups-panel");
  groupsSystem.openPanel();
});
document.getElementById("indicators-btn")!.addEventListener("click", () => {
  closeOtherSidePanels("indicators-panel");
  indicatorsSystem.openPanel();
});
document.getElementById("appearance-btn")!.addEventListener("click", () => {
  closeOtherSidePanels("appearance-panel");
  indicatorsSystem.openAppearancePanel();
});
document.getElementById("encyclopedie-btn")!.addEventListener("click", async () => {
  await ensureEncyclopedieSeed(supabase, () => currentSession);
  await ficheDossier.openEncyclopedieDossier();
});

// `redrawInfraLayers` (fonction déclarée plus bas, une fois les calques
// d'infrastructure — territoires contestés, ports, détroits, pipelines,
// bases, câbles, fleuves/lacs, capitales — créés) est appelée ici : les
// déclarations `function` étant hoistées, l'appel ci-dessous fonctionne
// même si sa définition apparaît plus loin dans le fichier — voir
// `redrawBorders` pour le même principe appliqué aux frontières.

type SovFeature = GeoJSON.Feature<GeoJSON.Geometry, CountryProps & Record<string, unknown>>;

let sovFeatures: SovFeature[] = [];
// iso_a3 -> feature, pour le calque de surlignage des groupes (src/groups.ts).
let isoA3ToFeature = new Map<string, SovFeature>();

// Pays "spéciaux" (territoires au statut particulier / non universellement
// reconnus) — reprend isSpecial() de l'artifact à l'identique : sert à
// distinguer leur tracé (pointillé de la couleur "contesté") quand la case
// "Statut contesté" est cochée.
const SPECIAL_NAMES = new Set(["Taiwan", "Somaliland", "N. Cyprus"]);
function isSpecialCountry(props: Record<string, unknown>): boolean {
  return (
    SPECIAL_NAMES.has(props.name as string) ||
    ["Disputed", "Indeterminate", "Breakaway"].includes(props.TYPE as string)
  );
}

// Reflète l'état de la case "Statut contesté" (voir toggle-disputed
// plus bas) — appliqué à chaque redessin de gLand pour ne pas perdre
// l'état "special" en cours de route (resetOverlay redessine à chaque
// zoom/déplacement).
let disputedShown = false;

function redrawBorders() {
  gLand
    .selectAll<SVGPathElement, SovFeature>("path")
    .data(sovFeatures)
    .join("path")
    .attr("d", (d) => geoPath(d as unknown as GeoJSON.GeoJSON) || "")
    .attr("class", (d) =>
      isSpecialCountry(d.properties)
        ? "special-eligible" + (disputedShown ? " special" : "")
        : null
    )
    .attr("fill", LAND_FILL)
    .attr("fill-opacity", 0.5)
    .attr("stroke", LAND_BORDER)
    .attr("stroke-width", 0.7)
    .style("cursor", "pointer")
    .on("mouseover", function () {
      d3.select(this)
        .attr("fill", LAND_FILL_HOVER)
        .attr("fill-opacity", 0.75)
        .attr("stroke", ACCENT)
        .attr("stroke-width", 1.4);
    })
    .on("mouseout", function () {
      d3.select(this)
        .attr("fill", LAND_FILL)
        .attr("fill-opacity", 0.5)
        .attr("stroke", LAND_BORDER)
        .attr("stroke-width", 0.7);
    })
    .on("click", (_event, d) => {
      // Mode "ajouter pays sur la carte" (édition d'un groupe, src/groups.ts) :
      // consomme le clic pour basculer l'appartenance au groupe plutôt que
      // d'ouvrir la fiche du pays — porté de resolveEntitySelection() (~8417).
      if (linksSystem?.handleMapCountryClick(d.properties.iso_a3)) return;
      if (groupsSystem.handleMapCountryClick(d.properties.iso_a3)) return;
      showCountry(d.properties);
    });
}

// Repositionne le SVG de superposition pour qu'il couvre le viewport courant
// (même logique que l'exemple classique Leaflet + D3 : le SVG est réancré à
// chaque `moveend`/`zoom` sur l'origine du pane pour éviter les décalages
// d'arrondi à fort zoom).
function resetOverlay() {
  const bounds = map.getBounds();
  const topLeft = map.latLngToLayerPoint(bounds.getNorthWest());
  const bottomRight = map.latLngToLayerPoint(bounds.getSouthEast());
  const pad = 200; // marge pour ne pas couper les tracés proches du bord
  overlaySvg
    .attr("width", bottomRight.x - topLeft.x + pad * 2)
    .attr("height", bottomRight.y - topLeft.y + pad * 2)
    .style("left", topLeft.x - pad + "px")
    .style("top", topLeft.y - pad + "px");
  overlayG.attr("transform", `translate(${-(topLeft.x - pad)},${-(topLeft.y - pad)})`);
  redrawBorders();
  redrawInfraLayers();
  groupsRedraw?.();
  indicatorsRedraw?.();
  linksRedraw?.();
}

map.on("zoom viewreset move", resetOverlay);

fetch("/data/raw/SOV.json")
  .then((r) => {
    if (!r.ok) throw new Error(`HTTP ${r.status}`);
    return r.json();
  })
  .then((sovTopo) => {
    const geo = topojson.feature(
      sovTopo,
      sovTopo.objects.sovereignty_50m
    ) as unknown as GeoJSON.FeatureCollection<GeoJSON.Geometry, Record<string, unknown>>;
    sovFeatures = geo.features.map((f) => {
      const props = f.properties as Record<string, unknown>;
      return {
        ...f,
        properties: {
          name: (props.NAME as string) || (props.ADMIN as string) || "",
          admin: (props.ADMIN as string) || "",
          iso_a3: (props.ISO_A3 as string) || (props.ADM0_A3 as string) || "",
          continent: (props.CONTINENT as string) || "",
          ...props,
        },
      } as SovFeature;
    });
    isoA3ToFeature = new Map(sovFeatures.filter((f) => f.properties.iso_a3).map((f) => [f.properties.iso_a3, f]));
    resetOverlay();
  })
  .catch((err) => {
    console.error("Failed to load country borders:", err);
    panelBody.innerHTML = `<span style="color:#e8734a">Erreur de chargement des frontières : ${err.message}</span>`;
  });

// ---------------------------------------------------------------------------
// Calques d'infrastructure portés de l'artifact — territoires contestés,
// ports, détroits, pipelines, bases militaires, câbles sous-marins,
// fleuves/lacs (fusionnés en une seule entrée de légende) et capitales.
//
// Même principe que gLand ci-dessus : un groupe SVG par calque dans
// `overlayG`, recalculé à chaque `resetOverlay()` via `redrawInfraLayers()`,
// avec des positions dérivées de `projectLonLat`/`geoPath` (le pont
// D3/Leaflet). Contrairement à l'artifact original — où tout le groupe `g`
// est mis à l'échelle par le zoom D3 (`g.attr('transform', e.transform)`),
// ce qui oblige à diviser les rayons/tailles par `k` pour compenser — ici
// aucune transformation d'échelle n'est appliquée : chaque position est
// reprojetée en pixels écran réels à chaque zoom, donc les tailles ci-
// dessous sont déjà les tailles finales (pas de `/k`).
// ---------------------------------------------------------------------------

type LonLat = { lon: number; lat: number };
type PortEntry = LonLat & { name: string; country: string; teu: number };
type StraitEntry = LonLat & { name: string; note: string };
type PipelineEntry = { name: string; kind: "gaz" | "petrole"; note: string; points: [number, number][] };
type BaseEntry = LonLat & { name: string; power: string; type: string; note: string };
type CableEntry = { name: string; owner: string; note: string; points: [number, number][] | [number, number][][] };
type RiverEntry = { name: string; scalerank: number; points: [number, number][] };
type LakeEntry = { name: string; type: string; coordinates: unknown };
type CityEntry = LonLat & { n: string; note?: string };

function slugify(s: string): string {
  return (
    (s || "")
      .normalize("NFD")
      .replace(/[̀-ͯ]/g, "")
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .slice(0, 120) || "x"
  );
}
// Bascule l'affichage d'un groupe D3 sans le union type `"none" | null`
// (les surcharges de `.style()` de d3 n'acceptent pas cette union).
function setLayerVisible(
  sel: d3.Selection<SVGGElement, unknown, HTMLElement | null, unknown>,
  show: boolean
) {
  if (show) sel.style("display", null);
  else sel.style("display", "none");
}

const portSlug = (d: PortEntry) => slugify(d.name);
const straitSlug = (d: StraitEntry) => slugify(d.name);
const pipelineSlug = (d: PipelineEntry) => slugify(d.name);
const baseSlug = (d: BaseEntry) => slugify(d.name);
const cableSlug = (d: CableEntry) => slugify(d.name);
const riverSlug = (d: RiverEntry) => slugify(d.name);
const capitalSlug = (d: CityEntry) => slugify(d.n);

// --- Infobulle au survol ----------------------------------------------------
// Reproduit showTip()/showEntityTip() de l'artifact : n'affiche que le
// libellé de l'entité survolée (jamais la note complémentaire — c'est le
// comportement exact de l'artifact source, où showEntityTip() appelle
// showTip(event, label, undefined) en ignorant systématiquement la note).
const tooltipEl = document.getElementById("entity-tooltip")! as HTMLDivElement;
function showEntityTip(event: MouseEvent, label: string) {
  const wrap = document.querySelector(".map-wrap")! as HTMLElement;
  const b = wrap.getBoundingClientRect();
  tooltipEl.style.left = event.clientX - b.left + "px";
  tooltipEl.style.top = event.clientY - b.top - 12 + "px";
  tooltipEl.textContent = label;
  tooltipEl.classList.add("visible");
}
function hideEntityTip() {
  tooltipEl.classList.remove("visible");
}

// --- Clic sur une entité -----------------------------------------------------
// L'artifact ouvre ici une "fiche" complète (dossier persistant, hors
// périmètre de ce portage). On affiche à la place, dans le même panneau
// latéral que les pays, un résumé minimal de l'entité cliquée.
function showInfraEntity(kindLabel: string, name: string, lines: [string, string][]) {
  selectedCountry = null;
  panelTitle.textContent = name;
  panelBody.classList.remove("empty");
  panelBody.innerHTML = `
    <dl>
      <dt>Type</dt>
      <dd>${escapeHtml(kindLabel)}</dd>
      ${lines
        .map(([k, v]) => `<dt>${escapeHtml(k)}</dt><dd>${escapeHtml(v)}</dd>`)
        .join("")}
    </dl>
    <p style="margin-top:10px;color:var(--text-dim);font-size:12px;line-height:1.5;">
      Fiche complète à connecter dans une prochaine étape.
    </p>
  `;
}

const gDisputed = overlayG.append("g").attr("id", "disputed-layer").style("display", "none");
const gPipelines = overlayG.append("g").attr("id", "pipelines-layer").style("display", "none");
// Couche invisible superposée aux pipelines avec un trait beaucoup plus
// large, servant uniquement de zone de clic/survol (le pointillé visible
// étant trop fin pour être cliqué confortablement) — même principe que
// l'artifact (gPipelinesHit).
const gPipelinesHit = overlayG.append("g").attr("id", "pipelines-hit-layer").style("display", "none");
const gPorts = overlayG.append("g").attr("id", "ports-layer").style("display", "none");
const gStraits = overlayG.append("g").attr("id", "straits-layer").style("display", "none");
const gCities = overlayG.append("g").attr("id", "cities-layer").style("display", "none");
const gBases = overlayG.append("g").attr("id", "bases-layer").style("display", "none");
const gCables = overlayG.append("g").attr("id", "cables-layer").style("display", "none");
// Couche invisible superposée aux câbles, même principe que gPipelinesHit.
const gCablesHit = overlayG.append("g").attr("id", "cables-hit-layer").style("display", "none");
const gRivers = overlayG.append("g").attr("id", "rivers-layer").style("display", "none");
// Zone de clic/survol des fleuves, même principe que gCablesHit/gPipelinesHit.
const gRiversHit = overlayG.append("g").attr("id", "rivers-hit-layer").style("display", "none");
// Lacs : calque dédié, caché par défaut, activé via la même case à cocher
// que les fleuves ("Fleuves & lacs" — fusion identique à l'artifact v66).
const gLakes = overlayG.append("g").attr("id", "lakes-layer").style("display", "none");
// Liens entre pays/groupes (diplomatie/conflit/économie/culture/autre) —
// dessiné en dernier, au-dessus de tous les autres calques, comme gLinks
// dans l'artifact (~2862, ajouté après tous les autres groupes SVG).
const gLinksLayer = overlayG.append("g").attr("id", "links-layer");

// Centre du territoire métropolitain (plus grand polygone d'un
// MultiPolygon) plutôt que le centroïde géographique complet — porté de
// mainlandCentroid() (~9338-9352) : sert d'ancre de tracé pour un pays
// dans src/links.ts, pour ne pas voir un lien partir d'un territoire
// d'outre-mer lointain (France, Royaume-Uni, États-Unis...).
function mainlandCentroid(f: GeoJSON.Feature): [number, number] {
  const geom = f.geometry;
  if (geom.type === "MultiPolygon") {
    let best: GeoJSON.Polygon | null = null;
    let bestArea = -1;
    (geom.coordinates as number[][][][]).forEach((poly) => {
      const pseudo = { type: "Polygon", coordinates: poly } as GeoJSON.Polygon;
      const area = Math.abs(d3.geoArea(pseudo));
      if (area > bestArea) {
        bestArea = area;
        best = pseudo;
      }
    });
    return d3.geoCentroid(best || (f as unknown as GeoJSON.GeoJSON)) as [number, number];
  }
  return d3.geoCentroid(f as unknown as GeoJSON.GeoJSON) as [number, number];
}

function selectLinkEntity(kind: LinkEntityKind, id: string) {
  if (kind === "country") {
    const f = isoA3ToFeature.get(id);
    if (!f) return;
    const centroid = d3.geoCentroid(f as unknown as GeoJSON.GeoJSON) as [number, number];
    flyToLonLat(centroid, 6);
    showCountry(f.properties as unknown as CountryProps);
  } else {
    const g = groupsSystem.getGroupsList().find((x) => x.id === id);
    if (g) ficheDossier.openGroupDossier(id, g.name, g.color);
  }
}

linksSystem = initLinksSystem({
  supabase,
  getSession: () => currentSession,
  getProfile: () => currentProfile,
  gLinksLayer,
  projectLonLat: (lonlat) => projectLonLat(lonlat),
  getCountryAnchor: (isoA3) => {
    const f = isoA3ToFeature.get(isoA3);
    return f ? mainlandCentroid(f as unknown as GeoJSON.Feature) : null;
  },
  getCountryFrenchName: (isoA3) => {
    const c = getAllCountryRefs().find((x) => x.isoA3 === isoA3);
    return c ? frenchCountryName(c.name) : isoA3;
  },
  getGroupMembers: (groupId) => groupsSystem.getGroupsList().find((g) => g.id === groupId)?.members,
  entityLabel: (kind, id) => {
    if (kind === "country") {
      const c = getAllCountryRefs().find((x) => x.isoA3 === id);
      return c ? frenchCountryName(c.name) : id;
    }
    const g = groupsSystem.getGroupsList().find((x) => x.id === id);
    return g ? g.name : id;
  },
  showBanner: (text) => {
    const banner = document.getElementById("group-add-banner");
    if (!banner) return;
    banner.textContent = text;
    banner.classList.add("open");
  },
  hideBanner: () => document.getElementById("group-add-banner")?.classList.remove("open"),
  setMapCursor: (active) => document.querySelector(".map-wrap")!.classList.toggle("group-add-cursor", active),
  onBeforeLinkMode: () => {
    if (groupsSystem.isMapAddModeActive()) groupsSystem.exitMapAddMode();
  },
  showTip: (event, label) => showEntityTip(event, label),
  hideTip: () => hideEntityTip(),
  selectEntity: (kind, id) => selectLinkEntity(kind, id),
});
linksRedraw = linksSystem.redraw;

// Générateur de ligne courbe (pipelines/câbles/fleuves) équivalent au
// `pipelineLine` de l'artifact, mais basé sur `projectLonLat` (le pont
// géo Leaflet) plutôt que sur la projection Equal Earth fixe.
const pipelineLine = d3
  .line<[number, number]>()
  .x((d) => projectLonLat(d)[0])
  .y((d) => projectLonLat(d)[1])
  .curve(d3.curveCatmullRom.alpha(0.5));

let dispFeatures: GeoJSON.Feature<GeoJSON.Geometry, Record<string, unknown>>[] = [];
let ports: PortEntry[] = [];
let straits: StraitEntry[] = [];
let pipelines: PipelineEntry[] = [];
let bases: BaseEntry[] = [];
let cables: CableEntry[] = [];
let rivers: RiverEntry[] = [];
let lakes: LakeEntry[] = [];
let cities: CityEntry[] = [];
let baseTypeFr: Record<string, string> = {};

// Un câble peut être défini soit par un tracé simple, soit — pour franchir
// l'antiméridien — par plusieurs segments imbriqués. On aplatit ici en une
// liste d'éléments {cable, points}, un <path> par segment, toujours
// rattaché au même câble pour l'infobulle/le clic (identique à
// `cableRenderSegments` de l'artifact).
function cableRenderSegments(c: CableEntry): { cable: CableEntry; points: [number, number][] }[] {
  const p = c.points as unknown as unknown[];
  const isMultiSegment = Array.isArray(p[0]) && Array.isArray((p[0] as unknown[])[0]);
  const segments = (isMultiSegment ? p : [p]) as [number, number][][];
  return segments.map((points) => ({ cable: c, points }));
}
let cableRenderItems: { cable: CableEntry; points: [number, number][] }[] = [];

// Rayon des ports proportionnel au trafic conteneurs (teu) — identique à
// `portRadius` de l'artifact (d3.scaleSqrt, range [2, 5]).
let portRadius = d3.scaleSqrt<number, number>().domain([0, 1]).range([2, 5]);
// Épaisseur des fleuves selon leur rang (1 = fleuve majeur, 4 = affluent
// secondaire) — identique à `riverWidth` de l'artifact.
const riverWidth = d3.scaleLinear().domain([1, 4]).range([2.2, 0.9]).clamp(true);
// Icône "détroit" en nœud papillon — identique à `bowtiePathD`/`STRAIT_BASE`.
function bowtiePathD(half: number): string {
  return `M${-half},${-half}L${half},${-half}L${-half},${half}L${half},${half}Z`;
}
const STRAIT_BASE = 9;
const baseSymbol = d3.symbol().type(d3.symbolStar).size(38);

// Seuil de zoom Leaflet à partir duquel les libellés des capitales
// apparaissent. L'artifact utilise `LABEL_MIN_K = 2.4` sur une échelle de
// zoom D3 (`scaleExtent([1, 20])`, départ à k=1) ; l'échelle de zoom
// Leaflet est différente (niveaux entiers, carte initiale au niveau 3,
// bornes [2, 12] ici). On retient le niveau Leaflet 6 — au-delà duquel on
// distingue confortablement les villes individuellement, comme k≥2.4 dans
// l'artifact — comme seuil équivalent le plus proche.
const CITY_LABEL_MIN_ZOOM = 6;

function redrawInfraLayers() {
  // --- Territoires contestés ---------------------------------------------
  gDisputed
    .selectAll<SVGPathElement, GeoJSON.Feature<GeoJSON.Geometry, Record<string, unknown>>>("path")
    .data(dispFeatures)
    .join("path")
    .attr("class", "disputed-outline")
    .attr("d", (d) => geoPath(d as unknown as GeoJSON.GeoJSON) || "")
    .on("mousemove", (event, d) => showEntityTip(event, (d.properties.NAME as string) || ""))
    .on("mouseleave", hideEntityTip)
    .on("click", (event, d) => {
      event.stopPropagation();
      const p = d.properties;
      showInfraEntity("Territoire contesté", (p.NAME as string) || "", [
        ["Note", (p.NOTE_BRK as string) || ""],
      ]);
    });

  // --- Pipelines -----------------------------------------------------------
  gPipelines
    .selectAll<SVGPathElement, PipelineEntry>("path")
    .data(pipelines)
    .join("path")
    .attr("class", (d) => "pipeline pipeline-" + d.kind)
    .attr("d", (d) => pipelineLine(d.points));

  gPipelinesHit
    .selectAll<SVGPathElement, PipelineEntry>("path")
    .data(pipelines)
    .join("path")
    .attr("class", "pipeline-hit")
    .attr("data-slug", pipelineSlug)
    .attr("d", (d) => pipelineLine(d.points))
    .on("mousemove", (event, d) => showEntityTip(event, d.name))
    .on("mouseleave", hideEntityTip)
    .on("click", (event, d) => {
      event.stopPropagation();
      showInfraEntity(d.kind === "gaz" ? "Gazoduc" : "Oléoduc", d.name, [["Note", d.note]]);
    });

  // --- Câbles sous-marins ----------------------------------------------------
  gCables
    .selectAll<SVGPathElement, { cable: CableEntry; points: [number, number][] }>("path")
    .data(cableRenderItems)
    .join("path")
    .attr("class", "cable")
    .attr("d", (d) => pipelineLine(d.points));

  gCablesHit
    .selectAll<SVGPathElement, { cable: CableEntry; points: [number, number][] }>("path")
    .data(cableRenderItems)
    .join("path")
    .attr("class", "cable-hit")
    .attr("data-slug", (d) => cableSlug(d.cable))
    .attr("d", (d) => pipelineLine(d.points))
    .on("mousemove", (event, d) => showEntityTip(event, d.cable.name))
    .on("mouseleave", hideEntityTip)
    .on("click", (event, d) => {
      event.stopPropagation();
      showInfraEntity("Câble sous-marin", d.cable.name, [
        ["Propriétaire", d.cable.owner],
        ["Note", d.cable.note],
      ]);
    });

  // --- Fleuves ---------------------------------------------------------------
  gRivers
    .selectAll<SVGPathElement, RiverEntry>("path")
    .data(rivers)
    .join("path")
    .attr("class", "river")
    .style("stroke-width", (d) => riverWidth(d.scalerank) + "px")
    .attr("d", (d) => pipelineLine(d.points));

  gRiversHit
    .selectAll<SVGPathElement, RiverEntry>("path")
    .data(rivers)
    .join("path")
    .attr("class", "river-hit")
    .attr("data-slug", riverSlug)
    .attr("d", (d) => pipelineLine(d.points))
    .on("mousemove", (event, d) => showEntityTip(event, d.name))
    .on("mouseleave", hideEntityTip);

  // --- Lacs (fusionnés dans la même entrée de légende que les fleuves) -----
  gLakes
    .selectAll<SVGPathElement, LakeEntry>("path")
    .data(lakes)
    .join("path")
    .attr("class", "lake")
    .attr("d", (d) => geoPath(d as unknown as GeoJSON.GeoJSON) || "")
    .on("mousemove", (event, d) => showEntityTip(event, d.name))
    .on("mouseleave", hideEntityTip);

  // --- Bases militaires --------------------------------------------------
  gBases
    .selectAll<SVGPathElement, BaseEntry>("path.military-base")
    .data(bases)
    .join("path")
    .attr("class", "military-base")
    .attr("data-slug", baseSlug)
    .attr("d", baseSymbol)
    .attr("transform", (d) => {
      const c = projectLonLat([d.lon, d.lat]);
      return "translate(" + c[0] + "," + c[1] + ")";
    })
    .on("mousemove", (event, d) =>
      showEntityTip(event, d.name)
    )
    .on("mouseleave", hideEntityTip)
    .on("click", (event, d) => {
      event.stopPropagation();
      showInfraEntity("Base militaire étrangère", d.name, [
        ["Puissance", d.power],
        ["Type", baseTypeFr[d.type] || d.type],
        ["Note", d.note],
      ]);
    });

  // --- Ports -----------------------------------------------------------------
  gPorts
    .selectAll<SVGCircleElement, PortEntry>("circle")
    .data(ports)
    .join("circle")
    .attr("class", "port")
    .attr("data-slug", portSlug)
    .attr("r", (d) => portRadius(d.teu))
    .attr("cx", (d) => projectLonLat([d.lon, d.lat])[0])
    .attr("cy", (d) => projectLonLat([d.lon, d.lat])[1])
    .on("mousemove", (event, d) => showEntityTip(event, d.name))
    .on("mouseleave", hideEntityTip)
    .on("click", (event, d) => {
      event.stopPropagation();
      const rank = ports.indexOf(d) + 1;
      showInfraEntity("Port", d.name, [
        ["Pays", d.country],
        ["Rang mondial (conteneurs)", rank === 1 ? "1er" : rank + "e"],
      ]);
    });

  // --- Détroits ----------------------------------------------------------
  const side = STRAIT_BASE;
  const shapeD = bowtiePathD(side / 2);
  gStraits
    .selectAll<SVGPathElement, StraitEntry>("path")
    .data(straits)
    .join("path")
    .attr("class", "strait")
    .attr("data-slug", straitSlug)
    .attr("d", shapeD)
    .attr("transform", (d) => {
      const c = projectLonLat([d.lon, d.lat]);
      return "translate(" + c[0] + "," + c[1] + ")";
    })
    .on("mousemove", (event, d) => showEntityTip(event, d.name))
    .on("mouseleave", hideEntityTip)
    .on("click", (event, d) => {
      event.stopPropagation();
      showInfraEntity("Détroit", d.name, [["Note", d.note]]);
    });

  // --- Capitales -----------------------------------------------------------
  const showLabels = map.getZoom() >= CITY_LABEL_MIN_ZOOM;
  const cityG = gCities
    .selectAll<SVGGElement, CityEntry>("g.city")
    .data(cities)
    .join((enter) => {
      const g = enter.append("g").attr("class", "city").attr("data-slug", capitalSlug);
      g.append("circle").attr("class", "city-dot").attr("r", 2);
      g.append("text")
        .attr("class", "city-label")
        .attr("x", 5)
        .attr("y", 3.5)
        .text((d) => d.n);
      return g;
    });
  cityG.attr("transform", (d) => {
    const c = projectLonLat([d.lon, d.lat]);
    return "translate(" + c[0] + "," + c[1] + ")";
  });
  const labelSel = cityG.select(".city-label");
  if (showLabels) labelSel.style("display", null);
  else labelSel.style("display", "none");
  cityG
    .on("mousemove", (event, d) => showEntityTip(event, d.n))
    .on("mouseleave", hideEntityTip)
    .on("click", (event, d) => {
      event.stopPropagation();
      showInfraEntity("Capitale", d.n, d.note ? [["Note", d.note]] : []);
    });
}

Promise.all([
  fetch("/data/raw/DISP.json").then((r) => r.json()),
  fetch("/data/raw/PORTS.json").then((r) => r.json()) as Promise<PortEntry[]>,
  fetch("/data/raw/STRAITS.json").then((r) => r.json()) as Promise<StraitEntry[]>,
  fetch("/data/raw/PIPELINES.json").then((r) => r.json()) as Promise<PipelineEntry[]>,
  fetch("/data/raw/MILITARY_BASES.json").then((r) => r.json()) as Promise<BaseEntry[]>,
  fetch("/data/raw/SUBMARINE_CABLES.json").then((r) => r.json()) as Promise<CableEntry[]>,
  fetch("/data/raw/RIVERS.json").then((r) => r.json()) as Promise<RiverEntry[]>,
  fetch("/data/raw/LAKES.json").then((r) => r.json()) as Promise<LakeEntry[]>,
  fetch("/data/raw/CITIES.json").then((r) => r.json()) as Promise<CityEntry[]>,
  fetch("/data/raw/BASE_TYPE_FR.json").then((r) => r.json()) as Promise<Record<string, string>>,
])
  .then(
    ([
      dispTopo,
      portsData,
      straitsData,
      pipelinesData,
      basesData,
      cablesData,
      riversData,
      lakesData,
      citiesData,
      baseTypeFrData,
    ]) => {
      const dispGeo = topojson.feature(
        dispTopo,
        dispTopo.objects.disputed_50m_given
      ) as unknown as GeoJSON.FeatureCollection<GeoJSON.Geometry, Record<string, unknown>>;
      dispFeatures = dispGeo.features;

      ports = portsData;
      straits = straitsData;
      pipelines = pipelinesData;
      bases = basesData;
      cables = cablesData;
      rivers = riversData;
      lakes = lakesData;
      cities = citiesData;
      baseTypeFr = baseTypeFrData;
      cableRenderItems = cables.flatMap(cableRenderSegments);
      portRadius = d3
        .scaleSqrt<number, number>()
        .domain([0, d3.max(ports, (d) => d.teu) || 1])
        .range([2, 5]);

      redrawInfraLayers();
    }
  )
  .catch((err) => {
    console.error("Failed to load infrastructure layers:", err);
  });

// --- Cases à cocher de la légende -------------------------------------------
// Même comportement que la légende de l'artifact : chaque case montre/masque
// son (ou ses) groupe(s) SVG correspondant(s), sans jamais toucher aux
// données déjà chargées.
document.getElementById("toggle-disputed")!.addEventListener("change", (e) => {
  const show = (e.target as HTMLInputElement).checked;
  disputedShown = show;
  setLayerVisible(gDisputed, show);
  redrawBorders();
});
document.getElementById("toggle-cities")!.addEventListener("change", (e) => {
  setLayerVisible(gCities, (e.target as HTMLInputElement).checked);
});
document.getElementById("toggle-ports")!.addEventListener("change", (e) => {
  setLayerVisible(gPorts, (e.target as HTMLInputElement).checked);
});
document.getElementById("toggle-straits")!.addEventListener("change", (e) => {
  setLayerVisible(gStraits, (e.target as HTMLInputElement).checked);
});
document.getElementById("toggle-pipelines")!.addEventListener("change", (e) => {
  const show = (e.target as HTMLInputElement).checked;
  setLayerVisible(gPipelines, show);
  setLayerVisible(gPipelinesHit, show);
});
document.getElementById("toggle-bases")!.addEventListener("change", (e) => {
  setLayerVisible(gBases, (e.target as HTMLInputElement).checked);
});
document.getElementById("toggle-cables")!.addEventListener("change", (e) => {
  const show = (e.target as HTMLInputElement).checked;
  setLayerVisible(gCables, show);
  setLayerVisible(gCablesHit, show);
});
document.getElementById("toggle-rivers-lakes")!.addEventListener("change", (e) => {
  const show = (e.target as HTMLInputElement).checked;
  setLayerVisible(gRivers, show);
  setLayerVisible(gRiversHit, show);
  setLayerVisible(gLakes, show);
});

// Recalcule le seuil d'affichage des libellés de capitales à chaque
// changement de niveau de zoom Leaflet (équivalent du seuil `LABEL_MIN_K`
// de l'artifact, piloté ici par `map.getZoom()` — voir CITY_LABEL_MIN_ZOOM).
map.on("zoomend", () => {
  if (cities.length) redrawInfraLayers();
});

// ---------------------------------------------------------------------------
// Recherche unifiée — voir src/search.ts. Câblée ici en dernier : elle a
// besoin des données de tous les calques d'infrastructure ci-dessus (ports,
// détroits, pipelines, bases, câbles, capitales) et des systèmes groupes/
// dossier déjà créés plus haut dans ce fichier.
// ---------------------------------------------------------------------------
function flyToLonLat(lonlat: [number, number], zoom: number) {
  const z = Math.max(map.getMinZoom(), Math.min(zoom, map.getMaxZoom()));
  map.setView([lonlat[1], lonlat[0]], z, { animate: true });
}

function buildStaticSearchEntries(): StaticSearchEntry[] {
  const out: StaticSearchEntry[] = [];
  sovFeatures.forEach((f) => {
    const props = f.properties as CountryProps;
    const fr = frenchCountryName(props.name);
    out.push({
      kind: "country",
      id: slugifyLocal(props.name || props.admin),
      label: fr || props.name,
      sub: "Pays",
      matchText: normalizeSearch([props.name, props.admin, fr].filter(Boolean).join(" ")),
    });
  });
  ports.forEach((p) =>
    out.push({ kind: "port", id: portSlug(p), label: p.name, sub: "Port (" + p.country + ")", matchText: normalizeSearch(p.name + " " + p.country) })
  );
  straits.forEach((s) => out.push({ kind: "strait", id: straitSlug(s), label: s.name, sub: "Détroit", matchText: normalizeSearch(s.name) }));
  pipelines.forEach((p) =>
    out.push({
      kind: "pipeline",
      id: pipelineSlug(p),
      label: p.name,
      sub: p.kind === "gaz" ? "Pipeline (gaz)" : "Pipeline (pétrole)",
      matchText: normalizeSearch(p.name),
    })
  );
  bases.forEach((b) =>
    out.push({ kind: "base", id: baseSlug(b), label: b.name, sub: "Base militaire (" + b.power + ")", matchText: normalizeSearch(b.name + " " + b.power) })
  );
  cables.forEach((c) =>
    out.push({ kind: "cable", id: cableSlug(c), label: c.name, sub: "Câble sous-marin", matchText: normalizeSearch(c.name + " " + c.owner) })
  );
  cities.forEach((c) => out.push({ kind: "capital", id: capitalSlug(c), label: c.n, sub: "Capitale", matchText: normalizeSearch(c.n) }));
  return out;
}

function revealCountryBySlug(slug: string) {
  const f = sovFeatures.find((feat) => slugifyLocal((feat.properties.name as string) || (feat.properties.admin as string)) === slug);
  if (!f) return;
  const centroid = d3.geoCentroid(f as unknown as GeoJSON.GeoJSON) as [number, number];
  flyToLonLat(centroid, 6);
  showCountry(f.properties);
}

function selectStaticSearchEntry(entry: StaticSearchEntry) {
  if (entry.kind === "country") {
    revealCountryBySlug(entry.id);
    return;
  }
  if (entry.kind === "port") {
    const d = ports.find((p) => portSlug(p) === entry.id);
    if (!d) return;
    flyToLonLat([d.lon, d.lat], 7);
    const rank = ports.indexOf(d) + 1;
    showInfraEntity("Port", d.name, [
      ["Pays", d.country],
      ["Rang mondial (conteneurs)", rank === 1 ? "1er" : rank + "e"],
    ]);
  } else if (entry.kind === "strait") {
    const d = straits.find((s) => straitSlug(s) === entry.id);
    if (!d) return;
    flyToLonLat([d.lon, d.lat], 7);
    showInfraEntity("Détroit", d.name, [["Note", d.note]]);
  } else if (entry.kind === "pipeline") {
    const d = pipelines.find((p) => pipelineSlug(p) === entry.id);
    if (!d) return;
    const mid = d.points[Math.floor(d.points.length / 2)] || d.points[0];
    if (mid) flyToLonLat(mid, 6);
    showInfraEntity(d.kind === "gaz" ? "Gazoduc" : "Oléoduc", d.name, [["Note", d.note]]);
  } else if (entry.kind === "base") {
    const d = bases.find((b) => baseSlug(b) === entry.id);
    if (!d) return;
    flyToLonLat([d.lon, d.lat], 7);
    showInfraEntity("Base militaire étrangère", d.name, [
      ["Puissance", d.power],
      ["Type", baseTypeFr[d.type] || d.type],
      ["Note", d.note],
    ]);
  } else if (entry.kind === "cable") {
    const d = cables.find((c) => cableSlug(c) === entry.id);
    if (!d) return;
    const flat = cableRenderSegments(d).flatMap((seg) => seg.points);
    const mid = flat[Math.floor(flat.length / 2)] || flat[0];
    if (mid) flyToLonLat(mid, 5);
    showInfraEntity("Câble sous-marin", d.name, [
      ["Propriétaire", d.owner],
      ["Note", d.note],
    ]);
  } else if (entry.kind === "capital") {
    const d = cities.find((c) => capitalSlug(c) === entry.id);
    if (!d) return;
    flyToLonLat([d.lon, d.lat], 7);
    showInfraEntity("Capitale", d.n, d.note ? [["Note", d.note]] : []);
  }
}

function getOwnerLabel(ownerType: string, ownerId: string): string | null {
  if (ownerType === "country") {
    const c = getAllCountryRefs().find((x) => x.isoA3 === ownerId);
    return c ? frenchCountryName(c.name) : null;
  }
  if (ownerType === "group") {
    const g = groupsSystem.getGroupsList().find((x) => x.id === ownerId);
    return g ? g.name : null;
  }
  if (ownerType === "port") return ports.find((p) => portSlug(p) === ownerId)?.name || null;
  if (ownerType === "strait") return straits.find((s) => straitSlug(s) === ownerId)?.name || null;
  if (ownerType === "pipeline") return pipelines.find((p) => pipelineSlug(p) === ownerId)?.name || null;
  if (ownerType === "base") return bases.find((b) => baseSlug(b) === ownerId)?.name || null;
  if (ownerType === "cable") return cables.find((c) => cableSlug(c) === ownerId)?.name || null;
  return null;
}

const searchSystem = initSearchSystem({
  supabase,
  getStaticEntries: buildStaticSearchEntries,
  getGroups: groupsSystem.getGroupsList,
  getOwnerLabel,
  selectStatic: selectStaticSearchEntry,
  openGroupDossier: (id, label, color) => ficheDossier.openGroupDossier(id, label, color),
  openEncyclopedieDossier: () => ficheDossier.openEncyclopedieDossier(),
  openCountryDossierByIso: async (isoA3) => {
    const c = getAllCountryRefs().find((x) => x.isoA3 === isoA3);
    if (c) await ficheDossier.openDossier(c);
  },
  openMiniDossier: (kind, id, label) => ficheDossier.openMiniDossier(kind, id, label),
  revealEntry: (entryId, categoryId) => ficheDossier.revealEntry(entryId, categoryId),
  revealSection: (sectionId, categoryId) => ficheDossier.revealSection(sectionId, categoryId),
});
document.getElementById("dossier-search-btn")!.addEventListener("click", () => searchSystem.openDossierSearch());
