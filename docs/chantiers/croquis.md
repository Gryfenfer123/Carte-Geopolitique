# Chantier « croquis » (outil de dessin sur la carte) — journal

## Dernières nouvelles (la plus récente en haut)
- 2026-10-27 — **Chantier créé**, spécification en brouillon (`docs/specs/croquis.md`), registre de sources ouvert (`docs/sources/croquis.md`), nom du chantier ajouté à `docs/CHANTIERS.md` et à `scripts/check-repo.mjs`. Décision proposée : moteur de dessin écrit pour le projet (pas de reprise de VectorCraft ni de Leaflet-Geoman). Aucun code, aucune migration.
  Prochaine étape : Martin valide les paliers et répond aux questions du §7 de la spec ; puis étape 1 = essai technique d'un calque de dessin accroché à la carte (ligne, Bézier, déplacement, annuler/refaire) et choix des briques.

## Pour qui reprend ce chantier
- Lire d'abord `docs/specs/croquis.md` (but, principes, paliers, questions ouvertes).
- Ne pas toucher aux fichiers des autres chantiers. Branchement dans `main.ts` : une ligne au maximum.
- Première migration : `supabase/croquis/croquis_v1.sql` (à réserver en la poussant tout de suite ; **exécutée par Martin**,
  seulement après son accord).
