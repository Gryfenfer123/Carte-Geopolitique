-- arbres_v167.sql — Syrie (Séleucides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Séleucides » (Syrie antique). Sources : pages Wikipédia « Seleucid dynasty » et « Seleucid Empire » (anglais).
-- Aucune date de naissance/mort sur les pages ; seules les dates de règne figurent dans les titres. Antiochos IV est dit « frère cadet » de Séleucos IV (lien « famille »). Alexandre Balas se prétendait fils d'Antiochos IV mais était un imposteur selon la page (lien « famille » avec cette réserve). Antiochos VII : fils de Démétrios Ier selon la page « Seleucid dynasty » (la page « Seleucid Empire » le dit frère de Démétrios II). Les rois suivants (Antiochos VIII à XIII, etc.) ne sont pas reliés par les pages : non ajoutés.
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
  if exists (select 1 from public.genealogy_members where id = '0515333d-6aba-556a-9e44-c1fb75065c3d') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Séleucides » (SYR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'SYR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour SYR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Séleucides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('c26a2a84-09a3-5afc-8d65-12ba4078cb1f', cat_id, 'country', 'SYR', top, 'Séleucides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'c26a2a84-09a3-5afc-8d65-12ba4078cb1f';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('09049776-cbd2-5b03-83ea-fc6469e62759', 'country', 'SYR', 'genealogy', 'Séleucides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0515333d-6aba-556a-9e44-c1fb75065c3d', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Séleucos Ier Nicator', null, null, null, 'Roi séleucide (305-281 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('84a2e297-5671-5197-a5f4-adc93e036df1', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Antiochos Ier Sôter', null, null, null, 'Roi séleucide (281-261 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('613758c4-8eba-5b85-a967-2ae340df9fb2', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Antiochos II Théos', null, null, null, 'Roi séleucide (261-246 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0c4fd7ca-898b-5bb8-a959-e3a926a01c6f', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Séleucos II Callinicos', null, null, null, 'Roi séleucide (246-225 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 250, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('369a55ef-ed42-5245-ba74-96893f846c34', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Antiochos III le Grand', null, null, null, 'Roi séleucide (223-187 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty - plus jeune fils de Séleucos II', 250, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1aa8a347-b0ae-5805-86ff-6223577c6774', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Antiochos (fils d''Antiochos III)', null, null, null, 'Co-roi (210-193 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('374fa7a1-f764-5e06-bebf-f0d7fdc05b2e', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Séleucos IV Philopator', null, null, null, 'Roi séleucide (187-175 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('25e261a7-f440-59a2-9bd4-424cf041e8d4', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Antiochos IV Épiphane', null, null, null, 'Roi séleucide (175-164 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty - frère cadet de Séleucos IV', 1750, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f32a57e8-1a14-5ef1-8a07-506353a51be4', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Antiochos (fils de Séleucos IV)', null, null, null, 'Co-roi (175-170 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 750, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3e3d18e8-a16b-59bf-8f32-023e76b08989', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Antiochos V Eupator', null, null, null, 'Roi séleucide (164-162 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 1750, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b920e777-f7ad-5693-9904-f0d8ed13791f', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Démétrios Ier Sôter', null, null, null, 'Roi séleucide (162-150 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 250, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4fb4c33e-6295-57d5-861b-469ab98b5f30', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Alexandre Ier Balas', null, null, null, 'Roi séleucide (150-145 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty - se disait fils d''Antiochos IV ; imposteur selon la page', 2750, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('84d8fe06-4485-50a1-b2e6-9b807c450ea3', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Démétrios II Nicator', null, null, null, 'Roi séleucide (145-138 puis 129-125 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('99d00425-b873-597a-80aa-e1858394a900', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Antiochos VI Dionysos', null, null, null, 'Roi séleucide (145/144-142/141 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 2750, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ec2e1d02-c204-5b7a-bec0-af8124e48b01', 'entry', '09049776-cbd2-5b03-83ea-fc6469e62759', 'Antiochos VII Sidétès', null, null, null, 'Roi séleucide (138-129 av. J.-C.)', 'Séleucides', 'Sources : https://en.wikipedia.org/wiki/Seleucid_dynasty', 0, 4480, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('0515333d-6aba-556a-9e44-c1fb75065c3d', '84a2e297-5671-5197-a5f4-adc93e036df1', 'parent');
  perform pg_temp.rel('84a2e297-5671-5197-a5f4-adc93e036df1', '613758c4-8eba-5b85-a967-2ae340df9fb2', 'parent');
  perform pg_temp.rel('613758c4-8eba-5b85-a967-2ae340df9fb2', '0c4fd7ca-898b-5bb8-a959-e3a926a01c6f', 'parent');
  perform pg_temp.rel('0c4fd7ca-898b-5bb8-a959-e3a926a01c6f', '369a55ef-ed42-5245-ba74-96893f846c34', 'parent');
  perform pg_temp.rel('369a55ef-ed42-5245-ba74-96893f846c34', '1aa8a347-b0ae-5805-86ff-6223577c6774', 'parent');
  perform pg_temp.rel('369a55ef-ed42-5245-ba74-96893f846c34', '374fa7a1-f764-5e06-bebf-f0d7fdc05b2e', 'parent');
  perform pg_temp.rel('374fa7a1-f764-5e06-bebf-f0d7fdc05b2e', 'f32a57e8-1a14-5ef1-8a07-506353a51be4', 'parent');
  perform pg_temp.rel('25e261a7-f440-59a2-9bd4-424cf041e8d4', '3e3d18e8-a16b-59bf-8f32-023e76b08989', 'parent');
  perform pg_temp.rel('374fa7a1-f764-5e06-bebf-f0d7fdc05b2e', 'b920e777-f7ad-5693-9904-f0d8ed13791f', 'parent');
  perform pg_temp.rel('b920e777-f7ad-5693-9904-f0d8ed13791f', '84d8fe06-4485-50a1-b2e6-9b807c450ea3', 'parent');
  perform pg_temp.rel('4fb4c33e-6295-57d5-861b-469ab98b5f30', '99d00425-b873-597a-80aa-e1858394a900', 'parent');
  perform pg_temp.rel('b920e777-f7ad-5693-9904-f0d8ed13791f', 'ec2e1d02-c204-5b7a-bec0-af8124e48b01', 'parent');
  perform pg_temp.rel('374fa7a1-f764-5e06-bebf-f0d7fdc05b2e', '25e261a7-f440-59a2-9bd4-424cf041e8d4', 'family');
  perform pg_temp.rel('25e261a7-f440-59a2-9bd4-424cf041e8d4', '4fb4c33e-6295-57d5-861b-469ab98b5f30', 'family');
  raise notice 'schema_v167 : % membres ajoutés.', 15;
end $$;
