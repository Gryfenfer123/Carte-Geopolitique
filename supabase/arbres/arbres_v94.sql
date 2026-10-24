-- arbres_v94.sql — Italie — Hauteville : Normands d'Italie du Sud, comtes puis rois de Sicile, et princes d'Antioche
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Hauteville » (aucun n'existait). Constance de Hauteville (arbre Hohenstaufen) y est affichée. Rien n'est supprimé.
-- Dates : connues par ailleurs (histoire de la Sicile), aucune page consultée pour ce lot ; les dates anciennes sont approximatives (notées).
-- Jeanne d'Angleterre est créée dans l'arbre Plantagenêts. Autres épouses de familles sans arbre (Salerne, Buonalbergo, Aleramici, Bourgogne, Navarre…) : signalées.
-- Non fait : les nombreux frères et enfants cadets, Tancrède de Galilée, ducs de Pouille au-delà de Roger Borsa.
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
  if exists (select 1 from public.genealogy_members where id = '90a6febb-27ff-5eed-92e8-3cb353329f5d') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('4433a65f-3db3-4d8a-bb05-64e228145658','5bb15ac8-132c-4ca2-a227-0e0254422770','ba3d69dd-6641-4814-b199-7efbc8d62cba');
  if k <> 3 then raise exception 'Membres préexistants manquants (% sur 3) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Hauteville » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Hauteville';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('849a4ec8-c8dc-576e-ab81-486d1e9a30e4', cat_id, 'country', 'ITA', top, 'Hauteville', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '849a4ec8-c8dc-576e-ab81-486d1e9a30e4';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'country', 'ITA', 'genealogy', 'Hauteville', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = '177fd0be-7236-4c6f-b8d6-08eab212742a' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Les Plantagenêts introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '19aed0d5-8c4a-4125-b821-8fc6bc357dab' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Hohenstaufen introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('90a6febb-27ff-5eed-92e8-3cb353329f5d', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Tancrède de Hauteville', null, 980, 1041, 'Seigneur normand, père des Hauteville d''Italie', 'Hauteville', 1979, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0c33dd90-fe79-5979-97c2-50f153389464', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Guillaume Bras-de-Fer', null, 1010, 1046, 'Premier comte d''Apulie', 'Hauteville', 3470, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3f15cd4f-a764-5721-ab14-721d356f8363', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Drogon de Hauteville', null, 1010, 1051, 'Comte d''Apulie', 'Hauteville', 1480, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5a8ea3eb-7c1d-5a44-add5-079831d6e2b8', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Onfroi de Hauteville', null, 1010, 1057, 'Comte d''Apulie', 'Hauteville', 1980, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('147883b2-250e-542c-bc5a-07c568536c51', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Robert Guiscard', null, 1015, 1085, 'Duc de Pouille et de Calabre', 'Hauteville', 490, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e79e4742-367f-514c-b87b-b9a8d7ccbfd2', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Roger Ier de Sicile', null, 1031, 1101, 'Grand comte de Sicile', 'Hauteville', 2480, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('22a95b32-b29d-59ea-b3e5-a023469e5ab9', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Alberade de Buonalbergo', null, null, null, 'Première épouse de Robert Guiscard', 'Buonalbergo', 0, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e47a9c23-352f-5fdb-9d3f-d32742788366', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Sikelgaïta de Salerne', null, 1040, 1090, 'Seconde épouse de Robert Guiscard', 'Salerne (Lombards)', 980, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cfaef95f-43b2-5c43-becc-e8782facb573', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Bohémond Ier de Tarente', null, 1058, 1111, 'Prince d''Antioche, chef de la 1re croisade', 'Hauteville', 231, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9927b075-c15d-519b-9c8c-012e974b4ebb', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Roger Borsa', null, 1060, 1111, 'Duc de Pouille', 'Hauteville', 732, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6c08352a-1d4a-5e3a-8457-9b17f328240f', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Bohémond II d''Antioche', null, 1108, 1130, 'Prince d''Antioche', 'Hauteville', 231, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('faf8d9f2-24d5-50f4-a026-b4db932045d0', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Adélaïde del Vasto', null, 1075, 1118, 'Comtesse de Sicile, reine de Jérusalem', 'Aleramici', 2970, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4399d4f0-afa5-5c61-b022-4e4784331625', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Roger II de Sicile', null, 1095, 1154, 'Premier roi de Sicile', 'Hauteville', 2777, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7f1aa5df-e5c3-5b63-9688-3f9b9ebd1368', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Elvire de Castille', null, 1100, 1135, 'Reine de Sicile', 'Castille-León', 2287, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2b6baa10-1b65-5a35-bf3b-2f3e308a05be', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Guillaume Ier le Mauvais', null, 1131, 1166, 'Roi de Sicile', 'Hauteville', 2674, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1592762d-d1a4-59eb-81a8-bfb4b10b3156', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Roger, duc de Pouille', null, 1118, 1148, 'Fils de Roger II', 'Hauteville', 1677, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aba63a5f-cde0-5146-b0ae-8eb85d52e2cf', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Tancrède de Lecce', null, 1138, 1194, 'Roi de Sicile', 'Hauteville', 1677, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1ea528ad-f044-5b7a-9298-2894fc91c6c1', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Marguerite de Navarre', null, 1128, 1183, 'Reine de Sicile, régente', 'Navarre', 2184, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ae11a514-334d-5fb8-b3d9-9bb982f21ad2', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Guillaume II le Bon', null, 1153, 1189, 'Roi de Sicile', 'Hauteville', 2429, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d2bc229d-9ea3-5b64-8a2c-eeb422b8a7d8', 'entry', '177fd0be-7236-4c6f-b8d6-08eab212742a', 'Jeanne d''Angleterre (1165-1199)', null, 1165, 1199, 'Reine de Sicile, comtesse de Toulouse', 'Plantagenêts', 354000, 2970, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1bd74a80-2834-57bc-99d4-8635a50f2186', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Sibylle d''Acerra', null, null, null, 'Reine de Sicile, épouse de Tancrède', 'Acerra', 1187, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d5e93fcd-61c4-5a83-b7de-c7418bcab0ff', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Guillaume III de Sicile', null, 1185, 1198, 'Roi de Sicile (1194)', 'Hauteville', 1432, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('debd5644-87c5-5256-a55c-03bfd6518aa4', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 'Béatrice de Rethel', null, 1130, 1185, 'Reine de Sicile, 3e épouse de Roger II', 'Rethel', 3267, 2560, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('90a6febb-27ff-5eed-92e8-3cb353329f5d', '0c33dd90-fe79-5979-97c2-50f153389464', 'parent');
  perform pg_temp.rel('90a6febb-27ff-5eed-92e8-3cb353329f5d', '3f15cd4f-a764-5721-ab14-721d356f8363', 'parent');
  perform pg_temp.rel('90a6febb-27ff-5eed-92e8-3cb353329f5d', '5a8ea3eb-7c1d-5a44-add5-079831d6e2b8', 'parent');
  perform pg_temp.rel('90a6febb-27ff-5eed-92e8-3cb353329f5d', '147883b2-250e-542c-bc5a-07c568536c51', 'parent');
  perform pg_temp.rel('90a6febb-27ff-5eed-92e8-3cb353329f5d', 'e79e4742-367f-514c-b87b-b9a8d7ccbfd2', 'parent');
  perform pg_temp.rel('147883b2-250e-542c-bc5a-07c568536c51', '22a95b32-b29d-59ea-b3e5-a023469e5ab9', 'spouse');
  perform pg_temp.rel('147883b2-250e-542c-bc5a-07c568536c51', 'e47a9c23-352f-5fdb-9d3f-d32742788366', 'spouse');
  perform pg_temp.rel('147883b2-250e-542c-bc5a-07c568536c51', 'cfaef95f-43b2-5c43-becc-e8782facb573', 'parent');
  perform pg_temp.rel('22a95b32-b29d-59ea-b3e5-a023469e5ab9', 'cfaef95f-43b2-5c43-becc-e8782facb573', 'parent');
  perform pg_temp.rel('147883b2-250e-542c-bc5a-07c568536c51', '9927b075-c15d-519b-9c8c-012e974b4ebb', 'parent');
  perform pg_temp.rel('e47a9c23-352f-5fdb-9d3f-d32742788366', '9927b075-c15d-519b-9c8c-012e974b4ebb', 'parent');
  perform pg_temp.rel('cfaef95f-43b2-5c43-becc-e8782facb573', '6c08352a-1d4a-5e3a-8457-9b17f328240f', 'parent');
  perform pg_temp.rel('e79e4742-367f-514c-b87b-b9a8d7ccbfd2', 'faf8d9f2-24d5-50f4-a026-b4db932045d0', 'spouse');
  perform pg_temp.rel('e79e4742-367f-514c-b87b-b9a8d7ccbfd2', '4399d4f0-afa5-5c61-b022-4e4784331625', 'parent');
  perform pg_temp.rel('faf8d9f2-24d5-50f4-a026-b4db932045d0', '4399d4f0-afa5-5c61-b022-4e4784331625', 'parent');
  perform pg_temp.rel('4399d4f0-afa5-5c61-b022-4e4784331625', '7f1aa5df-e5c3-5b63-9688-3f9b9ebd1368', 'spouse');
  perform pg_temp.rel('4399d4f0-afa5-5c61-b022-4e4784331625', '2b6baa10-1b65-5a35-bf3b-2f3e308a05be', 'parent');
  perform pg_temp.rel('7f1aa5df-e5c3-5b63-9688-3f9b9ebd1368', '2b6baa10-1b65-5a35-bf3b-2f3e308a05be', 'parent');
  perform pg_temp.rel('4399d4f0-afa5-5c61-b022-4e4784331625', '1592762d-d1a4-59eb-81a8-bfb4b10b3156', 'parent');
  perform pg_temp.rel('7f1aa5df-e5c3-5b63-9688-3f9b9ebd1368', '1592762d-d1a4-59eb-81a8-bfb4b10b3156', 'parent');
  perform pg_temp.rel('1592762d-d1a4-59eb-81a8-bfb4b10b3156', 'aba63a5f-cde0-5146-b0ae-8eb85d52e2cf', 'parent');
  perform pg_temp.rel('2b6baa10-1b65-5a35-bf3b-2f3e308a05be', '1ea528ad-f044-5b7a-9298-2894fc91c6c1', 'spouse');
  perform pg_temp.rel('2b6baa10-1b65-5a35-bf3b-2f3e308a05be', 'ae11a514-334d-5fb8-b3d9-9bb982f21ad2', 'parent');
  perform pg_temp.rel('1ea528ad-f044-5b7a-9298-2894fc91c6c1', 'ae11a514-334d-5fb8-b3d9-9bb982f21ad2', 'parent');
  perform pg_temp.rel('4433a65f-3db3-4d8a-bb05-64e228145658', 'd2bc229d-9ea3-5b64-8a2c-eeb422b8a7d8', 'parent');
  perform pg_temp.rel('ba3d69dd-6641-4814-b199-7efbc8d62cba', 'd2bc229d-9ea3-5b64-8a2c-eeb422b8a7d8', 'parent');
  perform pg_temp.rel('ae11a514-334d-5fb8-b3d9-9bb982f21ad2', 'd2bc229d-9ea3-5b64-8a2c-eeb422b8a7d8', 'spouse');
  perform pg_temp.rel('aba63a5f-cde0-5146-b0ae-8eb85d52e2cf', '1bd74a80-2834-57bc-99d4-8635a50f2186', 'spouse');
  perform pg_temp.rel('aba63a5f-cde0-5146-b0ae-8eb85d52e2cf', 'd5e93fcd-61c4-5a83-b7de-c7418bcab0ff', 'parent');
  perform pg_temp.rel('1bd74a80-2834-57bc-99d4-8635a50f2186', 'd5e93fcd-61c4-5a83-b7de-c7418bcab0ff', 'parent');
  perform pg_temp.rel('4399d4f0-afa5-5c61-b022-4e4784331625', 'debd5644-87c5-5256-a55c-03bfd6518aa4', 'spouse');
  perform pg_temp.rel('4399d4f0-afa5-5c61-b022-4e4784331625', '5bb15ac8-132c-4ca2-a227-0e0254422770', 'parent');
  perform pg_temp.rel('debd5644-87c5-5256-a55c-03bfd6518aa4', '5bb15ac8-132c-4ca2-a227-0e0254422770', 'parent');
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('d2bc229d-9ea3-5b64-8a2c-eeb422b8a7d8', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 2919, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('5bb15ac8-132c-4ca2-a227-0e0254422770', 'entry', 'ea00181b-77f0-5dc4-845b-50bacdaaed6d', 3174, 3200, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v94 : % membres ajoutés.', 23;
end $$;
