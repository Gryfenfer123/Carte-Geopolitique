-- ============================================================
-- Atlas Géopolitique — schéma v24 (2026-10-12) : statuts CUMULÉS (plusieurs
-- anneaux concentriques) autour d'un membre, au lieu d'un seul anneau.
--
-- Demande de Martin : "il faut que les statuts se cumulent autour du
-- personnage, si il a un statut qui l'entoure en vert par exemple, puis
-- que j'indique 'a gouverné le pays', il doit être entouré en vert et
-- autour en rouge." Précisions : pas de limite de statuts cumulables,
-- l'ordre des anneaux est celui d'ajout (le plus récent le plus à
-- l'extérieur), MAIS l'anneau rouge "A dirigé le pays" (case
-- genealogy_members.is_leader / genealogy_foreign_states.is_leader,
-- EXISTANTE, pas un nouveau statut) doit TOUJOURS être l'anneau le plus
-- extérieur de tous, peu importe quand il a été cochée. Toujours propre à
-- CHAQUE ARBRE (comme l'anneau unique actuel) : un membre étranger peut
-- avoir des statuts différents selon l'arbre depuis lequel on le regarde.
--
-- jusqu'ici, un membre n'avait qu'UN SEUL anneau de statut
-- (genealogy_members.legend_item_id pour un membre local,
-- genealogy_foreign_states.legend_item_id pour un membre étranger vu
-- depuis cet arbre, schema_v17.sql). Cette table remplace ces deux
-- colonnes par une relation plusieurs-à-plusieurs : un (membre, arbre
-- visiteur) peut désormais avoir N statuts, chacun avec sa position
-- d'ajout (les anneaux sont dessinés dans cet ordre, du plus proche de la
-- photo au plus extérieur — avant l'anneau rouge "A dirigé le pays" qui
-- reste géré séparément, voir plus haut).
--
-- owner_type/owner_id ici désigne TOUJOURS l'arbre depuis lequel on
-- regarde le membre (le "arbre visiteur") — pour un membre local, c'est
-- son propre arbre (= owner_type/owner_id de sa ligne genealogy_members) ;
-- pour un membre étranger, c'est l'arbre qui l'affiche via un lien (même
-- paire que genealogy_foreign_states). Un seul type de requête suffit
-- donc pour charger tous les statuts d'un arbre donné, qu'ils concernent
-- des membres locaux ou étrangers.
--
-- Les anciennes colonnes genealogy_members.legend_item_id et
-- genealogy_foreign_states.legend_item_id ne sont PAS supprimées ici
-- (prudence — rien n'est supprimé de ce qui existe déjà) mais ne sont
-- plus lues/écrites par le code à partir de cette version : leur contenu
-- est recopié ci-dessous dans la nouvelle table (position 0) pour que
-- rien ne se perde au passage.
--
-- Testé localement avant livraison (base de test disposable, scénarios
-- "jamais appliqué" et "déjà appliqué" — rerun sans effet la deuxième
-- fois, aucune duplication).
--
-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1-v23 déjà en
-- place)
-- ============================================================

create table if not exists public.genealogy_member_statuses (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.genealogy_members(id) on delete cascade,
  owner_type text not null,
  owner_id text not null,
  legend_item_id uuid not null references public.genealogy_legend_items(id) on delete cascade,
  position int not null default 0,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  unique (member_id, owner_type, owner_id, legend_item_id)
);

create index if not exists genealogy_member_statuses_scope_idx
  on public.genealogy_member_statuses (owner_type, owner_id);
create index if not exists genealogy_member_statuses_member_idx
  on public.genealogy_member_statuses (member_id);

alter table public.genealogy_member_statuses enable row level security;

-- Même régime que le reste de l'arbre généalogique depuis schema_v13 :
-- lecture publique, écriture réservée aux admins.
drop policy if exists "genealogy_member_statuses_select_all" on public.genealogy_member_statuses;
drop policy if exists "genealogy_member_statuses_insert_admin" on public.genealogy_member_statuses;
drop policy if exists "genealogy_member_statuses_update_admin" on public.genealogy_member_statuses;
drop policy if exists "genealogy_member_statuses_delete_admin" on public.genealogy_member_statuses;
create policy "genealogy_member_statuses_select_all" on public.genealogy_member_statuses
  for select using (true);
create policy "genealogy_member_statuses_insert_admin" on public.genealogy_member_statuses
  for insert with check (public.is_admin());
create policy "genealogy_member_statuses_update_admin" on public.genealogy_member_statuses
  for update using (public.is_admin());
create policy "genealogy_member_statuses_delete_admin" on public.genealogy_member_statuses
  for delete using (public.is_admin());

-- ------------------------------------------------------------
-- Backfill : recopie l'anneau unique existant d'un membre LOCAL
-- (genealogy_members.legend_item_id, owner_type/owner_id = sa propre
-- ligne) en position 0 — idempotent grâce à la contrainte unique
-- ci-dessus (on conflict do nothing : un second passage ne duplique rien
-- et ne touche pas à une réorganisation déjà faite à la main depuis).
-- ------------------------------------------------------------
insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position)
select gm.id, gm.owner_type, gm.owner_id, gm.legend_item_id, 0
from public.genealogy_members gm
where gm.legend_item_id is not null
on conflict (member_id, owner_type, owner_id, legend_item_id) do nothing;

-- ------------------------------------------------------------
-- Backfill : recopie l'anneau unique existant d'un membre ÉTRANGER, vu
-- depuis CET arbre visiteur (genealogy_foreign_states.legend_item_id).
-- ------------------------------------------------------------
insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position)
select gfs.member_id, gfs.owner_type, gfs.owner_id, gfs.legend_item_id, 0
from public.genealogy_foreign_states gfs
where gfs.legend_item_id is not null
on conflict (member_id, owner_type, owner_id, legend_item_id) do nothing;

-- ============================================================
