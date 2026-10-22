-- schema_v37.sql — Retirer un membre étranger d'un arbre sans toucher à ses liens (demande de Martin, 2026-10-22).
-- Avant : « Retirer de cet arbre » supprimait aussi les liens réels (ex. Sophie de Brandebourg → Christian II),
-- donc les cassait dans leur arbre d'origine. Désormais le retrait est seulement un MASQUAGE propre à l'arbre
-- ouvert : la colonne `hidden` de genealogy_foreign_states. Aucune donnée n'est supprimée.
-- À lancer UNE fois (Supabase → SQL Editor → Run). Sans danger si relancé.
-- (Prérequis : schema_v36.sql déjà exécutée.)
alter table public.genealogy_foreign_states add column if not exists hidden boolean not null default false;
