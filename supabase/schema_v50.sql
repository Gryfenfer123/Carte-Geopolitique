-- schema_v50.sql — Albanie — Kastrioti, Wied, Zogu
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Crée sous Albanie > Dynastie : Kastrioti (Gjon Kastrioti -> Gjon II), Wied (Guillaume de Wied, prince d'Albanie en 1914) et Zogu (Zog Ier -> Leka II).
-- Jerina Branković (épouse de Gjon II Kastrioti) est créée dans l'arbre Branković.
-- Naissance de Géraldine Apponyi (1915) et de Leka II (1982) : non données par les pages Wikipédia consultées, ajoutées de mémoire et marquées « à vérifier ».
-- Prérequis : v49 exécuté.
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
  if exists (select 1 from public.genealogy_members where id = '584916e3-2192-587d-b760-7c9bc174134c') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('870b75fa-4b16-571f-8220-d26683f03869','f1ad8e78-2125-5ebe-824e-32cc41498ff4');
  if k <> 2 then raise exception 'Membres préexistants manquants (% sur 2) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Kastrioti » (ALB)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ALB' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ALB : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Kastrioti';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('9e34a31c-8add-5736-b83f-2aea1b74d439', cat_id, 'country', 'ALB', top, 'Kastrioti', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '9e34a31c-8add-5736-b83f-2aea1b74d439';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('19309afc-7e2a-59ca-8802-b1dada3cf9e5', 'country', 'ALB', 'genealogy', 'Kastrioti', cat_id, sec, admin_id);
  -- Arbre « Wied » (ALB)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ALB' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ALB : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Wied';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('d37cd61d-c84c-56d1-9b50-89a48d574f00', cat_id, 'country', 'ALB', top, 'Wied', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'd37cd61d-c84c-56d1-9b50-89a48d574f00';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('39e0c5a5-4e46-5af5-bcd4-e13ed2b5fc8a', 'country', 'ALB', 'genealogy', 'Wied', cat_id, sec, admin_id);
  -- Arbre « Zogu » (ALB)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ALB' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ALB : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Zogu';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('b2b56110-60d0-5de1-a25c-5a87cda7db02', cat_id, 'country', 'ALB', top, 'Zogu', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'b2b56110-60d0-5de1-a25c-5a87cda7db02';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('61c45a5b-ae50-5e19-8619-f3f59e831081', 'country', 'ALB', 'genealogy', 'Zogu', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = '7b6e6a0b-c2a6-5095-9045-cab9b22659eb' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Branković introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('584916e3-2192-587d-b760-7c9bc174134c', 'entry', '19309afc-7e2a-59ca-8802-b1dada3cf9e5', 'Gjon Kastrioti', null, null, 1437, 'Seigneur de Mat, père de Skanderbeg', 'Kastrioti', 0, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c921baf0-22da-5d23-af25-64b3d13d09ad', 'entry', '19309afc-7e2a-59ca-8802-b1dada3cf9e5', 'Voisava', null, null, null, 'Mère de Skanderbeg', 'Origine discutée (Polog slave ou Muzaka)', 540, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c50ef9c7-c93b-54a8-af13-7c5c30ecf6e7', 'entry', '19309afc-7e2a-59ca-8802-b1dada3cf9e5', 'Skanderbeg (Gjergj Kastrioti)', null, 1405, 1468, 'Prince des Albanais, héros national', 'Kastrioti', 270, 460, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('82a33297-a276-53d4-82f6-ca33c923fbab', 'entry', '19309afc-7e2a-59ca-8802-b1dada3cf9e5', 'Donika Arianiti', null, null, null, 'Épouse de Skanderbeg', 'Arianiti (Albanie)', 810, 460, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7e33a8e0-e926-5396-9d1c-8dff12d3b683', 'entry', '19309afc-7e2a-59ca-8802-b1dada3cf9e5', 'Gjon II Kastrioti', null, 1456, 1514, 'Duc de San Pietro in Galatina', 'Kastrioti', 540, 1368, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7b3fff6d-081f-54a2-9f09-b45f03ff8d5c', 'entry', '7b6e6a0b-c2a6-5095-9045-cab9b22659eb', 'Jerina Branković (épouse de Gjon II Kastrioti)', null, null, null, 'Princesse, duchesse de Galatina', 'Branković', 380, 1746, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a6d496bd-6441-5c2b-a38e-deb004e54b0b', 'entry', '39e0c5a5-4e46-5af5-bcd4-e13ed2b5fc8a', 'Guillaume de Wied (5e prince de Wied)', null, 1845, 1907, 'Prince de Wied', 'Wied', 0, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4a0c7bc6-511d-5835-8aca-28a86bd7222e', 'entry', '39e0c5a5-4e46-5af5-bcd4-e13ed2b5fc8a', 'Marie des Pays-Bas (princesse de Wied)', null, 1841, 1910, 'Princesse de Wied', 'Orange-Nassau (Pays-Bas)', 540, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('28cca9fc-633c-5750-909c-e5d213d27a44', 'entry', '39e0c5a5-4e46-5af5-bcd4-e13ed2b5fc8a', 'Guillaume de Wied (prince d''Albanie)', null, 1876, 1945, 'Prince d''Albanie (1914)', 'Wied', 270, 630, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('312270ac-5905-55d5-aedb-8e36897dab83', 'entry', '39e0c5a5-4e46-5af5-bcd4-e13ed2b5fc8a', 'Sophie de Schönburg-Waldenburg', null, 1885, 1936, 'Princesse d''Albanie', 'Schönburg-Waldenburg', 782, 630, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('eb9aaea2-0476-5f28-9b41-e61d1fc4dd5a', 'entry', '39e0c5a5-4e46-5af5-bcd4-e13ed2b5fc8a', 'Marie-Éléonore de Wied', null, 1909, 1956, 'Princesse', 'Wied', 321, 1260, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e3618b1c-a6f4-54b0-beb4-a4cf88e3eb5b', 'entry', '39e0c5a5-4e46-5af5-bcd4-e13ed2b5fc8a', 'Charles-Victor de Wied', null, 1913, 1973, 'Prince héréditaire', 'Wied', 731, 1260, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f72c159a-9781-5946-8aa9-ee8fc65e884f', 'entry', '61c45a5b-ae50-5e19-8619-f3f59e831081', 'Xhemal Pacha Zogolli', null, null, 1911, 'Père de Zog Ier', 'Zogu', 0, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('41dab037-afbb-557c-8f78-8e059f830695', 'entry', '61c45a5b-ae50-5e19-8619-f3f59e831081', 'Sadije Toptani', null, null, null, 'Mère de Zog Ier', 'Toptani (Albanie)', 540, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('51a7fbf3-f15b-5065-b6e3-0939dd159c60', 'entry', '61c45a5b-ae50-5e19-8619-f3f59e831081', 'Zog Ier d''Albanie', null, 1895, 1961, 'Président (1925), puis roi des Albanais (1928-1939)', 'Zogu', 270, 630, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8958c32e-0bb4-5182-a04b-b90af34d6906', 'entry', '61c45a5b-ae50-5e19-8619-f3f59e831081', 'Géraldine Apponyi de Nagyappony', null, 1915, 2002, 'Reine des Albanais', 'Apponyi (Hongrie)', 810, 630, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('883b369f-29cf-54d0-8890-19f0fd9aa3c4', 'entry', '61c45a5b-ae50-5e19-8619-f3f59e831081', 'Leka Ier d''Albanie', null, 1939, 2011, 'Prince héritier, prétendant au trône', 'Zogu', 540, 1422, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('20ed403d-7e65-59df-bacb-b3850715d44f', 'entry', '61c45a5b-ae50-5e19-8619-f3f59e831081', 'Susan Cullen-Ward', null, null, 2004, 'Épouse de Leka Ier', 'Cullen-Ward (Australie)', 1080, 1422, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('87d8384f-e716-5942-b627-6ee616cb2b87', 'entry', '61c45a5b-ae50-5e19-8619-f3f59e831081', 'Leka II d''Albanie', null, 1982, null, 'Prétendant au trône d''Albanie', 'Zogu', 810, 2196, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('584916e3-2192-587d-b760-7c9bc174134c', 'c921baf0-22da-5d23-af25-64b3d13d09ad', 'spouse');
  perform pg_temp.rel('584916e3-2192-587d-b760-7c9bc174134c', 'c50ef9c7-c93b-54a8-af13-7c5c30ecf6e7', 'parent');
  perform pg_temp.rel('c921baf0-22da-5d23-af25-64b3d13d09ad', 'c50ef9c7-c93b-54a8-af13-7c5c30ecf6e7', 'parent');
  perform pg_temp.rel('c50ef9c7-c93b-54a8-af13-7c5c30ecf6e7', '82a33297-a276-53d4-82f6-ca33c923fbab', 'spouse');
  perform pg_temp.rel('c50ef9c7-c93b-54a8-af13-7c5c30ecf6e7', '7e33a8e0-e926-5396-9d1c-8dff12d3b683', 'parent');
  perform pg_temp.rel('82a33297-a276-53d4-82f6-ca33c923fbab', '7e33a8e0-e926-5396-9d1c-8dff12d3b683', 'parent');
  perform pg_temp.rel('f1ad8e78-2125-5ebe-824e-32cc41498ff4', '7b3fff6d-081f-54a2-9f09-b45f03ff8d5c', 'parent');
  perform pg_temp.rel('870b75fa-4b16-571f-8220-d26683f03869', '7b3fff6d-081f-54a2-9f09-b45f03ff8d5c', 'parent');
  perform pg_temp.rel('7e33a8e0-e926-5396-9d1c-8dff12d3b683', '7b3fff6d-081f-54a2-9f09-b45f03ff8d5c', 'spouse');
  perform pg_temp.rel('a6d496bd-6441-5c2b-a38e-deb004e54b0b', '4a0c7bc6-511d-5835-8aca-28a86bd7222e', 'spouse');
  perform pg_temp.rel('a6d496bd-6441-5c2b-a38e-deb004e54b0b', '28cca9fc-633c-5750-909c-e5d213d27a44', 'parent');
  perform pg_temp.rel('4a0c7bc6-511d-5835-8aca-28a86bd7222e', '28cca9fc-633c-5750-909c-e5d213d27a44', 'parent');
  perform pg_temp.rel('28cca9fc-633c-5750-909c-e5d213d27a44', '312270ac-5905-55d5-aedb-8e36897dab83', 'spouse');
  perform pg_temp.rel('28cca9fc-633c-5750-909c-e5d213d27a44', 'eb9aaea2-0476-5f28-9b41-e61d1fc4dd5a', 'parent');
  perform pg_temp.rel('312270ac-5905-55d5-aedb-8e36897dab83', 'eb9aaea2-0476-5f28-9b41-e61d1fc4dd5a', 'parent');
  perform pg_temp.rel('28cca9fc-633c-5750-909c-e5d213d27a44', 'e3618b1c-a6f4-54b0-beb4-a4cf88e3eb5b', 'parent');
  perform pg_temp.rel('312270ac-5905-55d5-aedb-8e36897dab83', 'e3618b1c-a6f4-54b0-beb4-a4cf88e3eb5b', 'parent');
  perform pg_temp.rel('f72c159a-9781-5946-8aa9-ee8fc65e884f', '41dab037-afbb-557c-8f78-8e059f830695', 'spouse');
  perform pg_temp.rel('f72c159a-9781-5946-8aa9-ee8fc65e884f', '51a7fbf3-f15b-5065-b6e3-0939dd159c60', 'parent');
  perform pg_temp.rel('41dab037-afbb-557c-8f78-8e059f830695', '51a7fbf3-f15b-5065-b6e3-0939dd159c60', 'parent');
  perform pg_temp.rel('51a7fbf3-f15b-5065-b6e3-0939dd159c60', '8958c32e-0bb4-5182-a04b-b90af34d6906', 'spouse');
  perform pg_temp.rel('51a7fbf3-f15b-5065-b6e3-0939dd159c60', '883b369f-29cf-54d0-8890-19f0fd9aa3c4', 'parent');
  perform pg_temp.rel('8958c32e-0bb4-5182-a04b-b90af34d6906', '883b369f-29cf-54d0-8890-19f0fd9aa3c4', 'parent');
  perform pg_temp.rel('883b369f-29cf-54d0-8890-19f0fd9aa3c4', '20ed403d-7e65-59df-bacb-b3850715d44f', 'spouse');
  perform pg_temp.rel('883b369f-29cf-54d0-8890-19f0fd9aa3c4', '87d8384f-e716-5942-b627-6ee616cb2b87', 'parent');
  perform pg_temp.rel('20ed403d-7e65-59df-bacb-b3850715d44f', '87d8384f-e716-5942-b627-6ee616cb2b87', 'parent');
  update public.genealogy_members set pos_x = 2908, pos_y = 2826 where id = '4df951d7-c982-5f06-985b-6cf53163daeb';
  update public.genealogy_members set pos_x = 665, pos_y = 0 where id = 'a1227e02-117f-5ae9-8fff-95cc5c22ad63';
  update public.genealogy_members set pos_x = 935, pos_y = 576 where id = 'f1ad8e78-2125-5ebe-824e-32cc41498ff4';
  update public.genealogy_members set pos_x = 1595, pos_y = 576 where id = '870b75fa-4b16-571f-8220-d26683f03869';
  update public.genealogy_members set pos_x = 790, pos_y = 1746 where id = '6f6c3e0a-9a54-52e8-8413-ed840502b169';
  update public.genealogy_members set pos_x = 2150, pos_y = 1746 where id = 'c9022f6e-3028-5d43-af82-9fcd9f89b483';
  update public.genealogy_members set pos_x = 1200, pos_y = 1746 where id = 'a5a3feb5-bf49-53d0-8e7a-b3018becfa6d';
  update public.genealogy_members set pos_x = 2715, pos_y = 1746 where id = '567a4b54-2bef-5b22-8b67-c4af0684c78c';
  update public.genealogy_members set pos_x = 1740, pos_y = 1746 where id = '628ea3c7-5047-5a1d-aa20-dd6d8d34b710';
  update public.genealogy_members set pos_x = 2638, pos_y = 2206 where id = '84cdfb2f-046b-5ddf-a4d8-091783150440';
  update public.genealogy_members set pos_x = 3178, pos_y = 2206 where id = '38e2bef4-c91e-5590-8d0c-ec55cbc16060';
  update public.genealogy_members set pos_x = 2228, pos_y = 2206 where id = '2bf976ea-0e05-58a5-b820-380d68dbae6d';
  update public.genealogy_members set pos_x = 1470, pos_y = 2206 where id = '309b9e48-2e77-56b5-8570-a24aaac197ed';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('7b3fff6d-081f-54a2-9f09-b45f03ff8d5c', 'entry', '19309afc-7e2a-59ca-8802-b1dada3cf9e5', 920, 1368, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('7e33a8e0-e926-5396-9d1c-8dff12d3b683', 'entry', '7b6e6a0b-c2a6-5095-9045-cab9b22659eb', 0, 1746, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('b38eba3b-0a28-5c97-bc2d-61b5fa70f0a7', 'entry', '7b6e6a0b-c2a6-5095-9045-cab9b22659eb', 2354, 2826, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('1131d8dd-702b-59b8-8c16-eadee3eff6e0', 'entry', '7b6e6a0b-c2a6-5095-9045-cab9b22659eb', 2426, 3357, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('1a1a6633-2b10-507a-824d-791688465d10', 'entry', '7b6e6a0b-c2a6-5095-9045-cab9b22659eb', 2836, 3357, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('e7f6ab6e-f6c9-5e21-a59a-8e635f52e893', 'entry', '7b6e6a0b-c2a6-5095-9045-cab9b22659eb', 1205, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('41637f1e-95e8-5688-bab9-662b44725884', 'entry', '7b6e6a0b-c2a6-5095-9045-cab9b22659eb', 1090, 2206, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v50 : % membres ajoutés.', 19;
end $$;
