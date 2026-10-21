-- ============================================================
-- Atlas Géopolitique — schéma v30 (2026-10-21) : frises — hauteur réglée à la
-- main d'un point (tige). NULL = hauteur automatique.
-- Nécessite schema_v27 à v29. À coller dans Supabase → SQL Editor → Run.
-- Ne supprime aucune donnée, peut être exécuté plusieurs fois.
-- ============================================================
alter table public.timeline_placements
  add column if not exists stem_length integer;

alter table public.timeline_placements
  drop constraint if exists timeline_placements_stem_length_check;
alter table public.timeline_placements
  add constraint timeline_placements_stem_length_check
  check (stem_length is null or stem_length between 8 and 900);
