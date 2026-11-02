-- ============================================================
-- dossiers_v1 (2026-11-02) — Histoire : « Conflits, traités et crises » devient « Chronologie »
--
-- Demande de Martin (2026-11-02) : une frise générale par pays (la Chronologie) contient TOUS les événements datés,
-- le type (conflit, traité, crise, religion…) devenant la couleur de l'événement. Voir docs/DECISIONS.md.
--
-- Portée : la catégorie Histoire des pays (196 sections racine). Aucun groupe n'a de catégorie Histoire.
-- Ne supprime rien, ne touche à aucune fiche. Aucune fiche ni frise n'était dans ces sections à la date de la migration.
-- Idempotente : relancée, elle ne trouve plus rien à renommer.
-- Prérequis : aucun. RLS : inchangée (aucune table créée).
-- Retour arrière :
--   update public.dossier_sections set title = 'Conflits, traités et crises'
--   where title = 'Chronologie' and parent_section_id is null and owner_type = 'country'
--     and category_id in (select id from public.dossier_categories where name = 'Histoire');
-- ============================================================
update public.dossier_sections
set title = 'Chronologie'
where title = 'Conflits, traités et crises'
  and parent_section_id is null
  and owner_type = 'country'
  and category_id in (select id from public.dossier_categories where name = 'Histoire');
