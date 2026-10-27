-- arbres_v163.sql — Italie (Nerva-Antonins)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Nerva-Antonins » (Rome antique, rattaché à l'Italie). Source : page « Nerva–Antonine dynasty » (anglais). La page ne donne que les dates de mort de certains empereurs.
-- Succession par adoption : Nerva → Trajan → Hadrien → Antonin le Pieux → Marc Aurèle et Lucius Verus. Ces liens d'adoption sont saisis en « famille » (pas parent-enfant biologique). Seul Commodus est fils biologique (de Marc Aurèle). Faustine, Plotine et Sabine ne sont pas citées sur la page : non ajoutées.
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
  if exists (select 1 from public.genealogy_members where id = 'f1713bbb-542e-54c5-8741-043d0bf1cc3a') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Nerva-Antonins » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Nerva-Antonins';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('4eb39213-6c24-5ff6-b250-baebc383cf60', cat_id, 'country', 'ITA', top, 'Nerva-Antonins', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '4eb39213-6c24-5ff6-b250-baebc383cf60';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('88ff110e-a8ba-57aa-97d4-1a865d4cd8d4', 'country', 'ITA', 'genealogy', 'Nerva-Antonins', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f1713bbb-542e-54c5-8741-043d0bf1cc3a', 'entry', '88ff110e-a8ba-57aa-97d4-1a865d4cd8d4', 'Nerva', null, null, null, 'Empereur romain (96-98)', 'Nerva-Antonins', 'Sources : https://en.wikipedia.org/wiki/Nerva%E2%80%93Antonine_dynasty', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('798d544b-61a0-504f-ba89-36661d5ab22b', 'entry', '88ff110e-a8ba-57aa-97d4-1a865d4cd8d4', 'Trajan', null, null, null, 'Empereur romain (98-117)', 'Nerva-Antonins', 'Sources : https://en.wikipedia.org/wiki/Nerva%E2%80%93Antonine_dynasty - fils adoptif de Nerva', 2000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a2c8f0ee-5c87-55e4-9a2b-d582dd29fe90', 'entry', '88ff110e-a8ba-57aa-97d4-1a865d4cd8d4', 'Hadrien', null, null, 138, 'Empereur romain (117-138)', 'Nerva-Antonins', 'Sources : https://en.wikipedia.org/wiki/Nerva%E2%80%93Antonine_dynasty - fils adoptif de Trajan', 3000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('24f135d0-6276-5b75-aca7-053739955206', 'entry', '88ff110e-a8ba-57aa-97d4-1a865d4cd8d4', 'Antonin le Pieux', null, null, null, 'Empereur romain (138-161)', 'Nerva-Antonins', 'Sources : https://en.wikipedia.org/wiki/Nerva%E2%80%93Antonine_dynasty - fils adoptif d''Hadrien', 4000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ae059a85-0694-57e7-96f3-a1ae6a11d7ce', 'entry', '88ff110e-a8ba-57aa-97d4-1a865d4cd8d4', 'Marc Aurèle', null, null, 180, 'Empereur romain (161-180)', 'Nerva-Antonins', 'Sources : https://en.wikipedia.org/wiki/Nerva%E2%80%93Antonine_dynasty - fils adoptif d''Antonin le Pieux', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('eb5bfeed-edfd-52d4-ae0f-cce62c1df817', 'entry', '88ff110e-a8ba-57aa-97d4-1a865d4cd8d4', 'Lucius Verus', null, null, 169, 'Empereur romain (161-169)', 'Nerva-Antonins', 'Sources : https://en.wikipedia.org/wiki/Nerva%E2%80%93Antonine_dynasty - fils adoptif d''Antonin le Pieux', 5000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f3237645-3d63-5b86-b686-ee253ff7bfe2', 'entry', '88ff110e-a8ba-57aa-97d4-1a865d4cd8d4', 'Commode', null, null, 192, 'Empereur romain (177-192)', 'Nerva-Antonins', 'Sources : https://en.wikipedia.org/wiki/Nerva%E2%80%93Antonine_dynasty - fils biologique de Marc Aurèle', 0, 640, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('ae059a85-0694-57e7-96f3-a1ae6a11d7ce', 'f3237645-3d63-5b86-b686-ee253ff7bfe2', 'parent');
  perform pg_temp.rel('f1713bbb-542e-54c5-8741-043d0bf1cc3a', '798d544b-61a0-504f-ba89-36661d5ab22b', 'family');
  perform pg_temp.rel('798d544b-61a0-504f-ba89-36661d5ab22b', 'a2c8f0ee-5c87-55e4-9a2b-d582dd29fe90', 'family');
  perform pg_temp.rel('a2c8f0ee-5c87-55e4-9a2b-d582dd29fe90', '24f135d0-6276-5b75-aca7-053739955206', 'family');
  perform pg_temp.rel('24f135d0-6276-5b75-aca7-053739955206', 'ae059a85-0694-57e7-96f3-a1ae6a11d7ce', 'family');
  perform pg_temp.rel('24f135d0-6276-5b75-aca7-053739955206', 'eb5bfeed-edfd-52d4-ae0f-cce62c1df817', 'family');
  raise notice 'schema_v163 : % membres ajoutés.', 7;
end $$;
