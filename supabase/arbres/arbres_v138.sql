-- arbres_v138.sql — Malaisie (sultans de Johor)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Sultans de Johor » (Malaisie) : 6 personnes, de Daeng Ibrahim à l'actuel sultan. Johor est un seul des États à monarchie de Malaisie ; les autres familles royales ne sont pas encore faites. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Dates et pères pris sur la page « Sultan of Johor » (liste), sauf Daeng Ibrahim (1810-1862, sa page). Sultan actuel : vivant. Le sultan actuel est le 5e de la liste ; Ibrahim Iskandar porte aussi le titre de « Ibrahim of Johor » (1895-1959).
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
  if exists (select 1 from public.genealogy_members where id = '4d3358f5-7819-53d1-8056-7c2540f21beb') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Sultans de Johor » (MYS)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'MYS' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour MYS : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Sultans de Johor';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('ff6adf2b-aded-5ca8-a2e7-af0e54699e89', cat_id, 'country', 'MYS', top, 'Sultans de Johor', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'ff6adf2b-aded-5ca8-a2e7-af0e54699e89';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('ff234677-92d8-5ffb-8c46-af67cf06e952', 'country', 'MYS', 'genealogy', 'Sultans de Johor', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4d3358f5-7819-53d1-8056-7c2540f21beb', 'entry', 'ff234677-92d8-5ffb-8c46-af67cf06e952', 'Daeng Ibrahim', null, 1810, 1862, 'Temenggong de Johor (1841-1862)', 'Sultans de Johor', 'Sources : https://en.wikipedia.org/wiki/Temenggong_Daeng_Ibrahim', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1156c637-d67d-50cd-b647-024fe9f5d75a', 'entry', 'ff234677-92d8-5ffb-8c46-af67cf06e952', 'Abu Bakar de Johor', null, 1833, 1895, 'Maharaja puis sultan de Johor (sultan 1886-1895)', 'Sultans de Johor', 'Sources : https://en.wikipedia.org/wiki/Sultan_of_Johor', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3ccb13bd-3491-557c-a310-56f63f4bcad2', 'entry', 'ff234677-92d8-5ffb-8c46-af67cf06e952', 'Ibrahim de Johor', null, 1873, 1959, 'Sultan de Johor (1895-1959)', 'Sultans de Johor', 'Sources : https://en.wikipedia.org/wiki/Sultan_of_Johor', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5502aa70-f5aa-5b00-8515-bdbdf84c2d02', 'entry', 'ff234677-92d8-5ffb-8c46-af67cf06e952', 'Ismail de Johor', null, 1894, 1981, 'Sultan de Johor (1959-1981)', 'Sultans de Johor', 'Sources : https://en.wikipedia.org/wiki/Sultan_of_Johor', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3a253d3f-7827-5345-94a6-ebf90ee2a83d', 'entry', 'ff234677-92d8-5ffb-8c46-af67cf06e952', 'Iskandar de Johor', null, 1932, 2010, 'Sultan de Johor (1981-2010)', 'Sultans de Johor', 'Sources : https://en.wikipedia.org/wiki/Sultan_of_Johor', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('aa654db8-ce0d-55f5-a041-6bc7074afa89', 'entry', 'ff234677-92d8-5ffb-8c46-af67cf06e952', 'Ibrahim Ismail de Johor', null, 1958, null, 'Sultan de Johor (depuis 2010)', 'Sultans de Johor', 'Sources : https://en.wikipedia.org/wiki/Sultan_of_Johor', 0, 3200, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('4d3358f5-7819-53d1-8056-7c2540f21beb', '1156c637-d67d-50cd-b647-024fe9f5d75a', 'parent');
  perform pg_temp.rel('1156c637-d67d-50cd-b647-024fe9f5d75a', '3ccb13bd-3491-557c-a310-56f63f4bcad2', 'parent');
  perform pg_temp.rel('3ccb13bd-3491-557c-a310-56f63f4bcad2', '5502aa70-f5aa-5b00-8515-bdbdf84c2d02', 'parent');
  perform pg_temp.rel('5502aa70-f5aa-5b00-8515-bdbdf84c2d02', '3a253d3f-7827-5345-94a6-ebf90ee2a83d', 'parent');
  perform pg_temp.rel('3a253d3f-7827-5345-94a6-ebf90ee2a83d', 'aa654db8-ce0d-55f5-a041-6bc7074afa89', 'parent');
  raise notice 'schema_v138 : % membres ajoutés.', 6;
end $$;
