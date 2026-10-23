# Outils de remplissage des arbres généalogiques

Générateur Python qui écrit une migration SQL (`supabase/arbres/arbres_vN.sql`) à partir d'une description lisible
d'une dynastie (membres, parents, époux). Martin exécute ensuite le fichier dans Supabase. Contexte et règles de
contenu : [`docs/chantiers/arbres.md`](../../docs/chantiers/arbres.md).

## Contenu
- `lib.py` — le générateur (`Gen`) : `g.tree()` crée un arbre, `g.m()` un membre, `g.par()` / `g.sp()` / `g.fam()` les
  liens, `g.move()` déplace un membre, `g.link_named()` relie à un membre déjà en base retrouvé par nom+année,
  `g.write()` écrit le SQL (vérifie les ids existants, refuse de s'exécuter deux fois). Identifiants **déterministes
  (uuid5)** à partir d'un code (`pl.mieszko1`) : un script peut retrouver les membres d'un script précédent.
- `data/registry.json` — **registre** : tous les membres/arbres créés par les scripts (id, code, arbre, dates) + `flags`
  (personnes placées hors de leur arbre, à signaler à Martin) + `dateflags` (dates approximatives). Mis à jour à chaque
  `g.write()` : **le committer avec la migration**.
- `data/db.json` — copie de la base **avant v39** (membres, relations, arbres existants, 23/10/2026) : sert à retrouver
  les membres préexistants (`X()`, `Xname()`, `find()`).
- `pays/gen_*.py` — les générateurs déjà utilisés (v39 → v59). **Modèles à imiter, pas à relancer** : le registre contient
  déjà leurs codes (un second passage échoue sur « code en double », exprès).
- `outils/` — `base_test.sh` (démarre une base PostgreSQL de test), `tester.sh N` (la reconstruit et applique v39→vN),
  `check.py` (contrôles de cohérence), `render*.py` + `shot.py` (images d'un arbre pour relecture), `livrer.sh`
  (doc + contrôles + commit + push), `layout_run.mjs` (positions : par défaut la mise en page « par dates » de l'appli,
  `src/genealogyLayers.ts` compilé à la volée avec rolldown ; `LAYOUT=old` pour l'ancienne), `chercher.py` (retrouver un membre
  déjà en base : `python3 scripts/arbres/outils/chercher.py "regex" ANNÉE TOL PAYS`), `doublons.py` (cherche les doublons possibles
  pour tous les nouveaux membres d'un `gen_*.py`, sans rien écrire).
- `mise-en-page-tests/` — bancs d'essai de la mise en page (voir plus bas).

## Faire un nouvel arbre (déroulé)
1. `git pull` ; numéro suivant du chantier = plus grand `arbres_vN` + 1 (pousser un fichier d'en-tête pour le réserver).
2. Copier un `pays/gen_*.py` proche, `g = Gen(N, "Pays — dynastie")`, décrire les membres (sources : pages Wikipédia, jamais
   de valeur inventée ; date inconnue = vide + `dateflags`).
3. `python3 scripts/arbres/outils/doublons.py scripts/arbres/pays/gen_xx.py` (aucun doublon ?), puis
   `python3 scripts/arbres/pays/gen_xx.py` → écrit la migration et met à jour le registre (si on relance après une erreur :
   `git checkout scripts/arbres/data/registry.json` d'abord). Outils utiles dans un script : `g.reposition = {'CLÉ'}` (remet tout l'arbre en
   ordre), `g.pin(X(..), 'CLÉ')` (affiche un membre d'un autre arbre dans celui-ci), `g.movex(X(..), 'CLÉ')` (déplace un membre existant),
   `g.xsetdates(X(..), naissance, mort)` (complète des dates vides, n'écrase jamais).
4. `bash scripts/arbres/outils/base_test.sh && bash scripts/arbres/outils/tester.sh N` pour l'essayer sur une base de test ;
   `python3 scripts/arbres/outils/check.py` (une douzaine de problèmes connus sont acceptés).
5. `bash scripts/arbres/outils/livrer.sh N "ligne de doc" "titre" "pourquoi"`.
6. Dire à Martin : fichier à exécuter dans le SQL Editor, **liste des personnes signalées**, choix pris.

## Limites à connaître
- La base de test est reconstruite depuis `data/db.json` (état avant v39) + les migrations ; elle ne contient pas les
  changements faits à la main par Martin dans l'appli depuis le 23/10. Si besoin d'un état plus récent, refaire une copie
  de la base via le navigateur de Martin (JavaScript lisant l'API Supabase en lecture) et remplacer `data/db.json`.
- Le sandbox ne peut ni joindre Supabase ni Wikimedia ; seul le navigateur de Martin (appli de bureau allumée) le peut.
- `outils/mock.py` recrée la base de test ; `psql` et PostgreSQL 16 (`/usr/lib/postgresql/16`) sont requis.

## Bancs d'essai de la mise en page
`mise-en-page-tests/` : `hab.json` (arbre Habsbourg réel, 116 liens), `run_l3.mjs`, `run_layers.mjs`, `fuzz.mjs` (graphes
aléatoires, y compris cycles), `buses.mjs` (traits en peigne). Ils importent un paquet construit à partir de `entry.ts`
(`esbuild entry.ts --bundle --format=esm --outfile=entry.mjs`, puis `layers.mjs` = même chose pour `genealogyLayers.ts`) ;
adapter les chemins d'`entry.ts` à votre copie du dépôt.
