-- arbres_v140.sql — Eswatini (Dlamini)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Rois d'Eswatini » : 4 personnes, de Mbandzeni à Mswati III. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Pages lues : Ngwane V/Bhunu (fils de Mbandzeni, père de Sobhuza II), liste des monarques d'Eswatini (Sobhuza II 1899-1982 fils de Ngwane V ; Mswati III né en 1968, fils de Sobhuza II). Les rois antérieurs ne sont pas liés : la liste ne donne ni dates ni pères. Naissance de Mbandzeni inconnue.
-- Bhunu règne 1895-1899 selon la liste (mère régente Labotsibeni).
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
  if exists (select 1 from public.genealogy_members where id = 'c493e418-6569-58ff-859b-8c616b25797e') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Rois d'Eswatini » (SWZ)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'SWZ' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour SWZ : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Rois d''Eswatini';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('2b97781c-5f83-5c12-ae6a-facb5c718fc1', cat_id, 'country', 'SWZ', top, 'Rois d''Eswatini', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '2b97781c-5f83-5c12-ae6a-facb5c718fc1';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('219a47c8-99cd-52a2-8ecf-9b3f0e8dd7b7', 'country', 'SWZ', 'genealogy', 'Rois d''Eswatini', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c493e418-6569-58ff-859b-8c616b25797e', 'entry', '219a47c8-99cd-52a2-8ecf-9b3f0e8dd7b7', 'Mbandzeni', null, null, null, 'Roi d''Eswatini (1875-1889)', 'Rois d''Eswatini', 'Sources : https://en.wikipedia.org/wiki/Ngwane_V - père de Bhunu selon la page de Ngwane V ; dates de règne : liste des monarques', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('dccb04bd-acaf-5b9a-a68f-fb9003f63bbb', 'entry', '219a47c8-99cd-52a2-8ecf-9b3f0e8dd7b7', 'Bhunu (Ngwane V)', null, 1876, 1899, 'Roi d''Eswatini (1895-1899)', 'Rois d''Eswatini', 'Sources : https://en.wikipedia.org/wiki/Ngwane_V', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e3ef42f6-6c4d-59ee-b12c-a691cccac15e', 'entry', '219a47c8-99cd-52a2-8ecf-9b3f0e8dd7b7', 'Sobhuza II', null, 1899, 1982, 'Roi d''Eswatini (1921-1982)', 'Rois d''Eswatini', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Eswatini - règne effectif depuis 1921, roi à partir de 1968', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7fb113d8-4984-5bbd-ab4c-28dc414a8fcb', 'entry', '219a47c8-99cd-52a2-8ecf-9b3f0e8dd7b7', 'Mswati III', null, 1968, null, 'Roi d''Eswatini (depuis 1986)', 'Rois d''Eswatini', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Eswatini', 0, 1920, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('c493e418-6569-58ff-859b-8c616b25797e', 'dccb04bd-acaf-5b9a-a68f-fb9003f63bbb', 'parent');
  perform pg_temp.rel('dccb04bd-acaf-5b9a-a68f-fb9003f63bbb', 'e3ef42f6-6c4d-59ee-b12c-a691cccac15e', 'parent');
  perform pg_temp.rel('e3ef42f6-6c4d-59ee-b12c-a691cccac15e', '7fb113d8-4984-5bbd-ab4c-28dc414a8fcb', 'parent');
  raise notice 'schema_v140 : % membres ajoutés.', 4;
end $$;
