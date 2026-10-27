// Outil de croquis — opérations sur des objets (cadres, alignement, miroir). Logique pure.

import type { SketchObject, TextObject } from "./sketchModel";
import {
  type Bounds,
  boundsOfPoints,
  pathBounds,
  unionBounds,
  scaleM,
  transformObject,
  translateM,
} from "./sketchGeometry";

/** Largeur approximative d'un texte en pixels (sans mesurer la police : suffisant pour un cadre). */
export function textSizePx(t: TextObject): { w: number; h: number } {
  const lines = t.text.split("\n");
  const longest = Math.max(1, ...lines.map((l) => l.length));
  return { w: longest * t.fontSize * (t.bold ? 0.6 : 0.55), h: lines.length * t.fontSize * 1.2 };
}

/** Cadre d'un objet en mètres. `k` = pixels par mètre (le texte a une taille d'écran). */
export function objectBounds(o: SketchObject, k: number): Bounds {
  if (o.kind === "path") {
    return (
      pathBounds(o.nodes, o.closed) ?? { minX: o.nodes[0].p.x, minY: o.nodes[0].p.y, maxX: o.nodes[0].p.x, maxY: o.nodes[0].p.y }
    );
  }
  const { w, h } = textSizePx(o);
  const wm = w / k;
  const hm = h / k;
  const x0 = o.anchor === "start" ? o.p.x : o.anchor === "middle" ? o.p.x - wm / 2 : o.p.x - wm;
  return { minX: x0, maxX: x0 + wm, minY: o.p.y - hm * 0.2, maxY: o.p.y + hm * 0.8 };
}

export function selectionBounds(objs: SketchObject[], k: number): Bounds | null {
  return unionBounds(objs.map((o) => objectBounds(o, k)));
}

export type AlignMode = "left" | "center" | "right" | "top" | "middle" | "bottom";

/** Aligne chaque objet sur le cadre de la sélection (il en faut au moins deux). */
export function alignObjects(objs: SketchObject[], mode: AlignMode, k: number): Map<string, SketchObject> {
  const out = new Map<string, SketchObject>();
  if (objs.length < 2) return out;
  const u = selectionBounds(objs, k);
  if (!u) return out;
  for (const o of objs) {
    const b = objectBounds(o, k);
    let dx = 0;
    let dy = 0;
    if (mode === "left") dx = u.minX - b.minX;
    else if (mode === "right") dx = u.maxX - b.maxX;
    else if (mode === "center") dx = (u.minX + u.maxX) / 2 - (b.minX + b.maxX) / 2;
    else if (mode === "top") dy = u.maxY - b.maxY;
    else if (mode === "bottom") dy = u.minY - b.minY;
    else dy = (u.minY + u.maxY) / 2 - (b.minY + b.maxY) / 2;
    if (dx !== 0 || dy !== 0) out.set(o.id, transformObject(o, translateM(dx, dy)));
  }
  return out;
}

/** Miroir horizontal ou vertical autour du centre de la sélection. */
export function flipObjects(objs: SketchObject[], axis: "h" | "v", k: number): Map<string, SketchObject> {
  const out = new Map<string, SketchObject>();
  const u = selectionBounds(objs, k);
  if (!u) return out;
  const pivot = { x: (u.minX + u.maxX) / 2, y: (u.minY + u.maxY) / 2 };
  const m = axis === "h" ? scaleM(-1, 1, pivot) : scaleM(1, -1, pivot);
  for (const o of objs) out.set(o.id, transformObject(o, m));
  return out;
}

/** Cadre d'un ensemble de points (réexport pratique pour l'éditeur). */
export const boundsFromPoints = boundsOfPoints;
