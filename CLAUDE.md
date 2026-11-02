# Carte Géopolitique — consignes pour toute session de travail

Atlas interactif du monde (carte à tuiles + dossiers par pays, groupes, indicateurs, liens,
généalogie, frises) pour les études de relations internationales de Martin.
Martin **ne programme pas** : il décrit en français, tu fais, tu expliques simplement.

## À lire d'abord (dans cet ordre)

1. `docs/ARCHITECTURE.md` — comment c'est construit, **points faibles connus**
2. `docs/DECISIONS.md` — ce qui est décidé (on n'y revient pas sans Martin)
3. `docs/CONVENTIONS.md` — **les règles de travail détaillées (obligatoires)**
4. `docs/BASE_DE_DONNEES.md` — Supabase, migrations, droits d'accès
5. `docs/CHANTIERS.md` — **quel chantier est le tien** (une conversation = un chantier) + son journal
   dans `docs/chantiers/` ; outils d'arbres : `scripts/arbres/README.md`
6. `docs/specs/frises-chronologiques.md` — si la tâche touche aux frises

## Les règles qui comptent le plus

1. **Tout le code est dans `src/`.** Rien de source à la racine.
2. **Git uniquement** : jamais d'upload manuel de fichiers sur GitHub (cause d'un incident
   de doublons « (1) » et d'un site périmé).
3. **Avant de dire « terminé »** : `npm run check:repo` puis `npm run build` doivent passer.
   Dire séparément ce qui est **vérifié** et ce qui est **non vérifié**. Jamais « ça marche »
   après simple relecture du code.
4. **Nouvelle fonctionnalité = nouveau module** ; ne pas grossir `dossier.ts`, `genealogy.ts`,
   `frise.ts`, `main.ts`, `style.css`. Logique pure dans un fichier sans DOM.
5. **Minimalisme** : pas de fonctionnalité non demandée, pas de dépendance sans justification.
6. **Migrations SQL** : `supabase/<chantier>/<chantier>_vN.sql` (un compteur par chantier, voir
   `docs/CHANTIERS.md` ; jamais de doublon), idempotente, sans suppression de données, RLS incluse ;
   **tu l'exécutes toi-même** via le connecteur Supabase (décision de Martin, 2026-11-02), tu contrôles le résultat
   dans la base, puis tu pousses sur GitHub. Martin ne copie plus rien. Les anciennes `schema_v1…v60` ne se renomment pas.
7. **Aucun secret** (`service_role`) dans le dépôt. Texte riche = toujours via `sanitize.ts`.
8. **Données — niveau de preuve maximal** : uniquement des **faits non contestés**, **recoupés par plusieurs sources indépendantes dont
   au moins une universitaire** (voir `docs/sources/README.md`, § « Barème de preuve »). Wikipédia/Wikidata = pistes, jamais preuve.
   Désaccord entre spécialistes : on suit la **convention enseignée** (en la notant) ; énorme désaccord sans convention = on n'écrit rien et on demande à Martin. Jamais de valeur inventée ou approximative : **dans le doute, on n'écrit pas** (ni en base, ni sur GitHub). Tout est sourcé dans
   `docs/sources/<chantier>.md` au moment du travail ; **rien n'est pris s'il n'est pas sourcé**.
9. **Docs dans le même commit** que le changement (`docs/`).
10. **Irréversible = demander d'abord** (suppression de données, changement de droits). Une migration non destructive s'exécute directement.

## Commandes

```bash
npm ci               # installer les dépendances (propre, reproductible)
npm run dev          # lancer en local (http://localhost:5173)
npm run check:repo   # le dépôt est-il sain ? (doublons, secrets, fichiers à la racine…)
npm run typecheck    # typage seul
npm run build        # typage strict + construction (= ce que fait le déploiement)
```

Le déploiement (GitHub Pages) est automatique à chaque push sur `main` et **bloqué** si une
vérification échoue : contrôler l'onglet Actions du dépôt après un push.

## Commits

En français, un sujet par commit, message qui explique **pourquoi**.
