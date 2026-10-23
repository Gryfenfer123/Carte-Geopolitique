// Mise en page d'un arbre généalogique « en couches » (demande de Martin,
// 2026-10-23, remplace le rangement « descendant depuis la racine » de
// genealogyLayout.ts pour le bouton « Organiser par dates »).
//
// Principes (dans l'ordre de priorité voulu par Martin) :
//  1. LES ENFANTS SOUS LEURS PARENTS : chaque personne a une ligne (génération)
//     déterminée par sa date de naissance (une ligne = `rowYears` ans, jamais
//     au-dessus de ses parents). Sur une ligne, l'ordre gauche-droite est
//     calculé pour réduire les croisements de traits, pas imposé par un arbre.
//  2. LES COUPLES CÔTE À CÔTE, mais seulement après (1) : un couple est un bloc,
//     et quand les deux époux viennent de branches éloignées, le bloc se place
//     ENTRE les deux familles (moindre carré des distances), au lieu de tirer
//     un long trait vers l'une d'elles.
//  3. Les traits qui traversent plusieurs lignes réservent leur passage
//     (nœuds fantômes invisibles), donc aucune carte ne se trouve sur leur chemin.
//
// Fonction pure (aucun accès réseau/DOM), testable seule.

import { planBuses, type BusEdge } from "./genealogyBus";

export type LNode = { id: string; birth: number | null; name?: string; female?: boolean };
export type LRel = { a: string; b: string; type: string };
export type LayersOptions = {
  cardW: number;
  cardH: number;
  originYear: number;
  pxPerYear: number;
  rowYears: number; // durée d'une ligne (génération) en années
  gapX: number; // espace libre minimal entre deux cartes d'une même ligne
  spouseGap: number; // espace libre entre deux époux
  budgetMs?: number;
};
export type LayersStats = { crossings: number; cardHits: number; longEdges: number; edges: number; totalLen: number; rows: number };
export type LayersResult = { pos: Map<string, { x: number; y: number }>; stats: LayersStats; longEdgeIds: [string, string][] };

type Unit = { id: number; members: string[]; order: string[]; row: number; year: number | null };
type Item = { kind: "u" | "d"; u?: Unit; e?: Edge; w: number; x: number; t: number; wt: number };
type Edge = { child: string; parents: string[]; dummies: Item[]; pRow: number; cRow: number };

function pav(y: number[], w: number[]): number[] {
  const bs: { sum: number; w: number; n: number }[] = [];
  for (let i = 0; i < y.length; i++) {
    bs.push({ sum: y[i] * w[i], w: w[i], n: 1 });
    while (bs.length > 1 && bs[bs.length - 2].sum / bs[bs.length - 2].w > bs[bs.length - 1].sum / bs[bs.length - 1].w) {
      const b = bs.pop()!;
      const a = bs.pop()!;
      bs.push({ sum: a.sum + b.sum, w: a.w + b.w, n: a.n + b.n });
    }
  }
  const out: number[] = [];
  for (const b of bs) {
    const v = b.sum / b.w;
    for (let k = 0; k < b.n; k++) out.push(v);
  }
  return out;
}

export function computeLayersLayout(nodes: LNode[], rels: LRel[], o: LayersOptions): LayersResult {
  const CW = o.cardW;
  const P = CW + o.spouseGap; // pas entre deux époux
  const rowH = o.rowYears * o.pxPerYear;
  const byId = new Map(nodes.map((n) => [n.id, n]));
  const parentsOf = new Map<string, string[]>();
  const childrenOf = new Map<string, string[]>();
  const spouses = new Map<string, string[]>();
  const push = (m: Map<string, string[]>, k: string, v: string) => {
    const l = m.get(k) || [];
    if (!l.includes(v)) l.push(v);
    m.set(k, l);
  };
  rels.forEach((r) => {
    if (!byId.has(r.a) || !byId.has(r.b) || r.a === r.b) return;
    if (r.type === "parent") {
      push(childrenOf, r.a, r.b);
      push(parentsOf, r.b, r.a);
    } else if (r.type === "spouse") {
      push(spouses, r.a, r.b);
      push(spouses, r.b, r.a);
    }
  });
  const birth = (id: string) => byId.get(id)?.birth ?? null;
  const nameOf = (id: string) => byId.get(id)?.name || "";

  // ---- composantes connexes (parenté + mariage) : chacune est calculée à part
  const comp = new Map<string, number>();
  const comps: string[][] = [];
  for (const n of nodes) {
    if (comp.has(n.id)) continue;
    const stack = [n.id];
    const list: string[] = [];
    comp.set(n.id, comps.length);
    while (stack.length) {
      const c = stack.pop()!;
      list.push(c);
      for (const q of [...(parentsOf.get(c) || []), ...(childrenOf.get(c) || []), ...(spouses.get(c) || [])]) {
        if (!comp.has(q)) {
          comp.set(q, comps.length);
          stack.push(q);
        }
      }
    }
    comps.push(list);
  }

  type CompOut = { cx: Map<string, number>; row: Map<string, number>; cross: number; hits: number; edges: number; len: number; longE: [string, string][] };
  const budget = o.budgetMs ?? 2500;
  const t00 = Date.now();

  function layoutComp(ids: string[], budgetMs: number): CompOut {
    const tStart = Date.now();
    const inC = new Set(ids);
    const par = (id: string) => (parentsOf.get(id) || []).filter((q) => inC.has(q));
    const kids = (id: string) => (childrenOf.get(id) || []).filter((q) => inC.has(q));
    const spo = (id: string) => (spouses.get(id) || []).filter((q) => inC.has(q));

    // ---- foyers (couples et mariages multiples) = blocs
    const unitOf = new Map<string, Unit>();
    const units: Unit[] = [];
    for (const id of ids) {
      if (unitOf.has(id)) continue;
      const u: Unit = { id: units.length, members: [], order: [], row: 0, year: null };
      const st = [id];
      unitOf.set(id, u);
      while (st.length) {
        const c = st.pop()!;
        u.members.push(c);
        for (const q of spo(c)) if (!unitOf.has(q)) { unitOf.set(q, u); st.push(q); }
      }
      units.push(u);
    }
    // ordre interne : le « pivot » (le plus de conjoints) au milieu, ses conjoints de part et d'autre
    function chain(u: Unit): string[] {
      if (u.members.length === 1) return [u.members[0]];
      const hub = u.members.slice().sort((a, b) => spo(b).length - spo(a).length || (birth(a) ?? 1e9) - (birth(b) ?? 1e9))[0];
      const seen = new Set<string>([hub]);
      const left: string[] = [];
      const right: string[] = [];
      const first = spo(hub).sort((a, b) => (birth(a) ?? 1e9) - (birth(b) ?? 1e9) || nameOf(a).localeCompare(nameOf(b)));
      first.forEach((s, i) => {
        seen.add(s);
        const side = i % 2 === 0 ? left : right;
        side.push(s);
      });
      // conjoints des conjoints : vers l'extérieur
      const ext = (side: string[], dir: "l" | "r") => {
        for (let i = 0; i < side.length; i++) {
          for (const q of spo(side[i])) {
            if (!seen.has(q)) {
              seen.add(q);
              if (dir === "l") side.splice(i, 0, q);
              else side.splice(i + 1, 0, q);
            }
          }
        }
      };
      ext(left, "l");
      ext(right, "r");
      u.members.forEach((m) => { if (!seen.has(m)) right.push(m); });
      return [...left, hub, ...right];
    }
    units.forEach((u) => (u.order = chain(u)));
    const uW = (u: Unit) => (u.order.length - 1) * P + CW;
    const offOf = (u: Unit, id: string) => (u.order.indexOf(id) - (u.order.length - 1) / 2) * P;

    // ---- lignes (générations) : date de naissance, jamais au-dessus des parents
    const isBlood = (id: string) => par(id).length > 0;
    for (const u of units) {
      const blood = u.members.filter(isBlood).map(birth).filter((v): v is number => v != null);
      const all = u.members.map(birth).filter((v): v is number => v != null);
      const src = blood.length ? blood : all;
      u.year = src.length ? src.reduce((s, v) => s + v, 0) / src.length : null;
    }
    const parentUnits = (u: Unit) => {
      const s = new Set<Unit>();
      u.members.forEach((m) => par(m).forEach((p) => { const pu = unitOf.get(p)!; if (pu !== u) s.add(pu); }));
      return Array.from(s);
    };
    const childUnits = (u: Unit) => {
      const s = new Set<Unit>();
      u.members.forEach((m) => kids(m).forEach((c) => { const cu = unitOf.get(c)!; if (cu !== u) s.add(cu); }));
      return Array.from(s);
    };
    // Les frères et sœurs (mêmes parents) partagent la même ligne : on prend la
    // date moyenne de la fratrie, pas la date de chacun (sinon une fratrie étalée
    // sur 20 ans se répartit sur plusieurs lignes et ses traits se mélangent).
    const sibMean = (id: string): number | null => {
      const ps = par(id);
      if (!ps.length) return birth(id);
      const sibs = new Set<string>([id]);
      ps.forEach((p) => kids(p).forEach((c) => { if (par(c).some((q) => ps.includes(q))) sibs.add(c); }));
      const ys = Array.from(sibs).map(birth).filter((v): v is number => v != null);
      return ys.length ? ys.reduce((a, b) => a + b, 0) / ys.length : null;
    };
    const rowRaw = new Map<Unit, number | null>();
    units.forEach((u) => {
      const blood = u.members.filter(isBlood).map(sibMean).filter((v): v is number => v != null);
      const y = blood.length ? Math.max(...blood) : u.year;
      rowRaw.set(u, y == null ? null : Math.round((y - o.originYear) / o.rowYears));
    });
    const rowv = new Map<Unit, number | null>(rowRaw);
    const relax = () => {
      for (let g = 0; g < 120; g++) {
        let ch = false;
        for (const u of units) {
          const ps = parentUnits(u).map((p) => rowv.get(p)).filter((v): v is number => v != null);
          if (!ps.length) continue;
          const need = Math.max(...ps) + 1;
          const cur = rowv.get(u);
          if (cur == null || cur < need) { rowv.set(u, need); ch = true; }
        }
        if (!ch) break;
      }
    };
    relax();
    for (let g = 0; g < 10; g++) {
      let ch = false;
      for (const u of units) {
        if (rowv.get(u) != null) continue;
        const cs = childUnits(u).map((c) => rowv.get(c)).filter((v): v is number => v != null);
        if (cs.length) { rowv.set(u, Math.min(...cs) - 1); ch = true; }
      }
      if (!ch) break;
    }
    const known = Array.from(rowv.values()).filter((v): v is number => v != null);
    const fallback = known.length ? Math.min(...known) : 0;
    units.forEach((u) => { if (rowv.get(u) == null) rowv.set(u, fallback); });
    relax();
    units.forEach((u) => (u.row = rowv.get(u)!));

    // ---- arêtes parent -> enfant, avec nœuds fantômes pour les traits qui traversent des lignes
    const edges: Edge[] = [];
    const rowOfP = (id: string) => unitOf.get(id)!.row;
    for (const c of ids) {
      const ps = par(c).filter((p) => unitOf.get(p) !== unitOf.get(c));
      if (!ps.length) continue;
      const pRow = Math.max(...ps.map(rowOfP));
      const cRow = rowOfP(c);
      const e: Edge = { child: c, parents: ps, dummies: [], pRow, cRow };
      for (let r = pRow + 1; r < cRow; r++) e.dummies.push({ kind: "d", e, w: 36, x: 0, t: 0, wt: 0 });
      edges.push(e);
    }

    // ---- lignes d'éléments
    const rowsMap = new Map<number, Item[]>();
    const itemOfUnit = new Map<Unit, Item>();
    const addItem = (r: number, it: Item) => { const l = rowsMap.get(r) || []; l.push(it); rowsMap.set(r, l); };
    units.forEach((u) => { const it: Item = { kind: "u", u, w: uW(u), x: 0, t: 0, wt: 0 }; itemOfUnit.set(u, it); addItem(u.row, it); });
    edges.forEach((e) => e.dummies.forEach((d, i) => addItem(e.pRow + 1 + i, d)));
    const rowKeys = Array.from(rowsMap.keys()).sort((a, b) => a - b);
    const rowsArr = rowKeys.map((k) => rowsMap.get(k)!);
    const rowIndexOfItem = new Map<Item, number>();
    rowsArr.forEach((l, i) => l.forEach((it) => rowIndexOfItem.set(it, i)));
    const edgesOfChild = new Map<string, Edge>();
    edges.forEach((e) => edgesOfChild.set(e.child, e));
    const edgesOfParent = new Map<string, Edge[]>();
    edges.forEach((e) => e.parents.forEach((p) => { const l = edgesOfParent.get(p) || []; l.push(e); edgesOfParent.set(p, l); }));

    const cardX = (id: string) => { const u = unitOf.get(id)!; return itemOfUnit.get(u)!.x + offOf(u, id); };
    const sepOf = (a: Item, b: Item) => (a.w + b.w) / 2 + (a.kind === "d" || b.kind === "d" ? 44 : o.gapX);

    // ---- points d'attache
    // parent -> haut : x du point d'où part le trait (milieu des parents)
    const parentPoint = (e: Edge) => e.parents.reduce((s, p) => s + cardX(p), 0) / e.parents.length;
    const aboveX = (e: Edge, i: number) => (i === 0 ? parentPoint(e) : e.dummies[i - 1].x);
    const belowX = (e: Edge, i: number) => (i === e.dummies.length - 1 ? cardX(e.child) : e.dummies[i + 1].x);

    // famille à enfant unique : le trait doit tomber droit (pas de virage inutile)
    const only = (e: Edge) => {
      const sibs = new Set<string>();
      e.parents.forEach((p) => kids(p).forEach((c) => { if (par(c).length === e.parents.length && par(c).every((q) => e.parents.includes(q))) sibs.add(c); }));
      return sibs.size <= 1;
    };
    function pullsOf(it: Item): { v: number; w: number }[] {
      const out: { v: number; w: number }[] = [];
      if (it.kind === "d") {
        const e = it.e!;
        const i = e.dummies.indexOf(it);
        out.push({ v: aboveX(e, i), w: 2 }, { v: belowX(e, i), w: 2 });
        return out;
      }
      const u = it.u!;
      for (const m of u.order) {
        const e = edgesOfChild.get(m);
        if (e) {
          const a = e.dummies.length ? e.dummies[e.dummies.length - 1].x : parentPoint(e);
          out.push({ v: a - offOf(u, m), w: only(e) ? 5 : 1.2 });
        }
        for (const ed of edgesOfParent.get(m) || []) {
          const b = ed.dummies.length ? ed.dummies[0].x : cardX(ed.child);
          // le point de départ du trait est le milieu des parents ; on en déduit où doit être ce foyer
          const mine = ed.parents.filter((p) => unitOf.get(p) === u);
          const mo = mine.reduce((s, p) => s + offOf(u, p), 0) / mine.length;
          let v = b - mo;
          if (mine.length < ed.parents.length) {
            const others = ed.parents.filter((p) => unitOf.get(p) !== u);
            const ox = others.reduce((s, p) => s + cardX(p), 0) / others.length;
            // milieu = (mine*(x+mo) + others*ox)/n  => x = (b*n - others*ox)/mine - mo
            v = (b * ed.parents.length - ox * others.length) / mine.length - mo;
            v = 0.5 * v + 0.5 * (b - mo);
          }
          out.push({ v, w: only(ed) ? 5 : 1 });
        }
      }
      return out;
    }

    function orientCost(it: Item, flip: boolean): number {
      const u = it.u!;
      const n = u.order.length;
      let c = 0;
      for (const m of u.order) {
        const e = edgesOfChild.get(m);
        if (!e) continue;
        const idx = u.order.indexOf(m);
        const off = ((flip ? n - 1 - idx : idx) - (n - 1) / 2) * P;
        const a = e.dummies.length ? e.dummies[e.dummies.length - 1].x : parentPoint(e);
        c += Math.abs(a - (it.x + off));
      }
      return c;
    }

    // ---- évaluation
    // Traits tels que l'appli les dessine (renderLinks) : un trait unique du milieu
    // du mariage vers l'enfant quand ses deux parents sont mariés entre eux, sinon
    // un trait par parent (bas de la carte -> haut de l'enfant). La note compte les
    // croisements trait/trait, trait/lien de mariage et trait/carte (jamais voulu).
    const spouseEdges: [string, string][] = [];
    ids.forEach((a) => spo(a).forEach((q) => { if (a < q) spouseEdges.push([a, q]); }));
    const segX = (a: number[], b: number[]) => {
      const d = (p: number[], q: number[], r: number[]) => (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0]);
      const d1 = d(b.slice(0, 2), b.slice(2), a.slice(0, 2));
      const d2 = d(b.slice(0, 2), b.slice(2), a.slice(2));
      const d3 = d(a.slice(0, 2), a.slice(2), b.slice(0, 2));
      const d4 = d(a.slice(0, 2), a.slice(2), b.slice(2));
      const E = 1e-3;
      return ((d1 > E && d2 < -E) || (d1 < -E && d2 > E)) && ((d3 > E && d4 < -E) || (d3 < -E && d4 > E));
    };
    // La note reproduit le tracé réel de l'appli (genealogyBus.ts) : barre commune par
    // famille, descentes verticales. Un trait qui ne peut pas être tracé « en peigne »
    // sans traverser une carte est lourdement pénalisé (l'appli le contournerait).
    function evaluate(): { cost: number; cross: number; len: number; longE: [string, string][]; hits: number } {
      let len = 0;
      const longE: [string, string][] = [];
      const bus: BusEdge[] = [];
      const top = (id: string) => unitOf.get(id)!.row * rowH;
      for (const e of edges) {
        const c = e.child;
        const ex = cardX(c);
        const ey = top(c);
        const ps = e.parents;
        const merged = ps.length === 2 && spo(ps[0]).includes(ps[1]);
        if (merged) {
          const mx = (cardX(ps[0]) + cardX(ps[1])) / 2;
          bus.push({ id: "M" + c, start: { x: mx, y: top(ps[0]) + o.cardH / 2 }, end: { x: ex, y: ey }, group: "M" + ps.slice().sort().join("|") });
        } else {
          ps.forEach((p) => bus.push({ id: "P" + p + ">" + c, start: { x: cardX(p), y: top(p) + o.cardH }, end: { x: ex, y: ey }, group: "P" + p }));
        }
        const dx = Math.abs(parentPoint(e) - ex);
        len += dx;
        if (dx > 1500) { longE.push([ps[0], c]); len += (dx - 1500) * 3; }
      }
      const cards: { x: number; y: number; w: number; h: number }[] = [];
      units.forEach((u) => u.order.forEach((m) => cards.push({ x: cardX(m) - CW / 2, y: u.row * rowH, w: CW, h: o.cardH })));
      const paths = planBuses(bus, { cards, above: 70, lane: 26, maxLanes: 6 });
      let hits = 0;
      const polys: { pts: { x: number; y: number }[]; group: string; end: string }[] = [];
      for (const b of bus) {
        const pts = paths.get(b.id);
        if (!pts) { hits++; polys.push({ pts: [b.start, b.end], group: b.group, end: b.id }); } else polys.push({ pts, group: b.group, end: b.id });
      }
      const segs: { x1: number; y1: number; x2: number; y2: number; g: number }[] = [];
      polys.forEach((pl, gi) => { for (let i = 0; i + 1 < pl.pts.length; i++) segs.push({ x1: pl.pts[i].x, y1: pl.pts[i].y, x2: pl.pts[i + 1].x, y2: pl.pts[i + 1].y, g: gi }); });
      let cross = 0;
      for (let i = 0; i < segs.length; i++) {
        const A = segs[i];
        for (let j = i + 1; j < segs.length; j++) {
          const B = segs[j];
          if (A.g === B.g || polys[A.g].group === polys[B.g].group) continue;
          if (segX([A.x1, A.y1, A.x2, A.y2], [B.x1, B.y1, B.x2, B.y2])) cross++;
        }
      }
      for (const [a, b] of spouseEdges) {
        const L = [cardX(a), top(a) + o.cardH / 2, cardX(b), top(b) + o.cardH / 2];
        const ga = "M" + [a, b].sort().join("|");
        for (const sg of segs) {
          if (polys[sg.g].group === ga) continue;
          if (segX(L, [sg.x1, sg.y1, sg.x2, sg.y2])) cross++;
        }
      }
      return { cost: len + cross * 1500 + hits * 6000, cross, len, longE, hits };
    }

    function pack(l: Item[]) {
      let x = 0;
      l.forEach((it, i) => {
        if (i > 0) x += sepOf(l[i - 1], it);
        it.x = x;
      });
      const mid = (l[0].x + l[l.length - 1].x) / 2;
      l.forEach((it) => (it.x -= mid));
    }
    function solveRow(l: Item[], damp: number) {
      const n = l.length;
      const cum: number[] = [0];
      for (let i = 1; i < n; i++) cum.push(cum[i - 1] + sepOf(l[i - 1], l[i]));
      const y = l.map((it, i) => it.t - cum[i]);
      const w = l.map((it) => Math.max(it.wt, 0.02));
      const z = pav(y, w);
      l.forEach((it, i) => { it.x = it.x + damp * (z[i] + cum[i] - it.x); });
    }
    function applyOrient() {
      for (const it of itemOfUnit.values()) {
        const u = it.u!;
        if (u.order.length < 2) continue;
        const a = orientCost(it, false);
        const b = orientCost(it, true);
        if (b + 1 < a) u.order = u.order.slice().reverse();
      }
    }

    // ---- état initial : tri par barycentre des parents, de haut en bas
    type Snap = { orders: Item[][]; xs: Map<Item, number>; uo: Map<Unit, string[]>; cost: number; cross: number; len: number; longE: [string, string][]; hits: number };
    const snap = (ev: ReturnType<typeof evaluate>): Snap => {
      const xs = new Map<Item, number>();
      rowsArr.forEach((l) => l.forEach((it) => xs.set(it, it.x)));
      const uo = new Map<Unit, string[]>();
      units.forEach((u) => uo.set(u, u.order.slice()));
      return { orders: rowsArr.map((l) => l.slice()), xs, uo, ...ev };
    };
    const restore = (s: Snap) => {
      s.orders.forEach((l, i) => { rowsArr[i].length = 0; l.forEach((it) => rowsArr[i].push(it)); });
      s.xs.forEach((x, it) => (it.x = x));
      s.uo.forEach((ord, u) => (u.order = ord.slice()));
    };

    let seed = 987654321;
    const rnd = () => { seed = (seed * 1664525 + 1013904223) % 4294967296; return seed / 4294967296; };
    let best: Snap | null = null;
    const initKey = (it: Item, noise: number): number => {
      const pl = pullsOf(it);
      const base = pl.length ? pl.reduce((s, p) => s + p.v * p.w, 0) / pl.reduce((s, p) => s + p.w, 0) : it.x;
      return base + (rnd() - 0.5) * noise;
    };
    const total = Math.max(1000, budgetMs);
    for (let attempt = 0; attempt < 1; attempt++) {
      const noise = attempt === 0 ? 0 : 400 + (attempt % 12) * 120;
      // départ : lignes triées de haut en bas
      rowsArr.forEach((l, ri) => {
        if (attempt === 0 || ri === 0) {
          l.sort((a, b) => {
            const ba = a.kind === "u" ? (a.u!.year ?? 1e9) : 1e9;
            const bb = b.kind === "u" ? (b.u!.year ?? 1e9) : 1e9;
            return ba - bb || nameOf(a.u?.order[0] || "").localeCompare(nameOf(b.u?.order[0] || ""));
          });
        } else {
          l.forEach((it) => (it.t = initKey(it, noise)));
          l.sort((a, b) => a.t - b.t);
        }
        pack(l);
        if (ri > 0) {
          l.forEach((it) => { const pl = pullsOf(it); it.t = pl.length ? pl.reduce((s, p) => s + p.v * p.w, 0) / pl.reduce((s, p) => s + p.w, 0) : it.x; });
          l.sort((a, b) => a.t - b.t);
          pack(l);
          l.forEach((it) => { const pl = pullsOf(it); it.t = pl.length ? pl.reduce((s, p) => s + p.v * p.w, 0) / pl.reduce((s, p) => s + p.w, 0) : it.x; it.wt = 1; });
          solveRow(l, 1);
        }
      });
      // balayages
      const sweeps = 46;
      const reorderUntil = 22;
      for (let k = 0; k < sweeps; k++) {
        const down = k % 2 === 0;
        const idxs = rowsArr.map((_l, i) => i);
        if (!down) idxs.reverse();
        for (const ri of idxs) {
          const l = rowsArr[ri];
          for (const it of l) {
            const pl = pullsOf(it);
            const sw = pl.reduce((s, p) => s + p.w, 0);
            it.t = sw ? pl.reduce((s, p) => s + p.v * p.w, 0) / sw : it.x;
            it.wt = sw;
          }
          if (k < reorderUntil) {
            const nz = noise * 0.15 * (1 - k / reorderUntil);
            const keys = new Map<Item, number>(l.map((it) => [it, it.t + (nz ? (rnd() - 0.5) * nz : 0)] as [Item, number]));
            l.sort((a, b) => keys.get(a)! - keys.get(b)!);
          }
          solveRow(l, k < reorderUntil ? 0.75 : 0.5);
          if (k < sweeps - 2) { /* orientation recalculée après chaque ligne */ }
        }
        applyOrient();
        if (k >= reorderUntil - 1 && (k % 2 === 1)) {
          const ev = evaluate();
          if (!best || ev.cost < best.cost) best = snap(ev);
        }
      }
      if (Date.now() - tStart > total * 0.3) break;
      if (best && best.cross === 0 && best.hits === 0 && best.longE.length === 0 && attempt >= 1) break;
    }
    if (best) restore(best);

    // ---- recuit simulé sur l'ORDRE des éléments de chaque ligne.
    // La note ne dépend que de l'ordre (donc très rapide à recalculer) : nombre de
    // croisements entre traits de deux lignes voisines + un petit terme de longueur.
    {
      type End = { it: Item; mem: string[] };
      type Seg = { top: End; bot: End };
      const pairSegs: Seg[][] = rowsArr.map(() => []);
      const endOf = (it: Item, mem: string[]): End => ({ it, mem });
      for (const e of edges) {
        const c = e.child;
        const ps = e.parents.filter((p) => rowOfP(p) === e.pRow);
        if (!ps.length) continue;
        const startMem: string[] = ps.length === 2 && spo(ps[0]).includes(ps[1]) ? [ps[0], ps[1]] : ps;
        const startItem = itemOfUnit.get(unitOf.get(ps[0])!)!;
        const chain: End[] = [endOf(startItem, startMem), ...e.dummies.map((d) => endOf(d, [])), endOf(itemOfUnit.get(unitOf.get(c)!)!, [c])];
        const r0 = rowIndexOfItem.get(startItem)!;
        for (let i = 0; i + 1 < chain.length; i++) {
          if (rowIndexOfItem.get(chain[i + 1].it) !== r0 + i + 1) break; // cas dégénéré (parenté circulaire)
          pairSegs[r0 + i].push({ top: chain[i], bot: chain[i + 1] });
        }
        // parents mariés ailleurs / non mariés entre eux : un trait par parent supplémentaire
        if (startMem.length === 1 && ps.length > 1) {
          for (const p of ps.slice(1)) {
            const pi = itemOfUnit.get(unitOf.get(p)!)!;
            if (rowIndexOfItem.get(chain[1].it) === rowIndexOfItem.get(pi)! + 1) pairSegs[rowIndexOfItem.get(pi)!].push({ top: endOf(pi, [p]), bot: chain[1] });
          }
        }
      }
      const rowIdx = new Map<Item, number>();
      const reindex = (ri: number) => rowsArr[ri].forEach((it, i) => rowIdx.set(it, i));
      rowsArr.forEach((_l, ri) => reindex(ri));
      const KEY = 2000;
      const slotOf = (en: End) => {
        if (!en.mem.length || en.it.kind !== "u") return 0;
        const u = en.it.u!;
        const n = u.order.length;
        return en.mem.reduce((s0, m) => s0 + u.order.indexOf(m), 0) / en.mem.length - (n - 1) / 2;
      };
      const keyOf = (en: End, ri: number) => (rowIdx.get(en.it)! - (rowsArr[ri].length - 1) / 2) * KEY + slotOf(en) * (KEY * 0.22);
      const pairCost = (ri: number): number => {
        if (ri < 0 || ri >= pairSegs.length) return 0;
        const ss = pairSegs[ri];
        const m = ss.length;
        if (!m) return 0;
        const tk = new Array<number>(m);
        const bk = new Array<number>(m);
        let len = 0;
        for (let i = 0; i < m; i++) {
          tk[i] = keyOf(ss[i].top, ri);
          bk[i] = keyOf(ss[i].bot, ri + 1);
          len += Math.abs(tk[i] - bk[i]);
        }
        let x = 0;
        for (let i = 0; i < m; i++) for (let j = i + 1; j < m; j++) {
          if ((tk[i] - tk[j]) * (bk[i] - bk[j]) < 0) x++;
        }
        return x * 100 + len * 0.004;
      };
      const pc = rowsArr.map((_l, ri) => pairCost(ri));
      let curC = pc.reduce((a, b) => a + b, 0);
      const movable = rowsArr.map((_l, ri) => ri).filter((ri) => rowsArr[ri].length > 1 || rowsArr[ri].some((it) => it.kind === "u" && it.u!.order.length > 1));
      let bestC = curC;
      let bestSnap = snap(evaluate());
      const CYCLES = 4;
      const perCycle = (total * 0.55) / CYCLES;
      for (let cycle = 0; cycle < CYCLES; cycle++) {
        if (cycle > 0) {
          restore(bestSnap);
          rowsArr.forEach((_l, ri) => reindex(ri));
          for (let ri = 0; ri < pc.length; ri++) pc[ri] = pairCost(ri);
          curC = pc.reduce((a, b) => a + b, 0);
        }
        const saEnd = Date.now() + perCycle;
        const T0 = cycle === 0 ? 60 : 25;
        let iter = 0;
        const maxIter = 600000;
        const t1 = Date.now();
        while (movable.length && Date.now() < saEnd && iter < maxIter) {
          iter++;
          const frac = Math.min(1, (Date.now() - t1) / Math.max(1, saEnd - t1));
          const T = T0 * Math.pow(1 - frac, 2) + 0.5;
          const ri = movable[Math.floor(rnd() * movable.length)];
          const l = rowsArr[ri];
          const mv = rnd();
          let undo: () => void;
          if (mv < 0.12 && l.some((it) => it.kind === "u" && it.u!.order.length > 1)) {
            const cands = l.filter((it) => it.kind === "u" && it.u!.order.length > 1);
            const it = cands[Math.floor(rnd() * cands.length)];
            it.u!.order.reverse();
            undo = () => it.u!.order.reverse();
          } else if (l.length > 1) {
            const i = Math.floor(rnd() * l.length);
            let j: number;
            if (mv < 0.35) j = Math.min(l.length - 1, Math.max(0, i + (rnd() < 0.5 ? -1 : 1)));
            else if (mv < 0.85) j = Math.min(l.length - 1, Math.max(0, i + Math.round((rnd() - 0.5) * 16)));
            else j = Math.floor(rnd() * l.length);
            if (j === i) continue;
            const moved = l.splice(i, 1)[0];
            l.splice(j, 0, moved);
            reindex(ri);
            undo = () => { const x2 = l.splice(j, 1)[0]; l.splice(i, 0, x2); reindex(ri); };
          } else continue;
          const a = pairCost(ri - 1);
          const b = pairCost(ri);
          const delta = a + b - (ri > 0 ? pc[ri - 1] : 0) - pc[ri];
          if (delta <= 0 || rnd() < Math.exp(-delta / T)) {
            if (ri > 0) pc[ri - 1] = a;
            pc[ri] = b;
            curC += delta;
            if (curC < bestC - 1e-9) {
              bestC = curC;
              bestSnap = snap({ cost: 0, cross: 0, len: 0, longE: [], hits: 0 });
            }
          } else undo();
        }
      }
      restore(bestSnap);
    }
    // alignement exact des familles à enfant unique : pas de virage inutile (demande de
    // Martin). D'abord de bas en haut (un parent qui n'a qu'un enfant se place pile
    // au-dessus de lui), puis de haut en bas (un enfant unique se place pile sous le
    // milieu de ses parents). Les voisins limitent le déplacement (jamais de chevauchement).
    const clampTo = (l: Item[], i: number, want: number) => {
      const it = l[i];
      const lo = i > 0 ? l[i - 1].x + sepOf(l[i - 1], it) : -Infinity;
      const hi = i + 1 < l.length ? l[i + 1].x - sepOf(it, l[i + 1]) : Infinity;
      it.x = Math.min(hi, Math.max(lo, want));
    };
    const align = (reps: number) => {
    for (let rep = 0; rep < reps; rep++) {
      for (let ri = rowsArr.length - 1; ri >= 0; ri--) {
        const l = rowsArr[ri];
        for (let i = 0; i < l.length; i++) {
          const it = l[i];
          if (it.kind !== "u") continue;
          const u = it.u!;
          const mine = new Set<Edge>();
          u.order.forEach((m) => (edgesOfParent.get(m) || []).forEach((ed) => mine.add(ed)));
          if (mine.size !== 1) continue;
          const ed = Array.from(mine)[0];
          if (ed.dummies.length || !only(ed) || !ed.parents.every((q) => unitOf.get(q) === u)) continue;
          const pointOff = ed.parents.reduce((sum, q) => sum + offOf(u, q), 0) / ed.parents.length;
          clampTo(l, i, cardX(ed.child) - pointOff);
        }
      }
      for (const l of rowsArr) {
        for (let i = 0; i < l.length; i++) {
          const it = l[i];
          if (it.kind !== "u") continue;
          const u = it.u!;
          const bloods = u.order.filter((m) => edgesOfChild.has(m));
          if (bloods.length !== 1) continue;
          const e = edgesOfChild.get(bloods[0])!;
          if (e.dummies.length || !only(e)) continue;
          clampTo(l, i, parentPoint(e) - offOf(u, bloods[0]));
        }
      }
    }
    };
    const settle = (n: number) => {
      for (let k = 0; k < n; k++) {
        const down = k % 2 === 0;
        const idxs = rowsArr.map((_l, i) => i);
        if (!down) idxs.reverse();
        for (const ri of idxs) {
          const l = rowsArr[ri];
          for (const it of l) {
            const pl = pullsOf(it);
            const sw = pl.reduce((s, p) => s + p.w, 0);
            it.t = sw ? pl.reduce((s, p) => s + p.v * p.w, 0) / sw : it.x;
            it.wt = sw;
          }
          solveRow(l, 0.6);
        }
      }
      align(2);
    };
    settle(12);
    // recherche locale : échanger deux voisins d'une ligne, ou retourner un couple,
    // et ne garder que ce qui améliore (croisements, longueur des traits)
    {
      let cur = snap(evaluate());
      const deadline = tStart + total;
      let improved = true;
      for (let pass = 0; pass < 30 && improved && Date.now() < deadline; pass++) {
        improved = false;
        for (let ri = 0; ri < rowsArr.length && Date.now() < deadline; ri++) {
          const l = rowsArr[ri];
          for (let i = 0; i < l.length; i++) {
            for (let d = -6; d <= 6; d++) {
              const j = i + d;
              if (d === 0 || j < 0 || j >= l.length) continue;
              const it = l.splice(i, 1)[0];
              l.splice(j, 0, it);
              pack(l);
              settle(4);
              const ev2 = evaluate();
              if (ev2.cost < cur.cost - 1) { cur = snap(ev2); improved = true; break; }
              restore(cur);
            }
          }
          for (const it of l) {
            if (it.kind !== "u" || it.u!.order.length < 2) continue;
            it.u!.order.reverse();
            settle(6);
            const ev2 = evaluate();
            if (ev2.cost < cur.cost - 1) { cur = snap(ev2); improved = true; } else restore(cur);
          }
        }
      }
      restore(cur);
    }
    settle(80);
    align(6);
    const ev = evaluate();
    const cx = new Map<string, number>();
    const row = new Map<string, number>();
    units.forEach((u) => u.order.forEach((m) => { cx.set(m, cardX(m)); row.set(m, u.row); }));
    return { cx, row, cross: ev.cross, hits: ev.hits, edges: edges.length, len: ev.len, longE: ev.longE };
  }

  // ---- calcul de chaque composante, puis alignement côte à côte
  const order = comps
    .map((ids, i) => ({ ids, i, y: Math.min(...ids.map((id) => birth(id) ?? 1e9)) }))
    .sort((a, b) => b.ids.length - a.ids.length || a.y - b.y);
  const outs: { out: CompOut; ids: string[] }[] = [];
  order.forEach((c) => {
    const left = Math.max(300, budget - (Date.now() - t00));
    const share = c.ids.length > 6 ? left * Math.min(1, c.ids.length / Math.max(1, nodes.length)) + 400 : 200;
    outs.push({ out: layoutComp(c.ids, share), ids: c.ids });
  });
  const pos = new Map<string, { x: number; y: number }>();
  let cursor = 0;
  let cross = 0;
  let hitsN = 0;
  let edgesN = 0;
  let len = 0;
  const longAll: [string, string][] = [];
  let minRow = Infinity;
  outs.forEach(({ out }) => out.row.forEach((r) => { minRow = Math.min(minRow, r); }));
  outs.forEach(({ out, ids }) => {
    const xs = ids.map((id) => out.cx.get(id)!);
    const lo = Math.min(...xs) - CW / 2;
    const hi = Math.max(...xs) + CW / 2;
    const shift = cursor - lo;
    ids.forEach((id) => pos.set(id, { x: Math.round(out.cx.get(id)! + shift - CW / 2), y: Math.round((out.row.get(id)! - minRow) * rowH) }));
    cursor += hi - lo + 700;
    cross += out.cross;
    hitsN += out.hits;
    edgesN += out.edges;
    len += out.len;
    longAll.push(...out.longE);
  });
  const rowSet = new Set<number>();
  outs.forEach(({ out }) => out.row.forEach((r) => rowSet.add(r)));
  return { pos, stats: { crossings: cross, cardHits: hitsN, longEdges: longAll.length, edges: edgesN, totalLen: Math.round(len), rows: rowSet.size }, longEdgeIds: longAll };
}
