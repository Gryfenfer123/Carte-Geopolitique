-- schema_v45.sql — Grèce — Wittelsbach (Othon) et Glücksbourg (Georges Ier → Constantin II)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Crée sous Grèce > Dynastie : Wittelsbach (Othon Ier et Amélie) et Glücksbourg (Georges Ier -> Constantin II), à partir des fiches Wikipédia.
-- Pas de dynastie byzantine ici (cas douteux : Grèce/Turquie, décision de Martin à prendre).
-- Épouses d'autres dynasties créées dans leur arbre : Thérèse de Saxe-Hildburghausen (Wettin), Olga Constantinovna et son père (Romanov), Sophie de Prusse (Hohenzollern), Frédérique de Hanovre (Welf), Anne-Marie de Danemark + Christian X, Frédéric IX et Ingrid (Glücksbourg danois, seulement les membres nécessaires).
-- Hélène de Grèce (créée par v44 dans l'arbre roumain) est rattachée à Glücksbourg ; Sophie d'Espagne et Philip Mountbatten (déjà en base) sont reliés.
-- Prérequis : v43 et v44 exécutés.
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
  if exists (select 1 from public.genealogy_members where id = 'ba0ae37e-972c-5d08-8efe-644fbf9a3d63') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('1cf3b0d0-0ede-4198-b86f-f2afa55d1083','380d8975-427d-5709-9d4e-883a16a58679','3a00d791-2624-43fe-938f-c670ee5c8f91','3ad23bf0-9d3f-535e-8681-ba0177ebdba4','7d1a58e1-331a-4bf0-aaef-27b0f146b64a','8b34e776-b6e1-4eeb-a8e5-174a9c0b84c0','8ccb484d-9c34-58aa-be64-d14a82c21c9b','8d90a20a-8beb-54e3-aeef-a9a29051eb38','90ba7484-f956-437d-af9d-89bc6de1f825','c01b6fc3-7da0-47e2-b9dc-153815f1ef69','e62118c0-d52b-4f4b-b8ff-ec66ecdcaa82','fd479735-1bf3-4898-a8fd-8d4dfd71a4ca');
  if k <> 12 then raise exception 'Membres préexistants manquants (% sur 12) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Wittelsbach » (GRC)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'GRC' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour GRC : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Wittelsbach';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('fadead30-ba8e-5422-b4f6-26c22fc3c8f6', cat_id, 'country', 'GRC', top, 'Wittelsbach', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'fadead30-ba8e-5422-b4f6-26c22fc3c8f6';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('85b756fc-1a58-5667-b9e5-b5cab574c23c', 'country', 'GRC', 'genealogy', 'Wittelsbach', cat_id, sec, admin_id);
  -- Arbre « Glücksbourg » (GRC)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'GRC' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour GRC : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Glücksbourg';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('721460c5-a76d-5bcd-9de5-5ee1daf5bbef', cat_id, 'country', 'GRC', top, 'Glücksbourg', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '721460c5-a76d-5bcd-9de5-5ee1daf5bbef';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 'country', 'GRC', 'genealogy', 'Glücksbourg', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = 'e76d91a3-1b9c-4703-85b3-9f711b6d6199' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Wittelsbach introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '309f20ea-3b5d-453b-87f9-286b7f1e6c60' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Wettin introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Romanov introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '39895573-27f3-4112-905b-c9ba7e3c95a1' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Hohenzollern introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = 'db5ef554-cbb9-448f-89fa-b656bf1d1147' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Welf introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '78bf5e64-5a01-48df-8ae2-e80934de7e4d' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Glücksbourg introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '546787ec-199c-5714-a8dd-efc170a09a62' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Hohenzollern-Sigmaringen introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ba0ae37e-972c-5d08-8efe-644fbf9a3d63', 'entry', '85b756fc-1a58-5667-b9e5-b5cab574c23c', 'Othon Ier de Grèce', null, 1815, 1867, 'Premier roi de Grèce (1832-1862)', 'Wittelsbach', 190, 576, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('24ec601a-a577-5f03-8627-ad8f6c018436', 'entry', '85b756fc-1a58-5667-b9e5-b5cab574c23c', 'Amélie d''Oldenbourg', null, 1818, 1875, 'Reine de Grèce', 'Oldenbourg (grand-duché)', 570, 576, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fc032ff4-8705-52b8-908e-f18eb83e7d21', 'entry', '309f20ea-3b5d-453b-87f9-286b7f1e6c60', 'Thérèse de Saxe-Hildburghausen', null, 1792, 1854, 'Reine de Bavière', 'Wettin (Saxe-Hildburghausen)', 60000, 14256, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('00b7cf89-f787-5874-a592-89a05b6aa579', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 'Georges Ier de Grèce', null, 1845, 1913, 'Roi des Hellènes (1863-1913)', 'Glücksbourg (Grèce)', 2306, 504, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('987f8ebe-1329-5ceb-a45e-cd72e00fdffc', 'entry', 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55', 'Olga Constantinovna de Russie', null, 1851, 1926, 'Reine des Hellènes', 'Romanov', 5746, 15318, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6f329842-e55c-51d9-847a-ba81c0e1fb17', 'entry', 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55', 'Constantin Nikolaïevitch de Russie', null, 1827, 1892, 'Grand-duc, père d''Olga', 'Romanov', 5746, 14805, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0c19d4b0-8806-5ad4-b03c-b73138cc4636', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 'Constantin Ier de Grèce', null, 1868, 1923, 'Roi des Hellènes (1913-1917, 1920-1922)', 'Glücksbourg (Grèce)', 2576, 964, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3afdcf0a-8831-50b0-8cdb-3daf58c10d3e', 'entry', '39895573-27f3-4112-905b-c9ba7e3c95a1', 'Sophie de Prusse', null, 1870, 1932, 'Reine des Hellènes', 'Hohenzollern', 60000, 15660, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('929cc915-5d66-57a9-a2a0-c53282d3ca44', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 'André de Grèce et de Danemark', null, 1882, 1944, 'Prince, père de Philip Mountbatten', 'Glücksbourg (Grèce)', 0, 1224, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('acb3e847-8d55-56a0-aa7c-80bde3323964', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 'Alice de Battenberg', null, 1885, 1969, 'Princesse de Grèce et de Danemark', 'Battenberg', 540, 1224, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d9546d79-6974-5e9a-874b-734dd9cdb9bb', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 'Georges II de Grèce', null, 1890, 1947, 'Roi des Hellènes (1922-1924, 1935-1947)', 'Glücksbourg (Grèce)', 2866, 1424, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b3777e2a-11be-5f62-8725-3239cdc3c319', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 'Alexandre Ier de Grèce', null, 1893, 1920, 'Roi des Hellènes (1917-1920)', 'Glücksbourg (Grèce)', 1070, 1422, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('14cd2586-1396-56a4-8f85-0f18efb60398', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 'Aspasia Manos', null, 1896, 1972, 'Épouse morganatique d''Alexandre Ier', 'Manos (noblesse grecque)', 1450, 1422, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9c34fc95-c612-5b34-a9b5-7337ab07d2f0', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 'Paul Ier de Grèce', null, 1901, 1964, 'Roi des Hellènes (1947-1964)', 'Glücksbourg (Grèce)', 2456, 1424, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('40b3669a-7b2d-52f3-89e8-6d92fff915b3', 'entry', 'db5ef554-cbb9-448f-89fa-b656bf1d1147', 'Frédérique de Hanovre', null, 1917, 1981, 'Reine des Hellènes', 'Hanovre (Welf)', 60000, 16506, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('846c852b-5e4c-55e2-9034-9d744f4bbde0', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 'Constantin II de Grèce', null, 1940, 2023, 'Dernier roi des Hellènes (1964-1973)', 'Glücksbourg (Grèce)', 2013, 2196, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('37776074-21f9-5263-83bf-d9b47fb94383', 'entry', '78bf5e64-5a01-48df-8ae2-e80934de7e4d', 'Christian X de Danemark', null, 1870, 1947, 'Roi de Danemark (1912-1947)', 'Glücksbourg', 60000, 15660, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('86d4566b-18da-5ec7-8169-ff7af03596f7', 'entry', '78bf5e64-5a01-48df-8ae2-e80934de7e4d', 'Frédéric IX de Danemark', null, 1899, 1972, 'Roi de Danemark (1947-1972)', 'Glücksbourg', 60340, 16182, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a78782ce-e7b5-5890-8054-724f647b945a', 'entry', '78bf5e64-5a01-48df-8ae2-e80934de7e4d', 'Ingrid de Suède', null, 1910, 2000, 'Reine de Danemark', 'Bernadotte (Suède)', 60680, 16380, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e4693e7c-3582-5902-8aff-fa86c650b924', 'entry', '78bf5e64-5a01-48df-8ae2-e80934de7e4d', 'Anne-Marie de Danemark', null, 1946, null, 'Reine des Hellènes', 'Glücksbourg', 61020, 17028, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('e62118c0-d52b-4f4b-b8ff-ec66ecdcaa82', 'fc032ff4-8705-52b8-908e-f18eb83e7d21', 'spouse');
  perform pg_temp.rel('e62118c0-d52b-4f4b-b8ff-ec66ecdcaa82', 'ba0ae37e-972c-5d08-8efe-644fbf9a3d63', 'parent');
  perform pg_temp.rel('fc032ff4-8705-52b8-908e-f18eb83e7d21', 'ba0ae37e-972c-5d08-8efe-644fbf9a3d63', 'parent');
  perform pg_temp.rel('ba0ae37e-972c-5d08-8efe-644fbf9a3d63', '24ec601a-a577-5f03-8627-ad8f6c018436', 'spouse');
  perform pg_temp.rel('380d8975-427d-5709-9d4e-883a16a58679', '6f329842-e55c-51d9-847a-ba81c0e1fb17', 'parent');
  perform pg_temp.rel('8ccb484d-9c34-58aa-be64-d14a82c21c9b', '6f329842-e55c-51d9-847a-ba81c0e1fb17', 'parent');
  perform pg_temp.rel('6f329842-e55c-51d9-847a-ba81c0e1fb17', '987f8ebe-1329-5ceb-a45e-cd72e00fdffc', 'parent');
  perform pg_temp.rel('fd479735-1bf3-4898-a8fd-8d4dfd71a4ca', '00b7cf89-f787-5874-a592-89a05b6aa579', 'parent');
  perform pg_temp.rel('7d1a58e1-331a-4bf0-aaef-27b0f146b64a', '00b7cf89-f787-5874-a592-89a05b6aa579', 'parent');
  perform pg_temp.rel('00b7cf89-f787-5874-a592-89a05b6aa579', '987f8ebe-1329-5ceb-a45e-cd72e00fdffc', 'spouse');
  perform pg_temp.rel('90ba7484-f956-437d-af9d-89bc6de1f825', '3afdcf0a-8831-50b0-8cdb-3daf58c10d3e', 'parent');
  perform pg_temp.rel('1cf3b0d0-0ede-4198-b86f-f2afa55d1083', '3afdcf0a-8831-50b0-8cdb-3daf58c10d3e', 'parent');
  perform pg_temp.rel('00b7cf89-f787-5874-a592-89a05b6aa579', '0c19d4b0-8806-5ad4-b03c-b73138cc4636', 'parent');
  perform pg_temp.rel('987f8ebe-1329-5ceb-a45e-cd72e00fdffc', '0c19d4b0-8806-5ad4-b03c-b73138cc4636', 'parent');
  perform pg_temp.rel('00b7cf89-f787-5874-a592-89a05b6aa579', '929cc915-5d66-57a9-a2a0-c53282d3ca44', 'parent');
  perform pg_temp.rel('987f8ebe-1329-5ceb-a45e-cd72e00fdffc', '929cc915-5d66-57a9-a2a0-c53282d3ca44', 'parent');
  perform pg_temp.rel('0c19d4b0-8806-5ad4-b03c-b73138cc4636', '3afdcf0a-8831-50b0-8cdb-3daf58c10d3e', 'spouse');
  perform pg_temp.rel('0c19d4b0-8806-5ad4-b03c-b73138cc4636', 'd9546d79-6974-5e9a-874b-734dd9cdb9bb', 'parent');
  perform pg_temp.rel('3afdcf0a-8831-50b0-8cdb-3daf58c10d3e', 'd9546d79-6974-5e9a-874b-734dd9cdb9bb', 'parent');
  perform pg_temp.rel('0c19d4b0-8806-5ad4-b03c-b73138cc4636', 'b3777e2a-11be-5f62-8725-3239cdc3c319', 'parent');
  perform pg_temp.rel('3afdcf0a-8831-50b0-8cdb-3daf58c10d3e', 'b3777e2a-11be-5f62-8725-3239cdc3c319', 'parent');
  perform pg_temp.rel('0c19d4b0-8806-5ad4-b03c-b73138cc4636', '9c34fc95-c612-5b34-a9b5-7337ab07d2f0', 'parent');
  perform pg_temp.rel('3afdcf0a-8831-50b0-8cdb-3daf58c10d3e', '9c34fc95-c612-5b34-a9b5-7337ab07d2f0', 'parent');
  perform pg_temp.rel('0c19d4b0-8806-5ad4-b03c-b73138cc4636', '8d90a20a-8beb-54e3-aeef-a9a29051eb38', 'parent');
  perform pg_temp.rel('3afdcf0a-8831-50b0-8cdb-3daf58c10d3e', '8d90a20a-8beb-54e3-aeef-a9a29051eb38', 'parent');
  perform pg_temp.rel('d9546d79-6974-5e9a-874b-734dd9cdb9bb', '3ad23bf0-9d3f-535e-8681-ba0177ebdba4', 'spouse');
  perform pg_temp.rel('b3777e2a-11be-5f62-8725-3239cdc3c319', '14cd2586-1396-56a4-8f85-0f18efb60398', 'spouse');
  perform pg_temp.rel('929cc915-5d66-57a9-a2a0-c53282d3ca44', 'acb3e847-8d55-56a0-aa7c-80bde3323964', 'spouse');
  perform pg_temp.rel('929cc915-5d66-57a9-a2a0-c53282d3ca44', 'c01b6fc3-7da0-47e2-b9dc-153815f1ef69', 'parent');
  perform pg_temp.rel('acb3e847-8d55-56a0-aa7c-80bde3323964', 'c01b6fc3-7da0-47e2-b9dc-153815f1ef69', 'parent');
  perform pg_temp.rel('9c34fc95-c612-5b34-a9b5-7337ab07d2f0', '40b3669a-7b2d-52f3-89e8-6d92fff915b3', 'spouse');
  perform pg_temp.rel('9c34fc95-c612-5b34-a9b5-7337ab07d2f0', '846c852b-5e4c-55e2-9034-9d744f4bbde0', 'parent');
  perform pg_temp.rel('40b3669a-7b2d-52f3-89e8-6d92fff915b3', '846c852b-5e4c-55e2-9034-9d744f4bbde0', 'parent');
  perform pg_temp.rel('9c34fc95-c612-5b34-a9b5-7337ab07d2f0', '3a00d791-2624-43fe-938f-c670ee5c8f91', 'parent');
  perform pg_temp.rel('40b3669a-7b2d-52f3-89e8-6d92fff915b3', '3a00d791-2624-43fe-938f-c670ee5c8f91', 'parent');
  perform pg_temp.rel('8b34e776-b6e1-4eeb-a8e5-174a9c0b84c0', '37776074-21f9-5263-83bf-d9b47fb94383', 'parent');
  perform pg_temp.rel('37776074-21f9-5263-83bf-d9b47fb94383', '86d4566b-18da-5ec7-8169-ff7af03596f7', 'parent');
  perform pg_temp.rel('86d4566b-18da-5ec7-8169-ff7af03596f7', 'a78782ce-e7b5-5890-8054-724f647b945a', 'spouse');
  perform pg_temp.rel('86d4566b-18da-5ec7-8169-ff7af03596f7', 'e4693e7c-3582-5902-8aff-fa86c650b924', 'parent');
  perform pg_temp.rel('a78782ce-e7b5-5890-8054-724f647b945a', 'e4693e7c-3582-5902-8aff-fa86c650b924', 'parent');
  perform pg_temp.rel('846c852b-5e4c-55e2-9034-9d744f4bbde0', 'e4693e7c-3582-5902-8aff-fa86c650b924', 'spouse');
  update public.genealogy_members set pos_x = 2745, pos_y = 0 where id = '5f86a171-0b2b-582c-a5eb-514ebecfc2f6';
  update public.genealogy_members set pos_x = 2950, pos_y = 9468 where id = 'aeb73e2e-2159-5a85-9af8-2a12b8f3c514';
  update public.genealogy_members set pos_x = 2540, pos_y = 9468 where id = '736d7bde-fe5b-55ab-89dd-c2c5f1c5aab2';
  update public.genealogy_members set pos_x = 2085, pos_y = 10080 where id = '5e818510-6368-5ab0-8949-0b0f06f263f4';
  update public.genealogy_members set pos_x = 2625, pos_y = 10080 where id = 'f3f378a8-5da8-58bd-b68d-1ea82342fc67';
  update public.genealogy_members set pos_x = 2355, pos_y = 10728 where id = '81585eea-1f3f-5430-b85c-868d95cfc2fc';
  update public.genealogy_members set pos_x = 2895, pos_y = 10728 where id = '3c4fc900-ce05-5d03-9e86-e4f61d1f3039';
  update public.genealogy_members set pos_x = 2625, pos_y = 11322 where id = '7024001c-b80a-5fca-96ef-83a74197edb1';
  update public.genealogy_members set pos_x = 0, pos_y = 11322 where id = '0a9222c3-6b8b-5df1-b002-f0f08f783d22';
  update public.genealogy_members set pos_x = 5126, pos_y = 11322 where id = '7d5cdc28-2a76-5f08-b154-31e646633fe0';
  update public.genealogy_members set pos_x = 1312, pos_y = 11952 where id = 'd1c3f032-9113-5a2f-b6e5-8e873f51f128';
  update public.genealogy_members set pos_x = 902, pos_y = 11952 where id = 'f32c0ec7-b59f-551b-8d55-f8cc9b5941a4';
  update public.genealogy_members set pos_x = 1722, pos_y = 11952 where id = 'ef1f9e75-3cce-55bb-aaa8-33d5e225d645';
  update public.genealogy_members set pos_x = 2287, pos_y = 11952 where id = '94138e5b-8350-5628-aac0-c74f489d6089';
  update public.genealogy_members set pos_x = 3875, pos_y = 11952 where id = 'd6793496-b9cb-55f7-a4d8-500c33598d0f';
  update public.genealogy_members set pos_x = 2697, pos_y = 11952 where id = '8ac50b9b-84a1-5bd0-b6bc-e66aa5a6fbbc';
  update public.genealogy_members set pos_x = 5007, pos_y = 11952 where id = 'c5e8471f-953c-53d7-81a0-8979bf6138f0';
  update public.genealogy_members set pos_x = 3286, pos_y = 12642 where id = 'fdb3975d-0d26-5481-9728-6099aaae2e27';
  update public.genealogy_members set pos_x = 3016, pos_y = 13102 where id = '4026ff1b-d3a7-5921-ad0d-f299c8b30c2c';
  update public.genealogy_members set pos_x = 2210, pos_y = 12456 where id = '0db6100f-20b7-5ea7-a5a3-270f0726fbd0';
  update public.genealogy_members set pos_x = 1800, pos_y = 12456 where id = 'b2a3fdd3-b996-5224-bd96-5d935170198c';
  update public.genealogy_members set pos_x = 1260, pos_y = 12456 where id = '3fe460aa-1085-5510-86d0-58e9eb242d7f';
  update public.genealogy_members set pos_x = 1530, pos_y = 12924 where id = 'a4085a06-4a3b-5fc9-8a04-d3b2cc75ad58';
  update public.genealogy_members set pos_x = 1260, pos_y = 13384 where id = 'e4698345-fb75-5d18-97c5-9edaea3145f5';
  update public.genealogy_members set pos_x = 4646, pos_y = 12642 where id = 'cc0ab643-8bd6-5ff1-a6cf-440d4bbc94ab';
  update public.genealogy_members set pos_x = 4236, pos_y = 12642 where id = '6a3227ba-26b4-565e-bac9-bbc52fcc6f1d';
  update public.genealogy_members set pos_x = 3696, pos_y = 12642 where id = '515a76c3-ee3e-5857-8056-baba39015d1d';
  update public.genealogy_members set pos_x = 3966, pos_y = 13104 where id = '4e48f878-b1cf-585f-b804-90e407945ece';
  update public.genealogy_members set pos_x = 4506, pos_y = 13104 where id = '20b5660a-92bc-5a8c-bf93-ef46cf585f9c';
  update public.genealogy_members set pos_x = 4236, pos_y = 13572 where id = '57d16fba-8237-56d7-ad59-e5572f77e8e0';
  update public.genealogy_members set pos_x = 4764, pos_y = 13572 where id = '02d2a8de-7e33-57c5-bfa5-1a17f6f6b41a';
  update public.genealogy_members set pos_x = 4295, pos_y = 14157 where id = 'fff8c132-6a3b-5ece-93f3-6f2d98f2e77f';
  update public.genealogy_members set pos_x = 3915, pos_y = 14157 where id = '80cdd307-6472-582e-8219-dfc1a9e29a8d';
  update public.genealogy_members set pos_x = 4705, pos_y = 14157 where id = '380d8975-427d-5709-9d4e-883a16a58679';
  update public.genealogy_members set pos_x = 4476, pos_y = 14805 where id = '41951938-61b4-568b-9b14-b3c456633c73';
  update public.genealogy_members set pos_x = 3936, pos_y = 14805 where id = 'e846ee0c-53b0-5bd6-a958-4dcb159fcfe5';
  update public.genealogy_members set pos_x = 4206, pos_y = 15265 where id = 'b460f60b-0f57-5bc1-886b-f9ab0e23c0c2';
  update public.genealogy_members set pos_x = 4284, pos_y = 15725 where id = '443aa9f3-0b8e-57ae-b387-fd348d2d2532';
  update public.genealogy_members set pos_x = 3744, pos_y = 15725 where id = 'ed83e643-c52e-54df-8013-5cbfd1713d5a';
  update public.genealogy_members set pos_x = 4014, pos_y = 16272 where id = '1473e79c-7554-576c-943c-d17407e768d2';
  update public.genealogy_members set pos_x = 4694, pos_y = 15725 where id = '27571788-e385-56b3-8481-7e31ccda743d';
  update public.genealogy_members set pos_x = 1268, pos_y = 576 where id = 'c824615b-5f16-581f-bb80-edf86f2c23e0';
  update public.genealogy_members set pos_x = 1648, pos_y = 576 where id = 'f19e2275-fbd3-53ef-9d61-9476869ef9fd';
  update public.genealogy_members set pos_x = 603, pos_y = 1152 where id = '6445dd56-a167-59c3-9a99-fb71ad5b5a90';
  update public.genealogy_members set pos_x = 1768, pos_y = 1152 where id = '6b1c17b8-aa8d-5d50-95ae-d1b9c22b58dd';
  update public.genealogy_members set pos_x = 1990, pos_y = 1612 where id = 'e648f724-c76b-580e-8402-9c658c8ec170';
  update public.genealogy_members set pos_x = 2370, pos_y = 1612 where id = '262b541c-9e0d-53fc-bdde-e004d1bb63c5';
  update public.genealogy_members set pos_x = 1610, pos_y = 1612 where id = 'a2319cd3-65dc-544b-9754-30ec1bb66072';
  update public.genealogy_members set pos_x = 2260, pos_y = 2072 where id = '539441be-08d0-517e-862d-211a0d88899f';
  update public.genealogy_members set pos_x = 2530, pos_y = 2532 where id = 'a127df16-05d2-5e5d-8e14-e94f846df830';
  update public.genealogy_members set pos_x = 380, pos_y = 1612 where id = '3ad23bf0-9d3f-535e-8681-ba0177ebdba4';
  update public.genealogy_members set pos_x = 790, pos_y = 1612 where id = '409659a4-633b-5ae1-ad17-c5e3b092e3b9';
  update public.genealogy_members set pos_x = 1200, pos_y = 1612 where id = 'd743954d-a28d-54c9-bf71-9d6f87fdacda';
  update public.genealogy_members set owner_id = 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', pos_x = 3656, pos_y = 1424, dynasty = 'Glücksbourg (Grèce)' where id = '8d90a20a-8beb-54e3-aeef-a9a29051eb38' and owner_type = 'entry';
  delete from public.genealogy_foreign_states where member_id = '8d90a20a-8beb-54e3-aeef-a9a29051eb38' and owner_type = 'entry' and owner_id = 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('e62118c0-d52b-4f4b-b8ff-ec66ecdcaa82', 'entry', '85b756fc-1a58-5667-b9e5-b5cab574c23c', 0, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('fc032ff4-8705-52b8-908e-f18eb83e7d21', 'entry', '85b756fc-1a58-5667-b9e5-b5cab574c23c', 380, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('fd479735-1bf3-4898-a8fd-8d4dfd71a4ca', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 2036, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('7d1a58e1-331a-4bf0-aaef-27b0f146b64a', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 2576, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('987f8ebe-1329-5ceb-a45e-cd72e00fdffc', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 2846, 504, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('3afdcf0a-8831-50b0-8cdb-3daf58c10d3e', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 3536, 964, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('3ad23bf0-9d3f-535e-8681-ba0177ebdba4', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 3246, 1424, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('c01b6fc3-7da0-47e2-b9dc-153815f1ef69', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 270, 1872, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('40b3669a-7b2d-52f3-89e8-6d92fff915b3', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 1980, 1424, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('3a00d791-2624-43fe-938f-c670ee5c8f91', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 2423, 2196, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('e4693e7c-3582-5902-8aff-fa86c650b924', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 1633, 2196, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('e648f724-c76b-580e-8402-9c658c8ec170', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 4196, 1424, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('539441be-08d0-517e-862d-211a0d88899f', 'entry', 'c704a8a4-e7f3-5be5-8fa2-2da0be8d11ee', 3926, 1884, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('8ccb484d-9c34-58aa-be64-d14a82c21c9b', 'entry', 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55', 5517, 14157, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('00b7cf89-f787-5874-a592-89a05b6aa579', 'entry', 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55', 5181, 15318, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('0c19d4b0-8806-5ad4-b03c-b73138cc4636', 'entry', 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55', 5259, 15778, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('929cc915-5d66-57a9-a2a0-c53282d3ca44', 'entry', 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55', 5669, 15778, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('1208e649-4289-5e61-920d-e6f7186786a8', 'entry', 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55', 3490, 9468, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('16c0ee72-955d-51b6-9118-0f08c75bf595', 'entry', 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55', 3220, 10026, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('2557b841-e6dd-5952-b801-d8b3c3f1959c', 'entry', 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55', 2746, 12642, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('7fb9d519-bfd3-5b00-a650-5692a49cb66f', 'entry', 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55', 990, 12924, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('37d5e22a-65a3-5d62-bbb7-331c966b6883', 'entry', 'a0f9af2b-e8d8-5edb-af82-3cda4917ae55', 4771, 15265, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('d9546d79-6974-5e9a-874b-734dd9cdb9bb', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 0, 1612, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('a229b45f-df5d-5a4f-a508-3c811765f21d', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 1078, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('05120133-bcce-520c-b6c7-d9296259ed6a', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 1458, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ccf2b88a-f16d-51ce-8223-1d05ec300c81', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 413, 432, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('7ad31217-24f3-59bc-ac26-03ee1137e825', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 793, 432, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('8d90a20a-8beb-54e3-aeef-a9a29051eb38', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 2750, 1612, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ed2847e5-4b58-5b32-ba4c-9d54126db0eb', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 2800, 2072, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v45 : % membres ajoutés.', 20;
end $$;
