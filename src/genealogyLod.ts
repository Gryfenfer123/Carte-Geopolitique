// Niveaux de détail des arbres généalogiques selon le zoom (demande de Martin,
// 2026-10-23) : de près, la carte complète ; en s'éloignant, seulement le nom et
// les dates ; de très loin, de simples blocs (seuls les personnages cerclés
// gardent leur nom) pour voir la FORME de l'arbre et ses relations.
// Logique pure : aucun accès au DOM.

export const GEN_MIN_ZOOM = 0.03; // dézoom maximal (avant : 0.25)
export const GEN_MAX_ZOOM = 2.5;
export const LOD_NAMES_BELOW = 0.34; // en dessous : nom + dates seulement
export const LOD_BLOCKS_BELOW = 0.12; // en dessous : blocs sans texte

export type GenLod = 0 | 1 | 2;

export function lodForScale(k: number): GenLod {
  if (k < LOD_BLOCKS_BELOW) return 2;
  if (k < LOD_NAMES_BELOW) return 1;
  return 0;
}
