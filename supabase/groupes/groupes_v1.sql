-- ============================================================
-- groupes_v1 — catégories de dossier propres aux GROUPES
-- Prérequis : aucun (schema_v1 à v60 déjà exécutées).
-- Demande de Martin (2026-11-02) : les dossiers de groupes (OTAN, BRICS…)
-- ont les mêmes 7 grandes catégories, différentes de celles des pays.
-- Ajoute un espace de catégories « group » à côté de « country » et
-- « encyclopedie », puis les 7 catégories de base.
-- Idempotente, ne supprime ni ne déplace aucune donnée : les entrées déjà
-- écrites dans les groupes (sans catégorie) restent telles quelles.
-- Droits : inchangés (politiques existantes de dossier_categories).
-- ============================================================

alter table public.dossier_categories drop constraint if exists dossier_categories_space_check;
alter table public.dossier_categories
  add constraint dossier_categories_space_check
  check (space in ('country','encyclopedie','group'));

insert into public.dossier_categories (name, space, builtin)
select v.name, 'group', true
from (values
  ('Présentation'),
  ('Origines et raison d''être'),
  ('Membres et adhésion'),
  ('Fonctionnement'),
  ('Actions et compétences'),
  ('Poids et chiffres'),
  ('Relations, tensions et critiques')
) as v(name)
where not exists (
  select 1 from public.dossier_categories c where c.space = 'group' and c.name = v.name
);
