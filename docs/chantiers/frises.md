# Chantier « frises » — journal

Spécification de référence : [`../specs/frises-chronologiques.md`](../specs/frises-chronologiques.md).

## Dernières nouvelles (la plus récente en haut)
- 2026-10-27 — aperçu de la sous-frise au survol (période ou point avec durée) : périodes + premiers points, sans ouvrir. Aucune migration. Vérifié : `check:repo`, `build`, lecture des données ; non vérifié : rendu à l'écran.
- 2026-10-23 (4) — correction : créer une période dans la frise d'un point avec durée (ex. « Guerre » 500→700) ne fait plus disparaître la durée ; les parties non couvertes restent affichées au nom du point. Vérifié : `check:repo`, `build`, calcul du découpage ; non vérifié : écran réel.
- 2026-10-23 (3) — le nom d'un point avec durée (ex. « Guerre ») est centré au milieu de la barre. Vérifié : `check:repo`, `build` ; non vérifié : rendu visuel dans le navigateur.
- 2026-10-23 (2) — « Placer sur une frise » depuis une fiche + placement automatique des fiches créées dans une période (date facultative dans « + Texte »). Étape 4 de la spec terminée, aucune migration. Vérifié : `check:repo`, `build`, test navigateur sur fausse base ; non vérifié : vraie base Supabase, mobile, parcours complet du formulaire « + Texte » en réel.
- 2026-10-23 — placements multiples (bouton « Frises » sur un point : voir / ajouter à une autre frise / retirer) + remontée sur la frise parente ; une fiche créée depuis « + Point » est rangée dans la période du point. Aucune migration. Vérifié : `check:repo`, `build`, test navigateur sur fausse base ; non vérifié : vraie base Supabase, mobile.
  Prochaine étape : « Placer sur une frise » depuis une fiche existante + placement automatique des fiches créées à la main.

## État au 2026-10-23
- **Fait** : modèle (périodes = sous-catégories, bornes partagées, trous de transition, sous-frises), interface
  (glisser/zoom, couleurs, légende, recherche, durées, export PDF/image, fiches multi-pays), rendu en tiges et
  branches colorées (côté haut/bas, empilement automatique, hauteur à la main) — migrations `schema_v27` à `schema_v31` ;
  placements multiples et remontée sur la frise parente (voir ci-dessus).
- **Reste à faire** : faire valider par Martin les choix de la spec §7bis et §9.
- Prochaine migration de ce chantier : **frises_v1** (`supabase/frises/frises_v1.sql`) — aucune écrite pour l'instant.

## Détail des livraisons

### 2026-10-23 (2) — placer une fiche existante sur une frise + placement automatique
- **Ce qui change pour Martin** : bouton « Placer sur une frise » en lisant une fiche. Dans « + Texte », choisir une période de frise comme sous-catégorie fait apparaître une date facultative ; avec une date, le point apparaît tout seul sur la frise. Date hors période : refus clair, texte conservé.
- **Code** : nouveau `src/friseAutoPlace.ts` ; petits crochets dans `dossier.ts` et `main.ts`.
- **Migration** : aucune.
- **Vérifié** : `check:repo`, `build`, typage ; Chromium + fausse base pour le dialogue ; l'appli réelle se charge, les blocs existent, aucune erreur JavaScript.
- **Non vérifié** : vraie base Supabase ; mobile ; création d'une fiche de bout en bout via le vrai formulaire.

### 2026-10-23 — placements multiples et remontée sur la frise parente
- **Ce qui change pour Martin** : sur la carte d'un point (clic), un bouton « Frises » montre les frises où le point
  apparaît, permet de l'ajouter à une autre frise (recherche par titre) ou de l'en retirer, et — dans une sous-frise —
  de l'afficher aussi sur la frise parente. « Voir sur la frise » depuis une fiche propose la liste quand le point est
  sur plusieurs frises. Une fiche créée depuis « + Point » est maintenant rangée dans la sous-catégorie de la période
  du point (avant : dans le dossier de la frise).
- **Code** : nouveaux `src/friseEvents.ts`, `src/friseMulti.ts` (+ `.css`), `src/friseDateFields.ts` ; `friseModel.ts`
  (+ `periodFromColumns`, `segmentForDate`) ; `frise.ts` (bouton, création de la fiche, API `placeFiche`).
- **Migration** : aucune (tables et droits existants).
- **Vérifié** : `check:repo` et `build` passent ; test dans un vrai navigateur (Chromium) avec une fausse base en
  mémoire : remontée sur la frise parente, refus d'une date hors frise, retrait d'un placement, interdiction de retirer
  le dernier, fiche rangée dans la bonne période (Moyen Âge / Antiquité), aucune erreur JavaScript.
- **Non vérifié** : le comportement sur la vraie base Supabase (droits réels, `schema_v28`/`v29` exécutés ?) ;
  l'aspect sur mobile ; le banc d'essai (fausse base) n'est pas dans le dépôt.
