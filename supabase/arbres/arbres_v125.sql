-- arbres_v125.sql — Tunisie (Husseinites)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Husseinites » (Tunisie) : 19 beys de Tunis, de Husayn Ier à Muhammad VIII al-Amin. Chaque fiche porte l'adresse de la page Wikipédia (anglais) « List of beys of Tunis » dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Liens « famille » (non parent-enfant direct) : Abu l-Hasan Ali Ier est le neveu de Husayn Ier ; Muhammad VI al-Habib est le cousin de Muhammad V (la page ne donne pas leurs parents).
-- Husayn Ier : naissance 1669 (liste des beys) contre 1675 (page de la dynastie husseinite) ; 1669 retenu.
-- Dates en année chrétienne (seule l'année est gardée).
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
  if exists (select 1 from public.genealogy_members where id = 'f567d487-3aeb-5b34-9cda-5ae0324584fe') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Husseinites » (TUN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'TUN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour TUN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Husseinites';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('72614ba0-0fc3-5d25-84e2-5ecba8f75784', cat_id, 'country', 'TUN', top, 'Husseinites', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '72614ba0-0fc3-5d25-84e2-5ecba8f75784';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('7e49d884-5e98-5d9e-b324-2863c411f1fa', 'country', 'TUN', 'genealogy', 'Husseinites', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f567d487-3aeb-5b34-9cda-5ae0324584fe', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Husayn Ier ben Ali', null, 1669, 1740, 'Fondateur de la dynastie husseinite, bey de Tunis (1705-1735)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis - naissance 1669 (liste) ou 1675 (page de la dynastie)', 805, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('dfe53496-4f11-55ed-abef-a5e3342a0b3a', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Ali Ier', null, 1688, 1756, 'Bey de Tunis (1735-1756)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 3753, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('33ec4888-fe15-5b1e-9f63-6b8abb1e52ff', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Muhammad Ier ar-Rachid', null, 1710, 1759, 'Bey de Tunis (1756-1759)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 468, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('863eec54-afbf-5c4c-8d9c-cfbbc0f53464', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Ali II', null, 1712, 1782, 'Bey de Tunis (1759-1782)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 1049, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('661d7a30-a78c-5f9f-99d8-371d135ceb2f', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Hammouda ben Ali', null, 1759, 1814, 'Bey de Tunis (1782-1814)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 968, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f56cd046-6d92-5785-a992-26ea6fb32f96', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Uthman ben Ali', null, 1763, 1814, 'Bey de Tunis (sept.-déc. 1814)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 1468, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('029f41ca-27fe-5036-b5f0-fdca474e138f', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Mahmoud ben Muhammad', null, 1757, 1824, 'Bey de Tunis (1814-1824)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 468, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c892ae99-7b49-585e-8be6-486b7c4e3a12', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Husayn II', null, 1784, 1835, 'Bey de Tunis (1824-1835)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 850, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('744d8ad1-8bd0-5f29-a12b-aabf648bd99b', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Mustafa ben Mahmoud', null, 1786, 1837, 'Bey de Tunis (1835-1837)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2ec57b64-d145-5189-91f5-4ce9414b39d6', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Ahmad Ier', null, 1806, 1855, 'Bey de Tunis (1837-1855)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('16db284f-6505-51b4-beb8-ce61d19f3f12', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Muhammad II', null, 1811, 1859, 'Bey de Tunis (1855-1859)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8b1cb4b5-acb2-5b74-90ff-5844fab76e53', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Muhammad III as-Sadiq', null, 1813, 1882, 'Bey de Tunis (1859-1882)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 1000, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('15d6072a-2300-5375-bf78-d14f5859e242', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Ali III', null, 1817, 1902, 'Bey de Tunis (1882-1902)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 1500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b890fb38-582a-508d-ade5-bb83e37388e2', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Muhammad IV al-Hadi', null, 1855, 1906, 'Bey de Tunis (1902-1906)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 1753, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fee87e98-5231-5e25-885e-c89764dea2b1', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Muhammad V an-Nasir', null, 1855, 1922, 'Bey de Tunis (1906-1922)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 500, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8cb9d84a-03d1-5d02-9021-21788d144380', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Muhammad VI al-Habib', null, 1858, 1929, 'Bey de Tunis (1922-1929)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 2753, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('66e4d1f9-0e5c-5cf3-9942-aad9b3885047', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Ahmad II', null, 1862, 1942, 'Bey de Tunis (1929-1942)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 1253, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('78dc3230-0462-5278-97d9-6405cb94988d', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Muhammad VII al-Munsif', null, 1881, 1948, 'Bey de Tunis (1942-1943)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f77ec2ac-e61c-50cd-a25f-b855a91dbf10', 'entry', '7e49d884-5e98-5d9e-b324-2863c411f1fa', 'Muhammad VIII al-Amin', null, 1881, 1962, 'Dernier bey de Tunis (1943-1957)', 'Husseinites', 'Sources : https://en.wikipedia.org/wiki/List_of_beys_of_Tunis', 2753, 4480, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('f567d487-3aeb-5b34-9cda-5ae0324584fe', '33ec4888-fe15-5b1e-9f63-6b8abb1e52ff', 'parent');
  perform pg_temp.rel('f567d487-3aeb-5b34-9cda-5ae0324584fe', '863eec54-afbf-5c4c-8d9c-cfbbc0f53464', 'parent');
  perform pg_temp.rel('863eec54-afbf-5c4c-8d9c-cfbbc0f53464', '661d7a30-a78c-5f9f-99d8-371d135ceb2f', 'parent');
  perform pg_temp.rel('863eec54-afbf-5c4c-8d9c-cfbbc0f53464', 'f56cd046-6d92-5785-a992-26ea6fb32f96', 'parent');
  perform pg_temp.rel('33ec4888-fe15-5b1e-9f63-6b8abb1e52ff', '029f41ca-27fe-5036-b5f0-fdca474e138f', 'parent');
  perform pg_temp.rel('029f41ca-27fe-5036-b5f0-fdca474e138f', 'c892ae99-7b49-585e-8be6-486b7c4e3a12', 'parent');
  perform pg_temp.rel('029f41ca-27fe-5036-b5f0-fdca474e138f', '744d8ad1-8bd0-5f29-a12b-aabf648bd99b', 'parent');
  perform pg_temp.rel('744d8ad1-8bd0-5f29-a12b-aabf648bd99b', '2ec57b64-d145-5189-91f5-4ce9414b39d6', 'parent');
  perform pg_temp.rel('c892ae99-7b49-585e-8be6-486b7c4e3a12', '16db284f-6505-51b4-beb8-ce61d19f3f12', 'parent');
  perform pg_temp.rel('c892ae99-7b49-585e-8be6-486b7c4e3a12', '8b1cb4b5-acb2-5b74-90ff-5844fab76e53', 'parent');
  perform pg_temp.rel('c892ae99-7b49-585e-8be6-486b7c4e3a12', '15d6072a-2300-5375-bf78-d14f5859e242', 'parent');
  perform pg_temp.rel('15d6072a-2300-5375-bf78-d14f5859e242', 'b890fb38-582a-508d-ade5-bb83e37388e2', 'parent');
  perform pg_temp.rel('16db284f-6505-51b4-beb8-ce61d19f3f12', 'fee87e98-5231-5e25-885e-c89764dea2b1', 'parent');
  perform pg_temp.rel('15d6072a-2300-5375-bf78-d14f5859e242', '66e4d1f9-0e5c-5cf3-9942-aad9b3885047', 'parent');
  perform pg_temp.rel('fee87e98-5231-5e25-885e-c89764dea2b1', '78dc3230-0462-5278-97d9-6405cb94988d', 'parent');
  perform pg_temp.rel('8cb9d84a-03d1-5d02-9021-21788d144380', 'f77ec2ac-e61c-50cd-a25f-b855a91dbf10', 'parent');
  perform pg_temp.rel('f567d487-3aeb-5b34-9cda-5ae0324584fe', 'dfe53496-4f11-55ed-abef-a5e3342a0b3a', 'family');
  perform pg_temp.rel('fee87e98-5231-5e25-885e-c89764dea2b1', '8cb9d84a-03d1-5d02-9021-21788d144380', 'family');
  raise notice 'schema_v125 : % membres ajoutés.', 19;
end $$;
