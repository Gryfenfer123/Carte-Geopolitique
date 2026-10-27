-- arbres_v145.sql — Ghana (Asante)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Asantehene » (Ghana) : 3 personnes seulement. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- La page « List of rulers of Asante » ne donne ni dates de naissance/mort ni parents, sauf deux liens de parenté : Opoku Ware I est « petit-neveu et successeur désigné » de son prédécesseur (Osei Tutu I) et Kusi Oboadum est l'« oncle » de son prédécesseur (Opoku Ware I). Les autres Asantehene ne sont pas ajoutés (aucun lien sourcé). À compléter avec une meilleure source.
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
  if exists (select 1 from public.genealogy_members where id = 'fbaedbfe-73cf-590c-b7e1-0621bc007468') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Asantehene » (GHA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'GHA' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour GHA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Asantehene';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('9e445b8d-f22d-51d5-8154-bcd76c2a87cf', cat_id, 'country', 'GHA', top, 'Asantehene', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '9e445b8d-f22d-51d5-8154-bcd76c2a87cf';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('dcf7bad2-aee3-5932-9b8d-6acfc0a8e832', 'country', 'GHA', 'genealogy', 'Asantehene', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fbaedbfe-73cf-590c-b7e1-0621bc007468', 'entry', 'dcf7bad2-aee3-5932-9b8d-6acfc0a8e832', 'Osei Tutu I', null, null, null, 'Asantehene (1701-vers 1717)', 'Asantehene', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Asante - dates de naissance et de mort non données', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b987a523-d74a-56fb-97df-794521d545dc', 'entry', 'dcf7bad2-aee3-5932-9b8d-6acfc0a8e832', 'Opoku Ware I', null, null, null, 'Asantehene (1720-1750)', 'Asantehene', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Asante - petit-neveu et successeur désigné de son prédécesseur (Osei Tutu I)', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bbea3b88-1bdb-5aa1-b843-bb3255ed0213', 'entry', 'dcf7bad2-aee3-5932-9b8d-6acfc0a8e832', 'Kusi Oboadum', null, null, null, 'Asantehene (1750-1764)', 'Asantehene', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Asante - oncle de son prédécesseur (Opoku Ware I) ; forcé d''abdiquer', 2000, 0, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('fbaedbfe-73cf-590c-b7e1-0621bc007468', 'b987a523-d74a-56fb-97df-794521d545dc', 'family');
  perform pg_temp.rel('b987a523-d74a-56fb-97df-794521d545dc', 'bbea3b88-1bdb-5aa1-b843-bb3255ed0213', 'family');
  raise notice 'schema_v145 : % membres ajoutés.', 3;
end $$;
