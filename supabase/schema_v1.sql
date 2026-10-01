-- ============================================================
-- Atlas Géopolitique — schéma initial (v1)
-- À coller dans Supabase → SQL Editor → New query → Run
-- ============================================================

-- Extension nécessaire pour générer des identifiants uuid
create extension if not exists "pgcrypto";

-- ------------------------------------------------------------
-- 1. Profils utilisateurs
--    Étend la table interne auth.users gérée par Supabase Auth.
--    role: 'admin' (toi) ou 'contributor' (tout compte créé).
-- ------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  role text not null default 'contributor' check (role in ('admin','contributor')),
  created_at timestamptz not null default now()
);

-- Crée automatiquement un profil "contributor" à chaque inscription
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (new.id, split_part(new.email, '@', 1));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Fonction utilitaire : l'utilisateur connecté est-il admin ?
create function public.is_admin()
returns boolean
language sql
security definer set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ------------------------------------------------------------
-- 2. Pays (données de référence, saisies une fois par un admin)
-- ------------------------------------------------------------
create table public.countries (
  id text primary key,           -- code ISO A3, ex: 'FRA'
  name_fr text not null,
  continent text,
  capital text
);

-- ------------------------------------------------------------
-- 3. Catégories de dossier (globales, partagées)
--    space: 'country' (dossiers pays) ou 'encyclopedie'
-- ------------------------------------------------------------
create table public.dossier_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  space text not null default 'country' check (space in ('country','encyclopedie')),
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 4. Sous-sections (imbriquées, jusqu'à 3 niveaux)
--    owner_type/owner_id identifient à qui appartient la section :
--    ('country','FRA'), ('encyclopedie','encyclopedie'), ('group','<id>')
-- ------------------------------------------------------------
create table public.dossier_sections (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.dossier_categories(id) on delete cascade,
  owner_type text not null check (owner_type in ('country','encyclopedie','group')),
  owner_id text not null,
  parent_section_id uuid references public.dossier_sections(id) on delete cascade,
  title text not null,
  cover_image_url text,
  collapsed boolean not null default false,
  position int not null default 0,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 5. Entrées de dossier (texte / photo / lien / hémicycle)
-- ------------------------------------------------------------
create table public.dossier_entries (
  id uuid primary key default gen_random_uuid(),
  section_id uuid references public.dossier_sections(id) on delete cascade,
  category_id uuid references public.dossier_categories(id) on delete cascade,
  owner_type text not null check (owner_type in ('country','encyclopedie','group')),
  owner_id text not null,
  type text not null check (type in ('text','photo','link','hemicycle')),
  title text,
  body_html text,        -- contenu riche assaini, pour type='text'
  photo_url text,        -- pour type='photo'
  link_url text,          -- pour type='link'
  hemicycle_data jsonb,   -- pour type='hemicycle' : {totalSeats, parties:[...]}
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- Sécurité (RLS) : lecture publique, écriture selon le rôle
-- ============================================================
alter table public.profiles enable row level security;
alter table public.countries enable row level security;
alter table public.dossier_categories enable row level security;
alter table public.dossier_sections enable row level security;
alter table public.dossier_entries enable row level security;

-- Profils : tout le monde peut lire (pour afficher "créé par X"),
-- chacun modifie son propre profil mais ne peut pas changer son role.
create policy "profiles_select_all" on public.profiles for select using (true);
create policy "profiles_update_self" on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id and role = (select role from public.profiles where id = auth.uid()));

-- Pays : lecture publique, écriture réservée aux admins.
create policy "countries_select_all" on public.countries for select using (true);
create policy "countries_admin_write" on public.countries for all
  using (public.is_admin()) with check (public.is_admin());

-- Catégories : lecture publique, création par tout utilisateur connecté,
-- modification/suppression réservées aux admins (évite le chaos sur une liste globale).
create policy "categories_select_all" on public.dossier_categories for select using (true);
create policy "categories_insert_auth" on public.dossier_categories for insert
  with check (auth.uid() is not null);
create policy "categories_admin_modify" on public.dossier_categories for update
  using (public.is_admin());
create policy "categories_admin_delete" on public.dossier_categories for delete
  using (public.is_admin());

-- Sections : lecture publique ; un utilisateur connecté peut créer ;
-- il peut modifier/supprimer ce qu'il a créé, un admin peut tout modifier/supprimer.
create policy "sections_select_all" on public.dossier_sections for select using (true);
create policy "sections_insert_auth" on public.dossier_sections for insert
  with check (auth.uid() is not null);
create policy "sections_modify_own_or_admin" on public.dossier_sections for update
  using (created_by = auth.uid() or public.is_admin());
create policy "sections_delete_own_or_admin" on public.dossier_sections for delete
  using (created_by = auth.uid() or public.is_admin());

-- Entrées : même logique que les sections.
create policy "entries_select_all" on public.dossier_entries for select using (true);
create policy "entries_insert_auth" on public.dossier_entries for insert
  with check (auth.uid() is not null);
create policy "entries_modify_own_or_admin" on public.dossier_entries for update
  using (created_by = auth.uid() or public.is_admin());
create policy "entries_delete_own_or_admin" on public.dossier_entries for delete
  using (created_by = auth.uid() or public.is_admin());
