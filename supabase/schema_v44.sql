-- schema_v44.sql — Roumanie — Basarab, Mușat, Hohenzollern-Sigmaringen
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Crée sous Roumanie > Dynastie : Basarab (Valachie), Mușat (Moldavie), Hohenzollern-Sigmaringen (royaume de Roumanie).
-- Prudence : les généalogies médiévales valaques et moldaves sont lacunaires dans Wikipédia ; seuls les liens attestés par les fiches des personnes sont créés ; beaucoup de naissances sont donc laissées vides (signalées dans le rapport).
-- Pas inclus : voïvodes valaques/moldaves sans filiation claire, Cuza (prince élu, pas de dynastie), Michel le Brave (rattachement aux Basarab discuté).
-- Hohenzollern-Sigmaringen : Karl Anton, Josephine de Bade, Léopold et Antonia de Portugal sont créés dans l'arbre Hohenzollern d'Allemagne (branche de Sigmaringen) ; Carol Ier apparaît dans les deux.
-- Marie de Saxe-Cobourg (Édimbourg) est reliée à Alfred et Maria Alexandrovna (créés par v38 ; si v38 n'a pas été exécuté ces liens sont ignorés avec un avertissement).
-- Hélène de Grèce, Élisabeth et Marie de Roumanie (reines de Grèce et de Yougoslavie) : créées ici, à rattacher aux arbres grec/serbe ensuite.
-- Prérequis : v43 exécuté.
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
  if exists (select 1 from public.genealogy_members where id = 'ba471bbc-8c8f-57bb-aa0c-be76147406f7') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('e53ccc75-fde3-532e-b0ef-5fc82bece33d');
  if k <> 1 then raise exception 'Membres préexistants manquants (% sur 1) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Basarab » (ROU)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ROU' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ROU : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Basarab';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('360137a2-fa02-5230-803d-ea2d62f2ee01', cat_id, 'country', 'ROU', top, 'Basarab', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '360137a2-fa02-5230-803d-ea2d62f2ee01';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'country', 'ROU', 'genealogy', 'Basarab', cat_id, sec, admin_id);
  -- Arbre « Mușat » (ROU)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ROU' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ROU : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Mușat';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('ecee6208-65e1-588d-a4d2-188186a4e1a1', cat_id, 'country', 'ROU', top, 'Mușat', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'ecee6208-65e1-588d-a4d2-188186a4e1a1';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('ac205bba-4d25-525f-9b10-aec373f48fbe', 'country', 'ROU', 'genealogy', 'Mușat', cat_id, sec, admin_id);
  -- Arbre « Hohenzollern-Sigmaringen » (ROU)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ROU' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ROU : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Hohenzollern-Sigmaringen';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('6832397d-dd86-521a-afa0-03ac9b37bc8d', cat_id, 'country', 'ROU', top, 'Hohenzollern-Sigmaringen', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '6832397d-dd86-521a-afa0-03ac9b37bc8d';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('546787ec-199c-5714-a8dd-efc170a09a62', 'country', 'ROU', 'genealogy', 'Hohenzollern-Sigmaringen', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = '39895573-27f3-4112-905b-c9ba7e3c95a1' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Hohenzollern introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '84c9f117-4375-499a-8634-b87e7515ec6a' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison de Bourbon-Parme introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ba471bbc-8c8f-57bb-aa0c-be76147406f7', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Radu Ier de Valachie', null, null, 1383, 'Voïvode de Valachie (v. 1377-1383)', 'Basarab', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('db120f8a-ba57-5565-9a08-9253a235f169', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Calinichia (épouse de Radu Ier)', null, null, null, 'Doamna de Valachie', 'Origine incertaine', 540, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('88288e5a-9f96-5e36-b128-9adb1fde0dd8', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Mircea Ier l''Ancien', null, 1355, 1418, 'Voïvode de Valachie (1386-1418)', 'Basarab', 270, 460, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('684a5f1a-f6cd-5a99-a8a0-b82fae54e21e', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Alexandre Ier Aldea', null, null, 1436, 'Voïvode de Valachie (1431-1436)', 'Basarab', 65, 1125, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e97e750b-3665-59c8-96c2-01c14b4761e7', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Vlad II Dracul', null, 1395, 1447, 'Voïvode de Valachie (1436-1442, 1443-1447)', 'Basarab', 475, 1125, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('162c799a-80e8-5dab-a6d5-e482a58977a8', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Eupraxie (Cneajna) de Moldavie', null, null, null, 'Épouse de Vlad II Dracul', 'Mușat', 795, 585, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1c53c87c-cdf3-5733-9662-20f02239de04', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Mircea II', null, 1428, 1446, 'Voïvode de Valachie (1442, 1443)', 'Basarab', 229, 1850, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('80222dc6-5a10-5d3f-9661-9e27ee9e711f', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Vlad III l''Empaleur (Dracula)', null, 1431, 1476, 'Voïvode de Valachie (1448, 1456-1462, 1476)', 'Basarab', 639, 1850, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1d2635ef-f680-51d8-bee2-a2f3329c26dc', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Radu III le Beau', null, 1437, 1475, 'Voïvode de Valachie (1462-1473, 1474-1475)', 'Basarab', 1049, 1850, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d0088211-27f9-5a4b-9e93-77c2d0e5c344', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Vlad IV le Moine', null, null, 1496, 'Voïvode de Valachie (1481-1495)', 'Basarab', 1459, 1850, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4cd91562-2f8b-540e-bf61-eb67bad04d2b', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Mihnea le Mauvais', null, 1462, 1510, 'Voïvode de Valachie (1508-1509)', 'Basarab', 639, 2376, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aa27450e-6ea6-50e3-b5c9-f0f364a02d3d', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Alexandre Ier le Bon', null, 1375, 1432, 'Voïvode de Moldavie (1400-1432)', 'Mușat', 1615, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8142f915-840c-556a-a308-0a1f68912e0a', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Iliaș Ier', null, null, 1448, 'Voïvode de Moldavie (1432-1442, 1435-1443)', 'Mușat', 1615, 585, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fca81424-b436-575c-ba7e-41fd1471c76a', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Étienne II de Moldavie', null, null, 1447, 'Voïvode de Moldavie (1434-1447)', 'Mușat', 1205, 585, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8625ae96-91b7-5e6c-af76-d0a6cbea3c8a', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Bogdan II', null, null, 1451, 'Voïvode de Moldavie (1449-1451)', 'Mușat', 2435, 585, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b75b56d0-b0a8-5eb8-bf3d-dd942c7fe032', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Petru Aron', null, null, 1470, 'Voïvode de Moldavie (1451-1457)', 'Mușat', 2025, 585, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8867d4ac-6ca2-5fcb-a1f3-98eda7949e0b', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Maria Oltea', null, null, null, 'Mère d''Étienne le Grand', 'Origine inconnue', 2975, 585, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3392d875-081c-58b8-a41f-8d5fcfb954bb', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Étienne III le Grand', null, null, 1504, 'Voïvode de Moldavie (1457-1504)', 'Mușat', 2705, 1080, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c7351f07-06c3-552b-990c-20c1b2b47015', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Maria Voichița', null, null, 1511, 'Voïvodesse de Moldavie', 'Valachie (Basarab ?)', 3171, 1080, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('84b30b74-76b3-57e1-9da6-7e76b499b4a7', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Bogdan III l''Aveugle', null, 1479, 1517, 'Voïvode de Moldavie (1504-1517)', 'Mușat', 2733, 1908, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b38eba3b-0a28-5c97-bc2d-61b5fa70f0a7', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Petru Rareș', null, 1483, 1546, 'Voïvode de Moldavie (1527-1538, 1541-1546)', 'Mușat', 3143, 1908, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4df951d7-c982-5f06-985b-6cf53163daeb', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Jelena Branković', null, 1502, 1552, 'Voïvodesse de Moldavie', 'Branković (Serbie)', 3597, 1908, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1131d8dd-702b-59b8-8c16-eadee3eff6e0', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Ilie II Rareș', null, 1531, 1561, 'Voïvode de Moldavie (1546-1551)', 'Mușat', 3165, 2817, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1a1a6633-2b10-507a-824d-791688465d10', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 'Étienne VI Rareș', null, 1532, 1552, 'Voïvode de Moldavie (1551-1552)', 'Mușat', 3575, 2817, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a229b45f-df5d-5a4f-a508-3c811765f21d', 'entry', '39895573-27f3-4112-905b-c9ba7e3c95a1', 'Charles-Antoine de Hohenzollern-Sigmaringen', null, 1811, 1885, 'Prince de Hohenzollern-Sigmaringen, ministre-président de Prusse', 'Hohenzollern-Sigmaringen', 54000, 14598, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('05120133-bcce-520c-b6c7-d9296259ed6a', 'entry', '39895573-27f3-4112-905b-c9ba7e3c95a1', 'Joséphine de Bade', null, 1813, 1900, 'Princesse de Hohenzollern-Sigmaringen', 'Zähringen (Bade)', 54340, 14634, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ccf2b88a-f16d-51ce-8223-1d05ec300c81', 'entry', '39895573-27f3-4112-905b-c9ba7e3c95a1', 'Léopold de Hohenzollern-Sigmaringen', null, 1835, 1905, 'Prince de Hohenzollern, candidat au trône d''Espagne (1870)', 'Hohenzollern-Sigmaringen', 54680, 15030, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7ad31217-24f3-59bc-ac26-03ee1137e825', 'entry', '39895573-27f3-4112-905b-c9ba7e3c95a1', 'Antónia de Portugal', null, 1845, 1913, 'Princesse de Hohenzollern-Sigmaringen', 'Bragance', 55020, 15210, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c824615b-5f16-581f-bb80-edf86f2c23e0', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Carol Ier', null, 1839, 1914, 'Prince (1866) puis premier roi de Roumanie (1881-1914)', 'Hohenzollern-Sigmaringen', 1388, 576, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f19e2275-fbd3-53ef-9d61-9476869ef9fd', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Élisabeth de Wied (Carmen Sylva)', null, 1843, 1916, 'Reine de Roumanie', 'Wied', 1768, 576, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6445dd56-a167-59c3-9a99-fb71ad5b5a90', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Ferdinand Ier de Roumanie', null, 1865, 1927, 'Roi de Roumanie (1914-1927)', 'Hohenzollern-Sigmaringen', 643, 1152, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6b1c17b8-aa8d-5d50-95ae-d1b9c22b58dd', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Marie d''Édimbourg (reine de Roumanie)', null, 1875, 1938, 'Reine de Roumanie', 'Saxe-Cobourg et Gotha / Windsor', 1888, 1152, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e648f724-c76b-580e-8402-9c658c8ec170', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Carol II', null, 1893, 1953, 'Roi de Roumanie (1930-1940)', 'Hohenzollern-Sigmaringen', 380, 1612, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('262b541c-9e0d-53fc-bdde-e004d1bb63c5', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Zizi Lambrino', null, 1898, 1953, 'Première épouse de Carol II (mariage annulé en 1919)', 'Lambrino (noblesse roumaine)', 760, 1612, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8d90a20a-8beb-54e3-aeef-a9a29051eb38', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Hélène de Grèce et de Danemark', null, 1896, 1982, 'Reine-mère de Roumanie', 'Glücksbourg (Grèce)', 1140, 1612, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a2319cd3-65dc-544b-9754-30ec1bb66072', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Magda Lupescu', null, 1895, 1977, 'Troisième épouse de Carol II (1947)', 'Lupescu (Roumanie)', 0, 1612, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('539441be-08d0-517e-862d-211a0d88899f', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Michel Ier de Roumanie', null, 1921, 2017, 'Roi de Roumanie (1927-1930, 1940-1947)', 'Hohenzollern-Sigmaringen', 650, 2072, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ed2847e5-4b58-5b32-ba4c-9d54126db0eb', 'entry', '84c9f117-4375-499a-8634-b87e7515ec6a', 'Anne de Bourbon-Parme', null, 1923, 2016, 'Reine de Roumanie (épouse de Michel Ier)', 'Bourbon-Parme', 54000, 16614, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a127df16-05d2-5e5d-8e14-e94f846df830', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Marguerite de Roumanie', null, 1949, null, 'Gardienne de la Couronne roumaine', 'Hohenzollern-Sigmaringen', 920, 2532, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3ad23bf0-9d3f-535e-8681-ba0177ebdba4', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Élisabeth de Roumanie (reine de Grèce)', null, 1894, 1956, 'Reine de Grèce', 'Hohenzollern-Sigmaringen', 1520, 1612, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('409659a4-633b-5ae1-ad17-c5e3b092e3b9', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Marie de Roumanie (Mignon, reine de Yougoslavie)', null, 1900, 1961, 'Reine de Yougoslavie', 'Hohenzollern-Sigmaringen', 1900, 1612, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d743954d-a28d-54c9-bf71-9d6f87fdacda', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 'Nicolas de Roumanie', null, 1903, 1978, 'Prince, régent (1927-1930)', 'Hohenzollern-Sigmaringen', 2280, 1612, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('28ec5941-c762-55eb-9a3e-9707bec8f6bb', 'entry', '84c9f117-4375-499a-8634-b87e7515ec6a', 'Robert Ier de Parme', null, 1848, 1907, 'Dernier duc de Parme', 'Bourbon-Parme', 54340, 15264, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4d570f58-da0d-542e-a02f-ef68239f826c', 'entry', '84c9f117-4375-499a-8634-b87e7515ec6a', 'René de Bourbon-Parme', null, 1894, 1962, 'Prince de Bourbon-Parme, père d''Anne', 'Bourbon-Parme', 54680, 16092, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('ba471bbc-8c8f-57bb-aa0c-be76147406f7', '88288e5a-9f96-5e36-b128-9adb1fde0dd8', 'parent');
  perform pg_temp.rel('db120f8a-ba57-5565-9a08-9253a235f169', '88288e5a-9f96-5e36-b128-9adb1fde0dd8', 'parent');
  perform pg_temp.rel('ba471bbc-8c8f-57bb-aa0c-be76147406f7', 'db120f8a-ba57-5565-9a08-9253a235f169', 'spouse');
  perform pg_temp.rel('88288e5a-9f96-5e36-b128-9adb1fde0dd8', '684a5f1a-f6cd-5a99-a8a0-b82fae54e21e', 'parent');
  perform pg_temp.rel('88288e5a-9f96-5e36-b128-9adb1fde0dd8', 'e97e750b-3665-59c8-96c2-01c14b4761e7', 'parent');
  perform pg_temp.rel('e97e750b-3665-59c8-96c2-01c14b4761e7', '162c799a-80e8-5dab-a6d5-e482a58977a8', 'spouse');
  perform pg_temp.rel('e97e750b-3665-59c8-96c2-01c14b4761e7', '1c53c87c-cdf3-5733-9662-20f02239de04', 'parent');
  perform pg_temp.rel('162c799a-80e8-5dab-a6d5-e482a58977a8', '1c53c87c-cdf3-5733-9662-20f02239de04', 'parent');
  perform pg_temp.rel('e97e750b-3665-59c8-96c2-01c14b4761e7', '80222dc6-5a10-5d3f-9661-9e27ee9e711f', 'parent');
  perform pg_temp.rel('162c799a-80e8-5dab-a6d5-e482a58977a8', '80222dc6-5a10-5d3f-9661-9e27ee9e711f', 'parent');
  perform pg_temp.rel('e97e750b-3665-59c8-96c2-01c14b4761e7', '1d2635ef-f680-51d8-bee2-a2f3329c26dc', 'parent');
  perform pg_temp.rel('162c799a-80e8-5dab-a6d5-e482a58977a8', '1d2635ef-f680-51d8-bee2-a2f3329c26dc', 'parent');
  perform pg_temp.rel('e97e750b-3665-59c8-96c2-01c14b4761e7', 'd0088211-27f9-5a4b-9e93-77c2d0e5c344', 'parent');
  perform pg_temp.rel('80222dc6-5a10-5d3f-9661-9e27ee9e711f', '4cd91562-2f8b-540e-bf61-eb67bad04d2b', 'parent');
  perform pg_temp.rel('aa27450e-6ea6-50e3-b5c9-f0f364a02d3d', '8142f915-840c-556a-a308-0a1f68912e0a', 'parent');
  perform pg_temp.rel('aa27450e-6ea6-50e3-b5c9-f0f364a02d3d', 'fca81424-b436-575c-ba7e-41fd1471c76a', 'parent');
  perform pg_temp.rel('aa27450e-6ea6-50e3-b5c9-f0f364a02d3d', '8625ae96-91b7-5e6c-af76-d0a6cbea3c8a', 'parent');
  perform pg_temp.rel('aa27450e-6ea6-50e3-b5c9-f0f364a02d3d', 'b75b56d0-b0a8-5eb8-bf3d-dd942c7fe032', 'parent');
  perform pg_temp.rel('aa27450e-6ea6-50e3-b5c9-f0f364a02d3d', '162c799a-80e8-5dab-a6d5-e482a58977a8', 'parent');
  perform pg_temp.rel('8625ae96-91b7-5e6c-af76-d0a6cbea3c8a', '3392d875-081c-58b8-a41f-8d5fcfb954bb', 'parent');
  perform pg_temp.rel('8867d4ac-6ca2-5fcb-a1f3-98eda7949e0b', '3392d875-081c-58b8-a41f-8d5fcfb954bb', 'parent');
  perform pg_temp.rel('8625ae96-91b7-5e6c-af76-d0a6cbea3c8a', '8867d4ac-6ca2-5fcb-a1f3-98eda7949e0b', 'spouse');
  perform pg_temp.rel('3392d875-081c-58b8-a41f-8d5fcfb954bb', 'c7351f07-06c3-552b-990c-20c1b2b47015', 'spouse');
  perform pg_temp.rel('3392d875-081c-58b8-a41f-8d5fcfb954bb', '84b30b74-76b3-57e1-9da6-7e76b499b4a7', 'parent');
  perform pg_temp.rel('c7351f07-06c3-552b-990c-20c1b2b47015', '84b30b74-76b3-57e1-9da6-7e76b499b4a7', 'parent');
  perform pg_temp.rel('3392d875-081c-58b8-a41f-8d5fcfb954bb', 'b38eba3b-0a28-5c97-bc2d-61b5fa70f0a7', 'parent');
  perform pg_temp.rel('b38eba3b-0a28-5c97-bc2d-61b5fa70f0a7', '4df951d7-c982-5f06-985b-6cf53163daeb', 'spouse');
  perform pg_temp.rel('b38eba3b-0a28-5c97-bc2d-61b5fa70f0a7', '1131d8dd-702b-59b8-8c16-eadee3eff6e0', 'parent');
  perform pg_temp.rel('4df951d7-c982-5f06-985b-6cf53163daeb', '1131d8dd-702b-59b8-8c16-eadee3eff6e0', 'parent');
  perform pg_temp.rel('b38eba3b-0a28-5c97-bc2d-61b5fa70f0a7', '1a1a6633-2b10-507a-824d-791688465d10', 'parent');
  perform pg_temp.rel('4df951d7-c982-5f06-985b-6cf53163daeb', '1a1a6633-2b10-507a-824d-791688465d10', 'parent');
  perform pg_temp.rel('a229b45f-df5d-5a4f-a508-3c811765f21d', '05120133-bcce-520c-b6c7-d9296259ed6a', 'spouse');
  perform pg_temp.rel('a229b45f-df5d-5a4f-a508-3c811765f21d', 'ccf2b88a-f16d-51ce-8223-1d05ec300c81', 'parent');
  perform pg_temp.rel('05120133-bcce-520c-b6c7-d9296259ed6a', 'ccf2b88a-f16d-51ce-8223-1d05ec300c81', 'parent');
  perform pg_temp.rel('a229b45f-df5d-5a4f-a508-3c811765f21d', 'c824615b-5f16-581f-bb80-edf86f2c23e0', 'parent');
  perform pg_temp.rel('05120133-bcce-520c-b6c7-d9296259ed6a', 'c824615b-5f16-581f-bb80-edf86f2c23e0', 'parent');
  perform pg_temp.rel('ccf2b88a-f16d-51ce-8223-1d05ec300c81', '7ad31217-24f3-59bc-ac26-03ee1137e825', 'spouse');
  perform pg_temp.rel('ccf2b88a-f16d-51ce-8223-1d05ec300c81', '6445dd56-a167-59c3-9a99-fb71ad5b5a90', 'parent');
  perform pg_temp.rel('7ad31217-24f3-59bc-ac26-03ee1137e825', '6445dd56-a167-59c3-9a99-fb71ad5b5a90', 'parent');
  perform pg_temp.rel('c824615b-5f16-581f-bb80-edf86f2c23e0', 'f19e2275-fbd3-53ef-9d61-9476869ef9fd', 'spouse');
  perform pg_temp.rel('6445dd56-a167-59c3-9a99-fb71ad5b5a90', '6b1c17b8-aa8d-5d50-95ae-d1b9c22b58dd', 'spouse');
  perform pg_temp.rel('6445dd56-a167-59c3-9a99-fb71ad5b5a90', 'e648f724-c76b-580e-8402-9c658c8ec170', 'parent');
  perform pg_temp.rel('6b1c17b8-aa8d-5d50-95ae-d1b9c22b58dd', 'e648f724-c76b-580e-8402-9c658c8ec170', 'parent');
  perform pg_temp.rel('6445dd56-a167-59c3-9a99-fb71ad5b5a90', '3ad23bf0-9d3f-535e-8681-ba0177ebdba4', 'parent');
  perform pg_temp.rel('6b1c17b8-aa8d-5d50-95ae-d1b9c22b58dd', '3ad23bf0-9d3f-535e-8681-ba0177ebdba4', 'parent');
  perform pg_temp.rel('6445dd56-a167-59c3-9a99-fb71ad5b5a90', '409659a4-633b-5ae1-ad17-c5e3b092e3b9', 'parent');
  perform pg_temp.rel('6b1c17b8-aa8d-5d50-95ae-d1b9c22b58dd', '409659a4-633b-5ae1-ad17-c5e3b092e3b9', 'parent');
  perform pg_temp.rel('6445dd56-a167-59c3-9a99-fb71ad5b5a90', 'd743954d-a28d-54c9-bf71-9d6f87fdacda', 'parent');
  perform pg_temp.rel('6b1c17b8-aa8d-5d50-95ae-d1b9c22b58dd', 'd743954d-a28d-54c9-bf71-9d6f87fdacda', 'parent');
  perform pg_temp.rel('e648f724-c76b-580e-8402-9c658c8ec170', '262b541c-9e0d-53fc-bdde-e004d1bb63c5', 'spouse');
  perform pg_temp.rel('e648f724-c76b-580e-8402-9c658c8ec170', '8d90a20a-8beb-54e3-aeef-a9a29051eb38', 'spouse');
  perform pg_temp.rel('e648f724-c76b-580e-8402-9c658c8ec170', 'a2319cd3-65dc-544b-9754-30ec1bb66072', 'spouse');
  perform pg_temp.rel('e648f724-c76b-580e-8402-9c658c8ec170', '539441be-08d0-517e-862d-211a0d88899f', 'parent');
  perform pg_temp.rel('8d90a20a-8beb-54e3-aeef-a9a29051eb38', '539441be-08d0-517e-862d-211a0d88899f', 'parent');
  perform pg_temp.rel('539441be-08d0-517e-862d-211a0d88899f', 'ed2847e5-4b58-5b32-ba4c-9d54126db0eb', 'spouse');
  perform pg_temp.rel('539441be-08d0-517e-862d-211a0d88899f', 'a127df16-05d2-5e5d-8e14-e94f846df830', 'parent');
  perform pg_temp.rel('ed2847e5-4b58-5b32-ba4c-9d54126db0eb', 'a127df16-05d2-5e5d-8e14-e94f846df830', 'parent');
  perform pg_temp.rel('28ec5941-c762-55eb-9a3e-9707bec8f6bb', 'e53ccc75-fde3-532e-b0ef-5fc82bece33d', 'parent');
  perform pg_temp.rel('4d570f58-da0d-542e-a02f-ef68239f826c', 'ed2847e5-4b58-5b32-ba4c-9d54126db0eb', 'parent');
  select id into ext from public.genealogy_members where name = 'Alfred de Saxe-Cobourg et Gotha' and birth_year = 1844 limit 1;
  if ext is not null then perform pg_temp.rel(ext, '6b1c17b8-aa8d-5d50-95ae-d1b9c22b58dd', 'parent'); else raise notice 'Membre introuvable (script précédent non exécuté ?) : Alfred de Saxe-Cobourg et Gotha'; end if;
  select id into ext from public.genealogy_members where name = 'Maria Alexandrovna de Russie' and birth_year = 1853 limit 1;
  if ext is not null then perform pg_temp.rel(ext, '6b1c17b8-aa8d-5d50-95ae-d1b9c22b58dd', 'parent'); else raise notice 'Membre introuvable (script précédent non exécuté ?) : Maria Alexandrovna de Russie'; end if;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('162c799a-80e8-5dab-a6d5-e482a58977a8', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 1212, 1125, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('e97e750b-3665-59c8-96c2-01c14b4761e7', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 25, 585, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('1c53c87c-cdf3-5733-9662-20f02239de04', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 0, 1045, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('80222dc6-5a10-5d3f-9661-9e27ee9e711f', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 410, 1045, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('1d2635ef-f680-51d8-bee2-a2f3329c26dc', 'entry', 'ac205bba-4d25-525f-9b10-aec373f48fbe', 820, 1045, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('a229b45f-df5d-5a4f-a508-3c811765f21d', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 1198, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('05120133-bcce-520c-b6c7-d9296259ed6a', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 1578, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ccf2b88a-f16d-51ce-8223-1d05ec300c81', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 453, 432, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('7ad31217-24f3-59bc-ac26-03ee1137e825', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 833, 432, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ed2847e5-4b58-5b32-ba4c-9d54126db0eb', 'entry', '546787ec-199c-5714-a8dd-efc170a09a62', 1190, 2072, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v44 : % membres ajoutés.', 44;
end $$;
