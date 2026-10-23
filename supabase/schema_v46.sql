-- schema_v46.sql — Bulgarie — Krum, Asen, Chichman, Saxe-Cobourg-Gotha ; Basarab Ier ajouté en Valachie
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Crée sous Bulgarie > Dynastie : Krum (Krum -> Pierre Ier), Asen (Ivan Asen II, Kaliman Ier), Chichman (Ivan Alexandre -> Ivan Chichman), Saxe-Cobourg-Gotha (Ferdinand Ier -> Siméon II).
-- Prudence : les dates des khans/tsars du haut Moyen Âge ne sont pas dans les fiches Wikipédia ; elles sont laissées vides plutôt qu'inventées. Pas inclus : Asparoukh, Térvel, Samuel (Cométopoules), Terter (données insuffisantes).
-- Ajoute dans l'arbre Basarab (Roumanie) Basarab Ier et Nicolas Alexandre (père de Radu Ier) car Théodora de Valachie, épouse d'Ivan Alexandre, est la fille de Basarab Ier.
-- Branche de Saxe-Cobourg-Koháry : Ferdinand (père d'August), August et Clémentine d'Orléans sont créés dans l'arbre Wettin (origine), Ferdinand Ier de Bulgarie démarre l'arbre bulgare ; liens avec François de Saxe-Cobourg-Saalfeld (v38) si présent.
-- Anne-Marie (Hongrie) : Anne-Marie de Hongrie (impératrice de Bulgarie) est créée dans Árpád ; Marie-Louise de Bourbon-Parme dans Bourbon-Parme.
-- Prérequis : v44 exécuté.
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
  if exists (select 1 from public.genealogy_members where id = '3a415b95-e9e3-5b4a-aed8-3e026ef3fa5f') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('1e63ace8-3da8-5085-adeb-45106d4bd4c0','28ec5941-c762-55eb-9a3e-9707bec8f6bb','86246879-dacc-4537-a5ef-6328904b270e','a96af6de-f8df-5c9a-b57f-09098767493f','ba471bbc-8c8f-57bb-aa0c-be76147406f7');
  if k <> 5 then raise exception 'Membres préexistants manquants (% sur 5) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Krum » (BGR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'BGR' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour BGR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Krum';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('082f4bf6-63dc-5aac-abd7-1ecec5dbc69b', cat_id, 'country', 'BGR', top, 'Krum', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '082f4bf6-63dc-5aac-abd7-1ecec5dbc69b';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('0a72b913-7a9e-52cf-8758-69cca71db95b', 'country', 'BGR', 'genealogy', 'Krum', cat_id, sec, admin_id);
  -- Arbre « Asen » (BGR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'BGR' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour BGR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Asen';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('b96b9f5e-fb16-5aec-86d0-a1c0c21e420d', cat_id, 'country', 'BGR', top, 'Asen', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'b96b9f5e-fb16-5aec-86d0-a1c0c21e420d';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 'country', 'BGR', 'genealogy', 'Asen', cat_id, sec, admin_id);
  -- Arbre « Chichman » (BGR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'BGR' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour BGR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Chichman';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('c525edb8-b4ec-5f08-9767-d98c89438269', cat_id, 'country', 'BGR', top, 'Chichman', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'c525edb8-b4ec-5f08-9767-d98c89438269';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('34b77462-0e0c-59cc-a278-220823c60067', 'country', 'BGR', 'genealogy', 'Chichman', cat_id, sec, admin_id);
  -- Arbre « Saxe-Cobourg-Gotha » (BGR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'BGR' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour BGR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Saxe-Cobourg-Gotha';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('e20f218c-53ab-5260-bd0b-a4b466107a04', cat_id, 'country', 'BGR', top, 'Saxe-Cobourg-Gotha', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'e20f218c-53ab-5260-bd0b-a4b466107a04';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 'country', 'BGR', 'genealogy', 'Saxe-Cobourg-Gotha', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = '7d2f1543-40e3-584d-9b74-ac8a83012bb0' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Basarab introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '6b135504-fb3a-5323-b9d6-a131fc52ea64' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Árpád introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '309f20ea-3b5d-453b-87f9-286b7f1e6c60' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Wettin introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '84c9f117-4375-499a-8634-b87e7515ec6a' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison de Bourbon-Parme introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '786a379d-20c7-446b-922a-af4beb086251' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Bourbon-Orléans introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3a415b95-e9e3-5b4a-aed8-3e026ef3fa5f', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Basarab Ier le Fondateur', null, 1270, 1352, 'Voïvode de Valachie (v. 1310-1352)', 'Basarab', 1146, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0757a149-9003-58ed-94a8-55c94dcbbafc', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 'Nicolas Alexandre de Valachie', null, null, 1364, 'Voïvode de Valachie (1352-1364)', 'Basarab', 941, 585, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('442d8814-0367-5532-b1a7-bc2f01010a67', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Krum', null, null, 814, 'Khan de Bulgarie (v. 803-814)', 'Krum', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f50fa150-8051-5a38-b9a2-acc79937578a', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Omourtag', null, null, 831, 'Khan de Bulgarie (814-831)', 'Krum', 0, 540, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d39ce982-b84f-50d1-91ea-5d6e68d174b7', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Boris Ier', null, null, 907, 'Knèze de Bulgarie (852-889), christianise la Bulgarie', 'Krum', 120, 1350, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('51083024-15ba-53ee-81b4-55f160a1c5a2', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Maria (épouse de Boris Ier)', null, null, null, 'Princesse de Bulgarie', 'Origine inconnue', 660, 1350, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9c7ad2d4-7814-5077-91b1-b80ae6f46059', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Siméon Ier le Grand', null, 864, 927, 'Knèze puis premier tsar de Bulgarie (893-927)', 'Krum', 390, 1962, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('70f78979-070d-586e-9fa7-ad62eb1ea3d4', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Maria Sursuvoul (épouse de Siméon Ier)', null, null, null, 'Tsarine de Bulgarie', 'Sursuvoul (noblesse bulgare)', 930, 1962, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aafcd9a8-3eef-56f2-9d9b-619b71d18abb', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Pierre Ier de Bulgarie', null, null, 970, 'Tsar de Bulgarie (927-969)', 'Krum', 660, 2826, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7a6f0c3c-c256-5183-be38-2c4c2c78c401', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Irène Lécapène (Maria)', null, null, null, 'Tsarine de Bulgarie', 'Lécapène (Byzance)', 1040, 2826, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('37c8c29c-0573-5fac-9ed7-5a2d3c99d47e', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 'Ivan Asen II', null, null, 1241, 'Tsar de Bulgarie (1218-1241)', 'Asen', 540, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f2b2fe73-515d-5ef7-a650-f5479d515f6d', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 'Anne-Marie de Hongrie (impératrice de Bulgarie)', null, 1203, null, 'Tsarine de Bulgarie', 'Árpád', 540, 6592, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8efec647-51a7-5073-a9ab-c9146a28449b', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 'Irène Comnène Doukas', null, null, null, 'Tsarine de Bulgarie', 'Doukas (Épire)', 920, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4a442e40-84d6-578f-ad83-fea3518acb37', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 'Kaliman Ier Asen', null, 1234, 1246, 'Tsar de Bulgarie (1241-1246)', 'Asen', 270, 720, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('da935432-8ffb-5434-959d-c2cb6e130d9e', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 'Ivan Alexandre', null, null, 1371, 'Tsar de Bulgarie (1331-1371)', 'Chichman', 1303, 558, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ddc60b67-d62a-5419-9f61-e10bf8227483', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 'Théodora de Valachie (Théophane)', null, null, null, 'Tsarine de Bulgarie (répudiée vers 1349)', 'Basarab', 0, 558, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2989a941-71dc-5d94-937d-6951289fe316', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 'Sarah-Théodora', null, null, null, 'Tsarine de Bulgarie', 'Origine juive convertie', 2400, 558, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bed0f6f7-104b-5a4f-84b0-83b74fa70c7c', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 'Michel Asen IV', null, 1322, 1355, 'Co-tsar de Bulgarie', 'Chichman', 242, 1089, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fa785a13-2507-5f82-b1cb-9cb239a2606e', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 'Ivan Asen IV', null, 1326, 1349, 'Co-tsar de Bulgarie', 'Chichman', 1062, 1089, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7210ef6c-b8b3-5423-a686-4e3845df557d', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 'Ivan Sratsimir', null, 1324, 1394, 'Tsar de Vidin', 'Chichman', 652, 1089, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e7974fe1-0552-5358-b2f4-135dd0d7e6e1', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 'Ivan Chichman', null, 1350, 1395, 'Tsar de Bulgarie (1371-1395)', 'Chichman', 1852, 1089, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('340ddfac-8ec9-570a-ad62-0bd13c45d01a', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 'Kira Maria (épouse d''Ivan Chichman)', null, null, null, 'Tsarine de Bulgarie', 'Origine bulgare', 2232, 1089, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4db92756-efa0-5e81-8ead-8b72213cc88a', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 'Dragana Lazarević', null, null, null, 'Tsarine de Bulgarie', 'Lazarević (Serbie)', 1472, 1089, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c7175bc4-24f1-504f-a999-eee188b642e8', 'entry', '309f20ea-3b5d-453b-87f9-286b7f1e6c60', 'Ferdinand de Saxe-Cobourg-Koháry', null, 1785, 1851, 'Prince de Saxe-Cobourg-Koháry', 'Wettin (Saxe-Cobourg)', 66000, 14130, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('65be4e9f-81a0-5da5-8ebb-da330afc7899', 'entry', '309f20ea-3b5d-453b-87f9-286b7f1e6c60', 'Marie-Antonie Koháry', null, 1797, 1862, 'Princesse de Saxe-Cobourg-Koháry', 'Koháry (Hongrie)', 66340, 14346, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b8df005e-22ce-5c01-9c69-abf7bb652fcf', 'entry', '309f20ea-3b5d-453b-87f9-286b7f1e6c60', 'August de Saxe-Cobourg et Gotha', null, 1818, 1881, 'Prince, père de Ferdinand Ier de Bulgarie', 'Wettin (Saxe-Cobourg-Koháry)', 66680, 14724, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('54141293-68a2-55b0-9869-d1bd277e7126', 'entry', '786a379d-20c7-446b-922a-af4beb086251', 'Clémentine d''Orléans', null, 1817, 1907, 'Princesse de Saxe-Cobourg et Gotha', 'Bourbon-Orléans', 66000, 14706, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('67f616b3-8dad-5657-9fd6-0aec3c51b2c3', 'entry', '4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 'Ferdinand Ier de Bulgarie', null, 1861, 1948, 'Prince (1887) puis tsar de Bulgarie (1908-1918)', 'Saxe-Cobourg-Gotha (Koháry)', 432, 774, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c419e705-7c40-5bf1-8cfe-8ca23a46de6b', 'entry', '84c9f117-4375-499a-8634-b87e7515ec6a', 'Marie-Louise de Bourbon-Parme', null, 1870, 1899, 'Princesse de Bulgarie', 'Bourbon-Parme', 66000, 15660, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ae405441-cd62-5268-8e24-d91efdb26af9', 'entry', '4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 'Éléonore Reuss de Köstritz', null, 1860, 1917, 'Tsarine de Bulgarie', 'Reuss', 52, 774, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('eef7d0b9-018d-57f9-b522-32eb255f28b2', 'entry', '4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 'Boris III de Bulgarie', null, 1894, 1943, 'Tsar de Bulgarie (1918-1943)', 'Saxe-Cobourg-Gotha (Koháry)', 485, 1395, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('30594506-0311-5870-8725-653f3036a879', 'entry', '4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 'Cyrille de Bulgarie', null, 1895, 1945, 'Prince de Preslav, régent (1943-1944)', 'Saxe-Cobourg-Gotha (Koháry)', 895, 1395, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d9c16e7f-c96a-5339-aa7b-f91a13b27ccd', 'entry', '4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 'Jeanne de Savoie (Giovanna)', null, 1907, 2000, 'Tsarine de Bulgarie', 'Savoie', 0, 1395, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9d2c6f89-65fa-5f01-be04-37ae7588c0e8', 'entry', '4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 'Siméon II de Bulgarie', null, 1937, null, 'Tsar de Bulgarie (1943-1946), Premier ministre (2001-2005)', 'Saxe-Cobourg-Gotha (Koháry)', 447, 2124, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e18c17d8-e60d-51b9-8a68-62c0aa445ed1', 'entry', '4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 'Margarita Gómez-Acebo', null, 1935, null, 'Épouse de Siméon II', 'Gómez-Acebo (Espagne)', 827, 2124, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e7f31ee3-8d65-5a35-b9e9-e7e9ffc47956', 'entry', '4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 'Marie-Louise de Bulgarie', null, 1933, null, 'Princesse de Bulgarie', 'Saxe-Cobourg-Gotha (Koháry)', 37, 2124, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('3a415b95-e9e3-5b4a-aed8-3e026ef3fa5f', '0757a149-9003-58ed-94a8-55c94dcbbafc', 'parent');
  perform pg_temp.rel('0757a149-9003-58ed-94a8-55c94dcbbafc', 'ba471bbc-8c8f-57bb-aa0c-be76147406f7', 'parent');
  perform pg_temp.rel('442d8814-0367-5532-b1a7-bc2f01010a67', 'f50fa150-8051-5a38-b9a2-acc79937578a', 'parent');
  perform pg_temp.rel('f50fa150-8051-5a38-b9a2-acc79937578a', 'd39ce982-b84f-50d1-91ea-5d6e68d174b7', 'family');
  perform pg_temp.rel('d39ce982-b84f-50d1-91ea-5d6e68d174b7', '51083024-15ba-53ee-81b4-55f160a1c5a2', 'spouse');
  perform pg_temp.rel('d39ce982-b84f-50d1-91ea-5d6e68d174b7', '9c7ad2d4-7814-5077-91b1-b80ae6f46059', 'parent');
  perform pg_temp.rel('51083024-15ba-53ee-81b4-55f160a1c5a2', '9c7ad2d4-7814-5077-91b1-b80ae6f46059', 'parent');
  perform pg_temp.rel('9c7ad2d4-7814-5077-91b1-b80ae6f46059', '70f78979-070d-586e-9fa7-ad62eb1ea3d4', 'spouse');
  perform pg_temp.rel('9c7ad2d4-7814-5077-91b1-b80ae6f46059', 'aafcd9a8-3eef-56f2-9d9b-619b71d18abb', 'parent');
  perform pg_temp.rel('70f78979-070d-586e-9fa7-ad62eb1ea3d4', 'aafcd9a8-3eef-56f2-9d9b-619b71d18abb', 'parent');
  perform pg_temp.rel('aafcd9a8-3eef-56f2-9d9b-619b71d18abb', '7a6f0c3c-c256-5183-be38-2c4c2c78c401', 'spouse');
  perform pg_temp.rel('1e63ace8-3da8-5085-adeb-45106d4bd4c0', 'f2b2fe73-515d-5ef7-a650-f5479d515f6d', 'parent');
  perform pg_temp.rel('a96af6de-f8df-5c9a-b57f-09098767493f', 'f2b2fe73-515d-5ef7-a650-f5479d515f6d', 'parent');
  perform pg_temp.rel('37c8c29c-0573-5fac-9ed7-5a2d3c99d47e', 'f2b2fe73-515d-5ef7-a650-f5479d515f6d', 'spouse');
  perform pg_temp.rel('37c8c29c-0573-5fac-9ed7-5a2d3c99d47e', '8efec647-51a7-5073-a9ab-c9146a28449b', 'spouse');
  perform pg_temp.rel('37c8c29c-0573-5fac-9ed7-5a2d3c99d47e', '4a442e40-84d6-578f-ad83-fea3518acb37', 'parent');
  perform pg_temp.rel('f2b2fe73-515d-5ef7-a650-f5479d515f6d', '4a442e40-84d6-578f-ad83-fea3518acb37', 'parent');
  perform pg_temp.rel('3a415b95-e9e3-5b4a-aed8-3e026ef3fa5f', 'ddc60b67-d62a-5419-9f61-e10bf8227483', 'parent');
  perform pg_temp.rel('da935432-8ffb-5434-959d-c2cb6e130d9e', 'ddc60b67-d62a-5419-9f61-e10bf8227483', 'spouse');
  perform pg_temp.rel('da935432-8ffb-5434-959d-c2cb6e130d9e', '2989a941-71dc-5d94-937d-6951289fe316', 'spouse');
  perform pg_temp.rel('da935432-8ffb-5434-959d-c2cb6e130d9e', 'bed0f6f7-104b-5a4f-84b0-83b74fa70c7c', 'parent');
  perform pg_temp.rel('ddc60b67-d62a-5419-9f61-e10bf8227483', 'bed0f6f7-104b-5a4f-84b0-83b74fa70c7c', 'parent');
  perform pg_temp.rel('da935432-8ffb-5434-959d-c2cb6e130d9e', 'fa785a13-2507-5f82-b1cb-9cb239a2606e', 'parent');
  perform pg_temp.rel('ddc60b67-d62a-5419-9f61-e10bf8227483', 'fa785a13-2507-5f82-b1cb-9cb239a2606e', 'parent');
  perform pg_temp.rel('da935432-8ffb-5434-959d-c2cb6e130d9e', '7210ef6c-b8b3-5423-a686-4e3845df557d', 'parent');
  perform pg_temp.rel('ddc60b67-d62a-5419-9f61-e10bf8227483', '7210ef6c-b8b3-5423-a686-4e3845df557d', 'parent');
  perform pg_temp.rel('da935432-8ffb-5434-959d-c2cb6e130d9e', 'e7974fe1-0552-5358-b2f4-135dd0d7e6e1', 'parent');
  perform pg_temp.rel('2989a941-71dc-5d94-937d-6951289fe316', 'e7974fe1-0552-5358-b2f4-135dd0d7e6e1', 'parent');
  perform pg_temp.rel('e7974fe1-0552-5358-b2f4-135dd0d7e6e1', '340ddfac-8ec9-570a-ad62-0bd13c45d01a', 'spouse');
  perform pg_temp.rel('e7974fe1-0552-5358-b2f4-135dd0d7e6e1', '4db92756-efa0-5e81-8ead-8b72213cc88a', 'spouse');
  perform pg_temp.rel('c7175bc4-24f1-504f-a999-eee188b642e8', '65be4e9f-81a0-5da5-8ebb-da330afc7899', 'spouse');
  perform pg_temp.rel('c7175bc4-24f1-504f-a999-eee188b642e8', 'b8df005e-22ce-5c01-9c69-abf7bb652fcf', 'parent');
  perform pg_temp.rel('65be4e9f-81a0-5da5-8ebb-da330afc7899', 'b8df005e-22ce-5c01-9c69-abf7bb652fcf', 'parent');
  perform pg_temp.rel('b8df005e-22ce-5c01-9c69-abf7bb652fcf', '54141293-68a2-55b0-9869-d1bd277e7126', 'spouse');
  perform pg_temp.rel('86246879-dacc-4537-a5ef-6328904b270e', '54141293-68a2-55b0-9869-d1bd277e7126', 'parent');
  perform pg_temp.rel('b8df005e-22ce-5c01-9c69-abf7bb652fcf', '67f616b3-8dad-5657-9fd6-0aec3c51b2c3', 'parent');
  perform pg_temp.rel('54141293-68a2-55b0-9869-d1bd277e7126', '67f616b3-8dad-5657-9fd6-0aec3c51b2c3', 'parent');
  perform pg_temp.rel('67f616b3-8dad-5657-9fd6-0aec3c51b2c3', 'c419e705-7c40-5bf1-8cfe-8ca23a46de6b', 'spouse');
  perform pg_temp.rel('67f616b3-8dad-5657-9fd6-0aec3c51b2c3', 'ae405441-cd62-5268-8e24-d91efdb26af9', 'spouse');
  perform pg_temp.rel('28ec5941-c762-55eb-9a3e-9707bec8f6bb', 'c419e705-7c40-5bf1-8cfe-8ca23a46de6b', 'parent');
  perform pg_temp.rel('67f616b3-8dad-5657-9fd6-0aec3c51b2c3', 'eef7d0b9-018d-57f9-b522-32eb255f28b2', 'parent');
  perform pg_temp.rel('c419e705-7c40-5bf1-8cfe-8ca23a46de6b', 'eef7d0b9-018d-57f9-b522-32eb255f28b2', 'parent');
  perform pg_temp.rel('67f616b3-8dad-5657-9fd6-0aec3c51b2c3', '30594506-0311-5870-8725-653f3036a879', 'parent');
  perform pg_temp.rel('c419e705-7c40-5bf1-8cfe-8ca23a46de6b', '30594506-0311-5870-8725-653f3036a879', 'parent');
  perform pg_temp.rel('eef7d0b9-018d-57f9-b522-32eb255f28b2', 'd9c16e7f-c96a-5339-aa7b-f91a13b27ccd', 'spouse');
  perform pg_temp.rel('eef7d0b9-018d-57f9-b522-32eb255f28b2', '9d2c6f89-65fa-5f01-be04-37ae7588c0e8', 'parent');
  perform pg_temp.rel('d9c16e7f-c96a-5339-aa7b-f91a13b27ccd', '9d2c6f89-65fa-5f01-be04-37ae7588c0e8', 'parent');
  perform pg_temp.rel('eef7d0b9-018d-57f9-b522-32eb255f28b2', 'e7f31ee3-8d65-5a35-b9e9-e7e9ffc47956', 'parent');
  perform pg_temp.rel('d9c16e7f-c96a-5339-aa7b-f91a13b27ccd', 'e7f31ee3-8d65-5a35-b9e9-e7e9ffc47956', 'parent');
  perform pg_temp.rel('9d2c6f89-65fa-5f01-be04-37ae7588c0e8', 'e18c17d8-e60d-51b9-8a68-62c0aa445ed1', 'spouse');
  select id into ext from public.genealogy_members where name = 'François de Saxe-Cobourg-Saalfeld' and birth_year = 1750 limit 1;
  if ext is not null then perform pg_temp.rel(ext, 'c7175bc4-24f1-504f-a999-eee188b642e8', 'parent'); else raise notice 'Membre introuvable (script précédent non exécuté ?) : François de Saxe-Cobourg-Saalfeld'; end if;
  update public.genealogy_members set pos_x = 941, pos_y = 1045 where id = 'ba471bbc-8c8f-57bb-aa0c-be76147406f7';
  update public.genealogy_members set pos_x = 1481, pos_y = 1045 where id = 'db120f8a-ba57-5565-9a08-9253a235f169';
  update public.genealogy_members set pos_x = 1211, pos_y = 1530 where id = '88288e5a-9f96-5e36-b128-9adb1fde0dd8';
  update public.genealogy_members set pos_x = 1416, pos_y = 2250 where id = '684a5f1a-f6cd-5a99-a8a0-b82fae54e21e';
  update public.genealogy_members set pos_x = 1006, pos_y = 2250 where id = 'e97e750b-3665-59c8-96c2-01c14b4761e7';
  update public.genealogy_members set pos_x = 0, pos_y = 2916 where id = '1c53c87c-cdf3-5733-9662-20f02239de04';
  update public.genealogy_members set pos_x = 410, pos_y = 2916 where id = '80222dc6-5a10-5d3f-9661-9e27ee9e711f';
  update public.genealogy_members set pos_x = 820, pos_y = 2916 where id = '1d2635ef-f680-51d8-bee2-a2f3329c26dc';
  update public.genealogy_members set pos_x = 1230, pos_y = 2916 where id = 'd0088211-27f9-5a4b-9e93-77c2d0e5c344';
  update public.genealogy_members set pos_x = 410, pos_y = 3456 where id = '4cd91562-2f8b-540e-bf61-eb67bad04d2b';
  update public.genealogy_members set pos_x = 2010, pos_y = 7052 where id = '6b02edd7-cb43-587a-aa90-49a308cc77a4';
  update public.genealogy_members set pos_x = 4566, pos_y = 3627 where id = '91f0879a-49ca-51e7-a0a8-6cf4ecca007c';
  update public.genealogy_members set pos_x = 6626, pos_y = 6132 where id = '75981043-2cdf-54c9-b908-350361244628';
  update public.genealogy_members set pos_x = 6029, pos_y = 0 where id = '71c7c081-5a4b-5610-8294-1ed68fe055dc';
  update public.genealogy_members set pos_x = 6029, pos_y = 630 where id = '734cb1d9-baf3-5f36-9e2d-372271bd5aae';
  update public.genealogy_members set pos_x = 6029, pos_y = 1548 where id = 'e7d52c67-ed06-5779-92cf-b08356126ac4';
  update public.genealogy_members set pos_x = 5555, pos_y = 2008 where id = '3bf23b47-c787-5d4a-a136-1a7231c82b83';
  update public.genealogy_members set pos_x = 5555, pos_y = 2468 where id = '34c736b5-3af9-5098-8a53-ea895f44b353';
  update public.genealogy_members set pos_x = 6504, pos_y = 2008 where id = '79af3137-bb0e-5ae1-8b6f-dc2217fca481';
  update public.genealogy_members set pos_x = 7044, pos_y = 2008 where id = '6f721d86-189e-592d-8e7e-825128e78c1e';
  update public.genealogy_members set pos_x = 6774, pos_y = 2468 where id = '3f61ae3b-5578-5a77-9b34-1f2268dd9dd6';
  update public.genealogy_members set pos_x = 7044, pos_y = 2928 where id = '9f663e00-4a40-54c1-b1ca-52ece92ad8c7';
  update public.genealogy_members set pos_x = 5041, pos_y = 3069 where id = '821834ed-aa61-5bfa-af81-26ec23775e57';
  update public.genealogy_members set pos_x = 6069, pos_y = 3069 where id = '4c046e90-0c86-51b4-b8cf-df9a08982be4';
  update public.genealogy_members set pos_x = 4976, pos_y = 3627 where id = '6347c78d-9767-59ab-a19b-d091216a70f4';
  update public.genealogy_members set pos_x = 6556, pos_y = 3529 where id = 'f976cbcc-65de-5b82-bed6-9b45d16bbfa7';
  update public.genealogy_members set pos_x = 7376, pos_y = 3529 where id = '39980f61-2815-5123-9356-b7d2e54a9435';
  update public.genealogy_members set pos_x = 6146, pos_y = 3529 where id = '98734619-09ab-5792-a975-5a120acdf8a1';
  update public.genealogy_members set pos_x = 5766, pos_y = 3529 where id = 'd6b79db2-871d-5b58-b025-b7d5ca20e6fe';
  update public.genealogy_members set pos_x = 6491, pos_y = 4050 where id = '2a89ac1d-9ee6-52a8-af4b-50fdb121f81b';
  update public.genealogy_members set pos_x = 7031, pos_y = 4050 where id = '3e145ffa-5cdc-5e8e-9010-8c7098a158e1';
  update public.genealogy_members set pos_x = 7441, pos_y = 4050 where id = '2eaef7e5-0475-54f5-8559-246f4f23d283';
  update public.genealogy_members set pos_x = 6761, pos_y = 4608 where id = 'ecc0199c-e713-5dfe-b277-066621820a2e';
  update public.genealogy_members set pos_x = 7711, pos_y = 4752 where id = '366ebb9c-0c0f-5a71-9493-f341f3a0884c';
  update public.genealogy_members set pos_x = 8481, pos_y = 4752 where id = 'a8d3dfcd-685a-5385-af2c-b0532a1c8647';
  update public.genealogy_members set pos_x = 7686, pos_y = 5212 where id = 'd7e03ffd-6567-5991-8a83-92a9b4b95b10';
  update public.genealogy_members set pos_x = 8096, pos_y = 5212 where id = '03b0b8c9-5b60-5bb0-8fa9-2156815b1894';
  update public.genealogy_members set pos_x = 8506, pos_y = 5212 where id = '0d2fd6cf-a454-5dac-8eea-047f2caa103a';
  update public.genealogy_members set pos_x = 7088, pos_y = 5672 where id = 'f2af0350-d7bc-5d97-adfe-a8c62b6fd325';
  update public.genealogy_members set pos_x = 6298, pos_y = 5672 where id = 'cde68ecd-711a-5a01-85cc-6865bee8da2a';
  update public.genealogy_members set pos_x = 4103, pos_y = 5672 where id = 'bfbc556e-5fcf-599f-8fa7-58144ef7896a';
  update public.genealogy_members set pos_x = 7036, pos_y = 6132 where id = '87edcc18-3115-569b-b2ea-fd40f172fd60';
  update public.genealogy_members set pos_x = 7306, pos_y = 6592 where id = '75b05532-7429-528e-8db1-6e465b0c7614';
  update public.genealogy_members set pos_x = 3365, pos_y = 6132 where id = '1e63ace8-3da8-5085-adeb-45106d4bd4c0';
  update public.genealogy_members set pos_x = 761, pos_y = 6132 where id = 'a96af6de-f8df-5c9a-b57f-09098767493f';
  update public.genealogy_members set pos_x = 4626, pos_y = 6132 where id = '5f7f6f8b-6fcc-5a4e-bb51-0370a14523a0';
  update public.genealogy_members set pos_x = 5446, pos_y = 6132 where id = '4d093e2e-c9fc-51c8-bc6c-e25070801712';
  update public.genealogy_members set pos_x = 3176, pos_y = 6592 where id = 'a43466a4-a460-5c0e-8eb5-acc2f3e599a0';
  update public.genealogy_members set pos_x = 1632, pos_y = 6592 where id = 'ae269912-dea3-5c4d-92a4-a3b79695f715';
  update public.genealogy_members set pos_x = 3586, pos_y = 6592 where id = '83bb1cf6-2be1-57f3-805d-2fa67cb76d5a';
  update public.genealogy_members set pos_x = 4406, pos_y = 6592 where id = '55006732-51dd-5c23-89db-6efc96a811b9';
  update public.genealogy_members set pos_x = 4946, pos_y = 6592 where id = 'bbf1df8c-7bc6-5d3d-95f0-cb940fdb4c45';
  update public.genealogy_members set pos_x = 1220, pos_y = 7052 where id = 'd0faa107-b940-51cf-b6d4-1a303c72bfc3';
  update public.genealogy_members set pos_x = 3588, pos_y = 7052 where id = '455ec573-e785-5b8e-ac11-5f4020b45786';
  update public.genealogy_members set pos_x = 2420, pos_y = 7052 where id = '4b5e5128-ad23-5f7c-9513-2107e0ab51e1';
  update public.genealogy_members set pos_x = 2985, pos_y = 7052 where id = '7e28df95-44db-57cd-b0b0-1ae5f2001d2e';
  update public.genealogy_members set pos_x = 2908, pos_y = 7512 where id = 'bac0a74b-8395-59bf-8f23-c63f1a81ead0';
  update public.genealogy_members set pos_x = 2498, pos_y = 7512 where id = '48ab95bb-4c5f-5a1c-9125-433a02299f9f';
  update public.genealogy_members set pos_x = 2118, pos_y = 7512 where id = 'ffbadba6-ba5f-5bc7-9698-6a358ae6c827';
  update public.genealogy_members set pos_x = 4676, pos_y = 7560 where id = '8a956586-5f67-5ae5-80ff-52e2298cafbd';
  update public.genealogy_members set pos_x = 5056, pos_y = 7560 where id = 'e3458d9f-3f0b-5ea7-b60e-0d3a298998dc';
  update public.genealogy_members set pos_x = 7909, pos_y = 5672 where id = 'd00c84b0-2d28-5432-b1ba-842b177f57d6';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f2b2fe73-515d-5ef7-a650-f5479d515f6d', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 0, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('3a415b95-e9e3-5b4a-aed8-3e026ef3fa5f', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 0, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('b8df005e-22ce-5c01-9c69-abf7bb652fcf', 'entry', '4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 242, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('54141293-68a2-55b0-9869-d1bd277e7126', 'entry', '4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 622, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('c419e705-7c40-5bf1-8cfe-8ca23a46de6b', 'entry', '4bf1a7c8-09c0-5a8c-ad88-7f6bfbb8d763', 947, 774, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ddc60b67-d62a-5419-9f61-e10bf8227483', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 1351, 585, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('162c799a-80e8-5dab-a6d5-e482a58977a8', 'entry', '7d2f1543-40e3-584d-9b74-ac8a83012bb0', 224, 2250, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('37c8c29c-0573-5fac-9ed7-5a2d3c99d47e', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 0, 6592, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('4a442e40-84d6-578f-ad83-fea3518acb37', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 270, 7052, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('4bd527f1-995d-57b4-b2db-23422a974f8f', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 1630, 7052, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('1fb35d8e-0c0e-4218-bdfe-02b7e21890a9', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 4001, 3627, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('6ed2ddce-e33b-5d97-b28a-0cbfc17d69a2', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 4079, 4087, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('cb8a3583-efb4-5443-9723-56265411b88a', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 4489, 4087, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('86690abf-cd2c-4d1c-bdf2-607e9bca2fbc', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 5856, 6132, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('a8fe33f6-a0d1-4676-8482-bdc2c3f55d48', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 6241, 6592, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('b91542c6-ae4d-5ff0-b322-f22c01efd8b7', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 5831, 6592, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('63f4bfee-c6d2-5525-ac9d-9dfaff613946', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 6651, 6592, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('c5d2a162-d64c-5984-8c10-b000c1a36c5d', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 7314, 2468, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ef159026-4efd-5179-a453-e71b614d3bfc', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 4501, 3069, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('7f0acd64-868e-5ceb-8e6b-c4022434838a', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 5356, 3627, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('fb5bf6d6-72dd-5663-9cef-4199c2a5a0b8', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 6634, 3069, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('0f7efd69-bc4a-5b7e-820b-eb20c8aa508e', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 6111, 4050, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('63efab91-c3fa-5536-9e88-8ae2c572d611', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 7981, 4050, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('2c462983-6c55-5e9a-abb8-8b850d495dfe', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 6521, 5212, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('b77b3cfa-891b-57be-9b30-bea22079c416', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 7468, 5672, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('11f95acb-6951-5f9b-92cf-c98761ea7bd2', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 6678, 5672, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('c71cce09-317e-5313-bb05-ea49a9ab63d2', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 7576, 6132, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f66e6467-59b9-4bf4-9cd4-39d7d16cb1ef', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 3996, 6592, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('c75e9e3b-f9a7-5475-9142-d25ad79c0e07', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 680, 7052, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('21f7d97b-6d19-5c4e-a271-7f96414ec4b5', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 950, 7578, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ccb61e02-a9e4-4549-969c-2d47dacb9368', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 4128, 7052, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('d74bc2e8-5c68-5ada-9a8e-4570da7cc74a', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 3858, 7512, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ce881189-5e7b-5c9f-b739-4a087f6dfb93', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 4296, 7560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('963424ff-9412-55a8-9548-457164b0703f', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 3178, 7972, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('78d0b5aa-fd6c-53da-865e-7a5fbbaf2129', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 3448, 7512, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ab6f5fa5-56d2-5388-93ad-d50deb4fcc8e', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 8474, 5672, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('3ef5d262-004a-5e80-b340-55dcf5306217', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 8396, 6132, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('2dd3f89f-51b9-565a-819e-3210921623e6', 'entry', '6b135504-fb3a-5323-b9d6-a131fc52ea64', 7986, 6132, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v46 : % membres ajoutés.', 36;
end $$;
