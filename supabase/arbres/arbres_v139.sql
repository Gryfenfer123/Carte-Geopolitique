-- arbres_v139.sql — Indonésie (sultans de Yogyakarta)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Sultans de Yogyakarta » (Indonésie) : 10 personnes, de Hamengkubuwono I à X. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Toutes les données viennent de la page « Hamengkubuwono » (liste). Le père de Hamengkubuwono I (Amangkurat IV) n'est pas dans l'arbre. Hamengkubuwono VI : père non indiqué par la page, seulement « frère de Hamengkubuwono V » : lien « famille » (pas de lien parent). La page donne la fin du règne de HB VII en janvier 1921 mais sa mort en décembre 1921 : à vérifier.
-- Le sultan actuel est vivant.
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
  if exists (select 1 from public.genealogy_members where id = 'c5dede1d-c7a9-52a7-a9c5-37fa10489cef') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Sultans de Yogyakarta » (IDN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IDN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IDN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Sultans de Yogyakarta';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('a22948cd-483e-5d4a-af15-8f4ade075736', cat_id, 'country', 'IDN', top, 'Sultans de Yogyakarta', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'a22948cd-483e-5d4a-af15-8f4ade075736';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('a568d81f-0f27-575b-8c5c-a7e3b5543120', 'country', 'IDN', 'genealogy', 'Sultans de Yogyakarta', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c5dede1d-c7a9-52a7-a9c5-37fa10489cef', 'entry', 'a568d81f-0f27-575b-8c5c-a7e3b5543120', 'Hamengkubuwono I', null, 1717, 1792, 'Premier sultan de Yogyakarta (1755-1792)', 'Sultans de Yogyakarta', 'Sources : https://en.wikipedia.org/wiki/Hamengkubuwono', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2b8327a6-d1e8-55c7-b728-2df90aa034b9', 'entry', 'a568d81f-0f27-575b-8c5c-a7e3b5543120', 'Hamengkubuwono II', null, 1750, 1828, 'Sultan de Yogyakarta (1792-1810 ; 1811-1812 ; 1826-1828)', 'Sultans de Yogyakarta', 'Sources : https://en.wikipedia.org/wiki/Hamengkubuwono', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2aed3657-1bc2-5b3a-9643-811bb7a9ab5a', 'entry', 'a568d81f-0f27-575b-8c5c-a7e3b5543120', 'Hamengkubuwono III', null, 1769, 1814, 'Sultan de Yogyakarta (1810-1811 ; 1812-1814)', 'Sultans de Yogyakarta', 'Sources : https://en.wikipedia.org/wiki/Hamengkubuwono', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cd42b052-c717-5f89-be2f-9a35aa926a9f', 'entry', 'a568d81f-0f27-575b-8c5c-a7e3b5543120', 'Hamengkubuwono IV', null, 1804, 1823, 'Sultan de Yogyakarta (1814-1823)', 'Sultans de Yogyakarta', 'Sources : https://en.wikipedia.org/wiki/Hamengkubuwono', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('35bb553a-f2f5-5812-920a-c5f1dafb2fd4', 'entry', 'a568d81f-0f27-575b-8c5c-a7e3b5543120', 'Hamengkubuwono V', null, 1820, 1855, 'Sultan de Yogyakarta (1823-1826 ; 1828-1855)', 'Sultans de Yogyakarta', 'Sources : https://en.wikipedia.org/wiki/Hamengkubuwono', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('410873ac-3198-5368-a192-31a6834eecf6', 'entry', 'a568d81f-0f27-575b-8c5c-a7e3b5543120', 'Hamengkubuwono VI', null, 1821, 1877, 'Sultan de Yogyakarta (1855-1877)', 'Sultans de Yogyakarta', 'Sources : https://en.wikipedia.org/wiki/Hamengkubuwono - père non indiqué : frère de Hamengkubuwono V', 1000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c8f009e7-968e-5f5c-814a-8c98feff4bb9', 'entry', 'a568d81f-0f27-575b-8c5c-a7e3b5543120', 'Hamengkubuwono VII', null, 1839, 1921, 'Sultan de Yogyakarta (1877-1921)', 'Sultans de Yogyakarta', 'Sources : https://en.wikipedia.org/wiki/Hamengkubuwono - fin de règne janvier 1921, mort décembre 1921 selon la page', 1000, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5acef504-47f4-5a93-8714-865da51011d4', 'entry', 'a568d81f-0f27-575b-8c5c-a7e3b5543120', 'Hamengkubuwono VIII', null, 1880, 1939, 'Sultan de Yogyakarta (1921-1939)', 'Sultans de Yogyakarta', 'Sources : https://en.wikipedia.org/wiki/Hamengkubuwono', 1000, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a0463eb2-f02e-54dd-b1fe-65e369f2943f', 'entry', 'a568d81f-0f27-575b-8c5c-a7e3b5543120', 'Hamengkubuwono IX', null, 1912, 1988, 'Sultan de Yogyakarta (1940-1988)', 'Sultans de Yogyakarta', 'Sources : https://en.wikipedia.org/wiki/Hamengkubuwono', 1000, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2c9fee96-a107-55c0-adf8-d7dc5ac67a0c', 'entry', 'a568d81f-0f27-575b-8c5c-a7e3b5543120', 'Hamengkubuwono X', null, 1946, null, 'Sultan de Yogyakarta (depuis 1989)', 'Sultans de Yogyakarta', 'Sources : https://en.wikipedia.org/wiki/Hamengkubuwono', 1000, 4480, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('c5dede1d-c7a9-52a7-a9c5-37fa10489cef', '2b8327a6-d1e8-55c7-b728-2df90aa034b9', 'parent');
  perform pg_temp.rel('2b8327a6-d1e8-55c7-b728-2df90aa034b9', '2aed3657-1bc2-5b3a-9643-811bb7a9ab5a', 'parent');
  perform pg_temp.rel('2aed3657-1bc2-5b3a-9643-811bb7a9ab5a', 'cd42b052-c717-5f89-be2f-9a35aa926a9f', 'parent');
  perform pg_temp.rel('cd42b052-c717-5f89-be2f-9a35aa926a9f', '35bb553a-f2f5-5812-920a-c5f1dafb2fd4', 'parent');
  perform pg_temp.rel('410873ac-3198-5368-a192-31a6834eecf6', 'c8f009e7-968e-5f5c-814a-8c98feff4bb9', 'parent');
  perform pg_temp.rel('c8f009e7-968e-5f5c-814a-8c98feff4bb9', '5acef504-47f4-5a93-8714-865da51011d4', 'parent');
  perform pg_temp.rel('5acef504-47f4-5a93-8714-865da51011d4', 'a0463eb2-f02e-54dd-b1fe-65e369f2943f', 'parent');
  perform pg_temp.rel('a0463eb2-f02e-54dd-b1fe-65e369f2943f', '2c9fee96-a107-55c0-adf8-d7dc5ac67a0c', 'parent');
  perform pg_temp.rel('35bb553a-f2f5-5812-920a-c5f1dafb2fd4', '410873ac-3198-5368-a192-31a6834eecf6', 'family');
  raise notice 'schema_v139 : % membres ajoutés.', 10;
end $$;
