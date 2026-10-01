// ---------------------------------------------------------------------------
// Pont D3 <-> Leaflet.
//
// L'artifact original dessine tout (frontières, ports, câbles, hémicycles...)
// via D3, en appelant une fonction `projection([lon, lat]) -> [x, y]` et un
// générateur de tracé `path` basés sur une projection Equal Earth fixe.
//
// Ici, `projection` et `path` sont recréés pour pointer vers la projection
// Mercator de Leaflet (celle des vraies tuiles), en suivant son zoom/pan en
// temps réel. Le reste du code D3 de l'artifact (qui ne fait qu'appeler
// `projection(...)` ou `path(...)`) peut donc être réutilisé tel quel — seule
// la "carte de fond" change.
// ---------------------------------------------------------------------------
import * as d3 from "d3";
import type L from "leaflet";

export function createGeoBridge(map: L.Map) {
  // Fonction "point" appelable directement — couvre tous les appels du code
  // source du type `projection([lon, lat])` (ports, câbles, villes, POI...).
  function projection(lonlat: [number, number]): [number, number] {
    const p = map.latLngToLayerPoint([lonlat[1], lonlat[0]] as L.LatLngTuple);
    return [p.x, p.y];
  }

  // Version "stream" pour d3.geoPath (tracés de polygones/lignes : frontières,
  // territoires contestés, contours de groupes...).
  const transform = d3.geoTransform({
    point(lon: number, lat: number) {
      const p = map.latLngToLayerPoint([lat, lon] as L.LatLngTuple);
      this.stream.point(p.x, p.y);
    },
  });
  const path = d3.geoPath(transform as unknown as d3.GeoProjection);

  return { projection, path };
}
