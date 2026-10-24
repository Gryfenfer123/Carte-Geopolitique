-- arbres_v121.sql — Qatar (Al Thani)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Al Thani » (Qatar) : 8 émirs de Mohammed ben Thani à Tamim. Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Non saisis (aucune page lue) : Thani ben Mohammed (père de Mohammed ben Thani), Hamad ben Abdullah (père de Khalifa), Ahmad ben Mohammed. Khalifa (cousin d'Ahmad, mais non confirmé par une page lue) forme donc une branche séparée dans l'arbre.
-- Dates en année chrétienne telles que la page les donne ; « c. » = approximatif. Hamad ben Khalifa : la page indique 1952–2026.
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
  if exists (select 1 from public.genealogy_members where id = '006a975b-4724-5635-a9da-f28c20003115') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Al Thani » (QAT)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'QAT' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour QAT : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Al Thani';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('dce30dbf-1076-5e33-9520-406951d0254f', cat_id, 'country', 'QAT', top, 'Al Thani', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'dce30dbf-1076-5e33-9520-406951d0254f';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('bcc62c61-8c4e-5ff4-a5de-32f1a2192e78', 'country', 'QAT', 'genealogy', 'Al Thani', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('006a975b-4724-5635-a9da-f28c20003115', 'entry', 'bcc62c61-8c4e-5ff4-a5de-32f1a2192e78', 'Mohammed ben Thani', null, 1788, 1878, 'Cheikh de Doha, fondateur de la dynastie', 'Al Thani', 'Sources : https://en.wikipedia.org/wiki/Mohammed_bin_Thani — naissance c. 1788 ; règne 1851-1878 (l''encadré de succession dit 1876)', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cc2fab66-637b-5aad-b8d8-aa0f10ba4e91', 'entry', 'bcc62c61-8c4e-5ff4-a5de-32f1a2192e78', 'Jassim ben Mohammed', null, 1825, 1913, 'Fondateur de l''État du Qatar (1878-1913)', 'Al Thani', 'Sources : https://en.wikipedia.org/wiki/Jassim_bin_Mohammed_Al_Thani — naissance c. 1825', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1d1ad90d-6d82-5074-97e3-7b7eed8dc932', 'entry', 'bcc62c61-8c4e-5ff4-a5de-32f1a2192e78', 'Abdullah ben Jassim', null, 1880, 1957, 'Cheikh du Qatar (1913-1949)', 'Al Thani', 'Sources : https://en.wikipedia.org/wiki/Abdullah_bin_Jassim_Al_Thani', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('df58dfbc-7363-55ab-a63b-b79e6a8bc2ec', 'entry', 'bcc62c61-8c4e-5ff4-a5de-32f1a2192e78', 'Ali ben Abdullah', null, 1895, 1974, 'Cheikh du Qatar (1949-1960)', 'Al Thani', 'Sources : https://en.wikipedia.org/wiki/Ali_bin_Abdullah_Al_Thani', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2bf0c4e3-125e-59fc-9f5a-df68b7cca516', 'entry', 'bcc62c61-8c4e-5ff4-a5de-32f1a2192e78', 'Ahmad ben Ali', null, 1922, 1977, 'Émir du Qatar (1960-1972)', 'Al Thani', 'Sources : https://en.wikipedia.org/wiki/Ahmad_bin_Ali_Al_Thani', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fddaae8f-5434-5bac-9010-84496a81ff76', 'entry', 'bcc62c61-8c4e-5ff4-a5de-32f1a2192e78', 'Khalifa ben Hamad', null, 1932, 2016, 'Émir du Qatar (1972-1995)', 'Al Thani', 'Sources : https://en.wikipedia.org/wiki/Khalifa_bin_Hamad_Al_Thani — père Hamad ben Abdullah (non saisi)', 1000, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('253d2580-1f0c-54e7-888e-734079121e6c', 'entry', 'bcc62c61-8c4e-5ff4-a5de-32f1a2192e78', 'Hamad ben Khalifa', null, 1952, 2026, 'Émir du Qatar (1995-2013)', 'Al Thani', 'Sources : https://en.wikipedia.org/wiki/Hamad_bin_Khalifa_Al_Thani', 1000, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6e8eadbe-e856-5f07-969e-fa64ae171327', 'entry', 'bcc62c61-8c4e-5ff4-a5de-32f1a2192e78', 'Tamim ben Hamad', null, 1980, null, 'Émir du Qatar (depuis 2013)', 'Al Thani', 'Sources : https://en.wikipedia.org/wiki/Tamim_bin_Hamad_Al_Thani', 1000, 3840, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('006a975b-4724-5635-a9da-f28c20003115', 'cc2fab66-637b-5aad-b8d8-aa0f10ba4e91', 'parent');
  perform pg_temp.rel('cc2fab66-637b-5aad-b8d8-aa0f10ba4e91', '1d1ad90d-6d82-5074-97e3-7b7eed8dc932', 'parent');
  perform pg_temp.rel('1d1ad90d-6d82-5074-97e3-7b7eed8dc932', 'df58dfbc-7363-55ab-a63b-b79e6a8bc2ec', 'parent');
  perform pg_temp.rel('df58dfbc-7363-55ab-a63b-b79e6a8bc2ec', '2bf0c4e3-125e-59fc-9f5a-df68b7cca516', 'parent');
  perform pg_temp.rel('fddaae8f-5434-5bac-9010-84496a81ff76', '253d2580-1f0c-54e7-888e-734079121e6c', 'parent');
  perform pg_temp.rel('253d2580-1f0c-54e7-888e-734079121e6c', '6e8eadbe-e856-5f07-969e-fa64ae171327', 'parent');
  raise notice 'schema_v121 : % membres ajoutés.', 8;
end $$;
