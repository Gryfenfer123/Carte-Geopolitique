-- schema_v58.sql — Chine — Trois Royaumes (Cao Wei, Shu Han, Wu oriental)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Chine, étape 3 : trois arbres, Cao Wei (Cao Cao -> Cao Huan), Shu Han (Liu Bei -> Liu Shan et enfants) et Wu oriental (Sun Jian -> Sun Hao).
-- Cao Jie (fille de Cao Cao) est créée dans l'arbre Cao Wei et reliée à Liu Xie (Han Xian, v57). Dame Sun (sœur de Sun Quan) est créée dans le Wu oriental et reliée à Liu Bei.
-- Filiations contestées : Cao Fang (probablement petit-fils de Cao Zhang, adopté par Cao Rui) ; Cao Rui (certains historiens : fils de Yuan Xi) ; mère de Liu Shan (dame Gan dans le texte, impératrice Zhaolie dans l'infobox) ; mère de Sun Xiu (consort Wang ou impératrice Jinghuai). Rapport au cas par cas.
-- Liu Bei est un descendant revendiqué des Han ; aucun lien n'est tracé car aucune page consultée ne le donne.
-- Prérequis : v57 exécuté.
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
  if exists (select 1 from public.genealogy_members where id = '5bafa790-59a2-5cc8-adcc-cfbcfe6ded62') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('55dbd430-050d-53a6-a16f-c0a9f7eb291a');
  if k <> 1 then raise exception 'Membres préexistants manquants (% sur 1) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Cao Wei » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Cao Wei';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('64b6befe-2df4-5477-8301-bac92bd514e9', cat_id, 'country', 'CHN', top, 'Cao Wei', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '64b6befe-2df4-5477-8301-bac92bd514e9';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'country', 'CHN', 'genealogy', 'Cao Wei', cat_id, sec, admin_id);
  -- Arbre « Shu Han » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Shu Han';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('9a4aafc9-21ac-51cd-9b2c-6bb2ad789eed', cat_id, 'country', 'CHN', top, 'Shu Han', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '9a4aafc9-21ac-51cd-9b2c-6bb2ad789eed';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('5dadf3a6-af63-59d3-9c3d-92916e775595', 'country', 'CHN', 'genealogy', 'Shu Han', cat_id, sec, admin_id);
  -- Arbre « Wu oriental » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Wu oriental';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('30059250-3f0a-54b3-951b-f02aa1431b93', cat_id, 'country', 'CHN', top, 'Wu oriental', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '30059250-3f0a-54b3-951b-f02aa1431b93';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('daa6cbf2-c844-5212-9684-288dd49ab751', 'country', 'CHN', 'genealogy', 'Wu oriental', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5bafa790-59a2-5cc8-adcc-cfbcfe6ded62', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Song', null, null, null, 'Père de Cao Cao', 'Cao (Wei)', 1729, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bf55fded-75c7-52c4-840b-5fef1136b7e1', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Cao', null, 155, 220, 'Roi de Wei, fondateur de fait des Wei (empereur Wu à titre posthume)', 'Cao (Wei)', 1729, 630, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8bbd0b22-c284-5b49-b273-ad9b3ad54da5', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Dame Ding (épouse de Cao Cao)', null, null, null, 'Première épouse de Cao Cao', 'Ding', 0, 630, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('27151f5b-621c-5733-8a64-7732e9e96fce', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Dame Bian (impératrice Wuxuan)', null, null, null, 'Épouse de Cao Cao, mère de Cao Pi', 'Bian', 3595, 630, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c7776778-51fc-554d-abb8-7fd62194de7c', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Ang', null, null, 197, 'Fils aîné de Cao Cao, tué à Wancheng', 'Cao (Wei)', 1464, 1263, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('93d9cb04-c13c-58d1-b543-d4d44cc9779b', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Pi (Wei Wendi)', null, 187, 226, 'Premier empereur de Wei (220 à 226)', 'Cao (Wei)', 3449, 1263, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e8224264-8e0a-560d-9569-63b7ad1b0a11', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Zhi', null, null, null, 'Prince de Chen, poète', 'Cao (Wei)', 2284, 1263, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('27531bb6-21d5-521c-8a7e-c4343333f4d4', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Zhang', null, null, 223, 'Prince de Rencheng', 'Cao (Wei)', 1874, 1263, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c4366798-9b56-5357-a4f7-c928998218cd', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Yu (prince de Yan)', null, null, null, 'Fils de Cao Cao, père de Cao Huan', 'Cao (Wei)', 264, 1263, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5775cad5-a243-5489-b6e5-9cc4058e0a99', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Jie (impératrice Xianmu)', null, 197, 260, 'Impératrice de Han, épouse de Xian', 'Cao (Wei)', 1054, 1263, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d57f4e3b-43fa-529b-963f-1248946ca85e', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Impératrice Wenzhao (dame Zhen)', null, 183, 221, 'Impératrice de Wei', 'Zhen', 2694, 1263, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8cd747f1-953b-525b-b607-fe3b83d5b7b1', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Impératrice Wende (Guo Nüwang)', null, 184, 235, 'Impératrice de Wei', 'Guo', 3829, 1263, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9503272c-0d10-5e09-94fa-865bf537a42f', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Rui (Wei Mingdi)', null, 204, 239, 'Deuxième empereur de Wei (226 à 239)', 'Cao (Wei)', 2677, 1723, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('51da498b-247c-5044-8e3e-848b1efc6e0f', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Impératrice Mingdao (clan Mao)', null, null, 237, 'Impératrice de Wei', 'Mao', 2297, 1723, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5d4f74ab-6820-5755-8949-9cae0917b9af', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Impératrice Mingyuan (clan Guo)', null, null, 264, 'Impératrice de Wei', 'Guo', 3057, 1723, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d4459b4a-1fff-52b6-b384-6224df74082e', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Lin (prince de Donghai)', null, null, 251, 'Fils de Cao Pi, père de Cao Mao', 'Cao (Wei)', 3467, 1723, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('debdf985-4411-5560-9c0c-3347c23df3bd', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Kai (prince de Rencheng)', null, null, null, 'Fils de Cao Zhang (selon une hypothèse)', 'Cao (Wei)', 1874, 1723, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6588a9b3-6de6-5093-b847-a7b231fdf055', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Fang (Wei Shaodi)', null, 232, 274, 'Troisième empereur de Wei (239 à 254), déposé', 'Cao (Wei)', 1874, 2183, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1703696d-e705-58df-a334-475a48b65c06', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Impératrice Huai (Zhen, épouse de Cao Fang)', null, null, 251, 'Impératrice de Wei', 'Zhen', 1494, 2183, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ddf4c132-8a9e-5144-a2d3-4ce2e9a229ab', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Impératrice Zhang (épouse de Cao Fang)', null, null, null, 'Impératrice de Wei, déposée en 254', 'Zhang', 2634, 2183, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d256faf8-299a-5e9b-aee1-1edc498fe8b2', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Impératrice Wang (épouse de Cao Fang)', null, null, null, 'Impératrice de Wei (254)', 'Wang', 2254, 2183, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('90b70692-17d2-57d1-befa-1802a3bcaeb2', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Mao (Wei Gaoguixiang gong)', null, 241, 260, 'Quatrième empereur de Wei (254 à 260), tué lors d''un coup d''État', 'Cao (Wei)', 3467, 2183, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fd911d79-2e93-5431-a593-151673d605cc', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Impératrice Bian (épouse de Cao Mao)', null, null, null, 'Impératrice de Wei', 'Bian', 3847, 2183, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c94e67b8-14bc-5b87-90e0-ad8fce2e16bc', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Cao Huan (Wei Yuandi)', null, 246, 302, 'Cinquième et dernier empereur de Wei (260 à 266)', 'Cao (Wei)', 264, 2268, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f9c6a41b-d779-5b5f-affb-ad844425e17d', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 'Impératrice Bian (épouse de Cao Huan)', null, null, null, 'Impératrice de Wei (263)', 'Bian', 644, 2268, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8dccff3c-aae8-56db-a17b-0b974e29ac17', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Hong (père de Liu Bei)', null, null, null, 'Père de Liu Bei', 'Liu (Shu Han)', 2949, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dceb9927-099b-5dd6-adb9-43faf7055686', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Bei (Shu Han Zhaolie)', null, 161, 223, 'Fondateur et empereur du Shu Han (221 à 223)', 'Liu (Shu Han)', 2949, 558, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('444a6124-c92f-5d66-a62f-676440478890', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Dame Gan', null, null, null, 'Concubine de Liu Bei, mère de Liu Shan (selon le texte)', 'Gan', 2301, 558, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5436a5be-7329-595b-887d-2e1f1caf3b4c', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Impératrice Wu (Mu)', null, null, null, 'Épouse de Liu Bei (impératrice douairière Mu)', 'Wu', 3709, 558, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('31b6aa9e-e53c-5988-9be3-dbae963ee940', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Dame Mi', null, null, null, 'Épouse de Liu Bei', 'Mi', 3329, 558, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Shan (Shu Han Houzhu)', null, 207, 271, 'Deuxième et dernier empereur du Shu Han (223 à 263)', 'Liu (Shu Han)', 2025, 1434, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3d2cbe62-9a94-5111-ae8a-d0ead46cb078', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Yong (prince de Ganling)', null, null, null, 'Fils de Liu Bei', 'Liu (Shu Han)', 3165, 1434, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('06a385c9-3891-5d58-b722-3a5488d82633', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Li (prince de Anping)', null, null, null, 'Fils de Liu Bei', 'Liu (Shu Han)', 3545, 1434, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('893990db-45a8-5c4e-ac46-1fdb9f7b5b41', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Impératrice Jing''ai (Zhang)', null, null, 237, 'Impératrice du Shu Han, fille de Zhang Fei', 'Zhang (Zhang Fei)', 2405, 1434, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6fffd7ed-4a3f-5886-a716-a07d0372bde4', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Impératrice Zhang (cadette)', null, null, null, 'Impératrice du Shu Han (238), sœur cadette de Jing''ai', 'Zhang (Zhang Fei)', 2785, 1434, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8e36fe89-e746-5cf6-9bf2-d15e832e58bb', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Dame Li (Li Zhaoyi)', null, null, null, 'Concubine de Liu Shan, mère de Liu Xuan', 'Li', 435, 1434, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d5b8a323-0f5e-56bd-b1a8-3270a20028e4', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Xuan (prince héritier du Shu Han)', null, 224, 264, 'Prince héritier', 'Liu (Shu Han)', 0, 1894, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('51831785-5019-522a-9f80-89fcfe38dcf3', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Yao (prince d''Anding)', null, null, null, 'Fils de Liu Shan', 'Liu (Shu Han)', 410, 1894, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cf544a08-4543-50cb-9f4b-22fd19826b88', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Cong (prince de Xihe)', null, null, 262, 'Fils de Liu Shan', 'Liu (Shu Han)', 820, 1894, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('78c2e655-7a50-52d4-9e30-56549181ffc8', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Zan', null, null, null, 'Fils de Liu Shan', 'Liu (Shu Han)', 1230, 1894, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9fbed755-162a-5177-9c54-045eb4d71ade', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Chen (prince de Beidi)', null, null, 263, 'Fils de Liu Shan', 'Liu (Shu Han)', 1640, 1894, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('389b8cc9-a163-5002-94bf-b116c8e21d67', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Xun (prince de Xinxing)', null, null, null, 'Fils de Liu Shan', 'Liu (Shu Han)', 2050, 1894, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('30943622-7c56-52be-9040-3e564fe22639', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 'Liu Qian', null, null, null, 'Fils de Liu Shan', 'Liu (Shu Han)', 2460, 1894, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('19816912-3b68-500e-9aca-c8da992fc52d', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Jian', null, 155, 191, 'Chef militaire, père de Sun Ce et de Sun Quan', 'Sun (Wu)', 953, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ffdc900f-e5c0-56c9-a74f-0716b10f625b', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Dame Wu (impératrice Wulie)', null, null, null, 'Épouse de Sun Jian', 'Wu', 2819, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('08f27951-d5a1-59f2-a2e8-bfbfbfe8bb22', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Ce', null, 175, 200, 'Fondateur du pouvoir des Sun au Jiangdong', 'Sun (Wu)', 790, 504, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('088ba613-1c7f-5030-8491-992fb587864a', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Quan (Wu Dadi)', null, 182, 252, 'Premier empereur du Wu oriental (229 à 252)', 'Sun (Wu)', 3392, 504, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b43a9ced-775d-5e2e-bdf9-3ec2a53f5892', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Yi', null, null, null, 'Frère cadet de Sun Quan', 'Sun (Wu)', 1200, 504, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('502cb618-480b-5125-bc16-05e5da50757d', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Kuang', null, null, null, 'Frère cadet de Sun Quan', 'Sun (Wu)', 1610, 504, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('28d04a60-0f08-54e7-9aeb-22b259c1468f', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Dame Sun (Sun Shangxiang)', null, null, null, 'Sœur cadette de Sun Quan, épouse de Liu Bei', 'Sun (Wu)', 380, 504, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fc2d3cf5-c32b-53da-a234-d868e31022c0', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Shao', null, null, null, 'Fils posthume de Sun Ce', 'Sun (Wu)', 790, 964, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b93e54c7-7bb3-5426-b1ae-ac1a4f1b6e49', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Impératrice Pan (mère de Sun Liang)', null, null, 252, 'Concubine de Sun Quan, impératrice en 251', 'Pan', 6380, 504, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8370c23c-2b81-51be-ad91-497e53ab5cee', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Impératrice Dayi (Wang)', null, null, null, 'Concubine de Sun Quan, mère de Sun He et de Sun Ba', 'Wang', 2020, 504, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3c01666a-66a8-5adb-a27d-50c1bf93b0df', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Impératrice Jinghuai (Wang)', null, null, null, 'Concubine de Sun Quan (mère de Sun Xiu selon l''infobox)', 'Wang', 4480, 504, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f1fad412-1b76-5c35-b5ef-d21424bf87f1', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Deng (prince héritier Xuan)', null, 209, 241, 'Prince héritier du Wu', 'Sun (Wu)', 2706, 1275, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b2315fc2-35a3-5ad0-b8b0-a29ee10472a5', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Lü (marquis de Jianchang)', null, null, null, 'Fils de Sun Quan', 'Sun (Wu)', 3116, 1275, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('af602252-b08e-5fb9-aca0-7364cdb07201', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun He (prince héritier, puis prince de Nanyang)', null, 224, 253, 'Prince héritier du Wu, père de Sun Hao', 'Sun (Wu)', 1886, 1275, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3239e595-b0ec-5a59-a920-0086f3daf7bb', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Ba (prince de Lu)', null, null, 250, 'Fils de Sun Quan', 'Sun (Wu)', 2296, 1275, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9f3532d9-c1cb-59dc-b7c7-14d35341affa', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Fen (prince de Qi)', null, null, 270, 'Fils de Sun Quan', 'Sun (Wu)', 3526, 1275, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('914a6348-dca1-57f7-8841-81c95adf1983', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Xiu (Wu Jingdi)', null, 235, 264, 'Troisième empereur du Wu (258 à 264)', 'Sun (Wu)', 3936, 1275, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5d853e5e-c15b-5a77-9756-933dc352ced1', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Liang (Wu)', null, 243, 260, 'Deuxième empereur du Wu (252 à 258), déposé', 'Sun (Wu)', 4886, 1275, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('92bbb805-7784-5b65-954d-1d7abe487aa9', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Dame He (mère de Sun Hao)', null, null, null, 'Concubine de Sun He, impératrice douairière He', 'He', 1346, 1275, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('877c39bc-f87a-5828-9650-bcab18c0a7b5', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Hao (Wu Modi)', null, 242, 284, 'Quatrième et dernier empereur du Wu (264 à 280)', 'Sun (Wu)', 1616, 1735, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('944b8b5c-98ac-5561-8b4f-275880ae9498', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Impératrice Quan (épouse de Sun Liang)', null, null, null, 'Impératrice du Wu (253)', 'Quan', 5266, 1275, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d49dca3c-8976-5bf5-8b8a-e87788eca9c9', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Impératrice Jing (dame Zhu)', null, null, null, 'Impératrice du Wu, épouse de Sun Xiu', 'Zhu', 4476, 1275, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('be852441-d86b-5bb6-bab0-b12799e4a31c', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Sun Wan (prince héritier)', null, null, 266, 'Fils aîné de Sun Xiu', 'Sun (Wu)', 4206, 1800, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('44ee93fc-69dd-55e4-869d-20a51c16c7b8', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 'Impératrice Teng (épouse de Sun Hao)', null, null, null, 'Impératrice du Wu', 'Teng', 1996, 1735, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('5bafa790-59a2-5cc8-adcc-cfbcfe6ded62', 'bf55fded-75c7-52c4-840b-5fef1136b7e1', 'parent');
  perform pg_temp.rel('bf55fded-75c7-52c4-840b-5fef1136b7e1', '8bbd0b22-c284-5b49-b273-ad9b3ad54da5', 'spouse');
  perform pg_temp.rel('bf55fded-75c7-52c4-840b-5fef1136b7e1', '27151f5b-621c-5733-8a64-7732e9e96fce', 'spouse');
  perform pg_temp.rel('bf55fded-75c7-52c4-840b-5fef1136b7e1', 'c7776778-51fc-554d-abb8-7fd62194de7c', 'parent');
  perform pg_temp.rel('bf55fded-75c7-52c4-840b-5fef1136b7e1', '93d9cb04-c13c-58d1-b543-d4d44cc9779b', 'parent');
  perform pg_temp.rel('27151f5b-621c-5733-8a64-7732e9e96fce', '93d9cb04-c13c-58d1-b543-d4d44cc9779b', 'parent');
  perform pg_temp.rel('bf55fded-75c7-52c4-840b-5fef1136b7e1', 'e8224264-8e0a-560d-9569-63b7ad1b0a11', 'parent');
  perform pg_temp.rel('27151f5b-621c-5733-8a64-7732e9e96fce', 'e8224264-8e0a-560d-9569-63b7ad1b0a11', 'parent');
  perform pg_temp.rel('bf55fded-75c7-52c4-840b-5fef1136b7e1', '27531bb6-21d5-521c-8a7e-c4343333f4d4', 'parent');
  perform pg_temp.rel('27151f5b-621c-5733-8a64-7732e9e96fce', '27531bb6-21d5-521c-8a7e-c4343333f4d4', 'parent');
  perform pg_temp.rel('bf55fded-75c7-52c4-840b-5fef1136b7e1', 'c4366798-9b56-5357-a4f7-c928998218cd', 'parent');
  perform pg_temp.rel('bf55fded-75c7-52c4-840b-5fef1136b7e1', '5775cad5-a243-5489-b6e5-9cc4058e0a99', 'parent');
  perform pg_temp.rel('55dbd430-050d-53a6-a16f-c0a9f7eb291a', '5775cad5-a243-5489-b6e5-9cc4058e0a99', 'spouse');
  perform pg_temp.rel('93d9cb04-c13c-58d1-b543-d4d44cc9779b', 'd57f4e3b-43fa-529b-963f-1248946ca85e', 'spouse');
  perform pg_temp.rel('93d9cb04-c13c-58d1-b543-d4d44cc9779b', '8cd747f1-953b-525b-b607-fe3b83d5b7b1', 'spouse');
  perform pg_temp.rel('93d9cb04-c13c-58d1-b543-d4d44cc9779b', '9503272c-0d10-5e09-94fa-865bf537a42f', 'parent');
  perform pg_temp.rel('d57f4e3b-43fa-529b-963f-1248946ca85e', '9503272c-0d10-5e09-94fa-865bf537a42f', 'parent');
  perform pg_temp.rel('9503272c-0d10-5e09-94fa-865bf537a42f', '51da498b-247c-5044-8e3e-848b1efc6e0f', 'spouse');
  perform pg_temp.rel('9503272c-0d10-5e09-94fa-865bf537a42f', '5d4f74ab-6820-5755-8949-9cae0917b9af', 'spouse');
  perform pg_temp.rel('93d9cb04-c13c-58d1-b543-d4d44cc9779b', 'd4459b4a-1fff-52b6-b384-6224df74082e', 'parent');
  perform pg_temp.rel('27531bb6-21d5-521c-8a7e-c4343333f4d4', 'debdf985-4411-5560-9c0c-3347c23df3bd', 'parent');
  perform pg_temp.rel('debdf985-4411-5560-9c0c-3347c23df3bd', '6588a9b3-6de6-5093-b847-a7b231fdf055', 'parent');
  perform pg_temp.rel('9503272c-0d10-5e09-94fa-865bf537a42f', '6588a9b3-6de6-5093-b847-a7b231fdf055', 'family');
  perform pg_temp.rel('6588a9b3-6de6-5093-b847-a7b231fdf055', '1703696d-e705-58df-a334-475a48b65c06', 'spouse');
  perform pg_temp.rel('6588a9b3-6de6-5093-b847-a7b231fdf055', 'ddf4c132-8a9e-5144-a2d3-4ce2e9a229ab', 'spouse');
  perform pg_temp.rel('6588a9b3-6de6-5093-b847-a7b231fdf055', 'd256faf8-299a-5e9b-aee1-1edc498fe8b2', 'spouse');
  perform pg_temp.rel('d4459b4a-1fff-52b6-b384-6224df74082e', '90b70692-17d2-57d1-befa-1802a3bcaeb2', 'parent');
  perform pg_temp.rel('90b70692-17d2-57d1-befa-1802a3bcaeb2', 'fd911d79-2e93-5431-a593-151673d605cc', 'spouse');
  perform pg_temp.rel('c4366798-9b56-5357-a4f7-c928998218cd', 'c94e67b8-14bc-5b87-90e0-ad8fce2e16bc', 'parent');
  perform pg_temp.rel('c94e67b8-14bc-5b87-90e0-ad8fce2e16bc', 'f9c6a41b-d779-5b5f-affb-ad844425e17d', 'spouse');
  perform pg_temp.rel('8dccff3c-aae8-56db-a17b-0b974e29ac17', 'dceb9927-099b-5dd6-adb9-43faf7055686', 'parent');
  perform pg_temp.rel('dceb9927-099b-5dd6-adb9-43faf7055686', '444a6124-c92f-5d66-a62f-676440478890', 'spouse');
  perform pg_temp.rel('dceb9927-099b-5dd6-adb9-43faf7055686', '5436a5be-7329-595b-887d-2e1f1caf3b4c', 'spouse');
  perform pg_temp.rel('dceb9927-099b-5dd6-adb9-43faf7055686', '31b6aa9e-e53c-5988-9be3-dbae963ee940', 'spouse');
  perform pg_temp.rel('dceb9927-099b-5dd6-adb9-43faf7055686', '0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', 'parent');
  perform pg_temp.rel('444a6124-c92f-5d66-a62f-676440478890', '0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', 'parent');
  perform pg_temp.rel('dceb9927-099b-5dd6-adb9-43faf7055686', '3d2cbe62-9a94-5111-ae8a-d0ead46cb078', 'parent');
  perform pg_temp.rel('dceb9927-099b-5dd6-adb9-43faf7055686', '06a385c9-3891-5d58-b722-3a5488d82633', 'parent');
  perform pg_temp.rel('0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', '893990db-45a8-5c4e-ac46-1fdb9f7b5b41', 'spouse');
  perform pg_temp.rel('0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', '6fffd7ed-4a3f-5886-a716-a07d0372bde4', 'spouse');
  perform pg_temp.rel('0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', '8e36fe89-e746-5cf6-9bf2-d15e832e58bb', 'spouse');
  perform pg_temp.rel('0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', 'd5b8a323-0f5e-56bd-b1a8-3270a20028e4', 'parent');
  perform pg_temp.rel('8e36fe89-e746-5cf6-9bf2-d15e832e58bb', 'd5b8a323-0f5e-56bd-b1a8-3270a20028e4', 'parent');
  perform pg_temp.rel('0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', '51831785-5019-522a-9f80-89fcfe38dcf3', 'parent');
  perform pg_temp.rel('0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', 'cf544a08-4543-50cb-9f4b-22fd19826b88', 'parent');
  perform pg_temp.rel('0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', '78c2e655-7a50-52d4-9e30-56549181ffc8', 'parent');
  perform pg_temp.rel('0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', '9fbed755-162a-5177-9c54-045eb4d71ade', 'parent');
  perform pg_temp.rel('0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', '389b8cc9-a163-5002-94bf-b116c8e21d67', 'parent');
  perform pg_temp.rel('0fbb2c31-6cc2-5e12-8d47-8c4cf96ca0b5', '30943622-7c56-52be-9040-3e564fe22639', 'parent');
  perform pg_temp.rel('19816912-3b68-500e-9aca-c8da992fc52d', 'ffdc900f-e5c0-56c9-a74f-0716b10f625b', 'spouse');
  perform pg_temp.rel('19816912-3b68-500e-9aca-c8da992fc52d', '08f27951-d5a1-59f2-a2e8-bfbfbfe8bb22', 'parent');
  perform pg_temp.rel('ffdc900f-e5c0-56c9-a74f-0716b10f625b', '08f27951-d5a1-59f2-a2e8-bfbfbfe8bb22', 'parent');
  perform pg_temp.rel('19816912-3b68-500e-9aca-c8da992fc52d', '088ba613-1c7f-5030-8491-992fb587864a', 'parent');
  perform pg_temp.rel('ffdc900f-e5c0-56c9-a74f-0716b10f625b', '088ba613-1c7f-5030-8491-992fb587864a', 'parent');
  perform pg_temp.rel('19816912-3b68-500e-9aca-c8da992fc52d', 'b43a9ced-775d-5e2e-bdf9-3ec2a53f5892', 'parent');
  perform pg_temp.rel('ffdc900f-e5c0-56c9-a74f-0716b10f625b', 'b43a9ced-775d-5e2e-bdf9-3ec2a53f5892', 'parent');
  perform pg_temp.rel('19816912-3b68-500e-9aca-c8da992fc52d', '502cb618-480b-5125-bc16-05e5da50757d', 'parent');
  perform pg_temp.rel('ffdc900f-e5c0-56c9-a74f-0716b10f625b', '502cb618-480b-5125-bc16-05e5da50757d', 'parent');
  perform pg_temp.rel('19816912-3b68-500e-9aca-c8da992fc52d', '28d04a60-0f08-54e7-9aeb-22b259c1468f', 'parent');
  perform pg_temp.rel('ffdc900f-e5c0-56c9-a74f-0716b10f625b', '28d04a60-0f08-54e7-9aeb-22b259c1468f', 'parent');
  perform pg_temp.rel('dceb9927-099b-5dd6-adb9-43faf7055686', '28d04a60-0f08-54e7-9aeb-22b259c1468f', 'spouse');
  perform pg_temp.rel('08f27951-d5a1-59f2-a2e8-bfbfbfe8bb22', 'fc2d3cf5-c32b-53da-a234-d868e31022c0', 'parent');
  perform pg_temp.rel('088ba613-1c7f-5030-8491-992fb587864a', 'b93e54c7-7bb3-5426-b1ae-ac1a4f1b6e49', 'spouse');
  perform pg_temp.rel('088ba613-1c7f-5030-8491-992fb587864a', '8370c23c-2b81-51be-ad91-497e53ab5cee', 'spouse');
  perform pg_temp.rel('088ba613-1c7f-5030-8491-992fb587864a', '3c01666a-66a8-5adb-a27d-50c1bf93b0df', 'spouse');
  perform pg_temp.rel('088ba613-1c7f-5030-8491-992fb587864a', 'f1fad412-1b76-5c35-b5ef-d21424bf87f1', 'parent');
  perform pg_temp.rel('088ba613-1c7f-5030-8491-992fb587864a', 'b2315fc2-35a3-5ad0-b8b0-a29ee10472a5', 'parent');
  perform pg_temp.rel('088ba613-1c7f-5030-8491-992fb587864a', '9f3532d9-c1cb-59dc-b7c7-14d35341affa', 'parent');
  perform pg_temp.rel('088ba613-1c7f-5030-8491-992fb587864a', 'af602252-b08e-5fb9-aca0-7364cdb07201', 'parent');
  perform pg_temp.rel('8370c23c-2b81-51be-ad91-497e53ab5cee', 'af602252-b08e-5fb9-aca0-7364cdb07201', 'parent');
  perform pg_temp.rel('088ba613-1c7f-5030-8491-992fb587864a', '3239e595-b0ec-5a59-a920-0086f3daf7bb', 'parent');
  perform pg_temp.rel('8370c23c-2b81-51be-ad91-497e53ab5cee', '3239e595-b0ec-5a59-a920-0086f3daf7bb', 'parent');
  perform pg_temp.rel('088ba613-1c7f-5030-8491-992fb587864a', '914a6348-dca1-57f7-8841-81c95adf1983', 'parent');
  perform pg_temp.rel('3c01666a-66a8-5adb-a27d-50c1bf93b0df', '914a6348-dca1-57f7-8841-81c95adf1983', 'parent');
  perform pg_temp.rel('088ba613-1c7f-5030-8491-992fb587864a', '5d853e5e-c15b-5a77-9756-933dc352ced1', 'parent');
  perform pg_temp.rel('b93e54c7-7bb3-5426-b1ae-ac1a4f1b6e49', '5d853e5e-c15b-5a77-9756-933dc352ced1', 'parent');
  perform pg_temp.rel('af602252-b08e-5fb9-aca0-7364cdb07201', '92bbb805-7784-5b65-954d-1d7abe487aa9', 'spouse');
  perform pg_temp.rel('af602252-b08e-5fb9-aca0-7364cdb07201', '877c39bc-f87a-5828-9650-bcab18c0a7b5', 'parent');
  perform pg_temp.rel('92bbb805-7784-5b65-954d-1d7abe487aa9', '877c39bc-f87a-5828-9650-bcab18c0a7b5', 'parent');
  perform pg_temp.rel('5d853e5e-c15b-5a77-9756-933dc352ced1', '944b8b5c-98ac-5561-8b4f-275880ae9498', 'spouse');
  perform pg_temp.rel('914a6348-dca1-57f7-8841-81c95adf1983', 'd49dca3c-8976-5bf5-8b8a-e87788eca9c9', 'spouse');
  perform pg_temp.rel('914a6348-dca1-57f7-8841-81c95adf1983', 'be852441-d86b-5bb6-bab0-b12799e4a31c', 'parent');
  perform pg_temp.rel('d49dca3c-8976-5bf5-8b8a-e87788eca9c9', 'be852441-d86b-5bb6-bab0-b12799e4a31c', 'parent');
  perform pg_temp.rel('877c39bc-f87a-5828-9650-bcab18c0a7b5', '44ee93fc-69dd-55e4-869d-20a51c16c7b8', 'spouse');
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('55dbd430-050d-53a6-a16f-c0a9f7eb291a', 'entry', '0a46f6f1-ad3d-5f40-bd57-c4586f614a5d', 674, 1263, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('28d04a60-0f08-54e7-9aeb-22b259c1468f', 'entry', '5dadf3a6-af63-59d3-9c3d-92916e775595', 4089, 558, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('dceb9927-099b-5dd6-adb9-43faf7055686', 'entry', 'daa6cbf2-c844-5212-9684-288dd49ab751', 0, 504, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v58 : % membres ajoutés.', 67;
end $$;
