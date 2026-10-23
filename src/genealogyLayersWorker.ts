// Calcul de la mise en page dans un thread à part : le calcul peut durer
// plusieurs dizaines de secondes sans figer la page (demande de Martin :
// « il vaut mieux que ça prenne du temps et que ce soit vraiment bien »).
import { computeLayersLayout, type LayersOptions, type LNode, type LRel } from "./genealogyLayers";

const scope = self as unknown as { onmessage: ((e: MessageEvent) => void) | null; postMessage(m: unknown): void };
scope.onmessage = (e: MessageEvent) => {
  const { nodes, rels, opts } = e.data as { nodes: LNode[]; rels: LRel[]; opts: LayersOptions };
  const r = computeLayersLayout(nodes, rels, opts);
  scope.postMessage({ pos: Array.from(r.pos.entries()), stats: r.stats });
};
