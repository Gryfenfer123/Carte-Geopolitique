-- arbres_v170.sql — Afghanistan (Ghurides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Ghurides » (Afghanistan). Sources : pages Wikipédia « Ghurid dynasty » et « Muhammad of Ghor » (anglais).
-- Seules les relations écrites sur les pages sont saisies : Sam Ier père de Ghiyath al-Din Muhammad et de Muhammad de Ghor ; Sayf al-Din Muhammad fils d'Ala al-Din Husayn ; Sayf al-Din Suri, Qutb al-Din Muhammad, Sam Ier et Ala al-Din Husayn sont dits frères (liens « famille » avec Sayf al-Din Suri) ; Fakhr al-Din Masud « oncle » de Ghiyath al-Din (lien « famille »). Naissance de Muhammad de Ghor : « vers 1144 » (estimation de la page).
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
  if exists (select 1 from public.genealogy_members where id = 'bb43357a-8433-539a-bc5c-07f6e68b2c2a') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Ghurides » (AFG)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'AFG' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour AFG : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Ghurides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('41e373f6-714f-52f8-9d67-2476d2d1324a', cat_id, 'country', 'AFG', top, 'Ghurides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '41e373f6-714f-52f8-9d67-2476d2d1324a';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('5895b3ab-4b72-57d5-87dd-a7e1ac35f621', 'country', 'AFG', 'genealogy', 'Ghurides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bb43357a-8433-539a-bc5c-07f6e68b2c2a', 'entry', '5895b3ab-4b72-57d5-87dd-a7e1ac35f621', 'Sayf al-Din Suri', null, null, null, 'Souverain ghouride (1146-1149)', 'Ghurides', 'Sources : https://en.wikipedia.org/wiki/Ghurid_dynasty - frère de Qutb al-Din Muhammad, de Baha al-Din Sam Ier et d''Ala al-Din Husayn', 2500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e6d2f555-128f-596a-a841-2cad5a057084', 'entry', '5895b3ab-4b72-57d5-87dd-a7e1ac35f621', 'Qutb al-Din Muhammad', null, null, 1149, 'Frère de Sayf al-Din Suri', 'Ghurides', 'Sources : https://en.wikipedia.org/wiki/Ghurid_dynasty', 3500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1e51d643-7384-5db1-a465-2da7572c5421', 'entry', '5895b3ab-4b72-57d5-87dd-a7e1ac35f621', 'Baha al-Din Sam Ier', null, null, 1149, 'Souverain ghouride (1149)', 'Ghurides', 'Sources : https://en.wikipedia.org/wiki/Ghurid_dynasty - mort en 1149', 250, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('df16c84a-4617-57a4-8811-535151bcd3be', 'entry', '5895b3ab-4b72-57d5-87dd-a7e1ac35f621', 'Ala al-Din Husayn', null, null, 1161, 'Souverain ghouride (1149-1161)', 'Ghurides', 'Sources : https://en.wikipedia.org/wiki/Ghurid_dynasty', 1500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a4ea176c-de1c-588f-839b-12fa100bb9e1', 'entry', '5895b3ab-4b72-57d5-87dd-a7e1ac35f621', 'Sayf al-Din Muhammad', null, null, 1163, 'Souverain ghouride (1161-1163)', 'Ghurides', 'Sources : https://en.wikipedia.org/wiki/Ghurid_dynasty - fils d''Ala al-Din Husayn', 1500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1c98386d-904d-5e48-ac6e-40d4958f66c1', 'entry', '5895b3ab-4b72-57d5-87dd-a7e1ac35f621', 'Fakhr al-Din Masud', null, null, null, 'Souverain à Bamiyan (1152-1163)', 'Ghurides', 'Sources : https://en.wikipedia.org/wiki/Ghurid_dynasty - oncle de Ghiyath al-Din Muhammad', 4500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bdeb705e-1953-5bda-b8cf-d14ea9e18750', 'entry', '5895b3ab-4b72-57d5-87dd-a7e1ac35f621', 'Ghiyath al-Din Muhammad', null, null, 1203, 'Souverain ghouride (1163-1203)', 'Ghurides', 'Sources : https://en.wikipedia.org/wiki/Ghurid_dynasty - mort le 13 mars 1203', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e45584dc-83b2-5828-bb51-c0b9f814af48', 'entry', '5895b3ab-4b72-57d5-87dd-a7e1ac35f621', 'Muhammad de Ghor', null, 1144, 1206, 'Souverain ghouride (1203-1206)', 'Ghurides', 'Sources : https://en.wikipedia.org/wiki/Muhammad_of_Ghor - naissance « vers 1144 » (estimation) ; mort le 15 mars 1206 ; frère cadet de Ghiyath al-Din Muhammad', 0, 2560, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('df16c84a-4617-57a4-8811-535151bcd3be', 'a4ea176c-de1c-588f-839b-12fa100bb9e1', 'parent');
  perform pg_temp.rel('1e51d643-7384-5db1-a465-2da7572c5421', 'bdeb705e-1953-5bda-b8cf-d14ea9e18750', 'parent');
  perform pg_temp.rel('1e51d643-7384-5db1-a465-2da7572c5421', 'e45584dc-83b2-5828-bb51-c0b9f814af48', 'parent');
  perform pg_temp.rel('bb43357a-8433-539a-bc5c-07f6e68b2c2a', 'e6d2f555-128f-596a-a841-2cad5a057084', 'family');
  perform pg_temp.rel('bb43357a-8433-539a-bc5c-07f6e68b2c2a', '1e51d643-7384-5db1-a465-2da7572c5421', 'family');
  perform pg_temp.rel('bb43357a-8433-539a-bc5c-07f6e68b2c2a', 'df16c84a-4617-57a4-8811-535151bcd3be', 'family');
  perform pg_temp.rel('1c98386d-904d-5e48-ac6e-40d4958f66c1', 'bdeb705e-1953-5bda-b8cf-d14ea9e18750', 'family');
  raise notice 'schema_v170 : % membres ajoutés.', 8;
end $$;
