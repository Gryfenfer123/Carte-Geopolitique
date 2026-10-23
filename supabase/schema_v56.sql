-- schema_v56.sql — Chine — Zhou et Qin
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Première étape de la Chine, par ordre chronologique : Zhou (roi Wen → roi Nan) et Qin (roi Huiwen → Ziying).
-- Pas de Xia ni de Shang : dynasties semi-légendaires ou connues seulement par des généalogies tardives, sans source datée fiable (à décider avec Martin).
-- Zhou : les dates avant 841 av. J.-C. sont tentatives ; je n'ai saisi ni naissance ni mort, seulement la durée du règne dans le titre (pas de date inventée). Seule la ligne masculine de père en fils est modélisée ; épouses et frères omis sauf Tai Ren, Tai Si, Bo Yikao et le duc de Zhou.
-- Qin : Ziying a une filiation incertaine (fils, frère, neveu ou cousin de Qin Er Shi selon les sources) : relié par un lien « famille » à Qin Er Shi, pas par une filiation.
-- Années avant J.-C. : valeurs négatives (comme pour les empereurs du Japon).
-- Prérequis : v55 exécuté.
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
  if exists (select 1 from public.genealogy_members where id = '46391e11-9aca-581c-a03f-bd25c7b9b2ec') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Zhou » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Zhou';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('8204a891-dfe9-5da3-8dcc-53af6216824e', cat_id, 'country', 'CHN', top, 'Zhou', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '8204a891-dfe9-5da3-8dcc-53af6216824e';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'country', 'CHN', 'genealogy', 'Zhou', cat_id, sec, admin_id);
  -- Arbre « Qin » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Qin';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('338cdfee-8aac-56bb-ad03-65dbce8912f8', cat_id, 'country', 'CHN', top, 'Qin', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '338cdfee-8aac-56bb-ad03-65dbce8912f8';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('d01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'country', 'CHN', 'genealogy', 'Qin', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('46391e11-9aca-581c-a03f-bd25c7b9b2ec', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Ji de Zhou (Ji Li)', null, null, null, 'Père du roi Wen, titre posthume', 'Zhou (Ji)', 85, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2c41e988-da0c-5022-a8bc-40e4ab866364', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Tai Ren', null, null, null, 'Mère du roi Wen', 'Ren (Zhi)', 625, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b3404d93-1ee5-5ed2-b690-448d34379b0c', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Wen de Zhou (Ji Chang)', null, -1152, -1050, 'Seigneur de l''Ouest, fondateur de la puissance des Zhou', 'Zhou (Ji)', 355, 684, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('904e4476-4730-516f-a69a-f2af07bd4fb1', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Tai Si', null, null, null, 'Épouse du roi Wen', 'Si (Sì)', 859, 684, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ff5d5182-5782-59f2-842a-12fcb039e20a', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Bo Yikao', null, null, null, 'Fils aîné du roi Wen', 'Zhou (Ji)', 197, 1824, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fe38c392-5aec-57c3-a524-d8051147cebe', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Ji Dan (duc de Zhou)', null, null, null, 'Régent sous le roi Cheng', 'Zhou (Ji)', 607, 1824, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ee9b9399-6655-56c2-879e-52ce35b94ae7', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Wu de Zhou (Ji Fa)', null, null, null, 'Roi des Zhou (-1046 à -1043), renverse les Shang', 'Zhou (Ji)', 1017, 1824, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('426828da-b4a5-50b2-911e-50c1999f2354', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Cheng de Zhou (Ji Song)', null, null, null, 'Roi des Zhou (-1042 à -1021)', 'Zhou (Ji)', 1017, 2664, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('00e7ba0c-1bd0-5363-ba3b-26fdd3eda670', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Kang de Zhou (Ji Zhao)', null, null, null, 'Roi des Zhou (-1020 à -996)', 'Zhou (Ji)', 1017, 3124, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('34f0e0ff-c64f-5ffd-a97f-dcbff16b11fb', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Zhao de Zhou (Ji Xia)', null, null, null, 'Roi des Zhou (-995 à -977)', 'Zhou (Ji)', 1017, 3584, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e0ef8993-1ed8-5c17-9560-e429de22cf4d', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Mu de Zhou (Ji Man)', null, null, null, 'Roi des Zhou (-976 à -922)', 'Zhou (Ji)', 1017, 4044, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b6c1181d-0e9c-50c7-b4fd-29812fd2148f', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Gong de Zhou (Ji Yihu)', null, null, null, 'Roi des Zhou (-922 à -900)', 'Zhou (Ji)', 812, 5103, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('33f0cbb8-0271-5444-a700-b6c9061bb4cc', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Yi de Zhou (Ji Jian)', null, null, null, 'Roi des Zhou (-899 à -892)', 'Zhou (Ji)', 812, 5563, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7888ba67-e26c-55eb-baa7-5a5ffe6bedd8', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Xiao de Zhou (Ji Pifang)', null, null, null, 'Roi des Zhou (-891 à -886)', 'Zhou (Ji)', 1222, 5103, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2d763827-bd4e-5339-8bf0-e9aa6cc7fe88', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Yi de Zhou (Ji Xie)', null, null, null, 'Roi des Zhou (-885 à -878)', 'Zhou (Ji)', 812, 6023, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('811829a5-18d1-52bb-82ad-c7b729cfea09', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Li de Zhou (Ji Hu)', null, null, null, 'Roi des Zhou (-877 à -841), chassé par une révolte', 'Zhou (Ji)', 812, 6483, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('206918a7-b23d-5f95-960e-1073acaaa2a9', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Xuan de Zhou (Ji Jing)', null, null, null, 'Roi des Zhou (-827 à -782)', 'Zhou (Ji)', 812, 6943, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1d3db228-9fdc-5cfd-baca-d42db44430ec', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi You de Zhou (Ji Gongnie)', null, null, null, 'Dernier roi des Zhou occidentaux (-781 à -771), tué par les Quanrong', 'Zhou (Ji)', 812, 7403, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0ea36d9a-f1dd-58ba-89fe-f3998acb9138', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Ping de Zhou (Ji Yijiu)', null, null, null, 'Roi des Zhou (-770 à -720), déplace la capitale à l''est', 'Zhou (Ji)', 812, 7863, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dc34c4a5-b983-5ca0-85cd-4d866ff81181', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Huan de Zhou (Ji Lin)', null, null, null, 'Roi des Zhou (-719 à -697)', 'Zhou (Ji)', 205, 8478, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7bf76e89-6578-585b-9f01-0232c6e1029c', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Zhuang de Zhou (Ji Tuo)', null, null, null, 'Roi des Zhou (-696 à -682)', 'Zhou (Ji)', 205, 8938, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('08453f89-1aba-5817-9605-597bf5662895', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Xi de Zhou (Ji Huqi)', null, null, null, 'Roi des Zhou (-681 à -677)', 'Zhou (Ji)', 205, 9398, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('80ecca0a-55a9-581b-949d-63bf990a76d1', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Hui de Zhou (Ji Lang)', null, null, null, 'Roi des Zhou (-676 à -652)', 'Zhou (Ji)', 205, 9858, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0eaa5a90-f322-5df4-bb0a-e1f7afe572e3', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Xiang de Zhou (Ji Zheng)', null, null, null, 'Roi des Zhou (-651 à -619)', 'Zhou (Ji)', 205, 10318, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('26db4e11-0425-5784-a0db-ff8971d5df5f', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Qing de Zhou (Ji Renchen)', null, null, null, 'Roi des Zhou (-618 à -613)', 'Zhou (Ji)', 205, 10778, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('26a2943a-26bb-540f-8425-c288eaf3176e', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Kuang de Zhou (Ji Ban)', null, null, null, 'Roi des Zhou (-612 à -607)', 'Zhou (Ji)', 0, 11238, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c4e577ad-936e-541e-b423-f2215ab81f0e', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Ding de Zhou (Ji Yu)', null, null, null, 'Roi des Zhou (-606 à -586)', 'Zhou (Ji)', 410, 11238, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3a11eb0a-fe6a-5a1c-9442-c3d184ebaab0', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Jian de Zhou (Ji Yi)', null, null, null, 'Roi des Zhou (-585 à -572)', 'Zhou (Ji)', 410, 11698, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('027000c5-7c80-5daa-a6f4-4e1eab020b1a', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Ling de Zhou (Ji Xiexin)', null, null, null, 'Roi des Zhou (-571 à -545)', 'Zhou (Ji)', 410, 12158, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aae95fbd-6e24-514a-9c26-9807f8672fe2', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Jing de Zhou (Ji Gui)', null, null, null, 'Roi des Zhou (-544 à -521)', 'Zhou (Ji)', 410, 12618, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1b74f2e9-6c31-56b2-811d-78d1760524eb', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Dao de Zhou (Ji Meng)', null, null, null, 'Roi des Zhou (-520, moins d''un an)', 'Zhou (Ji)', 205, 13078, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0e1759a6-c30e-5589-a907-59cbba9329fe', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Jing de Zhou (Ji Gai)', null, null, null, 'Roi des Zhou (-519 à -476)', 'Zhou (Ji)', 615, 13078, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('15d3b5ad-e2fb-53bc-b53c-74a7044cd7b7', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Yuan de Zhou (Ji Ren)', null, null, null, 'Roi des Zhou (-475 à -469)', 'Zhou (Ji)', 615, 13538, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b257896e-83d7-50d2-801a-e91dd147f9f4', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Zhending de Zhou (Ji Jie)', null, null, null, 'Roi des Zhou (-468 à -442)', 'Zhou (Ji)', 615, 13998, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bd110456-ad95-5047-9f6f-853e9c9febb1', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Ai de Zhou (Ji Quji)', null, null, null, 'Roi des Zhou (-441, moins d''un an)', 'Zhou (Ji)', 205, 14458, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7edab006-6a66-5ffe-938e-d833fb76b269', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Si de Zhou (Ji Shu)', null, null, null, 'Roi des Zhou (-441, moins d''un an)', 'Zhou (Ji)', 615, 14458, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('56ea6a01-410f-5c27-a73f-d049b2239162', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Kao de Zhou (Ji Wei)', null, null, null, 'Roi des Zhou (-440 à -426)', 'Zhou (Ji)', 1025, 14458, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('38346a28-f0c2-5686-a8ab-cda61efbb35c', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Weilie de Zhou (Ji Wu)', null, null, null, 'Roi des Zhou (-425 à -402)', 'Zhou (Ji)', 1025, 14918, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9dbffd10-2be4-5890-828e-d9bf0479960d', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi An de Zhou (Ji Jiao)', null, null, null, 'Roi des Zhou (-401 à -376)', 'Zhou (Ji)', 1025, 15378, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1f0bcfbf-4abf-5b93-83e0-4edaee94431b', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Lie de Zhou (Ji Xi)', null, null, null, 'Roi des Zhou (-375 à -369)', 'Zhou (Ji)', 820, 15838, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8fb83e46-f803-5dcc-92d2-1f42dc78e99f', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Xian de Zhou (Ji Bian)', null, null, null, 'Roi des Zhou (-368 à -321)', 'Zhou (Ji)', 1230, 15838, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e43ad95b-6c7e-5455-9721-73719f9f7ee3', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Shenjing de Zhou (Ji Ding)', null, null, null, 'Roi des Zhou (-320 à -315)', 'Zhou (Ji)', 1230, 16298, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('75c69947-5425-54b7-88fe-8bb339f30299', 'entry', '03e835bb-6c40-5a4e-83c0-b66c0c2bb0ac', 'Roi Nan de Zhou (Ji Yan)', null, null, null, 'Dernier roi des Zhou (-314 à -256), la dynastie s''éteint avec lui', 'Zhou (Ji)', 1230, 16758, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c9380484-fc9d-5948-99d6-9a46bb83e90d', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Huiwen de Qin', null, -356, -311, 'Roi de Qin (-338 à -311)', 'Qin (Ying)', 810, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f10905fb-a68f-5a49-b4e2-9c45382ee0b2', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Reine Huiwen (de Wei)', null, null, -305, 'Reine de Qin', 'Wei', 1350, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b92d0cb0-89f3-5d86-bd6f-dd3fc73624d2', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Reine douairière Xuan (Lady Mi)', null, null, -265, 'Reine douairière de Qin, régente', 'Mi (Chu)', 270, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4e486737-14ea-5677-a941-61262da05b05', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Wu de Qin (prince Dang)', null, -329, -307, 'Roi de Qin (-310 à -307)', 'Qin (Ying)', 1080, 522, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('12c5338c-1a19-5c48-8b05-a0ac30b4a972', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Zhaoxiang de Qin (prince Ji)', null, -325, -251, 'Roi de Qin (-306 à -251)', 'Qin (Ying)', 540, 522, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('173f57c7-2bde-515b-9661-e68b4ccdb400', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Reine douairière Tang', null, null, null, 'Reine douairière de Qin', 'Tang (Qin)', 0, 522, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c502f99f-6c13-57b5-86cf-c3eb3a1804cc', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Xiaowen de Qin (Lord Anguo)', null, -302, -250, 'Roi de Qin (-250, trois jours)', 'Qin (Ying)', 270, 982, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5754e7c3-9199-564b-95af-d5231f65c7e8', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Reine douairière Xia', null, null, null, 'Reine douairière de Qin', 'Xia (Qin)', 810, 982, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1d792b8b-2257-5097-b830-c597df2d312b', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Zhuangxiang de Qin (Zichu)', null, -281, -247, 'Roi de Qin (-250 à -247)', 'Qin (Ying)', 540, 1442, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ade6871e-3919-5caf-9d9f-f704ef5bb98b', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Reine douairière Zhao', null, null, null, 'Reine douairière de Qin', 'Zhao', 1105, 1442, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5152b4d5-ac72-5aa4-9fa2-0129b3b1b6ba', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Qin Shi Huang (Ying Zheng)', null, -259, -210, 'Premier empereur de Chine (-221 à -210)', 'Qin (Ying)', 618, 1902, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ec18b519-4298-56dc-9092-479c1415fcce', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Zhao Chengjiao', null, null, null, 'Demi-frère de Qin Shi Huang (infobox)', 'Qin (Ying)', 1028, 1902, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1bce2220-f6a5-56ad-8dbc-684cc7a598bf', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Fusu', null, null, -210, 'Fils aîné et prince héritier de Qin Shi Huang', 'Qin (Ying)', 540, 2362, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d6016dac-fc72-5a35-b0d3-9b7f939002ea', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Qin Er Shi (Huhai)', null, -229, -207, 'Second empereur (-210 à -207)', 'Qin (Ying)', 130, 2362, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a7890325-174d-5dfd-a8ae-64d69e4d083c', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Hu Ji', null, null, null, 'Mère probable de Qin Er Shi', 'Hu (peuples du Nord)', 53, 1902, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5b44e1ea-4754-549f-b315-d82c54e3c5a6', 'entry', 'd01f1d38-8c1b-56f3-bcd6-3b13a199ca59', 'Ziying', null, null, -206, 'Dernier souverain de Qin (-207), tué par Xiang Yu', 'Qin (Ying)', 1070, 2304, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('46391e11-9aca-581c-a03f-bd25c7b9b2ec', '2c41e988-da0c-5022-a8bc-40e4ab866364', 'spouse');
  perform pg_temp.rel('46391e11-9aca-581c-a03f-bd25c7b9b2ec', 'b3404d93-1ee5-5ed2-b690-448d34379b0c', 'parent');
  perform pg_temp.rel('2c41e988-da0c-5022-a8bc-40e4ab866364', 'b3404d93-1ee5-5ed2-b690-448d34379b0c', 'parent');
  perform pg_temp.rel('b3404d93-1ee5-5ed2-b690-448d34379b0c', '904e4476-4730-516f-a69a-f2af07bd4fb1', 'spouse');
  perform pg_temp.rel('b3404d93-1ee5-5ed2-b690-448d34379b0c', 'ff5d5182-5782-59f2-842a-12fcb039e20a', 'parent');
  perform pg_temp.rel('904e4476-4730-516f-a69a-f2af07bd4fb1', 'ff5d5182-5782-59f2-842a-12fcb039e20a', 'parent');
  perform pg_temp.rel('b3404d93-1ee5-5ed2-b690-448d34379b0c', 'fe38c392-5aec-57c3-a524-d8051147cebe', 'parent');
  perform pg_temp.rel('904e4476-4730-516f-a69a-f2af07bd4fb1', 'fe38c392-5aec-57c3-a524-d8051147cebe', 'parent');
  perform pg_temp.rel('b3404d93-1ee5-5ed2-b690-448d34379b0c', 'ee9b9399-6655-56c2-879e-52ce35b94ae7', 'parent');
  perform pg_temp.rel('ee9b9399-6655-56c2-879e-52ce35b94ae7', '426828da-b4a5-50b2-911e-50c1999f2354', 'parent');
  perform pg_temp.rel('426828da-b4a5-50b2-911e-50c1999f2354', '00e7ba0c-1bd0-5363-ba3b-26fdd3eda670', 'parent');
  perform pg_temp.rel('00e7ba0c-1bd0-5363-ba3b-26fdd3eda670', '34f0e0ff-c64f-5ffd-a97f-dcbff16b11fb', 'parent');
  perform pg_temp.rel('34f0e0ff-c64f-5ffd-a97f-dcbff16b11fb', 'e0ef8993-1ed8-5c17-9560-e429de22cf4d', 'parent');
  perform pg_temp.rel('e0ef8993-1ed8-5c17-9560-e429de22cf4d', 'b6c1181d-0e9c-50c7-b4fd-29812fd2148f', 'parent');
  perform pg_temp.rel('b6c1181d-0e9c-50c7-b4fd-29812fd2148f', '33f0cbb8-0271-5444-a700-b6c9061bb4cc', 'parent');
  perform pg_temp.rel('e0ef8993-1ed8-5c17-9560-e429de22cf4d', '7888ba67-e26c-55eb-baa7-5a5ffe6bedd8', 'parent');
  perform pg_temp.rel('33f0cbb8-0271-5444-a700-b6c9061bb4cc', '2d763827-bd4e-5339-8bf0-e9aa6cc7fe88', 'parent');
  perform pg_temp.rel('2d763827-bd4e-5339-8bf0-e9aa6cc7fe88', '811829a5-18d1-52bb-82ad-c7b729cfea09', 'parent');
  perform pg_temp.rel('811829a5-18d1-52bb-82ad-c7b729cfea09', '206918a7-b23d-5f95-960e-1073acaaa2a9', 'parent');
  perform pg_temp.rel('206918a7-b23d-5f95-960e-1073acaaa2a9', '1d3db228-9fdc-5cfd-baca-d42db44430ec', 'parent');
  perform pg_temp.rel('1d3db228-9fdc-5cfd-baca-d42db44430ec', '0ea36d9a-f1dd-58ba-89fe-f3998acb9138', 'parent');
  perform pg_temp.rel('0ea36d9a-f1dd-58ba-89fe-f3998acb9138', 'dc34c4a5-b983-5ca0-85cd-4d866ff81181', 'family');
  perform pg_temp.rel('dc34c4a5-b983-5ca0-85cd-4d866ff81181', '7bf76e89-6578-585b-9f01-0232c6e1029c', 'parent');
  perform pg_temp.rel('7bf76e89-6578-585b-9f01-0232c6e1029c', '08453f89-1aba-5817-9605-597bf5662895', 'parent');
  perform pg_temp.rel('08453f89-1aba-5817-9605-597bf5662895', '80ecca0a-55a9-581b-949d-63bf990a76d1', 'parent');
  perform pg_temp.rel('80ecca0a-55a9-581b-949d-63bf990a76d1', '0eaa5a90-f322-5df4-bb0a-e1f7afe572e3', 'parent');
  perform pg_temp.rel('0eaa5a90-f322-5df4-bb0a-e1f7afe572e3', '26db4e11-0425-5784-a0db-ff8971d5df5f', 'parent');
  perform pg_temp.rel('26db4e11-0425-5784-a0db-ff8971d5df5f', '26a2943a-26bb-540f-8425-c288eaf3176e', 'parent');
  perform pg_temp.rel('26db4e11-0425-5784-a0db-ff8971d5df5f', 'c4e577ad-936e-541e-b423-f2215ab81f0e', 'parent');
  perform pg_temp.rel('c4e577ad-936e-541e-b423-f2215ab81f0e', '3a11eb0a-fe6a-5a1c-9442-c3d184ebaab0', 'parent');
  perform pg_temp.rel('3a11eb0a-fe6a-5a1c-9442-c3d184ebaab0', '027000c5-7c80-5daa-a6f4-4e1eab020b1a', 'parent');
  perform pg_temp.rel('027000c5-7c80-5daa-a6f4-4e1eab020b1a', 'aae95fbd-6e24-514a-9c26-9807f8672fe2', 'parent');
  perform pg_temp.rel('aae95fbd-6e24-514a-9c26-9807f8672fe2', '1b74f2e9-6c31-56b2-811d-78d1760524eb', 'parent');
  perform pg_temp.rel('aae95fbd-6e24-514a-9c26-9807f8672fe2', '0e1759a6-c30e-5589-a907-59cbba9329fe', 'parent');
  perform pg_temp.rel('0e1759a6-c30e-5589-a907-59cbba9329fe', '15d3b5ad-e2fb-53bc-b53c-74a7044cd7b7', 'parent');
  perform pg_temp.rel('15d3b5ad-e2fb-53bc-b53c-74a7044cd7b7', 'b257896e-83d7-50d2-801a-e91dd147f9f4', 'parent');
  perform pg_temp.rel('b257896e-83d7-50d2-801a-e91dd147f9f4', 'bd110456-ad95-5047-9f6f-853e9c9febb1', 'parent');
  perform pg_temp.rel('b257896e-83d7-50d2-801a-e91dd147f9f4', '7edab006-6a66-5ffe-938e-d833fb76b269', 'parent');
  perform pg_temp.rel('b257896e-83d7-50d2-801a-e91dd147f9f4', '56ea6a01-410f-5c27-a73f-d049b2239162', 'parent');
  perform pg_temp.rel('56ea6a01-410f-5c27-a73f-d049b2239162', '38346a28-f0c2-5686-a8ab-cda61efbb35c', 'parent');
  perform pg_temp.rel('38346a28-f0c2-5686-a8ab-cda61efbb35c', '9dbffd10-2be4-5890-828e-d9bf0479960d', 'parent');
  perform pg_temp.rel('9dbffd10-2be4-5890-828e-d9bf0479960d', '1f0bcfbf-4abf-5b93-83e0-4edaee94431b', 'parent');
  perform pg_temp.rel('9dbffd10-2be4-5890-828e-d9bf0479960d', '8fb83e46-f803-5dcc-92d2-1f42dc78e99f', 'parent');
  perform pg_temp.rel('8fb83e46-f803-5dcc-92d2-1f42dc78e99f', 'e43ad95b-6c7e-5455-9721-73719f9f7ee3', 'parent');
  perform pg_temp.rel('e43ad95b-6c7e-5455-9721-73719f9f7ee3', '75c69947-5425-54b7-88fe-8bb339f30299', 'parent');
  perform pg_temp.rel('c9380484-fc9d-5948-99d6-9a46bb83e90d', 'f10905fb-a68f-5a49-b4e2-9c45382ee0b2', 'spouse');
  perform pg_temp.rel('c9380484-fc9d-5948-99d6-9a46bb83e90d', 'b92d0cb0-89f3-5d86-bd6f-dd3fc73624d2', 'spouse');
  perform pg_temp.rel('c9380484-fc9d-5948-99d6-9a46bb83e90d', '4e486737-14ea-5677-a941-61262da05b05', 'parent');
  perform pg_temp.rel('f10905fb-a68f-5a49-b4e2-9c45382ee0b2', '4e486737-14ea-5677-a941-61262da05b05', 'parent');
  perform pg_temp.rel('c9380484-fc9d-5948-99d6-9a46bb83e90d', '12c5338c-1a19-5c48-8b05-a0ac30b4a972', 'parent');
  perform pg_temp.rel('b92d0cb0-89f3-5d86-bd6f-dd3fc73624d2', '12c5338c-1a19-5c48-8b05-a0ac30b4a972', 'parent');
  perform pg_temp.rel('12c5338c-1a19-5c48-8b05-a0ac30b4a972', '173f57c7-2bde-515b-9661-e68b4ccdb400', 'spouse');
  perform pg_temp.rel('12c5338c-1a19-5c48-8b05-a0ac30b4a972', 'c502f99f-6c13-57b5-86cf-c3eb3a1804cc', 'parent');
  perform pg_temp.rel('173f57c7-2bde-515b-9661-e68b4ccdb400', 'c502f99f-6c13-57b5-86cf-c3eb3a1804cc', 'parent');
  perform pg_temp.rel('c502f99f-6c13-57b5-86cf-c3eb3a1804cc', '5754e7c3-9199-564b-95af-d5231f65c7e8', 'spouse');
  perform pg_temp.rel('c502f99f-6c13-57b5-86cf-c3eb3a1804cc', '1d792b8b-2257-5097-b830-c597df2d312b', 'parent');
  perform pg_temp.rel('5754e7c3-9199-564b-95af-d5231f65c7e8', '1d792b8b-2257-5097-b830-c597df2d312b', 'parent');
  perform pg_temp.rel('1d792b8b-2257-5097-b830-c597df2d312b', 'ade6871e-3919-5caf-9d9f-f704ef5bb98b', 'spouse');
  perform pg_temp.rel('1d792b8b-2257-5097-b830-c597df2d312b', '5152b4d5-ac72-5aa4-9fa2-0129b3b1b6ba', 'parent');
  perform pg_temp.rel('ade6871e-3919-5caf-9d9f-f704ef5bb98b', '5152b4d5-ac72-5aa4-9fa2-0129b3b1b6ba', 'parent');
  perform pg_temp.rel('1d792b8b-2257-5097-b830-c597df2d312b', 'ec18b519-4298-56dc-9092-479c1415fcce', 'parent');
  perform pg_temp.rel('5152b4d5-ac72-5aa4-9fa2-0129b3b1b6ba', '1bce2220-f6a5-56ad-8dbc-684cc7a598bf', 'parent');
  perform pg_temp.rel('5152b4d5-ac72-5aa4-9fa2-0129b3b1b6ba', 'd6016dac-fc72-5a35-b0d3-9b7f939002ea', 'parent');
  perform pg_temp.rel('a7890325-174d-5dfd-a8ae-64d69e4d083c', 'd6016dac-fc72-5a35-b0d3-9b7f939002ea', 'parent');
  perform pg_temp.rel('d6016dac-fc72-5a35-b0d3-9b7f939002ea', '5b44e1ea-4754-549f-b315-d82c54e3c5a6', 'family');
  raise notice 'schema_v56 : % membres ajoutés.', 59;
end $$;
