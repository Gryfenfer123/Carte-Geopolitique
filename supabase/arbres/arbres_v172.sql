-- arbres_v172.sql — Maroc (Mérinides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Mérinides » (Maroc). Source : page Wikipédia « Marinid dynasty » (anglais).
-- Aucune date de mort n'est saisie : la page donne pour chaque sultan la fin de règne, sans qu'on puisse la distinguer de la date de mort. Seules les filiations explicites de la page sont saisies ; les frères sont reliés par un lien « famille ». Abd al-Haqq Ier : père des sultans Uthman Ier, Muhammad Ier (frère d'Uthman), Abu Yahya (3e fils) et Abu Yusuf Yaqub (4e fils). Les rois dont le père n'est pas indiqué (Abu Zayyan Muhammad II, Abu Bakr ibn Faris, Tashfin, Ahmad al-Mustansir, Muhammad IV) ne sont pas ajoutés.
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
  if exists (select 1 from public.genealogy_members where id = 'd44238b5-209e-512e-bddc-0a0797e9ed71') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Mérinides » (MAR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'MAR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour MAR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Mérinides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('4f66c8c9-fc81-5e2c-8e68-61e9e8e07f66', cat_id, 'country', 'MAR', top, 'Mérinides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '4f66c8c9-fc81-5e2c-8e68-61e9e8e07f66';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'country', 'MAR', 'genealogy', 'Mérinides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d44238b5-209e-512e-bddc-0a0797e9ed71', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Mahyu', null, null, null, 'Père d''Abd al-Haqq Ier', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty', 500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('458d574b-2252-5ebd-903e-895bdabe3ebd', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abd al-Haqq Ier', null, null, null, 'Émir mérinide (1215-1217)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8521cca9-e76d-5585-93db-fc432efcf50a', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Uthman Ier', null, null, null, 'Émir mérinide (1217-1240)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty', 1000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2a6e6b4a-55d6-5ef1-a19c-3dea68b8a378', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Muhammad Ier', null, null, null, 'Émir mérinide (1240-1244)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty - frère d''Uthman Ier', 5000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c482d8c6-27c7-576f-9257-b41e6de0aff7', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Yahya ibn Abd al-Haqq', null, null, null, 'Émir mérinide (1244-1258)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty - troisième fils d''Abd al-Haqq', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('32ca17d4-b075-5d37-8ee2-2cc86135f8b4', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Yusuf Yaqub', null, null, null, 'Sultan mérinide (1258-1286)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty - quatrième fils d''Abd al-Haqq', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7d451cad-7f31-52d2-a6ae-a7d37a0ee8d9', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Yaqub Yusuf an-Nasr', null, null, null, 'Sultan mérinide (1286-1307)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('378ab1e2-b50d-55fc-8be3-62abf589b4ef', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Thabit Amir', null, null, null, 'Sultan mérinide (1307-1308)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('56097673-03ae-5125-bf72-f3be3a3d86a4', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu al-Rabi Sulayman', null, null, null, 'Sultan mérinide (1308-1310)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty - frère d''Abu Thabit Amir', 6000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b7562d7e-fb9b-5027-ae46-df5f57884207', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Said Uthman II', null, null, null, 'Sultan mérinide (1310-1331)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty - frère d''Abu al-Rabi Sulayman', 2500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a46b2eb5-47a2-5fe4-bcb3-38e7c9020824', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu al-Hasan Ali', null, null, null, 'Sultan mérinide (1331-1351)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty', 2500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('dc24670b-8cb3-531e-9d5a-208bbc798da4', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Inan Faris', null, null, null, 'Sultan mérinide (1348-1358)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty', 2500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2102f80e-fe39-5ef0-912c-65c9178796dc', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Salim Ibrahim', null, null, null, 'Sultan mérinide (1359-1361)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty - l''un des fils d''Abu al-Hasan', 3000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('effd74da-5c32-574c-859d-1aa82f009df2', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Faris Abd al-Aziz Ier', null, null, null, 'Sultan mérinide (1365-1372)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty - l''un des fils d''Abu al-Hasan', 2000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('985d2066-10fd-55f1-8b18-8bf33496d769', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Zayyan Muhammad III', null, null, null, 'Sultan mérinide (1372-1374)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty', 2000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('735a917a-04d0-522d-98ae-5d103216cd41', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Faris Musa', null, null, null, 'Sultan mérinide (1384-1386)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty - fils d''Abu Inan', 2500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f0f011e2-5a8a-5129-b6cf-9ebf45e4200e', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Said Uthman III', null, null, null, 'Sultan mérinide (1398-1420)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty', 4000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c2b00a05-1a6c-5e06-9fe5-4c325c4b3281', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Amir Abdallah', null, null, null, 'Sultan mérinide (1396-1397)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty - frère d''Abu Said Uthman III', 7000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a8b18aea-6fba-5032-bda9-d1e155f09aa4', 'entry', 'f3dbc4dd-1fcc-5a30-880b-d82f384587f2', 'Abu Muhammad Abd al-Haqq II', null, null, null, 'Dernier sultan mérinide (1420-1465)', 'Mérinides', 'Sources : https://en.wikipedia.org/wiki/Marinid_dynasty', 4000, 640, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('d44238b5-209e-512e-bddc-0a0797e9ed71', '458d574b-2252-5ebd-903e-895bdabe3ebd', 'parent');
  perform pg_temp.rel('458d574b-2252-5ebd-903e-895bdabe3ebd', '8521cca9-e76d-5585-93db-fc432efcf50a', 'parent');
  perform pg_temp.rel('458d574b-2252-5ebd-903e-895bdabe3ebd', 'c482d8c6-27c7-576f-9257-b41e6de0aff7', 'parent');
  perform pg_temp.rel('458d574b-2252-5ebd-903e-895bdabe3ebd', '32ca17d4-b075-5d37-8ee2-2cc86135f8b4', 'parent');
  perform pg_temp.rel('32ca17d4-b075-5d37-8ee2-2cc86135f8b4', '7d451cad-7f31-52d2-a6ae-a7d37a0ee8d9', 'parent');
  perform pg_temp.rel('7d451cad-7f31-52d2-a6ae-a7d37a0ee8d9', '378ab1e2-b50d-55fc-8be3-62abf589b4ef', 'parent');
  perform pg_temp.rel('b7562d7e-fb9b-5027-ae46-df5f57884207', 'a46b2eb5-47a2-5fe4-bcb3-38e7c9020824', 'parent');
  perform pg_temp.rel('a46b2eb5-47a2-5fe4-bcb3-38e7c9020824', 'dc24670b-8cb3-531e-9d5a-208bbc798da4', 'parent');
  perform pg_temp.rel('a46b2eb5-47a2-5fe4-bcb3-38e7c9020824', '2102f80e-fe39-5ef0-912c-65c9178796dc', 'parent');
  perform pg_temp.rel('a46b2eb5-47a2-5fe4-bcb3-38e7c9020824', 'effd74da-5c32-574c-859d-1aa82f009df2', 'parent');
  perform pg_temp.rel('effd74da-5c32-574c-859d-1aa82f009df2', '985d2066-10fd-55f1-8b18-8bf33496d769', 'parent');
  perform pg_temp.rel('dc24670b-8cb3-531e-9d5a-208bbc798da4', '735a917a-04d0-522d-98ae-5d103216cd41', 'parent');
  perform pg_temp.rel('f0f011e2-5a8a-5129-b6cf-9ebf45e4200e', 'a8b18aea-6fba-5032-bda9-d1e155f09aa4', 'parent');
  perform pg_temp.rel('8521cca9-e76d-5585-93db-fc432efcf50a', '2a6e6b4a-55d6-5ef1-a19c-3dea68b8a378', 'family');
  perform pg_temp.rel('378ab1e2-b50d-55fc-8be3-62abf589b4ef', '56097673-03ae-5125-bf72-f3be3a3d86a4', 'family');
  perform pg_temp.rel('56097673-03ae-5125-bf72-f3be3a3d86a4', 'b7562d7e-fb9b-5027-ae46-df5f57884207', 'family');
  perform pg_temp.rel('f0f011e2-5a8a-5129-b6cf-9ebf45e4200e', 'c2b00a05-1a6c-5e06-9fe5-4c325c4b3281', 'family');
  raise notice 'schema_v172 : % membres ajoutés.', 19;
end $$;
