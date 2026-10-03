-- ============================================================
-- Atlas Géopolitique — schéma v12 : dirigeants multiples par pays
-- (demande de Martin, 2026-10-03 : remplacer le champ texte libre
-- "Dirigeant" de la fiche pays par une liste — un dirigeant = un statut
-- + un nom, ex. "Président : Emmanuel Macron", "Première ministre : ...",
-- ajoutables/supprimables un par un via un bouton "+ Ajouter un
-- dirigeant").
--
-- public.countries.leader (texte libre, schema_v1.sql) reste en place
-- tel quel : on ne supprime aucune colonne existante dans ces migrations
-- (convention du projet). Il devient simplement obsolète côté
-- application, remplacée par cette nouvelle table. Les valeurs qui s'y
-- trouvaient déjà sont reprises ci-dessous (un seul dirigeant par pays,
-- statut générique "Dirigeant") pour ne rien perdre de ce que Martin a
-- déjà saisi.
--
-- Suit la même convention que public.genealogy_members /
-- public.genealogy_relations (schema_v11.sql) : lecture publique,
-- écriture/suppression ouvertes à tout compte connecté (politique du
-- site depuis schema_v8.sql — "tout compte inscrit peut éditer
-- directement").
-- ============================================================

create table if not exists public.country_leaders (
  id uuid primary key default gen_random_uuid(),
  country_id text not null references public.countries(id) on delete cascade,
  status text not null,   -- ex. "Président", "Premier ministre", "Roi"
  name text not null,
  position int not null default 0,  -- ordre d'affichage
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create index if not exists country_leaders_country_idx
  on public.country_leaders (country_id);

alter table public.country_leaders enable row level security;

create policy "country_leaders_select_all" on public.country_leaders
  for select using (true);
create policy "country_leaders_insert_auth" on public.country_leaders
  for insert with check (auth.uid() is not null);
create policy "country_leaders_update_auth" on public.country_leaders
  for update using (auth.uid() is not null);
create policy "country_leaders_delete_auth" on public.country_leaders
  for delete using (auth.uid() is not null);

-- Reprise des dirigeants déjà saisis dans l'ancien champ texte
-- public.countries.leader, un par pays, statut générique "Dirigeant".
-- Idempotent (évite les doublons si cette migration est rejouée) grâce
-- au "where not exists".
insert into public.country_leaders (country_id, status, name, position)
select c.id, 'Dirigeant', c.leader, 0
from public.countries c
where c.leader is not null
  and trim(c.leader) <> ''
  and not exists (
    select 1 from public.country_leaders cl where cl.country_id = c.id
  );
