-- arbres_v174.sql — Espagne (Nasrides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Nasrides » (émirat de Grenade). Source : page « Emirate of Granada » (anglais).
-- Seules les relations écrites sur la page sont saisies ; frères, cousins et demi-frères via des liens « famille ». Naissances non indiquées. Dates de mort telles que sur la page ; mort de Boabdil contestée (1518, 1533 ou 1536) : non saisie. Les Omeyyades de Cordoue n'ont pas été faits : la page consultée ne donne aucune parenté.
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
  if exists (select 1 from public.genealogy_members where id = 'ac7d2d3f-606e-5ebd-96d6-475c19ffb02b') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Nasrides » (ESP)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ESP' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ESP : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Nasrides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('67c40607-bb67-5284-ba9f-7826b32c7c66', cat_id, 'country', 'ESP', top, 'Nasrides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '67c40607-bb67-5284-ba9f-7826b32c7c66';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('d98ae57b-8204-53be-80b5-e05ae5527d16', 'country', 'ESP', 'genealogy', 'Nasrides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ac7d2d3f-606e-5ebd-96d6-475c19ffb02b', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Muhammad Ier (Ibn al-Ahmar)', null, null, 1273, 'Émir de Grenade (1232-1273)', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - père non indiqué', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('28783954-c931-5e58-b57b-f330501f19f7', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Muhammad II', null, null, 1302, 'Émir de Grenade (1273-1302)', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1f0f923c-fbce-5ec0-91ba-886a19fa2abb', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Muhammad III', null, null, null, 'Émir de Grenade (1302-1309)', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - abdique en 1309', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('991660fa-f885-5a71-9ad9-5a6a2d5d2882', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Nasr', null, null, null, 'Émir de Grenade (1309-1314)', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - frère de Muhammad III', 4000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e8c5cded-97de-5281-9b15-5d0dd5960552', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Isma''il Ier', null, null, 1325, 'Émir de Grenade (1314-1325)', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - cousin de Nasr ; assassiné en juillet 1325', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0f604033-aecd-588c-b535-3dd60ccf177e', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Muhammad IV', null, null, 1333, 'Émir de Grenade (1325-1333)', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - assassiné le 25 août 1333', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('78cd1d8d-9475-54d8-92f9-29ac8bae2efd', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Yusuf Ier', null, null, 1354, 'Émir de Grenade (1333-1354)', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - frère de Muhammad IV ; assassiné', 2000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('de95c3c4-3276-588c-abb8-9927769d46e9', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Muhammad V', null, null, 1391, 'Émir de Grenade', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - règne 1354-1359 puis 1362-1391 (selon le texte de la page)', 2000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('88d75cea-3156-5cc3-860c-2a716bf369d4', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Isma''il II', null, null, 1360, 'Émir de Grenade (1359-1360)', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - demi-frère de Muhammad V ; assassiné en juin 1360', 5000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7f5ec1f9-62a7-5f7c-98a8-2df475ff1168', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Muhammad VI', null, null, null, 'Émir de Grenade (1360-1362)', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - cousin d''Isma''il II ; exécuté par Pierre de Castille (année non indiquée)', 6000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('30326743-735f-5f23-95d3-568b05721486', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Abu''l Hasan', null, null, 1485, 'Émir de Grenade', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - père de Muhammad XI', 3000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3636a294-25e6-50bb-a879-1ac59e47067c', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Muhammad XI (Boabdil)', null, null, null, 'Émir de Grenade (1487-1492)', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - mort contestée (1518, 1533 ou 1536)', 3000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('685a937d-1c28-50c5-a300-ca62cd6c32d1', 'entry', 'd98ae57b-8204-53be-80b5-e05ae5527d16', 'Muhammad XII (al-Zaghal)', null, null, null, 'Émir de Grenade', 'Nasrides', 'Sources : https://en.wikipedia.org/wiki/Emirate_of_Granada - frère d''Abu''l Hasan', 7000, 0, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('ac7d2d3f-606e-5ebd-96d6-475c19ffb02b', '28783954-c931-5e58-b57b-f330501f19f7', 'parent');
  perform pg_temp.rel('28783954-c931-5e58-b57b-f330501f19f7', '1f0f923c-fbce-5ec0-91ba-886a19fa2abb', 'parent');
  perform pg_temp.rel('e8c5cded-97de-5281-9b15-5d0dd5960552', '0f604033-aecd-588c-b535-3dd60ccf177e', 'parent');
  perform pg_temp.rel('78cd1d8d-9475-54d8-92f9-29ac8bae2efd', 'de95c3c4-3276-588c-abb8-9927769d46e9', 'parent');
  perform pg_temp.rel('30326743-735f-5f23-95d3-568b05721486', '3636a294-25e6-50bb-a879-1ac59e47067c', 'parent');
  perform pg_temp.rel('1f0f923c-fbce-5ec0-91ba-886a19fa2abb', '991660fa-f885-5a71-9ad9-5a6a2d5d2882', 'family');
  perform pg_temp.rel('991660fa-f885-5a71-9ad9-5a6a2d5d2882', 'e8c5cded-97de-5281-9b15-5d0dd5960552', 'family');
  perform pg_temp.rel('0f604033-aecd-588c-b535-3dd60ccf177e', '78cd1d8d-9475-54d8-92f9-29ac8bae2efd', 'family');
  perform pg_temp.rel('de95c3c4-3276-588c-abb8-9927769d46e9', '88d75cea-3156-5cc3-860c-2a716bf369d4', 'family');
  perform pg_temp.rel('88d75cea-3156-5cc3-860c-2a716bf369d4', '7f5ec1f9-62a7-5f7c-98a8-2df475ff1168', 'family');
  perform pg_temp.rel('30326743-735f-5f23-95d3-568b05721486', '685a937d-1c28-50c5-a300-ca62cd6c32d1', 'family');
  raise notice 'schema_v174 : % membres ajoutés.', 13;
end $$;
