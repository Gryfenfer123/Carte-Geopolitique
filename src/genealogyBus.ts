// Tracé « en peigne » des liens parent -> enfant (demande de Martin, 2026-10-23 :
// « quand il y a 2 enfants, tu me fais des trucs pas très droits »).
// Au lieu de diagonales, chaque famille a un trait qui descend du couple (ou du
// parent), une barre horizontale commune au-dessus de ses enfants, puis une
// descente verticale vers chaque enfant. Deux familles voisines n'utilisent
// jamais la même hauteur de barre quand leurs barres se recouvriraient.
// Logique pure, sans DOM.

import type { Pt, Rect } from "./genealogyRouting";
import { countCrossings } from "./genealogyRouting";

export type BusEdge = {
  id: string;
  start: Pt; // milieu du mariage, ou bas de la carte du parent
  end: Pt; // haut de la carte de l'enfant
  group: string; // même valeur pour tous les enfants des mêmes parents
};

export type BusOptions = {
  cards: Rect[]; // toutes les cartes (pour refuser un tracé qui en traverserait une)
  above: number; // distance entre la barre la plus basse et le haut de l'enfant
  lane: number; // écart entre deux hauteurs de barre
  maxLanes: number;
};

/**
 * Renvoie, pour chaque lien dont le tracé en peigne est valable, sa ligne
 * brisée. Les liens absents du résultat (trop longs, ou qui traverseraient une
 * carte) sont à tracer autrement par l'appelant.
 */
export function planBuses(edges: BusEdge[], o: BusOptions): Map<string, Pt[]> {
  const out = new Map<string, Pt[]>();
  // une barre par (famille, hauteur d'arrivée)
  type Bar = { key: string; endY: number; x0: number; x1: number; edges: BusEdge[]; lane: number };
  const bars = new Map<string, Bar>();
  for (const e of edges) {
    if (e.end.y - e.start.y < 60) continue;
    const key = e.group + "@" + Math.round(e.end.y);
    let b = bars.get(key);
    if (!b) {
      b = { key, endY: e.end.y, x0: e.start.x, x1: e.start.x, edges: [], lane: 0 };
      bars.set(key, b);
    }
    b.edges.push(e);
    b.x0 = Math.min(b.x0, e.start.x, e.end.x);
    b.x1 = Math.max(b.x1, e.start.x, e.end.x);
  }
  // hauteurs de barre : par ligne d'arrivée, deux barres qui se recouvrent sont décalées
  const byRow = new Map<number, Bar[]>();
  bars.forEach((b) => {
    const l = byRow.get(Math.round(b.endY)) || [];
    l.push(b);
    byRow.set(Math.round(b.endY), l);
  });
  byRow.forEach((list) => {
    list.sort((a, b) => a.x0 - b.x0 || a.x1 - b.x1);
    const laneEnd: number[] = []; // x1 de la dernière barre posée sur chaque hauteur
    for (const b of list) {
      let lane = laneEnd.findIndex((x) => x < b.x0 - 24);
      if (lane < 0) { lane = laneEnd.length; laneEnd.push(b.x1); } else laneEnd[lane] = b.x1;
      b.lane = Math.min(lane, o.maxLanes - 1);
    }
  });
  bars.forEach((b) => {
    const busY = b.endY - o.above - b.lane * o.lane;
    for (const e of b.edges) {
      if (busY <= e.start.y + 10) continue; // pas la place : tracé diagonal
      const raw: Pt[] = [e.start, { x: e.start.x, y: busY }, { x: e.end.x, y: busY }, e.end];
      const pts = raw.filter((p, i) => i === 0 || Math.abs(p.x - raw[i - 1].x) > 0.5 || Math.abs(p.y - raw[i - 1].y) > 0.5);
      if (countCrossings(pts, o.cards.filter((r) => !(e.start.x > r.x + 1 && e.start.x < r.x + r.w - 1 && e.start.y > r.y + 1 && e.start.y < r.y + r.h - 1)).filter((r) => !(e.end.x > r.x && e.end.x < r.x + r.w && e.end.y >= r.y && e.end.y <= r.y + r.h + 1))) > 0) continue;
      out.set(e.id, pts);
    }
  });
  return out;
}
