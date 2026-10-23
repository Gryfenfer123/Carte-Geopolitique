-- arbres_v84.sql — Chine — Gengiskhanides : Gengis Khan, ses fils, les grands khans et les empereurs Yuan
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Gengiskhanides (Yuan) » (aucun n'existait). Rien n'est supprimé.
-- Dates : connues par ailleurs (histoire mongole), aucune page consultée pour ce lot ; la naissance de Gengis Khan (vers 1162) est discutée.
-- Börte, Sorghaghtani Beki et Chabi viennent de familles sans arbre : placées ici et signalées.
-- Non fait : Ilkhanat (Houlagou et descendants), Horde d'Or au-delà de Batu, Djaghataïdes, autres fils et épouses.
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
  if exists (select 1 from public.genealogy_members where id = '4ee3faef-a159-514f-ae3d-0767de865d05') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Gengiskhanides (Yuan) » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Gengiskhanides (Yuan)';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('fb986840-a40a-5f01-baa4-32a5d5cedf45', cat_id, 'country', 'CHN', top, 'Gengiskhanides (Yuan)', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'fb986840-a40a-5f01-baa4-32a5d5cedf45';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('613c089b-471c-533f-9653-930720d42543', 'country', 'CHN', 'genealogy', 'Gengiskhanides (Yuan)', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4ee3faef-a159-514f-ae3d-0767de865d05', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Gengis Khan (Temüjin)', null, 1162, 1227, 'Fondateur de l''Empire mongol', 'Gengiskhanides', 1158, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('67d76c43-cf2f-5f4d-aa5f-c6d87e479026', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Djötchi', null, 1182, 1227, 'Fils aîné de Gengis Khan', 'Gengiskhanides', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2537c4ee-cd74-5d42-b49e-9107afb31a36', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Djaghataï', null, 1183, 1242, 'Fils de Gengis Khan, khan du Djaghataï', 'Gengiskhanides', 1105, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7c1bdcb4-362f-5991-b204-cb2c886aff81', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Ögödei', null, 1186, 1241, 'Grand khan (1229-1241)', 'Gengiskhanides', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('803faf60-4bed-5c59-b510-6acd886a017b', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Tolui', null, 1192, 1232, 'Fils cadet de Gengis Khan, régent', 'Gengiskhanides', 1850, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f0ec3282-cc90-5a98-b035-775bbaa54b95', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Batu Khan', null, 1205, 1255, 'Fondateur de la Horde d''Or', 'Gengiskhanides', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('72e63220-0d03-5592-859b-aedc1408a956', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Güyük', null, 1206, 1248, 'Grand khan (1246-1248)', 'Gengiskhanides', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('53907f89-a539-51a2-8db7-9a978985ad96', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Möngke', null, 1209, 1259, 'Grand khan (1251-1259)', 'Gengiskhanides', 1990, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7ca95b8a-c766-5c28-ba25-70feefec7528', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Kubilaï Khan (Yuan Shizu)', null, 1215, 1294, 'Grand khan, fondateur de la dynastie Yuan (1271-1294)', 'Gengiskhanides', 1490, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b001eb0f-d510-50f5-a440-9076b9ad3b79', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Houlagou', null, 1218, 1265, 'Fondateur de l''Ilkhanat', 'Gengiskhanides', 2490, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c656cb7f-21bb-5426-8a6b-930b4e684ae0', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Ariq Böke', null, 1219, 1266, 'Prétendant au grand khanat', 'Gengiskhanides', 2990, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b0bae3f2-9777-576e-acd0-a5ae7453c465', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Zhenjin', null, 1243, 1286, 'Prince héritier, fils de Kubilaï', 'Gengiskhanides', 1245, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('09649f66-7404-50c3-99e9-ca0799c85d8f', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Gammala', null, 1263, 1302, 'Petit-fils de Kubilaï', 'Gengiskhanides', 690, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('01402455-ef11-5a78-a0cf-04f3a9ba2e40', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Darmabala', null, 1264, 1292, 'Petit-fils de Kubilaï', 'Gengiskhanides', 1695, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('15329cbc-8c8e-512a-9b1b-320d07c99827', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Temür Khan (Yuan Chengzong)', null, 1265, 1307, 'Empereur Yuan (1294-1307)', 'Gengiskhanides', 1195, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b0713b53-8994-5aad-943d-f9374f967121', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Külüg Khan (Yuan Wuzong)', null, 1281, 1311, 'Empereur Yuan (1307-1311)', 'Gengiskhanides', 1419, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('87050386-3924-507f-b0d5-9fe04fce8f52', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Ayurbarwada (Yuan Renzong)', null, 1285, 1320, 'Empereur Yuan (1311-1320)', 'Gengiskhanides', 2009, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e9d2bdea-41e5-53c2-ab0d-d2c0c8e9cd62', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Gegeen Khan (Yuan Yingzong)', null, 1303, 1323, 'Empereur Yuan (1320-1323)', 'Gengiskhanides', 2009, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2e534c96-3d23-5a8e-986a-06786f0d08f4', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Yesün Temür (Taiding)', null, 1293, 1328, 'Empereur Yuan (1323-1328)', 'Gengiskhanides', 690, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('83beb51f-1a34-569d-9ecd-03160cde2831', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Kusala (Yuan Mingzong)', null, 1300, 1329, 'Empereur Yuan (1329)', 'Gengiskhanides', 1009, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1461633a-e743-5696-afc5-030f759ca481', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Tugh Temür (Yuan Wenzong)', null, 1304, 1332, 'Empereur Yuan (1328-1332)', 'Gengiskhanides', 1509, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1e09858f-09b0-501d-bed7-acfe5913929a', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Rinchinbal (Yuan Ningzong)', null, 1326, 1332, 'Empereur Yuan (1332)', 'Gengiskhanides', 755, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('315f0c13-0384-5a90-ac7e-2225be86acdd', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Toghon Temür (Yuan Huizong)', null, 1320, 1370, 'Dernier empereur Yuan (1333-1368)', 'Gengiskhanides', 1255, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('527bd60c-88f4-5557-9661-1b453458d4cb', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Börte', null, 1161, 1230, 'Première épouse de Gengis Khan', 'Khongirad', 668, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('14b8e74c-506e-5956-b4c5-2f8de99d125f', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Sorghaghtani Beki', null, 1190, 1252, 'Épouse de Tolui, mère de quatre grands khans', 'Kerait', 2340, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5185a4a1-f9ff-552b-8146-b55d48f6e4cf', 'entry', '613c089b-471c-533f-9653-930720d42543', 'Chabi', null, 1216, 1281, 'Impératrice, épouse de Kubilaï', 'Khongirad', 1000, 1280, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('4ee3faef-a159-514f-ae3d-0767de865d05', '67d76c43-cf2f-5f4d-aa5f-c6d87e479026', 'parent');
  perform pg_temp.rel('527bd60c-88f4-5557-9661-1b453458d4cb', '67d76c43-cf2f-5f4d-aa5f-c6d87e479026', 'parent');
  perform pg_temp.rel('4ee3faef-a159-514f-ae3d-0767de865d05', '2537c4ee-cd74-5d42-b49e-9107afb31a36', 'parent');
  perform pg_temp.rel('527bd60c-88f4-5557-9661-1b453458d4cb', '2537c4ee-cd74-5d42-b49e-9107afb31a36', 'parent');
  perform pg_temp.rel('4ee3faef-a159-514f-ae3d-0767de865d05', '7c1bdcb4-362f-5991-b204-cb2c886aff81', 'parent');
  perform pg_temp.rel('527bd60c-88f4-5557-9661-1b453458d4cb', '7c1bdcb4-362f-5991-b204-cb2c886aff81', 'parent');
  perform pg_temp.rel('4ee3faef-a159-514f-ae3d-0767de865d05', '803faf60-4bed-5c59-b510-6acd886a017b', 'parent');
  perform pg_temp.rel('527bd60c-88f4-5557-9661-1b453458d4cb', '803faf60-4bed-5c59-b510-6acd886a017b', 'parent');
  perform pg_temp.rel('4ee3faef-a159-514f-ae3d-0767de865d05', '527bd60c-88f4-5557-9661-1b453458d4cb', 'spouse');
  perform pg_temp.rel('67d76c43-cf2f-5f4d-aa5f-c6d87e479026', 'f0ec3282-cc90-5a98-b035-775bbaa54b95', 'parent');
  perform pg_temp.rel('7c1bdcb4-362f-5991-b204-cb2c886aff81', '72e63220-0d03-5592-859b-aedc1408a956', 'parent');
  perform pg_temp.rel('803faf60-4bed-5c59-b510-6acd886a017b', '14b8e74c-506e-5956-b4c5-2f8de99d125f', 'spouse');
  perform pg_temp.rel('803faf60-4bed-5c59-b510-6acd886a017b', '53907f89-a539-51a2-8db7-9a978985ad96', 'parent');
  perform pg_temp.rel('14b8e74c-506e-5956-b4c5-2f8de99d125f', '53907f89-a539-51a2-8db7-9a978985ad96', 'parent');
  perform pg_temp.rel('803faf60-4bed-5c59-b510-6acd886a017b', '7ca95b8a-c766-5c28-ba25-70feefec7528', 'parent');
  perform pg_temp.rel('14b8e74c-506e-5956-b4c5-2f8de99d125f', '7ca95b8a-c766-5c28-ba25-70feefec7528', 'parent');
  perform pg_temp.rel('803faf60-4bed-5c59-b510-6acd886a017b', 'b001eb0f-d510-50f5-a440-9076b9ad3b79', 'parent');
  perform pg_temp.rel('14b8e74c-506e-5956-b4c5-2f8de99d125f', 'b001eb0f-d510-50f5-a440-9076b9ad3b79', 'parent');
  perform pg_temp.rel('803faf60-4bed-5c59-b510-6acd886a017b', 'c656cb7f-21bb-5426-8a6b-930b4e684ae0', 'parent');
  perform pg_temp.rel('14b8e74c-506e-5956-b4c5-2f8de99d125f', 'c656cb7f-21bb-5426-8a6b-930b4e684ae0', 'parent');
  perform pg_temp.rel('7ca95b8a-c766-5c28-ba25-70feefec7528', '5185a4a1-f9ff-552b-8146-b55d48f6e4cf', 'spouse');
  perform pg_temp.rel('7ca95b8a-c766-5c28-ba25-70feefec7528', 'b0bae3f2-9777-576e-acd0-a5ae7453c465', 'parent');
  perform pg_temp.rel('5185a4a1-f9ff-552b-8146-b55d48f6e4cf', 'b0bae3f2-9777-576e-acd0-a5ae7453c465', 'parent');
  perform pg_temp.rel('b0bae3f2-9777-576e-acd0-a5ae7453c465', '09649f66-7404-50c3-99e9-ca0799c85d8f', 'parent');
  perform pg_temp.rel('b0bae3f2-9777-576e-acd0-a5ae7453c465', '01402455-ef11-5a78-a0cf-04f3a9ba2e40', 'parent');
  perform pg_temp.rel('b0bae3f2-9777-576e-acd0-a5ae7453c465', '15329cbc-8c8e-512a-9b1b-320d07c99827', 'parent');
  perform pg_temp.rel('01402455-ef11-5a78-a0cf-04f3a9ba2e40', 'b0713b53-8994-5aad-943d-f9374f967121', 'parent');
  perform pg_temp.rel('01402455-ef11-5a78-a0cf-04f3a9ba2e40', '87050386-3924-507f-b0d5-9fe04fce8f52', 'parent');
  perform pg_temp.rel('87050386-3924-507f-b0d5-9fe04fce8f52', 'e9d2bdea-41e5-53c2-ab0d-d2c0c8e9cd62', 'parent');
  perform pg_temp.rel('09649f66-7404-50c3-99e9-ca0799c85d8f', '2e534c96-3d23-5a8e-986a-06786f0d08f4', 'parent');
  perform pg_temp.rel('b0713b53-8994-5aad-943d-f9374f967121', '83beb51f-1a34-569d-9ecd-03160cde2831', 'parent');
  perform pg_temp.rel('b0713b53-8994-5aad-943d-f9374f967121', '1461633a-e743-5696-afc5-030f759ca481', 'parent');
  perform pg_temp.rel('83beb51f-1a34-569d-9ecd-03160cde2831', '315f0c13-0384-5a90-ac7e-2225be86acdd', 'parent');
  perform pg_temp.rel('83beb51f-1a34-569d-9ecd-03160cde2831', '1e09858f-09b0-501d-bed7-acfe5913929a', 'parent');
  raise notice 'schema_v84 : % membres ajoutés.', 26;
end $$;
