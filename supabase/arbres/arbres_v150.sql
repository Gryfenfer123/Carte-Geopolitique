-- arbres_v150.sql — Égypte (Qalawunides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Qalawunides » (Égypte, Mamelouks bahrites) : 15 sultans. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Tout vient de la page « Bahri Mamluks » : Khalil et an-Nasir Muhammad fils de Qalawun ; les 8 sultans suivants fils d'an-Nasir Muhammad ; al-Mansur Muhammad fils de Hajji ; Ali II et Hajji II fils de Shaban II ; Shaban II est dit « petit-fils d'an-Nasir Muhammad » (ligne exacte non indiquée : lien « famille »). Les sultans qui étaient mamelouks de Qalawun (Kitbugha, Lajin, Baybars II) ne sont pas ajoutés. Aucune date de naissance ou de mort.
-- Sultans régnant en Égypte et en Syrie (1279-1390).
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
  if exists (select 1 from public.genealogy_members where id = '2a15e5cc-e3dc-5d82-b65d-ea3100c25f60') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Qalawunides » (EGY)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'EGY' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour EGY : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Qalawunides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('ce653c5f-f1fa-51f6-8be2-2b207942fde3', cat_id, 'country', 'EGY', top, 'Qalawunides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'ce653c5f-f1fa-51f6-8be2-2b207942fde3';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('b1733373-bab7-501c-93b3-39d42949461e', 'country', 'EGY', 'genealogy', 'Qalawunides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2a15e5cc-e3dc-5d82-b65d-ea3100c25f60', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'Qalawun', null, null, null, 'Sultan mamelouk d''Égypte (1279-1290)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - listé comme mamelouk d''Aybak', 2000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b6d3a0ff-2815-50f7-af09-55ec0f31ccde', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'Al-Ashraf Khalil', null, null, null, 'Sultan (1290-1293)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils de Qalawun', 2250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('39d2d97d-1d01-518e-8e5d-4943b10eb37b', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'An-Nasir Muhammad', null, null, null, 'Sultan (1293-1294 ; 1299-1309 ; 1310-1341)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils de Qalawun', 1750, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('94e51ea2-ee3e-5be6-bb93-6986c73e0289', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'Al-Mansur Abu Bakr', null, null, null, 'Sultan (1341)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils d''an-Nasir Muhammad', 2000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e9c95c36-45aa-59ba-8d1e-ca4f875e69ec', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'Al-Ashraf Kujuk', null, null, null, 'Sultan (1341-1342)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils d''an-Nasir Muhammad', 1000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('df25adee-73e9-546b-9724-38c62bf5de35', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'An-Nasir Ahmad', null, null, null, 'Sultan (1342)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils d''an-Nasir Muhammad', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('93be2f2f-0a95-5c76-89f7-df16c7641647', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'As-Salih Ismail', null, null, null, 'Sultan (1342-1345)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils d''an-Nasir Muhammad', 3000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('af9715e3-1f50-5ac6-a0e1-f2b9d57ba081', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'Al-Kamil Shaban', null, null, null, 'Sultan (1345-1346)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils d''an-Nasir Muhammad', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fce47f99-6f64-5314-abdc-919eb9453ecc', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'Al-Muzaffar Hajji', null, null, null, 'Sultan (1346-1347)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils d''an-Nasir Muhammad', 1500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('941a9192-a2c0-594c-b85e-32f8e1e95039', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'An-Nasir Hasan', null, null, null, 'Sultan (1347-1351 ; 1354-1361)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils d''an-Nasir Muhammad', 2500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1e196784-88ab-59b7-98c6-75ffd1167e3d', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'As-Salih Salih', null, null, null, 'Sultan (1351-1354)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils d''an-Nasir Muhammad', 3500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9e7715e3-af70-5e8c-b47e-0a0af676c204', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'Al-Mansur Muhammad', null, null, null, 'Sultan (1361-1363)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils de Hajji', 1500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('16e67add-2a5e-5929-85eb-c7ddda36ffc2', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'Al-Ashraf Shaban II', null, null, null, 'Sultan (1363-1377)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - petit-fils d''an-Nasir Muhammad', 4750, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('11fbfde1-c70a-5827-9e28-647bdde12e86', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'Al-Mansur Ali II', null, null, null, 'Sultan (1377-1381)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils de Shaban II', 4500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b54a851a-b972-5d94-ac11-3ae682278ea4', 'entry', 'b1733373-bab7-501c-93b3-39d42949461e', 'As-Salih Hajji II', null, null, null, 'Sultan (1381-1382 ; 1389-1390)', 'Qalawunides', 'Sources : https://en.wikipedia.org/wiki/Bahri_Mamluks - fils de Shaban II', 5000, 640, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('2a15e5cc-e3dc-5d82-b65d-ea3100c25f60', 'b6d3a0ff-2815-50f7-af09-55ec0f31ccde', 'parent');
  perform pg_temp.rel('2a15e5cc-e3dc-5d82-b65d-ea3100c25f60', '39d2d97d-1d01-518e-8e5d-4943b10eb37b', 'parent');
  perform pg_temp.rel('39d2d97d-1d01-518e-8e5d-4943b10eb37b', '94e51ea2-ee3e-5be6-bb93-6986c73e0289', 'parent');
  perform pg_temp.rel('39d2d97d-1d01-518e-8e5d-4943b10eb37b', 'e9c95c36-45aa-59ba-8d1e-ca4f875e69ec', 'parent');
  perform pg_temp.rel('39d2d97d-1d01-518e-8e5d-4943b10eb37b', 'df25adee-73e9-546b-9724-38c62bf5de35', 'parent');
  perform pg_temp.rel('39d2d97d-1d01-518e-8e5d-4943b10eb37b', '93be2f2f-0a95-5c76-89f7-df16c7641647', 'parent');
  perform pg_temp.rel('39d2d97d-1d01-518e-8e5d-4943b10eb37b', 'af9715e3-1f50-5ac6-a0e1-f2b9d57ba081', 'parent');
  perform pg_temp.rel('39d2d97d-1d01-518e-8e5d-4943b10eb37b', 'fce47f99-6f64-5314-abdc-919eb9453ecc', 'parent');
  perform pg_temp.rel('39d2d97d-1d01-518e-8e5d-4943b10eb37b', '941a9192-a2c0-594c-b85e-32f8e1e95039', 'parent');
  perform pg_temp.rel('39d2d97d-1d01-518e-8e5d-4943b10eb37b', '1e196784-88ab-59b7-98c6-75ffd1167e3d', 'parent');
  perform pg_temp.rel('fce47f99-6f64-5314-abdc-919eb9453ecc', '9e7715e3-af70-5e8c-b47e-0a0af676c204', 'parent');
  perform pg_temp.rel('16e67add-2a5e-5929-85eb-c7ddda36ffc2', '11fbfde1-c70a-5827-9e28-647bdde12e86', 'parent');
  perform pg_temp.rel('16e67add-2a5e-5929-85eb-c7ddda36ffc2', 'b54a851a-b972-5d94-ac11-3ae682278ea4', 'parent');
  perform pg_temp.rel('39d2d97d-1d01-518e-8e5d-4943b10eb37b', '16e67add-2a5e-5929-85eb-c7ddda36ffc2', 'family');
  raise notice 'schema_v150 : % membres ajoutés.', 15;
end $$;
