-- arbres_v175.sql — Belgique (Valois-Bourgogne)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Valois-Bourgogne » (ducs de Bourgogne, rattaché à la Belgique). Source : page « House of Valois-Burgundy » (anglais).
-- Seules les filiations écrites sur la page sont saisies (Jean II → Philippe le Hardi → Jean sans Peur → Philippe le Bon → Charles le Téméraire → Marie). Naissances non indiquées ; seule la mort de Charles le Téméraire (janvier 1477) est écrite. Jean II de Nevers et Charlotte de Rethel sont cités sans lien avec les ducs : non ajoutés.
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
  if exists (select 1 from public.genealogy_members where id = 'b748a0ed-0862-5f3e-a44d-743d66c44dbf') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Valois-Bourgogne » (BEL)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'BEL' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour BEL : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Valois-Bourgogne';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('8a093470-239f-5a5e-a280-57c011c0aeb6', cat_id, 'country', 'BEL', top, 'Valois-Bourgogne', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '8a093470-239f-5a5e-a280-57c011c0aeb6';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'country', 'BEL', 'genealogy', 'Valois-Bourgogne', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b748a0ed-0862-5f3e-a44d-743d66c44dbf', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Philippe VI de France', null, null, null, 'Roi de France, père de Jean II', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy', 980, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('797bd2c4-5102-51be-a5d1-2607dfa17f66', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Jean II de France', null, null, null, 'Roi de France, duc de Bourgogne (1361-1363)', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy - règne 1350-1364 ; duc de Bourgogne 1361-1363', 980, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('862c91eb-4d63-5571-ae64-157d45c08803', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Bonne de Luxembourg', null, null, null, 'Épouse de Jean II (m. 1332)', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy', 490, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3fa88d2c-f9a2-5545-b103-d25d8775265d', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Philippe le Hardi', null, null, null, 'Duc de Bourgogne (1363-1404)', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy', 735, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5fd64f13-2544-5284-8de3-56a13f9c1836', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Marguerite III de Flandre', null, null, null, 'Épouse de Philippe le Hardi (m. 1369)', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy', 245, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4a30e038-8d0a-5c12-83ce-8f18ee0f4fc4', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Jean sans Peur', null, null, null, 'Duc de Bourgogne (1404-1419)', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy', 490, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('afbdc73f-4c5d-5434-acc7-564fb20c3a04', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Marguerite de Bavière', null, null, null, 'Épouse de Jean sans Peur (m. 1385)', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e7557023-d810-5a19-8156-688155f75d1d', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Philippe le Bon', null, null, null, 'Duc de Bourgogne (1419-1467)', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy', 245, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('666d47aa-cdfa-514a-b1d5-1d67d50741f9', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Isabelle de Portugal', null, null, null, 'Mère de Charles le Téméraire', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy', 1480, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('187785de-02bd-55c9-a528-f9f9e52f7be2', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Charles le Téméraire', null, null, 1477, 'Duc de Bourgogne (1467-1477)', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy - tué en janvier 1477', 863, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a68e4485-83da-5736-9647-c8c381864235', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Isabelle de Bourbon', null, null, null, 'Seconde épouse de Charles le Téméraire, mère de Marie', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy', 373, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cab4c411-7bad-510a-a558-e9ba6b0eef6b', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Marie de Bourgogne', null, null, null, 'Duchesse de Bourgogne (1477-1482)', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy', 618, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4929dab1-5917-5e74-bd71-2ec2b6a146d6', 'entry', '0a4f48be-e04e-56ef-8ba8-6e8179e890bf', 'Maximilien Ier d''Autriche', null, null, null, 'Époux de Marie (m. 1477)', 'Valois-Bourgogne', 'Sources : https://en.wikipedia.org/wiki/House_of_Valois-Burgundy', 128, 3840, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('b748a0ed-0862-5f3e-a44d-743d66c44dbf', '797bd2c4-5102-51be-a5d1-2607dfa17f66', 'parent');
  perform pg_temp.rel('797bd2c4-5102-51be-a5d1-2607dfa17f66', '3fa88d2c-f9a2-5545-b103-d25d8775265d', 'parent');
  perform pg_temp.rel('862c91eb-4d63-5571-ae64-157d45c08803', '3fa88d2c-f9a2-5545-b103-d25d8775265d', 'parent');
  perform pg_temp.rel('3fa88d2c-f9a2-5545-b103-d25d8775265d', '4a30e038-8d0a-5c12-83ce-8f18ee0f4fc4', 'parent');
  perform pg_temp.rel('5fd64f13-2544-5284-8de3-56a13f9c1836', '4a30e038-8d0a-5c12-83ce-8f18ee0f4fc4', 'parent');
  perform pg_temp.rel('4a30e038-8d0a-5c12-83ce-8f18ee0f4fc4', 'e7557023-d810-5a19-8156-688155f75d1d', 'parent');
  perform pg_temp.rel('afbdc73f-4c5d-5434-acc7-564fb20c3a04', 'e7557023-d810-5a19-8156-688155f75d1d', 'parent');
  perform pg_temp.rel('e7557023-d810-5a19-8156-688155f75d1d', '187785de-02bd-55c9-a528-f9f9e52f7be2', 'parent');
  perform pg_temp.rel('666d47aa-cdfa-514a-b1d5-1d67d50741f9', '187785de-02bd-55c9-a528-f9f9e52f7be2', 'parent');
  perform pg_temp.rel('187785de-02bd-55c9-a528-f9f9e52f7be2', 'cab4c411-7bad-510a-a558-e9ba6b0eef6b', 'parent');
  perform pg_temp.rel('a68e4485-83da-5736-9647-c8c381864235', 'cab4c411-7bad-510a-a558-e9ba6b0eef6b', 'parent');
  perform pg_temp.rel('797bd2c4-5102-51be-a5d1-2607dfa17f66', '862c91eb-4d63-5571-ae64-157d45c08803', 'spouse');
  perform pg_temp.rel('3fa88d2c-f9a2-5545-b103-d25d8775265d', '5fd64f13-2544-5284-8de3-56a13f9c1836', 'spouse');
  perform pg_temp.rel('4a30e038-8d0a-5c12-83ce-8f18ee0f4fc4', 'afbdc73f-4c5d-5434-acc7-564fb20c3a04', 'spouse');
  perform pg_temp.rel('187785de-02bd-55c9-a528-f9f9e52f7be2', 'a68e4485-83da-5736-9647-c8c381864235', 'spouse');
  perform pg_temp.rel('cab4c411-7bad-510a-a558-e9ba6b0eef6b', '4929dab1-5917-5e74-bd71-2ec2b6a146d6', 'spouse');
  raise notice 'schema_v175 : % membres ajoutés.', 13;
end $$;
