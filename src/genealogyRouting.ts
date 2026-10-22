// Tracé des liens de l'arbre généalogique — logique pure, sans DOM.
//
// Demande de Martin (2026-10-22) : « qu'il ne soit pas possible qu'un trait
// passe sur un portrait, un personnage, quoi que ce soit. Les liens doivent
// être contournés. » On calcule donc, pour chaque lien, une ligne brisée qui
// évite toutes les cartes (sauf celles du lien lui-même). Si rien ne gêne, le
// trait reste droit comme avant.

export interface Rect {
  x: number;
  y: number;
  w: number;
  h: number;
}
export interface Pt {
  x: number;
  y: number;
}

const MAX_DEPTH = 5;

function inflate(r: Rect, pad: number): Rect {
  return { x: r.x - pad, y: r.y - pad, w: r.w + pad * 2, h: r.h + pad * 2 };
}

function containsStrict(r: Rect, p: Pt): boolean {
  return p.x > r.x + 0.5 && p.x < r.x + r.w - 0.5 && p.y > r.y + 0.5 && p.y < r.y + r.h - 0.5;
}

// Le segment a→b traverse-t-il l'intérieur du rectangle ? Renvoie la
// distance (0..1) d'entrée le long du segment, ou -1 s'il ne le traverse pas.
function hitT(a: Pt, b: Pt, r: Rect): number {
  const eps = 0.5;
  const x0 = r.x + eps;
  const x1 = r.x + r.w - eps;
  const y0 = r.y + eps;
  const y1 = r.y + r.h - eps;
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  let t0 = 0;
  let t1 = 1;
  const clip = (p: number, q: number): boolean => {
    if (p === 0) return q >= 0;
    const t = q / p;
    if (p < 0) {
      if (t > t1) return false;
      if (t > t0) t0 = t;
    } else {
      if (t < t0) return false;
      if (t < t1) t1 = t;
    }
    return true;
  };
  if (clip(-dx, a.x - x0) && clip(dx, x1 - a.x) && clip(-dy, a.y - y0) && clip(dy, y1 - a.y)) {
    return t1 - t0 > 1e-6 ? t0 : -1;
  }
  return -1;
}

function len(a: Pt, b: Pt): number {
  return Math.hypot(a.x - b.x, a.y - b.y);
}

function pathLen(pts: Pt[]): number {
  let s = 0;
  for (let i = 1; i < pts.length; i++) s += len(pts[i - 1], pts[i]);
  return s;
}

function firstBlocker(a: Pt, b: Pt, obs: Rect[]): Rect | null {
  let best: Rect | null = null;
  let bt = Infinity;
  for (const r of obs) {
    const t = hitT(a, b, r);
    if (t >= 0 && t < bt) {
      bt = t;
      best = r;
    }
  }
  return best;
}

function route(a: Pt, b: Pt, obs: Rect[], depth: number, down: number): Pt[] | null {
  const blocker = firstBlocker(a, b, obs);
  if (!blocker) return [a, b];
  if (depth >= MAX_DEPTH) return null;
  const corners: Pt[] = [
    { x: blocker.x, y: blocker.y },
    { x: blocker.x + blocker.w, y: blocker.y },
    { x: blocker.x + blocker.w, y: blocker.y + blocker.h },
    { x: blocker.x, y: blocker.y + blocker.h },
  ]
    .filter((c) => !obs.some((r) => containsStrict(r, c)))
    // down = 2 : descente stricte (jamais de remontée, jamais plus bas que l'arrivée) ;
    // down = 1 : jamais de remontée seulement ; 0 : libre.
    .filter((c) => down === 0 || (c.y >= a.y - 0.5 && (down === 1 || c.y <= b.y + 0.5)))
    .sort((p, q) => len(a, p) + len(p, b) - (len(a, q) + len(q, b)))
    .slice(0, 3);
  let best: Pt[] | null = null;
  let bestLen = Infinity;
  for (const c of corners) {
    const first = route(a, c, obs, depth + 1, down);
    if (!first) continue;
    const second = route(c, b, obs, depth + 1, down);
    if (!second) continue;
    const path = first.concat(second.slice(1));
    const l = pathLen(path);
    if (l < bestLen) {
      bestLen = l;
      best = path;
    }
  }
  return best;
}

// Retire les points alignés (inutiles) d'une ligne brisée.
function simplify(pts: Pt[]): Pt[] {
  const out: Pt[] = [pts[0]];
  for (let i = 1; i < pts.length - 1; i++) {
    const p = out[out.length - 1];
    const c = pts[i];
    const n = pts[i + 1];
    const cross = (c.x - p.x) * (n.y - c.y) - (c.y - p.y) * (n.x - c.x);
    if (Math.abs(cross) > 1e-3) out.push(c);
  }
  out.push(pts[pts.length - 1]);
  return out;
}

/**
 * Ligne brisée de `a` à `b` qui contourne les `cards` (rectangles bruts des
 * cartes). Les cartes qui contiennent `a` ou `b` sont ignorées (ce sont les
 * extrémités du lien). `pad` = marge laissée autour des cartes. Si aucun
 * contournement n'est possible (cas extrême), renvoie le trait droit.
 */
export function routeAround(a: Pt, b: Pt, cards: Rect[], pad = 14, descend = false): Pt[] {
  const obs = cards
    .filter((r) => !containsStrict(r, a) && !containsStrict(r, b))
    .map((r) => inflate(r, pad));
  // Un point de départ coincé dans une carte « gonflée » (marge) : on ignore
  // cette carte plutôt que de bloquer le tracé.
  const usable = obs.filter((r) => !containsStrict(r, a) && !containsStrict(r, b));
  const quick = firstBlocker(a, b, usable);
  if (!quick) return [a, b];
  // Lien de descendance : le trait ne doit jamais remonter (demande de
  // Martin, 2026-10-22). On essaie d'abord une descente stricte, puis sans
  // remontée, puis libre.
  const levels = descend && b.y > a.y ? [2, 1, 0] : [0];
  for (const lv of levels) {
    const path = route(a, b, usable, 0, lv);
    if (path) return simplify(path);
  }
  return [a, b];
}

/** Nombre de cartes réellement traversées par une ligne brisée (pour les tests). */
export function countCrossings(path: Pt[], cards: Rect[]): number {
  let n = 0;
  for (const r of cards) {
    if (containsStrict(r, path[0]) || containsStrict(r, path[path.length - 1])) continue;
    for (let i = 1; i < path.length; i++) {
      if (hitT(path[i - 1], path[i], r) >= 0) {
        n++;
        break;
      }
    }
  }
  return n;
}
