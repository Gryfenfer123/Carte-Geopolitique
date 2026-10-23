-- arbres_v102.sql — Italie du Sud — Anjou-Naples et Aragon-Naples
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Deux nouveaux arbres : « Anjou-Naples » (Charles Ier à René, avec les Anjou-Durazzo et les ducs d'Anjou Valois qui ont régné ou revendiqué Naples) et « Aragon-Naples » (Ferrante Ier à Frédéric IV). Charles II, Charles Martel, Marie de Hongrie, André de Hongrie, Marie d'Anjou, Marguerite d'Anjou, Alphonse V, Isabelle, Béatrice et Éléonore d'Aragon y sont affichés (ils restent dans leur arbre). Rien n'est supprimé.
-- Dates : connues par ailleurs (histoire de Naples), aucune page consultée pour ce lot.
-- Liens ajoutés : Charles III d'Espagne (Charles VII de Naples) était déjà relié à Ferdinand Ier des Deux-Siciles ; rien à ajouter côté Bourbon-Siciles.
-- Épouses créées dans leur propre arbre puis affichées : Hippolyte Sforza (Sforza), Yolande d'Aragon (Barcelone). Béatrice de Provence, Isabelle de Clermont et Sancie de Majorque : familles sans arbre, signalées.
-- Non fait : épouses des Anjou-Durazzo, branche de Tarente après Louis, cadets d'Aragon-Naples (princes de Rossano…).
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
  if exists (select 1 from public.genealogy_members where id = '82828df6-bd22-5802-99a7-e1c1a90f74dd') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('07589e84-afa5-49d3-bb7f-68b7b748adb8','44a442af-0ed4-4893-a27a-e44fe6b4e997','579590ed-6dcb-4aeb-b902-9ac0494038a7','5c72ec7d-85f3-4b97-b6d5-ed54fad8e0c7','69d0a891-c17b-4dc2-bd45-edd1eb05baed','6df9addc-5cc8-41e3-9b0b-7647b501403a','6fb37332-44b6-5c53-ae83-b4fc01afc487','7010ac16-c56a-4733-9600-7078b764ac1e','716152f7-5bd7-5b17-905e-09c5faf7d5c2','78d0b5aa-fd6c-53da-865e-7a5fbbaf2129','7b2839f1-b8c3-53ed-8c28-831ff2df2cdc','8c899e6e-45ef-5a05-8b16-41903b36526f','8fbc7d6a-1c1e-5655-a152-1285e26c5202','90cd1f76-514c-5cfa-9f46-edcc228f924c','963424ff-9412-55a8-9548-457164b0703f','a810968f-0a99-50c7-8a00-63b1ec538b50','ab28690e-c022-4321-841c-4b1819c2a86b','ace83db1-2da5-5163-8728-e23bba8a42d4','bac0a74b-8395-59bf-8f23-c63f1a81ead0','bbbe49d7-372e-4a9c-9d2f-4da3ecac6d9d','e268c95a-004f-4d64-9fe0-5b768ec0b9fa');
  if k <> 21 then raise exception 'Membres préexistants manquants (% sur 21) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Anjou-Naples » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Anjou-Naples';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('73eba114-948d-573c-852f-ce2a700d89cb', cat_id, 'country', 'ITA', top, 'Anjou-Naples', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '73eba114-948d-573c-852f-ce2a700d89cb';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('edd033cb-9503-535c-b756-b5d41fea2e9a', 'country', 'ITA', 'genealogy', 'Anjou-Naples', cat_id, sec, admin_id);
  -- Arbre « Aragon-Naples » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Aragon-Naples';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('a658c181-b4f4-5838-afbb-4911ee7c21bd', cat_id, 'country', 'ITA', top, 'Aragon-Naples', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'a658c181-b4f4-5838-afbb-4911ee7c21bd';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('77a59bb6-8434-5515-a6e8-09434bcabb69', 'country', 'ITA', 'genealogy', 'Aragon-Naples', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = 'ffaf76f0-867f-51c9-b934-f6509dfaf6ab' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Sforza introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '5ff35d9f-8f58-458a-93b4-a1fadc1949f9' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison de Barcelone introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('82828df6-bd22-5802-99a7-e1c1a90f74dd', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Charles Ier d''Anjou', null, 1226, 1285, 'Roi de Sicile puis de Naples, comte de Provence', 'Anjou-Naples', 1485, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7ff8e15d-1544-5907-b471-16e97e9454c6', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Béatrice de Provence', null, 1234, 1267, 'Reine de Sicile, épouse de Charles Ier', 'Anjou-Naples', 995, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bc331b50-83ba-5b21-8c3c-34046d0aa5cb', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Robert le Sage', null, 1278, 1343, 'Roi de Naples (1309-1343)', 'Anjou-Naples', 490, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b93636e0-a1e5-5638-8b1e-0b8fbd0c53c9', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Sancie de Majorque', null, 1285, 1345, 'Reine de Naples, épouse de Robert', 'Anjou-Naples', 0, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('14750ab9-7853-5b09-bc7c-be4e4fa87c4d', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Philippe Ier de Tarente', null, 1278, 1332, 'Prince de Tarente, frère de Robert', 'Anjou-Naples', 990, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('878dfa74-4994-53a0-bc4d-148c9058d867', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Louis de Tarente', null, 1320, 1362, 'Prince de Tarente, roi de Naples par mariage (1352-1362)', 'Anjou-Naples', 985, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8f963624-fa0c-5a44-9e78-acce642f2e0c', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Jean de Durazzo (de Gravina)', null, 1294, 1336, 'Duc de Durazzo, frère de Robert', 'Anjou-Naples', 1490, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('31466b8c-5b13-5646-b586-ba1f61440d06', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Charles de Durazzo', null, 1323, 1348, 'Duc de Durazzo, exécuté par le roi de Hongrie', 'Anjou-Naples', 1490, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ec89f014-0df9-584a-ac60-dc00d01ba8bf', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Charles de Calabre', null, 1298, 1328, 'Duc de Calabre, fils de Robert', 'Anjou-Naples', 490, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('41f5b9f8-313b-5c1b-ba4c-af5156e8c893', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Jeanne Ire de Naples', null, 1325, 1382, 'Reine de Naples (1343-1382), comtesse de Provence', 'Anjou-Naples', 495, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('13071073-cfec-5f85-9573-b9e4149ff203', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Charles III de Durazzo', null, 1345, 1386, 'Roi de Naples (1382-1386), roi de Hongrie (1385-1386)', 'Anjou-Naples', 1490, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7de16ff1-ad86-57bc-ab0f-8a4e455b493e', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Marguerite de Durazzo', null, 1347, 1412, 'Reine de Naples, épouse de Charles III, régente', 'Anjou-Naples', 1980, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4263c204-96de-5c13-96a4-a61013a46432', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Ladislas Ier de Naples', null, 1377, 1414, 'Roi de Naples (1386-1414)', 'Anjou-Naples', 1985, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0f7d67d7-eb27-5e10-8bab-9d994c6b8ede', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Jeanne II de Naples', null, 1373, 1435, 'Reine de Naples (1414-1435)', 'Anjou-Naples', 1485, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3b7347e4-ef63-5f63-89fb-ce7eb6efbcc5', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Louis Ier d''Anjou', null, 1339, 1384, 'Duc d''Anjou, héritier désigné de Jeanne Ire', 'Anjou-Naples', 3826, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f25d0bc1-65a5-5422-923c-fae71ec63d3a', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Louis II d''Anjou', null, 1377, 1417, 'Duc d''Anjou, roi de Naples titulaire', 'Anjou-Naples', 3826, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d3202a37-b170-596e-92e8-814e87bb1e52', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'Louis III d''Anjou', null, 1403, 1434, 'Duc d''Anjou, héritier de Jeanne II', 'Anjou-Naples', 2985, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cdf9f687-0bd8-5616-a89c-647de844e54b', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 'René d''Anjou (le bon roi René)', null, 1409, 1480, 'Roi de Naples (1435-1442), duc d''Anjou et de Lorraine', 'Anjou-Naples', 3485, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c4cdb47d-1f16-51be-8828-43708366bb41', 'entry', '5ff35d9f-8f58-458a-93b4-a1fadc1949f9', 'Yolande d''Aragon', null, 1384, 1442, 'Duchesse d''Anjou, belle-mère de Charles VII', 'Maison de Barcelone', 402000, 6912, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d6eb4cf6-c97d-59a9-97ca-1ed0bdc88918', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 'Ferrante Ier de Naples', null, 1431, 1494, 'Roi de Naples (1458-1494), fils naturel d''Alphonse V', 'Aragon-Naples', 1445, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1e2ade20-fe56-577b-8f80-63b83bb537fd', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 'Isabelle de Clermont-Tarente', null, 1424, 1465, 'Reine de Naples, épouse de Ferrante Ier', 'Aragon-Naples', 955, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7eeb0730-3b4f-59e6-9261-76bb4f9ecef7', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 'Jeanne d''Aragon (reine de Naples)', null, 1454, 1517, 'Seconde épouse de Ferrante Ier', 'Aragon-Naples', 1935, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9f26dcc3-c84b-5a64-acb6-7b1f4d2bb60d', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 'Alphonse II de Naples', null, 1448, 1495, 'Roi de Naples (1494-1495)', 'Aragon-Naples', 1500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f5938a98-385c-59f2-8e3c-b3f9de17dd1b', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 'Ferdinand II de Naples (Ferrandino)', null, 1469, 1496, 'Roi de Naples (1495-1496)', 'Aragon-Naples', 1784, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0a69853a-5ca9-5adc-87b1-5c9d6c24147b', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 'Jeanne de Naples (reine, épouse de Ferrandino)', null, 1478, 1518, 'Reine de Naples', 'Aragon-Naples', 2274, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('25c04be1-4f08-5eb3-9296-0a639d0c1186', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 'Frédéric IV de Naples', null, 1451, 1504, 'Roi de Naples (1496-1501), dernier roi aragonais', 'Aragon-Naples', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ec58da77-5e60-5c17-92b9-d4ce7d30b7ec', 'entry', 'ffaf76f0-867f-51c9-b934-f6509dfaf6ab', 'Hippolyte Marie Sforza', null, 1446, 1484, 'Duchesse de Calabre, épouse d''Alphonse II', 'Sforza', 3220, 1920, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('579590ed-6dcb-4aeb-b902-9ac0494038a7', '82828df6-bd22-5802-99a7-e1c1a90f74dd', 'parent');
  perform pg_temp.rel('82828df6-bd22-5802-99a7-e1c1a90f74dd', '7ff8e15d-1544-5907-b471-16e97e9454c6', 'spouse');
  perform pg_temp.rel('82828df6-bd22-5802-99a7-e1c1a90f74dd', '78d0b5aa-fd6c-53da-865e-7a5fbbaf2129', 'parent');
  perform pg_temp.rel('7ff8e15d-1544-5907-b471-16e97e9454c6', '78d0b5aa-fd6c-53da-865e-7a5fbbaf2129', 'parent');
  perform pg_temp.rel('78d0b5aa-fd6c-53da-865e-7a5fbbaf2129', '963424ff-9412-55a8-9548-457164b0703f', 'parent');
  perform pg_temp.rel('bac0a74b-8395-59bf-8f23-c63f1a81ead0', '963424ff-9412-55a8-9548-457164b0703f', 'parent');
  perform pg_temp.rel('78d0b5aa-fd6c-53da-865e-7a5fbbaf2129', 'bc331b50-83ba-5b21-8c3c-34046d0aa5cb', 'parent');
  perform pg_temp.rel('bac0a74b-8395-59bf-8f23-c63f1a81ead0', 'bc331b50-83ba-5b21-8c3c-34046d0aa5cb', 'parent');
  perform pg_temp.rel('78d0b5aa-fd6c-53da-865e-7a5fbbaf2129', '14750ab9-7853-5b09-bc7c-be4e4fa87c4d', 'parent');
  perform pg_temp.rel('bac0a74b-8395-59bf-8f23-c63f1a81ead0', '14750ab9-7853-5b09-bc7c-be4e4fa87c4d', 'parent');
  perform pg_temp.rel('78d0b5aa-fd6c-53da-865e-7a5fbbaf2129', '8f963624-fa0c-5a44-9e78-acce642f2e0c', 'parent');
  perform pg_temp.rel('bac0a74b-8395-59bf-8f23-c63f1a81ead0', '8f963624-fa0c-5a44-9e78-acce642f2e0c', 'parent');
  perform pg_temp.rel('963424ff-9412-55a8-9548-457164b0703f', 'ace83db1-2da5-5163-8728-e23bba8a42d4', 'parent');
  perform pg_temp.rel('78d0b5aa-fd6c-53da-865e-7a5fbbaf2129', '44a442af-0ed4-4893-a27a-e44fe6b4e997', 'parent');
  perform pg_temp.rel('78d0b5aa-fd6c-53da-865e-7a5fbbaf2129', '07589e84-afa5-49d3-bb7f-68b7b748adb8', 'parent');
  perform pg_temp.rel('78d0b5aa-fd6c-53da-865e-7a5fbbaf2129', 'e268c95a-004f-4d64-9fe0-5b768ec0b9fa', 'parent');
  perform pg_temp.rel('bc331b50-83ba-5b21-8c3c-34046d0aa5cb', 'b93636e0-a1e5-5638-8b1e-0b8fbd0c53c9', 'spouse');
  perform pg_temp.rel('bc331b50-83ba-5b21-8c3c-34046d0aa5cb', 'ec89f014-0df9-584a-ac60-dc00d01ba8bf', 'parent');
  perform pg_temp.rel('ec89f014-0df9-584a-ac60-dc00d01ba8bf', '41f5b9f8-313b-5c1b-ba4c-af5156e8c893', 'parent');
  perform pg_temp.rel('41f5b9f8-313b-5c1b-ba4c-af5156e8c893', '716152f7-5bd7-5b17-905e-09c5faf7d5c2', 'spouse');
  perform pg_temp.rel('41f5b9f8-313b-5c1b-ba4c-af5156e8c893', '878dfa74-4994-53a0-bc4d-148c9058d867', 'spouse');
  perform pg_temp.rel('14750ab9-7853-5b09-bc7c-be4e4fa87c4d', '878dfa74-4994-53a0-bc4d-148c9058d867', 'parent');
  perform pg_temp.rel('8f963624-fa0c-5a44-9e78-acce642f2e0c', '31466b8c-5b13-5646-b586-ba1f61440d06', 'parent');
  perform pg_temp.rel('31466b8c-5b13-5646-b586-ba1f61440d06', '13071073-cfec-5f85-9573-b9e4149ff203', 'parent');
  perform pg_temp.rel('13071073-cfec-5f85-9573-b9e4149ff203', '7de16ff1-ad86-57bc-ab0f-8a4e455b493e', 'spouse');
  perform pg_temp.rel('13071073-cfec-5f85-9573-b9e4149ff203', '4263c204-96de-5c13-96a4-a61013a46432', 'parent');
  perform pg_temp.rel('7de16ff1-ad86-57bc-ab0f-8a4e455b493e', '4263c204-96de-5c13-96a4-a61013a46432', 'parent');
  perform pg_temp.rel('13071073-cfec-5f85-9573-b9e4149ff203', '0f7d67d7-eb27-5e10-8bab-9d994c6b8ede', 'parent');
  perform pg_temp.rel('7de16ff1-ad86-57bc-ab0f-8a4e455b493e', '0f7d67d7-eb27-5e10-8bab-9d994c6b8ede', 'parent');
  perform pg_temp.rel('41f5b9f8-313b-5c1b-ba4c-af5156e8c893', '13071073-cfec-5f85-9573-b9e4149ff203', 'family');
  perform pg_temp.rel('41f5b9f8-313b-5c1b-ba4c-af5156e8c893', '3b7347e4-ef63-5f63-89fb-ce7eb6efbcc5', 'family');
  perform pg_temp.rel('0f7d67d7-eb27-5e10-8bab-9d994c6b8ede', 'd3202a37-b170-596e-92e8-814e87bb1e52', 'family');
  perform pg_temp.rel('0f7d67d7-eb27-5e10-8bab-9d994c6b8ede', 'cdf9f687-0bd8-5616-a89c-647de844e54b', 'family');
  perform pg_temp.rel('0f7d67d7-eb27-5e10-8bab-9d994c6b8ede', 'bbbe49d7-372e-4a9c-9d2f-4da3ecac6d9d', 'family');
  perform pg_temp.rel('5c72ec7d-85f3-4b97-b6d5-ed54fad8e0c7', '3b7347e4-ef63-5f63-89fb-ce7eb6efbcc5', 'parent');
  perform pg_temp.rel('7010ac16-c56a-4733-9600-7078b764ac1e', '3b7347e4-ef63-5f63-89fb-ce7eb6efbcc5', 'parent');
  perform pg_temp.rel('3b7347e4-ef63-5f63-89fb-ce7eb6efbcc5', 'f25d0bc1-65a5-5422-923c-fae71ec63d3a', 'parent');
  perform pg_temp.rel('f25d0bc1-65a5-5422-923c-fae71ec63d3a', 'c4cdb47d-1f16-51be-8828-43708366bb41', 'spouse');
  perform pg_temp.rel('69d0a891-c17b-4dc2-bd45-edd1eb05baed', 'c4cdb47d-1f16-51be-8828-43708366bb41', 'parent');
  perform pg_temp.rel('f25d0bc1-65a5-5422-923c-fae71ec63d3a', 'd3202a37-b170-596e-92e8-814e87bb1e52', 'parent');
  perform pg_temp.rel('c4cdb47d-1f16-51be-8828-43708366bb41', 'd3202a37-b170-596e-92e8-814e87bb1e52', 'parent');
  perform pg_temp.rel('f25d0bc1-65a5-5422-923c-fae71ec63d3a', 'cdf9f687-0bd8-5616-a89c-647de844e54b', 'parent');
  perform pg_temp.rel('c4cdb47d-1f16-51be-8828-43708366bb41', 'cdf9f687-0bd8-5616-a89c-647de844e54b', 'parent');
  perform pg_temp.rel('f25d0bc1-65a5-5422-923c-fae71ec63d3a', '6df9addc-5cc8-41e3-9b0b-7647b501403a', 'parent');
  perform pg_temp.rel('c4cdb47d-1f16-51be-8828-43708366bb41', '6df9addc-5cc8-41e3-9b0b-7647b501403a', 'parent');
  perform pg_temp.rel('cdf9f687-0bd8-5616-a89c-647de844e54b', '6fb37332-44b6-5c53-ae83-b4fc01afc487', 'parent');
  perform pg_temp.rel('bbbe49d7-372e-4a9c-9d2f-4da3ecac6d9d', 'd6eb4cf6-c97d-59a9-97ca-1ed0bdc88918', 'parent');
  perform pg_temp.rel('d6eb4cf6-c97d-59a9-97ca-1ed0bdc88918', '1e2ade20-fe56-577b-8f80-63b83bb537fd', 'spouse');
  perform pg_temp.rel('d6eb4cf6-c97d-59a9-97ca-1ed0bdc88918', '7eeb0730-3b4f-59e6-9261-76bb4f9ecef7', 'spouse');
  perform pg_temp.rel('ab28690e-c022-4321-841c-4b1819c2a86b', '7eeb0730-3b4f-59e6-9261-76bb4f9ecef7', 'parent');
  perform pg_temp.rel('d6eb4cf6-c97d-59a9-97ca-1ed0bdc88918', '9f26dcc3-c84b-5a64-acb6-7b1f4d2bb60d', 'parent');
  perform pg_temp.rel('1e2ade20-fe56-577b-8f80-63b83bb537fd', '9f26dcc3-c84b-5a64-acb6-7b1f4d2bb60d', 'parent');
  perform pg_temp.rel('d6eb4cf6-c97d-59a9-97ca-1ed0bdc88918', '25c04be1-4f08-5eb3-9296-0a639d0c1186', 'parent');
  perform pg_temp.rel('1e2ade20-fe56-577b-8f80-63b83bb537fd', '25c04be1-4f08-5eb3-9296-0a639d0c1186', 'parent');
  perform pg_temp.rel('d6eb4cf6-c97d-59a9-97ca-1ed0bdc88918', 'a810968f-0a99-50c7-8a00-63b1ec538b50', 'parent');
  perform pg_temp.rel('1e2ade20-fe56-577b-8f80-63b83bb537fd', 'a810968f-0a99-50c7-8a00-63b1ec538b50', 'parent');
  perform pg_temp.rel('d6eb4cf6-c97d-59a9-97ca-1ed0bdc88918', '8c899e6e-45ef-5a05-8b16-41903b36526f', 'parent');
  perform pg_temp.rel('1e2ade20-fe56-577b-8f80-63b83bb537fd', '8c899e6e-45ef-5a05-8b16-41903b36526f', 'parent');
  perform pg_temp.rel('9f26dcc3-c84b-5a64-acb6-7b1f4d2bb60d', 'ec58da77-5e60-5c17-92b9-d4ce7d30b7ec', 'spouse');
  perform pg_temp.rel('7b2839f1-b8c3-53ed-8c28-831ff2df2cdc', 'ec58da77-5e60-5c17-92b9-d4ce7d30b7ec', 'parent');
  perform pg_temp.rel('8fbc7d6a-1c1e-5655-a152-1285e26c5202', 'ec58da77-5e60-5c17-92b9-d4ce7d30b7ec', 'parent');
  perform pg_temp.rel('9f26dcc3-c84b-5a64-acb6-7b1f4d2bb60d', 'f5938a98-385c-59f2-8e3c-b3f9de17dd1b', 'parent');
  perform pg_temp.rel('ec58da77-5e60-5c17-92b9-d4ce7d30b7ec', 'f5938a98-385c-59f2-8e3c-b3f9de17dd1b', 'parent');
  perform pg_temp.rel('9f26dcc3-c84b-5a64-acb6-7b1f4d2bb60d', '90cd1f76-514c-5cfa-9f46-edcc228f924c', 'parent');
  perform pg_temp.rel('ec58da77-5e60-5c17-92b9-d4ce7d30b7ec', '90cd1f76-514c-5cfa-9f46-edcc228f924c', 'parent');
  perform pg_temp.rel('d6eb4cf6-c97d-59a9-97ca-1ed0bdc88918', '0a69853a-5ca9-5adc-87b1-5c9d6c24147b', 'parent');
  perform pg_temp.rel('7eeb0730-3b4f-59e6-9261-76bb4f9ecef7', '0a69853a-5ca9-5adc-87b1-5c9d6c24147b', 'parent');
  perform pg_temp.rel('f5938a98-385c-59f2-8e3c-b3f9de17dd1b', '0a69853a-5ca9-5adc-87b1-5c9d6c24147b', 'spouse');
  update public.genealogy_members set pos_x = 1897, pos_y = 0 where id = '235ca4d3-323f-5ad8-be5f-d8bb1b63019c';
  update public.genealogy_members set pos_x = 1897, pos_y = 640 where id = '7b2839f1-b8c3-53ed-8c28-831ff2df2cdc';
  update public.genealogy_members set pos_x = 1260, pos_y = 1920 where id = '17b5c283-4ef7-514c-be16-29ad5b2e4cca';
  update public.genealogy_members set pos_x = 496, pos_y = 2560 where id = '5a506475-31de-5ceb-9557-0c05e51f0be0';
  update public.genealogy_members set pos_x = 2486, pos_y = 2560 where id = 'a33ab24c-0e9f-50b1-a251-a9f698a0a3ac';
  update public.genealogy_members set pos_x = 1986, pos_y = 2560 where id = '925432de-d608-528b-8fbe-41cdbdb2e3e1';
  update public.genealogy_members set pos_x = 2976, pos_y = 2560 where id = '90cd1f76-514c-5cfa-9f46-edcc228f924c';
  update public.genealogy_members set pos_x = 6, pos_y = 2560 where id = 'f388aa57-8aca-54ed-9b7d-1973561af12f';
  update public.genealogy_members set pos_x = 500, pos_y = 3200 where id = 'b8a95ccb-9673-5baa-b450-29f85d5423dd';
  update public.genealogy_members set pos_x = 0, pos_y = 3200 where id = 'fd6fd47d-4dd9-5ba1-9213-291ed67f0708';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('579590ed-6dcb-4aeb-b902-9ac0494038a7', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 1485, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('78d0b5aa-fd6c-53da-865e-7a5fbbaf2129', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 1240, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('bac0a74b-8395-59bf-8f23-c63f1a81ead0', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 740, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('716152f7-5bd7-5b17-905e-09c5faf7d5c2', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 5, 3200, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('bbbe49d7-372e-4a9c-9d2f-4da3ecac6d9d', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 10076, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('5c72ec7d-85f3-4b97-b6d5-ed54fad8e0c7', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 4076, 2560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('7010ac16-c56a-4733-9600-7078b764ac1e', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 3576, 2560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('c4cdb47d-1f16-51be-8828-43708366bb41', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 3336, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('6df9addc-5cc8-41e3-9b0b-7647b501403a', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 3985, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('6fb37332-44b6-5c53-ae83-b4fc01afc487', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 3485, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('963424ff-9412-55a8-9548-457164b0703f', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 5076, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ace83db1-2da5-5163-8728-e23bba8a42d4', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 8076, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('44a442af-0ed4-4893-a27a-e44fe6b4e997', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 7076, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('07589e84-afa5-49d3-bb7f-68b7b748adb8', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 9076, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('e268c95a-004f-4d64-9fe0-5b768ec0b9fa', 'entry', 'edd033cb-9503-535c-b756-b5d41fea2e9a', 6076, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('bbbe49d7-372e-4a9c-9d2f-4da3ecac6d9d', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 1336, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ab28690e-c022-4321-841c-4b1819c2a86b', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 1836, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('a810968f-0a99-50c7-8a00-63b1ec538b50', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 1000, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('8c899e6e-45ef-5a05-8b16-41903b36526f', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 0, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ec58da77-5e60-5c17-92b9-d4ce7d30b7ec', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 1990, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('90cd1f76-514c-5cfa-9f46-edcc228f924c', 'entry', '77a59bb6-8434-5515-a6e8-09434bcabb69', 1284, 2560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('9f26dcc3-c84b-5a64-acb6-7b1f4d2bb60d', 'entry', 'ffaf76f0-867f-51c9-b934-f6509dfaf6ab', 2730, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('8fbc7d6a-1c1e-5655-a152-1285e26c5202', 'entry', 'ffaf76f0-867f-51c9-b934-f6509dfaf6ab', 2387, 640, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f5938a98-385c-59f2-8e3c-b3f9de17dd1b', 'entry', 'ffaf76f0-867f-51c9-b934-f6509dfaf6ab', 3476, 2560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('200e2ea5-cfaa-5e65-955d-621b9375b195', 'entry', 'ffaf76f0-867f-51c9-b934-f6509dfaf6ab', 1750, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('22d205d8-1cef-4226-89e7-7cc7940763f0', 'entry', 'ffaf76f0-867f-51c9-b934-f6509dfaf6ab', 1496, 2560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('387d26db-cc1c-5e89-91f4-d53946159d36', 'entry', 'ffaf76f0-867f-51c9-b934-f6509dfaf6ab', 996, 2560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('dd0ecce2-e687-52cd-82a2-fd7477051700', 'entry', 'ffaf76f0-867f-51c9-b934-f6509dfaf6ab', 2731, 3200, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('61dcdaea-ba35-5ed6-aac7-604aeb97dd1d', 'entry', 'ffaf76f0-867f-51c9-b934-f6509dfaf6ab', 5, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('a810968f-0a99-50c7-8a00-63b1ec538b50', 'entry', 'ffaf76f0-867f-51c9-b934-f6509dfaf6ab', 6, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v102 : % membres ajoutés.', 27;
end $$;
