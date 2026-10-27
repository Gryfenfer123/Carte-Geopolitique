-- arbres_v161.sql — Cameroun (Bamoun)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Bamoun » (Cameroun). Sources : pages Wikipédia « List of rulers of the Bamum » et « Ibrahim Njoya », notées dans chaque fiche et dans docs/sources/arbres.md.
-- Seules les filiations écrites sur les pages sont saisies : Njoya fils de Nsangou ; Seidou Njimoluh Njoya fils de Njoya ; Ibrahim Mbombo Njoya petit-fils de Njoya (père non vérifié ici : lien « famille »). Les rois plus anciens (Nchare Yen…) sont dans la liste sans parenté : non ajoutés. Njoya : naissance c. 1860, mort c. 1933 ; âge au décès incohérent entre infobox et texte.
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
  if exists (select 1 from public.genealogy_members where id = '58d4a286-87e7-5b40-96b3-f3c3e6f01521') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Bamoun » (CMR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CMR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CMR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Bamoun';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('3fad2990-488a-529b-a233-1461c1f52cc6', cat_id, 'country', 'CMR', top, 'Bamoun', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '3fad2990-488a-529b-a233-1461c1f52cc6';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('c6825f0e-bdc2-5aa9-b397-8cf570c68dcb', 'country', 'CMR', 'genealogy', 'Bamoun', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('58d4a286-87e7-5b40-96b3-f3c3e6f01521', 'entry', 'c6825f0e-bdc2-5aa9-b397-8cf570c68dcb', 'Nsangou', null, null, null, 'Mfon des Bamoun (1865-1884)', 'Bamoun', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_the_Bamum - père de Njoya ; liste : règne 1865-1884 (date de mort non indiquée)', 0, 16000, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6d9c1612-06d3-54d5-8184-34c1ce0987c6', 'entry', 'c6825f0e-bdc2-5aa9-b397-8cf570c68dcb', 'Ibrahim Njoya', null, 1860, 1933, 'Mfon des Bamoun (1889-1931/33)', 'Bamoun', 'Sources : https://en.wikipedia.org/wiki/Ibrahim_Njoya - naissance et mort « c. »', 0, 16640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2fe75e77-1a32-5e65-9f00-cd1fdb315733', 'entry', 'c6825f0e-bdc2-5aa9-b397-8cf570c68dcb', 'Seidou Njimoluh Njoya', null, null, null, 'Mfon des Bamoun (1933-1992)', 'Bamoun', 'Sources : https://en.wikipedia.org/wiki/Seidou_Njimoluh_Njoya - fils de Njoya', 0, 17280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('de081e73-1497-5b9d-a948-3d0666027332', 'entry', 'c6825f0e-bdc2-5aa9-b397-8cf570c68dcb', 'Ibrahim Mbombo Njoya', null, null, null, 'Mfon des Bamoun (1992-2021)', 'Bamoun', 'Sources : https://en.wikipedia.org/wiki/Ibrahim_Mbombo_Njoya - petit-fils de Njoya', 1000, 0, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('58d4a286-87e7-5b40-96b3-f3c3e6f01521', '6d9c1612-06d3-54d5-8184-34c1ce0987c6', 'parent');
  perform pg_temp.rel('6d9c1612-06d3-54d5-8184-34c1ce0987c6', '2fe75e77-1a32-5e65-9f00-cd1fdb315733', 'parent');
  perform pg_temp.rel('6d9c1612-06d3-54d5-8184-34c1ce0987c6', 'de081e73-1497-5b9d-a948-3d0666027332', 'family');
  raise notice 'schema_v161 : % membres ajoutés.', 4;
end $$;
