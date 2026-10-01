-- ============================================================
-- Atlas Géopolitique — schéma v5 : hémicycles + groupes
-- géopolitiques + indicateurs OWID + Encyclopédie.
-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1-v4 déjà en place)
-- ============================================================

-- ------------------------------------------------------------
-- 1. Hémicycles : AUCUNE colonne manquante — dossier_entries.type
--    accepte déjà 'hemicycle' et dossier_entries.hemicycle_data jsonb
--    existe depuis le schéma v1. Rien à ajouter ici.
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 2. Groupes géopolitiques : catégories de groupes (item manquant du
--    schéma v2, qui n'avait que public.groups/public.group_members
--    sans notion de catégorie — cf. ORG_GROUP_CATEGORIES/groupCategoryId
--    dans l'artifact source).
-- ------------------------------------------------------------
create table if not exists public.group_categories (
  id text primary key,          -- ex: 'gcat-institutions' (repris tel quel des id de l'artifact pour les 4 catégories de base)
  name text not null,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

alter table public.groups add column if not exists category_id text references public.group_categories(id);

alter table public.group_categories enable row level security;
create policy "group_categories_select_all" on public.group_categories for select using (true);
create policy "group_categories_insert_auth" on public.group_categories for insert
  with check (auth.uid() is not null);
create policy "group_categories_modify_own_or_admin" on public.group_categories for update
  using (created_by = auth.uid() or public.is_admin());
create policy "group_categories_delete_own_or_admin" on public.group_categories for delete
  using (created_by = auth.uid() or public.is_admin());

-- ------------------------------------------------------------
-- 3. Encyclopédie : chaque « notion » est une sous-section (niveau 2)
--    du dossier owner_type='encyclopedie', avec une éventuelle liste
--    de pays de référence associés (countries[], cf. notionDocs[id].
--    countries dans l'artifact — NOTIONS_SEED.json) — colonne absente
--    du schéma v1 (qui ne portait que category_id/parent_section_id/
--    title/cover_image_url/collapsed/position).
-- ------------------------------------------------------------
alter table public.dossier_sections add column if not exists countries text[] not null default '{}';

-- ------------------------------------------------------------
-- 4. Indicateurs OWID : les tables indicator_categories/indicators/
--    indicator_values existent déjà (schéma v2) mais restent VIDES —
--    ce portage charge OWID_CATEGORIES.json/OWID_DATA.json directement
--    en statique côté client (même principe que SOV.json/FR_NAMES.json
--    pour les frontières/noms de pays), car ce sont des données de
--    référence figées, non éditables par les utilisateurs. Les tables
--    Supabase existantes restent disponibles pour une future bascule
--    vers une édition collaborative de ces indicateurs, mais rien à
--    ajouter ici pour ce portage.
-- ------------------------------------------------------------
