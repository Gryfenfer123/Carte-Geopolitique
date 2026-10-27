-- arbres_v165.sql — Italie (Sévères)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Sévères » (Rome antique, rattaché à l'Italie). Source : page « Severan dynasty » (anglais).
-- Julia Domna et Julia Maesa sont dites sœurs. Élagabal et Sévère Alexandre sont cousins (leurs mères sont les filles de Maesa). Le texte rapporte aussi la rumeur, répandue par Maesa, qu'Élagabal serait un fils illégitime de Caracalla : non retenue comme filiation. Sévère Alexandre : naissance « v. 209 » (année saisie 209).
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
  if exists (select 1 from public.genealogy_members where id = 'acabe6e7-52dd-5456-b61e-71b9e5b471ab') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Sévères » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Sévères';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('da89085d-c99e-5bb8-a775-2abf7748e5f0', cat_id, 'country', 'ITA', top, 'Sévères', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'da89085d-c99e-5bb8-a775-2abf7748e5f0';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('2c2c359e-9cba-5cba-bc2a-0ccd89b1933a', 'country', 'ITA', 'genealogy', 'Sévères', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('acabe6e7-52dd-5456-b61e-71b9e5b471ab', 'entry', '2c2c359e-9cba-5cba-bc2a-0ccd89b1933a', 'Septime Sévère', null, 145, 211, 'Empereur romain (193-211)', 'Sévères', 'Sources : https://en.wikipedia.org/wiki/Severan_dynasty', 1995, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b72b1a81-45d7-55b3-8470-252b4003cf04', 'entry', '2c2c359e-9cba-5cba-bc2a-0ccd89b1933a', 'Julia Domna', null, null, null, 'Épouse de Septime Sévère', 'Sévères', 'Sources : https://en.wikipedia.org/wiki/Severan_dynasty', 1505, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e7757299-c499-5f7c-938f-4e4388044bdf', 'entry', '2c2c359e-9cba-5cba-bc2a-0ccd89b1933a', 'Caracalla', null, 188, 217, 'Empereur romain (règne 192-217 selon la page)', 'Sévères', 'Sources : https://en.wikipedia.org/wiki/Severan_dynasty - fils aîné de Septime Sévère', 1500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('28e75978-7528-57b2-bd25-dc4b8760173a', 'entry', '2c2c359e-9cba-5cba-bc2a-0ccd89b1933a', 'Geta', null, 189, 211, 'Empereur romain (211)', 'Sévères', 'Sources : https://en.wikipedia.org/wiki/Severan_dynasty - fils cadet de Septime Sévère', 2000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ebe11dea-6eb6-581a-bbb3-372055b2a483', 'entry', '2c2c359e-9cba-5cba-bc2a-0ccd89b1933a', 'Julia Maesa', null, null, null, 'Sœur de Julia Domna', 'Sévères', 'Sources : https://en.wikipedia.org/wiki/Severan_dynasty', 250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c091ec22-f5e8-54fc-9cf5-de6931f85361', 'entry', '2c2c359e-9cba-5cba-bc2a-0ccd89b1933a', 'Julia Soaemias', null, null, null, 'Fille de Maesa, mère d''Élagabal', 'Sévères', 'Sources : https://en.wikipedia.org/wiki/Severan_dynasty', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('73f19b1f-b485-5483-a2b7-6c61421589db', 'entry', '2c2c359e-9cba-5cba-bc2a-0ccd89b1933a', 'Julia Mamaea', null, null, null, 'Fille de Maesa, mère de Sévère Alexandre', 'Sévères', 'Sources : https://en.wikipedia.org/wiki/Severan_dynasty', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c5aef3a6-359e-5c7b-96e6-d66b9d94ffd4', 'entry', '2c2c359e-9cba-5cba-bc2a-0ccd89b1933a', 'Élagabal', null, 203, 222, 'Empereur romain (218-222)', 'Sévères', 'Sources : https://en.wikipedia.org/wiki/Severan_dynasty', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('86c8074e-7a57-5cbb-baf2-eff00bfe95b3', 'entry', '2c2c359e-9cba-5cba-bc2a-0ccd89b1933a', 'Sévère Alexandre', null, 209, 235, 'Empereur romain (222-235)', 'Sévères', 'Sources : https://en.wikipedia.org/wiki/Severan_dynasty - naissance « v. 209 »', 0, 1280, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('acabe6e7-52dd-5456-b61e-71b9e5b471ab', 'e7757299-c499-5f7c-938f-4e4388044bdf', 'parent');
  perform pg_temp.rel('acabe6e7-52dd-5456-b61e-71b9e5b471ab', '28e75978-7528-57b2-bd25-dc4b8760173a', 'parent');
  perform pg_temp.rel('b72b1a81-45d7-55b3-8470-252b4003cf04', 'e7757299-c499-5f7c-938f-4e4388044bdf', 'parent');
  perform pg_temp.rel('b72b1a81-45d7-55b3-8470-252b4003cf04', '28e75978-7528-57b2-bd25-dc4b8760173a', 'parent');
  perform pg_temp.rel('ebe11dea-6eb6-581a-bbb3-372055b2a483', 'c091ec22-f5e8-54fc-9cf5-de6931f85361', 'parent');
  perform pg_temp.rel('ebe11dea-6eb6-581a-bbb3-372055b2a483', '73f19b1f-b485-5483-a2b7-6c61421589db', 'parent');
  perform pg_temp.rel('c091ec22-f5e8-54fc-9cf5-de6931f85361', 'c5aef3a6-359e-5c7b-96e6-d66b9d94ffd4', 'parent');
  perform pg_temp.rel('73f19b1f-b485-5483-a2b7-6c61421589db', '86c8074e-7a57-5cbb-baf2-eff00bfe95b3', 'parent');
  perform pg_temp.rel('b72b1a81-45d7-55b3-8470-252b4003cf04', 'ebe11dea-6eb6-581a-bbb3-372055b2a483', 'family');
  perform pg_temp.rel('acabe6e7-52dd-5456-b61e-71b9e5b471ab', 'b72b1a81-45d7-55b3-8470-252b4003cf04', 'spouse');
  raise notice 'schema_v165 : % membres ajoutés.', 9;
end $$;
