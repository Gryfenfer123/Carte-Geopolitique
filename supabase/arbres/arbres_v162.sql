-- arbres_v162.sql — Italie (Julio-Claudiens)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Julio-Claudiens » (Rome antique, rattaché à l'Italie). Source : page Wikipédia « Julio-Claudian dynasty » (anglais), notée dans chaque fiche et dans docs/sources/arbres.md.
-- La page ne donne aucune date de naissance ; seules les dates de mort écrites sur la page sont saisies (av. J.-C. = années négatives). Jules César est lié à Auguste par un lien « famille » (père adoptif). Livia, Marcellus, Octavie la Jeune et Marc Antoine sont cités sans lien de parenté précis sur la page : non ajoutés (sauf Livia, mère de Tibère et Drusus). Les unions (Auguste–Livie, etc.) ne sont pas saisies car la page ne les énonce pas dans la liste utilisée.
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
  if exists (select 1 from public.genealogy_members where id = 'bc39726d-1899-56a0-9004-ccbe146623fc') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Julio-Claudiens » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Julio-Claudiens';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('489e65f4-4614-5676-8f59-f010402954ea', cat_id, 'country', 'ITA', top, 'Julio-Claudiens', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '489e65f4-4614-5676-8f59-f010402954ea';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('871e20e8-7145-5c37-9198-20bfd433bef7', 'country', 'ITA', 'genealogy', 'Julio-Claudiens', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bc39726d-1899-56a0-9004-ccbe146623fc', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Jules César', null, null, null, 'Père adoptif d''Auguste', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty', 4435, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('36710fe6-3344-5cfe-a213-6e56f92a3e94', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Atia', null, null, null, 'Mère d''Auguste', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty', 935, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('69de4325-3c64-5df5-8b20-f9e7fc65f1e8', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Auguste', null, null, 14, 'Premier empereur romain (27 av. J.-C. - 14)', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - mort le 19 août 14', 935, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a0123866-ea7e-55b9-a519-6419e655bef9', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Livie', null, null, null, 'Mère de Tibère et de Drusus', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty', 1935, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2ffff5e4-a8f2-5c4d-9dec-f0fba3c0b104', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Tiberius Claudius Nero (préteur)', null, null, null, 'Père de Tibère et de Drusus', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty', 1435, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('be8d604d-77b8-5c7c-9502-631d65b13d78', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Tibère', null, null, 37, 'Empereur romain (14-37)', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - mort le 16 mars 37', 1657, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ceefa1b3-9e20-5b8f-a00c-43dc78dede32', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Drusus (Nero Claudius Drusus)', null, null, -9, 'Fils de Livie, père de Germanicus et de Claude', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - mort en 9 av. J.-C. (chute de cheval)', 2167, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b9bba75c-72c7-58dc-a374-39b0297993c6', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Antonia la Jeune', null, null, null, 'Mère de Germanicus et de Claude', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty', 2435, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d50c479f-c18a-506c-b1c7-cacde927ba9b', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Germanicus', null, null, 19, 'Père de Caligula', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - mort en Syrie', 2213, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7db3910d-166d-514c-8fc6-ab656b6407ff', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Marcus Vipsanius Agrippa', null, null, -12, 'Général, père de Gaius, Lucius, Julia la Jeune, Agrippine l''Aînée', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - mort en 12 av. J.-C.', 435, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2977dead-9a10-5030-ad09-fcfcf4d3a14e', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Julia l''Aînée', null, null, null, 'Fille d''Auguste', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty', 935, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('17e37e8d-bd8d-566c-9a0b-97e7967484d4', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Gaius Caesar', null, null, 4, 'Fils d''Agrippa et de Julia l''Aînée', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty', 1500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b60b57e2-7b14-5cf1-8a66-d0c798e92816', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Lucius Caesar', null, null, 2, 'Fils d''Agrippa et de Julia l''Aînée', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('24adb1b3-dd01-5b00-a029-920730e34074', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Julia la Jeune', null, null, null, 'Fille d''Agrippa et de Julia l''Aînée', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('062d2ec2-2201-585c-af3d-045a9956805a', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Agrippa Postumus', null, null, null, 'Fils d''Agrippa et de Julia l''Aînée', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - exécuté (date non indiquée)', 1000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('de62011a-153b-5845-9930-a515fb085eb2', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Agrippine l''Aînée', null, null, null, 'Fille d''Agrippa et de Julia l''Aînée, mère de Caligula', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - tuée sur ordre de Tibère', 2000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('47ba6475-8eb9-5ba5-b1cf-8b346a0230a0', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Caligula', null, null, 41, 'Empereur romain (37-41)', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - mort le 24 janvier 41', 2823, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5bb58af1-0620-5808-ab9f-5c6b6d7ffeec', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Claude', null, null, 54, 'Empereur romain (41-54)', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - mort le 13 octobre 54', 2713, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f48360b3-e62f-597f-ac78-3169d17e883f', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Messaline', null, null, null, 'Épouse de Claude', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - exécutée', 2935, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b24c6da6-b52e-5383-addc-b11f620bad2e', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Britannicus', null, null, null, 'Fils de Claude', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - tué sur ordre de Néron', 3000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2289130f-ef68-5043-a195-e35eb316ec0f', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Octavie (Claudia Octavia)', null, null, null, 'Fille de Claude et de Messaline', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - tuée sur ordre de Néron', 2500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3d20e6eb-8764-51ad-9793-9c236ab19b5e', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Agrippine la Jeune', null, null, null, 'Fille de Germanicus, mère de Néron', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty', 2323, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5fe7da82-6b61-5f72-aeeb-92e928c9a57e', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Gnaeus Domitius Ahenobarbus (consul 32)', null, null, null, 'Père de Néron', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty', 3435, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d2bfe8b7-d5c0-575e-9f72-6626226f73b0', 'entry', '871e20e8-7145-5c37-9198-20bfd433bef7', 'Néron', null, null, 68, 'Empereur romain (54-68)', 'Julio-Claudiens', 'Sources : https://en.wikipedia.org/wiki/Julio-Claudian_dynasty - suicide en 68', 2879, 3200, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('36710fe6-3344-5cfe-a213-6e56f92a3e94', '69de4325-3c64-5df5-8b20-f9e7fc65f1e8', 'parent');
  perform pg_temp.rel('2ffff5e4-a8f2-5c4d-9dec-f0fba3c0b104', 'be8d604d-77b8-5c7c-9502-631d65b13d78', 'parent');
  perform pg_temp.rel('a0123866-ea7e-55b9-a519-6419e655bef9', 'be8d604d-77b8-5c7c-9502-631d65b13d78', 'parent');
  perform pg_temp.rel('2ffff5e4-a8f2-5c4d-9dec-f0fba3c0b104', 'ceefa1b3-9e20-5b8f-a00c-43dc78dede32', 'parent');
  perform pg_temp.rel('a0123866-ea7e-55b9-a519-6419e655bef9', 'ceefa1b3-9e20-5b8f-a00c-43dc78dede32', 'parent');
  perform pg_temp.rel('ceefa1b3-9e20-5b8f-a00c-43dc78dede32', 'd50c479f-c18a-506c-b1c7-cacde927ba9b', 'parent');
  perform pg_temp.rel('b9bba75c-72c7-58dc-a374-39b0297993c6', 'd50c479f-c18a-506c-b1c7-cacde927ba9b', 'parent');
  perform pg_temp.rel('ceefa1b3-9e20-5b8f-a00c-43dc78dede32', '5bb58af1-0620-5808-ab9f-5c6b6d7ffeec', 'parent');
  perform pg_temp.rel('b9bba75c-72c7-58dc-a374-39b0297993c6', '5bb58af1-0620-5808-ab9f-5c6b6d7ffeec', 'parent');
  perform pg_temp.rel('69de4325-3c64-5df5-8b20-f9e7fc65f1e8', '2977dead-9a10-5030-ad09-fcfcf4d3a14e', 'parent');
  perform pg_temp.rel('7db3910d-166d-514c-8fc6-ab656b6407ff', '17e37e8d-bd8d-566c-9a0b-97e7967484d4', 'parent');
  perform pg_temp.rel('2977dead-9a10-5030-ad09-fcfcf4d3a14e', '17e37e8d-bd8d-566c-9a0b-97e7967484d4', 'parent');
  perform pg_temp.rel('7db3910d-166d-514c-8fc6-ab656b6407ff', 'b60b57e2-7b14-5cf1-8a66-d0c798e92816', 'parent');
  perform pg_temp.rel('2977dead-9a10-5030-ad09-fcfcf4d3a14e', 'b60b57e2-7b14-5cf1-8a66-d0c798e92816', 'parent');
  perform pg_temp.rel('7db3910d-166d-514c-8fc6-ab656b6407ff', '24adb1b3-dd01-5b00-a029-920730e34074', 'parent');
  perform pg_temp.rel('2977dead-9a10-5030-ad09-fcfcf4d3a14e', '24adb1b3-dd01-5b00-a029-920730e34074', 'parent');
  perform pg_temp.rel('7db3910d-166d-514c-8fc6-ab656b6407ff', '062d2ec2-2201-585c-af3d-045a9956805a', 'parent');
  perform pg_temp.rel('2977dead-9a10-5030-ad09-fcfcf4d3a14e', '062d2ec2-2201-585c-af3d-045a9956805a', 'parent');
  perform pg_temp.rel('7db3910d-166d-514c-8fc6-ab656b6407ff', 'de62011a-153b-5845-9930-a515fb085eb2', 'parent');
  perform pg_temp.rel('2977dead-9a10-5030-ad09-fcfcf4d3a14e', 'de62011a-153b-5845-9930-a515fb085eb2', 'parent');
  perform pg_temp.rel('d50c479f-c18a-506c-b1c7-cacde927ba9b', '47ba6475-8eb9-5ba5-b1cf-8b346a0230a0', 'parent');
  perform pg_temp.rel('de62011a-153b-5845-9930-a515fb085eb2', '47ba6475-8eb9-5ba5-b1cf-8b346a0230a0', 'parent');
  perform pg_temp.rel('d50c479f-c18a-506c-b1c7-cacde927ba9b', '3d20e6eb-8764-51ad-9793-9c236ab19b5e', 'parent');
  perform pg_temp.rel('de62011a-153b-5845-9930-a515fb085eb2', '3d20e6eb-8764-51ad-9793-9c236ab19b5e', 'parent');
  perform pg_temp.rel('5bb58af1-0620-5808-ab9f-5c6b6d7ffeec', 'b24c6da6-b52e-5383-addc-b11f620bad2e', 'parent');
  perform pg_temp.rel('5bb58af1-0620-5808-ab9f-5c6b6d7ffeec', '2289130f-ef68-5043-a195-e35eb316ec0f', 'parent');
  perform pg_temp.rel('f48360b3-e62f-597f-ac78-3169d17e883f', '2289130f-ef68-5043-a195-e35eb316ec0f', 'parent');
  perform pg_temp.rel('5fe7da82-6b61-5f72-aeeb-92e928c9a57e', 'd2bfe8b7-d5c0-575e-9f72-6626226f73b0', 'parent');
  perform pg_temp.rel('3d20e6eb-8764-51ad-9793-9c236ab19b5e', 'd2bfe8b7-d5c0-575e-9f72-6626226f73b0', 'parent');
  perform pg_temp.rel('bc39726d-1899-56a0-9004-ccbe146623fc', '69de4325-3c64-5df5-8b20-f9e7fc65f1e8', 'family');
  raise notice 'schema_v162 : % membres ajoutés.', 24;
end $$;
