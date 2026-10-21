-- ============================================================
-- Atlas Géopolitique — schéma v27 (2026-10-21) : frises chronologiques,
-- NOUVEAU MODÈLE (remplace le prototype schema_v19 / timeline_items, qui
-- n'est plus utilisé : "les frises déjà créées sont des prototypes, rien à
-- garder" — Martin, 2026-10-21. La table timeline_items n'est PAS
-- supprimée ici, pour ne rien détruire sans accord explicite.)
--
-- Spécification complète : document de projet
-- "claude/frises-chronologiques-specification.md". Résumé du modèle :
--
-- * Une FRISE est une entrée de dossier de type 'frise' (dossier_entries,
--   existe déjà), placée où l'on veut (pays, groupe, catégorie, sous-
--   catégorie à n'importe quelle profondeur).
--
-- * Une PÉRIODE EST une sous-catégorie (dossier_sections, déjà imbriquable
--   via parent_section_id et propre à chaque pays/groupe). On lui ajoute
--   simplement une date de début : il n'y a donc qu'UN SEUL objet, ce qui
--   garantit la synchronisation totale renommer/déplacer/supprimer
--   période <-> sous-catégorie, sans rien à recopier. Une sous-frise est
--   une frise placée dans une période : profondeur illimitée.
--
--   Bornes partagées : une période n'enregistre que sa date de DÉBUT ; sa
--   fin est le début de la période suivante (même frise, triées par date)
--   — elles ne peuvent donc pas se désaccorder. period_end_* n'est rempli
--   que pour (a) un TROU DE TRANSITION grisé entre deux périodes (avec
--   transition_label) ou (b) la dernière période d'une frise si elle a une
--   fin (NULL = ouverte, jusqu'à aujourd'hui). Pas de chevauchement.
--
-- * Un ÉVÉNEMENT (timeline_events) = un objet unique : titre + date (année
--   négative = avant J.-C., mois et jour facultatifs, drapeau "vers").
--   Il est TOUJOURS lié à au moins une FICHE (une entrée de dossier) via
--   timeline_event_fiches : une fiche PAR PAYS pour un événement commun
--   (point de vue propre à chaque pays), toutes reliées au même événement,
--   ce qui permet de passer de l'une à l'autre. Le pays d'une fiche est
--   dossier_entries.owner_type/owner_id.
--
-- * PLACEMENT (timeline_placements) : où un événement apparaît. Un
--   événement peut figurer sur plusieurs frises (générale + thématique,
--   pays différents, remontée sur une frise parente) : c'est une
--   RÉFÉRENCE, jamais une copie. La période d'affichage se déduit des
--   dates, rien à stocker.
--
-- Régime d'accès : lecture publique, écriture pour tout compte connecté
-- (comme le reste de l'appli depuis schema_v8).
--
-- À coller dans Supabase → SQL Editor → New query → Run.
-- Ne supprime rien, peut être exécuté plusieurs fois sans erreur.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Périodes : colonnes ajoutées aux sous-catégories
-- ------------------------------------------------------------
alter table public.dossier_sections
  -- La frise dont cette sous-catégorie est une période (NULL = sous-
  -- catégorie ordinaire). Si la frise est supprimée, la sous-catégorie
  -- reste, redevenue ordinaire (on ne supprime jamais de contenu).
  add column if not exists period_frise_id uuid
    references public.dossier_entries(id) on delete set null,
  add column if not exists period_start_year int,
  add column if not exists period_start_month smallint,
  add column if not exists period_start_day smallint,
  add column if not exists period_start_circa boolean not null default false,
  add column if not exists period_end_year int,
  add column if not exists period_end_month smallint,
  add column if not exists period_end_day smallint,
  add column if not exists period_end_circa boolean not null default false,
  add column if not exists transition_label text;

alter table public.dossier_sections
  drop constraint if exists dossier_sections_period_dates_check;
alter table public.dossier_sections
  add constraint dossier_sections_period_dates_check check (
    (period_start_month is null or period_start_month between 1 and 12)
    and (period_start_day is null or (period_start_day between 1 and 31 and period_start_month is not null))
    and (period_end_month is null or period_end_month between 1 and 12)
    and (period_end_day is null or (period_end_day between 1 and 31 and period_end_month is not null))
    -- une période d'une frise a toujours une date de début
    and (period_frise_id is null or period_start_year is not null)
    -- une fin sans année n'a pas de sens
    and (period_end_year is not null or (period_end_month is null and period_end_day is null))
  );

create index if not exists dossier_sections_period_frise_idx
  on public.dossier_sections (period_frise_id)
  where period_frise_id is not null;

-- ------------------------------------------------------------
-- 2. Événements
-- ------------------------------------------------------------
create table if not exists public.timeline_events (
  id uuid primary key default gen_random_uuid(),

  title text not null,                       -- ex. "Traité de Versailles"

  date_year int not null,                    -- négatif = avant J.-C.
  date_month smallint check (date_month between 1 and 12),
  date_day smallint check (date_day between 1 and 31),
  date_circa boolean not null default false, -- "vers"

  -- Clé de tri chronologique (l'année domine ; mois et jour affinent).
  sort_key bigint generated always as (
    date_year::bigint * 10000
    + coalesce(date_month, 0) * 100
    + coalesce(date_day, 0)
  ) stored,

  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint timeline_events_day_needs_month check (date_day is null or date_month is not null)
);

create index if not exists timeline_events_sort_key_idx
  on public.timeline_events (sort_key);

-- ------------------------------------------------------------
-- 3. Fiches d'un événement (une fiche par pays pour un événement commun)
-- ------------------------------------------------------------
create table if not exists public.timeline_event_fiches (
  -- Une fiche appartient à au plus UN événement.
  entry_id uuid primary key references public.dossier_entries(id) on delete cascade,
  event_id uuid not null references public.timeline_events(id) on delete cascade,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create index if not exists timeline_event_fiches_event_idx
  on public.timeline_event_fiches (event_id);

-- Un événement est toujours lié à une fiche : quand la dernière fiche d'un
-- événement disparaît, l'événement (et ses placements, en cascade) aussi.
create or replace function public.timeline_delete_orphan_event()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if not exists (
    select 1 from public.timeline_event_fiches where event_id = old.event_id
  ) then
    delete from public.timeline_events where id = old.event_id;
  end if;
  return old;
end;
$$;

drop trigger if exists timeline_event_fiches_orphan_cleanup on public.timeline_event_fiches;
create trigger timeline_event_fiches_orphan_cleanup
  after delete on public.timeline_event_fiches
  for each row execute function public.timeline_delete_orphan_event();

-- ------------------------------------------------------------
-- 4. Placements : où un événement apparaît (référence, jamais une copie)
-- ------------------------------------------------------------
create table if not exists public.timeline_placements (
  frise_entry_id uuid not null references public.dossier_entries(id) on delete cascade,
  event_id uuid not null references public.timeline_events(id) on delete cascade,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  primary key (frise_entry_id, event_id)
);

create index if not exists timeline_placements_event_idx
  on public.timeline_placements (event_id);

-- ------------------------------------------------------------
-- 5. Sécurité (RLS) : lecture publique, écriture pour tout compte connecté
-- ------------------------------------------------------------
alter table public.timeline_events enable row level security;
alter table public.timeline_event_fiches enable row level security;
alter table public.timeline_placements enable row level security;

drop policy if exists "timeline_events_select_all" on public.timeline_events;
drop policy if exists "timeline_events_auth_insert" on public.timeline_events;
drop policy if exists "timeline_events_auth_update" on public.timeline_events;
drop policy if exists "timeline_events_auth_delete" on public.timeline_events;
create policy "timeline_events_select_all" on public.timeline_events
  for select using (true);
create policy "timeline_events_auth_insert" on public.timeline_events
  for insert with check (auth.uid() is not null);
create policy "timeline_events_auth_update" on public.timeline_events
  for update using (auth.uid() is not null);
create policy "timeline_events_auth_delete" on public.timeline_events
  for delete using (auth.uid() is not null);

drop policy if exists "timeline_event_fiches_select_all" on public.timeline_event_fiches;
drop policy if exists "timeline_event_fiches_auth_insert" on public.timeline_event_fiches;
drop policy if exists "timeline_event_fiches_auth_update" on public.timeline_event_fiches;
drop policy if exists "timeline_event_fiches_auth_delete" on public.timeline_event_fiches;
create policy "timeline_event_fiches_select_all" on public.timeline_event_fiches
  for select using (true);
create policy "timeline_event_fiches_auth_insert" on public.timeline_event_fiches
  for insert with check (auth.uid() is not null);
create policy "timeline_event_fiches_auth_update" on public.timeline_event_fiches
  for update using (auth.uid() is not null);
create policy "timeline_event_fiches_auth_delete" on public.timeline_event_fiches
  for delete using (auth.uid() is not null);

drop policy if exists "timeline_placements_select_all" on public.timeline_placements;
drop policy if exists "timeline_placements_auth_insert" on public.timeline_placements;
drop policy if exists "timeline_placements_auth_delete" on public.timeline_placements;
create policy "timeline_placements_select_all" on public.timeline_placements
  for select using (true);
create policy "timeline_placements_auth_insert" on public.timeline_placements
  for insert with check (auth.uid() is not null);
create policy "timeline_placements_auth_delete" on public.timeline_placements
  for delete using (auth.uid() is not null);

-- ------------------------------------------------------------
-- Vérification (facultative) après exécution : doit renvoyer 4 lignes
--   select table_name from information_schema.tables
--   where table_schema = 'public' and table_name like 'timeline_%'
--   order by 1;
-- (timeline_event_fiches, timeline_events, timeline_items,
--  timeline_placements — timeline_items est l'ancien prototype, inutilisé)
-- ------------------------------------------------------------
