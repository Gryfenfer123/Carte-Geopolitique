// Joints visibles entre tuiles (retour de Martin, 2026-10-27 : « on voit les cases sur la carte »).
// Cause : quand le navigateur / Windows est réglé sur un zoom qui n'est pas 100 % (80 %, 125 %…),
// la position de chaque tuile tombe entre deux pixels écran et le fond sombre de la carte
// apparaît en fine ligne entre elles. Correctif classique de Leaflet : chaque tuile dépasse de
// 1 px vers la droite et le bas, et recouvre donc sa voisine. Aucun effet sur le contenu des
// tuiles ; l'export PNG (compareExport.ts) garde sa propre règle `.export-tile-fix`.
import L from "leaflet";

export function installTileSeamFix(): void {
  const proto = L.GridLayer.prototype as unknown as { _initTile: (tile: HTMLElement) => void };
  const original = proto._initTile;
  proto._initTile = function (this: L.GridLayer, tile: HTMLElement) {
    original.call(this, tile);
    const size = this.getTileSize();
    tile.style.width = size.x + 1 + "px";
    tile.style.height = size.y + 1 + "px";
  };
}
