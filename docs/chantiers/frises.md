# Chantier « frises » — journal

Spécification de référence : [`../specs/frises-chronologiques.md`](../specs/frises-chronologiques.md).

## Dernières nouvelles (la plus récente en haut)
- 2026-11-02 (3) — « Histoire de France » REFAITE : test frises_v1 supprimé, nouvelle frise dans Histoire > Chronologie (4 époques + 17 sous-périodes, sans événements) : `supabase/frises/frises_v3.sql`, **exécuté par Claude via Supabase** sur demande de Martin. Vérifié : contrôles intégrés au script, relecture en base ; non vérifié : affichage dans l'appli, 2 points à valider (début ≈ −600, « Crise du IIIe siècle »), voir `docs/sources/frises.md`. Prochaine étape : 3e niveau (dynasties/régimes) après validation.
- 2026-11-02 (2) — proposition écrite (spec §10, rien codé) : ruban « Règnes » sur la frise relié aux arbres ; il manque les dates de règne en base (seulement naissance/décès) → nouvelle table à valider avec Martin. Catégories de points : à revoir ensemble plus tard.
- 2026-11-02 — confort de la frise : tout est ~30 % plus grand, la frise s'ajuste à l'écran à l'ouverture et sur « Recentrer », grandes marges pour glisser aussi vers la gauche, boutons ← →, flèches du clavier, geste horizontal ; noms de périodes étroites sur 2 lignes. Aucune migration. Vérifié : `check:repo`, `build`, test navigateur ; non vérifié : mobile/tactile, vraie base.
- 2026-11-01 — exemple « Histoire de France » en 3 niveaux (grandes périodes → Révolution → Convention), 40 points sourcés : `supabase/frises/frises_v1.sql`, **à exécuter par Martin** (SQL Editor). Vérifié : script testé 2 fois sur une base locale, affichage testé dans l'appli ; non vérifié : exécution sur la vraie base.
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
- **Reste à faire** : faire valider par Martin les choix de la spec §7bis et §9 ; trancher la proposition §10 (règnes) ; revoir les catégories de points avec Martin.
- Migration : **frises_v1** (exemple « Histoire de France », données) écrite, en attente d'exécution par Martin. Prochaine : **frises_v2**.

## Détail des livraisons

### 2026-11-02 — confort d'utilisation de la frise
- **Ce qui change pour Martin** : (1) police, bandeau, branches et graduations plus grands (échelle `TL_SCALE = 1.3` dans `frise.ts`, répercutée en CSS par `--tl-s`) ; (2) à l'ouverture et sur « Recentrer », la frise est ajustée à la largeur de l'écran (zoom mini 0,05) et centrée, au lieu d'être collée à gauche ; (3) marges latérales de 40 % de l'écran : on peut faire glisser dans les deux sens ; (4) boutons ← →, flèches gauche/droite du clavier, Maj + molette ou geste horizontal du pavé tactile pour défiler (la molette seule zoome toujours) ; (5) une période a une largeur minimale de 84 px, son nom se réduit et passe sur 2 lignes au lieu d'être coupé.
- **Code** : `src/frise.ts` (rendu, `fitZoom`, `centerView`, défilement), `src/style.css` (tailles en `calc(… * var(--tl-s))`). Aucune migration.
- **Vérifié** : Chromium sur l'exemple « Histoire de France » : tout tient à l'écran, glisser vers la gauche et vers la droite, boutons, flèches, geste horizontal, Recentrer ; `check:repo`, `build`.
- **Non vérifié** : écran tactile / mobile ; frises très chargées (beaucoup de points) ; export image après le changement d'échelle (marges forcées à 100 px pour l'export, non retesté).

### 2026-11-01 — exemple « Histoire de France » (frises_v1)
- **Ce qui change pour Martin** : après exécution du script, France > Histoire contient la frise « Histoire de France » (14 grandes périodes, 12 points). Cliquer « Révolution française » ouvre une sous-frise (4 périodes, 18 points), puis « Convention nationale » une 3e frise (3 périodes, 16 points). Certains points sont sur deux frises (même événement). Chaque point a une fiche vide rangée dans la sous-catégorie de sa période, avec ses sources.
- **Code** : aucun changement d'appli ; `supabase/frises/frises_v1.sql` (données).
- **Sources** : `docs/sources/frises.md` (dates recoupées ; celles absentes des textes lus ont été écartées, voir ce fichier).
- **Vérifié** : script exécuté 2 fois sur PostgreSQL local avec les mêmes contraintes que la base (3 frises, 21 périodes, 40 événements, 46 placements, rien de dupliqué) ; affichage des 3 niveaux, du survol de sous-frise et du fil d'Ariane dans un vrai Chromium avec ces données ; `check:repo`, `build`.
- **Non vérifié** : exécution sur la vraie base Supabase ; vérification humaine des dates (certaines bornes sont des conventions, voir sources).

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
