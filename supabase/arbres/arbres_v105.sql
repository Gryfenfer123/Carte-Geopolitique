-- arbres_v105.sql — Égypte — Ptolémées et dynastie de Méhémet-Ali
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Deux nouveaux arbres pour l'Égypte (aucun n'existait) : « Ptolémées » et « Dynastie de Méhémet-Ali ». Fawzia d'Égypte (créée en v104 dans l'arbre Pahlavi) est affichée dans l'arbre de Méhémet-Ali et reliée à son père Fouad Ier ; son signalement « arbre à créer » est retiré. Rien n'est supprimé.
-- Dates : connues par ailleurs (histoire de l'Égypte), aucune page consultée pour ce lot. Années avant J.-C. en négatif ; plusieurs naissances ptolémaïques sont approximatives (signalé).
-- Particularité des Ptolémées : les mariages frère-sœur sont représentés par des liens « conjoint » ; Ptolémée XII est un fils illégitime de Ptolémée IX. Le père de Césarion (Jules César) n'est pas relié (arbre romain absent) : signalé.
-- Non fait : Fatimides, Ayyoubides, Mamelouks, Lagides secondaires, enfants cadets.
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
  if exists (select 1 from public.genealogy_members where id = 'aff5643c-95cb-5da3-b04f-4df0d8f489ba') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('155cbcc0-3627-5f1b-8223-7f5c271930ca');
  if k <> 1 then raise exception 'Membres préexistants manquants (% sur 1) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Ptolémées » (EGY)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'EGY' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour EGY : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Ptolémées';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('283af4b3-03de-5b78-9145-f9b40c9aef03', cat_id, 'country', 'EGY', top, 'Ptolémées', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '283af4b3-03de-5b78-9145-f9b40c9aef03';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'country', 'EGY', 'genealogy', 'Ptolémées', cat_id, sec, admin_id);
  -- Arbre « Dynastie de Méhémet-Ali » (EGY)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'EGY' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour EGY : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Dynastie de Méhémet-Ali';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('a28ff3f6-7a6b-5cd0-8b4e-5c934b3fa723', cat_id, 'country', 'EGY', top, 'Dynastie de Méhémet-Ali', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'a28ff3f6-7a6b-5cd0-8b4e-5c934b3fa723';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'country', 'EGY', 'genealogy', 'Dynastie de Méhémet-Ali', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = '65c73c1c-5773-5e6f-b97d-d058f4e3a440' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Pahlavi introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aff5643c-95cb-5da3-b04f-4df0d8f489ba', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée Ier Sôter', null, -367, -282, 'Fondateur de la dynastie lagide, roi d''Égypte (-305 à -283)', 'Ptolémées', 736, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('787f4c3c-f7c2-527b-b3c9-2fec8f89270f', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée II Philadelphe', null, -309, -246, 'Roi d''Égypte (-283 à -246)', 'Ptolémées', 736, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5b7aa8ec-616f-5a5b-a1e4-b3064e39249d', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Arsinoé II', null, -316, -270, 'Reine, épouse de Ptolémée II', 'Ptolémées', 246, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('379782c2-9751-5604-9e83-6eeb7e1329b2', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée III Évergète', null, -280, -222, 'Roi d''Égypte (-246 à -222)', 'Ptolémées', 736, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('430b2a40-4045-5f6f-9f76-481d3c0be918', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Bérénice II', null, -267, -221, 'Reine, épouse de Ptolémée III', 'Ptolémées', 246, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ec3bbbf4-ab9f-580a-ac04-ba6e44b7f2dd', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée IV Philopator', null, -244, -204, 'Roi d''Égypte (-221 à -204)', 'Ptolémées', 245, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1fae8295-dcb2-5ab8-91bd-43ec00fe7dc2', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Arsinoé III', null, -246, -204, 'Reine, épouse de Ptolémée IV', 'Ptolémées', 735, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('38c18d87-c5a1-5340-abbd-fa4d678076bc', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée V Épiphane', null, -210, -180, 'Roi d''Égypte (-204 à -180)', 'Ptolémées', 245, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1eebc7b4-9711-579d-9163-5ed56a928f58', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Cléopâtre Ire', null, -204, -176, 'Reine, régente (-180 à -176)', 'Ptolémées', 735, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3687ecaf-7227-5797-9c7e-0f026d5ccf9c', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée VI Philométor', null, -186, -145, 'Roi d''Égypte (-180 à -145)', 'Ptolémées', 0, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b6c0669e-8e3b-5dfe-b6f9-a6a6f51b4dd0', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée VIII Évergète II', null, -182, -116, 'Roi d''Égypte (-170 à -116)', 'Ptolémées', 980, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e0ab3c72-653a-5549-87e8-a2b72d9df82c', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Cléopâtre II', null, -185, -116, 'Reine, sœur et épouse de Ptolémée VI puis de Ptolémée VIII', 'Ptolémées', 490, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('60ef275f-70b7-5c28-bad9-6ac1e4bf09e1', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Cléopâtre III', null, -161, -101, 'Reine, fille de Ptolémée VI, épouse de Ptolémée VIII', 'Ptolémées', 1470, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('991cc390-7fb7-5d27-b979-da4adbc0de0d', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée IX Sôter II (Lathyros)', null, -143, -81, 'Roi d''Égypte (-116 à -107, -88 à -81)', 'Ptolémées', 1960, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('829430a0-d4f4-5662-b629-0170347bf788', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée X Alexandre Ier', null, -140, -88, 'Roi d''Égypte (-107 à -88)', 'Ptolémées', 1225, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('05cb7344-a765-5878-96c3-e9ceba2ae9b1', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée XII Aulète', null, -117, -51, 'Roi d''Égypte (-80 à -51), fils illégitime de Ptolémée IX', 'Ptolémées', 1960, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c0fcc188-dfd3-5f24-ac85-178905d67ec5', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Cléopâtre VII', null, -69, -30, 'Dernière reine d''Égypte (-51 à -30)', 'Ptolémées', 1712, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b4a97179-e012-5d98-b218-afa30a500239', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée XIII', null, -62, -47, 'Roi d''Égypte (-51 à -47), frère et époux de Cléopâtre VII', 'Ptolémées', 2202, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d7f3f108-6d41-5909-b326-d94c7a7920b1', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Arsinoé IV', null, -68, -41, 'Sœur de Cléopâtre VII, reine rivale (-48 à -47)', 'Ptolémées', 2702, 5760, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0c62635b-2148-5996-940c-46c7fca4a584', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée XIV', null, -59, -44, 'Roi d''Égypte (-47 à -44), frère et époux de Cléopâtre VII', 'Ptolémées', 1222, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f872691a-458f-55ed-9253-b188bbd920ca', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Ptolémée XV Césarion', null, -47, -30, 'Co-roi d''Égypte (-44 à -30), fils de Jules César', 'Ptolémées', 1962, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c114f332-7c10-5f19-9a86-ad1b176bbbce', 'entry', 'acd30242-6aa3-52d9-a439-3f7ec36fcbad', 'Cléopâtre Séléné II', null, -40, -6, 'Fille de Cléopâtre VII et d''Antoine, reine de Maurétanie', 'Ptolémées', 1462, 6400, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ff4f107b-2bed-541a-9a31-d0075441cfca', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Méhémet-Ali', null, 1769, 1849, 'Wali d''Égypte (1805-1848), fondateur de la dynastie', 'Dynastie de Méhémet-Ali', 1397, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4eb2d6bf-781c-5bfd-9335-ada42b2ca2f7', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Toussoun Pacha', null, 1794, 1816, 'Fils de Méhémet-Ali, père d''Abbas Ier', 'Dynastie de Méhémet-Ali', 1897, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f28e5ef2-6486-55f6-9e11-ce96c92d0a96', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Ibrahim Pacha', null, 1789, 1848, 'Wali d''Égypte (1848), conquérant de la Syrie', 'Dynastie de Méhémet-Ali', 897, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a7ae581e-07fa-5b3d-8ca0-023cae61d7c4', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Abbas Ier', null, 1813, 1854, 'Wali d''Égypte (1848-1854)', 'Dynastie de Méhémet-Ali', 1897, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ecf0c167-5176-5699-ba6a-3fc535f6ad98', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Saïd Pacha', null, 1822, 1863, 'Wali d''Égypte (1854-1863), concède le canal de Suez', 'Dynastie de Méhémet-Ali', 1397, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7f4e0d71-6f10-57ab-9f38-5d542af14541', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Ismaïl Pacha', null, 1830, 1895, 'Khédive d''Égypte (1863-1879)', 'Dynastie de Méhémet-Ali', 897, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('46ff9fe1-f3e1-557f-b0da-68cec8d84bdf', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Tewfik Pacha', null, 1852, 1892, 'Khédive d''Égypte (1879-1892)', 'Dynastie de Méhémet-Ali', 1726, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('17a6fb3c-c7fe-5209-b8be-1030432e5d80', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Abbas II Hilmi', null, 1874, 1944, 'Dernier khédive d''Égypte (1892-1914)', 'Dynastie de Méhémet-Ali', 1726, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('de95ea4e-6e74-55ec-8da3-2aa73f2db151', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Hussein Kamel', null, 1853, 1917, 'Sultan d''Égypte (1914-1917)', 'Dynastie de Méhémet-Ali', 236, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f37d770a-2174-5f78-9545-02346b07d8fe', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Fouad Ier', null, 1868, 1936, 'Sultan puis premier roi d''Égypte (1917-1936)', 'Dynastie de Méhémet-Ali', 736, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4a5d1226-bf5f-5644-9d75-9e9c457a75fe', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Nazli Sabri', null, 1894, 1978, 'Reine d''Égypte, épouse de Fouad Ier', 'Dynastie de Méhémet-Ali', 1226, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('706b8da7-3e0c-5a66-b62f-f261f70e6236', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Farouk Ier', null, 1920, 1965, 'Roi d''Égypte (1936-1952), déposé', 'Dynastie de Méhémet-Ali', 490, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('18667d75-1386-5953-bce7-53206b8473b1', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Farida Zulfikar', null, 1921, 1988, 'Première épouse de Farouk Ier', 'Dynastie de Méhémet-Ali', 980, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d8d12233-0a5e-51ea-a624-9cf522976ae0', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Narriman Sadek', null, 1934, 2005, 'Seconde épouse de Farouk Ier', 'Dynastie de Méhémet-Ali', 0, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d83f372d-4fc7-5704-9fa8-75dbaa9e10e2', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 'Fouad II', null, 1952, null, 'Dernier roi d''Égypte (1952-1953)', 'Dynastie de Méhémet-Ali', 245, 3840, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('aff5643c-95cb-5da3-b04f-4df0d8f489ba', '787f4c3c-f7c2-527b-b3c9-2fec8f89270f', 'parent');
  perform pg_temp.rel('787f4c3c-f7c2-527b-b3c9-2fec8f89270f', '379782c2-9751-5604-9e83-6eeb7e1329b2', 'parent');
  perform pg_temp.rel('379782c2-9751-5604-9e83-6eeb7e1329b2', 'ec3bbbf4-ab9f-580a-ac04-ba6e44b7f2dd', 'parent');
  perform pg_temp.rel('ec3bbbf4-ab9f-580a-ac04-ba6e44b7f2dd', '38c18d87-c5a1-5340-abbd-fa4d678076bc', 'parent');
  perform pg_temp.rel('38c18d87-c5a1-5340-abbd-fa4d678076bc', '3687ecaf-7227-5797-9c7e-0f026d5ccf9c', 'parent');
  perform pg_temp.rel('38c18d87-c5a1-5340-abbd-fa4d678076bc', 'b6c0669e-8e3b-5dfe-b6f9-a6a6f51b4dd0', 'parent');
  perform pg_temp.rel('38c18d87-c5a1-5340-abbd-fa4d678076bc', 'e0ab3c72-653a-5549-87e8-a2b72d9df82c', 'parent');
  perform pg_temp.rel('1eebc7b4-9711-579d-9163-5ed56a928f58', '3687ecaf-7227-5797-9c7e-0f026d5ccf9c', 'parent');
  perform pg_temp.rel('1eebc7b4-9711-579d-9163-5ed56a928f58', 'b6c0669e-8e3b-5dfe-b6f9-a6a6f51b4dd0', 'parent');
  perform pg_temp.rel('1eebc7b4-9711-579d-9163-5ed56a928f58', 'e0ab3c72-653a-5549-87e8-a2b72d9df82c', 'parent');
  perform pg_temp.rel('379782c2-9751-5604-9e83-6eeb7e1329b2', '1fae8295-dcb2-5ab8-91bd-43ec00fe7dc2', 'parent');
  perform pg_temp.rel('430b2a40-4045-5f6f-9f76-481d3c0be918', 'ec3bbbf4-ab9f-580a-ac04-ba6e44b7f2dd', 'parent');
  perform pg_temp.rel('430b2a40-4045-5f6f-9f76-481d3c0be918', '1fae8295-dcb2-5ab8-91bd-43ec00fe7dc2', 'parent');
  perform pg_temp.rel('3687ecaf-7227-5797-9c7e-0f026d5ccf9c', '60ef275f-70b7-5c28-bad9-6ac1e4bf09e1', 'parent');
  perform pg_temp.rel('e0ab3c72-653a-5549-87e8-a2b72d9df82c', '60ef275f-70b7-5c28-bad9-6ac1e4bf09e1', 'parent');
  perform pg_temp.rel('b6c0669e-8e3b-5dfe-b6f9-a6a6f51b4dd0', '991cc390-7fb7-5d27-b979-da4adbc0de0d', 'parent');
  perform pg_temp.rel('b6c0669e-8e3b-5dfe-b6f9-a6a6f51b4dd0', '829430a0-d4f4-5662-b629-0170347bf788', 'parent');
  perform pg_temp.rel('60ef275f-70b7-5c28-bad9-6ac1e4bf09e1', '991cc390-7fb7-5d27-b979-da4adbc0de0d', 'parent');
  perform pg_temp.rel('60ef275f-70b7-5c28-bad9-6ac1e4bf09e1', '829430a0-d4f4-5662-b629-0170347bf788', 'parent');
  perform pg_temp.rel('991cc390-7fb7-5d27-b979-da4adbc0de0d', '05cb7344-a765-5878-96c3-e9ceba2ae9b1', 'parent');
  perform pg_temp.rel('05cb7344-a765-5878-96c3-e9ceba2ae9b1', 'c0fcc188-dfd3-5f24-ac85-178905d67ec5', 'parent');
  perform pg_temp.rel('05cb7344-a765-5878-96c3-e9ceba2ae9b1', 'b4a97179-e012-5d98-b218-afa30a500239', 'parent');
  perform pg_temp.rel('05cb7344-a765-5878-96c3-e9ceba2ae9b1', 'd7f3f108-6d41-5909-b326-d94c7a7920b1', 'parent');
  perform pg_temp.rel('05cb7344-a765-5878-96c3-e9ceba2ae9b1', '0c62635b-2148-5996-940c-46c7fca4a584', 'parent');
  perform pg_temp.rel('c0fcc188-dfd3-5f24-ac85-178905d67ec5', 'f872691a-458f-55ed-9253-b188bbd920ca', 'parent');
  perform pg_temp.rel('c0fcc188-dfd3-5f24-ac85-178905d67ec5', 'c114f332-7c10-5f19-9a86-ad1b176bbbce', 'parent');
  perform pg_temp.rel('787f4c3c-f7c2-527b-b3c9-2fec8f89270f', '5b7aa8ec-616f-5a5b-a1e4-b3064e39249d', 'spouse');
  perform pg_temp.rel('379782c2-9751-5604-9e83-6eeb7e1329b2', '430b2a40-4045-5f6f-9f76-481d3c0be918', 'spouse');
  perform pg_temp.rel('ec3bbbf4-ab9f-580a-ac04-ba6e44b7f2dd', '1fae8295-dcb2-5ab8-91bd-43ec00fe7dc2', 'spouse');
  perform pg_temp.rel('38c18d87-c5a1-5340-abbd-fa4d678076bc', '1eebc7b4-9711-579d-9163-5ed56a928f58', 'spouse');
  perform pg_temp.rel('3687ecaf-7227-5797-9c7e-0f026d5ccf9c', 'e0ab3c72-653a-5549-87e8-a2b72d9df82c', 'spouse');
  perform pg_temp.rel('b6c0669e-8e3b-5dfe-b6f9-a6a6f51b4dd0', 'e0ab3c72-653a-5549-87e8-a2b72d9df82c', 'spouse');
  perform pg_temp.rel('b6c0669e-8e3b-5dfe-b6f9-a6a6f51b4dd0', '60ef275f-70b7-5c28-bad9-6ac1e4bf09e1', 'spouse');
  perform pg_temp.rel('991cc390-7fb7-5d27-b979-da4adbc0de0d', '60ef275f-70b7-5c28-bad9-6ac1e4bf09e1', 'spouse');
  perform pg_temp.rel('c0fcc188-dfd3-5f24-ac85-178905d67ec5', 'b4a97179-e012-5d98-b218-afa30a500239', 'spouse');
  perform pg_temp.rel('c0fcc188-dfd3-5f24-ac85-178905d67ec5', '0c62635b-2148-5996-940c-46c7fca4a584', 'spouse');
  perform pg_temp.rel('ff4f107b-2bed-541a-9a31-d0075441cfca', '4eb2d6bf-781c-5bfd-9335-ada42b2ca2f7', 'parent');
  perform pg_temp.rel('ff4f107b-2bed-541a-9a31-d0075441cfca', 'f28e5ef2-6486-55f6-9e11-ce96c92d0a96', 'parent');
  perform pg_temp.rel('ff4f107b-2bed-541a-9a31-d0075441cfca', 'ecf0c167-5176-5699-ba6a-3fc535f6ad98', 'parent');
  perform pg_temp.rel('4eb2d6bf-781c-5bfd-9335-ada42b2ca2f7', 'a7ae581e-07fa-5b3d-8ca0-023cae61d7c4', 'parent');
  perform pg_temp.rel('f28e5ef2-6486-55f6-9e11-ce96c92d0a96', '7f4e0d71-6f10-57ab-9f38-5d542af14541', 'parent');
  perform pg_temp.rel('7f4e0d71-6f10-57ab-9f38-5d542af14541', '46ff9fe1-f3e1-557f-b0da-68cec8d84bdf', 'parent');
  perform pg_temp.rel('46ff9fe1-f3e1-557f-b0da-68cec8d84bdf', '17a6fb3c-c7fe-5209-b8be-1030432e5d80', 'parent');
  perform pg_temp.rel('7f4e0d71-6f10-57ab-9f38-5d542af14541', 'de95ea4e-6e74-55ec-8da3-2aa73f2db151', 'parent');
  perform pg_temp.rel('7f4e0d71-6f10-57ab-9f38-5d542af14541', 'f37d770a-2174-5f78-9545-02346b07d8fe', 'parent');
  perform pg_temp.rel('f37d770a-2174-5f78-9545-02346b07d8fe', '706b8da7-3e0c-5a66-b62f-f261f70e6236', 'parent');
  perform pg_temp.rel('4a5d1226-bf5f-5644-9d75-9e9c457a75fe', '706b8da7-3e0c-5a66-b62f-f261f70e6236', 'parent');
  perform pg_temp.rel('706b8da7-3e0c-5a66-b62f-f261f70e6236', 'd83f372d-4fc7-5704-9fa8-75dbaa9e10e2', 'parent');
  perform pg_temp.rel('d8d12233-0a5e-51ea-a624-9cf522976ae0', 'd83f372d-4fc7-5704-9fa8-75dbaa9e10e2', 'parent');
  perform pg_temp.rel('f37d770a-2174-5f78-9545-02346b07d8fe', '4a5d1226-bf5f-5644-9d75-9e9c457a75fe', 'spouse');
  perform pg_temp.rel('706b8da7-3e0c-5a66-b62f-f261f70e6236', '18667d75-1386-5953-bce7-53206b8473b1', 'spouse');
  perform pg_temp.rel('706b8da7-3e0c-5a66-b62f-f261f70e6236', 'd8d12233-0a5e-51ea-a624-9cf522976ae0', 'spouse');
  perform pg_temp.rel('f37d770a-2174-5f78-9545-02346b07d8fe', '155cbcc0-3627-5f1b-8223-7f5c271930ca', 'parent');
  perform pg_temp.rel('4a5d1226-bf5f-5644-9d75-9e9c457a75fe', '155cbcc0-3627-5f1b-8223-7f5c271930ca', 'parent');
  update public.genealogy_members set pos_x = 980, pos_y = 640 where id = 'ddfcbf96-3455-5a8d-8845-5af644f64a8e';
  update public.genealogy_members set pos_x = 980, pos_y = 1280 where id = '55884d5e-2bed-56ef-8326-fd5cea678bb3';
  update public.genealogy_members set pos_x = 1470, pos_y = 1280 where id = '759e55e7-fa63-51ba-b578-589e2f6e2dea';
  update public.genealogy_members set pos_x = 490, pos_y = 1280 where id = '370776ae-74d1-5a95-b3e8-c29455a2e5bb';
  update public.genealogy_members set pos_x = 0, pos_y = 1280 where id = '155cbcc0-3627-5f1b-8223-7f5c271930ca';
  update public.genealogy_members set pos_x = 735, pos_y = 1920 where id = '013627df-f3ce-563e-80ba-7689fe5ecc77';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('155cbcc0-3627-5f1b-8223-7f5c271930ca', 'entry', '1a6d68b4-4ea2-5cae-95b6-9a5c70c9fc2e', 1480, 3200, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f37d770a-2174-5f78-9545-02346b07d8fe', 'entry', '65c73c1c-5773-5e6f-b97d-d058f4e3a440', 0, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('4a5d1226-bf5f-5644-9d75-9e9c457a75fe', 'entry', '65c73c1c-5773-5e6f-b97d-d058f4e3a440', 0, 640, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v105 : % membres ajoutés.', 37;
end $$;
