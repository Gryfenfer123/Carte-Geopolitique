# Chantier « listes » (listes de personnes avec photos) — journal

## Dernières nouvelles (la plus récente en haut)
- 2026-11-12 — **Chantier créé** à la demande de Martin (après l'abandon de l'outil de croquis). Spécification en brouillon : `docs/specs/listes-de-personnes.md`. Aucun code, aucune migration.
  Prochaine étape : Martin valide la spec (§5) ; puis palier 1 (liste simple, vue Ligne/Grille, photos). La migration `supabase/listes/listes_v1.sql` ne sera écrite et exécutée qu'avec son accord.

## Pour qui reprend ce chantier
- Lire `docs/specs/listes-de-personnes.md`. Nouveaux modules `liste*.ts` ; ne pas grossir `dossier.ts` ni `genealogy.ts` (une ligne de branchement au plus).
- Migrations : `supabase/listes/listes_vN.sql` (premier : `listes_v1`), **exécutées avec l'accord de Martin**.
