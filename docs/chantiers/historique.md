# Chantier « historique » (carte historique) — journal

## Dernières nouvelles (la plus récente en haut)
- 2026-10-23 — chantier créé (séparé de « carte » à la demande de Martin) ; journal créé ; aucun code touché. Prochaine étape : état des lieux de la carte historique actuelle et recueil de ce que Martin veut construire.

## État de départ (lu dans le code, non encore testé en ligne)
- `src/historicalMap.ts` (310 lignes) : page plein écran avec sa propre carte Leaflet, données « historical-basemaps »
  (GPL-3.0), **54 années fixes** de -123000 à 2010 (pas de curseur continu), GeoJSON chargés à la volée depuis
  raw.githubusercontent.com (« version test » validée par Martin le 2026-10-06), fond physique Esri sans frontières modernes.
- Table `schema_v20.sql` : correspondance territoire historique → fiche, conçue pour l'ancienne source OpenHistoricalMap ;
  usage actuel à vérifier.
- Prochaine migration de ce chantier : **historique_v1** (`supabase/historique/historique_v1.sql`).
