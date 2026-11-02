-- ============================================================
-- Atlas Géopolitique — frises_v2 (2026-11-02) : RÈGNES sur les frises.
--
-- Demande de Martin (2026-11-02) : sur une frise de pays, un ruban « Règnes » montre qui règne à chaque
-- moment ; un clic mène à la fiche, à l'arbre généalogique du souverain, etc. Les dates de règne
-- ne sont PAS dans les arbres (seulement naissance/décès) : on les saisit ici, sur la frise, avec
-- leurs sources. Les arbres pourront ensuite les lire (table publique en lecture).
--
-- * timeline_reigns : un règne = (frise où il s'affiche, membre d'un arbre, titre, début, fin,
--   sources). Un membre peut avoir plusieurs règnes (Henri VI d'Angleterre, Charles Quint...).
--   fin NULL = règne en cours / fin inconnue (affiché ouvert jusqu'au bord de la frise).
--   sources = [{"label": "...", "url": "...", "academic": true|false}] ; l'appli marque un règne
--   « vérifié » seulement avec >= 2 sources dont une universitaire (barème docs/sources/README.md).
-- * Lecture publique ; écriture réservée aux administrateurs (is_admin()).
--
-- Nécessite schema_v27 à v31 et genealogy_members. Ne supprime rien ; idempotent.
-- ============================================================

create table if not exists public.timeline_reigns (
  id uuid primary key default gen_random_uuid(),
  frise_entry_id uuid not null references public.dossier_entries(id) on delete cascade,
  member_id uuid not null references public.genealogy_members(id) on delete cascade,
  title text,                                   -- ex. « Roi des Francs »
  start_year int not null,                      -- négatif = avant J.-C.
  start_month smallint check (start_month between 1 and 12),
  start_day smallint check (start_day between 1 and 31),
  start_circa boolean not null default false,
  end_year int,
  end_month smallint check (end_month between 1 and 12),
  end_day smallint check (end_day between 1 and 31),
  end_circa boolean not null default false,
  sources jsonb not null default '[]'::jsonb,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  constraint timeline_reigns_start_day_needs_month check (start_day is null or start_month is not null),
  constraint timeline_reigns_end_check check (
    (end_year is not null or (end_month is null and end_day is null))
    and (end_day is null or end_month is not null)
  )
);

create index if not exists timeline_reigns_frise_idx on public.timeline_reigns (frise_entry_id);
create index if not exists timeline_reigns_member_idx on public.timeline_reigns (member_id);

alter table public.timeline_reigns enable row level security;
drop policy if exists "timeline_reigns_select_all" on public.timeline_reigns;
drop policy if exists "timeline_reigns_admin_insert" on public.timeline_reigns;
drop policy if exists "timeline_reigns_admin_update" on public.timeline_reigns;
drop policy if exists "timeline_reigns_admin_delete" on public.timeline_reigns;
create policy "timeline_reigns_select_all" on public.timeline_reigns for select using (true);
create policy "timeline_reigns_admin_insert" on public.timeline_reigns for insert with check (public.is_admin());
create policy "timeline_reigns_admin_update" on public.timeline_reigns for update using (public.is_admin());
create policy "timeline_reigns_admin_delete" on public.timeline_reigns for delete using (public.is_admin());
