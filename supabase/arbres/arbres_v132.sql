-- arbres_v132.sql — Cambodge (Norodom / Sisowath)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Norodom / Sisowath » (Cambodge) : 8 personnes de Ang Duong à Sihamoni. Chaque fiche porte l'adresse de la page Wikipédia (anglais) « List of heads of state of Cambodia » dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Ang Duong : père de Norodom d'après la liste, sans dates (page non lue). Sisowath est le frère de Norodom (lien « famille »). Sihanouk est le fils de Suramarit et de Kossamak (fille de Monivong) ; la mère de Sihamoni n'est pas saisie.
-- Sihamoni : né en 1953, vivant. Dates en année chrétienne.
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
  if exists (select 1 from public.genealogy_members where id = 'd692baab-587f-590a-85ce-0bb76083e34b') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Norodom / Sisowath » (KHM)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'KHM' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour KHM : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Norodom / Sisowath';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('3e78ccea-e3a9-501f-88d0-b923f64cfb2d', cat_id, 'country', 'KHM', top, 'Norodom / Sisowath', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '3e78ccea-e3a9-501f-88d0-b923f64cfb2d';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('40f4689f-c840-5b1f-a3b7-13bb6c95752b', 'country', 'KHM', 'genealogy', 'Norodom / Sisowath', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d692baab-587f-590a-85ce-0bb76083e34b', 'entry', '40f4689f-c840-5b1f-a3b7-13bb6c95752b', 'Ang Duong', null, null, null, 'Roi du Cambodge, père de Norodom', 'Norodom / Sisowath', 'Sources : https://en.wikipedia.org/wiki/List_of_heads_of_state_of_Cambodia', 1490, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fdcce0a4-2a1d-5ac7-8910-6972303695ff', 'entry', '40f4689f-c840-5b1f-a3b7-13bb6c95752b', 'Norodom', null, 1834, 1904, 'Roi du Cambodge (1860-1904)', 'Norodom / Sisowath', 'Sources : https://en.wikipedia.org/wiki/List_of_heads_of_state_of_Cambodia', 1490, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4fb7104d-e582-5cc1-ba3b-672efcdd4f3d', 'entry', '40f4689f-c840-5b1f-a3b7-13bb6c95752b', 'Sisowath', null, 1840, 1927, 'Roi du Cambodge (1904-1927)', 'Norodom / Sisowath', 'Sources : https://en.wikipedia.org/wiki/List_of_heads_of_state_of_Cambodia', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('aec044ca-beb3-5117-a70d-45a6a474a4b3', 'entry', '40f4689f-c840-5b1f-a3b7-13bb6c95752b', 'Sisowath Monivong', null, 1875, 1941, 'Roi du Cambodge (1927-1941)', 'Norodom / Sisowath', 'Sources : https://en.wikipedia.org/wiki/List_of_heads_of_state_of_Cambodia', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('58f96a61-0f5b-5ce4-a418-a873c940d760', 'entry', '40f4689f-c840-5b1f-a3b7-13bb6c95752b', 'Norodom Suramarit', null, 1896, 1960, 'Roi du Cambodge (1955-1960)', 'Norodom / Sisowath', 'Sources : https://en.wikipedia.org/wiki/List_of_heads_of_state_of_Cambodia', 490, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0683e5d9-ff44-5d70-8527-7bf0623ceee2', 'entry', '40f4689f-c840-5b1f-a3b7-13bb6c95752b', 'Sisowath Kossamak', null, 1904, 1975, 'Reine, mère de Norodom Sihanouk', 'Norodom / Sisowath', 'Sources : https://en.wikipedia.org/wiki/List_of_heads_of_state_of_Cambodia - monarque honorifique 1960-1970', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('85d21e15-7e75-5ec7-9de0-7fffe2d27104', 'entry', '40f4689f-c840-5b1f-a3b7-13bb6c95752b', 'Norodom Sihanouk', null, 1922, 2012, 'Roi (1941-1955 ; 1993-2004), chef de l''État', 'Norodom / Sisowath', 'Sources : https://en.wikipedia.org/wiki/List_of_heads_of_state_of_Cambodia', 245, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('307326d5-2135-520f-b3d9-e25396d1f3fc', 'entry', '40f4689f-c840-5b1f-a3b7-13bb6c95752b', 'Norodom Sihamoni', null, 1953, null, 'Roi du Cambodge (depuis 2004)', 'Norodom / Sisowath', 'Sources : https://en.wikipedia.org/wiki/List_of_heads_of_state_of_Cambodia', 245, 3840, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('d692baab-587f-590a-85ce-0bb76083e34b', 'fdcce0a4-2a1d-5ac7-8910-6972303695ff', 'parent');
  perform pg_temp.rel('4fb7104d-e582-5cc1-ba3b-672efcdd4f3d', 'aec044ca-beb3-5117-a70d-45a6a474a4b3', 'parent');
  perform pg_temp.rel('aec044ca-beb3-5117-a70d-45a6a474a4b3', '0683e5d9-ff44-5d70-8527-7bf0623ceee2', 'parent');
  perform pg_temp.rel('58f96a61-0f5b-5ce4-a418-a873c940d760', '85d21e15-7e75-5ec7-9de0-7fffe2d27104', 'parent');
  perform pg_temp.rel('0683e5d9-ff44-5d70-8527-7bf0623ceee2', '85d21e15-7e75-5ec7-9de0-7fffe2d27104', 'parent');
  perform pg_temp.rel('85d21e15-7e75-5ec7-9de0-7fffe2d27104', '307326d5-2135-520f-b3d9-e25396d1f3fc', 'parent');
  perform pg_temp.rel('fdcce0a4-2a1d-5ac7-8910-6972303695ff', '4fb7104d-e582-5cc1-ba3b-672efcdd4f3d', 'family');
  perform pg_temp.rel('58f96a61-0f5b-5ce4-a418-a873c940d760', '0683e5d9-ff44-5d70-8527-7bf0623ceee2', 'spouse');
  raise notice 'schema_v132 : % membres ajoutés.', 8;
end $$;
