-- arbres_v104.sql — Iran — Achéménides, Sassanides, Safavides, Qajars et Pahlavi
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Cinq nouveaux arbres pour l'Iran (aucun n'existait) : « Achéménides », « Sassanides », « Safavides », « Qajars », « Pahlavi ». Rien n'est supprimé.
-- Dates : connues par ailleurs (histoire de l'Iran), aucune page consultée pour ce lot. Années avant J.-C. en négatif ; naissances des Achéménides et Sassanides anciens laissées vides quand elles sont inconnues (signalé).
-- Succession : les liens père-fils suivent les listes classiques ; les passages par un autre rameau (Darius Ier, Darius III, Yazdgard III, Fath Ali Shah) sont des liens « famille ».
-- Épouses des Pahlavi (Fawzia d'Égypte, Soraya, Farah Diba) : familles sans arbre pour l'instant, signalées ; Fawzia sera liée quand l'arbre égyptien existera.
-- Non fait : Parthes, Afsharides, Zands, Buyides, Seldjoukides, Ghaznévides, épouses et cadets.
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
  if exists (select 1 from public.genealogy_members where id = 'a743eefc-fe64-5e6d-b25c-5e3fa8246c69') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Achéménides » (IRN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IRN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IRN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Achéménides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('cf2a5209-e495-5075-9ac1-a7de8fe2b6d5', cat_id, 'country', 'IRN', top, 'Achéménides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'cf2a5209-e495-5075-9ac1-a7de8fe2b6d5';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('d544e28f-74ff-5043-a131-1d335c3d6e38', 'country', 'IRN', 'genealogy', 'Achéménides', cat_id, sec, admin_id);
  -- Arbre « Sassanides » (IRN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IRN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IRN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Sassanides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('1ada8271-8bb7-52b5-858d-363f80c12ecc', cat_id, 'country', 'IRN', top, 'Sassanides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '1ada8271-8bb7-52b5-858d-363f80c12ecc';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('80db5993-f24d-587b-9a33-4f92bed1f516', 'country', 'IRN', 'genealogy', 'Sassanides', cat_id, sec, admin_id);
  -- Arbre « Safavides » (IRN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IRN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IRN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Safavides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('ff14dcf5-4fea-5d8d-9b50-294694b2fc1b', cat_id, 'country', 'IRN', top, 'Safavides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'ff14dcf5-4fea-5d8d-9b50-294694b2fc1b';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('6c044b6f-f457-53ca-9440-62885219f4ee', 'country', 'IRN', 'genealogy', 'Safavides', cat_id, sec, admin_id);
  -- Arbre « Qajars » (IRN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IRN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IRN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Qajars';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('0840ab9b-4afd-5648-a0ad-3d78f186e66c', cat_id, 'country', 'IRN', top, 'Qajars', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '0840ab9b-4afd-5648-a0ad-3d78f186e66c';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('152d5bb2-1490-5228-978c-8e39c9223cd9', 'country', 'IRN', 'genealogy', 'Qajars', cat_id, sec, admin_id);
  -- Arbre « Pahlavi » (IRN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IRN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IRN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Pahlavi';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('b2056972-8e10-521b-a96e-2e45306282f3', cat_id, 'country', 'IRN', top, 'Pahlavi', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'b2056972-8e10-521b-a96e-2e45306282f3';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('65c73c1c-5773-5e6f-b97d-d058f4e3a440', 'country', 'IRN', 'genealogy', 'Pahlavi', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a743eefc-fe64-5e6d-b25c-5e3fa8246c69', 'entry', 'd544e28f-74ff-5043-a131-1d335c3d6e38', 'Cyrus II le Grand', null, null, -530, 'Fondateur de l''Empire achéménide (-559 à -530)', 'Achéménides', 1000, 30080, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6e87c29c-1b84-5b14-ae94-7494ea73fcc7', 'entry', 'd544e28f-74ff-5043-a131-1d335c3d6e38', 'Cambyse II', null, null, -522, 'Roi des rois (-530 à -522), conquiert l''Égypte', 'Achéménides', 1000, 30720, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6ce6af20-e872-5b04-9ddc-d2c47c9cc7c4', 'entry', 'd544e28f-74ff-5043-a131-1d335c3d6e38', 'Darius Ier', null, -550, -486, 'Roi des rois (-522 à -486)', 'Achéménides', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('30326bb6-7c56-57d9-8d44-386f06b92a3e', 'entry', 'd544e28f-74ff-5043-a131-1d335c3d6e38', 'Xerxès Ier', null, -518, -465, 'Roi des rois (-486 à -465), guerres médiques', 'Achéménides', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('43e7550e-9641-5a77-88ce-f9527ee4fc0b', 'entry', 'd544e28f-74ff-5043-a131-1d335c3d6e38', 'Artaxerxès Ier', null, null, -424, 'Roi des rois (-465 à -424)', 'Achéménides', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2911a01a-d337-57cb-b114-00b3f54a28d1', 'entry', 'd544e28f-74ff-5043-a131-1d335c3d6e38', 'Darius II', null, null, -404, 'Roi des rois (-423 à -404)', 'Achéménides', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5eda482f-7fb4-59c1-b9f2-05f67127f813', 'entry', 'd544e28f-74ff-5043-a131-1d335c3d6e38', 'Artaxerxès II', null, -445, -358, 'Roi des rois (-404 à -358)', 'Achéménides', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a6757017-b251-5e6e-919f-4511e206166f', 'entry', 'd544e28f-74ff-5043-a131-1d335c3d6e38', 'Artaxerxès III', null, -425, -338, 'Roi des rois (-358 à -338)', 'Achéménides', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c96ca2fe-8539-5546-8fbd-7080d5e9fef8', 'entry', 'd544e28f-74ff-5043-a131-1d335c3d6e38', 'Arsès (Artaxerxès IV)', null, null, -336, 'Roi des rois (-338 à -336)', 'Achéménides', 0, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('35ca6a39-b543-5aa1-96ef-cf750818f84d', 'entry', 'd544e28f-74ff-5043-a131-1d335c3d6e38', 'Darius III', null, -380, -330, 'Dernier roi des rois (-336 à -330), vaincu par Alexandre', 'Achéménides', 2000, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cb95d341-e4e8-5b4e-a844-1097689d826d', 'entry', '80db5993-f24d-587b-9a33-4f92bed1f516', 'Ardachîr Ier', null, null, 242, 'Fondateur de l''Empire sassanide (224-242)', 'Sassanides', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6ec1cc2c-b426-5f33-972b-f27a64f7476d', 'entry', '80db5993-f24d-587b-9a33-4f92bed1f516', 'Shapur Ier', null, null, 270, 'Roi des rois (240-270), capture l''empereur Valérien', 'Sassanides', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('372a762b-c3d0-50a0-99f8-f57fba6656a1', 'entry', '80db5993-f24d-587b-9a33-4f92bed1f516', 'Narsès', null, null, 302, 'Roi des rois (293-302)', 'Sassanides', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ff8be811-91cd-5fdb-8b6c-a02c7ea3b383', 'entry', '80db5993-f24d-587b-9a33-4f92bed1f516', 'Hormizd II', null, null, 309, 'Roi des rois (302-309)', 'Sassanides', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d0610f4f-4ab6-531c-906f-93a7a90b60dd', 'entry', '80db5993-f24d-587b-9a33-4f92bed1f516', 'Shapur II le Grand', null, 309, 379, 'Roi des rois (309-379), roi dès sa naissance', 'Sassanides', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e63af3da-5619-585f-99f0-23705eea6551', 'entry', '80db5993-f24d-587b-9a33-4f92bed1f516', 'Kavadh Ier', null, 473, 531, 'Roi des rois (488-531)', 'Sassanides', 1000, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9b201f58-569e-5583-94d2-6483dbfc87c5', 'entry', '80db5993-f24d-587b-9a33-4f92bed1f516', 'Khosro Ier Anushirvan', null, 501, 579, 'Roi des rois (531-579)', 'Sassanides', 1000, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a0a835c5-8385-558d-8aa3-987ae15e21cd', 'entry', '80db5993-f24d-587b-9a33-4f92bed1f516', 'Hormizd IV', null, null, 590, 'Roi des rois (579-590)', 'Sassanides', 1000, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7b275930-0496-5a6d-a32e-d7017224aa8a', 'entry', '80db5993-f24d-587b-9a33-4f92bed1f516', 'Khosro II Parviz', null, 570, 628, 'Roi des rois (590-628), dernière grande guerre contre Byzance', 'Sassanides', 1000, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dd118635-9641-5ef0-bd4c-d277f42c3d25', 'entry', '80db5993-f24d-587b-9a33-4f92bed1f516', 'Kavadh II', null, null, 628, 'Roi des rois (628)', 'Sassanides', 1000, 8320, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c953e913-891f-5b9e-b7d6-c697a9c956eb', 'entry', '80db5993-f24d-587b-9a33-4f92bed1f516', 'Yazdgard III', null, 624, 651, 'Dernier roi des rois (632-651), vaincu par les Arabes', 'Sassanides', 2000, 8960, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0791ac01-f8fd-588e-a006-86dacd22af1b', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Cheikh Haydar', null, 1459, 1488, 'Chef de l''ordre safavide, père d''Ismaïl Ier', 'Safavides', 250, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8ea9c0c9-5214-55fd-ae57-271264b68ca1', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Ismaïl Ier', null, 1487, 1524, 'Fondateur de l''Empire safavide (1501-1524)', 'Safavides', 250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9c4b7bb5-1e0a-502b-a055-7f7e40aee225', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Tahmasp Ier', null, 1514, 1576, 'Shah (1524-1576)', 'Safavides', 250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('041b1b67-2233-5048-b0a7-6cda65051074', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Ismaïl II', null, 1537, 1577, 'Shah (1576-1577)', 'Safavides', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('58edca92-4bef-5f06-be81-6cf2b34db815', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Mohammad Khodabanda', null, 1531, 1595, 'Shah (1578-1587)', 'Safavides', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b255f8c7-9132-57e9-bd6a-7863e1508efa', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Abbas Ier le Grand', null, 1571, 1629, 'Shah (1588-1629)', 'Safavides', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a5c7676f-06fa-53b2-9071-6d9e721cd888', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Mohammad Baqir Mirza', null, 1587, 1615, 'Prince héritier, père de Safi Ier', 'Safavides', 0, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1fd616dd-faa9-5b5b-8467-93daef6dfd8e', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Safi Ier', null, 1611, 1642, 'Shah (1629-1642)', 'Safavides', 0, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('802b54af-321d-5961-abb8-f3565781df8b', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Abbas II', null, 1632, 1666, 'Shah (1642-1666)', 'Safavides', 0, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e88ab996-7af5-503e-940c-4fc33f690aa9', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Soleiman Ier', null, 1647, 1694, 'Shah (1666-1694)', 'Safavides', 0, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d823ed07-4675-553e-95ef-6fc2866d5903', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Soltan Hosein', null, 1668, 1726, 'Shah (1694-1722), renversé par les Afghans', 'Safavides', 0, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('49ffc8f3-a050-56ff-889c-2fada921b0cf', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Tahmasp II', null, 1704, 1740, 'Shah (1722-1732)', 'Safavides', 0, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('304cc8a6-e084-50c4-9f32-77674cbe3430', 'entry', '6c044b6f-f457-53ca-9440-62885219f4ee', 'Abbas III', null, 1732, 1740, 'Shah (1732-1736), enfant déposé par Nader Shah', 'Safavides', 0, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bbd673a6-bbb1-5391-a7f2-3024e5ec2b80', 'entry', '152d5bb2-1490-5228-978c-8e39c9223cd9', 'Hosein Qoli Khan Qajar', null, 1722, 1777, 'Chef qajar, père de Fath Ali Shah', 'Qajars', 0, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e23e5175-3cc5-52ef-b006-a93388ca8f2d', 'entry', '152d5bb2-1490-5228-978c-8e39c9223cd9', 'Agha Mohammad Khan', null, 1742, 1797, 'Fondateur de la dynastie qajare (1789-1797)', 'Qajars', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('233f297d-a6cb-5cc5-b855-8bc754d5ec0c', 'entry', '152d5bb2-1490-5228-978c-8e39c9223cd9', 'Fath Ali Shah', null, 1772, 1834, 'Shah (1797-1834)', 'Qajars', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('463663fa-ddc0-593d-99f4-685ab2906044', 'entry', '152d5bb2-1490-5228-978c-8e39c9223cd9', 'Abbas Mirza', null, 1789, 1833, 'Prince héritier réformateur', 'Qajars', 0, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ada2492b-1d98-558e-8751-ae612e79d946', 'entry', '152d5bb2-1490-5228-978c-8e39c9223cd9', 'Mohammad Shah', null, 1808, 1848, 'Shah (1834-1848)', 'Qajars', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('90970ffc-98fc-5b0c-82f2-8041bbacafd3', 'entry', '152d5bb2-1490-5228-978c-8e39c9223cd9', 'Nasser ed-Din Shah', null, 1831, 1896, 'Shah (1848-1896), assassiné', 'Qajars', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e18ee7ea-ac9c-5d24-84d2-f3f5f89b4776', 'entry', '152d5bb2-1490-5228-978c-8e39c9223cd9', 'Mozaffar ed-Din Shah', null, 1853, 1907, 'Shah (1896-1907), accorde la Constitution', 'Qajars', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bb5df395-584e-5af5-af08-a40961a560a8', 'entry', '152d5bb2-1490-5228-978c-8e39c9223cd9', 'Mohammad Ali Shah', null, 1872, 1925, 'Shah (1907-1909), déposé', 'Qajars', 0, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7fdd69c3-d574-5ed7-8296-aea9ddd9fa0a', 'entry', '152d5bb2-1490-5228-978c-8e39c9223cd9', 'Ahmad Shah', null, 1898, 1930, 'Dernier shah qajar (1909-1925)', 'Qajars', 0, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ddfcbf96-3455-5a8d-8845-5af644f64a8e', 'entry', '65c73c1c-5773-5e6f-b97d-d058f4e3a440', 'Reza Shah', null, 1878, 1944, 'Fondateur de la dynastie Pahlavi (1925-1941)', 'Pahlavi', 980, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('55884d5e-2bed-56ef-8326-fd5cea678bb3', 'entry', '65c73c1c-5773-5e6f-b97d-d058f4e3a440', 'Mohammad Reza Pahlavi', null, 1919, 1980, 'Shah d''Iran (1941-1979), renversé par la révolution', 'Pahlavi', 980, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('759e55e7-fa63-51ba-b578-589e2f6e2dea', 'entry', '65c73c1c-5773-5e6f-b97d-d058f4e3a440', 'Soraya Esfandiary-Bakhtiari', null, 1932, 2001, 'Deuxième épouse du shah, répudiée', 'Pahlavi', 1470, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('370776ae-74d1-5a95-b3e8-c29455a2e5bb', 'entry', '65c73c1c-5773-5e6f-b97d-d058f4e3a440', 'Farah Diba', null, 1938, null, 'Impératrice d''Iran, troisième épouse du shah', 'Pahlavi', 490, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('155cbcc0-3627-5f1b-8223-7f5c271930ca', 'entry', '65c73c1c-5773-5e6f-b97d-d058f4e3a440', 'Fawzia d''Égypte', null, 1921, 2013, 'Première épouse du shah, princesse d''Égypte', 'Pahlavi', 0, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('013627df-f3ce-563e-80ba-7689fe5ecc77', 'entry', '65c73c1c-5773-5e6f-b97d-d058f4e3a440', 'Reza Pahlavi', null, 1960, null, 'Prince héritier, prétendant au trône', 'Pahlavi', 735, 1280, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('a743eefc-fe64-5e6d-b25c-5e3fa8246c69', '6e87c29c-1b84-5b14-ae94-7494ea73fcc7', 'parent');
  perform pg_temp.rel('a743eefc-fe64-5e6d-b25c-5e3fa8246c69', '6ce6af20-e872-5b04-9ddc-d2c47c9cc7c4', 'family');
  perform pg_temp.rel('6ce6af20-e872-5b04-9ddc-d2c47c9cc7c4', '30326bb6-7c56-57d9-8d44-386f06b92a3e', 'parent');
  perform pg_temp.rel('30326bb6-7c56-57d9-8d44-386f06b92a3e', '43e7550e-9641-5a77-88ce-f9527ee4fc0b', 'parent');
  perform pg_temp.rel('43e7550e-9641-5a77-88ce-f9527ee4fc0b', '2911a01a-d337-57cb-b114-00b3f54a28d1', 'parent');
  perform pg_temp.rel('2911a01a-d337-57cb-b114-00b3f54a28d1', '5eda482f-7fb4-59c1-b9f2-05f67127f813', 'parent');
  perform pg_temp.rel('5eda482f-7fb4-59c1-b9f2-05f67127f813', 'a6757017-b251-5e6e-919f-4511e206166f', 'parent');
  perform pg_temp.rel('a6757017-b251-5e6e-919f-4511e206166f', 'c96ca2fe-8539-5546-8fbd-7080d5e9fef8', 'parent');
  perform pg_temp.rel('2911a01a-d337-57cb-b114-00b3f54a28d1', '35ca6a39-b543-5aa1-96ef-cf750818f84d', 'family');
  perform pg_temp.rel('cb95d341-e4e8-5b4e-a844-1097689d826d', '6ec1cc2c-b426-5f33-972b-f27a64f7476d', 'parent');
  perform pg_temp.rel('6ec1cc2c-b426-5f33-972b-f27a64f7476d', '372a762b-c3d0-50a0-99f8-f57fba6656a1', 'parent');
  perform pg_temp.rel('372a762b-c3d0-50a0-99f8-f57fba6656a1', 'ff8be811-91cd-5fdb-8b6c-a02c7ea3b383', 'parent');
  perform pg_temp.rel('ff8be811-91cd-5fdb-8b6c-a02c7ea3b383', 'd0610f4f-4ab6-531c-906f-93a7a90b60dd', 'parent');
  perform pg_temp.rel('e63af3da-5619-585f-99f0-23705eea6551', '9b201f58-569e-5583-94d2-6483dbfc87c5', 'parent');
  perform pg_temp.rel('9b201f58-569e-5583-94d2-6483dbfc87c5', 'a0a835c5-8385-558d-8aa3-987ae15e21cd', 'parent');
  perform pg_temp.rel('a0a835c5-8385-558d-8aa3-987ae15e21cd', '7b275930-0496-5a6d-a32e-d7017224aa8a', 'parent');
  perform pg_temp.rel('7b275930-0496-5a6d-a32e-d7017224aa8a', 'dd118635-9641-5ef0-bd4c-d277f42c3d25', 'parent');
  perform pg_temp.rel('d0610f4f-4ab6-531c-906f-93a7a90b60dd', 'e63af3da-5619-585f-99f0-23705eea6551', 'family');
  perform pg_temp.rel('7b275930-0496-5a6d-a32e-d7017224aa8a', 'c953e913-891f-5b9e-b7d6-c697a9c956eb', 'family');
  perform pg_temp.rel('0791ac01-f8fd-588e-a006-86dacd22af1b', '8ea9c0c9-5214-55fd-ae57-271264b68ca1', 'parent');
  perform pg_temp.rel('8ea9c0c9-5214-55fd-ae57-271264b68ca1', '9c4b7bb5-1e0a-502b-a055-7f7e40aee225', 'parent');
  perform pg_temp.rel('9c4b7bb5-1e0a-502b-a055-7f7e40aee225', '041b1b67-2233-5048-b0a7-6cda65051074', 'parent');
  perform pg_temp.rel('9c4b7bb5-1e0a-502b-a055-7f7e40aee225', '58edca92-4bef-5f06-be81-6cf2b34db815', 'parent');
  perform pg_temp.rel('58edca92-4bef-5f06-be81-6cf2b34db815', 'b255f8c7-9132-57e9-bd6a-7863e1508efa', 'parent');
  perform pg_temp.rel('b255f8c7-9132-57e9-bd6a-7863e1508efa', 'a5c7676f-06fa-53b2-9071-6d9e721cd888', 'parent');
  perform pg_temp.rel('a5c7676f-06fa-53b2-9071-6d9e721cd888', '1fd616dd-faa9-5b5b-8467-93daef6dfd8e', 'parent');
  perform pg_temp.rel('1fd616dd-faa9-5b5b-8467-93daef6dfd8e', '802b54af-321d-5961-abb8-f3565781df8b', 'parent');
  perform pg_temp.rel('802b54af-321d-5961-abb8-f3565781df8b', 'e88ab996-7af5-503e-940c-4fc33f690aa9', 'parent');
  perform pg_temp.rel('e88ab996-7af5-503e-940c-4fc33f690aa9', 'd823ed07-4675-553e-95ef-6fc2866d5903', 'parent');
  perform pg_temp.rel('d823ed07-4675-553e-95ef-6fc2866d5903', '49ffc8f3-a050-56ff-889c-2fada921b0cf', 'parent');
  perform pg_temp.rel('49ffc8f3-a050-56ff-889c-2fada921b0cf', '304cc8a6-e084-50c4-9f32-77674cbe3430', 'parent');
  perform pg_temp.rel('bbd673a6-bbb1-5391-a7f2-3024e5ec2b80', '233f297d-a6cb-5cc5-b855-8bc754d5ec0c', 'parent');
  perform pg_temp.rel('e23e5175-3cc5-52ef-b006-a93388ca8f2d', '233f297d-a6cb-5cc5-b855-8bc754d5ec0c', 'family');
  perform pg_temp.rel('e23e5175-3cc5-52ef-b006-a93388ca8f2d', 'bbd673a6-bbb1-5391-a7f2-3024e5ec2b80', 'family');
  perform pg_temp.rel('233f297d-a6cb-5cc5-b855-8bc754d5ec0c', '463663fa-ddc0-593d-99f4-685ab2906044', 'parent');
  perform pg_temp.rel('463663fa-ddc0-593d-99f4-685ab2906044', 'ada2492b-1d98-558e-8751-ae612e79d946', 'parent');
  perform pg_temp.rel('ada2492b-1d98-558e-8751-ae612e79d946', '90970ffc-98fc-5b0c-82f2-8041bbacafd3', 'parent');
  perform pg_temp.rel('90970ffc-98fc-5b0c-82f2-8041bbacafd3', 'e18ee7ea-ac9c-5d24-84d2-f3f5f89b4776', 'parent');
  perform pg_temp.rel('e18ee7ea-ac9c-5d24-84d2-f3f5f89b4776', 'bb5df395-584e-5af5-af08-a40961a560a8', 'parent');
  perform pg_temp.rel('bb5df395-584e-5af5-af08-a40961a560a8', '7fdd69c3-d574-5ed7-8296-aea9ddd9fa0a', 'parent');
  perform pg_temp.rel('ddfcbf96-3455-5a8d-8845-5af644f64a8e', '55884d5e-2bed-56ef-8326-fd5cea678bb3', 'parent');
  perform pg_temp.rel('55884d5e-2bed-56ef-8326-fd5cea678bb3', '155cbcc0-3627-5f1b-8223-7f5c271930ca', 'spouse');
  perform pg_temp.rel('55884d5e-2bed-56ef-8326-fd5cea678bb3', '759e55e7-fa63-51ba-b578-589e2f6e2dea', 'spouse');
  perform pg_temp.rel('55884d5e-2bed-56ef-8326-fd5cea678bb3', '370776ae-74d1-5a95-b3e8-c29455a2e5bb', 'spouse');
  perform pg_temp.rel('55884d5e-2bed-56ef-8326-fd5cea678bb3', '013627df-f3ce-563e-80ba-7689fe5ecc77', 'parent');
  perform pg_temp.rel('370776ae-74d1-5a95-b3e8-c29455a2e5bb', '013627df-f3ce-563e-80ba-7689fe5ecc77', 'parent');
  raise notice 'schema_v104 : % membres ajoutés.', 49;
end $$;
