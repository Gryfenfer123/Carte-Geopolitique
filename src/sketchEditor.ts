// Outil de croquis — l'éditeur : outils, sélection, transformations, calques, historique.
//
// Ce fichier relie les clics et touches du navigateur au modèle (sketchModel/Geometry/Ops).
// Il ne dessine rien lui-même : il met à jour le document (immuable) et fournit à sketchLayer
// les dessins temporaires (cadre de sélection, poignées, aperçus).
//
// Principes :
//  - un glissé de souris montre un APERÇU (le document « vivant »), et ne crée UNE étape
//    d'historique qu'au relâchement ;
//  - les réglages continus (couleur, curseur) sont regroupés en une seule étape d'historique ;
//  - un objet sur un calque masqué ou verrouillé ne peut ni être cliqué ni être sélectionné.

import {
  DEFAULT_STYLE,
  DEFAULT_TEXT,
  addObjects,
  arrangeObjects,
  layerIndex,
  newLayer,
  removeObjects,
  replaceObjects,
  setGroup,
  uid,
  withLayers,
  withObjects,
  type ArrangeMode,
  type PathObject,
  type Pt,
  type SketchDoc,
  type SketchLayer,
  type SketchNode,
  type SketchObject,
  type SketchStyle,
  type TextDefaults,
  type TextObject,
} from "./sketchModel";
import {
  type Bounds,
  type View,
  cloneNode,
  cornerNode,
  dist,
  ellipseNodes,
  fitSmooth,
  hitPath,
  mercToPx,
  nearestOnPath,
  pxToMerc,
  rectNodes,
  rotateM,
  scaleM,
  splitSegment,
  transformObject,
  translateM,
} from "./sketchGeometry";
import { type AlignMode, alignObjects, flipObjects, objectBounds, selectionBounds } from "./sketchOps";
import { createHistory, type History } from "./sketchHistory";
import { mapNodes, objectSvg, pathD, strokePx, docToSvg, type SvgExport } from "./sketchSvg";
import type { SketchView } from "./sketchLayer";

export type Tool = "select" | "direct" | "pen" | "pencil" | "line" | "rect" | "ellipse" | "text" | "hand";

export const TOOL_LABELS: Record<Tool, { label: string; key: string; hint: string }> = {
  select: { label: "Sélection", key: "V", hint: "Sélectionner, déplacer, redimensionner, pivoter" },
  direct: { label: "Nœuds", key: "A", hint: "Modifier les points et les poignées d'une courbe (double-clic : ajouter un point ou le rendre lisse/anguleux)" },
  pen: { label: "Plume", key: "P", hint: "Clic = point anguleux ; clic-glissé = point lisse ; clic sur le 1er point = fermer ; double-clic ou Entrée = terminer" },
  pencil: { label: "Crayon", key: "N", hint: "Dessin à main levée, lissé automatiquement" },
  line: { label: "Ligne", key: "L", hint: "Segment (Maj = angles de 45°)" },
  rect: { label: "Rectangle", key: "R", hint: "Rectangle (Maj = carré)" },
  ellipse: { label: "Ellipse", key: "E", hint: "Ellipse (Maj = cercle)" },
  text: { label: "Texte", key: "T", hint: "Clic pour écrire ; Entrée valide, Maj+Entrée = nouvelle ligne" },
  hand: { label: "Main", key: "H", hint: "Déplacer la carte (ou maintenir Espace)" },
};

const SEL = "#00e5ff";
const HIT_PX = 7;

export type EditorSnapshot = {
  doc: SketchDoc | null;
  tool: Tool;
  selection: string[];
  selectedNodeCount: number;
  activeLayerId: string;
  defaultStyle: SketchStyle;
  defaultText: TextDefaults;
  canUndo: boolean;
  canRedo: boolean;
};

export type EditorHooks = {
  /** Appelé à chaque modification du document (pour l'enregistrement automatique). */
  onDocChanged: (doc: SketchDoc) => void;
  toast: (msg: string) => void;
};

type HandleId = "nw" | "n" | "ne" | "e" | "se" | "s" | "sw" | "w" | "rot";
const HANDLE_FRAC: Record<Exclude<HandleId, "rot">, [number, number]> = {
  nw: [0, 0],
  n: [0.5, 0],
  ne: [1, 0],
  e: [1, 0.5],
  se: [1, 1],
  s: [0.5, 1],
  sw: [0, 1],
  w: [0, 0.5],
};

type Drag =
  | { kind: "move"; start: Pt; startPx: Pt; orig: Map<string, SketchObject>; moved: boolean }
  | { kind: "scale"; pivot: Pt; hpos: Pt; hx: number; hy: number; orig: Map<string, SketchObject> }
  | { kind: "rotate"; pivot: Pt; pivotPx: Pt; startAngle: number; orig: Map<string, SketchObject> }
  | { kind: "marquee"; a: Pt; b: Pt; additive: boolean; base: Set<string> }
  | { kind: "nodes"; start: Pt; startPx: Pt; orig: Map<string, SketchNode[]>; moved: boolean }
  | { kind: "handle"; objId: string; idx: number; which: "in" | "out"; orig: SketchNode[] }
  | { kind: "pen-handle"; idx: number; start: Pt }
  | { kind: "pencil"; pts: Pt[]; ptsPx: Pt[] }
  | { kind: "shape"; a: Pt; b: Pt; shift: boolean };

type PenDraft = { nodes: SketchNode[]; cursor: Pt | null };

export type Editor = {
  open(doc: SketchDoc): void;
  close(): SketchDoc | null;
  snapshot(): EditorSnapshot;
  selectedObjects(): SketchObject[];
  onChange(fn: () => void): void;
  setTool(t: Tool): void;
  undo(): void;
  redo(): void;
  applyStyle(patch: Partial<SketchStyle>): void;
  applyText(patch: Partial<TextDefaults>): void;
  deleteSelection(): void;
  duplicate(): void;
  copy(): void;
  cut(): void;
  paste(): void;
  selectAll(): void;
  arrange(mode: ArrangeMode): void;
  group(): void;
  ungroup(): void;
  align(mode: AlignMode): void;
  flip(axis: "h" | "v"): void;
  addLayer(): void;
  updateLayer(id: string, patch: Partial<Pick<SketchLayer, "name" | "visible" | "locked">>): void;
  removeLayer(id: string): void;
  moveLayer(id: string, dir: -1 | 1): void;
  setActiveLayer(id: string): void;
  moveSelectionToLayer(id: string): void;
  setMeta(patch: Partial<Pick<SketchDoc, "title" | "sources">>): void;
  exportSvg(background?: string | null): SvgExport | null;
};

export function createEditor(view: SketchView, hooks: EditorHooks): Editor {
  let doc: SketchDoc | null = null;
  let hist: History<SketchDoc> | null = null;
  let tool: Tool = "select";
  let sel = new Set<string>();
  let nodeSel = new Set<string>(); // "idObjet:indexNœud"
  let activeLayerId = "";
  let defaultStyle: SketchStyle = { ...DEFAULT_STYLE };
  let defaultText: TextDefaults = { ...DEFAULT_TEXT };
  let drag: Drag | null = null;
  let draft: PenDraft | null = null;
  let hoverPx: Pt | null = null;
  let clipboard: SketchObject[] = [];
  let spaceDown = false;
  let lastKey = "";
  let lastKeyAt = 0;
  let textBox: { ta: HTMLTextAreaElement; existing: TextObject | null; at: Pt } | null = null;
  const listeners = new Set<() => void>();

  // ---------------------------------------------------------------- état et diffusion

  const rect = view.captureRect;

  function notify() {
    listeners.forEach((f) => f());
    view.requestRender();
  }

  function selectable(o: SketchObject): boolean {
    if (!doc) return false;
    const l = doc.layers.find((x) => x.id === o.layerId);
    return !!l && l.visible && !l.locked;
  }

  function cleanSelection() {
    if (!doc) return;
    const byId = new Map(doc.objects.map((o) => [o.id, o]));
    sel = new Set([...sel].filter((id) => {
      const o = byId.get(id);
      return !!o && selectable(o);
    }));
    nodeSel = new Set([...nodeSel].filter((k) => sel.has(k.slice(0, k.lastIndexOf(":")))));
  }

  function setDoc(next: SketchDoc) {
    doc = next;
    view.setEditingDoc(doc);
  }

  /** Enregistre une étape d'historique. `key` regroupe des réglages continus en une seule étape. */
  function commit(next: SketchDoc, key = "") {
    if (!hist) return;
    const now = performance.now();
    if (key && key === lastKey && now - lastKeyAt < 1000) hist.replace(next);
    else hist.push(next);
    lastKey = key;
    lastKeyAt = now;
    setDoc(next);
    cleanSelection();
    hooks.onDocChanged(next);
    notify();
  }

  function previewDoc(next: SketchDoc) {
    setDoc(next);
    view.requestRender();
  }

  function cancelDrag() {
    drag = null;
    if (hist) setDoc(hist.current);
    notify();
  }

  function selectedObjects(): SketchObject[] {
    return doc ? doc.objects.filter((o) => sel.has(o.id)) : [];
  }

  function selectedPaths(): PathObject[] {
    return selectedObjects().filter((o): o is PathObject => o.kind === "path");
  }

  function targetLayerId(): string | null {
    if (!doc) return null;
    const ok = (l: SketchLayer | undefined) => !!l && l.visible && !l.locked;
    const act = doc.layers.find((l) => l.id === activeLayerId);
    if (ok(act)) return act!.id;
    for (let i = doc.layers.length - 1; i >= 0; i--) if (ok(doc.layers[i])) return doc.layers[i].id;
    hooks.toast("Aucun calque disponible : affiche ou déverrouille un calque.");
    return null;
  }

  function makePath(nodes: SketchNode[], closed: boolean): PathObject | null {
    const layerId = targetLayerId();
    if (!layerId) return null;
    return {
      id: uid(),
      kind: "path",
      layerId,
      group: null,
      nodes,
      closed,
      style: closed ? { ...defaultStyle } : { ...defaultStyle, fill: null },
    };
  }

  function addAndSelect(objs: SketchObject[]) {
    if (!doc || objs.length === 0) return;
    sel = new Set(objs.map((o) => o.id));
    nodeSel = new Set();
    commit(addObjects(doc, objs));
  }

  // ---------------------------------------------------------------- détection

  const strokeHalfM = (o: PathObject, k: number) => strokePx(o.style, k) / 2 / k;

  function pickObject(m: Pt, v: View, onlyPaths = false): SketchObject | null {
    if (!doc) return null;
    const tol = 6 / v.k;
    for (let li = doc.layers.length - 1; li >= 0; li--) {
      const layer = doc.layers[li];
      if (!layer.visible || layer.locked) continue;
      for (let i = doc.objects.length - 1; i >= 0; i--) {
        const o = doc.objects[i];
        if (o.layerId !== layer.id) continue;
        if (o.kind === "path") {
          if (hitPath(o, m, tol, strokeHalfM(o, v.k))) return o;
        } else if (!onlyPaths) {
          const b = objectBounds(o, v.k);
          if (m.x >= b.minX - tol && m.x <= b.maxX + tol && m.y >= b.minY - tol && m.y <= b.maxY + tol) return o;
        }
      }
    }
    return null;
  }

  function groupMembers(o: SketchObject): string[] {
    if (!doc || !o.group) return [o.id];
    return doc.objects.filter((x) => x.group === o.group && selectable(x)).map((x) => x.id);
  }

  // ---------------------------------------------------------------- cadre de sélection et poignées

  type Frame = { b: Bounds; l: number; t: number; r: number; btm: number };

  function frame(v: View): Frame | null {
    const objs = selectedObjects();
    if (objs.length === 0) return null;
    const b = selectionBounds(objs, v.k);
    if (!b) return null;
    const tl = mercToPx(v, { x: b.minX, y: b.maxY });
    const br = mercToPx(v, { x: b.maxX, y: b.minY });
    return { b, l: tl.x, t: tl.y, r: br.x, btm: br.y };
  }

  function handlePx(f: Frame, id: HandleId): Pt {
    if (id === "rot") return { x: (f.l + f.r) / 2, y: f.t - 26 };
    const [fx, fy] = HANDLE_FRAC[id];
    return { x: f.l + (f.r - f.l) * fx, y: f.t + (f.btm - f.t) * fy };
  }

  function hitHandle(px: Pt, v: View): HandleId | null {
    if (tool !== "select") return null;
    const f = frame(v);
    if (!f) return null;
    const ids: HandleId[] = ["rot", "nw", "n", "ne", "e", "se", "s", "sw", "w"];
    for (const id of ids) if (dist(px, handlePx(f, id)) <= HIT_PX + 1) return id;
    return null;
  }

  function startTransform(id: HandleId, px: Pt, v: View) {
    const f = frame(v);
    if (!f) return;
    const orig = new Map(selectedObjects().map((o) => [o.id, o]));
    const b = f.b;
    if (id === "rot") {
      const pivot = { x: (b.minX + b.maxX) / 2, y: (b.minY + b.maxY) / 2 };
      const pivotPx = mercToPx(v, pivot);
      drag = { kind: "rotate", pivot, pivotPx, startAngle: Math.atan2(px.y - pivotPx.y, px.x - pivotPx.x), orig };
      return;
    }
    const [hx, hy] = HANDLE_FRAC[id];
    const at = (fx: number, fy: number): Pt => ({ x: b.minX + fx * (b.maxX - b.minX), y: b.maxY - fy * (b.maxY - b.minY) });
    drag = { kind: "scale", pivot: at(1 - hx, 1 - hy), hpos: at(hx, hy), hx, hy, orig };
  }

  // ---------------------------------------------------------------- événements souris

  function localPx(e: { clientX: number; clientY: number }): Pt {
    const r = view.svg.getBoundingClientRect();
    return { x: e.clientX - r.left, y: e.clientY - r.top };
  }

  function stop(e: Event) {
    e.stopPropagation();
  }

  function onDown(e: PointerEvent) {
    if (!doc || e.button !== 0) return;
    e.preventDefault();
    e.stopPropagation();
    if (textBox) {
      commitTextBox();
      return;
    }
    rect.setPointerCapture(e.pointerId);
    const px = localPx(e);
    const v = view.getView();
    const m = pxToMerc(v, px.x, px.y);
    switch (tool) {
      case "select":
        downSelect(e, px, m, v);
        break;
      case "direct":
        downDirect(e, px, m, v);
        break;
      case "pen":
        downPen(px, m, v);
        break;
      case "pencil":
        drag = { kind: "pencil", pts: [m], ptsPx: [px] };
        break;
      case "line":
      case "rect":
      case "ellipse":
        drag = { kind: "shape", a: m, b: m, shift: e.shiftKey };
        break;
      case "text":
        openTextBox(px, m, null);
        break;
      default:
        break;
    }
    notify();
  }

  function downSelect(e: PointerEvent, px: Pt, m: Pt, v: View) {
    const h = hitHandle(px, v);
    if (h) {
      startTransform(h, px, v);
      return;
    }
    const o = pickObject(m, v);
    if (o) {
      const ids = groupMembers(o);
      if (e.shiftKey) {
        const all = ids.every((id) => sel.has(id));
        for (const id of ids) {
          if (all) sel.delete(id);
          else sel.add(id);
        }
      } else if (!sel.has(o.id)) {
        sel = new Set(ids);
      }
      nodeSel = new Set();
      if (sel.size > 0) beginMove(m, px);
    } else {
      if (!e.shiftKey) sel = new Set();
      nodeSel = new Set();
      drag = { kind: "marquee", a: px, b: px, additive: e.shiftKey, base: new Set(sel) };
    }
  }

  function beginMove(m: Pt, px: Pt) {
    drag = { kind: "move", start: m, startPx: px, orig: new Map(selectedObjects().map((o) => [o.id, o])), moved: false };
  }

  // Poignées et ancres visibles en mode « Nœuds » : les nœuds choisis et leurs voisins ; si aucun nœud
  // n'est choisi, tout le tracé quand il est court.
  function handlesVisible(o: PathObject, idx: number): boolean {
    const n = o.nodes.length;
    const any = [...nodeSel].some((k) => k.startsWith(o.id + ":"));
    if (!any) return n <= 12;
    const near = (i: number) => nodeSel.has(`${o.id}:${(i + n) % n}`);
    return near(idx) || near(idx - 1) || near(idx + 1);
  }

  function downDirect(e: PointerEvent, px: Pt, m: Pt, v: View) {
    const paths = selectedPaths();
    // 1. poignées de Bézier
    for (const o of paths) {
      for (let i = 0; i < o.nodes.length; i++) {
        if (!handlesVisible(o, i)) continue;
        const n = o.nodes[i];
        for (const which of ["out", "in"] as const) {
          const hp = which === "out" ? n.hout : n.hin;
          if (hp && dist(px, mercToPx(v, hp)) <= HIT_PX) {
            drag = { kind: "handle", objId: o.id, idx: i, which, orig: o.nodes.map(cloneNode) };
            return;
          }
        }
      }
    }
    // 2. points d'ancrage
    for (const o of paths) {
      for (let i = 0; i < o.nodes.length; i++) {
        if (dist(px, mercToPx(v, o.nodes[i].p)) <= HIT_PX) {
          const key = `${o.id}:${i}`;
          if (e.shiftKey) {
            if (nodeSel.has(key)) nodeSel.delete(key);
            else nodeSel.add(key);
          } else if (!nodeSel.has(key)) {
            nodeSel = new Set([key]);
          }
          if (nodeSel.size > 0) beginNodeDrag(m, px);
          return;
        }
      }
    }
    // 3. un tracé (ou un texte) à sélectionner
    const o = pickObject(m, v);
    if (o) {
      if (!sel.has(o.id) || e.shiftKey) {
        if (!e.shiftKey) sel = new Set([o.id]);
        else sel.add(o.id);
        nodeSel = new Set();
      }
      beginMove(m, px);
    } else {
      if (!e.shiftKey) {
        nodeSel = new Set();
      }
      drag = { kind: "marquee", a: px, b: px, additive: e.shiftKey, base: new Set(sel) };
    }
  }

  function beginNodeDrag(m: Pt, px: Pt) {
    const orig = new Map<string, SketchNode[]>();
    for (const o of selectedPaths()) {
      if ([...nodeSel].some((k) => k.startsWith(o.id + ":"))) orig.set(o.id, o.nodes.map(cloneNode));
    }
    drag = { kind: "nodes", start: m, startPx: px, orig, moved: false };
  }

  function downPen(px: Pt, m: Pt, v: View) {
    if (!draft) {
      draft = { nodes: [cornerNode(m)], cursor: m };
      drag = { kind: "pen-handle", idx: 0, start: m };
      return;
    }
    const first = draft.nodes[0];
    if (draft.nodes.length >= 2 && dist(px, mercToPx(v, first.p)) <= HIT_PX + 2) {
      finishPen(true);
      return;
    }
    draft.nodes.push(cornerNode(m));
    drag = { kind: "pen-handle", idx: draft.nodes.length - 1, start: m };
  }

  function finishPen(closed: boolean) {
    const d = draft;
    draft = null;
    drag = null;
    if (d && d.nodes.length >= 2) {
      const o = makePath(d.nodes, closed);
      if (o) addAndSelect([o]);
    }
    notify();
  }

  function onMove(e: PointerEvent) {
    if (!doc) return;
    const px = localPx(e);
    hoverPx = px;
    const v = view.getView();
    const m = pxToMerc(v, px.x, px.y);
    if (!drag) {
      if (draft) {
        draft.cursor = m;
        view.requestRender();
      }
      return;
    }
    const d = drag;
    switch (d.kind) {
      case "move": {
        if (!d.moved && dist(px, d.startPx) < 3) return;
        d.moved = true;
        let dx = m.x - d.start.x;
        let dy = m.y - d.start.y;
        if (e.shiftKey) {
          if (Math.abs(dx) > Math.abs(dy)) dy = 0;
          else dx = 0;
        }
        const mat = translateM(dx, dy);
        const repl = new Map<string, SketchObject>();
        for (const [id, o] of d.orig) repl.set(id, transformObject(o, mat));
        if (hist) previewDoc(replaceObjects(hist.current, repl));
        break;
      }
      case "scale": {
        let sx = d.hx === 0.5 ? 1 : (m.x - d.pivot.x) / (d.hpos.x - d.pivot.x || 1);
        let sy = d.hy === 0.5 ? 1 : (m.y - d.pivot.y) / (d.hpos.y - d.pivot.y || 1);
        if (e.shiftKey && d.hx !== 0.5 && d.hy !== 0.5) {
          const s = (Math.abs(sx) + Math.abs(sy)) / 2;
          sx = Math.sign(sx || 1) * s;
          sy = Math.sign(sy || 1) * s;
        }
        const clamp = (s: number) => (Math.abs(s) < 0.01 ? 0.01 * (s < 0 ? -1 : 1) : s);
        const mat = scaleM(clamp(sx), clamp(sy), d.pivot);
        const repl = new Map<string, SketchObject>();
        for (const [id, o] of d.orig) repl.set(id, transformObject(o, mat));
        if (hist) previewDoc(replaceObjects(hist.current, repl));
        break;
      }
      case "rotate": {
        let delta = Math.atan2(px.y - d.pivotPx.y, px.x - d.pivotPx.x) - d.startAngle;
        if (e.shiftKey) delta = Math.round(delta / (Math.PI / 12)) * (Math.PI / 12);
        const mat = rotateM(-delta, d.pivot);
        const repl = new Map<string, SketchObject>();
        for (const [id, o] of d.orig) repl.set(id, transformObject(o, mat));
        if (hist) previewDoc(replaceObjects(hist.current, repl));
        break;
      }
      case "marquee":
        d.b = px;
        view.requestRender();
        break;
      case "nodes": {
        if (!d.moved && dist(px, d.startPx) < 3) return;
        d.moved = true;
        const dx = m.x - d.start.x;
        const dy = m.y - d.start.y;
        const repl = new Map<string, SketchObject>();
        for (const [id, orig] of d.orig) {
          const nodes = orig.map((n, i) => {
            if (!nodeSel.has(`${id}:${i}`)) return n;
            const mv = (p: Pt | null) => (p ? { x: p.x + dx, y: p.y + dy } : null);
            return { p: { x: n.p.x + dx, y: n.p.y + dy }, hin: mv(n.hin), hout: mv(n.hout), smooth: n.smooth };
          });
          const o = hist?.current.objects.find((x) => x.id === id);
          if (o && o.kind === "path") repl.set(id, { ...o, nodes });
        }
        if (hist) previewDoc(replaceObjects(hist.current, repl));
        break;
      }
      case "handle": {
        const nodes = d.orig.map(cloneNode);
        const n = nodes[d.idx];
        if (d.which === "out") n.hout = m;
        else n.hin = m;
        if (e.altKey) n.smooth = false;
        else if (n.smooth) {
          const other = d.which === "out" ? d.orig[d.idx].hin : d.orig[d.idx].hout;
          if (other) {
            const len = dist(n.p, other);
            const dir = { x: n.p.x - m.x, y: n.p.y - m.y };
            const dl = Math.hypot(dir.x, dir.y) || 1;
            const mirrored = { x: n.p.x + (dir.x / dl) * len, y: n.p.y + (dir.y / dl) * len };
            if (d.which === "out") n.hin = mirrored;
            else n.hout = mirrored;
          }
        }
        const o = hist?.current.objects.find((x) => x.id === d.objId);
        if (hist && o && o.kind === "path") previewDoc(replaceObjects(hist.current, new Map([[d.objId, { ...o, nodes }]])));
        break;
      }
      case "pen-handle": {
        if (!draft) break;
        const v0 = mercToPx(v, d.start);
        if (dist(px, v0) < 3) break;
        const n = draft.nodes[d.idx];
        n.hout = m;
        n.hin = { x: 2 * d.start.x - m.x, y: 2 * d.start.y - m.y };
        n.smooth = true;
        view.requestRender();
        break;
      }
      case "pencil": {
        const last = d.ptsPx[d.ptsPx.length - 1];
        if (dist(px, last) >= 2) {
          d.pts.push(m);
          d.ptsPx.push(px);
          view.requestRender();
        }
        break;
      }
      case "shape":
        d.b = m;
        d.shift = e.shiftKey;
        view.requestRender();
        break;
    }
  }

  function constrained(a: Pt, b: Pt, shift: boolean, kind: Tool): Pt {
    if (!shift) return b;
    const dx = b.x - a.x;
    const dy = b.y - a.y;
    if (kind === "line") {
      const ang = Math.round(Math.atan2(dy, dx) / (Math.PI / 4)) * (Math.PI / 4);
      const len = Math.hypot(dx, dy);
      return { x: a.x + Math.cos(ang) * len, y: a.y + Math.sin(ang) * len };
    }
    const s = Math.max(Math.abs(dx), Math.abs(dy));
    return { x: a.x + Math.sign(dx || 1) * s, y: a.y + Math.sign(dy || 1) * s };
  }

  function onUp(e: PointerEvent) {
    if (!doc || !drag) return;
    const d = drag;
    const px = localPx(e);
    const v = view.getView();
    try {
      rect.releasePointerCapture(e.pointerId);
    } catch {
      /* déjà relâché */
    }
    switch (d.kind) {
      case "move":
        drag = null;
        if (d.moved) commit(doc);
        else notify();
        return;
      case "scale":
      case "rotate":
      case "nodes":
      case "handle":
        drag = null;
        if (d.kind === "nodes" && !d.moved) {
          notify();
          return;
        }
        commit(doc);
        return;
      case "marquee": {
        drag = null;
        const x0 = Math.min(d.a.x, d.b.x);
        const x1 = Math.max(d.a.x, d.b.x);
        const y0 = Math.min(d.a.y, d.b.y);
        const y1 = Math.max(d.a.y, d.b.y);
        const tiny = x1 - x0 < 3 && y1 - y0 < 3;
        if (tool === "direct") {
          if (!tiny) {
            const keys = new Set(d.additive ? nodeSel : []);
            for (const o of selectedPaths()) {
              o.nodes.forEach((n, i) => {
                const q = mercToPx(v, n.p);
                if (q.x >= x0 && q.x <= x1 && q.y >= y0 && q.y <= y1) keys.add(`${o.id}:${i}`);
              });
            }
            nodeSel = keys;
            if (keys.size === 0 && !d.additive) {
              // Rien dans le cadre : on retombe sur la sélection d'objets qui touchent le cadre.
              sel = new Set(objectsTouching(v, x0, y0, x1, y1));
            }
          }
        } else if (!tiny) {
          const ids = new Set(d.additive ? d.base : []);
          for (const id of objectsTouching(v, x0, y0, x1, y1)) ids.add(id);
          sel = ids;
        }
        notify();
        return;
      }
      case "pen-handle":
        drag = null;
        notify();
        return;
      case "pencil": {
        drag = null;
        if (d.pts.length >= 2) {
          const nodes = fitSmooth(d.pts, 2.5 / v.k);
          if (nodes.length >= 2) {
            const o = makePath(nodes, false);
            if (o) addAndSelect([o]);
            return;
          }
        }
        notify();
        return;
      }
      case "shape": {
        drag = null;
        const a = mercToPx(v, d.a);
        if (dist(a, px) < 4) {
          notify();
          return;
        }
        const b = constrained(d.a, pxToMerc(v, px.x, px.y), e.shiftKey, tool);
        const o = shapeObject(d.a, b);
        if (o) addAndSelect([o]);
        return;
      }
    }
  }

  function objectsTouching(v: View, x0: number, y0: number, x1: number, y1: number): string[] {
    if (!doc) return [];
    const ids: string[] = [];
    for (const o of doc.objects) {
      if (!selectable(o)) continue;
      const b = objectBounds(o, v.k);
      const tl = mercToPx(v, { x: b.minX, y: b.maxY });
      const br = mercToPx(v, { x: b.maxX, y: b.minY });
      if (br.x >= x0 && tl.x <= x1 && br.y >= y0 && tl.y <= y1) {
        for (const id of groupMembers(o)) ids.push(id);
      }
    }
    return ids;
  }

  function shapeObject(a: Pt, b: Pt): PathObject | null {
    if (tool === "line") return makePath([cornerNode(a), cornerNode(b)], false);
    if (tool === "rect") return makePath(rectNodes(a, b), true);
    if (tool === "ellipse") return makePath(ellipseNodes(a, b), true);
    return null;
  }

  function onDblClick(e: MouseEvent) {
    if (!doc) return;
    e.preventDefault();
    e.stopPropagation();
    const px = localPx(e);
    const v = view.getView();
    const m = pxToMerc(v, px.x, px.y);
    if (tool === "pen" && draft) {
      // Le double-clic a déjà posé deux points au même endroit : on retire le doublon.
      const n = draft.nodes;
      if (n.length >= 2 && dist(mercToPx(v, n[n.length - 1].p), mercToPx(v, n[n.length - 2].p)) < 5) n.pop();
      finishPen(false);
      return;
    }
    if (tool === "select") {
      const o = pickObject(m, v);
      if (o?.kind === "text") {
        sel = new Set([o.id]);
        openTextBox(mercToPx(v, o.p), o.p, o);
      } else if (o) {
        sel = new Set([o.id]);
        setTool("direct");
      }
      return;
    }
    if (tool === "direct") {
      for (const o of selectedPaths()) {
        for (let i = 0; i < o.nodes.length; i++) {
          if (dist(px, mercToPx(v, o.nodes[i].p)) <= HIT_PX) {
            toggleSmooth(o, i);
            return;
          }
        }
      }
      for (const o of selectedPaths()) {
        const near = nearestOnPath(o.nodes, o.closed, m);
        if (near && near.dist * v.k <= HIT_PX && doc) {
          const nodes = splitSegment(o.nodes, o.closed, near.seg, near.t);
          const idx = near.seg + 1;
          nodeSel = new Set([`${o.id}:${idx}`]);
          commit(replaceObjects(doc, new Map([[o.id, { ...o, nodes }]])));
          return;
        }
      }
    }
  }

  function toggleSmooth(o: PathObject, i: number) {
    if (!doc) return;
    const n = o.nodes[i];
    const nodes = o.nodes.map(cloneNode);
    if (n.hin || n.hout) {
      nodes[i] = { p: n.p, hin: null, hout: null, smooth: false };
    } else {
      const len = o.nodes.length;
      const prev = o.nodes[(i - 1 + len) % len];
      const next = o.nodes[(i + 1) % len];
      const hasPrev = o.closed || i > 0;
      const hasNext = o.closed || i < len - 1;
      const a = hasPrev ? prev.p : n.p;
      const b = hasNext ? next.p : n.p;
      let dir = { x: b.x - a.x, y: b.y - a.y };
      const dl = Math.hypot(dir.x, dir.y);
      if (dl < 1e-9) return;
      dir = { x: dir.x / dl, y: dir.y / dl };
      const reach = Math.min(hasPrev ? dist(n.p, prev.p) : Infinity, hasNext ? dist(n.p, next.p) : Infinity) / 3;
      nodes[i] = {
        p: n.p,
        hin: { x: n.p.x - dir.x * reach, y: n.p.y - dir.y * reach },
        hout: { x: n.p.x + dir.x * reach, y: n.p.y + dir.y * reach },
        smooth: true,
      };
    }
    commit(replaceObjects(doc, new Map([[o.id, { ...o, nodes }]])));
  }

  // ---------------------------------------------------------------- texte

  function openTextBox(px: Pt, at: Pt, existing: TextObject | null) {
    const host = view.svg.parentElement;
    if (!host) return;
    const ta = document.createElement("textarea");
    ta.className = "sk-textbox";
    ta.value = existing?.text ?? "";
    const fs = existing?.fontSize ?? defaultText.fontSize;
    ta.style.left = `${px.x}px`;
    ta.style.top = `${px.y - fs}px`;
    ta.style.fontSize = `${fs}px`;
    ta.rows = 1;
    ta.placeholder = "Texte…";
    ta.addEventListener("keydown", (ev) => {
      ev.stopPropagation();
      if (ev.key === "Escape") {
        ev.preventDefault();
        closeTextBox(false);
      } else if (ev.key === "Enter" && !ev.shiftKey) {
        ev.preventDefault();
        commitTextBox();
      }
    });
    ta.addEventListener("input", () => {
      ta.rows = Math.max(1, ta.value.split("\n").length);
    });
    ta.addEventListener("blur", () => commitTextBox());
    host.appendChild(ta);
    textBox = { ta, existing, at };
    ta.focus();
    ta.select();
  }

  function closeTextBox(save: boolean) {
    const tb = textBox;
    if (!tb) return;
    textBox = null;
    const value = tb.ta.value;
    tb.ta.remove();
    if (!save || !doc || value.trim() === "") return;
    if (tb.existing) {
      const ex = tb.existing;
      commit(replaceObjects(doc, new Map([[ex.id, { ...ex, text: value }]])));
      return;
    }
    const layerId = targetLayerId();
    if (!layerId) return;
    addAndSelect([{ id: uid(), kind: "text", layerId, group: null, p: tb.at, text: value, rotation: 0, ...defaultText }]);
  }

  function commitTextBox() {
    closeTextBox(true);
  }

  // ---------------------------------------------------------------- clavier

  function typing(t: EventTarget | null): boolean {
    const el = t as HTMLElement | null;
    return !!el && (el.tagName === "INPUT" || el.tagName === "TEXTAREA" || el.tagName === "SELECT" || el.isContentEditable);
  }

  function onKeyDown(e: KeyboardEvent) {
    if (!doc || textBox || typing(e.target)) return;
    const mod = e.ctrlKey || e.metaKey;
    const key = e.key.toLowerCase();
    const handled = () => {
      e.preventDefault();
      e.stopPropagation();
    };
    if (e.key === " ") {
      handled();
      if (!spaceDown) {
        spaceDown = true;
        view.setPassThrough(true);
      }
      return;
    }
    if (mod) {
      if (key === "z" && !e.shiftKey) { handled(); undo(); }
      else if (key === "y" || (key === "z" && e.shiftKey)) { handled(); redo(); }
      else if (key === "c") { handled(); copy(); }
      else if (key === "x") { handled(); cut(); }
      else if (key === "v") { handled(); paste(); }
      else if (key === "d") { handled(); duplicate(); }
      else if (key === "a") { handled(); selectAll(); }
      else if (key === "g" && !e.shiftKey) { handled(); group(); }
      else if (key === "g" && e.shiftKey) { handled(); ungroup(); }
      return;
    }
    if (e.key === "Escape") {
      handled();
      if (drag) cancelDrag();
      else if (draft) {
        if (draft.nodes.length >= 2) finishPen(false);
        else {
          draft = null;
          notify();
        }
      } else if (sel.size || nodeSel.size) {
        sel = new Set();
        nodeSel = new Set();
        notify();
      }
      return;
    }
    if (e.key === "Enter" && draft) {
      handled();
      finishPen(false);
      return;
    }
    if (e.key === "Delete" || e.key === "Backspace") {
      handled();
      deleteSelection();
      return;
    }
    if (e.key.startsWith("Arrow") && sel.size > 0 && doc) {
      handled();
      const step = (e.shiftKey ? 10 : 1) / view.getView().k;
      const dx = e.key === "ArrowLeft" ? -step : e.key === "ArrowRight" ? step : 0;
      const dy = e.key === "ArrowUp" ? step : e.key === "ArrowDown" ? -step : 0;
      const repl = new Map<string, SketchObject>();
      for (const o of selectedObjects()) repl.set(o.id, transformObject(o, translateM(dx, dy)));
      commit(replaceObjects(doc, repl), "nudge");
      return;
    }
    const tools: Record<string, Tool> = { v: "select", a: "direct", p: "pen", n: "pencil", l: "line", r: "rect", e: "ellipse", t: "text", h: "hand" };
    if (tools[key] && !e.altKey) {
      handled();
      setTool(tools[key]);
    }
  }

  function onKeyUp(e: KeyboardEvent) {
    if (e.key === " " && spaceDown) {
      spaceDown = false;
      if (tool !== "hand") view.setPassThrough(false);
    }
  }

  // ---------------------------------------------------------------- actions

  function setTool(t: Tool) {
    if (draft) finishPen(false);
    if (textBox) commitTextBox();
    drag = null;
    tool = t;
    view.setPassThrough(t === "hand" || spaceDown);
    const cursors: Record<Tool, string> = {
      select: "default",
      direct: "default",
      pen: "crosshair",
      pencil: "crosshair",
      line: "crosshair",
      rect: "crosshair",
      ellipse: "crosshair",
      text: "text",
      hand: "grab",
    };
    view.setCursor(cursors[t]);
    notify();
  }

  function undo() {
    if (!hist) return;
    if (draft) {
      draft = null;
      notify();
      return;
    }
    if (hist.undo()) {
      setDoc(hist.current);
      cleanSelection();
      hooks.onDocChanged(hist.current);
      notify();
    }
  }

  function redo() {
    if (hist?.redo()) {
      setDoc(hist.current);
      cleanSelection();
      hooks.onDocChanged(hist.current);
      notify();
    }
  }

  function deleteSelection() {
    if (!doc) return;
    if (tool === "direct" && nodeSel.size > 0) {
      const byObj = new Map<string, number[]>();
      for (const k of nodeSel) {
        const i = k.lastIndexOf(":");
        const id = k.slice(0, i);
        byObj.set(id, [...(byObj.get(id) ?? []), Number(k.slice(i + 1))]);
      }
      const repl = new Map<string, SketchObject>();
      const gone = new Set<string>();
      for (const [id, idxs] of byObj) {
        const o = doc.objects.find((x) => x.id === id);
        if (!o || o.kind !== "path") continue;
        const nodes = o.nodes.filter((_, i) => !idxs.includes(i));
        if (nodes.length < 2) gone.add(id);
        else repl.set(id, { ...o, nodes });
      }
      nodeSel = new Set();
      let next = replaceObjects(doc, repl);
      if (gone.size) next = removeObjects(next, gone);
      commit(next);
      return;
    }
    if (sel.size === 0) return;
    const ids = new Set(sel);
    sel = new Set();
    nodeSel = new Set();
    commit(removeObjects(doc, ids));
  }

  function cloneObjects(objs: SketchObject[], offsetPx: number): SketchObject[] {
    const k = view.getView().k;
    const groupMap = new Map<string, string>();
    return objs.map((o) => {
      const moved = transformObject(o, translateM(offsetPx / k, -offsetPx / k));
      let group = o.group;
      if (group) {
        if (!groupMap.has(group)) groupMap.set(group, uid());
        group = groupMap.get(group) ?? null;
      }
      return { ...moved, id: uid(), group };
    });
  }

  function duplicate() {
    const objs = selectedObjects();
    if (objs.length) addAndSelect(cloneObjects(objs, 18));
  }

  function copy() {
    clipboard = selectedObjects();
    if (clipboard.length) hooks.toast(`${clipboard.length} objet(s) copié(s).`);
  }

  function cut() {
    copy();
    deleteSelection();
  }

  function paste() {
    if (!doc || clipboard.length === 0) return;
    const layerId = targetLayerId();
    if (!layerId) return;
    addAndSelect(cloneObjects(clipboard, 18).map((o) => ({ ...o, layerId })));
  }

  function selectAll() {
    if (!doc) return;
    sel = new Set(doc.objects.filter(selectable).map((o) => o.id));
    nodeSel = new Set();
    notify();
  }

  function arrange(mode: ArrangeMode) {
    if (doc && sel.size) commit(arrangeObjects(doc, sel, mode));
  }

  function group() {
    if (doc && sel.size >= 2) commit(setGroup(doc, sel, uid()));
  }

  function ungroup() {
    if (doc && sel.size) commit(setGroup(doc, sel, null));
  }

  function align(mode: AlignMode) {
    if (!doc) return;
    const repl = alignObjects(selectedObjects(), mode, view.getView().k);
    if (repl.size) commit(replaceObjects(doc, repl));
    else if (sel.size < 2) hooks.toast("Sélectionne au moins deux objets pour les aligner.");
  }

  function flip(axis: "h" | "v") {
    if (!doc) return;
    const repl = flipObjects(selectedObjects(), axis, view.getView().k);
    if (repl.size) commit(replaceObjects(doc, repl));
  }

  function roundWidth(x: number, toMap: boolean): number {
    if (!toMap) return Math.max(0.5, Math.round(x * 10) / 10);
    return x >= 100 ? Math.round(x) : Math.round(x * 10) / 10;
  }

  function applyStyle(patch: Partial<SketchStyle>) {
    const paths = selectedPaths();
    const k = view.getView().k;
    const convert = (s: SketchStyle): SketchStyle => {
      const next = { ...s, ...patch };
      if (patch.widthMode && patch.widthMode !== s.widthMode && patch.strokeWidth === undefined) {
        // On garde la même épaisseur visible au zoom actuel quand on change de mode.
        next.strokeWidth = patch.widthMode === "map" ? roundWidth(s.strokeWidth / k, true) : roundWidth(s.strokeWidth * k, false);
      }
      return next;
    };
    if (paths.length === 0 || !doc) {
      defaultStyle = convert(defaultStyle);
      notify();
      return;
    }
    const repl = new Map<string, SketchObject>();
    for (const o of paths) repl.set(o.id, { ...o, style: convert(o.style) });
    commit(replaceObjects(doc, repl), "style:" + Object.keys(patch).join(","));
  }

  function applyText(patch: Partial<TextDefaults>) {
    const texts = selectedObjects().filter((o): o is TextObject => o.kind === "text");
    if (texts.length === 0 || !doc) {
      defaultText = { ...defaultText, ...patch };
      notify();
      return;
    }
    const repl = new Map<string, SketchObject>();
    for (const o of texts) repl.set(o.id, { ...o, ...patch });
    commit(replaceObjects(doc, repl), "text:" + Object.keys(patch).join(","));
  }

  // ---------------------------------------------------------------- calques

  function addLayer() {
    if (!doc) return;
    const l = newLayer(`Calque ${doc.layers.length + 1}`);
    activeLayerId = l.id;
    commit(withLayers(doc, [...doc.layers, l]));
  }

  function updateLayer(id: string, patch: Partial<Pick<SketchLayer, "name" | "visible" | "locked">>) {
    if (!doc) return;
    commit(withLayers(doc, doc.layers.map((l) => (l.id === id ? { ...l, ...patch } : l))), patch.name !== undefined ? "layer-name:" + id : "");
  }

  function removeLayer(id: string) {
    if (!doc || doc.layers.length <= 1) {
      hooks.toast("Un croquis garde toujours au moins un calque.");
      return;
    }
    const layers = doc.layers.filter((l) => l.id !== id);
    const objects = doc.objects.filter((o) => o.layerId !== id);
    if (activeLayerId === id) activeLayerId = layers[layers.length - 1].id;
    commit(withLayers(doc, layers, objects));
  }

  function moveLayer(id: string, dir: -1 | 1) {
    if (!doc) return;
    const i = layerIndex(doc, id);
    const j = i + dir;
    if (i < 0 || j < 0 || j >= doc.layers.length) return;
    const layers = doc.layers.slice();
    [layers[i], layers[j]] = [layers[j], layers[i]];
    commit(withLayers(doc, layers));
  }

  function moveSelectionToLayer(id: string) {
    if (!doc || sel.size === 0) return;
    commit(withObjects(doc, doc.objects.map((o) => (sel.has(o.id) ? { ...o, layerId: id } : o))));
  }

  // ---------------------------------------------------------------- dessins temporaires

  const sq = (x: number, y: number, filled: boolean, size = 8) =>
    `<rect x="${x - size / 2}" y="${y - size / 2}" width="${size}" height="${size}" fill="${filled ? SEL : "#fff"}" stroke="${SEL}" stroke-width="1.5"/>`;
  const circ = (x: number, y: number, filled: boolean, r = 4) =>
    `<circle cx="${x}" cy="${y}" r="${r}" fill="${filled ? SEL : "#fff"}" stroke="${SEL}" stroke-width="1.5"/>`;

  function previewObject(nodes: SketchNode[], closed: boolean, v: View, opacity = 0.8): string {
    const o = makePathNoLayer(nodes, closed);
    return `<g opacity="${opacity}">${objectSvg(o, (p) => mercToPx(v, p), v.k)}</g>`;
  }

  function makePathNoLayer(nodes: SketchNode[], closed: boolean): PathObject {
    return {
      id: "preview",
      kind: "path",
      layerId: "",
      group: null,
      nodes,
      closed,
      style: closed ? { ...defaultStyle } : { ...defaultStyle, fill: null },
    };
  }

  function drawOverlay(v: View): string {
    if (!doc) return "";
    let out = "";
    const toPx = (p: Pt) => mercToPx(v, p);
    // Contours des objets sélectionnés
    for (const o of selectedObjects()) {
      if (o.kind !== "path") continue;
      out += `<path d="${pathD(mapNodes(o.nodes, toPx), o.closed)}" fill="none" stroke="${SEL}" stroke-width="1.2" opacity="0.9"/>`;
    }
    if (tool === "select") {
      const f = frame(v);
      if (f) {
        out += `<rect x="${f.l}" y="${f.t}" width="${f.r - f.l}" height="${f.btm - f.t}" fill="none" stroke="${SEL}" stroke-width="1" stroke-dasharray="4 3"/>`;
        const rot = handlePx(f, "rot");
        out += `<line x1="${(f.l + f.r) / 2}" y1="${f.t}" x2="${rot.x}" y2="${rot.y}" stroke="${SEL}" stroke-width="1"/>`;
        out += circ(rot.x, rot.y, false, 5);
        for (const id of Object.keys(HANDLE_FRAC) as Exclude<HandleId, "rot">[]) {
          const p = handlePx(f, id);
          out += sq(p.x, p.y, false);
        }
      }
    }
    if (tool === "direct") {
      for (const o of selectedPaths()) {
        const px = mapNodes(o.nodes, toPx);
        px.forEach((n, i) => {
          if (handlesVisible(o, i)) {
            for (const h of [n.hin, n.hout]) {
              if (!h) continue;
              out += `<line x1="${n.p.x}" y1="${n.p.y}" x2="${h.x}" y2="${h.y}" stroke="${SEL}" stroke-width="1"/>${circ(h.x, h.y, true, 3.5)}`;
            }
          }
        });
        px.forEach((n, i) => {
          out += sq(n.p.x, n.p.y, nodeSel.has(`${o.id}:${i}`));
        });
      }
    }
    // Aperçus de ce qu'on est en train de dessiner
    if (draft) {
      const nodes = draft.nodes.map(cloneNode);
      const dragging = drag?.kind === "pen-handle";
      if (draft.cursor && !dragging) nodes.push(cornerNode(draft.cursor));
      if (nodes.length >= 2) out += previewObject(nodes, false, v);
      draft.nodes.forEach((n, i) => {
        const p = toPx(n.p);
        const close = i === 0 && draft !== null && draft.nodes.length >= 2 && hoverPx !== null && dist(hoverPx, p) <= HIT_PX + 2;
        out += close ? circ(p.x, p.y, true, 7) : sq(p.x, p.y, i === draft!.nodes.length - 1);
        for (const h of [n.hin, n.hout]) {
          if (!h) continue;
          const q = toPx(h);
          out += `<line x1="${p.x}" y1="${p.y}" x2="${q.x}" y2="${q.y}" stroke="${SEL}" stroke-width="1"/>${circ(q.x, q.y, true, 3)}`;
        }
      });
    }
    if (drag?.kind === "pencil" && drag.pts.length >= 2) {
      out += previewObject(drag.pts.map(cornerNode), false, v, 0.7);
    }
    if (drag?.kind === "shape") {
      const b = constrained(drag.a, drag.b, drag.shift, tool);
      const nodes = tool === "line" ? [cornerNode(drag.a), cornerNode(b)] : tool === "rect" ? rectNodes(drag.a, b) : ellipseNodes(drag.a, b);
      out += previewObject(nodes, tool !== "line", v);
    }
    if (drag?.kind === "marquee") {
      const x = Math.min(drag.a.x, drag.b.x);
      const y = Math.min(drag.a.y, drag.b.y);
      out += `<rect x="${x}" y="${y}" width="${Math.abs(drag.b.x - drag.a.x)}" height="${Math.abs(drag.b.y - drag.a.y)}" fill="rgba(0,229,255,0.12)" stroke="${SEL}" stroke-width="1" stroke-dasharray="3 3"/>`;
    }
    return out;
  }

  // ---------------------------------------------------------------- ouverture / fermeture

  rect.addEventListener("pointerdown", onDown);
  rect.addEventListener("pointermove", onMove);
  rect.addEventListener("pointerup", onUp);
  rect.addEventListener("pointercancel", () => drag && cancelDrag());
  rect.addEventListener("dblclick", onDblClick);
  for (const ev of ["click", "mousedown", "contextmenu", "touchstart"]) rect.addEventListener(ev, stop);
  document.addEventListener("keydown", onKeyDown, true);
  document.addEventListener("keyup", onKeyUp, true);

  return {
    open(d) {
      doc = d;
      hist = createHistory(d);
      sel = new Set();
      nodeSel = new Set();
      draft = null;
      drag = null;
      lastKey = "";
      activeLayerId = d.layers[d.layers.length - 1].id;
      view.setEditingDoc(d);
      view.setOverlay(drawOverlay);
      view.setInteractive(true);
      setTool("select");
    },
    close() {
      if (draft) finishPen(false);
      if (textBox) commitTextBox();
      const last = doc;
      doc = null;
      hist = null;
      sel = new Set();
      nodeSel = new Set();
      drag = null;
      spaceDown = false;
      view.setEditingDoc(null);
      view.setOverlay(null);
      view.setInteractive(false);
      view.setPassThrough(false);
      notify();
      return last;
    },
    snapshot: () => ({
      doc,
      tool,
      selection: [...sel],
      selectedNodeCount: nodeSel.size,
      activeLayerId,
      defaultStyle,
      defaultText,
      canUndo: !!hist?.canUndo(),
      canRedo: !!hist?.canRedo(),
    }),
    selectedObjects,
    onChange: (fn) => {
      listeners.add(fn);
    },
    setTool,
    undo,
    redo,
    applyStyle,
    applyText,
    deleteSelection,
    duplicate,
    copy,
    cut,
    paste,
    selectAll,
    arrange,
    group,
    ungroup,
    align,
    flip,
    addLayer,
    updateLayer,
    removeLayer,
    moveLayer,
    setActiveLayer(id) {
      activeLayerId = id;
      notify();
    },
    moveSelectionToLayer,
    setMeta(patch) {
      if (!doc || !hist) return;
      const next = { ...doc, ...patch, updatedAt: new Date().toISOString() };
      hist.replace(next);
      setDoc(next);
      hooks.onDocChanged(next);
    },
    exportSvg: (background) => (doc ? docToSvg(doc, { background }) : null),
  };
}
