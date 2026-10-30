// Fonds de carte de la carte historique (module à part, voir docs/DECISIONS.md).
// Demande de Martin (2026-10-30) : l'ancien fond (Esri « World_Physical_Map ») était « trop clair, pas joli ».
// Choix : trois fonds SANS frontières ni noms de pays modernes, sans clé d'accès, choisis dans un petit sélecteur.
//  - « Relief sombre » (défaut) : NASA Blue Marble (relief + fonds marins), légèrement assombri par un filtre CSS (voir historique.css)
//  - « Satellite sombre » : Esri World Imagery, assombri de la même façon
//  - « Physique clair » : l'ancien fond, gardé au cas où
import L from "leaflet";

export function ajouterFonds(carte: L.Map): void {
  const relief = L.tileLayer(
    "https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/BlueMarble_ShadedRelief_Bathymetry/default/GoogleMapsCompatible_Level8/{z}/{y}/{x}.jpeg",
    { maxZoom: 8, maxNativeZoom: 8, className: "fond-sombre-relief",
      attribution: 'Fond : <a href="https://earthdata.nasa.gov/gibs">NASA GIBS</a> (Blue Marble, relief et bathymétrie)' });
  const satellite = L.tileLayer(
    "https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
    { maxZoom: 8, className: "fond-sombre-satellite",
      attribution: '&copy; <a href="https://www.esri.com">Esri</a> — imagerie satellite' });
  const physique = L.tileLayer(
    "https://services.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}",
    { maxZoom: 8, attribution: '&copy; <a href="https://www.esri.com">Esri</a> — Esri, US National Park Service' });
  relief.addTo(carte);
  L.control.layers({ "Relief sombre": relief, "Satellite sombre": satellite, "Physique clair": physique }, {}, { position: "topright", collapsed: true }).addTo(carte);
}
