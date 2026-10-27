-- arbres_v136.sql — Laos (Luang Prabang, Champassak)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Maisons royales du Laos » (Laos) : 6 personnes (Luang Prabang : Kham Souk, Sisavang Vong, Sisavang Vatthana ; Champassak : un Kham Souk, Ratsadanay, Boun Oum). Chaque fiche porte l'adresse de la page Wikipédia (anglais) « List of monarchs of Laos » dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Les deux Kham Souk sont deux personnes : celui de Luang Prabang (1840-1904) et celui de Champassak (1839-1900, dates tirées de la ligne de son fils). Aucun lien entre les deux branches n'est saisi (non indiqué par la page). Anouvong (Vientiane) non saisi : son père Ong Boun n'a pas de page lue.
-- Sisavang Vong : fin du règne de Luang Prabang 1945 ou 1946 selon les tableaux. Dates en année chrétienne.
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
  if exists (select 1 from public.genealogy_members where id = 'f4c058c3-a03b-58ad-ad18-e3a9e3d1711c') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Maisons royales du Laos » (LAO)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'LAO' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour LAO : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Maisons royales du Laos';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('e3486940-b0e3-52df-bdd4-c11bf912d05b', cat_id, 'country', 'LAO', top, 'Maisons royales du Laos', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'e3486940-b0e3-52df-bdd4-c11bf912d05b';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('88570d33-cf45-5b84-acb5-6a37ea9fb3a4', 'country', 'LAO', 'genealogy', 'Maisons royales du Laos', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f4c058c3-a03b-58ad-ad18-e3a9e3d1711c', 'entry', '88570d33-cf45-5b84-acb5-6a37ea9fb3a4', 'Kham Souk (Luang Prabang)', null, 1840, 1904, 'Roi de Luang Prabang (1895-1904)', 'Maisons royales du Laos', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Laos', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('334d4c71-3bd2-514b-ac52-6dd9b5501fd1', 'entry', '88570d33-cf45-5b84-acb5-6a37ea9fb3a4', 'Sisavang Vong', null, 1885, 1959, 'Roi de Luang Prabang puis du Laos (1904-1959)', 'Maisons royales du Laos', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Laos', 1000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c80238c9-a7cb-542b-b9d7-6010bd7d0fcd', 'entry', '88570d33-cf45-5b84-acb5-6a37ea9fb3a4', 'Sisavang Vatthana', null, 1907, 1978, 'Dernier roi du Laos (1959-1975)', 'Maisons royales du Laos', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Laos', 1000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('62edc692-f889-5820-864d-bb73394460a8', 'entry', '88570d33-cf45-5b84-acb5-6a37ea9fb3a4', 'Kham Souk (Champassak)', null, 1839, 1900, 'Prince de Champassak, père de Ratsadanay', 'Maisons royales du Laos', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Laos - dates tirées de la ligne de son fils Ratsadanay', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('edd9f0ae-cc0f-5c58-a42b-83184dcda64f', 'entry', '88570d33-cf45-5b84-acb5-6a37ea9fb3a4', 'Ratsadanay', null, 1874, 1945, 'Roi de Champassak (1900-1904)', 'Maisons royales du Laos', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Laos', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d489c975-5089-5162-8562-9ddace6feac9', 'entry', '88570d33-cf45-5b84-acb5-6a37ea9fb3a4', 'Boun Oum', null, 1912, 1980, 'Prince de Champassak, renonce à ses droits en 1946', 'Maisons royales du Laos', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Laos', 0, 1920, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('f4c058c3-a03b-58ad-ad18-e3a9e3d1711c', '334d4c71-3bd2-514b-ac52-6dd9b5501fd1', 'parent');
  perform pg_temp.rel('334d4c71-3bd2-514b-ac52-6dd9b5501fd1', 'c80238c9-a7cb-542b-b9d7-6010bd7d0fcd', 'parent');
  perform pg_temp.rel('62edc692-f889-5820-864d-bb73394460a8', 'edd9f0ae-cc0f-5c58-a42b-83184dcda64f', 'parent');
  perform pg_temp.rel('edd9f0ae-cc0f-5c58-a42b-83184dcda64f', 'd489c975-5089-5162-8562-9ddace6feac9', 'parent');
  raise notice 'schema_v136 : % membres ajoutés.', 6;
end $$;
