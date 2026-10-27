-- arbres_v146.sql — Mexique (tlatoani de Tenochtitlan)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Tlatoani de Tenochtitlan » (Mexique) : 7 souverains mexicas, d'Itzcoatl à Cuitlahuac. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Toutes les données viennent de la page « Aztec Empire » : elle donne les règnes et des liens de parenté (oncle, neveu, frère) mais aucune date de naissance ou de mort ; seul le lien Moctezuma I → Axayacatl est « père-fils ». Les autres sont des liens « famille ». Acamapichtli, Huitzilihuitl, Chimalpopoca et Cuauhtémoc ne sont pas ajoutés : la page ne les relie pas aux autres.
-- Les dates de règne sont celles de la page.
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
  if exists (select 1 from public.genealogy_members where id = '237f60e7-2443-55a0-b274-091a1293e497') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Tlatoani de Tenochtitlan » (MEX)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'MEX' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour MEX : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Tlatoani de Tenochtitlan';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('522fd93c-36df-57c7-acb0-4c92a49f0185', cat_id, 'country', 'MEX', top, 'Tlatoani de Tenochtitlan', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '522fd93c-36df-57c7-acb0-4c92a49f0185';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('03f84812-b043-5ddf-81cb-e3b123d6ceed', 'country', 'MEX', 'genealogy', 'Tlatoani de Tenochtitlan', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('237f60e7-2443-55a0-b274-091a1293e497', 'entry', '03f84812-b043-5ddf-81cb-e3b123d6ceed', 'Itzcoatl', null, null, null, 'Tlatoani de Tenochtitlan (1427-1440)', 'Tlatoani de Tenochtitlan', 'Sources : https://en.wikipedia.org/wiki/Aztec_Empire - oncle de Moctezuma I et de Tlacaelel', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b2759182-86e9-5bab-913c-e3469654d223', 'entry', '03f84812-b043-5ddf-81cb-e3b123d6ceed', 'Moctezuma I', null, null, null, 'Tlatoani de Tenochtitlan (1440-1468)', 'Tlatoani de Tenochtitlan', 'Sources : https://en.wikipedia.org/wiki/Aztec_Empire - neveu d''Itzcoatl, père d''Axayacatl', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1a7199f4-1c7b-5fd0-9915-4ffde8c2562b', 'entry', '03f84812-b043-5ddf-81cb-e3b123d6ceed', 'Axayacatl', null, null, null, 'Tlatoani de Tenochtitlan (1469-1481)', 'Tlatoani de Tenochtitlan', 'Sources : https://en.wikipedia.org/wiki/Aztec_Empire - fils de Moctezuma I', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3637516f-90e6-5f51-ad4c-08137601da63', 'entry', '03f84812-b043-5ddf-81cb-e3b123d6ceed', 'Tizoc', null, null, null, 'Tlatoani de Tenochtitlan (1481-1486)', 'Tlatoani de Tenochtitlan', 'Sources : https://en.wikipedia.org/wiki/Aztec_Empire - frère d''Axayacatl', 2000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d66fbdfb-5fe0-51cf-b60a-e6b435a37f5e', 'entry', '03f84812-b043-5ddf-81cb-e3b123d6ceed', 'Ahuitzotl', null, null, null, 'Tlatoani de Tenochtitlan (1486-1502)', 'Tlatoani de Tenochtitlan', 'Sources : https://en.wikipedia.org/wiki/Aztec_Empire - frère de Tizoc, oncle de Moctezuma II', 3000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('27608745-0488-5269-9333-7b78eeb9948d', 'entry', '03f84812-b043-5ddf-81cb-e3b123d6ceed', 'Moctezuma II', null, null, null, 'Tlatoani de Tenochtitlan (1502-1520)', 'Tlatoani de Tenochtitlan', 'Sources : https://en.wikipedia.org/wiki/Aztec_Empire - neveu d''Ahuitzotl', 4000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('84018d73-10a4-5ef5-a163-5d7403ce1794', 'entry', '03f84812-b043-5ddf-81cb-e3b123d6ceed', 'Cuitlahuac', null, null, null, 'Tlatoani de Tenochtitlan (1520)', 'Tlatoani de Tenochtitlan', 'Sources : https://en.wikipedia.org/wiki/Aztec_Empire - frère de Moctezuma II', 5000, 0, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('b2759182-86e9-5bab-913c-e3469654d223', '1a7199f4-1c7b-5fd0-9915-4ffde8c2562b', 'parent');
  perform pg_temp.rel('237f60e7-2443-55a0-b274-091a1293e497', 'b2759182-86e9-5bab-913c-e3469654d223', 'family');
  perform pg_temp.rel('1a7199f4-1c7b-5fd0-9915-4ffde8c2562b', '3637516f-90e6-5f51-ad4c-08137601da63', 'family');
  perform pg_temp.rel('3637516f-90e6-5f51-ad4c-08137601da63', 'd66fbdfb-5fe0-51cf-b60a-e6b435a37f5e', 'family');
  perform pg_temp.rel('d66fbdfb-5fe0-51cf-b60a-e6b435a37f5e', '27608745-0488-5269-9333-7b78eeb9948d', 'family');
  perform pg_temp.rel('27608745-0488-5269-9333-7b78eeb9948d', '84018d73-10a4-5ef5-a163-5d7403ce1794', 'family');
  raise notice 'schema_v146 : % membres ajoutés.', 7;
end $$;
