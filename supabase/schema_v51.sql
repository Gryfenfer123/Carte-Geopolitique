-- schema_v51.sql — Chypre — Lusignan
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Crée sous Chypre > Dynastie : Lusignan (Guy de Lusignan -> Jacques III), à partir de Wikipédia anglais. La branche d'origine (Poitou, France) n'est pas créée : l'arbre démarre au premier roi de Chypre.
-- Dates : la page ne donne presque aucune naissance ; celles saisies viennent de ma connaissance générale et sont toutes marquées « non revérifiées sur la page » dans le rapport.
-- Épouses/époux sans arbre, signalés : Sibylle et Isabelle de Jérusalem, Alix de Champagne, Hélène Paléologue, Amédée de Montferrat, Charlotte de Bourbon, Helvis de Brunswick-Grubenhagen, Éléonore d'Aragon, Louis de Savoie, Catherine Cornaro.
-- Hors périmètre ici : la période vénitienne, puis ottomane et britannique.
-- Prérequis : v50 exécuté.
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
  if exists (select 1 from public.genealogy_members where id = 'a2e6e3f1-e9a7-5942-a8ef-6e3f055f7106') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Lusignan » (CYP)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CYP' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CYP : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Lusignan';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('45a46af3-2d41-5f90-ad94-c7fc0ff747ca', cat_id, 'country', 'CYP', top, 'Lusignan', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '45a46af3-2d41-5f90-ad94-c7fc0ff747ca';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('9735b3f2-1004-5697-9366-38c2b38b5c8f', 'country', 'CYP', 'genealogy', 'Lusignan', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a2e6e3f1-e9a7-5942-a8ef-6e3f055f7106', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Guy de Lusignan', null, 1150, 1194, 'Roi de Jérusalem, premier seigneur de Chypre (1192-1194)', 'Lusignan', 2152, 90, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('16f9184b-978e-5641-8c54-3d45328a323a', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Sibylle de Jérusalem', null, null, 1190, 'Reine de Jérusalem', 'Anjou (Jérusalem)', 2532, 90, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0d2d847f-49b3-596c-a732-09a14fb59dd3', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Aimery de Lusignan', null, 1145, 1205, 'Roi de Chypre (1196-1205) et de Jérusalem', 'Lusignan', 1242, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('34cd8af1-ee9d-5df8-9a9d-ba3dd0e318c3', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Échive d''Ibelin', null, null, null, 'Reine de Chypre', 'Ibelin', 702, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7cb125e8-8fa3-54d0-b72e-5f5407a54d7b', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Isabelle Ire de Jérusalem', null, 1172, 1205, 'Reine de Jérusalem, épouse d''Aimery', 'Anjou (Jérusalem)', 1622, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('addc4169-dcb7-5819-965a-a4dfff1fb6a8', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Hugues Ier de Chypre', null, 1194, 1218, 'Roi de Chypre (1205-1218)', 'Lusignan', 972, 882, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('39c7fc24-d70e-5504-9893-b4b7f99147ec', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Alix de Champagne', null, 1195, 1246, 'Reine de Chypre, régente', 'Champagne', 1710, 882, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2cdbdd61-3498-5208-976c-f5df8e02f0f2', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Henri Ier de Chypre', null, 1217, 1253, 'Roi de Chypre (1218-1253)', 'Lusignan', 1719, 1342, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6b313c8b-9950-56d9-90eb-334833fb8952', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Hugues II de Chypre', null, 1252, 1267, 'Roi de Chypre (1253-1267), mort à 14 ans', 'Lusignan', 1719, 1926, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('18ed6f82-2ea7-585d-8a0e-25af21002302', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Isabelle de Lusignan (fille d''Hugues Ier)', null, null, null, 'Princesse d''Antioche', 'Lusignan', 964, 1342, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('16d612db-d9bc-5397-b845-174d741f8c16', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Henri d''Antioche', null, null, null, 'Prince d''Antioche, père d''Hugues III', 'Poitiers-Antioche', 424, 1342, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9f32edad-3cdf-5c76-a662-aed83d71979a', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Hugues III de Chypre (d''Antioche-Lusignan)', null, 1235, 1284, 'Roi de Chypre (1267-1284), roi de Jérusalem', 'Lusignan', 694, 1802, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('23b049c1-1255-5d9a-8dd3-cc4569c7ad4e', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Jean Ier de Chypre', null, 1259, 1285, 'Roi de Chypre (1284-1285)', 'Lusignan', 79, 2262, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e3a792e5-d6d0-5099-8156-8062c3499d9a', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Henri II de Chypre', null, 1270, 1324, 'Roi de Chypre (1285-1324), roi de Jérusalem', 'Lusignan', 899, 2262, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a395d464-4133-5b30-9226-e0333a594a63', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Amaury de Lusignan (seigneur de Tyr)', null, 1272, 1310, 'Gouverneur de Chypre (1306-1310)', 'Lusignan', 1309, 2262, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fb34f8b2-f51d-53c3-82b2-4d794fb6bbbe', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Guy de Lusignan (connétable de Chypre)', null, null, 1308, 'Connétable de Chypre', 'Lusignan', 489, 2262, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cd933915-3384-53f0-a8a6-73f5de288ede', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Hugues IV de Chypre', null, 1295, 1359, 'Roi de Chypre (1324-1359)', 'Lusignan', 489, 2722, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('85f0c63e-cd29-5359-a24e-b31860641073', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Alix d''Ibelin (épouse d''Hugues IV)', null, null, null, 'Reine de Chypre', 'Ibelin', 1001, 2722, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f589ad56-833f-5499-a249-ad472b39376d', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Pierre Ier de Chypre', null, 1328, 1369, 'Roi de Chypre (1359-1369), assassiné', 'Lusignan', 540, 3348, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4c86b19e-c8a1-59ba-8547-4d694d505684', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Jacques Ier de Chypre', null, 1334, 1398, 'Roi de Chypre (1382-1398)', 'Lusignan', 950, 3348, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c0ba29bc-e048-5c47-ba29-aabf56a779c4', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Éléonore d''Aragon (reine de Chypre)', null, 1333, 1417, 'Reine de Chypre', 'Aragon (Gandie)', 0, 3348, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('43998cc6-fb33-5c2e-b2fe-60440c1ac100', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Pierre II de Chypre', null, 1354, 1382, 'Roi de Chypre (1369-1382)', 'Lusignan', 270, 3808, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ba201d68-9325-5355-be1c-7bf30efda128', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Helvis de Brunswick-Grubenhagen', null, null, null, 'Reine de Chypre', 'Welf (Brunswick-Grubenhagen)', 1490, 3348, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6da50982-3c97-55d6-90aa-65a5ebcedf40', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Janus de Chypre', null, 1375, 1432, 'Roi de Chypre (1398-1432)', 'Lusignan', 1220, 4140, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('339d461e-3299-5999-9dc2-2bca5a09e2b8', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Charlotte de Bourbon (reine de Chypre)', null, null, 1422, 'Reine de Chypre', 'Bourbon-La Marche', 1760, 4140, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('70663dcd-100e-59ae-865c-75d28ff40419', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Jean II de Chypre', null, 1418, 1458, 'Roi de Chypre (1432-1458)', 'Lusignan', 1490, 4914, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6af063d5-89e6-5f99-b896-b67a1dc637da', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Amadée de Montferrat', null, null, 1440, 'Reine de Chypre', 'Paléologue de Montferrat', 1110, 4914, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('86576f75-0d7c-53c0-a2b2-cc7aa13a4cb1', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Hélène Paléologue (reine de Chypre)', null, 1428, 1458, 'Reine de Chypre', 'Paléologue (Byzance)', 2850, 4914, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('41738076-811d-534d-8d8a-08e959f22069', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Charlotte de Chypre', null, 1444, 1487, 'Reine de Chypre (1458-1464), prétendante', 'Lusignan', 2170, 5374, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5a3f6300-ae16-5aaf-8502-95dd1a88a4c6', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Louis de Savoie (roi consort de Chypre)', null, 1436, 1482, 'Comte de Genève, roi consort de Chypre', 'Savoie', 2550, 5374, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('061af3a4-d951-5e87-95bb-053c8067f2fe', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Marietta de Patras', null, null, null, 'Mère de Jacques II', 'Origine : Patras', 2030, 4914, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a7048bf4-a34f-59d6-811e-fc3abad42dbf', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Jacques II de Chypre (le Bâtard)', null, 1440, 1473, 'Roi de Chypre (1460-1473)', 'Lusignan', 1760, 5374, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7739cf1f-6dee-589e-a588-812258407f10', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Catherine Cornaro', null, 1454, 1510, 'Reine de Chypre (1474-1489)', 'Cornaro (Venise)', 1220, 5374, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9042f1f9-313e-57b0-b670-47b365a4c80e', 'entry', '9735b3f2-1004-5697-9366-38c2b38b5c8f', 'Jacques III de Chypre', null, 1473, 1474, 'Roi de Chypre (1473-1474), mort en bas âge', 'Lusignan', 1490, 5904, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('a2e6e3f1-e9a7-5942-a8ef-6e3f055f7106', '16f9184b-978e-5641-8c54-3d45328a323a', 'spouse');
  perform pg_temp.rel('a2e6e3f1-e9a7-5942-a8ef-6e3f055f7106', '0d2d847f-49b3-596c-a732-09a14fb59dd3', 'family');
  perform pg_temp.rel('0d2d847f-49b3-596c-a732-09a14fb59dd3', '34cd8af1-ee9d-5df8-9a9d-ba3dd0e318c3', 'spouse');
  perform pg_temp.rel('0d2d847f-49b3-596c-a732-09a14fb59dd3', '7cb125e8-8fa3-54d0-b72e-5f5407a54d7b', 'spouse');
  perform pg_temp.rel('0d2d847f-49b3-596c-a732-09a14fb59dd3', 'addc4169-dcb7-5819-965a-a4dfff1fb6a8', 'parent');
  perform pg_temp.rel('34cd8af1-ee9d-5df8-9a9d-ba3dd0e318c3', 'addc4169-dcb7-5819-965a-a4dfff1fb6a8', 'parent');
  perform pg_temp.rel('addc4169-dcb7-5819-965a-a4dfff1fb6a8', '39c7fc24-d70e-5504-9893-b4b7f99147ec', 'spouse');
  perform pg_temp.rel('addc4169-dcb7-5819-965a-a4dfff1fb6a8', '2cdbdd61-3498-5208-976c-f5df8e02f0f2', 'parent');
  perform pg_temp.rel('39c7fc24-d70e-5504-9893-b4b7f99147ec', '2cdbdd61-3498-5208-976c-f5df8e02f0f2', 'parent');
  perform pg_temp.rel('2cdbdd61-3498-5208-976c-f5df8e02f0f2', '6b313c8b-9950-56d9-90eb-334833fb8952', 'parent');
  perform pg_temp.rel('addc4169-dcb7-5819-965a-a4dfff1fb6a8', '18ed6f82-2ea7-585d-8a0e-25af21002302', 'parent');
  perform pg_temp.rel('39c7fc24-d70e-5504-9893-b4b7f99147ec', '18ed6f82-2ea7-585d-8a0e-25af21002302', 'parent');
  perform pg_temp.rel('16d612db-d9bc-5397-b845-174d741f8c16', '18ed6f82-2ea7-585d-8a0e-25af21002302', 'spouse');
  perform pg_temp.rel('16d612db-d9bc-5397-b845-174d741f8c16', '9f32edad-3cdf-5c76-a662-aed83d71979a', 'parent');
  perform pg_temp.rel('18ed6f82-2ea7-585d-8a0e-25af21002302', '9f32edad-3cdf-5c76-a662-aed83d71979a', 'parent');
  perform pg_temp.rel('9f32edad-3cdf-5c76-a662-aed83d71979a', '23b049c1-1255-5d9a-8dd3-cc4569c7ad4e', 'parent');
  perform pg_temp.rel('9f32edad-3cdf-5c76-a662-aed83d71979a', 'e3a792e5-d6d0-5099-8156-8062c3499d9a', 'parent');
  perform pg_temp.rel('9f32edad-3cdf-5c76-a662-aed83d71979a', 'a395d464-4133-5b30-9226-e0333a594a63', 'parent');
  perform pg_temp.rel('9f32edad-3cdf-5c76-a662-aed83d71979a', 'fb34f8b2-f51d-53c3-82b2-4d794fb6bbbe', 'parent');
  perform pg_temp.rel('fb34f8b2-f51d-53c3-82b2-4d794fb6bbbe', 'cd933915-3384-53f0-a8a6-73f5de288ede', 'parent');
  perform pg_temp.rel('cd933915-3384-53f0-a8a6-73f5de288ede', '85f0c63e-cd29-5359-a24e-b31860641073', 'spouse');
  perform pg_temp.rel('cd933915-3384-53f0-a8a6-73f5de288ede', 'f589ad56-833f-5499-a249-ad472b39376d', 'parent');
  perform pg_temp.rel('85f0c63e-cd29-5359-a24e-b31860641073', 'f589ad56-833f-5499-a249-ad472b39376d', 'parent');
  perform pg_temp.rel('cd933915-3384-53f0-a8a6-73f5de288ede', '4c86b19e-c8a1-59ba-8547-4d694d505684', 'parent');
  perform pg_temp.rel('85f0c63e-cd29-5359-a24e-b31860641073', '4c86b19e-c8a1-59ba-8547-4d694d505684', 'parent');
  perform pg_temp.rel('f589ad56-833f-5499-a249-ad472b39376d', 'c0ba29bc-e048-5c47-ba29-aabf56a779c4', 'spouse');
  perform pg_temp.rel('f589ad56-833f-5499-a249-ad472b39376d', '43998cc6-fb33-5c2e-b2fe-60440c1ac100', 'parent');
  perform pg_temp.rel('c0ba29bc-e048-5c47-ba29-aabf56a779c4', '43998cc6-fb33-5c2e-b2fe-60440c1ac100', 'parent');
  perform pg_temp.rel('4c86b19e-c8a1-59ba-8547-4d694d505684', 'ba201d68-9325-5355-be1c-7bf30efda128', 'spouse');
  perform pg_temp.rel('4c86b19e-c8a1-59ba-8547-4d694d505684', '6da50982-3c97-55d6-90aa-65a5ebcedf40', 'parent');
  perform pg_temp.rel('ba201d68-9325-5355-be1c-7bf30efda128', '6da50982-3c97-55d6-90aa-65a5ebcedf40', 'parent');
  perform pg_temp.rel('6da50982-3c97-55d6-90aa-65a5ebcedf40', '339d461e-3299-5999-9dc2-2bca5a09e2b8', 'spouse');
  perform pg_temp.rel('6da50982-3c97-55d6-90aa-65a5ebcedf40', '70663dcd-100e-59ae-865c-75d28ff40419', 'parent');
  perform pg_temp.rel('339d461e-3299-5999-9dc2-2bca5a09e2b8', '70663dcd-100e-59ae-865c-75d28ff40419', 'parent');
  perform pg_temp.rel('70663dcd-100e-59ae-865c-75d28ff40419', '6af063d5-89e6-5f99-b896-b67a1dc637da', 'spouse');
  perform pg_temp.rel('70663dcd-100e-59ae-865c-75d28ff40419', '86576f75-0d7c-53c0-a2b2-cc7aa13a4cb1', 'spouse');
  perform pg_temp.rel('70663dcd-100e-59ae-865c-75d28ff40419', '41738076-811d-534d-8d8a-08e959f22069', 'parent');
  perform pg_temp.rel('86576f75-0d7c-53c0-a2b2-cc7aa13a4cb1', '41738076-811d-534d-8d8a-08e959f22069', 'parent');
  perform pg_temp.rel('41738076-811d-534d-8d8a-08e959f22069', '5a3f6300-ae16-5aaf-8502-95dd1a88a4c6', 'spouse');
  perform pg_temp.rel('70663dcd-100e-59ae-865c-75d28ff40419', 'a7048bf4-a34f-59d6-811e-fc3abad42dbf', 'parent');
  perform pg_temp.rel('061af3a4-d951-5e87-95bb-053c8067f2fe', 'a7048bf4-a34f-59d6-811e-fc3abad42dbf', 'parent');
  perform pg_temp.rel('a7048bf4-a34f-59d6-811e-fc3abad42dbf', '7739cf1f-6dee-589e-a588-812258407f10', 'spouse');
  perform pg_temp.rel('a7048bf4-a34f-59d6-811e-fc3abad42dbf', '9042f1f9-313e-57b0-b670-47b365a4c80e', 'parent');
  perform pg_temp.rel('7739cf1f-6dee-589e-a588-812258407f10', '9042f1f9-313e-57b0-b670-47b365a4c80e', 'parent');
  raise notice 'schema_v51 : % membres ajoutés.', 34;
end $$;
