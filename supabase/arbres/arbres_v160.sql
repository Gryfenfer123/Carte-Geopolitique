-- arbres_v160.sql — Kazakhstan (Khanat kazakh)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Khanat kazakh » (Kazakhstan). Sources : pages Wikipédia « Kazakh Khanate » et « List of Kazakh khans », notées dans chaque fiche et dans docs/sources/arbres.md.
-- Seules les filiations écrites sur la page sont saisies : Kasym fils de Janibek ; Haqnazar fils de Kasym ; Shygai fils d'Adiq Sultan, lui-même fils de Janibek (Adiq non ajouté : lien « famille » Janibek→Shygai) ; Tauekel et Esim fils de Shygai. Les autres khans ne sont pas reliés par la page. Dates de règne de Kerei différentes selon les passages (1456-1473 / 1465-1480).
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
  if exists (select 1 from public.genealogy_members where id = 'b56b09a9-7304-5e20-bcf0-ef2f4f9123c6') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Khanat kazakh » (KAZ)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'KAZ' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour KAZ : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Khanat kazakh';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('7efebd1b-7774-5073-be6e-c4372e0fd784', cat_id, 'country', 'KAZ', top, 'Khanat kazakh', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '7efebd1b-7774-5073-be6e-c4372e0fd784';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('c4ff0d51-3a65-5d46-9f9a-6e38fab15bd0', 'country', 'KAZ', 'genealogy', 'Khanat kazakh', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b56b09a9-7304-5e20-bcf0-ef2f4f9123c6', 'entry', 'c4ff0d51-3a65-5d46-9f9a-6e38fab15bd0', 'Kerei Khan', null, null, null, 'Khan kazakh (1456-1473)', 'Khanat kazakh', 'Sources : https://en.wikipedia.org/wiki/Kerei_Khan', 2500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2266c751-5093-5c10-92b7-1d9516171ad1', 'entry', 'c4ff0d51-3a65-5d46-9f9a-6e38fab15bd0', 'Janibek Khan', null, null, null, 'Khan kazakh (1473-1480)', 'Khanat kazakh', 'Sources : https://en.wikipedia.org/wiki/Janybek_Khan', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('42e65548-3f74-5851-a6b9-499b6d3f835e', 'entry', 'c4ff0d51-3a65-5d46-9f9a-6e38fab15bd0', 'Kasym Khan', null, null, null, 'Khan kazakh (1511-1518)', 'Khanat kazakh', 'Sources : https://en.wikipedia.org/wiki/Kasym_Khan - fils de Janibek', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5ee9c639-7bd8-50f4-b72b-6b898cce4632', 'entry', 'c4ff0d51-3a65-5d46-9f9a-6e38fab15bd0', 'Haqnazar Khan', null, null, null, 'Khan kazakh (1538-1580)', 'Khanat kazakh', 'Sources : https://en.wikipedia.org/wiki/Kazakh_Khanate - fils de Kasym', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4609fe4a-f3de-50da-8a85-479cf9636a8c', 'entry', 'c4ff0d51-3a65-5d46-9f9a-6e38fab15bd0', 'Shygai Khan', null, null, null, 'Khan kazakh (1580-1582)', 'Khanat kazakh', 'Sources : https://en.wikipedia.org/wiki/Kazakh_Khanate - fils d''Adiq Sultan, petit-fils de Janibek', 1250, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('db7745b8-936c-575e-8500-d4647fb4659c', 'entry', 'c4ff0d51-3a65-5d46-9f9a-6e38fab15bd0', 'Tauekel Khan', null, null, null, 'Khan kazakh (1582-1598)', 'Khanat kazakh', 'Sources : https://en.wikipedia.org/wiki/Kazakh_Khanate - fils de Shygai', 1500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d50d5a92-9104-5bb6-9bee-66a425dae463', 'entry', 'c4ff0d51-3a65-5d46-9f9a-6e38fab15bd0', 'Esim Khan', null, null, null, 'Khan kazakh (1598-1628)', 'Khanat kazakh', 'Sources : https://en.wikipedia.org/wiki/Kazakh_Khanate - fils de Shygai', 1000, 640, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('2266c751-5093-5c10-92b7-1d9516171ad1', '42e65548-3f74-5851-a6b9-499b6d3f835e', 'parent');
  perform pg_temp.rel('42e65548-3f74-5851-a6b9-499b6d3f835e', '5ee9c639-7bd8-50f4-b72b-6b898cce4632', 'parent');
  perform pg_temp.rel('4609fe4a-f3de-50da-8a85-479cf9636a8c', 'db7745b8-936c-575e-8500-d4647fb4659c', 'parent');
  perform pg_temp.rel('4609fe4a-f3de-50da-8a85-479cf9636a8c', 'd50d5a92-9104-5bb6-9bee-66a425dae463', 'parent');
  perform pg_temp.rel('2266c751-5093-5c10-92b7-1d9516171ad1', '4609fe4a-f3de-50da-8a85-479cf9636a8c', 'family');
  raise notice 'schema_v160 : % membres ajoutés.', 7;
end $$;
