-- arbres_v122.sql — Bahreïn (Al Khalifa)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Al Khalifa » (Bahreïn) : 12 dirigeants. Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Pages individuelles lues : Isa ben Ali et Isa ben Salman ; les autres fiches viennent du tableau des dirigeants de la page « House of Khalifa », qui ne donne les dates de vie que pour Isa ben Ali, Hamad (1872-1942), Salman (1894-1961), Isa ben Salman et le roi Hamad.
-- Isa ben Salman : naissance 1933 (sa page) contre 1931 (tableau) ; 1933 retenu. Le tableau précise que les deux Hamad sont deux personnes. Le tableau donne seulement « Khalifa » comme père de Muhammad et Ali : lu comme Khalifa ben Salman (non vérifié).
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
  if exists (select 1 from public.genealogy_members where id = '62d7794c-2b1e-52f8-b53d-dfe1cea82330') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Al Khalifa » (BHR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'BHR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour BHR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Al Khalifa';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('158271b2-1b76-55d8-a5c0-e7fcaa0c0677', cat_id, 'country', 'BHR', top, 'Al Khalifa', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '158271b2-1b76-55d8-a5c0-e7fcaa0c0677';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('36e0e903-c871-5766-8d4a-83aa0d810574', 'country', 'BHR', 'genealogy', 'Al Khalifa', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('62d7794c-2b1e-52f8-b53d-dfe1cea82330', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Ahmad ben Muhammad (al-Fateh)', null, null, 1795, 'Premier hakim de Bahreïn (1783-1795)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/House_of_Khalifa - mort 1795 (tableau) ou 1796 (texte de la page)', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('033fcc13-df04-5e6f-93d9-edfc2a8a8cba', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Salman ben Ahmad', null, null, null, 'Co-régent de Bahreïn (1795-1825)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/House_of_Khalifa', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('41f4e967-685c-5075-8242-522d989c5334', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Abdullah ben Ahmad', null, null, null, 'Co-régent de Bahreïn (1795-1843)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/House_of_Khalifa', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d4026e55-f03b-5768-8f99-8a169fa29501', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Khalifa ben Salman', null, null, null, 'Co-régent de Bahreïn (1825-1834)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/House_of_Khalifa', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('287543da-ee29-5587-8893-55a9ac932fc4', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Muhammad ben Khalifa', null, null, null, 'Hakim de Bahreïn (1834-1868)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/House_of_Khalifa', 750, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('87f79390-2748-5be4-978f-a793874dbd11', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Ali ben Khalifa', null, null, null, 'Hakim de Bahreïn (1868-1869)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/House_of_Khalifa', 250, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('505bb7e4-577e-503d-bf9b-d6251a4dca47', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Muhammad ben Abdullah', null, null, 1877, 'Hakim de Bahreïn (sept.-déc. 1869)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/House_of_Khalifa', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ea70964c-2096-5c9c-9394-e3b29516fcfa', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Isa ben Ali', null, 1848, 1932, 'Hakim de Bahreïn (1869-1923)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/Isa_bin_Ali_Al_Khalifa', 250, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('59182298-4fe1-5424-b7d5-bdf2fd260d90', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Hamad ben Isa', null, 1872, 1942, 'Hakim de Bahreïn (1923-1942)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/House_of_Khalifa', 250, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bff5b905-acdf-5f47-b750-3a52f39af065', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Salman ben Hamad', null, 1894, 1961, 'Hakim de Bahreïn (1942-1961)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/House_of_Khalifa', 250, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b92b2f93-047b-5b7d-9738-3c719fbc8378', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Isa ben Salman', null, 1933, 1999, 'Émir de Bahreïn (1961-1999)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/Isa_bin_Salman_Al_Khalifa', 250, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('896d4809-7753-553b-a436-aa6677a5c47a', 'entry', '36e0e903-c871-5766-8d4a-83aa0d810574', 'Hamad ben Isa (roi)', null, 1950, null, 'Roi de Bahreïn (depuis 1999)', 'Al Khalifa', 'Sources : https://en.wikipedia.org/wiki/House_of_Khalifa', 250, 5120, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('62d7794c-2b1e-52f8-b53d-dfe1cea82330', '033fcc13-df04-5e6f-93d9-edfc2a8a8cba', 'parent');
  perform pg_temp.rel('62d7794c-2b1e-52f8-b53d-dfe1cea82330', '41f4e967-685c-5075-8242-522d989c5334', 'parent');
  perform pg_temp.rel('033fcc13-df04-5e6f-93d9-edfc2a8a8cba', 'd4026e55-f03b-5768-8f99-8a169fa29501', 'parent');
  perform pg_temp.rel('d4026e55-f03b-5768-8f99-8a169fa29501', '287543da-ee29-5587-8893-55a9ac932fc4', 'parent');
  perform pg_temp.rel('d4026e55-f03b-5768-8f99-8a169fa29501', '87f79390-2748-5be4-978f-a793874dbd11', 'parent');
  perform pg_temp.rel('41f4e967-685c-5075-8242-522d989c5334', '505bb7e4-577e-503d-bf9b-d6251a4dca47', 'parent');
  perform pg_temp.rel('87f79390-2748-5be4-978f-a793874dbd11', 'ea70964c-2096-5c9c-9394-e3b29516fcfa', 'parent');
  perform pg_temp.rel('ea70964c-2096-5c9c-9394-e3b29516fcfa', '59182298-4fe1-5424-b7d5-bdf2fd260d90', 'parent');
  perform pg_temp.rel('59182298-4fe1-5424-b7d5-bdf2fd260d90', 'bff5b905-acdf-5f47-b750-3a52f39af065', 'parent');
  perform pg_temp.rel('bff5b905-acdf-5f47-b750-3a52f39af065', 'b92b2f93-047b-5b7d-9738-3c719fbc8378', 'parent');
  perform pg_temp.rel('b92b2f93-047b-5b7d-9738-3c719fbc8378', '896d4809-7753-553b-a436-aa6677a5c47a', 'parent');
  raise notice 'schema_v122 : % membres ajoutés.', 12;
end $$;
