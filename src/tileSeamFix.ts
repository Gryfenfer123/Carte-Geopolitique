// Joints visibles entre tuiles (retours de Martin, 2026-10-27 : « on voit les cases sur la carte »).
// Cause : dès que l'écran n'est pas à un facteur d'échelle entier (Windows à 125 %/150 %, zoom
// navigateur ≠ 100 %), la position de chaque tuile tombe entre deux pixels écran et une fine ligne
// apparaît entre elles. Deux ingrédients, mesurés ensemble (voir DECISIONS.md) :
//  1. chaque tuile dépasse de 2 px vers la droite et le bas et recouvre sa voisine ;
//  2. le mode de fusion `plus-lighter` que leaflet.css impose aux tuiles est désactivé : avec lui,
//     le recouvrement s'ADDITIONNE et trace des lignes CLAIRES (1,25 × la couleur) au lieu de les cacher.
// L'export PNG (compareExport.ts) garde sa propre règle `.export-tile-fix` (257 px, plus prioritaire).
import L from "leaflet";

const OVERLAP_PX = 2;

export function installTileSeamFix(): void {
  const style = document.createElement("style");
  style.textContent = ".leaflet-container img.leaflet-tile { mix-blend-mode: normal; }";
  document.head.appendChild(style);

  const proto = L.GridLayer.prototype as unknown as { _initTile: (tile: HTMLElement) => void };
  const original = proto._initTile;
  proto._initTile = function (this: L.GridLayer, tile: HTMLElement) {
    original.call(this, tile);
    const size = this.getTileSize();
    tile.style.width = size.x + OVERLAP_PX + "px";
    tile.style.height = size.y + OVERLAP_PX + "px";
  };
}
