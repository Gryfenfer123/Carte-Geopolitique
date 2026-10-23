-- arbres_v89.sql — Corée — dynastie Joseon (Yi) de Taejo à Sunjong, avec l'Empire coréen
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Joseon » (aucun n'existait). Rien n'est supprimé.
-- Source de la liste des rois : Wikipédia en anglais, « List of monarchs of Korea » (noms et règnes) ; dates de vie et filiations : connues par ailleurs (histoire coréenne), car la page ne les imprime pas. Les successions par adoption ou par collatéral (Seonjo, Injo, Cheoljong, Gojong…) passent par les princes intermédiaires ou par un lien « famille ».
-- La reine Min (impératrice Myeongseong) vient d'une famille sans arbre : signalée.
-- Non fait : Goryeo et Silla (la page ne donne pas de dates de vie ; à faire avec des sources dédiées), épouses des rois, princes non rois (hors intermédiaires dynastiques).
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
  if exists (select 1 from public.genealogy_members where id = 'b79acb03-8bcd-5487-98c4-bb750e037cfa') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Joseon » (KOR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'KOR' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour KOR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Joseon';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('be18c5a1-6ac5-5b4f-8127-809cffe1f105', cat_id, 'country', 'KOR', top, 'Joseon', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'be18c5a1-6ac5-5b4f-8127-809cffe1f105';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('aad25d66-fdcd-585d-9357-c52687f693d2', 'country', 'KOR', 'genealogy', 'Joseon', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b79acb03-8bcd-5487-98c4-bb750e037cfa', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Taejo (Yi Seong-gye)', null, 1335, 1408, 'Fondateur de Joseon (1392-1398)', 'Joseon (Yi)', 825, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fd20d656-8693-520a-9f5f-f4e99eacfc4c', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Jeongjong (Yi Bang-gwa)', null, 1357, 1419, 'Roi (1398-1400)', 'Joseon (Yi)', 1075, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('439dd911-bae0-51f3-93c6-e70beb4e9fd4', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Taejong (Yi Bang-won)', null, 1367, 1422, 'Roi (1400-1418)', 'Joseon (Yi)', 573, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a2363b5a-cf15-5583-a052-61f006c699d3', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Sejong le Grand (Yi Do)', null, 1397, 1450, 'Roi (1418-1450), inventeur du hangeul', 'Joseon (Yi)', 573, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8124b59c-655f-5c34-b510-d0cce301f8eb', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Munjong (Yi Hyang)', null, 1414, 1452, 'Roi (1450-1452)', 'Joseon (Yi)', 233, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('af62574b-d0e5-5720-85fe-090a68572912', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Danjong (Yi Hong-wi)', null, 1441, 1457, 'Roi (1452-1455)', 'Joseon (Yi)', 233, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0082a7cc-4cdf-5031-801a-fb8377b1d859', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Sejo (Yi Yu)', null, 1417, 1468, 'Roi (1455-1468)', 'Joseon (Yi)', 830, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cc4ed8e3-bb10-5592-a206-d0f9f1189042', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Yejong (Yi Hwang)', null, 1450, 1469, 'Roi (1468-1469)', 'Joseon (Yi)', 1233, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8f10ab82-b70b-53b0-9e8c-c0e8ad342c57', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Seongjong (Yi Hyeol)', null, 1457, 1494, 'Roi (1469-1494)', 'Joseon (Yi)', 733, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5e8a4ffd-1ead-5a16-a30d-4e949723c8d4', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Yeonsangun (Yi Yung)', null, 1476, 1506, 'Roi (1494-1506), détrôné', 'Joseon (Yi)', 995, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4ba22a20-51df-5e0e-9cf4-7058ab3d16b8', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Jungjong (Yi Yeok)', null, 1488, 1544, 'Roi (1506-1544)', 'Joseon (Yi)', 495, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('40184ea8-e755-5a7b-8aa2-9fca7c7028b8', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Injong (Yi Ho)', null, 1515, 1545, 'Roi (1544-1545)', 'Joseon (Yi)', 1000, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('76897351-a2b2-5310-9064-dd5ed793fcae', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Myeongjong (Yi Hwan)', null, 1534, 1567, 'Roi (1545-1567)', 'Joseon (Yi)', 0, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1c78a768-c6ca-5eaa-a542-4e9637713553', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Seonjo (Yi Yeon)', null, 1552, 1608, 'Roi (1567-1608), guerre d''Imjin', 'Joseon (Yi)', 500, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7a23b49d-1bc6-5112-8983-7904f6b62de8', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Gwanghaegun (Yi Hon)', null, 1575, 1641, 'Roi (1608-1623), détrôné', 'Joseon (Yi)', 255, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('36256d80-57fe-5b77-8aa6-17bffabdc754', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Injo (Yi Jong)', null, 1595, 1649, 'Roi (1623-1649)', 'Joseon (Yi)', 755, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('89badc38-b733-5884-bc24-2fe08edca651', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Hyojong (Yi Ho)', null, 1619, 1659, 'Roi (1649-1659)', 'Joseon (Yi)', 755, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('053f749d-9a57-54a7-9e76-28173d0681df', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Hyeonjong (Yi Yeon)', null, 1641, 1674, 'Roi (1659-1674)', 'Joseon (Yi)', 755, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e48d1491-be67-5a7f-b7a8-c9244cf4d87f', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Sukjong (Yi Sun)', null, 1661, 1720, 'Roi (1674-1720)', 'Joseon (Yi)', 755, 8320, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c533c415-865d-5ac7-b359-998459b3ba49', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Gyeongjong (Yi Yun)', null, 1688, 1724, 'Roi (1720-1724)', 'Joseon (Yi)', 494, 8960, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b6ef8974-eecd-5368-bf2c-d0f2a3b732f2', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Yeongjo (Yi Geum)', null, 1694, 1776, 'Roi (1724-1776)', 'Joseon (Yi)', 994, 8960, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aeba0717-6732-5ea0-9b98-06396bc01c1c', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Jeongjo (Yi San)', null, 1752, 1800, 'Roi (1776-1800)', 'Joseon (Yi)', 994, 10240, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b838195f-80df-5d4f-8985-9b6aa189a6c7', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Sunjo (Yi Gong)', null, 1790, 1834, 'Roi (1800-1834)', 'Joseon (Yi)', 994, 10880, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b2da0ece-3004-5915-8e66-950f758199e3', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Heonjong (Yi Hwan)', null, 1827, 1849, 'Roi (1834-1849)', 'Joseon (Yi)', 994, 12160, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c45cf3d7-e47e-572f-802e-549c8b0d3871', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Cheoljong (Yi Byeon)', null, 1831, 1864, 'Roi (1849-1864)', 'Joseon (Yi)', 3723, 9600, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f5f17bd0-4642-5ef6-89e8-ef837ef9b586', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Gojong (Yi Myeong-bok)', null, 1852, 1919, 'Roi (1864-1897) puis premier empereur coréen (1897-1907)', 'Joseon (Yi)', 2233, 10240, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1e511180-9766-55d9-9350-d58ecc1838d7', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Sunjong (Yi Cheok)', null, 1874, 1926, 'Dernier empereur de Corée (1907-1910)', 'Joseon (Yi)', 2478, 10880, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b717dd02-fc99-5ada-acff-2d69961cd177', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Deokjong (prince héritier Uigyeong)', null, 1438, 1457, 'Père de Seongjong, roi à titre posthume', 'Joseon (Yi)', 733, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b045d3b5-45d5-5662-a5ca-6e07d5189cab', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Prince Deokheung', null, 1530, 1559, 'Père de Seonjo', 'Joseon (Yi)', 500, 4480, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('881f06ef-b6a6-5a65-93a8-050d694e5ed7', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Prince Jeongwon (Wonjong)', null, 1580, 1619, 'Père d''Injo, roi à titre posthume', 'Joseon (Yi)', 755, 5760, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b90f5a99-ba2d-530a-950f-a3270d680c19', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Prince héritier Sado', null, 1735, 1762, 'Père de Jeongjo', 'Joseon (Yi)', 994, 9600, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4c6a1522-f041-53a6-93e9-68247a758511', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Prince héritier Hyomyeong', null, 1809, 1830, 'Père de Heonjong', 'Joseon (Yi)', 994, 11520, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('df4c7a36-6ec7-5aac-93e7-9281912185ee', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Heungseon Daewongun (Yi Ha-eung)', null, 1820, 1898, 'Régent, père de Gojong', 'Joseon (Yi)', 2233, 9600, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1015791d-fbe6-53a9-88d2-5eb30f191c96', 'entry', 'aad25d66-fdcd-585d-9357-c52687f693d2', 'Impératrice Myeongseong (reine Min)', null, 1851, 1895, 'Épouse de Gojong, assassinée', 'Joseon (Yi)', 2723, 10240, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('b79acb03-8bcd-5487-98c4-bb750e037cfa', 'fd20d656-8693-520a-9f5f-f4e99eacfc4c', 'parent');
  perform pg_temp.rel('b79acb03-8bcd-5487-98c4-bb750e037cfa', '439dd911-bae0-51f3-93c6-e70beb4e9fd4', 'parent');
  perform pg_temp.rel('439dd911-bae0-51f3-93c6-e70beb4e9fd4', 'a2363b5a-cf15-5583-a052-61f006c699d3', 'parent');
  perform pg_temp.rel('a2363b5a-cf15-5583-a052-61f006c699d3', '8124b59c-655f-5c34-b510-d0cce301f8eb', 'parent');
  perform pg_temp.rel('8124b59c-655f-5c34-b510-d0cce301f8eb', 'af62574b-d0e5-5720-85fe-090a68572912', 'parent');
  perform pg_temp.rel('a2363b5a-cf15-5583-a052-61f006c699d3', '0082a7cc-4cdf-5031-801a-fb8377b1d859', 'parent');
  perform pg_temp.rel('0082a7cc-4cdf-5031-801a-fb8377b1d859', 'cc4ed8e3-bb10-5592-a206-d0f9f1189042', 'parent');
  perform pg_temp.rel('0082a7cc-4cdf-5031-801a-fb8377b1d859', 'b717dd02-fc99-5ada-acff-2d69961cd177', 'parent');
  perform pg_temp.rel('b717dd02-fc99-5ada-acff-2d69961cd177', '8f10ab82-b70b-53b0-9e8c-c0e8ad342c57', 'parent');
  perform pg_temp.rel('8f10ab82-b70b-53b0-9e8c-c0e8ad342c57', '5e8a4ffd-1ead-5a16-a30d-4e949723c8d4', 'parent');
  perform pg_temp.rel('8f10ab82-b70b-53b0-9e8c-c0e8ad342c57', '4ba22a20-51df-5e0e-9cf4-7058ab3d16b8', 'parent');
  perform pg_temp.rel('4ba22a20-51df-5e0e-9cf4-7058ab3d16b8', '40184ea8-e755-5a7b-8aa2-9fca7c7028b8', 'parent');
  perform pg_temp.rel('4ba22a20-51df-5e0e-9cf4-7058ab3d16b8', '76897351-a2b2-5310-9064-dd5ed793fcae', 'parent');
  perform pg_temp.rel('4ba22a20-51df-5e0e-9cf4-7058ab3d16b8', 'b045d3b5-45d5-5662-a5ca-6e07d5189cab', 'parent');
  perform pg_temp.rel('b045d3b5-45d5-5662-a5ca-6e07d5189cab', '1c78a768-c6ca-5eaa-a542-4e9637713553', 'parent');
  perform pg_temp.rel('1c78a768-c6ca-5eaa-a542-4e9637713553', '7a23b49d-1bc6-5112-8983-7904f6b62de8', 'parent');
  perform pg_temp.rel('1c78a768-c6ca-5eaa-a542-4e9637713553', '881f06ef-b6a6-5a65-93a8-050d694e5ed7', 'parent');
  perform pg_temp.rel('881f06ef-b6a6-5a65-93a8-050d694e5ed7', '36256d80-57fe-5b77-8aa6-17bffabdc754', 'parent');
  perform pg_temp.rel('36256d80-57fe-5b77-8aa6-17bffabdc754', '89badc38-b733-5884-bc24-2fe08edca651', 'parent');
  perform pg_temp.rel('89badc38-b733-5884-bc24-2fe08edca651', '053f749d-9a57-54a7-9e76-28173d0681df', 'parent');
  perform pg_temp.rel('053f749d-9a57-54a7-9e76-28173d0681df', 'e48d1491-be67-5a7f-b7a8-c9244cf4d87f', 'parent');
  perform pg_temp.rel('e48d1491-be67-5a7f-b7a8-c9244cf4d87f', 'c533c415-865d-5ac7-b359-998459b3ba49', 'parent');
  perform pg_temp.rel('e48d1491-be67-5a7f-b7a8-c9244cf4d87f', 'b6ef8974-eecd-5368-bf2c-d0f2a3b732f2', 'parent');
  perform pg_temp.rel('b6ef8974-eecd-5368-bf2c-d0f2a3b732f2', 'b90f5a99-ba2d-530a-950f-a3270d680c19', 'parent');
  perform pg_temp.rel('b90f5a99-ba2d-530a-950f-a3270d680c19', 'aeba0717-6732-5ea0-9b98-06396bc01c1c', 'parent');
  perform pg_temp.rel('aeba0717-6732-5ea0-9b98-06396bc01c1c', 'b838195f-80df-5d4f-8985-9b6aa189a6c7', 'parent');
  perform pg_temp.rel('b838195f-80df-5d4f-8985-9b6aa189a6c7', '4c6a1522-f041-53a6-93e9-68247a758511', 'parent');
  perform pg_temp.rel('4c6a1522-f041-53a6-93e9-68247a758511', 'b2da0ece-3004-5915-8e66-950f758199e3', 'parent');
  perform pg_temp.rel('df4c7a36-6ec7-5aac-93e7-9281912185ee', 'f5f17bd0-4642-5ef6-89e8-ef837ef9b586', 'parent');
  perform pg_temp.rel('f5f17bd0-4642-5ef6-89e8-ef837ef9b586', '1e511180-9766-55d9-9350-d58ecc1838d7', 'parent');
  perform pg_temp.rel('b6ef8974-eecd-5368-bf2c-d0f2a3b732f2', 'c45cf3d7-e47e-572f-802e-549c8b0d3871', 'family');
  perform pg_temp.rel('b838195f-80df-5d4f-8985-9b6aa189a6c7', 'c45cf3d7-e47e-572f-802e-549c8b0d3871', 'family');
  perform pg_temp.rel('c45cf3d7-e47e-572f-802e-549c8b0d3871', 'f5f17bd0-4642-5ef6-89e8-ef837ef9b586', 'family');
  perform pg_temp.rel('f5f17bd0-4642-5ef6-89e8-ef837ef9b586', '1015791d-fbe6-53a9-88d2-5eb30f191c96', 'spouse');
  perform pg_temp.rel('1015791d-fbe6-53a9-88d2-5eb30f191c96', '1e511180-9766-55d9-9350-d58ecc1838d7', 'parent');
  raise notice 'schema_v89 : % membres ajoutés.', 34;
end $$;
