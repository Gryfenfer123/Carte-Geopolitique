// Outil de croquis — géométrie (logique pure : aucun DOM).
// Projection Web Mercator, courbes de Bézier cubiques, transformations, détection de clic,
// tracé main levée lissé, pointes de flèche. Voir docs/specs/croquis.md et docs/sources/croquis.md.

import type { Pt, SketchNode, PathObject, SketchObject } from "./sketchModel";

// ---------------------------------------------------------------------------
// Web Mercator (EPSG:3857) : la projection des tuiles de la carte
// ---------------------------------------------------------------------------

export const R_EARTH = 6378137;
/** Demi-circonférence : la carte du monde fait 2 × MERC_HALF mètres de large. */
export const MERC_HALF = Math.PI * R_EARTH;
const MAX_LAT = 85.05112878;

export function lngLatToMerc(lng: number, lat: number): Pt {
  const la = Math.max(-MAX_LAT, Math.min(MAX_LAT, lat));
  return {
    x: (R_EARTH * lng * Math.PI) / 180,
    y: R_EARTH * Math.log(Math.tan(Math.PI / 4 + (la * Math.PI) / 360)),
  };
}

export function mercToLngLat(p: Pt): { lng: number; lat: number } {
  return {
    lng: ((p.x / R_EARTH) * 180) / Math.PI,
    lat: ((2 * Math.atan(Math.exp(p.y / R_EARTH)) - Math.PI / 2) * 180) / Math.PI,
  };
}

/** Vue de la carte : `k` pixels par mètre, centre en mètres, taille de l'écran en pixels. */
export type View = { k: number; cx: number; cy: number; w: number; h: number };

export function makeView(centerLng: number, centerLat: number, zoom: number, w: number, h: number): View {
  const c = lngLatToMerc(centerLng, centerLat);
  return { k: (256 * Math.pow(2, zoom)) / (2 * MERC_HALF), cx: c.x, cy: c.y, w, h };
}

export function mercToPx(v: View, p: Pt): Pt {
  return { x: (p.x - v.cx) * v.k + v.w / 2, y: (v.cy - p.y) * v.k + v.h / 2 };
}

export function pxToMerc(v: View, x: number, y: number): Pt {
  return { x: v.cx + (x - v.w / 2) / v.k, y: v.cy - (y - v.h / 2) / v.k };
}

// ---------------------------------------------------------------------------
// Petits outils sur les points
// ---------------------------------------------------------------------------

export const dist = (a: Pt, b: Pt): number => Math.hypot(a.x - b.x, a.y - b.y);
export const lerp = (a: Pt, b: Pt, t: number): Pt => ({ x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t });
export const add = (a: Pt, b: Pt): Pt => ({ x: a.x + b.x, y: a.y + b.y });
export const sub = (a: Pt, b: Pt): Pt => ({ x: a.x - b.x, y: a.y - b.y });
export const scale = (a: Pt, s: number): Pt => ({ x: a.x * s, y: a.y * s });

export function cloneNode(n: SketchNode): SketchNode {
  return { p: { ...n.p }, hin: n.hin ? { ...n.hin } : null, hout: n.hout ? { ...n.hout } : null, smooth: n.smooth };
}

export function cornerNode(p: Pt): SketchNode {
  return { p: { x: p.x, y: p.y }, hin: null, hout: null, smooth: false };
}

// ---------------------------------------------------------------------------
// Courbes de Bézier cubiques
// ---------------------------------------------------------------------------

/** Les 4 points de contrôle du tronçon entre deux nœuds voisins. */
export function segPts(a: SketchNode, b: SketchNode): [Pt, Pt, Pt, Pt] {
  return [a.p, a.hout ?? a.p, b.hin ?? b.p, b.p];
}

export function bezierAt(p0: Pt, p1: Pt, p2: Pt, p3: Pt, t: number): Pt {
  const u = 1 - t;
  const a = u * u * u;
  const b = 3 * u * u * t;
  const c = 3 * u * t * t;
  const d = t * t * t;
  return {
    x: a * p0.x + b * p1.x + c * p2.x + d * p3.x,
    y: a * p0.y + b * p1.y + c * p2.y + d * p3.y,
  };
}

export function segmentCount(n: number, closed: boolean): number {
  if (n < 2) return 0;
  return closed ? n : n - 1;
}

/** Polyligne qui suit le tracé (pour les clics, les cadres, les calculs). */
export function flatten(nodes: SketchNode[], closed: boolean, steps = 16): Pt[] {
  const n = nodes.length;
  const out: Pt[] = [];
  const segs = segmentCount(n, closed);
  for (let i = 0; i < segs; i++) {
    const a = nodes[i];
    const b = nodes[(i + 1) % n];
    if (!a.hout && !b.hin) {
      out.push(a.p);
      continue;
    }
    const [p0, p1, p2, p3] = segPts(a, b);
    for (let s = 0; s < steps; s++) out.push(bezierAt(p0, p1, p2, p3, s / steps));
  }
  if (!closed && n > 0) out.push(nodes[n - 1].p);
  return out;
}

export type Bounds = { minX: number; minY: number; maxX: number; maxY: number };

export function boundsOfPoints(pts: Pt[]): Bounds | null {
  if (pts.length === 0) return null;
  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;
  for (const p of pts) {
    if (p.x < minX) minX = p.x;
    if (p.x > maxX) maxX = p.x;
    if (p.y < minY) minY = p.y;
    if (p.y > maxY) maxY = p.y;
  }
  return { minX, minY, maxX, maxY };
}

export function unionBounds(bs: Bounds[]): Bounds | null {
  if (bs.length === 0) return null;
  return {
    minX: Math.min(...bs.map((b) => b.minX)),
    minY: Math.min(...bs.map((b) => b.minY)),
    maxX: Math.max(...bs.map((b) => b.maxX)),
    maxY: Math.max(...bs.map((b) => b.maxY)),
  };
}

export function pathBounds(nodes: SketchNode[], closed: boolean): Bounds | null {
  return boundsOfPoints([...flatten(nodes, closed, 24), ...nodes.map((n) => n.p)]);
}

function distToSegment(p: Pt, a: Pt, b: Pt): number {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const l2 = dx * dx + dy * dy;
  if (l2 === 0) return dist(p, a);
  const t = Math.max(0, Math.min(1, ((p.x - a.x) * dx + (p.y - a.y) * dy) / l2));
  return Math.hypot(p.x - (a.x + t * dx), p.y - (a.y + t * dy));
}

/** Distance du point à la polyligne (fermée ou non). */
export function distToPolyline(p: Pt, pts: Pt[], closed: boolean): number {
  let best = Infinity;
  const n = pts.length;
  const last = closed ? n : n - 1;
  for (let i = 0; i < last; i++) best = Math.min(best, distToSegment(p, pts[i], pts[(i + 1) % n]));
  if (n === 1) best = dist(p, pts[0]);
  return best;
}

/** Point dans un polygone (règle pair-impair). */
export function pointInPolygon(p: Pt, poly: Pt[]): boolean {
  let inside = false;
  for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    const a = poly[i];
    const b = poly[j];
    if (a.y > p.y !== b.y > p.y && p.x < ((b.x - a.x) * (p.y - a.y)) / (b.y - a.y) + a.x) inside = !inside;
  }
  return inside;
}

/**
 * Un clic touche-t-il ce tracé ? `tol` = tolérance en mètres (≈ 6 px / k), `halfStroke` = demi-épaisseur
 * du trait en mètres.
 */
export function hitPath(o: PathObject, pt: Pt, tol: number, halfStroke: number): boolean {
  const poly = flatten(o.nodes, o.closed, 16);
  if (o.style.stroke && distToPolyline(pt, poly, o.closed) <= tol + halfStroke) return true;
  if (o.style.fill && poly.length >= 3 && (o.closed || o.nodes.length >= 3) && pointInPolygon(pt, poly)) return true;
  return false;
}

export type Nearest = { seg: number; t: number; dist: number; point: Pt };

/** Point du tracé le plus proche d'un point donné (pour ajouter un nœud au clic). */
export function nearestOnPath(nodes: SketchNode[], closed: boolean, pt: Pt): Nearest | null {
  const n = nodes.length;
  const segs = segmentCount(n, closed);
  let best: Nearest | null = null;
  const STEPS = 32;
  for (let i = 0; i < segs; i++) {
    const a = nodes[i];
    const b = nodes[(i + 1) % n];
    if (!a.hout && !b.hin) {
      // Tronçon droit : projection directe. (Avec les « poignées » confondues avec les extrémités,
      // le paramètre de Bézier n'avance pas à vitesse constante : il faut le paramètre LINÉAIRE,
      // celui que `splitSegment` attend pour un tronçon droit.)
      const dx = b.p.x - a.p.x;
      const dy = b.p.y - a.p.y;
      const l2 = dx * dx + dy * dy;
      const t = l2 === 0 ? 0 : Math.max(0, Math.min(1, ((pt.x - a.p.x) * dx + (pt.y - a.p.y) * dy) / l2));
      const point = lerp(a.p, b.p, t);
      const d = dist(pt, point);
      if (!best || d < best.dist) best = { seg: i, t, dist: d, point };
      continue;
    }
    const [p0, p1, p2, p3] = segPts(a, b);
    let bt = 0;
    let bd = Infinity;
    for (let s = 0; s <= STEPS; s++) {
      const d = dist(pt, bezierAt(p0, p1, p2, p3, s / STEPS));
      if (d < bd) {
        bd = d;
        bt = s / STEPS;
      }
    }
    // Affinage autour du meilleur échantillon.
    const lo = Math.max(0, bt - 1 / STEPS);
    const hi = Math.min(1, bt + 1 / STEPS);
    for (let s = 0; s <= 16; s++) {
      const t = lo + ((hi - lo) * s) / 16;
      const d = dist(pt, bezierAt(p0, p1, p2, p3, t));
      if (d < bd) {
        bd = d;
        bt = t;
      }
    }
    if (!best || bd < best.dist) best = { seg: i, t: bt, dist: bd, point: bezierAt(p0, p1, p2, p3, bt) };
  }
  return best;
}

/** Coupe le tronçon `seg` au paramètre `t` (de Casteljau) : renvoie les nœuds avec le nouveau nœud inséré. */
export function splitSegment(nodes: SketchNode[], closed: boolean, seg: number, t: number): SketchNode[] {
  const n = nodes.length;
  const out = nodes.map(cloneNode);
  const a = out[seg];
  const b = out[(seg + 1) % n];
  const [p0, p1, p2, p3] = segPts(a, b);
  if (!a.hout && !b.hin) {
    const m = lerp(p0, p3, t);
    const node = cornerNode(m);
    out.splice(seg + 1, 0, node);
    return out;
  }
  const p01 = lerp(p0, p1, t);
  const p12 = lerp(p1, p2, t);
  const p23 = lerp(p2, p3, t);
  const p012 = lerp(p01, p12, t);
  const p123 = lerp(p12, p23, t);
  const m = lerp(p012, p123, t);
  a.hout = a.hout ? p01 : null;
  b.hin = b.hin ? p23 : null;
  const node: SketchNode = { p: m, hin: p012, hout: p123, smooth: true };
  void closed;
  out.splice(seg + 1, 0, node);
  return out;
}

// ---------------------------------------------------------------------------
// Transformations (matrices 2D : x' = a·x + c·y + e ; y' = b·x + d·y + f)
// ---------------------------------------------------------------------------

export type Mat = readonly [number, number, number, number, number, number];
export const IDENTITY: Mat = [1, 0, 0, 1, 0, 0];

export function applyMat(m: Mat, p: Pt): Pt {
  return { x: m[0] * p.x + m[2] * p.y + m[4], y: m[1] * p.x + m[3] * p.y + m[5] };
}

/** m1 ∘ m2 : applique d'abord m2, puis m1. */
export function mulMat(m1: Mat, m2: Mat): Mat {
  return [
    m1[0] * m2[0] + m1[2] * m2[1],
    m1[1] * m2[0] + m1[3] * m2[1],
    m1[0] * m2[2] + m1[2] * m2[3],
    m1[1] * m2[2] + m1[3] * m2[3],
    m1[0] * m2[4] + m1[2] * m2[5] + m1[4],
    m1[1] * m2[4] + m1[3] * m2[5] + m1[5],
  ];
}

export const translateM = (dx: number, dy: number): Mat => [1, 0, 0, 1, dx, dy];
export const scaleM = (sx: number, sy: number, pivot: Pt): Mat => [
  sx,
  0,
  0,
  sy,
  pivot.x - sx * pivot.x,
  pivot.y - sy * pivot.y,
];
/** Rotation d'un angle (radians, sens trigonométrique dans le plan en mètres, y vers le nord) autour du pivot. */
export function rotateM(rad: number, pivot: Pt): Mat {
  const c = Math.cos(rad);
  const s = Math.sin(rad);
  return [c, s, -s, c, pivot.x - c * pivot.x + s * pivot.y, pivot.y - s * pivot.x - c * pivot.y];
}

export function transformNode(n: SketchNode, m: Mat): SketchNode {
  return {
    p: applyMat(m, n.p),
    hin: n.hin ? applyMat(m, n.hin) : null,
    hout: n.hout ? applyMat(m, n.hout) : null,
    smooth: n.smooth,
  };
}

/** Applique une matrice à un objet (renvoie un nouvel objet). Le texte garde une taille lisible. */
export function transformObject(o: SketchObject, m: Mat): SketchObject {
  if (o.kind === "path") return { ...o, nodes: o.nodes.map((n) => transformNode(n, m)) };
  const det = Math.abs(m[0] * m[3] - m[1] * m[2]);
  const factor = Math.sqrt(det) || 1;
  // Rotation visible à l'écran : le plan en mètres a son y vers le haut, l'écran vers le bas.
  const rot = (-Math.atan2(m[1], m[0]) * 180) / Math.PI;
  return {
    ...o,
    p: applyMat(m, o.p),
    fontSize: Math.min(400, Math.max(4, o.fontSize * factor)),
    rotation: o.rotation + rot,
  };
}

// ---------------------------------------------------------------------------
// Formes toutes faites
// ---------------------------------------------------------------------------

export function rectNodes(a: Pt, b: Pt): SketchNode[] {
  const minX = Math.min(a.x, b.x);
  const maxX = Math.max(a.x, b.x);
  const minY = Math.min(a.y, b.y);
  const maxY = Math.max(a.y, b.y);
  return [
    cornerNode({ x: minX, y: maxY }),
    cornerNode({ x: maxX, y: maxY }),
    cornerNode({ x: maxX, y: minY }),
    cornerNode({ x: minX, y: minY }),
  ];
}

/** 4/3 × (√2 − 1) : longueur de poignée qui fait d'un quart de cercle une Bézier cubique. */
export const KAPPA = (4 / 3) * (Math.SQRT2 - 1);

export function ellipseNodes(a: Pt, b: Pt): SketchNode[] {
  const cx = (a.x + b.x) / 2;
  const cy = (a.y + b.y) / 2;
  const rx = Math.abs(b.x - a.x) / 2;
  const ry = Math.abs(b.y - a.y) / 2;
  const kx = KAPPA * rx;
  const ky = KAPPA * ry;
  const mk = (p: Pt, hin: Pt, hout: Pt): SketchNode => ({ p, hin, hout, smooth: true });
  return [
    mk({ x: cx + rx, y: cy }, { x: cx + rx, y: cy + ky }, { x: cx + rx, y: cy - ky }),
    mk({ x: cx, y: cy - ry }, { x: cx + kx, y: cy - ry }, { x: cx - kx, y: cy - ry }),
    mk({ x: cx - rx, y: cy }, { x: cx - rx, y: cy - ky }, { x: cx - rx, y: cy + ky }),
    mk({ x: cx, y: cy + ry }, { x: cx - kx, y: cy + ry }, { x: cx + kx, y: cy + ry }),
  ];
}

/** Simplification de Ramer-Douglas-Peucker. */
export function simplifyRdp(pts: Pt[], eps: number): Pt[] {
  if (pts.length < 3) return pts.slice();
  const keep = new Array<boolean>(pts.length).fill(false);
  keep[0] = true;
  keep[pts.length - 1] = true;
  const stack: [number, number][] = [[0, pts.length - 1]];
  while (stack.length) {
    const [s, e] = stack.pop() as [number, number];
    let maxD = 0;
    let idx = -1;
    for (let i = s + 1; i < e; i++) {
      const d = distToSegment(pts[i], pts[s], pts[e]);
      if (d > maxD) {
        maxD = d;
        idx = i;
      }
    }
    if (idx >= 0 && maxD > eps) {
      keep[idx] = true;
      stack.push([s, idx], [idx, e]);
    }
  }
  return pts.filter((_, i) => keep[i]);
}

/** Trait main levée → courbe lisse (Catmull-Rom converti en Bézier) à peu de nœuds. */
export function fitSmooth(raw: Pt[], eps: number): SketchNode[] {
  const pts = simplifyRdp(raw, eps);
  const n = pts.length;
  if (n < 2) return [];
  if (n === 2) return [cornerNode(pts[0]), cornerNode(pts[1])];
  const nodes: SketchNode[] = [];
  for (let i = 0; i < n; i++) {
    const p = pts[i];
    if (i === 0) {
      nodes.push({ p, hin: null, hout: lerp(p, pts[1], 1 / 3), smooth: false });
    } else if (i === n - 1) {
      nodes.push({ p, hin: lerp(p, pts[n - 2], 1 / 3), hout: null, smooth: false });
    } else {
      const t = scale(sub(pts[i + 1], pts[i - 1]), 1 / 6);
      nodes.push({ p, hin: sub(p, t), hout: add(p, t), smooth: true });
    }
  }
  return nodes;
}

// ---------------------------------------------------------------------------
// Pointes de flèche (calculées en pixels, à partir des nœuds déjà convertis en pixels)
// ---------------------------------------------------------------------------

function unit(v: Pt): Pt | null {
  const l = Math.hypot(v.x, v.y);
  return l > 1e-9 ? { x: v.x / l, y: v.y / l } : null;
}

/** Point et direction (vers l'extérieur) à une extrémité d'un tracé ouvert. */
export function endTangent(nodes: SketchNode[], atEnd: boolean): { pt: Pt; dir: Pt } | null {
  const n = nodes.length;
  if (n < 2) return null;
  const e = atEnd ? nodes[n - 1] : nodes[0];
  const nb = atEnd ? nodes[n - 2] : nodes[1];
  const own = atEnd ? e.hin : e.hout;
  const nbOwn = atEnd ? nb.hout : nb.hin;
  const candidates = [own, nbOwn, nb.p];
  for (const c of candidates) {
    if (!c) continue;
    const u = unit(sub(e.p, c));
    if (u) return { pt: e.p, dir: u };
  }
  return null;
}

export function arrowPolygon(tip: Pt, dir: Pt, length: number, halfWidth: number): Pt[] {
  const bx = tip.x - dir.x * length;
  const by = tip.y - dir.y * length;
  const nx = -dir.y;
  const ny = dir.x;
  return [tip, { x: bx + nx * halfWidth, y: by + ny * halfWidth }, { x: bx - nx * halfWidth, y: by - ny * halfWidth }];
}
