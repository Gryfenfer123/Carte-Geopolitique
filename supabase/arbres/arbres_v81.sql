-- arbres_v81.sql — Turquie — dynastie ottomane : d'Osman Ier au dernier calife Abdülmecid II
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Ottomans » (aucun n'existait). Rien n'est supprimé.
-- Dates et filiations des sultans : connues par ailleurs (histoire ottomane), aucune page consultée pour ce lot ; seuls les liens père-fils certains sont posés. Dates incertaines laissées vides.
-- Hürrem, Nurbanu et Kösem (épouses d'origine hors dynastie, sans maison identifiée) : placées ici et signalées.
-- Non fait : les princes exécutés ou écartés (Mustafa, Cem, Bayezid fils de Soliman…), les autres épouses, les sultanes ; le compte à 1922 s'arrête au dernier calife.
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
  if exists (select 1 from public.genealogy_members where id = 'fbfb55f4-1079-55a9-94f9-5c909e08a1c4') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Ottomans » (TUR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'TUR' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour TUR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Ottomans';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('4fa7d3b2-9f03-5b40-a984-e583e8d52c8f', cat_id, 'country', 'TUR', top, 'Ottomans', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '4fa7d3b2-9f03-5b40-a984-e583e8d52c8f';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('f4f752a8-3d2c-516d-bf05-4a116772abca', 'country', 'TUR', 'genealogy', 'Ottomans', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fbfb55f4-1079-55a9-94f9-5c909e08a1c4', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Osman Ier', null, 1258, 1326, 'Fondateur de la dynastie, bey', 'Ottomans', 1188, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('44bd33d8-3121-5f86-89cb-1bab15495016', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Orhan Ier', null, 1281, 1362, 'Bey (sultan)', 'Ottomans', 1188, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('46db7c56-2723-5b5c-883a-44b6e4d58854', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mourad Ier', null, 1326, 1389, 'Sultan', 'Ottomans', 1188, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('95cba0fc-45b6-516f-9155-88faff91d7ed', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Bayezid Ier', null, 1360, 1403, 'Sultan', 'Ottomans', 1188, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cf3813ae-f1e9-5c37-9714-79f060229707', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mehmed Ier', null, 1386, 1421, 'Sultan', 'Ottomans', 1188, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4daa3092-1d1c-5105-aab4-a64a167b4015', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mourad II', null, 1404, 1451, 'Sultan', 'Ottomans', 1188, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('eef84b46-131c-5387-9fb6-d728d607f06a', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mehmed II le Conquérant', null, 1432, 1481, 'Sultan, conquérant de Constantinople', 'Ottomans', 1188, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('82e03574-ba2b-5466-8a9f-2b56a7076481', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Bayezid II', null, 1447, 1512, 'Sultan', 'Ottomans', 1188, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8ce3b7ed-be3b-5bd2-9771-66b5361f85ff', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Selim Ier', null, 1470, 1520, 'Sultan', 'Ottomans', 1188, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b94a1745-f1c4-5660-a2a8-db89181e56ac', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Soliman Ier le Magnifique', null, 1494, 1566, 'Sultan', 'Ottomans', 1188, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('51f9f838-8ff4-534c-b299-7961abcf055c', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Selim II', null, 1524, 1574, 'Sultan', 'Ottomans', 1433, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7bc5f8ea-a297-5567-949a-d25296419d65', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mourad III', null, 1546, 1595, 'Sultan', 'Ottomans', 1188, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9b78c578-e53d-5452-a4cc-e93e42bb804f', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mehmed III', null, 1566, 1603, 'Sultan', 'Ottomans', 1188, 7680, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('45d0c580-8d0a-5ca0-b0b8-a5696f3f14ca', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Ahmed Ier', null, 1590, 1617, 'Sultan', 'Ottomans', 1546, 8320, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('426071c6-b5b3-51e8-92c2-96866bc39a1a', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mustafa Ier', null, 1591, 1639, 'Sultan', 'Ottomans', 1046, 8320, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('30d3053a-f31f-5d1e-96b2-a696a9e7eecc', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Osman II', null, 1604, 1622, 'Sultan', 'Ottomans', 1356, 8960, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('783cd8d4-9d28-5e5f-bf0f-37e77d22a570', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mourad IV', null, 1612, 1640, 'Sultan', 'Ottomans', 2356, 8960, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('be64783e-0803-529d-a94f-e0cb4ebffdaa', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Ibrahim Ier', null, 1615, 1648, 'Sultan', 'Ottomans', 1856, 8960, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('30304cc6-b2c2-53ea-9473-9b02dbd0643c', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mehmed IV', null, 1642, 1693, 'Sultan', 'Ottomans', 1812, 9600, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('672b0838-6b29-5bfd-8a45-455b373f10e1', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Soliman II', null, 1642, 1691, 'Sultan', 'Ottomans', 1312, 9600, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2cb15bf5-ad59-5e5b-82cc-5e1343ea7c2f', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Ahmed II', null, 1643, 1695, 'Sultan', 'Ottomans', 2312, 9600, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5dbefe08-d801-52c6-a346-30cb61d8b49a', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mustafa II', null, 1664, 1703, 'Sultan', 'Ottomans', 2059, 10240, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2f877346-b614-5bf9-be6a-68c265a8c4c2', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Ahmed III', null, 1673, 1736, 'Sultan', 'Ottomans', 1434, 10240, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c9fe0838-1a81-59cb-8642-25fdc0fa0efb', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mahmud Ier', null, 1696, 1754, 'Sultan', 'Ottomans', 2464, 10880, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('71056714-6537-5d67-9fbe-8a60548cc251', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Osman III', null, 1699, 1757, 'Sultan', 'Ottomans', 1964, 10880, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d1fcf9e8-3f0b-5163-8dde-285a29653717', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mustafa III', null, 1717, 1774, 'Sultan', 'Ottomans', 878, 10880, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1bfc8c10-b0f7-5394-937f-0e87a2728e24', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Abdülhamid Ier', null, 1725, 1789, 'Sultan', 'Ottomans', 1464, 10880, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6b8f7878-bf65-5850-a572-3f6b3c923bcb', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Selim III', null, 1761, 1808, 'Sultan', 'Ottomans', 878, 11520, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cb563f38-92c1-589b-8e24-09e551c6337b', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mustafa IV', null, 1779, 1808, 'Sultan', 'Ottomans', 1878, 11520, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0af31369-48af-571e-a6e7-4e69920ffb73', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mahmud II', null, 1785, 1839, 'Sultan', 'Ottomans', 1378, 11520, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fd96c722-fe19-56ae-851b-971c5f385707', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Abdülmecid Ier', null, 1823, 1861, 'Sultan', 'Ottomans', 891, 12160, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('251cb877-3198-5553-8ab7-340fba17ad60', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Abdülaziz', null, 1830, 1876, 'Sultan', 'Ottomans', 2000, 12160, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a8278c4a-dc5a-5e17-807b-dc02ab430de2', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mourad V', null, 1840, 1904, 'Sultan', 'Ottomans', 500, 12800, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5b3b1ee2-97ca-5fb3-bb3d-59d6dacdb5fa', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Abdülhamid II', null, 1842, 1918, 'Sultan', 'Ottomans', 1500, 12800, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5ed99ea6-520b-573e-9cfa-bbca8d24f12f', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mehmed V Reşad', null, 1844, 1918, 'Sultan', 'Ottomans', 0, 12800, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b66e4589-34f9-5c79-9ffc-1d8c5cad73fb', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Mehmed VI Vahideddin', null, 1861, 1926, 'Dernier sultan', 'Ottomans', 1000, 12800, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c5a69aab-f917-5296-9809-ba3a99cf1f9b', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Abdülmecid II', null, 1868, 1944, 'Dernier calife', 'Ottomans', 2000, 12800, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fce27cde-45c0-5d15-8fb9-6d8115b51b02', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Hürrem Sultan (Roxelane)', null, 1502, 1558, 'Épouse de Soliman Ier, mère de Selim II', 'Ottomans', 1678, 5760, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d2909b59-68b1-5f00-90d9-a99f083b5ef3', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Nurbanu Sultan', null, 1525, 1583, 'Épouse de Selim II, mère de Mourad III', 'Ottomans', 943, 6400, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d3ec139f-6ac6-5c65-b45d-66bc46cb1c48', 'entry', 'f4f752a8-3d2c-516d-bf05-4a116772abca', 'Kösem Sultan', null, 1589, 1651, 'Épouse d''Ahmed Ier, mère de Mourad IV et d''Ibrahim, régente', 'Ottomans', 2036, 8320, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('fbfb55f4-1079-55a9-94f9-5c909e08a1c4', '44bd33d8-3121-5f86-89cb-1bab15495016', 'parent');
  perform pg_temp.rel('44bd33d8-3121-5f86-89cb-1bab15495016', '46db7c56-2723-5b5c-883a-44b6e4d58854', 'parent');
  perform pg_temp.rel('46db7c56-2723-5b5c-883a-44b6e4d58854', '95cba0fc-45b6-516f-9155-88faff91d7ed', 'parent');
  perform pg_temp.rel('95cba0fc-45b6-516f-9155-88faff91d7ed', 'cf3813ae-f1e9-5c37-9714-79f060229707', 'parent');
  perform pg_temp.rel('cf3813ae-f1e9-5c37-9714-79f060229707', '4daa3092-1d1c-5105-aab4-a64a167b4015', 'parent');
  perform pg_temp.rel('4daa3092-1d1c-5105-aab4-a64a167b4015', 'eef84b46-131c-5387-9fb6-d728d607f06a', 'parent');
  perform pg_temp.rel('eef84b46-131c-5387-9fb6-d728d607f06a', '82e03574-ba2b-5466-8a9f-2b56a7076481', 'parent');
  perform pg_temp.rel('82e03574-ba2b-5466-8a9f-2b56a7076481', '8ce3b7ed-be3b-5bd2-9771-66b5361f85ff', 'parent');
  perform pg_temp.rel('8ce3b7ed-be3b-5bd2-9771-66b5361f85ff', 'b94a1745-f1c4-5660-a2a8-db89181e56ac', 'parent');
  perform pg_temp.rel('b94a1745-f1c4-5660-a2a8-db89181e56ac', '51f9f838-8ff4-534c-b299-7961abcf055c', 'parent');
  perform pg_temp.rel('51f9f838-8ff4-534c-b299-7961abcf055c', '7bc5f8ea-a297-5567-949a-d25296419d65', 'parent');
  perform pg_temp.rel('7bc5f8ea-a297-5567-949a-d25296419d65', '9b78c578-e53d-5452-a4cc-e93e42bb804f', 'parent');
  perform pg_temp.rel('9b78c578-e53d-5452-a4cc-e93e42bb804f', '45d0c580-8d0a-5ca0-b0b8-a5696f3f14ca', 'parent');
  perform pg_temp.rel('9b78c578-e53d-5452-a4cc-e93e42bb804f', '426071c6-b5b3-51e8-92c2-96866bc39a1a', 'parent');
  perform pg_temp.rel('45d0c580-8d0a-5ca0-b0b8-a5696f3f14ca', '30d3053a-f31f-5d1e-96b2-a696a9e7eecc', 'parent');
  perform pg_temp.rel('45d0c580-8d0a-5ca0-b0b8-a5696f3f14ca', '783cd8d4-9d28-5e5f-bf0f-37e77d22a570', 'parent');
  perform pg_temp.rel('45d0c580-8d0a-5ca0-b0b8-a5696f3f14ca', 'be64783e-0803-529d-a94f-e0cb4ebffdaa', 'parent');
  perform pg_temp.rel('be64783e-0803-529d-a94f-e0cb4ebffdaa', '30304cc6-b2c2-53ea-9473-9b02dbd0643c', 'parent');
  perform pg_temp.rel('be64783e-0803-529d-a94f-e0cb4ebffdaa', '672b0838-6b29-5bfd-8a45-455b373f10e1', 'parent');
  perform pg_temp.rel('be64783e-0803-529d-a94f-e0cb4ebffdaa', '2cb15bf5-ad59-5e5b-82cc-5e1343ea7c2f', 'parent');
  perform pg_temp.rel('30304cc6-b2c2-53ea-9473-9b02dbd0643c', '5dbefe08-d801-52c6-a346-30cb61d8b49a', 'parent');
  perform pg_temp.rel('30304cc6-b2c2-53ea-9473-9b02dbd0643c', '2f877346-b614-5bf9-be6a-68c265a8c4c2', 'parent');
  perform pg_temp.rel('5dbefe08-d801-52c6-a346-30cb61d8b49a', 'c9fe0838-1a81-59cb-8642-25fdc0fa0efb', 'parent');
  perform pg_temp.rel('5dbefe08-d801-52c6-a346-30cb61d8b49a', '71056714-6537-5d67-9fbe-8a60548cc251', 'parent');
  perform pg_temp.rel('2f877346-b614-5bf9-be6a-68c265a8c4c2', 'd1fcf9e8-3f0b-5163-8dde-285a29653717', 'parent');
  perform pg_temp.rel('2f877346-b614-5bf9-be6a-68c265a8c4c2', '1bfc8c10-b0f7-5394-937f-0e87a2728e24', 'parent');
  perform pg_temp.rel('d1fcf9e8-3f0b-5163-8dde-285a29653717', '6b8f7878-bf65-5850-a572-3f6b3c923bcb', 'parent');
  perform pg_temp.rel('1bfc8c10-b0f7-5394-937f-0e87a2728e24', 'cb563f38-92c1-589b-8e24-09e551c6337b', 'parent');
  perform pg_temp.rel('1bfc8c10-b0f7-5394-937f-0e87a2728e24', '0af31369-48af-571e-a6e7-4e69920ffb73', 'parent');
  perform pg_temp.rel('0af31369-48af-571e-a6e7-4e69920ffb73', 'fd96c722-fe19-56ae-851b-971c5f385707', 'parent');
  perform pg_temp.rel('0af31369-48af-571e-a6e7-4e69920ffb73', '251cb877-3198-5553-8ab7-340fba17ad60', 'parent');
  perform pg_temp.rel('fd96c722-fe19-56ae-851b-971c5f385707', 'a8278c4a-dc5a-5e17-807b-dc02ab430de2', 'parent');
  perform pg_temp.rel('fd96c722-fe19-56ae-851b-971c5f385707', '5b3b1ee2-97ca-5fb3-bb3d-59d6dacdb5fa', 'parent');
  perform pg_temp.rel('fd96c722-fe19-56ae-851b-971c5f385707', '5ed99ea6-520b-573e-9cfa-bbca8d24f12f', 'parent');
  perform pg_temp.rel('fd96c722-fe19-56ae-851b-971c5f385707', 'b66e4589-34f9-5c79-9ffc-1d8c5cad73fb', 'parent');
  perform pg_temp.rel('251cb877-3198-5553-8ab7-340fba17ad60', 'c5a69aab-f917-5296-9809-ba3a99cf1f9b', 'parent');
  perform pg_temp.rel('b94a1745-f1c4-5660-a2a8-db89181e56ac', 'fce27cde-45c0-5d15-8fb9-6d8115b51b02', 'spouse');
  perform pg_temp.rel('fce27cde-45c0-5d15-8fb9-6d8115b51b02', '51f9f838-8ff4-534c-b299-7961abcf055c', 'parent');
  perform pg_temp.rel('51f9f838-8ff4-534c-b299-7961abcf055c', 'd2909b59-68b1-5f00-90d9-a99f083b5ef3', 'spouse');
  perform pg_temp.rel('d2909b59-68b1-5f00-90d9-a99f083b5ef3', '7bc5f8ea-a297-5567-949a-d25296419d65', 'parent');
  perform pg_temp.rel('45d0c580-8d0a-5ca0-b0b8-a5696f3f14ca', 'd3ec139f-6ac6-5c65-b45d-66bc46cb1c48', 'spouse');
  perform pg_temp.rel('d3ec139f-6ac6-5c65-b45d-66bc46cb1c48', '783cd8d4-9d28-5e5f-bf0f-37e77d22a570', 'parent');
  perform pg_temp.rel('d3ec139f-6ac6-5c65-b45d-66bc46cb1c48', 'be64783e-0803-529d-a94f-e0cb4ebffdaa', 'parent');
  raise notice 'schema_v81 : % membres ajoutés.', 40;
end $$;
