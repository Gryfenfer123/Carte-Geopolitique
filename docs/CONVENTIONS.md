# Conventions de travail

Règles pour **toute personne ou IA** qui modifie ce dépôt. Elles existent parce que le projet est
construit par des demandes en langage courant (Martin ne programme pas) : il faut donc que le
résultat reste solide, relisable par un développeur, et que chaque session reparte du même point.

## 0. Contexte de Martin

- Martin décrit ce qu'il veut en français, sans lire le code. **Expliquer en français simple**,
  sans jargon ; dire ce qui change **pour lui** dans l'appli.
- Avant tout ce qui est difficile à annuler (suppression de données, migration SQL, changement
  de droits), **demander et attendre un accord clair**.
- Les migrations SQL sont exécutées **par Martin** dans Supabase : on ne peut pas le faire à sa place.

## 1. Avant de commencer une session

1. Lire `CLAUDE.md`, puis `docs/ARCHITECTURE.md` et `docs/DECISIONS.md`, puis `docs/CHANTIERS.md` et le journal
   de son chantier (`docs/chantiers/`). Une conversation = un chantier ; `git pull --rebase` avant chaque push.
2. Pour les frises : `docs/specs/frises-chronologiques.md` (document de référence).
3. Pour la base : `docs/BASE_DE_DONNEES.md`.
4. Vérifier l'état réel : `git log --oneline -10`, `git status`. **Ne pas se fier à un résumé de
   session** : ils vieillissent (l'ancien `PORT_STATUS` citait des fonctions déjà retirées).

## 2. Git : jamais d'envoi manuel de fichiers

- Tout passe par `git` (commit + push). **Plus aucun glisser-déposer de fichiers sur le site de
  GitHub** : c'est ainsi qu'étaient apparus des doublons « nom (1).ts » et un site resté sur une
  version périmée pendant plusieurs jours.
- Si, exceptionnellement, un envoi manuel est inévitable : vérifier d'abord que le fichier a
  exactement le bon nom (le navigateur ajoute « (1) » si un fichier de même nom existe déjà
  dans Téléchargements), puis lancer `npm run check:repo`.
- **Commits petits, un sujet par commit**, message en français qui dit **pourquoi**
  (pas seulement quoi).
- Avant un gros chantier : poser une étiquette de retour arrière
  (`git tag avant-<nom-du-chantier>` puis `git push origin avant-<nom-du-chantier>`).
- Ne jamais réécrire l'historique de `main` (pas de `push --force`).

## 3. « Terminé » veut dire « vérifié »

Avant de dire qu'un travail est fini :

```bash
npm run check:repo     # le dépôt est sain (pas de doublons, pas de secret…)
npm run build          # typage strict + construction, doit passer sans erreur
```

Puis, dans le compte rendu à Martin, **séparer ce qui a été vérifié de ce qui ne l'a pas été** :

- « Vérifié : le build passe ; j'ai ouvert la fiche X dans un vrai navigateur. »
- « **Non vérifié** : l'aspect visuel sur mobile ; l'effet réel de la migration (pas encore exécutée). »

Interdit : écrire « ça marche » après une simple relecture du code, ou affirmer un contrôle
visuel sans navigateur.

## 4. Où va le code

- **Tout le code est dans `src/`.** Rien de source à la racine (le contrôle automatique l'interdit).
- **Une fonctionnalité = un module** (`src/maFonction.ts`), branché depuis `main.ts` par une
  fonction `initMaFonctionSystem(...)`, comme les existants.
- **Ne pas agrandir les très gros fichiers** (`dossier.ts`, `genealogy.ts`, `frise.ts`, `main.ts`,
  `style.css`). Une nouvelle fonctionnalité s'écrit dans un nouveau fichier ; on ne rajoute dans
  un gros fichier que le strict nécessaire pour la brancher.
- **Logique pure à part** : les calculs (dates, mises en page, règles) vont dans un fichier sans
  DOM ni Supabase, sur le modèle de `friseModel.ts` / `genealogyLayout.ts`. C'est ce qui rend
  le code testable.
- **Minimalisme** : la solution la plus simple qui répond à la demande. Pas de « au cas où », pas
  de couche d'abstraction sans besoin actuel, pas de fonctionnalité que Martin n'a pas demandée
  (une fonctionnalité inventée au portage initial a dû être retirée).
- **Nouvelle dépendance npm** : seulement si c'est vraiment nécessaire ; la justifier dans
  `docs/DECISIONS.md`. Préférer ce que le navigateur sait déjà faire.
- Commentaires **en français**, qui expliquent le **pourquoi** et citent la demande de Martin
  avec sa date quand elle explique un choix. Pas de commentaires qui répètent le code.
- Chemins de données : `import.meta.env.BASE_URL + "data/…"`, jamais `/data/…`.

## 5. Base de données

Tout est dans `docs/BASE_DE_DONNEES.md` ; l'essentiel :

- Nouvelle migration = `supabase/<chantier>/<chantier>_vN.sql` avec **N = plus grand numéro de CE chantier + 1**
  (un compteur par chantier, voir `docs/CHANTIERS.md` ; les anciennes `schema_v1…v60` gardent leur nom),
  jamais de doublon de numéro, **idempotente**, **sans suppression de données** sans accord explicite.
  Réserver le numéro en poussant le fichier tout de suite quand plusieurs conversations travaillent en parallèle.
- **Ne jamais modifier une migration déjà exécutée** : en écrire une corrective.
- Toute nouvelle table : **RLS activée et policies écrites dans la même migration**.
- Prévenir Martin que le fichier est **à exécuter dans le SQL Editor**, et que le code qui en
  dépend ne marchera pas avant.

## 6. Sécurité

- Jamais de clé `service_role` / `sb_secret_…` dans le dépôt, ni dans une conversation. Seule la
  clé « anon » (publique par conception) est commitée.
- Tout texte riche affiché passe par `src/sanitize.ts`. **Ne jamais contourner** cette liste
  blanche, ne jamais injecter du HTML brut venant de la base ou d'un utilisateur.
- Le masquage des boutons dans le navigateur n'est **pas** une sécurité : la barrière est la RLS.

## 7. Données et sources

- Une donnée affichée vient d'une **source fiable identifiable** ; on la note (nom, année,
  couverture) à côté du fichier ou dans le commit. **On n'invente jamais de valeurs** pour
  combler un trou.
- Pas de source fiable à large couverture → on **retire** l'indicateur plutôt que d'afficher du
  vide ou de l'approximatif (4 indicateurs retirés le 2026-10-21, voir `DECISIONS.md`).
- Quand une donnée est volontairement approximative (ex. zones naturelles), c'est écrit dans le
  fichier qui la produit et dans `DECISIONS.md`.

## 8. Documentation : dans le même commit que le changement

| Si le commit… | …alors mettre à jour |
|---|---|
| ajoute/supprime un module ou change un flux | `docs/ARCHITECTURE.md` |
| ajoute une migration | `docs/BASE_DE_DONNEES.md` |
| prend ou remplace une décision | `docs/DECISIONS.md` (ajouter une ligne, ne pas réécrire l'historique) |
| change le comportement des frises | `docs/specs/frises-chronologiques.md` (validé par Martin avant) |
| change la façon de lancer/déployer | `README.md` |

Un résumé de session n'est **pas** une documentation : ce qui doit survivre va dans `docs/`.

## 9. Ce qu'il ne faut jamais faire

- Pousser du code dont le build échoue.
- Supprimer des données de la base sans accord explicite et sauvegarde.
- Modifier les droits d'accès (RLS) sans l'annoncer clairement à Martin.
- Désactiver un contrôle automatique (`check:repo`, typage strict, workflow) pour « faire passer »
  un changement : si un contrôle échoue, on corrige la cause.
- Laisser des fichiers de travail ou des copies (`… (1)`, `… copie`, `.bak`) dans le dépôt.
