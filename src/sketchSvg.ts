// Outil de croquis — rendu SVG d'un document (logique pure : produit du texte, ne touche pas au DOM).
// Le MÊME code sert à l'affichage sur la carte (coordonnées d'écran) et à l'export SVG/PNG
// (coordonnées d'une page fixe) : ce qu'on voit est ce qu'on exporte.

import {
  FONTS,
  objectsInDrawOrder,
  sanitizeColor,
  type PathObject,
  type Pt,
  type SketchDoc,
  type SketchNode,
  type SketchObject,
  type SketchStyle,
  type TextObject,
} from "./sketchModel";
import { arrowPolygon, endTangent, pathBounds, type Bounds, unionBounds } from "./sketchGeometry";
import { textSizePx } from "./sketchOps";

/** Convertit un point en mètres en point du support (écran ou page d'export). */
export type Mapper = (p: Pt) => Pt;

export function esc(s: string): string {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

const r2 = (n: number): string => String(Math.round(n * 100) / 100);

/** Épaisseur du trait en pixels du support. `k` = pixels par mètre. */
export function strokePx(style: SketchStyle, k: number): number {
  return Math.max(0, style.widthMode === "screen" ? style.strokeWidth : style.strokeWidth * k);
}

export function mapNodes(nodes: SketchNode[], map: Mapper): SketchNode[] {
  return nodes.map((n) => ({
    p: map(n.p),
    hin: n.hin ? map(n.hin) : null,
    hout: n.hout ? map(n.hout) : null,
    smooth: n.smooth,
  }));
}

export function pathD(nodes: SketchNode[], closed: boolean): string {
  const n = nodes.length;
  if (n === 0) return "";
  let d = `M${r2(nodes[0].p.x)} ${r2(nodes[0].p.y)}`;
  const segs = closed ? n : n - 1;
  for (let i = 0; i < segs; i++) {
    const a = nodes[i];
    const b = nodes[(i + 1) % n];
    if (!a.hout && !b.hin) {
      d += `L${r2(b.p.x)} ${r2(b.p.y)}`;
    } else {
      const c1 = a.hout ?? a.p;
      const c2 = b.hin ?? b.p;
      d += `C${r2(c1.x)} ${r2(c1.y)} ${r2(c2.x)} ${r2(c2.y)} ${r2(b.p.x)} ${r2(b.p.y)}`;
    }
  }
  if (closed) d += "Z";
  return d;
}

function polyD(pts: Pt[]): string {
  return pts.map((p, i) => `${i === 0 ? "M" : "L"}${r2(p.x)} ${r2(p.y)}`).join("") + "Z";
}

function pathSvg(o: PathObject, map: Mapper, k: number): string {
  const s = o.style;
  const nodes = mapNodes(o.nodes, map);
  const w = strokePx(s, k);
  const stroke = sanitizeColor(s.stroke, null);
  const fill = o.closed || o.nodes.length >= 3 ? sanitizeColor(s.fill, null) : null;
  const base = Math.max(w, 1.5);
  let dash = "";
  let cap = s.cap;
  if (s.dash === "dashed") dash = ` stroke-dasharray="${r2(base * 3)} ${r2(base * 2)}"`;
  else if (s.dash === "dotted") {
    dash = ` stroke-dasharray="0.01 ${r2(base * 2.2)}"`;
    cap = "round";
  }
  let out =
    `<path d="${pathD(nodes, o.closed)}" fill="${fill ?? "none"}"` +
    (fill ? ` fill-opacity="${r2(s.fillOpacity)}"` : "") +
    ` stroke="${stroke ?? "none"}"` +
    (stroke ? ` stroke-width="${r2(w)}" stroke-linecap="${cap}" stroke-linejoin="${s.join}"${dash}` : "") +
    `/>`;
  if (stroke && !o.closed && (s.arrowStart || s.arrowEnd)) {
    const len = Math.max(6, base * s.arrowSize);
    for (const atEnd of [false, true]) {
      if ((atEnd && !s.arrowEnd) || (!atEnd && !s.arrowStart)) continue;
      const t = endTangent(nodes, atEnd);
      if (!t) continue;
      out += `<path d="${polyD(arrowPolygon(t.pt, t.dir, len, len * 0.42))}" fill="${stroke}" stroke="${stroke}" stroke-width="1" stroke-linejoin="round"/>`;
    }
  }
  return out;
}

function fontCss(id: string): string {
  return (FONTS.find((f) => f.id === id) ?? FONTS[0]).css;
}

function textSvg(o: TextObject, map: Mapper): string {
  const p = map(o.p);
  const color = sanitizeColor(o.color, "#ffffff") ?? "#ffffff";
  const halo = sanitizeColor(o.halo, null);
  const lines = o.text.split("\n");
  const tspans = lines
    .map((l, i) => `<tspan x="${r2(p.x)}" dy="${i === 0 ? 0 : r2(o.fontSize * 1.2)}">${esc(l) || "&#160;"}</tspan>`)
    .join("");
  return (
    `<text x="${r2(p.x)}" y="${r2(p.y)}" font-family="${esc(fontCss(o.fontFamily))}" font-size="${r2(o.fontSize)}"` +
    (o.bold ? ` font-weight="700"` : "") +
    (o.italic ? ` font-style="italic"` : "") +
    ` fill="${color}" text-anchor="${o.anchor}"` +
    (halo ? ` stroke="${halo}" stroke-width="${r2(Math.max(1, o.fontSize * 0.16))}" stroke-linejoin="round" paint-order="stroke"` : "") +
    (o.rotation ? ` transform="rotate(${r2(o.rotation)} ${r2(p.x)} ${r2(p.y)})"` : "") +
    `>${tspans}</text>`
  );
}

/** Un objet sous forme de SVG, enveloppé dans un <g> portant l'opacité de l'objet. */
export function objectSvg(o: SketchObject, map: Mapper, k: number): string {
  const op = o.kind === "path" ? o.style.opacity : o.opacity;
  const inner = o.kind === "path" ? pathSvg(o, map, k) : textSvg(o, map);
  return `<g data-id="${esc(o.id)}"${op < 1 ? ` opacity="${r2(op)}"` : ""}>${inner}</g>`;
}

function layerAttrId(name: string, index: number): string {
  const safe = name.replace(/[^A-Za-z0-9_-]+/g, "_").replace(/^_+|_+$/g, "");
  return `${safe || "Calque"}_${index + 1}`;
}

/** Tous les calques visibles du document, dans l'ordre d'empilement. */
export function docInnerSvg(doc: SketchDoc, map: Mapper, k: number, forExport = false): string {
  let out = "";
  doc.layers.forEach((layer, li) => {
    if (!layer.visible) return;
    const objs = doc.objects.filter((o) => o.layerId === layer.id);
    if (objs.length === 0 && !forExport) return;
    const attrs = forExport
      ? ` id="${esc(layerAttrId(layer.name, li))}" inkscape:groupmode="layer" inkscape:label="${esc(layer.name)}"`
      : ` data-layer="${esc(layer.id)}"`;
    out += `<g${attrs}>${objs.map((o) => objectSvg(o, map, k)).join("")}</g>`;
  });
  return out;
}

// ---------------------------------------------------------------------------
// Export : un croquis devient un fichier SVG autonome (ouvrable dans Illustrator, Inkscape…)
// ---------------------------------------------------------------------------

export type SvgExport = { svg: string; width: number; height: number };

/** Cadre (en mètres) de tout ce qui est visible, avec une estimation pour les textes. */
export function docBounds(doc: SketchDoc): Bounds | null {
  const visible = new Set(doc.layers.filter((l) => l.visible).map((l) => l.id));
  const bs: Bounds[] = [];
  for (const o of objectsInDrawOrder(doc)) {
    if (!visible.has(o.layerId)) continue;
    if (o.kind === "path") {
      const b = pathBounds(o.nodes, o.closed);
      if (b) bs.push(b);
    } else {
      bs.push({ minX: o.p.x, maxX: o.p.x, minY: o.p.y, maxY: o.p.y });
    }
  }
  return unionBounds(bs);
}

export function docToSvg(doc: SketchDoc, opts: { widthPx?: number; padding?: number; background?: string | null } = {}): SvgExport | null {
  const b = docBounds(doc);
  if (!b) return null;
  const widthPx = opts.widthPx ?? 1600;
  const pad = opts.padding ?? 60;
  // Un croquis réduit à un point ou à une ligne parfaitement horizontale/verticale : on lui donne de l'épaisseur.
  const spanX = Math.max(b.maxX - b.minX, 1);
  const spanY = Math.max(b.maxY - b.minY, 1);
  const k = widthPx / Math.max(spanX, spanY * (widthPx / 1200));
  const width = Math.round(spanX * k + 2 * pad);
  const height = Math.round(spanY * k + 2 * pad);
  const map: Mapper = (p) => ({ x: (p.x - b.minX) * k + pad, y: (b.maxY - p.y) * k + pad });
  // Les textes ajoutent leur largeur : on élargit la page si un texte dépasse du cadre.
  let extraRight = 0;
  for (const o of doc.objects) {
    if (o.kind !== "text") continue;
    const q = map(o.p);
    const sz = textSizePx(o);
    const right = o.anchor === "start" ? q.x + sz.w : o.anchor === "middle" ? q.x + sz.w / 2 : q.x;
    extraRight = Math.max(extraRight, right + pad - width);
  }
  const W = Math.round(width + Math.max(0, extraRight));
  const bg = opts.background ? `<rect width="${W}" height="${height}" fill="${sanitizeColor(opts.background, "#ffffff")}"/>` : "";
  const svg =
    `<?xml version="1.0" encoding="UTF-8"?>\n` +
    `<svg xmlns="http://www.w3.org/2000/svg" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" width="${W}" height="${height}" viewBox="0 0 ${W} ${height}">` +
    `<title>${esc(doc.title)}</title>` +
    (doc.sources ? `<desc>Sources : ${esc(doc.sources)}</desc>` : "") +
    bg +
    docInnerSvg(doc, map, k, true) +
    `</svg>\n`;
  return { svg, width: W, height };
}
