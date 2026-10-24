-- arbres_v129.sql — Liban (Chéhab)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Chéhab » (Liban) : émirs du Mont-Liban de la lignée de Haydar. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Pages lues : Shihab dynasty, Bashir Shihab II, Yusuf Shihab. Les pages ne donnent pas de dates de naissance sauf pour Yusuf et Bashir II. Musa (père de Haydar), Husayn (père de Bashir Ier) et Bashir Ier ne sont pas saisis ; Bashir III non saisi (parenté non indiquée).
-- Bashir II est cousin de Yusuf (page de Bashir II) : lien « famille ». Son père est nommé Qasim Shihab, mais la parenté avec le Qasim fils de Mulhim n'est pas établie par les pages : non relié.
-- Dates en année chrétienne telles que la page les donne.
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
  if exists (select 1 from public.genealogy_members where id = '202769b4-40df-533f-9885-53face91b857') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Chéhab » (LBN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'LBN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour LBN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Chéhab';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('313cd4cf-3f07-5534-bc64-dccbcb01ee26', cat_id, 'country', 'LBN', top, 'Chéhab', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '313cd4cf-3f07-5534-bc64-dccbcb01ee26';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('4138100f-0297-5414-b3b8-ce5bd23b014e', 'country', 'LBN', 'genealogy', 'Chéhab', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('202769b4-40df-533f-9885-53face91b857', 'entry', '4138100f-0297-5414-b3b8-ce5bd23b014e', 'Haydar Chéhab', null, null, 1732, 'Émir du Mont-Liban (1711-1732)', 'Chéhab', 'Sources : https://en.wikipedia.org/wiki/Shihab_dynasty - chassé en 1709, rétabli en 1711', 500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7277f9d0-60c3-5fc7-9cd6-3dc95ca36f32', 'entry', '4138100f-0297-5414-b3b8-ce5bd23b014e', 'Mulhim Chéhab', null, null, 1759, 'Émir du Mont-Liban (1732-1753)', 'Chéhab', 'Sources : https://en.wikipedia.org/wiki/Shihab_dynasty', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('45fb0f3f-af3f-5a6c-acf5-6ff7868313f8', 'entry', '4138100f-0297-5414-b3b8-ce5bd23b014e', 'Mansour Chéhab', null, null, null, 'Émir du Mont-Liban (démission en 1770)', 'Chéhab', 'Sources : https://en.wikipedia.org/wiki/Shihab_dynasty', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9651508a-af87-598c-85ee-bb6340fd34e1', 'entry', '4138100f-0297-5414-b3b8-ce5bd23b014e', 'Ahmad Chéhab', null, null, null, 'Prétendant à l''émirat, fils de Haydar', 'Chéhab', 'Sources : https://en.wikipedia.org/wiki/Shihab_dynasty', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('250eff5a-8c0e-58bc-89fa-5791e245bc67', 'entry', '4138100f-0297-5414-b3b8-ce5bd23b014e', 'Qasim Chéhab', null, null, null, 'Émir du Mont-Liban (1760)', 'Chéhab', 'Sources : https://en.wikipedia.org/wiki/Shihab_dynasty', 250, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5eb64cdb-57bd-54fb-a264-abe0d9408aab', 'entry', '4138100f-0297-5414-b3b8-ce5bd23b014e', 'Yusuf Chéhab', null, 1748, 1790, 'Émir du Mont-Liban (1770-1789)', 'Chéhab', 'Sources : https://en.wikipedia.org/wiki/Yusuf_Shihab', 750, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('8829d484-a83f-53f4-a703-3627a31c0780', 'entry', '4138100f-0297-5414-b3b8-ce5bd23b014e', 'Bachir II Chéhab', null, 1767, 1850, 'Émir du Mont-Liban (1789-1840)', 'Chéhab', 'Sources : https://en.wikipedia.org/wiki/Bashir_Shihab_II', 2000, 1280, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('202769b4-40df-533f-9885-53face91b857', '7277f9d0-60c3-5fc7-9cd6-3dc95ca36f32', 'parent');
  perform pg_temp.rel('202769b4-40df-533f-9885-53face91b857', '45fb0f3f-af3f-5a6c-acf5-6ff7868313f8', 'parent');
  perform pg_temp.rel('202769b4-40df-533f-9885-53face91b857', '9651508a-af87-598c-85ee-bb6340fd34e1', 'parent');
  perform pg_temp.rel('7277f9d0-60c3-5fc7-9cd6-3dc95ca36f32', '250eff5a-8c0e-58bc-89fa-5791e245bc67', 'parent');
  perform pg_temp.rel('7277f9d0-60c3-5fc7-9cd6-3dc95ca36f32', '5eb64cdb-57bd-54fb-a264-abe0d9408aab', 'parent');
  perform pg_temp.rel('5eb64cdb-57bd-54fb-a264-abe0d9408aab', '8829d484-a83f-53f4-a703-3627a31c0780', 'family');
  raise notice 'schema_v129 : % membres ajoutés.', 7;
end $$;
