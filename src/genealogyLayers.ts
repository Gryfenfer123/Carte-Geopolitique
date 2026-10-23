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
export type LayersStats = { crossings: number; longEdges: number; edges: number; totalLen: number; rows: number };
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

  type CompOut = { cx: Map<string, number>; row: Map<string, number>; cross: number; edges: number; len: number; longE: [string, string][] };
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
    const rowRaw = new Map<Unit, number | null>();
    units.forEach((u) => rowRaw.set(u, u.year == null ? null : Math.round((u.year - o.originYear) / o.rowYears)));
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
          out.push({ v: a - offOf(u, m), w: 1.2 });
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
          out.push({ v, w: 1 });
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
    function evaluate(): { cost: number; cross: number; len: number; longE: [string, string][] } {
      let len = 0;
      const longE: [string, string][] = [];
      const segs = new Map<number, [number, number][]>(); // ligne -> segments [x haut, x bas]
      for (const e of edges) {
        const pts: number[] = [parentPoint(e), ...e.dummies.map((d) => d.x), cardX(e.child)];
        for (let i = 0; i + 1 < pts.length; i++) {
          const r = e.pRow + i;
          const l = segs.get(r) || [];
          l.push([pts[i], pts[i + 1]]);
          segs.set(r, l);
        }
        const dx = Math.abs(pts[0] - pts[pts.length - 1]);
        len += dx;
        if (dx > 1500) { longE.push([e.parents[0], e.child]); len += (dx - 1500) * 3; }
      }
      let cross = 0;
      segs.forEach((l) => {
        for (let i = 0; i < l.length; i++) for (let j = i + 1; j < l.length; j++) {
          if ((l[i][0] - l[j][0]) * (l[i][1] - l[j][1]) < -1e-6) cross++;
        }
      });
      return { cost: len + cross * 1500, cross, len, longE };
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
    type Snap = { orders: Item[][]; xs: Map<Item, number>; uo: Map<Unit, string[]>; cost: number; cross: number; len: number; longE: [string, string][] };
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
    for (let attempt = 0; attempt < 60; attempt++) {
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
      if (best && best.cross === 0 && best.longE.length === 0 && attempt >= 1) break;
    }
    if (best) restore(best);
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
    };
    settle(12);
    // recherche locale : échanger deux voisins d'une ligne, ou retourner un couple,
    // et ne garder que ce qui améliore (croisements, longueur des traits)
    {
      let cur = snap(evaluate());
      const deadline = tStart + total;
      let improved = true;
      for (let pass = 0; pass < 12 && improved && Date.now() < deadline; pass++) {
        improved = false;
        for (let ri = 0; ri < rowsArr.length && Date.now() < deadline; ri++) {
          const l = rowsArr[ri];
          for (let i = 0; i + 1 < l.length; i++) {
            [l[i], l[i + 1]] = [l[i + 1], l[i]];
            pack(l);
            settle(6);
            const ev2 = evaluate();
            if (ev2.cost < cur.cost - 1) { cur = snap(ev2); improved = true; } else restore(cur);
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
    settle(8);
    const ev = evaluate();
    const cx = new Map<string, number>();
    const row = new Map<string, number>();
    units.forEach((u) => u.order.forEach((m) => { cx.set(m, cardX(m)); row.set(m, u.row); }));
    return { cx, row, cross: ev.cross, edges: edges.length, len: ev.len, longE: ev.longE };
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
    edgesN += out.edges;
    len += out.len;
    longAll.push(...out.longE);
  });
  const rowSet = new Set<number>();
  outs.forEach(({ out }) => out.row.forEach((r) => rowSet.add(r)));
  return { pos, stats: { crossings: cross, longEdges: longAll.length, edges: edgesN, totalLen: Math.round(len), rows: rowSet.size }, longEdgeIds: longAll };
}
