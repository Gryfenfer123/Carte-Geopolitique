-- arbres_v118.sql — Égypte — XVIIIe et XIXe dynasties, Fatimides, Ayyoubides
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Quatre nouveaux arbres égyptiens : « Dynastie XVIII », « Dynastie XIX », « Fatimides », « Ayyoubides ». Chaque fiche porte, dans « Notes / biographie », l'adresse de sa page Wikipédia (anglais) ; sources aussi dans docs/sources/arbres.md.
-- Dates : uniquement celles que la page donne. Pour beaucoup de pharaons la page ne donne que le règne (chronologie incertaine) : naissance et mort laissées vides, règne écrit dans le titre. Dates approximatives (« c. ») signalées. Années avant J.-C. en négatif.
-- Non fait (volontairement, faute de sources fiables saisies) : autres pharaons et dynasties, Fatimides après al-Mustansir, Ayyoubides après as-Salih Ayyub, Mamelouks, pères/mères hors arbre.
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
  if exists (select 1 from public.genealogy_members where id = '0cc944f8-b555-5718-be39-2f2437c5ffa2') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Dynastie XVIII » (EGY)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'EGY' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour EGY : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Dynastie XVIII';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('cd6599a2-4848-5d75-84ed-9c6f57ba687c', cat_id, 'country', 'EGY', top, 'Dynastie XVIII', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'cd6599a2-4848-5d75-84ed-9c6f57ba687c';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('002411c0-5eb2-5b1a-a490-001198a47805', 'country', 'EGY', 'genealogy', 'Dynastie XVIII', cat_id, sec, admin_id);
  -- Arbre « Dynastie XIX » (EGY)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'EGY' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour EGY : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Dynastie XIX';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('540af4db-76ec-5fc4-93dc-a2d726399392', cat_id, 'country', 'EGY', top, 'Dynastie XIX', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '540af4db-76ec-5fc4-93dc-a2d726399392';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('d00c4d99-4abc-5b96-a950-4f76b3a482cd', 'country', 'EGY', 'genealogy', 'Dynastie XIX', cat_id, sec, admin_id);
  -- Arbre « Fatimides » (EGY)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'EGY' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour EGY : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Fatimides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('3b1baaf3-96af-5356-a58f-77ad35ae0dfd', cat_id, 'country', 'EGY', top, 'Fatimides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '3b1baaf3-96af-5356-a58f-77ad35ae0dfd';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('5150d9b4-4ad0-5845-8656-c5e9ce2af660', 'country', 'EGY', 'genealogy', 'Fatimides', cat_id, sec, admin_id);
  -- Arbre « Ayyoubides » (EGY)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'EGY' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour EGY : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Ayyoubides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('7d8890f8-beae-53d2-afa7-11784e2cfcea', cat_id, 'country', 'EGY', top, 'Ayyoubides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '7d8890f8-beae-53d2-afa7-11784e2cfcea';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('3787af7c-523d-5f15-98fc-310002e93a15', 'country', 'EGY', 'genealogy', 'Ayyoubides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0cc944f8-b555-5718-be39-2f2437c5ffa2', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Ahmôsis Ier', null, null, null, 'Pharaon, fondateur de la XVIIIe dynastie (règne : 1570-1546 av. J.-C., chronologie « haute »)', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Ahmose_I — dates de vie non données, règne seul ; parents : Séqénenrê Taa et Ahhotep Ire (hors arbre)', 2470, 49280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1afd008f-a2b3-5974-a3a1-6e82e064386b', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Ahmès-Néfertary', null, null, null, 'Grande épouse royale, épouse de son frère Ahmôsis Ier', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Ahmose-Nefertari — dates non données', 1980, 49280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('38a89622-2d73-5344-a4e6-55e05068834c', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Amenhotep Ier', null, null, null, 'Pharaon (règne : c. 1526-1506 av. J.-C., chronologie « basse »)', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Amenhotep_I — dates de vie non données, règne seul', 2225, 49920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1647f7c3-2225-5acd-b47b-5dddc1edbf20', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Thoutmôsis Ier', null, null, -1493, 'Pharaon (règne : c. 1505-1493 av. J.-C.)', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Thutmose_I — père inconnu, mère Senseneb', 494, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6fcfb05d-a52e-534c-bc7b-26d188b09e84', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Thoutmôsis II', null, null, -1479, 'Pharaon (règne : 1493-1479 av. J.-C.)', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Thutmose_II — naissance incertaine (c. 1502 ou c. 1492) donc laissée vide ; mère Moutnofret (hors arbre)', 490, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('44a1e863-62dc-5021-9724-560a568f9597', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Hatchepsout', null, -1505, -1458, 'Reine puis pharaon (règne c. 1479-1458 av. J.-C.)', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Hatshepsut', 980, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9073a14a-d8d5-5e9b-b2fa-17aec13e318b', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Thoutmôsis III', null, null, null, 'Pharaon (règne : 1479-1425 av. J.-C.)', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Thutmose_III — dates de vie non données, règne seul ; mère Iset (hors arbre)', 490, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('92c3fcc0-789f-5c02-8dc4-8823a918061d', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Amenhotep II', null, -1443, -1401, 'Pharaon', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Amenhotep_II — mère Merytre-Hatchepsout (hors arbre)', 490, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0c954b62-d4ea-5dda-b09b-9d4eb10dc7c5', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Thoutmôsis IV', null, null, -1391, 'Pharaon', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Thutmose_IV — mort en 1391 ou 1388 av. J.-C. (1391 retenu) ; naissance non donnée ; mère Tiaa (hors arbre)', 490, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('41e65450-90e3-5b4a-9ccc-a858aa0db082', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Amenhotep III', null, -1401, -1353, 'Pharaon', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Amenhotep_III — mère Moutemouia (hors arbre)', 490, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c433bfd4-0d27-5656-91b5-9a8f44b92987', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Tiyi', null, -1398, -1338, 'Grande épouse royale d''Amenhotep III', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Tiye — parents Youya et Touya (hors arbre)', 0, 3200, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f488cc99-6de6-5409-b89c-70f3db14c0a8', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Akhénaton', null, null, null, 'Pharaon (règne : c. 1353-1336 av. J.-C.)', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Akhenaten — dates de vie non données, règne seul', 245, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8d94a368-a8b8-5ee1-bf4a-157deb8af161', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Néfertiti', null, -1370, -1330, 'Grande épouse royale d''Akhénaton', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Nefertiti', 735, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9b4dc3f6-1ec2-5e21-b94a-dd8f71ca64ef', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Toutânkhamon', null, -1342, -1323, 'Pharaon', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Tutankhamun — père : Akhénaton ou Smenkhkarê selon la page ; mère « la Jeune Dame » (hors arbre)', 110, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c4e8c6dc-8865-59eb-8b7e-8b61577cc091', 'entry', '002411c0-5eb2-5b1a-a490-001198a47805', 'Ânkhesenamon', null, -1348, null, 'Grande épouse royale de Toutânkhamon', 'Dynastie XVIII', 'Sources : https://en.wikipedia.org/wiki/Ankhesenamun', 600, 4480, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0b3840f4-57f9-5001-b61e-2383b8c12e45', 'entry', 'd00c4d99-4abc-5b96-a950-4f76b3a482cd', 'Ramsès Ier', null, null, -1290, 'Pharaon, fondateur de la XIXe dynastie (règne : 1292-1290 ou 1295-1294 av. J.-C.)', 'Dynastie XIX', 'Sources : https://en.wikipedia.org/wiki/Ramesses_I — mort en 1290 ou 1294 av. J.-C. (1290 retenu) ; père Séti, mère inconnue', 735, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('febefba8-2dd2-5c02-bb1e-290a309f4773', 'entry', 'd00c4d99-4abc-5b96-a950-4f76b3a482cd', 'Séthi Ier', null, null, null, 'Pharaon (règne : 1290-1279 av. J.-C.)', 'Dynastie XIX', 'Sources : https://en.wikipedia.org/wiki/Seti_I — dates de vie non données, règne seul ; mère Sitrê (hors arbre)', 735, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9d8353ab-f930-52f0-bb1c-9ad56d62ffa8', 'entry', 'd00c4d99-4abc-5b96-a950-4f76b3a482cd', 'Touya', null, null, -1257, 'Grande épouse royale de Séthi Ier, mère de Ramsès II', 'Dynastie XIX', 'Sources : https://en.wikipedia.org/wiki/Tuya_(queen) — parents Raia et Rouia (hors arbre)', 245, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d81941e9-d1e5-5d73-ac31-e02365afdb69', 'entry', 'd00c4d99-4abc-5b96-a950-4f76b3a482cd', 'Ramsès II', null, -1303, -1213, 'Pharaon (règne : 1279-1213 av. J.-C.)', 'Dynastie XIX', 'Sources : https://en.wikipedia.org/wiki/Ramesses_II', 490, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('25299975-3c41-54af-be2c-f17a40d10cb4', 'entry', 'd00c4d99-4abc-5b96-a950-4f76b3a482cd', 'Néfertari', null, null, -1255, 'Grande épouse royale de Ramsès II', 'Dynastie XIX', 'Sources : https://en.wikipedia.org/wiki/Nefertari', 0, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c095fd4a-1c61-5abc-8bc1-0671eb585feb', 'entry', 'd00c4d99-4abc-5b96-a950-4f76b3a482cd', 'Mérenptah', null, -1263, -1203, 'Pharaon (règne : 1213-1203 av. J.-C.)', 'Dynastie XIX', 'Sources : https://en.wikipedia.org/wiki/Merneptah — mère Isetnofret (hors arbre)', 490, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5cdcc8fd-c149-5322-a6e7-07e39e84ece7', 'entry', '5150d9b4-4ad0-5845-8656-c5e9ce2af660', 'Al-Mahdi Billah', null, 874, 934, 'Premier calife fatimide (909-934)', 'Fatimides', 'Sources : https://en.wikipedia.org/wiki/Abdallah_al-Mahdi_Billah — père al-Husayn', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0775c10c-7130-5ed6-bff5-764431c1465b', 'entry', '5150d9b4-4ad0-5845-8656-c5e9ce2af660', 'Al-Qaïm bi-Amr Allah', null, 893, 946, 'Calife fatimide (934-946)', 'Fatimides', 'Sources : https://en.wikipedia.org/wiki/Al-Qa%27im_(Fatimid_caliph)', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5ee44375-d9b9-57ad-a363-65202bd435f5', 'entry', '5150d9b4-4ad0-5845-8656-c5e9ce2af660', 'Al-Mansur Billah', null, 914, 953, 'Calife fatimide (946-953)', 'Fatimides', 'Sources : https://en.wikipedia.org/wiki/Al-Mansur_Billah', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1f88adcf-7bcd-58ce-96ca-8a924dd45e47', 'entry', '5150d9b4-4ad0-5845-8656-c5e9ce2af660', 'Al-Mouizz li-Din Allah', null, 931, 975, 'Calife fatimide (953-975), conquiert l''Égypte', 'Fatimides', 'Sources : https://en.wikipedia.org/wiki/Al-Mu%27izz_li-Din_Allah', 0, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e0eea2d5-24d4-5868-9990-ee0bff04c3c2', 'entry', '5150d9b4-4ad0-5845-8656-c5e9ce2af660', 'Al-Aziz Billah', null, 955, 996, 'Calife fatimide (975-996)', 'Fatimides', 'Sources : https://en.wikipedia.org/wiki/Al-Aziz_Billah', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b6364da9-0558-5f16-8822-9039505a45bc', 'entry', '5150d9b4-4ad0-5845-8656-c5e9ce2af660', 'Al-Hakim bi-Amr Allah', null, 985, 1021, 'Calife fatimide (996-1021)', 'Fatimides', 'Sources : https://en.wikipedia.org/wiki/Al-Hakim_bi-Amr_Allah', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9596fd33-72c9-5f22-9b18-ca670bcc2726', 'entry', '5150d9b4-4ad0-5845-8656-c5e9ce2af660', 'Az-Zahir li-Izaz Din Allah', null, 1005, 1036, 'Calife fatimide (1021-1036)', 'Fatimides', 'Sources : https://en.wikipedia.org/wiki/Al-Zahir_li-I%27zaz_Din_Allah', 0, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('84b6db81-ef50-5789-9498-f1f3246f26fb', 'entry', '5150d9b4-4ad0-5845-8656-c5e9ce2af660', 'Al-Moustansir Billah', null, 1029, 1094, 'Calife fatimide (1036-1094)', 'Fatimides', 'Sources : https://en.wikipedia.org/wiki/Al-Mustansir_Billah', 0, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('989257cd-d37a-55b9-8128-662355032690', 'entry', '3787af7c-523d-5f15-98fc-310002e93a15', 'Najm ad-Din Ayyub', null, null, 1173, 'Père de Saladin et d''al-Adil, gouverneur de Damas', 'Ayyoubides', 'Sources : https://en.wikipedia.org/wiki/Najm_ad-Din_Ayyub — père Shadhi ibn Marwan (hors arbre) ; naissance inconnue', 250, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('37821184-912e-5214-ae36-ddb918c7a3ee', 'entry', '3787af7c-523d-5f15-98fc-310002e93a15', 'Saladin', null, 1137, 1193, 'Sultan d''Égypte et de Syrie, fondateur des Ayyoubides', 'Ayyoubides', 'Sources : https://en.wikipedia.org/wiki/Saladin', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9b41e15d-cad1-53df-86cf-a76b756270d2', 'entry', '3787af7c-523d-5f15-98fc-310002e93a15', 'Al-Adil Ier', null, 1145, 1218, 'Sultan d''Égypte (1200-1218), frère de Saladin', 'Ayyoubides', 'Sources : https://en.wikipedia.org/wiki/Al-Adil_I', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('dbe42d24-579b-5c8e-be83-a55176342e5e', 'entry', '3787af7c-523d-5f15-98fc-310002e93a15', 'Al-Kamil', null, 1177, 1238, 'Sultan d''Égypte (1218-1238)', 'Ayyoubides', 'Sources : https://en.wikipedia.org/wiki/Al-Kamil', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('63871a15-ed1b-5a8a-9fe9-e01b509259f8', 'entry', '3787af7c-523d-5f15-98fc-310002e93a15', 'As-Salih Ayyub', null, 1205, 1249, 'Sultan d''Égypte (1240-1249)', 'Ayyoubides', 'Sources : https://en.wikipedia.org/wiki/As-Salih_Ayyub — mère Ward al-Muna', 500, 1920, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('0cc944f8-b555-5718-be39-2f2437c5ffa2', '38a89622-2d73-5344-a4e6-55e05068834c', 'parent');
  perform pg_temp.rel('1afd008f-a2b3-5974-a3a1-6e82e064386b', '38a89622-2d73-5344-a4e6-55e05068834c', 'parent');
  perform pg_temp.rel('1647f7c3-2225-5acd-b47b-5dddc1edbf20', '6fcfb05d-a52e-534c-bc7b-26d188b09e84', 'parent');
  perform pg_temp.rel('1647f7c3-2225-5acd-b47b-5dddc1edbf20', '44a1e863-62dc-5021-9724-560a568f9597', 'parent');
  perform pg_temp.rel('6fcfb05d-a52e-534c-bc7b-26d188b09e84', '9073a14a-d8d5-5e9b-b2fa-17aec13e318b', 'parent');
  perform pg_temp.rel('9073a14a-d8d5-5e9b-b2fa-17aec13e318b', '92c3fcc0-789f-5c02-8dc4-8823a918061d', 'parent');
  perform pg_temp.rel('92c3fcc0-789f-5c02-8dc4-8823a918061d', '0c954b62-d4ea-5dda-b09b-9d4eb10dc7c5', 'parent');
  perform pg_temp.rel('0c954b62-d4ea-5dda-b09b-9d4eb10dc7c5', '41e65450-90e3-5b4a-9ccc-a858aa0db082', 'parent');
  perform pg_temp.rel('41e65450-90e3-5b4a-9ccc-a858aa0db082', 'f488cc99-6de6-5409-b89c-70f3db14c0a8', 'parent');
  perform pg_temp.rel('c433bfd4-0d27-5656-91b5-9a8f44b92987', 'f488cc99-6de6-5409-b89c-70f3db14c0a8', 'parent');
  perform pg_temp.rel('f488cc99-6de6-5409-b89c-70f3db14c0a8', '9b4dc3f6-1ec2-5e21-b94a-dd8f71ca64ef', 'parent');
  perform pg_temp.rel('f488cc99-6de6-5409-b89c-70f3db14c0a8', 'c4e8c6dc-8865-59eb-8b7e-8b61577cc091', 'parent');
  perform pg_temp.rel('8d94a368-a8b8-5ee1-bf4a-157deb8af161', 'c4e8c6dc-8865-59eb-8b7e-8b61577cc091', 'parent');
  perform pg_temp.rel('0cc944f8-b555-5718-be39-2f2437c5ffa2', '1afd008f-a2b3-5974-a3a1-6e82e064386b', 'spouse');
  perform pg_temp.rel('6fcfb05d-a52e-534c-bc7b-26d188b09e84', '44a1e863-62dc-5021-9724-560a568f9597', 'spouse');
  perform pg_temp.rel('41e65450-90e3-5b4a-9ccc-a858aa0db082', 'c433bfd4-0d27-5656-91b5-9a8f44b92987', 'spouse');
  perform pg_temp.rel('f488cc99-6de6-5409-b89c-70f3db14c0a8', '8d94a368-a8b8-5ee1-bf4a-157deb8af161', 'spouse');
  perform pg_temp.rel('9b4dc3f6-1ec2-5e21-b94a-dd8f71ca64ef', 'c4e8c6dc-8865-59eb-8b7e-8b61577cc091', 'spouse');
  perform pg_temp.rel('0b3840f4-57f9-5001-b61e-2383b8c12e45', 'febefba8-2dd2-5c02-bb1e-290a309f4773', 'parent');
  perform pg_temp.rel('febefba8-2dd2-5c02-bb1e-290a309f4773', 'd81941e9-d1e5-5d73-ac31-e02365afdb69', 'parent');
  perform pg_temp.rel('9d8353ab-f930-52f0-bb1c-9ad56d62ffa8', 'd81941e9-d1e5-5d73-ac31-e02365afdb69', 'parent');
  perform pg_temp.rel('d81941e9-d1e5-5d73-ac31-e02365afdb69', 'c095fd4a-1c61-5abc-8bc1-0671eb585feb', 'parent');
  perform pg_temp.rel('febefba8-2dd2-5c02-bb1e-290a309f4773', '9d8353ab-f930-52f0-bb1c-9ad56d62ffa8', 'spouse');
  perform pg_temp.rel('d81941e9-d1e5-5d73-ac31-e02365afdb69', '25299975-3c41-54af-be2c-f17a40d10cb4', 'spouse');
  perform pg_temp.rel('5cdcc8fd-c149-5322-a6e7-07e39e84ece7', '0775c10c-7130-5ed6-bff5-764431c1465b', 'parent');
  perform pg_temp.rel('0775c10c-7130-5ed6-bff5-764431c1465b', '5ee44375-d9b9-57ad-a363-65202bd435f5', 'parent');
  perform pg_temp.rel('5ee44375-d9b9-57ad-a363-65202bd435f5', '1f88adcf-7bcd-58ce-96ca-8a924dd45e47', 'parent');
  perform pg_temp.rel('1f88adcf-7bcd-58ce-96ca-8a924dd45e47', 'e0eea2d5-24d4-5868-9990-ee0bff04c3c2', 'parent');
  perform pg_temp.rel('e0eea2d5-24d4-5868-9990-ee0bff04c3c2', 'b6364da9-0558-5f16-8822-9039505a45bc', 'parent');
  perform pg_temp.rel('b6364da9-0558-5f16-8822-9039505a45bc', '9596fd33-72c9-5f22-9b18-ca670bcc2726', 'parent');
  perform pg_temp.rel('9596fd33-72c9-5f22-9b18-ca670bcc2726', '84b6db81-ef50-5789-9498-f1f3246f26fb', 'parent');
  perform pg_temp.rel('989257cd-d37a-55b9-8128-662355032690', '37821184-912e-5214-ae36-ddb918c7a3ee', 'parent');
  perform pg_temp.rel('989257cd-d37a-55b9-8128-662355032690', '9b41e15d-cad1-53df-86cf-a76b756270d2', 'parent');
  perform pg_temp.rel('9b41e15d-cad1-53df-86cf-a76b756270d2', 'dbe42d24-579b-5c8e-be83-a55176342e5e', 'parent');
  perform pg_temp.rel('dbe42d24-579b-5c8e-be83-a55176342e5e', '63871a15-ed1b-5a8a-9fe9-e01b509259f8', 'parent');
  raise notice 'schema_v118 : % membres ajoutés.', 34;
end $$;
