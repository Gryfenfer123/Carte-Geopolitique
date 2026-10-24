-- arbres_v106.sql — Hachémites (Jordanie, Irak) et Al Saoud (Arabie saoudite)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Trois nouveaux arbres : « Hachémites » (Jordanie), « Hachémites (Irak) » et « Al Saoud » (Arabie saoudite). Hussein ibn Ali (chérif de La Mecque) est dans l'arbre de Jordanie et affiché aussi dans celui d'Irak, où il est relié à son fils Fayçal Ier.
-- Dates : connues par ailleurs, aucune page consultée pour ce lot. Naissances inconnues laissées vides ; naissance approximative signalée quand elle l'est.
-- Al Saoud : seuls les rois, leurs ancêtres directs et la mère des « Soudayri » sont saisis. Le premier État saoudien est coupé de la lignée de Fayçal ben Turki (chaînon Abdallah ben Mohammed non saisi, donc Turki n'est pas relié à Mohammed ben Saoud).
-- Non fait : princes cadets, épouses de la plupart des rois, Hachémites du Hedjaz au-delà d'Ali, dynastie rachidide.
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
  if exists (select 1 from public.genealogy_members where id = 'bd410388-1880-5661-b1eb-fb29a5106a97') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Hachémites » (JOR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'JOR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour JOR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Hachémites';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('2ace5854-c517-5888-8714-4b0ed844fca2', cat_id, 'country', 'JOR', top, 'Hachémites', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '2ace5854-c517-5888-8714-4b0ed844fca2';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'country', 'JOR', 'genealogy', 'Hachémites', cat_id, sec, admin_id);
  -- Arbre « Hachémites (Irak) » (IRQ)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IRQ' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IRQ : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Hachémites (Irak)';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('6f7713f0-0456-5fb6-b20c-751f6acccab9', cat_id, 'country', 'IRQ', top, 'Hachémites (Irak)', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '6f7713f0-0456-5fb6-b20c-751f6acccab9';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('a25d6578-33b5-5655-8061-3fc487f94149', 'country', 'IRQ', 'genealogy', 'Hachémites (Irak)', cat_id, sec, admin_id);
  -- Arbre « Al Saoud » (SAU)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'SAU' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour SAU : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Al Saoud';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('44072e4f-c1ba-558b-9d26-c471a394d3cc', cat_id, 'country', 'SAU', top, 'Al Saoud', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '44072e4f-c1ba-558b-9d26-c471a394d3cc';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('7e2f5b05-c9f7-555b-892f-2a163fdef668', 'country', 'SAU', 'genealogy', 'Al Saoud', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bd410388-1880-5661-b1eb-fb29a5106a97', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'Hussein ibn Ali', null, 1854, 1931, 'Chérif de La Mecque, roi du Hedjaz (1916-1924), meneur de la Révolte arabe', 'Hachémites', 750, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9ab3d1ab-6395-52e4-8d37-603ffe1d0000', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'Ali ibn Hussein', null, 1879, 1935, 'Roi du Hedjaz (1924-1925)', 'Hachémites', 250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d63ccdfe-6e1b-513c-874b-319fcc61bb89', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'Abdallah Ier de Jordanie', null, 1882, 1951, 'Émir puis roi de Jordanie (1921-1951)', 'Hachémites', 1250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3ada60d6-61c6-5d0e-91a5-43daf5fb37c6', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'Misha''al bint Fahd', null, null, null, 'Épouse de Abdallah Ier', 'Hachémites', 1740, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('219e5682-63a7-5ec0-b9c8-488b6d7657cc', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'Talal de Jordanie', null, 1909, 1972, 'Roi de Jordanie (1951-1952)', 'Hachémites', 1495, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('71a34b2b-ceb3-5de3-9358-0aa9c736f7b7', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'Zein al-Sharaf', null, 1916, 1994, 'Reine de Jordanie, épouse de Talal', 'Hachémites', 1005, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b06b959c-df7d-5167-a1a4-ad1bc97fd939', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'Hussein de Jordanie', null, 1935, 1999, 'Roi de Jordanie (1952-1999)', 'Hachémites', 1250, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('96b6a91c-7738-54b1-a65d-033dea1371e4', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'Muna al-Hussein', null, 1941, null, 'Princesse, deuxième épouse du roi Hussein', 'Hachémites', 760, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f9f39d38-5e57-5d51-9e7f-383f2c98fed1', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'Abdallah II de Jordanie', null, 1962, null, 'Roi de Jordanie (depuis 1999)', 'Hachémites', 1005, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1adc035c-a34e-52e2-a635-7c6e1892e83a', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'Rania al-Abdullah', null, 1970, null, 'Reine de Jordanie, épouse d''Abdallah II', 'Hachémites', 515, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bb6331eb-139b-54cd-9c7c-524787aac033', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 'Hussein de Jordanie (prince héritier)', null, 1994, null, 'Prince héritier de Jordanie', 'Hachémites', 760, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0bfd44a4-68ba-55c3-b9d8-875d9ec8a408', 'entry', 'a25d6578-33b5-5655-8061-3fc487f94149', 'Fayçal Ier d''Irak', null, 1885, 1933, 'Roi de Syrie (1920) puis d''Irak (1921-1933)', 'Hachémites (Irak)', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8ea9a09f-443d-5d6c-aa5b-1c998cd70ef9', 'entry', 'a25d6578-33b5-5655-8061-3fc487f94149', 'Ghazi d''Irak', null, 1912, 1939, 'Roi d''Irak (1933-1939)', 'Hachémites (Irak)', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8afcecb6-a899-5bc6-8f42-4e5da0e22b5f', 'entry', 'a25d6578-33b5-5655-8061-3fc487f94149', 'Aliya bint Ali', null, 1911, 1950, 'Reine d''Irak, épouse de Ghazi', 'Hachémites (Irak)', 490, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dd43ff09-36eb-57ab-817a-d502839d0a50', 'entry', 'a25d6578-33b5-5655-8061-3fc487f94149', 'Fayçal II d''Irak', null, 1935, 1958, 'Dernier roi d''Irak (1939-1958)', 'Hachémites (Irak)', 245, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('37327b6d-174c-5b8f-b4cc-fa2f80e71deb', 'entry', 'a25d6578-33b5-5655-8061-3fc487f94149', 'Abd al-Ilah', null, 1913, 1958, 'Régent d''Irak (1939-1953)', 'Hachémites (Irak)', 990, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cc802f41-d4b5-5d37-9d5a-7858c9636188', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Mohammed ibn Saoud', null, null, 1765, 'Émir de Diriyya, fondateur du premier État saoudien', 'Al Saoud', 3500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('76863e99-9bd9-5335-8aac-6425cbdae83b', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Abdulaziz ibn Mohammed', null, 1720, 1803, 'Imam du premier État saoudien (1765-1803)', 'Al Saoud', 3500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f702b852-d98d-5f45-8348-03767edc47d8', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Saoud ibn Abdulaziz (Saoud le Grand)', null, 1748, 1814, 'Imam du premier État saoudien (1803-1814)', 'Al Saoud', 3500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('72b05d89-e5bb-5eb0-a58f-a309e2322770', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Turki ibn Abdallah', null, null, 1834, 'Fondateur du second État saoudien (1824-1834)', 'Al Saoud', 1237, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cef19b63-2a97-598f-9f19-5515e86a99ee', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Fayçal ibn Turki', null, null, 1865, 'Émir du Nejd (1834-1865)', 'Al Saoud', 1237, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7d5732c6-3782-56e7-9a2f-703c7b0edbfa', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Abdul Rahman ibn Fayçal', null, 1850, 1928, 'Dernier émir du Nejd, père d''Ibn Saoud', 'Al Saoud', 1237, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0ec63e72-abfe-5488-bca8-3555291c1598', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Abdulaziz ibn Saoud (Ibn Saoud)', null, 1875, 1953, 'Fondateur et premier roi d''Arabie saoudite (1932-1953)', 'Al Saoud', 1237, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a575bb31-55db-5786-a06a-7b958864612b', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Hassa bint Ahmad al-Soudaïri', null, null, 1969, 'Épouse d''Ibn Saoud, mère des « Soudayri »', 'Al Saoud', 747, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('54186eb6-9c4a-57be-b2ca-4ab68f99e7f9', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Saoud ben Abdelaziz', null, 1902, 1969, 'Roi d''Arabie saoudite (1953-1964)', 'Al Saoud', 1500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8ba9ea6a-903c-50a4-9ae9-fdda18cbfdaa', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Fayçal ben Abdelaziz', null, 1906, 1975, 'Roi d''Arabie saoudite (1964-1975)', 'Al Saoud', 2000, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('00e0d77e-552c-5528-8079-6efc1abffe60', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Khaled ben Abdelaziz', null, 1913, 1982, 'Roi d''Arabie saoudite (1975-1982)', 'Al Saoud', 1000, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0fa9f54a-02b1-5492-8c6b-7a8fb648e89c', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Fahd ben Abdelaziz', null, 1921, 2005, 'Roi d''Arabie saoudite (1982-2005)', 'Al Saoud', 0, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3804eee9-ccfc-57b5-aa5f-1beb4b5ad012', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Abdallah ben Abdelaziz', null, 1924, 2015, 'Roi d''Arabie saoudite (2005-2015)', 'Al Saoud', 2500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('363e937d-2ec1-5ba6-8e92-1dc13868d200', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Salmane ben Abdelaziz', null, 1935, null, 'Roi d''Arabie saoudite (depuis 2015)', 'Al Saoud', 500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7cab3deb-0bfb-50fb-94ec-c9fc63ec1058', 'entry', '7e2f5b05-c9f7-555b-892f-2a163fdef668', 'Mohammed ben Salmane', null, 1985, null, 'Prince héritier, Premier ministre (depuis 2022)', 'Al Saoud', 602, 5760, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('bd410388-1880-5661-b1eb-fb29a5106a97', '9ab3d1ab-6395-52e4-8d37-603ffe1d0000', 'parent');
  perform pg_temp.rel('bd410388-1880-5661-b1eb-fb29a5106a97', 'd63ccdfe-6e1b-513c-874b-319fcc61bb89', 'parent');
  perform pg_temp.rel('d63ccdfe-6e1b-513c-874b-319fcc61bb89', '219e5682-63a7-5ec0-b9c8-488b6d7657cc', 'parent');
  perform pg_temp.rel('219e5682-63a7-5ec0-b9c8-488b6d7657cc', 'b06b959c-df7d-5167-a1a4-ad1bc97fd939', 'parent');
  perform pg_temp.rel('b06b959c-df7d-5167-a1a4-ad1bc97fd939', 'f9f39d38-5e57-5d51-9e7f-383f2c98fed1', 'parent');
  perform pg_temp.rel('96b6a91c-7738-54b1-a65d-033dea1371e4', 'f9f39d38-5e57-5d51-9e7f-383f2c98fed1', 'parent');
  perform pg_temp.rel('f9f39d38-5e57-5d51-9e7f-383f2c98fed1', 'bb6331eb-139b-54cd-9c7c-524787aac033', 'parent');
  perform pg_temp.rel('1adc035c-a34e-52e2-a635-7c6e1892e83a', 'bb6331eb-139b-54cd-9c7c-524787aac033', 'parent');
  perform pg_temp.rel('3ada60d6-61c6-5d0e-91a5-43daf5fb37c6', '219e5682-63a7-5ec0-b9c8-488b6d7657cc', 'parent');
  perform pg_temp.rel('71a34b2b-ceb3-5de3-9358-0aa9c736f7b7', 'b06b959c-df7d-5167-a1a4-ad1bc97fd939', 'parent');
  perform pg_temp.rel('d63ccdfe-6e1b-513c-874b-319fcc61bb89', '3ada60d6-61c6-5d0e-91a5-43daf5fb37c6', 'spouse');
  perform pg_temp.rel('219e5682-63a7-5ec0-b9c8-488b6d7657cc', '71a34b2b-ceb3-5de3-9358-0aa9c736f7b7', 'spouse');
  perform pg_temp.rel('b06b959c-df7d-5167-a1a4-ad1bc97fd939', '96b6a91c-7738-54b1-a65d-033dea1371e4', 'spouse');
  perform pg_temp.rel('f9f39d38-5e57-5d51-9e7f-383f2c98fed1', '1adc035c-a34e-52e2-a635-7c6e1892e83a', 'spouse');
  perform pg_temp.rel('bd410388-1880-5661-b1eb-fb29a5106a97', '0bfd44a4-68ba-55c3-b9d8-875d9ec8a408', 'parent');
  perform pg_temp.rel('0bfd44a4-68ba-55c3-b9d8-875d9ec8a408', '8ea9a09f-443d-5d6c-aa5b-1c998cd70ef9', 'parent');
  perform pg_temp.rel('9ab3d1ab-6395-52e4-8d37-603ffe1d0000', '8afcecb6-a899-5bc6-8f42-4e5da0e22b5f', 'parent');
  perform pg_temp.rel('8ea9a09f-443d-5d6c-aa5b-1c998cd70ef9', 'dd43ff09-36eb-57ab-817a-d502839d0a50', 'parent');
  perform pg_temp.rel('8afcecb6-a899-5bc6-8f42-4e5da0e22b5f', 'dd43ff09-36eb-57ab-817a-d502839d0a50', 'parent');
  perform pg_temp.rel('9ab3d1ab-6395-52e4-8d37-603ffe1d0000', '37327b6d-174c-5b8f-b4cc-fa2f80e71deb', 'parent');
  perform pg_temp.rel('8ea9a09f-443d-5d6c-aa5b-1c998cd70ef9', '8afcecb6-a899-5bc6-8f42-4e5da0e22b5f', 'spouse');
  perform pg_temp.rel('cc802f41-d4b5-5d37-9d5a-7858c9636188', '76863e99-9bd9-5335-8aac-6425cbdae83b', 'parent');
  perform pg_temp.rel('76863e99-9bd9-5335-8aac-6425cbdae83b', 'f702b852-d98d-5f45-8348-03767edc47d8', 'parent');
  perform pg_temp.rel('72b05d89-e5bb-5eb0-a58f-a309e2322770', 'cef19b63-2a97-598f-9f19-5515e86a99ee', 'parent');
  perform pg_temp.rel('cef19b63-2a97-598f-9f19-5515e86a99ee', '7d5732c6-3782-56e7-9a2f-703c7b0edbfa', 'parent');
  perform pg_temp.rel('7d5732c6-3782-56e7-9a2f-703c7b0edbfa', '0ec63e72-abfe-5488-bca8-3555291c1598', 'parent');
  perform pg_temp.rel('0ec63e72-abfe-5488-bca8-3555291c1598', '54186eb6-9c4a-57be-b2ca-4ab68f99e7f9', 'parent');
  perform pg_temp.rel('0ec63e72-abfe-5488-bca8-3555291c1598', '8ba9ea6a-903c-50a4-9ae9-fdda18cbfdaa', 'parent');
  perform pg_temp.rel('0ec63e72-abfe-5488-bca8-3555291c1598', '00e0d77e-552c-5528-8079-6efc1abffe60', 'parent');
  perform pg_temp.rel('0ec63e72-abfe-5488-bca8-3555291c1598', '0fa9f54a-02b1-5492-8c6b-7a8fb648e89c', 'parent');
  perform pg_temp.rel('0ec63e72-abfe-5488-bca8-3555291c1598', '3804eee9-ccfc-57b5-aa5f-1beb4b5ad012', 'parent');
  perform pg_temp.rel('0ec63e72-abfe-5488-bca8-3555291c1598', '363e937d-2ec1-5ba6-8e92-1dc13868d200', 'parent');
  perform pg_temp.rel('a575bb31-55db-5786-a06a-7b958864612b', '0fa9f54a-02b1-5492-8c6b-7a8fb648e89c', 'parent');
  perform pg_temp.rel('a575bb31-55db-5786-a06a-7b958864612b', '363e937d-2ec1-5ba6-8e92-1dc13868d200', 'parent');
  perform pg_temp.rel('363e937d-2ec1-5ba6-8e92-1dc13868d200', '7cab3deb-0bfb-50fb-94ec-c9fc63ec1058', 'parent');
  perform pg_temp.rel('0ec63e72-abfe-5488-bca8-3555291c1598', 'a575bb31-55db-5786-a06a-7b958864612b', 'spouse');
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('0bfd44a4-68ba-55c3-b9d8-875d9ec8a408', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 750, 640, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('8afcecb6-a899-5bc6-8f42-4e5da0e22b5f', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 0, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('37327b6d-174c-5b8f-b4cc-fa2f80e71deb', 'entry', 'a7156b01-62f2-54ab-aa58-e64f76c5b7da', 500, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('bd410388-1880-5661-b1eb-fb29a5106a97', 'entry', 'a25d6578-33b5-5655-8061-3fc487f94149', 0, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('9ab3d1ab-6395-52e4-8d37-603ffe1d0000', 'entry', 'a25d6578-33b5-5655-8061-3fc487f94149', 740, 640, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v106 : % membres ajoutés.', 31;
end $$;
