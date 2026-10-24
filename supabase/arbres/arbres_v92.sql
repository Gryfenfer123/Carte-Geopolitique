-- arbres_v92.sql — Écosse — maison de Dunkeld (de Malcolm II à Alexandre III), Balliol, et ancêtres Bruce
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouveaux arbres « Dunkeld » et « Balliol » ; compléments dans les arbres Alpin, Bruce, Wessex, Plantagenêts et Rollonides (rien n'est supprimé).
-- Dates : connues par ailleurs (histoire d'Écosse), aucune page consultée pour ce lot ; les dates médiévales anciennes sont approximatives (notées).
-- Sainte Marguerite (Wessex), Jeanne et Marguerite d'Angleterre (Plantagenêts) sont créées dans leurs arbres. Autres épouses et ancêtres de familles sans arbre (Crínán, Gruoch, Huntingdon, Galloway, Brus, Carrick, Balliol père) : signalés.
-- Non fait : enfants naturels, Macbeth au-delà de Lulach, comtes de Mar/Carrick, branche de Donald III Bàn.
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
  if exists (select 1 from public.genealogy_members where id = 'c153f240-a5f0-5fee-be33-afc2c6c1a97c') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('14a47148-8939-4160-a1fc-f3de3513d77d','2bbe0128-ee74-5bb8-ba58-6a4e86259e82','2d42f36b-ac4a-4739-afd6-5cf3331fdabf','6594dce9-0b70-4f9a-af27-0c4339e7a80b','7d6f1565-dfd5-430e-9a93-a7b9a71c5158','aa3f4985-7d1a-406f-ade2-a0884d2705d4','ad10272c-225f-4b1b-87d6-95ae5f79978f','db456e5e-385a-4597-87b0-1ec2248cba1a','e4c68318-b75e-4bc3-8194-8d8babb28008');
  if k <> 9 then raise exception 'Membres préexistants manquants (% sur 9) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Dunkeld » (GBR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'GBR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour GBR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Dunkeld';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('10116402-8a22-5e6d-88c8-de10ccdc5371', cat_id, 'country', 'GBR', top, 'Dunkeld', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '10116402-8a22-5e6d-88c8-de10ccdc5371';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('91210342-240f-5a40-827b-3e5021e27f96', 'country', 'GBR', 'genealogy', 'Dunkeld', cat_id, sec, admin_id);
  -- Arbre « Balliol » (GBR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'GBR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour GBR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Balliol';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('18984bac-d231-588c-9fe2-6d37c3d8ac8b', cat_id, 'country', 'GBR', top, 'Balliol', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '18984bac-d231-588c-9fe2-6d37c3d8ac8b';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('eddd8454-601c-50c8-a9e4-9364f30c5a56', 'country', 'GBR', 'genealogy', 'Balliol', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = '80f1cfdd-a933-4379-937b-1032aca5104c' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison d''Alpin introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '20fcf3c0-b237-4baf-bd79-42b2e89b39c4' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison de Bruce introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '324177bb-e58e-4a04-9718-bb9e9765bd49' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison de Wessex et de Godwin introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '177fd0be-7236-4c6f-b8d6-08eab212742a' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Les Plantagenêts introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = 'b545151c-cabc-48f1-af74-4c77696b64ca' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Les Rollonides et Blois introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = 'e54ea4ad-8213-490c-95cd-a7b538988b75' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Rois de Norvège introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c153f240-a5f0-5fee-be33-afc2c6c1a97c', 'entry', '80f1cfdd-a933-4379-937b-1032aca5104c', 'Malcolm II', null, 954, 1034, 'Roi d''Écosse', 'Alpin', 4218, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e2fc6144-aca4-5fea-b126-800f0c6806ce', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Bethoc', null, null, null, 'Fille de Malcolm II', 'Écosse', 1269, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fe411ba1-c3ac-50ef-a8ee-72f660a20f44', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Crínán de Dunkeld', null, null, 1045, 'Abbé laïc de Dunkeld', 'Crínán', 779, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5a1e4793-e13a-5752-a028-334e33f0057b', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Duncan Ier', null, 1001, 1040, 'Roi d''Écosse', 'Dunkeld', 1024, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c307c9b0-690a-521b-80fe-2423e4b3d513', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Macbeth', null, 1005, 1057, 'Roi d''Écosse (1040-1057)', 'Moray', 4038, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('585b909a-e605-550c-9bff-cc0bfc7ff610', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Gruoch', null, 1015, 1058, 'Reine d''Écosse, épouse de Macbeth', 'Moray', 3548, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ae55af42-d888-5872-8267-63e9d9f4c1b3', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Lulach', null, 1032, 1058, 'Roi d''Écosse (1057-1058)', 'Moray', 3548, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fbc60e2a-4749-5876-bfda-674bc6d0edba', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Malcolm III Canmore', null, 1031, 1093, 'Roi d''Écosse', 'Dunkeld', 1024, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('157d9a44-c94d-5021-b386-1479b77bacdf', 'entry', '324177bb-e58e-4a04-9718-bb9e9765bd49', 'Marguerite d''Écosse (sainte Marguerite)', null, 1045, 1093, 'Reine d''Écosse', 'Wessex', 342000, 810, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4cf8a604-da57-568e-a56b-254bb64c6535', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Duncan II', null, 1060, 1094, 'Roi d''Écosse', 'Dunkeld', 2000, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ef3e4940-aad3-53bd-a7ab-0cb5ef74c195', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Édgar d''Écosse', null, 1074, 1107, 'Roi d''Écosse', 'Dunkeld', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('92290c04-face-5993-9aed-0a5b32179c39', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Alexandre Ier', null, 1078, 1124, 'Roi d''Écosse', 'Dunkeld', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f1844f54-1ae3-55e9-b074-2b0568decd00', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'David Ier', null, 1084, 1153, 'Roi d''Écosse', 'Dunkeld', 1000, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('477cdb51-d8d4-53ba-bc4c-3b90ad63a97e', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Henri de Huntingdon, comte de Northumbrie', null, 1114, 1152, 'Prince héritier, fils de David Ier', 'Dunkeld', 1000, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9b48a946-a6c2-53d4-b15c-baeaf9ffece7', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Ada de Warenne', null, 1120, 1178, 'Comtesse de Huntingdon, mère de Malcolm IV et de Guillaume', 'Warenne', 1490, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1f3572af-335b-58da-b373-0804d4554700', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Malcolm IV', null, 1141, 1165, 'Roi d''Écosse', 'Dunkeld', 1475, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8fa4d85d-c4ba-5e51-963e-4588f2684493', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Guillaume le Lion', null, 1143, 1214, 'Roi d''Écosse', 'Dunkeld', 967, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('25bc46b9-516f-5352-ba8a-22b6b2f262f2', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'David de Huntingdon', null, 1144, 1219, 'Comte de Huntingdon, frère de Guillaume le Lion', 'Dunkeld', 1975, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0074ddea-21b2-566a-b3ba-fa731f233594', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Alexandre II', null, 1198, 1249, 'Roi d''Écosse', 'Dunkeld', 967, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fee3b75f-90bf-5bff-a87b-50b0f99e1559', 'entry', '177fd0be-7236-4c6f-b8d6-08eab212742a', 'Jeanne d''Angleterre', null, 1210, 1238, 'Reine d''Écosse, épouse d''Alexandre II', 'Plantagenêts', 342000, 3780, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('180e4769-f41f-548c-b7ec-307ca812a4d1', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Marie de Coucy', null, null, 1284, 'Reine d''Écosse, 2e épouse d''Alexandre II', 'Coucy', 477, 4480, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('940d22f6-0b2f-5c01-817d-21d2bcdef2a1', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Alexandre III', null, 1241, 1286, 'Roi d''Écosse', 'Dunkeld', 722, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('69c7a9b9-1c1a-567c-ad5a-2767886ea33e', 'entry', '177fd0be-7236-4c6f-b8d6-08eab212742a', 'Marguerite d''Angleterre', null, 1240, 1275, 'Reine d''Écosse, épouse d''Alexandre III', 'Plantagenêts', 342340, 4320, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bf5aefec-4eba-5f3a-a1e8-78df20fade72', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Marguerite de Norvège (la Vierge de Norvège)', null, 1283, 1290, 'Reine d''Écosse, morte en route', 'Norvège', 1049, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('50fcc5a9-ac37-5371-a4a8-d2fb3ec026d3', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Marguerite d''Écosse, reine de Norvège', null, 1261, 1283, 'Reine de Norvège, fille d''Alexandre III', 'Dunkeld', 967, 5760, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ebece6d0-60e5-5af0-86a6-e7e6292cd8ed', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Maud de Chester', null, 1171, 1233, 'Comtesse de Huntingdon, épouse de David', 'Chester', 2465, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('72b20a0f-413e-56c0-9141-398789c2a554', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Isabelle de Huntingdon', null, 1199, 1251, 'Fille de David de Huntingdon', 'Dunkeld', 2548, 4480, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5101a699-da30-5ae7-b697-2e792458c3e6', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 'Marguerite de Huntingdon', null, 1194, 1228, 'Fille de David de Huntingdon, mère de Devorguilla', 'Dunkeld', 2039, 4480, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f6eafac5-55fa-5d7d-a99d-596274b89270', 'entry', '20fcf3c0-b237-4baf-bd79-42b2e89b39c4', 'Robert de Brus, 5e seigneur d''Annandale', null, 1210, 1295, 'Le Compétiteur, prétendant au trône', 'Bruce', 985, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('884eea0b-f85b-5964-bfe5-9e1763eb370a', 'entry', '20fcf3c0-b237-4baf-bd79-42b2e89b39c4', 'Robert de Brus, 6e seigneur d''Annandale', null, 1243, 1304, 'Père de Robert Ier', 'Bruce', 985, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('98c2f8ce-ad7f-54aa-8e40-4e6b4d0952c0', 'entry', '20fcf3c0-b237-4baf-bd79-42b2e89b39c4', 'Marjorie de Carrick', null, null, 1292, 'Comtesse de Carrick, mère de Robert Ier', 'Carrick', 495, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5a61115e-666e-5c4d-9763-cd1357052406', 'entry', 'eddd8454-601c-50c8-a9e4-9364f30c5a56', 'Devorguilla de Galloway', null, 1210, 1290, 'Dame de Galloway, mère de Jean Balliol', 'Galloway', 0, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d862c102-c07d-58e2-9978-ac0f5a42d3db', 'entry', 'eddd8454-601c-50c8-a9e4-9364f30c5a56', 'Jean de Balliol (père)', null, 1208, 1268, 'Fondateur du Balliol College, époux de Devorguilla', 'Balliol', 490, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('78bda1f9-a825-55cd-8dd4-60e571b18234', 'entry', 'eddd8454-601c-50c8-a9e4-9364f30c5a56', 'Jean Balliol', null, 1249, 1314, 'Roi d''Écosse (1292-1296)', 'Balliol', 245, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('107c907f-91e7-5a40-bfaf-7e26bded909a', 'entry', 'eddd8454-601c-50c8-a9e4-9364f30c5a56', 'Édouard Balliol', null, 1283, 1367, 'Roi d''Écosse (1332-1356)', 'Balliol', 245, 1920, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('ad10272c-225f-4b1b-87d6-95ae5f79978f', 'c153f240-a5f0-5fee-be33-afc2c6c1a97c', 'parent');
  perform pg_temp.rel('c153f240-a5f0-5fee-be33-afc2c6c1a97c', 'e2fc6144-aca4-5fea-b126-800f0c6806ce', 'parent');
  perform pg_temp.rel('fe411ba1-c3ac-50ef-a8ee-72f660a20f44', 'e2fc6144-aca4-5fea-b126-800f0c6806ce', 'spouse');
  perform pg_temp.rel('fe411ba1-c3ac-50ef-a8ee-72f660a20f44', '5a1e4793-e13a-5752-a028-334e33f0057b', 'parent');
  perform pg_temp.rel('e2fc6144-aca4-5fea-b126-800f0c6806ce', '5a1e4793-e13a-5752-a028-334e33f0057b', 'parent');
  perform pg_temp.rel('c153f240-a5f0-5fee-be33-afc2c6c1a97c', 'c307c9b0-690a-521b-80fe-2423e4b3d513', 'family');
  perform pg_temp.rel('c307c9b0-690a-521b-80fe-2423e4b3d513', '585b909a-e605-550c-9bff-cc0bfc7ff610', 'spouse');
  perform pg_temp.rel('585b909a-e605-550c-9bff-cc0bfc7ff610', 'ae55af42-d888-5872-8267-63e9d9f4c1b3', 'parent');
  perform pg_temp.rel('c307c9b0-690a-521b-80fe-2423e4b3d513', 'ae55af42-d888-5872-8267-63e9d9f4c1b3', 'family');
  perform pg_temp.rel('5a1e4793-e13a-5752-a028-334e33f0057b', 'fbc60e2a-4749-5876-bfda-674bc6d0edba', 'parent');
  perform pg_temp.rel('e4c68318-b75e-4bc3-8194-8d8babb28008', '157d9a44-c94d-5021-b386-1479b77bacdf', 'parent');
  perform pg_temp.rel('2d42f36b-ac4a-4739-afd6-5cf3331fdabf', '157d9a44-c94d-5021-b386-1479b77bacdf', 'parent');
  perform pg_temp.rel('fbc60e2a-4749-5876-bfda-674bc6d0edba', '157d9a44-c94d-5021-b386-1479b77bacdf', 'spouse');
  perform pg_temp.rel('fbc60e2a-4749-5876-bfda-674bc6d0edba', '4cf8a604-da57-568e-a56b-254bb64c6535', 'parent');
  perform pg_temp.rel('fbc60e2a-4749-5876-bfda-674bc6d0edba', 'ef3e4940-aad3-53bd-a7ab-0cb5ef74c195', 'parent');
  perform pg_temp.rel('157d9a44-c94d-5021-b386-1479b77bacdf', 'ef3e4940-aad3-53bd-a7ab-0cb5ef74c195', 'parent');
  perform pg_temp.rel('fbc60e2a-4749-5876-bfda-674bc6d0edba', '92290c04-face-5993-9aed-0a5b32179c39', 'parent');
  perform pg_temp.rel('157d9a44-c94d-5021-b386-1479b77bacdf', '92290c04-face-5993-9aed-0a5b32179c39', 'parent');
  perform pg_temp.rel('fbc60e2a-4749-5876-bfda-674bc6d0edba', 'f1844f54-1ae3-55e9-b074-2b0568decd00', 'parent');
  perform pg_temp.rel('157d9a44-c94d-5021-b386-1479b77bacdf', 'f1844f54-1ae3-55e9-b074-2b0568decd00', 'parent');
  perform pg_temp.rel('fbc60e2a-4749-5876-bfda-674bc6d0edba', '7d6f1565-dfd5-430e-9a93-a7b9a71c5158', 'parent');
  perform pg_temp.rel('157d9a44-c94d-5021-b386-1479b77bacdf', '7d6f1565-dfd5-430e-9a93-a7b9a71c5158', 'parent');
  perform pg_temp.rel('f1844f54-1ae3-55e9-b074-2b0568decd00', '477cdb51-d8d4-53ba-bc4c-3b90ad63a97e', 'parent');
  perform pg_temp.rel('477cdb51-d8d4-53ba-bc4c-3b90ad63a97e', '9b48a946-a6c2-53d4-b15c-baeaf9ffece7', 'spouse');
  perform pg_temp.rel('477cdb51-d8d4-53ba-bc4c-3b90ad63a97e', '1f3572af-335b-58da-b373-0804d4554700', 'parent');
  perform pg_temp.rel('9b48a946-a6c2-53d4-b15c-baeaf9ffece7', '1f3572af-335b-58da-b373-0804d4554700', 'parent');
  perform pg_temp.rel('477cdb51-d8d4-53ba-bc4c-3b90ad63a97e', '8fa4d85d-c4ba-5e51-963e-4588f2684493', 'parent');
  perform pg_temp.rel('9b48a946-a6c2-53d4-b15c-baeaf9ffece7', '8fa4d85d-c4ba-5e51-963e-4588f2684493', 'parent');
  perform pg_temp.rel('477cdb51-d8d4-53ba-bc4c-3b90ad63a97e', '25bc46b9-516f-5352-ba8a-22b6b2f262f2', 'parent');
  perform pg_temp.rel('9b48a946-a6c2-53d4-b15c-baeaf9ffece7', '25bc46b9-516f-5352-ba8a-22b6b2f262f2', 'parent');
  perform pg_temp.rel('8fa4d85d-c4ba-5e51-963e-4588f2684493', '0074ddea-21b2-566a-b3ba-fa731f233594', 'parent');
  perform pg_temp.rel('db456e5e-385a-4597-87b0-1ec2248cba1a', 'fee3b75f-90bf-5bff-a87b-50b0f99e1559', 'parent');
  perform pg_temp.rel('0074ddea-21b2-566a-b3ba-fa731f233594', 'fee3b75f-90bf-5bff-a87b-50b0f99e1559', 'spouse');
  perform pg_temp.rel('0074ddea-21b2-566a-b3ba-fa731f233594', '180e4769-f41f-548c-b7ec-307ca812a4d1', 'spouse');
  perform pg_temp.rel('0074ddea-21b2-566a-b3ba-fa731f233594', '940d22f6-0b2f-5c01-817d-21d2bcdef2a1', 'parent');
  perform pg_temp.rel('180e4769-f41f-548c-b7ec-307ca812a4d1', '940d22f6-0b2f-5c01-817d-21d2bcdef2a1', 'parent');
  perform pg_temp.rel('6594dce9-0b70-4f9a-af27-0c4339e7a80b', '69c7a9b9-1c1a-567c-ad5a-2767886ea33e', 'parent');
  perform pg_temp.rel('14a47148-8939-4160-a1fc-f3de3513d77d', '69c7a9b9-1c1a-567c-ad5a-2767886ea33e', 'parent');
  perform pg_temp.rel('940d22f6-0b2f-5c01-817d-21d2bcdef2a1', '69c7a9b9-1c1a-567c-ad5a-2767886ea33e', 'spouse');
  perform pg_temp.rel('940d22f6-0b2f-5c01-817d-21d2bcdef2a1', 'bf5aefec-4eba-5f3a-a1e8-78df20fade72', 'parent');
  perform pg_temp.rel('940d22f6-0b2f-5c01-817d-21d2bcdef2a1', '50fcc5a9-ac37-5371-a4a8-d2fb3ec026d3', 'parent');
  perform pg_temp.rel('69c7a9b9-1c1a-567c-ad5a-2767886ea33e', '50fcc5a9-ac37-5371-a4a8-d2fb3ec026d3', 'parent');
  perform pg_temp.rel('50fcc5a9-ac37-5371-a4a8-d2fb3ec026d3', 'bf5aefec-4eba-5f3a-a1e8-78df20fade72', 'parent');
  perform pg_temp.rel('2bbe0128-ee74-5bb8-ba58-6a4e86259e82', 'bf5aefec-4eba-5f3a-a1e8-78df20fade72', 'parent');
  perform pg_temp.rel('2bbe0128-ee74-5bb8-ba58-6a4e86259e82', '50fcc5a9-ac37-5371-a4a8-d2fb3ec026d3', 'spouse');
  perform pg_temp.rel('25bc46b9-516f-5352-ba8a-22b6b2f262f2', 'ebece6d0-60e5-5af0-86a6-e7e6292cd8ed', 'spouse');
  perform pg_temp.rel('25bc46b9-516f-5352-ba8a-22b6b2f262f2', '72b20a0f-413e-56c0-9141-398789c2a554', 'parent');
  perform pg_temp.rel('ebece6d0-60e5-5af0-86a6-e7e6292cd8ed', '72b20a0f-413e-56c0-9141-398789c2a554', 'parent');
  perform pg_temp.rel('25bc46b9-516f-5352-ba8a-22b6b2f262f2', '5101a699-da30-5ae7-b697-2e792458c3e6', 'parent');
  perform pg_temp.rel('ebece6d0-60e5-5af0-86a6-e7e6292cd8ed', '5101a699-da30-5ae7-b697-2e792458c3e6', 'parent');
  perform pg_temp.rel('72b20a0f-413e-56c0-9141-398789c2a554', 'f6eafac5-55fa-5d7d-a99d-596274b89270', 'parent');
  perform pg_temp.rel('f6eafac5-55fa-5d7d-a99d-596274b89270', '884eea0b-f85b-5964-bfe5-9e1763eb370a', 'parent');
  perform pg_temp.rel('884eea0b-f85b-5964-bfe5-9e1763eb370a', '98c2f8ce-ad7f-54aa-8e40-4e6b4d0952c0', 'spouse');
  perform pg_temp.rel('884eea0b-f85b-5964-bfe5-9e1763eb370a', 'aa3f4985-7d1a-406f-ade2-a0884d2705d4', 'parent');
  perform pg_temp.rel('98c2f8ce-ad7f-54aa-8e40-4e6b4d0952c0', 'aa3f4985-7d1a-406f-ade2-a0884d2705d4', 'parent');
  perform pg_temp.rel('5101a699-da30-5ae7-b697-2e792458c3e6', '5a61115e-666e-5c4d-9763-cd1357052406', 'parent');
  perform pg_temp.rel('d862c102-c07d-58e2-9978-ac0f5a42d3db', '5a61115e-666e-5c4d-9763-cd1357052406', 'spouse');
  perform pg_temp.rel('d862c102-c07d-58e2-9978-ac0f5a42d3db', '78bda1f9-a825-55cd-8dd4-60e571b18234', 'parent');
  perform pg_temp.rel('5a61115e-666e-5c4d-9763-cd1357052406', '78bda1f9-a825-55cd-8dd4-60e571b18234', 'parent');
  perform pg_temp.rel('78bda1f9-a825-55cd-8dd4-60e571b18234', '107c907f-91e7-5a40-bfaf-7e26bded909a', 'parent');
  update public.genealogy_members set pos_x = 1245, pos_y = 2560 where id = '4a54452b-df90-4b4e-b6f5-a73af7ec9654';
  update public.genealogy_members set pos_x = 2238, pos_y = 2560 where id = 'fdef35ca-a4a5-4a52-902e-fd70e2f7c108';
  update public.genealogy_members set pos_x = 1297, pos_y = 0 where id = '3bc816bd-f3f6-4870-990b-54aa9a245007';
  update public.genealogy_members set pos_x = 3218, pos_y = 1280 where id = 'e803653d-826c-4131-893d-1712ce4d0836';
  update public.genealogy_members set pos_x = 807, pos_y = 0 where id = '3cecbae7-ec48-4946-b280-d4aa75944543';
  update public.genealogy_members set pos_x = 990, pos_y = 1920 where id = '54590cb6-5b5e-4c98-9e03-7a13517ee32a';
  update public.genealogy_members set pos_x = 0, pos_y = 640 where id = '9cd1be84-4711-48ea-a0b6-be0f9e5c6f14';
  update public.genealogy_members set pos_x = 245, pos_y = 1280 where id = 'd7102346-b003-4bdd-a59d-c0974d6c84b4';
  update public.genealogy_members set pos_x = 1490, pos_y = 1920 where id = '7f15ddfd-8b24-4a08-9842-37e0e07630f2';
  update public.genealogy_members set pos_x = 2728, pos_y = 2560 where id = 'a1eae044-fbe7-4062-9a3f-a3737b65450a';
  update public.genealogy_members set pos_x = 2043, pos_y = 640 where id = 'c73bef6d-39b7-4cfe-8cb7-9b65d7777c9e';
  update public.genealogy_members set pos_x = 2734, pos_y = 3200 where id = '9a27a07e-f5d5-4d9d-bb55-acbb3dd9678c';
  update public.genealogy_members set pos_x = 1980, pos_y = 1920 where id = 'c6bda662-dddf-4622-858d-e9479e737f1e';
  update public.genealogy_members set pos_x = 2728, pos_y = 1280 where id = '0346ee9a-5a91-4824-92f2-7484f17c63df';
  update public.genealogy_members set pos_x = 2483, pos_y = 1920 where id = 'b746265f-d7ad-46e4-abce-d57f569abfc5';
  update public.genealogy_members set pos_x = 2225, pos_y = 1280 where id = 'c8c1617c-c5ab-4ac0-b981-f59c4294304e';
  update public.genealogy_members set pos_x = 2234, pos_y = 3200 where id = '6cc65d8b-88d5-4fa5-a1a8-ba862d98979b';
  update public.genealogy_members set pos_x = 1735, pos_y = 1280 where id = 'e998bcda-6747-49a4-8aeb-26ff303429fc';
  update public.genealogy_members set pos_x = 1553, pos_y = 640 where id = '0eeea35e-2a58-4d37-9b5a-acd1fc1e5943';
  update public.genealogy_members set pos_x = 745, pos_y = 1280 where id = '1d7a9190-f447-409a-95ce-2f9a6712b66f';
  update public.genealogy_members set pos_x = 1735, pos_y = 2560 where id = '5a408503-1fcb-4c88-b3ad-4de31b89798e';
  update public.genealogy_members set pos_x = 1490, pos_y = 3200 where id = '5f2c2150-574b-4e86-9c93-4a88232ed947';
  update public.genealogy_members set pos_x = 490, pos_y = 640 where id = '0f1b9bdd-0cfc-48d6-9580-1ffe3e4d148e';
  update public.genealogy_members set pos_x = 1235, pos_y = 1280 where id = '82382a3b-df9c-477c-8a3f-4d2ca25c3613';
  update public.genealogy_members set pos_x = 2973, pos_y = 1920 where id = '75fb4234-db95-44c6-8ff6-ee483875f3dd';
  update public.genealogy_members set pos_x = 4218, pos_y = 3200 where id = 'ad10272c-225f-4b1b-87d6-95ae5f79978f';
  update public.genealogy_members set pos_x = 740, pos_y = 1920 where id = 'aa3f4985-7d1a-406f-ade2-a0884d2705d4';
  update public.genealogy_members set pos_x = 250, pos_y = 1920 where id = '7bf6e2f2-9530-45dd-a015-2398f6502f67';
  update public.genealogy_members set pos_x = 490, pos_y = 2560 where id = 'afd9632d-aff9-443d-a036-b1b35dccc7d4';
  update public.genealogy_members set pos_x = 0, pos_y = 2560 where id = '866505e5-87df-48af-a203-1595e08a230c';
  update public.genealogy_members set pos_x = 1230, pos_y = 1920 where id = '43be94f2-faf5-43fa-8544-ae55eea02625';
  update public.genealogy_members set pos_x = 990, pos_y = 2560 where id = '5b9fddee-7052-48bb-bdb5-055a16a94870';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('c153f240-a5f0-5fee-be33-afc2c6c1a97c', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 1269, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('157d9a44-c94d-5021-b386-1479b77bacdf', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 534, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('7d6f1565-dfd5-430e-9a93-a7b9a71c5158', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 1500, 2560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('fee3b75f-90bf-5bff-a87b-50b0f99e1559', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 1457, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('69c7a9b9-1c1a-567c-ad5a-2767886ea33e', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 1212, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('2bbe0128-ee74-5bb8-ba58-6a4e86259e82', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 1457, 5760, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f6eafac5-55fa-5d7d-a99d-596274b89270', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 2548, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('5a61115e-666e-5c4d-9763-cd1357052406', 'entry', '91210342-240f-5a40-827b-3e5021e27f96', 2039, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('5101a699-da30-5ae7-b697-2e792458c3e6', 'entry', 'eddd8454-601c-50c8-a9e4-9364f30c5a56', 0, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('e2fc6144-aca4-5fea-b126-800f0c6806ce', 'entry', '80f1cfdd-a933-4379-937b-1032aca5104c', 4218, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('c307c9b0-690a-521b-80fe-2423e4b3d513', 'entry', '80f1cfdd-a933-4379-937b-1032aca5104c', 5218, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('72b20a0f-413e-56c0-9141-398789c2a554', 'entry', '20fcf3c0-b237-4baf-bd79-42b2e89b39c4', 985, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('bae1fe49-b1ff-4ce8-905d-2b9c6853e64c', 'entry', '20fcf3c0-b237-4baf-bd79-42b2e89b39c4', 245, 3200, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v92 : % membres ajoutés.', 35;
end $$;
