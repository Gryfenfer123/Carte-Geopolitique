-- arbres_v108.sql — Moghols (Inde), Chakri (Thaïlande), Nguyen (Vietnam), Durrani et Barakzaï (Afghanistan)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Quatre nouveaux arbres : « Empire moghol » (Inde), « Dynastie Chakri » (Thaïlande), « Dynastie des Nguyen » (Vietnam), « Durrani et Barakzaï » (Afghanistan). Aucun n'existait.
-- Dates : connues par ailleurs, aucune page consultée pour ce lot. Naissance vide quand inconnue ; approximations signalées. Sirikit (Thaïlande) : seule la naissance est saisie, la date de décès n'a pas été vérifiée.
-- Vietnam : Duc Duc et Dong Khanh sont des fils adoptifs de Tu Duc ; leur filiation biologique n'est pas saisie (signalé). Afghanistan : Dost Mohammad Khan (Barakzaï) n'est pas relié aux Durrani ; Nadir Shah est saisi sans parent.
-- Non fait : autres empereurs moghols, sultanat de Delhi, rois du Laos/Cambodge/Birmanie, cadets.
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
  if exists (select 1 from public.genealogy_members where id = '9a14b806-f11a-521b-a5f2-3e548aa9b4a3') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Empire moghol » (IND)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IND' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IND : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Empire moghol';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('35f8b368-e4fc-5576-9419-240108878a9b', cat_id, 'country', 'IND', top, 'Empire moghol', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '35f8b368-e4fc-5576-9419-240108878a9b';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'country', 'IND', 'genealogy', 'Empire moghol', cat_id, sec, admin_id);
  -- Arbre « Dynastie Chakri » (THA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'THA' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour THA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Dynastie Chakri';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('930887d9-ac59-5635-a30b-720b85566ee1', cat_id, 'country', 'THA', top, 'Dynastie Chakri', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '930887d9-ac59-5635-a30b-720b85566ee1';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'country', 'THA', 'genealogy', 'Dynastie Chakri', cat_id, sec, admin_id);
  -- Arbre « Dynastie des Nguyen » (VNM)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'VNM' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour VNM : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Dynastie des Nguyen';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('43d4709a-606a-58b6-8bc9-736a5c002ac7', cat_id, 'country', 'VNM', top, 'Dynastie des Nguyen', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '43d4709a-606a-58b6-8bc9-736a5c002ac7';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('dd4c14ab-4c8c-59a4-b859-d8d3727567ca', 'country', 'VNM', 'genealogy', 'Dynastie des Nguyen', cat_id, sec, admin_id);
  -- Arbre « Durrani et Barakzaï » (AFG)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'AFG' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour AFG : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Durrani et Barakzaï';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('77f55b60-e4e5-5b39-b260-25163367f81b', cat_id, 'country', 'AFG', top, 'Durrani et Barakzaï', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '77f55b60-e4e5-5b39-b260-25163367f81b';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'country', 'AFG', 'genealogy', 'Durrani et Barakzaï', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9a14b806-f11a-521b-a5f2-3e548aa9b4a3', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Babur', null, 1483, 1530, 'Fondateur de l''Empire moghol (1526-1530)', 'Empire moghol', 495, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a39cce9c-c74d-5f26-9d2e-06c7a9a0fc3b', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Humayun', null, 1508, 1556, 'Empereur moghol (1530-1556)', 'Empire moghol', 495, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c7b30f9a-73db-5523-91f6-0f334079dba0', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Akbar', null, 1542, 1605, 'Empereur moghol (1556-1605)', 'Empire moghol', 495, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6d23560b-3fd0-589a-b400-d823318c9c53', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Jahangir', null, 1569, 1627, 'Empereur moghol (1605-1627)', 'Empire moghol', 495, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3f376ef2-7fd5-5376-a285-dbe3c39e5b2b', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Nur Jahan', null, 1577, 1645, 'Impératrice, épouse de Jahangir', 'Empire moghol', 5, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('961c8ff8-f9a2-55a0-b8d7-77f21c80d297', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Shah Jahan', null, 1592, 1666, 'Empereur moghol (1628-1658), bâtisseur du Taj Mahal', 'Empire moghol', 495, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2d2dd727-3809-58d9-9fea-2c84ace65ddb', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Mumtaz Mahal', null, 1593, 1631, 'Impératrice, épouse de Shah Jahan', 'Empire moghol', 5, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e89b179b-bf11-5799-8442-101091616a99', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Dara Shikoh', null, 1615, 1659, 'Prince héritier, fils aîné de Shah Jahan', 'Empire moghol', 0, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5862ae4c-2a83-5cb4-9dfd-045e059168f6', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Aurangzeb', null, 1618, 1707, 'Empereur moghol (1658-1707)', 'Empire moghol', 500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2d2f859a-5799-5b6c-ba87-467578cea2c0', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Bahadur Shah Ier', null, 1643, 1712, 'Empereur moghol (1707-1712)', 'Empire moghol', 500, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('80b91dbd-04a9-5958-8083-cb8f8ef5d7dd', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Jahandar Shah', null, 1661, 1713, 'Empereur moghol (1712-1713)', 'Empire moghol', 500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('230d647c-04df-5d2c-ac33-1699f321f04e', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Alamgir II', null, 1699, 1759, 'Empereur moghol (1754-1759)', 'Empire moghol', 500, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8172ce85-074b-5cd5-841b-546d9c3dd7f3', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Shah Alam II', null, 1728, 1806, 'Empereur moghol (1760-1806)', 'Empire moghol', 500, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ec8d0db8-8d2f-54bd-8bf8-42087b146154', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Akbar II', null, 1760, 1837, 'Empereur moghol (1806-1837)', 'Empire moghol', 500, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ee26bbe3-5270-5be0-b6bc-1d4a81064a17', 'entry', 'f1bbec15-58a3-54c1-8a96-6f5d0810b9d2', 'Bahadur Shah II', null, 1775, 1862, 'Dernier empereur moghol (1837-1857)', 'Empire moghol', 500, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4ea6660d-ab1e-5e96-b4a6-f1d4069e7817', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Rama Ier', null, 1737, 1809, 'Roi du Siam (1782-1809), fondateur de la dynastie Chakri', 'Dynastie Chakri', 1235, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ade2efd9-d347-50a3-98c7-d5d5d4800ef4', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Rama II', null, 1767, 1824, 'Roi du Siam (1809-1824)', 'Dynastie Chakri', 1235, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2e4c12bc-fa3c-50a8-9b5c-7e96ae26cf05', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Rama III', null, 1788, 1851, 'Roi du Siam (1824-1851)', 'Dynastie Chakri', 985, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aab70e1a-2444-5386-9934-6ac044fe82e7', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Rama IV (Mongkut)', null, 1804, 1868, 'Roi du Siam (1851-1868)', 'Dynastie Chakri', 1485, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('055337e2-f04e-50fb-a9c7-c331008a4792', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Rama V (Chulalongkorn)', null, 1853, 1910, 'Roi du Siam (1868-1910)', 'Dynastie Chakri', 1485, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2786241f-db5b-5efc-a6cd-1666149ead62', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Rama VI (Vajiravudh)', null, 1881, 1925, 'Roi du Siam (1910-1925)', 'Dynastie Chakri', 1485, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('07cc93de-f742-5517-8859-1517fa8569b9', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Rama VII (Prajadhipok)', null, 1893, 1941, 'Roi du Siam (1925-1935)', 'Dynastie Chakri', 1985, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d93bc38f-f6a6-5a6b-9c1f-0cc228e4369a', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Mahidol Adulyadej', null, 1892, 1929, 'Prince de Songkhla, père de Rama VIII et Rama IX', 'Dynastie Chakri', 985, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6f5e05a5-6641-5b5b-90af-b129c46cd3e0', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Srinagarindra', null, 1900, 1995, 'Princesse mère, épouse de Mahidol', 'Dynastie Chakri', 495, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9c6b12bf-cd01-5678-97db-d0a72c13e555', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Rama VIII (Ananda Mahidol)', null, 1925, 1946, 'Roi de Thaïlande (1935-1946)', 'Dynastie Chakri', 990, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9ece220f-fdbe-5897-ac84-8d1851536ddd', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Rama IX (Bhumibol Adulyadej)', null, 1927, 2016, 'Roi de Thaïlande (1946-2016)', 'Dynastie Chakri', 490, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6bbe00db-92a2-585a-b221-13f3d99c32b8', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Sirikit', null, 1932, null, 'Reine de Thaïlande, épouse de Rama IX', 'Dynastie Chakri', 0, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d48dde00-da8b-5956-a3e4-b52fd1c37cd2', 'entry', '4bc592ad-eaaa-504a-a321-fd7c8dff7ac1', 'Rama X (Vajiralongkorn)', null, 1952, null, 'Roi de Thaïlande (depuis 2016)', 'Dynastie Chakri', 245, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4a2e4d6b-1cee-54ff-a7ee-1b5d00df70c0', 'entry', 'dd4c14ab-4c8c-59a4-b859-d8d3727567ca', 'Gia Long', null, 1762, 1820, 'Empereur du Viêt Nam (1802-1820), fondateur des Nguyen', 'Dynastie des Nguyen', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4bdaecc2-27f1-52ca-9c73-e29dedfdfb33', 'entry', 'dd4c14ab-4c8c-59a4-b859-d8d3727567ca', 'Minh Mang', null, 1791, 1841, 'Empereur du Viêt Nam (1820-1841)', 'Dynastie des Nguyen', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2602e809-76dd-565a-8f95-bbd1db9f5875', 'entry', 'dd4c14ab-4c8c-59a4-b859-d8d3727567ca', 'Thieu Tri', null, 1807, 1847, 'Empereur du Viêt Nam (1841-1847)', 'Dynastie des Nguyen', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ea6c09ca-8eef-5916-ac0a-c7fe149c0b18', 'entry', 'dd4c14ab-4c8c-59a4-b859-d8d3727567ca', 'Tu Duc', null, 1829, 1883, 'Empereur du Viêt Nam (1847-1883)', 'Dynastie des Nguyen', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0e458220-fa1e-5eac-b254-8f7f6703777a', 'entry', 'dd4c14ab-4c8c-59a4-b859-d8d3727567ca', 'Duc Duc', null, 1852, 1883, 'Empereur du Viêt Nam (1883, trois jours)', 'Dynastie des Nguyen', 1000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8071137b-4443-50c2-ad0e-730c9ec3d640', 'entry', 'dd4c14ab-4c8c-59a4-b859-d8d3727567ca', 'Dong Khanh', null, 1864, 1889, 'Empereur du Viêt Nam (1885-1889)', 'Dynastie des Nguyen', 2000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('79cffa3c-fa80-5861-9cb0-27d0c1aa81ff', 'entry', 'dd4c14ab-4c8c-59a4-b859-d8d3727567ca', 'Thanh Thai', null, 1879, 1954, 'Empereur du Viêt Nam (1889-1907), déposé', 'Dynastie des Nguyen', 1000, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0a17ee8e-1376-51ba-9d7e-63c95a816048', 'entry', 'dd4c14ab-4c8c-59a4-b859-d8d3727567ca', 'Duy Tan', null, 1900, 1945, 'Empereur du Viêt Nam (1907-1916), déposé', 'Dynastie des Nguyen', 1000, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c3a5a62d-8c61-5f87-b707-7dee72ac8503', 'entry', 'dd4c14ab-4c8c-59a4-b859-d8d3727567ca', 'Khai Dinh', null, 1885, 1925, 'Empereur du Viêt Nam (1916-1925)', 'Dynastie des Nguyen', 2000, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a32a312f-45cf-5a0b-85da-c6bf14a26dda', 'entry', 'dd4c14ab-4c8c-59a4-b859-d8d3727567ca', 'Bao Dai', null, 1913, 1997, 'Dernier empereur du Viêt Nam (1926-1945)', 'Dynastie des Nguyen', 2000, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('193f77c3-1a66-55fb-bff5-3991a24edeba', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Ahmad Shah Durrani', null, 1722, 1772, 'Fondateur de l''Empire durrani (1747-1772)', 'Durrani et Barakzaï', 1750, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0870a034-9ab9-5ca8-8186-99be64dc1a85', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Timur Shah Durrani', null, 1748, 1793, 'Émir de l''Empire durrani (1772-1793)', 'Durrani et Barakzaï', 1750, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('812d20d7-564f-5510-a4df-4054163199b4', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Zaman Shah Durrani', null, 1770, 1844, 'Émir de l''Empire durrani (1793-1801)', 'Durrani et Barakzaï', 1500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('23077383-b76e-506f-85bf-9fd1d9ba94a3', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Shah Shuja Durrani', null, 1785, 1842, 'Émir de l''Empire durrani (1803-1809, 1839-1842)', 'Durrani et Barakzaï', 2000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('27512845-e58b-58bf-a22b-96aa858da4be', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Dost Mohammad Khan', null, 1793, 1863, 'Émir d''Afghanistan (1826-1863), fondateur des Barakzaï', 'Durrani et Barakzaï', 250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('abe219c2-8be4-50a0-a1b6-5e0ea89f49b7', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Mohammad Afzal Khan', null, null, 1867, 'Émir d''Afghanistan (1866-1867), fils de Dost Mohammad', 'Durrani et Barakzaï', 500, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a0d44d01-1f6a-5cfd-bbcf-09f09fe234a3', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Sher Ali Khan', null, 1825, 1879, 'Émir d''Afghanistan (1863-1879)', 'Durrani et Barakzaï', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('33eaa7fd-cc39-500a-ac29-14a697276673', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Abdur Rahman Khan', null, 1844, 1901, 'Émir d''Afghanistan (1880-1901)', 'Durrani et Barakzaï', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('88ce1e7e-cc0e-520c-a3b1-7729cb301e27', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Habibullah Khan', null, 1872, 1919, 'Émir d''Afghanistan (1901-1919)', 'Durrani et Barakzaï', 500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ff75b1de-86d3-5636-bbc7-48d4fbf9de99', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Amanullah Khan', null, 1892, 1960, 'Émir puis roi d''Afghanistan (1919-1929)', 'Durrani et Barakzaï', 500, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0b7d480f-195d-5f36-8ca9-4b0557ca2d80', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Nadir Shah', null, 1883, 1933, 'Roi d''Afghanistan (1929-1933)', 'Durrani et Barakzaï', 3000, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('27a865a9-17a0-5e52-9f5b-3c3b676e60c3', 'entry', '8fd6f053-70a5-583b-9d09-d0f5e0c8e9ce', 'Mohammad Zaher Shah', null, 1914, 2007, 'Roi d''Afghanistan (1933-1973)', 'Durrani et Barakzaï', 3000, 3840, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('9a14b806-f11a-521b-a5f2-3e548aa9b4a3', 'a39cce9c-c74d-5f26-9d2e-06c7a9a0fc3b', 'parent');
  perform pg_temp.rel('a39cce9c-c74d-5f26-9d2e-06c7a9a0fc3b', 'c7b30f9a-73db-5523-91f6-0f334079dba0', 'parent');
  perform pg_temp.rel('c7b30f9a-73db-5523-91f6-0f334079dba0', '6d23560b-3fd0-589a-b400-d823318c9c53', 'parent');
  perform pg_temp.rel('6d23560b-3fd0-589a-b400-d823318c9c53', '961c8ff8-f9a2-55a0-b8d7-77f21c80d297', 'parent');
  perform pg_temp.rel('961c8ff8-f9a2-55a0-b8d7-77f21c80d297', 'e89b179b-bf11-5799-8442-101091616a99', 'parent');
  perform pg_temp.rel('961c8ff8-f9a2-55a0-b8d7-77f21c80d297', '5862ae4c-2a83-5cb4-9dfd-045e059168f6', 'parent');
  perform pg_temp.rel('2d2dd727-3809-58d9-9fea-2c84ace65ddb', 'e89b179b-bf11-5799-8442-101091616a99', 'parent');
  perform pg_temp.rel('2d2dd727-3809-58d9-9fea-2c84ace65ddb', '5862ae4c-2a83-5cb4-9dfd-045e059168f6', 'parent');
  perform pg_temp.rel('5862ae4c-2a83-5cb4-9dfd-045e059168f6', '2d2f859a-5799-5b6c-ba87-467578cea2c0', 'parent');
  perform pg_temp.rel('2d2f859a-5799-5b6c-ba87-467578cea2c0', '80b91dbd-04a9-5958-8083-cb8f8ef5d7dd', 'parent');
  perform pg_temp.rel('80b91dbd-04a9-5958-8083-cb8f8ef5d7dd', '230d647c-04df-5d2c-ac33-1699f321f04e', 'parent');
  perform pg_temp.rel('230d647c-04df-5d2c-ac33-1699f321f04e', '8172ce85-074b-5cd5-841b-546d9c3dd7f3', 'parent');
  perform pg_temp.rel('8172ce85-074b-5cd5-841b-546d9c3dd7f3', 'ec8d0db8-8d2f-54bd-8bf8-42087b146154', 'parent');
  perform pg_temp.rel('ec8d0db8-8d2f-54bd-8bf8-42087b146154', 'ee26bbe3-5270-5be0-b6bc-1d4a81064a17', 'parent');
  perform pg_temp.rel('6d23560b-3fd0-589a-b400-d823318c9c53', '3f376ef2-7fd5-5376-a285-dbe3c39e5b2b', 'spouse');
  perform pg_temp.rel('961c8ff8-f9a2-55a0-b8d7-77f21c80d297', '2d2dd727-3809-58d9-9fea-2c84ace65ddb', 'spouse');
  perform pg_temp.rel('4ea6660d-ab1e-5e96-b4a6-f1d4069e7817', 'ade2efd9-d347-50a3-98c7-d5d5d4800ef4', 'parent');
  perform pg_temp.rel('ade2efd9-d347-50a3-98c7-d5d5d4800ef4', '2e4c12bc-fa3c-50a8-9b5c-7e96ae26cf05', 'parent');
  perform pg_temp.rel('ade2efd9-d347-50a3-98c7-d5d5d4800ef4', 'aab70e1a-2444-5386-9934-6ac044fe82e7', 'parent');
  perform pg_temp.rel('aab70e1a-2444-5386-9934-6ac044fe82e7', '055337e2-f04e-50fb-a9c7-c331008a4792', 'parent');
  perform pg_temp.rel('055337e2-f04e-50fb-a9c7-c331008a4792', '2786241f-db5b-5efc-a6cd-1666149ead62', 'parent');
  perform pg_temp.rel('055337e2-f04e-50fb-a9c7-c331008a4792', '07cc93de-f742-5517-8859-1517fa8569b9', 'parent');
  perform pg_temp.rel('055337e2-f04e-50fb-a9c7-c331008a4792', 'd93bc38f-f6a6-5a6b-9c1f-0cc228e4369a', 'parent');
  perform pg_temp.rel('d93bc38f-f6a6-5a6b-9c1f-0cc228e4369a', '9c6b12bf-cd01-5678-97db-d0a72c13e555', 'parent');
  perform pg_temp.rel('d93bc38f-f6a6-5a6b-9c1f-0cc228e4369a', '9ece220f-fdbe-5897-ac84-8d1851536ddd', 'parent');
  perform pg_temp.rel('6f5e05a5-6641-5b5b-90af-b129c46cd3e0', '9c6b12bf-cd01-5678-97db-d0a72c13e555', 'parent');
  perform pg_temp.rel('6f5e05a5-6641-5b5b-90af-b129c46cd3e0', '9ece220f-fdbe-5897-ac84-8d1851536ddd', 'parent');
  perform pg_temp.rel('9ece220f-fdbe-5897-ac84-8d1851536ddd', 'd48dde00-da8b-5956-a3e4-b52fd1c37cd2', 'parent');
  perform pg_temp.rel('6bbe00db-92a2-585a-b221-13f3d99c32b8', 'd48dde00-da8b-5956-a3e4-b52fd1c37cd2', 'parent');
  perform pg_temp.rel('d93bc38f-f6a6-5a6b-9c1f-0cc228e4369a', '6f5e05a5-6641-5b5b-90af-b129c46cd3e0', 'spouse');
  perform pg_temp.rel('9ece220f-fdbe-5897-ac84-8d1851536ddd', '6bbe00db-92a2-585a-b221-13f3d99c32b8', 'spouse');
  perform pg_temp.rel('4a2e4d6b-1cee-54ff-a7ee-1b5d00df70c0', '4bdaecc2-27f1-52ca-9c73-e29dedfdfb33', 'parent');
  perform pg_temp.rel('4bdaecc2-27f1-52ca-9c73-e29dedfdfb33', '2602e809-76dd-565a-8f95-bbd1db9f5875', 'parent');
  perform pg_temp.rel('2602e809-76dd-565a-8f95-bbd1db9f5875', 'ea6c09ca-8eef-5916-ac0a-c7fe149c0b18', 'parent');
  perform pg_temp.rel('0e458220-fa1e-5eac-b254-8f7f6703777a', '79cffa3c-fa80-5861-9cb0-27d0c1aa81ff', 'parent');
  perform pg_temp.rel('79cffa3c-fa80-5861-9cb0-27d0c1aa81ff', '0a17ee8e-1376-51ba-9d7e-63c95a816048', 'parent');
  perform pg_temp.rel('8071137b-4443-50c2-ad0e-730c9ec3d640', 'c3a5a62d-8c61-5f87-b707-7dee72ac8503', 'parent');
  perform pg_temp.rel('c3a5a62d-8c61-5f87-b707-7dee72ac8503', 'a32a312f-45cf-5a0b-85da-c6bf14a26dda', 'parent');
  perform pg_temp.rel('193f77c3-1a66-55fb-bff5-3991a24edeba', '0870a034-9ab9-5ca8-8186-99be64dc1a85', 'parent');
  perform pg_temp.rel('0870a034-9ab9-5ca8-8186-99be64dc1a85', '812d20d7-564f-5510-a4df-4054163199b4', 'parent');
  perform pg_temp.rel('0870a034-9ab9-5ca8-8186-99be64dc1a85', '23077383-b76e-506f-85bf-9fd1d9ba94a3', 'parent');
  perform pg_temp.rel('27512845-e58b-58bf-a22b-96aa858da4be', 'abe219c2-8be4-50a0-a1b6-5e0ea89f49b7', 'parent');
  perform pg_temp.rel('27512845-e58b-58bf-a22b-96aa858da4be', 'a0d44d01-1f6a-5cfd-bbcf-09f09fe234a3', 'parent');
  perform pg_temp.rel('abe219c2-8be4-50a0-a1b6-5e0ea89f49b7', '33eaa7fd-cc39-500a-ac29-14a697276673', 'parent');
  perform pg_temp.rel('33eaa7fd-cc39-500a-ac29-14a697276673', '88ce1e7e-cc0e-520c-a3b1-7729cb301e27', 'parent');
  perform pg_temp.rel('88ce1e7e-cc0e-520c-a3b1-7729cb301e27', 'ff75b1de-86d3-5636-bbc7-48d4fbf9de99', 'parent');
  perform pg_temp.rel('0b7d480f-195d-5f36-8ca9-4b0557ca2d80', '27a865a9-17a0-5e52-9f5b-3c3b676e60c3', 'parent');
  raise notice 'schema_v108 : % membres ajoutés.', 50;
end $$;
