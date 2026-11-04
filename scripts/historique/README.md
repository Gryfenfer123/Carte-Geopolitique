# Outils de la carte historique (chantier « historique »)

Données source : Cliopatria v0.2.1 (CC BY 4.0), voir `public/data/historique/SOURCE.md`.

| Fichier | Rôle |
|---|---|
| `preparer_cliopatria.py` | Transforme le fichier Cliopatria (172 Mo) en `public/data/historique/` (≈ 22 Mo : un index + une cinquantaine de morceaux de tracés). Format décrit en tête du script. |
| `caler_cotes.py` | Retire des contours ce qui est en pleine mer (trait de côte Natural Earth, option `--terres`). |
| `corrections_dates.py` + `corrections_dates_manuelles.json` + `corrections_dates_wikidata.txt` | Avance les débuts/fins d'entités à leur date historique sourcée (garde-fous : fenêtre entre deux instantanés, pas de trou, pas de doublon). Rapport : `corrections_dates_rapport.json`. |
| `audit/` | Mesures de l'audit des frontières (lecture seule) ; résultats : `docs/chantiers/historique_audit_2026-10-24.md`. |
| `verifier_donnees.py` | Contrôle la structure des fichiers produits et, si on lui donne le fichier d'origine, la fidélité des contours (recouvrement). |
| `construire_noms_fr.py` | Construit `noms_fr.json` (noms français) à partir de `wikidata_fr_brut.json` (libellés Wikidata récupérés le 2026-10-23, positions = index dans `index.json`) et de `traductions_fr.json` (propositions à relire). Liste `EXCLUS` = libellés Wikidata hors-sujet. |
| `tester-modele.mjs` | Teste `src/historiqueModel.ts` sur les vraies données (Node 22.18+ : `node scripts/historique/tester-modele.mjs`). |

## Régénérer les données (seulement si la source change : chaque régénération alourdit l'historique Git de ~13 Mo)
```bash
git clone --depth 1 https://github.com/Seshat-Global-History-Databank/cliopatria /tmp/cliopatria
mkdir /tmp/cliopatria-data && unzip /tmp/cliopatria/cliopatria.geojson.zip -d /tmp/cliopatria-data
pip install shapely
curl -L -o /tmp/terres_10m.geojson https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_10m_land.geojson
python3 scripts/historique/preparer_cliopatria.py /tmp/cliopatria-data/<fichier>.geojson public/data/historique --terres /tmp/terres_10m.geojson   # ≈ 40 min
python3 scripts/historique/verifier_donnees.py   /tmp/cliopatria-data/<fichier>.geojson
node scripts/historique/tester-modele.mjs
```
Puis mettre à jour la version dans `SOURCE.md`, dans l'en-tête de `src/historicalMap.ts` (texte de crédit) et dans le journal.

## Registre des dates
`python3 -I scripts/historique/generer_registre_dates.py <cliopatria.geojson> [dossier]` (hors ligne) relit `wikidata_dates_brut.json` et `corrections_dates_manuelles.json`, régénère `corrections_dates_wikidata.txt`, `corrections_dates_rapport.json` et `docs/sources/historique_dates_registre.csv`. Puis relancer `preparer_cliopatria.py` pour reconstruire les données.

## Chevauchements (2026-10-30)
- `audit/a4_chevauchements_corriges.py` : liste les entités qui se recouvrent encore (lecture seule). `preparer_cliopatria.py … --arret-apres-formes` écrit d'abord les contours corrigés.
- `chevauchements_table.py` (classement manuel) + `audit/chevauchements_apres_passe*.json` → `generer_decisions_chevauchements.py` → `chevauchements_decisions.json` (lu par `corrections_formes.py`) et `docs/sources/historique_chevauchements.csv`.

`--lacs <ne_10m_lakes.geojson>` : traite les lacs ≥ 1 000 km² comme de l'eau (rives suivies). Commande complète 2026-11-01 : `... --terres terres_10m.geojson --lacs lacs_10m.geojson --debut -700` (≈ 2 h 15). `parties_retirees.json` : parties de contours mal placées retirées. `audit/a5_chevauchements_donnees.py` : audit des données finales.

## Côte GSHHG et îles complétées (2026-11-02)
```bash
python3 -I gshhg_vers_terres.py <dossier gshhg res_f> /tmp/terres_gshhg.geojson 100 0.001
python3 -I preparer_cliopatria.py <cliopatria.geojson> <sortie> --terres /tmp/terres_gshhg.geojson --debut -700
```
La complétion des îles (`iles_completees.py`) est appliquée automatiquement ; rapport dans `iles_completees_rapport.json`. Mémoire : ≈ 6 Go, un processus tué fige le calcul : le relancer reprend où il en était.

## Lacs dans les pays (2026-11-03)
```bash
python3 -I gshhg_vers_terres.py <res_f> /tmp/terres_gshhg2.geojson 300000 0.001   # seule la Caspienne est retirée
python3 -I preparer_cliopatria.py <cliopatria.geojson> /tmp/s5 --terres /tmp/terres_gshhg2.geojson --debut -700
python3 -I lacs_completes.py /tmp/s5 /tmp/s7 <res_f> /tmp/terres_gshhg2.geojson 500      # ≈ 1 h
```
