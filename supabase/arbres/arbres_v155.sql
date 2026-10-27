-- arbres_v155.sql — Syrie (Zengides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Zengides » (Syrie, Mossoul, Alep) : 20 personnes, d'Aq Sunqur à Mahmud al-Zahir. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Tout vient de la page « Zengid dynasty » (branches de Mossoul, Alep, Damas/Sinjar et Djézireh avec filiation). Badr al-Din Lulu (régent de Mossoul, sans lien de famille indiqué) n'est pas ajouté. Aucune date de naissance ; quelques morts. La page donne deux fins de règne pour as-Salih Ismail (1181 ou 1182) et deux durées pour Imad al-Din Zengi II (1171-1197 selon la liste de Damas).
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
  if exists (select 1 from public.genealogy_members where id = '6bff64b0-14c4-57b8-9823-c41fa9371044') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Zengides » (SYR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'SYR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour SYR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Zengides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('51df8c0e-c2e9-5229-a64b-0c38ea20664d', cat_id, 'country', 'SYR', top, 'Zengides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '51df8c0e-c2e9-5229-a64b-0c38ea20664d';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'country', 'SYR', 'genealogy', 'Zengides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6bff64b0-14c4-57b8-9823-c41fa9371044', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Aq Sunqur al-Hajib', null, null, null, 'Père de Zengi', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - père de Zengi', 817, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('86160ab9-1b35-54f4-af99-faa1ec7ee3c3', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Zengi (Imad al-Din)', null, null, 1146, 'Atabeg de Mossoul (1127-1146)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - assassiné par un esclave en 1146', 817, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b0d9f2f2-86f8-55ec-9838-0d7fb42621fc', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Sayf al-Din Ghazi I', null, null, null, 'Émir de Mossoul (1146-1149)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Zengi', 824, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('99609738-1e57-5227-a0be-0f5799a0f669', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Qutb al-Din Mawdud', null, null, null, 'Émir de Mossoul (1149-1170)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Zengi', 1324, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('929ffe28-a2df-51dc-bbe5-75f057e2ccfe', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Sayf al-Din Ghazi II', null, null, 1181, 'Émir de Mossoul (1170-1180)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Mawdud ; mort en juin 1181', 2083, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('51c6317b-2c9e-5add-8e12-6ee0644d5cb5', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Izz al-Din Masud I', null, null, null, 'Émir de Mossoul (1180-1193)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Mawdud', 1500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1bffdae9-9bed-568c-9d4d-979f4ea728cd', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Nur al-Din Arslan Shah I', null, null, null, 'Émir de Mossoul (1193-1211)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils d''Izz al-Din Masud', 1500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d3549e0a-a249-59f4-93f8-28547c16da3b', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Izz al-Din Masud II', null, null, null, 'Émir de Mossoul (1211-1218)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils d''Arslan Shah I', 1500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('d4512a67-81b7-5af9-bb67-2e12f7237d5e', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Nur al-Din Arslan Shah II', null, null, null, 'Émir de Mossoul (1218-1219)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils d''Izz al-Din Masud II', 1083, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9d39883b-5cd3-5967-9b35-7eef56c1c171', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Nasir ad-Din Mahmud', null, null, 1234, 'Émir de Mossoul (1219-1234)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils d''Izz al-Din Masud II ; mort en 1234 (peut-être assassiné)', 1583, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9339d509-b683-5ac8-a5fc-9a1094c2d6a1', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Nur al-Din (Nur ad-Din Mahmud)', null, null, 1174, 'Émir d''Alep puis de Damas (1146-1174)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Zengi ; mort le 15 mai 1174', 320, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('288ea464-453b-5d35-afa9-990538aad6d9', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'As-Salih Ismail al-Malik', null, null, 1181, 'Émir d''Alep (1174-1181)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Nur al-Din ; mort le 4 décembre 1181', 320, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('551b0d8d-2ae7-5396-9f7b-e852a2eb4886', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Imad al-Din Zengi II', null, null, null, 'Émir de Sinjar et d''Alep (1171-1197)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Mawdud, cousin d''as-Salih Ismail (liste de Damas)', 820, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('4f169bea-dc26-53af-b072-4399417cf6c7', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Qutb ad-Din Muhammad', null, null, null, 'Émir de Sinjar (1197-1219)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils d''Imad al-Din Zengi II', 820, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('31d853ae-fef7-5014-9645-ace8afa469d8', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Imad al-Din Shahanshah', null, null, null, 'Émir de Sinjar (1219-1220)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Qutb ad-Din Muhammad', 500, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('36da28c2-1be9-5541-a685-d78c7be05740', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Jalal al-Din Mahmud', null, null, null, 'Co-souverain de Sinjar (1219-1220)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Qutb ad-Din Muhammad', 1000, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('f7ac5722-6a76-568b-9e95-7ba95f18b20c', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Fath al-Din Umar', null, null, null, 'Co-souverain de Sinjar (1219-1220)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Qutb ad-Din Muhammad', 0, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('698a1c86-a7bf-5a93-a32a-8a62f13d3fa6', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Muizz al-Din Sanjar Shah', null, null, null, 'Émir de Djézireh (1180-1208)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Ghazi II', 2083, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('93d8321c-370b-59f5-b473-2fbf733ab8e9', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Muizz al-Din Mahmud', null, null, null, 'Émir de Djézireh (1208-1241)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Sanjar Shah', 2083, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bca4d415-978a-505b-a801-5402195a90a1', 'entry', 'cc8f28ac-f341-542e-9fc9-b546f8b385c4', 'Mahmud al-Malik al-Zahir', null, null, null, 'Émir de Djézireh (1241-1250)', 'Zengides', 'Sources : https://en.wikipedia.org/wiki/Zengid_dynasty - fils de Muizz al-Din Mahmud', 2083, 3840, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('6bff64b0-14c4-57b8-9823-c41fa9371044', '86160ab9-1b35-54f4-af99-faa1ec7ee3c3', 'parent');
  perform pg_temp.rel('86160ab9-1b35-54f4-af99-faa1ec7ee3c3', 'b0d9f2f2-86f8-55ec-9838-0d7fb42621fc', 'parent');
  perform pg_temp.rel('86160ab9-1b35-54f4-af99-faa1ec7ee3c3', '99609738-1e57-5227-a0be-0f5799a0f669', 'parent');
  perform pg_temp.rel('86160ab9-1b35-54f4-af99-faa1ec7ee3c3', '9339d509-b683-5ac8-a5fc-9a1094c2d6a1', 'parent');
  perform pg_temp.rel('99609738-1e57-5227-a0be-0f5799a0f669', '929ffe28-a2df-51dc-bbe5-75f057e2ccfe', 'parent');
  perform pg_temp.rel('99609738-1e57-5227-a0be-0f5799a0f669', '51c6317b-2c9e-5add-8e12-6ee0644d5cb5', 'parent');
  perform pg_temp.rel('51c6317b-2c9e-5add-8e12-6ee0644d5cb5', '1bffdae9-9bed-568c-9d4d-979f4ea728cd', 'parent');
  perform pg_temp.rel('1bffdae9-9bed-568c-9d4d-979f4ea728cd', 'd3549e0a-a249-59f4-93f8-28547c16da3b', 'parent');
  perform pg_temp.rel('d3549e0a-a249-59f4-93f8-28547c16da3b', 'd4512a67-81b7-5af9-bb67-2e12f7237d5e', 'parent');
  perform pg_temp.rel('d3549e0a-a249-59f4-93f8-28547c16da3b', '9d39883b-5cd3-5967-9b35-7eef56c1c171', 'parent');
  perform pg_temp.rel('9339d509-b683-5ac8-a5fc-9a1094c2d6a1', '288ea464-453b-5d35-afa9-990538aad6d9', 'parent');
  perform pg_temp.rel('99609738-1e57-5227-a0be-0f5799a0f669', '551b0d8d-2ae7-5396-9f7b-e852a2eb4886', 'parent');
  perform pg_temp.rel('551b0d8d-2ae7-5396-9f7b-e852a2eb4886', '4f169bea-dc26-53af-b072-4399417cf6c7', 'parent');
  perform pg_temp.rel('4f169bea-dc26-53af-b072-4399417cf6c7', '31d853ae-fef7-5014-9645-ace8afa469d8', 'parent');
  perform pg_temp.rel('4f169bea-dc26-53af-b072-4399417cf6c7', '36da28c2-1be9-5541-a685-d78c7be05740', 'parent');
  perform pg_temp.rel('4f169bea-dc26-53af-b072-4399417cf6c7', 'f7ac5722-6a76-568b-9e95-7ba95f18b20c', 'parent');
  perform pg_temp.rel('929ffe28-a2df-51dc-bbe5-75f057e2ccfe', '698a1c86-a7bf-5a93-a32a-8a62f13d3fa6', 'parent');
  perform pg_temp.rel('698a1c86-a7bf-5a93-a32a-8a62f13d3fa6', '93d8321c-370b-59f5-b473-2fbf733ab8e9', 'parent');
  perform pg_temp.rel('93d8321c-370b-59f5-b473-2fbf733ab8e9', 'bca4d415-978a-505b-a801-5402195a90a1', 'parent');
  raise notice 'schema_v155 : % membres ajoutés.', 20;
end $$;
