# Chantier « frises » — journal

Spécification de référence : [`../specs/frises-chronologiques.md`](../specs/frises-chronologiques.md).

## Dernières nouvelles (la plus récente en haut)
- 2026-11-03 (3) — **« Vue Atlas »** (essai demandé par Martin, inspiré des frises illustrées de histoirealacarte.com : barre latérale à gauche avec titre et sommaire des périodes, bandeau des époques en haut, règle des dates, cartes illustrées sous la règle reliées à leur date, mini-carte colorée en bas). Par défaut ; le bouton « Vue Tiges » ramène au croquis d'origine (tiges et branches). Les cartes montrent l'image de la fiche si elle existe (sinon un aplat de la couleur de la catégorie) ; au-delà des rangées qui tiennent à l'écran, un point devient une pastille. Aucune migration. Vérifié : `check:repo`, `build`, test Chromium avec images factices (cartes, sommaire, volet, bascule). Non vérifié : rendu avec de vraies images, mobile/tactile, ruban des règnes en Vue Atlas (position à affiner), export image. Le site de référence n'a été regardé que de loin (aperçu réduit) : on n'a copié ni son code ni ses contenus.
- 2026-11-03 (2) — **refonte ergonomique de la frise** (l'agrandissement seul ne suffisait pas) : barre du haut toujours visible, en groupes (Navigation / Affichage / Édition) ; **volet de détail à droite** (point ou période : titre, dates, extrait du texte de la fiche, boutons) avec ‹ › pour passer au point précédent/suivant (flèches du clavier) ; **clic sur une période = zoom animé dessus** + volet, double-clic = ouvrir la sous-frise ; **anti-encombrement** : quand trop de points se superposent, les derniers deviennent des pastilles (titre au survol) au lieu d'empiler des étiquettes sans fin ; molette fluide ; raccourcis (← →, + −, 0, Échap) avec aide en bas ; point sélectionné entouré ; dates de période toujours lisibles. Le mode « barres cachées » est abandonné. Aucune migration. Vérifié : `check:repo`, `build`, test Chromium (volet, ‹ ›, zoom période, mini-carte). Non vérifié : mobile/tactile, extrait avec de vraies fiches, export image, frises très chargées.
- 2026-11-03 — **frise immersive** : tout est beaucoup plus gros (échelle de 1,3 à ~2,2 et jusqu'à 3,2 : la frise prend la plus grande taille qui tient dans la hauteur de l'écran), les barres du haut se cachent (elles redescendent quand la souris monte en haut), titre flottant, **mini-carte** en bas (clic/glisser pour se déplacer), boutons A−/A+ (taille mémorisée), « Barres fixes » / « Immersif », « Plein écran » du navigateur ; graduations qui ne se chevauchent plus ; périodes étroites moins minuscules. Aucune migration. Vérifié : `check:repo`, `build`, test Chromium (taille, barres, mini-carte). Non vérifié : mobile/tactile, frises très chargées, export image avec la nouvelle échelle.
- 2026-11-02 (3) — « Histoire de France » REFAITE : test frises_v1 supprimé, nouvelle frise dans Histoire > Chronologie (4 époques + 17 sous-périodes, sans événements) : `supabase/frises/frises_v3.sql`, **exécuté par Claude via Supabase** sur demande de Martin. Vérifié : contrôles intégrés au script, relecture en base ; non vérifié : affichage dans l'appli, 2 points à valider (début ≈ −600, « Crise du IIIe siècle »), voir `docs/sources/frises.md`. Prochaine étape : 3e niveau (dynasties/régimes) après validation.
- 2026-11-02 (3) — **outil « Règnes »** : bouton « + Règne » (choisir un souverain d'un arbre, dates de début/fin, au moins une source obligatoire) ; ruban « Règnes » sous la frise (trait plein = vérifié : 2 sources dont 1 universitaire ; pointillés = à vérifier) ; clic sur un règne → carte avec sources et bouton « Ouvrir l'arbre » ; bouton « Règnes » pour masquer/afficher. **La table `timeline_reigns` n'existe pas encore sur la vraie base** (`frises_v2.sql` écrit, exécution refusée par le système de permissions : décision de Martin attendue) ; en attendant, la frise s'affiche normalement sans règnes. Aucune donnée ajoutée. Vérifié : `check:repo`, `build`, test navigateur (fausse base) ; non vérifié : vraie base, mobile. Pour le chantier « arbres » : `fetchReignsOfMember(supabase, memberId)` dans `src/friseReigns.ts`.
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
- Migration : **frises_v1** (exemple « Histoire de France », données) écrite, en attente d'exécution par Martin. **frises_v2** (table des règnes, sans données) écrite et poussée, **non exécutée** (attente de Martin).

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

## 2026-11-03 (4) — Identité visuelle « planche d'atlas »
- **Pourquoi** : Martin trouvait le rendu (fond noir + or, cartes arrondies, tout symétrique) « style IA ». Quatre maquettes très différentes lui ont été montrées (A papier découpé, B planche d'atlas, C strates, D affiche) ; il a choisi **B** « pour le moment » (essai, pas définitif).
- **Ce qui change pour lui** : la frise passe sur papier clair, encre bleu nuit, rouge vermillon pour l'accent ; titres en EB Garamond, repères et boutons en Archivo Narrow majuscules ; angles droits, filets fins, double cadre ; ombres supprimées. Le reste du site garde son style.
- **Code** : nouveau `src/friseTheme.css` (variables redéfinies uniquement sous `#timeline-view` et les boîtes de frise, importé en dernier dans `frise.ts`). Aucune logique modifiée.
- **Polices** : EB Garamond et Archivo Narrow chargées depuis Google Fonts (`@import`), licence SIL OFL.
- **Vérifié** : `check:repo` et `build` passent ; capture dans Chromium (fausse base) de la Vue Atlas, de la Vue Tiges et du volet de détail, aucune erreur JavaScript.
- **Non vérifié** : mobile/tactile ; boîtes de dialogue d'édition (règnes, catégories) ; contraste des couleurs de catégories choisies pour l'ancien fond sombre ; vrai navigateur de Martin.
- **Suite** : retours de Martin sur B (à garder / à changer), puis éventuels éléments propres à B (légende « Signes conventionnels », accolades pour les périodes, encart de situation).

## 2026-11-03 (5) — Frise plus intégrée, éléments inutiles retirés
- **Demande de Martin** : frise plus importante à l'écran (mieux intégrée, pas seulement plus grosse) ; retirer A−/A+, les flèches gauche/droite, la mini-carte « où en est-on », la ligne d'aide en bas ; titre de la frise une seule fois ; noms de catégories/périodes bien visibles.
- **Fait** : boutons A−/A+ et flèches retirés (clavier ← → + − 0 inchangé) ; mini-carte et aide du bas supprimées (`friseImmersive.ts` ne garde que le plein écran, `friseImmersive.css` supprimé) ; titre seulement en haut (le sommaire latéral n'affiche plus que les dates) ; cadre collé aux bords de l'écran (plus de marge) ; légende des catégories remontée sur la ligne du titre (une ligne gagnée) ; noms de périodes agrandis, qui s'adaptent à la largeur de leur case et passent à la ligne au lieu d'être coupés (« GAULE… ») ; pastilles de catégories plus grandes.
- **Vérifié** : `check:repo` et `build` ; captures Vue Atlas / Vue Tiges / volet, aucune erreur JavaScript.
- **Non vérifié** : écrans étroits et mobile ; nom de frise très long (retour à la ligne de la barre) ; frise sans événement.

## 2026-11-03 (6) — Vue Atlas des deux côtés, menu à droite, fond gris texturé, zoom rapide
- **Demande de Martin** : points trop gros (ils se chevauchent) ; zoom/déplacement plus rapides ; menu de gauche à droite et remplacé par le volet quand on ouvre un point ; événements aussi au-dessus de la frise, frise centrée ; fond blanc fatigant → gris doux texturé, même identité.
- **Fait** : Vue Atlas : les événements alternent au-dessus / en dessous de la règle (2× plus de place), zones de hauteur égale donc frise centrée (`friseAtlas.ts`) ; cartes plus petites ; étiquettes et points de la Vue Tiges réduits (≈ 40 %) ; sommaire à droite, masqué quand le volet d'un point s'ouvre (même emplacement) ; fond `#d3d4cc` avec grain de papier (bruit SVG léger), cartes `#e4e5dd` ; molette ×~2 par cran (avant ×1,15), boutons +/− et touches ×2, glissé avec élan, défilement horizontal ×2,5, flèches du clavier 60 % de l'écran.
- **Mesuré** : 3 crans de molette = largeur de frise ×5 (avant : ×1,5).
- **Vérifié** : `check:repo`, `build` ; captures Vue Atlas / Tiges / volet, aucune erreur JavaScript.
- **Non vérifié** : élan du glissé au toucher ; mobile ; beaucoup d'événements très proches (au-delà des rangées, retour aux pastilles) ; sensation de la molette sur pavé tactile ; côté choisi par alternance (pas encore réglable par événement en Vue Atlas).

## 2026-11-06 — Une seule vue, plus aucun point masqué, ruban des règnes retiré
- **Demande de Martin** : supprimer la Vue Tiges (une seule vue) ; les dates se chevauchaient et certaines disparaissaient ; il ne comprend pas la « vue règnes ».
- **Fait** :
  - Vue Tiges supprimée (branche de rendu, placement par niveaux, mesure de texte, glissé des points, bouton de bascule) : `frise.ts` perd ~250 lignes. Une seule vue : l'ex-« Vue Atlas ».
  - Convention des frises/cartes en ligne pour les événements serrés : quand il n'y a plus de place pour une carte, les événements voisins (< 24 px) sont **regroupés en une pastille numérotée** sur la ligne des dates ; clic = liste de tous les événements du groupe (ouvrir l'un d'eux) + bouton « Zoomer ici ». Plus aucun point ne se superpose ni ne disparaît ; en zoomant, les cartes se séparent.
  - Bouton « Règnes » et ruban des règnes retirés de l'écran. Gardé : bouton admin « + Règne » (saisie des dates de règne pour le futur lien avec l'arbre généalogique), module `friseReigns*.ts` et table `timeline_reigns`. Le chargement des règnes n'est plus fait à l'ouverture d'une frise.
  - Avertissement « N point(s) hors de la frise » conservé.
- **Vérifié** : `tsc`, `check:repo`, `build` ; frise de test à 27 événements dont 15 sur 1789-1795 : 1 pastille « 12 » + 15 cartes, liste complète au clic, « Zoomer ici » sépare le groupe ; aucune erreur JavaScript.
- **Non vérifié** : mobile/tactile ; plusieurs groupes sur la même frise ; événements à la date identique au jour près (visibles uniquement via la liste du groupe) ; réglage de hauteur/côté d'un point (supprimé avec les Tiges : la colonne `side` des placements n'est plus utilisée) ; CSS des Tiges encore présent dans `style.css` (inactif, à nettoyer avec le chantier d'identité du site).

## 2026-11-06 (2) — Époque « actuelle » (sans fin)
- **Demande de Martin** : une époque peut ne pas avoir de fin (époque actuelle).
- **Fait** : dans la fenêtre d'une période, case « Époque actuelle (pas de fin, jusqu'à aujourd'hui) » : elle grise les champs de fin et enregistre une fin vide (`period_end_* = null`). À la réouverture, la case est cochée si la période n'a pas de fin. Aucun changement de base (colonnes déjà optionnelles) ni de modèle : la dernière période sans fin va déjà « jusqu'à aujourd'hui » (affiché « aujourd'hui » partout) ; une période sans fin suivie d'une autre s'arrête au début de la suivante.
- **Vérifié** : `tsc`, `build`, `check:repo` ; test navigateur (fausse base) : ouverture de « Cinquième République » → case cochée, champs de fin grisés, enregistrement sans erreur, fin vide en base.
- **Non vérifié** : décocher puis saisir une fin sur une période existante ; période sans fin au milieu de la frise ; vraie base Supabase.
