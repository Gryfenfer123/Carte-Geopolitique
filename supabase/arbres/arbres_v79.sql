-- arbres_v79.sql — Italie — Médicis : de Giovanni di Bicci aux derniers grands-ducs de Toscane, avec Catherine et Marie de Médicis
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Médicis » (aucun n'existait). Rien n'est supprimé.
-- Source de la structure : Wikipédia en anglais (House of Medici : tableau des souverains). Dates : connues par ailleurs, la page ne les donne pas toutes ; dates douteuses laissées vides.
-- Catherine de Médicis (arbre Valois) et Marie de Médicis (arbre Bourbon) sont affichées ici. Jeanne et Marguerite d'Autriche sont créées dans l'arbre Habsbourg ; Marguerite-Louise d'Orléans dans l'arbre Bourbon.
-- Épouses de familles sans arbre (Bardi, Tornabuoni, Orsini, Sforza, Salviati, Tolède, Lorraine, Della Rovere, Saxe-Lauenbourg…) : placées ici et signalées.
-- Non fait : branches latérales, enfants naturels (hors Alessandro et Ippolito), cardinaux Médicis, Léon XI.
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
  if exists (select 1 from public.genealogy_members where id = '15974c82-b86f-5053-b6fe-2e377024f361') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('13608e16-4ad6-4106-acf6-010fb43d4555','2b61583b-5e1e-456a-90b9-0758f126db75','323fddf6-5fa4-4338-9720-04c03f0e9f77','32b5e90e-4358-5a9f-b97a-dda04286d882','401b55d7-2a9c-44f3-991e-f677a497b2db','52ed7330-a403-52ca-8a58-11695b9eee87','b5893e2e-7ed2-4ac8-a900-a22c0e50fdf6');
  if k <> 7 then raise exception 'Membres préexistants manquants (% sur 7) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Médicis » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Médicis';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('a2b117c6-e304-5a8e-a4ef-0b69af9182b8', cat_id, 'country', 'ITA', top, 'Médicis', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'a2b117c6-e304-5a8e-a4ef-0b69af9182b8';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('31ab743f-533f-5c1b-b317-728a4e0067b5', 'country', 'ITA', 'genealogy', 'Médicis', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = '786a379d-20c7-446b-922a-af4beb086251' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre de Bourbon et Bourbon-Orléans introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '6b34bc03-d0ad-4c48-a485-f541cecafd5d' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Habsbourg introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = 'a92b4627-d9e5-4325-81ed-8b3dfebacf5b' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Valois introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('15974c82-b86f-5053-b6fe-2e377024f361', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Giovanni di Bicci de'' Medici', null, 1360, 1429, 'Fondateur de la banque Médicis', 'Médicis', 2047, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('94fd6cfc-8880-58b4-9350-eabe6a188060', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Piccarda Bueri', null, null, null, 'Épouse de Giovanni di Bicci', 'Bueri', 1557, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0daae3a4-4738-56e9-be9c-30d30c2ce5ff', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Cosimo l''Ancien', null, 1389, 1464, 'Maître de Florence (1434-1464)', 'Médicis', 1521, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('92299032-2e3c-552e-83f2-ec10f8094385', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Lorenzo l''Ancien', null, 1395, 1440, 'Frère de Cosimo, souche de la branche cadette', 'Médicis', 2245, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2eeccb07-f268-50c3-a933-624ef80d1231', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Contessina de'' Bardi', null, null, null, 'Épouse de Cosimo l''Ancien', 'Bardi', 1031, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f110cd83-3c6b-5876-a7c0-ca43f325840c', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Piero Ier le Goutteux', null, 1416, 1469, 'Maître de Florence (1464-1469)', 'Médicis', 941, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('487ed0a7-70ee-5f7f-871e-67b92c3da18d', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Giovanni di Cosimo', null, 1421, 1463, 'Fils de Cosimo l''Ancien', 'Médicis', 1441, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1d12dc56-e857-5d2c-a2ab-d89c5c325d85', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Lucrezia Tornabuoni', null, 1425, 1482, 'Épouse de Piero le Goutteux', 'Tornabuoni', 451, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('07d33fc7-3eb4-5479-b0df-a1edf2619da7', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Laurent le Magnifique', null, 1449, 1492, 'Maître de Florence (1469-1492)', 'Médicis', 1154, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a82bed61-7d43-5ec4-a576-bbe12aa7fa93', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Julien de Médicis', null, 1453, 1478, 'Frère de Laurent, tué lors de la conjuration des Pazzi', 'Médicis', 0, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('473d1033-81e4-5174-9e01-12cfebc276e3', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Clarice Orsini', null, 1453, 1488, 'Épouse de Laurent le Magnifique', 'Orsini', 1644, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('22f423cd-89ba-5255-9d98-37a1c8956efd', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Pierre II l''Infortuné', null, 1472, 1503, 'Maître de Florence (1492-1494)', 'Médicis', 990, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5caa0f9c-5e16-5e32-a071-2526f2dec9fd', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Léon X (Giovanni de Médicis)', null, 1475, 1521, 'Pape (1513-1521)', 'Médicis', 1490, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('82197180-d29c-5b7f-9595-0c1b74f0aef6', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Julien de Médicis, duc de Nemours', null, 1479, 1516, 'Duc de Nemours', 'Médicis', 1990, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bbf70094-e263-5337-968f-a3fae7835bd4', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Clément VII (Giulio de Médicis)', null, 1478, 1534, 'Pape (1523-1534)', 'Médicis', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('35efa46f-84ba-54ee-bd24-916f7ad2ba55', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Hippolyte de Médicis', null, 1511, 1535, 'Cardinal, maître de Florence (1523-1529)', 'Médicis', 1990, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('64ae5624-7b99-5426-a103-e2d1aac61d65', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Alfonsina Orsini', null, 1472, 1520, 'Épouse de Pierre II', 'Orsini', 500, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5f0e9877-fa0a-5ff6-b50c-19eab2fded6a', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Laurent II, duc d''Urbin', null, 1492, 1519, 'Duc d''Urbin, maître de Florence', 'Médicis', 745, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ee400799-a106-5fc8-adad-0a556e0807d8', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Madeleine de La Tour d''Auvergne', null, 1500, 1519, 'Duchesse d''Urbin, mère de Catherine', 'La Tour d''Auvergne', 1235, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2f14d3ea-6f2f-52e1-a38f-44d63b72de76', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Alexandre de Médicis', null, 1510, 1537, 'Premier duc de Florence', 'Médicis', 595, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('60980970-8d53-5628-b0dd-7baadfa1e7e7', 'entry', '6b34bc03-d0ad-4c48-a485-f541cecafd5d', 'Marguerite d''Autriche (fille naturelle de Charles Quint)', null, 1522, 1586, 'Duchesse de Florence puis de Parme', 'Habsbourg', 264000, 9396, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('84f2ab55-9f1e-59cf-9b68-1bb7ac20c27f', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Pierfrancesco de Médicis', null, 1430, 1476, 'Fils de Lorenzo l''Ancien', 'Médicis', 2245, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('57f560f5-8ba8-5d1e-abd2-7ffcd3721259', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Jean le Popolain', null, 1467, 1498, 'Fils de Pierfrancesco', 'Médicis', 2245, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('387d26db-cc1c-5e89-91f4-d53946159d36', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Caterina Sforza', null, 1463, 1509, 'Comtesse de Forlì, épouse de Jean le Popolain', 'Sforza', 2735, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('be0c6999-1699-5080-8530-c74129fc3684', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Jean des Bandes Noires', null, 1498, 1526, 'Condottiere, père de Cosimo Ier', 'Médicis', 2490, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3cbb56f4-c550-5ab8-acfe-3fd06489b0c5', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Maria Salviati', null, 1499, 1543, 'Épouse de Jean des Bandes Noires', 'Salviati', 2980, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('38414dbd-38b9-56b3-a1e6-5a7f32927af4', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Cosme Ier', null, 1519, 1574, 'Duc de Florence, premier grand-duc de Toscane', 'Médicis', 2735, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8974197c-5642-5687-9532-cd5838830e02', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Éléonore de Tolède', null, 1522, 1562, 'Duchesse de Florence', 'Tolède', 3225, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('98562bc3-d046-5922-b744-acd374c2056b', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'François Ier', null, 1541, 1587, 'Grand-duc de Toscane', 'Médicis', 2085, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('061bcb61-8db7-5caf-be4c-cda052d67e1d', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Ferdinand Ier', null, 1549, 1609, 'Grand-duc de Toscane', 'Médicis', 3593, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3263323d-5323-56ec-8009-9252393b9031', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Isabelle de Médicis', null, 1542, 1576, 'Duchesse de Bracciano', 'Médicis', 3075, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8cfd9ecd-4064-5fe0-be57-f2b12094b2cd', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Bianca Cappello', null, 1548, 1587, 'Seconde épouse de François Ier', 'Cappello', 2575, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('376de58a-617f-5d5a-98cc-79695efc3ede', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Éléonore de Médicis', null, 1567, 1611, 'Duchesse de Mantoue', 'Médicis', 1713, 4480, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b68e21d4-1f1f-54a6-816a-c0bc17451299', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Christine de Lorraine', null, 1565, 1637, 'Grande-duchesse de Toscane', 'Lorraine', 4083, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('507c3d51-bc0e-5fd3-98f4-d80f2a501503', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Cosme II', null, 1590, 1621, 'Grand-duc de Toscane', 'Médicis', 3838, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9d06c682-eab3-5cac-81f3-0233c71b71e1', 'entry', '6b34bc03-d0ad-4c48-a485-f541cecafd5d', 'Marie-Madeleine d''Autriche', null, 1589, 1631, 'Grande-duchesse de Toscane', 'Habsbourg', 264340, 10602, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('02d920d4-bab9-5ae6-852e-cb65b82bde80', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Ferdinand II', null, 1610, 1670, 'Grand-duc de Toscane', 'Médicis', 3593, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('34cf979b-f42a-5f06-901b-ec4f7db09108', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Victoire della Rovere', null, 1622, 1694, 'Grande-duchesse de Toscane', 'Della Rovere', 3103, 5120, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('29b7c014-3fb2-5182-bbda-39ad4a34de24', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Cosme III', null, 1642, 1723, 'Grand-duc de Toscane', 'Médicis', 3348, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f2292393-d302-558a-80e5-bdee83f0df1f', 'entry', '786a379d-20c7-446b-922a-af4beb086251', 'Marguerite de Lorraine', null, 1615, 1672, 'Duchesse d''Orléans, seconde épouse de Gaston', 'Lorraine', 264000, 11070, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('895a4460-54b6-53fe-a2ba-0d52fb3d63f2', 'entry', '786a379d-20c7-446b-922a-af4beb086251', 'Marguerite-Louise d''Orléans', null, 1645, 1721, 'Grande-duchesse de Toscane', 'Orléans', 264340, 11610, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('78598cea-314f-520a-a1ad-ae3ded159e85', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Ferdinand de Médicis, grand-prince', null, 1663, 1713, 'Héritier non couronné de Toscane', 'Médicis', 3594, 6400, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6fe70583-e9b4-5bcd-81d2-7fc22ad59c12', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Anne-Marie-Louise de Médicis', null, 1667, 1743, 'Électrice palatine, dernière des Médicis', 'Médicis', 3094, 6400, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d8a54c67-b656-552c-9589-601a14cdccb9', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Jean-Gaston', null, 1671, 1737, 'Dernier grand-duc de Toscane', 'Médicis', 4094, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('008ef7cc-1350-5c86-93c1-5ed1011345cf', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Anne-Marie-Françoise de Saxe-Lauenbourg', null, 1672, 1741, 'Grande-duchesse de Toscane', 'Saxe-Lauenbourg', 4584, 6400, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('15974c82-b86f-5053-b6fe-2e377024f361', '94fd6cfc-8880-58b4-9350-eabe6a188060', 'spouse');
  perform pg_temp.rel('15974c82-b86f-5053-b6fe-2e377024f361', '0daae3a4-4738-56e9-be9c-30d30c2ce5ff', 'parent');
  perform pg_temp.rel('94fd6cfc-8880-58b4-9350-eabe6a188060', '0daae3a4-4738-56e9-be9c-30d30c2ce5ff', 'parent');
  perform pg_temp.rel('15974c82-b86f-5053-b6fe-2e377024f361', '92299032-2e3c-552e-83f2-ec10f8094385', 'parent');
  perform pg_temp.rel('94fd6cfc-8880-58b4-9350-eabe6a188060', '92299032-2e3c-552e-83f2-ec10f8094385', 'parent');
  perform pg_temp.rel('0daae3a4-4738-56e9-be9c-30d30c2ce5ff', '2eeccb07-f268-50c3-a933-624ef80d1231', 'spouse');
  perform pg_temp.rel('0daae3a4-4738-56e9-be9c-30d30c2ce5ff', 'f110cd83-3c6b-5876-a7c0-ca43f325840c', 'parent');
  perform pg_temp.rel('2eeccb07-f268-50c3-a933-624ef80d1231', 'f110cd83-3c6b-5876-a7c0-ca43f325840c', 'parent');
  perform pg_temp.rel('0daae3a4-4738-56e9-be9c-30d30c2ce5ff', '487ed0a7-70ee-5f7f-871e-67b92c3da18d', 'parent');
  perform pg_temp.rel('2eeccb07-f268-50c3-a933-624ef80d1231', '487ed0a7-70ee-5f7f-871e-67b92c3da18d', 'parent');
  perform pg_temp.rel('f110cd83-3c6b-5876-a7c0-ca43f325840c', '1d12dc56-e857-5d2c-a2ab-d89c5c325d85', 'spouse');
  perform pg_temp.rel('f110cd83-3c6b-5876-a7c0-ca43f325840c', '07d33fc7-3eb4-5479-b0df-a1edf2619da7', 'parent');
  perform pg_temp.rel('1d12dc56-e857-5d2c-a2ab-d89c5c325d85', '07d33fc7-3eb4-5479-b0df-a1edf2619da7', 'parent');
  perform pg_temp.rel('f110cd83-3c6b-5876-a7c0-ca43f325840c', 'a82bed61-7d43-5ec4-a576-bbe12aa7fa93', 'parent');
  perform pg_temp.rel('1d12dc56-e857-5d2c-a2ab-d89c5c325d85', 'a82bed61-7d43-5ec4-a576-bbe12aa7fa93', 'parent');
  perform pg_temp.rel('07d33fc7-3eb4-5479-b0df-a1edf2619da7', '473d1033-81e4-5174-9e01-12cfebc276e3', 'spouse');
  perform pg_temp.rel('07d33fc7-3eb4-5479-b0df-a1edf2619da7', '22f423cd-89ba-5255-9d98-37a1c8956efd', 'parent');
  perform pg_temp.rel('473d1033-81e4-5174-9e01-12cfebc276e3', '22f423cd-89ba-5255-9d98-37a1c8956efd', 'parent');
  perform pg_temp.rel('07d33fc7-3eb4-5479-b0df-a1edf2619da7', '5caa0f9c-5e16-5e32-a071-2526f2dec9fd', 'parent');
  perform pg_temp.rel('473d1033-81e4-5174-9e01-12cfebc276e3', '5caa0f9c-5e16-5e32-a071-2526f2dec9fd', 'parent');
  perform pg_temp.rel('07d33fc7-3eb4-5479-b0df-a1edf2619da7', '82197180-d29c-5b7f-9595-0c1b74f0aef6', 'parent');
  perform pg_temp.rel('473d1033-81e4-5174-9e01-12cfebc276e3', '82197180-d29c-5b7f-9595-0c1b74f0aef6', 'parent');
  perform pg_temp.rel('a82bed61-7d43-5ec4-a576-bbe12aa7fa93', 'bbf70094-e263-5337-968f-a3fae7835bd4', 'parent');
  perform pg_temp.rel('82197180-d29c-5b7f-9595-0c1b74f0aef6', '35efa46f-84ba-54ee-bd24-916f7ad2ba55', 'parent');
  perform pg_temp.rel('22f423cd-89ba-5255-9d98-37a1c8956efd', '64ae5624-7b99-5426-a103-e2d1aac61d65', 'spouse');
  perform pg_temp.rel('22f423cd-89ba-5255-9d98-37a1c8956efd', '5f0e9877-fa0a-5ff6-b50c-19eab2fded6a', 'parent');
  perform pg_temp.rel('64ae5624-7b99-5426-a103-e2d1aac61d65', '5f0e9877-fa0a-5ff6-b50c-19eab2fded6a', 'parent');
  perform pg_temp.rel('5f0e9877-fa0a-5ff6-b50c-19eab2fded6a', 'ee400799-a106-5fc8-adad-0a556e0807d8', 'spouse');
  perform pg_temp.rel('5f0e9877-fa0a-5ff6-b50c-19eab2fded6a', '401b55d7-2a9c-44f3-991e-f677a497b2db', 'parent');
  perform pg_temp.rel('ee400799-a106-5fc8-adad-0a556e0807d8', '401b55d7-2a9c-44f3-991e-f677a497b2db', 'parent');
  perform pg_temp.rel('5f0e9877-fa0a-5ff6-b50c-19eab2fded6a', '2f14d3ea-6f2f-52e1-a38f-44d63b72de76', 'parent');
  perform pg_temp.rel('13608e16-4ad6-4106-acf6-010fb43d4555', '60980970-8d53-5628-b0dd-7baadfa1e7e7', 'parent');
  perform pg_temp.rel('2f14d3ea-6f2f-52e1-a38f-44d63b72de76', '60980970-8d53-5628-b0dd-7baadfa1e7e7', 'spouse');
  perform pg_temp.rel('92299032-2e3c-552e-83f2-ec10f8094385', '84f2ab55-9f1e-59cf-9b68-1bb7ac20c27f', 'parent');
  perform pg_temp.rel('84f2ab55-9f1e-59cf-9b68-1bb7ac20c27f', '57f560f5-8ba8-5d1e-abd2-7ffcd3721259', 'parent');
  perform pg_temp.rel('57f560f5-8ba8-5d1e-abd2-7ffcd3721259', '387d26db-cc1c-5e89-91f4-d53946159d36', 'spouse');
  perform pg_temp.rel('57f560f5-8ba8-5d1e-abd2-7ffcd3721259', 'be0c6999-1699-5080-8530-c74129fc3684', 'parent');
  perform pg_temp.rel('387d26db-cc1c-5e89-91f4-d53946159d36', 'be0c6999-1699-5080-8530-c74129fc3684', 'parent');
  perform pg_temp.rel('be0c6999-1699-5080-8530-c74129fc3684', '3cbb56f4-c550-5ab8-acfe-3fd06489b0c5', 'spouse');
  perform pg_temp.rel('be0c6999-1699-5080-8530-c74129fc3684', '38414dbd-38b9-56b3-a1e6-5a7f32927af4', 'parent');
  perform pg_temp.rel('3cbb56f4-c550-5ab8-acfe-3fd06489b0c5', '38414dbd-38b9-56b3-a1e6-5a7f32927af4', 'parent');
  perform pg_temp.rel('38414dbd-38b9-56b3-a1e6-5a7f32927af4', '8974197c-5642-5687-9532-cd5838830e02', 'spouse');
  perform pg_temp.rel('38414dbd-38b9-56b3-a1e6-5a7f32927af4', '98562bc3-d046-5922-b744-acd374c2056b', 'parent');
  perform pg_temp.rel('8974197c-5642-5687-9532-cd5838830e02', '98562bc3-d046-5922-b744-acd374c2056b', 'parent');
  perform pg_temp.rel('38414dbd-38b9-56b3-a1e6-5a7f32927af4', '061bcb61-8db7-5caf-be4c-cda052d67e1d', 'parent');
  perform pg_temp.rel('8974197c-5642-5687-9532-cd5838830e02', '061bcb61-8db7-5caf-be4c-cda052d67e1d', 'parent');
  perform pg_temp.rel('38414dbd-38b9-56b3-a1e6-5a7f32927af4', '3263323d-5323-56ec-8009-9252393b9031', 'parent');
  perform pg_temp.rel('8974197c-5642-5687-9532-cd5838830e02', '3263323d-5323-56ec-8009-9252393b9031', 'parent');
  perform pg_temp.rel('98562bc3-d046-5922-b744-acd374c2056b', 'b5893e2e-7ed2-4ac8-a900-a22c0e50fdf6', 'spouse');
  perform pg_temp.rel('98562bc3-d046-5922-b744-acd374c2056b', '8cfd9ecd-4064-5fe0-be57-f2b12094b2cd', 'spouse');
  perform pg_temp.rel('98562bc3-d046-5922-b744-acd374c2056b', '2b61583b-5e1e-456a-90b9-0758f126db75', 'parent');
  perform pg_temp.rel('b5893e2e-7ed2-4ac8-a900-a22c0e50fdf6', '2b61583b-5e1e-456a-90b9-0758f126db75', 'parent');
  perform pg_temp.rel('98562bc3-d046-5922-b744-acd374c2056b', '376de58a-617f-5d5a-98cc-79695efc3ede', 'parent');
  perform pg_temp.rel('b5893e2e-7ed2-4ac8-a900-a22c0e50fdf6', '376de58a-617f-5d5a-98cc-79695efc3ede', 'parent');
  perform pg_temp.rel('061bcb61-8db7-5caf-be4c-cda052d67e1d', 'b68e21d4-1f1f-54a6-816a-c0bc17451299', 'spouse');
  perform pg_temp.rel('061bcb61-8db7-5caf-be4c-cda052d67e1d', '507c3d51-bc0e-5fd3-98f4-d80f2a501503', 'parent');
  perform pg_temp.rel('b68e21d4-1f1f-54a6-816a-c0bc17451299', '507c3d51-bc0e-5fd3-98f4-d80f2a501503', 'parent');
  perform pg_temp.rel('323fddf6-5fa4-4338-9720-04c03f0e9f77', '9d06c682-eab3-5cac-81f3-0233c71b71e1', 'parent');
  perform pg_temp.rel('507c3d51-bc0e-5fd3-98f4-d80f2a501503', '9d06c682-eab3-5cac-81f3-0233c71b71e1', 'spouse');
  perform pg_temp.rel('507c3d51-bc0e-5fd3-98f4-d80f2a501503', '02d920d4-bab9-5ae6-852e-cb65b82bde80', 'parent');
  perform pg_temp.rel('9d06c682-eab3-5cac-81f3-0233c71b71e1', '02d920d4-bab9-5ae6-852e-cb65b82bde80', 'parent');
  perform pg_temp.rel('02d920d4-bab9-5ae6-852e-cb65b82bde80', '34cf979b-f42a-5f06-901b-ec4f7db09108', 'spouse');
  perform pg_temp.rel('02d920d4-bab9-5ae6-852e-cb65b82bde80', '29b7c014-3fb2-5182-bbda-39ad4a34de24', 'parent');
  perform pg_temp.rel('34cf979b-f42a-5f06-901b-ec4f7db09108', '29b7c014-3fb2-5182-bbda-39ad4a34de24', 'parent');
  perform pg_temp.rel('52ed7330-a403-52ca-8a58-11695b9eee87', '895a4460-54b6-53fe-a2ba-0d52fb3d63f2', 'parent');
  perform pg_temp.rel('f2292393-d302-558a-80e5-bdee83f0df1f', '895a4460-54b6-53fe-a2ba-0d52fb3d63f2', 'parent');
  perform pg_temp.rel('52ed7330-a403-52ca-8a58-11695b9eee87', 'f2292393-d302-558a-80e5-bdee83f0df1f', 'spouse');
  perform pg_temp.rel('29b7c014-3fb2-5182-bbda-39ad4a34de24', '895a4460-54b6-53fe-a2ba-0d52fb3d63f2', 'spouse');
  perform pg_temp.rel('29b7c014-3fb2-5182-bbda-39ad4a34de24', '78598cea-314f-520a-a1ad-ae3ded159e85', 'parent');
  perform pg_temp.rel('895a4460-54b6-53fe-a2ba-0d52fb3d63f2', '78598cea-314f-520a-a1ad-ae3ded159e85', 'parent');
  perform pg_temp.rel('29b7c014-3fb2-5182-bbda-39ad4a34de24', '6fe70583-e9b4-5bcd-81d2-7fc22ad59c12', 'parent');
  perform pg_temp.rel('895a4460-54b6-53fe-a2ba-0d52fb3d63f2', '6fe70583-e9b4-5bcd-81d2-7fc22ad59c12', 'parent');
  perform pg_temp.rel('29b7c014-3fb2-5182-bbda-39ad4a34de24', 'd8a54c67-b656-552c-9589-601a14cdccb9', 'parent');
  perform pg_temp.rel('895a4460-54b6-53fe-a2ba-0d52fb3d63f2', 'd8a54c67-b656-552c-9589-601a14cdccb9', 'parent');
  perform pg_temp.rel('32b5e90e-4358-5a9f-b97a-dda04286d882', '6fe70583-e9b4-5bcd-81d2-7fc22ad59c12', 'spouse');
  perform pg_temp.rel('d8a54c67-b656-552c-9589-601a14cdccb9', '008ef7cc-1350-5c86-93c1-5ed1011345cf', 'spouse');
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('401b55d7-2a9c-44f3-991e-f677a497b2db', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 1095, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('60980970-8d53-5628-b0dd-7baadfa1e7e7', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 105, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('b5893e2e-7ed2-4ac8-a900-a22c0e50fdf6', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 1595, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('2b61583b-5e1e-456a-90b9-0758f126db75', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 2213, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('9d06c682-eab3-5cac-81f3-0233c71b71e1', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 3348, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('895a4460-54b6-53fe-a2ba-0d52fb3d63f2', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 3838, 5760, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('32b5e90e-4358-5a9f-b97a-dda04286d882', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 2604, 6400, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v79 : % membres ajoutés.', 45;
end $$;
