-- schema_v36.sql — Membres d'un autre arbre « épinglés » dans un arbre (demande de Martin, 2026-10-22).
-- Jusqu'ici, un membre d'un autre arbre n'apparaissait que s'il était directement lié à un membre de l'arbre
-- ouvert. La colonne `pinned` permet d'afficher aussi les parents / conjoints / enfants de ce membre étranger
-- (bouton « Afficher ses parents… » et liens créés entre deux membres étrangers).
-- À lancer UNE fois (Supabase → SQL Editor → Run). Sans danger si relancé.
alter table public.genealogy_foreign_states add column if not exists pinned boolean not null default false;
