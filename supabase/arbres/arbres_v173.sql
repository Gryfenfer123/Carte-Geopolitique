-- arbres_v173.sql — Birmanie (Toungoo)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Toungoo » (Birmanie). Source : page Wikipédia « Toungoo dynasty » (anglais).
-- Seuls deux liens père-fils sont indiqués par la page (Mingyi Nyo → Tabinshwehti ; Bayinnaung → Nanda Bayin). Anaukpetlun est dit petit-fils de Bayinnaung (lien « famille »). Les dates de naissance/mort de la page sont notées comme approximatives et ne sont pas saisies. Les autres rois (Nyaungyan Min, Thalun, Mahadhammaraza Dipadi) ne sont pas reliés : non ajoutés.
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
  if exists (select 1 from public.genealogy_members where id = '887f4cee-5031-5167-9661-077492ae7fa4') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Toungoo » (MMR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'MMR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour MMR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Toungoo';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('722611aa-26d4-5742-8db9-2484041f4cd3', cat_id, 'country', 'MMR', top, 'Toungoo', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '722611aa-26d4-5742-8db9-2484041f4cd3';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('c09d4a20-409b-53d9-9b94-5a7981ba4d3f', 'country', 'MMR', 'genealogy', 'Toungoo', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('887f4cee-5031-5167-9661-077492ae7fa4', 'entry', 'c09d4a20-409b-53d9-9b94-5a7981ba4d3f', 'Mingyi Nyo', null, null, null, 'Roi de Toungoo (1485-1530)', 'Toungoo', 'Sources : https://en.wikipedia.org/wiki/Toungoo_dynasty', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('76eb0755-f50d-5ff0-acc3-591ba99974e8', 'entry', 'c09d4a20-409b-53d9-9b94-5a7981ba4d3f', 'Tabinshwehti', null, null, null, 'Roi (1530-1550)', 'Toungoo', 'Sources : https://en.wikipedia.org/wiki/Toungoo_dynasty', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1344c854-280e-5f80-a326-72d63ebdf8ed', 'entry', 'c09d4a20-409b-53d9-9b94-5a7981ba4d3f', 'Bayinnaung', null, null, null, 'Roi (1550-1581)', 'Toungoo', 'Sources : https://en.wikipedia.org/wiki/Toungoo_dynasty - beau-frère de Tabinshwehti', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('dcec3d47-4ab4-5b50-bcec-1d704b9cbc16', 'entry', 'c09d4a20-409b-53d9-9b94-5a7981ba4d3f', 'Nanda Bayin', null, null, null, 'Roi (1581-1599)', 'Toungoo', 'Sources : https://en.wikipedia.org/wiki/Toungoo_dynasty', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('626ffae8-df8f-585b-a3c7-f8ca226dcabc', 'entry', 'c09d4a20-409b-53d9-9b94-5a7981ba4d3f', 'Anaukpetlun', null, null, null, 'Roi (1605-1628)', 'Toungoo', 'Sources : https://en.wikipedia.org/wiki/Toungoo_dynasty - petit-fils de Bayinnaung', 2000, 0, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('887f4cee-5031-5167-9661-077492ae7fa4', '76eb0755-f50d-5ff0-acc3-591ba99974e8', 'parent');
  perform pg_temp.rel('1344c854-280e-5f80-a326-72d63ebdf8ed', 'dcec3d47-4ab4-5b50-bcec-1d704b9cbc16', 'parent');
  perform pg_temp.rel('1344c854-280e-5f80-a326-72d63ebdf8ed', '626ffae8-df8f-585b-a3c7-f8ca226dcabc', 'family');
  raise notice 'schema_v173 : % membres ajoutés.', 5;
end $$;
