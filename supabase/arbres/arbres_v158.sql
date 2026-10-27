-- arbres_v158.sql — Inde (Gupta)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Gupta » (Inde). Chaque fiche porte l'adresse de la page Wikipédia (anglais) ; sources aussi dans docs/sources/arbres.md.
-- Pages « Gupta Empire » et « List of Gupta emperors » : aucune date de naissance ou de mort n'est donnée, seulement des dates de règne. Ramagupta (« frère de Chandragupta » selon la page, sans autre précision), Purugupta (« frère » de Skandagupta), Budhagupta et Narasimhagupta ne sont pas rattachés à un père par la page : liens non saisis ou notés.
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
  if exists (select 1 from public.genealogy_members where id = '8fbdfc87-46fa-570e-8afd-f850b9f41209') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Gupta » (IND)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IND' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IND : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Gupta';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('bcefa6f9-5b28-5a0d-bda5-c2877a905458', cat_id, 'country', 'IND', top, 'Gupta', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'bcefa6f9-5b28-5a0d-bda5-c2877a905458';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'country', 'IND', 'genealogy', 'Gupta', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8fbdfc87-46fa-570e-8afd-f850b9f41209', 'entry', 'eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'Sri Gupta', null, null, null, 'Fondateur de la dynastie (fin IIIe s.)', 'Gupta', 'Sources : https://en.wikipedia.org/wiki/Srigupta', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fac4d891-2507-50a7-83c2-56db251e04d0', 'entry', 'eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'Ghatotkacha', null, null, null, 'Roi gupta (v. 280/290-319)', 'Gupta', 'Sources : https://en.wikipedia.org/wiki/List_of_Gupta_emperors', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('dee68bad-eae5-5776-b828-3fc6ce5b4253', 'entry', 'eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'Chandragupta Ier', null, null, null, 'Empereur gupta (319-335)', 'Gupta', 'Sources : https://en.wikipedia.org/wiki/Chandragupta_I', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('856539c2-8643-5d0a-b2fd-d77b11589576', 'entry', 'eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'Samudragupta', null, null, null, 'Empereur gupta (335-375)', 'Gupta', 'Sources : https://en.wikipedia.org/wiki/Samudragupta', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('43643782-500a-5517-b985-44c575f01876', 'entry', 'eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'Chandragupta II', null, null, null, 'Empereur gupta (375-415)', 'Gupta', 'Sources : https://en.wikipedia.org/wiki/Candra_Gupta_II', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('aca8c433-9205-57c5-8503-087215bc6a51', 'entry', 'eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'Kumaragupta Ier', null, null, null, 'Empereur gupta (415-455)', 'Gupta', 'Sources : https://en.wikipedia.org/wiki/Gupta_Empire', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cf1465c8-1760-5105-a702-e91784317fa1', 'entry', 'eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'Skandagupta', null, null, null, 'Empereur gupta (455-467)', 'Gupta', 'Sources : https://en.wikipedia.org/wiki/Gupta_Empire', 0, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7610e77a-13e0-50bf-97e4-18f9c6887bb7', 'entry', 'eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'Purugupta', null, null, null, 'Empereur gupta (467-473)', 'Gupta', 'Sources : https://en.wikipedia.org/wiki/Gupta_Empire - présenté comme « frère » de Skandagupta (même ascendance), père non indiqué', 2000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b70ae846-c3ab-593b-a27b-9d9c5a44b5b7', 'entry', 'eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'Budhagupta', null, null, null, 'Empereur gupta (476-495)', 'Gupta', 'Sources : https://en.wikipedia.org/wiki/Gupta_Empire - père non indiqué', 3000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('56c6ef80-7584-5121-89bd-3dd522057a7f', 'entry', 'eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'Narasimhagupta Baladitya', null, null, null, 'Empereur gupta (495-530)', 'Gupta', 'Sources : https://en.wikipedia.org/wiki/Gupta_Empire - père non indiqué', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1e2dc86e-cb05-5e9c-9ac6-a683b449ad66', 'entry', 'eeb991dc-daab-53f5-a1b1-70dfd1886c59', 'Vajra', null, null, null, 'Fils de Narasimhagupta', 'Gupta', 'Sources : https://en.wikipedia.org/wiki/Gupta_Empire', 1000, 640, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('8fbdfc87-46fa-570e-8afd-f850b9f41209', 'fac4d891-2507-50a7-83c2-56db251e04d0', 'parent');
  perform pg_temp.rel('fac4d891-2507-50a7-83c2-56db251e04d0', 'dee68bad-eae5-5776-b828-3fc6ce5b4253', 'parent');
  perform pg_temp.rel('dee68bad-eae5-5776-b828-3fc6ce5b4253', '856539c2-8643-5d0a-b2fd-d77b11589576', 'parent');
  perform pg_temp.rel('856539c2-8643-5d0a-b2fd-d77b11589576', '43643782-500a-5517-b985-44c575f01876', 'parent');
  perform pg_temp.rel('43643782-500a-5517-b985-44c575f01876', 'aca8c433-9205-57c5-8503-087215bc6a51', 'parent');
  perform pg_temp.rel('aca8c433-9205-57c5-8503-087215bc6a51', 'cf1465c8-1760-5105-a702-e91784317fa1', 'parent');
  perform pg_temp.rel('56c6ef80-7584-5121-89bd-3dd522057a7f', '1e2dc86e-cb05-5e9c-9ac6-a683b449ad66', 'parent');
  perform pg_temp.rel('cf1465c8-1760-5105-a702-e91784317fa1', '7610e77a-13e0-50bf-97e4-18f9c6887bb7', 'family');
  raise notice 'schema_v158 : % membres ajoutés.', 11;
end $$;
