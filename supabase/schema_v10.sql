-- ============================================================
-- Atlas Géopolitique — schéma v10 : image + cadrage sur les catégories et
-- sous-catégories de dossier (demande de Martin, 2026-10-02).
--
-- Deux tables concernées :
-- 1. public.dossier_categories (catégories/thèmes, GLOBALES/partagées par
--    "space" — ex. "Histoire" existe une seule fois et sert à tous les
--    dossiers pays) : n'avait aucune colonne image. Ajout de
--    `image_url` + `image_position` (position du cadrage CSS
--    `object-position`, ex. "50% 30%" — par défaut centré).
-- 2. public.dossier_sections (sous-catégories, propres à un dossier
--    précis via owner_type/owner_id) : avait déjà une colonne
--    `cover_image_url` (schéma v1), jamais utilisée côté application
--    jusqu'à cette session (voir src/dossier.ts, ajouté pour l'occasion).
--    Il ne lui manquait que la position de cadrage, ajoutée ici sous le
--    même nom `image_position` que pour les catégories, pour que le code
--    applicatif partage un seul format.
--
-- Pas de nouvelle policy RLS nécessaire : les policies existantes sur ces
-- deux tables (lecture publique, écriture/suppression ouvertes à tout
-- compte connecté — schema_v1.sql + schema_v8.sql) couvrent déjà ces
-- nouvelles colonnes, qui sont de simples colonnes supplémentaires des
-- mêmes lignes.
--
-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1-v9 déjà en place)
-- ============================================================

alter table public.dossier_categories
  add column if not exists image_url text,
  add column if not exists image_position text not null default '50% 50%';

alter table public.dossier_sections
  add column if not exists image_position text not null default '50% 50%';
  -- (cover_image_url existe déjà depuis schema_v1.sql — rien à ajouter
  -- pour l'image elle-même, seulement sa position de cadrage ci-dessus.)
