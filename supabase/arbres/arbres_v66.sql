-- arbres_v66.sql — Allemagne — petites dynasties : Hohenstaufen (enfants de Barberousse, Conradin, Manfred), Ottoniens, Saliens
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Complète les arbres Hohenstaufen, Ottoniens et Saliens (rien n'est supprimé).
-- Sources : Wikipédia en anglais (Frédéric Barberousse, Conradin, Henri IV, Otton Ier). Dates non données = vides et signalées.
-- Bianca Lancia (famille sans arbre) est placée dans l'arbre Hohenstaufen et signalée.
-- Remarque : Liutgarde (fille d'Otton Ier) est reliée en base à Adélaïde, mais Wikipédia la dit fille d'Édith ; non modifié (suppression d'un lien = à décider par Martin).
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
  if exists (select 1 from public.genealogy_members where id = '56508165-a9e2-57ec-9ec3-bf96c95cea96') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('04dd1dfb-28c9-4504-8721-84290d799bf7','1f955b05-e95c-4644-b272-7bf5e991b50c','4409e210-6000-40a8-a333-836f1d346b00','50dba002-d282-47eb-be96-aaa4fc7f2ac2','7d2f8eb8-d87e-4f1b-9af9-674855ad35b1','8bc0cda2-c013-465e-8688-f90df3a615be','df121566-2739-4375-86e8-938ef55c82ec','ff146d02-1752-405d-b4b6-45d3fcb44462');
  if k <> 8 then raise exception 'Membres préexistants manquants (% sur 8) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  select count(*) into k from public.dossier_entries where id = '19aed0d5-8c4a-4125-b821-8fc6bc357dab' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Hohenstaufen introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '99d9527e-fbca-4280-ac55-426024c9ed90' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Ottoniens introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = 'bd5ca9f3-1ab0-4056-81d7-56ece7b0eee8' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Saliens introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('56508165-a9e2-57ec-9ec3-bf96c95cea96', 'entry', '19aed0d5-8c4a-4125-b821-8fc6bc357dab', 'Frédéric V de Souabe', null, 1164, 1170, 'Duc de Souabe', 'Hohenstaufen', 186000, 2952, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('82cdc93d-203a-598c-a5e5-5b4f65889bcb', 'entry', '19aed0d5-8c4a-4125-b821-8fc6bc357dab', 'Conrad (Frédéric VI) de Souabe', null, 1167, 1191, 'Duc de Souabe', 'Hohenstaufen', 186340, 3006, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a12867db-021f-500a-9451-0802e2853b2f', 'entry', '19aed0d5-8c4a-4125-b821-8fc6bc357dab', 'Judith de Hohenstaufen', null, 1168, 1184, '', 'Hohenstaufen', 186680, 3024, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('92ffb5db-49a2-51e2-8ee2-0098f78a491d', 'entry', '19aed0d5-8c4a-4125-b821-8fc6bc357dab', 'Otton Ier de Bourgogne', null, 1170, 1200, 'Comte de Bourgogne', 'Hohenstaufen', 187020, 3060, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e502bf27-12bd-5809-a240-5ac1d4278ba4', 'entry', '19aed0d5-8c4a-4125-b821-8fc6bc357dab', 'Conrad II de Souabe', null, 1172, 1196, 'Duc de Souabe et de Rothenburg', 'Hohenstaufen', 187360, 3096, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('891e9923-96a8-5061-8836-ebd86104c8c7', 'entry', '19aed0d5-8c4a-4125-b821-8fc6bc357dab', 'Agnès de Hohenstaufen (1179-1184)', null, 1179, 1184, '', 'Hohenstaufen', 187700, 3222, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('92dbade5-ae57-5354-b743-23e7d7e7b73b', 'entry', '19aed0d5-8c4a-4125-b821-8fc6bc357dab', 'Conradin', null, 1252, 1268, 'Duc de Souabe, roi de Jérusalem et de Sicile (dernier Hohenstaufen)', 'Hohenstaufen', 188040, 4536, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('595a15cc-2f11-5b74-80ac-b3052a17712e', 'entry', '19aed0d5-8c4a-4125-b821-8fc6bc357dab', 'Bianca Lancia', null, null, null, 'Épouse de Frédéric II', 'Lancia', 188380, 5400, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('905b3423-aedf-5c33-ad0f-021345da1066', 'entry', '19aed0d5-8c4a-4125-b821-8fc6bc357dab', 'Manfred de Sicile', null, 1232, 1266, 'Roi de Sicile', 'Hohenstaufen', 188720, 4176, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0c9a2bf3-9eee-569e-b607-bf23cff1b0c4', 'entry', '99d9527e-fbca-4280-ac55-426024c9ed90', 'Liudolf de Souabe', null, 930, 957, 'Duc de Souabe', 'Ottoniens', 186000, -1260, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0b83dc74-b25e-5efb-97b9-bfe9f4f8f4a0', 'entry', '99d9527e-fbca-4280-ac55-426024c9ed90', 'Édith d''Angleterre', null, 910, 946, 'Reine de Germanie', 'Wessex', 186340, -1620, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('806b77a3-877c-5246-8553-d055285ff2df', 'entry', '99d9527e-fbca-4280-ac55-426024c9ed90', 'Guillaume de Mayence', null, 929, 968, 'Archevêque de Mayence', 'Ottoniens', 186680, -1278, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dba4d024-cc5f-5a3c-b8f1-8a6ff17b0a0c', 'entry', 'bd5ca9f3-1ab0-4056-81d7-56ece7b0eee8', 'Conrad II d''Italie', null, null, null, 'Roi d''Italie', 'Saliens', 186000, 5400, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('4409e210-6000-40a8-a333-836f1d346b00', '56508165-a9e2-57ec-9ec3-bf96c95cea96', 'parent');
  perform pg_temp.rel('7d2f8eb8-d87e-4f1b-9af9-674855ad35b1', '56508165-a9e2-57ec-9ec3-bf96c95cea96', 'parent');
  perform pg_temp.rel('4409e210-6000-40a8-a333-836f1d346b00', '82cdc93d-203a-598c-a5e5-5b4f65889bcb', 'parent');
  perform pg_temp.rel('7d2f8eb8-d87e-4f1b-9af9-674855ad35b1', '82cdc93d-203a-598c-a5e5-5b4f65889bcb', 'parent');
  perform pg_temp.rel('4409e210-6000-40a8-a333-836f1d346b00', 'a12867db-021f-500a-9451-0802e2853b2f', 'parent');
  perform pg_temp.rel('7d2f8eb8-d87e-4f1b-9af9-674855ad35b1', 'a12867db-021f-500a-9451-0802e2853b2f', 'parent');
  perform pg_temp.rel('4409e210-6000-40a8-a333-836f1d346b00', '92ffb5db-49a2-51e2-8ee2-0098f78a491d', 'parent');
  perform pg_temp.rel('7d2f8eb8-d87e-4f1b-9af9-674855ad35b1', '92ffb5db-49a2-51e2-8ee2-0098f78a491d', 'parent');
  perform pg_temp.rel('4409e210-6000-40a8-a333-836f1d346b00', 'e502bf27-12bd-5809-a240-5ac1d4278ba4', 'parent');
  perform pg_temp.rel('7d2f8eb8-d87e-4f1b-9af9-674855ad35b1', 'e502bf27-12bd-5809-a240-5ac1d4278ba4', 'parent');
  perform pg_temp.rel('4409e210-6000-40a8-a333-836f1d346b00', '891e9923-96a8-5061-8836-ebd86104c8c7', 'parent');
  perform pg_temp.rel('7d2f8eb8-d87e-4f1b-9af9-674855ad35b1', '891e9923-96a8-5061-8836-ebd86104c8c7', 'parent');
  perform pg_temp.rel('8bc0cda2-c013-465e-8688-f90df3a615be', '92dbade5-ae57-5354-b743-23e7d7e7b73b', 'parent');
  perform pg_temp.rel('1f955b05-e95c-4644-b272-7bf5e991b50c', '92dbade5-ae57-5354-b743-23e7d7e7b73b', 'parent');
  perform pg_temp.rel('df121566-2739-4375-86e8-938ef55c82ec', '595a15cc-2f11-5b74-80ac-b3052a17712e', 'spouse');
  perform pg_temp.rel('df121566-2739-4375-86e8-938ef55c82ec', '905b3423-aedf-5c33-ad0f-021345da1066', 'parent');
  perform pg_temp.rel('595a15cc-2f11-5b74-80ac-b3052a17712e', '905b3423-aedf-5c33-ad0f-021345da1066', 'parent');
  perform pg_temp.rel('ff146d02-1752-405d-b4b6-45d3fcb44462', '0b83dc74-b25e-5efb-97b9-bfe9f4f8f4a0', 'spouse');
  perform pg_temp.rel('ff146d02-1752-405d-b4b6-45d3fcb44462', '0c9a2bf3-9eee-569e-b607-bf23cff1b0c4', 'parent');
  perform pg_temp.rel('0b83dc74-b25e-5efb-97b9-bfe9f4f8f4a0', '0c9a2bf3-9eee-569e-b607-bf23cff1b0c4', 'parent');
  perform pg_temp.rel('ff146d02-1752-405d-b4b6-45d3fcb44462', '806b77a3-877c-5246-8553-d055285ff2df', 'parent');
  perform pg_temp.rel('50dba002-d282-47eb-be96-aaa4fc7f2ac2', 'dba4d024-cc5f-5a3c-b8f1-8a6ff17b0a0c', 'parent');
  perform pg_temp.rel('04dd1dfb-28c9-4504-8721-84290d799bf7', 'dba4d024-cc5f-5a3c-b8f1-8a6ff17b0a0c', 'parent');
  raise notice 'schema_v66 : % membres ajoutés.', 13;
end $$;
