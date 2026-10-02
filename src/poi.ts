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
};

type MapFeatureRow = {
  id: string;
  kind: string;
  name: string;
  note: string | null;
  geometry: { type: string; coordinates: [number, number] };
  created_by: string | null;
};

export function initPoiSystem(deps: {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  // Calque D3 dédié aux marqueurs POI (créé dans main.ts, au-dessus de tous
  // les autres calques — un point placé par l'utilisateur doit rester
  // visible par-dessus ports/câbles/etc.).
  gPoiLayer: d3.Selection<SVGGElement, unknown, HTMLElement | null, unknown>;
  projectLonLat: (lonlat: [number, number]) => [number, number];
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
}) {
  const { supabase } = deps;
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

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

  // Bouton "placer un POI" (dans #poi-toggle, markup de main.ts).
  const addBtn = document.getElementById("poi-add-btn") as HTMLButtonElement;

  // --- État -------------------------------------------------------------
  const pois: PoiEntry[] = [];
  let placementActive = false;
  // Position cliquée en attente de création — conservée tant que l'overlay
  // de création est ouvert, même si l'utilisateur doit d'abord se connecter
  // (voir handleSubmit ci-dessous) : il ne perd pas son point en se
  // connectant, il n'a qu'à cliquer "Créer" à nouveau une fois connecté.
  let pendingLatLng: { lat: number; lng: number } | null = null;

  function setPlacementActive(active: boolean) {
    placementActive = active;
    addBtn.classList.toggle("placing", active);
    deps.setMapCursor(active);
  }

  function enterPlacementMode() {
    deps.onBeforeMapAddMode?.();
    setPlacementActive(true);
    deps.showBanner("Cliquez sur la carte pour placer un point d'intérêt (Échap pour annuler).");
  }
  function exitPlacementMode() {
    setPlacementActive(false);
  }

  addBtn.addEventListener("click", () => {
    if (placementActive) exitPlacementMode();
    else enterPlacementMode();
  });

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
    const note = noteInput.value.trim() || null;
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
        })
        .select("id, name, note, geometry, created_by")
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
      });
      redraw();
      closeCreateOverlay();
    } catch (err) {
      console.error("Failed to create POI:", err);
      statusEl.textContent =
        "Échec de l'enregistrement. Si l'erreur persiste, la migration supabase/schema_v9.sql n'a peut-être pas encore été exécutée (voir PORT_STATUS.md).";
    } finally {
      submitBtn.disabled = false;
    }
  }
  submitBtn.addEventListener("click", handleSubmit);

  // --- Clic sur la carte (placement) -----------------------------------
  // Appelé depuis main.ts sur chaque `map.on("click", ...)`. Renvoie true si
  // le clic a été consommé par le mode placement (pour que main.ts ne
  // déclenche pas d'autre comportement sur ce même clic, le cas échéant).
  function handleMapClick(latlng: { lat: number; lng: number }): boolean {
    if (!placementActive) return false;
    exitPlacementMode();
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

    const session = deps.getSession();
    if (session) {
      const delBtn = document.createElement("button");
      delBtn.type = "button";
      delBtn.className = "btn-small";
      delBtn.style.marginTop = "10px";
      delBtn.textContent = "Supprimer ce point d'intérêt";
      delBtn.addEventListener("click", async () => {
        if (!window.confirm("Supprimer ce point d'intérêt ?")) return;
        delBtn.disabled = true;
        try {
          const { error } = await supabase.from("map_features").delete().eq("id", poi.id);
          if (error) throw error;
          const idx = pois.findIndex((p) => p.id === poi.id);
          if (idx !== -1) pois.splice(idx, 1);
          redraw();
          panel.classList.remove("open");
        } catch (err) {
          console.error("Failed to delete POI:", err);
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
    .select("id, name, note, geometry, created_by")
    .eq("kind", "poi")
    .then(({ data, error }) => {
      if (error) {
        console.error("Failed to load POIs (schema_v9.sql exécutée ?):", error);
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
        });
      });
      redraw();
    });

  return {
    ready,
    redraw,
    handleMapClick,
    isPlacementActive,
    exitPlacementMode,
    setLayerVisible: (show: boolean) => {
      if (show) deps.gPoiLayer.style("display", null);
      else deps.gPoiLayer.style("display", "none");
    },
  };
}
