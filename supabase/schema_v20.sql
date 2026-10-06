-- ============================================================
-- Atlas Géopolitique — schéma v20 (2026-10-06) : correspondance territoire
-- historique (carte "vue historique", OpenHistoricalMap) → fiche actuelle.
--
-- Deuxième "gros chantier" de Martin, 2026-10-06 : "Possibilité de faire la
-- carte historique, à la gaecron. [...] si par exemple je clique sur
-- l'empire britannique en 1500, je tombe sur la fiche de l'empire
-- britannique sur cette période" — clarifié ensuite : "Ça va renvoyer a un
-- pays, ex : Saint empire romain sera un élément présent dans Allemagne
-- => Histoire... Et quand je cliquerai sur la carte historique, ça
-- m'amènera ici."
--
-- OpenHistoricalMap (source des données de la carte historique, choisie
-- après recherche technique pour sa vraie continuité date par date — voir
-- src/historicalMap.ts) ne connaît rien du contenu de cet atlas : une
-- correspondance automatique par nom (comme pour les frises,
-- schema_v19.sql) ne trouvera qu'une partie des territoires historiques
-- (nomenclature OHM généralement en anglais, pas forcément alignée avec
-- les titres français de l'atlas). D'où, confirmé par Martin ("les deux",
-- même principe que les frises) : une table de correspondance MANUELLE,
-- construite progressivement par Martin au fil de ses découvertes sur la
-- carte historique, qui complète/prime sur l'auto-lien par nom.
--
-- territory_key : identifiant stable du territoire historique côté OHM.
-- On retient le NOM tel qu'il apparaît dans les tuiles OHM (propriété
-- `name` du feature), normalisé (minuscules, espaces compressés) plutôt
-- que l'id OSM/OHM brut de l'élément — un id OSM peut changer si la
-- géométrie est retouchée par un contributeur OHM, alors que le nom d'un
-- territoire historique change rarement une fois établi. Ambiguïté
-- acceptée (plusieurs territoires différents dans le temps peuvent
-- partager le même nom) : la correspondance s'applique alors à tous,
-- comme pour le lien par nom des frises/textes.
--
-- link_target : même forme JSON que timeline_items.link_target
-- (schema_v19.sql) et que les liens automatiques de texte (src/linkIndex.ts
-- ::LinkTarget) — réutilise donc tout le mécanisme de résolution de
-- navigation déjà en place (resolveLinkTarget, src/dossier.ts), pas de
-- nouveau code de navigation à écrire pour ce chantier.
--
-- "on delete" sans objet ici (link_target est un jsonb libre, pas une
-- clé étrangère) ; additive pure, RLS admin — même conventions que le
-- reste du schéma depuis schema_v13.
--
-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1-v19 déjà en
-- place)
-- ============================================================

create table if not exists public.historical_territory_links (
  id uuid primary key default gen_random_uuid(),
  territory_key text not null unique, -- nom OHM normalisé (minuscules, espaces compressés)
  link_target jsonb not null,
  note text, -- libre, ex. "Saint Empire romain germanique, 962-1806 — voir Allemagne > Histoire"
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create index if not exists historical_territory_links_key_idx
  on public.historical_territory_links (territory_key);

alter table public.historical_territory_links enable row level security;

create policy "historical_territory_links_select_all" on public.historical_territory_links
  for select using (true);
create policy "historical_territory_links_insert_admin" on public.historical_territory_links
  for insert with check (public.is_admin());
create policy "historical_territory_links_update_admin" on public.historical_territory_links
  for update using (public.is_admin());
create policy "historical_territory_links_delete_admin" on public.historical_territory_links
  for delete using (public.is_admin());

-- ============================================================
