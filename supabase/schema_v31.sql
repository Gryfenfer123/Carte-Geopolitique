-- ============================================================
-- Atlas Géopolitique — schéma v31 (2026-10-21) : frises — catégories de points
-- (nom + couleur fixe, légende filtrante), points avec durée et sous-frise
-- d'un événement.
--
-- * timeline_categories : catégories d'événements (Conflit, Traité, Crise...),
--   chacune avec UNE couleur. Un point (timeline_placements) choisit sa
--   catégorie ; sa couleur est celle de la catégorie. Lecture publique,
--   écriture réservée aux administrateurs.
-- * timeline_events.date_end_* : date de fin facultative = point "avec durée"
--   (barre colorée entre les deux dates).
-- * timeline_events.sub_frise_entry_id : la frise ouverte en cliquant sur un
--   événement avec durée (ex. la Première Guerre mondiale).
--
-- Nécessite schema_v27 à v30. À coller dans Supabase → SQL Editor → Run.
-- Ne supprime aucune donnée, peut être exécuté plusieurs fois.
-- ============================================================

create table if not exists public.timeline_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  color text not null default '#2980b9',
  position integer not null default 0,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);
create unique index if not exists timeline_categories_name_idx
  on public.timeline_categories (lower(name));

alter table public.timeline_categories enable row level security;
drop policy if exists "timeline_categories_select_all" on public.timeline_categories;
drop policy if exists "timeline_categories_admin_insert" on public.timeline_categories;
drop policy if exists "timeline_categories_admin_update" on public.timeline_categories;
drop policy if exists "timeline_categories_admin_delete" on public.timeline_categories;
create policy "timeline_categories_select_all" on public.timeline_categories
  for select using (true);
create policy "timeline_categories_admin_insert" on public.timeline_categories
  for insert with check (public.is_admin());
create policy "timeline_categories_admin_update" on public.timeline_categories
  for update using (public.is_admin());
create policy "timeline_categories_admin_delete" on public.timeline_categories
  for delete using (public.is_admin());

-- Catégories de départ (modifiables ensuite depuis la frise).
insert into public.timeline_categories (name, color, position) values
  ('Conflit', '#c0392b', 0),
  ('Traité', '#2980b9', 1),
  ('Crise', '#e67e22', 2),
  ('Dynastie', '#8e44ad', 3),
  ('Institution politique', '#16a085', 4),
  ('Religion', '#d4ac0d', 5),
  ('Économie et société', '#27ae60', 6),
  ('Relations avec le monde', '#5d6d7e', 7),
  ('Territoire', '#a04000', 8)
on conflict do nothing;

alter table public.timeline_placements
  add column if not exists category_id uuid
    references public.timeline_categories(id) on delete set null;

alter table public.timeline_events
  add column if not exists date_end_year int,
  add column if not exists date_end_month smallint check (date_end_month between 1 and 12),
  add column if not exists date_end_day smallint check (date_end_day between 1 and 31),
  add column if not exists date_end_circa boolean not null default false,
  add column if not exists sub_frise_entry_id uuid
    references public.dossier_entries(id) on delete set null;

alter table public.timeline_events
  drop constraint if exists timeline_events_end_check;
alter table public.timeline_events
  add constraint timeline_events_end_check check (
    (date_end_year is not null or (date_end_month is null and date_end_day is null))
    and (date_end_day is null or date_end_month is not null)
  );

create index if not exists timeline_events_sub_frise_idx
  on public.timeline_events (sub_frise_entry_id)
  where sub_frise_entry_id is not null;
