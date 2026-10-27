-- arbres_v151.sql — Iran (Bouyides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Nouvel arbre « Bouyides » (Iran) : 6 personnes. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Page « Buyid dynasty » : Ali, Hasan et Ahmad fils de Buya ; Muayyad al-Dawla fils de Rukn al-Dawla (Hasan) ; Fakhr al-Dawla frère de Muayyad (lien « famille »). Adud al-Dawla n'est pas ajouté : la page ne donne pas son père. Aucune date de naissance ou de mort.
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
  if exists (select 1 from public.genealogy_members where id = '2e224187-6866-5735-8cdc-f86e2f5b16a0') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Bouyides » (IRN)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IRN' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IRN : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Bouyides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('c06cd7e4-b71f-5022-8787-26e02c2d5cfe', cat_id, 'country', 'IRN', top, 'Bouyides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'c06cd7e4-b71f-5022-8787-26e02c2d5cfe';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('f6bf6842-0775-53b9-9c06-f12e7f8994d4', 'country', 'IRN', 'genealogy', 'Bouyides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('2e224187-6866-5735-8cdc-f86e2f5b16a0', 'entry', 'f6bf6842-0775-53b9-9c06-f12e7f8994d4', 'Buya', null, null, null, 'Père des trois premiers émirs bouyides', 'Bouyides', 'Sources : https://en.wikipedia.org/wiki/Buyid_dynasty - père d''Ali, Hasan et Ahmad', 500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('984e74d0-9692-543e-811c-23eb4fa81ef9', 'entry', 'f6bf6842-0775-53b9-9c06-f12e7f8994d4', 'Ali ibn Buya (Imad al-Dawla)', null, null, null, 'Émir de Fars (934-949)', 'Bouyides', 'Sources : https://en.wikipedia.org/wiki/Buyid_dynasty', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('49feb3b4-9801-557a-a4ec-a6ec5c621184', 'entry', 'f6bf6842-0775-53b9-9c06-f12e7f8994d4', 'Hasan ibn Buya (Rukn al-Dawla)', null, null, null, 'Émir de Ray (935-976)', 'Bouyides', 'Sources : https://en.wikipedia.org/wiki/Buyid_dynasty', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cca6517e-a1b3-5421-ae93-0daad2381c3b', 'entry', 'f6bf6842-0775-53b9-9c06-f12e7f8994d4', 'Ahmad ibn Buya (Muizz al-Dawla)', null, null, null, 'Émir d''Irak (945-967)', 'Bouyides', 'Sources : https://en.wikipedia.org/wiki/Buyid_dynasty', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('be3bfa22-55fb-50b7-a659-f3095ec93846', 'entry', 'f6bf6842-0775-53b9-9c06-f12e7f8994d4', 'Muayyad al-Dawla', null, null, null, 'Émir de Ray puis Hamadan (976-983)', 'Bouyides', 'Sources : https://en.wikipedia.org/wiki/Buyid_dynasty - fils de Rukn al-Dawla', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a88f522f-1d17-598a-aac9-d000751fd2d1', 'entry', 'f6bf6842-0775-53b9-9c06-f12e7f8994d4', 'Fakhr al-Dawla', null, null, null, 'Émir de Ray (976-980 ; 984-997)', 'Bouyides', 'Sources : https://en.wikipedia.org/wiki/Buyid_dynasty - frère de Muayyad al-Dawla selon la page', 2000, 0, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('2e224187-6866-5735-8cdc-f86e2f5b16a0', '984e74d0-9692-543e-811c-23eb4fa81ef9', 'parent');
  perform pg_temp.rel('2e224187-6866-5735-8cdc-f86e2f5b16a0', '49feb3b4-9801-557a-a4ec-a6ec5c621184', 'parent');
  perform pg_temp.rel('2e224187-6866-5735-8cdc-f86e2f5b16a0', 'cca6517e-a1b3-5421-ae93-0daad2381c3b', 'parent');
  perform pg_temp.rel('49feb3b4-9801-557a-a4ec-a6ec5c621184', 'be3bfa22-55fb-50b7-a659-f3095ec93846', 'parent');
  perform pg_temp.rel('be3bfa22-55fb-50b7-a659-f3095ec93846', 'a88f522f-1d17-598a-aac9-d000751fd2d1', 'family');
  raise notice 'schema_v151 : % membres ajoutés.', 6;
end $$;
