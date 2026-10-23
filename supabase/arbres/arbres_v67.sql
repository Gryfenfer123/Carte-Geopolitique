-- arbres_v67.sql — Allemagne — Luxembourg (ascendance de Henri VI, enfants de Charles IV) et Carolingiens de Germanie (enfants de Louis le Germanique, Zwentibold)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Complète les arbres Luxembourg et Carolingiens (rien n'est supprimé).
-- Sources : Wikipédia en anglais (Henri V de Luxembourg, Henri VI, Charles IV, Jean de Görlitz, Louis le Germanique, Zwentibold, Arnulf). Dates non données = vides et signalées.
-- Marguerite de Bar, Richarde de Mecklembourg : familles sans arbre, placées dans l'arbre Luxembourg et signalées.
-- Oda de Saxe (épouse de Zwentibold, fille d'Otton Ier de Saxe) est créée dans l'arbre Ottoniens puis reliée.
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
  if exists (select 1 from public.genealogy_members where id = '576f32f6-3584-5128-a9c3-d894ce79043b') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('06f4496e-ddf5-4da4-9dd1-521987182138','135dac09-95b3-512d-9e2d-bce817e58469','22e11696-0645-4e59-b0a8-89ea28e5decb','233cbc8c-5e62-4ebb-ad94-02c93558e4c2','914f0473-6ac9-4109-886d-9e2fbec54dd3','bf39b729-2c4d-45ea-979c-ce768022f803','c4b5e199-023e-413d-b1aa-16c200dee630','eaa833a2-8bc7-4bbc-a721-d3c3420fd0f3','f20ba802-bd64-487e-9e48-151536453f69');
  if k <> 9 then raise exception 'Membres préexistants manquants (% sur 9) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  select count(*) into k from public.dossier_entries where id = '7c6654ff-ce07-440b-b856-fdfbaeb9a535' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Luxembourg introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = 'fbb1f258-25db-4dd9-95a1-32a99045444f' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Carolingiens introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '99d9527e-fbca-4280-ac55-426024c9ed90' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Ottoniens introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('576f32f6-3584-5128-a9c3-d894ce79043b', 'entry', '7c6654ff-ce07-440b-b856-fdfbaeb9a535', 'Henri V de Luxembourg', null, 1216, 1281, 'Comte de Luxembourg', 'Luxembourg', 192000, 3888, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fcb9f3c1-6f97-507c-b78b-cb487b11142b', 'entry', '7c6654ff-ce07-440b-b856-fdfbaeb9a535', 'Marguerite de Bar', null, null, null, 'Comtesse de Luxembourg', 'Bar', 192340, 5400, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('008667ae-6892-51bc-bcf5-428d05a9655f', 'entry', '7c6654ff-ce07-440b-b856-fdfbaeb9a535', 'Marguerite de Bohême (reine de Hongrie)', null, 1335, 1349, 'Reine de Hongrie', 'Luxembourg', 192680, 6030, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('32ab620c-46df-5a1e-ae89-0c34cbd22ff5', 'entry', '7c6654ff-ce07-440b-b856-fdfbaeb9a535', 'Jean de Görlitz', null, 1370, 1396, 'Duc de Görlitz', 'Luxembourg', 193020, 6660, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('03bdb010-3b63-5f8a-9f7f-a594e1f31372', 'entry', '7c6654ff-ce07-440b-b856-fdfbaeb9a535', 'Richarde de Mecklembourg', null, null, 1400, 'Duchesse de Görlitz', 'Mecklembourg', 193360, 5400, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d9c323b1-57e3-52eb-ad40-e93b02feeab7', 'entry', '7c6654ff-ce07-440b-b856-fdfbaeb9a535', 'Élisabeth de Görlitz', null, 1390, 1451, 'Duchesse de Luxembourg', 'Luxembourg', 193700, 7020, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('18fc01e8-6058-5bdf-9651-a91e5a5f7971', 'entry', '7c6654ff-ce07-440b-b856-fdfbaeb9a535', 'Marguerite de Bohême (burgravine de Nuremberg)', null, 1373, 1410, 'Burgravine de Nuremberg', 'Luxembourg', 194040, 6714, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ee857847-ce76-54cc-8a06-a1a1ae85a7aa', 'entry', 'fbb1f258-25db-4dd9-95a1-32a99045444f', 'Hildegarde de Germanie', null, 828, 856, 'Abbesse du Fraumünster', 'Carolingiens', 192000, -3096, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('06dcab2d-fa90-59df-ad62-23f94451464c', 'entry', 'fbb1f258-25db-4dd9-95a1-32a99045444f', 'Berthe de Germanie', null, null, 877, 'Abbesse du Fraumünster', 'Carolingiens', 192340, 5400, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5c31d956-8481-5a6a-8141-196b058c41a0', 'entry', 'fbb1f258-25db-4dd9-95a1-32a99045444f', 'Irmengarde de Chiemsee', null, null, 866, 'Abbesse de Chiemsee', 'Carolingiens', 192680, 5400, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5213b631-b2dd-56e5-8662-d2c348e45e69', 'entry', 'fbb1f258-25db-4dd9-95a1-32a99045444f', 'Zwentibold', null, 870, 900, 'Roi de Lotharingie', 'Carolingiens', 193020, -2340, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5f527e41-831c-5fcb-beb1-49747f361adb', 'entry', '99d9527e-fbca-4280-ac55-426024c9ed90', 'Oda de Saxe', null, null, null, 'Reine de Lotharingie', 'Ottoniens', 192000, 5400, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('576f32f6-3584-5128-a9c3-d894ce79043b', 'fcb9f3c1-6f97-507c-b78b-cb487b11142b', 'spouse');
  perform pg_temp.rel('576f32f6-3584-5128-a9c3-d894ce79043b', '22e11696-0645-4e59-b0a8-89ea28e5decb', 'parent');
  perform pg_temp.rel('fcb9f3c1-6f97-507c-b78b-cb487b11142b', '22e11696-0645-4e59-b0a8-89ea28e5decb', 'parent');
  perform pg_temp.rel('233cbc8c-5e62-4ebb-ad94-02c93558e4c2', '008667ae-6892-51bc-bcf5-428d05a9655f', 'parent');
  perform pg_temp.rel('c4b5e199-023e-413d-b1aa-16c200dee630', '008667ae-6892-51bc-bcf5-428d05a9655f', 'parent');
  perform pg_temp.rel('008667ae-6892-51bc-bcf5-428d05a9655f', '135dac09-95b3-512d-9e2d-bce817e58469', 'spouse');
  perform pg_temp.rel('233cbc8c-5e62-4ebb-ad94-02c93558e4c2', '32ab620c-46df-5a1e-ae89-0c34cbd22ff5', 'parent');
  perform pg_temp.rel('eaa833a2-8bc7-4bbc-a721-d3c3420fd0f3', '32ab620c-46df-5a1e-ae89-0c34cbd22ff5', 'parent');
  perform pg_temp.rel('32ab620c-46df-5a1e-ae89-0c34cbd22ff5', '03bdb010-3b63-5f8a-9f7f-a594e1f31372', 'spouse');
  perform pg_temp.rel('32ab620c-46df-5a1e-ae89-0c34cbd22ff5', 'd9c323b1-57e3-52eb-ad40-e93b02feeab7', 'parent');
  perform pg_temp.rel('03bdb010-3b63-5f8a-9f7f-a594e1f31372', 'd9c323b1-57e3-52eb-ad40-e93b02feeab7', 'parent');
  perform pg_temp.rel('233cbc8c-5e62-4ebb-ad94-02c93558e4c2', '18fc01e8-6058-5bdf-9651-a91e5a5f7971', 'parent');
  perform pg_temp.rel('eaa833a2-8bc7-4bbc-a721-d3c3420fd0f3', '18fc01e8-6058-5bdf-9651-a91e5a5f7971', 'parent');
  perform pg_temp.rel('914f0473-6ac9-4109-886d-9e2fbec54dd3', 'ee857847-ce76-54cc-8a06-a1a1ae85a7aa', 'parent');
  perform pg_temp.rel('06f4496e-ddf5-4da4-9dd1-521987182138', 'ee857847-ce76-54cc-8a06-a1a1ae85a7aa', 'parent');
  perform pg_temp.rel('914f0473-6ac9-4109-886d-9e2fbec54dd3', '06dcab2d-fa90-59df-ad62-23f94451464c', 'parent');
  perform pg_temp.rel('06f4496e-ddf5-4da4-9dd1-521987182138', '06dcab2d-fa90-59df-ad62-23f94451464c', 'parent');
  perform pg_temp.rel('914f0473-6ac9-4109-886d-9e2fbec54dd3', '5c31d956-8481-5a6a-8141-196b058c41a0', 'parent');
  perform pg_temp.rel('06f4496e-ddf5-4da4-9dd1-521987182138', '5c31d956-8481-5a6a-8141-196b058c41a0', 'parent');
  perform pg_temp.rel('f20ba802-bd64-487e-9e48-151536453f69', '5213b631-b2dd-56e5-8662-d2c348e45e69', 'parent');
  perform pg_temp.rel('bf39b729-2c4d-45ea-979c-ce768022f803', '5f527e41-831c-5fcb-beb1-49747f361adb', 'parent');
  perform pg_temp.rel('5213b631-b2dd-56e5-8662-d2c348e45e69', '5f527e41-831c-5fcb-beb1-49747f361adb', 'spouse');
  raise notice 'schema_v67 : % membres ajoutés.', 12;
end $$;
