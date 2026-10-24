-- arbres_v107.sql — Maroc (Alaouites), Libye (Senoussi), Éthiopie (dynastie salomonide)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Trois nouveaux arbres : « Alaouites » (Maroc), « Senoussi » (Libye), « Dynastie salomonide » (Éthiopie). Aucun n'existait.
-- Dates : connues par ailleurs, aucune page consultée pour ce lot. Naissance laissée vide quand inconnue ; approximations signalées.
-- Alaouites : le chaînon Hicham (père d'Abderrahmane, fils de Mohammed III) n'est pas saisi ; Abderrahmane est donc sans parent dans l'arbre. Ali Chérif relié à Rachid et Ismaïl.
-- Éthiopie : Ras Makonnen (père de Haile Selassie) est saisi sans lien vers Menelik II (cousin, lien non saisi).
-- Non fait : Tunisie (beys husseinites), Algérie, autres sultans alaouites, nombreux cadets.
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
  if exists (select 1 from public.genealogy_members where id = 'a9281f7a-61b9-5a02-b75e-53b158a498c3') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Alaouites » (MAR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'MAR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour MAR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Alaouites';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('98395565-2068-5e20-a60e-cfc95a2e03c8', cat_id, 'country', 'MAR', top, 'Alaouites', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '98395565-2068-5e20-a60e-cfc95a2e03c8';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('61c54147-4a6a-5ff4-981f-54da52cd4700', 'country', 'MAR', 'genealogy', 'Alaouites', cat_id, sec, admin_id);
  -- Arbre « Senoussi » (LBY)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'LBY' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour LBY : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Senoussi';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('3e07c33d-ed8c-5ebc-8510-62663a4e938c', cat_id, 'country', 'LBY', top, 'Senoussi', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '3e07c33d-ed8c-5ebc-8510-62663a4e938c';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('625e4726-c237-59eb-81d1-3c4461053e32', 'country', 'LBY', 'genealogy', 'Senoussi', cat_id, sec, admin_id);
  -- Arbre « Dynastie salomonide » (ETH)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ETH' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ETH : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Dynastie salomonide';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('11f4a7e9-5be7-5147-941c-61a4e2c41db8', cat_id, 'country', 'ETH', top, 'Dynastie salomonide', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '11f4a7e9-5be7-5147-941c-61a4e2c41db8';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('1e0f1f91-8753-5976-ac45-2cb1c376028a', 'country', 'ETH', 'genealogy', 'Dynastie salomonide', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a9281f7a-61b9-5a02-b75e-53b158a498c3', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Moulay Ali Chérif', null, null, 1659, 'Ancêtre des Alaouites, prince du Tafilalet', 'Alaouites', 2250, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b8fc96cd-dcc4-5e58-872c-b4fd53db8c75', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Moulay Rachid', null, 1631, 1672, 'Sultan du Maroc (1666-1672), fondateur de la dynastie alaouite', 'Alaouites', 2000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e39385b1-b3e0-5641-a6dc-d6513271b0fa', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Moulay Ismaïl', null, 1645, 1727, 'Sultan du Maroc (1672-1727)', 'Alaouites', 2500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b23cf403-8c9c-5755-91bd-44fabcf7ba30', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Moulay Abdallah', null, 1694, 1757, 'Sultan du Maroc (plusieurs règnes)', 'Alaouites', 2500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7ffc5af2-33e0-54d8-9b27-071327b5e787', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Mohammed III ben Abdallah', null, 1710, 1790, 'Sultan du Maroc (1757-1790)', 'Alaouites', 2500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('99db75ed-f475-5a2e-91da-49c81ee0b82a', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Moulay Yazid', null, 1750, 1792, 'Sultan du Maroc (1790-1792)', 'Alaouites', 2250, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6dccf8a4-7a2a-59f8-b084-1183d27cfbd4', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Moulay Slimane', null, 1766, 1822, 'Sultan du Maroc (1792-1822)', 'Alaouites', 2750, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('838e7650-48f4-5407-be04-d56c96507a39', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Abd al-Rahman du Maroc', null, 1778, 1859, 'Sultan du Maroc (1822-1859)', 'Alaouites', 500, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('176fa183-1424-517a-82a9-8d912095cf62', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Mohammed IV du Maroc', null, 1803, 1873, 'Sultan du Maroc (1859-1873)', 'Alaouites', 500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('44d8e6d3-d2ad-5909-8ff4-ed516de49b7c', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Hassan Ier du Maroc', null, 1836, 1894, 'Sultan du Maroc (1873-1894)', 'Alaouites', 500, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bd805555-b321-5eb5-b475-026eed052562', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Abd al-Aziz du Maroc', null, 1878, 1943, 'Sultan du Maroc (1894-1908)', 'Alaouites', 0, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0cd8bb5a-695d-515a-a4fe-f188775fa276', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Abd al-Hafid du Maroc', null, 1875, 1937, 'Sultan du Maroc (1908-1912)', 'Alaouites', 1000, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1768c948-0b64-5471-9506-3dfaa0764366', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Moulay Youssef', null, 1882, 1927, 'Sultan du Maroc (1912-1927)', 'Alaouites', 500, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f6172e39-292d-584c-9504-25a627416f6e', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Mohammed V du Maroc', null, 1909, 1961, 'Sultan puis roi du Maroc (1927-1961)', 'Alaouites', 500, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f14344a9-d74b-5d74-a845-b5eded39af36', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Hassan II du Maroc', null, 1929, 1999, 'Roi du Maroc (1961-1999)', 'Alaouites', 500, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b161abd7-cc06-5c8a-8fe1-e659cf904c4a', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Mohammed VI du Maroc', null, 1963, null, 'Roi du Maroc (depuis 1999)', 'Alaouites', 500, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('20fcdb6d-73c3-5345-bf56-157501e90461', 'entry', '61c54147-4a6a-5ff4-981f-54da52cd4700', 'Moulay Hassan (prince héritier)', null, 2003, null, 'Prince héritier du Maroc', 'Alaouites', 500, 8320, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('13fb03af-e8a9-5c92-89ec-d3e2b6644cb4', 'entry', '625e4726-c237-59eb-81d1-3c4461053e32', 'Mohammed ibn Ali as-Senoussi', null, 1787, 1859, 'Fondateur de la confrérie senoussie', 'Senoussi', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('58359db6-75d2-5883-ac6d-6a4f2bd602a5', 'entry', '625e4726-c237-59eb-81d1-3c4461053e32', 'Mohammed al-Mahdi as-Senoussi', null, 1844, 1902, 'Chef de la confrérie senoussie', 'Senoussi', 0, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('039f860f-4e27-53f5-aeeb-cd7d1953225f', 'entry', '625e4726-c237-59eb-81d1-3c4461053e32', 'Idris Ier de Libye', null, 1889, 1983, 'Roi de Libye (1951-1969)', 'Senoussi', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('521fe6ae-5845-5c99-89b1-2d8740ec6aee', 'entry', '1e0f1f91-8753-5976-ac45-2cb1c376028a', 'Sahle Selassie', null, 1795, 1847, 'Négus du Choa (1813-1847)', 'Dynastie salomonide', 1490, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3bd31d40-9f44-51b5-b28f-ddffee2e33e3', 'entry', '1e0f1f91-8753-5976-ac45-2cb1c376028a', 'Haile Melekot', null, 1824, 1855, 'Roi du Choa (1847-1855)', 'Dynastie salomonide', 1490, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0321b92e-b9d0-5929-9278-d70a18f8079d', 'entry', '1e0f1f91-8753-5976-ac45-2cb1c376028a', 'Menelik II', null, 1844, 1913, 'Empereur d''Éthiopie (1889-1913)', 'Dynastie salomonide', 1490, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ac3a2097-fcc4-564a-ad71-2fd19e69ad72', 'entry', '1e0f1f91-8753-5976-ac45-2cb1c376028a', 'Zewditu Ire', null, 1876, 1930, 'Impératrice d''Éthiopie (1916-1930)', 'Dynastie salomonide', 1490, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('414a8326-9585-5dd7-a241-29a3e13d4d9a', 'entry', '1e0f1f91-8753-5976-ac45-2cb1c376028a', 'Ras Makonnen', null, 1852, 1906, 'Gouverneur du Harar, père de Haile Selassie', 'Dynastie salomonide', 0, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('71a54198-bb5e-5c3e-8c95-26f3a5c9fd6d', 'entry', '1e0f1f91-8753-5976-ac45-2cb1c376028a', 'Haile Selassie Ier', null, 1892, 1975, 'Empereur d''Éthiopie (1930-1974)', 'Dynastie salomonide', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6da7b938-bd24-5dd5-8310-bec29e006a13', 'entry', '1e0f1f91-8753-5976-ac45-2cb1c376028a', 'Menen Asfaw', null, 1889, 1962, 'Impératrice d''Éthiopie, épouse de Haile Selassie', 'Dynastie salomonide', 490, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a339a78e-8ef9-5b19-a687-f6373cf0b932', 'entry', '1e0f1f91-8753-5976-ac45-2cb1c376028a', 'Amha Selassie Ier', null, 1916, 1997, 'Dernier empereur d''Éthiopie (1974, en exil)', 'Dynastie salomonide', 245, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7684d791-0fb8-526e-9314-5371e6ceafff', 'entry', '1e0f1f91-8753-5976-ac45-2cb1c376028a', 'Zera Yacob Amha Selassie', null, 1953, null, 'Prétendant au trône d''Éthiopie', 'Dynastie salomonide', 245, 3200, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('a9281f7a-61b9-5a02-b75e-53b158a498c3', 'b8fc96cd-dcc4-5e58-872c-b4fd53db8c75', 'parent');
  perform pg_temp.rel('a9281f7a-61b9-5a02-b75e-53b158a498c3', 'e39385b1-b3e0-5641-a6dc-d6513271b0fa', 'parent');
  perform pg_temp.rel('e39385b1-b3e0-5641-a6dc-d6513271b0fa', 'b23cf403-8c9c-5755-91bd-44fabcf7ba30', 'parent');
  perform pg_temp.rel('b23cf403-8c9c-5755-91bd-44fabcf7ba30', '7ffc5af2-33e0-54d8-9b27-071327b5e787', 'parent');
  perform pg_temp.rel('7ffc5af2-33e0-54d8-9b27-071327b5e787', '99db75ed-f475-5a2e-91da-49c81ee0b82a', 'parent');
  perform pg_temp.rel('7ffc5af2-33e0-54d8-9b27-071327b5e787', '6dccf8a4-7a2a-59f8-b084-1183d27cfbd4', 'parent');
  perform pg_temp.rel('838e7650-48f4-5407-be04-d56c96507a39', '176fa183-1424-517a-82a9-8d912095cf62', 'parent');
  perform pg_temp.rel('176fa183-1424-517a-82a9-8d912095cf62', '44d8e6d3-d2ad-5909-8ff4-ed516de49b7c', 'parent');
  perform pg_temp.rel('44d8e6d3-d2ad-5909-8ff4-ed516de49b7c', 'bd805555-b321-5eb5-b475-026eed052562', 'parent');
  perform pg_temp.rel('44d8e6d3-d2ad-5909-8ff4-ed516de49b7c', '0cd8bb5a-695d-515a-a4fe-f188775fa276', 'parent');
  perform pg_temp.rel('44d8e6d3-d2ad-5909-8ff4-ed516de49b7c', '1768c948-0b64-5471-9506-3dfaa0764366', 'parent');
  perform pg_temp.rel('1768c948-0b64-5471-9506-3dfaa0764366', 'f6172e39-292d-584c-9504-25a627416f6e', 'parent');
  perform pg_temp.rel('f6172e39-292d-584c-9504-25a627416f6e', 'f14344a9-d74b-5d74-a845-b5eded39af36', 'parent');
  perform pg_temp.rel('f14344a9-d74b-5d74-a845-b5eded39af36', 'b161abd7-cc06-5c8a-8fe1-e659cf904c4a', 'parent');
  perform pg_temp.rel('b161abd7-cc06-5c8a-8fe1-e659cf904c4a', '20fcdb6d-73c3-5345-bf56-157501e90461', 'parent');
  perform pg_temp.rel('13fb03af-e8a9-5c92-89ec-d3e2b6644cb4', '58359db6-75d2-5883-ac6d-6a4f2bd602a5', 'parent');
  perform pg_temp.rel('58359db6-75d2-5883-ac6d-6a4f2bd602a5', '039f860f-4e27-53f5-aeeb-cd7d1953225f', 'parent');
  perform pg_temp.rel('521fe6ae-5845-5c99-89b1-2d8740ec6aee', '3bd31d40-9f44-51b5-b28f-ddffee2e33e3', 'parent');
  perform pg_temp.rel('3bd31d40-9f44-51b5-b28f-ddffee2e33e3', '0321b92e-b9d0-5929-9278-d70a18f8079d', 'parent');
  perform pg_temp.rel('0321b92e-b9d0-5929-9278-d70a18f8079d', 'ac3a2097-fcc4-564a-ad71-2fd19e69ad72', 'parent');
  perform pg_temp.rel('414a8326-9585-5dd7-a241-29a3e13d4d9a', '71a54198-bb5e-5c3e-8c95-26f3a5c9fd6d', 'parent');
  perform pg_temp.rel('71a54198-bb5e-5c3e-8c95-26f3a5c9fd6d', 'a339a78e-8ef9-5b19-a687-f6373cf0b932', 'parent');
  perform pg_temp.rel('6da7b938-bd24-5dd5-8310-bec29e006a13', 'a339a78e-8ef9-5b19-a687-f6373cf0b932', 'parent');
  perform pg_temp.rel('a339a78e-8ef9-5b19-a687-f6373cf0b932', '7684d791-0fb8-526e-9314-5371e6ceafff', 'parent');
  perform pg_temp.rel('71a54198-bb5e-5c3e-8c95-26f3a5c9fd6d', '6da7b938-bd24-5dd5-8310-bec29e006a13', 'spouse');
  raise notice 'schema_v107 : % membres ajoutés.', 29;
end $$;
