-- arbres_v143.sql — Pérou (Incas)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Sapa Inca » (Pérou) : 19 souverains incas, de Manco Cápac à Túpac Amaru. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Toutes les données viennent de la page « Sapa Inca » (liste) : filiation père-fils pour chaque souverain. Aucune date de naissance n'est donnée ; les dates de mort sont celles de la page (« vers » pour les plus anciens). Manco Cápac est légendaire (fils du dieu Inti selon la tradition). Les trois derniers frères (Sayri Túpac, Titu Cusi, Túpac Amaru) sont fils de Manco Inca Yupanqui d'après la page.
-- Les rois de la période de Vilcabamba ne sont pas tous dans la même ligne de succession que les rois de Cuzco.
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
  if exists (select 1 from public.genealogy_members where id = '9840831f-39af-5bac-ac9a-50c7c158dcce') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Sapa Inca » (PER)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'PER' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour PER : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Sapa Inca';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('316dd79a-1301-50e4-a457-d1a9d43454ca', cat_id, 'country', 'PER', top, 'Sapa Inca', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '316dd79a-1301-50e4-a457-d1a9d43454ca';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'country', 'PER', 'genealogy', 'Sapa Inca', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9840831f-39af-5bac-ac9a-50c7c158dcce', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Manco Cápac', null, null, 1230, 'Fondateur légendaire de la dynastie inca (c. 1200-1230)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca - mort vers 1230 ; considéré comme fils du dieu Inti (légendaire)', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6341738b-8839-51a2-bfcd-d55e72a2fd00', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Sinchi Roca', null, null, 1260, 'Sapa Inca (c. 1230-1260)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca - mort vers 1260', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('498de58d-e0e6-55f0-8da0-5bb31b62a663', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Lloque Yupanqui', null, null, 1290, 'Sapa Inca (c. 1260-1290)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca - mort vers 1290', 1000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('31e934e0-9df3-54af-9f32-7f887b4a57f8', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Mayta Cápac', null, null, 1320, 'Sapa Inca (c. 1290-1320)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca - mort vers 1320', 1000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('242d9fc6-0fac-5f72-9cf4-46ec02ac78a9', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Cápac Yupanqui', null, null, 1350, 'Sapa Inca (c. 1320-1350)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca - mort vers 1350', 1000, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('98d9baf9-b058-5136-a2d1-d0a119442822', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Inca Roca', null, null, 1380, 'Sapa Inca (c. 1350-1380)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca - mort vers 1380', 1000, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('45bd4835-e4c2-5713-a91b-4c2d5e4ee969', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Yahuar Huácac', null, null, 1410, 'Sapa Inca (c. 1380-1410)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca - mort vers 1410', 1000, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4220ec94-bfb9-56b7-9d6b-f367be6b2eac', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Viracocha', null, null, 1438, 'Sapa Inca (c. 1410-1438)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca', 1000, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d0e2d061-511b-59fd-8e10-09de807e1370', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Pachacútec (Pachacuti)', null, null, 1471, 'Sapa Inca (1438-1471)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca', 1000, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bc166481-a8a5-5628-8412-ecae15d95e91', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Túpac Inca Yupanqui', null, null, 1493, 'Sapa Inca (1471-1493)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca', 1000, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('72adf4c4-647a-56a3-894b-e155217586b1', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Huayna Cápac', null, null, 1527, 'Sapa Inca (1493-1527)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca', 1000, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6f0f7abf-f7ee-53b7-ba1e-36b46fd878f2', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Huáscar', null, null, 1533, 'Sapa Inca (1527-1532)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca - tué sur ordre d''Atahualpa selon la page', 500, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ff53da74-f5bb-53bf-9324-db137fe5481d', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Atahualpa', null, null, 1533, 'Sapa Inca (1532-1533)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca - exécuté par les conquistadors le 26 juillet 1533', 2000, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('183a7ccd-36f6-5135-bd8f-d401f7c360b1', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Túpac Huallpa', null, null, 1533, 'Sapa Inca (1533)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca', 0, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d59e0d78-aec7-5d5b-afb3-ea04a8702824', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Manco Inca Yupanqui', null, null, 1544, 'Sapa Inca (1533-1544)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca', 1000, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('199cee29-49c0-5833-abb9-dc897d01f8d5', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Paullu Inca', null, null, 1549, 'Sapa Inca (1536-1549)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca', 1500, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('98de2f2e-4c77-5246-8aed-695bae73af6c', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Sayri Túpac', null, null, 1560, 'Sapa Inca (1544-1560)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca', 1500, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('89382f76-db3b-5163-b7d3-1cb26af4801b', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Titu Cusi', null, null, 1571, 'Sapa Inca (1563-1571)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca', 500, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4dce230a-424f-5460-94f3-6cf127076d1c', 'entry', 'e4c0fb7d-b8eb-510c-ad53-a80c24cef3f9', 'Túpac Amaru', null, null, 1572, 'Dernier Sapa Inca (1571-1572)', 'Sapa Inca', 'Sources : https://en.wikipedia.org/wiki/Sapa_Inca - exécuté par les Espagnols le 24 septembre 1572', 1000, 7680, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('9840831f-39af-5bac-ac9a-50c7c158dcce', '6341738b-8839-51a2-bfcd-d55e72a2fd00', 'parent');
  perform pg_temp.rel('6341738b-8839-51a2-bfcd-d55e72a2fd00', '498de58d-e0e6-55f0-8da0-5bb31b62a663', 'parent');
  perform pg_temp.rel('498de58d-e0e6-55f0-8da0-5bb31b62a663', '31e934e0-9df3-54af-9f32-7f887b4a57f8', 'parent');
  perform pg_temp.rel('31e934e0-9df3-54af-9f32-7f887b4a57f8', '242d9fc6-0fac-5f72-9cf4-46ec02ac78a9', 'parent');
  perform pg_temp.rel('242d9fc6-0fac-5f72-9cf4-46ec02ac78a9', '98d9baf9-b058-5136-a2d1-d0a119442822', 'parent');
  perform pg_temp.rel('98d9baf9-b058-5136-a2d1-d0a119442822', '45bd4835-e4c2-5713-a91b-4c2d5e4ee969', 'parent');
  perform pg_temp.rel('45bd4835-e4c2-5713-a91b-4c2d5e4ee969', '4220ec94-bfb9-56b7-9d6b-f367be6b2eac', 'parent');
  perform pg_temp.rel('4220ec94-bfb9-56b7-9d6b-f367be6b2eac', 'd0e2d061-511b-59fd-8e10-09de807e1370', 'parent');
  perform pg_temp.rel('d0e2d061-511b-59fd-8e10-09de807e1370', 'bc166481-a8a5-5628-8412-ecae15d95e91', 'parent');
  perform pg_temp.rel('bc166481-a8a5-5628-8412-ecae15d95e91', '72adf4c4-647a-56a3-894b-e155217586b1', 'parent');
  perform pg_temp.rel('72adf4c4-647a-56a3-894b-e155217586b1', '6f0f7abf-f7ee-53b7-ba1e-36b46fd878f2', 'parent');
  perform pg_temp.rel('72adf4c4-647a-56a3-894b-e155217586b1', 'ff53da74-f5bb-53bf-9324-db137fe5481d', 'parent');
  perform pg_temp.rel('72adf4c4-647a-56a3-894b-e155217586b1', '183a7ccd-36f6-5135-bd8f-d401f7c360b1', 'parent');
  perform pg_temp.rel('72adf4c4-647a-56a3-894b-e155217586b1', 'd59e0d78-aec7-5d5b-afb3-ea04a8702824', 'parent');
  perform pg_temp.rel('72adf4c4-647a-56a3-894b-e155217586b1', '199cee29-49c0-5833-abb9-dc897d01f8d5', 'parent');
  perform pg_temp.rel('d59e0d78-aec7-5d5b-afb3-ea04a8702824', '98de2f2e-4c77-5246-8aed-695bae73af6c', 'parent');
  perform pg_temp.rel('d59e0d78-aec7-5d5b-afb3-ea04a8702824', '89382f76-db3b-5163-b7d3-1cb26af4801b', 'parent');
  perform pg_temp.rel('d59e0d78-aec7-5d5b-afb3-ea04a8702824', '4dce230a-424f-5460-94f3-6cf127076d1c', 'parent');
  raise notice 'schema_v143 : % membres ajoutés.', 19;
end $$;
