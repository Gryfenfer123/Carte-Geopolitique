-- arbres_v86.sql — Chine — dynastie Qing de Nurhaci à Puyi
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Qing » (aucun n'existait). Rien n'est supprimé.
-- Dates : connues par ailleurs (histoire de Chine), aucune page consultée pour ce lot. Guangxu et Puyi descendent de Daoguang par le prince Chun (Yixuan) puis Zaifeng, non empereurs.
-- Les impératrices Xiaozhuangwen et Cixi viennent de familles sans arbre (Borjigit, Yehe Nara) : signalées.
-- Non fait : Dorgon et autres princes, épouses autres que Xiaozhuangwen et Cixi.
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
  if exists (select 1 from public.genealogy_members where id = 'c2581fba-d9bc-5a5f-a607-e0f7ecee1dfc') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Qing » (CHN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'CHN' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour CHN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Qing';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('b52f2f79-a641-52b6-9016-07b8b6d1ddbf', cat_id, 'country', 'CHN', top, 'Qing', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'b52f2f79-a641-52b6-9016-07b8b6d1ddbf';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('becb86a3-258f-5a43-a34d-c098a502cb33', 'country', 'CHN', 'genealogy', 'Qing', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c2581fba-d9bc-5a5f-a607-e0f7ecee1dfc', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Nurhaci (Qing Taizu)', null, 1559, 1626, 'Fondateur de la dynastie (khan des Jin postérieurs)', 'Qing (Aisin Gioro)', 985, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a00ea2f1-f6b1-505a-a89f-6bb0e11de83b', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Hong Taiji (Qing Taizong)', null, 1592, 1643, 'Empereur (1626-1643), fonde officiellement les Qing', 'Qing (Aisin Gioro)', 985, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4f46fc6d-546d-5964-aa10-97a48b101b85', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Shunzhi (Fulin)', null, 1638, 1661, 'Premier empereur Qing à Pékin (1644-1661)', 'Qing (Aisin Gioro)', 740, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3c170065-f7db-5af9-ac72-2d4e84eb7aa2', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Kangxi (Xuanye)', null, 1654, 1722, 'Empereur (1661-1722)', 'Qing (Aisin Gioro)', 740, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fefdcd5e-3552-5e69-8d48-145e5cf5d375', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Yongzheng (Yinzhen)', null, 1678, 1735, 'Empereur (1722-1735)', 'Qing (Aisin Gioro)', 740, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('97f627e9-a99a-5c7b-a331-b02571c529a4', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Qianlong (Hongli)', null, 1711, 1799, 'Empereur (1735-1796)', 'Qing (Aisin Gioro)', 740, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a5281e23-9fbd-5d16-9969-0b28d4dc7383', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Jiaqing (Yongyan)', null, 1760, 1820, 'Empereur (1796-1820)', 'Qing (Aisin Gioro)', 740, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('cca82f84-2e79-54ac-9e7b-ea6ca644da28', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Daoguang (Minning)', null, 1782, 1850, 'Empereur (1820-1850), guerre de l''opium', 'Qing (Aisin Gioro)', 740, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('46899c09-eee7-5cef-92d8-24bf306ba167', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Xianfeng (Yizhu)', null, 1831, 1861, 'Empereur (1850-1861)', 'Qing (Aisin Gioro)', 490, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4f094a07-6613-5790-91cd-026514e1a592', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Tongzhi (Zaichun)', null, 1856, 1875, 'Empereur (1861-1875)', 'Qing (Aisin Gioro)', 245, 5760, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('be5fb27e-0586-577d-b50b-488d800672c2', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Yixuan, prince Chun', null, 1840, 1891, 'Fils de Daoguang, père de Guangxu', 'Qing (Aisin Gioro)', 990, 5120, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5ef532fa-e8b8-5395-b9dc-f70515aae8da', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Guangxu (Zaitian)', null, 1871, 1908, 'Empereur (1875-1908)', 'Qing (Aisin Gioro)', 1240, 6400, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e3565c7f-adac-5937-8520-687e953f6fbe', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Zaifeng, prince Chun', null, 1883, 1951, 'Régent, père de Puyi', 'Qing (Aisin Gioro)', 740, 6400, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('48e863ef-ec72-5149-8be3-fcd949b49088', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Puyi (Xuantong)', null, 1906, 1967, 'Dernier empereur de Chine (1908-1912)', 'Qing (Aisin Gioro)', 740, 7040, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('dc23c6dc-d7ea-56e8-a0a0-364867e028d4', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Impératrice Xiaozhuangwen', null, 1613, 1688, 'Épouse de Hong Taiji, mère de Shunzhi', 'Borjigit', 495, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7b8735c6-1808-5d93-aa20-b5c820e92522', 'entry', 'becb86a3-258f-5a43-a34d-c098a502cb33', 'Cixi', null, 1835, 1908, 'Impératrice douairière, régente, mère de Tongzhi', 'Yehe Nara', 0, 5120, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('c2581fba-d9bc-5a5f-a607-e0f7ecee1dfc', 'a00ea2f1-f6b1-505a-a89f-6bb0e11de83b', 'parent');
  perform pg_temp.rel('a00ea2f1-f6b1-505a-a89f-6bb0e11de83b', '4f46fc6d-546d-5964-aa10-97a48b101b85', 'parent');
  perform pg_temp.rel('4f46fc6d-546d-5964-aa10-97a48b101b85', '3c170065-f7db-5af9-ac72-2d4e84eb7aa2', 'parent');
  perform pg_temp.rel('3c170065-f7db-5af9-ac72-2d4e84eb7aa2', 'fefdcd5e-3552-5e69-8d48-145e5cf5d375', 'parent');
  perform pg_temp.rel('fefdcd5e-3552-5e69-8d48-145e5cf5d375', '97f627e9-a99a-5c7b-a331-b02571c529a4', 'parent');
  perform pg_temp.rel('97f627e9-a99a-5c7b-a331-b02571c529a4', 'a5281e23-9fbd-5d16-9969-0b28d4dc7383', 'parent');
  perform pg_temp.rel('a5281e23-9fbd-5d16-9969-0b28d4dc7383', 'cca82f84-2e79-54ac-9e7b-ea6ca644da28', 'parent');
  perform pg_temp.rel('cca82f84-2e79-54ac-9e7b-ea6ca644da28', '46899c09-eee7-5cef-92d8-24bf306ba167', 'parent');
  perform pg_temp.rel('46899c09-eee7-5cef-92d8-24bf306ba167', '4f094a07-6613-5790-91cd-026514e1a592', 'parent');
  perform pg_temp.rel('cca82f84-2e79-54ac-9e7b-ea6ca644da28', 'be5fb27e-0586-577d-b50b-488d800672c2', 'parent');
  perform pg_temp.rel('be5fb27e-0586-577d-b50b-488d800672c2', '5ef532fa-e8b8-5395-b9dc-f70515aae8da', 'parent');
  perform pg_temp.rel('be5fb27e-0586-577d-b50b-488d800672c2', 'e3565c7f-adac-5937-8520-687e953f6fbe', 'parent');
  perform pg_temp.rel('e3565c7f-adac-5937-8520-687e953f6fbe', '48e863ef-ec72-5149-8be3-fcd949b49088', 'parent');
  perform pg_temp.rel('a00ea2f1-f6b1-505a-a89f-6bb0e11de83b', 'dc23c6dc-d7ea-56e8-a0a0-364867e028d4', 'spouse');
  perform pg_temp.rel('dc23c6dc-d7ea-56e8-a0a0-364867e028d4', '4f46fc6d-546d-5964-aa10-97a48b101b85', 'parent');
  perform pg_temp.rel('46899c09-eee7-5cef-92d8-24bf306ba167', '7b8735c6-1808-5d93-aa20-b5c820e92522', 'spouse');
  perform pg_temp.rel('7b8735c6-1808-5d93-aa20-b5c820e92522', '4f094a07-6613-5790-91cd-026514e1a592', 'parent');
  raise notice 'schema_v86 : % membres ajoutés.', 16;
end $$;
