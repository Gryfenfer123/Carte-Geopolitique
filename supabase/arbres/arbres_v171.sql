-- arbres_v171.sql — Iran (Ilkhans)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Ilkhans » (Iran). Sources : pages Wikipédia « Ilkhanate » et « Ghazan » (anglais).
-- Tolui est le père de Houlagou. Ahmad Tegüder est dit frère d'Abaqa, Gaykhatu frère d'Arghun, Öljaitü frère de Ghazan (liens « famille »). Ghazan est fils d'Arghun (page « Ghazan »). Naissance de Ghazan : 5 novembre 1271 selon la page « Ghazan », 1272 selon la liste de la page « Ilkhanate » (1271 retenu). Baydu (cousin de Gaykhatu) n'est pas ajouté faute de lien précis.
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
  if exists (select 1 from public.genealogy_members where id = 'f11886d1-0687-5575-975e-36f9fa70c921') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Ilkhans » (IRN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IRN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IRN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Ilkhans';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('d8a29e9b-bf62-5923-ada0-1d37b546c00c', cat_id, 'country', 'IRN', top, 'Ilkhans', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'd8a29e9b-bf62-5923-ada0-1d37b546c00c';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('14cf2ab2-d01a-54ab-9be7-2aa91c81054c', 'country', 'IRN', 'genealogy', 'Ilkhans', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f11886d1-0687-5575-975e-36f9fa70c921', 'entry', '14cf2ab2-d01a-54ab-9be7-2aa91c81054c', 'Tolui', null, null, null, 'Père de Houlagou', 'Ilkhans', 'Sources : https://en.wikipedia.org/wiki/Ilkhanate', 0, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2dfe81d7-5c0f-5797-b56e-d6cdb826b0f4', 'entry', '14cf2ab2-d01a-54ab-9be7-2aa91c81054c', 'Houlagou', null, 1217, 1265, 'Premier ilkhan (1256-1265)', 'Ilkhans', 'Sources : https://en.wikipedia.org/wiki/Ilkhanate', 0, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('49f8f2dc-cb08-5e99-84a2-282fa4b35583', 'entry', '14cf2ab2-d01a-54ab-9be7-2aa91c81054c', 'Abaqa', null, 1234, 1282, 'Ilkhan (1265-1282)', 'Ilkhans', 'Sources : https://en.wikipedia.org/wiki/Ilkhanate', 0, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0b3281d5-5c65-55e4-8bfa-12d6d4aed3d5', 'entry', '14cf2ab2-d01a-54ab-9be7-2aa91c81054c', 'Ahmad Tegüder', null, 1233, 1284, 'Ilkhan (1282-1284)', 'Ilkhans', 'Sources : https://en.wikipedia.org/wiki/Ilkhanate - frère d''Abaqa', 2000, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('317a8426-83c9-5e5c-8754-315e2039ba6e', 'entry', '14cf2ab2-d01a-54ab-9be7-2aa91c81054c', 'Arghun', null, null, 1292, 'Ilkhan (1284-1291)', 'Ilkhans', 'Sources : https://en.wikipedia.org/wiki/Ilkhanate - naissance 1258 sur la page « Ilkhanate » : incompatible avec Ghazan né en 1271, non saisie', 0, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('89a77283-2eff-50d6-aca0-b227466e5baa', 'entry', '14cf2ab2-d01a-54ab-9be7-2aa91c81054c', 'Gaykhatu', null, null, 1295, 'Ilkhan (1291-1295)', 'Ilkhans', 'Sources : https://en.wikipedia.org/wiki/Ilkhanate - frère d''Arghun', 3000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('58cd0499-8dc4-542e-b82e-b38ab8c8b4f8', 'entry', '14cf2ab2-d01a-54ab-9be7-2aa91c81054c', 'Ghazan', null, 1271, 1304, 'Ilkhan (1295-1304)', 'Ilkhans', 'Sources : https://en.wikipedia.org/wiki/Ghazan - né le 5 novembre 1271 ; mort le 11 mai 1304', 0, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('715b5577-86ee-564c-b548-60d195961081', 'entry', '14cf2ab2-d01a-54ab-9be7-2aa91c81054c', 'Öljaitü', null, 1280, 1316, 'Ilkhan (1304-1316)', 'Ilkhans', 'Sources : https://en.wikipedia.org/wiki/Ilkhanate - frère de Ghazan', 1000, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b1f3cca4-b0b9-5a4b-92cf-eba6164b6a52', 'entry', '14cf2ab2-d01a-54ab-9be7-2aa91c81054c', 'Abu Saïd', null, 1305, 1335, 'Ilkhan (1316-1335)', 'Ilkhans', 'Sources : https://en.wikipedia.org/wiki/Ilkhanate', 1000, 5760, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('f11886d1-0687-5575-975e-36f9fa70c921', '2dfe81d7-5c0f-5797-b56e-d6cdb826b0f4', 'parent');
  perform pg_temp.rel('2dfe81d7-5c0f-5797-b56e-d6cdb826b0f4', '49f8f2dc-cb08-5e99-84a2-282fa4b35583', 'parent');
  perform pg_temp.rel('49f8f2dc-cb08-5e99-84a2-282fa4b35583', '317a8426-83c9-5e5c-8754-315e2039ba6e', 'parent');
  perform pg_temp.rel('317a8426-83c9-5e5c-8754-315e2039ba6e', '58cd0499-8dc4-542e-b82e-b38ab8c8b4f8', 'parent');
  perform pg_temp.rel('715b5577-86ee-564c-b548-60d195961081', 'b1f3cca4-b0b9-5a4b-92cf-eba6164b6a52', 'parent');
  perform pg_temp.rel('49f8f2dc-cb08-5e99-84a2-282fa4b35583', '0b3281d5-5c65-55e4-8bfa-12d6d4aed3d5', 'family');
  perform pg_temp.rel('317a8426-83c9-5e5c-8754-315e2039ba6e', '89a77283-2eff-50d6-aca0-b227466e5baa', 'family');
  perform pg_temp.rel('58cd0499-8dc4-542e-b82e-b38ab8c8b4f8', '715b5577-86ee-564c-b548-60d195961081', 'family');
  raise notice 'schema_v171 : % membres ajoutés.', 9;
end $$;
