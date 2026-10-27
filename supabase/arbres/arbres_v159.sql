-- arbres_v159.sql — Inde (Maurya)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Maurya » (Inde). Sources : pages Wikipédia (anglais) notées dans chaque fiche et dans docs/sources/arbres.md.
-- Aucune date de naissance/mort n'est donnée par les pages. Dasharatha est décrit comme petit-fils d'Ashoka sans nom de père sur la page : relié à Ashoka par un lien « famille ». Samprati est « fils de Kunala » (fils d'Ashoka, non ajouté) et petit-fils d'Ashoka : lien « famille ». Les dates de règne d'Ashoka varient selon les passages.
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
  if exists (select 1 from public.genealogy_members where id = '4437c522-3999-50ae-a973-2dc94bb611b5') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Maurya » (IND)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IND' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IND : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Maurya';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('284c88d2-f955-5b64-9dca-a382fd2842f2', cat_id, 'country', 'IND', top, 'Maurya', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '284c88d2-f955-5b64-9dca-a382fd2842f2';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('86dba272-7600-5228-98ea-4b4bb143ddda', 'country', 'IND', 'genealogy', 'Maurya', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4437c522-3999-50ae-a973-2dc94bb611b5', 'entry', '86dba272-7600-5228-98ea-4b4bb143ddda', 'Chandragupta Maurya', null, null, null, 'Fondateur de l''empire maurya (v. 321-298 av. J.-C.)', 'Maurya', 'Sources : https://en.wikipedia.org/wiki/Chandragupta_Maurya', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a3309e34-f11f-52f7-a744-956912be5c96', 'entry', '86dba272-7600-5228-98ea-4b4bb143ddda', 'Bindusara', null, null, null, 'Empereur maurya (v. 298-272 av. J.-C.)', 'Maurya', 'Sources : https://en.wikipedia.org/wiki/Bindusara', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('50d1446c-12ae-5c09-be29-4c9febc8a5cb', 'entry', '86dba272-7600-5228-98ea-4b4bb143ddda', 'Ashoka', null, null, null, 'Empereur maurya (268-232 av. J.-C.)', 'Maurya', 'Sources : https://en.wikipedia.org/wiki/Ashoka_Maurya_The_Great', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('42de244f-8114-5a54-9c67-200e875f0db9', 'entry', '86dba272-7600-5228-98ea-4b4bb143ddda', 'Dasharatha Maurya', null, null, null, 'Empereur maurya (232-224 av. J.-C.)', 'Maurya', 'Sources : https://en.wikipedia.org/wiki/Dasharatha_Maurya - petit-fils d''Ashoka', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('243e12da-3c2e-5f57-9d76-9b922133ecb2', 'entry', '86dba272-7600-5228-98ea-4b4bb143ddda', 'Samprati', null, null, null, 'Empereur maurya (224-215 av. J.-C.)', 'Maurya', 'Sources : https://en.wikipedia.org/wiki/Maurya_Empire - fils de Kunala (fils d''Ashoka), petit-fils d''Ashoka', 2000, 0, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('4437c522-3999-50ae-a973-2dc94bb611b5', 'a3309e34-f11f-52f7-a744-956912be5c96', 'parent');
  perform pg_temp.rel('a3309e34-f11f-52f7-a744-956912be5c96', '50d1446c-12ae-5c09-be29-4c9febc8a5cb', 'parent');
  perform pg_temp.rel('50d1446c-12ae-5c09-be29-4c9febc8a5cb', '42de244f-8114-5a54-9c67-200e875f0db9', 'family');
  perform pg_temp.rel('50d1446c-12ae-5c09-be29-4c9febc8a5cb', '243e12da-3c2e-5f57-9d76-9b922133ecb2', 'family');
  raise notice 'schema_v159 : % membres ajoutés.', 5;
end $$;
