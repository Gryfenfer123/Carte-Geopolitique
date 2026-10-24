-- arbres_v126.sql — Yémen (imams Hamid ad-Din)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Hamid ad-Din » (Yémen) : 4 imams du royaume mutawakkilite. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Muhammad ben Yahya Hamid ad-Din (père de Yahya) : aucune date lue, fiche sans dates. Les imams yéménites plus anciens ne sont pas saisis (pages sans liens de parenté précis).
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
  if exists (select 1 from public.genealogy_members where id = 'aafd12b5-f108-5707-84ca-7f490735b948') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Hamid ad-Din » (YEM)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'YEM' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour YEM : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Hamid ad-Din';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('e35ffc0d-2eaa-5033-bb31-386dc62edaf9', cat_id, 'country', 'YEM', top, 'Hamid ad-Din', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'e35ffc0d-2eaa-5033-bb31-386dc62edaf9';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('7cd4a467-956a-577d-9a85-aecf026f4718', 'country', 'YEM', 'genealogy', 'Hamid ad-Din', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('aafd12b5-f108-5707-84ca-7f490735b948', 'entry', '7cd4a467-956a-577d-9a85-aecf026f4718', 'Muhammad ben Yahya Hamid ad-Din (al-Mansour)', null, null, null, 'Imam zaydite, père de l''imam Yahya', 'Hamid ad-Din', 'Sources : https://en.wikipedia.org/wiki/List_of_Kings_of_Yemen', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('0b41863a-36b1-570c-b731-5f5fc61259ce', 'entry', '7cd4a467-956a-577d-9a85-aecf026f4718', 'Yahya Muhammad Hamid ad-Din', null, 1869, 1948, 'Imam et roi du Yémen (1918-1948)', 'Hamid ad-Din', 'Sources : https://en.wikipedia.org/wiki/List_of_Kings_of_Yemen', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('01d87a50-3683-5aeb-a6fe-97781b2d31f3', 'entry', '7cd4a467-956a-577d-9a85-aecf026f4718', 'Ahmad ben Yahya', null, 1891, 1962, 'Imam et roi du Yémen (1948-1962)', 'Hamid ad-Din', 'Sources : https://en.wikipedia.org/wiki/List_of_Kings_of_Yemen', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('701fdaf3-8294-5608-a7e9-fb3b21653062', 'entry', '7cd4a467-956a-577d-9a85-aecf026f4718', 'Muhammad al-Badr', null, 1926, 1996, 'Dernier imam du Yémen (1962)', 'Hamid ad-Din', 'Sources : https://en.wikipedia.org/wiki/List_of_Kings_of_Yemen', 0, 1920, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('aafd12b5-f108-5707-84ca-7f490735b948', '0b41863a-36b1-570c-b731-5f5fc61259ce', 'parent');
  perform pg_temp.rel('0b41863a-36b1-570c-b731-5f5fc61259ce', '01d87a50-3683-5aeb-a6fe-97781b2d31f3', 'parent');
  perform pg_temp.rel('01d87a50-3683-5aeb-a6fe-97781b2d31f3', '701fdaf3-8294-5608-a7e9-fb3b21653062', 'parent');
  raise notice 'schema_v126 : % membres ajoutés.', 4;
end $$;
