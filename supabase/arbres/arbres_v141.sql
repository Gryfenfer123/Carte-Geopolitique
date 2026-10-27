-- arbres_v141.sql — Tonga (Tupou)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Maison Tupou » (Tonga) : 5 personnes, de George Tupou II à Tupou VI. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Page lue : liste des monarques de Tonga. George Tupou I (1797-1893) est écarté : la page n'indique pas son lien avec Tupou II (père de Tupou II non indiqué). Tupou IV : « fils de Sālote Tupou III » (mère) selon la page ; le père n'est pas donné.
-- Tupou VI : vivant.
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
  if exists (select 1 from public.genealogy_members where id = 'dbfb4757-3319-5ded-b604-ba550fbceb08') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Maison Tupou » (TON)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'TON' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour TON : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Maison Tupou';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('3a194bb1-7324-5d3a-9a39-2c4dd0eaca0a', cat_id, 'country', 'TON', top, 'Maison Tupou', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '3a194bb1-7324-5d3a-9a39-2c4dd0eaca0a';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('f35ca9bd-6664-5c90-9bc8-652d9449ea76', 'country', 'TON', 'genealogy', 'Maison Tupou', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('dbfb4757-3319-5ded-b604-ba550fbceb08', 'entry', 'f35ca9bd-6664-5c90-9bc8-652d9449ea76', 'George Tupou II', null, 1874, 1918, 'Roi de Tonga (1893-1918)', 'Maison Tupou', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Tonga', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('021a1f46-51d6-5736-962f-8411fb1a0109', 'entry', 'f35ca9bd-6664-5c90-9bc8-652d9449ea76', 'Sālote Tupou III', null, 1900, 1965, 'Reine de Tonga (1918-1965)', 'Maison Tupou', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Tonga', 250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a38e2c9d-6671-57dc-a0a2-1d5785308bac', 'entry', 'f35ca9bd-6664-5c90-9bc8-652d9449ea76', 'Tāufaʻāhau Tupou IV', null, 1918, 2006, 'Roi de Tonga (1965-2006)', 'Maison Tupou', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Tonga - fils de Sālote Tupou III', 250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('144f190f-23d1-59d9-b39b-115fb1cb94eb', 'entry', 'f35ca9bd-6664-5c90-9bc8-652d9449ea76', 'George Tupou V', null, 1948, 2012, 'Roi de Tonga (2006-2012)', 'Maison Tupou', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Tonga', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1632dc5b-8b23-5eb0-83ec-465fd24d0619', 'entry', 'f35ca9bd-6664-5c90-9bc8-652d9449ea76', 'Tupou VI', null, 1959, null, 'Roi de Tonga (depuis 2012)', 'Maison Tupou', 'Sources : https://en.wikipedia.org/wiki/List_of_monarchs_of_Tonga', 500, 1920, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('dbfb4757-3319-5ded-b604-ba550fbceb08', '021a1f46-51d6-5736-962f-8411fb1a0109', 'parent');
  perform pg_temp.rel('021a1f46-51d6-5736-962f-8411fb1a0109', 'a38e2c9d-6671-57dc-a0a2-1d5785308bac', 'parent');
  perform pg_temp.rel('a38e2c9d-6671-57dc-a0a2-1d5785308bac', '144f190f-23d1-59d9-b39b-115fb1cb94eb', 'parent');
  perform pg_temp.rel('a38e2c9d-6671-57dc-a0a2-1d5785308bac', '1632dc5b-8b23-5eb0-83ec-465fd24d0619', 'parent');
  raise notice 'schema_v141 : % membres ajoutés.', 5;
end $$;
