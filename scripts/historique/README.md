# Outils de la carte historique (chantier « historique »)

Données source : Cliopatria v0.2.1 (CC BY 4.0), voir `public/data/historique/SOURCE.md`.

| Fichier | Rôle |
|---|---|
| `preparer_cliopatria.py` | Transforme le fichier Cliopatria (172 Mo) en `public/data/historique/` (≈ 13 Mo : un index + 28 morceaux de tracés). Format décrit en tête du script. |
| `verifier_donnees.py` | Contrôle la structure des fichiers produits et, si on lui donne le fichier d'origine, la fidélité des contours (recouvrement). |
| `construire_noms_fr.py` | Construit `noms_fr.json` (noms français) à partir de `wikidata_fr_brut.json` (libellés Wikidata récupérés le 2026-10-23, positions = index dans `index.json`) et de `traductions_fr.json` (propositions à relire). Liste `EXCLUS` = libellés Wikidata hors-sujet. |
| `tester-modele.mjs` | Teste `src/historiqueModel.ts` sur les vraies données (Node 22.18+ : `node scripts/historique/tester-modele.mjs`). |

## Régénérer les données (seulement si la source change : chaque régénération alourdit l'historique Git de ~13 Mo)
```bash
git clone --depth 1 https://github.com/Seshat-Global-History-Databank/cliopatria /tmp/cliopatria
mkdir /tmp/cliopatria-data && unzip /tmp/cliopatria/cliopatria.geojson.zip -d /tmp/cliopatria-data
pip install shapely
python3 scripts/historique/preparer_cliopatria.py /tmp/cliopatria-data/<fichier>.geojson
python3 scripts/historique/verifier_donnees.py   /tmp/cliopatria-data/<fichier>.geojson
node scripts/historique/tester-modele.mjs
```
Puis mettre à jour la version dans `SOURCE.md`, dans l'en-tête de `src/historicalMap.ts` (texte de crédit) et dans le journal.
