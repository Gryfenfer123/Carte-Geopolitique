-- arbres_v147.sql — Ouzbékistan (Timourides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Timourides » (Ouzbékistan) : 15 personnes. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Toutes les données viennent de la page « Timurid dynasty ». Père-fils indiqués par la page : Timur → Shahrukh → Ulugh Beg → Abd al-Latif ; Abu Sa'id → Ahmad, Mahmud, Umar Shaikh II, Ulugh Mirza ; Mahmud → Baysonqor, Ali, Masud ; Ulugh Mirza → Abd al-Razzaq. Pir Muhammad, Khalil Sultan et Abu Sa'id sont rattachés à Timur par un lien « famille » (petit-fils ou arrière-petit-fils à travers Jahangir ou Miran Shah, qui ne sont pas dans l'arbre).
-- Babur et les empereurs moghols sont dans l'arbre « Empire moghol » (Inde) : Babur (fils d'Umar Shaikh II) n'est pas dupliqué ici. Les dates de naissance et de mort sont absentes pour la plupart des princes.
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
  if exists (select 1 from public.genealogy_members where id = '24c676c6-a878-5699-ac55-abf048c12546') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Timourides » (UZB)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'UZB' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour UZB : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Timourides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('57c28b7c-2b24-5e9e-86db-5b8745e29093', cat_id, 'country', 'UZB', top, 'Timourides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '57c28b7c-2b24-5e9e-86db-5b8745e29093';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'country', 'UZB', 'genealogy', 'Timourides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('24c676c6-a878-5699-ac55-abf048c12546', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Timur (Tamerlan)', null, null, 1405, 'Fondateur de l''empire timouride (1370-1405)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - naissance dans les années 1320 (pas d''année précise sur la page)', 2500, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4d484653-8a01-530f-820f-37888cd98e84', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Shahrukh Mirza', null, 1377, 1447, 'Souverain timouride (1405-1447)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty', 2500, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cd8f4fe1-db32-5c3b-b564-285ce54030d8', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Ulugh Beg Mirza', null, 1394, 1449, 'Souverain timouride (1447-1449)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty', 2500, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cd1aa93a-2f75-574c-9a11-39779624338f', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Abd al-Latif Mirza', null, null, null, 'Souverain timouride (1449-1450)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - fils d''Ulugh Beg', 2500, 8320, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e700712f-b085-559b-a770-78aceed1bca2', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Pir Muhammad', null, 1376, 1407, 'Souverain timouride (1405-1407)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - petit-fils de Timur par Jahangir Mirza', 3500, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f94210d9-246c-5759-ac3f-fe5da8c8a145', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Khalil Sultan', null, 1384, 1411, 'Souverain timouride (1405-1409)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - petit-fils de Timur par Miran Shah', 4500, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b9f8fe30-d682-5d16-919f-01b3e0681355', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Abu Sa''id Mirza', null, null, null, 'Souverain timouride (1459-1469)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - petit-fils de Miran Shah, fils de Timur', 750, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e7590f81-510c-540f-bad2-af72d27edaa5', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Ahmad Mirza', null, null, null, 'Souverain de Samarcande (1469-1494)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - fils d''Abu Sa''id', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2d3a1b4c-aa34-55a7-974e-10277dd39f2b', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Mahmud Mirza', null, null, null, 'Souverain timouride (1469-1495)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - fils d''Abu Sa''id', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f77df0f3-1ff3-5a6c-890a-dc294ee36c26', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Umar Shaikh Mirza II', null, null, null, 'Souverain de Fergana (1469-1494)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - fils d''Abu Sa''id', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fb048239-eb93-5a61-ac61-09f1f62cc172', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Ulugh Mirza', null, null, null, 'Souverain de Kaboul (1469-1502)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - fils d''Abu Sa''id', 1500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d8e76a19-b7fa-58fd-b987-c0650c3a8dc3', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Baysonqor Mirza', null, null, null, 'Souverain de Samarcande (1495-1497)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - fils de Mahmud Mirza', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8aa2ed90-14f8-556a-8a85-e81611ac8496', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Ali Mirza', null, null, null, 'Souverain de Boukhara (1495-1500)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - fils de Mahmud Mirza', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1a5f538d-9c52-5e30-947c-ddb96387f415', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Masud Mirza', null, null, null, 'Souverain de Hissar (1495-1500)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - fils de Mahmud Mirza', 1000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c35cc3ec-aba6-5384-ae55-e1c102e13284', 'entry', '9ded9ff6-e85c-52e3-8358-a06be14d95e5', 'Abd al-Razzaq', null, null, null, 'Souverain de Kaboul (1502)', 'Timourides', 'Sources : https://en.wikipedia.org/wiki/Timurid_dynasty - fils d''Ulugh Mirza', 1500, 1280, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('4d484653-8a01-530f-820f-37888cd98e84', 'cd8f4fe1-db32-5c3b-b564-285ce54030d8', 'parent');
  perform pg_temp.rel('cd8f4fe1-db32-5c3b-b564-285ce54030d8', 'cd1aa93a-2f75-574c-9a11-39779624338f', 'parent');
  perform pg_temp.rel('b9f8fe30-d682-5d16-919f-01b3e0681355', 'e7590f81-510c-540f-bad2-af72d27edaa5', 'parent');
  perform pg_temp.rel('b9f8fe30-d682-5d16-919f-01b3e0681355', '2d3a1b4c-aa34-55a7-974e-10277dd39f2b', 'parent');
  perform pg_temp.rel('b9f8fe30-d682-5d16-919f-01b3e0681355', 'f77df0f3-1ff3-5a6c-890a-dc294ee36c26', 'parent');
  perform pg_temp.rel('b9f8fe30-d682-5d16-919f-01b3e0681355', 'fb048239-eb93-5a61-ac61-09f1f62cc172', 'parent');
  perform pg_temp.rel('2d3a1b4c-aa34-55a7-974e-10277dd39f2b', 'd8e76a19-b7fa-58fd-b987-c0650c3a8dc3', 'parent');
  perform pg_temp.rel('2d3a1b4c-aa34-55a7-974e-10277dd39f2b', '8aa2ed90-14f8-556a-8a85-e81611ac8496', 'parent');
  perform pg_temp.rel('2d3a1b4c-aa34-55a7-974e-10277dd39f2b', '1a5f538d-9c52-5e30-947c-ddb96387f415', 'parent');
  perform pg_temp.rel('fb048239-eb93-5a61-ac61-09f1f62cc172', 'c35cc3ec-aba6-5384-ae55-e1c102e13284', 'parent');
  perform pg_temp.rel('24c676c6-a878-5699-ac55-abf048c12546', '4d484653-8a01-530f-820f-37888cd98e84', 'parent');
  perform pg_temp.rel('24c676c6-a878-5699-ac55-abf048c12546', 'e700712f-b085-559b-a770-78aceed1bca2', 'family');
  perform pg_temp.rel('24c676c6-a878-5699-ac55-abf048c12546', 'f94210d9-246c-5759-ac3f-fe5da8c8a145', 'family');
  perform pg_temp.rel('24c676c6-a878-5699-ac55-abf048c12546', 'b9f8fe30-d682-5d16-919f-01b3e0681355', 'family');
  raise notice 'schema_v147 : % membres ajoutés.', 15;
end $$;
