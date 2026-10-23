-- arbres_v97.sql — Corée — dynastie Goryeo (Wang) de Taejo à Gongyang
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Goryeo » (aucun n'existait). Rien n'est supprimé.
-- Source : pages Wikipédia en anglais de chaque roi (dates de vie et père) ; pour quelques rois (Gyeongjong, Mokjong, Munjong et fils, Sukjong, Yejong, Injong et fils, Huijong, Wonjong, Chungnyeol à Chungmok) les pages ont été lues une par une.
-- Daejong et Anjong (fils de Taejo, rois à titre posthume) s'appellent tous deux Wang Uk : nommés avec leur titre pour les distinguer. Dates de naissance incertaines (Anjong : vers 920/937) : laissées vides.
-- Gongyang (dernier roi) descend de Sinjong par une branche éloignée (père : prince Wang Kyun) : père ajouté sans lien avec les rois précédents faute de chaîne sourcée.
-- Non fait : épouses des rois (familles sans arbre), Silla et les Trois Royaumes.
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
  if exists (select 1 from public.genealogy_members where id = '61cc1040-2c52-5e24-b01f-b5fd0e3b4555') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Goryeo » (KOR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'KOR' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour KOR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Goryeo';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('15ac17b0-428f-5601-aa14-aa1504e78403', cat_id, 'country', 'KOR', top, 'Goryeo', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '15ac17b0-428f-5601-aa14-aa1504e78403';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('ae22758c-d1de-50a1-a76d-8cc43db80246', 'country', 'KOR', 'genealogy', 'Goryeo', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('61cc1040-2c52-5e24-b01f-b5fd0e3b4555', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Taejo (Wang Geon)', null, 877, 943, 'Fondateur de Goryeo (918-943)', 'Goryeo (Wang)', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0ec04876-4d75-57dd-8881-76e420eb5d3f', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Hyejong (Goryeo)', null, 912, 945, 'Roi (943-945)', 'Goryeo (Wang)', 1500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7dba9dc2-60b3-5577-910a-3e5552a5c084', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Jeongjong I (Goryeo)', null, 923, 949, 'Roi (945-949)', 'Goryeo (Wang)', 2000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f06aad33-f574-57e5-9e8b-8408c6c0b49c', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Gwangjong (Goryeo)', null, 925, 975, 'Roi (949-975)', 'Goryeo (Wang)', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bb891b55-2d3f-5d73-a2a5-f5b4f9e05862', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Gyeongjong (Goryeo)', null, 955, 981, 'Roi (975-981)', 'Goryeo (Wang)', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c905c044-50b3-5c21-b4b5-07fbf74263a5', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Seongjong (Goryeo)', null, 961, 997, 'Roi (981-997)', 'Goryeo (Wang)', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c994cfb5-a6e7-5284-b400-55b898ba31a2', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Mokjong (Goryeo)', null, 980, 1009, 'Roi (997-1009)', 'Goryeo (Wang)', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1136f18e-f42f-5366-9358-061789dbbc46', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Hyeonjong (Goryeo)', null, 992, 1031, 'Roi (1009-1031)', 'Goryeo (Wang)', 1001, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d2491634-b975-5355-b765-00139d188563', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Deokjong (Goryeo)', null, 1016, 1034, 'Roi (1031-1034)', 'Goryeo (Wang)', 1502, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c2781eae-716f-57c6-a87a-8e052c09cfac', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Jeongjong II (Goryeo)', null, 1018, 1046, 'Roi (1034-1046)', 'Goryeo (Wang)', 502, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('22250824-7be4-5595-9c1c-723aa22c80b4', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Munjong (Goryeo)', null, 1019, 1083, 'Roi (1046-1083)', 'Goryeo (Wang)', 1002, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c9a65d8d-db36-534e-80b5-63bba6c7217d', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Sunjong (Goryeo)', null, 1047, 1083, 'Roi (1083)', 'Goryeo (Wang)', 503, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cf19ef77-a118-56b4-a143-c48e6dc0c11b', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Seonjong (Goryeo)', null, 1049, 1094, 'Roi (1083-1094)', 'Goryeo (Wang)', 1504, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e313f9af-938e-5fd0-8dbd-96a39a9d2e5a', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Heonjong (Goryeo)', null, 1084, 1097, 'Roi (1094-1095)', 'Goryeo (Wang)', 1504, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0a2df13c-4462-5360-9134-a89e8b614923', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Sukjong (Goryeo)', null, 1054, 1105, 'Roi (1095-1105)', 'Goryeo (Wang)', 1003, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4e6fa8bc-c6ea-558b-8331-e384088c8c9f', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Yejong (Goryeo)', null, 1079, 1122, 'Roi (1105-1122)', 'Goryeo (Wang)', 1003, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aea4d6bf-3742-5a68-9c8b-3aa976068567', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Injong (Goryeo)', null, 1109, 1146, 'Roi (1122-1146)', 'Goryeo (Wang)', 1003, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('18dbd929-f32f-53d3-9fc6-bda67655a1ca', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Uijong (Goryeo)', null, 1127, 1173, 'Roi (1146-1170), détrôné', 'Goryeo (Wang)', 1504, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c0b1db24-0a14-5723-b8ee-3fce701c2aab', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Myeongjong (Goryeo)', null, 1131, 1202, 'Roi (1170-1197), mis sur le trône par les généraux', 'Goryeo (Wang)', 488, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b5e99dc0-25fd-5ee2-a76f-b7fea1c66754', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Sinjong (Goryeo)', null, 1144, 1204, 'Roi (1197-1204)', 'Goryeo (Wang)', 1004, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4ec631df-17bf-5e97-8bbe-d18eca4fe5f4', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Huijong (Goryeo)', null, 1181, 1237, 'Roi (1204-1211)', 'Goryeo (Wang)', 1004, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bc06060b-fb2b-5d2b-aff5-91bf64fa71ec', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Gangjong (Goryeo)', null, 1152, 1213, 'Roi (1211-1213)', 'Goryeo (Wang)', 488, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('37e3248d-34ba-5e2d-a0b3-cba09b10f583', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Gojong (Goryeo)', null, 1192, 1259, 'Roi (1213-1259), invasions mongoles', 'Goryeo (Wang)', 488, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b9422680-fea0-594f-9352-d7f5ecc5624c', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Wonjong (Goryeo)', null, 1219, 1274, 'Roi (1259-1274), paix avec les Mongols', 'Goryeo (Wang)', 488, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('35cf7abc-783b-5eca-a915-bfc8e7e7e2cf', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Chungnyeol (Goryeo)', null, 1236, 1308, 'Roi (1274-1308), gendre de Kubilai', 'Goryeo (Wang)', 488, 8320, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('57933a30-12e8-5e83-8e70-fb4655b20b15', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Chungseon (Goryeo)', null, 1275, 1325, 'Roi (1298, 1308-1313)', 'Goryeo (Wang)', 488, 8960, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ba381500-eed8-56c0-b5b6-70f53dd5e2e1', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Chungsuk (Goryeo)', null, 1294, 1339, 'Roi (1313-1330, 1332-1339)', 'Goryeo (Wang)', 488, 9600, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('67455130-db28-526f-802b-5c619be30a1f', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Chunghye (Goryeo)', null, 1315, 1344, 'Roi (1330-1332, 1339-1344)', 'Goryeo (Wang)', 739, 10240, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('819d9420-cfb7-52ac-8f82-aa2a4dd71208', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Chungmok (Goryeo)', null, 1337, 1348, 'Roi (1344-1348)', 'Goryeo (Wang)', 638, 10880, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b7def91e-2e1f-5e89-b7b4-4f35764e1189', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Chungjeong (Goryeo)', null, 1338, 1352, 'Roi (1349-1351)', 'Goryeo (Wang)', 1138, 10880, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e677f8b7-64e3-5b25-99d3-557b4ede7478', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Gongmin (Goryeo)', null, 1330, 1374, 'Roi (1351-1374), libère Goryeo des Yuan', 'Goryeo (Wang)', 138, 10240, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9d981fb7-511d-54ef-96f2-129c2cfb92e5', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'U (Goryeo)', null, 1365, 1389, 'Roi (1374-1388), détrôné', 'Goryeo (Wang)', 138, 10880, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d2ae0aa7-0c00-5d7e-a821-5e4b6206365c', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Chang (Goryeo)', null, 1380, 1389, 'Roi (1388-1389), détrôné', 'Goryeo (Wang)', 138, 11520, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4d0776e3-1c39-5113-b464-86b4d541ac2f', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Gongyang (Goryeo)', null, 1345, 1394, 'Dernier roi de Goryeo (1389-1392)', 'Goryeo (Wang)', 3000, 8960, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ceb5fa47-1a17-5156-9182-7dc9dd6e33d6', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Daejong (Wang Uk, fils de Taejo)', null, null, 969, 'Père de Seongjong, roi à titre posthume', 'Goryeo (Wang)', 0, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('75fd5df1-0223-5933-aa91-92a030171020', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Anjong (Wang Uk, fils de Taejo)', null, null, 996, 'Père de Hyeonjong, roi à titre posthume', 'Goryeo (Wang)', 1000, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b8f5b49d-6a58-5bfd-a686-e4991121a569', 'entry', 'ae22758c-d1de-50a1-a76d-8cc43db80246', 'Prince Wang Kyun (Jeongwon)', null, null, null, 'Père de Gongyang', 'Goryeo (Wang)', 3000, 8320, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('61cc1040-2c52-5e24-b01f-b5fd0e3b4555', '0ec04876-4d75-57dd-8881-76e420eb5d3f', 'parent');
  perform pg_temp.rel('61cc1040-2c52-5e24-b01f-b5fd0e3b4555', '7dba9dc2-60b3-5577-910a-3e5552a5c084', 'parent');
  perform pg_temp.rel('61cc1040-2c52-5e24-b01f-b5fd0e3b4555', 'f06aad33-f574-57e5-9e8b-8408c6c0b49c', 'parent');
  perform pg_temp.rel('61cc1040-2c52-5e24-b01f-b5fd0e3b4555', 'ceb5fa47-1a17-5156-9182-7dc9dd6e33d6', 'parent');
  perform pg_temp.rel('61cc1040-2c52-5e24-b01f-b5fd0e3b4555', '75fd5df1-0223-5933-aa91-92a030171020', 'parent');
  perform pg_temp.rel('f06aad33-f574-57e5-9e8b-8408c6c0b49c', 'bb891b55-2d3f-5d73-a2a5-f5b4f9e05862', 'parent');
  perform pg_temp.rel('ceb5fa47-1a17-5156-9182-7dc9dd6e33d6', 'c905c044-50b3-5c21-b4b5-07fbf74263a5', 'parent');
  perform pg_temp.rel('bb891b55-2d3f-5d73-a2a5-f5b4f9e05862', 'c994cfb5-a6e7-5284-b400-55b898ba31a2', 'parent');
  perform pg_temp.rel('75fd5df1-0223-5933-aa91-92a030171020', '1136f18e-f42f-5366-9358-061789dbbc46', 'parent');
  perform pg_temp.rel('1136f18e-f42f-5366-9358-061789dbbc46', 'd2491634-b975-5355-b765-00139d188563', 'parent');
  perform pg_temp.rel('1136f18e-f42f-5366-9358-061789dbbc46', 'c2781eae-716f-57c6-a87a-8e052c09cfac', 'parent');
  perform pg_temp.rel('1136f18e-f42f-5366-9358-061789dbbc46', '22250824-7be4-5595-9c1c-723aa22c80b4', 'parent');
  perform pg_temp.rel('22250824-7be4-5595-9c1c-723aa22c80b4', 'c9a65d8d-db36-534e-80b5-63bba6c7217d', 'parent');
  perform pg_temp.rel('22250824-7be4-5595-9c1c-723aa22c80b4', 'cf19ef77-a118-56b4-a143-c48e6dc0c11b', 'parent');
  perform pg_temp.rel('22250824-7be4-5595-9c1c-723aa22c80b4', '0a2df13c-4462-5360-9134-a89e8b614923', 'parent');
  perform pg_temp.rel('cf19ef77-a118-56b4-a143-c48e6dc0c11b', 'e313f9af-938e-5fd0-8dbd-96a39a9d2e5a', 'parent');
  perform pg_temp.rel('0a2df13c-4462-5360-9134-a89e8b614923', '4e6fa8bc-c6ea-558b-8331-e384088c8c9f', 'parent');
  perform pg_temp.rel('4e6fa8bc-c6ea-558b-8331-e384088c8c9f', 'aea4d6bf-3742-5a68-9c8b-3aa976068567', 'parent');
  perform pg_temp.rel('aea4d6bf-3742-5a68-9c8b-3aa976068567', '18dbd929-f32f-53d3-9fc6-bda67655a1ca', 'parent');
  perform pg_temp.rel('aea4d6bf-3742-5a68-9c8b-3aa976068567', 'c0b1db24-0a14-5723-b8ee-3fce701c2aab', 'parent');
  perform pg_temp.rel('aea4d6bf-3742-5a68-9c8b-3aa976068567', 'b5e99dc0-25fd-5ee2-a76f-b7fea1c66754', 'parent');
  perform pg_temp.rel('b5e99dc0-25fd-5ee2-a76f-b7fea1c66754', '4ec631df-17bf-5e97-8bbe-d18eca4fe5f4', 'parent');
  perform pg_temp.rel('c0b1db24-0a14-5723-b8ee-3fce701c2aab', 'bc06060b-fb2b-5d2b-aff5-91bf64fa71ec', 'parent');
  perform pg_temp.rel('bc06060b-fb2b-5d2b-aff5-91bf64fa71ec', '37e3248d-34ba-5e2d-a0b3-cba09b10f583', 'parent');
  perform pg_temp.rel('37e3248d-34ba-5e2d-a0b3-cba09b10f583', 'b9422680-fea0-594f-9352-d7f5ecc5624c', 'parent');
  perform pg_temp.rel('b9422680-fea0-594f-9352-d7f5ecc5624c', '35cf7abc-783b-5eca-a915-bfc8e7e7e2cf', 'parent');
  perform pg_temp.rel('35cf7abc-783b-5eca-a915-bfc8e7e7e2cf', '57933a30-12e8-5e83-8e70-fb4655b20b15', 'parent');
  perform pg_temp.rel('57933a30-12e8-5e83-8e70-fb4655b20b15', 'ba381500-eed8-56c0-b5b6-70f53dd5e2e1', 'parent');
  perform pg_temp.rel('ba381500-eed8-56c0-b5b6-70f53dd5e2e1', '67455130-db28-526f-802b-5c619be30a1f', 'parent');
  perform pg_temp.rel('ba381500-eed8-56c0-b5b6-70f53dd5e2e1', 'e677f8b7-64e3-5b25-99d3-557b4ede7478', 'parent');
  perform pg_temp.rel('67455130-db28-526f-802b-5c619be30a1f', '819d9420-cfb7-52ac-8f82-aa2a4dd71208', 'parent');
  perform pg_temp.rel('67455130-db28-526f-802b-5c619be30a1f', 'b7def91e-2e1f-5e89-b7b4-4f35764e1189', 'parent');
  perform pg_temp.rel('e677f8b7-64e3-5b25-99d3-557b4ede7478', '9d981fb7-511d-54ef-96f2-129c2cfb92e5', 'parent');
  perform pg_temp.rel('9d981fb7-511d-54ef-96f2-129c2cfb92e5', 'd2ae0aa7-0c00-5d7e-a821-5e4b6206365c', 'parent');
  perform pg_temp.rel('b8f5b49d-6a58-5bfd-a686-e4991121a569', '4d0776e3-1c39-5113-b464-86b4d541ac2f', 'parent');
  raise notice 'schema_v97 : % membres ajoutés.', 37;
end $$;
