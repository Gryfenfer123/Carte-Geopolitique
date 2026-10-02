-- ============================================================
-- Atlas Géopolitique — schéma v9 : activation des Points d'intérêt (POI)
-- sur la table public.map_features (créée au schéma v2 pour les ports/
-- détroits/bases/câbles/pipelines, jamais utilisée depuis pour un "kind"
-- POI — voir src/poi.ts, ajouté dans cette même session, qui lit/écrit
-- désormais cette table avec kind='poi').
--
-- Deux changements :
-- 1. La contrainte CHECK sur `kind` n'autorisait que
--    'port'|'strait'|'base'|'cable'|'pipeline' : on y ajoute 'poi'.
-- 2. Ajout d'une colonne `note` (texte libre, nullable) : les points
--    d'intérêt ont une description facultative que les autres "kind"
--    n'utilisent pas (elle reste donc NULL pour eux, sans impact).
--
-- Les policies RLS (lecture publique, écriture réservée aux comptes
-- connectés, édition/suppression ouvertes à tout compte connecté — voir
-- schema_v2.sql et schema_v8.sql) s'appliquent déjà à map_features et
-- couvrent 'poi' sans rien y changer.
--
-- À coller dans Supabase → SQL Editor → New query → Run
-- (vient compléter, sans rien supprimer, les schémas v1-v8 déjà en place)
--
-- IMPORTANT : tant que cette migration n'a pas été exécutée sur la base
-- de production, toute tentative de créer un point d'intérêt depuis
-- l'application échouera avec une violation de contrainte CHECK
-- ("map_features_kind_check") côté Supabase.
-- ============================================================

alter table public.map_features
  drop constraint if exists map_features_kind_check;

alter table public.map_features
  add constraint map_features_kind_check
  check (kind in ('port', 'strait', 'base', 'cable', 'pipeline', 'poi'));

alter table public.map_features
  add column if not exists note text;
