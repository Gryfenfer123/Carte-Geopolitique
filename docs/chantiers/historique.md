# Chantier « historique » (carte historique) — journal

## Dernières nouvelles (la plus récente en haut)
- 2026-10-23 — étude des sources de données pour la carte historique (voir « Sources étudiées » ci-dessous) ; aucun code touché.
  Prochaine étape : télécharger et inspecter Cliopatria (champs, licence du fichier, liens avec les dynasties) puis décider avec Martin.
- 2026-10-23 — chantier créé (séparé de « carte » à la demande de Martin) ; journal créé ; aucun code touché. Prochaine étape : état des lieux de la carte historique actuelle et recueil de ce que Martin veut construire.

## État de départ (lu dans le code, non encore testé en ligne)
- `src/historicalMap.ts` (310 lignes) : page plein écran avec sa propre carte Leaflet, données « historical-basemaps »
  (GPL-3.0), **54 années fixes** de -123000 à 2010 (pas de curseur continu), GeoJSON chargés à la volée depuis
  raw.githubusercontent.com (« version test » validée par Martin le 2026-10-06), fond physique Esri sans frontières modernes.
- Table `schema_v20.sql` : correspondance territoire historique → fiche, conçue pour l'ancienne source OpenHistoricalMap ;
  usage actuel à vérifier.
- Prochaine migration de ce chantier : **historique_v1** (`supabase/historique/historique_v1.sql`).

## Sources étudiées (2026-10-23, lecture de pages web ; fichiers de données NON encore téléchargés ni inspectés)
Objectif de Martin : carte historique la plus fiable possible **et** interactive (voir à la tête de quel empire était un
dirigeant des arbres généalogiques, ce que cela représente sur la carte).

| Source | Ce qui est établi | Limites |
|---|---|---|
| historical-basemaps (aourednik, GPL-3.0) | Un GeoJSON par année fixe (54 dans notre version), champs NAME / SUBJECTO / PARTOF / BORDERPRECISION (1 approximatif → 3 fixé par le droit international), fond mondial. Les auteurs disent eux-mêmes : travail en cours, précision adaptée à l'échelle mondiale/continentale, à recouper avant usage académique ; sources par polygone non détaillées. | Pas d'identifiant d'entité stable ni de dates de début/fin par entité : relier à un dirigeant ou à une dynastie se ferait par le nom, à la main. Licence GPL-3.0 à examiner si les données sont copiées dans le dépôt. |
| Cliopatria (Seshat, Bennett et al., *Scientific Data* 2025) | Plus de 1 600–1 800 entités politiques, monde entier, 3400 av. J.-C. → 2024, GeoJSON, relecture par experts (procédure Seshat), publié sur Zenodo en CC BY 4.0 (v0.0.1, 49,2 Mo ; une version plus récente existe). Entités avec dates ; certaines liées aux pages Seshat (dirigeants, événements). | Champs exacts, qualité réelle et liens vers Wikipedia/Wikidata **non vérifiés** (pages GitHub et PMC non lues). Les auteurs reconnaissent des inexactitudes possibles. Pas de pas de temps régulier. |
| OpenHistoricalMap | Base communautaire avec vraie continuité par date ; statistiques de couverture publiques. | Jugée « incomplète niveau frontière » par Martin le 2026-10-06 ; couverture réelle non chiffrée dans ce qui a été lu. |
| Euratlas | Très précis. | Europe seulement, payant (160 € par siècle) — écarté le 2026-10-06. |

Pas étudiés pour l'instant : CShapes (frontières 1886–aujourd'hui), GeaCron (propriétaire), Chronas, Wikidata (liens dirigeants ↔ États).
