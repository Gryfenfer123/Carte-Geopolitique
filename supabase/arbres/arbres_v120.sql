-- arbres_v120.sql — Koweït (Al Sabah)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Al Sabah » (Koweït) : 15 émirs. Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Sabah Ier et Abdullah Ier : pas de page lue (accès refusé) ; Sabah Ier daté d'après la liste des émirs, Abdullah Ier sans dates, lien avec Sabah Ier en « famille » faute de page confirmant la filiation. Muhammad Ier (émir 1892-1896) non saisi : aucune donnée lue.
-- Lien « famille » (non parent-enfant) : Abdullah II (frère de Mubarak, non confirmé par une page lue) n'est pas saisi non plus.
-- Dates en année chrétienne telles que la page les donne ; « c. » = approximatif.
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
  if exists (select 1 from public.genealogy_members where id = '4f567e32-dcaa-5b80-b8b4-0172d438e648') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Al Sabah » (KWT)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'KWT' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour KWT : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Al Sabah';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('3d06d603-08db-5b00-a7f2-f4654ab592b5', cat_id, 'country', 'KWT', top, 'Al Sabah', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '3d06d603-08db-5b00-a7f2-f4654ab592b5';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'country', 'KWT', 'genealogy', 'Al Sabah', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4f567e32-dcaa-5b80-b8b4-0172d438e648', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Sabah Ier ben Jaber', null, 1700, 1762, 'Premier cheikh du Koweït (1752-1762)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/List_of_emirs_of_Kuwait — naissance c. 1700 ; page de la liste des émirs', 3000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('db1d66f0-14cf-5560-8ada-83284eb5c8c3', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Abdullah Ier ben Sabah', null, null, null, 'Cheikh du Koweït (1762-1814)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/List_of_emirs_of_Kuwait — dates non lues ; lien avec Sabah Ier en « famille » (père non confirmé par une page lue) ; père de Jaber Ier d''après la page de Jaber Ier', 1443, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('323806f0-e381-571c-b8ca-ba02ff313d36', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Jaber Ier', null, 1775, 1859, 'Cheikh du Koweït (1814-1859)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Jaber_I_Al-Sabah', 1443, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c1574d25-8b33-51da-831d-ae7e1c7fd8cf', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Sabah II', null, 1784, 1866, 'Cheikh du Koweït (1859-1866)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Sabah_II_Al-Sabah — naissance c. 1784 ; INCOHÉRENT avec Jaber Ier (né 1775, soit 9 ans d''écart) : à vérifier avec une autre source', 1443, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d27915dd-7e80-515d-a46e-48b9da3071d8', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Abdullah II', null, 1814, 1892, 'Cheikh du Koweït (1866-1892)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Abdullah_II_Al-Sabah — naissance c. 1814', 1695, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('52d898fa-8be1-5102-80dd-21a34671bce2', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Moubarak le Grand', null, 1837, 1915, 'Cheikh du Koweït (1896-1915)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Mubarak_Al-Sabah — naissance c. 1837', 1195, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8d3dbfb9-b978-59f8-a349-84a217d50e58', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Jaber II', null, 1860, 1917, 'Cheikh du Koweït (1915-1917)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Jaber_II_Al-Sabah', 837, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('de39d3a3-140c-537d-aeb7-0a8d75b3fa41', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Salim al-Moubarak', null, 1864, 1921, 'Cheikh du Koweït (1917-1921)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Salim_Al-Mubarak_Al-Sabah', 1489, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9f1c8de5-002f-5a16-b982-44911965293e', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Ahmad al-Jaber', null, 1885, 1950, 'Cheikh du Koweït (1921-1950)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Ahmad_Al-Jaber_Al-Sabah', 837, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d37ca4df-5792-5387-b13a-b24b9da4d5c4', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Abdullah al-Salim', null, 1895, 1965, 'Premier émir du Koweït indépendant (1950-1965)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Abdullah_Al-Salim_Al-Sabah', 2000, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ddfe0f9f-5cbd-5dee-830e-d4370b349b26', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Sabah al-Salim', null, 1913, 1977, 'Émir du Koweït (1965-1977)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Sabah_Al-Salim_Al-Sabah', 1416, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('517c095b-d01c-5f67-914d-84cd7226c158', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Jaber al-Ahmad', null, 1926, 2006, 'Émir du Koweït (1977-2006)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Jaber_Al-Ahmad_Al-Sabah', 0, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7c4298d8-291a-5fa8-a61a-ab98f1972dc9', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Saad al-Abdullah', null, 1930, 2008, 'Émir du Koweït (15-24 janvier 2006)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Saad_Al-Abdullah_Al-Salim_Al-Sabah', 2000, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9a555cfc-382f-5fca-9ace-0fa0e5145aef', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Sabah al-Ahmad', null, 1929, 2020, 'Émir du Koweït (2006-2020)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Sabah_Al-Ahmad_Al-Jaber_Al-Sabah', 500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c74a7b87-d6e4-5c82-bb78-c6f8c41ad8a1', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Nawaf al-Ahmad', null, 1937, 2023, 'Émir du Koweït (2020-2023)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Nawaf_Al-Ahmad_Al-Jaber_Al-Sabah', 1000, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c43170c3-d767-5f79-b347-4d889c593072', 'entry', 'cb8ca7e2-86d9-54da-b4bc-45a5708097d3', 'Mishal al-Ahmad', null, 1940, null, 'Émir du Koweït (depuis 2023)', 'Al Sabah', 'Sources : https://en.wikipedia.org/wiki/Mishal_Al-Ahmad_Al-Jaber_Al-Sabah', 1500, 4480, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('db1d66f0-14cf-5560-8ada-83284eb5c8c3', '323806f0-e381-571c-b8ca-ba02ff313d36', 'parent');
  perform pg_temp.rel('323806f0-e381-571c-b8ca-ba02ff313d36', 'c1574d25-8b33-51da-831d-ae7e1c7fd8cf', 'parent');
  perform pg_temp.rel('c1574d25-8b33-51da-831d-ae7e1c7fd8cf', 'd27915dd-7e80-515d-a46e-48b9da3071d8', 'parent');
  perform pg_temp.rel('c1574d25-8b33-51da-831d-ae7e1c7fd8cf', '52d898fa-8be1-5102-80dd-21a34671bce2', 'parent');
  perform pg_temp.rel('52d898fa-8be1-5102-80dd-21a34671bce2', '8d3dbfb9-b978-59f8-a349-84a217d50e58', 'parent');
  perform pg_temp.rel('52d898fa-8be1-5102-80dd-21a34671bce2', 'de39d3a3-140c-537d-aeb7-0a8d75b3fa41', 'parent');
  perform pg_temp.rel('8d3dbfb9-b978-59f8-a349-84a217d50e58', '9f1c8de5-002f-5a16-b982-44911965293e', 'parent');
  perform pg_temp.rel('de39d3a3-140c-537d-aeb7-0a8d75b3fa41', 'd37ca4df-5792-5387-b13a-b24b9da4d5c4', 'parent');
  perform pg_temp.rel('de39d3a3-140c-537d-aeb7-0a8d75b3fa41', 'ddfe0f9f-5cbd-5dee-830e-d4370b349b26', 'parent');
  perform pg_temp.rel('d37ca4df-5792-5387-b13a-b24b9da4d5c4', '7c4298d8-291a-5fa8-a61a-ab98f1972dc9', 'parent');
  perform pg_temp.rel('9f1c8de5-002f-5a16-b982-44911965293e', '517c095b-d01c-5f67-914d-84cd7226c158', 'parent');
  perform pg_temp.rel('9f1c8de5-002f-5a16-b982-44911965293e', '9a555cfc-382f-5fca-9ace-0fa0e5145aef', 'parent');
  perform pg_temp.rel('9f1c8de5-002f-5a16-b982-44911965293e', 'c74a7b87-d6e4-5c82-bb78-c6f8c41ad8a1', 'parent');
  perform pg_temp.rel('9f1c8de5-002f-5a16-b982-44911965293e', 'c43170c3-d767-5f79-b347-4d889c593072', 'parent');
  perform pg_temp.rel('4f567e32-dcaa-5b80-b8b4-0172d438e648', 'db1d66f0-14cf-5560-8ada-83284eb5c8c3', 'family');
  raise notice 'schema_v120 : % membres ajoutés.', 16;
end $$;
