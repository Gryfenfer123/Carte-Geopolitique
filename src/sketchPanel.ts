// Outil de croquis — le panneau (liste des croquis, outils, style, calques, export).
//
// Deux écrans : la LISTE des croquis (afficher / masquer sur la carte, modifier, supprimer) et
// l'écran d'ÉDITION. L'écran d'édition est construit une seule fois ; on met ensuite à jour les
// valeurs des champs sans le reconstruire (sinon un curseur de couleur perdrait le focus à
// chaque mouvement).

import { FONTS, parseDoc, type PathObject, type SketchDoc, type SketchStyle, type TextObject } from "./sketchModel";
import { TOOL_LABELS, type Editor, type Tool } from "./sketchEditor";
import { esc } from "./sketchSvg";

export type PanelApi = {
  listDocs(): SketchDoc[];
  isShown(id: string): boolean;
  setShown(id: string, on: boolean): void;
  newDoc(): void;
  editDoc(id: string): void;
  deleteDoc(id: string): void;
  importDoc(doc: SketchDoc): void;
  stopEditing(): void;
  zoomTo(id: string): void;
  toast(msg: string): void;
};

export type SketchPanel = {
  open(): void;
  close(): void;
  toggle(): void;
  isOpen(): boolean;
  /** À rappeler quand la liste des croquis ou les droits changent. */
  refresh(): void;
  showList(): void;
  showEdit(): void;
};

const ICON_CROQUIS =
  `<svg class="icon-svg" style="width:17px;height:17px;" viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20l4-1 11-11a2.1 2.1 0 0 0-3-3L5 16l-1 4z"/><path d="M14 7l3 3"/></svg>`;

export function sketchButtonHtml(): string {
  return ICON_CROQUIS;
}

function hex(c: string | null | undefined, fallback = "#888888"): string {
  if (!c) return fallback;
  if (/^#[0-9a-f]{6}$/i.test(c)) return c.toLowerCase();
  const m = /^#([0-9a-f])([0-9a-f])([0-9a-f])$/i.exec(c);
  if (m) return `#${m[1]}${m[1]}${m[2]}${m[2]}${m[3]}${m[3]}`.toLowerCase();
  return fallback;
}

function slug(s: string): string {
  return (
    s
      .normalize("NFD")
      .replace(/[̀-ͯ]/g, "")
      .replace(/[^a-zA-Z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .toLowerCase() || "croquis"
  );
}

function download(blob: Blob, name: string) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = name;
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 2000);
}

const TOOL_ORDER: Tool[] = ["select", "direct", "pen", "pencil", "line", "rect", "ellipse", "text", "hand"];

const EDIT_HTML = `
  <div class="sk-head">
    <button type="button" class="sk-btn" data-act="back" title="Enregistrer et revenir à la liste">&larr; Liste</button>
    <span class="sk-saved" data-saved>Enregistré dans ce navigateur</span>
    <button type="button" class="sk-x" data-act="close" aria-label="Fermer">&times;</button>
  </div>
  <input class="sk-title" data-f="title" type="text" placeholder="Titre du croquis" maxlength="160">
  <textarea class="sk-sources" data-f="sources" rows="2" placeholder="Sources des données (obligatoire pour un croquis publié)"></textarea>

  <div class="sk-tools" data-tools>
    ${TOOL_ORDER.map(
      (t) => `<button type="button" class="sk-tool" data-tool="${t}" title="${esc(TOOL_LABELS[t].label)} (${TOOL_LABELS[t].key}) — ${esc(TOOL_LABELS[t].hint)}">${TOOL_LABELS[t].label}<kbd>${TOOL_LABELS[t].key}</kbd></button>`,
    ).join("")}
  </div>
  <div class="sk-row">
    <button type="button" class="sk-btn" data-act="undo" title="Annuler (Ctrl+Z)">Annuler</button>
    <button type="button" class="sk-btn" data-act="redo" title="Refaire (Ctrl+Y)">Refaire</button>
    <button type="button" class="sk-btn" data-act="duplicate" title="Dupliquer (Ctrl+D)">Dupliquer</button>
    <button type="button" class="sk-btn" data-act="delete" title="Supprimer (Suppr)">Supprimer</button>
  </div>

  <details class="sk-sec" open>
    <summary data-style-title>Style</summary>
    <div class="sk-grid">
      <label>Remplissage</label>
      <span class="sk-inline"><input type="color" data-s="fill"><label class="sk-chk"><input type="checkbox" data-s="fillNone"> aucun</label></span>
      <label>Opacité du remplissage</label>
      <input type="range" min="0" max="1" step="0.05" data-s="fillOpacity">
      <label>Contour</label>
      <span class="sk-inline"><input type="color" data-s="stroke"><label class="sk-chk"><input type="checkbox" data-s="strokeNone"> aucun</label></span>
      <label>Épaisseur</label>
      <span class="sk-inline"><input type="number" min="0" step="0.5" data-s="strokeWidth" class="sk-num"><select data-s="widthMode"><option value="screen">pixels (écran)</option><option value="map">mètres (carte)</option></select></span>
      <label>Trait</label>
      <select data-s="dash"><option value="solid">continu</option><option value="dashed">tirets</option><option value="dotted">points</option></select>
      <label>Bouts / angles</label>
      <span class="sk-inline"><select data-s="cap"><option value="round">arrondi</option><option value="butt">plat</option><option value="square">carré</option></select><select data-s="join"><option value="round">arrondi</option><option value="miter">pointu</option><option value="bevel">biseauté</option></select></span>
      <label>Opacité de l'objet</label>
      <input type="range" min="0" max="1" step="0.05" data-s="opacity">
      <label>Flèches</label>
      <span class="sk-inline"><label class="sk-chk"><input type="checkbox" data-s="arrowStart"> début</label><label class="sk-chk"><input type="checkbox" data-s="arrowEnd"> fin</label><input type="number" min="1" max="30" step="0.5" data-s="arrowSize" class="sk-num" title="Taille de la pointe (× épaisseur)"></span>
    </div>
  </details>

  <details class="sk-sec" open data-text-sec>
    <summary>Texte</summary>
    <div class="sk-grid">
      <label>Taille / police</label>
      <span class="sk-inline"><input type="number" min="4" max="400" step="1" data-t="fontSize" class="sk-num"><select data-t="fontFamily">${FONTS.map((f) => `<option value="${f.id}">${esc(f.label)}</option>`).join("")}</select></span>
      <label>Style</label>
      <span class="sk-inline"><label class="sk-chk"><input type="checkbox" data-t="bold"> gras</label><label class="sk-chk"><input type="checkbox" data-t="italic"> italique</label><select data-t="anchor"><option value="start">à gauche</option><option value="middle">centré</option><option value="end">à droite</option></select></span>
      <label>Couleur</label>
      <span class="sk-inline"><input type="color" data-t="color"><label class="sk-chk"><input type="checkbox" data-t="haloOn"> contour</label><input type="color" data-t="halo"></span>
      <label>Opacité</label>
      <input type="range" min="0" max="1" step="0.05" data-t="opacity">
    </div>
  </details>

  <details class="sk-sec">
    <summary>Organiser</summary>
    <div class="sk-row">
      <button type="button" class="sk-btn" data-arrange="front" title="Mettre devant">Devant</button>
      <button type="button" class="sk-btn" data-arrange="forward" title="Avancer d'un cran">+1</button>
      <button type="button" class="sk-btn" data-arrange="backward" title="Reculer d'un cran">&minus;1</button>
      <button type="button" class="sk-btn" data-arrange="back" title="Mettre derrière">Derrière</button>
    </div>
    <div class="sk-row">
      <button type="button" class="sk-btn" data-act="group" title="Grouper (Ctrl+G)">Grouper</button>
      <button type="button" class="sk-btn" data-act="ungroup" title="Dégrouper (Ctrl+Maj+G)">Dégrouper</button>
      <button type="button" class="sk-btn" data-flip="h" title="Miroir horizontal">Miroir &harr;</button>
      <button type="button" class="sk-btn" data-flip="v" title="Miroir vertical">Miroir &varr;</button>
    </div>
    <div class="sk-row">
      <button type="button" class="sk-btn" data-align="left">Gauche</button>
      <button type="button" class="sk-btn" data-align="center">Centre</button>
      <button type="button" class="sk-btn" data-align="right">Droite</button>
      <button type="button" class="sk-btn" data-align="top">Haut</button>
      <button type="button" class="sk-btn" data-align="middle">Milieu</button>
      <button type="button" class="sk-btn" data-align="bottom">Bas</button>
    </div>
  </details>

  <details class="sk-sec" open>
    <summary>Calques</summary>
    <div class="sk-layers" data-layers></div>
    <div class="sk-row"><button type="button" class="sk-btn" data-act="addlayer">+ Calque</button></div>
  </details>

  <details class="sk-sec">
    <summary>Exporter</summary>
    <div class="sk-row">
      <button type="button" class="sk-btn" data-export="svg" title="Fichier vectoriel : s'ouvre dans Illustrator, Inkscape…">SVG</button>
      <button type="button" class="sk-btn" data-export="png" title="Image à fond transparent">PNG</button>
      <button type="button" class="sk-btn" data-export="json" title="Sauvegarde complète, réimportable">JSON</button>
    </div>
  </details>
`;

export function createSketchPanel(deps: {
  host: HTMLElement;
  editor: Editor;
  isEditor: () => boolean;
  api: PanelApi;
}): SketchPanel {
  const { editor, api } = deps;
  const root = document.createElement("div");
  root.id = "sketch-panel";
  root.className = "panel sk-panel";
  root.style.display = "none";
  deps.host.appendChild(root);

  let mode: "list" | "edit" = "list";
  let opened = false;
  let armedDelete: string | null = null;
  let armedTimer = 0;

  // ------------------------------------------------------------------ liste

  function renderList() {
    const docs = api.listDocs();
    const canEdit = deps.isEditor();
    root.innerHTML = `
      <div class="sk-head"><strong>Croquis</strong><button type="button" class="sk-x" data-act="close" aria-label="Fermer">&times;</button></div>
      <p class="sk-note">Les croquis sont enregistrés dans <b>ce navigateur</b> (provisoire) : exporte-les en JSON ou SVG pour les conserver.</p>
      <div class="sk-list">${
        docs.length === 0
          ? `<p class="sk-empty">Aucun croquis pour l'instant.</p>`
          : docs
              .map(
                (d) => `<div class="sk-item" data-id="${esc(d.id)}">
          <label class="sk-chk" title="Afficher sur la carte"><input type="checkbox" data-show="${esc(d.id)}" ${api.isShown(d.id) ? "checked" : ""}> <span class="sk-name">${esc(d.title || "Sans titre")}</span></label>
          <button type="button" class="sk-mini" data-zoom="${esc(d.id)}" title="Zoomer sur ce croquis">Voir</button>
          ${canEdit ? `<button type="button" class="sk-mini" data-edit="${esc(d.id)}">Modifier</button><button type="button" class="sk-mini sk-danger" data-del="${esc(d.id)}">${armedDelete === d.id ? "Confirmer ?" : "&times;"}</button>` : ""}
        </div>`,
              )
              .join("")
      }</div>
      ${
        canEdit
          ? `<div class="sk-row"><button type="button" class="sk-btn sk-primary" data-act="new">+ Nouveau croquis</button><button type="button" class="sk-btn" data-act="import">Importer…</button><input type="file" accept=".json,application/json" data-import hidden></div>`
          : `<p class="sk-note">Modification réservée aux administrateurs.</p>`
      }`;
  }

  root.addEventListener("click", (e) => {
    const t = (e.target as HTMLElement).closest<HTMLElement>("button, input[data-show]");
    if (!t) return;
    const d = t.dataset;
    if (d.act === "close") return close();
    if (d.act === "back") return api.stopEditing();
    if (d.act === "new") return api.newDoc();
    if (d.act === "import") return root.querySelector<HTMLInputElement>("[data-import]")?.click();
    if (d.edit) return api.editDoc(d.edit);
    if (d.zoom) return api.zoomTo(d.zoom);
    if (d.del) {
      if (armedDelete === d.del) {
        armedDelete = null;
        window.clearTimeout(armedTimer);
        api.deleteDoc(d.del);
      } else {
        armedDelete = d.del;
        window.clearTimeout(armedTimer);
        armedTimer = window.setTimeout(() => {
          armedDelete = null;
          if (mode === "list") renderList();
        }, 3000);
        renderList();
      }
      return;
    }
    // Écran d'édition
    if (d.tool) return editor.setTool(d.tool as Tool);
    switch (d.act) {
      case "undo": return editor.undo();
      case "redo": return editor.redo();
      case "duplicate": return editor.duplicate();
      case "delete": return editor.deleteSelection();
      case "group": return editor.group();
      case "ungroup": return editor.ungroup();
      case "addlayer": return editor.addLayer();
    }
    if (d.arrange) return editor.arrange(d.arrange as "front" | "back" | "forward" | "backward");
    if (d.align) return editor.align(d.align as "left" | "center" | "right" | "top" | "middle" | "bottom");
    if (d.flip) return editor.flip(d.flip as "h" | "v");
    if (d.export) return doExport(d.export);
    if (d.l) return layerAction(t);
  });

  root.addEventListener("change", (e) => {
    const el = e.target as HTMLInputElement;
    if (el.dataset.show) api.setShown(el.dataset.show, el.checked);
    if (el.matches("[data-import]") && el.files?.[0]) {
      const file = el.files[0];
      void file.text().then((txt) => {
        let parsed: SketchDoc | null = null;
        try {
          parsed = parseDoc(JSON.parse(txt));
        } catch {
          parsed = null;
        }
        if (parsed) api.importDoc(parsed);
        else api.toast("Fichier non reconnu : ce n'est pas un croquis exporté par l'outil.");
        el.value = "";
      });
    }
  });

  // ------------------------------------------------------------------ édition : saisie des champs

  const q = <T extends HTMLElement>(sel: string) => root.querySelector<T>(sel);

  function onInput(e: Event) {
    const el = e.target as HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement;
    const ds = el.dataset;
    if (ds.f === "title") return editor.setMeta({ title: el.value });
    if (ds.f === "sources") return editor.setMeta({ sources: el.value });
    const num = () => Number((el as HTMLInputElement).value);
    const chk = () => (el as HTMLInputElement).checked;
    if (ds.s) {
      const k = ds.s;
      if (k === "fill") return editor.applyStyle({ fill: el.value });
      if (k === "fillNone") return editor.applyStyle({ fill: chk() ? null : hex(q<HTMLInputElement>('[data-s="fill"]')?.value, "#e8b34a") });
      if (k === "stroke") return editor.applyStyle({ stroke: el.value });
      if (k === "strokeNone") return editor.applyStyle({ stroke: chk() ? null : hex(q<HTMLInputElement>('[data-s="stroke"]')?.value, "#e8b34a") });
      if (k === "fillOpacity" || k === "opacity") return editor.applyStyle({ [k]: num() } as Partial<SketchStyle>);
      if (k === "strokeWidth") {
        const n = num();
        if (Number.isFinite(n) && n >= 0) editor.applyStyle({ strokeWidth: n });
        return;
      }
      if (k === "arrowSize") {
        const n = num();
        if (Number.isFinite(n) && n >= 1) editor.applyStyle({ arrowSize: Math.min(30, n) });
        return;
      }
      if (k === "arrowStart" || k === "arrowEnd") return editor.applyStyle({ [k]: chk() } as Partial<SketchStyle>);
      return editor.applyStyle({ [k]: el.value } as Partial<SketchStyle>);
    }
    if (ds.t) {
      const k = ds.t;
      if (k === "fontSize") {
        const n = num();
        if (Number.isFinite(n) && n >= 4) editor.applyText({ fontSize: Math.min(400, n) });
        return;
      }
      if (k === "bold" || k === "italic") return editor.applyText({ [k]: chk() });
      if (k === "haloOn") return editor.applyText({ halo: chk() ? hex(q<HTMLInputElement>('[data-t="halo"]')?.value, "#0a0e18") : null });
      if (k === "opacity") return editor.applyText({ opacity: num() });
      return editor.applyText({ [k]: el.value });
    }
  }
  root.addEventListener("input", onInput);

  // ------------------------------------------------------------------ édition : calques

  function layerAction(btn: HTMLElement) {
    const row = btn.closest<HTMLElement>("[data-layer]");
    const id = row?.dataset.layer;
    if (!id) return;
    const doc = editor.snapshot().doc;
    const layer = doc?.layers.find((l) => l.id === id);
    switch (btn.dataset.l) {
      case "vis": return editor.updateLayer(id, { visible: !layer?.visible });
      case "lock": return editor.updateLayer(id, { locked: !layer?.locked });
      case "up": return editor.moveLayer(id, 1);
      case "down": return editor.moveLayer(id, -1);
      case "to": return editor.moveSelectionToLayer(id);
      case "del": return editor.removeLayer(id);
    }
  }

  function renderLayers() {
    const snap = editor.snapshot();
    const box = q<HTMLElement>("[data-layers]");
    if (!box || !snap.doc) return;
    const rows = snap.doc.layers
      .map(
        (l) => `<div class="sk-layer${l.id === snap.activeLayerId ? " is-active" : ""}" data-layer="${esc(l.id)}">
        <button type="button" class="sk-mini" data-l="vis" title="${l.visible ? "Masquer" : "Afficher"}">${l.visible ? "Visible" : "Masqué"}</button>
        <button type="button" class="sk-mini" data-l="lock" title="${l.locked ? "Déverrouiller" : "Verrouiller"}">${l.locked ? "Verrouillé" : "Libre"}</button>
        <span class="sk-lname" data-lname title="Clic : calque de travail — double-clic : renommer">${esc(l.name)}</span>
        <button type="button" class="sk-mini" data-l="up" title="Monter">&uarr;</button>
        <button type="button" class="sk-mini" data-l="down" title="Descendre">&darr;</button>
        <button type="button" class="sk-mini" data-l="to" title="Mettre la sélection sur ce calque">&rarr;</button>
        <button type="button" class="sk-mini sk-danger" data-l="del" title="Supprimer le calque et son contenu">&times;</button>
      </div>`,
      )
      .reverse()
      .join("");
    box.innerHTML = rows;
  }

  root.addEventListener("click", (e) => {
    const nameEl = (e.target as HTMLElement).closest<HTMLElement>("[data-lname]");
    const id = nameEl?.closest<HTMLElement>("[data-layer]")?.dataset.layer;
    if (id) editor.setActiveLayer(id);
  });
  root.addEventListener("dblclick", (e) => {
    const nameEl = (e.target as HTMLElement).closest<HTMLElement>("[data-lname]");
    const id = nameEl?.closest<HTMLElement>("[data-layer]")?.dataset.layer;
    if (!nameEl || !id) return;
    const input = document.createElement("input");
    input.type = "text";
    input.className = "sk-lname-edit";
    input.value = nameEl.textContent ?? "";
    nameEl.replaceWith(input);
    input.focus();
    input.select();
    let done = false;
    const finish = (save: boolean) => {
      if (done) return;
      done = true;
      const v = input.value.trim();
      if (save && v) editor.updateLayer(id, { name: v.slice(0, 80) });
      else renderLayers();
    };
    input.addEventListener("keydown", (ev) => {
      ev.stopPropagation();
      if (ev.key === "Enter") finish(true);
      if (ev.key === "Escape") finish(false);
    });
    input.addEventListener("blur", () => finish(true));
  });

  // ------------------------------------------------------------------ export

  function doExport(kind: string) {
    const snap = editor.snapshot();
    if (!snap.doc) return;
    const base = slug(snap.doc.title);
    if (kind === "json") {
      download(new Blob([JSON.stringify(snap.doc, null, 2)], { type: "application/json" }), `${base}.json`);
      return;
    }
    const out = editor.exportSvg();
    if (!out) {
      api.toast("Rien à exporter : le croquis est vide (ou tous ses calques sont masqués).");
      return;
    }
    if (kind === "svg") {
      download(new Blob([out.svg], { type: "image/svg+xml" }), `${base}.svg`);
      return;
    }
    const url = URL.createObjectURL(new Blob([out.svg], { type: "image/svg+xml;charset=utf-8" }));
    const img = new Image();
    img.onload = () => {
      const c = document.createElement("canvas");
      c.width = out.width;
      c.height = out.height;
      const ctx = c.getContext("2d");
      if (!ctx) return api.toast("Export PNG impossible dans ce navigateur.");
      ctx.drawImage(img, 0, 0);
      URL.revokeObjectURL(url);
      c.toBlob((b) => (b ? download(b, `${base}.png`) : api.toast("Export PNG impossible.")), "image/png");
    };
    img.onerror = () => {
      URL.revokeObjectURL(url);
      api.toast("Export PNG impossible.");
    };
    img.src = url;
  }

  // ------------------------------------------------------------------ édition : mise à jour des champs

  function setVal(sel: string, value: string | boolean | number) {
    const el = q<HTMLInputElement | HTMLSelectElement>(sel);
    if (!el || el === document.activeElement) return;
    if (el instanceof HTMLInputElement && el.type === "checkbox") el.checked = Boolean(value);
    else el.value = String(value);
  }

  function refreshEdit() {
    const snap = editor.snapshot();
    if (!snap.doc || mode !== "edit") return;
    const objs = editor.selectedObjects();
    const paths = objs.filter((o): o is PathObject => o.kind === "path");
    const texts = objs.filter((o): o is TextObject => o.kind === "text");
    const s: SketchStyle = paths[0]?.style ?? snap.defaultStyle;
    const t = texts[0] ?? { ...snap.defaultText };

    setVal('[data-f="title"]', snap.doc.title);
    setVal('[data-f="sources"]', snap.doc.sources);
    root.querySelectorAll<HTMLElement>("[data-tool]").forEach((b) => b.classList.toggle("is-active", b.dataset.tool === snap.tool));
    q<HTMLButtonElement>('[data-act="undo"]')!.disabled = !snap.canUndo;
    q<HTMLButtonElement>('[data-act="redo"]')!.disabled = !snap.canRedo;
    const title = q<HTMLElement>("[data-style-title]");
    if (title) title.textContent = paths.length ? `Style (${paths.length} tracé${paths.length > 1 ? "s" : ""} sélectionné${paths.length > 1 ? "s" : ""})` : "Style des nouveaux tracés";

    setVal('[data-s="fill"]', hex(s.fill, "#e8b34a"));
    setVal('[data-s="fillNone"]', s.fill === null);
    setVal('[data-s="fillOpacity"]', s.fillOpacity);
    setVal('[data-s="stroke"]', hex(s.stroke, "#e8b34a"));
    setVal('[data-s="strokeNone"]', s.stroke === null);
    setVal('[data-s="strokeWidth"]', s.strokeWidth);
    setVal('[data-s="widthMode"]', s.widthMode);
    setVal('[data-s="dash"]', s.dash);
    setVal('[data-s="cap"]', s.cap);
    setVal('[data-s="join"]', s.join);
    setVal('[data-s="opacity"]', s.opacity);
    setVal('[data-s="arrowStart"]', s.arrowStart);
    setVal('[data-s="arrowEnd"]', s.arrowEnd);
    setVal('[data-s="arrowSize"]', s.arrowSize);

    const textSec = q<HTMLElement>("[data-text-sec]");
    if (textSec) textSec.style.display = texts.length || snap.tool === "text" ? "" : "none";
    setVal('[data-t="fontSize"]', Math.round(t.fontSize * 10) / 10);
    setVal('[data-t="fontFamily"]', t.fontFamily);
    setVal('[data-t="bold"]', t.bold);
    setVal('[data-t="italic"]', t.italic);
    setVal('[data-t="anchor"]', t.anchor);
    setVal('[data-t="color"]', hex(t.color, "#ffffff"));
    setVal('[data-t="haloOn"]', t.halo !== null);
    setVal('[data-t="halo"]', hex(t.halo, "#0a0e18"));
    setVal('[data-t="opacity"]', t.opacity);
    renderLayers();
  }

  editor.onChange(() => {
    if (opened && mode === "edit") refreshEdit();
  });

  // ------------------------------------------------------------------ ouverture

  function showList() {
    mode = "list";
    renderList();
  }

  function showEdit() {
    mode = "edit";
    root.innerHTML = EDIT_HTML;
    refreshEdit();
  }

  function open() {
    opened = true;
    root.style.display = "";
    if (mode === "list") renderList();
    document.getElementById("sketch-btn")?.classList.add("active");
  }

  function close() {
    if (mode === "edit") api.stopEditing();
    opened = false;
    root.style.display = "none";
    document.getElementById("sketch-btn")?.classList.remove("active");
  }

  return {
    open,
    close,
    toggle: () => (opened ? close() : open()),
    isOpen: () => opened,
    refresh() {
      if (!opened) return;
      if (mode === "list") renderList();
      else refreshEdit();
    },
    showList,
    showEdit,
  };
}
