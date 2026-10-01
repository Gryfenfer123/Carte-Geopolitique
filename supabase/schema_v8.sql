-- ============================================================
-- Atlas Géopolitique — schéma v8 : édition ouverte à tout compte connecté
-- (retour de Martin, 2026-10-01 : "tout compte inscrit peut éditer
-- directement" — on abandonne la distinction admin / "propriétaire de
-- la ligne", qui limitait certaines modifications/suppressions aux
-- seuls admins ou au créateur d'origine. Tout utilisateur connecté a
-- désormais les mêmes droits d'édition sur tout le contenu.)
-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1-v7 déjà en place)
-- ============================================================

-- ------------------------------------------------------------
-- Catégories de dossier (thèmes) : renommer/supprimer une catégorie
-- non "builtin" était réservé aux admins (schéma v4) ; ouvert à tout
-- utilisateur connecté.
-- ------------------------------------------------------------
drop policy if exists "categories_admin_modify" on public.dossier_categories;
create policy "categories_auth_modify" on public.dossier_categories for update
  using (auth.uid() is not null);
drop policy if exists "categories_admin_delete" on public.dossier_categories;
create policy "categories_auth_delete" on public.dossier_categories for delete
  using (auth.uid() is not null);

-- ------------------------------------------------------------
-- Sections/entrées de dossier : modifier/supprimer était réservé au
-- créateur de la ligne ou à un admin ; ouvert à tout utilisateur
-- connecté (n'importe qui peut désormais éditer le travail de
-- n'importe qui d'autre, comme dans l'artifact d'origine où tout se
-- jouait dans une base partagée sans notion de "propriétaire").
-- ------------------------------------------------------------
drop policy if exists "sections_modify_own_or_admin" on public.dossier_sections;
create policy "sections_auth_modify" on public.dossier_sections for update
  using (auth.uid() is not null);
drop policy if exists "sections_delete_own_or_admin" on public.dossier_sections;
create policy "sections_auth_delete" on public.dossier_sections for delete
  using (auth.uid() is not null);

drop policy if exists "entries_modify_own_or_admin" on public.dossier_entries;
create policy "entries_auth_modify" on public.dossier_entries for update
  using (auth.uid() is not null);
drop policy if exists "entries_delete_own_or_admin" on public.dossier_entries;
create policy "entries_auth_delete" on public.dossier_entries for delete
  using (auth.uid() is not null);

-- ------------------------------------------------------------
-- Groupes / catégories de groupes / liens pays-groupes / éléments de
-- carte (POI) : même logique, "own_or_admin" -> "tout connecté".
-- ------------------------------------------------------------
drop policy if exists "groups_modify_own_or_admin" on public.groups;
create policy "groups_auth_modify" on public.groups for update
  using (auth.uid() is not null);
drop policy if exists "groups_delete_own_or_admin" on public.groups;
create policy "groups_auth_delete" on public.groups for delete
  using (auth.uid() is not null);

drop policy if exists "group_categories_modify_own_or_admin" on public.group_categories;
create policy "group_categories_auth_modify" on public.group_categories for update
  using (auth.uid() is not null);
drop policy if exists "group_categories_delete_own_or_admin" on public.group_categories;
create policy "group_categories_auth_delete" on public.group_categories for delete
  using (auth.uid() is not null);

drop policy if exists "country_links_modify_own_or_admin" on public.country_links;
create policy "country_links_auth_modify" on public.country_links for update
  using (auth.uid() is not null);
drop policy if exists "country_links_delete_own_or_admin" on public.country_links;
create policy "country_links_auth_delete" on public.country_links for delete
  using (auth.uid() is not null);

drop policy if exists "map_features_modify_own_or_admin" on public.map_features;
create policy "map_features_auth_modify" on public.map_features for update
  using (auth.uid() is not null);
drop policy if exists "map_features_delete_own_or_admin" on public.map_features;
create policy "map_features_auth_delete" on public.map_features for delete
  using (auth.uid() is not null);

-- ------------------------------------------------------------
-- Indicateurs (catégories / indicateurs / valeurs) : entièrement
-- réservés aux admins depuis le schéma v2 ("for all" avec is_admin()).
-- Remplacés par des policies séparées insert/update/delete ouvertes à
-- tout utilisateur connecté (le select_all existant reste inchangé).
-- ------------------------------------------------------------
drop policy if exists "indicator_categories_admin_write" on public.indicator_categories;
create policy "indicator_categories_auth_insert" on public.indicator_categories for insert
  with check (auth.uid() is not null);
create policy "indicator_categories_auth_update" on public.indicator_categories for update
  using (auth.uid() is not null);
create policy "indicator_categories_auth_delete" on public.indicator_categories for delete
  using (auth.uid() is not null);

drop policy if exists "indicators_admin_write" on public.indicators;
create policy "indicators_auth_insert" on public.indicators for insert
  with check (auth.uid() is not null);
create policy "indicators_auth_update" on public.indicators for update
  using (auth.uid() is not null);
create policy "indicators_auth_delete" on public.indicators for delete
  using (auth.uid() is not null);

drop policy if exists "indicator_values_admin_write" on public.indicator_values;
create policy "indicator_values_auth_insert" on public.indicator_values for insert
  with check (auth.uid() is not null);
create policy "indicator_values_auth_update" on public.indicator_values for update
  using (auth.uid() is not null);
create policy "indicator_values_auth_delete" on public.indicator_values for delete
  using (auth.uid() is not null);

-- ------------------------------------------------------------
-- Photos de dossier (bucket storage "dossier-photos") : modifier/
-- supprimer une photo était réservé à son auteur (owner = auth.uid()) ;
-- ouvert à tout utilisateur connecté.
-- ------------------------------------------------------------
drop policy if exists "dossier_photos_owner_update" on storage.objects;
create policy "dossier_photos_auth_update" on storage.objects for update
  using (bucket_id = 'dossier-photos' and auth.uid() is not null);
drop policy if exists "dossier_photos_owner_delete" on storage.objects;
create policy "dossier_photos_auth_delete" on storage.objects for delete
  using (bucket_id = 'dossier-photos' and auth.uid() is not null);

-- ------------------------------------------------------------
-- NB : les policies "_select_all" (lecture publique, sans connexion)
-- et "_insert_auth" (création réservée aux connectés) des schémas
-- précédents restent inchangées et correctes avec ce nouveau modèle.
-- La colonne profiles.role ('contributor'/'admin') et la fonction
-- public.is_admin() restent en place (plus utilisées par ces policies,
-- mais rien ne les supprime : Martin peut les remettre en service plus
-- tard s'il veut réintroduire une distinction de droits).
-- ------------------------------------------------------------
