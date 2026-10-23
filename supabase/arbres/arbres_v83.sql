-- arbres_v83.sql — Chine — dynastie Song (Nord et Sud) de Taizu à l'empereur Bing
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Song » (aucun n'existait). Rien n'est supprimé.
-- Dates : connues par ailleurs (histoire de Chine), aucune page consultée pour ce lot. Les adoptions et frères sont reliés par un lien « famille » (pas de filiation).
-- L'impératrice Liu (régente) vient d'une famille sans arbre : signalée.
-- Non fait : épouses autres que Liu, princes non empereurs (dont les ancêtres de Yingzong, Xiaozong, Lizong, Duzong).
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
  if exists (select 1 from public.genealogy_members where id = 'a4fe89c6-766e-54ce-8e30-4b5ba8d34008') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Song » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Song';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('53adefe6-5d13-5193-b184-5014688ac127', cat_id, 'country', 'CHN', top, 'Song', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '53adefe6-5d13-5193-b184-5014688ac127';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'country', 'CHN', 'genealogy', 'Song', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a4fe89c6-766e-54ce-8e30-4b5ba8d34008', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Taizu (Zhao Kuangyin)', null, 927, 976, 'Fondateur des Song (960-976)', 'Song (Zhao)', 6240, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('965d1ef2-a7a4-5071-a392-e08167ee474f', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Taizong (Zhao Jiong)', null, 939, 997, 'Empereur (976-997)', 'Song (Zhao)', 2240, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a03eea47-2773-59cc-bd5c-7393419fb6b3', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Zhenzong (Zhao Heng)', null, 968, 1022, 'Empereur (997-1022)', 'Song (Zhao)', 2240, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aa07ae97-ea97-50b3-bea3-a83a5b435e52', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Renzong (Zhao Zhen)', null, 1010, 1063, 'Empereur (1022-1063)', 'Song (Zhao)', 2240, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e3682896-7aa5-57e2-837c-fc0e5a82ed63', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Yingzong (Zhao Shu)', null, 1032, 1067, 'Empereur (1063-1067)', 'Song (Zhao)', 250, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('70a58fd3-c13a-5018-9796-5eb3b0074ea9', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Shenzong (Zhao Xu)', null, 1048, 1085, 'Empereur (1067-1085)', 'Song (Zhao)', 250, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9e839739-3b1b-58cc-82f2-1997c48abaad', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Zhezong (Zhao Xu)', null, 1077, 1100, 'Empereur (1085-1100)', 'Song (Zhao)', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9b222ea5-1d90-5008-a7a5-871fc434a9c2', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Huizong (Zhao Ji)', null, 1082, 1135, 'Empereur (1100-1126), capturé par les Jin', 'Song (Zhao)', 500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bf748d00-5486-54f6-bad5-b834cb00b09b', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Qinzong (Zhao Huan)', null, 1100, 1161, 'Empereur (1126-1127), capturé par les Jin', 'Song (Zhao)', 250, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5737f5e1-8b44-57f9-a3f1-61feb351724a', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Gaozong (Zhao Gou)', null, 1107, 1187, 'Premier empereur des Song du Sud (1127-1162)', 'Song (Zhao)', 750, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0f8ade02-865e-568b-b3ce-f3cf512b171e', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Xiaozong (Zhao Shen)', null, 1127, 1194, 'Empereur (1162-1189)', 'Song (Zhao)', 5240, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dd50b8c5-2401-5c0a-8a3f-df556aed28bf', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Guangzong (Zhao Dun)', null, 1147, 1200, 'Empereur (1189-1194)', 'Song (Zhao)', 5240, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7979b5ef-4aa2-501e-977a-eb1e74eadf36', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Ningzong (Zhao Kuo)', null, 1168, 1224, 'Empereur (1194-1224)', 'Song (Zhao)', 5240, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('51bb7300-bb23-5499-898b-fd39561029de', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Lizong (Zhao Yun)', null, 1205, 1264, 'Empereur (1224-1264)', 'Song (Zhao)', 7240, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a988b8da-235b-556c-aa21-d2d6cb432a31', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Duzong (Zhao Qi)', null, 1240, 1274, 'Empereur (1264-1274)', 'Song (Zhao)', 3740, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bd69a896-e75e-5ca5-9d7a-c7537ddda9f0', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Gongdi (Zhao Xian)', null, 1271, 1323, 'Empereur (1274-1276), se rend aux Mongols', 'Song (Zhao)', 3740, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('041202f4-ceea-59f9-8ba3-b039e360dd46', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Duanzong (Zhao Shi)', null, 1270, 1278, 'Empereur (1276-1278)', 'Song (Zhao)', 3240, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fae66c94-90da-57a6-a24b-f1132bd8920c', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Song Bing (Zhao Bing)', null, 1272, 1279, 'Dernier empereur Song (1278-1279)', 'Song (Zhao)', 4240, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ecf39c10-42ad-566c-8686-dae8361f98de', 'entry', '7385b184-f10a-5d1a-b8a5-dcebfdf18709', 'Impératrice douairière Liu', null, 968, 1033, 'Épouse de Zhenzong, régente de Renzong', 'Liu', 1750, 640, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('965d1ef2-a7a4-5071-a392-e08167ee474f', 'a03eea47-2773-59cc-bd5c-7393419fb6b3', 'parent');
  perform pg_temp.rel('a03eea47-2773-59cc-bd5c-7393419fb6b3', 'aa07ae97-ea97-50b3-bea3-a83a5b435e52', 'parent');
  perform pg_temp.rel('e3682896-7aa5-57e2-837c-fc0e5a82ed63', '70a58fd3-c13a-5018-9796-5eb3b0074ea9', 'parent');
  perform pg_temp.rel('70a58fd3-c13a-5018-9796-5eb3b0074ea9', '9e839739-3b1b-58cc-82f2-1997c48abaad', 'parent');
  perform pg_temp.rel('70a58fd3-c13a-5018-9796-5eb3b0074ea9', '9b222ea5-1d90-5008-a7a5-871fc434a9c2', 'parent');
  perform pg_temp.rel('9b222ea5-1d90-5008-a7a5-871fc434a9c2', 'bf748d00-5486-54f6-bad5-b834cb00b09b', 'parent');
  perform pg_temp.rel('9b222ea5-1d90-5008-a7a5-871fc434a9c2', '5737f5e1-8b44-57f9-a3f1-61feb351724a', 'parent');
  perform pg_temp.rel('0f8ade02-865e-568b-b3ce-f3cf512b171e', 'dd50b8c5-2401-5c0a-8a3f-df556aed28bf', 'parent');
  perform pg_temp.rel('dd50b8c5-2401-5c0a-8a3f-df556aed28bf', '7979b5ef-4aa2-501e-977a-eb1e74eadf36', 'parent');
  perform pg_temp.rel('a988b8da-235b-556c-aa21-d2d6cb432a31', 'bd69a896-e75e-5ca5-9d7a-c7537ddda9f0', 'parent');
  perform pg_temp.rel('a988b8da-235b-556c-aa21-d2d6cb432a31', '041202f4-ceea-59f9-8ba3-b039e360dd46', 'parent');
  perform pg_temp.rel('a988b8da-235b-556c-aa21-d2d6cb432a31', 'fae66c94-90da-57a6-a24b-f1132bd8920c', 'parent');
  perform pg_temp.rel('a4fe89c6-766e-54ce-8e30-4b5ba8d34008', '965d1ef2-a7a4-5071-a392-e08167ee474f', 'family');
  perform pg_temp.rel('aa07ae97-ea97-50b3-bea3-a83a5b435e52', 'e3682896-7aa5-57e2-837c-fc0e5a82ed63', 'family');
  perform pg_temp.rel('5737f5e1-8b44-57f9-a3f1-61feb351724a', '0f8ade02-865e-568b-b3ce-f3cf512b171e', 'family');
  perform pg_temp.rel('7979b5ef-4aa2-501e-977a-eb1e74eadf36', '51bb7300-bb23-5499-898b-fd39561029de', 'family');
  perform pg_temp.rel('51bb7300-bb23-5499-898b-fd39561029de', 'a988b8da-235b-556c-aa21-d2d6cb432a31', 'family');
  perform pg_temp.rel('a03eea47-2773-59cc-bd5c-7393419fb6b3', 'ecf39c10-42ad-566c-8686-dae8361f98de', 'spouse');
  perform pg_temp.rel('ecf39c10-42ad-566c-8686-dae8361f98de', 'aa07ae97-ea97-50b3-bea3-a83a5b435e52', 'family');
  raise notice 'schema_v83 : % membres ajoutés.', 19;
end $$;
