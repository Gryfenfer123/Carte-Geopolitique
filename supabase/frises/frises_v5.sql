-- ============================================================
-- Atlas Géopolitique — frises_v5 (2026-11-12) : suppression du contenu de TEST de l'Allemagne
--
-- Demande de Martin (2026-11-12) : « Tout ce qu'il y a sur la frise de l'Allemagne actuellement, ce sont des tests que j'ai faits.
-- Tu peux tout supprimer. » Suppression ciblée, par identifiants, de : 4 frises de test (« Histoire Allemande », « test », « Guerre »,
-- « pipoland »), leurs 8 sections-périodes, 9 fiches de test et les événements/placements qui y étaient rattachés.
-- Ne touche PAS : la frise « Histoire de l'Allemagne » (frises_v4), les dynasties/arbres, ni les sections vides de la 2e « Chronologie ».
-- Garde-fou : s'arrête si un événement de test est aussi placé sur une autre frise. Idempotent (une 2e exécution ne supprime plus rien).
-- Exécuté par Claude via le connecteur Supabase sur demande de Martin (2026-11-12) ; le contrôle « il reste les 4 frises de frises_v4 »
-- a été fait à l'exécution (retiré ici pour que le fichier reste rejouable quand d'autres frises existeront).
-- Retour arrière : impossible (suppression voulue de données de test).
-- ============================================================
do $$
declare
  fr uuid[] := array['a130b2e9-2bc2-4248-aeba-95bdd040318f','2c28a4a4-617c-41d4-9383-9194a3c90c34','f798abd5-a8e0-457f-847e-d548d0a5bb9f','237f332c-6296-4d28-98bb-fa2ce41e9d75']::uuid[];
  secs uuid[] := array['416cb471-1ed4-4101-b628-8066f9b75b32','96f57986-3768-46e4-81c4-33138667e398','6a5542e0-ce6b-446b-9d8b-45eb4d67ec70','add05448-cdaa-4176-af84-28fc202d5d23','d1f5c3bd-5fe1-41fb-8a85-eb47ed6da347','88ac0b11-909f-432c-9ada-4585ffa402c4','09c270d2-f5eb-459a-8440-0082ffc53610','34249e30-7ff8-45d9-818a-cdb93d89053e']::uuid[];
  ev uuid[];
begin
  select array_agg(distinct event_id) into ev from (
    select event_id from public.timeline_placements where frise_entry_id = any(fr)
    union select id from public.timeline_events where sub_frise_entry_id = any(fr)) x;
  if exists (select 1 from public.timeline_placements where event_id = any(coalesce(ev,'{}')) and frise_entry_id <> all(fr)) then
    raise exception 'Un événement de test est aussi placé ailleurs : rien supprimé.';
  end if;
  delete from public.timeline_events where id = any(coalesce(ev,'{}'));
  delete from public.dossier_sections where id = any(secs);
  delete from public.dossier_entries where id = any(fr);
  if exists (select 1 from public.dossier_entries where id = any(fr)) or exists (select 1 from public.dossier_sections where id = any(secs)) then
    raise exception 'Suppression incomplète : tout est annulé.';
  end if;
end $$;
