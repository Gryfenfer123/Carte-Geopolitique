-- arbres_v128.sql — Irlande (Dál gCais / Ua Briain)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Dál gCais / Ua Briain » (Irlande) : 7 personnes autour de Brian Boru. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Pages lues : Brian Boru, Toirdelbach Ua Briain, Muirchertach Ua Briain, liste des grands rois d'Irlande. Cennétig, Murchad et Tadc sont sans dates (aucune page lue pour eux). Donnchad : mort 1064 d'après la liste des grands rois.
-- Autres fils de Brian cités mais non saisis : Conchobar, Flann, Domhnall.
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
  if exists (select 1 from public.genealogy_members where id = '72f31a68-edb0-598a-abdc-34744ac70977') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Dál gCais » (IRL)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IRL' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IRL : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Dál gCais';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('c1904c9b-533e-5217-93d3-bef194b0c307', cat_id, 'country', 'IRL', top, 'Dál gCais', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'c1904c9b-533e-5217-93d3-bef194b0c307';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('4341ad32-233a-5b9b-9df4-ed1c07f26900', 'country', 'IRL', 'genealogy', 'Dál gCais', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('72f31a68-edb0-598a-abdc-34744ac70977', 'entry', '4341ad32-233a-5b9b-9df4-ed1c07f26900', 'Cennétig mac Lorcáin', null, null, null, 'Roi de Thomond, père de Brian Boru', 'Dál gCais', 'Sources : https://en.wikipedia.org/wiki/Brian_Boru', 500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1615f779-7eb3-5416-b881-8e691a55c6cc', 'entry', '4341ad32-233a-5b9b-9df4-ed1c07f26900', 'Brian Boru', null, 941, 1014, 'Grand roi d''Irlande (1002-1014)', 'Dál gCais', 'Sources : https://en.wikipedia.org/wiki/Brian_Boru - naissance c. 941 ; mort 23 avril 1014', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('16a66904-dbed-5d56-90f6-8765db32d4a4', 'entry', '4341ad32-233a-5b9b-9df4-ed1c07f26900', 'Murchad mac Briain', null, null, null, 'Fils aîné de Brian Boru', 'Dál gCais', 'Sources : https://en.wikipedia.org/wiki/Brian_Boru', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ce6db3fd-a30c-526a-bacf-b406836131c9', 'entry', '4341ad32-233a-5b9b-9df4-ed1c07f26900', 'Donnchad mac Briain', null, null, 1064, 'Roi de Munster, fils de Brian Boru', 'Dál gCais', 'Sources : https://en.wikipedia.org/wiki/Brian_Boru - mort 1064 d''après la liste des grands rois d''Irlande', 1000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c7d9906a-8b06-5b9e-9d6f-e3806ad90b27', 'entry', '4341ad32-233a-5b9b-9df4-ed1c07f26900', 'Tadc mac Briain', null, null, null, 'Fils de Brian Boru, père de Toirdelbach', 'Dál gCais', 'Sources : https://en.wikipedia.org/wiki/Brian_Boru', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('26c0d1f7-0553-5134-af2b-a1c03b46914f', 'entry', '4341ad32-233a-5b9b-9df4-ed1c07f26900', 'Toirdelbach Ua Briain', null, 1009, 1086, 'Roi de Munster, grand roi avec opposition', 'Dál gCais', 'Sources : https://en.wikipedia.org/wiki/Toirdelbach_Ua_Briain', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1597a3e6-bf7a-53a4-9e02-3ac184d2a04a', 'entry', '4341ad32-233a-5b9b-9df4-ed1c07f26900', 'Muirchertach Ua Briain', null, 1050, 1119, 'Roi de Munster, grand roi avec opposition', 'Dál gCais', 'Sources : https://en.wikipedia.org/wiki/Muirchertach_Ua_Briain - naissance c. 1050', 500, 3200, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('72f31a68-edb0-598a-abdc-34744ac70977', '1615f779-7eb3-5416-b881-8e691a55c6cc', 'parent');
  perform pg_temp.rel('1615f779-7eb3-5416-b881-8e691a55c6cc', '16a66904-dbed-5d56-90f6-8765db32d4a4', 'parent');
  perform pg_temp.rel('1615f779-7eb3-5416-b881-8e691a55c6cc', 'ce6db3fd-a30c-526a-bacf-b406836131c9', 'parent');
  perform pg_temp.rel('1615f779-7eb3-5416-b881-8e691a55c6cc', 'c7d9906a-8b06-5b9e-9d6f-e3806ad90b27', 'parent');
  perform pg_temp.rel('c7d9906a-8b06-5b9e-9d6f-e3806ad90b27', '26c0d1f7-0553-5134-af2b-a1c03b46914f', 'parent');
  perform pg_temp.rel('26c0d1f7-0553-5134-af2b-a1c03b46914f', '1597a3e6-bf7a-53a4-9e02-3ac184d2a04a', 'parent');
  raise notice 'schema_v128 : % membres ajoutés.', 7;
end $$;
