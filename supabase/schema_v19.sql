-- ============================================================
-- Atlas Géopolitique — schéma v19 (2026-10-06) : frises chronologiques.
--
-- Demande de Martin : "Rajouter la possibilité de créer des frises
-- chronologiques, un peu sur le même système que les arbres
-- généalogiques, mais donc une frise. Chaque frise avec ses dates, et
-- très important, l'intérêt est de rajouter des étapes sur la frise,
-- soit un point (ex : traité de Verdun) ou une période entre 2 dates
-- (ex : Saint Empire germanique). [...] les éléments des frises doivent
-- êtres reliés à la fiche ou catégorie correspondante."
--
-- Conception retenue (confirmée par Martin) :
-- - "Possibilité de faire une frise par entrée, MAIS une frise globale
--   se construit, en mettant tout bout à bout, et si je clique sur la
--   partie d'une frise dans la frise globale, je suis amené vers la
--   frise de l'entrée spécifique" : EXACTEMENT la même convention que
--   genealogy_members — owner_type/owner_id identifie la frise (ici
--   toujours owner_type = 'entry', owner_id = l'id de l'entrée dossier
--   de type "frise"). Il n'y a donc pas de table "frises" séparée : une
--   frise, c'est simplement l'ensemble des timeline_items qui partagent
--   le même (owner_type, owner_id). La "frise globale" (vue fusionnée
--   de TOUTES les frises) est une requête côté client sur toute la
--   table, triée chronologiquement — pas besoin de structure dédiée en
--   base.
-- - Chaque étape est un POINT (une seule date) ou une PÉRIODE (date de
--   début + date de fin). start_year/end_year sont numériques (et non
--   des dates calendaires) pour pouvoir représenter l'Antiquité/le Moyen
--   Âge : une valeur négative = avant J.-C. (ex. -753 pour la fondation
--   de Rome). date_label est un texte libre optionnel pour affiner
--   l'affichage sans toucher au tri chronologique réel (ex. start_year
--   = 843, date_label = "Traité de Verdun (août 843)").
-- - "Les deux" (lien automatique par nom + lien manuel) pour relier un
--   élément de frise à sa fiche/catégorie : link_target (jsonb, nullable)
--   stocke l'override MANUEL choisi par l'utilisateur via le sélecteur
--   dédié (même forme que linkIndex.ts::LinkTarget, ex.
--   {"kind":"country","id":"FRA"} ou {"kind":"section","id":"<uuid>"}).
--   Quand link_target est null, le client retombe sur le lien
--   AUTOMATIQUE par correspondance de nom (findLinkTargetForName, comme
--   pour le texte des fiches) — rien à stocker en base dans ce cas.
--
-- "on delete set null" n'est pas nécessaire ici (link_target est un
-- jsonb libre, pas une clé étrangère) ; owner_id n'a pas non plus de
-- contrainte FK stricte (même choix que genealogy_members.owner_id :
-- l'entrée dossier "frise" propriétaire peut théoriquement être
-- supprimée sans forcer une cascade, cohérent avec "ne jamais rien
-- supprimer de ce qui est fait").
--
-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1-v18 déjà en
-- place)
-- ============================================================

create table if not exists public.timeline_items (
  id uuid primary key default gen_random_uuid(),

  -- Même convention que genealogy_members.owner_type/owner_id : la
  -- frise propriétaire. En pratique toujours owner_type = 'entry'
  -- (une entrée dossier de type "frise"), mais on garde le champ
  -- générique owner_type pour rester cohérent avec le reste du schéma
  -- et permettre une extension future sans migration supplémentaire.
  owner_type text not null,
  owner_id text not null,

  kind text not null check (kind in ('point', 'period')),

  title text not null,              -- ex. "Traité de Verdun", "Saint Empire germanique"
  description text,                 -- texte libre, détaillé

  -- Dates numériques (permet les années avant J.-C. en négatif).
  start_year numeric not null,
  end_year numeric,                 -- requis si kind = 'period', doit être null si kind = 'point'
  date_label text,                  -- override d'affichage libre (ex. "Vers 800", "Été 1944")

  color text,                       -- ex. "#e63946" (hex, <input type="color">), optionnel

  -- Lien manuel vers une fiche/catégorie (forme LinkTarget de
  -- linkIndex.ts, ex. {"kind":"country","id":"FRA"}). Null = retombe
  -- sur le lien automatique par nom côté client.
  link_target jsonb,

  position int not null default 0,  -- ordre d'affichage secondaire (items à date égale)

  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),

  constraint timeline_items_period_end_check check (
    (kind = 'point' and end_year is null)
    or
    (kind = 'period' and end_year is not null and end_year >= start_year)
  )
);

create index if not exists timeline_items_owner_idx
  on public.timeline_items (owner_type, owner_id);

-- Pour construire efficacement la "frise globale" (tri chronologique
-- sur toute la table, toutes frises confondues).
create index if not exists timeline_items_start_year_idx
  on public.timeline_items (start_year);

alter table public.timeline_items enable row level security;

-- Même régime que le reste de l'app depuis schema_v13 : lecture
-- publique, écriture réservée aux admins.
create policy "timeline_items_select_all" on public.timeline_items
  for select using (true);
create policy "timeline_items_insert_admin" on public.timeline_items
  for insert with check (public.is_admin());
create policy "timeline_items_update_admin" on public.timeline_items
  for update using (public.is_admin());
create policy "timeline_items_delete_admin" on public.timeline_items
  for delete using (public.is_admin());

-- ============================================================
