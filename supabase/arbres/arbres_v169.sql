-- arbres_v169.sql — Italie (Constantiniens)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Constantiniens » (Empire romain, rattaché à l'Italie). Source : page « Constantinian dynasty » (anglais). Le schéma généalogique de la page est mal restitué par l'extraction : les liens de parenté ci-dessous sont ceux lus dans ce schéma, à revérifier sur la page.
-- Seules les dates de mort écrites dans le texte ou le schéma sont saisies (306, 337, 340, 350, 361, 363). Julius Constantius est cité sans lien avec Constance Chlore sur la page : non relié. Minervine, Anastasia, Eutropie, Eusébie et Flavia Julia Constantia sont cités sans lien précis : non ajoutés. Crispus n'est pas cité sur la page.
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
  if exists (select 1 from public.genealogy_members where id = '4f5a353b-b535-5f3a-97cb-836a5c2eb991') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Constantiniens » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Constantiniens';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('fd844dc3-6851-5756-bce0-c3d482c1f25a', cat_id, 'country', 'ITA', top, 'Constantiniens', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'fd844dc3-6851-5756-bce0-c3d482c1f25a';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'country', 'ITA', 'genealogy', 'Constantiniens', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4f5a353b-b535-5f3a-97cb-836a5c2eb991', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Constance Chlore', null, null, 306, 'Empereur romain (père de Constantin Ier)', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty - mort en 306', 2743, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a1216a8e-a84d-5ad4-a5c0-b2f52c10862d', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Théodora', null, null, null, 'Épouse de Constance Chlore', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 3233, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('df8d38be-b958-5747-bd67-effc41675ebd', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Hélène', null, null, null, 'Mère de Constantin Ier', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('42e23d84-a37c-5a01-a4a6-53cee94c211f', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Constantin Ier', null, null, 337, 'Empereur romain (306-337)', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty - mort en 337', 1872, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9e042b24-3dbd-5604-a169-4d633d9543d9', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Fausta', null, null, null, 'Épouse de Constantin Ier', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 2362, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('02e43629-6bb0-55ad-b919-0789b835f7fa', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Constantin II', null, null, 340, 'Empereur romain d''Occident', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 2580, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7f0c1f74-ca74-5b66-ab40-758359bd126b', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Constance II', null, null, 361, 'Empereur romain', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 2080, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1418d70f-1f07-58b1-8d9f-598be87e3f88', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Constant', null, null, 350, 'Empereur romain d''Occident', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 3080, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cea79c68-924f-5905-ac3d-80c46f0193ed', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Flavius Dalmatius', null, null, null, 'Fils de Constance Chlore et de Théodora', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 2988, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5a6d5ed9-1e40-5068-ae37-2fc846b78d83', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Hannibalianus', null, null, null, 'Fils de Flavius Dalmatius', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 3580, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2a13b036-6805-5241-ade8-7fb9c6783a0b', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Julius Constantius', null, null, null, 'Père de Gallus et de Julien', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty - lien avec Constance Chlore non indiqué sur la page', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d0465998-3e0c-5d7c-8a97-9e8279e4afa6', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Galla (mère de Gallus)', null, null, null, 'Mère de Constance Gallus', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('17d68feb-b8a1-569e-a126-7eb3f7e452ee', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Basilina', null, null, null, 'Mère de Julien', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 1500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('42f08ae4-8ba2-5c2e-8481-8c4e7ac5d76b', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Constance Gallus', null, null, null, 'César', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0351677a-4463-58ab-8fa0-88ef75ce5d99', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Julien', null, null, 363, 'Empereur romain (360-363)', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty - mort en 363', 600, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a17fcaae-263d-5f08-9dc9-852f68b132ef', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Hélène (épouse de Julien)', null, null, null, 'Fille de Constantin Ier', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 1090, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('590306ed-ac67-53b5-a219-0b7ce374843f', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Faustine', null, null, null, 'Mère de Constantia', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 1590, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('70131c76-5a79-5c83-9db9-410d0628e2d4', 'entry', 'b5e75d8c-d5b9-597c-8dd5-f34e9962f266', 'Constantia (épouse de Gratien)', null, null, null, 'Fille de Constance II', 'Constantiniens', 'Sources : https://en.wikipedia.org/wiki/Constantinian_dynasty', 1835, 1920, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('4f5a353b-b535-5f3a-97cb-836a5c2eb991', '42e23d84-a37c-5a01-a4a6-53cee94c211f', 'parent');
  perform pg_temp.rel('df8d38be-b958-5747-bd67-effc41675ebd', '42e23d84-a37c-5a01-a4a6-53cee94c211f', 'parent');
  perform pg_temp.rel('42e23d84-a37c-5a01-a4a6-53cee94c211f', '02e43629-6bb0-55ad-b919-0789b835f7fa', 'parent');
  perform pg_temp.rel('9e042b24-3dbd-5604-a169-4d633d9543d9', '02e43629-6bb0-55ad-b919-0789b835f7fa', 'parent');
  perform pg_temp.rel('42e23d84-a37c-5a01-a4a6-53cee94c211f', '7f0c1f74-ca74-5b66-ab40-758359bd126b', 'parent');
  perform pg_temp.rel('9e042b24-3dbd-5604-a169-4d633d9543d9', '7f0c1f74-ca74-5b66-ab40-758359bd126b', 'parent');
  perform pg_temp.rel('42e23d84-a37c-5a01-a4a6-53cee94c211f', '1418d70f-1f07-58b1-8d9f-598be87e3f88', 'parent');
  perform pg_temp.rel('9e042b24-3dbd-5604-a169-4d633d9543d9', '1418d70f-1f07-58b1-8d9f-598be87e3f88', 'parent');
  perform pg_temp.rel('4f5a353b-b535-5f3a-97cb-836a5c2eb991', 'cea79c68-924f-5905-ac3d-80c46f0193ed', 'parent');
  perform pg_temp.rel('a1216a8e-a84d-5ad4-a5c0-b2f52c10862d', 'cea79c68-924f-5905-ac3d-80c46f0193ed', 'parent');
  perform pg_temp.rel('cea79c68-924f-5905-ac3d-80c46f0193ed', '5a6d5ed9-1e40-5068-ae37-2fc846b78d83', 'parent');
  perform pg_temp.rel('2a13b036-6805-5241-ade8-7fb9c6783a0b', '42f08ae4-8ba2-5c2e-8481-8c4e7ac5d76b', 'parent');
  perform pg_temp.rel('d0465998-3e0c-5d7c-8a97-9e8279e4afa6', '42f08ae4-8ba2-5c2e-8481-8c4e7ac5d76b', 'parent');
  perform pg_temp.rel('2a13b036-6805-5241-ade8-7fb9c6783a0b', '0351677a-4463-58ab-8fa0-88ef75ce5d99', 'parent');
  perform pg_temp.rel('17d68feb-b8a1-569e-a126-7eb3f7e452ee', '0351677a-4463-58ab-8fa0-88ef75ce5d99', 'parent');
  perform pg_temp.rel('42e23d84-a37c-5a01-a4a6-53cee94c211f', 'a17fcaae-263d-5f08-9dc9-852f68b132ef', 'parent');
  perform pg_temp.rel('7f0c1f74-ca74-5b66-ab40-758359bd126b', '70131c76-5a79-5c83-9db9-410d0628e2d4', 'parent');
  perform pg_temp.rel('590306ed-ac67-53b5-a219-0b7ce374843f', '70131c76-5a79-5c83-9db9-410d0628e2d4', 'parent');
  perform pg_temp.rel('4f5a353b-b535-5f3a-97cb-836a5c2eb991', 'a1216a8e-a84d-5ad4-a5c0-b2f52c10862d', 'spouse');
  perform pg_temp.rel('42e23d84-a37c-5a01-a4a6-53cee94c211f', '9e042b24-3dbd-5604-a169-4d633d9543d9', 'spouse');
  perform pg_temp.rel('0351677a-4463-58ab-8fa0-88ef75ce5d99', 'a17fcaae-263d-5f08-9dc9-852f68b132ef', 'spouse');
  perform pg_temp.rel('7f0c1f74-ca74-5b66-ab40-758359bd126b', '590306ed-ac67-53b5-a219-0b7ce374843f', 'spouse');
  raise notice 'schema_v169 : % membres ajoutés.', 18;
end $$;
