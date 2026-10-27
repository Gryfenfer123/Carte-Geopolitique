// Outil de croquis — point d'entrée, branché depuis main.ts (une seule ligne).
//
// Demande de Martin (2026-10-27) : un outil de dessin « à la Illustrator » sur la carte, pour
// créer des croquis et en afficher. Voir docs/specs/croquis.md.
//
// Qui dessine : les comptes administrateurs, hors « mode lecture » (comme le reste de l'appli).
// Où sont gardés les croquis : PROVISOIREMENT dans ce navigateur (sketchStore.ts) ; le rangement
// dans les dossiers pays/groupes viendra avec une migration, après accord de Martin.

import "./sketch.css";
import type L from "leaflet";
import { createSketchView } from "./sketchLayer";
import { createEditor } from "./sketchEditor";
import { createSketchPanel, sketchButtonHtml, type PanelApi } from "./sketchPanel";
import { loadAllDocs, loadShown, removeDoc, saveDoc, saveShown } from "./sketchStore";
import { newDoc, uid, type SketchDoc } from "./sketchModel";
import { docBounds } from "./sketchSvg";
import { mercToLngLat } from "./sketchGeometry";

export function initSketchSystem(deps: {
  map: L.Map;
  isEditor: () => boolean;
  onReadOnlyModeChanged: (fn: () => void) => void;
  showBanner: (msg: string) => void;
}) {
  const { map } = deps;
  const stage = document.getElementById("stage");
  if (!stage) return;

  let docs: SketchDoc[] = loadAllDocs();
  const shown = new Set(loadShown().filter((id) => docs.some((d) => d.id === id)));
  let editingId: string | null = null;
  let saveTimer = 0;

  // Bouton dans la rangée des outils, en bas à droite (même gabarit que les autres boutons).
  const toggle = document.createElement("div");
  toggle.id = "sketch-toggle";
  toggle.className = "panel";
  toggle.innerHTML = `<button id="sketch-btn" title="Croquis (dessiner sur la carte)" aria-label="Croquis">${sketchButtonHtml()}</button>`;
  stage.appendChild(toggle);

  const view = createSketchView(map);

  function persist(doc: SketchDoc) {
    docs = docs.some((d) => d.id === doc.id) ? docs.map((d) => (d.id === doc.id ? doc : d)) : [...docs, doc];
    if (!saveDoc(doc)) deps.showBanner("Enregistrement impossible dans ce navigateur (stockage plein ou interdit) : exporte ton croquis en JSON.");
  }

  const editor = createEditor(view, {
    onDocChanged(doc) {
      docs = docs.map((d) => (d.id === doc.id ? doc : d));
      window.clearTimeout(saveTimer);
      saveTimer = window.setTimeout(() => persist(doc), 500);
    },
    toast: deps.showBanner,
  });

  function syncView() {
    view.setViewDocs(docs.filter((d) => shown.has(d.id) && d.id !== editingId));
  }

  const api: PanelApi = {
      listDocs: () => docs,
      isShown: (id) => shown.has(id),
      setShown(id, on) {
        if (on) shown.add(id);
        else shown.delete(id);
        saveShown([...shown]);
        syncView();
      },
      newDoc() {
        if (!deps.isEditor()) return;
        const d = newDoc("Croquis sans titre");
        docs = [...docs, d];
        persist(d);
        api.editDoc(d.id);
      },
      editDoc(id) {
        if (!deps.isEditor()) return;
        const d = docs.find((x) => x.id === id);
        if (!d) return;
        if (editingId) api.stopEditing();
        editingId = id;
        shown.add(id);
        saveShown([...shown]);
        editor.open(d);
        syncView();
        panel.showEdit();
      },
      stopEditing() {
        window.clearTimeout(saveTimer);
        const last = editor.close();
        if (last) persist(last);
        editingId = null;
        syncView();
        panel.showList();
      },
      deleteDoc(id) {
        window.clearTimeout(saveTimer);
        if (editingId === id) {
          editor.close();
          editingId = null;
        }
        docs = docs.filter((d) => d.id !== id);
        shown.delete(id);
        removeDoc(id);
        saveShown([...shown]);
        syncView();
        panel.showList();
      },
      importDoc(doc) {
        const d = docs.some((x) => x.id === doc.id) ? { ...doc, id: uid(), title: `${doc.title} (importé)` } : doc;
        docs = [...docs, d];
        shown.add(d.id);
        persist(d);
        saveShown([...shown]);
        syncView();
        panel.showList();
        deps.showBanner(`Croquis « ${d.title} » importé.`);
      },
      zoomTo(id) {
        const d = docs.find((x) => x.id === id);
        const b = d ? docBounds(editingId === id ? (editor.snapshot().doc ?? d) : d) : null;
        if (!b) {
          deps.showBanner("Ce croquis est vide : rien à montrer.");
          return;
        }
        shown.add(id);
        saveShown([...shown]);
        syncView();
        const sw = mercToLngLat({ x: b.minX, y: b.minY });
        const ne = mercToLngLat({ x: b.maxX, y: b.maxY });
        map.fitBounds(
          [
            [sw.lat, sw.lng],
            [ne.lat, ne.lng],
          ],
          { padding: [80, 80], maxZoom: 16 },
        );
        if (panel.isOpen()) panel.refresh();
      },
      toast: deps.showBanner,
  };
  const panel = createSketchPanel({ host: stage, editor, isEditor: deps.isEditor, api });
  document.getElementById("sketch-btn")!.addEventListener("click", () => panel.toggle());

  // Perdre les droits (déconnexion, « mode lecture ») pendant l'édition : on enregistre et on ferme l'édition.
  deps.onReadOnlyModeChanged(() => {
    if (!deps.isEditor() && editingId) api.stopEditing();
    panel.refresh();
  });

  // Avant de quitter la page : enregistrer ce qui est en cours.
  window.addEventListener("beforeunload", () => {
    const d = editor.snapshot().doc;
    if (d) saveDoc(d);
  });

  syncView();
}
