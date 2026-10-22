// Mise en page automatique d'un arbre généalogique, selon une ÉCHELLE DE DATES
// (demande de Martin, 2026-10-22) :
//  - hauteur d'une carte = fonction de l'année de naissance (même échelle
//    partout : `yearToY`), avec un minimum d'une génération sous les parents ;
//  - un couple est sur la même ligne (mari à gauche, épouse à droite) ;
//  - les enfants d'un couple sont sur une même ligne, centrés sous le couple
//    (un enfant unique pile entre les deux parents) ;
//  - les ascendants d'une épouse venue d'ailleurs sont posés au-dessus d'elle,
//    décalés en x s'ils gênent.
// Fonction pure (aucun accès réseau/DOM) pour pouvoir être testée seule.

export type LayoutNode = { id: string; birth: number | null; death: number | null; name?: string; female?: boolean };

// Deviner si un membre est une femme (aucun champ "sexe" en base) : titre
// féminin (Électrice, Reine, Margravine…) ou prénom féminin courant.
const FEM_TITLE = /(trice|ine\b|esse\b|\breine\b|impératrice|princesse|duchesse|comtesse|dame\b|abbesse|électrice|épouse|régente)/i;
const FEM_NAME = /^(élisabeth|elisabeth|marguerite|anne|catherine|sophie|madeleine|marie|sabine|béatrice|hedwige|dorothée|louise|augusta|frédérique|christiane|cécilie|victoria|jutta|mathilde|agnès|sidonie|amélie|carola|constance|jeanne|isabelle|éléonore|charlotte|wilhelmine|elisabeth-|claire|bertha|berthe|gisèle|judith|ingeborg|cunégonde|gertrude|adélaïde|agnes|hélène|juliane|ulrike|bona|barbara|marthe|sibylle|ursule|eléonore|henriette|thérèse|alexandrine|auguste-victoria|élise|emma|eve|ève|hedwig|kunigunde|kunégonde|luitgarde|richilde|rixa|salomé|sigrid|théodora|zoé)(\b|-)/i;
export function guessFemale(name: string | null | undefined, title: string | null | undefined): boolean | undefined {
  if (title && FEM_TITLE.test(title)) return true;
  const n = (name || "").trim();
  if (FEM_NAME.test(n)) return true;
  return undefined;
}
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

type Block = {
  main: string;
  row: string[];
  offs: number[]; // centre de chaque carte de la rangée, relatif au centre du principal
  kids: Block[];
  kidOrigins: number[]; // centre des principaux enfants, relatif au centre du principal de ce bloc
  min: number;
  max: number;
};

export function computeLayout(nodes: LayoutNode[], rels: LayoutRel[], o: LayoutOptions): Map<string, Pos> {
  const CW = o.cardW;
  const S = CW + 40; // pas entre deux conjoints
  const SG = 70; // espace entre deux familles côte à côte
  const byId = new Map(nodes.map((n) => [n.id, n]));
  const parentsOf = new Map<string, string[]>();
  const childrenOf = new Map<string, string[]>();
  const spouses = new Map<string, Set<string>>();
  const husbandOf = new Map<string, boolean>(); // id -> a été "a" (mari) d'un lien conjugal
  const isFemale = (id: string): boolean | undefined => byId.get(id)?.female;
  const add = <T,>(m: Map<string, T[]>, k: string, v: T) => {
    const l = m.get(k) || [];
    if (!l.includes(v)) l.push(v);
    m.set(k, l);
  };
  rels.forEach((r) => {
    if (!byId.has(r.a) || !byId.has(r.b) || r.a === r.b) return;
    if (r.type === "parent") {
      add(childrenOf, r.a, r.b);
      add(parentsOf, r.b, r.a);
    } else if (r.type === "spouse") {
      if (!spouses.has(r.a)) spouses.set(r.a, new Set());
      if (!spouses.has(r.b)) spouses.set(r.b, new Set());
      spouses.get(r.a)!.add(r.b);
      spouses.get(r.b)!.add(r.a);
      husbandOf.set(r.a, true);
    }
  });
  const birth = (id: string) => byId.get(id)?.birth ?? null;
  const sortByBirth = (ids: string[]) =>
    ids.slice().sort((x, y) => (birth(x) ?? 1e9) - (birth(y) ?? 1e9) || (byId.get(x)?.name || "").localeCompare(byId.get(y)?.name || ""));

  // Partenaires d'une personne : conjoints + autre parent de ses enfants.
  function partnersOf(p: string): string[] {
    const set = new Set<string>(spouses.get(p) || []);
    (childrenOf.get(p) || []).forEach((c) => (parentsOf.get(c) || []).forEach((q) => { if (q !== p) set.add(q); }));
    return sortByBirth(Array.from(set));
  }

  const placed = new Set<string>();
  const parentsBlockBirth = (ids: string[]) => {
    const ys = ids.map(birth).filter((v): v is number => v != null);
    return ys.length ? ys.reduce((s, v) => s + v, 0) / ys.length : null;
  };

  function block(p: string): Block {
    placed.add(p);
    const partners = partnersOf(p).filter((q) => !placed.has(q));
    partners.forEach((q) => placed.add(q));
    // Rangée : le mari est à gauche de l'épouse. Un principal "mari" (ou
    // sans info) a ses partenaires à droite ; une principale "épouse" a ses
    // partenaires (maris) à gauche.
    const wifeFirst = (id: string) => isFemale(id) ?? (husbandOf.get(id) ? false : undefined);
    const pf = wifeFirst(p);
    const principalIsWife =
      partners.length > 0 &&
      (pf === true ? partners.every((q) => wifeFirst(q) !== true) : pf === undefined ? partners.every((q) => wifeFirst(q) === false) : false);
    const row: string[] = [];
    const offs: number[] = [];
    if (principalIsWife) {
      partners.slice().reverse().forEach((q, i) => { row.push(q); offs.push(-S * (partners.length - i)); });
      row.push(p); offs.push(0);
    } else {
      row.push(p); offs.push(0);
      partners.forEach((q, i) => { row.push(q); offs.push(S * (i + 1)); });
    }
    const kidIds: string[] = [];
    row.forEach((r) => (childrenOf.get(r) || []).forEach((c) => { if (!kidIds.includes(c)) kidIds.push(c); }));
    const kids: Block[] = [];
    sortByBirth(kidIds).forEach((c) => { if (!placed.has(c)) kids.push(block(c)); });
    const rowMin = Math.min(...offs) - CW / 2;
    const rowMax = Math.max(...offs) + CW / 2;
    const rowMid = (Math.min(...offs) + Math.max(...offs)) / 2;
    const kidOrigins: number[] = [];
    let min = rowMin;
    let max = rowMax;
    if (kids.length) {
      let cursor = 0;
      kids.forEach((k) => {
        const origin = cursor - k.min;
        kidOrigins.push(origin);
        cursor = origin + k.max + SG;
      });
      const delta = rowMid - (kidOrigins[0] + kidOrigins[kidOrigins.length - 1]) / 2;
      for (let i = 0; i < kidOrigins.length; i++) kidOrigins[i] += delta;
      kids.forEach((k, i) => {
        min = Math.min(min, kidOrigins[i] + k.min);
        max = Math.max(max, kidOrigins[i] + k.max);
      });
    }
    return { main: p, row, offs, kids, kidOrigins, min, max };
  }

  const out = new Map<string, Pos>();
  const dateY = (yr: number) => yearToY(yr, o);

  // Pose un bloc : x = centre du principal ; y = ligne du bloc.
  function assign(b: Block, cx: number, y: number) {
    b.row.forEach((id, i) => out.set(id, { x: cx + b.offs[i] - CW / 2, y }));
    if (!b.kids.length) return;
    const gb = parentsBlockBirth(b.kids.map((k) => k.main));
    const rowYear = gb != null ? dateY(gb) : null;
    const ky = Math.max(y + o.minGen, rowYear ?? y + o.stdGen);
    b.kids.forEach((k, i) => assign(k, cx + b.kidOrigins[i], ky));
  }
  function rootY(b: Block): number {
    const years = b.row.map(birth).filter((v): v is number => v != null);
    return years.length ? dateY(years[0]) : 0;
  }

  // --- 1. Arbres issus des racines de l'arbre ouvert (priorité aux locaux) ---
  const hasParents = (id: string) => (parentsOf.get(id) || []).length > 0;
  const rootCands = sortByBirth(nodes.map((n) => n.id).filter((id) => !hasParents(id)));
  const localFirst = [...rootCands.filter((id) => o.localIds.has(id)), ...rootCands.filter((id) => !o.localIds.has(id))];
  let cursorX = 0;
  const blocksPlaced: { b: Block; cx: number }[] = [];
  for (const r of localFirst) {
    if (placed.has(r)) continue;
    if (!o.localIds.has(r) && (childrenOf.get(r) || []).some((c) => placed.has(c))) continue; // ascendance d'une épouse : étape 2
    const b = block(r);
    const cx = cursorX - b.min;
    assign(b, cx, rootY(b));
    blocksPlaced.push({ b, cx });
    cursorX = cx + b.max + 400;
  }

  // --- 2. Ascendants des membres déjà posés (épouses venues d'ailleurs) ---
  const overlap = (p: Pos, q: Pos) => Math.abs(p.x - q.x) < CW + 24 && Math.abs(p.y - q.y) < o.cardH + 50;
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
    const b = block(r);
    // enfant déjà posé dont un parent est dans ce groupe -> point d'accroche
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
    assign(b, 0, rootY(b));
    out.forEach((v, k) => tmp.set(k, v));
    out.clear();
    saveOut.forEach((v, k) => out.set(k, v));
    let dx: number;
    let dy = 0;
    if (anchor) {
      const ap = out.get(anchor)!;
      const parents = (parentsOf.get(anchor) || []).filter((pid) => tmp.has(pid));
      const mid = parents.length ? parents.reduce((s, pid) => s + tmp.get(pid)!.x, 0) / parents.length : 0;
      dx = ap.x - mid;
      const py = parents.length ? Math.max(...parents.map((pid) => tmp.get(pid)!.y)) : 0;
      if (py > ap.y - o.minGen) dy = ap.y - o.minGen - py;
    } else {
      const maxX = Math.max(0, ...Array.from(out.values()).map((p) => p.x + CW));
      const minTmp = Math.min(...Array.from(tmp.values()).map((p) => p.x));
      dx = maxX + 400 - minTmp;
    }
    tmp.forEach((p, id) => tmp.set(id, { x: p.x, y: p.y + dy }));
    // évitement des collisions : plus petit décalage horizontal libre
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

  // --- 3. Reste (composantes avec boucles / cousins non atteints) ---
  nodes.forEach((n) => {
    if (out.has(n.id)) return;
    const maxX = Math.max(0, ...Array.from(out.values()).map((p) => p.x + CW));
    out.set(n.id, { x: maxX + 400, y: n.birth != null ? dateY(n.birth) : 0 });
  });

  // Recadrage : coin haut-gauche à (0, 0) (l'échelle reste la même).
  let minX = Infinity;
  let minY = Infinity;
  out.forEach((p) => { minX = Math.min(minX, p.x); minY = Math.min(minY, p.y); });
  out.forEach((p, id) => out.set(id, { x: Math.round(p.x - minX), y: Math.round(p.y - minY) }));
  return out;
}
