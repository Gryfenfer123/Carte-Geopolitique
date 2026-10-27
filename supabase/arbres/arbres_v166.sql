-- arbres_v166.sql — Grèce (Argéades)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Argéades » (Macédoine antique, rattaché à la Grèce). Sources : pages Wikipédia « List of kings of Macedonia », « Argead dynasty », « Philip II of Macedon » (anglais).
-- Filiations telles qu'écrites sur la page « List of kings of Macedonia ». Amyntas II (fils de Ménélaos, lui-même fils d'Alexandre Ier) et Amyntas III (arrière-petit-fils d'Alexandre Ier par Amyntas) sont reliés à Alexandre Ier par un lien « famille ». Perdiccas Ier : « fils de Caranos ou de Tyrimmas » → racine. Les années de mort ambiguës (ex. 398/7) ne sont pas saisies. Années négatives = av. J.-C.
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
  if exists (select 1 from public.genealogy_members where id = '2149a41e-c337-53f1-81da-b0fd66867036') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Argéades » (GRC)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'GRC' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour GRC : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Argéades';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('39e043da-375a-5c74-bbfa-cb88af22b59b', cat_id, 'country', 'GRC', top, 'Argéades', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '39e043da-375a-5c74-bbfa-cb88af22b59b';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('0b758226-74fb-58b2-a756-784e2cd730ab', 'country', 'GRC', 'genealogy', 'Argéades', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2149a41e-c337-53f1-81da-b0fd66867036', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Perdiccas Ier', null, null, null, 'Roi de Macédoine (v. 650 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia - fils de Caranos ou de Tyrimmas selon les auteurs antiques', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('25161074-2230-5d06-ae65-2cec6045bbe8', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Argaios Ier', null, null, null, 'Roi de Macédoine (v. 623 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia', 250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('288f37b4-1417-50b8-97a1-6a8d70a5b9fa', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Philippe Ier', null, null, null, 'Roi de Macédoine (v. 593 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia', 250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d11c882a-2e76-594b-a16e-354caacfc738', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Aéropos Ier', null, null, null, 'Roi de Macédoine (v. 563 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia', 250, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9bfa5fc4-b1e6-5f45-b3b5-e9c594b86954', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Alcétas', null, null, null, 'Roi de Macédoine (v. 533 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia', 250, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1089a451-f719-59e0-af9e-93c386d705b4', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Amyntas Ier', null, null, null, 'Roi de Macédoine (v. 512-498/7 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia', 250, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('56d67a1d-4e90-5c7d-beab-c6a419118b15', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Alexandre Ier le Philhellène', null, null, null, 'Roi de Macédoine (498/7-454 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia', 250, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f0180d2b-7dfa-5e3c-b09d-78d64a4b0268', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Perdiccas II', null, null, null, 'Roi de Macédoine (454-413 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia', 250, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e767bcf8-dcf3-5ad2-8d56-ad33814408f6', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Archélaos', null, null, -399, 'Roi de Macédoine (413-399 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia - mort en 399 av. J.-C.', 500, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('780d8e08-3159-5f23-88d4-c2062c2f3c0b', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Oreste', null, null, null, 'Roi de Macédoine (399-398/7 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia', 500, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c4e5f951-4a3c-5fb6-8d64-2deced0b8961', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Aéropos II', null, null, null, 'Roi de Macédoine (398/7-395/4 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia', 0, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7285afdb-2a9d-505f-ad87-cd00f65c31b6', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Pausanias', null, null, null, 'Roi de Macédoine (394/3 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia', 0, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('64e90236-4bbd-52c8-a44f-8eb733e15db3', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Amyntas II le Petit', null, null, null, 'Roi de Macédoine (394/3 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia - fils de Ménélaos, lui-même second fils d''Alexandre Ier', 3750, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('383f5881-032b-54dd-8395-4d08850e3e8b', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Amyntas III', null, null, -369, 'Roi de Macédoine (393 puis 393-369 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia - arrière-petit-fils d''Alexandre Ier par son troisième fils Amyntas ; mort en 369 av. J.-C.', 2000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d462fef3-063a-56ed-aa23-cd7797f76ae3', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Alexandre II', null, null, -368, 'Roi de Macédoine (369-368 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia - fils aîné d''Amyntas III ; assassiné', 2000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5b8d91d9-0f8c-5fa2-9e33-19792b3a6173', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Perdiccas III', null, null, null, 'Roi de Macédoine (365-360/59 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia - fils d''Amyntas III ; tué au combat', 1500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('37943dbd-d29a-5949-a1a5-64b43c3accd2', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Amyntas IV', null, null, null, 'Roi de Macédoine (360/59 av. J.-C., contesté)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia - fils de Perdiccas III', 1500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0c175805-190d-5ce6-a155-9b22c9511c94', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Philippe II', null, null, -336, 'Roi de Macédoine (360/59-336 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/Philip_II_of_Macedon - fils d''Amyntas III ; assassiné en 336 av. J.-C. ; naissance 383 ou 382 av. J.-C. selon la page', 2500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1b70b86a-f073-5fe6-8921-47e09b5c2b59', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Alexandre III le Grand', null, null, -323, 'Roi de Macédoine (336-323 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia - mort le 10/11 juin 323 av. J.-C. à Babylone', 2250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0fabf5f9-e636-54a3-948f-7c8f06c6202b', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Philippe III Arrhidée', null, null, -317, 'Roi de Macédoine (323-317 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia - fils de Philippe II ; exécuté en 317 av. J.-C.', 2750, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('eb5c3906-acb6-5189-af82-2940f59205f8', 'entry', '0b758226-74fb-58b2-a756-784e2cd730ab', 'Alexandre IV', null, null, -310, 'Roi de Macédoine (323-310 av. J.-C.)', 'Argéades', 'Sources : https://en.wikipedia.org/wiki/List_of_kings_of_Macedonia - fils d''Alexandre III ; assassiné en 310 av. J.-C.', 2250, 1920, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('2149a41e-c337-53f1-81da-b0fd66867036', '25161074-2230-5d06-ae65-2cec6045bbe8', 'parent');
  perform pg_temp.rel('25161074-2230-5d06-ae65-2cec6045bbe8', '288f37b4-1417-50b8-97a1-6a8d70a5b9fa', 'parent');
  perform pg_temp.rel('288f37b4-1417-50b8-97a1-6a8d70a5b9fa', 'd11c882a-2e76-594b-a16e-354caacfc738', 'parent');
  perform pg_temp.rel('d11c882a-2e76-594b-a16e-354caacfc738', '9bfa5fc4-b1e6-5f45-b3b5-e9c594b86954', 'parent');
  perform pg_temp.rel('9bfa5fc4-b1e6-5f45-b3b5-e9c594b86954', '1089a451-f719-59e0-af9e-93c386d705b4', 'parent');
  perform pg_temp.rel('1089a451-f719-59e0-af9e-93c386d705b4', '56d67a1d-4e90-5c7d-beab-c6a419118b15', 'parent');
  perform pg_temp.rel('56d67a1d-4e90-5c7d-beab-c6a419118b15', 'f0180d2b-7dfa-5e3c-b09d-78d64a4b0268', 'parent');
  perform pg_temp.rel('f0180d2b-7dfa-5e3c-b09d-78d64a4b0268', 'e767bcf8-dcf3-5ad2-8d56-ad33814408f6', 'parent');
  perform pg_temp.rel('e767bcf8-dcf3-5ad2-8d56-ad33814408f6', '780d8e08-3159-5f23-88d4-c2062c2f3c0b', 'parent');
  perform pg_temp.rel('f0180d2b-7dfa-5e3c-b09d-78d64a4b0268', 'c4e5f951-4a3c-5fb6-8d64-2deced0b8961', 'parent');
  perform pg_temp.rel('c4e5f951-4a3c-5fb6-8d64-2deced0b8961', '7285afdb-2a9d-505f-ad87-cd00f65c31b6', 'parent');
  perform pg_temp.rel('383f5881-032b-54dd-8395-4d08850e3e8b', 'd462fef3-063a-56ed-aa23-cd7797f76ae3', 'parent');
  perform pg_temp.rel('383f5881-032b-54dd-8395-4d08850e3e8b', '5b8d91d9-0f8c-5fa2-9e33-19792b3a6173', 'parent');
  perform pg_temp.rel('5b8d91d9-0f8c-5fa2-9e33-19792b3a6173', '37943dbd-d29a-5949-a1a5-64b43c3accd2', 'parent');
  perform pg_temp.rel('383f5881-032b-54dd-8395-4d08850e3e8b', '0c175805-190d-5ce6-a155-9b22c9511c94', 'parent');
  perform pg_temp.rel('0c175805-190d-5ce6-a155-9b22c9511c94', '1b70b86a-f073-5fe6-8921-47e09b5c2b59', 'parent');
  perform pg_temp.rel('0c175805-190d-5ce6-a155-9b22c9511c94', '0fabf5f9-e636-54a3-948f-7c8f06c6202b', 'parent');
  perform pg_temp.rel('1b70b86a-f073-5fe6-8921-47e09b5c2b59', 'eb5c3906-acb6-5189-af82-2940f59205f8', 'parent');
  perform pg_temp.rel('56d67a1d-4e90-5c7d-beab-c6a419118b15', '64e90236-4bbd-52c8-a44f-8eb733e15db3', 'family');
  perform pg_temp.rel('56d67a1d-4e90-5c7d-beab-c6a419118b15', '383f5881-032b-54dd-8395-4d08850e3e8b', 'family');
  raise notice 'schema_v166 : % membres ajoutés.', 21;
end $$;
