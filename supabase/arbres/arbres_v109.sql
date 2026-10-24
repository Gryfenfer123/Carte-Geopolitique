-- arbres_v109.sql — Géorgie (Bagrationi), Arménie, Israël (Hasmonéens et Hérodiens)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Trois nouveaux arbres : « Bagrationi » (Géorgie), « Dynasties d'Arménie » (Artaxiades et Bagratides), « Hasmonéens et Hérodiens » (Israël). Aucun n'existait.
-- Dates : connues par ailleurs, aucune page consultée pour ce lot. Années avant J.-C. en négatif ; naissances inconnues laissées vides, approximations signalées. Plusieurs dates antiques et médiévales sont incertaines dans les sources : à vérifier.
-- Arménie : version volontairement courte. Ashot III et ses fils, Abas Ier et le reste des Bagratides ne sont pas saisis. Gagik Ier est saisi sans parent (signalé).
-- Géorgie : Bagrat III est saisi sans parent (Gurgen). Les deux lignes (royaume uni médiéval, Kartli-Kakhétie) ne sont pas reliées entre elles.
-- Non fait : Azerbaïdjan, Séleucides, Nabatéens, Hérodiens secondaires, nombreux cadets.
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
  if exists (select 1 from public.genealogy_members where id = '9953d825-1e02-5b93-8c56-38b392f1be7f') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Bagrationi » (GEO)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'GEO' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour GEO : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Bagrationi';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('73c68ad3-0120-5d78-a97e-4bcff98dafd0', cat_id, 'country', 'GEO', top, 'Bagrationi', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '73c68ad3-0120-5d78-a97e-4bcff98dafd0';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('bb771463-2b67-55f0-b667-4e3c396b5f92', 'country', 'GEO', 'genealogy', 'Bagrationi', cat_id, sec, admin_id);
  -- Arbre « Dynasties d'Arménie » (ARM)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ARM' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ARM : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Dynasties d''Arménie';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('9da893f5-1229-531f-8663-3b160fd99f3d', cat_id, 'country', 'ARM', top, 'Dynasties d''Arménie', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '9da893f5-1229-531f-8663-3b160fd99f3d';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('92b655bf-a8c5-5fff-b39e-1cd52e4e5b2b', 'country', 'ARM', 'genealogy', 'Dynasties d''Arménie', cat_id, sec, admin_id);
  -- Arbre « Hasmonéens et Hérodiens » (ISR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ISR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ISR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Hasmonéens et Hérodiens';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('253f57b6-2b54-58bb-b127-5dde7f6b686e', cat_id, 'country', 'ISR', top, 'Hasmonéens et Hérodiens', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '253f57b6-2b54-58bb-b127-5dde7f6b686e';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'country', 'ISR', 'genealogy', 'Hasmonéens et Hérodiens', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9953d825-1e02-5b93-8c56-38b392f1be7f', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Bagrat III de Géorgie', null, 960, 1014, 'Premier roi de la Géorgie unifiée (1008-1014)', 'Bagrationi', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6954d8be-29ba-5e72-91fd-0dbdd9436015', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Georges Ier de Géorgie', null, 998, 1027, 'Roi de Géorgie (1014-1027)', 'Bagrationi', 250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('19af8664-dd90-5bd2-8c92-fc8e721f08e4', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Bagrat IV de Géorgie', null, 1018, 1072, 'Roi de Géorgie (1027-1072)', 'Bagrationi', 250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('64a9fa36-7a53-506d-abdf-b70b82b02474', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Georges II de Géorgie', null, 1042, 1112, 'Roi de Géorgie (1072-1089)', 'Bagrationi', 250, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('57c6d986-370a-542e-a63c-a623ad0c6754', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'David IV le Bâtisseur', null, 1073, 1125, 'Roi de Géorgie (1089-1125)', 'Bagrationi', 250, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d5d4a021-d458-55cf-907e-f30198bb5f18', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Dimitri Ier de Géorgie', null, 1093, 1156, 'Roi de Géorgie (1125-1156)', 'Bagrationi', 250, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d706aab3-cb89-5ce7-a9ac-f6e521d90866', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Georges III de Géorgie', null, 1133, 1184, 'Roi de Géorgie (1156-1184)', 'Bagrationi', 250, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a6588c4b-32a5-540e-8fad-a90474df5fdd', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Tamar de Géorgie', null, 1160, 1213, 'Reine de Géorgie (1184-1213), âge d''or', 'Bagrationi', 250, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3bb8a88a-b177-5b08-b976-f620b6ee373b', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Georges IV Lacha', null, 1192, 1223, 'Roi de Géorgie (1213-1223)', 'Bagrationi', 0, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('36e7b5f5-06b0-5b41-9175-86db1a8a360b', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Rousoudan de Géorgie', null, 1194, 1245, 'Reine de Géorgie (1223-1245)', 'Bagrationi', 500, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('eb834158-0274-521d-b930-c34fe4131fa5', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'David VII Oulou', null, 1215, 1270, 'Roi de Géorgie (1247-1270)', 'Bagrationi', 500, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e9bbf6db-f62a-5bbd-ae47-30a725b82dec', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Téïmouraz II de Kakhétie', null, 1700, 1762, 'Roi de Kakhétie puis de Kartli (1744-1762)', 'Bagrationi', 1500, 14080, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fb443005-e61c-554f-b2fb-5f626d57c17a', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Héraclius II de Géorgie', null, 1720, 1798, 'Roi de Kartli-Kakhétie (1762-1798)', 'Bagrationi', 1500, 14720, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9d04c41c-5b94-5396-9cb8-48450df3f4f0', 'entry', 'bb771463-2b67-55f0-b667-4e3c396b5f92', 'Georges XII de Géorgie', null, 1746, 1800, 'Dernier roi de Kartli-Kakhétie (1798-1800)', 'Bagrationi', 1500, 15360, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f0557681-c3f6-5729-944b-77d7fda1d7fb', 'entry', '92b655bf-a8c5-5fff-b39e-1cd52e4e5b2b', 'Tigrane II le Grand', null, -140, -55, 'Roi d''Arménie (-95 à -55)', 'Dynasties d''Arménie', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d4a10536-db03-578e-8f2a-cb0d5164a8a5', 'entry', '92b655bf-a8c5-5fff-b39e-1cd52e4e5b2b', 'Artavazde II d''Arménie', null, null, -31, 'Roi d''Arménie (-55 à -34)', 'Dynasties d''Arménie', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8cd43672-8090-50dd-aee8-b9aaa63590ac', 'entry', '92b655bf-a8c5-5fff-b39e-1cd52e4e5b2b', 'Ashot Ier d''Arménie', null, null, 890, 'Premier roi bagratide d''Arménie (884-890)', 'Dynasties d''Arménie', 0, 22400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ad17990f-4cff-51bc-a482-49292f5a1824', 'entry', '92b655bf-a8c5-5fff-b39e-1cd52e4e5b2b', 'Smbat Ier d''Arménie', null, null, 914, 'Roi d''Arménie (890-914)', 'Dynasties d''Arménie', 0, 23040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('07ed656c-2aa2-58eb-80e7-081d0cf49e06', 'entry', '92b655bf-a8c5-5fff-b39e-1cd52e4e5b2b', 'Ashot II d''Arménie', null, null, 929, 'Roi d''Arménie (914-928)', 'Dynasties d''Arménie', 0, 23680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('42faf9a5-72c2-5bb8-a389-6b6e790c2e9e', 'entry', '92b655bf-a8c5-5fff-b39e-1cd52e4e5b2b', 'Gagik Ier d''Arménie', null, null, 1020, 'Roi d''Arménie (989-1020)', 'Dynasties d''Arménie', 2000, 22400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d28a77f0-9109-546e-9cb7-4db677773ae2', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Mattathias', null, null, -166, 'Prêtre de Modiin, initiateur de la révolte des Maccabées', 'Hasmonéens et Hérodiens', 1373, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8ecc2e2a-20d6-59f5-8b12-d120865c10c4', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Judas Maccabée', null, -190, -160, 'Chef de la révolte des Maccabées', 'Hasmonéens et Hérodiens', 1108, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f796998a-1831-56f3-920f-fa9ae89f297d', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Simon Maccabée', null, null, -135, 'Grand prêtre et ethnarque (-142 à -135)', 'Hasmonéens et Hérodiens', 1608, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b1d62dcf-11c1-5cb5-ae3e-455308d752d4', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Jean Hyrcan Ier', null, -164, -104, 'Grand prêtre et ethnarque de Judée (-134 à -104)', 'Hasmonéens et Hérodiens', 1608, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6929441f-a2be-5a53-80e5-48e17776a559', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Aristobule Ier', null, null, -103, 'Roi de Judée (-104 à -103)', 'Hasmonéens et Hérodiens', 1668, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d85696be-86dd-52b0-881a-258f8a3c5b52', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Alexandre Jannée', null, -126, -76, 'Roi de Judée (-103 à -76)', 'Hasmonéens et Hérodiens', 1168, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('436989cb-0296-566c-8136-8810509b5634', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Alexandra Salomé', null, -139, -67, 'Reine de Judée (-76 à -67)', 'Hasmonéens et Hérodiens', 678, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a0a4e6dc-e464-593a-ada4-3e522180f90d', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Hyrcan II', null, -110, -30, 'Grand prêtre et ethnarque de Judée', 'Hasmonéens et Hérodiens', 212, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('405eb31c-5364-5927-92de-12be524ed4ee', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Aristobule II', null, -100, -49, 'Roi de Judée (-66 à -63)', 'Hasmonéens et Hérodiens', 1132, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f66a8fd0-fa6b-5d7e-8642-f2bca321684a', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Antigone Mattathias', null, null, -37, 'Dernier roi hasmonéen (-40 à -37)', 'Hasmonéens et Hérodiens', 1132, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('349159e8-02ac-58e0-8ab1-57f4144938b4', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Alexandra la Jeune', null, null, null, 'Fille d''Hyrcan II, mère de Mariamne', 'Hasmonéens et Hérodiens', 212, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('baf684e4-2528-55a2-8ee0-6743c83a3f55', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Mariamne l''Hasmonéenne', null, -54, -29, 'Épouse d''Hérode le Grand', 'Hasmonéens et Hérodiens', 212, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('65fdf014-2806-537e-ae6b-ae865371afd3', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Hérode le Grand', null, -73, -4, 'Roi de Judée (-37 à -4)', 'Hasmonéens et Hérodiens', 702, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2ce27639-e578-5574-a5c8-5d061988cb3b', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Aristobule IV', null, null, -6, 'Fils d''Hérode le Grand et de Mariamne', 'Hasmonéens et Hérodiens', 196, 4480, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b7e662eb-352e-5599-9e00-4280f718712b', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Hérode Antipas', null, -20, 39, 'Tétrarque de Galilée et de Pérée', 'Hasmonéens et Hérodiens', 696, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('450f329d-d7ae-57fb-bd1d-2b58cbf598a9', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Hérode Archélaüs', null, -23, 18, 'Ethnarque de Judée (-4 à 6)', 'Hasmonéens et Hérodiens', 1696, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('338264bc-566e-5606-8041-42419dc6099c', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Hérode Philippe II', null, -26, 34, 'Tétrarque d''Iturée et de Trachonitide', 'Hasmonéens et Hérodiens', 1196, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b3b7f90c-ab69-505c-8e13-41e37c78a77d', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Hérode Agrippa Ier', null, -10, 44, 'Roi de Judée (41-44)', 'Hasmonéens et Hérodiens', 196, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7c230fcf-84b3-5b25-aa69-6bd06d7c6b92', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Hérode Agrippa II', null, 27, 100, 'Roi de Chalcis puis de Batanée (50-92/100)', 'Hasmonéens et Hérodiens', 0, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b0f51325-78c1-5f0e-91d9-b09cb5de1489', 'entry', 'e87f2a65-4cfe-56f2-85b4-dbf67ee261e3', 'Bérénice (princesse hérodienne)', null, 28, null, 'Fille d''Agrippa Ier, compagne de Titus', 'Hasmonéens et Hérodiens', 500, 5760, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('9953d825-1e02-5b93-8c56-38b392f1be7f', '6954d8be-29ba-5e72-91fd-0dbdd9436015', 'parent');
  perform pg_temp.rel('6954d8be-29ba-5e72-91fd-0dbdd9436015', '19af8664-dd90-5bd2-8c92-fc8e721f08e4', 'parent');
  perform pg_temp.rel('19af8664-dd90-5bd2-8c92-fc8e721f08e4', '64a9fa36-7a53-506d-abdf-b70b82b02474', 'parent');
  perform pg_temp.rel('64a9fa36-7a53-506d-abdf-b70b82b02474', '57c6d986-370a-542e-a63c-a623ad0c6754', 'parent');
  perform pg_temp.rel('57c6d986-370a-542e-a63c-a623ad0c6754', 'd5d4a021-d458-55cf-907e-f30198bb5f18', 'parent');
  perform pg_temp.rel('d5d4a021-d458-55cf-907e-f30198bb5f18', 'd706aab3-cb89-5ce7-a9ac-f6e521d90866', 'parent');
  perform pg_temp.rel('d706aab3-cb89-5ce7-a9ac-f6e521d90866', 'a6588c4b-32a5-540e-8fad-a90474df5fdd', 'parent');
  perform pg_temp.rel('a6588c4b-32a5-540e-8fad-a90474df5fdd', '3bb8a88a-b177-5b08-b976-f620b6ee373b', 'parent');
  perform pg_temp.rel('a6588c4b-32a5-540e-8fad-a90474df5fdd', '36e7b5f5-06b0-5b41-9175-86db1a8a360b', 'parent');
  perform pg_temp.rel('36e7b5f5-06b0-5b41-9175-86db1a8a360b', 'eb834158-0274-521d-b930-c34fe4131fa5', 'parent');
  perform pg_temp.rel('e9bbf6db-f62a-5bbd-ae47-30a725b82dec', 'fb443005-e61c-554f-b2fb-5f626d57c17a', 'parent');
  perform pg_temp.rel('fb443005-e61c-554f-b2fb-5f626d57c17a', '9d04c41c-5b94-5396-9cb8-48450df3f4f0', 'parent');
  perform pg_temp.rel('f0557681-c3f6-5729-944b-77d7fda1d7fb', 'd4a10536-db03-578e-8f2a-cb0d5164a8a5', 'parent');
  perform pg_temp.rel('8cd43672-8090-50dd-aee8-b9aaa63590ac', 'ad17990f-4cff-51bc-a482-49292f5a1824', 'parent');
  perform pg_temp.rel('ad17990f-4cff-51bc-a482-49292f5a1824', '07ed656c-2aa2-58eb-80e7-081d0cf49e06', 'parent');
  perform pg_temp.rel('d28a77f0-9109-546e-9cb7-4db677773ae2', '8ecc2e2a-20d6-59f5-8b12-d120865c10c4', 'parent');
  perform pg_temp.rel('d28a77f0-9109-546e-9cb7-4db677773ae2', 'f796998a-1831-56f3-920f-fa9ae89f297d', 'parent');
  perform pg_temp.rel('f796998a-1831-56f3-920f-fa9ae89f297d', 'b1d62dcf-11c1-5cb5-ae3e-455308d752d4', 'parent');
  perform pg_temp.rel('b1d62dcf-11c1-5cb5-ae3e-455308d752d4', '6929441f-a2be-5a53-80e5-48e17776a559', 'parent');
  perform pg_temp.rel('b1d62dcf-11c1-5cb5-ae3e-455308d752d4', 'd85696be-86dd-52b0-881a-258f8a3c5b52', 'parent');
  perform pg_temp.rel('d85696be-86dd-52b0-881a-258f8a3c5b52', 'a0a4e6dc-e464-593a-ada4-3e522180f90d', 'parent');
  perform pg_temp.rel('d85696be-86dd-52b0-881a-258f8a3c5b52', '405eb31c-5364-5927-92de-12be524ed4ee', 'parent');
  perform pg_temp.rel('436989cb-0296-566c-8136-8810509b5634', 'a0a4e6dc-e464-593a-ada4-3e522180f90d', 'parent');
  perform pg_temp.rel('436989cb-0296-566c-8136-8810509b5634', '405eb31c-5364-5927-92de-12be524ed4ee', 'parent');
  perform pg_temp.rel('405eb31c-5364-5927-92de-12be524ed4ee', 'f66a8fd0-fa6b-5d7e-8642-f2bca321684a', 'parent');
  perform pg_temp.rel('a0a4e6dc-e464-593a-ada4-3e522180f90d', '349159e8-02ac-58e0-8ab1-57f4144938b4', 'parent');
  perform pg_temp.rel('349159e8-02ac-58e0-8ab1-57f4144938b4', 'baf684e4-2528-55a2-8ee0-6743c83a3f55', 'parent');
  perform pg_temp.rel('65fdf014-2806-537e-ae6b-ae865371afd3', '2ce27639-e578-5574-a5c8-5d061988cb3b', 'parent');
  perform pg_temp.rel('baf684e4-2528-55a2-8ee0-6743c83a3f55', '2ce27639-e578-5574-a5c8-5d061988cb3b', 'parent');
  perform pg_temp.rel('65fdf014-2806-537e-ae6b-ae865371afd3', 'b7e662eb-352e-5599-9e00-4280f718712b', 'parent');
  perform pg_temp.rel('65fdf014-2806-537e-ae6b-ae865371afd3', '450f329d-d7ae-57fb-bd1d-2b58cbf598a9', 'parent');
  perform pg_temp.rel('65fdf014-2806-537e-ae6b-ae865371afd3', '338264bc-566e-5606-8041-42419dc6099c', 'parent');
  perform pg_temp.rel('2ce27639-e578-5574-a5c8-5d061988cb3b', 'b3b7f90c-ab69-505c-8e13-41e37c78a77d', 'parent');
  perform pg_temp.rel('b3b7f90c-ab69-505c-8e13-41e37c78a77d', '7c230fcf-84b3-5b25-aa69-6bd06d7c6b92', 'parent');
  perform pg_temp.rel('b3b7f90c-ab69-505c-8e13-41e37c78a77d', 'b0f51325-78c1-5f0e-91d9-b09cb5de1489', 'parent');
  perform pg_temp.rel('d85696be-86dd-52b0-881a-258f8a3c5b52', '436989cb-0296-566c-8136-8810509b5634', 'spouse');
  perform pg_temp.rel('65fdf014-2806-537e-ae6b-ae865371afd3', 'baf684e4-2528-55a2-8ee0-6743c83a3f55', 'spouse');
  raise notice 'schema_v109 : % membres ajoutés.', 40;
end $$;
