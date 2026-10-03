// ---------------------------------------------------------------------------
// Points d'intérêt (POI) — nouveau système (session du 2026-10-02, voir
// PORT_STATUS.md). Réutilise la table public.map_features (créée au schéma
// v2 pour ports/détroits/bases/câbles/pipelines, jamais exploitée pour un
// autre "kind") avec kind='poi' — voir supabase/schema_v9.sql, qui doit être
// exécuté manuellement par Martin dans l'éditeur SQL Supabase AVANT que la
// création de POI ne fonctionne en production (la contrainte CHECK actuelle
// sur `kind` n'autorise pas encore 'poi').
//
// Même schéma d'initialisation que src/groups.ts/src/indicators.ts :
// initPoiSystem(deps) injecte son propre DOM dans document.body et renvoie
// des gestionnaires câblés depuis main.ts.
// ---------------------------------------------------------------------------

import type { SupabaseClient, Session } from "@supabase/supabase-js";
import * as d3 from "d3";

export type PoiEntry = {
  id: string;
  name: string;
  note: string | null;
  lon: number;
  lat: number;
  created_by: string | null;
  // Pays auquel le POI est rattaché (point 5, 2026-10-03) — country_id =
  // countries.id = isoA3 (schema_v13.sql). null pour un POI "libre", non
  // rattaché à un pays (voir le choix documenté plus bas : désormais tous
  // les NOUVEAUX POI passent par la fiche d'un pays, mais un POI déjà sans
  // pays — créé avant cette session — reste affiché sur la carte, juste
  // absent de toute fiche).
  country_id: string | null;
};

type MapFeatureRow = {
  id: string;
  kind: string;
  name: string;
  note: string | null;
  geometry: { type: string; coordinates: [number, number] };
  created_by: string | null;
  country_id: string | null;
};

// Minimal CountryRef nécessaire ici (évite d'importer tout src/dossier.ts
// pour un seul type — même champ isoA3 que CountryRef de dossier.ts).
type CountryLike = { isoA3: string; name: string };

export function initPoiSystem(deps: {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  getProfile: () => { id: string; role: string } | null;
  // Calque D3 dédié aux marqueurs POI (créé dans main.ts, au-dessus de tous
  // les autres calques — un point placé par l'utilisateur doit rester
  // visible par-dessus ports/câbles/etc.).
  gPoiLayer: d3.Selection<SVGGElement, unknown, HTMLElement | null, unknown>;
  projectLonLat: (lonlat: [number, number]) => [number, number];
  // Centre/zoome la carte sur un POI cliqué depuis la fiche pays.
  flyToLonLat: (lonlat: [number, number], zoom: number) => void;
  // Bascule la classe CSS de curseur en croix sur la carte pendant le mode
  // placement — même principe que setMapAddCursor dans src/groups.ts.
  setMapCursor: (active: boolean) => void;
  // Un seul mode "clic sur la carte" actif à la fois — coordination avec
  // src/groups.ts (ajout de pays à un groupe) et src/links.ts (création de
  // lien), qui s'annulent mutuellement entre eux de la même façon.
  onBeforeMapAddMode?: () => void;
  // Panneau latéral partagé (#infra-panel) déjà câblé dans main.ts (titre/
  // corps/fermeture/closeOtherSidePanels) — on le réutilise pour afficher un
  // POI cliqué (avec un bouton Supprimer), au lieu de dupliquer un panneau.
  closeOtherSidePanels: (exceptId: string) => void;
  // Ouvre le panneau de connexion (réutilise #auth-trigger) quand on tente
  // de créer un POI sans être connecté.
  openAuthPanel: () => void;
  showBanner: (text: string) => void;
  // Masque le bandeau #link-banner — câblé dans main.ts vers le même
  // élément que showBanner ci-dessus (voir deps.hideBanner de
  // src/links.ts pour le pattern identique déjà en place). Sans lui, le
  // bandeau "Cliquez sur la carte pour placer un point d'intérêt" restait
  // affiché indéfiniment une fois le mode placement quitté (bug confirmé
  // 2026-10-03) : rien n'appelait jamais sa fermeture.
  hideBanner?: () => void;
}) {
  const { supabase } = deps;
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;
  // Retours de Martin (2026-10-03, point 4a) : seul un compte au rôle
  // "admin" peut créer/supprimer un POI — un compte connecté mais non-admin
  // ne doit plus pouvoir écrire (voir supabase/schema_v13.sql pour le
  // pendant RLS). isAdmin() centralise cette vérification, remplaçant les
  // anciens appels directs à deps.getSession() pour gater une action
  // d'écriture (le simple fait d'être connecté reste utilisé ailleurs,
  // ex. savoir si on affiche un nom — ça n'a pas changé ici).
  function isAdmin(): boolean {
    return deps.getProfile()?.role === "admin" && !document.body.classList.contains("read-only-mode");
  }

  // --- DOM : overlay de création (nom + note) --------------------------------
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="poi-create-overlay" class="poi-overlay">
      <div class="poi-overlay-box">
        <h3>Nouveau point d'intérêt</h3>
        <label class="field-label">Nom</label>
        <input type="text" id="poi-create-name" maxlength="120" autocomplete="off">
        <label class="field-label">Note (optionnel)</label>
        <textarea id="poi-create-note" rows="3" maxlength="2000"></textarea>
        <div id="poi-create-status" class="muted"></div>
        <div class="poi-overlay-actions">
          <button type="button" id="poi-create-cancel" class="btn-small">Annuler</button>
          <button type="button" id="poi-create-submit" class="btn-primary">Créer</button>
        </div>
      </div>
    </div>
  `;
  while (root.firstChild) document.body.appendChild(root.firstChild);

  const overlay = $("poi-create-overlay");
  const nameInput = $("poi-create-name") as HTMLInputElement;
  const noteInput = $("poi-create-note") as HTMLTextAreaElement;
  const statusEl = $("poi-create-status");
  const submitBtn = $("poi-create-submit") as HTMLButtonElement;

  // --- État -------------------------------------------------------------
  const pois: PoiEntry[] = [];
  let placementActive = false;
  // Pays cible du POI en cours de création — point 5 (2026-10-03) : le
  // mode placement ne démarre plus QUE depuis le bouton "+ Point d'intérêt"
  // de la fiche d'un pays (voir renderFichePoiWidget plus bas ; l'ancien
  // bouton générique #poi-add-btn de la barre d'outils, sans rattachement,
  // a été retiré de main.ts). pendingCountryId est posé à l'entrée en mode
  // placement et reste en mémoire jusqu'à la création effective, pour que
  // le POI créé juste après soit automatiquement rattaché à ce pays.
  let pendingCountryId: string | null = null;
  // Position cliquée en attente de création — conservée tant que l'overlay
  // de création est ouvert, même si l'utilisateur doit d'abord se connecter
  // (voir handleSubmit ci-dessous) : il ne perd pas son point en se
  // connectant, il n'a qu'à cliquer "Créer" à nouveau une fois connecté.
  let pendingLatLng: { lat: number; lng: number } | null = null;

  function setPlacementActive(active: boolean) {
    placementActive = active;
    deps.setMapCursor(active);
  }

  // Démarre le mode placement pour un pays donné — appelé depuis le bouton
  // "+ Point d'intérêt" de la fiche pays (src/dossier.ts, renderFichePoi).
  function startPlacementForCountry(countryId: string) {
    pendingCountryId = countryId;
    deps.onBeforeMapAddMode?.();
    setPlacementActive(true);
    deps.showBanner("Cliquez sur la carte pour placer le point d'intérêt (Échap pour annuler).");
  }
  function exitPlacementMode() {
    setPlacementActive(false);
    pendingCountryId = null;
    deps.hideBanner?.();
  }

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && placementActive) exitPlacementMode();
  });

  function openCreateOverlay(lat: number, lng: number) {
    pendingLatLng = { lat, lng };
    nameInput.value = "";
    noteInput.value = "";
    statusEl.textContent = "";
    overlay.classList.add("open");
    setTimeout(() => nameInput.focus(), 30);
  }
  function closeCreateOverlay() {
    overlay.classList.remove("open");
    pendingLatLng = null;
    pendingCountryId = null;
  }
  $("poi-create-cancel").addEventListener("click", closeCreateOverlay);
  overlay.addEventListener("click", (e) => {
    if (e.target === overlay) closeCreateOverlay();
  });

  async function handleSubmit() {
    if (!pendingLatLng) return;
    const name = nameInput.value.trim();
    if (!name) {
      statusEl.textContent = "Le nom est obligatoire.";
      return;
    }
    const session = deps.getSession();
    if (!session) {
      statusEl.textContent = "Connectez-vous pour créer un point d'intérêt (votre emplacement reste en mémoire).";
      deps.openAuthPanel();
      return;
    }
    if (!isAdmin()) {
      statusEl.textContent = "Tu n'as pas les droits d'édition sur cet atlas.";
      return;
    }
    const note = noteInput.value.trim() || null;
    const countryId = pendingCountryId;
    submitBtn.disabled = true;
    statusEl.textContent = "Enregistrement…";
    try {
      const { data, error } = await supabase
        .from("map_features")
        .insert({
          kind: "poi",
          name,
          note,
          geometry: { type: "Point", coordinates: [pendingLatLng.lng, pendingLatLng.lat] },
          created_by: session.user.id,
          country_id: countryId,
        })
        .select("id, name, note, geometry, created_by, country_id")
        .single();
      if (error) throw error;
      const row = data as MapFeatureRow;
      pois.push({
        id: row.id,
        name: row.name,
        note: row.note,
        lon: row.geometry.coordinates[0],
        lat: row.geometry.coordinates[1],
        created_by: row.created_by,
        country_id: row.country_id,
      });
      redraw();
      closeCreateOverlay();
      if (countryId) onPoiListChanged.forEach((fn) => fn(countryId));
    } catch (err) {
      console.error("Failed to create POI:", err);
      statusEl.textContent =
        "Échec de l'enregistrement. Si l'erreur persiste, la migration supabase/schema_v9.sql n'a peut-être pas encore été exécutée (voir PORT_STATUS.md).";
    } finally {
      submitBtn.disabled = false;
    }
  }
  submitBtn.addEventListener("click", handleSubmit);

  // Petits callbacks enregistrés par renderFichePoiWidget pour rafraîchir sa
  // liste quand un POI de son pays est créé/supprimé par un autre chemin
  // (ex. overlay de création ouvert depuis la fiche, mais le widget a pu
  // être démonté entre-temps — voir son propre re-render à l'ouverture).
  const onPoiListChanged: ((countryId: string) => void)[] = [];

  // --- Clic sur la carte (placement) -----------------------------------
  // Appelé depuis main.ts sur chaque `map.on("click", ...)`. Renvoie true si
  // le clic a été consommé par le mode placement (pour que main.ts ne
  // déclenche pas d'autre comportement sur ce même clic, le cas échéant).
  function handleMapClick(latlng: { lat: number; lng: number }): boolean {
    if (!placementActive) return false;
    const countryId = pendingCountryId;
    exitPlacementMode();
    pendingCountryId = countryId;
    openCreateOverlay(latlng.lat, latlng.lng);
    return true;
  }
  // Appelé depuis redrawBorders() (clic sur un pays) : consomme aussi le
  // clic pendant le mode placement, exactement comme pour les modes
  // "ajouter un pays à un groupe"/"créer un lien" déjà en place — sans quoi
  // cliquer sur un pays en mode placement ouvrirait à la fois sa fiche ET
  // poserait un POI.
  function isPlacementActive(): boolean {
    return placementActive;
  }

  // Supprime un POI (gaté admin, point 4a) — factorisé entre showPoi
  // (panneau #infra-panel) et renderFichePoiWidget (fiche pays).
  async function deletePoi(poi: PoiEntry): Promise<boolean> {
    if (!isAdmin()) return false;
    if (!window.confirm("Supprimer ce point d'intérêt ?")) return false;
    const { error } = await supabase.from("map_features").delete().eq("id", poi.id);
    if (error) {
      console.error("Failed to delete POI:", error);
      return false;
    }
    const idx = pois.findIndex((p) => p.id === poi.id);
    if (idx !== -1) pois.splice(idx, 1);
    redraw();
    return true;
  }

  // --- Affichage/suppression d'un POI cliqué (réutilise #infra-panel) ---
  function showPoi(poi: PoiEntry) {
    deps.closeOtherSidePanels("infra-panel");
    const panel = document.getElementById("infra-panel")!;
    const title = document.getElementById("infra-panel-title")!;
    const body = document.getElementById("infra-panel-body")!;
    panel.classList.add("open");
    title.textContent = poi.name;
    body.classList.remove("empty");
    body.replaceChildren();

    const dl = document.createElement("dl");
    const dt = document.createElement("dt");
    dt.textContent = "Type";
    const dd = document.createElement("dd");
    dd.textContent = "Point d'intérêt";
    dl.append(dt, dd);
    if (poi.note) {
      const dt2 = document.createElement("dt");
      dt2.textContent = "Note";
      const dd2 = document.createElement("dd");
      dd2.textContent = poi.note;
      dl.append(dt2, dd2);
    }
    body.appendChild(dl);

    if (isAdmin()) {
      const delBtn = document.createElement("button");
      delBtn.type = "button";
      delBtn.className = "btn-small edit-control";
      delBtn.style.marginTop = "10px";
      delBtn.textContent = "Supprimer ce point d'intérêt";
      delBtn.addEventListener("click", async () => {
        delBtn.disabled = true;
        const ok = await deletePoi(poi);
        if (ok) {
          panel.classList.remove("open");
        } else {
          delBtn.disabled = false;
          delBtn.textContent = "Échec de la suppression — réessayer";
        }
      });
      body.appendChild(delBtn);
    }
  }

  // --- Calque carte -------------------------------------------------------
  function slug(id: string): string {
    return "poi-" + id;
  }
  function redraw() {
    deps.gPoiLayer
      .selectAll<SVGGElement, PoiEntry>("g.poi-marker")
      .data(pois, (d) => d.id)
      .join((enter) => {
        const g = enter.append("g").attr("class", "poi-marker").attr("data-slug", (d) => slug(d.id));
        g.append("path")
          .attr("class", "poi-pin")
          .attr(
            "d",
            // Même silhouette "goutte" que l'icône du bouton #poi-add-btn
            // (viewBox 24x24, pointe en bas), recentrée pour que la pointe
            // touche exactement [lon, lat].
            "M0,8.5C0,3.8,3.6,0,8,0s8,3.8,8,8.5C16,14.3,8,24,8,24S0,14.3,0,8.5Z"
          )
          .attr("transform", "translate(-8,-24) scale(0.95)");
        g.append("circle").attr("class", "poi-pin-dot").attr("cx", 0).attr("cy", -16.5).attr("r", 2.6);
        return g;
      })
      .attr("transform", (d) => {
        const c = deps.projectLonLat([d.lon, d.lat]);
        return "translate(" + c[0] + "," + c[1] + ")";
      })
      .on("click", (event, d) => {
        event.stopPropagation();
        showPoi(d);
      });
  }

  // --- Chargement initial -------------------------------------------------
  const ready = supabase
    .from("map_features")
    .select("id, name, note, geometry, created_by, country_id")
    .eq("kind", "poi")
    .then(({ data, error }) => {
      if (error) {
        console.error("Failed to load POIs (schema_v9.sql/schema_v13.sql exécutées ?):", error);
        return;
      }
      (data as MapFeatureRow[] | null)?.forEach((row) => {
        pois.push({
          id: row.id,
          name: row.name,
          note: row.note,
          lon: row.geometry.coordinates[0],
          lat: row.geometry.coordinates[1],
          created_by: row.created_by,
          country_id: row.country_id ?? null,
        });
      });
      redraw();
    });

  // --- Widget "Points d'intérêt" de la fiche pays (point 5, 2026-10-03) —
  // même principe que renderFicheLinksWidget (src/links.ts) : liste les POI
  // rattachés à ce pays (country_id === country.isoA3), cliquables (centre
  // la carte dessus) et supprimables si admin, + bouton "+ Point d'intérêt"
  // qui démarre le mode placement pour CE pays.
  function renderFichePoiWidget(container: HTMLElement, country: CountryLike) {
    function render() {
      container.replaceChildren();
      const label = document.createElement("label");
      label.className = "field-label";
      label.textContent = "Points d'intérêt";
      container.appendChild(label);
      const list = pois.filter((p) => p.country_id === country.isoA3);
      if (list.length) {
        const wrap = document.createElement("div");
        wrap.className = "fiche-poi-list";
        list.forEach((poi) => {
          const row = document.createElement("div");
          row.className = "fiche-poi-row";
          const btn = document.createElement("button");
          btn.type = "button";
          btn.className = "fiche-poi-name";
          btn.textContent = poi.name;
          btn.title = "Centrer la carte sur ce point";
          btn.addEventListener("click", () => {
            deps.flyToLonLat([poi.lon, poi.lat], 7);
            showPoi(poi);
          });
          row.appendChild(btn);
          if (isAdmin()) {
            const del = document.createElement("button");
            del.type = "button";
            del.className = "entry-del edit-control";
            del.style.cssText = "position:static;opacity:1;";
            del.innerHTML =
              '<svg class="icon-svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/></svg>';
            del.title = "Supprimer ce point d'intérêt";
            del.addEventListener("click", async (e) => {
              e.stopPropagation();
              if (await deletePoi(poi)) render();
            });
            row.appendChild(del);
          }
          wrap.appendChild(row);
        });
        container.appendChild(wrap);
      }
      if (isAdmin()) {
        const addBtn = document.createElement("button");
        addBtn.type = "button";
        addBtn.className = "btn-small edit-control";
        addBtn.textContent = "+ Point d'intérêt";
        addBtn.addEventListener("click", () => startPlacementForCountry(country.isoA3));
        container.appendChild(addBtn);
      }
    }
    render();
    const idx = onPoiListChanged.push((countryId) => {
      if (countryId === country.isoA3) render();
    }) - 1;
    void idx; // la fiche entière est reconstruite à chaque ouverture (voir dossier.ts openFiche) : pas besoin de désinscrire explicitement, les anciens callbacks ciblent un container détaché et deviennent inoffensifs.
  }

  return {
    ready,
    redraw,
    handleMapClick,
    isPlacementActive,
    exitPlacementMode,
    startPlacementForCountry,
    renderFichePoiWidget,
    setLayerVisible: (show: boolean) => {
      if (show) deps.gPoiLayer.style("display", null);
      else deps.gPoiLayer.style("display", "none");
    },
  };
}
