# Chantier « croquis » (outil de dessin sur la carte) — journal

## Dernières nouvelles (la plus récente en haut)
- 2026-10-27 (nuit) — **Première version utilisable de l'outil (palier 1 + une grande partie des paliers 2 et 3)**. Sur la carte, un nouveau bouton « crayon » (en bas à droite, à gauche de la rangée) ouvre le panneau Croquis. Dessin : plume (courbes de Bézier), crayon main levée lissé, ligne, rectangle, ellipse, texte, main ; outils Sélection (déplacer, redimensionner, pivoter) et Nœuds (poignées, nœud lisse/anguleux) ; style (remplissage, contour, tirets, flèches, épaisseur en pixels ou en mètres de carte, opacité) ; calques (masquer, verrouiller, ordre, renommer) ; grouper, aligner, miroir, ordre d'empilement, copier/coller/dupliquer ; annuler/refaire ; export SVG (calques Inkscape/Illustrator), PNG, JSON ; import JSON. Les dessins restent accrochés à la géographie (zoom et déplacement suivis).
  **Provisoire** : les croquis sont enregistrés dans le navigateur de Martin (localStorage), PAS encore dans la base ni dans les dossiers pays/groupes. Aucune migration écrite : à faire avec son accord (`supabase/croquis/croquis_v1.sql`, + type d'entrée `croquis`).
  Vérifié : 23 tests de logique (`bash scripts/croquis/lancer-tests.sh`), typage, `check:repo`, `build`, essai dans un vrai navigateur (dessin, zoom, annuler/refaire, export SVG, rechargement). Non vérifié : écran tactile, comptes administrateurs réels (Supabase injoignable depuis l'environnement de test), tuiles réelles, grands volumes d'objets, Safari/Firefox.
  Prochaine étape : Martin essaie et dit ce qui manque ; puis migration + entrée de dossier `croquis` ; ensuite opérations Pathfinder, texte sur tracé, dégradés/hachures, symboles, coloration de pays.
- 2026-10-27 (soir) — **Réponses de Martin intégrées à la spec (§7)** : dessin par les comptes administrateurs ; croquis rangés dans les dossiers pays/groupes (nouveau type d'entrée `croquis`, à vérifier côté base). Ordre des paliers et export SVG non tranchés (défauts annoncés). Aucun code, aucune migration.
  Prochaine étape : Martin confirme l'ordre ; étape 1 (essai technique du calque de dessin sur la carte).
- 2026-10-27 — **Chantier créé**, spécification en brouillon (`docs/specs/croquis.md`), registre de sources ouvert (`docs/sources/croquis.md`), nom du chantier ajouté à `docs/CHANTIERS.md` et à `scripts/check-repo.mjs`. Décision proposée : moteur de dessin écrit pour le projet (pas de reprise de VectorCraft ni de Leaflet-Geoman). Aucun code, aucune migration.
  Prochaine étape : Martin valide les paliers et répond aux questions du §7 de la spec ; puis étape 1 = essai technique d'un calque de dessin accroché à la carte (ligne, Bézier, déplacement, annuler/refaire) et choix des briques.

## Pour qui reprend ce chantier
- Lire d'abord `docs/specs/croquis.md` (but, principes, paliers, questions ouvertes).
- Ne pas toucher aux fichiers des autres chantiers. Branchement dans `main.ts` : une ligne au maximum.
- Première migration : `supabase/croquis/croquis_v1.sql` (à réserver en la poussant tout de suite ; **exécutée par Martin**,
  seulement après son accord).
