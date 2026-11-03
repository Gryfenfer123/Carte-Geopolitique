// ---------------------------------------------------------------------------
// Frises — vue pro : rangement des événements d'une ligne (couloir) en rangées.
// Logique pure, sans DOM. Les événements les plus importants sont placés en premier ;
// ceux qui ne trouvent pas de place dans les rangées autorisées deviennent de simples
// points (ils redeviennent des cartes quand on zoome).
// ---------------------------------------------------------------------------

export type PackItem = { id: string; x: number; w: number; priority: number };
export type PackResult = { row: Map<string, number>; dots: string[]; rows: number };

/** Place chaque item dans la première rangée libre (max `cap` rangées). Priorité haute d'abord, puis de gauche à droite. */
export function packLane(items: PackItem[], cap: number, gap = 8): PackResult {
  const rows: { a: number; b: number }[][] = [];
  const row = new Map<string, number>();
  const dots: string[] = [];
  const order = [...items].sort((p, q) => q.priority - p.priority || p.x - q.x);
  for (const it of order) {
    const a = it.x;
    const b = it.x + it.w + gap;
    let placed = -1;
    for (let r = 0; r < Math.min(cap, rows.length + 1); r++) {
      const list = (rows[r] ??= []);
      if (!list.some((s) => a < s.b && b > s.a)) {
        list.push({ a, b });
        placed = r;
        break;
      }
    }
    if (placed >= 0) row.set(it.id, placed);
    else dots.push(it.id);
  }
  return { row, dots, rows: rows.length };
}

/** Nombre de rangées autorisées par couloir pour que tout tienne en hauteur (entre min et max). */
export function rowCap(availablePx: number, lanes: number, rowPx: number, min = 2, max = 7): number {
  if (lanes <= 0) return max;
  return Math.max(min, Math.min(max, Math.floor(availablePx / lanes / rowPx)));
}
