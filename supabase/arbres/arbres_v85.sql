-- arbres_v85.sql — Chine — dynastie Ming de Hongwu à Chongzhen
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Ming » (aucun n'existait). Rien n'est supprimé.
-- Dates : connues par ailleurs (histoire de Chine), aucune page consultée pour ce lot. Jiajing descend de Chenghua par son père Zhu Youyuan (prince de Xing), non empereur.
-- Les impératrices Ma et Xu viennent de familles sans arbre : signalées.
-- Non fait : princes non empereurs hors Zhu Biao et Zhu Youyuan, autres épouses.
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
  if exists (select 1 from public.genealogy_members where id = '6c13ec39-aecc-5700-95d5-afda8821e715') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Ming » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Ming';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('38c8b665-8194-5697-980d-3199db53a468', cat_id, 'country', 'CHN', top, 'Ming', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '38c8b665-8194-5697-980d-3199db53a468';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('392caaa1-f90e-511f-823f-68d42a6b7386', 'country', 'CHN', 'genealogy', 'Ming', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6c13ec39-aecc-5700-95d5-afda8821e715', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Ming Taizu (Zhu Yuanzhang, Hongwu)', null, 1328, 1398, 'Fondateur des Ming (1368-1398)', 'Ming (Zhu)', 490, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8bb53e04-b454-502c-b4eb-59b20ea939b0', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Zhu Biao', null, 1355, 1392, 'Prince héritier, mort avant son père', 'Ming (Zhu)', 204, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('17954e50-090a-55cb-9386-a58b6d480316', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Jianwen (Zhu Yunwen)', null, 1377, 1402, 'Empereur (1398-1402)', 'Ming (Zhu)', 204, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d0af171a-0a14-5428-9ae9-46423f2c8803', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Yongle (Zhu Di)', null, 1360, 1424, 'Empereur (1402-1424)', 'Ming (Zhu)', 704, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1bc53dbc-c51d-505e-af51-82a11f3d414f', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Hongxi (Zhu Gaochi)', null, 1378, 1425, 'Empereur (1424-1425)', 'Ming (Zhu)', 949, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aab34ef2-955c-5343-8a01-0b784b1b3eff', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Xuande (Zhu Zhanji)', null, 1399, 1435, 'Empereur (1425-1435)', 'Ming (Zhu)', 949, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('56301ebf-501e-5472-aeed-64bbd734fd84', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Zhengtong / Tianshun (Zhu Qizhen)', null, 1427, 1464, 'Empereur (1435-1449 et 1457-1464)', 'Ming (Zhu)', 1251, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dc2eaa1e-070e-58d4-8d97-26d51a43e4b1', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Jingtai (Zhu Qiyu)', null, 1428, 1457, 'Empereur (1449-1457)', 'Ming (Zhu)', 736, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c732b597-ff6e-5b17-8064-86717f1d4402', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Chenghua (Zhu Jianshen)', null, 1447, 1487, 'Empereur (1464-1487)', 'Ming (Zhu)', 1251, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('40ffdeb3-449a-5917-a169-b352c85a3311', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Hongzhi (Zhu Youtang)', null, 1470, 1505, 'Empereur (1487-1505)', 'Ming (Zhu)', 1028, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bc139f8a-fce5-526b-bf68-299f9edde932', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Zhengde (Zhu Houzhao)', null, 1491, 1521, 'Empereur (1505-1521)', 'Ming (Zhu)', 1028, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6886691a-64d9-5480-bafd-7918f43e611c', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Zhu Youyuan, prince de Xing', null, 1476, 1519, 'Père de Jiajing', 'Ming (Zhu)', 1545, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bf2d6481-8ff0-5db7-a228-60ee31761264', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Jiajing (Zhu Houcong)', null, 1507, 1567, 'Empereur (1521-1567)', 'Ming (Zhu)', 1545, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('260a1810-72ae-5e8b-bb28-ac1b93683ef6', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Longqing (Zhu Zaiji)', null, 1537, 1572, 'Empereur (1567-1572)', 'Ming (Zhu)', 1545, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9ebfe12d-65d4-5c10-8202-b6e9f0da5d4d', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Wanli (Zhu Yijun)', null, 1563, 1620, 'Empereur (1572-1620)', 'Ming (Zhu)', 1545, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('73377e87-63fc-5c62-af07-7fca88ba468b', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Taichang (Zhu Changluo)', null, 1582, 1620, 'Empereur (1620)', 'Ming (Zhu)', 1545, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('368154fa-d4bc-5df8-aff8-2fb7627bbbb1', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Tianqi (Zhu Youjiao)', null, 1605, 1627, 'Empereur (1620-1627)', 'Ming (Zhu)', 1296, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f33790e3-7599-51f9-871f-2c075c9f19eb', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Chongzhen (Zhu Youjian)', null, 1611, 1644, 'Dernier empereur Ming (1627-1644)', 'Ming (Zhu)', 1796, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ef8a1e14-86f0-5772-9b82-14d6c8ff7aa7', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Impératrice Ma', null, 1332, 1382, 'Épouse de Hongwu', 'Ma', 0, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8c3e94db-c096-55fe-a1c0-416ba27cfa98', 'entry', '392caaa1-f90e-511f-823f-68d42a6b7386', 'Impératrice Xu', null, 1362, 1407, 'Épouse de Yongle', 'Xu', 1194, 640, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('6c13ec39-aecc-5700-95d5-afda8821e715', '8bb53e04-b454-502c-b4eb-59b20ea939b0', 'parent');
  perform pg_temp.rel('8bb53e04-b454-502c-b4eb-59b20ea939b0', '17954e50-090a-55cb-9386-a58b6d480316', 'parent');
  perform pg_temp.rel('6c13ec39-aecc-5700-95d5-afda8821e715', 'd0af171a-0a14-5428-9ae9-46423f2c8803', 'parent');
  perform pg_temp.rel('d0af171a-0a14-5428-9ae9-46423f2c8803', '1bc53dbc-c51d-505e-af51-82a11f3d414f', 'parent');
  perform pg_temp.rel('1bc53dbc-c51d-505e-af51-82a11f3d414f', 'aab34ef2-955c-5343-8a01-0b784b1b3eff', 'parent');
  perform pg_temp.rel('aab34ef2-955c-5343-8a01-0b784b1b3eff', '56301ebf-501e-5472-aeed-64bbd734fd84', 'parent');
  perform pg_temp.rel('aab34ef2-955c-5343-8a01-0b784b1b3eff', 'dc2eaa1e-070e-58d4-8d97-26d51a43e4b1', 'parent');
  perform pg_temp.rel('56301ebf-501e-5472-aeed-64bbd734fd84', 'c732b597-ff6e-5b17-8064-86717f1d4402', 'parent');
  perform pg_temp.rel('c732b597-ff6e-5b17-8064-86717f1d4402', '40ffdeb3-449a-5917-a169-b352c85a3311', 'parent');
  perform pg_temp.rel('40ffdeb3-449a-5917-a169-b352c85a3311', 'bc139f8a-fce5-526b-bf68-299f9edde932', 'parent');
  perform pg_temp.rel('c732b597-ff6e-5b17-8064-86717f1d4402', '6886691a-64d9-5480-bafd-7918f43e611c', 'parent');
  perform pg_temp.rel('6886691a-64d9-5480-bafd-7918f43e611c', 'bf2d6481-8ff0-5db7-a228-60ee31761264', 'parent');
  perform pg_temp.rel('bf2d6481-8ff0-5db7-a228-60ee31761264', '260a1810-72ae-5e8b-bb28-ac1b93683ef6', 'parent');
  perform pg_temp.rel('260a1810-72ae-5e8b-bb28-ac1b93683ef6', '9ebfe12d-65d4-5c10-8202-b6e9f0da5d4d', 'parent');
  perform pg_temp.rel('9ebfe12d-65d4-5c10-8202-b6e9f0da5d4d', '73377e87-63fc-5c62-af07-7fca88ba468b', 'parent');
  perform pg_temp.rel('73377e87-63fc-5c62-af07-7fca88ba468b', '368154fa-d4bc-5df8-aff8-2fb7627bbbb1', 'parent');
  perform pg_temp.rel('73377e87-63fc-5c62-af07-7fca88ba468b', 'f33790e3-7599-51f9-871f-2c075c9f19eb', 'parent');
  perform pg_temp.rel('6c13ec39-aecc-5700-95d5-afda8821e715', 'ef8a1e14-86f0-5772-9b82-14d6c8ff7aa7', 'spouse');
  perform pg_temp.rel('ef8a1e14-86f0-5772-9b82-14d6c8ff7aa7', '8bb53e04-b454-502c-b4eb-59b20ea939b0', 'parent');
  perform pg_temp.rel('d0af171a-0a14-5428-9ae9-46423f2c8803', '8c3e94db-c096-55fe-a1c0-416ba27cfa98', 'spouse');
  perform pg_temp.rel('8c3e94db-c096-55fe-a1c0-416ba27cfa98', '1bc53dbc-c51d-505e-af51-82a11f3d414f', 'parent');
  raise notice 'schema_v85 : % membres ajoutés.', 20;
end $$;
