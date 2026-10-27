-- arbres_v130.sql — Népal (Shah)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Shah » (Népal) : 13 rois de Prithvi Narayan Shah à Gyanendra, avec son père Nara Bhupal (sans dates). Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Prithvi Bir Bikram est « petit-fils » de Surendra (le père, non nommé par la page, n'est pas saisi) : lien « famille ». Tribhuvan et Gyanendra ont chacun deux règnes ; une seule fiche chacun. Gyanendra : né en 1947, vivant.
-- Dates en année chrétienne telles que la page les donne.
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
  if exists (select 1 from public.genealogy_members where id = 'c2aa78ba-52e4-555b-8c97-57b67f88165f') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Shah » (NPL)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'NPL' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour NPL : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Shah';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('01d50921-9a26-5942-ad8a-414937cc686f', cat_id, 'country', 'NPL', top, 'Shah', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '01d50921-9a26-5942-ad8a-414937cc686f';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'country', 'NPL', 'genealogy', 'Shah', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c2aa78ba-52e4-555b-8c97-57b67f88165f', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Nara Bhupal Shah', null, null, null, 'Roi de Gorkha, père de Prithvi Narayan Shah', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e7206a92-e707-5033-8892-b3ad018fbb29', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Prithvi Narayan Shah', null, 1723, 1775, 'Roi du Népal (1743-1775), unificateur du pays', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d419c740-4833-5d9c-8c0c-7e6b6755c258', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Pratap Singh Shah', null, 1751, 1777, 'Roi du Népal (1775-1777)', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('05c8cf67-89bd-5294-b907-dd298bb15127', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Rana Bahadur Shah', null, 1775, 1806, 'Roi du Népal (1777-1799)', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0d964817-ea2f-5e35-bdb3-471d612e1de3', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Girvan Yuddha Bikram Shah', null, 1797, 1816, 'Roi du Népal (1799-1816)', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('18daaf49-232f-59a6-96d7-cac76a0a274e', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Rajendra Bikram Shah', null, 1813, 1881, 'Roi du Népal (1816-1847)', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9487b763-566e-5ee6-b949-01c45c92057c', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Surendra Bikram Shah', null, 1829, 1881, 'Roi du Népal (1847-1881)', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 0, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4f71be9f-2a7f-5f46-b9c9-8eb1273e717b', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Prithvi Bir Bikram Shah', null, 1875, 1911, 'Roi du Népal (1881-1911)', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 1250, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bc915970-8efe-596e-b809-c14411fda177', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Tribhuvan Bir Bikram Shah', null, 1906, 1955, 'Roi du Népal (1911-1950 ; 1951-1955)', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 1250, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('434f9b6d-3fb7-5fef-98bb-161b090adf60', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Mahendra Bir Bikram Shah', null, 1920, 1972, 'Roi du Népal (1955-1972)', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 1250, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cc8e5725-5920-5a8f-93e1-961f60c998c3', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Birendra Bir Bikram Shah', null, 1945, 2001, 'Roi du Népal (1972-2001), assassiné', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 1000, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('038ead80-fc9a-59ed-9f68-a6df2d3b5b62', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Dipendra Bir Bikram Shah', null, 1971, 2001, 'Roi du Népal (1er-4 juin 2001)', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 1000, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ae3ab72b-2b6f-54c0-80f4-e8feafd347d8', 'entry', '26480cb8-f603-53f8-9c49-16cf72b2e7c9', 'Gyanendra Bir Bikram Shah', null, 1947, null, 'Roi du Népal (1950-1951 ; 2001-2008)', 'Shah', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Nepal', 1500, 5760, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('c2aa78ba-52e4-555b-8c97-57b67f88165f', 'e7206a92-e707-5033-8892-b3ad018fbb29', 'parent');
  perform pg_temp.rel('e7206a92-e707-5033-8892-b3ad018fbb29', 'd419c740-4833-5d9c-8c0c-7e6b6755c258', 'parent');
  perform pg_temp.rel('d419c740-4833-5d9c-8c0c-7e6b6755c258', '05c8cf67-89bd-5294-b907-dd298bb15127', 'parent');
  perform pg_temp.rel('05c8cf67-89bd-5294-b907-dd298bb15127', '0d964817-ea2f-5e35-bdb3-471d612e1de3', 'parent');
  perform pg_temp.rel('0d964817-ea2f-5e35-bdb3-471d612e1de3', '18daaf49-232f-59a6-96d7-cac76a0a274e', 'parent');
  perform pg_temp.rel('18daaf49-232f-59a6-96d7-cac76a0a274e', '9487b763-566e-5ee6-b949-01c45c92057c', 'parent');
  perform pg_temp.rel('4f71be9f-2a7f-5f46-b9c9-8eb1273e717b', 'bc915970-8efe-596e-b809-c14411fda177', 'parent');
  perform pg_temp.rel('bc915970-8efe-596e-b809-c14411fda177', '434f9b6d-3fb7-5fef-98bb-161b090adf60', 'parent');
  perform pg_temp.rel('434f9b6d-3fb7-5fef-98bb-161b090adf60', 'cc8e5725-5920-5a8f-93e1-961f60c998c3', 'parent');
  perform pg_temp.rel('cc8e5725-5920-5a8f-93e1-961f60c998c3', '038ead80-fc9a-59ed-9f68-a6df2d3b5b62', 'parent');
  perform pg_temp.rel('434f9b6d-3fb7-5fef-98bb-161b090adf60', 'ae3ab72b-2b6f-54c0-80f4-e8feafd347d8', 'parent');
  perform pg_temp.rel('9487b763-566e-5ee6-b949-01c45c92057c', '4f71be9f-2a7f-5f46-b9c9-8eb1273e717b', 'family');
  raise notice 'schema_v130 : % membres ajoutés.', 13;
end $$;
