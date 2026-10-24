# Données de la carte historique — source, licence, modifications

**Source** : Cliopatria, version 0.2.1 — base de données géospatiale des entités politiques du monde de 3400 av. J.-C.
à 2024, du projet *Seshat : Global History Databank*.
- Dépôt : https://github.com/Seshat-Global-History-Databank/cliopatria (fichier `cliopatria.geojson.zip`)
- Article : Bennett et al., *Cliopatria — A geospatial database of world-wide political entities from 3400BCE to 2024CE*,
  Scientific Data, 2025, https://doi.org/10.1038/s41597-025-04516-9
- Licence : Creative Commons Attribution 4.0 International (CC BY 4.0) — https://creativecommons.org/licenses/by/4.0/
  (fichier LICENSE.md du dépôt source). Elle impose de **citer les auteurs et la source** (fait dans la page « Vue
  historique », bas d'écran) et d'**indiquer les modifications** (ci-dessous).

**Modifications apportées** (script `scripts/historique/preparer_cliopatria.py`, contrôle `verifier_donnees.py`) :
1. On ne garde que les lignes de type POLITY dont le nom ne commence pas par « ( » ; les ensembles entre parenthèses
   (union de leurs membres) servent seulement de nom de groupe ; les lignes de type RELATION (alliances, vassalités)
   sont écartées pour l'instant.
2. Contours simplifiés (tolérance de 0,01° à 0,08° selon la taille de chaque partie) et coordonnées arrondies à
   0,01° (≈ 1 km) — recouvrement moyen avec les contours d'origine : 99 % sur un échantillon de 1 500 lignes.
3. Les tracés identiques sont stockés une seule fois ; coordonnées codées en écarts entiers ; fichiers découpés.
4. **(2026-10-24) Contours calés sur la côte réelle** (`caler_cotes.py`) : on retire ce qui est en pleine mer d'après le trait de
   côte actuel Natural Earth 1:10 m (domaine public). On ne fait que retirer, jamais ajouter ; les micro-États et archipels
   sont gardés tels quels. Limite : le trait de côte est celui d'aujourd'hui.
5. **(2026-10-24) Dates ajustées à la date historique** (`corrections_dates.py`) : les bornes de début et de fin de certaines
   entités sont avancées à leur date réelle (Wikidata P571/P576, CC0, et événements majeurs sourcés : Wikipédia). Les FORMES
   ne changent pas ; entre l'ancien instantané et la date corrigée, la forme de l'instantané voisin est affichée. Liste
   complète, avec sources et refus : `scripts/historique/corrections_dates_rapport.json` ; méthode : `docs/sources/historique.md`.
6. Hors points 4 et 5, rien n'est ajouté ni corrigé : noms, identifiants Wikipédia / Wikidata / Seshat sont ceux de la source.
   Pour retrouver les données non modifiées : régénérer sans options (`--sans-dates`, sans `--terres`).

**Avertissement des auteurs, à garder en tête** : ces cartes ne montrent qu'une version possible des territoires du
passé ; les frontières, noms, dates et durées sont souvent débattus par les historiens.

## Noms français (`noms_fr.json`, ajouté le 2026-10-23)
Les noms français viennent (1) des libellés français de **Wikidata** (données CC0, https://www.wikidata.org), repris
seulement si le libellé anglais de l'élément Wikidata correspond bien au nom de la source ; (2) à défaut, de
**traductions proposées par Claude**, signalées comme telles (champ `traduits`) et à relire. Un nom sans équivalent
reste en anglais. Outils et règles : `scripts/historique/construire_noms_fr.py`.
