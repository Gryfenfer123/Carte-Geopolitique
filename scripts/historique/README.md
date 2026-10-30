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
