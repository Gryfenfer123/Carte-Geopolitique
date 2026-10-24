-- arbres_v127.sql — Croatie (Trpimirović)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Trpimirović » (Croatie) : 16 ducs et rois croates (845-1091). Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Aucune date de naissance dans les pages ; seules les années de règne et deux morts (Zdeslav 879, Étienne II 1091) sont données. Les fiches sont donc sans dates de vie : les règnes sont dans le titre. La page précise que la chronologie des IXe-Xe siècles est contestée.
-- Liens parent-enfant retenus seulement quand les pages le disent. Liens « famille » (non parent-enfant) : Tomislav (« peut-être fils de Muncimir »), Trpimir II (« frère cadet ou fils de Tomislav »), Demetrius Zvonimir (cousin de Pierre Krešimir IV), Étienne II (neveu de Pierre Krešimir IV). Domagoj (autre dynastie) non saisi.
-- Michel Krešimir II et Miroslav sont frères ; les deux pages donnent aussi Gojslav et Krešimir III comme frères de Svetoslav Suronja, fils d'Étienne Držislav.
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
  if exists (select 1 from public.genealogy_members where id = 'b059c6e2-c888-52ad-a7ee-e7b02f54dba1') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Trpimirović » (HRV)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'HRV' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour HRV : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Trpimirović';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('e5885f71-bd87-57c6-9269-6b275fa4202d', cat_id, 'country', 'HRV', top, 'Trpimirović', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'e5885f71-bd87-57c6-9269-6b275fa4202d';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('4d86c40b-4a77-553d-9054-1d17f9f0a878', 'country', 'HRV', 'genealogy', 'Trpimirović', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b059c6e2-c888-52ad-a7ee-e7b02f54dba1', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Trpimir Ier', null, null, null, 'Duc de Croatie, fondateur de la dynastie (c. 845-864)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 2250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b6272226-e13c-5750-bf92-3d3933e091b5', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Zdeslav', null, null, 879, 'Duc de Croatie (864 ; 878-879)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia - mort en mai 879 (tué par Branimir)', 2500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3f6e82d1-f350-5841-9b84-044647bedb79', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Muncimir', null, null, null, 'Duc de Croatie (892-910)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 2000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c0b0d36a-fb30-5f34-9977-a371c58ad2ef', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Tomislav', null, null, null, 'Premier roi de Croatie (925-928)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 4500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ca51aa82-2733-5d93-89c5-d96c50154402', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Trpimir II', null, null, null, 'Roi de Croatie (928-935)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 3500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8581d7d8-2ba7-5204-96ad-5749705cbca1', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Krešimir Ier', null, null, null, 'Roi de Croatie (935-945)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 3500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f2da9349-8091-5e99-88a9-6a8a1524c480', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Miroslav', null, null, null, 'Roi de Croatie (945-949)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 3500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1f3eb346-e51f-579f-8d65-4c4669f2fd0e', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Michel Krešimir II', null, null, null, 'Roi de Croatie (949-969)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('173d7fbf-1620-509e-bf5b-6db6ccee3b83', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Étienne Držislav', null, null, null, 'Roi de Croatie (969-997)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia - fils de Michel Krešimir II selon la liste des ducs et rois', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4847c410-5c6e-5f3f-afff-c62d0e5634cb', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Svetoslav Suronja', null, null, null, 'Roi de Croatie (997-1000)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 1000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5edae18a-a08c-5518-a854-355ef2244e77', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Gojslav', null, null, null, 'Roi de Croatie (1000-1020)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d4c21f52-6829-5de1-b868-17b9c6a4c946', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Krešimir III', null, null, null, 'Roi de Croatie (1000-1030)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9df7815f-746d-5d47-bdbf-6de944213d97', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Étienne Ier', null, null, null, 'Roi de Croatie (1030-1058)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5a43add2-6bd5-5935-a2a8-d934efd3b57d', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Pierre Krešimir IV', null, null, null, 'Roi de Croatie (1058-1074)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f29d0341-7dcc-56cd-b860-ee8c87b71803', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Demetrius Zvonimir', null, null, null, 'Roi de Croatie (1075-1089)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 5500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ea8998c6-288d-5f92-84fb-3cf671660ec8', 'entry', '4d86c40b-4a77-553d-9054-1d17f9f0a878', 'Étienne II', null, null, 1091, 'Dernier roi de la dynastie (1089-1091)', 'Trpimirović', 'Sources : https://en.wikipedia.org/wiki/List_of_dukes_and_kings_of_Croatia', 6500, 0, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('b059c6e2-c888-52ad-a7ee-e7b02f54dba1', 'b6272226-e13c-5750-bf92-3d3933e091b5', 'parent');
  perform pg_temp.rel('b059c6e2-c888-52ad-a7ee-e7b02f54dba1', '3f6e82d1-f350-5841-9b84-044647bedb79', 'parent');
  perform pg_temp.rel('8581d7d8-2ba7-5204-96ad-5749705cbca1', 'f2da9349-8091-5e99-88a9-6a8a1524c480', 'parent');
  perform pg_temp.rel('ca51aa82-2733-5d93-89c5-d96c50154402', '8581d7d8-2ba7-5204-96ad-5749705cbca1', 'parent');
  perform pg_temp.rel('1f3eb346-e51f-579f-8d65-4c4669f2fd0e', '173d7fbf-1620-509e-bf5b-6db6ccee3b83', 'parent');
  perform pg_temp.rel('173d7fbf-1620-509e-bf5b-6db6ccee3b83', '4847c410-5c6e-5f3f-afff-c62d0e5634cb', 'parent');
  perform pg_temp.rel('173d7fbf-1620-509e-bf5b-6db6ccee3b83', '5edae18a-a08c-5518-a854-355ef2244e77', 'parent');
  perform pg_temp.rel('173d7fbf-1620-509e-bf5b-6db6ccee3b83', 'd4c21f52-6829-5de1-b868-17b9c6a4c946', 'parent');
  perform pg_temp.rel('d4c21f52-6829-5de1-b868-17b9c6a4c946', '9df7815f-746d-5d47-bdbf-6de944213d97', 'parent');
  perform pg_temp.rel('9df7815f-746d-5d47-bdbf-6de944213d97', '5a43add2-6bd5-5935-a2a8-d934efd3b57d', 'parent');
  perform pg_temp.rel('f2da9349-8091-5e99-88a9-6a8a1524c480', '1f3eb346-e51f-579f-8d65-4c4669f2fd0e', 'family');
  perform pg_temp.rel('3f6e82d1-f350-5841-9b84-044647bedb79', 'c0b0d36a-fb30-5f34-9977-a371c58ad2ef', 'family');
  perform pg_temp.rel('c0b0d36a-fb30-5f34-9977-a371c58ad2ef', 'ca51aa82-2733-5d93-89c5-d96c50154402', 'family');
  perform pg_temp.rel('5a43add2-6bd5-5935-a2a8-d934efd3b57d', 'f29d0341-7dcc-56cd-b860-ee8c87b71803', 'family');
  perform pg_temp.rel('5a43add2-6bd5-5935-a2a8-d934efd3b57d', 'ea8998c6-288d-5f92-84fb-3cf671660ec8', 'family');
  raise notice 'schema_v127 : % membres ajoutés.', 16;
end $$;
