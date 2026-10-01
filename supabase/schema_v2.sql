-- ============================================================
-- Atlas Géopolitique — schéma v2 : compléments
-- À coller dans Supabase → SQL Editor → New query → Run
-- (s'ajoute au schéma v1 déjà en place, ne le remplace pas)
-- ============================================================

-- ------------------------------------------------------------
-- 1. Indicateurs (OWID) : catégories + valeurs par pays/année
-- ------------------------------------------------------------
create table public.indicator_categories (
  id text primary key,        -- ex: 'demographie', 'economie', 'militaire'
  label text not null,
  position int not null default 0
);

create table public.indicators (
  id text primary key,        -- ex: 'population_totale'
  category_id text references public.indicator_categories(id) on delete cascade,
  label text not null,
  unit text,
  decimals int not null default 0,
  position int not null default 0
);

create table public.indicator_values (
  indicator_id text references public.indicators(id) on delete cascade,
  country_id text references public.countries(id) on delete cascade,
  value numeric,
  year int,
  primary key (indicator_id, country_id)
);

-- ------------------------------------------------------------
-- 2. Groupes géopolitiques (UE, OTAN, ONU...) + appartenance
-- ------------------------------------------------------------
create table public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  color text not null default '#e8b34a',
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.group_members (
  group_id uuid references public.groups(id) on delete cascade,
  country_id text references public.countries(id) on delete cascade,
  primary key (group_id, country_id)
);

-- ------------------------------------------------------------
-- 3. Liens entre pays (diplomatie / conflit / économie / culture / autre)
-- ------------------------------------------------------------
create table public.country_links (
  id uuid primary key default gen_random_uuid(),
  country_a text references public.countries(id) on delete cascade,
  country_b text references public.countries(id) on delete cascade,
  category text not null check (category in ('diplomatie','conflit','economie','culture','autre')),
  label text,
  start_date date,
  end_date date,
  visible boolean not null default true,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 4. Éléments géographiques ponctuels/linéaires
--    (ports, détroits, bases militaires, câbles, pipelines)
-- ------------------------------------------------------------
create table public.map_features (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('port','strait','base','cable','pipeline')),
  name text not null,
  subtype text,                    -- ex: pipeline 'gaz' | 'petrole'
  geometry jsonb not null,          -- GeoJSON (Point ou LineString)
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

-- ============================================================
-- Sécurité (RLS) : même logique que le schéma v1
-- ============================================================
alter table public.indicator_categories enable row level security;
alter table public.indicators enable row level security;
alter table public.indicator_values enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.country_links enable row level security;
alter table public.map_features enable row level security;

-- Indicateurs : référence, lecture publique, écriture admin seulement
create policy "indicator_categories_select_all" on public.indicator_categories for select using (true);
create policy "indicator_categories_admin_write" on public.indicator_categories for all
  using (public.is_admin()) with check (public.is_admin());

create policy "indicators_select_all" on public.indicators for select using (true);
create policy "indicators_admin_write" on public.indicators for all
  using (public.is_admin()) with check (public.is_admin());

create policy "indicator_values_select_all" on public.indicator_values for select using (true);
create policy "indicator_values_admin_write" on public.indicator_values for all
  using (public.is_admin()) with check (public.is_admin());

-- Groupes : lecture publique, création par tout connecté, modif/suppr par créateur ou admin
create policy "groups_select_all" on public.groups for select using (true);
create policy "groups_insert_auth" on public.groups for insert with check (auth.uid() is not null);
create policy "groups_modify_own_or_admin" on public.groups for update
  using (created_by = auth.uid() or public.is_admin());
create policy "groups_delete_own_or_admin" on public.groups for delete
  using (created_by = auth.uid() or public.is_admin());

create policy "group_members_select_all" on public.group_members for select using (true);
create policy "group_members_write_auth" on public.group_members for all
  using (auth.uid() is not null) with check (auth.uid() is not null);

-- Liens entre pays : même logique que groupes
create policy "country_links_select_all" on public.country_links for select using (true);
create policy "country_links_insert_auth" on public.country_links for insert with check (auth.uid() is not null);
create policy "country_links_modify_own_or_admin" on public.country_links for update
  using (created_by = auth.uid() or public.is_admin());
create policy "country_links_delete_own_or_admin" on public.country_links for delete
  using (created_by = auth.uid() or public.is_admin());

-- Éléments géographiques : même logique
create policy "map_features_select_all" on public.map_features for select using (true);
create policy "map_features_insert_auth" on public.map_features for insert with check (auth.uid() is not null);
create policy "map_features_modify_own_or_admin" on public.map_features for update
  using (created_by = auth.uid() or public.is_admin());
create policy "map_features_delete_own_or_admin" on public.map_features for delete
  using (created_by = auth.uid() or public.is_admin());
