-- ============================================================
-- Atlas Géopolitique — schéma v6 : panneau "Apparence" (couleurs
-- de dégradé des indicateurs, couleurs des liens, couleurs de la
-- carte) — porté de settings/appearance (loadAppearance/saveAppearance,
-- ~4667-4665 dans l'artifact source), stocké côté Firestore comme un
-- document unique. Ici : une table à une seule ligne partagée par
-- tout le monde (id fixe 'appearance'), à l'image des autres réglages
-- globaux (group_categories, dossier_categories...).
-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1-v5 déjà en place)
-- ============================================================

create table if not exists public.app_settings (
  id text primary key,          -- ex: 'appearance' (une seule ligne pour ce réglage)
  value jsonb not null,
  updated_by uuid references public.profiles(id),
  updated_at timestamptz not null default now()
);

alter table public.app_settings enable row level security;

-- Lisible par tous (y compris anonymes) : nécessaire pour appliquer les
-- couleurs personnalisées dès le chargement de la carte, avant connexion.
create policy "app_settings_select_all" on public.app_settings for select using (true);

-- Modifiable par tout utilisateur connecté (réglage global partagé, pas de
-- propriétaire individuel — même principe que les catégories de groupes/
-- dossiers) ; ajustable plus tard vers public.is_admin() si Martin veut
-- réserver ce panneau aux administrateurs.
create policy "app_settings_upsert_auth" on public.app_settings for insert
  with check (auth.uid() is not null);
create policy "app_settings_update_auth" on public.app_settings for update
  using (auth.uid() is not null);
