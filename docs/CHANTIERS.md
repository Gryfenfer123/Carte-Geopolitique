# Chantiers : travailler à plusieurs conversations en même temps

Martin ouvre plusieurs conversations en parallèle (une par chantier). Pour qu'elles ne se marchent
pas dessus, **chaque conversation a UN chantier** et ne touche qu'à ce qui lui appartient.

## Les chantiers

| Chantier | Contenu | Code (`src/`) | Migrations | Journal du chantier |
|---|---|---|---|---|
| `arbres` | Arbres généalogiques : fonctionnalité + remplissage des dynasties + photos | `genealogy*.ts` | `supabase/arbres/arbres_vN.sql` (continue après v60 → **arbres_v61**) | [`chantiers/arbres.md`](chantiers/arbres.md) |
| `frises` | Frises chronologiques | `frise.ts`, `friseModel.ts` | `supabase/frises/frises_vN.sql` (commence à **frises_v1**) | [`chantiers/frises.md`](chantiers/frises.md) |
| `carte` | Carte, fonds, calques (ports, câbles…), carte historique, POI, exports, comparateur | `geobridge.ts`, `historicalMap.ts`, `poi.ts`, `compareExport.ts` | `supabase/carte/carte_vN.sql` (**carte_v1**) | à créer à la 1re session |
| `groupes` | Groupes géopolitiques et liens entre pays | `groups.ts`, `links.ts`, `linkIndex.ts` | `supabase/groupes/groupes_vN.sql` (**groupes_v1**) | à créer |
| `dossiers` | Fiches pays, catégories, entrées, recherche, encyclopédie | `dossier.ts`, `sanitize.ts`, `imageCrop.ts`, `search.ts`, `encyclopedie.ts`, `countryNames.ts` | `supabase/dossiers/dossiers_vN.sql` (**dossiers_v1**) | à créer |
| `indicateurs` | Indicateurs chiffrés | `indicators.ts`, `public/data/raw/OWID_*.json` | `supabase/indicateurs/indicateurs_vN.sql` (**indicateurs_v1**) | à créer |

Fichiers **partagés** (tout le monde peut avoir à y brancher une ligne, jamais plus) : `main.ts`,
`style.css`, `supabase.ts`, `index.html`. Pour une nouvelle fonctionnalité : un **nouveau fichier**
dans `src/` + une ligne de branchement dans `main.ts` (voir `CONVENTIONS.md` §4).
Nouveau chantier (ex. « historique ») : ajouter une ligne ici ET le nom dans `scripts/check-repo.mjs`.

## Noms des migrations

- **Anciennes (v1 → v60)** : `supabase/schema_vN.sql`. Elles ont déjà été exécutées ; **on ne les renomme pas**.
- **Nouvelles** : `supabase/<chantier>/<chantier>_vN.sql`, **un compteur par chantier**
  (`arbres_v61`, `arbres_v62`… ; `frises_v1`, `frises_v2`… ; `carte_v1`…). Le nom dit tout de suite à
  quel chantier le fichier appartient. `npm run check:repo` refuse un nom mal formé ou un numéro en
  double **dans le même chantier**.
- Chaque fichier indique en en-tête son **prérequis exact** (nom de fichier, ex. « arbres_v61 exécuté »).
  Un chantier ne dépend d'un autre que s'il le dit ; sinon les chantiers s'exécutent dans n'importe
  quel ordre entre eux, **mais toujours dans l'ordre des numéros à l'intérieur d'un chantier**.
- Une migration déjà exécutée n'est jamais modifiée (on en écrit une corrective).

## Règles de départ pour chaque conversation

1. `git pull` ; lire `CLAUDE.md`, ce fichier, puis le **journal de son chantier**.
2. Dire en une phrase quel chantier on prend. Ne pas toucher aux fichiers d'un autre chantier.
3. Pour une migration : prendre le **numéro suivant dans son propre chantier**, le pousser tout de
   suite (même vide, avec l'en-tête) pour le réserver.
4. `git pull --rebase` avant chaque `git push`. Jamais `push --force`. Un conflit = s'arrêter et le dire à Martin.
5. À la fin : mettre à jour le **journal du chantier** (fait / en cours / prochaine étape) et `BASE_DE_DONNEES.md`
   (une ligne par migration) **dans le même commit**.
