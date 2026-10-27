-- arbres_v134.sql — Sources — Gengiskhanides (v84)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- 12 fiches du tableau « Gengiskhanides (Yuan) » (v84, saisi de mémoire) reçoivent l'adresse de leur page Wikipédia (anglais) dans « Notes / biographie » ; dates corrigées quand la page dit autre chose : Djötchi mort c. 1225 (et non 1227), Djaghataï né c. 1184 (et non 1183), Tolui né 1191 (et non 1192), Houlagou né c. 1217 (et non 1218).
-- Berke (khan de la Horde d'Or, fils de Djötchi) ajouté. Börte, Sorghaghtani Beki, Chabi, Zhenjin et les empereurs Yuan restent NON sourcés : pages non lues dans ce lot (Börte et Sorghaghtani sont seulement citées comme mères dans les pages de leurs fils). Remarque : la page de Djötchi dit que son père biologique était probablement Chilger-Bökö.
-- À lancer UNE fois dans Supabase -> SQL Editor -> Run. Le script s'arrête sans rien écrire si une vérification échoue.
-- Ensuite, sur le site, ouvre chaque arbre créé et vérifie ; « Organiser par dates » remet l'ordre si tu déplaces des cartes.

do $$
declare
  admin_id constant uuid := '96d2f891-6b9e-4967-89ed-18f83270ef28';
  cat_id constant uuid := '428a2e75-c8e3-51a1-b12a-bfe7a4018659';
  top uuid;
  sec uuid;
  k int;
  ext uuid;
begin
  if exists (select 1 from public.genealogy_members where id = '1685d2bc-7a6d-54e5-817c-88c31928700b') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('67d76c43-cf2f-5f4d-aa5f-c6d87e479026');
  if k <> 1 then raise exception 'Membres préexistants manquants (% sur 1) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  select count(*) into k from public.dossier_entries where id = '613c089b-471c-533f-9653-930720d42543' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Gengiskhanides (Yuan) introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1685d2bc-7a6d-54e5-817c-88c31928700b', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Berke', null, 1207, 1266, 'Khan de la Horde d''Or (1257-1266)', 'Gengiskhanides', 'Sources : https://en.wikipedia.org/wiki/Berke — naissance c. 1207, mort 1266 ou 1267', 594000, 3726, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('67d76c43-cf2f-5f4d-aa5f-c6d87e479026', '1685d2bc-7a6d-54e5-817c-88c31928700b', 'parent');
  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then 'Sources : https://en.wikipedia.org/wiki/Genghis_Khan — naissance c. 1162 ; mort le 18 ou le 25 août 1227' when bio like '%Sources :%' then bio else bio || E'\n\n' || 'Sources : https://en.wikipedia.org/wiki/Genghis_Khan — naissance c. 1162 ; mort le 18 ou le 25 août 1227' end where id = '4ee3faef-a159-514f-ae3d-0767de865d05';
  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then 'Sources : https://en.wikipedia.org/wiki/Jochi — naissance c. 1182, mort c. 1225 ; père officiel Gengis Khan, probablement Chilger-Bökö' when bio like '%Sources :%' then bio else bio || E'\n\n' || 'Sources : https://en.wikipedia.org/wiki/Jochi — naissance c. 1182, mort c. 1225 ; père officiel Gengis Khan, probablement Chilger-Bökö' end where id = '67d76c43-cf2f-5f4d-aa5f-c6d87e479026';
  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then 'Sources : https://en.wikipedia.org/wiki/Chagatai_Khan — naissance c. 1184' when bio like '%Sources :%' then bio else bio || E'\n\n' || 'Sources : https://en.wikipedia.org/wiki/Chagatai_Khan — naissance c. 1184' end where id = '2537c4ee-cd74-5d42-b49e-9107afb31a36';
  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then 'Sources : https://en.wikipedia.org/wiki/%C3%96gedei_Khan — naissance c. 1186' when bio like '%Sources :%' then bio else bio || E'\n\n' || 'Sources : https://en.wikipedia.org/wiki/%C3%96gedei_Khan — naissance c. 1186' end where id = '7c1bdcb4-362f-5991-b204-cb2c886aff81';
  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then 'Sources : https://en.wikipedia.org/wiki/Tolui' when bio like '%Sources :%' then bio else bio || E'\n\n' || 'Sources : https://en.wikipedia.org/wiki/Tolui' end where id = '803faf60-4bed-5c59-b510-6acd886a017b';
  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then 'Sources : https://en.wikipedia.org/wiki/Batu_Khan — naissance c. 1205' when bio like '%Sources :%' then bio else bio || E'\n\n' || 'Sources : https://en.wikipedia.org/wiki/Batu_Khan — naissance c. 1205' end where id = 'f0ec3282-cc90-5a98-b035-775bbaa54b95';
  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then 'Sources : https://en.wikipedia.org/wiki/G%C3%BCy%C3%BCk_Khan' when bio like '%Sources :%' then bio else bio || E'\n\n' || 'Sources : https://en.wikipedia.org/wiki/G%C3%BCy%C3%BCk_Khan' end where id = '72e63220-0d03-5592-859b-aedc1408a956';
  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then 'Sources : https://en.wikipedia.org/wiki/M%C3%B6ngke_Khan' when bio like '%Sources :%' then bio else bio || E'\n\n' || 'Sources : https://en.wikipedia.org/wiki/M%C3%B6ngke_Khan' end where id = '53907f89-a539-51a2-8db7-9a978985ad96';
  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then 'Sources : https://en.wikipedia.org/wiki/Kublai_Khan' when bio like '%Sources :%' then bio else bio || E'\n\n' || 'Sources : https://en.wikipedia.org/wiki/Kublai_Khan' end where id = '7ca95b8a-c766-5c28-ba25-70feefec7528';
  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then 'Sources : https://en.wikipedia.org/wiki/Hulagu_Khan — naissance c. 1217' when bio like '%Sources :%' then bio else bio || E'\n\n' || 'Sources : https://en.wikipedia.org/wiki/Hulagu_Khan — naissance c. 1217' end where id = 'b001eb0f-d510-50f5-a440-9076b9ad3b79';
  update public.genealogy_members set bio = case when coalesce(bio, '') = '' then 'Sources : https://en.wikipedia.org/wiki/Ariq_B%C3%B6ke — naissance c. 1219' when bio like '%Sources :%' then bio else bio || E'\n\n' || 'Sources : https://en.wikipedia.org/wiki/Ariq_B%C3%B6ke — naissance c. 1219' end where id = 'c656cb7f-21bb-5426-8a6b-930b4e684ae0';
  update public.genealogy_members set birth_year = 1182, death_year = 1225 where id = '67d76c43-cf2f-5f4d-aa5f-c6d87e479026';
  update public.genealogy_members set birth_year = 1184, death_year = 1242 where id = '2537c4ee-cd74-5d42-b49e-9107afb31a36';
  update public.genealogy_members set birth_year = 1191, death_year = 1232 where id = '803faf60-4bed-5c59-b510-6acd886a017b';
  update public.genealogy_members set birth_year = 1217, death_year = 1265 where id = 'b001eb0f-d510-50f5-a440-9076b9ad3b79';
  raise notice 'schema_v134 : % membres ajoutés.', 1;
end $$;
