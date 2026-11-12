// Fond de carte de la carte historique (module à part, voir docs/DECISIONS.md).
// Demande de Martin (2026-11-01) : UN SEUL fond, précis, qui fasse bien ressortir les couleurs des territoires.
// Choix (2026-11-12, Martin) : Esri « World_Shaded_Relief » — relief ombré doux et neutre, AUCUNE
// frontière ni nom de pays modernes (les seules frontières affichées sont celles de l'époque choisie). Sans clé d'accès.
// (Historique des essais : NASA Blue Marble trop sombre, Esri Physical trop clair, CartoDB Positron exige maintenant une clé.)
import L from "leaflet";

export function ajouterFonds(carte: L.Map): void {
  L.tileLayer(
    "https://services.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer/tile/{z}/{y}/{x}",
    { maxZoom: 9, maxNativeZoom: 9,
      attribution: '&copy; <a href="https://www.esri.com">Esri</a> — Shaded Relief (Esri, USGS, NOAA)' }).addTo(carte);
}
