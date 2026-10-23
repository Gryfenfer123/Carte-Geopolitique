-- arbres_v72.sql — Suède — Maison Vasa (Gustave Ier à Christine) et lien avec les Palatins de Deux-Ponts (Charles X à Charles XII, Ulrique-Éléonore)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Complète l'arbre Vasa (déjà présent pour la Pologne) avec la branche suédoise ; rien n'est supprimé.
-- Sources : Wikipédia en anglais (Gustave Ier, Éric XIV, Jean III, Charles IX, Gustave-Adolphe, Christine, Charles X, Charles XI, Ulrique-Éléonore, Sigismond III). Dates non données = vides.
-- Marie de Simmern est créée dans Wittelsbach, Marie-Éléonore de Brandebourg dans Hohenzollern, Christine de Holstein-Gottorp et son père dans Oldenbourg, Ulrique-Éléonore de Danemark dans Oldenbourg : familles qui ont un arbre.
-- Katarina Stenbock, Margareta Leijonhufvud, Karin Månsdotter, Gunilla Bielke (noblesse suédoise), Catherine de Saxe-Lauenbourg, Christine de Hesse : placées dans l'arbre et signalées.
-- Les filles de Gustave Ier (mariées en Allemagne) ne sont pas incluses.
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
  if exists (select 1 from public.genealogy_members where id = '7d4388ff-49a7-55e0-8e6f-37d9b4e8103c') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('0ff1c7fc-619a-402c-94ce-dc6215a9dcd4','3161e73d-9607-5cce-89e0-188b3a585e2c','36ca6e33-35e2-4b57-9fbb-15228aac5d4d','555a36dc-18c0-4abc-a411-901c1d7ac59c','5fbd94f4-23bd-5a00-a935-db6709604ec0','5feee699-997e-428c-90ea-82e0c395c062','62b68c62-88d6-55d8-80ff-c9c223152670','67571e4c-fc66-4ba0-8e84-66c06f88f8ae','76ae7223-6fe2-5151-ad8e-ecb9b391cec3','7c5d6558-c46c-48e1-8b55-ac8b977417e9','841eb365-6517-4b89-bd3e-ef6192c6d93f','a09fa1dd-c798-4f65-8f48-aaff29b4f813');
  if k <> 12 then raise exception 'Membres préexistants manquants (% sur 12) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  select count(*) into k from public.dossier_entries where id = '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Vasa introuvable : rien n''a été fait.'; end if;
  -- Arbre « Palatinat-Deux-Ponts (Suède) » (SWE)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'SWE' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour SWE : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Palatinat-Deux-Ponts (Suède)';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('e8742ded-8946-593a-b7fc-e17054583d4d', cat_id, 'country', 'SWE', top, 'Palatinat-Deux-Ponts (Suède)', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'e8742ded-8946-593a-b7fc-e17054583d4d';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('a19ba0b6-9d7f-5121-837b-40cda646ea38', 'country', 'SWE', 'genealogy', 'Palatinat-Deux-Ponts (Suède)', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = 'e76d91a3-1b9c-4703-85b3-9f711b6d6199' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Wittelsbach introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '39895573-27f3-4112-905b-c9ba7e3c95a1' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Hohenzollern introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '7fc4995d-01af-4a5b-8344-817566b6f3c2' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison d''Oldenbourg introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7d4388ff-49a7-55e0-8e6f-37d9b4e8103c', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Erik Johansson Vasa', null, null, 1520, 'Noble suédois, exécuté lors du bain de sang de Stockholm', 'Vasa', 1199, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6b076ad8-7ab3-5e1e-adb1-9d487fc5f203', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Cécile Månsdotter Eka', null, null, null, 'Noble suédoise', 'Eka', 1689, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bf084a0f-5514-5b5b-bfb3-c254d2e20ba8', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Gustave Ier Vasa', null, 1496, 1560, 'Roi de Suède', 'Vasa', 1444, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('35803429-98f9-5f83-8f5f-e0ae08b0c7fe', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Catherine de Saxe-Lauenbourg', null, 1513, 1535, 'Reine de Suède', 'Saxe-Lauenbourg', 464, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b87cf92a-a1a4-58ce-82e0-9a07e0fbc765', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Marguerite Leijonhufvud', null, 1514, 1551, 'Reine de Suède', 'Leijonhufvud', 1934, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8cd6dfb7-3994-5f17-9931-a4fbe1f874d4', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Catherine Stenbock', null, 1535, 1621, 'Reine de Suède', 'Stenbock', 954, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ed01951b-a5ac-5bf2-a9a9-052daf30fcc1', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Éric XIV', null, 1533, 1577, 'Roi de Suède', 'Vasa', 490, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dfd38bea-a542-5a69-95e1-b8c02bf8ff7c', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Magnus de Suède', null, 1542, 1595, 'Duc d''Östergötland', 'Vasa', 2470, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fb7b5be8-098d-58f0-b78f-4067e8f34030', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Charles IX', null, 1550, 1611, 'Roi de Suède', 'Vasa', 1480, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('54e4c8f7-6aa8-5dec-b19a-198c9178ee4c', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Karin Månsdotter', null, 1550, 1612, 'Reine de Suède', 'Månsdotter', 0, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f652b240-1bf9-5246-a5e1-e4750ccdad8b', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Gustave Eriksson', null, 1568, 1607, 'Fils d''Éric XIV', 'Vasa', 245, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('57b713c1-33be-5640-bc09-cb72c3d5437c', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Gunilla Bielke', null, 1568, 1597, 'Reine de Suède', 'Bielke', 2970, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6a232d78-53f6-5189-b3e3-a0f8fd994c7f', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Jean, duc d''Östergötland', null, 1589, 1618, 'Duc d''Östergötland', 'Vasa', 3326, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('68dbdf3d-947e-594d-80dc-d86ce3eaf8c2', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Anne Vasa (1568)', null, 1568, null, 'Princesse de Suède', 'Vasa', 3702, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c788bf4a-ffe2-5451-bc88-2f8c82bfae2b', 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Marie de Palatinat-Simmern', null, 1561, 1589, 'Duchesse de Södermanland', 'Wittelsbach', 222000, 10098, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9ff1e551-9d76-5e15-bf32-1a2d6ba87659', 'entry', '7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Adolphe de Holstein-Gottorp', null, 1526, 1586, 'Duc de Holstein-Gottorp', 'Oldenbourg (Holstein-Gottorp)', 222000, 9468, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b42f9b16-5513-5bb8-95cb-b2ca0de379b0', 'entry', '7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Christine de Hesse', null, 1543, 1604, 'Duchesse de Holstein-Gottorp', 'Hesse', 222340, 9774, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b36cbc6a-25cf-55ca-af2c-8ea264ba5dfb', 'entry', '7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Christine de Holstein-Gottorp (1573-1625)', null, 1573, 1625, 'Reine de Suède', 'Oldenbourg (Holstein-Gottorp)', 222680, 10314, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dea8be65-86af-59ef-89df-980bd172af0d', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Catherine de Suède (1584-1638)', null, 1584, 1638, 'Comtesse palatine de Kleebourg', 'Vasa', 838, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1e285909-040f-519b-ae87-cba221517e2c', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Gustave II Adolphe', null, 1594, 1632, 'Roi de Suède', 'Vasa', 1846, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1176d1af-cb7b-5260-899b-3e940695a0b6', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Marie-Élisabeth de Suède', null, 1596, 1618, 'Duchesse d''Östergötland', 'Vasa', 2836, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f5fd1f0c-d596-52bd-8b95-b3ddb79ccc42', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Charles-Philippe de Suède', null, 1601, 1622, 'Duc de Södermanland', 'Vasa', 1346, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cff665d8-0cdb-5fa8-b4cd-c58528bb9616', 'entry', '39895573-27f3-4112-905b-c9ba7e3c95a1', 'Marie-Éléonore de Brandebourg', null, 1599, 1655, 'Reine de Suède', 'Hohenzollern', 222000, 10782, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7401af24-a7b4-5edf-992a-658c88eb2ced', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Christine de Suède', null, 1626, 1689, 'Reine de Suède', 'Vasa', 2091, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a4c696f1-e60e-5877-bb52-4ec292fc0892', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 'Hedwige-Éléonore de Holstein-Gottorp', null, 1636, 1715, 'Reine de Suède', 'Holstein-Gottorp', 348, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e05b47aa-900b-5e54-a48a-db6645dde7a6', 'entry', '7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Ulrique-Éléonore de Danemark', null, 1656, 1693, 'Reine de Suède', 'Oldenbourg', 223020, 11808, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b2807021-8150-511e-a65e-7d423667e645', 'entry', 'a19ba0b6-9d7f-5121-837b-40cda646ea38', 'Hedvige-Sophie de Suède', null, 1681, 1708, 'Duchesse de Holstein-Gottorp', 'Palatinat-Deux-Ponts', 250, 640, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('7d4388ff-49a7-55e0-8e6f-37d9b4e8103c', '6b076ad8-7ab3-5e1e-adb1-9d487fc5f203', 'spouse');
  perform pg_temp.rel('7d4388ff-49a7-55e0-8e6f-37d9b4e8103c', 'bf084a0f-5514-5b5b-bfb3-c254d2e20ba8', 'parent');
  perform pg_temp.rel('6b076ad8-7ab3-5e1e-adb1-9d487fc5f203', 'bf084a0f-5514-5b5b-bfb3-c254d2e20ba8', 'parent');
  perform pg_temp.rel('bf084a0f-5514-5b5b-bfb3-c254d2e20ba8', '35803429-98f9-5f83-8f5f-e0ae08b0c7fe', 'spouse');
  perform pg_temp.rel('bf084a0f-5514-5b5b-bfb3-c254d2e20ba8', 'b87cf92a-a1a4-58ce-82e0-9a07e0fbc765', 'spouse');
  perform pg_temp.rel('bf084a0f-5514-5b5b-bfb3-c254d2e20ba8', '8cd6dfb7-3994-5f17-9931-a4fbe1f874d4', 'spouse');
  perform pg_temp.rel('bf084a0f-5514-5b5b-bfb3-c254d2e20ba8', 'ed01951b-a5ac-5bf2-a9a9-052daf30fcc1', 'parent');
  perform pg_temp.rel('35803429-98f9-5f83-8f5f-e0ae08b0c7fe', 'ed01951b-a5ac-5bf2-a9a9-052daf30fcc1', 'parent');
  perform pg_temp.rel('bf084a0f-5514-5b5b-bfb3-c254d2e20ba8', '3161e73d-9607-5cce-89e0-188b3a585e2c', 'parent');
  perform pg_temp.rel('b87cf92a-a1a4-58ce-82e0-9a07e0fbc765', '3161e73d-9607-5cce-89e0-188b3a585e2c', 'parent');
  perform pg_temp.rel('bf084a0f-5514-5b5b-bfb3-c254d2e20ba8', 'dfd38bea-a542-5a69-95e1-b8c02bf8ff7c', 'parent');
  perform pg_temp.rel('b87cf92a-a1a4-58ce-82e0-9a07e0fbc765', 'dfd38bea-a542-5a69-95e1-b8c02bf8ff7c', 'parent');
  perform pg_temp.rel('bf084a0f-5514-5b5b-bfb3-c254d2e20ba8', 'fb7b5be8-098d-58f0-b78f-4067e8f34030', 'parent');
  perform pg_temp.rel('b87cf92a-a1a4-58ce-82e0-9a07e0fbc765', 'fb7b5be8-098d-58f0-b78f-4067e8f34030', 'parent');
  perform pg_temp.rel('ed01951b-a5ac-5bf2-a9a9-052daf30fcc1', '54e4c8f7-6aa8-5dec-b19a-198c9178ee4c', 'spouse');
  perform pg_temp.rel('ed01951b-a5ac-5bf2-a9a9-052daf30fcc1', 'f652b240-1bf9-5246-a5e1-e4750ccdad8b', 'parent');
  perform pg_temp.rel('54e4c8f7-6aa8-5dec-b19a-198c9178ee4c', 'f652b240-1bf9-5246-a5e1-e4750ccdad8b', 'parent');
  perform pg_temp.rel('3161e73d-9607-5cce-89e0-188b3a585e2c', '57b713c1-33be-5640-bc09-cb72c3d5437c', 'spouse');
  perform pg_temp.rel('3161e73d-9607-5cce-89e0-188b3a585e2c', '6a232d78-53f6-5189-b3e3-a0f8fd994c7f', 'parent');
  perform pg_temp.rel('3161e73d-9607-5cce-89e0-188b3a585e2c', '68dbdf3d-947e-594d-80dc-d86ce3eaf8c2', 'parent');
  perform pg_temp.rel('5fbd94f4-23bd-5a00-a935-db6709604ec0', '68dbdf3d-947e-594d-80dc-d86ce3eaf8c2', 'parent');
  perform pg_temp.rel('62b68c62-88d6-55d8-80ff-c9c223152670', 'c788bf4a-ffe2-5451-bc88-2f8c82bfae2b', 'parent');
  perform pg_temp.rel('76ae7223-6fe2-5151-ad8e-ecb9b391cec3', 'c788bf4a-ffe2-5451-bc88-2f8c82bfae2b', 'parent');
  perform pg_temp.rel('fb7b5be8-098d-58f0-b78f-4067e8f34030', 'c788bf4a-ffe2-5451-bc88-2f8c82bfae2b', 'spouse');
  perform pg_temp.rel('7c5d6558-c46c-48e1-8b55-ac8b977417e9', '9ff1e551-9d76-5e15-bf32-1a2d6ba87659', 'parent');
  perform pg_temp.rel('9ff1e551-9d76-5e15-bf32-1a2d6ba87659', 'b42f9b16-5513-5bb8-95cb-b2ca0de379b0', 'spouse');
  perform pg_temp.rel('9ff1e551-9d76-5e15-bf32-1a2d6ba87659', 'b36cbc6a-25cf-55ca-af2c-8ea264ba5dfb', 'parent');
  perform pg_temp.rel('b42f9b16-5513-5bb8-95cb-b2ca0de379b0', 'b36cbc6a-25cf-55ca-af2c-8ea264ba5dfb', 'parent');
  perform pg_temp.rel('fb7b5be8-098d-58f0-b78f-4067e8f34030', 'b36cbc6a-25cf-55ca-af2c-8ea264ba5dfb', 'spouse');
  perform pg_temp.rel('fb7b5be8-098d-58f0-b78f-4067e8f34030', 'dea8be65-86af-59ef-89df-980bd172af0d', 'parent');
  perform pg_temp.rel('c788bf4a-ffe2-5451-bc88-2f8c82bfae2b', 'dea8be65-86af-59ef-89df-980bd172af0d', 'parent');
  perform pg_temp.rel('dea8be65-86af-59ef-89df-980bd172af0d', '5feee699-997e-428c-90ea-82e0c395c062', 'spouse');
  perform pg_temp.rel('5feee699-997e-428c-90ea-82e0c395c062', '0ff1c7fc-619a-402c-94ce-dc6215a9dcd4', 'parent');
  perform pg_temp.rel('dea8be65-86af-59ef-89df-980bd172af0d', '0ff1c7fc-619a-402c-94ce-dc6215a9dcd4', 'parent');
  perform pg_temp.rel('fb7b5be8-098d-58f0-b78f-4067e8f34030', '1e285909-040f-519b-ae87-cba221517e2c', 'parent');
  perform pg_temp.rel('b36cbc6a-25cf-55ca-af2c-8ea264ba5dfb', '1e285909-040f-519b-ae87-cba221517e2c', 'parent');
  perform pg_temp.rel('fb7b5be8-098d-58f0-b78f-4067e8f34030', '1176d1af-cb7b-5260-899b-3e940695a0b6', 'parent');
  perform pg_temp.rel('b36cbc6a-25cf-55ca-af2c-8ea264ba5dfb', '1176d1af-cb7b-5260-899b-3e940695a0b6', 'parent');
  perform pg_temp.rel('fb7b5be8-098d-58f0-b78f-4067e8f34030', 'f5fd1f0c-d596-52bd-8b95-b3ddb79ccc42', 'parent');
  perform pg_temp.rel('b36cbc6a-25cf-55ca-af2c-8ea264ba5dfb', 'f5fd1f0c-d596-52bd-8b95-b3ddb79ccc42', 'parent');
  perform pg_temp.rel('6a232d78-53f6-5189-b3e3-a0f8fd994c7f', '1176d1af-cb7b-5260-899b-3e940695a0b6', 'spouse');
  perform pg_temp.rel('67571e4c-fc66-4ba0-8e84-66c06f88f8ae', 'cff665d8-0cdb-5fa8-b4cd-c58528bb9616', 'parent');
  perform pg_temp.rel('1e285909-040f-519b-ae87-cba221517e2c', 'cff665d8-0cdb-5fa8-b4cd-c58528bb9616', 'spouse');
  perform pg_temp.rel('1e285909-040f-519b-ae87-cba221517e2c', '7401af24-a7b4-5edf-992a-658c88eb2ced', 'parent');
  perform pg_temp.rel('cff665d8-0cdb-5fa8-b4cd-c58528bb9616', '7401af24-a7b4-5edf-992a-658c88eb2ced', 'parent');
  perform pg_temp.rel('0ff1c7fc-619a-402c-94ce-dc6215a9dcd4', 'a4c696f1-e60e-5877-bb52-4ec292fc0892', 'spouse');
  perform pg_temp.rel('0ff1c7fc-619a-402c-94ce-dc6215a9dcd4', 'a09fa1dd-c798-4f65-8f48-aaff29b4f813', 'parent');
  perform pg_temp.rel('a4c696f1-e60e-5877-bb52-4ec292fc0892', 'a09fa1dd-c798-4f65-8f48-aaff29b4f813', 'parent');
  perform pg_temp.rel('555a36dc-18c0-4abc-a411-901c1d7ac59c', 'e05b47aa-900b-5e54-a48a-db6645dde7a6', 'parent');
  perform pg_temp.rel('a09fa1dd-c798-4f65-8f48-aaff29b4f813', 'e05b47aa-900b-5e54-a48a-db6645dde7a6', 'spouse');
  perform pg_temp.rel('a09fa1dd-c798-4f65-8f48-aaff29b4f813', '841eb365-6517-4b89-bd3e-ef6192c6d93f', 'parent');
  perform pg_temp.rel('e05b47aa-900b-5e54-a48a-db6645dde7a6', '841eb365-6517-4b89-bd3e-ef6192c6d93f', 'parent');
  perform pg_temp.rel('a09fa1dd-c798-4f65-8f48-aaff29b4f813', '36ca6e33-35e2-4b57-9fbb-15228aac5d4d', 'parent');
  perform pg_temp.rel('e05b47aa-900b-5e54-a48a-db6645dde7a6', '36ca6e33-35e2-4b57-9fbb-15228aac5d4d', 'parent');
  perform pg_temp.rel('a09fa1dd-c798-4f65-8f48-aaff29b4f813', 'b2807021-8150-511e-a65e-7d423667e645', 'parent');
  perform pg_temp.rel('e05b47aa-900b-5e54-a48a-db6645dde7a6', 'b2807021-8150-511e-a65e-7d423667e645', 'parent');
  update public.genealogy_members set pos_x = 4316, pos_y = 2560 where id = '93abf290-4091-4e07-bfcb-889686f3377e';
  update public.genealogy_members set pos_x = 3460, pos_y = 1280 where id = '3161e73d-9607-5cce-89e0-188b3a585e2c';
  update public.genealogy_members set pos_x = 4742, pos_y = 1920 where id = 'f5808a3e-7f8e-58a0-92a2-132707a45f99';
  update public.genealogy_members set pos_x = 5296, pos_y = 2560 where id = 'bfe49031-f637-5e0a-af97-47b9d3831c44';
  update public.genealogy_members set pos_x = 4806, pos_y = 2560 where id = '5cd01c04-b31e-5569-9879-126d1c804fbd';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('5fbd94f4-23bd-5a00-a935-db6709604ec0', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 3950, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('c788bf4a-ffe2-5451-bc88-2f8c82bfae2b', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 990, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('b36cbc6a-25cf-55ca-af2c-8ea264ba5dfb', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 1970, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('5feee699-997e-428c-90ea-82e0c395c062', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 348, 2560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('0ff1c7fc-619a-402c-94ce-dc6215a9dcd4', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 838, 3200, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('cff665d8-0cdb-5fa8-b4cd-c58528bb9616', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 2336, 2560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('a09fa1dd-c798-4f65-8f48-aaff29b4f813', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 348, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('41a459cf-d841-41e3-a1f9-ca408a114b4b', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 3826, 2560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('d6b7f2a8-729b-521c-a5e8-fc676e90b39c', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 4252, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ebe4927a-5cbe-5989-9fde-a91aca8eaddb', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 5232, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('841eb365-6517-4b89-bd3e-ef6192c6d93f', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 6296, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('36ca6e33-35e2-4b57-9fbb-15228aac5d4d', 'entry', '2ad4a20e-d7a2-4732-9a7f-b29093b07ceb', 7296, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('a09fa1dd-c798-4f65-8f48-aaff29b4f813', 'entry', 'a19ba0b6-9d7f-5121-837b-40cda646ea38', 500, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('e05b47aa-900b-5e54-a48a-db6645dde7a6', 'entry', 'a19ba0b6-9d7f-5121-837b-40cda646ea38', 0, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v72 : % membres ajoutés.', 27;
end $$;
