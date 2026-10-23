-- arbres_v93.sql — Danemark médiéval — Estridsen et Valdemar : de Sven II à Valdemar IV ; correctif des dates de la maison de Huntingdon (v92)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Complète l'arbre « Maison d'Estridsen » (3 membres au départ ; rien n'est supprimé).
-- Dates : connues par ailleurs (histoire du Danemark), aucune page consultée pour ce lot ; les dates médiévales anciennes sont approximatives (notées).
-- Dagmar de Bohême est créée dans l'arbre Přemyslides. Autres épouses de familles sans arbre (Sophie de Minsk, Bérengère de Portugal, Agnès de Brandebourg, Helvig de Slesvig, Ulf) : signalées.
-- Correctif de v92 : la mère d'Isabelle de Huntingdon n'est pas Maud de Chester (dates incompatibles) ; les dates d'Isabelle (vers 1176) et de Maud (naissance vide) sont rectifiées. Les liens parentaux de v92 restent (incertains).
-- Non fait : Magnus le Fort, enfants cadets, branche d'Abel, maison de Bavière (Christophe III) entre Éric de Poméranie et Christian Ier.
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
  if exists (select 1 from public.genealogy_members where id = 'd99f255b-c073-5411-870c-b454c38b5e72') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('1e2890c2-9c3d-45a7-a97e-6ab65003a490','328018bd-3280-458d-9981-43226a013bd6','345d74b4-9bc4-5875-90bb-09645b39ae57','59229f89-6517-581a-b870-95cad1855c28','859daf76-7cc9-57d6-8b32-ccf892a508b1','86690abf-cd2c-4d1c-bdf2-607e9bca2fbc','ef4df279-a2d8-5578-b39f-4e3865aef537');
  if k <> 7 then raise exception 'Membres préexistants manquants (% sur 7) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  select count(*) into k from public.dossier_entries where id = 'f2e02253-744a-428b-8fe9-c3d347998035' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison d''Estridsen introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '3a16424c-8305-4d32-9835-618eadd8bd12' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison de Jelling introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = 'b53dda9c-6240-43c2-8503-91cda7693dd1' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Přemyslides introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d99f255b-c073-5411-870c-b454c38b5e72', 'entry', '3a16424c-8305-4d32-9835-618eadd8bd12', 'Estrid Svendsdatter', null, 990, 1057, 'Fille de Sven à la Barbe fourchue, mère de Sven II', 'Jelling', 348000, -180, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f3414b87-8ef0-58f2-a882-dec9597b287e', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Ulf Thorgilsson', null, null, 1026, 'Jarl, père de Sven II', 'Ulf', 1956, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('312ad662-e724-5d37-9947-590c598722d1', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Sven II Estridsen', null, 1019, 1076, 'Roi de Danemark', 'Estridsen', 1711, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b762c0ba-e784-51a7-b23e-6d626e2ba5a5', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Harald III Hen', null, 1041, 1080, 'Roi de Danemark', 'Estridsen', 706, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aaa520dd-2d8b-5f54-a65d-c5f6e73a601f', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Knud IV le Saint', null, 1042, 1086, 'Roi de Danemark', 'Estridsen', 2206, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6bd780a2-425f-56ae-b9a3-ba68a41162af', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Olaf Ier la Famine', null, 1050, 1095, 'Roi de Danemark', 'Estridsen', 1706, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3e9aa62e-39eb-5b1a-bcff-3d006e82889e', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Éric Ier Ejegod', null, 1056, 1103, 'Roi de Danemark', 'Estridsen', 1206, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2ecdedea-0265-5940-9a41-95ede8602a6d', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Niels', null, 1064, 1134, 'Roi de Danemark', 'Estridsen', 2706, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dfacc6cd-3f5c-5c8e-b3a4-93bdaa892074', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Éric II Emune', null, 1090, 1137, 'Roi de Danemark', 'Estridsen', 1436, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0a4ea258-827f-5bae-92af-6321058e8496', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Knud Lavard', null, 1096, 1131, 'Duc de Slesvig, père de Valdemar Ier', 'Estridsen', 923, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('197964af-faef-528f-b382-263b86c59187', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Valdemar Ier le Grand', null, 1131, 1182, 'Roi de Danemark', 'Estridsen', 923, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c4958146-b46a-507a-af29-6edf180143dd', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Sophie de Minsk', null, 1140, 1198, 'Reine de Danemark', 'Minsk (Riourikides)', 1413, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('45ab789d-87f9-51f6-aa77-a54a5f6e3feb', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Knud VI', null, 1162, 1202, 'Roi de Danemark', 'Estridsen', 990, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c2744b96-1f61-578f-9686-a763df6a6e05', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Valdemar II le Victorieux', null, 1170, 1241, 'Roi de Danemark', 'Estridsen', 1980, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('20d20795-81f2-5dc1-8ccc-19ebb21d6544', 'entry', 'b53dda9c-6240-43c2-8503-91cda7693dd1', 'Dagmar de Bohême (Marguerite)', null, 1186, 1212, 'Reine de Danemark', 'Přemyslides', 348000, 3348, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0373f6a9-8f72-5ebc-ac05-09d42a94de6e', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Bérengère de Portugal', null, 1194, 1221, 'Reine de Danemark', 'Portugal (Bourgogne)', 1490, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('293e9fb9-ec8c-5493-9cf9-26cbab3e744d', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Valdemar le Jeune', null, 1209, 1231, 'Co-roi, fils de Valdemar II', 'Estridsen', 2394, 4480, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9d7f7c9d-9c6e-5075-b75b-b37de0c135f2', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Éric IV Plovpenning', null, 1216, 1250, 'Roi de Danemark', 'Estridsen', 871, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c1669bd6-a7e9-5cd3-bced-dcaf7f2c789f', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Abel', null, 1218, 1252, 'Roi de Danemark', 'Estridsen', 1394, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d186a4cf-eef2-5451-b04f-a11fcfc32300', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Christophe Ier', null, 1219, 1259, 'Roi de Danemark', 'Estridsen', 1894, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2ce43858-816c-54b1-bce1-fd03ec722644', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Éric V Klipping', null, 1249, 1286, 'Roi de Danemark', 'Estridsen', 1894, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('89ff365e-33b0-53cd-9291-04cf4d636630', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Agnès de Brandebourg', null, 1257, 1304, 'Reine de Danemark, régente', 'Brandebourg (Ascaniens)', 1404, 5120, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a4571626-6c50-54fd-a445-4cb4ed97bfcd', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Éric VI Menved', null, 1274, 1319, 'Roi de Danemark', 'Estridsen', 1049, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d9f614e1-82c2-522c-98f7-f810ecba6e69', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Christophe II', null, 1276, 1332, 'Roi de Danemark', 'Estridsen', 1549, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('36ef9b40-cc72-5047-ab13-d75b4596cfe7', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 'Helvig de Slesvig', null, 1327, 1375, 'Reine de Danemark', 'Slesvig', 1059, 6400, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('1e2890c2-9c3d-45a7-a97e-6ab65003a490', 'd99f255b-c073-5411-870c-b454c38b5e72', 'parent');
  perform pg_temp.rel('f3414b87-8ef0-58f2-a882-dec9597b287e', 'd99f255b-c073-5411-870c-b454c38b5e72', 'spouse');
  perform pg_temp.rel('f3414b87-8ef0-58f2-a882-dec9597b287e', '312ad662-e724-5d37-9947-590c598722d1', 'parent');
  perform pg_temp.rel('d99f255b-c073-5411-870c-b454c38b5e72', '312ad662-e724-5d37-9947-590c598722d1', 'parent');
  perform pg_temp.rel('312ad662-e724-5d37-9947-590c598722d1', 'b762c0ba-e784-51a7-b23e-6d626e2ba5a5', 'parent');
  perform pg_temp.rel('312ad662-e724-5d37-9947-590c598722d1', 'aaa520dd-2d8b-5f54-a65d-c5f6e73a601f', 'parent');
  perform pg_temp.rel('312ad662-e724-5d37-9947-590c598722d1', '6bd780a2-425f-56ae-b9a3-ba68a41162af', 'parent');
  perform pg_temp.rel('312ad662-e724-5d37-9947-590c598722d1', '3e9aa62e-39eb-5b1a-bcff-3d006e82889e', 'parent');
  perform pg_temp.rel('312ad662-e724-5d37-9947-590c598722d1', '2ecdedea-0265-5940-9a41-95ede8602a6d', 'parent');
  perform pg_temp.rel('3e9aa62e-39eb-5b1a-bcff-3d006e82889e', 'dfacc6cd-3f5c-5c8e-b3a4-93bdaa892074', 'parent');
  perform pg_temp.rel('3e9aa62e-39eb-5b1a-bcff-3d006e82889e', '0a4ea258-827f-5bae-92af-6321058e8496', 'parent');
  perform pg_temp.rel('0a4ea258-827f-5bae-92af-6321058e8496', '197964af-faef-528f-b382-263b86c59187', 'parent');
  perform pg_temp.rel('197964af-faef-528f-b382-263b86c59187', 'c4958146-b46a-507a-af29-6edf180143dd', 'spouse');
  perform pg_temp.rel('197964af-faef-528f-b382-263b86c59187', '45ab789d-87f9-51f6-aa77-a54a5f6e3feb', 'parent');
  perform pg_temp.rel('c4958146-b46a-507a-af29-6edf180143dd', '45ab789d-87f9-51f6-aa77-a54a5f6e3feb', 'parent');
  perform pg_temp.rel('197964af-faef-528f-b382-263b86c59187', 'c2744b96-1f61-578f-9686-a763df6a6e05', 'parent');
  perform pg_temp.rel('c4958146-b46a-507a-af29-6edf180143dd', 'c2744b96-1f61-578f-9686-a763df6a6e05', 'parent');
  perform pg_temp.rel('197964af-faef-528f-b382-263b86c59187', '328018bd-3280-458d-9981-43226a013bd6', 'parent');
  perform pg_temp.rel('c4958146-b46a-507a-af29-6edf180143dd', '328018bd-3280-458d-9981-43226a013bd6', 'parent');
  perform pg_temp.rel('86690abf-cd2c-4d1c-bdf2-607e9bca2fbc', '20d20795-81f2-5dc1-8ccc-19ebb21d6544', 'parent');
  perform pg_temp.rel('c2744b96-1f61-578f-9686-a763df6a6e05', '20d20795-81f2-5dc1-8ccc-19ebb21d6544', 'spouse');
  perform pg_temp.rel('c2744b96-1f61-578f-9686-a763df6a6e05', '0373f6a9-8f72-5ebc-ac05-09d42a94de6e', 'spouse');
  perform pg_temp.rel('c2744b96-1f61-578f-9686-a763df6a6e05', '293e9fb9-ec8c-5493-9cf9-26cbab3e744d', 'parent');
  perform pg_temp.rel('20d20795-81f2-5dc1-8ccc-19ebb21d6544', '293e9fb9-ec8c-5493-9cf9-26cbab3e744d', 'parent');
  perform pg_temp.rel('c2744b96-1f61-578f-9686-a763df6a6e05', '9d7f7c9d-9c6e-5075-b75b-b37de0c135f2', 'parent');
  perform pg_temp.rel('0373f6a9-8f72-5ebc-ac05-09d42a94de6e', '9d7f7c9d-9c6e-5075-b75b-b37de0c135f2', 'parent');
  perform pg_temp.rel('c2744b96-1f61-578f-9686-a763df6a6e05', 'c1669bd6-a7e9-5cd3-bced-dcaf7f2c789f', 'parent');
  perform pg_temp.rel('0373f6a9-8f72-5ebc-ac05-09d42a94de6e', 'c1669bd6-a7e9-5cd3-bced-dcaf7f2c789f', 'parent');
  perform pg_temp.rel('c2744b96-1f61-578f-9686-a763df6a6e05', 'd186a4cf-eef2-5451-b04f-a11fcfc32300', 'parent');
  perform pg_temp.rel('0373f6a9-8f72-5ebc-ac05-09d42a94de6e', 'd186a4cf-eef2-5451-b04f-a11fcfc32300', 'parent');
  perform pg_temp.rel('d186a4cf-eef2-5451-b04f-a11fcfc32300', '2ce43858-816c-54b1-bce1-fd03ec722644', 'parent');
  perform pg_temp.rel('2ce43858-816c-54b1-bce1-fd03ec722644', '89ff365e-33b0-53cd-9291-04cf4d636630', 'spouse');
  perform pg_temp.rel('2ce43858-816c-54b1-bce1-fd03ec722644', 'a4571626-6c50-54fd-a445-4cb4ed97bfcd', 'parent');
  perform pg_temp.rel('89ff365e-33b0-53cd-9291-04cf4d636630', 'a4571626-6c50-54fd-a445-4cb4ed97bfcd', 'parent');
  perform pg_temp.rel('2ce43858-816c-54b1-bce1-fd03ec722644', 'd9f614e1-82c2-522c-98f7-f810ecba6e69', 'parent');
  perform pg_temp.rel('89ff365e-33b0-53cd-9291-04cf4d636630', 'd9f614e1-82c2-522c-98f7-f810ecba6e69', 'parent');
  perform pg_temp.rel('d9f614e1-82c2-522c-98f7-f810ecba6e69', '59229f89-6517-581a-b870-95cad1855c28', 'parent');
  perform pg_temp.rel('59229f89-6517-581a-b870-95cad1855c28', '36ef9b40-cc72-5047-ab13-d75b4596cfe7', 'spouse');
  perform pg_temp.rel('36ef9b40-cc72-5047-ab13-d75b4596cfe7', 'ef4df279-a2d8-5578-b39f-4e3865aef537', 'parent');
  perform pg_temp.rel('9d7f7c9d-9c6e-5075-b75b-b37de0c135f2', '859daf76-7cc9-57d6-8b32-ccf892a508b1', 'parent');
  perform pg_temp.rel('2ce43858-816c-54b1-bce1-fd03ec722644', '345d74b4-9bc4-5875-90bb-09645b39ae57', 'parent');
  update public.genealogy_members set pos_x = 490, pos_y = 3200 where id = '328018bd-3280-458d-9981-43226a013bd6';
  update public.genealogy_members set pos_x = 1549, pos_y = 6400 where id = '59229f89-6517-581a-b870-95cad1855c28';
  update public.genealogy_members set pos_x = 1304, pos_y = 7040 where id = 'ef4df279-a2d8-5578-b39f-4e3865aef537';
  update public.genealogy_members set birth_year = 1176, death_year = 1251 where id = '72b20a0f-413e-56c0-9141-398789c2a554';
  update public.genealogy_members set birth_year = null, death_year = 1233 where id = 'ebece6d0-60e5-5af0-86a6-e7e6292cd8ed';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('d99f255b-c073-5411-870c-b454c38b5e72', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 1466, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('20d20795-81f2-5dc1-8ccc-19ebb21d6544', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 2470, 3200, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('859daf76-7cc9-57d6-8b32-ccf892a508b1', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 871, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('345d74b4-9bc4-5875-90bb-09645b39ae57', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 2049, 5760, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('89d29638-9fb9-439d-890f-0d67a21a4ede', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 0, 3200, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f9a2061c-5b8c-42c5-b087-09f7bfe3f577', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 490, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('1a5046e9-6512-5de0-ba0f-79c2b3f5bc39', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 814, 7040, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('cafe94f6-e78b-59af-922c-02285a6f56e5', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 1304, 7680, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('cc31b7ba-1115-589a-8d07-8815a9413f9d', 'entry', 'f2e02253-744a-428b-8fe9-c3d347998035', 3706, 7680, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v93 : % membres ajoutés.', 25;
end $$;
