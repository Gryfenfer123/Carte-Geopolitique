-- arbres_v168.sql — Italie (Théodosiens)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Théodosiens » (Rome antique/Empire romain tardif, rattaché à l'Italie). Source : page « Theodosian dynasty » (anglais).
-- Dates de naissance incertaines sur la page (ex. Théodose Ier 346 ou 347, Galla Placidie 392 ou 393) : non saisies. Seules les dates précises de mort écrites sur la page sont saisies. Les unions (y compris Honorius) autres que celles saisies ne sont pas reprises. Anthémius est cité sans lien de parenté : non ajouté.
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
  if exists (select 1 from public.genealogy_members where id = '4a853f98-c1e2-57ea-849a-13da2816ce5a') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Théodosiens » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Théodosiens';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('490e0732-865c-540e-953b-a591d9619517', cat_id, 'country', 'ITA', top, 'Théodosiens', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '490e0732-865c-540e-953b-a591d9619517';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('e2300896-14d8-54f5-a4c6-772510af80ba', 'country', 'ITA', 'genealogy', 'Théodosiens', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4a853f98-c1e2-57ea-849a-13da2816ce5a', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Comte Théodose', null, null, null, 'Père de Théodose Ier', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty', 1643, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a6b4ea7c-e660-5bb0-960d-25e5a51d25d6', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Flavia Thermantia', null, null, null, 'Mère de Théodose Ier', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty', 2643, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b0facf69-eb3b-5628-897f-868aa150ce87', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Théodose Ier', null, null, 395, 'Empereur romain (379-395)', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty - mort le 17 janvier 395 ; naissance 346 ou 347', 2148, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9b676ced-9346-509e-9a82-433a830e278a', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Aelia Flaccilla', null, null, null, 'Première épouse de Théodose Ier, augusta (379-386)', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty', 1658, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('340c07a2-668e-52d4-af76-d365a7939f48', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Valentinien Ier', null, null, null, 'Père de Galla', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty', 2143, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bd1d04a2-5261-50cb-8468-59f131ede1db', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Justine', null, null, null, 'Mère de Galla', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty', 3143, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('888ca6ab-2589-584d-ae9e-ba7e19708052', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Galla', null, null, null, 'Seconde épouse de Théodose Ier', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty - morte fin avril 394', 2638, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8d70d834-8061-55b1-a0be-7547f271dbc3', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Arcadius', null, null, null, 'Empereur romain (395-408)', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty - naissance « vers 377 »', 1480, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b0785320-a7a3-5823-9d34-eac5b06b2f18', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Honorius', null, 384, 423, 'Empereur romain (395-423)', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty - né le 9 décembre 384', 1980, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e2e58571-8883-5962-a764-079c01ebd992', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Pulchérie', null, null, null, 'Augusta (414-453)', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty - naissance 377 ou 378', 490, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4f89b94a-bc7b-5d3e-b4fa-8cb3e035f4bf', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Galla Placidie', null, null, 450, 'Augusta (421-450)', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty - morte le 25 novembre 450 ; naissance 392 ou 393', 3480, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e2423707-2c70-535d-9ca5-f3e2d576db25', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Gratien (fils de Théodose Ier)', null, null, 394, 'Fils de Théodose Ier et de Galla', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty', 2980, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('74bbdda8-4329-5442-8181-46d9df9974c8', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Jean (fils de Théodose Ier)', null, null, null, 'Fils de Théodose Ier et de Galla', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty - naissance peut-être 394', 2480, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a3afdd04-68d7-5cac-ac25-04f5d993316e', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Aelia Eudoxia', null, null, null, 'Épouse d''Arcadius', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty', 990, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8cfe4868-0e64-51d7-9b85-482da6fc7665', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Théodose II', null, null, null, 'Empereur romain d''Orient (408-450)', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty', 1235, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('37be3c5f-2dd4-5b4f-9d93-d8224c8e99b6', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Aelia Eudocia', null, null, null, 'Épouse de Théodose II', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty', 745, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3b5ac67c-9c8e-5252-b4a7-b444fc6fa43a', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Constance III', null, null, 421, 'Empereur romain d''Occident (421)', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty', 3970, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9209a634-ec98-5206-9436-d65c77fd21fa', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Valentinien III', null, null, 455, 'Empereur romain d''Occident (425-455)', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty - mort le 16 mars 455', 3725, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bd928960-faa8-5e6c-9897-6c9c5baedca2', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Licinia Eudoxia', null, null, null, 'Épouse de Valentinien III', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty', 4215, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6c0802d5-b48b-522a-8bc2-700e1e5a3dde', 'entry', 'e2300896-14d8-54f5-a4c6-772510af80ba', 'Marcien', null, null, 457, 'Empereur romain d''Orient (450-457)', 'Théodosiens', 'Sources : https://en.wikipedia.org/wiki/Theodosian_dynasty - époux de Pulchérie', 0, 1280, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('4a853f98-c1e2-57ea-849a-13da2816ce5a', 'b0facf69-eb3b-5628-897f-868aa150ce87', 'parent');
  perform pg_temp.rel('a6b4ea7c-e660-5bb0-960d-25e5a51d25d6', 'b0facf69-eb3b-5628-897f-868aa150ce87', 'parent');
  perform pg_temp.rel('b0facf69-eb3b-5628-897f-868aa150ce87', '8d70d834-8061-55b1-a0be-7547f271dbc3', 'parent');
  perform pg_temp.rel('9b676ced-9346-509e-9a82-433a830e278a', '8d70d834-8061-55b1-a0be-7547f271dbc3', 'parent');
  perform pg_temp.rel('b0facf69-eb3b-5628-897f-868aa150ce87', 'b0785320-a7a3-5823-9d34-eac5b06b2f18', 'parent');
  perform pg_temp.rel('9b676ced-9346-509e-9a82-433a830e278a', 'b0785320-a7a3-5823-9d34-eac5b06b2f18', 'parent');
  perform pg_temp.rel('b0facf69-eb3b-5628-897f-868aa150ce87', 'e2e58571-8883-5962-a764-079c01ebd992', 'parent');
  perform pg_temp.rel('9b676ced-9346-509e-9a82-433a830e278a', 'e2e58571-8883-5962-a764-079c01ebd992', 'parent');
  perform pg_temp.rel('b0facf69-eb3b-5628-897f-868aa150ce87', '4f89b94a-bc7b-5d3e-b4fa-8cb3e035f4bf', 'parent');
  perform pg_temp.rel('888ca6ab-2589-584d-ae9e-ba7e19708052', '4f89b94a-bc7b-5d3e-b4fa-8cb3e035f4bf', 'parent');
  perform pg_temp.rel('b0facf69-eb3b-5628-897f-868aa150ce87', 'e2423707-2c70-535d-9ca5-f3e2d576db25', 'parent');
  perform pg_temp.rel('888ca6ab-2589-584d-ae9e-ba7e19708052', 'e2423707-2c70-535d-9ca5-f3e2d576db25', 'parent');
  perform pg_temp.rel('b0facf69-eb3b-5628-897f-868aa150ce87', '74bbdda8-4329-5442-8181-46d9df9974c8', 'parent');
  perform pg_temp.rel('888ca6ab-2589-584d-ae9e-ba7e19708052', '74bbdda8-4329-5442-8181-46d9df9974c8', 'parent');
  perform pg_temp.rel('340c07a2-668e-52d4-af76-d365a7939f48', '888ca6ab-2589-584d-ae9e-ba7e19708052', 'parent');
  perform pg_temp.rel('bd1d04a2-5261-50cb-8468-59f131ede1db', '888ca6ab-2589-584d-ae9e-ba7e19708052', 'parent');
  perform pg_temp.rel('8d70d834-8061-55b1-a0be-7547f271dbc3', '8cfe4868-0e64-51d7-9b85-482da6fc7665', 'parent');
  perform pg_temp.rel('a3afdd04-68d7-5cac-ac25-04f5d993316e', '8cfe4868-0e64-51d7-9b85-482da6fc7665', 'parent');
  perform pg_temp.rel('3b5ac67c-9c8e-5252-b4a7-b444fc6fa43a', '9209a634-ec98-5206-9436-d65c77fd21fa', 'parent');
  perform pg_temp.rel('4f89b94a-bc7b-5d3e-b4fa-8cb3e035f4bf', '9209a634-ec98-5206-9436-d65c77fd21fa', 'parent');
  perform pg_temp.rel('b0facf69-eb3b-5628-897f-868aa150ce87', '9b676ced-9346-509e-9a82-433a830e278a', 'spouse');
  perform pg_temp.rel('b0facf69-eb3b-5628-897f-868aa150ce87', '888ca6ab-2589-584d-ae9e-ba7e19708052', 'spouse');
  perform pg_temp.rel('8d70d834-8061-55b1-a0be-7547f271dbc3', 'a3afdd04-68d7-5cac-ac25-04f5d993316e', 'spouse');
  perform pg_temp.rel('8cfe4868-0e64-51d7-9b85-482da6fc7665', '37be3c5f-2dd4-5b4f-9d93-d8224c8e99b6', 'spouse');
  perform pg_temp.rel('4f89b94a-bc7b-5d3e-b4fa-8cb3e035f4bf', '3b5ac67c-9c8e-5252-b4a7-b444fc6fa43a', 'spouse');
  perform pg_temp.rel('9209a634-ec98-5206-9436-d65c77fd21fa', 'bd928960-faa8-5e6c-9897-6c9c5baedca2', 'spouse');
  perform pg_temp.rel('e2e58571-8883-5962-a764-079c01ebd992', '6c0802d5-b48b-522a-8bc2-700e1e5a3dde', 'spouse');
  raise notice 'schema_v168 : % membres ajoutés.', 20;
end $$;
