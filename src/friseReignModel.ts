// ---------------------------------------------------------------------------
// Frises — règnes : logique pure (sans DOM, sans base). Utilisée par
// friseReigns.ts (données) et friseReignsUi.ts (affichage).
// Spécification : docs/specs/frises-chronologiques.md §10 et §11.
// ---------------------------------------------------------------------------

export type ReignSource = { label: string; url: string; academic: boolean };

/**
 * Un règne est « vérifié » quand il a au moins 2 sources distinctes dont une
 * universitaire (barème de preuve : docs/sources/README.md). Sinon il est
 * affiché en pointillés, comme « à vérifier ».
 */
export function isReignVerified(sources: ReignSource[]): boolean {
  const seen = new Set<string>();
  let academic = false;
  for (const s of sources) {
    const key = (s.url || s.label).trim().toLowerCase();
    if (!key || seen.has(key)) continue;
    seen.add(key);
    if (s.academic) academic = true;
  }
  return seen.size >= 2 && academic;
}

/** Nettoie les sources lues en base (jsonb libre) : ignore ce qui n'a pas de libellé. */
export function parseSources(raw: unknown): ReignSource[] {
  if (!Array.isArray(raw)) return [];
  const out: ReignSource[] = [];
  for (const r of raw) {
    if (!r || typeof r !== "object") continue;
    const o = r as Record<string, unknown>;
    const label = typeof o.label === "string" ? o.label.trim() : "";
    if (!label) continue;
    out.push({ label, url: typeof o.url === "string" ? o.url.trim() : "", academic: o.academic === true });
  }
  return out;
}

/**
 * Répartit des intervalles [début, fin] sur le moins de rangées possible :
 * deux règnes qui se chevauchent (régence, co-règne) ne sont jamais sur la
 * même rangée. Renvoie le numéro de rangée de chaque intervalle, dans l'ordre reçu.
 */
export function assignLanes(items: { start: number; end: number }[], gap = 2): number[] {
  const order = items.map((_, i) => i).sort((a, b) => items[a].start - items[b].start || items[a].end - items[b].end);
  const laneEnd: number[] = [];
  const lanes: number[] = new Array(items.length).fill(0);
  for (const i of order) {
    let lane = laneEnd.findIndex((e) => e + gap <= items[i].start);
    if (lane < 0) {
      lane = laneEnd.length;
      laneEnd.push(items[i].end);
    } else {
      laneEnd[lane] = items[i].end;
    }
    lanes[i] = lane;
  }
  return lanes;
}
