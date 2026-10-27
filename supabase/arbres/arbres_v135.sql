-- arbres_v135.sql — Afrique du Sud (rois zoulous)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Rois zoulous » (Afrique du Sud) : 10 personnes de Senzangakhona à Misuzulu. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Deux pages donnent des détails différents : « Solomon kaDinuzulu » (liste des rois, 1891-1933) est appelé « Phumuzuzulu » (1890-1933) dans la page de la famille royale ; une seule fiche, dates de la liste. Goodwill Zwelithini : règne 1968 (liste) ou 1971 (famille royale) ; Misuzulu : 2021 ou 2022. Senzangakhona : sans dates.
-- Dates en année chrétienne ; « c. » = approximatif.
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
  if exists (select 1 from public.genealogy_members where id = 'aab6cab5-c9b9-5813-97b8-2ca5805baf5d') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Rois zoulous » (ZAF)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ZAF' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ZAF : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Rois zoulous';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('24c0e489-96d8-5952-b189-fe38fa518cff', cat_id, 'country', 'ZAF', top, 'Rois zoulous', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '24c0e489-96d8-5952-b189-fe38fa518cff';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('d43efa7f-a346-5ad7-8234-4dfc792b56ad', 'country', 'ZAF', 'genealogy', 'Rois zoulous', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('aab6cab5-c9b9-5813-97b8-2ca5805baf5d', 'entry', 'd43efa7f-a346-5ad7-8234-4dfc792b56ad', 'Senzangakhona', null, null, null, 'Chef zoulou, père de Shaka, Dingane et Mpande', 'Rois zoulous', 'Sources : https://en.wikipedia.org/wiki/Zulu_royal_family', 500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b60ef6b9-0e59-570e-b872-97d81d2a02fa', 'entry', 'd43efa7f-a346-5ad7-8234-4dfc792b56ad', 'Shaka', null, 1787, 1828, 'Roi des Zoulous (1816-1828)', 'Rois zoulous', 'Sources : https://en.wikipedia.org/wiki/List_of_Zulu_kings - naissance c. juillet 1787', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d6ad81e8-3b62-523e-8733-beb737d60dc0', 'entry', 'd43efa7f-a346-5ad7-8234-4dfc792b56ad', 'Dingane', null, 1795, 1840, 'Roi des Zoulous (1828-1840)', 'Rois zoulous', 'Sources : https://en.wikipedia.org/wiki/List_of_Zulu_kings - naissance c. 1795', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e95e29ef-e3b3-558e-b1fe-ae88c6b16875', 'entry', 'd43efa7f-a346-5ad7-8234-4dfc792b56ad', 'Mpande', null, 1798, 1872, 'Roi des Zoulous (1840-1872)', 'Rois zoulous', 'Sources : https://en.wikipedia.org/wiki/List_of_Zulu_kings - naissance c. 1798', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8994678c-128d-5180-840d-24f8518951d1', 'entry', 'd43efa7f-a346-5ad7-8234-4dfc792b56ad', 'Cetshwayo', null, 1834, 1884, 'Roi des Zoulous (1872-1879 ; 1883-1884)', 'Rois zoulous', 'Sources : https://en.wikipedia.org/wiki/List_of_Zulu_kings', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4849064f-a353-5e1b-9b47-1f246f8aeb19', 'entry', 'd43efa7f-a346-5ad7-8234-4dfc792b56ad', 'Dinuzulu', null, 1868, 1913, 'Roi des Zoulous (1884-1913)', 'Rois zoulous', 'Sources : https://en.wikipedia.org/wiki/List_of_Zulu_kings - naissance c. 1868', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3039f221-fcdb-5b65-bd51-a892d404fd5c', 'entry', 'd43efa7f-a346-5ad7-8234-4dfc792b56ad', 'Solomon kaDinuzulu (Phumuzuzulu)', null, 1891, 1933, 'Roi des Zoulous (1913-1933)', 'Rois zoulous', 'Sources : https://en.wikipedia.org/wiki/List_of_Zulu_kings - appelé Phumuzuzulu (1890-1933) dans la page de la famille royale', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('16795fc1-84d1-598d-a140-0b753a3e5039', 'entry', 'd43efa7f-a346-5ad7-8234-4dfc792b56ad', 'Cyprian Bhekuzulu', null, 1924, 1968, 'Roi des Zoulous (1948-1968)', 'Rois zoulous', 'Sources : https://en.wikipedia.org/wiki/List_of_Zulu_kings', 500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fc4f61de-594e-5cb2-8ddd-2ad6d3ec1568', 'entry', 'd43efa7f-a346-5ad7-8234-4dfc792b56ad', 'Goodwill Zwelithini', null, 1948, 2021, 'Roi des Zoulous (1968-2021)', 'Rois zoulous', 'Sources : https://en.wikipedia.org/wiki/List_of_Zulu_kings - règne depuis 1968 (liste) ou 1971 (famille royale)', 500, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('833041cd-3fbb-5a76-a4bd-e12da03e84d6', 'entry', 'd43efa7f-a346-5ad7-8234-4dfc792b56ad', 'Misuzulu', null, 1974, null, 'Roi des Zoulous (depuis 2021)', 'Rois zoulous', 'Sources : https://en.wikipedia.org/wiki/List_of_Zulu_kings - règne depuis 2021 (liste) ou 2022 (famille royale)', 500, 4480, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('aab6cab5-c9b9-5813-97b8-2ca5805baf5d', 'b60ef6b9-0e59-570e-b872-97d81d2a02fa', 'parent');
  perform pg_temp.rel('aab6cab5-c9b9-5813-97b8-2ca5805baf5d', 'd6ad81e8-3b62-523e-8733-beb737d60dc0', 'parent');
  perform pg_temp.rel('aab6cab5-c9b9-5813-97b8-2ca5805baf5d', 'e95e29ef-e3b3-558e-b1fe-ae88c6b16875', 'parent');
  perform pg_temp.rel('e95e29ef-e3b3-558e-b1fe-ae88c6b16875', '8994678c-128d-5180-840d-24f8518951d1', 'parent');
  perform pg_temp.rel('8994678c-128d-5180-840d-24f8518951d1', '4849064f-a353-5e1b-9b47-1f246f8aeb19', 'parent');
  perform pg_temp.rel('4849064f-a353-5e1b-9b47-1f246f8aeb19', '3039f221-fcdb-5b65-bd51-a892d404fd5c', 'parent');
  perform pg_temp.rel('3039f221-fcdb-5b65-bd51-a892d404fd5c', '16795fc1-84d1-598d-a140-0b753a3e5039', 'parent');
  perform pg_temp.rel('16795fc1-84d1-598d-a140-0b753a3e5039', 'fc4f61de-594e-5cb2-8ddd-2ad6d3ec1568', 'parent');
  perform pg_temp.rel('fc4f61de-594e-5cb2-8ddd-2ad6d3ec1568', '833041cd-3fbb-5a76-a4bd-e12da03e84d6', 'parent');
  raise notice 'schema_v135 : % membres ajoutés.', 10;
end $$;
