-- arbres_v131.sql — Bhoutan (Wangchuck)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Wangchuck » (Bhoutan) : 6 personnes de Jigme Namgyal au roi actuel. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Pages lues pour chaque personne sauf Jigme Dorji (père confirmé par la page de Jigme Singye, ses dates viennent de la page de la dynastie). Ugyen Wangchuck : né en 1862 (sa page) contre 1861 (page de la dynastie) ; 1862 retenu. Jigme Singye et Jigme Khesar : vivants.
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
  if exists (select 1 from public.genealogy_members where id = '4db1d4f7-eb5b-5902-9c46-0aa22d17b84f') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Wangchuck » (BTN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'BTN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour BTN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Wangchuck';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('4733f8d6-1efa-5ed3-9191-dc6acc614172', cat_id, 'country', 'BTN', top, 'Wangchuck', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '4733f8d6-1efa-5ed3-9191-dc6acc614172';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('d749c399-bd4c-5f0d-ad47-d03a4e97dd77', 'country', 'BTN', 'genealogy', 'Wangchuck', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4db1d4f7-eb5b-5902-9c46-0aa22d17b84f', 'entry', 'd749c399-bd4c-5f0d-ad47-d03a4e97dd77', 'Jigme Namgyal', null, 1825, 1881, 'Dru Desi, père du premier roi', 'Wangchuck', 'Sources : https://en.wikipedia.org/wiki/Jigme_Namgyel', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1a503a0f-11c7-5ae7-a05b-6cfb07871ad9', 'entry', 'd749c399-bd4c-5f0d-ad47-d03a4e97dd77', 'Ugyen Wangchuck', null, 1862, 1926, 'Premier roi du Bhoutan (1907-1926)', 'Wangchuck', 'Sources : https://en.wikipedia.org/wiki/Ugyen_Wangchuck - naissance 1862 (sa page) ou 1861 (page de la dynastie)', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0239e9f8-2eb3-5842-95ea-e2cd3ffba842', 'entry', 'd749c399-bd4c-5f0d-ad47-d03a4e97dd77', 'Jigme Wangchuck', null, 1905, 1952, 'Deuxième roi du Bhoutan (1926-1952)', 'Wangchuck', 'Sources : https://en.wikipedia.org/wiki/Jigme_Wangchuck', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('59687d96-4610-5099-88c5-fee5a5dd4e9d', 'entry', 'd749c399-bd4c-5f0d-ad47-d03a4e97dd77', 'Jigme Dorji Wangchuck', null, 1929, 1972, 'Troisième roi du Bhoutan (1952-1972)', 'Wangchuck', 'Sources : https://en.wikipedia.org/wiki/Wangchuck_dynasty', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a0acf6f2-50da-5d89-8388-30956f6d6d0a', 'entry', 'd749c399-bd4c-5f0d-ad47-d03a4e97dd77', 'Jigme Singye Wangchuck', null, 1955, null, 'Quatrième roi du Bhoutan (1972-2006)', 'Wangchuck', 'Sources : https://en.wikipedia.org/wiki/Jigme_Singye_Wangchuck', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e770a78d-6c95-5341-91bf-134670482e63', 'entry', 'd749c399-bd4c-5f0d-ad47-d03a4e97dd77', 'Jigme Khesar Namgyel Wangchuck', null, 1980, null, 'Cinquième roi du Bhoutan (depuis 2006)', 'Wangchuck', 'Sources : https://en.wikipedia.org/wiki/Wangchuck_dynasty', 0, 3200, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('4db1d4f7-eb5b-5902-9c46-0aa22d17b84f', '1a503a0f-11c7-5ae7-a05b-6cfb07871ad9', 'parent');
  perform pg_temp.rel('1a503a0f-11c7-5ae7-a05b-6cfb07871ad9', '0239e9f8-2eb3-5842-95ea-e2cd3ffba842', 'parent');
  perform pg_temp.rel('0239e9f8-2eb3-5842-95ea-e2cd3ffba842', '59687d96-4610-5099-88c5-fee5a5dd4e9d', 'parent');
  perform pg_temp.rel('59687d96-4610-5099-88c5-fee5a5dd4e9d', 'a0acf6f2-50da-5d89-8388-30956f6d6d0a', 'parent');
  perform pg_temp.rel('a0acf6f2-50da-5d89-8388-30956f6d6d0a', 'e770a78d-6c95-5341-91bf-134670482e63', 'parent');
  raise notice 'schema_v131 : % membres ajoutés.', 6;
end $$;
