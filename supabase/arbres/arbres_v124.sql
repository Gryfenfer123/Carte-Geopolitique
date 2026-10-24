-- arbres_v124.sql — Oman (Al Said)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Al Said » (Oman) : 15 sultans et princes. Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Pages individuelles lues : Taimur, Said bin Taimur, Qaboos, Tariq, Haitham ; les autres fiches viennent de la liste des dirigeants d'Oman.
-- Non saisi : Azzan ben Qays (1868-1871, usurpateur hors de la lignée directe, père non indiqué). Dans la liste, les règnes de Said ben Sultan et Salim ben Sultan se chevauchent (tous deux 1804).
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
  if exists (select 1 from public.genealogy_members where id = '49a4c64f-7bfc-5bf5-9416-84c12c06782f') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Al Said » (OMN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'OMN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour OMN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Al Said';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('6c3ce1a8-11a7-576d-9771-bb60cbbc82df', cat_id, 'country', 'OMN', top, 'Al Said', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '6c3ce1a8-11a7-576d-9771-bb60cbbc82df';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'country', 'OMN', 'genealogy', 'Al Said', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('49a4c64f-7bfc-5bf5-9416-84c12c06782f', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Ahmad ben Said', null, 1694, 1783, 'Fondateur de la dynastie, imam puis sultan (1749-1783)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Oman', 671, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c76a306f-5815-5093-89c9-fafc9c23af50', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Said ben Ahmad', null, 1741, 1811, 'Imam d''Oman (1783-1786)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Oman', 1000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('70b36867-91f9-53af-a9da-1ce1245df52b', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Hamad ben Said', null, null, 1792, 'Dirigeant d''Oman (1786-1792)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Oman', 1000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('65628024-475d-5a9f-9a72-031d5ec0e1df', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Sultan ben Ahmad', null, 1755, 1804, 'Sultan d''Oman (1792-1804)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Oman', 422, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c8ae0369-8ad2-5df6-973e-50aacf9b05a1', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Salim ben Sultan', null, 1790, 1821, 'Co-dirigeant d''Oman (1804-1806)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Oman', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1c859f86-a904-5bb3-b7aa-2765807e1d7c', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Saïd ben Sultan', null, 1791, 1856, 'Sultan d''Oman et de Zanzibar (1804-1856)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Oman', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0742ea74-970d-5026-a12b-74ecfd1fbde7', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Thuwaini ben Said', null, 1821, 1866, 'Sultan d''Oman (1856-1866)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Oman', 224, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('71004b5a-eb3a-5d4a-ad41-2371cfacc9c3', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Salim ben Thuwaini', null, 1839, 1876, 'Sultan d''Oman (1866-1868)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Oman', 224, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4401f34e-3cca-54ef-a186-d5d7be678153', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Turki ben Said', null, 1832, 1888, 'Sultan d''Oman (1871-1888)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Oman', 724, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('dc42d437-021a-5f8b-a26e-3ca69ec2a0fe', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Fayçal ben Turki', null, 1864, 1913, 'Sultan d''Oman (1888-1913)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/List_of_rulers_of_Oman', 724, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('68bf9709-78c9-56ee-89a0-b6b8d799e478', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Taimur ben Fayçal', null, 1886, 1965, 'Sultan d''Oman (1913-1932)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/Taimur_bin_Feisal', 724, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0009c086-b0c2-5cbc-8216-21b6ff5ca5df', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Saïd ben Taimur', null, 1910, 1972, 'Sultan d''Oman (1932-1970)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/Said_bin_Taimur', 459, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f893ae13-9416-53a3-a85b-5aeec56c325a', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Tariq ben Taimur', null, 1921, 1980, 'Premier ministre d''Oman, père du sultan Haïtham', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/Tariq_bin_Taimur', 959, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d35db6fc-c7d3-55a3-99ef-def83381d98e', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Qabous ben Saïd', null, 1940, 2020, 'Sultan d''Oman (1970-2020)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/Qaboos_bin_Said', 459, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('245b1c91-ae88-58e3-af02-4d3eaab33f6a', 'entry', '2cc403f0-02e1-5b0b-b78e-8e31f6adaa90', 'Haïtham ben Tariq', null, 1955, null, 'Sultan d''Oman (depuis 2020)', 'Al Said', 'Sources : https://en.wikipedia.org/wiki/Haitham_bin_Tariq', 959, 5120, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('49a4c64f-7bfc-5bf5-9416-84c12c06782f', 'c76a306f-5815-5093-89c9-fafc9c23af50', 'parent');
  perform pg_temp.rel('c76a306f-5815-5093-89c9-fafc9c23af50', '70b36867-91f9-53af-a9da-1ce1245df52b', 'parent');
  perform pg_temp.rel('49a4c64f-7bfc-5bf5-9416-84c12c06782f', '65628024-475d-5a9f-9a72-031d5ec0e1df', 'parent');
  perform pg_temp.rel('65628024-475d-5a9f-9a72-031d5ec0e1df', 'c8ae0369-8ad2-5df6-973e-50aacf9b05a1', 'parent');
  perform pg_temp.rel('65628024-475d-5a9f-9a72-031d5ec0e1df', '1c859f86-a904-5bb3-b7aa-2765807e1d7c', 'parent');
  perform pg_temp.rel('1c859f86-a904-5bb3-b7aa-2765807e1d7c', '0742ea74-970d-5026-a12b-74ecfd1fbde7', 'parent');
  perform pg_temp.rel('0742ea74-970d-5026-a12b-74ecfd1fbde7', '71004b5a-eb3a-5d4a-ad41-2371cfacc9c3', 'parent');
  perform pg_temp.rel('1c859f86-a904-5bb3-b7aa-2765807e1d7c', '4401f34e-3cca-54ef-a186-d5d7be678153', 'parent');
  perform pg_temp.rel('4401f34e-3cca-54ef-a186-d5d7be678153', 'dc42d437-021a-5f8b-a26e-3ca69ec2a0fe', 'parent');
  perform pg_temp.rel('dc42d437-021a-5f8b-a26e-3ca69ec2a0fe', '68bf9709-78c9-56ee-89a0-b6b8d799e478', 'parent');
  perform pg_temp.rel('68bf9709-78c9-56ee-89a0-b6b8d799e478', '0009c086-b0c2-5cbc-8216-21b6ff5ca5df', 'parent');
  perform pg_temp.rel('68bf9709-78c9-56ee-89a0-b6b8d799e478', 'f893ae13-9416-53a3-a85b-5aeec56c325a', 'parent');
  perform pg_temp.rel('0009c086-b0c2-5cbc-8216-21b6ff5ca5df', 'd35db6fc-c7d3-55a3-99ef-def83381d98e', 'parent');
  perform pg_temp.rel('f893ae13-9416-53a3-a85b-5aeec56c325a', '245b1c91-ae88-58e3-af02-4d3eaab33f6a', 'parent');
  raise notice 'schema_v124 : % membres ajoutés.', 15;
end $$;
