-- arbres_v149.sql — Afghanistan (Ghaznévides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Ghaznévides » (Afghanistan) : 17 personnes, de Sabuktigin à Khusrau Malik. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Tout vient de la page « Ghaznavid Empire » : filiation père-fils pour chaque sultan, sauf Toghrul (général mamelouk turc, 1052-1053) qui n'est pas ajouté. Aucune date de naissance ; quelques morts seulement (Mahmud 1030, Masud I 1040, Masud III 1115, Khusrau Malik 1191). La page présente des petites incohérences (mort de Masud I « assassiné » dans le texte, « exécuté » dans le tableau ; Ibrahim jusqu'en 1098 ou 1099).
-- Ces sultans régnaient depuis Ghazni (Afghanistan actuel).
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
  if exists (select 1 from public.genealogy_members where id = '75b2e468-dc5c-5544-aaca-a5ca403b2306') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Ghaznévides » (AFG)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'AFG' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour AFG : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Ghaznévides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('267ab682-1df3-5a81-9932-ce984e9de470', cat_id, 'country', 'AFG', top, 'Ghaznévides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '267ab682-1df3-5a81-9932-ce984e9de470';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'country', 'AFG', 'genealogy', 'Ghaznévides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('75b2e468-dc5c-5544-aaca-a5ca403b2306', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Sabuktigin', null, null, null, 'Fondateur de la dynastie ghaznévide (977-997)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - père de Mahmud et d''Ismaïl', 1000, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('26b2e575-8b2e-5924-936d-6818bd2ca3e9', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Ismail de Ghazni', null, null, null, 'Émir ghaznévide (997-998)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Sabuktigin', 1250, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0e99a082-aa2e-5329-828d-63e0d1ee464a', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Mahmud de Ghazni', null, null, 1030, 'Sultan ghaznévide (998-1030)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Sabuktigin ; mort en avril 1030', 750, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d62ad4d5-62bc-5bc5-a7c0-3170b40d194a', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Muhammad (Jalal ad-Dawla)', null, null, null, 'Sultan ghaznévide (1030 et 1041)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - deuxième fils de Mahmud', 250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7f7a3b90-0ea0-5455-a680-4accdac605c6', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Masud I', null, null, 1040, 'Sultan ghaznévide (1030-1041)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - premier fils de Mahmud ; mort en 1040 selon la page (assassiné ou exécuté)', 750, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a95e7f3a-8924-5120-8828-a7be7930a968', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Mawdud', null, null, null, 'Sultan ghaznévide (1041-1048)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Masud I', 1000, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f0ec7fd0-9844-50b8-bde0-8a1c20b4dfc8', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Masud II', null, null, null, 'Sultan ghaznévide (1048)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Mawdud', 1000, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c3f13c0f-cadc-58cc-a5a6-c711914f92d5', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Ali (Baha ad-Dawla)', null, null, null, 'Sultan ghaznévide (1048-1049)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Masud I', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3c182b10-06aa-52b9-91d7-bd9d456b818d', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Abd al-Rashid', null, null, null, 'Sultan ghaznévide (1049-1052)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - cinquième fils de Mahmud', 1250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0d2902a8-4f6c-5646-acea-093b4bd0b483', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Farrukh-Zad', null, null, null, 'Sultan ghaznévide (1053-1059)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Masud I', 1500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('71ca6eb5-6ddf-5843-b847-cfa04b0f2014', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Ibrahim de Ghazni', null, null, null, 'Sultan ghaznévide (1059-1099)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Masud I', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('58d3fa87-ad7d-5bd9-822f-681f7271e6ba', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Masud III', null, null, 1115, 'Sultan ghaznévide (1099-1115)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils d''Ibrahim', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('652d0d2b-46b4-55d0-8e75-62c72171a20d', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Shir-Zad', null, null, null, 'Sultan ghaznévide (1115-1116)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Masud III ; assassiné', 1000, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('19612a5a-becc-5221-a0fa-45da4fe0f013', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Arslan-Shah', null, null, null, 'Sultan ghaznévide (1116-1117)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Masud III', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('996a0c05-babb-58e0-adc8-c5bab1a75e34', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Bahram Shah', null, null, null, 'Sultan ghaznévide (1117-1157)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Masud III', 500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e8b43994-ac2b-5a6a-8ae7-deb913e9e147', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Khusrau Shah', null, null, null, 'Sultan ghaznévide (1157-1160)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Bahram Shah', 500, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1bd1304a-529e-543c-b693-1f57e804e3e4', 'entry', 'c1ae9f82-f1f5-57d2-b4d0-9f084dfebbc8', 'Khusrau Malik', null, null, 1191, 'Dernier sultan ghaznévide (1160-1186)', 'Ghaznévides', 'Sources : https://en.wikipedia.org/wiki/Ghaznavid_Empire - fils de Khusrau Shah ; exécuté en 1191 (texte de la page)', 500, 4480, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('75b2e468-dc5c-5544-aaca-a5ca403b2306', '26b2e575-8b2e-5924-936d-6818bd2ca3e9', 'parent');
  perform pg_temp.rel('75b2e468-dc5c-5544-aaca-a5ca403b2306', '0e99a082-aa2e-5329-828d-63e0d1ee464a', 'parent');
  perform pg_temp.rel('0e99a082-aa2e-5329-828d-63e0d1ee464a', 'd62ad4d5-62bc-5bc5-a7c0-3170b40d194a', 'parent');
  perform pg_temp.rel('0e99a082-aa2e-5329-828d-63e0d1ee464a', '7f7a3b90-0ea0-5455-a680-4accdac605c6', 'parent');
  perform pg_temp.rel('0e99a082-aa2e-5329-828d-63e0d1ee464a', '3c182b10-06aa-52b9-91d7-bd9d456b818d', 'parent');
  perform pg_temp.rel('7f7a3b90-0ea0-5455-a680-4accdac605c6', 'a95e7f3a-8924-5120-8828-a7be7930a968', 'parent');
  perform pg_temp.rel('a95e7f3a-8924-5120-8828-a7be7930a968', 'f0ec7fd0-9844-50b8-bde0-8a1c20b4dfc8', 'parent');
  perform pg_temp.rel('7f7a3b90-0ea0-5455-a680-4accdac605c6', 'c3f13c0f-cadc-58cc-a5a6-c711914f92d5', 'parent');
  perform pg_temp.rel('7f7a3b90-0ea0-5455-a680-4accdac605c6', '0d2902a8-4f6c-5646-acea-093b4bd0b483', 'parent');
  perform pg_temp.rel('7f7a3b90-0ea0-5455-a680-4accdac605c6', '71ca6eb5-6ddf-5843-b847-cfa04b0f2014', 'parent');
  perform pg_temp.rel('71ca6eb5-6ddf-5843-b847-cfa04b0f2014', '58d3fa87-ad7d-5bd9-822f-681f7271e6ba', 'parent');
  perform pg_temp.rel('58d3fa87-ad7d-5bd9-822f-681f7271e6ba', '652d0d2b-46b4-55d0-8e75-62c72171a20d', 'parent');
  perform pg_temp.rel('58d3fa87-ad7d-5bd9-822f-681f7271e6ba', '19612a5a-becc-5221-a0fa-45da4fe0f013', 'parent');
  perform pg_temp.rel('58d3fa87-ad7d-5bd9-822f-681f7271e6ba', '996a0c05-babb-58e0-adc8-c5bab1a75e34', 'parent');
  perform pg_temp.rel('996a0c05-babb-58e0-adc8-c5bab1a75e34', 'e8b43994-ac2b-5a6a-8ae7-deb913e9e147', 'parent');
  perform pg_temp.rel('e8b43994-ac2b-5a6a-8ae7-deb913e9e147', '1bd1304a-529e-543c-b693-1f57e804e3e4', 'parent');
  raise notice 'schema_v149 : % membres ajoutés.', 17;
end $$;
