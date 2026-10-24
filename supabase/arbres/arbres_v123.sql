-- arbres_v123.sql — Émirats arabes unis (Al Nahyan)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Al Nahyan » (Abou Dhabi) : 15 dirigeants. Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Pages individuelles lues : Zayed ben Sultan et Khalifa ben Zayed ; les autres fiches viennent du tableau des dirigeants de la page « House of Nahyan ».
-- Dhiyab ben Isa : son père Isa n'est pas nommé dans la page (non saisi). Dates inconnues laissées vides.
-- Dates en année chrétienne telles que la page les donne.
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
  if exists (select 1 from public.genealogy_members where id = '0387d6e4-32c6-5b7f-afc7-642c2669ae0e') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Al Nahyan » (ARE)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ARE' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ARE : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Al Nahyan';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('864eb7c1-702d-59d4-8886-e33a95442081', cat_id, 'country', 'ARE', top, 'Al Nahyan', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '864eb7c1-702d-59d4-8886-e33a95442081';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'country', 'ARE', 'genealogy', 'Al Nahyan', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0387d6e4-32c6-5b7f-afc7-642c2669ae0e', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Dhiyab ben Isa', null, 1700, 1793, 'Cheikh d''Abou Dhabi (1761-1793)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 1250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('19672258-5c6b-5477-9aaa-bdb55351a84a', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Shakhbut ben Dhiyab', null, null, null, 'Cheikh d''Abou Dhabi (1793-1816)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 1250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('db3d5b1a-e001-5584-9b2e-eed7da460764', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Muhammad ben Shakhbut', null, null, null, 'Cheikh d''Abou Dhabi (1816-1818)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 1750, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cf0958fb-a5ff-509d-9724-a7dc4dfbc1a1', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Tahnun ben Shakhbut', null, null, 1833, 'Cheikh d''Abou Dhabi (1818-1833)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 1250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5e9c05e2-54d1-57aa-8ce3-ec7ebb6a8ca2', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Khalifa ben Shakhbut', null, null, 1845, 'Cheikh d''Abou Dhabi (1833-1845)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 750, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('56c2ec65-ffe6-5a20-aa1b-85cd980d3982', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Saïd ben Tahnun', null, null, 1855, 'Cheikh d''Abou Dhabi (1845-1855)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 1250, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f1013b87-c265-51f3-8c83-f106e12f85e6', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Zayed ben Khalifa (Zayed le Grand)', null, 1835, 1909, 'Cheikh d''Abou Dhabi (1855-1909)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 750, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ef3660c4-f8d0-5eff-94ce-ddb72490ca3e', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Tahnoun ben Zayed', null, 1857, 1912, 'Cheikh d''Abou Dhabi (1909-1912)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('173bef4f-7238-5726-a9da-409b9be632be', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Hamdan ben Zayed', null, null, 1922, 'Cheikh d''Abou Dhabi (1912-1922)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 1500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a8cb693d-08eb-5b0e-9c8c-de1484684944', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Sultan ben Zayed', null, null, 1926, 'Cheikh d''Abou Dhabi (1922-1926)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 1000, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fdfb024f-93b2-5578-902c-b82b05c8a252', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Saqr ben Zayed', null, null, 1928, 'Cheikh d''Abou Dhabi (1926-1928)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('06502976-f6f0-5494-b618-43fff6cf7442', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Shakhbut ben Sultan', null, 1905, 1989, 'Cheikh d''Abou Dhabi (1928-1966)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 1250, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a0b508f0-c912-5871-b641-955753a1508f', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Zayed ben Sultan', null, 1918, 2004, 'Premier président des Émirats arabes unis (1971-2004)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/Zayed_bin_Sultan_Al_Nahyan', 750, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1452df01-e137-5a0e-9249-601ed275e8f9', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Khalifa ben Zayed', null, 1948, 2022, 'Président des Émirats arabes unis (2004-2022)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/Khalifa_bin_Zayed_Al_Nahyan', 500, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('46c5c9b4-f049-5b95-bc96-609f4dc658ae', 'entry', '1d2cadee-e69d-50ab-b93b-1bcf36fcbb5a', 'Mohamed ben Zayed', null, 1961, null, 'Président des Émirats arabes unis (depuis 2022)', 'Al Nahyan', 'Sources : https://en.wikipedia.org/wiki/House_of_Nahyan', 1000, 5120, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('0387d6e4-32c6-5b7f-afc7-642c2669ae0e', '19672258-5c6b-5477-9aaa-bdb55351a84a', 'parent');
  perform pg_temp.rel('19672258-5c6b-5477-9aaa-bdb55351a84a', 'db3d5b1a-e001-5584-9b2e-eed7da460764', 'parent');
  perform pg_temp.rel('19672258-5c6b-5477-9aaa-bdb55351a84a', 'cf0958fb-a5ff-509d-9724-a7dc4dfbc1a1', 'parent');
  perform pg_temp.rel('19672258-5c6b-5477-9aaa-bdb55351a84a', '5e9c05e2-54d1-57aa-8ce3-ec7ebb6a8ca2', 'parent');
  perform pg_temp.rel('cf0958fb-a5ff-509d-9724-a7dc4dfbc1a1', '56c2ec65-ffe6-5a20-aa1b-85cd980d3982', 'parent');
  perform pg_temp.rel('5e9c05e2-54d1-57aa-8ce3-ec7ebb6a8ca2', 'f1013b87-c265-51f3-8c83-f106e12f85e6', 'parent');
  perform pg_temp.rel('f1013b87-c265-51f3-8c83-f106e12f85e6', 'ef3660c4-f8d0-5eff-94ce-ddb72490ca3e', 'parent');
  perform pg_temp.rel('f1013b87-c265-51f3-8c83-f106e12f85e6', '173bef4f-7238-5726-a9da-409b9be632be', 'parent');
  perform pg_temp.rel('f1013b87-c265-51f3-8c83-f106e12f85e6', 'a8cb693d-08eb-5b0e-9c8c-de1484684944', 'parent');
  perform pg_temp.rel('f1013b87-c265-51f3-8c83-f106e12f85e6', 'fdfb024f-93b2-5578-902c-b82b05c8a252', 'parent');
  perform pg_temp.rel('a8cb693d-08eb-5b0e-9c8c-de1484684944', '06502976-f6f0-5494-b618-43fff6cf7442', 'parent');
  perform pg_temp.rel('a8cb693d-08eb-5b0e-9c8c-de1484684944', 'a0b508f0-c912-5871-b641-955753a1508f', 'parent');
  perform pg_temp.rel('a0b508f0-c912-5871-b641-955753a1508f', '1452df01-e137-5a0e-9249-601ed275e8f9', 'parent');
  perform pg_temp.rel('a0b508f0-c912-5871-b641-955753a1508f', '46c5c9b4-f049-5b95-bc96-609f4dc658ae', 'parent');
  raise notice 'schema_v123 : % membres ajoutés.', 15;
end $$;
