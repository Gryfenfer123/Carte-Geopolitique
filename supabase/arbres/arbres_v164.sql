-- arbres_v164.sql — Italie (Flaviens)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Flaviens » (Rome antique, rattaché à l'Italie). Source : page « Flavian dynasty » (anglais).
-- Domitille l'Aînée est citée sans lien de parenté sur la page : non ajoutée. Julia Flavia : « peut-être » fille de Titus selon la page → lien « famille ».
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
  if exists (select 1 from public.genealogy_members where id = '98963d13-d8c9-578d-b008-d15e1274ac92') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Flaviens » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Flaviens';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('99e57cdb-fb1c-5e2b-ab71-1dc260473e4c', cat_id, 'country', 'ITA', top, 'Flaviens', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '99e57cdb-fb1c-5e2b-ab71-1dc260473e4c';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('fc2c7ffb-2d48-52a6-9543-208c4838fea2', 'country', 'ITA', 'genealogy', 'Flaviens', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('98963d13-d8c9-578d-b008-d15e1274ac92', 'entry', 'fc2c7ffb-2d48-52a6-9543-208c4838fea2', 'Titus Flavius Petro', null, null, null, 'Père de Titus Flavius Sabinus Ier', 'Flaviens', 'Sources : https://en.wikipedia.org/wiki/Flavian_dynasty', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0bd79307-7eac-5a40-b92f-f7c764d60ad3', 'entry', 'fc2c7ffb-2d48-52a6-9543-208c4838fea2', 'Titus Flavius Sabinus Ier', null, null, null, 'Père de Vespasien et de Sabinus II', 'Flaviens', 'Sources : https://en.wikipedia.org/wiki/Flavian_dynasty', 250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b57ad69f-b3ee-5ad7-80bd-89c24142f81d', 'entry', 'fc2c7ffb-2d48-52a6-9543-208c4838fea2', 'Titus Flavius Sabinus II', null, null, 69, 'Exécuté le 19 décembre 69', 'Flaviens', 'Sources : https://en.wikipedia.org/wiki/Flavian_dynasty', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d210c812-8727-5dcf-8689-166368afb8f4', 'entry', 'fc2c7ffb-2d48-52a6-9543-208c4838fea2', 'Vespasien', null, null, 79, 'Empereur romain (69-79)', 'Flaviens', 'Sources : https://en.wikipedia.org/wiki/Flavian_dynasty - mort le 23 juin 79', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3bafdc8a-e92b-5f78-b65b-1008262a9bb4', 'entry', 'fc2c7ffb-2d48-52a6-9543-208c4838fea2', 'Titus', null, 39, 81, 'Empereur romain (79-81)', 'Flaviens', 'Sources : https://en.wikipedia.org/wiki/Flavian_dynasty - mort le 13 septembre 81', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3537d5e4-d17d-5f7e-afbe-3460de8f6184', 'entry', 'fc2c7ffb-2d48-52a6-9543-208c4838fea2', 'Domitien', null, 51, 96, 'Empereur romain (81-96)', 'Flaviens', 'Sources : https://en.wikipedia.org/wiki/Flavian_dynasty - mort le 18 septembre 96', 1000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4e7094fc-14af-5e35-9b31-a814665a4010', 'entry', 'fc2c7ffb-2d48-52a6-9543-208c4838fea2', 'Domitille la Jeune', null, 45, null, 'Fille de Vespasien', 'Flaviens', 'Sources : https://en.wikipedia.org/wiki/Flavian_dynasty', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1780f750-b227-5b08-93e7-0d87759fa31b', 'entry', 'fc2c7ffb-2d48-52a6-9543-208c4838fea2', 'Julia Flavia', null, null, null, 'Fille de Titus (peut-être)', 'Flaviens', 'Sources : https://en.wikipedia.org/wiki/Flavian_dynasty - filiation incertaine selon la page', 2000, 20480, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('98963d13-d8c9-578d-b008-d15e1274ac92', '0bd79307-7eac-5a40-b92f-f7c764d60ad3', 'parent');
  perform pg_temp.rel('0bd79307-7eac-5a40-b92f-f7c764d60ad3', 'b57ad69f-b3ee-5ad7-80bd-89c24142f81d', 'parent');
  perform pg_temp.rel('0bd79307-7eac-5a40-b92f-f7c764d60ad3', 'd210c812-8727-5dcf-8689-166368afb8f4', 'parent');
  perform pg_temp.rel('d210c812-8727-5dcf-8689-166368afb8f4', '3bafdc8a-e92b-5f78-b65b-1008262a9bb4', 'parent');
  perform pg_temp.rel('d210c812-8727-5dcf-8689-166368afb8f4', '3537d5e4-d17d-5f7e-afbe-3460de8f6184', 'parent');
  perform pg_temp.rel('d210c812-8727-5dcf-8689-166368afb8f4', '4e7094fc-14af-5e35-9b31-a814665a4010', 'parent');
  perform pg_temp.rel('3bafdc8a-e92b-5f78-b65b-1008262a9bb4', '1780f750-b227-5b08-93e7-0d87759fa31b', 'family');
  raise notice 'schema_v164 : % membres ajoutés.', 8;
end $$;
