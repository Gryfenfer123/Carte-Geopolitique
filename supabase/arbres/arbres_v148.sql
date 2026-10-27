-- arbres_v148.sql — Iran (Seldjoukides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Seldjoukides » (Iran) : 9 personnes, de Mikail à Ahmad Sanjar. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Pages lues : Chaghri Beg (989-1060, fils de Mikail, frère de Tughril), Alp Arslan (1029-1072, fils de Chaghri Beg), Malik-Shah I (1055-1092, fils d'Alp Arslan ; fils : Berkyaruq, Mahmud I, Muhammad I Tapar, Ahmad Sanjar), et « Seljuk Empire » (Tughril 990-1063, mort de Sanjar en 1157). Tughril est relié à Chaghri par un lien « famille » (frère) ; Mikail comme père de Chaghri Beg seulement. Les sultans seldjoukides de Roum (Anatolie) ne sont pas dans cet arbre.
-- Dates absentes pour les fils de Malik-Shah sauf la mort de Sanjar.
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
  if exists (select 1 from public.genealogy_members where id = 'bd25c5f4-7d5d-5806-806f-60a6b8fdfdfc') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Seldjoukides » (IRN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IRN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IRN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Seldjoukides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('9490416e-703a-5f9d-bfca-823a921d9a3a', cat_id, 'country', 'IRN', top, 'Seldjoukides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '9490416e-703a-5f9d-bfca-823a921d9a3a';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('a11ba850-8848-5830-acca-dbf73f06499c', 'country', 'IRN', 'genealogy', 'Seldjoukides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bd25c5f4-7d5d-5806-806f-60a6b8fdfdfc', 'entry', 'a11ba850-8848-5830-acca-dbf73f06499c', 'Mikail', null, null, null, 'Père de Chaghri Beg', 'Seldjoukides', 'Sources : https://en.wikipedia.org/wiki/Chaghri_Beg - père de Chaghri Beg selon la page de Chaghri Beg', 750, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a79b748a-cfa7-5624-8afa-463c2a492e24', 'entry', 'a11ba850-8848-5830-acca-dbf73f06499c', 'Tughril', null, 990, 1063, 'Premier sultan seldjoukide (1037-1063)', 'Seldjoukides', 'Sources : https://en.wikipedia.org/wiki/Seljuk_Empire - frère de Chaghri Beg', 2500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ecf2c72b-be3f-564a-8de5-5d3331d725ad', 'entry', 'a11ba850-8848-5830-acca-dbf73f06499c', 'Chaghri Beg', null, 989, 1060, 'Co-fondateur de la dynastie seldjoukide', 'Seldjoukides', 'Sources : https://en.wikipedia.org/wiki/Chaghri_Beg', 750, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('698c9173-44cb-5e77-a07e-87ddece12fc5', 'entry', 'a11ba850-8848-5830-acca-dbf73f06499c', 'Alp Arslan', null, 1029, 1072, 'Sultan seldjoukide (1063-1072)', 'Seldjoukides', 'Sources : https://en.wikipedia.org/wiki/Alp_Arslan - fils de Chaghri Beg', 750, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6a630045-297a-5a7f-b6d7-06b72dab5e95', 'entry', 'a11ba850-8848-5830-acca-dbf73f06499c', 'Malik-Shah I', null, 1055, 1092, 'Sultan seldjoukide (1072-1092)', 'Seldjoukides', 'Sources : https://en.wikipedia.org/wiki/Malik-Shah_I - fils d''Alp Arslan', 750, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9f102e32-0f1a-5a4e-ae28-33540bf6896c', 'entry', 'a11ba850-8848-5830-acca-dbf73f06499c', 'Berkyaruq', null, null, null, 'Sultan seldjoukide', 'Seldjoukides', 'Sources : https://en.wikipedia.org/wiki/Malik-Shah_I - fils de Malik-Shah I', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6c659f05-f7f2-5081-8d74-4214b9a57d57', 'entry', 'a11ba850-8848-5830-acca-dbf73f06499c', 'Mahmud I', null, null, null, 'Sultan seldjoukide, proclamé après 1092', 'Seldjoukides', 'Sources : https://en.wikipedia.org/wiki/Seljuk_Empire - fils de Malik-Shah I', 1000, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('41ebb18b-7fad-5cdd-9a9d-b6b83138b9be', 'entry', 'a11ba850-8848-5830-acca-dbf73f06499c', 'Muhammad I Tapar', null, null, null, 'Sultan seldjoukide (jusqu''en 1118)', 'Seldjoukides', 'Sources : https://en.wikipedia.org/wiki/Malik-Shah_I - fils de Malik-Shah I', 1500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6399fb9d-b0cb-5433-8654-2d7552729693', 'entry', 'a11ba850-8848-5830-acca-dbf73f06499c', 'Ahmad Sanjar', null, null, 1157, 'Sultan seldjoukide (1118-1157)', 'Seldjoukides', 'Sources : https://en.wikipedia.org/wiki/Malik-Shah_I - fils de Malik-Shah I ; mort en 1157', 0, 2560, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('bd25c5f4-7d5d-5806-806f-60a6b8fdfdfc', 'ecf2c72b-be3f-564a-8de5-5d3331d725ad', 'parent');
  perform pg_temp.rel('ecf2c72b-be3f-564a-8de5-5d3331d725ad', '698c9173-44cb-5e77-a07e-87ddece12fc5', 'parent');
  perform pg_temp.rel('698c9173-44cb-5e77-a07e-87ddece12fc5', '6a630045-297a-5a7f-b6d7-06b72dab5e95', 'parent');
  perform pg_temp.rel('6a630045-297a-5a7f-b6d7-06b72dab5e95', '9f102e32-0f1a-5a4e-ae28-33540bf6896c', 'parent');
  perform pg_temp.rel('6a630045-297a-5a7f-b6d7-06b72dab5e95', '6c659f05-f7f2-5081-8d74-4214b9a57d57', 'parent');
  perform pg_temp.rel('6a630045-297a-5a7f-b6d7-06b72dab5e95', '41ebb18b-7fad-5cdd-9a9d-b6b83138b9be', 'parent');
  perform pg_temp.rel('6a630045-297a-5a7f-b6d7-06b72dab5e95', '6399fb9d-b0cb-5433-8654-2d7552729693', 'parent');
  perform pg_temp.rel('ecf2c72b-be3f-564a-8de5-5d3331d725ad', 'a79b748a-cfa7-5624-8afa-463c2a492e24', 'family');
  raise notice 'schema_v148 : % membres ajoutés.', 9;
end $$;
