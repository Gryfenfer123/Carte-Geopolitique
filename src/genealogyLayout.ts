// Mise en page automatique d'un arbre généalogique, selon une ÉCHELLE DE DATES
// (demande de Martin, 2026-10-22) :
//  - hauteur d'une carte = fonction de l'année de naissance (`yearToY`), avec
//    au minimum une génération sous les parents ;
//  - un couple est sur la même ligne ; les deux époux sont assez écartés pour
//    que les traits partant du milieu de leur lien de mariage descendent dans
//    l'espace libre entre eux (jamais à travers une carte) ;
//  - les enfants sont symétriques autour de ce milieu ; le conjoint d'un enfant
//    se place du côté opposé aux parents ;
//  - les branches sont serrées au plus près (aucun chevauchement) ;
//  - l'ordre des frères et sœurs est optimisé pour que les mariages entre deux
//    branches du même arbre (cousins) tombent côte à côte.
// Fonction pure (aucun accès réseau/DOM) pour pouvoir être testée seule.

export type LayoutNode = { id: string; birth: number | null; death: number | null; name?: string; female?: boolean };
export type LayoutRel = { a: string; b: string; type: string };
export type LayoutOptions = {
  cardW: number;
  cardH: number;
  originYear: number;
  pxPerYear: number;
  minGen: number; // écart vertical minimum parent -> enfant
  stdGen: number; // écart par défaut quand les dates sont inconnues
  localIds: Set<string>; // membres de l'arbre ouvert : racines prioritaires
};
export type Pos = { x: number; y: number };

export function yearToY(year: number, o: Pick<LayoutOptions, "originYear" | "pxPerYear">): number {
  return (year - o.originYear) * o.pxPerYear;
}

// Deviner si un membre est une femme (aucun champ "sexe" en base) : titre
// féminin (Électrice, Reine, Margravine…) ou prénom féminin courant.
const FEM_TITLE = /(trice|ine\b|esse\b|\breine\b|impératrice|princesse|duchesse|comtesse|dame\b|abbesse|électrice|épouse|régente)/i;
const FEM_NAME =
  /^(élisabeth|elisabeth|marguerite|anne|catherine|sophie|madeleine|marie|sabine|béatrice|hedwige|dorothée|louise|augusta|frédérique|christiane|cécilie|victoria|jutta|mathilde|agnès|sidonie|amélie|carola|constance|jeanne|isabelle|éléonore|charlotte|wilhelmine|claire|bertha|berthe|gisèle|judith|ingeborg|cunégonde|gertrude|adélaïde|agnes|hélène|juliane|ulrike|bona|barbara|marthe|sibylle|ursule|henriette|thérèse|alexandrine|auguste-victoria|élise|emma|eve|ève|hedwig|kunigunde|kunégonde|luitgarde|richilde|rixa|salomé|sigrid|théodora|zoé)(\b|-)/i;
export function guessFemale(name: string | null | undefined, title: string | null | undefined): boolean | undefined {
  if (title && FEM_TITLE.test(title)) return true;
  const n = (name || "").trim();
  if (FEM_NAME.test(n)) return true;
  return undefined;
}

type Rect = { x: number; y: number }; // x = centre (relatif à l'origine du bloc), y = haut de la carte (absolu)
type Block = {
  main: string;
  y: number;
  row: string[];
  offs: number[];
  kids: Block[];
  kidOrigins: number[];
  rects: Rect[];
  min: number;
  max: number;
};
type Hints = { order: Map<string, string[]>; claims: Set<string> }; // ordre des enfants par principal ; membres rattachés à leur conjoint

const SG = 50; // marge horizontale minimale entre deux cartes

export function computeLayout(nodes: LayoutNode[], rels: LayoutRel[], o: LayoutOptions): Map<string, Pos> {
  const CW = o.cardW;
  const CH = o.cardH;
  const S = CW + 40; // pas entre deux conjoints collés
  const byId = new Map(nodes.map((n) => [n.id, n]));
  const parentsOf = new Map<string, string[]>();
  const childrenOf = new Map<string, string[]>();
  const spouses = new Map<string, Set<string>>();
  const husbandOf = new Map<string, boolean>();
  const add = <T,>(m: Map<string, T[]>, k: string, v: T) => {
    const l = m.get(k) || [];
    if (!l.includes(v)) l.push(v);
    m.set(k, l);
  };
  const spouseLinks: [string, string][] = [];
  const parentLinks: [string, string][] = [];
  rels.forEach((r) => {
    if (!byId.has(r.a) || !byId.has(r.b) || r.a === r.b) return;
    if (r.type === "parent") {
      add(childrenOf, r.a, r.b);
      add(parentsOf, r.b, r.a);
      parentLinks.push([r.a, r.b]);
    } else if (r.type === "spouse") {
      if (!spouses.has(r.a)) spouses.set(r.a, new Set());
      if (!spouses.has(r.b)) spouses.set(r.b, new Set());
      spouses.get(r.a)!.add(r.b);
      spouses.get(r.b)!.add(r.a);
      husbandOf.set(r.a, true);
      spouseLinks.push([r.a, r.b]);
    }
  });
  const isFemale = (id: string): boolean | undefined => byId.get(id)?.female;
  const birth = (id: string) => byId.get(id)?.birth ?? null;
  const sortByBirth = (ids: string[]) =>
    ids.slice().sort((x, y) => (birth(x) ?? 1e9) - (birth(y) ?? 1e9) || (byId.get(x)?.name || "").localeCompare(byId.get(y)?.name || ""));
  const hasParents = (id: string) => (parentsOf.get(id) || []).length > 0;
  const dateY = (yr: number) => yearToY(yr, o);

  function partnersOf(p: string): string[] {
    const set = new Set<string>(spouses.get(p) || []);
    (childrenOf.get(p) || []).forEach((c) => (parentsOf.get(c) || []).forEach((q) => { if (q !== p) set.add(q); }));
    return sortByBirth(Array.from(set));
  }
  const meanBirth = (ids: string[]) => {
    const ys = ids.map(birth).filter((v): v is number => v != null);
    return ys.length ? ys.reduce((s, v) => s + v, 0) / ys.length : null;
  };

  // Place les blocs côte à côte, le plus serré possible (sans chevauchement).
  function packOrigins(blocks: Block[], minStep: number): number[] {
    const origins: number[] = [];
    blocks.forEach((b, i) => {
      if (i === 0) {
        origins.push(0);
        return;
      }
      let need = origins[i - 1] + minStep;
      for (let k = 0; k < i; k++) {
        for (const a of blocks[k].rects) {
          for (const c of b.rects) {
            if (Math.abs(a.y - c.y) < CH + 40) need = Math.max(need, origins[k] + a.x - c.x + CW + SG);
          }
        }
      }
      origins.push(need);
    });
    return origins;
  }

  function run(hints: Hints) {
    const claims = hints.claims;
    const placed = new Set<string>();
    const used = new Map<string, string[]>();

    function block(p: string, dir: number, y: number): Block {
      placed.add(p);
      const partners = partnersOf(p).filter((q) => !placed.has(q) && (!hasParents(q) || !hasParents(p) || !o.localIds.has(q) || claims.has(q)));
      const via: number[] = partners.map(() => -1); // indice du partenaire par lequel un autre conjoint est rattaché
      for (let i = 0; i < partners.length; i++) {
        partnersOf(partners[i]).forEach((r) => {
          if (r !== p && !placed.has(r) && !partners.includes(r) && (!hasParents(r) || !o.localIds.has(r) || claims.has(r))) {
            partners.push(r);
            via.push(via[i] >= 0 ? via[i] : i);
          }
        });
      }
      partners.forEach((q) => placed.add(q));
      const wifeFirst = (id: string) => isFemale(id) ?? (husbandOf.get(id) ? false : undefined);
      const pf = wifeFirst(p);
      const principalIsWife =
        partners.length > 0 &&
        (pf === true ? partners.every((q) => wifeFirst(q) !== true) : pf === undefined ? partners.every((q) => wifeFirst(q) === false) : false);
      const sides: number[] = [];
      const directIdx = partners.map((_q, i) => i).filter((i) => via[i] < 0);
      partners.forEach((_q, i) => {
        if (via[i] >= 0) sides.push(0); // fixé plus bas (même côté que le partenaire d'attache)
        else if (directIdx.length >= 2) sides.push(directIdx.indexOf(i) === 0 ? -1 : 1);
        else if (dir !== 0) sides.push(dir);
        else sides.push(principalIsWife ? -1 : 1);
      });
      partners.forEach((_q, i) => { if (via[i] >= 0) sides[i] = sides[via[i]]; });
      // enfants par partenaire
      const kidGroups: string[][] = partners.map(() => []);
      const soloKids: string[] = [];
      const allKidIds: string[] = [];
      [p, ...partners].forEach((r) => (childrenOf.get(r) || []).forEach((c) => { if (!allKidIds.includes(c) && !placed.has(c)) allKidIds.push(c); }));
      const hint = hints.order.get(p);
      const ordered = hint
        ? [...hint.filter((c) => allKidIds.includes(c)), ...sortByBirth(allKidIds.filter((c) => !hint.includes(c)))]
        : sortByBirth(allKidIds);
      ordered.forEach((c) => {
        const ps = parentsOf.get(c) || [];
        const cand = partners.map((q, ix) => (ps.includes(q) ? ix : -1)).filter((ix) => ix >= 0);
        const j = ps.includes(p) ? cand.find((ix) => via[ix] < 0) ?? -1 : cand.length ? cand[cand.length - 1] : -1;
        if (j >= 0) kidGroups[j].push(c);
        else soloKids.push(c);
      });
      if (partners.length) kidGroups[0] = [...kidGroups[0], ...soloKids];
      const order = partners.map((_q, j) => j).sort((x, y2) => sides[x] - sides[y2] || x - y2);
      const plan: { j: number; c: string }[] = [];
      if (partners.length) order.forEach((j) => kidGroups[j].forEach((c) => plan.push({ j, c })));
      else soloKids.forEach((c) => plan.push({ j: 0, c }));
      used.set(p, plan.map((e) => e.c));
      const mb = meanBirth(plan.map((e) => e.c));
      const ky = plan.length ? Math.max(y + o.minGen, mb != null ? dateY(mb) : y + o.stdGen) : y + o.stdGen;
      const dirOf = (i: number, n: number) => (i < (n - 1) / 2 - 0.01 ? -1 : i > (n - 1) / 2 + 0.01 ? 1 : 0);
      const kidBlocks: Block[] = [];
      const kidGroupIdx: number[] = [];
      plan.forEach(({ j, c }, i) => {
        if (placed.has(c)) return;
        kidBlocks.push(block(c, dirOf(i, plan.length), ky));
        kidGroupIdx.push(j);
      });
      const origins = kidBlocks.length ? packOrigins(kidBlocks, S) : [];
      const gIdx = partners.length ? Array.from(new Set(kidGroupIdx)) : [0];
      const groups = gIdx.map((g) => {
        const idxs = kidGroupIdx.map((v, i) => (v === g ? i : -1)).filter((i) => i >= 0);
        const first = origins[idxs[0]];
        const last = origins[idxs[idxs.length - 1]];
        return { g, idxs, ac: (first + last) / 2, span: last - first };
      }).filter((gr) => gr.idxs.length);
      const dyv = ky - (y + CH / 2); // distance verticale milieu de rangée -> haut des enfants
      const d = partners.map(() => S);
      groups.forEach((gr) => {
        if (!partners.length) return;
        const nKids = gr.idxs.length;
        // un peu d'air pour un enfant unique, plus serré pour deux
        const base = nKids === 1 ? S + 160 : nKids === 2 ? S + 40 : S + 80;
        const need = CW + 40 + (gr.span * (CH / 2)) / Math.max(dyv, CH) + 20;
        d[gr.g] = Math.max(base, need);
      });
      // positions des partenaires (directs : à d du principal ; rattachés : à d de leur partenaire d'attache)
      const xOf = (j: number): number => (via[j] >= 0 ? xOf(via[j]) + sides[j] * d[j] : sides[j] * d[j]);
      const midOf = (j: number): number => (via[j] >= 0 ? (xOf(via[j]) + xOf(j)) / 2 : xOf(j) / 2);
      // groupes d'enfants voisins : pas de chevauchement (tassement imposé)
      for (let guard = 0; guard < 8 && partners.length && groups.length >= 2; guard++) {
        const sorted = groups.slice().sort((a2, b2) => midOf(a2.g) - midOf(b2.g));
        let grew = false;
        for (let k = 0; k + 1 < sorted.length; k++) {
          const g1 = sorted[k];
          const g2 = sorted[k + 1];
          const deficit = g2.ac - g1.ac - (midOf(g2.g) - midOf(g1.g));
          if (deficit > 1e-6) {
            if (sides[g2.g] > 0 && sides[g1.g] < 0) { d[g1.g] += deficit; d[g2.g] += deficit; }
            else if (sides[g2.g] > 0) d[g2.g] += 2 * deficit;
            else d[g1.g] += 2 * deficit;
            grew = true;
          }
        }
        if (!grew) break;
      }
      const entries: { id: string; x: number }[] = [{ id: p, x: 0 }];
      partners.forEach((q, j) => entries.push({ id: q, x: xOf(j) }));
      entries.sort((a2, b2) => a2.x - b2.x);
      const rowIds: string[] = entries.map((e) => e.id);
      const rowOffs: number[] = entries.map((e) => e.x);
      const kidOrigins: number[] = origins.slice();
      groups.forEach((gr) => {
        const mid = partners.length ? midOf(gr.g) : 0;
        gr.idxs.forEach((i) => { kidOrigins[i] = origins[i] - gr.ac + mid; });
      });
      const rects: Rect[] = rowOffs.map((x) => ({ x, y }));
      kidBlocks.forEach((k, i) => k.rects.forEach((r) => rects.push({ x: r.x + kidOrigins[i], y: r.y })));
      const min = Math.min(...rects.map((r) => r.x)) - CW / 2;
      const max = Math.max(...rects.map((r) => r.x)) + CW / 2;
      return { main: p, y, row: rowIds, offs: rowOffs, kids: kidBlocks, kidOrigins, rects, min, max };
    }

    const out = new Map<string, Pos>();
    function assign(b: Block, cx: number) {
      b.row.forEach((id, i) => out.set(id, { x: cx + b.offs[i] - CW / 2, y: b.y }));
      b.kids.forEach((k, i) => assign(k, cx + b.kidOrigins[i]));
    }
    const rootY = (id: string) => {
      const ys = [id, ...partnersOf(id)].map(birth).filter((v): v is number => v != null);
      return ys.length ? dateY(ys[0]) : 0;
    };

    // 1. Racines de l'arbre ouvert
    const rootCands = sortByBirth(nodes.map((n) => n.id).filter((id) => !hasParents(id)));
    const localFirst = [...rootCands.filter((id) => o.localIds.has(id)), ...rootCands.filter((id) => !o.localIds.has(id))];
    const rootBlocks: Block[] = [];
    for (const r of localFirst) {
      if (placed.has(r)) continue;
      if (!o.localIds.has(r) && (childrenOf.get(r) || []).some((c) => placed.has(c))) continue;
      rootBlocks.push(block(r, 0, rootY(r)));
    }
    if (rootBlocks.length) {
      const ro = packOrigins(rootBlocks, 0).map((v, i) => v + i * 120);
      rootBlocks.forEach((b, i) => assign(b, ro[i]));
    }

    // 2. Ascendants des membres posés (épouses venues d'ailleurs) : au-dessus d'elles
    const overlap = (p: Pos, q: Pos) => Math.abs(p.x - q.x) < CW + 24 && Math.abs(p.y - q.y) < CH + 50;
    const free = (cand: Map<string, Pos>, dx: number) => {
      for (const [id, p] of cand) {
        const pp = { x: p.x + dx, y: p.y };
        for (const [oid, q] of out) if (oid !== id && overlap(pp, q)) return false;
      }
      return true;
    };
    const leftovers = sortByBirth(nodes.map((n) => n.id).filter((id) => !placed.has(id) && !hasParents(id)));
    for (const r of leftovers) {
      if (placed.has(r)) continue;
      const b = block(r, 0, rootY(r));
      const members = new Set<string>();
      const collect = (x: Block) => { x.row.forEach((id) => members.add(id)); x.kids.forEach(collect); };
      collect(b);
      let anchor: string | null = null;
      for (const id of members) {
        for (const c of childrenOf.get(id) || []) if (out.has(c) && !members.has(c)) { anchor = c; break; }
        if (anchor) break;
      }
      const tmp = new Map<string, Pos>();
      const saveOut = new Map(out);
      out.clear();
      assign(b, 0);
      out.forEach((v, k) => tmp.set(k, v));
      out.clear();
      saveOut.forEach((v, k) => out.set(k, v));
      let dx: number;
      let dyy = 0;
      if (anchor) {
        const ap = out.get(anchor)!;
        const parents = (parentsOf.get(anchor) || []).filter((pid) => tmp.has(pid));
        const mid = parents.length ? parents.reduce((s, pid) => s + tmp.get(pid)!.x, 0) / parents.length : 0;
        dx = ap.x - mid;
        const py = parents.length ? Math.max(...parents.map((pid) => tmp.get(pid)!.y)) : 0;
        if (py > ap.y - o.minGen) dyy = ap.y - o.minGen - py;
      } else {
        const maxX = Math.max(0, ...Array.from(out.values()).map((p) => p.x + CW));
        const minTmp = Math.min(...Array.from(tmp.values()).map((p) => p.x));
        dx = maxX + 400 - minTmp;
      }
      tmp.forEach((p, id) => tmp.set(id, { x: p.x, y: p.y + dyy }));
      let best = dx;
      if (anchor && !free(tmp, dx)) {
        best = NaN;
        for (let k = 1; k <= 400 && Number.isNaN(best); k++) {
          for (const s of [1, -1]) if (free(tmp, dx + s * k * 60)) { best = dx + s * k * 60; break; }
        }
        if (Number.isNaN(best)) best = dx;
      }
      tmp.forEach((p, id) => { if (!out.has(id)) out.set(id, { x: p.x + best, y: p.y }); });
    }

    // 3. Reste
    nodes.forEach((n) => {
      if (out.has(n.id)) return;
      const maxX = Math.max(0, ...Array.from(out.values()).map((p) => p.x + CW));
      out.set(n.id, { x: maxX + 400, y: n.birth != null ? dateY(n.birth) : 0 });
    });
    return { out, used };
  }

  // Coût d'une disposition : mariages non voisins (très pénalisés), traits
  // parent -> enfant longs, écarts à l'ordre chronologique des fratries.
  function cost(out: Map<string, Pos>, used: Map<string, string[]>): number {
    let c = 0;
    spouseLinks.forEach(([a, b]) => {
      const pa = out.get(a);
      const pb = out.get(b);
      if (!pa || !pb) return;
      const dx = Math.abs(pa.x - pb.x);
      const dy2 = Math.abs(pa.y - pb.y);
      // Mariage entre deux branches de l'arbre (les deux époux ont des parents
      // affichés) : doit tomber côte à côte. Les autres couples sont déjà collés.
      if (hasParents(a) && hasParents(b)) c += (dx > 700 ? 800 : 0) + Math.max(0, dx - 700) * 1.5 + dy2 * 2;
    });
    parentLinks.forEach(([a, b]) => {
      const pa = out.get(a);
      const pb = out.get(b);
      if (pa && pb) c += Math.abs(pa.x - pb.x) * 0.04;
    });
    used.forEach((kids) => {
      for (let i = 0; i < kids.length; i++) for (let j = i + 1; j < kids.length; j++) if ((birth(kids[i]) ?? 0) > (birth(kids[j]) ?? 0)) c += 15;
    });
    const xs = Array.from(out.values()).map((p) => p.x);
    c += (Math.max(...xs) - Math.min(...xs)) * 0.01;
    return c;
  }

  // Recherche sur l'ordre des enfants de chaque couple (recuit simulé, borné
  // en temps) : fait tomber côte à côte les mariages entre deux branches.
  let hints: Hints = { order: new Map(), claims: new Set() };
  let cur = run(hints);
  let curCost = cost(cur.out, cur.used);
  let best = { hints, run: cur, cost: curCost };
  const t0 = Date.now();
  const BUDGET = 1800;
  let seed = 12345;
  const rnd = () => {
    seed = (seed * 1664525 + 1013904223) % 4294967296;
    return seed / 4294967296;
  };
  const crossPersons = Array.from(new Set(spouseLinks.filter(([a, b]) => hasParents(a) && hasParents(b)).flatMap(([a, b]) => [a, b])));
  if (crossPersons.length) {
    const total = 6000;
    for (let it = 0; it < total && Date.now() - t0 < BUDGET; it++) {
      let h2: Hints;
      if (crossPersons.length && rnd() < 0.2) {
        const q = crossPersons[Math.floor(rnd() * crossPersons.length)];
        const cl = new Set(hints.claims);
        if (cl.has(q)) cl.delete(q);
        else cl.add(q);
        h2 = { order: hints.order, claims: cl };
      } else {
        const keys = Array.from(cur.used.keys()).filter((k) => (cur.used.get(k) || []).length >= 2);
        if (!keys.length) continue;
        const k = keys[Math.floor(rnd() * keys.length)];
        const c = (cur.used.get(k) || []).slice();
        const m = rnd();
        const i = Math.floor(rnd() * c.length);
        const j = Math.floor(rnd() * c.length);
        if (m < 0.5) [c[i], c[j]] = [c[j], c[i]];
        else if (m < 0.75) c.push(c.splice(i, 1)[0]);
        else if (m < 0.9) c.unshift(c.splice(i, 1)[0]);
        else c.reverse();
        const ord = new Map(hints.order);
        ord.set(k, c);
        h2 = { order: ord, claims: hints.claims };
      }
      const r2 = run(h2);
      const c2 = cost(r2.out, r2.used);
      const T = 600 * (1 - it / total) + 1;
      if (c2 < curCost || rnd() < Math.exp((curCost - c2) / T)) {
        hints = h2;
        cur = r2;
        curCost = c2;
        if (c2 < best.cost) best = { hints: h2, run: r2, cost: c2 };
      }
    }
    cur = best.run;
    curCost = best.cost;
  }
  const out = cur.out;

  // Recadrage : coin haut-gauche à (0, 0) (l'échelle reste la même).
  let minX = Infinity;
  let minY = Infinity;
  out.forEach((p) => { minX = Math.min(minX, p.x); minY = Math.min(minY, p.y); });
  const res = new Map<string, Pos>();
  out.forEach((p, id) => res.set(id, { x: Math.round(p.x - minX), y: Math.round(p.y - minY) }));
  return res;
}
