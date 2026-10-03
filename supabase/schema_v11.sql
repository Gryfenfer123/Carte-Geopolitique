-- ============================================================
-- Atlas Géopolitique — schéma v11 : arbres généalogiques (dynasties)
-- (demande de Martin, 2026-10-03 : "ajouter des membres, faire un
-- truc bien interactif... zoomable, avec photo, possibilité de se
-- balader dedans en glissant, avec des liens entre tous, et montrer
-- les croisements entre plusieurs pays").
--
-- Organisation retenue (confirmée par Martin) : un arbre par pays,
-- rattaché à son dossier via owner_type/owner_id (même convention que
-- dossier_sections/dossier_entries), mais les RELATIONS entre deux
-- membres peuvent pointer vers un membre d'un AUTRE pays (mariage
-- royal franco-anglais, etc.) — member_a_id/member_b_id sont de
-- simples clés étrangères vers genealogy_members, sans contrainte de
-- même owner_id des deux côtés, exprès pour permettre ces liens
-- transnationaux.
--
-- genealogy_members : une personne sur l'arbre.
-- - owner_type/owner_id : à quel dossier (pays/groupe/Encyclopédie)
--   cette personne est rattachée pour l'affichage (son arbre
--   "d'origine" — une personne liée depuis un autre pays n'est pas
--   dupliquée, juste reliée par une ligne qui traverse les arbres).
-- - pos_x/pos_y : position libre sur le canevas (glisser-déposer),
--   en pixels à l'échelle 1 (zoom appliqué uniquement à l'affichage).
-- - photo_url : même bucket Supabase Storage "dossier-photos" que les
--   autres images du dossier (categories/sections/entrées), chemin
--   "genealogy/<ownerType>-<ownerId>/<memberId>-....".
--
-- genealogy_relations : un lien entre deux membres (parent/enfant ou
-- conjoint·e). relation_type = 'parent' signifie member_a_id est le
-- parent de member_b_id ; 'spouse' est symétrique (sens indifférent).
-- ============================================================

create table if not exists public.genealogy_members (
  id uuid primary key default gen_random_uuid(),
  owner_type text not null,
  owner_id text not null,
  name text not null,
  photo_url text,
  birth_year integer,
  death_year integer,
  title text,
  dynasty text,
  bio text,
  pos_x double precision not null default 0,
  pos_y double precision not null default 0,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table if not exists public.genealogy_relations (
  id uuid primary key default gen_random_uuid(),
  member_a_id uuid not null references public.genealogy_members(id) on delete cascade,
  member_b_id uuid not null references public.genealogy_members(id) on delete cascade,
  relation_type text not null default 'parent' check (relation_type in ('parent', 'spouse')),
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create index if not exists genealogy_members_owner_idx
  on public.genealogy_members (owner_type, owner_id);
create index if not exists genealogy_relations_a_idx
  on public.genealogy_relations (member_a_id);
create index if not exists genealogy_relations_b_idx
  on public.genealogy_relations (member_b_id);

alter table public.genealogy_members enable row level security;
alter table public.genealogy_relations enable row level security;

-- Lecture publique, écriture ouverte à tout compte connecté — même
-- régime que le reste du dossier depuis le schéma v8.
create policy "genealogy_members_select_all" on public.genealogy_members
  for select using (true);
create policy "genealogy_members_insert_auth" on public.genealogy_members
  for insert with check (auth.uid() is not null);
create policy "genealogy_members_update_auth" on public.genealogy_members
  for update using (auth.uid() is not null);
create policy "genealogy_members_delete_auth" on public.genealogy_members
  for delete using (auth.uid() is not null);

create policy "genealogy_relations_select_all" on public.genealogy_relations
  for select using (true);
create policy "genealogy_relations_insert_auth" on public.genealogy_relations
  for insert with check (auth.uid() is not null);
create policy "genealogy_relations_update_auth" on public.genealogy_relations
  for update using (auth.uid() is not null);
create policy "genealogy_relations_delete_auth" on public.genealogy_relations
  for delete using (auth.uid() is not null);

-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1-v10 déjà en place)
