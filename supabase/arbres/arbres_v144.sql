-- arbres_v144.sql — Madagascar (Merina)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Monarchie merina » (Madagascar) : 7 personnes, d'Andrianampoinimerina à Ranavalona III. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Toutes les données viennent de la page « List of Imerina monarchs ». Cette page ne donne ni père ni mère pour la plupart des rois (donc les rois avant Andrianampoinimerina ne sont pas dans l'arbre). Elle indique : Radama I fils d'Andrianampoinimerina ; Ranavalona I épouse de Radama I ; Radama II dont Ranavalona I est « parent » (sexe non précisé) ; Rasoherina et Ranavalona II épouses de Radama II ; Ranavalona III nièce de Ranavalona II et petite-fille de Radama I (ligne exacte non donnée : lien « famille »).
-- Ranavalona I est donnée comme mère de Radama II par lien « parent » : formulation de la page ambiguë, à vérifier.
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
  if exists (select 1 from public.genealogy_members where id = 'd06d65a0-d80f-5920-9fc4-ecfc24c80a18') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Monarchie merina » (MDG)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'MDG' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour MDG : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Monarchie merina';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('9f35df66-8ef0-50ae-a752-032340c6192f', cat_id, 'country', 'MDG', top, 'Monarchie merina', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '9f35df66-8ef0-50ae-a752-032340c6192f';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('54533537-ed07-5e74-8bbd-63e5dea6c825', 'country', 'MDG', 'genealogy', 'Monarchie merina', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d06d65a0-d80f-5920-9fc4-ecfc24c80a18', 'entry', '54533537-ed07-5e74-8bbd-63e5dea6c825', 'Andrianampoinimerina', null, 1745, null, 'Roi d''Imerina (1787-1810)', 'Monarchie merina', 'Sources : https://en.wikipedia.org/wiki/List_of_Imerina_monarchs - naissance 1745 (indiquée seulement dans l''encadré de la page)', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e4dfaa9e-4a35-5920-a950-617ce22324e8', 'entry', '54533537-ed07-5e74-8bbd-63e5dea6c825', 'Radama I', null, 1793, 1828, 'Roi de Madagascar (1810-1828)', 'Monarchie merina', 'Sources : https://en.wikipedia.org/wiki/List_of_Imerina_monarchs', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('517edffc-4b36-5385-bf13-9a39b6e1507b', 'entry', '54533537-ed07-5e74-8bbd-63e5dea6c825', 'Ranavalona I', null, 1778, 1861, 'Reine de Madagascar (1828-1861)', 'Monarchie merina', 'Sources : https://en.wikipedia.org/wiki/List_of_Imerina_monarchs - épouse de Radama I selon la liste', 490, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bcff88d0-d9f6-564d-8a82-1b82ce83c53c', 'entry', '54533537-ed07-5e74-8bbd-63e5dea6c825', 'Radama II', null, 1829, 1863, 'Roi de Madagascar (1861-1863)', 'Monarchie merina', 'Sources : https://en.wikipedia.org/wiki/List_of_Imerina_monarchs - assassiné ; Ranavalona I figure comme parent', 490, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1223b0dc-f319-55a6-b815-bdb3e7395af1', 'entry', '54533537-ed07-5e74-8bbd-63e5dea6c825', 'Rasoherina', null, 1814, 1868, 'Reine de Madagascar (1863-1868)', 'Monarchie merina', 'Sources : https://en.wikipedia.org/wiki/List_of_Imerina_monarchs - épouse de Radama II selon la liste', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8fd856d8-1f82-5624-a379-12c01b6b93c7', 'entry', '54533537-ed07-5e74-8bbd-63e5dea6c825', 'Ranavalona II', null, 1829, 1883, 'Reine de Madagascar (1868-1883)', 'Monarchie merina', 'Sources : https://en.wikipedia.org/wiki/List_of_Imerina_monarchs - épouse de Radama II selon la liste', 980, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c8e1d271-50a7-5e09-955d-1e2005d01f71', 'entry', '54533537-ed07-5e74-8bbd-63e5dea6c825', 'Ranavalona III', null, 1861, 1917, 'Dernière reine de Madagascar (1883-1897)', 'Monarchie merina', 'Sources : https://en.wikipedia.org/wiki/List_of_Imerina_monarchs - nièce de Ranavalona II et petite-fille de Radama I selon la liste', 1980, 1920, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('d06d65a0-d80f-5920-9fc4-ecfc24c80a18', 'e4dfaa9e-4a35-5920-a950-617ce22324e8', 'parent');
  perform pg_temp.rel('517edffc-4b36-5385-bf13-9a39b6e1507b', 'bcff88d0-d9f6-564d-8a82-1b82ce83c53c', 'parent');
  perform pg_temp.rel('8fd856d8-1f82-5624-a379-12c01b6b93c7', 'c8e1d271-50a7-5e09-955d-1e2005d01f71', 'family');
  perform pg_temp.rel('e4dfaa9e-4a35-5920-a950-617ce22324e8', 'c8e1d271-50a7-5e09-955d-1e2005d01f71', 'family');
  perform pg_temp.rel('e4dfaa9e-4a35-5920-a950-617ce22324e8', '517edffc-4b36-5385-bf13-9a39b6e1507b', 'spouse');
  perform pg_temp.rel('bcff88d0-d9f6-564d-8a82-1b82ce83c53c', '1223b0dc-f319-55a6-b815-bdb3e7395af1', 'spouse');
  perform pg_temp.rel('bcff88d0-d9f6-564d-8a82-1b82ce83c53c', '8fd856d8-1f82-5624-a379-12c01b6b93c7', 'spouse');
  raise notice 'schema_v144 : % membres ajoutés.', 7;
end $$;
