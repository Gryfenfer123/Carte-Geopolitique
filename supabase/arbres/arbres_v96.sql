-- arbres_v96.sql — Lituanie — Gediminides : de Gediminas à Vytautas et Švitrigaila, jusqu'à Jogaila
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Gediminides » (aucun n'existait). Jogaila (Ladislas II Jagellon), Casimir IV et Sophie de Lituanie (fille de Vytautas, arbre Riourikides) y sont affichés. Rien n'est supprimé.
-- Dates : connues par ailleurs (histoire de Lituanie), aucune page consultée pour ce lot ; les dates médiévales sont approximatives (notées).
-- Oulyana de Tver et Birutė viennent de familles sans arbre : placées ici et signalées.
-- Non fait : Mindaugas (lien avec Gediminas non établi), fils cadets de Gediminas, épouses de Vytautas, descendance de Švitrigaila et de Skirgaila.
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
  if exists (select 1 from public.genealogy_members where id = 'afb72856-5e9e-56e4-bc8f-97b7f4a661f5') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('ba967f1a-1d50-599c-a5e4-7101de90325a','f0684304-9584-55f5-bd0f-777479568e4a');
  if k <> 2 then raise exception 'Membres préexistants manquants (% sur 2) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Gediminides » (LTU)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'LTU' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour LTU : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Gediminides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('921dbb50-b1b5-5549-b47c-b6ff42b40238', cat_id, 'country', 'LTU', top, 'Gediminides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '921dbb50-b1b5-5549-b47c-b6ff42b40238';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('e719c0d9-be1d-53ad-b926-12531952ba9c', 'country', 'LTU', 'genealogy', 'Gediminides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('afb72856-5e9e-56e4-bc8f-97b7f4a661f5', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 'Gediminas', null, 1275, 1341, 'Grand-duc de Lituanie', 'Gediminides', 916, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('36883efb-79f8-53d1-845a-17ec2fb53f25', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 'Algirdas', null, 1296, 1377, 'Grand-duc de Lituanie', 'Gediminides', 490, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0361553a-00a5-5d41-9069-f84c6e1c2083', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 'Kęstutis', null, 1297, 1382, 'Grand-duc de Lituanie', 'Gediminides', 1333, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f0bcfad1-46a2-5aef-8047-6d412254a226', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 'Oulyana de Tver', null, 1325, 1392, 'Seconde épouse d''Algirdas, mère de Jogaila', 'Tver', 0, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d50d4549-e96d-52ff-87cf-ca322bf2a29b', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 'Skirgaila', null, 1354, 1397, 'Régent de Lituanie', 'Gediminides', 554, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('621634e9-0f1f-5267-94c3-5541d4eddcf3', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 'Švitrigaila', null, 1370, 1452, 'Grand-duc de Lituanie', 'Gediminides', 1054, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('56de5db5-1806-54e5-adad-c6b22d7b8089', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 'Birutė', null, null, null, 'Épouse de Kęstutis, mère de Vytautas', 'Palanga', 1823, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b59daa60-c927-5fb0-b5cd-c00701bba5ac', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 'Vytautas le Grand', null, 1350, 1430, 'Grand-duc de Lituanie', 'Gediminides', 1554, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('00d20cf3-9402-50d0-b23d-3ee99412802f', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 'Žygimantas Kęstutaitis', null, 1365, 1440, 'Grand-duc de Lituanie', 'Gediminides', 2054, 1920, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('afb72856-5e9e-56e4-bc8f-97b7f4a661f5', '36883efb-79f8-53d1-845a-17ec2fb53f25', 'parent');
  perform pg_temp.rel('afb72856-5e9e-56e4-bc8f-97b7f4a661f5', '0361553a-00a5-5d41-9069-f84c6e1c2083', 'parent');
  perform pg_temp.rel('36883efb-79f8-53d1-845a-17ec2fb53f25', 'f0bcfad1-46a2-5aef-8047-6d412254a226', 'spouse');
  perform pg_temp.rel('36883efb-79f8-53d1-845a-17ec2fb53f25', 'f0684304-9584-55f5-bd0f-777479568e4a', 'parent');
  perform pg_temp.rel('f0bcfad1-46a2-5aef-8047-6d412254a226', 'f0684304-9584-55f5-bd0f-777479568e4a', 'parent');
  perform pg_temp.rel('36883efb-79f8-53d1-845a-17ec2fb53f25', 'd50d4549-e96d-52ff-87cf-ca322bf2a29b', 'parent');
  perform pg_temp.rel('36883efb-79f8-53d1-845a-17ec2fb53f25', '621634e9-0f1f-5267-94c3-5541d4eddcf3', 'parent');
  perform pg_temp.rel('0361553a-00a5-5d41-9069-f84c6e1c2083', '56de5db5-1806-54e5-adad-c6b22d7b8089', 'spouse');
  perform pg_temp.rel('0361553a-00a5-5d41-9069-f84c6e1c2083', 'b59daa60-c927-5fb0-b5cd-c00701bba5ac', 'parent');
  perform pg_temp.rel('56de5db5-1806-54e5-adad-c6b22d7b8089', 'b59daa60-c927-5fb0-b5cd-c00701bba5ac', 'parent');
  perform pg_temp.rel('0361553a-00a5-5d41-9069-f84c6e1c2083', '00d20cf3-9402-50d0-b23d-3ee99412802f', 'parent');
  perform pg_temp.rel('56de5db5-1806-54e5-adad-c6b22d7b8089', '00d20cf3-9402-50d0-b23d-3ee99412802f', 'parent');
  perform pg_temp.rel('b59daa60-c927-5fb0-b5cd-c00701bba5ac', 'ba967f1a-1d50-599c-a5e4-7101de90325a', 'parent');
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f0684304-9584-55f5-bd0f-777479568e4a', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 54, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ba967f1a-1d50-599c-a5e4-7101de90325a', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 1554, 2560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('a32377f3-562b-5945-af4a-4ff060cf2ab9', 'entry', 'e719c0d9-be1d-53ad-b926-12531952ba9c', 3054, 3200, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v96 : % membres ajoutés.', 9;
end $$;
