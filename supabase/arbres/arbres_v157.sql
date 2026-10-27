-- arbres_v157.sql — Yémen (Rasoulides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Rasoulides » (Yémen) : 4 personnes en deux couples père-fils. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Page « Rasulid dynasty » : seules deux filiations sont indiquées (Yusuf I fils d'Umar I ; Ismail I fils d'al-Abbas). Les autres sultans ne sont pas reliés par la page et ne sont pas ajoutés. Les dates de règne de la liste et du texte divergent parfois.
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
  if exists (select 1 from public.genealogy_members where id = '5a82856f-362b-518a-8fb7-5b0217e2f9dc') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Rasoulides » (YEM)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'YEM' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour YEM : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Rasoulides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('994f6d50-0197-501f-b4ad-bc6c0c9cf7fa', cat_id, 'country', 'YEM', top, 'Rasoulides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '994f6d50-0197-501f-b4ad-bc6c0c9cf7fa';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('4498ec05-8b80-5867-98d8-3e0f25d3df06', 'country', 'YEM', 'genealogy', 'Rasoulides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5a82856f-362b-518a-8fb7-5b0217e2f9dc', 'entry', '4498ec05-8b80-5867-98d8-3e0f25d3df06', 'Al-Mansur Umar I', null, null, 1249, 'Premier sultan rasoulide du Yémen (1229-1249)', 'Rasoulides', 'Sources : https://en.wikipedia.org/wiki/Rasulid_dynasty - assassiné en 1249', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fdafb7a7-052a-53e2-ac3a-37059530151b', 'entry', '4498ec05-8b80-5867-98d8-3e0f25d3df06', 'Al-Muzaffar Yusuf I', null, null, 1295, 'Sultan rasoulide (1249-1295)', 'Rasoulides', 'Sources : https://en.wikipedia.org/wiki/Rasulid_dynasty - fils d''Umar I', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('741aee16-59bd-5648-82ed-aaf7122a4b43', 'entry', '4498ec05-8b80-5867-98d8-3e0f25d3df06', 'Al-Afdal al-Abbas', null, null, null, 'Sultan rasoulide (1363-1377)', 'Rasoulides', 'Sources : https://en.wikipedia.org/wiki/Rasulid_dynasty', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('401acfdd-d100-5f27-aed5-c3ed17f25462', 'entry', '4498ec05-8b80-5867-98d8-3e0f25d3df06', 'Al-Ashraf Ismail I', null, null, null, 'Sultan rasoulide (1377-1400)', 'Rasoulides', 'Sources : https://en.wikipedia.org/wiki/Rasulid_dynasty - fils d''al-Abbas ; fin de règne 1400 ou 1401 selon la page', 1000, 640, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('5a82856f-362b-518a-8fb7-5b0217e2f9dc', 'fdafb7a7-052a-53e2-ac3a-37059530151b', 'parent');
  perform pg_temp.rel('741aee16-59bd-5648-82ed-aaf7122a4b43', '401acfdd-d100-5f27-aed5-c3ed17f25462', 'parent');
  raise notice 'schema_v157 : % membres ajoutés.', 4;
end $$;
