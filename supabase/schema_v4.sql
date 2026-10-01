-- ============================================================
-- Atlas Géopolitique — schéma v4 : fiche pays + système de dossier
-- (catégories/sections/entrées texte-photo-lien, historique, favoris,
-- étiquettes, sources) — colonnes manquantes pour porter fidèlement
-- l'ancienne fiche/dossier de l'artifact d'origine.
-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1/v2/v3 déjà en place)
-- ============================================================

-- ------------------------------------------------------------
-- 1. Fiche pays (panneau "fiche" : infos clés / dirigeant / notes)
--    Champs absents du schéma v1 (qui ne portait que les données de
--    référence name_fr/continent/capital, saisies "une fois par un
--    admin"). Le panneau fiche est collaboratif dans l'artifact
--    d'origine (n'importe quel utilisateur connecté peut le remplir/
--    corriger, pas seulement un admin) : on aligne donc l'écriture sur
--    ce même modèle "auth.uid() non nul", au lieu du admin-only
--    hérité du schéma v1 pour les colonnes de référence.
-- ------------------------------------------------------------
alter table public.countries add column if not exists key_info text;
alter table public.countries add column if not exists notes text;
alter table public.countries add column if not exists leader text;
alter table public.countries add column if not exists updated_at timestamptz;

drop policy if exists "countries_admin_write" on public.countries;
create policy "countries_auth_insert" on public.countries for insert
  with check (auth.uid() is not null);
create policy "countries_auth_update" on public.countries for update
  using (auth.uid() is not null) with check (auth.uid() is not null);

-- ------------------------------------------------------------
-- 2. Catégories de dossier : distinguer les 6 catégories de base
--    (Histoire/Politique/Géographie/Actualité/Droit/Culture générale —
--    non renommables/supprimables, cf. dossierCategoryDocs[id].builtin
--    dans l'artifact) des catégories créées par les utilisateurs.
-- ------------------------------------------------------------
alter table public.dossier_categories add column if not exists builtin boolean not null default false;

-- ------------------------------------------------------------
-- 3. Entrées de dossier : champs portés de l'artifact, absents du
--    schéma v1 (qui ne couvrait que title/body_html/photo_url/link_url/
--    hemicycle_data).
-- ------------------------------------------------------------
alter table public.dossier_entries add column if not exists caption text;               -- légende de photo
alter table public.dossier_entries add column if not exists link_label text;             -- libellé affiché pour type='link'
alter table public.dossier_entries add column if not exists tags text[] not null default '{}';
alter table public.dossier_entries add column if not exists sources jsonb not null default '[]'::jsonb;   -- [{label,url}]
alter table public.dossier_entries add column if not exists favorite boolean not null default false;
alter table public.dossier_entries add column if not exists status text not null default 'published' check (status in ('draft','published'));
alter table public.dossier_entries add column if not exists history jsonb not null default '[]'::jsonb;   -- versions archivées (DOSSIER_HISTORY_FIELDS)

-- ------------------------------------------------------------
-- 4. Stockage des photos de dossier (bucket public en lecture, écriture
--    réservée aux utilisateurs connectés — remplace la capacité
--    `assets` propre à l'artefact Claude d'origine).
-- ------------------------------------------------------------
insert into storage.buckets (id, name, public)
  values ('dossier-photos', 'dossier-photos', true)
  on conflict (id) do nothing;

create policy "dossier_photos_read_all" on storage.objects for select
  using (bucket_id = 'dossier-photos');
create policy "dossier_photos_auth_insert" on storage.objects for insert
  with check (bucket_id = 'dossier-photos' and auth.uid() is not null);
create policy "dossier_photos_owner_update" on storage.objects for update
  using (bucket_id = 'dossier-photos' and owner = auth.uid());
create policy "dossier_photos_owner_delete" on storage.objects for delete
  using (bucket_id = 'dossier-photos' and owner = auth.uid());
