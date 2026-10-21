-- ============================================================
-- Atlas Géopolitique — schéma v29 (2026-10-21) : frises — couleurs des
-- périodes, transitions cliquables, points colorés.
--
-- * dossier_sections.period_color : couleur d'une période (#rrggbb).
-- * Transitions : l'intervalle entre deux périodes qui ne se touchent pas
--   est une transition grisée. Elle devient une vraie sous-catégorie
--   (period_is_transition = true) dès qu'on y entre (sous-frise, points...).
--   transition_after_id = la période qui la précède ; ses dates sont
--   toujours calculées d'après ses voisines.
-- * timeline_placements.side / color : un point part de la bande vers le haut
--   ('up') ou le bas ('down') et porte sa couleur.
--
-- Nécessite schema_v27 (et v28 pour les droits admin).
-- À coller dans Supabase → SQL Editor → New query → Run.
-- Ne supprime aucune donnée, peut être exécuté plusieurs fois.
-- ============================================================
alter table public.dossier_sections
  add column if not exists period_color text,
  add column if not exists period_is_transition boolean not null default false,
  add column if not exists transition_after_id uuid
    references public.dossier_sections(id) on delete set null;

alter table public.timeline_placements
  add column if not exists side text not null default 'down',
  add column if not exists color text;

alter table public.timeline_placements
  drop constraint if exists timeline_placements_side_check;
alter table public.timeline_placements
  add constraint timeline_placements_side_check check (side in ('up', 'down'));

-- Les points peuvent être modifiés (côté, couleur) : droit de mise à jour admin.
drop policy if exists "timeline_placements_admin_update" on public.timeline_placements;
create policy "timeline_placements_admin_update" on public.timeline_placements
  for update using (public.is_admin());
