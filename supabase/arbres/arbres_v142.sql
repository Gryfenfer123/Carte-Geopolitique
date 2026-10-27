-- arbres_v142.sql — Lesotho (Moshoeshoe)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Rois du Lesotho » : 5 personnes en deux branches. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Pages lues : Moshoeshoe I (père Mokhachane, successeur Letsie I) et liste des monarques (Moshoeshoe II fils de Simon Seeiso Griffith). Letsie III : fils de Moshoeshoe II. Les générations entre Letsie I et Seeiso ne sont pas indiquées par ces pages : les deux branches ne sont donc pas reliées. Dates de Letsie I et Seeiso inconnues.
-- Moshoeshoe I : né vers 1786 (date approximative).
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
  if exists (select 1 from public.genealogy_members where id = '11e5dc8f-d862-5643-9bfc-4e4e8bed2621') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Rois du Lesotho » (LSO)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'LSO' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour LSO : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Rois du Lesotho';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('f0e3f355-b68f-5ad6-ae15-ebcd4c07392a', cat_id, 'country', 'LSO', top, 'Rois du Lesotho', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'f0e3f355-b68f-5ad6-ae15-ebcd4c07392a';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('361e6daf-c0f6-5fff-bad6-26660c0458bb', 'country', 'LSO', 'genealogy', 'Rois du Lesotho', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('11e5dc8f-d862-5643-9bfc-4e4e8bed2621', 'entry', '361e6daf-c0f6-5fff-bad6-26660c0458bb', 'Moshoeshoe I', null, 1786, 1870, 'Fondateur du royaume basotho (1822-1870)', 'Rois du Lesotho', 'Sources : https://en.wikipedia.org/wiki/Moshoeshoe_I - naissance vers 1786 ; mort le 11 mars 1870', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('84e5ba22-5b7d-5934-b7bf-b2377c175362', 'entry', '361e6daf-c0f6-5fff-bad6-26660c0458bb', 'Letsie I', null, null, null, 'Chef suprême des Basotho (1870-1891)', 'Rois du Lesotho', 'Sources : https://en.wikipedia.org/wiki/Monarchy_of_Lesotho - règne 1870-1891 ; fils de Moshoeshoe I selon la page de Moshoeshoe I', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e442e9d5-135e-5079-a5dd-5300d2ac20a7', 'entry', '361e6daf-c0f6-5fff-bad6-26660c0458bb', 'Simon Seeiso Griffith', null, null, null, 'Chef suprême des Basotho (1939-1940)', 'Rois du Lesotho', 'Sources : https://en.wikipedia.org/wiki/Monarchy_of_Lesotho', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ac06de1e-6a6c-52b1-bfa1-a0c2ef4f5db2', 'entry', '361e6daf-c0f6-5fff-bad6-26660c0458bb', 'Moshoeshoe II', null, 1938, 1996, 'Roi du Lesotho (1960-1990 ; 1995-1996)', 'Rois du Lesotho', 'Sources : https://en.wikipedia.org/wiki/Monarchy_of_Lesotho', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b314422e-c955-5595-92d1-8d111f5d0ef7', 'entry', '361e6daf-c0f6-5fff-bad6-26660c0458bb', 'Letsie III', null, 1963, null, 'Roi du Lesotho (1990-1995 ; depuis 1996)', 'Rois du Lesotho', 'Sources : https://en.wikipedia.org/wiki/Monarchy_of_Lesotho', 0, 3200, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('11e5dc8f-d862-5643-9bfc-4e4e8bed2621', '84e5ba22-5b7d-5934-b7bf-b2377c175362', 'parent');
  perform pg_temp.rel('e442e9d5-135e-5079-a5dd-5300d2ac20a7', 'ac06de1e-6a6c-52b1-bfa1-a0c2ef4f5db2', 'parent');
  perform pg_temp.rel('ac06de1e-6a6c-52b1-bfa1-a0c2ef4f5db2', 'b314422e-c955-5595-92d1-8d111f5d0ef7', 'parent');
  raise notice 'schema_v142 : % membres ajoutés.', 5;
end $$;
