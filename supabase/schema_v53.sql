-- schema_v53.sql — Monaco — Grimaldi
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Crée sous Monaco > Dynastie : Grimaldi (Honoré II -> Albert II et ses enfants). La branche génoise plus ancienne (Francesco Grimaldi 1297, Rainier Ier, Lambert) n'est pas incluse : la page Wikipédia ne donne pas de dates ni de liens.
-- Épouses avant Honoré III non saisies faute de source consultée ; elles sont à ajouter si Martin le souhaite.
-- Honoré V : épouse non précisée par la page, laissée vide.
-- Florestine de Monaco et son mari Guillaume d'Urach sont ajoutés (leur fils Mindaugas II servira pour la Lituanie).
-- Naissance de Charlène Wittstock (1978) : non donnée par la page, de mémoire, à vérifier.
-- Prérequis : v52 exécuté.
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
  if exists (select 1 from public.genealogy_members where id = 'aace91c2-d9a1-5380-b972-9af1a7dd14aa') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Grimaldi » (MCO)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'MCO' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour MCO : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Grimaldi';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('e033860f-0604-54c4-8f36-66d0f8bf4adf', cat_id, 'country', 'MCO', top, 'Grimaldi', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'e033860f-0604-54c4-8f36-66d0f8bf4adf';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'country', 'MCO', 'genealogy', 'Grimaldi', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aace91c2-d9a1-5380-b972-9af1a7dd14aa', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Honoré II de Monaco', null, 1597, 1662, 'Premier prince de Monaco (seigneur en 1604, prince en 1633)', 'Grimaldi', 540, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('52478c5e-7e4a-544d-b785-0b437edcad60', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Hercule Grimaldi (marquis des Baux)', null, 1623, 1651, 'Marquis des Baux, héritier', 'Grimaldi', 540, 468, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2c9ab53e-04e2-51b7-8359-0c367249d40d', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Louis Ier de Monaco', null, 1642, 1701, 'Prince de Monaco (1662-1701)', 'Grimaldi', 540, 928, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('edd83d53-e61a-5691-9b68-052e3367e1d2', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Antoine Ier de Monaco', null, 1661, 1731, 'Prince de Monaco (1701-1731)', 'Grimaldi', 540, 1388, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('68b424b8-0ae6-5f27-8245-c0adbff1445c', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Louise Hippolyte de Monaco', null, 1697, 1731, 'Princesse de Monaco (1731)', 'Grimaldi', 540, 1848, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e4d27171-70f9-58d4-9657-334937bf96a9', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Jacques Ier de Monaco (Goyon de Matignon)', null, 1689, 1751, 'Prince de Monaco (1731-1733), époux de Louise Hippolyte', 'Goyon de Matignon (puis Grimaldi)', 0, 1848, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c10b357d-5685-5abc-a867-323dbceeddad', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Honoré III de Monaco', null, 1720, 1795, 'Prince de Monaco (1733-1793)', 'Grimaldi', 270, 2308, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('11e048c2-4455-55f1-9b3a-98961328d330', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Maria Caterina Brignole', null, null, 1813, 'Princesse de Monaco', 'Brignole (Gênes)', 810, 2308, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('14664cd2-f6a3-5fe4-9dd4-70a648af79b9', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Honoré IV de Monaco', null, 1758, 1819, 'Prince de Monaco (1814-1819)', 'Grimaldi', 540, 2898, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ebd0612b-2b94-5570-87d8-9d86296009b1', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Louise d''Aumont (duchesse de Mazarin)', null, null, null, 'Princesse de Monaco, duchesse d''Aumont et de Mazarin', 'd''Aumont', 1105, 2898, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dced5c23-f072-5c93-84b7-a8b1585b01df', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Honoré V de Monaco', null, 1778, 1841, 'Prince de Monaco (1819-1841)', 'Grimaldi', 618, 3358, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f7ed76ef-9526-5c1e-9871-3467b97f7ee1', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Florestan Ier de Monaco', null, 1785, 1856, 'Prince de Monaco (1841-1856)', 'Grimaldi', 1028, 3358, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6e843258-4aee-5ade-84d2-a7ecabbd4b6f', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Caroline Gibert de Lametz', null, null, null, 'Princesse de Monaco', 'Gibert de Lametz (Champagne)', 1507, 3358, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2263d634-4bdc-5564-8447-de82e31ef771', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Charles III de Monaco', null, 1818, 1889, 'Prince de Monaco (1856-1889)', 'Grimaldi', 1062, 4113, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fcc01840-304a-590e-8c00-462a22c81289', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Florestine de Monaco (duchesse d''Urach)', null, 1833, 1897, 'Princesse de Monaco, duchesse d''Urach', 'Grimaldi', 1472, 4113, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d22a4f35-1485-54c1-b7b0-0c212b364f51', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Guillaume d''Urach (duc d''Urach)', null, 1810, 1869, 'Duc d''Urach', 'Urach (Wurtemberg)', 1852, 4113, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('eab151c4-428d-5491-b431-0863a9bc133e', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Antoinette de Mérode', null, 1828, 1864, 'Princesse de Monaco', 'de Mérode (Belgique)', 522, 4113, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('52360545-cc76-5583-9e42-2bf35f2e64f0', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Albert Ier de Monaco', null, 1848, 1922, 'Prince de Monaco (1889-1922), océanographe', 'Grimaldi', 792, 4573, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dc70fe7b-4da8-5b74-b76a-dc2e0d90c91b', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Lady Mary Victoria Hamilton', null, 1850, 1922, 'Princesse de Monaco (mariage annulé en 1880)', 'Hamilton (Royaume-Uni)', 252, 4573, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b4b8d9ec-c955-55ff-a693-24d9f1b9b39e', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Alice Heine', null, 1858, 1925, 'Princesse de Monaco', 'Heine (États-Unis)', 1172, 4573, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('84a82748-1d7a-53c0-a773-089d7f137449', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Louis II de Monaco', null, 1870, 1949, 'Prince de Monaco (1922-1949)', 'Grimaldi', 522, 5033, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d863c053-8343-5210-b2cb-ed55e830cc69', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Ghislaine Dommanget', null, 1900, 1991, 'Princesse de Monaco (épouse de Louis II, 1946)', 'Dommanget', 1062, 5033, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('44835634-5c75-50d1-9118-b36da633254d', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Charlotte de Monaco', null, 1898, 1977, 'Princesse héréditaire, duchesse de Valentinois', 'Grimaldi', 792, 5493, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('50ce492d-d525-5070-9eb0-187b1e912064', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Pierre de Polignac (prince Pierre de Monaco)', null, 1895, 1964, 'Prince consort', 'Polignac (France)', 252, 5493, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c6ed5e6a-b175-57e1-a401-e5d79f9d1a52', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Rainier III de Monaco', null, 1923, 2005, 'Prince de Monaco (1949-2005)', 'Grimaldi', 522, 5953, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8004c1e2-2802-5ca2-be6f-d162380b78dd', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Grace Kelly', null, 1929, 1982, 'Princesse de Monaco, actrice', 'Kelly (États-Unis)', 1406, 5953, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d187a81f-eea1-5173-9535-3b503da92d59', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Caroline de Monaco', null, 1957, null, 'Princesse de Hanovre', 'Grimaldi', 331, 6534, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dc753339-7205-53ad-bc20-8a5eeb5458f0', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Albert II de Monaco', null, 1958, null, 'Prince de Monaco (depuis 2005)', 'Grimaldi', 741, 6534, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ce0f218e-c67d-58d3-b711-ae638ce1acf8', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Stéphanie de Monaco', null, 1965, null, 'Princesse', 'Grimaldi', 1598, 6534, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cb46b5d5-1a98-558e-b692-7ca69c5088d9', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Charlène Wittstock', null, 1978, null, 'Princesse de Monaco', 'Wittstock (Afrique du Sud)', 1188, 6534, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8b479f16-5eeb-5a14-af51-dcc79e460609', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Jacques de Monaco', null, 2014, null, 'Prince héréditaire de Monaco', 'Grimaldi', 1169, 7506, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('29d176a5-375a-53c9-a71e-73e756fd603c', 'entry', 'eea7a1a3-9435-55b9-ae8b-eb1806e3c688', 'Gabriella de Monaco', null, 2014, null, 'Comtesse de Carladès', 'Grimaldi', 759, 7506, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('aace91c2-d9a1-5380-b972-9af1a7dd14aa', '52478c5e-7e4a-544d-b785-0b437edcad60', 'parent');
  perform pg_temp.rel('52478c5e-7e4a-544d-b785-0b437edcad60', '2c9ab53e-04e2-51b7-8359-0c367249d40d', 'parent');
  perform pg_temp.rel('2c9ab53e-04e2-51b7-8359-0c367249d40d', 'edd83d53-e61a-5691-9b68-052e3367e1d2', 'parent');
  perform pg_temp.rel('edd83d53-e61a-5691-9b68-052e3367e1d2', '68b424b8-0ae6-5f27-8245-c0adbff1445c', 'parent');
  perform pg_temp.rel('68b424b8-0ae6-5f27-8245-c0adbff1445c', 'e4d27171-70f9-58d4-9657-334937bf96a9', 'spouse');
  perform pg_temp.rel('e4d27171-70f9-58d4-9657-334937bf96a9', 'c10b357d-5685-5abc-a867-323dbceeddad', 'parent');
  perform pg_temp.rel('68b424b8-0ae6-5f27-8245-c0adbff1445c', 'c10b357d-5685-5abc-a867-323dbceeddad', 'parent');
  perform pg_temp.rel('c10b357d-5685-5abc-a867-323dbceeddad', '11e048c2-4455-55f1-9b3a-98961328d330', 'spouse');
  perform pg_temp.rel('c10b357d-5685-5abc-a867-323dbceeddad', '14664cd2-f6a3-5fe4-9dd4-70a648af79b9', 'parent');
  perform pg_temp.rel('11e048c2-4455-55f1-9b3a-98961328d330', '14664cd2-f6a3-5fe4-9dd4-70a648af79b9', 'parent');
  perform pg_temp.rel('14664cd2-f6a3-5fe4-9dd4-70a648af79b9', 'ebd0612b-2b94-5570-87d8-9d86296009b1', 'spouse');
  perform pg_temp.rel('14664cd2-f6a3-5fe4-9dd4-70a648af79b9', 'dced5c23-f072-5c93-84b7-a8b1585b01df', 'parent');
  perform pg_temp.rel('ebd0612b-2b94-5570-87d8-9d86296009b1', 'dced5c23-f072-5c93-84b7-a8b1585b01df', 'parent');
  perform pg_temp.rel('14664cd2-f6a3-5fe4-9dd4-70a648af79b9', 'f7ed76ef-9526-5c1e-9871-3467b97f7ee1', 'parent');
  perform pg_temp.rel('ebd0612b-2b94-5570-87d8-9d86296009b1', 'f7ed76ef-9526-5c1e-9871-3467b97f7ee1', 'parent');
  perform pg_temp.rel('f7ed76ef-9526-5c1e-9871-3467b97f7ee1', '6e843258-4aee-5ade-84d2-a7ecabbd4b6f', 'spouse');
  perform pg_temp.rel('f7ed76ef-9526-5c1e-9871-3467b97f7ee1', '2263d634-4bdc-5564-8447-de82e31ef771', 'parent');
  perform pg_temp.rel('6e843258-4aee-5ade-84d2-a7ecabbd4b6f', '2263d634-4bdc-5564-8447-de82e31ef771', 'parent');
  perform pg_temp.rel('f7ed76ef-9526-5c1e-9871-3467b97f7ee1', 'fcc01840-304a-590e-8c00-462a22c81289', 'parent');
  perform pg_temp.rel('6e843258-4aee-5ade-84d2-a7ecabbd4b6f', 'fcc01840-304a-590e-8c00-462a22c81289', 'parent');
  perform pg_temp.rel('fcc01840-304a-590e-8c00-462a22c81289', 'd22a4f35-1485-54c1-b7b0-0c212b364f51', 'spouse');
  perform pg_temp.rel('2263d634-4bdc-5564-8447-de82e31ef771', 'eab151c4-428d-5491-b431-0863a9bc133e', 'spouse');
  perform pg_temp.rel('2263d634-4bdc-5564-8447-de82e31ef771', '52360545-cc76-5583-9e42-2bf35f2e64f0', 'parent');
  perform pg_temp.rel('eab151c4-428d-5491-b431-0863a9bc133e', '52360545-cc76-5583-9e42-2bf35f2e64f0', 'parent');
  perform pg_temp.rel('52360545-cc76-5583-9e42-2bf35f2e64f0', 'dc70fe7b-4da8-5b74-b76a-dc2e0d90c91b', 'spouse');
  perform pg_temp.rel('52360545-cc76-5583-9e42-2bf35f2e64f0', 'b4b8d9ec-c955-55ff-a693-24d9f1b9b39e', 'spouse');
  perform pg_temp.rel('52360545-cc76-5583-9e42-2bf35f2e64f0', '84a82748-1d7a-53c0-a773-089d7f137449', 'parent');
  perform pg_temp.rel('dc70fe7b-4da8-5b74-b76a-dc2e0d90c91b', '84a82748-1d7a-53c0-a773-089d7f137449', 'parent');
  perform pg_temp.rel('84a82748-1d7a-53c0-a773-089d7f137449', 'd863c053-8343-5210-b2cb-ed55e830cc69', 'spouse');
  perform pg_temp.rel('84a82748-1d7a-53c0-a773-089d7f137449', '44835634-5c75-50d1-9118-b36da633254d', 'parent');
  perform pg_temp.rel('44835634-5c75-50d1-9118-b36da633254d', '50ce492d-d525-5070-9eb0-187b1e912064', 'spouse');
  perform pg_temp.rel('44835634-5c75-50d1-9118-b36da633254d', 'c6ed5e6a-b175-57e1-a401-e5d79f9d1a52', 'parent');
  perform pg_temp.rel('50ce492d-d525-5070-9eb0-187b1e912064', 'c6ed5e6a-b175-57e1-a401-e5d79f9d1a52', 'parent');
  perform pg_temp.rel('c6ed5e6a-b175-57e1-a401-e5d79f9d1a52', '8004c1e2-2802-5ca2-be6f-d162380b78dd', 'spouse');
  perform pg_temp.rel('c6ed5e6a-b175-57e1-a401-e5d79f9d1a52', 'd187a81f-eea1-5173-9535-3b503da92d59', 'parent');
  perform pg_temp.rel('8004c1e2-2802-5ca2-be6f-d162380b78dd', 'd187a81f-eea1-5173-9535-3b503da92d59', 'parent');
  perform pg_temp.rel('c6ed5e6a-b175-57e1-a401-e5d79f9d1a52', 'dc753339-7205-53ad-bc20-8a5eeb5458f0', 'parent');
  perform pg_temp.rel('8004c1e2-2802-5ca2-be6f-d162380b78dd', 'dc753339-7205-53ad-bc20-8a5eeb5458f0', 'parent');
  perform pg_temp.rel('c6ed5e6a-b175-57e1-a401-e5d79f9d1a52', 'ce0f218e-c67d-58d3-b711-ae638ce1acf8', 'parent');
  perform pg_temp.rel('8004c1e2-2802-5ca2-be6f-d162380b78dd', 'ce0f218e-c67d-58d3-b711-ae638ce1acf8', 'parent');
  perform pg_temp.rel('dc753339-7205-53ad-bc20-8a5eeb5458f0', 'cb46b5d5-1a98-558e-b692-7ca69c5088d9', 'spouse');
  perform pg_temp.rel('dc753339-7205-53ad-bc20-8a5eeb5458f0', '8b479f16-5eeb-5a14-af51-dcc79e460609', 'parent');
  perform pg_temp.rel('cb46b5d5-1a98-558e-b692-7ca69c5088d9', '8b479f16-5eeb-5a14-af51-dcc79e460609', 'parent');
  perform pg_temp.rel('dc753339-7205-53ad-bc20-8a5eeb5458f0', '29d176a5-375a-53c9-a71e-73e756fd603c', 'parent');
  perform pg_temp.rel('cb46b5d5-1a98-558e-b692-7ca69c5088d9', '29d176a5-375a-53c9-a71e-73e756fd603c', 'parent');
  raise notice 'schema_v53 : % membres ajoutés.', 32;
end $$;
