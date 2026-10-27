-- arbres_v154.sql — Ouzbékistan (Samanides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Samanides » (Ouzbékistan, Boukhara) : 18 personnes, d'Asad ibn Saman à Ismail Muntasir. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Tout vient de la page « Samanid Empire » (liste des souverains avec filiation). Ne sont pas ajoutés : Ibrahim ibn Ahmad (oncle de Nuh I mais Ahmad ambigu) et Abd al-Aziz (père non indiqué). Dates de naissance absentes ; morts à l'année quand la page la donne (Nuh ibn Asad et Ahmad ibn Asad : « 841/2 » et « 864/5 », laissés vides).
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
  if exists (select 1 from public.genealogy_members where id = '162d8ee2-fd55-553d-bbc5-febf0c76db05') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Samanides » (UZB)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'UZB' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour UZB : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Samanides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('6f334eee-2161-5163-a19a-ee7f9aad344e', cat_id, 'country', 'UZB', top, 'Samanides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '6f334eee-2161-5163-a19a-ee7f9aad344e';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'country', 'UZB', 'genealogy', 'Samanides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('162d8ee2-fd55-553d-bbc5-febf0c76db05', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Asad ibn Saman', null, null, null, 'Ancêtre de la dynastie samanide', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - père de Nuh, Ahmad, Yahya et Ilyas', 750, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6b94e1d6-53a4-54ed-8b5e-b358ac75456b', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Nuh ibn Asad', null, null, null, 'Gouverneur samanide de Samarcande (819-841/2)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils d''Asad ; mort en 841 ou 842', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8c6eba6a-3292-531a-9170-7bae02d677b2', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Ahmad ibn Asad', null, null, null, 'Gouverneur samanide de Fergana (819-864/5)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils d''Asad ; mort en 864 ou 865', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b136c62b-7e29-5b2a-847b-3227689d9829', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Yahya ibn Asad', null, null, 855, 'Gouverneur samanide de Chach (819-855)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils d''Asad', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bf1e8336-a59d-51c6-ad7f-589532bc01f1', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Ilyas ibn Asad', null, null, 856, 'Gouverneur samanide d''Hérat (819-856)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils d''Asad', 1500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a0a69a8d-836b-56bd-97f0-09deeb8ed1f0', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Ibrahim ibn Ilyas', null, null, null, 'Gouverneur samanide (856-867)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils d''Ilyas', 1500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('37a12ac7-5fce-5f9a-bd48-c3b53788f6ee', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Nasr I', null, null, 892, 'Émir samanide (864-892)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils d''Ahmad ibn Asad ; mort en août 892', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('878a1cc7-08ab-5831-a1be-c2eaa5f18a83', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Yaqub ibn Ahmad', null, null, null, 'Fils d''Ahmad ibn Asad', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - règne non indiqué sur la page', 1000, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cd63d971-2a8e-5a59-a47e-cb9038c054f6', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Ismail Samani', null, null, 907, 'Émir samanide (892-907)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils d''Ahmad ibn Asad, frère de Nasr I ; mort en novembre 907', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fc602e32-e760-5c69-8be8-15151708e47a', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Ahmad Samani', null, null, 914, 'Émir samanide (907-914)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils d''Ismail ; assassiné en 914', 500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8bd739ed-825b-5604-ae2e-31c9d6284b78', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Nasr II', null, null, null, 'Émir samanide (914-943)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils d''Ahmad Samani ; mort de tuberculose quelques mois après son abdication', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('60654d74-2ed4-5c49-a2e6-a3d643c61744', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Nuh I', null, null, null, 'Émir samanide (943-954)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils de Nasr II', 500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5cd937c2-8806-55fb-85df-aea5d5a2fece', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Abd al-Malik I', null, null, null, 'Émir samanide (954-961)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils de Nuh I', 251, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('290c83b2-2d11-52a6-b804-a18cb53643c7', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Mansur I (Abu Salih)', null, null, null, 'Émir samanide (961-976)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils de Nuh I', 751, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('203d6196-a232-57fe-af70-1b25579b05b4', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Nuh II', null, null, null, 'Émir samanide (976-997)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils de Mansur I', 751, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('346b40ee-54a7-58ba-8134-7aaa293c9dba', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Mansur II', null, null, null, 'Émir samanide (997-999)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils de Nuh II', 251, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ae26f9b8-d802-5a07-a959-394ced948648', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Abd al-Malik II', null, null, null, 'Émir samanide (999)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - fils de Nuh II', 751, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('be711d97-ae07-588a-9114-3c281773c355', 'entry', '4ddb5abe-ee72-5ce2-b357-97b5461f37b3', 'Ismail Muntasir', null, null, null, 'Dernier émir samanide (1000-1005)', 'Samanides', 'Sources : https://en.wikipedia.org/wiki/Samanid_Empire - plus jeune fils de Nuh II', 1251, 5120, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('162d8ee2-fd55-553d-bbc5-febf0c76db05', '6b94e1d6-53a4-54ed-8b5e-b358ac75456b', 'parent');
  perform pg_temp.rel('162d8ee2-fd55-553d-bbc5-febf0c76db05', '8c6eba6a-3292-531a-9170-7bae02d677b2', 'parent');
  perform pg_temp.rel('162d8ee2-fd55-553d-bbc5-febf0c76db05', 'b136c62b-7e29-5b2a-847b-3227689d9829', 'parent');
  perform pg_temp.rel('162d8ee2-fd55-553d-bbc5-febf0c76db05', 'bf1e8336-a59d-51c6-ad7f-589532bc01f1', 'parent');
  perform pg_temp.rel('bf1e8336-a59d-51c6-ad7f-589532bc01f1', 'a0a69a8d-836b-56bd-97f0-09deeb8ed1f0', 'parent');
  perform pg_temp.rel('8c6eba6a-3292-531a-9170-7bae02d677b2', '37a12ac7-5fce-5f9a-bd48-c3b53788f6ee', 'parent');
  perform pg_temp.rel('8c6eba6a-3292-531a-9170-7bae02d677b2', '878a1cc7-08ab-5831-a1be-c2eaa5f18a83', 'parent');
  perform pg_temp.rel('8c6eba6a-3292-531a-9170-7bae02d677b2', 'cd63d971-2a8e-5a59-a47e-cb9038c054f6', 'parent');
  perform pg_temp.rel('cd63d971-2a8e-5a59-a47e-cb9038c054f6', 'fc602e32-e760-5c69-8be8-15151708e47a', 'parent');
  perform pg_temp.rel('fc602e32-e760-5c69-8be8-15151708e47a', '8bd739ed-825b-5604-ae2e-31c9d6284b78', 'parent');
  perform pg_temp.rel('8bd739ed-825b-5604-ae2e-31c9d6284b78', '60654d74-2ed4-5c49-a2e6-a3d643c61744', 'parent');
  perform pg_temp.rel('60654d74-2ed4-5c49-a2e6-a3d643c61744', '5cd937c2-8806-55fb-85df-aea5d5a2fece', 'parent');
  perform pg_temp.rel('60654d74-2ed4-5c49-a2e6-a3d643c61744', '290c83b2-2d11-52a6-b804-a18cb53643c7', 'parent');
  perform pg_temp.rel('290c83b2-2d11-52a6-b804-a18cb53643c7', '203d6196-a232-57fe-af70-1b25579b05b4', 'parent');
  perform pg_temp.rel('203d6196-a232-57fe-af70-1b25579b05b4', '346b40ee-54a7-58ba-8134-7aaa293c9dba', 'parent');
  perform pg_temp.rel('203d6196-a232-57fe-af70-1b25579b05b4', 'ae26f9b8-d802-5a07-a959-394ced948648', 'parent');
  perform pg_temp.rel('203d6196-a232-57fe-af70-1b25579b05b4', 'be711d97-ae07-588a-9114-3c281773c355', 'parent');
  raise notice 'schema_v154 : % membres ajoutés.', 18;
end $$;
