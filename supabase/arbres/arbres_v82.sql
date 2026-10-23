-- arbres_v82.sql — Chine — Sui et Tang : de Yang Jian au dernier empereur Tang
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Deux nouveaux arbres : « Sui » et « Tang » (aucun n'existait). Rien n'est supprimé.
-- Dates et filiations : connues par ailleurs (histoire de Chine), aucune page consultée pour ce lot ; seules les filiations père-fils certaines sont posées. Gongdi de Sui (petit-fils de Yangdi) est relié par un lien « famille ». Années avant J.-C. : négatives (aucune ici).
-- Wu Zetian : épouse de Gaozong (aussi concubine de Taizong, non représenté) ; elle fonde la dynastie Zhou éphémère (690-705) et porte l'anneau rouge.
-- Les impératrices Dugu, Zhangsun et la concubine Yang Guifei viennent de familles sans arbre : placées ici et signalées.
-- Non fait : princes héritiers écartés (Li Jiancheng, Li Chengqian…), autres épouses.
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
  if exists (select 1 from public.genealogy_members where id = '7f0530d7-5ee1-52cc-939b-b6edd83cdeb8') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Sui » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Sui';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('a230861f-8df3-5ce4-b8dc-fbf83f878ca4', cat_id, 'country', 'CHN', top, 'Sui', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'a230861f-8df3-5ce4-b8dc-fbf83f878ca4';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('2a2fd59f-b83c-5ae9-9ca5-a5c90ffdf5f3', 'country', 'CHN', 'genealogy', 'Sui', cat_id, sec, admin_id);
  -- Arbre « Tang » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Tang';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('c66d1ed4-b35c-50c1-954b-c744ce4777c6', cat_id, 'country', 'CHN', top, 'Tang', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'c66d1ed4-b35c-50c1-954b-c744ce4777c6';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'country', 'CHN', 'genealogy', 'Tang', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7f0530d7-5ee1-52cc-939b-b6edd83cdeb8', 'entry', '2a2fd59f-b83c-5ae9-9ca5-a5c90ffdf5f3', 'Sui Wendi (Yang Jian)', null, 541, 604, 'Empereur fondateur des Sui (581-604)', 'Sui (Yang)', 490, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('acfe2e82-1bd2-5ee7-a259-ef1b86996109', 'entry', '2a2fd59f-b83c-5ae9-9ca5-a5c90ffdf5f3', 'Impératrice Dugu Qieluo', null, 544, 602, 'Épouse de Sui Wendi', 'Dugu', 0, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('95bd52f4-3e71-5044-b1c1-4b8c7720a4e7', 'entry', '2a2fd59f-b83c-5ae9-9ca5-a5c90ffdf5f3', 'Sui Yangdi (Yang Guang)', null, 569, 618, 'Empereur des Sui (604-618)', 'Sui (Yang)', 245, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a5d4102f-a59b-5529-a977-b8c4e7f3a305', 'entry', '2a2fd59f-b83c-5ae9-9ca5-a5c90ffdf5f3', 'Gongdi de Sui (Yang You)', null, 605, 619, 'Empereur des Sui (617-618), déposé', 'Sui (Yang)', 1490, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('50d8b36b-d5d5-5010-8274-04e8b4eaea6f', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Gaozu (Li Yuan)', null, 566, 635, 'Fondateur des Tang (618-626)', 'Tang (Li)', 544, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3e812595-50b0-5ce7-bd06-c8654b0e63a4', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Taizong (Li Shimin)', null, 598, 649, 'Empereur (626-649)', 'Tang (Li)', 544, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6fa0c66b-5b02-5eb7-8fb1-4ff031543ea8', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Gaozong (Li Zhi)', null, 628, 683, 'Empereur (649-683)', 'Tang (Li)', 299, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('33b6649d-638e-5d01-8cd2-4af43361f148', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Zhongzong (Li Xian)', null, 656, 710, 'Empereur (684 puis 705-710)', 'Tang (Li)', 290, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0a1bcdba-7512-5f1b-9477-a20aef29ca8a', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Ruizong (Li Dan)', null, 662, 716, 'Empereur (684-690 puis 710-712)', 'Tang (Li)', 790, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('19fc908c-5734-5cf7-b080-8df5e0b2af8f', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Xuanzong (Li Longji)', null, 685, 762, 'Empereur (712-756)', 'Tang (Li)', 790, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b94df8d2-7707-5ec1-9c58-bdba20379007', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Suzong (Li Heng)', null, 711, 762, 'Empereur (756-762)', 'Tang (Li)', 790, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7cf5a589-6c4b-555e-91c6-dacc89984a2d', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Daizong (Li Yu)', null, 726, 779, 'Empereur (762-779)', 'Tang (Li)', 790, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5ae27851-d68a-50f7-ab04-8590ba45e1b8', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Dezong (Li Kuo)', null, 742, 805, 'Empereur (779-805)', 'Tang (Li)', 790, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9c531355-e0fe-554c-b596-9f2cccaa16a7', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Shunzong (Li Song)', null, 761, 806, 'Empereur (805)', 'Tang (Li)', 790, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c7520c66-0e59-560b-a02b-30af462b0734', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Xianzong (Li Chun)', null, 778, 820, 'Empereur (805-820)', 'Tang (Li)', 790, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bfc330b0-62b1-5288-99cd-0bd0d6c973c3', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Muzong (Li Heng)', null, 795, 824, 'Empereur (820-824)', 'Tang (Li)', 1106, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d3e953ff-93c2-56d1-9d35-751b2177a95d', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Jingzong (Li Zhan)', null, 809, 827, 'Empereur (824-827)', 'Tang (Li)', 747, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8d873dce-6998-5a9b-abe3-f6d900cda70e', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Wenzong (Li Ang)', null, 809, 840, 'Empereur (827-840)', 'Tang (Li)', 1247, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('234fc026-03d3-5b86-9e21-a4b8a692510d', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Wuzong (Li Yan)', null, 814, 846, 'Empereur (840-846)', 'Tang (Li)', 1747, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a30a73af-1de3-5837-9785-e5dbd5e3308b', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Xuanzong II (Li Chen)', null, 810, 859, 'Empereur (846-859)', 'Tang (Li)', 247, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7f4197ce-449a-5f0e-9746-3727967153f5', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Yizong (Li Cui)', null, 833, 873, 'Empereur (859-873)', 'Tang (Li)', 247, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('43f3e712-33dc-525f-bd38-4562515b584c', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Xizong (Li Xuan)', null, 862, 888, 'Empereur (873-888)', 'Tang (Li)', 0, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('07f45c0e-d549-56a6-bbde-ae70b486f5d1', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Zhaozong (Li Ye)', null, 867, 904, 'Empereur (888-904)', 'Tang (Li)', 501, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6ab444f2-6375-508d-b1ad-9c21a65b61ea', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Tang Aidi (Li Zhu)', null, 892, 908, 'Dernier empereur Tang (904-907)', 'Tang (Li)', 501, 8320, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4456cda5-cd5b-5de2-96a1-2dee6d05ea50', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Wu Zetian (Wu Zhao)', null, 624, 705, 'Impératrice, seule femme empereur de Chine (Zhou, 690-705)', 'Wu (Zhou)', 789, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c9ef4216-06ec-55bb-b610-8f80e16105dc', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Impératrice Zhangsun', null, 601, 636, 'Épouse de Taizong', 'Zhangsun', 54, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bc852cba-1ff5-5d83-acb7-8c9410c85d19', 'entry', '9b4855cf-26f4-5917-8eaa-e9590e995f3f', 'Yang Guifei', null, 719, 756, 'Concubine de Xuanzong', 'Yang', 300, 2560, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('7f0530d7-5ee1-52cc-939b-b6edd83cdeb8', 'acfe2e82-1bd2-5ee7-a259-ef1b86996109', 'spouse');
  perform pg_temp.rel('7f0530d7-5ee1-52cc-939b-b6edd83cdeb8', '95bd52f4-3e71-5044-b1c1-4b8c7720a4e7', 'parent');
  perform pg_temp.rel('acfe2e82-1bd2-5ee7-a259-ef1b86996109', '95bd52f4-3e71-5044-b1c1-4b8c7720a4e7', 'parent');
  perform pg_temp.rel('95bd52f4-3e71-5044-b1c1-4b8c7720a4e7', 'a5d4102f-a59b-5529-a977-b8c4e7f3a305', 'family');
  perform pg_temp.rel('50d8b36b-d5d5-5010-8274-04e8b4eaea6f', '3e812595-50b0-5ce7-bd06-c8654b0e63a4', 'parent');
  perform pg_temp.rel('3e812595-50b0-5ce7-bd06-c8654b0e63a4', '6fa0c66b-5b02-5eb7-8fb1-4ff031543ea8', 'parent');
  perform pg_temp.rel('6fa0c66b-5b02-5eb7-8fb1-4ff031543ea8', '33b6649d-638e-5d01-8cd2-4af43361f148', 'parent');
  perform pg_temp.rel('6fa0c66b-5b02-5eb7-8fb1-4ff031543ea8', '0a1bcdba-7512-5f1b-9477-a20aef29ca8a', 'parent');
  perform pg_temp.rel('0a1bcdba-7512-5f1b-9477-a20aef29ca8a', '19fc908c-5734-5cf7-b080-8df5e0b2af8f', 'parent');
  perform pg_temp.rel('19fc908c-5734-5cf7-b080-8df5e0b2af8f', 'b94df8d2-7707-5ec1-9c58-bdba20379007', 'parent');
  perform pg_temp.rel('b94df8d2-7707-5ec1-9c58-bdba20379007', '7cf5a589-6c4b-555e-91c6-dacc89984a2d', 'parent');
  perform pg_temp.rel('7cf5a589-6c4b-555e-91c6-dacc89984a2d', '5ae27851-d68a-50f7-ab04-8590ba45e1b8', 'parent');
  perform pg_temp.rel('5ae27851-d68a-50f7-ab04-8590ba45e1b8', '9c531355-e0fe-554c-b596-9f2cccaa16a7', 'parent');
  perform pg_temp.rel('9c531355-e0fe-554c-b596-9f2cccaa16a7', 'c7520c66-0e59-560b-a02b-30af462b0734', 'parent');
  perform pg_temp.rel('c7520c66-0e59-560b-a02b-30af462b0734', 'bfc330b0-62b1-5288-99cd-0bd0d6c973c3', 'parent');
  perform pg_temp.rel('c7520c66-0e59-560b-a02b-30af462b0734', 'a30a73af-1de3-5837-9785-e5dbd5e3308b', 'parent');
  perform pg_temp.rel('bfc330b0-62b1-5288-99cd-0bd0d6c973c3', 'd3e953ff-93c2-56d1-9d35-751b2177a95d', 'parent');
  perform pg_temp.rel('bfc330b0-62b1-5288-99cd-0bd0d6c973c3', '8d873dce-6998-5a9b-abe3-f6d900cda70e', 'parent');
  perform pg_temp.rel('bfc330b0-62b1-5288-99cd-0bd0d6c973c3', '234fc026-03d3-5b86-9e21-a4b8a692510d', 'parent');
  perform pg_temp.rel('a30a73af-1de3-5837-9785-e5dbd5e3308b', '7f4197ce-449a-5f0e-9746-3727967153f5', 'parent');
  perform pg_temp.rel('7f4197ce-449a-5f0e-9746-3727967153f5', '43f3e712-33dc-525f-bd38-4562515b584c', 'parent');
  perform pg_temp.rel('7f4197ce-449a-5f0e-9746-3727967153f5', '07f45c0e-d549-56a6-bbde-ae70b486f5d1', 'parent');
  perform pg_temp.rel('07f45c0e-d549-56a6-bbde-ae70b486f5d1', '6ab444f2-6375-508d-b1ad-9c21a65b61ea', 'parent');
  perform pg_temp.rel('6fa0c66b-5b02-5eb7-8fb1-4ff031543ea8', '4456cda5-cd5b-5de2-96a1-2dee6d05ea50', 'spouse');
  perform pg_temp.rel('4456cda5-cd5b-5de2-96a1-2dee6d05ea50', '33b6649d-638e-5d01-8cd2-4af43361f148', 'parent');
  perform pg_temp.rel('4456cda5-cd5b-5de2-96a1-2dee6d05ea50', '0a1bcdba-7512-5f1b-9477-a20aef29ca8a', 'parent');
  perform pg_temp.rel('3e812595-50b0-5ce7-bd06-c8654b0e63a4', 'c9ef4216-06ec-55bb-b610-8f80e16105dc', 'spouse');
  perform pg_temp.rel('c9ef4216-06ec-55bb-b610-8f80e16105dc', '6fa0c66b-5b02-5eb7-8fb1-4ff031543ea8', 'parent');
  perform pg_temp.rel('19fc908c-5734-5cf7-b080-8df5e0b2af8f', 'bc852cba-1ff5-5d83-acb7-8c9410c85d19', 'spouse');
  raise notice 'schema_v82 : % membres ajoutés.', 27;
end $$;
