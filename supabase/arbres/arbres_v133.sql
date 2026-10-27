-- arbres_v133.sql — Birmanie (Konbaung)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Konbaung » (Birmanie) : 10 rois et un prince, d'Alaungpaya à Thibaw. Chaque fiche porte l'adresse de la page Wikipédia (anglais) du roi dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Thado Minsaw, fils de Bodawpaya et père de Bagyidaw et Tharrawaddy : fiche sans dates (aucune page lue). Les rois du XIXe siècle sont tous reliés par les pages lues ; le père d'Alaungpaya (Min Nyo San) n'est pas saisi.
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
  if exists (select 1 from public.genealogy_members where id = '749672eb-b958-5e2c-9142-54d2b893c04c') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Konbaung » (MMR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'MMR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour MMR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Konbaung';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('84c6a9da-1bb7-5493-8dac-0ebb95e1e1b0', cat_id, 'country', 'MMR', top, 'Konbaung', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '84c6a9da-1bb7-5493-8dac-0ebb95e1e1b0';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('a735ac20-7db4-5b97-ab02-a2a93973d919', 'country', 'MMR', 'genealogy', 'Konbaung', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('749672eb-b958-5e2c-9142-54d2b893c04c', 'entry', 'a735ac20-7db4-5b97-ab02-a2a93973d919', 'Alaungpaya', null, 1714, 1760, 'Fondateur de la dynastie Konbaung (1752-1760)', 'Konbaung', 'Sources : https://en.wikipedia.org/wiki/Alaungpaya', 500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('65892269-4497-51fa-bcd8-3095b42657bc', 'entry', 'a735ac20-7db4-5b97-ab02-a2a93973d919', 'Naungdawgyi', null, 1734, 1763, 'Roi de Birmanie (1760-1763)', 'Konbaung', 'Sources : https://en.wikipedia.org/wiki/Naungdawgyi', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5157210f-260c-56b7-b247-970238bc7a9a', 'entry', 'a735ac20-7db4-5b97-ab02-a2a93973d919', 'Hsinbyushin', null, 1736, 1776, 'Roi de Birmanie (1763-1776)', 'Konbaung', 'Sources : https://en.wikipedia.org/wiki/Hsinbyushin', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9c341373-36a1-5233-a238-fa6929a3aaea', 'entry', 'a735ac20-7db4-5b97-ab02-a2a93973d919', 'Bodawpaya', null, 1745, 1819, 'Roi de Birmanie (1782-1819)', 'Konbaung', 'Sources : https://en.wikipedia.org/wiki/Bodawpaya', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6df6a56f-8146-5b62-beab-9e30bfbcf398', 'entry', 'a735ac20-7db4-5b97-ab02-a2a93973d919', 'Thado Minsaw', null, null, null, 'Prince, fils de Bodawpaya', 'Konbaung', 'Sources : https://en.wikipedia.org/wiki/Bodawpaya', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a993c349-bc1c-5a7f-bf37-9a2c053f383b', 'entry', 'a735ac20-7db4-5b97-ab02-a2a93973d919', 'Bagyidaw', null, 1784, 1846, 'Roi de Birmanie (1819-1837)', 'Konbaung', 'Sources : https://en.wikipedia.org/wiki/Bagyidaw', 250, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c81fd4be-9cf5-5e3c-8e42-c6d7445cef7d', 'entry', 'a735ac20-7db4-5b97-ab02-a2a93973d919', 'Tharrawaddy', null, 1787, 1846, 'Roi de Birmanie (1837-1846)', 'Konbaung', 'Sources : https://en.wikipedia.org/wiki/Tharrawaddy_Min', 750, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('24157bbb-03ee-532b-a718-c00fe8ff4408', 'entry', 'a735ac20-7db4-5b97-ab02-a2a93973d919', 'Pagan Min', null, 1811, 1880, 'Roi de Birmanie (1846-1853)', 'Konbaung', 'Sources : https://en.wikipedia.org/wiki/Pagan_Min', 1000, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a96062ef-2fc8-591f-bc27-2d25a63d8bb6', 'entry', 'a735ac20-7db4-5b97-ab02-a2a93973d919', 'Mindon', null, 1808, 1878, 'Roi de Birmanie (1853-1878)', 'Konbaung', 'Sources : https://en.wikipedia.org/wiki/Mindon_Min', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('412cbb5f-3c83-557c-a0f7-d79d36e16eeb', 'entry', 'a735ac20-7db4-5b97-ab02-a2a93973d919', 'Thibaw', null, 1859, 1916, 'Dernier roi de Birmanie (1878-1885)', 'Konbaung', 'Sources : https://en.wikipedia.org/wiki/Thibaw_Min', 500, 3200, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('749672eb-b958-5e2c-9142-54d2b893c04c', '65892269-4497-51fa-bcd8-3095b42657bc', 'parent');
  perform pg_temp.rel('749672eb-b958-5e2c-9142-54d2b893c04c', '5157210f-260c-56b7-b247-970238bc7a9a', 'parent');
  perform pg_temp.rel('749672eb-b958-5e2c-9142-54d2b893c04c', '9c341373-36a1-5233-a238-fa6929a3aaea', 'parent');
  perform pg_temp.rel('9c341373-36a1-5233-a238-fa6929a3aaea', '6df6a56f-8146-5b62-beab-9e30bfbcf398', 'parent');
  perform pg_temp.rel('6df6a56f-8146-5b62-beab-9e30bfbcf398', 'a993c349-bc1c-5a7f-bf37-9a2c053f383b', 'parent');
  perform pg_temp.rel('6df6a56f-8146-5b62-beab-9e30bfbcf398', 'c81fd4be-9cf5-5e3c-8e42-c6d7445cef7d', 'parent');
  perform pg_temp.rel('c81fd4be-9cf5-5e3c-8e42-c6d7445cef7d', '24157bbb-03ee-532b-a718-c00fe8ff4408', 'parent');
  perform pg_temp.rel('c81fd4be-9cf5-5e3c-8e42-c6d7445cef7d', 'a96062ef-2fc8-591f-bc27-2d25a63d8bb6', 'parent');
  perform pg_temp.rel('a96062ef-2fc8-591f-bc27-2d25a63d8bb6', '412cbb5f-3c83-557c-a0f7-d79d36e16eeb', 'parent');
  raise notice 'schema_v133 : % membres ajoutés.', 10;
end $$;
