-- schema_v59.sql — Chine — Jin (Sima) : Jin occidentaux et orientaux
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Chine, étape 4 : dynastie Jin (Sima), de Sima Yi à Gong de Jin (Jin occidentaux 266-316 puis orientaux 317-420), un seul arbre.
-- Sources : pages Wikipédia anglaises de chaque empereur. Filiation Sima Zhou -> Sima Jin -> Yuan de Jin : non confirmée par les pages consultées, ajoutée de connaissance générale (marquée « à vérifier »).
-- Deux « Sima Yan » apparaissent dans la liste des fils de Wu : seul le prince Xiao de Wu (281-311), père de Min, est créé ; l'autre (prince de Dai, né en 272) est omis.
-- Les Seize Royaumes (Han-Zhao, Zhao postérieur, Yan, Qin, Liang…) ne sont pas traités ici (à décider).
-- Prérequis : v58 exécuté.
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
  if exists (select 1 from public.genealogy_members where id = '4b699325-50c9-5f98-bd22-3295e8b5aec2') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Jin (Sima) » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Jin (Sima)';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('a23f935a-7636-554c-9c39-43b9eb525ef6', cat_id, 'country', 'CHN', top, 'Jin (Sima)', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'a23f935a-7636-554c-9c39-43b9eb525ef6';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('767cc36d-697d-59e4-83fc-e80ec84890a5', 'country', 'CHN', 'genealogy', 'Jin (Sima)', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4b699325-50c9-5f98-bd22-3295e8b5aec2', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Fang', null, null, null, 'Père de Sima Yi', 'Sima (Jin)', 3400, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('122e72cf-e1a9-5198-848e-6665e225ef18', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Yi (Jin Xuandi)', null, 179, 251, 'Régent des Wei, ancêtre des Jin (empereur à titre posthume)', 'Sima (Jin)', 3400, 522, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a17b890e-7f94-50c6-ba3e-e5210f10d06d', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Zhang Chunhua (impératrice Xuanmu)', null, null, null, 'Épouse de Sima Yi', 'Zhang', 4805, 522, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('40add1f6-a3ac-5918-adbf-ad04d54065a7', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Shi (Jin Jingdi)', null, 208, 255, 'Régent des Wei (251-255)', 'Sima (Jin)', 3405, 1176, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5cbc750e-dc0d-585c-9432-62e85024cca3', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Zhao (Jin Wendi)', null, 211, 265, 'Régent des Wei (255-265)', 'Sima (Jin)', 2615, 1176, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f5295cbf-baf3-5760-a1b6-34aeb0150e08', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Zhou (prince de Langya)', null, null, null, 'Fils de Sima Yi (avec dame Fu)', 'Sima (Jin)', 5590, 1176, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ceeacadd-e80b-595b-b6a1-012e9d04edbf', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Xiahou Hui (impératrice Jinghuai)', null, 211, 234, 'Première épouse de Sima Shi', 'Xiahou', 3025, 1176, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('50145c6b-db79-5602-a6a7-2fb2bee6cf50', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Yang Huiyu (impératrice Jingxian)', null, 214, 278, 'Épouse de Sima Shi', 'Yang', 3785, 1176, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('088fd902-c315-55eb-9da1-7cbc93271581', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Wang Yuanji (impératrice Wenming)', null, 217, 268, 'Épouse de Sima Zhao, mère de Sima Yan', 'Wang (Donghai)', 2075, 1176, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('94b80d78-f897-51a6-acd6-60e1a1d12fdb', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Wu de Jin (Sima Yan)', null, 236, 290, 'Empereur de Chine (265 à 290), fondateur des Jin occidentaux', 'Sima (Jin)', 2345, 1636, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('da8f31c7-4ebc-501d-a012-6cd717fe49d7', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Impératrice Wuyuan (Yang Yan)', null, 238, 274, 'Impératrice de Chine', 'Yang', 345, 1636, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c6f70cef-2415-549e-a708-b1741b0c1432', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Impératrice Wudao (Yang Zhi)', null, 259, 292, 'Impératrice de Chine', 'Yang', 2725, 1636, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('607392d3-713b-5cde-8a97-486b0b7960e9', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Hui de Jin (Sima Zhong)', null, 259, 307, 'Empereur de Chine (290 à 307)', 'Sima (Jin)', 540, 2214, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('255ffa8a-a89e-502c-9161-6ecd220b8a9a', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Jian (prince Xian de Qin)', null, 262, 291, 'Fils de Wu', 'Sima (Jin)', 1680, 2214, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d9a6431d-0aa2-5f63-b780-ffae54601aa0', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Ying (prince de Chengdu)', null, 279, 306, 'Fils de Wu, prince de Chengdu', 'Sima (Jin)', 2060, 2214, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3c5235e2-5feb-5bf4-b5ca-66ebc2e704d4', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Yan (prince Xiao de Wu)', null, 281, 311, 'Fils de Wu, père de Min', 'Sima (Jin)', 2440, 2214, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8eed68a4-8396-5583-9731-0aa435f2d22d', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Huai de Jin (Sima Chi)', null, 284, 313, 'Empereur de Chine (307 à 311), empoisonné en captivité', 'Sima (Jin)', 3200, 2214, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3bc3bb84-8d06-5808-bfd7-1e9debe4052b', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Dame Wang Yuanji (王媛姬, mère de Huai)', null, null, null, 'Concubine de Wu, mère de Huai', 'Wang', 3855, 1636, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a11fdb1f-a527-5b61-95c8-ab2b3a48e05b', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Jia Nanfeng (impératrice Huijia)', null, 257, 300, 'Impératrice de Chine, au cœur de la guerre des Huit Princes', 'Jia', 920, 2214, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cee0fa7d-8916-5433-832e-6f118deeb310', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Yang Xianrong (impératrice Xianwen)', null, null, 322, 'Impératrice de Chine (300)', 'Yang', 1300, 2214, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4d01e923-50f8-586a-a3b0-32ad48431538', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Xie Jiu (Shuyuan)', null, null, 300, 'Concubine de Wu puis de Hui, mère du prince héritier', 'Xie', 0, 2214, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1f711b06-5a46-584d-9016-f75148be0b7e', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Yu (prince héritier Minhuai)', null, 278, 300, 'Prince héritier, fils de Hui', 'Sima (Jin)', 270, 2674, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('55586810-c7bf-5b2e-8f59-0977347fe5cd', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Liang Lanbi', null, null, null, 'Impératrice de Chine (épouse de Huai)', 'Liang', 3580, 2214, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e12b64a4-7442-5f4a-bc2b-fa55f1c5bc7b', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Min de Jin (Sima Ye)', null, 300, 318, 'Dernier empereur des Jin occidentaux (313 à 316)', 'Sima (Jin)', 2420, 2700, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('78c0bd6e-1138-5512-acaa-b4a38d24bf89', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Dame Xun (fille de Xun Xu)', null, null, null, 'Mère de Min', 'Xun', 2820, 2214, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9f6571f7-035f-5c1a-81d2-f3ecc4b14188', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Jin (prince de Langya)', null, null, 290, 'Prince de Langya, père de Yuan', 'Sima (Jin)', 5590, 1800, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8d37e442-475a-5608-9b88-9bb0dc0d5310', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Xiahou Guangji', null, null, null, 'Princesse consort de Langya, mère de Yuan', 'Xiahou', 6130, 1800, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ae7c1e2e-2b68-5ade-ac85-78a95a3242fc', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Yuan de Jin (Sima Rui)', null, 276, 323, 'Empereur de Chine (318 à 323), fondateur des Jin orientaux', 'Sima (Jin)', 5860, 2268, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f09043b0-d178-5154-885e-1be80672000e', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Impératrice Yuanjing (Yu Mengmu)', null, 277, 312, 'Impératrice de Chine', 'Yu', 3960, 2268, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fe2aea62-6f7a-5560-a14d-03696ab1f6bb', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Zheng Achun (impératrice douairière Jianwenxuan)', null, null, 326, 'Concubine de Yuan, mère de Jianwen', 'Zheng', 7520, 2268, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e7758921-a291-5286-88b5-a86ea61635bf', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Ming de Jin (Sima Shao)', null, 299, 325, 'Empereur de Chine (323 à 325)', 'Sima (Jin)', 4260, 2866, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fbb63514-3b5d-5eaf-8786-3783b1e72e70', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Pou (prince de Langya)', null, 300, 317, 'Fils de Yuan', 'Sima (Jin)', 4670, 2866, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1fd16fbf-f403-552f-a767-16f82a45c184', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Chong (prince de Donghai)', null, 311, 341, 'Fils de Yuan', 'Sima (Jin)', 5080, 2866, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('79a14411-8cf9-5812-a50d-7a6421dba1f0', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Xi (prince de Wuling)', null, 316, 381, 'Fils de Yuan', 'Sima (Jin)', 5490, 2866, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('074df2cd-9ea7-534c-b565-2fbb4cbe3aca', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Yu Wenjun (impératrice Mingmu)', null, 297, 328, 'Impératrice de Chine', 'Yu', 3396, 2866, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ea2dc4ea-e7c9-5cd7-b545-1f3c851be771', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Cheng de Jin (Sima Yan)', null, 321, 342, 'Empereur de Chine (325 à 342)', 'Sima (Jin)', 3324, 3326, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0c391c74-30e3-5b18-9153-3ae375d22330', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Kang de Jin (Sima Yue)', null, 322, 344, 'Empereur de Chine (342 à 344)', 'Sima (Jin)', 4332, 3326, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7fb88f8a-d99d-50f9-accf-7b3987ccb5c4', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Du Lingyang (impératrice Chenggong)', null, 321, 341, 'Impératrice de Chine', 'Du', 2944, 3326, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('813a714b-9cba-5238-b0ab-e80b47a9dc53', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Consort Zhou (mère d''Ai et de Fei)', null, null, 363, 'Concubine de Cheng', 'Zhou', 3889, 3326, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('209759c2-12be-5032-9396-ce8d3652f501', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Chu Suanzi (impératrice Kangxian)', null, 324, 384, 'Impératrice de Chine', 'Chu', 4872, 3326, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('471059f2-f274-5fcd-98ed-4ef805a38d85', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Mu de Jin (Sima Dan)', null, 343, 361, 'Empereur de Chine (344 à 361)', 'Sima (Jin)', 4602, 3786, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d7cf24d1-2e9f-549c-8659-034321e8db68', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'He Fani (impératrice Muzhang)', null, 339, 404, 'Impératrice de Chine', 'He', 4982, 3786, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c6f897b9-df64-55b0-a7cb-b84abfdc31e4', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Ai de Jin (Sima Pi)', null, 341, 365, 'Empereur de Chine (361 à 365)', 'Sima (Jin)', 3402, 3786, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8224a3e3-1e4f-5f5b-8377-a784d72d34b7', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Fei de Jin (Sima Yi)', null, 342, 386, 'Empereur de Chine (365 à 371), déposé', 'Sima (Jin)', 3812, 3786, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('41a86a85-192a-5e7f-9215-885fa366c0cb', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Wang Muzhi (impératrice Aijing)', null, null, 365, 'Impératrice de Chine', 'Wang (Taiyuan)', 3022, 3786, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d19bfc6c-b79b-5ad4-b318-9dc78b372ed6', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Yu Daolian (impératrice Xiao)', null, null, 366, 'Impératrice de Chine', 'Yu', 4192, 3786, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('91931bdf-9410-58e3-b313-455eac0ffa4d', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Jianwen de Jin (Sima Yu)', null, 320, 372, 'Empereur de Chine (371 à 372)', 'Sima (Jin)', 6690, 2866, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cf343971-cb11-5807-bce8-d2692be35894', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Wang Jianji (impératrice Jianwenshun)', null, null, 348, 'Épouse de Jianwen', 'Wang (Taiyuan)', 5900, 2866, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bbb65bd5-74eb-557f-89cf-baced02e7dc2', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Li Lingrong (impératrice douairière Xiaowuwen)', null, null, 400, 'Concubine de Jianwen, mère de Xiaowu', 'Li', 7480, 2866, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e8ec80d1-3aa0-5f9d-8660-57c6d15ca1a1', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Xiaowu de Jin (Sima Yao)', null, 362, 396, 'Empereur de Chine (372 à 396)', 'Sima (Jin)', 7085, 3834, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('121f01e6-f04c-56f5-88f0-989c4da572a7', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Sima Daozi (prince de Kuaiji)', null, null, null, 'Fils de Jianwen, régent', 'Sima (Jin)', 6295, 3834, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('47a8a222-2791-515e-9484-5cb732d8ef0e', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Wang Fahui (impératrice Xiaowuding)', null, 360, 380, 'Impératrice de Chine', 'Wang (Taiyuan)', 6705, 3834, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('31a9ed42-0f98-5d62-90d1-ffd1aabe0951', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Chen Guinü (impératrice douairière Ande)', null, 362, 390, 'Concubine de Xiaowu, mère d''An et de Gong', 'Chen', 7650, 3834, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('508a00d5-363c-5819-9bf6-fc50ac61366e', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'An de Jin (Sima Dezong)', null, 382, 419, 'Empereur de Chine (396 à 419)', 'Sima (Jin)', 7162, 4294, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3c1b6772-710a-51f5-a96e-40ea07fbd6d5', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Gong de Jin (Sima Dewen)', null, 386, 421, 'Dernier empereur des Jin (419 à 420)', 'Sima (Jin)', 7572, 4294, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1ab6dfd6-2ae7-5d2d-a949-1ec93d812f0e', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Wang Shen''ai (impératrice Anxi)', null, 384, 412, 'Impératrice de Chine', 'Wang (Langya)', 6782, 4294, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2e109a15-8df2-5550-ad18-5ccb9ca7ecef', 'entry', '767cc36d-697d-59e4-83fc-e80ec84890a5', 'Chu Lingyuan (impératrice Gongsi)', null, 384, 436, 'Impératrice de Chine', 'Chu', 7952, 4294, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('4b699325-50c9-5f98-bd22-3295e8b5aec2', '122e72cf-e1a9-5198-848e-6665e225ef18', 'parent');
  perform pg_temp.rel('122e72cf-e1a9-5198-848e-6665e225ef18', 'a17b890e-7f94-50c6-ba3e-e5210f10d06d', 'spouse');
  perform pg_temp.rel('122e72cf-e1a9-5198-848e-6665e225ef18', '40add1f6-a3ac-5918-adbf-ad04d54065a7', 'parent');
  perform pg_temp.rel('122e72cf-e1a9-5198-848e-6665e225ef18', '5cbc750e-dc0d-585c-9432-62e85024cca3', 'parent');
  perform pg_temp.rel('122e72cf-e1a9-5198-848e-6665e225ef18', 'f5295cbf-baf3-5760-a1b6-34aeb0150e08', 'parent');
  perform pg_temp.rel('a17b890e-7f94-50c6-ba3e-e5210f10d06d', '40add1f6-a3ac-5918-adbf-ad04d54065a7', 'parent');
  perform pg_temp.rel('a17b890e-7f94-50c6-ba3e-e5210f10d06d', '5cbc750e-dc0d-585c-9432-62e85024cca3', 'parent');
  perform pg_temp.rel('40add1f6-a3ac-5918-adbf-ad04d54065a7', 'ceeacadd-e80b-595b-b6a1-012e9d04edbf', 'spouse');
  perform pg_temp.rel('40add1f6-a3ac-5918-adbf-ad04d54065a7', '50145c6b-db79-5602-a6a7-2fb2bee6cf50', 'spouse');
  perform pg_temp.rel('5cbc750e-dc0d-585c-9432-62e85024cca3', '088fd902-c315-55eb-9da1-7cbc93271581', 'spouse');
  perform pg_temp.rel('5cbc750e-dc0d-585c-9432-62e85024cca3', '94b80d78-f897-51a6-acd6-60e1a1d12fdb', 'parent');
  perform pg_temp.rel('088fd902-c315-55eb-9da1-7cbc93271581', '94b80d78-f897-51a6-acd6-60e1a1d12fdb', 'parent');
  perform pg_temp.rel('94b80d78-f897-51a6-acd6-60e1a1d12fdb', 'da8f31c7-4ebc-501d-a012-6cd717fe49d7', 'spouse');
  perform pg_temp.rel('94b80d78-f897-51a6-acd6-60e1a1d12fdb', 'c6f70cef-2415-549e-a708-b1741b0c1432', 'spouse');
  perform pg_temp.rel('94b80d78-f897-51a6-acd6-60e1a1d12fdb', '607392d3-713b-5cde-8a97-486b0b7960e9', 'parent');
  perform pg_temp.rel('da8f31c7-4ebc-501d-a012-6cd717fe49d7', '607392d3-713b-5cde-8a97-486b0b7960e9', 'parent');
  perform pg_temp.rel('94b80d78-f897-51a6-acd6-60e1a1d12fdb', '255ffa8a-a89e-502c-9161-6ecd220b8a9a', 'parent');
  perform pg_temp.rel('94b80d78-f897-51a6-acd6-60e1a1d12fdb', 'd9a6431d-0aa2-5f63-b780-ffae54601aa0', 'parent');
  perform pg_temp.rel('94b80d78-f897-51a6-acd6-60e1a1d12fdb', '3c5235e2-5feb-5bf4-b5ca-66ebc2e704d4', 'parent');
  perform pg_temp.rel('94b80d78-f897-51a6-acd6-60e1a1d12fdb', '8eed68a4-8396-5583-9731-0aa435f2d22d', 'parent');
  perform pg_temp.rel('94b80d78-f897-51a6-acd6-60e1a1d12fdb', '3bc3bb84-8d06-5808-bfd7-1e9debe4052b', 'spouse');
  perform pg_temp.rel('3bc3bb84-8d06-5808-bfd7-1e9debe4052b', '8eed68a4-8396-5583-9731-0aa435f2d22d', 'parent');
  perform pg_temp.rel('607392d3-713b-5cde-8a97-486b0b7960e9', 'a11fdb1f-a527-5b61-95c8-ab2b3a48e05b', 'spouse');
  perform pg_temp.rel('607392d3-713b-5cde-8a97-486b0b7960e9', 'cee0fa7d-8916-5433-832e-6f118deeb310', 'spouse');
  perform pg_temp.rel('607392d3-713b-5cde-8a97-486b0b7960e9', '4d01e923-50f8-586a-a3b0-32ad48431538', 'spouse');
  perform pg_temp.rel('607392d3-713b-5cde-8a97-486b0b7960e9', '1f711b06-5a46-584d-9016-f75148be0b7e', 'parent');
  perform pg_temp.rel('4d01e923-50f8-586a-a3b0-32ad48431538', '1f711b06-5a46-584d-9016-f75148be0b7e', 'parent');
  perform pg_temp.rel('8eed68a4-8396-5583-9731-0aa435f2d22d', '55586810-c7bf-5b2e-8f59-0977347fe5cd', 'spouse');
  perform pg_temp.rel('3c5235e2-5feb-5bf4-b5ca-66ebc2e704d4', '78c0bd6e-1138-5512-acaa-b4a38d24bf89', 'spouse');
  perform pg_temp.rel('3c5235e2-5feb-5bf4-b5ca-66ebc2e704d4', 'e12b64a4-7442-5f4a-bc2b-fa55f1c5bc7b', 'parent');
  perform pg_temp.rel('78c0bd6e-1138-5512-acaa-b4a38d24bf89', 'e12b64a4-7442-5f4a-bc2b-fa55f1c5bc7b', 'parent');
  perform pg_temp.rel('f5295cbf-baf3-5760-a1b6-34aeb0150e08', '9f6571f7-035f-5c1a-81d2-f3ecc4b14188', 'parent');
  perform pg_temp.rel('9f6571f7-035f-5c1a-81d2-f3ecc4b14188', '8d37e442-475a-5608-9b88-9bb0dc0d5310', 'spouse');
  perform pg_temp.rel('9f6571f7-035f-5c1a-81d2-f3ecc4b14188', 'ae7c1e2e-2b68-5ade-ac85-78a95a3242fc', 'parent');
  perform pg_temp.rel('8d37e442-475a-5608-9b88-9bb0dc0d5310', 'ae7c1e2e-2b68-5ade-ac85-78a95a3242fc', 'parent');
  perform pg_temp.rel('ae7c1e2e-2b68-5ade-ac85-78a95a3242fc', 'f09043b0-d178-5154-885e-1be80672000e', 'spouse');
  perform pg_temp.rel('ae7c1e2e-2b68-5ade-ac85-78a95a3242fc', 'fe2aea62-6f7a-5560-a14d-03696ab1f6bb', 'spouse');
  perform pg_temp.rel('ae7c1e2e-2b68-5ade-ac85-78a95a3242fc', 'e7758921-a291-5286-88b5-a86ea61635bf', 'parent');
  perform pg_temp.rel('f09043b0-d178-5154-885e-1be80672000e', 'e7758921-a291-5286-88b5-a86ea61635bf', 'parent');
  perform pg_temp.rel('ae7c1e2e-2b68-5ade-ac85-78a95a3242fc', 'fbb63514-3b5d-5eaf-8786-3783b1e72e70', 'parent');
  perform pg_temp.rel('ae7c1e2e-2b68-5ade-ac85-78a95a3242fc', '1fd16fbf-f403-552f-a767-16f82a45c184', 'parent');
  perform pg_temp.rel('ae7c1e2e-2b68-5ade-ac85-78a95a3242fc', '79a14411-8cf9-5812-a50d-7a6421dba1f0', 'parent');
  perform pg_temp.rel('f09043b0-d178-5154-885e-1be80672000e', 'fbb63514-3b5d-5eaf-8786-3783b1e72e70', 'parent');
  perform pg_temp.rel('e7758921-a291-5286-88b5-a86ea61635bf', '074df2cd-9ea7-534c-b565-2fbb4cbe3aca', 'spouse');
  perform pg_temp.rel('e7758921-a291-5286-88b5-a86ea61635bf', 'ea2dc4ea-e7c9-5cd7-b545-1f3c851be771', 'parent');
  perform pg_temp.rel('074df2cd-9ea7-534c-b565-2fbb4cbe3aca', 'ea2dc4ea-e7c9-5cd7-b545-1f3c851be771', 'parent');
  perform pg_temp.rel('e7758921-a291-5286-88b5-a86ea61635bf', '0c391c74-30e3-5b18-9153-3ae375d22330', 'parent');
  perform pg_temp.rel('074df2cd-9ea7-534c-b565-2fbb4cbe3aca', '0c391c74-30e3-5b18-9153-3ae375d22330', 'parent');
  perform pg_temp.rel('ea2dc4ea-e7c9-5cd7-b545-1f3c851be771', '7fb88f8a-d99d-50f9-accf-7b3987ccb5c4', 'spouse');
  perform pg_temp.rel('ea2dc4ea-e7c9-5cd7-b545-1f3c851be771', '813a714b-9cba-5238-b0ab-e80b47a9dc53', 'spouse');
  perform pg_temp.rel('0c391c74-30e3-5b18-9153-3ae375d22330', '209759c2-12be-5032-9396-ce8d3652f501', 'spouse');
  perform pg_temp.rel('0c391c74-30e3-5b18-9153-3ae375d22330', '471059f2-f274-5fcd-98ed-4ef805a38d85', 'parent');
  perform pg_temp.rel('209759c2-12be-5032-9396-ce8d3652f501', '471059f2-f274-5fcd-98ed-4ef805a38d85', 'parent');
  perform pg_temp.rel('471059f2-f274-5fcd-98ed-4ef805a38d85', 'd7cf24d1-2e9f-549c-8659-034321e8db68', 'spouse');
  perform pg_temp.rel('ea2dc4ea-e7c9-5cd7-b545-1f3c851be771', 'c6f897b9-df64-55b0-a7cb-b84abfdc31e4', 'parent');
  perform pg_temp.rel('813a714b-9cba-5238-b0ab-e80b47a9dc53', 'c6f897b9-df64-55b0-a7cb-b84abfdc31e4', 'parent');
  perform pg_temp.rel('ea2dc4ea-e7c9-5cd7-b545-1f3c851be771', '8224a3e3-1e4f-5f5b-8377-a784d72d34b7', 'parent');
  perform pg_temp.rel('813a714b-9cba-5238-b0ab-e80b47a9dc53', '8224a3e3-1e4f-5f5b-8377-a784d72d34b7', 'parent');
  perform pg_temp.rel('c6f897b9-df64-55b0-a7cb-b84abfdc31e4', '41a86a85-192a-5e7f-9215-885fa366c0cb', 'spouse');
  perform pg_temp.rel('8224a3e3-1e4f-5f5b-8377-a784d72d34b7', 'd19bfc6c-b79b-5ad4-b318-9dc78b372ed6', 'spouse');
  perform pg_temp.rel('ae7c1e2e-2b68-5ade-ac85-78a95a3242fc', '91931bdf-9410-58e3-b313-455eac0ffa4d', 'parent');
  perform pg_temp.rel('fe2aea62-6f7a-5560-a14d-03696ab1f6bb', '91931bdf-9410-58e3-b313-455eac0ffa4d', 'parent');
  perform pg_temp.rel('91931bdf-9410-58e3-b313-455eac0ffa4d', 'cf343971-cb11-5807-bce8-d2692be35894', 'spouse');
  perform pg_temp.rel('91931bdf-9410-58e3-b313-455eac0ffa4d', 'bbb65bd5-74eb-557f-89cf-baced02e7dc2', 'spouse');
  perform pg_temp.rel('91931bdf-9410-58e3-b313-455eac0ffa4d', 'e8ec80d1-3aa0-5f9d-8660-57c6d15ca1a1', 'parent');
  perform pg_temp.rel('bbb65bd5-74eb-557f-89cf-baced02e7dc2', 'e8ec80d1-3aa0-5f9d-8660-57c6d15ca1a1', 'parent');
  perform pg_temp.rel('91931bdf-9410-58e3-b313-455eac0ffa4d', '121f01e6-f04c-56f5-88f0-989c4da572a7', 'parent');
  perform pg_temp.rel('e8ec80d1-3aa0-5f9d-8660-57c6d15ca1a1', '47a8a222-2791-515e-9484-5cb732d8ef0e', 'spouse');
  perform pg_temp.rel('e8ec80d1-3aa0-5f9d-8660-57c6d15ca1a1', '31a9ed42-0f98-5d62-90d1-ffd1aabe0951', 'spouse');
  perform pg_temp.rel('e8ec80d1-3aa0-5f9d-8660-57c6d15ca1a1', '508a00d5-363c-5819-9bf6-fc50ac61366e', 'parent');
  perform pg_temp.rel('31a9ed42-0f98-5d62-90d1-ffd1aabe0951', '508a00d5-363c-5819-9bf6-fc50ac61366e', 'parent');
  perform pg_temp.rel('e8ec80d1-3aa0-5f9d-8660-57c6d15ca1a1', '3c1b6772-710a-51f5-a96e-40ea07fbd6d5', 'parent');
  perform pg_temp.rel('31a9ed42-0f98-5d62-90d1-ffd1aabe0951', '3c1b6772-710a-51f5-a96e-40ea07fbd6d5', 'parent');
  perform pg_temp.rel('508a00d5-363c-5819-9bf6-fc50ac61366e', '1ab6dfd6-2ae7-5d2d-a949-1ec93d812f0e', 'spouse');
  perform pg_temp.rel('3c1b6772-710a-51f5-a96e-40ea07fbd6d5', '2e109a15-8df2-5550-ad18-5ccb9ca7ecef', 'spouse');
  raise notice 'schema_v59 : % membres ajoutés.', 57;
end $$;
