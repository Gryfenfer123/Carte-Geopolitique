-- arbres_v152.sql — Rwanda (Bami)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Bami du Rwanda » : 5 personnes, de Mutara II à Mutara III. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Pages lues : Mutara II (père de Rwabugiri d'après la page de Rwabugiri ; sa propre page ne nomme pas son père), Kigeli IV Rwabugiri (fils de Mutara II ; fils : Musinga biologique, Rutarindwa adopté), Rutarindwa (sa page : père Rwabugiri), Musinga (1883-1944), Mutara III (1911-1959, fils de Musinga). Rutarindwa est relié comme fils (la page de Rwabugiri précise « adopté »). Kigeli V Ndahindurwa, demi-frère de Mutara III, n'est pas ajouté.
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
  if exists (select 1 from public.genealogy_members where id = '396fe252-0d3b-535f-93c5-9349da1b4bc2') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Bami du Rwanda » (RWA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'RWA' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour RWA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Bami du Rwanda';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('942f3ad8-c61a-5d99-9e79-5614a0baeb42', cat_id, 'country', 'RWA', top, 'Bami du Rwanda', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '942f3ad8-c61a-5d99-9e79-5614a0baeb42';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('edc992da-de4f-5f28-ac54-c9db720fcb4c', 'country', 'RWA', 'genealogy', 'Bami du Rwanda', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('396fe252-0d3b-535f-93c5-9349da1b4bc2', 'entry', 'edc992da-de4f-5f28-ac54-c9db720fcb4c', 'Mutara II Rwogera', null, null, 1867, 'Mwami du Rwanda (1845-1867)', 'Bami du Rwanda', 'Sources : https://en.wikipedia.org/wiki/Mutara_II_of_Rwanda - père de Rwabugiri selon la page de Kigeli IV Rwabugiri ; mort en 1867', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5bb9c291-a7c3-576a-a4e7-b5a42704f754', 'entry', 'edc992da-de4f-5f28-ac54-c9db720fcb4c', 'Kigeli IV Rwabugiri', null, 1840, 1895, 'Mwami du Rwanda (1867-1895)', 'Bami du Rwanda', 'Sources : https://en.wikipedia.org/wiki/Kigeli_IV_Rwabugiri - naissance vers 1840 ; mort en septembre 1895', 250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('04dece44-1078-5bdf-816e-02a6f6526c85', 'entry', 'edc992da-de4f-5f28-ac54-c9db720fcb4c', 'Mibambwe IV Rutarindwa', null, null, 1896, 'Mwami du Rwanda (1895-1896)', 'Bami du Rwanda', 'Sources : https://en.wikipedia.org/wiki/Mibambwe_IV_Rutarindwa - fils adoptif de Rwabugiri selon la page de Rwabugiri ; sa propre page le dit « fils » ; mort en décembre 1896', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('08aceb50-36b6-59c0-9d8b-f4255bf41b13', 'entry', 'edc992da-de4f-5f28-ac54-c9db720fcb4c', 'Yuhi V Musinga', null, 1883, 1944, 'Mwami du Rwanda (1896-1931)', 'Bami du Rwanda', 'Sources : https://en.wikipedia.org/wiki/Yuhi_Musinga - fils biologique de Rwabugiri selon la page de Rwabugiri', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d366cd3f-10e7-5f17-91b2-2320f890c61b', 'entry', 'edc992da-de4f-5f28-ac54-c9db720fcb4c', 'Mutara III Rudahigwa', null, 1911, 1959, 'Mwami du Rwanda (1931-1959)', 'Bami du Rwanda', 'Sources : https://en.wikipedia.org/wiki/Mutara_III_Rudahigwa - fils de Musinga', 0, 2560, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('396fe252-0d3b-535f-93c5-9349da1b4bc2', '5bb9c291-a7c3-576a-a4e7-b5a42704f754', 'parent');
  perform pg_temp.rel('5bb9c291-a7c3-576a-a4e7-b5a42704f754', '04dece44-1078-5bdf-816e-02a6f6526c85', 'parent');
  perform pg_temp.rel('5bb9c291-a7c3-576a-a4e7-b5a42704f754', '08aceb50-36b6-59c0-9d8b-f4255bf41b13', 'parent');
  perform pg_temp.rel('08aceb50-36b6-59c0-9d8b-f4255bf41b13', 'd366cd3f-10e7-5f17-91b2-2320f890c61b', 'parent');
  raise notice 'schema_v152 : % membres ajoutés.', 5;
end $$;
