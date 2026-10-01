-- ============================================================
-- Atlas Géopolitique — schéma v7 : liens entre pays/groupes
-- (diplomatie/conflit/économie/culture/autre), porté de linkDocs/
-- LINKABLE_KINDS (~3371, 3449, 9686-9922 dans l'artifact source).
-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1-v6 déjà en place)
-- ============================================================

-- ------------------------------------------------------------
-- La table public.country_links existait déjà (schéma v2) mais avec
-- country_a/country_b en `text references countries(id)` : cela ne
-- permet QUE des liens pays↔pays. Or l'artifact source permet aussi
-- des liens pays↔groupe et groupe↔groupe (LINKABLE_KINDS = new
-- Set(['country', 'group']), vérifié dans le source : un lien a deux
-- extrémités { kind: 'country'|'group', id, label }, pas seulement
-- deux pays.
--
-- On ajoute donc des colonnes génériques entity_a_*/entity_b_*
-- (kind + id + label, ce dernier reprenant a.label/b.label de
-- l'artifact — le libellé mémorisé au moment de la création du lien,
-- utilisé en priorité par l'appli avant de retomber sur un lookup
-- live) plutôt que de modifier country_a/country_b, qui restent en
-- place (inutilisés par le nouveau code, mais rien n'est supprimé).
--
-- start_date/end_date passent de `date` à `text` : l'artifact stocke
-- des chaînes libres («1957», «-500» pour une date av. J.-C., «en
-- cours» implicite si vide — cf. linkYearBounds, regex /-?\d{3,4}/),
-- pas de vraies dates ISO. Comme la fonctionnalité n'a jamais été
-- branchée à une interface jusqu'ici, la table est vide : cette
-- conversion de type est sans risque de perte de données.
-- ------------------------------------------------------------

alter table public.country_links
  alter column start_date type text using start_date::text;
alter table public.country_links
  alter column end_date type text using end_date::text;

alter table public.country_links add column if not exists description text;
alter table public.country_links add column if not exists entity_a_kind text not null default 'country' check (entity_a_kind in ('country','group'));
alter table public.country_links add column if not exists entity_a_id text;
alter table public.country_links add column if not exists entity_a_label text;
alter table public.country_links add column if not exists entity_b_kind text not null default 'country' check (entity_b_kind in ('country','group'));
alter table public.country_links add column if not exists entity_b_id text;
alter table public.country_links add column if not exists entity_b_label text;

-- Reprend les éventuelles lignes déjà posées via country_a/country_b
-- (pas de perte si la table contenait déjà des liens pays↔pays).
update public.country_links
  set entity_a_id = country_a
  where entity_a_id is null and country_a is not null;
update public.country_links
  set entity_b_id = country_b
  where entity_b_id is null and country_b is not null;

create index if not exists country_links_entity_a_idx on public.country_links(entity_a_kind, entity_a_id);
create index if not exists country_links_entity_b_idx on public.country_links(entity_b_kind, entity_b_id);

-- RLS déjà en place depuis le schéma v2 (country_links_select_all /
-- _insert_auth / _modify_own_or_admin / _delete_own_or_admin) :
-- s'applique telle quelle aux nouvelles colonnes, rien à ajouter.

-- ------------------------------------------------------------
-- Préférence "Afficher les liens de ce pays sur la carte" (case à
-- cocher de la fiche pays, cochée par défaut) — porté du champ
-- countryDocs[id].linksHidden de l'artifact (~8368, 8477, 9429-9431).
-- Écriture alignée sur countries_auth_update (schéma v4, tout
-- utilisateur connecté) : pas de nouvelle policy nécessaire.
-- ------------------------------------------------------------
alter table public.countries add column if not exists links_hidden boolean not null default false;
