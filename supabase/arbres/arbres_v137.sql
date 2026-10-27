-- arbres_v137.sql — Brunéi (Maison de Bolkiah)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Maison de Bolkiah » (Brunéi) : 7 personnes, du sultan Omar Ali Saifuddin II au prince héritier. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Pages lues : Hashim Jalilul Alam Aqamaddin (père Omar Ali Saifuddin II), Muhammad Jamalul Alam II (fils de Hashim), Ahmad Tajuddin et Omar Ali Saifuddien III (fils de Muhammad Jamalul Alam II), Hassanal Bolkiah (fils d'Omar Ali Saifuddien III), Al-Muhtadee Billah (fils de Hassanal Bolkiah). La page d'Omar Ali Saifuddin II ne donne pas sa naissance : laissée vide. Seule la lignée directe est représentée (pas toute la famille).
-- Ahmad Tajuddin n'a pas de fils cité par sa page (que des filles) : la couronne passe à son frère.
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
  if exists (select 1 from public.genealogy_members where id = '4395604b-d24d-53e5-9b0b-34c700daefae') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Maison de Bolkiah » (BRN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'BRN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour BRN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Maison de Bolkiah';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('8f1a2931-618a-59a4-8aab-30dd13b47699', cat_id, 'country', 'BRN', top, 'Maison de Bolkiah', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '8f1a2931-618a-59a4-8aab-30dd13b47699';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('d8aff1d6-ed01-57bf-bbe6-bcf1d89d14c7', 'country', 'BRN', 'genealogy', 'Maison de Bolkiah', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4395604b-d24d-53e5-9b0b-34c700daefae', 'entry', 'd8aff1d6-ed01-57bf-bbe6-bcf1d89d14c7', 'Omar Ali Saifuddin II', null, null, 1852, 'Sultan de Brunéi (1828-1852)', 'Maison de Bolkiah', 'Sources : https://en.wikipedia.org/wiki/Omar_Ali_Saifuddin_II', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7dae8226-6687-5cb8-b62c-179d7175ab6c', 'entry', 'd8aff1d6-ed01-57bf-bbe6-bcf1d89d14c7', 'Hashim Jalilul Alam Aqamaddin', null, 1825, 1906, 'Sultan de Brunéi (1885-1906)', 'Maison de Bolkiah', 'Sources : https://en.wikipedia.org/wiki/Hashim_Jalilul_Alam_Aqamaddin', 250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('27b61b15-1ff0-55ba-88c7-77eb9c59bc27', 'entry', 'd8aff1d6-ed01-57bf-bbe6-bcf1d89d14c7', 'Muhammad Jamalul Alam II', null, 1889, 1924, 'Sultan de Brunéi (1906-1924)', 'Maison de Bolkiah', 'Sources : https://en.wikipedia.org/wiki/Muhammad_Jamalul_Alam_II', 250, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('82129dfa-3e5c-5ef2-af32-242bcca3c551', 'entry', 'd8aff1d6-ed01-57bf-bbe6-bcf1d89d14c7', 'Ahmad Tajuddin', null, 1912, 1950, 'Sultan de Brunéi (1924-1950)', 'Maison de Bolkiah', 'Sources : https://en.wikipedia.org/wiki/Ahmad_Tajuddin', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('71ae5ec1-00d0-5cac-a626-ae0f256502c7', 'entry', 'd8aff1d6-ed01-57bf-bbe6-bcf1d89d14c7', 'Omar Ali Saifuddien III', null, 1914, 1986, 'Sultan de Brunéi (1950-1967)', 'Maison de Bolkiah', 'Sources : https://en.wikipedia.org/wiki/Omar_Ali_Saifuddien_III', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cad96bb4-8ab7-5acf-8769-892db46013e7', 'entry', 'd8aff1d6-ed01-57bf-bbe6-bcf1d89d14c7', 'Hassanal Bolkiah', null, 1946, null, 'Sultan de Brunéi (depuis 1967)', 'Maison de Bolkiah', 'Sources : https://en.wikipedia.org/wiki/Hassanal_Bolkiah', 500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('26921d84-67c4-5c10-a396-500b47ad9842', 'entry', 'd8aff1d6-ed01-57bf-bbe6-bcf1d89d14c7', 'Al-Muhtadee Billah', null, 1974, null, 'Prince héritier de Brunéi', 'Maison de Bolkiah', 'Sources : https://en.wikipedia.org/wiki/Al-Muhtadee_Billah', 500, 3840, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('4395604b-d24d-53e5-9b0b-34c700daefae', '7dae8226-6687-5cb8-b62c-179d7175ab6c', 'parent');
  perform pg_temp.rel('7dae8226-6687-5cb8-b62c-179d7175ab6c', '27b61b15-1ff0-55ba-88c7-77eb9c59bc27', 'parent');
  perform pg_temp.rel('27b61b15-1ff0-55ba-88c7-77eb9c59bc27', '82129dfa-3e5c-5ef2-af32-242bcca3c551', 'parent');
  perform pg_temp.rel('27b61b15-1ff0-55ba-88c7-77eb9c59bc27', '71ae5ec1-00d0-5cac-a626-ae0f256502c7', 'parent');
  perform pg_temp.rel('71ae5ec1-00d0-5cac-a626-ae0f256502c7', 'cad96bb4-8ab7-5acf-8769-892db46013e7', 'parent');
  perform pg_temp.rel('cad96bb4-8ab7-5acf-8769-892db46013e7', '26921d84-67c4-5c10-a396-500b47ad9842', 'parent');
  raise notice 'schema_v137 : % membres ajoutés.', 7;
end $$;
