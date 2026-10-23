-- arbres_v88.sql — Japon — shoguns : Minamoto, Ashikaga, Oda/Toyotomi et Tokugawa
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Quatre nouveaux arbres : « Minamoto (Kamakura) », « Ashikaga », « Oda et Toyotomi », « Tokugawa » (aucun n'existait). Rien n'est supprimé.
-- Dates : connues par ailleurs (histoire du Japon), aucune page consultée pour ce lot. Les adoptions et héritiers de branches collatérales (Tokugawa de Kii, de Mito, Hitotsubashi…) sont reliés par un lien « famille », pas par une filiation.
-- Hōjō Masako (épouse de Yoritomo) vient d'une famille sans arbre : signalée.
-- Non fait : régents Hōjō, Ashikaga après Yoshimasa (hors Yoshiharu, Yoshiteru, Yoshiaki), enfants et épouses des Tokugawa, Oda après Nobunaga.
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
  if exists (select 1 from public.genealogy_members where id = '244f1de9-791a-5857-915e-27ed5cb8e5ff') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Minamoto (Kamakura) » (JPN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'JPN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour JPN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Minamoto (Kamakura)';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('53b38093-e9f6-50d4-be4a-d303721df91f', cat_id, 'country', 'JPN', top, 'Minamoto (Kamakura)', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '53b38093-e9f6-50d4-be4a-d303721df91f';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('941a3d47-fce8-5a8f-9277-5fcc931e30d7', 'country', 'JPN', 'genealogy', 'Minamoto (Kamakura)', cat_id, sec, admin_id);
  -- Arbre « Ashikaga » (JPN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'JPN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour JPN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Ashikaga';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('543e3665-d600-5455-bc57-ae383b90a551', cat_id, 'country', 'JPN', top, 'Ashikaga', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '543e3665-d600-5455-bc57-ae383b90a551';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('3d5d8648-4323-51e7-957b-44c41d121cdb', 'country', 'JPN', 'genealogy', 'Ashikaga', cat_id, sec, admin_id);
  -- Arbre « Oda et Toyotomi » (JPN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'JPN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour JPN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Oda et Toyotomi';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('b6db2f12-68b8-5fa0-861b-ec0a1b895c98', cat_id, 'country', 'JPN', top, 'Oda et Toyotomi', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'b6db2f12-68b8-5fa0-861b-ec0a1b895c98';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('5f252697-3a0b-58e1-aab8-d83b4cf825af', 'country', 'JPN', 'genealogy', 'Oda et Toyotomi', cat_id, sec, admin_id);
  -- Arbre « Tokugawa » (JPN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'JPN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour JPN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Tokugawa';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('27df9baf-96cb-5a14-9dac-c847507e5118', cat_id, 'country', 'JPN', top, 'Tokugawa', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '27df9baf-96cb-5a14-9dac-c847507e5118';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('e6751e92-8d39-59d3-81db-8eaeb534620c', 'country', 'JPN', 'genealogy', 'Tokugawa', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('244f1de9-791a-5857-915e-27ed5cb8e5ff', 'entry', '941a3d47-fce8-5a8f-9277-5fcc931e30d7', 'Minamoto no Yoritomo', null, 1147, 1199, 'Premier shogun (shogunat de Kamakura)', 'Minamoto', 495, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8535bcb4-b3f0-51ff-b42a-5eb7d5bbc5ab', 'entry', '941a3d47-fce8-5a8f-9277-5fcc931e30d7', 'Minamoto no Yoriie', null, 1182, 1204, 'Deuxième shogun', 'Minamoto', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dcde26ce-b87f-5cbf-a4aa-7ced4eb83ba2', 'entry', '941a3d47-fce8-5a8f-9277-5fcc931e30d7', 'Minamoto no Sanetomo', null, 1192, 1219, 'Troisième shogun, dernier Minamoto', 'Minamoto', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('48b2a0ec-a4b1-5813-95ac-9f2146ae152f', 'entry', '941a3d47-fce8-5a8f-9277-5fcc931e30d7', 'Hōjō Masako', null, 1157, 1225, 'Épouse de Yoritomo, « nonne shogun »', 'Hōjō', 5, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c3d667b7-672c-5caa-bcf5-ef81010248e1', 'entry', '3d5d8648-4323-51e7-957b-44c41d121cdb', 'Ashikaga Takauji', null, 1305, 1358, 'Premier shogun Ashikaga', 'Ashikaga', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2d414260-1b2e-5d3a-bad2-12c6a9b88a43', 'entry', '3d5d8648-4323-51e7-957b-44c41d121cdb', 'Ashikaga Yoshiakira', null, 1330, 1367, 'Deuxième shogun', 'Ashikaga', 250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('289cc1a9-13d6-5ff5-8f33-d87c61257ef3', 'entry', '3d5d8648-4323-51e7-957b-44c41d121cdb', 'Ashikaga Yoshimitsu', null, 1358, 1408, 'Troisième shogun', 'Ashikaga', 250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('09b7116e-547d-50da-89d0-4b9a7af8c157', 'entry', '3d5d8648-4323-51e7-957b-44c41d121cdb', 'Ashikaga Yoshimochi', null, 1386, 1428, 'Quatrième shogun', 'Ashikaga', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('86866ec1-2e39-5326-a734-ef7597cdf85e', 'entry', '3d5d8648-4323-51e7-957b-44c41d121cdb', 'Ashikaga Yoshinori', null, 1394, 1441, 'Sixième shogun', 'Ashikaga', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5041d7fd-f83c-5f2e-b67b-74397e462b55', 'entry', '3d5d8648-4323-51e7-957b-44c41d121cdb', 'Ashikaga Yoshimasa', null, 1436, 1490, 'Huitième shogun (guerre d''Ōnin)', 'Ashikaga', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9dfbcd48-954d-5f81-ae2e-3606f0727396', 'entry', '3d5d8648-4323-51e7-957b-44c41d121cdb', 'Ashikaga Yoshiharu', null, 1511, 1550, 'Douzième shogun', 'Ashikaga', 1750, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('39b48183-2168-53db-bdbe-1219c7733915', 'entry', '3d5d8648-4323-51e7-957b-44c41d121cdb', 'Ashikaga Yoshiteru', null, 1536, 1565, 'Treizième shogun', 'Ashikaga', 1500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d54bf37a-0a54-551e-8e32-9a5134b50e83', 'entry', '3d5d8648-4323-51e7-957b-44c41d121cdb', 'Ashikaga Yoshiaki', null, 1537, 1597, 'Quinzième et dernier shogun Ashikaga', 'Ashikaga', 2000, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4d0898d1-8d9f-585f-bbaa-88d6fb63d67f', 'entry', '5f252697-3a0b-58e1-aab8-d83b4cf825af', 'Oda Nobunaga', null, 1534, 1582, 'Seigneur de la guerre, unificateur du Japon', 'Oda et Toyotomi', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5b8a9dd4-d22e-548e-9d8d-4bd73d53014f', 'entry', '5f252697-3a0b-58e1-aab8-d83b4cf825af', 'Toyotomi Hideyoshi', null, 1537, 1598, 'Régent (kanpaku), unificateur du Japon', 'Oda et Toyotomi', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('322f5d64-f324-5ba4-8b78-840f5739e201', 'entry', '5f252697-3a0b-58e1-aab8-d83b4cf825af', 'Toyotomi Hideyori', null, 1593, 1615, 'Fils de Hideyoshi, vaincu à Osaka', 'Oda et Toyotomi', 1000, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8eb035db-7afe-5d10-a84d-0db50edfde24', 'entry', '5f252697-3a0b-58e1-aab8-d83b4cf825af', 'Oda Nobuhide', null, 1510, 1551, 'Père de Nobunaga, seigneur de Owari', 'Oda et Toyotomi', 0, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('012c713c-c8c7-5ba5-a36b-eaac8cd2cfbc', 'entry', '5f252697-3a0b-58e1-aab8-d83b4cf825af', 'Oda Nobutada', null, 1557, 1582, 'Fils aîné de Nobunaga', 'Oda et Toyotomi', 0, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('23f1b329-c7cf-5f92-ab98-c73afb79be82', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Ieyasu', null, 1543, 1616, 'Premier shogun Tokugawa', 'Tokugawa', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9c942ec9-7abe-5822-bdbf-8b9aa6f261a4', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Hidetada', null, 1579, 1632, 'Deuxième shogun', 'Tokugawa', 250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f3d2b86e-61ce-5072-9da0-e9c2dcac7a21', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Iemitsu', null, 1604, 1651, 'Troisième shogun', 'Tokugawa', 250, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8f62e81b-e160-55bd-bea6-6e12c7fb7c3c', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Ietsuna', null, 1641, 1680, 'Quatrième shogun', 'Tokugawa', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9babcb73-2843-5655-80fc-1af83fb74c0e', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Tsunayoshi', null, 1646, 1709, 'Cinquième shogun', 'Tokugawa', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d3d986a5-e988-51b9-bbc0-70403b26b7d5', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Ienobu', null, 1662, 1712, 'Sixième shogun', 'Tokugawa', 3500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5d2ccdf4-aaa6-536f-8cb9-eb4c5c8d7e6d', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Ietsugu', null, 1709, 1716, 'Septième shogun', 'Tokugawa', 3500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bc91776a-f741-5409-a0ad-b7f839fc0e64', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Yoshimune', null, 1684, 1751, 'Huitième shogun (réformes Kyōhō)', 'Tokugawa', 1500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('129b991b-7100-56d0-90b9-cb7eaae97cf1', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Ieshige', null, 1712, 1761, 'Neuvième shogun', 'Tokugawa', 1500, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('898cc35c-3eb5-57bb-9432-1f55d08286c4', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Ieharu', null, 1737, 1786, 'Dixième shogun', 'Tokugawa', 1500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f1c028a0-fdf8-598f-872c-3794c3a8cdd0', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Ienari', null, 1773, 1841, 'Onzième shogun', 'Tokugawa', 2500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3f7255cc-ae91-54f8-b1af-da66e284cfbf', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Ieyoshi', null, 1793, 1853, 'Douzième shogun', 'Tokugawa', 2500, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a3e4fce1-6931-5335-99b9-8938336a09a7', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Iesada', null, 1824, 1858, 'Treizième shogun (traité de Harris)', 'Tokugawa', 2500, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2ae2eec9-9cee-59e2-b580-0c481e3fc3e4', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Iemochi', null, 1846, 1866, 'Quatorzième shogun', 'Tokugawa', 5500, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4cb961c8-c35b-5f82-9614-7a6b7fbeeec6', 'entry', 'e6751e92-8d39-59d3-81db-8eaeb534620c', 'Tokugawa Yoshinobu', null, 1837, 1913, 'Quinzième et dernier shogun', 'Tokugawa', 4500, 5760, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('244f1de9-791a-5857-915e-27ed5cb8e5ff', '48b2a0ec-a4b1-5813-95ac-9f2146ae152f', 'spouse');
  perform pg_temp.rel('244f1de9-791a-5857-915e-27ed5cb8e5ff', '8535bcb4-b3f0-51ff-b42a-5eb7d5bbc5ab', 'parent');
  perform pg_temp.rel('48b2a0ec-a4b1-5813-95ac-9f2146ae152f', '8535bcb4-b3f0-51ff-b42a-5eb7d5bbc5ab', 'parent');
  perform pg_temp.rel('244f1de9-791a-5857-915e-27ed5cb8e5ff', 'dcde26ce-b87f-5cbf-a4aa-7ced4eb83ba2', 'parent');
  perform pg_temp.rel('48b2a0ec-a4b1-5813-95ac-9f2146ae152f', 'dcde26ce-b87f-5cbf-a4aa-7ced4eb83ba2', 'parent');
  perform pg_temp.rel('c3d667b7-672c-5caa-bcf5-ef81010248e1', '2d414260-1b2e-5d3a-bad2-12c6a9b88a43', 'parent');
  perform pg_temp.rel('2d414260-1b2e-5d3a-bad2-12c6a9b88a43', '289cc1a9-13d6-5ff5-8f33-d87c61257ef3', 'parent');
  perform pg_temp.rel('289cc1a9-13d6-5ff5-8f33-d87c61257ef3', '09b7116e-547d-50da-89d0-4b9a7af8c157', 'parent');
  perform pg_temp.rel('289cc1a9-13d6-5ff5-8f33-d87c61257ef3', '86866ec1-2e39-5326-a734-ef7597cdf85e', 'parent');
  perform pg_temp.rel('86866ec1-2e39-5326-a734-ef7597cdf85e', '5041d7fd-f83c-5f2e-b67b-74397e462b55', 'parent');
  perform pg_temp.rel('9dfbcd48-954d-5f81-ae2e-3606f0727396', '39b48183-2168-53db-bdbe-1219c7733915', 'parent');
  perform pg_temp.rel('9dfbcd48-954d-5f81-ae2e-3606f0727396', 'd54bf37a-0a54-551e-8e32-9a5134b50e83', 'parent');
  perform pg_temp.rel('5041d7fd-f83c-5f2e-b67b-74397e462b55', '9dfbcd48-954d-5f81-ae2e-3606f0727396', 'family');
  perform pg_temp.rel('5b8a9dd4-d22e-548e-9d8d-4bd73d53014f', '322f5d64-f324-5ba4-8b78-840f5739e201', 'parent');
  perform pg_temp.rel('8eb035db-7afe-5d10-a84d-0db50edfde24', '4d0898d1-8d9f-585f-bbaa-88d6fb63d67f', 'parent');
  perform pg_temp.rel('4d0898d1-8d9f-585f-bbaa-88d6fb63d67f', '012c713c-c8c7-5ba5-a36b-eaac8cd2cfbc', 'parent');
  perform pg_temp.rel('23f1b329-c7cf-5f92-ab98-c73afb79be82', '9c942ec9-7abe-5822-bdbf-8b9aa6f261a4', 'parent');
  perform pg_temp.rel('9c942ec9-7abe-5822-bdbf-8b9aa6f261a4', 'f3d2b86e-61ce-5072-9da0-e9c2dcac7a21', 'parent');
  perform pg_temp.rel('f3d2b86e-61ce-5072-9da0-e9c2dcac7a21', '8f62e81b-e160-55bd-bea6-6e12c7fb7c3c', 'parent');
  perform pg_temp.rel('f3d2b86e-61ce-5072-9da0-e9c2dcac7a21', '9babcb73-2843-5655-80fc-1af83fb74c0e', 'parent');
  perform pg_temp.rel('d3d986a5-e988-51b9-bbc0-70403b26b7d5', '5d2ccdf4-aaa6-536f-8cb9-eb4c5c8d7e6d', 'parent');
  perform pg_temp.rel('bc91776a-f741-5409-a0ad-b7f839fc0e64', '129b991b-7100-56d0-90b9-cb7eaae97cf1', 'parent');
  perform pg_temp.rel('129b991b-7100-56d0-90b9-cb7eaae97cf1', '898cc35c-3eb5-57bb-9432-1f55d08286c4', 'parent');
  perform pg_temp.rel('f1c028a0-fdf8-598f-872c-3794c3a8cdd0', '3f7255cc-ae91-54f8-b1af-da66e284cfbf', 'parent');
  perform pg_temp.rel('3f7255cc-ae91-54f8-b1af-da66e284cfbf', 'a3e4fce1-6931-5335-99b9-8938336a09a7', 'parent');
  perform pg_temp.rel('f3d2b86e-61ce-5072-9da0-e9c2dcac7a21', 'd3d986a5-e988-51b9-bbc0-70403b26b7d5', 'family');
  perform pg_temp.rel('23f1b329-c7cf-5f92-ab98-c73afb79be82', 'bc91776a-f741-5409-a0ad-b7f839fc0e64', 'family');
  perform pg_temp.rel('898cc35c-3eb5-57bb-9432-1f55d08286c4', 'f1c028a0-fdf8-598f-872c-3794c3a8cdd0', 'family');
  perform pg_temp.rel('3f7255cc-ae91-54f8-b1af-da66e284cfbf', '2ae2eec9-9cee-59e2-b580-0c481e3fc3e4', 'family');
  perform pg_temp.rel('f1c028a0-fdf8-598f-872c-3794c3a8cdd0', '4cb961c8-c35b-5f82-9614-7a6b7fbeeec6', 'family');
  raise notice 'schema_v88 : % membres ajoutés.', 33;
end $$;
