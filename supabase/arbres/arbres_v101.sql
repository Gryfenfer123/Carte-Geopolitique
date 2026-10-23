-- arbres_v101.sql — Navarre — royaume de Navarre : Jiménez, Champagne, Capet, Évreux, Trastamare, Foix, Albret
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Royaume de Navarre » (aucun n'existait) : il suit la couronne à travers ses maisons successives. Sanche V, Pierre Ier, Alphonse Ier (Aragon), Jeanne Ire, Philippe IV, Louis X, Jean Ier, Philippe V, Charles IV (Capétiens), Jean II d'Aragon, Bérengère d'Angleterre, Jeanne d'Albret, Antoine de Bourbon et Henri III de Navarre (Henri IV) y sont affichés. Rien n'est supprimé.
-- Sources : pages Wikipédia en anglais (François Fébus, Catherine, Jean III, Henri II, Charles de Viane, Gaston IV, Philippe III d'Évreux, Charles III) pour dates et parents ; autres dates de connaissance générale.
-- Épouses créées dans l'arbre de leur maison puis affichées : Isabelle de France et Marguerite de Bourgogne (Capétiens), Jeanne de France (Valois), Éléonore de Castille (Castille), Madeleine de France (Valois), Marguerite d'Angoulême (Valois). Familles sans arbre (Champagne-Blois, Foix, Albret, Évreux avant la couronne) : placées ici et signalées.
-- García IV Ramírez : naissance laissée vide (incertaine) ; Ramire Sánchez de Monzón : naissance inconnue.
-- Non fait : branche des Foix-Béarn avant Gaston IV, enfants cadets de Gaston IV, descendance d'Alain d'Albret hors Jean III.
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
  if exists (select 1 from public.genealogy_members where id = '4ffdd30f-0201-5e0c-91c6-1ca1362d0ee7') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('14b4e7b7-2c0c-44ed-91d1-b48e96b5a947','2905cc98-f0a5-4282-a792-72cd27b69e1c','44a43b3a-58f2-406b-a9a6-50f6ad73b716','50d03330-9124-45c3-9e32-512d30975f07','5b5ddf13-e634-5d1e-bab3-a8f86c823403','5c72ec7d-85f3-4b97-b6d5-ed54fad8e0c7','6c7bbade-5c41-4303-b45d-f046dce9311e','6dbff916-ca5a-4206-a42b-e2b577aa4b46','6e723508-4ac3-4e12-bbc8-084d3460a1c5','74e6ef51-e06c-4fff-a032-67663a267317','773c19a5-93d1-4171-8660-466c9f464ef3','7ab44e3e-6f2f-4701-8b12-49b8fb585eaa','800e8f67-bcc1-48a3-8e37-c3882d1a151f','9269a040-a00f-482b-9ab0-0240dfd9ee48','97ad334e-c901-4205-9b42-730b2cf80f8a','aaf4eda5-3825-404e-95b2-342f31a9acd0','ab28690e-c022-4321-841c-4b1819c2a86b','ce21005e-1d38-437f-9ecd-8affb07a1ddc','d52e8bf8-4fa2-4ee0-b36e-2965767b22ef','d60fe239-e250-4224-9605-49bc5b685853','da46a1b7-640a-4afb-be70-afbf5f716fa5');
  if k <> 21 then raise exception 'Membres préexistants manquants (% sur 21) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Royaume de Navarre » (ESP)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ESP' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ESP : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Royaume de Navarre';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('97b8f339-ea18-55b0-8f50-c335fe0e30a1', cat_id, 'country', 'ESP', top, 'Royaume de Navarre', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '97b8f339-ea18-55b0-8f50-c335fe0e30a1';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'country', 'ESP', 'genealogy', 'Royaume de Navarre', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = '6f093aa5-08bc-4b10-ba1f-5755c2819d3d' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Capétiens introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = 'a92b4627-d9e5-4325-81ed-8b3dfebacf5b' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Valois introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '786a379d-20c7-446b-922a-af4beb086251' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre de Bourbon et Bourbon-Orléans introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '4b5cbfc8-fe56-4e78-8168-05445986c625' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison d''Ivrée introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '58a47142-d591-45c4-8be8-8945a9b4443d' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison d''Aragon introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '512e1a72-2193-4820-af1b-03fc1b75c1ee' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison de Trastamare introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4ffdd30f-0201-5e0c-91c6-1ca1362d0ee7', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'García Sánchez III le Trembleur', null, 1012, 1054, 'Roi de Navarre (1035-1054)', 'Maison Jiménez (Navarre)', 3241, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('30a6b45d-41ca-5350-883b-0595bee7062f', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Sanche IV de Peñalén', null, 1039, 1076, 'Roi de Navarre (1054-1076), assassiné', 'Maison Jiménez (Navarre)', 3241, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('40a576f3-3a8c-5ca8-b9e7-20d9ea65ddee', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Ramire Sánchez de Monzón', null, null, 1116, 'Seigneur de Monzón, petit-fils de García III', 'Maison Jiménez (Navarre)', 3241, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('167db292-180f-51b3-9d40-d6aa2bf04ac4', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'García IV Ramírez le Restaurateur', null, null, 1150, 'Roi de Navarre (1134-1150)', 'Maison Jiménez (Navarre)', 3241, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0232cd78-5dc7-5f49-b0ac-6ba14cefff8f', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Sanche VI le Sage', null, 1132, 1194, 'Roi de Navarre (1150-1194)', 'Maison Jiménez (Navarre)', 3241, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e30eb3db-9e0c-5e8e-b979-d24d56bbdefd', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Sanche VII le Fort', null, 1157, 1234, 'Roi de Navarre (1194-1234), dernier Jiménez', 'Maison Jiménez (Navarre)', 2741, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2fdd6595-3bc6-5a4a-9b70-c7c18ed40b65', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Blanche de Navarre (comtesse de Champagne)', null, 1177, 1229, 'Régente de Champagne, sœur de Sanche VII', 'Blois-Champagne (Navarre)', 3741, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a5ab3f06-163f-52aa-9658-82a7e85eb798', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Thibaut III de Champagne', null, 1179, 1201, 'Comte de Champagne, père de Thibaut Ier de Navarre', 'Blois-Champagne (Navarre)', 4231, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1b1c57b5-3f6d-52b5-98ea-59b0fa600640', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Thibaut Ier de Navarre (Thibaut IV de Champagne)', null, 1201, 1253, 'Roi de Navarre (1234-1253), trouvère', 'Blois-Champagne (Navarre)', 3986, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('301c4f2f-77e9-59fb-9805-a744ec2914b0', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Thibaut II de Navarre', null, 1238, 1270, 'Roi de Navarre (1253-1270)', 'Blois-Champagne (Navarre)', 3735, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7b294ba5-3dbe-5171-aff2-f4cabc57d599', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Henri Ier le Gros', null, 1244, 1274, 'Roi de Navarre (1270-1274)', 'Blois-Champagne (Navarre)', 4235, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bd0bae4a-1243-5471-bc3d-8f367355773c', 'entry', '6f093aa5-08bc-4b10-ba1f-5755c2819d3d', 'Isabelle de France (reine de Navarre)', null, 1242, 1271, 'Reine de Navarre, épouse de Thibaut II', 'Capétiens', 396000, 4356, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('78ca35e1-1487-5c31-aefb-f64809ce59da', 'entry', '6f093aa5-08bc-4b10-ba1f-5755c2819d3d', 'Blanche d''Artois', null, 1248, 1302, 'Reine de Navarre, épouse d''Henri Ier', 'Capétiens', 396340, 4464, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b68fcf36-62b4-58c1-b00a-62d328e6e130', 'entry', '6f093aa5-08bc-4b10-ba1f-5755c2819d3d', 'Marguerite de Bourgogne (reine de France et de Navarre)', null, 1290, 1315, 'Première épouse de Louis X, morte en prison', 'Capétiens', 396680, 5220, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cf59cae5-af1a-53ac-abf9-8c14c26b94d4', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Louis d''Évreux', null, 1276, 1319, 'Comte d''Évreux, père de Philippe III de Navarre', 'Évreux (Navarre)', 507, 5760, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('65dfcfea-9030-5f31-8332-31f0ee936705', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Philippe III d''Évreux', null, 1306, 1343, 'Roi de Navarre par mariage (1328-1343)', 'Évreux (Navarre)', 814, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bb9cb492-ebd3-5138-9217-5abf70d34e52', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Jeanne II de Navarre', null, 1312, 1349, 'Reine de Navarre (1328-1349)', 'Évreux (Navarre)', 1304, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1ae279f0-3665-5f00-acbe-d6c10b0193fa', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Charles II le Mauvais', null, 1332, 1387, 'Roi de Navarre (1349-1387)', 'Évreux (Navarre)', 1059, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c4279528-0edc-59eb-824b-845d16868fa5', 'entry', 'a92b4627-d9e5-4325-81ed-8b3dfebacf5b', 'Jeanne de France (reine de Navarre)', null, 1343, 1373, 'Reine de Navarre, épouse de Charles II', 'Valois', 396000, 6174, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8eda31ec-5b8d-5d1c-a37d-bdc129839624', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Charles III le Noble', null, 1361, 1425, 'Roi de Navarre (1387-1425)', 'Évreux (Navarre)', 1304, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f2467a25-edb2-5957-b3ce-e1592aab53d5', 'entry', '4b5cbfc8-fe56-4e78-8168-05445986c625', 'Éléonore de Castille (reine de Navarre)', null, 1363, 1415, 'Reine de Navarre, épouse de Charles III', 'Maison d''Ivrée', 396000, 6534, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('34017186-23f9-5a0b-92af-cfae71e4d7ac', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Blanche Ire de Navarre', null, 1385, 1441, 'Reine de Navarre (1425-1441)', 'Évreux (Navarre)', 1059, 8320, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('568969f8-1cb8-500c-a299-4188bec482d9', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Charles de Viane', null, 1421, 1461, 'Prince de Viane, héritier de Navarre', 'Trastamare (Navarre)', 0, 8960, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('61960a71-381f-5494-8f7b-f70be8f7ebd6', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Blanche II de Navarre', null, 1424, 1464, 'Héritière de Navarre, répudiée par Henri IV de Castille', 'Trastamare (Navarre)', 1490, 8960, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9b47c76f-548c-5fd2-a181-26830cd5c23d', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Éléonore Ire de Navarre', null, 1426, 1479, 'Reine de Navarre (1479), comtesse de Foix', 'Trastamare (Navarre)', 990, 8960, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fa89a476-8583-59f8-8af2-05c6f016a493', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Gaston IV de Foix', null, 1422, 1472, 'Comte de Foix, époux d''Éléonore', 'Foix (Navarre)', 500, 8960, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e8697ed5-63a3-5c25-8ff9-01e0b32b9252', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Gaston de Foix, prince de Viane', null, 1444, 1470, 'Père de François Fébus et de Catherine', 'Foix (Navarre)', 745, 9600, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4b6eefcb-4f82-560d-9ea3-ca99eab562da', 'entry', 'a92b4627-d9e5-4325-81ed-8b3dfebacf5b', 'Madeleine de France (princesse de Viane)', null, 1443, 1495, 'Régente de Navarre, fille de Charles VII', 'Valois', 396340, 7974, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8b827af1-62d9-5a26-82f5-3495be8becf2', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'François Fébus', null, 1467, 1483, 'Roi de Navarre (1479-1483)', 'Foix (Navarre)', 749, 10240, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2f8c274f-e405-5574-afdf-3fb3f70eeb56', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Catherine de Foix', null, 1468, 1517, 'Reine de Navarre (1483-1517)', 'Foix (Navarre)', 1250, 10240, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9a644975-d26a-5515-95a7-be702460d24e', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Alain Ier d''Albret', null, 1440, 1522, 'Sire d''Albret, père de Jean III', 'Albret (Navarre)', 1741, 8320, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ca7c0a13-2157-5f1b-ae4b-d9a6d8c57594', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Jean III d''Albret', null, 1469, 1516, 'Roi de Navarre par mariage (1484-1516)', 'Albret (Navarre)', 1740, 10240, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('24be18dd-185b-51c3-8bb2-51b18ba15ffa', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 'Henri II d''Albret', null, 1503, 1555, 'Roi de Navarre (1517-1555)', 'Albret (Navarre)', 1495, 10880, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('414d38be-a451-5e2e-a808-aa6897d355d0', 'entry', 'a92b4627-d9e5-4325-81ed-8b3dfebacf5b', 'Marguerite d''Angoulême (reine de Navarre)', null, 1492, 1549, 'Reine de Navarre, sœur de François Ier, écrivaine', 'Valois', 396680, 8856, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('6c7bbade-5c41-4303-b45d-f046dce9311e', '4ffdd30f-0201-5e0c-91c6-1ca1362d0ee7', 'parent');
  perform pg_temp.rel('4ffdd30f-0201-5e0c-91c6-1ca1362d0ee7', '30a6b45d-41ca-5350-883b-0595bee7062f', 'parent');
  perform pg_temp.rel('30a6b45d-41ca-5350-883b-0595bee7062f', '40a576f3-3a8c-5ca8-b9e7-20d9ea65ddee', 'parent');
  perform pg_temp.rel('40a576f3-3a8c-5ca8-b9e7-20d9ea65ddee', '167db292-180f-51b3-9d40-d6aa2bf04ac4', 'parent');
  perform pg_temp.rel('30a6b45d-41ca-5350-883b-0595bee7062f', '7ab44e3e-6f2f-4701-8b12-49b8fb585eaa', 'family');
  perform pg_temp.rel('167db292-180f-51b3-9d40-d6aa2bf04ac4', '0232cd78-5dc7-5f49-b0ac-6ba14cefff8f', 'parent');
  perform pg_temp.rel('0232cd78-5dc7-5f49-b0ac-6ba14cefff8f', 'e30eb3db-9e0c-5e8e-b979-d24d56bbdefd', 'parent');
  perform pg_temp.rel('0232cd78-5dc7-5f49-b0ac-6ba14cefff8f', '2fdd6595-3bc6-5a4a-9b70-c7c18ed40b65', 'parent');
  perform pg_temp.rel('0232cd78-5dc7-5f49-b0ac-6ba14cefff8f', '5b5ddf13-e634-5d1e-bab3-a8f86c823403', 'parent');
  perform pg_temp.rel('2fdd6595-3bc6-5a4a-9b70-c7c18ed40b65', 'a5ab3f06-163f-52aa-9658-82a7e85eb798', 'spouse');
  perform pg_temp.rel('2fdd6595-3bc6-5a4a-9b70-c7c18ed40b65', '1b1c57b5-3f6d-52b5-98ea-59b0fa600640', 'parent');
  perform pg_temp.rel('a5ab3f06-163f-52aa-9658-82a7e85eb798', '1b1c57b5-3f6d-52b5-98ea-59b0fa600640', 'parent');
  perform pg_temp.rel('1b1c57b5-3f6d-52b5-98ea-59b0fa600640', '301c4f2f-77e9-59fb-9805-a744ec2914b0', 'parent');
  perform pg_temp.rel('1b1c57b5-3f6d-52b5-98ea-59b0fa600640', '7b294ba5-3dbe-5171-aff2-f4cabc57d599', 'parent');
  perform pg_temp.rel('301c4f2f-77e9-59fb-9805-a744ec2914b0', 'bd0bae4a-1243-5471-bc3d-8f367355773c', 'spouse');
  perform pg_temp.rel('da46a1b7-640a-4afb-be70-afbf5f716fa5', 'bd0bae4a-1243-5471-bc3d-8f367355773c', 'parent');
  perform pg_temp.rel('6dbff916-ca5a-4206-a42b-e2b577aa4b46', 'bd0bae4a-1243-5471-bc3d-8f367355773c', 'parent');
  perform pg_temp.rel('7b294ba5-3dbe-5171-aff2-f4cabc57d599', '78ca35e1-1487-5c31-aefb-f64809ce59da', 'spouse');
  perform pg_temp.rel('7b294ba5-3dbe-5171-aff2-f4cabc57d599', '44a43b3a-58f2-406b-a9a6-50f6ad73b716', 'parent');
  perform pg_temp.rel('78ca35e1-1487-5c31-aefb-f64809ce59da', '44a43b3a-58f2-406b-a9a6-50f6ad73b716', 'parent');
  perform pg_temp.rel('44a43b3a-58f2-406b-a9a6-50f6ad73b716', 'd60fe239-e250-4224-9605-49bc5b685853', 'spouse');
  perform pg_temp.rel('44a43b3a-58f2-406b-a9a6-50f6ad73b716', '6e723508-4ac3-4e12-bbc8-084d3460a1c5', 'parent');
  perform pg_temp.rel('d60fe239-e250-4224-9605-49bc5b685853', '6e723508-4ac3-4e12-bbc8-084d3460a1c5', 'parent');
  perform pg_temp.rel('44a43b3a-58f2-406b-a9a6-50f6ad73b716', 'aaf4eda5-3825-404e-95b2-342f31a9acd0', 'parent');
  perform pg_temp.rel('d60fe239-e250-4224-9605-49bc5b685853', 'aaf4eda5-3825-404e-95b2-342f31a9acd0', 'parent');
  perform pg_temp.rel('44a43b3a-58f2-406b-a9a6-50f6ad73b716', '9269a040-a00f-482b-9ab0-0240dfd9ee48', 'parent');
  perform pg_temp.rel('d60fe239-e250-4224-9605-49bc5b685853', '9269a040-a00f-482b-9ab0-0240dfd9ee48', 'parent');
  perform pg_temp.rel('6e723508-4ac3-4e12-bbc8-084d3460a1c5', 'b68fcf36-62b4-58c1-b00a-62d328e6e130', 'spouse');
  perform pg_temp.rel('6e723508-4ac3-4e12-bbc8-084d3460a1c5', 'bb9cb492-ebd3-5138-9217-5abf70d34e52', 'parent');
  perform pg_temp.rel('b68fcf36-62b4-58c1-b00a-62d328e6e130', 'bb9cb492-ebd3-5138-9217-5abf70d34e52', 'parent');
  perform pg_temp.rel('d52e8bf8-4fa2-4ee0-b36e-2965767b22ef', 'cf59cae5-af1a-53ac-abf9-8c14c26b94d4', 'parent');
  perform pg_temp.rel('74e6ef51-e06c-4fff-a032-67663a267317', 'cf59cae5-af1a-53ac-abf9-8c14c26b94d4', 'parent');
  perform pg_temp.rel('cf59cae5-af1a-53ac-abf9-8c14c26b94d4', '65dfcfea-9030-5f31-8332-31f0ee936705', 'parent');
  perform pg_temp.rel('65dfcfea-9030-5f31-8332-31f0ee936705', 'bb9cb492-ebd3-5138-9217-5abf70d34e52', 'spouse');
  perform pg_temp.rel('65dfcfea-9030-5f31-8332-31f0ee936705', '1ae279f0-3665-5f00-acbe-d6c10b0193fa', 'parent');
  perform pg_temp.rel('bb9cb492-ebd3-5138-9217-5abf70d34e52', '1ae279f0-3665-5f00-acbe-d6c10b0193fa', 'parent');
  perform pg_temp.rel('1ae279f0-3665-5f00-acbe-d6c10b0193fa', 'c4279528-0edc-59eb-824b-845d16868fa5', 'spouse');
  perform pg_temp.rel('5c72ec7d-85f3-4b97-b6d5-ed54fad8e0c7', 'c4279528-0edc-59eb-824b-845d16868fa5', 'parent');
  perform pg_temp.rel('1ae279f0-3665-5f00-acbe-d6c10b0193fa', '8eda31ec-5b8d-5d1c-a37d-bdc129839624', 'parent');
  perform pg_temp.rel('c4279528-0edc-59eb-824b-845d16868fa5', '8eda31ec-5b8d-5d1c-a37d-bdc129839624', 'parent');
  perform pg_temp.rel('8eda31ec-5b8d-5d1c-a37d-bdc129839624', 'f2467a25-edb2-5957-b3ce-e1592aab53d5', 'spouse');
  perform pg_temp.rel('ce21005e-1d38-437f-9ecd-8affb07a1ddc', 'f2467a25-edb2-5957-b3ce-e1592aab53d5', 'parent');
  perform pg_temp.rel('2905cc98-f0a5-4282-a792-72cd27b69e1c', 'f2467a25-edb2-5957-b3ce-e1592aab53d5', 'parent');
  perform pg_temp.rel('8eda31ec-5b8d-5d1c-a37d-bdc129839624', '34017186-23f9-5a0b-92af-cfae71e4d7ac', 'parent');
  perform pg_temp.rel('f2467a25-edb2-5957-b3ce-e1592aab53d5', '34017186-23f9-5a0b-92af-cfae71e4d7ac', 'parent');
  perform pg_temp.rel('34017186-23f9-5a0b-92af-cfae71e4d7ac', 'ab28690e-c022-4321-841c-4b1819c2a86b', 'spouse');
  perform pg_temp.rel('34017186-23f9-5a0b-92af-cfae71e4d7ac', '568969f8-1cb8-500c-a299-4188bec482d9', 'parent');
  perform pg_temp.rel('ab28690e-c022-4321-841c-4b1819c2a86b', '568969f8-1cb8-500c-a299-4188bec482d9', 'parent');
  perform pg_temp.rel('34017186-23f9-5a0b-92af-cfae71e4d7ac', '61960a71-381f-5494-8f7b-f70be8f7ebd6', 'parent');
  perform pg_temp.rel('ab28690e-c022-4321-841c-4b1819c2a86b', '61960a71-381f-5494-8f7b-f70be8f7ebd6', 'parent');
  perform pg_temp.rel('34017186-23f9-5a0b-92af-cfae71e4d7ac', '9b47c76f-548c-5fd2-a181-26830cd5c23d', 'parent');
  perform pg_temp.rel('ab28690e-c022-4321-841c-4b1819c2a86b', '9b47c76f-548c-5fd2-a181-26830cd5c23d', 'parent');
  perform pg_temp.rel('9b47c76f-548c-5fd2-a181-26830cd5c23d', 'fa89a476-8583-59f8-8af2-05c6f016a493', 'spouse');
  perform pg_temp.rel('9b47c76f-548c-5fd2-a181-26830cd5c23d', 'e8697ed5-63a3-5c25-8ff9-01e0b32b9252', 'parent');
  perform pg_temp.rel('fa89a476-8583-59f8-8af2-05c6f016a493', 'e8697ed5-63a3-5c25-8ff9-01e0b32b9252', 'parent');
  perform pg_temp.rel('e8697ed5-63a3-5c25-8ff9-01e0b32b9252', '4b6eefcb-4f82-560d-9ea3-ca99eab562da', 'spouse');
  perform pg_temp.rel('50d03330-9124-45c3-9e32-512d30975f07', '4b6eefcb-4f82-560d-9ea3-ca99eab562da', 'parent');
  perform pg_temp.rel('e8697ed5-63a3-5c25-8ff9-01e0b32b9252', '8b827af1-62d9-5a26-82f5-3495be8becf2', 'parent');
  perform pg_temp.rel('4b6eefcb-4f82-560d-9ea3-ca99eab562da', '8b827af1-62d9-5a26-82f5-3495be8becf2', 'parent');
  perform pg_temp.rel('e8697ed5-63a3-5c25-8ff9-01e0b32b9252', '2f8c274f-e405-5574-afdf-3fb3f70eeb56', 'parent');
  perform pg_temp.rel('4b6eefcb-4f82-560d-9ea3-ca99eab562da', '2f8c274f-e405-5574-afdf-3fb3f70eeb56', 'parent');
  perform pg_temp.rel('9a644975-d26a-5515-95a7-be702460d24e', 'ca7c0a13-2157-5f1b-ae4b-d9a6d8c57594', 'parent');
  perform pg_temp.rel('2f8c274f-e405-5574-afdf-3fb3f70eeb56', 'ca7c0a13-2157-5f1b-ae4b-d9a6d8c57594', 'spouse');
  perform pg_temp.rel('2f8c274f-e405-5574-afdf-3fb3f70eeb56', '24be18dd-185b-51c3-8bb2-51b18ba15ffa', 'parent');
  perform pg_temp.rel('ca7c0a13-2157-5f1b-ae4b-d9a6d8c57594', '24be18dd-185b-51c3-8bb2-51b18ba15ffa', 'parent');
  perform pg_temp.rel('24be18dd-185b-51c3-8bb2-51b18ba15ffa', '414d38be-a451-5e2e-a808-aa6897d355d0', 'spouse');
  perform pg_temp.rel('97ad334e-c901-4205-9b42-730b2cf80f8a', '414d38be-a451-5e2e-a808-aa6897d355d0', 'parent');
  perform pg_temp.rel('24be18dd-185b-51c3-8bb2-51b18ba15ffa', '800e8f67-bcc1-48a3-8e37-c3882d1a151f', 'parent');
  perform pg_temp.rel('414d38be-a451-5e2e-a808-aa6897d355d0', '800e8f67-bcc1-48a3-8e37-c3882d1a151f', 'parent');
  perform pg_temp.rel('800e8f67-bcc1-48a3-8e37-c3882d1a151f', '773c19a5-93d1-4171-8660-466c9f464ef3', 'spouse');
  perform pg_temp.rel('800e8f67-bcc1-48a3-8e37-c3882d1a151f', '14b4e7b7-2c0c-44ed-91d1-b48e96b5a947', 'parent');
  perform pg_temp.rel('773c19a5-93d1-4171-8660-466c9f464ef3', '14b4e7b7-2c0c-44ed-91d1-b48e96b5a947', 'parent');
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('6c7bbade-5c41-4303-b45d-f046dce9311e', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 3241, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('7ab44e3e-6f2f-4701-8b12-49b8fb585eaa', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 5725, 640, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('5b5ddf13-e634-5d1e-bab3-a8f86c823403', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 3241, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('bd0bae4a-1243-5471-bc3d-8f367355773c', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 3245, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('78ca35e1-1487-5c31-aefb-f64809ce59da', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 4725, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('44a43b3a-58f2-406b-a9a6-50f6ad73b716', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 4235, 5760, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('6e723508-4ac3-4e12-bbc8-084d3460a1c5', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 1507, 5760, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('b68fcf36-62b4-58c1-b00a-62d328e6e130', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 1007, 5760, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('d52e8bf8-4fa2-4ee0-b36e-2965767b22ef', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 507, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('74e6ef51-e06c-4fff-a032-67663a267317', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 507, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('c4279528-0edc-59eb-824b-845d16868fa5', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 1549, 7040, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f2467a25-edb2-5957-b3ce-e1592aab53d5', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 814, 7680, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ab28690e-c022-4321-841c-4b1819c2a86b', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 569, 8320, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('4b6eefcb-4f82-560d-9ea3-ca99eab562da', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 1235, 9600, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('414d38be-a451-5e2e-a808-aa6897d355d0', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 1005, 10880, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('800e8f67-bcc1-48a3-8e37-c3882d1a151f', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 1495, 11520, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('4e9f6c9b-0659-4dbd-a900-5087e975fda9', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 6725, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('d705a0ce-d481-42dd-90f9-e801431f0c65', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 7725, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('d60fe239-e250-4224-9605-49bc5b685853', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 8725, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f3313dab-fd88-49ed-b776-88d05bcf87ae', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 11725, 6400, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('aaf4eda5-3825-404e-95b2-342f31a9acd0', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 9725, 5760, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('9269a040-a00f-482b-9ab0-0240dfd9ee48', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 10725, 5760, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('773c19a5-93d1-4171-8660-466c9f464ef3', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 12725, 10240, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('14b4e7b7-2c0c-44ed-91d1-b48e96b5a947', 'entry', '29423ab4-ed68-5a1f-8f40-8d14fa0b0819', 13725, 10880, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v101 : % membres ajoutés.', 34;
end $$;
