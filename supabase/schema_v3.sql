-- ============================================================
-- Atlas Géopolitique — schéma v3 : dossiers pour ports/détroits/
-- bases/câbles/pipelines (l'export live a révélé des dossiers avec
-- ces owner_type, pas prévus dans le schéma v1 initial).
-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1 et v2 déjà en place)
-- ============================================================

alter table public.dossier_sections
  drop constraint if exists dossier_sections_owner_type_check;
alter table public.dossier_sections
  add constraint dossier_sections_owner_type_check
  check (owner_type in ('country','encyclopedie','group','port','strait','base','cable','pipeline'));

alter table public.dossier_entries
  drop constraint if exists dossier_entries_owner_type_check;
alter table public.dossier_entries
  add constraint dossier_entries_owner_type_check
  check (owner_type in ('country','encyclopedie','group','port','strait','base','cable','pipeline'));
