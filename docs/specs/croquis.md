# Outil de croquis — spécification

**État : BROUILLON du 2026-10-27, à valider par Martin.** Rien n'est encore codé. Les choix marqués
« proposé » ont été pris en autonomie et sont à confirmer ; on ne les rouvre pas sans Martin une fois validés.

## 1. Le but (demande de Martin, 2026-10-27)

Construire **l'outil**, pas un croquis en particulier (la migration pendulaire en France n'était qu'un exemple).
Un outil « **aussi complet que possible, à la manière d'Adobe Illustrator** », même si cela prend du temps,
qui permet de **créer des croquis directement sur la carte du site** et d'**afficher** des croquis sur la carte.

Les modifications se font sur la carte vivante, **pas** sur une image de fond : le croquis est accroché
à la géographie, il suit le zoom et le déplacement de la carte.

## 2. Principes

1. **Accroché à la géographie.** Chaque point d'un dessin a des coordonnées sur la Terre. Zoomer ou déplacer
   la carte déplace le dessin avec elle (proposé : coordonnées stockées en mètres Web Mercator, la projection
   des tuiles, pour que les courbes gardent exactement la même forme à tous les zooms).
2. **Un croquis = un ensemble d'objets rangés en calques**, avec un titre, une légende et des sources.
   Plusieurs croquis peuvent être **affichés en même temps** sur la carte ; chacun s'active et se désactive.
3. **Deux manières de fixer une épaisseur** (proposé) : *fixe à l'écran* (lisible à tout zoom, comme un trait de
   crayon) ou *en unités de carte* (un trait de 10 km reste de 10 km : utile pour des flux proportionnels).
4. **Droits** : lecture publique, **modification réservée aux administrateurs**, comme le reste de l'appli
   (la vraie barrière est la RLS en base, voir `docs/BASE_DE_DONNEES.md`).
5. **Sourcé** : un croquis porte ses sources (champ « sources » + registre `docs/sources/croquis.md` pour tout
   ce qui est chargé par le code). Pas de donnée sans source.

## 3. Fonctionnalités visées, par paliers

Chaque palier est **utilisable seul** et livré séparément. L'ordre est proposé ; le contenu d'un palier peut bouger.

**Palier 1 — Dessiner et enregistrer (fondations)**
- Outils : sélection, ligne, polyligne, rectangle, ellipse, polygone, **plume à courbes de Bézier** (poignées),
  crayon main levée (lissé), flèche simple.
- Éditer : déplacer, redimensionner, **pivoter**, modifier les nœuds et les poignées d'une courbe, supprimer.
- Apparence : couleur de remplissage, contour (couleur, épaisseur, pointillés, bouts et angles), opacité.
- **Annuler / refaire** illimité ; raccourcis clavier.
- Enregistrement dans la base ; ouverture et réaffichage sur la carte.

**Palier 2 — S'organiser**
- **Calques** : afficher/masquer, verrouiller, renommer, réordonner, plusieurs par croquis.
- Groupes, sélection multiple, copier/coller/dupliquer, ordre d'empilement (devant/derrière).
- Alignement et répartition, **aimantation** (aux nœuds, à une grille, aux frontières de pays).

**Palier 3 — Richesse du dessin**
- Flèches avancées : têtes réglables, **largeur variable** le long du tracé (flux).
- **Texte** : polices, taille, alignement, **texte qui suit un tracé**.
- Dégradés, ombres, flou ; **motifs de hachures** (usage classique des croquis de géographie).
- **Bibliothèque de symboles** (villes, ports, bases, conflits…), symboles que l'on peut ajouter à la bibliothèque.
- Pinceaux à largeur variable.

**Palier 4 — Opérations sur les formes (type « Pathfinder »)**
- Union, intersection, soustraction, découpe ; décalage de tracé ; joindre et scinder des tracés ; simplifier ;
  texte converti en courbes ; masques d'écrêtage.

**Palier 5 — Propre à la carte**
- **Colorier des pays et des subdivisions** en cliquant sur leur forme (frontières déjà dans l'appli) ; colorier
  d'un coup un groupe (OTAN, BRICS…) ou selon un indicateur.
- **Épaisseur ou taille liée à une donnée** (flux, effectifs) à partir d'un tableau importé (chaque jeu de données
  est sourcé avant chargement).
- **Légende automatique** construite à partir de ce qui est dessiné ; titre, échelle, flèche du nord, bloc « sources ».

**Palier 6 — Sorties**
- Export **SVG** fidèle (ouvrable dans Illustrator, Inkscape, VectorCraft : permet de finir un croquis ailleurs),
  **PNG**, **PDF**, avec ou sans fond de carte ; import SVG ; export JSON.

**Palier 7 — Intégration au reste du site** (idées, à confirmer)
- Un croquis rangé comme **entrée de dossier** (pays, groupe, catégorie), à la manière des frises et des arbres ;
  croquis liés à des fiches ; choix des croquis affichés sur la carte principale.

## 4. Choix techniques proposés (à confirmer à l'étape 1)

- **Moteur de dessin écrit pour ce projet**, posé comme un calque SVG dans la carte Leaflet existante.
  Raison : un éditeur « à la Illustrator » a besoin de courbes à poignées, de texte, de groupes, de calques, de
  transformations, d'annuler/refaire. Aucune brique carte rencontrée ne couvre cela (voir §5).
- **Logique pure à part** (sans DOM ni base), testable : modèle d'objets, géométrie, historique annuler/refaire,
  conversions de coordonnées, sérialisation. Interface et rendu dans d'autres modules. Fichiers prévus :
  `src/sketchModel.ts`, `src/sketchGeometry.ts`, `src/sketchHistory.ts`, `src/sketchLayer.ts`, `src/sketchTools.ts`,
  `src/sketchPanel.ts`, `src/sketchExport.ts`, `src/sketch.css` ; une seule ligne de branchement dans `main.ts`.
- **Briques candidates** (aucune ajoutée pour l'instant : chaque dépendance sera justifiée dans `DECISIONS.md`) :

| Brique | Utilité possible | Licence (registre npm, 2026-10-27) |
|---|---|---|
| Paper.js (`paper`) | calculs de courbes, opérations booléennes sur les tracés, aires | MIT |
| `polygon-clipping` / `martinez-polygon-clipping` | union, intersection, soustraction de polygones | MIT |
| `bezier-js` | calculs sur les courbes de Bézier (longueurs, points proches, découpe) | MIT |
| `svg2pdf.js` + `jspdf` ou `pdfkit` | export PDF | MIT |
| `@flatten-js/core` | géométrie plane (distances, intersections) | MIT |

  Toutes sont à licence permissive : compatibles avec un site ouvert un jour au public. Les sources de ces
  informations sont dans `docs/sources/croquis.md`. Le choix final se fait après un essai (étape 1).
- **Stockage** (à décider avec Martin) : une table `sketches` (croquis) et peut-être `sketch_layers`, avec le
  contenu des objets en JSON ; RLS écrite dans la même migration. **Migration exécutée par Martin**,
  uniquement après son accord (c'est irréversible).
- **Export** : réutiliser la logique d'assemblage `<canvas>` de `compareExport.ts` (sans `html2canvas`, voir
  `DECISIONS.md`) ; le SVG du croquis est produit directement depuis le modèle.

## 5. Ce qu'on ne reprend pas, et pourquoi

- **VectorCraft** (logiciel libre type Illustrator, écrit en Rust, tourne aussi dans le navigateur) : c'est un
  logiciel complet avec sa propre feuille de dessin, pas une brique à poser sur une carte ; sa documentation dit que
  l'intégration dans un autre site est encore en préparation ; il est en **alpha**. Un dessin fait dedans ne
  serait pas accroché à la géographie. Il reste utile **à côté** : un croquis exporté en SVG peut y être retouché.
- **Leaflet-Geoman** (version gratuite) : dessine et modifie des formes sur une carte (polygones, lignes, cercles,
  découpe, rotation, aimantation) mais sans courbes de Bézier à poignées ni texte (d'après sa documentation lue) ;
  certaines fonctions sont dans une version payante. Trop limité pour l'objectif. Peut servir d'inspiration.
- **Leaflet.curve** : courbes sur une carte, mais pas d'édition ; inspiration seulement.
- Cette appréciation vient de la lecture des pages citées dans `docs/sources/croquis.md` ; **les dépôts de code
  eux-mêmes n'ont pas été lus** : à revérifier si on veut vraiment reprendre une de ces briques.

## 6. Limites et risques (dits franchement)

- **Illustrator représente des décennies de travail** : atteindre « tout » n'est pas réaliste d'un coup. On vise les
  fonctions les plus utiles aux croquis de géopolitique d'abord, puis on étend palier par palier.
- Les calculs de formes (Pathfinder, décalage) sont la partie la plus difficile et la plus risquée.
- Performance : beaucoup d'objets sur une carte qui bouge demandera du soin (rendu par blocs, simplification au dézoom).
- Précision géographique : les formes dessinées en projection Mercator sont déformées près des pôles (comme la
  carte) ; sans importance pour un croquis, à signaler si on mesure des surfaces.

## 7. Questions ouvertes pour Martin

1. Les **paliers** et leur ordre te conviennent-ils ? Quelles fonctions sont indispensables dès le début ?
2. Qui peut dessiner : seulement toi (administrateur), comme le reste de l'appli, ou plus tard d'autres personnes ?
3. Où vivent les croquis : un **panneau « Croquis »** séparé (liste, ouvrir/fermer), et/ou rangés dans les
   **dossiers** des pays et groupes ?
4. Faut-il pouvoir **exporter vers Illustrator** (SVG) dès le premier palier d'export, ou le PDF/PNG suffit-il d'abord ?
