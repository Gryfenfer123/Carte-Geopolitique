-- arbres_v156.sql — Azerbaïdjan (Aq Qoyunlu)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Aq Qoyunlu » (Azerbaïdjan) : 7 personnes. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Tout vient de la page « Aq Qoyunlu » : Khalil, Yaqub, Ughurlu Muhammad et Rustam sont fils d'Uzun Hasan (pour Rustam un passage dit fils de Maqsud) ; Baysungur fils de Yaqub ; Ahmad Bey fils d'Ughurlu Muhammad. Alvand, Sultan Murad, Mohammad et Qasim ne sont pas ajoutés (liens trop vagues). Qara Yuluk Uthman (fondateur) non ajouté : lien avec Uzun Hasan non indiqué. Aucune date de naissance.
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
  if exists (select 1 from public.genealogy_members where id = 'd1b27d13-41bf-5af7-9cc9-2ff8766b5571') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Aq Qoyunlu » (AZE)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'AZE' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour AZE : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Aq Qoyunlu';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('dca6ac63-b074-55a6-958c-08fb6e8fa576', cat_id, 'country', 'AZE', top, 'Aq Qoyunlu', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'dca6ac63-b074-55a6-958c-08fb6e8fa576';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('69029036-d9cf-55b5-85cc-5c23f1c6d0b2', 'country', 'AZE', 'genealogy', 'Aq Qoyunlu', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d1b27d13-41bf-5af7-9cc9-2ff8766b5571', 'entry', '69029036-d9cf-55b5-85cc-5c23f1c6d0b2', 'Uzun Hasan', null, null, 1478, 'Souverain Aq Qoyunlu (1452-1478)', 'Aq Qoyunlu', 'Sources : https://en.wikipedia.org/wiki/Aq_Qoyunlu - mort au début de 1478 ; pas d''année de naissance sur la page', 750, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c719402d-0a5e-5b33-aad5-76a1ed69965c', 'entry', '69029036-d9cf-55b5-85cc-5c23f1c6d0b2', 'Khalil Mirza', null, null, null, 'Souverain Aq Qoyunlu (quelques mois en 1478)', 'Aq Qoyunlu', 'Sources : https://en.wikipedia.org/wiki/Aq_Qoyunlu - fils d''Uzun Hasan', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8cbf81bf-6690-5a69-944f-a49c67bebc87', 'entry', '69029036-d9cf-55b5-85cc-5c23f1c6d0b2', 'Yaqub', null, null, null, 'Souverain Aq Qoyunlu (1478-1490)', 'Aq Qoyunlu', 'Sources : https://en.wikipedia.org/wiki/Aq_Qoyunlu - fils d''Uzun Hasan, frère cadet de Khalil', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9cd1a566-6ee2-5233-b413-5cfb6c098909', 'entry', '69029036-d9cf-55b5-85cc-5c23f1c6d0b2', 'Ughurlu Muhammad', null, null, null, 'Fils aîné d''Uzun Hasan', 'Aq Qoyunlu', 'Sources : https://en.wikipedia.org/wiki/Aq_Qoyunlu - fils aîné d''Uzun Hasan', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('eb970fd0-c7aa-5e07-9b61-4da3100c9aae', 'entry', '69029036-d9cf-55b5-85cc-5c23f1c6d0b2', 'Rustam', null, null, null, 'Souverain Aq Qoyunlu (1493-1497 ou 1478-1490 selon les passages)', 'Aq Qoyunlu', 'Sources : https://en.wikipedia.org/wiki/Aq_Qoyunlu - fils d''Uzun Hasan (un passage dit fils de Maqsud)', 1500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('40bcbdfa-eef0-5a00-b81a-e8b8da93b59b', 'entry', '69029036-d9cf-55b5-85cc-5c23f1c6d0b2', 'Baysungur', null, null, 1493, 'Souverain Aq Qoyunlu (détrôné en 1491)', 'Aq Qoyunlu', 'Sources : https://en.wikipedia.org/wiki/Aq_Qoyunlu - fils de Yaqub ; tué en 1493', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('421089ca-bb08-5fb5-889c-107403404aad', 'entry', '69029036-d9cf-55b5-85cc-5c23f1c6d0b2', 'Ahmad Bey', null, null, 1497, 'Souverain Aq Qoyunlu (1497)', 'Aq Qoyunlu', 'Sources : https://en.wikipedia.org/wiki/Aq_Qoyunlu - fils d''Ughurlu Muhammad ; mort en décembre 1497', 1000, 1280, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('d1b27d13-41bf-5af7-9cc9-2ff8766b5571', 'c719402d-0a5e-5b33-aad5-76a1ed69965c', 'parent');
  perform pg_temp.rel('d1b27d13-41bf-5af7-9cc9-2ff8766b5571', '8cbf81bf-6690-5a69-944f-a49c67bebc87', 'parent');
  perform pg_temp.rel('d1b27d13-41bf-5af7-9cc9-2ff8766b5571', '9cd1a566-6ee2-5233-b413-5cfb6c098909', 'parent');
  perform pg_temp.rel('d1b27d13-41bf-5af7-9cc9-2ff8766b5571', 'eb970fd0-c7aa-5e07-9b61-4da3100c9aae', 'parent');
  perform pg_temp.rel('8cbf81bf-6690-5a69-944f-a49c67bebc87', '40bcbdfa-eef0-5a00-b81a-e8b8da93b59b', 'parent');
  perform pg_temp.rel('9cd1a566-6ee2-5233-b413-5cfb6c098909', '421089ca-bb08-5fb5-889c-107403404aad', 'parent');
  raise notice 'schema_v156 : % membres ajoutés.', 7;
end $$;
