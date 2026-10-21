-- ============================================================
-- Atlas Géopolitique — schéma v28 (2026-10-21) : écriture des frises
-- réservée aux administrateurs.
--
-- schema_v27 autorisait l'écriture à tout compte connecté, alors que
-- l'appli entière est en régime "admin seul" depuis schema_v13
-- (public.is_admin()). Ce script aligne les 3 tables d'événements sur ce
-- régime. Lecture publique inchangée.
--
-- À coller dans Supabase → SQL Editor → New query → Run.
-- Ne supprime aucune donnée, peut être exécuté plusieurs fois.
-- ============================================================

-- timeline_events
drop policy if exists "timeline_events_auth_insert" on public.timeline_events;
drop policy if exists "timeline_events_admin_insert" on public.timeline_events;
drop policy if exists "timeline_events_auth_update" on public.timeline_events;
drop policy if exists "timeline_events_admin_update" on public.timeline_events;
drop policy if exists "timeline_events_auth_delete" on public.timeline_events;
drop policy if exists "timeline_events_admin_delete" on public.timeline_events;
create policy "timeline_events_admin_insert" on public.timeline_events
  for insert with check (public.is_admin());
create policy "timeline_events_admin_update" on public.timeline_events
  for update using (public.is_admin());
create policy "timeline_events_admin_delete" on public.timeline_events
  for delete using (public.is_admin());

-- timeline_event_fiches
drop policy if exists "timeline_event_fiches_auth_insert" on public.timeline_event_fiches;
drop policy if exists "timeline_event_fiches_admin_insert" on public.timeline_event_fiches;
drop policy if exists "timeline_event_fiches_auth_update" on public.timeline_event_fiches;
drop policy if exists "timeline_event_fiches_admin_update" on public.timeline_event_fiches;
drop policy if exists "timeline_event_fiches_auth_delete" on public.timeline_event_fiches;
drop policy if exists "timeline_event_fiches_admin_delete" on public.timeline_event_fiches;
create policy "timeline_event_fiches_admin_insert" on public.timeline_event_fiches
  for insert with check (public.is_admin());
create policy "timeline_event_fiches_admin_update" on public.timeline_event_fiches
  for update using (public.is_admin());
create policy "timeline_event_fiches_admin_delete" on public.timeline_event_fiches
  for delete using (public.is_admin());

-- timeline_placements
drop policy if exists "timeline_placements_auth_insert" on public.timeline_placements;
drop policy if exists "timeline_placements_admin_insert" on public.timeline_placements;
drop policy if exists "timeline_placements_auth_delete" on public.timeline_placements;
drop policy if exists "timeline_placements_admin_delete" on public.timeline_placements;
create policy "timeline_placements_admin_insert" on public.timeline_placements
  for insert with check (public.is_admin());
create policy "timeline_placements_admin_delete" on public.timeline_placements
  for delete using (public.is_admin());
