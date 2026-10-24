-- arbres_v119.sql — Syrie (Omeyyades) et Irak (Abbassides)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Deux nouveaux arbres : « Omeyyades » (Syrie) et « Abbassides » (Irak). Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.
-- Dates en année chrétienne, telles que la page les donne ; quand la page propose plusieurs années (« 623 ou 626 »), la première est retenue et la fiche le dit. Date approximative signalée par « c. ».
-- Liens « famille » (et non parent-enfant direct) quand un chaînon n'est pas saisi : Marwan Ier → Omar II et Marwan II ; Ali ibn Abdallah → al-Saffah et al-Mansur (leur père Muhammad ibn Ali n'a pas pu être lu) ; al-Mansur → Zubayda (sa petite-fille). Abou Soufyane et Marwan Ier appartiennent à la même famille Omeyya mais ne sont pas reliés.
-- Non fait : autres califes omeyyades et abbassides, califes de Cordoue, califat du Caire.
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
  if exists (select 1 from public.genealogy_members where id = 'a1431b8d-789d-5db2-9c19-9a4e75238e16') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  -- Arbre « Omeyyades » (SYR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'SYR' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour SYR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Omeyyades';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('287209d3-b2e5-5874-b975-7d123093c655', cat_id, 'country', 'SYR', top, 'Omeyyades', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '287209d3-b2e5-5874-b975-7d123093c655';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('d8825687-17d2-565f-b6c7-7a33994b2051', 'country', 'SYR', 'genealogy', 'Omeyyades', cat_id, sec, admin_id);
  -- Arbre « Abbassides » (IRQ)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'IRQ' and lower(title) = 'dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour IRQ : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Abbassides';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('78c82554-3b90-52bd-8784-c7422d96d86f', cat_id, 'country', 'IRQ', top, 'Abbassides', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '78c82554-3b90-52bd-8784-c7422d96d86f';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'country', 'IRQ', 'genealogy', 'Abbassides', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('a1431b8d-789d-5db2-9c19-9a4e75238e16', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Abou Soufyane ibn Harb', null, 560, 653, 'Chef de La Mecque, père de Muawiya Ier', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Abu_Sufyan_ibn_Harb — naissance c. 560 ; mort 652 ou 653 (653 retenu)', 2500, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9f64afb1-c6ee-5708-87e6-795839bda732', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Muawiya Ier', null, 597, 680, 'Premier calife omeyyade (661-680)', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Muawiya_I — naissance c. 597, 603 ou 605 (597 retenu)', 2500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('7757ff58-e424-530e-8a7e-852e4d66fbf0', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Yazid Ier', null, 646, 683, 'Calife omeyyade (680-683)', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Yazid_I — naissance c. 646', 2500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('ef4b278d-ee9f-5003-9af1-b35793f794b0', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Muawiya II', null, 664, 684, 'Calife omeyyade (683-684)', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Muawiya_II — naissance c. 664', 2500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('cab0e6d4-14ad-5eae-9e10-68610b4082f3', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Marwan Ier', null, 623, 685, 'Calife omeyyade (684-685), fondateur de la branche marwanide', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Marwan_I — naissance 623 ou 626 (623 retenu) ; père al-Hakam ibn Abi al-As', 750, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('b20237a8-4db1-55a2-992a-7ee2e29e5047', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Abd al-Malik', null, 644, 705, 'Calife omeyyade (685-705)', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Abd_al-Malik_ibn_Marwan — naissance 644 ou 647 (644 retenu)', 750, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('042a56c9-2ed0-5549-9559-a7e6943044c3', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Al-Walid Ier', null, 674, 715, 'Calife omeyyade (705-715)', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Al-Walid_I — naissance c. 674', 0, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e3229409-67a3-52aa-a656-6e363f2101b1', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Sulayman ibn Abd al-Malik', null, 675, 717, 'Calife omeyyade (715-717)', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Sulayman_ibn_Abd_al-Malik — naissance c. 675', 500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('27ff14a3-4ec6-504f-a770-62f62e7955cb', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Omar II', null, 680, 720, 'Calife omeyyade (717-720)', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Umar_ibn_Abd_al-Aziz — naissance c. 680 ; père Abd al-Aziz ibn Marwan (hors arbre)', 3500, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('38c6b355-0d10-503d-bdd4-0f0798c347cd', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Yazid II', null, 690, 724, 'Calife omeyyade (720-724)', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Yazid_II — naissance c. 690/691', 1000, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('eb2de662-029d-5c9f-834d-de0a570275fe', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Hicham ibn Abd al-Malik', null, 691, 743, 'Calife omeyyade (724-743)', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Hisham_ibn_Abd_al-Malik', 1500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e3c62b63-83f7-5c3c-be2d-db32f10bc68c', 'entry', 'd8825687-17d2-565f-b6c7-7a33994b2051', 'Marwan II', null, 691, 750, 'Dernier calife omeyyade (744-750)', 'Omeyyades', 'Sources : https://en.wikipedia.org/wiki/Marwan_II — naissance c. 691 ; père Muhammad ibn Marwan (hors arbre)', 4500, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('98325c62-4ad8-5586-b041-484389b13359', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Al-Abbas ibn Abd al-Muttalib', null, 566, 653, 'Oncle du prophète Mahomet, ancêtre des Abbassides', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Al-Abbas_ibn_Abd_al-Muttalib — dates c.', 2117, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c7986fa9-0e8b-534d-bb7b-223310594586', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Abdallah ibn Abbas', null, 619, 687, 'Compagnon du prophète, ancêtre des Abbassides', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Abdullah_ibn_Abbas — naissance c. 619', 2117, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('9bf3b001-66fc-57b3-8598-593db742ac80', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Ali ibn Abdallah ibn Abbas', null, 661, 736, 'Ancêtre des califes abbassides', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Ali_ibn_Abd_Allah_ibn_al-Abbas — naissance c. 661', 2117, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('c50e171f-b40a-5edf-948d-0762517d097e', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Al-Saffah', null, 721, 754, 'Premier calife abbasside (750-754)', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Al-Saffah — naissance 721 ou 722 (721 retenu) ; père Muhammad ibn Ali (non saisi)', 3117, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('fc49cc3e-813a-5695-af60-7ec9377b991b', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Al-Mansour', null, 714, 775, 'Calife abbasside (754-775), fondateur de Bagdad', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Al-Mansur — père Muhammad ibn Ali (non saisi)', 865, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('e87f26a1-0923-50c5-9696-a8b4c05fe74e', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Al-Mahdi', null, 744, 785, 'Calife abbasside (775-785)', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Al-Mahdi — naissance 744 ou 745 (744 retenu)', 865, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('5dc94500-a0a8-5d1c-ba2a-f0d88f3a4afa', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Al-Hadi', null, 759, 786, 'Calife abbasside (785-786)', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Al-Hadi — naissance 759 ou 762 (759 retenu)', 990, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('bf539724-fd32-5431-9c88-e7548e0e22a3', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Haroun al-Rachid', null, 763, 809, 'Calife abbasside (786-809)', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Harun_al-Rashid — naissance c. 763 ou 766 (763 retenu)', 490, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('db9e0dab-a4e3-5709-8c05-56aed72f89ef', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Zubayda bint Jafar', null, 765, 831, 'Épouse de Haroun al-Rachid, mère d''al-Amin', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Zubaidah_bint_Ja%27far — naissance 765 ou 766 (765 retenu) ; père Jafar ibn al-Mansour (hors arbre)', 0, 3840, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('720218d6-43f2-5b91-9569-e3035623ebea', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Al-Amin', null, 787, 813, 'Calife abbasside (809-813)', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Al-Amin', 117, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('3fcb50fe-d85d-5ff1-9b27-564d49f6a8a7', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Al-Mamoun', null, 786, 833, 'Calife abbasside (813-833)', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Al-Ma%27mun', 1117, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('1fe94099-0bab-5a72-999c-b63c3e53ff78', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Al-Moutassim', null, 796, 842, 'Calife abbasside (833-842)', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Al-Mu%27tasim', 617, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('222a3cc7-047d-5374-8135-f162d72b2683', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Al-Wathiq', null, 812, 847, 'Calife abbasside (842-847)', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Al-Wathiq', 885, 5120, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader) values ('6b88bac5-ad60-5dd7-b0c9-5e72e2eabaae', 'entry', 'ab642ed9-93a3-5c13-be50-46b08dddd8ef', 'Al-Moutawakkil', null, 822, 861, 'Calife abbasside (847-861)', 'Abbassides', 'Sources : https://en.wikipedia.org/wiki/Al-Mutawakkil', 385, 5120, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('a1431b8d-789d-5db2-9c19-9a4e75238e16', '9f64afb1-c6ee-5708-87e6-795839bda732', 'parent');
  perform pg_temp.rel('9f64afb1-c6ee-5708-87e6-795839bda732', '7757ff58-e424-530e-8a7e-852e4d66fbf0', 'parent');
  perform pg_temp.rel('7757ff58-e424-530e-8a7e-852e4d66fbf0', 'ef4b278d-ee9f-5003-9af1-b35793f794b0', 'parent');
  perform pg_temp.rel('cab0e6d4-14ad-5eae-9e10-68610b4082f3', 'b20237a8-4db1-55a2-992a-7ee2e29e5047', 'parent');
  perform pg_temp.rel('b20237a8-4db1-55a2-992a-7ee2e29e5047', '042a56c9-2ed0-5549-9559-a7e6943044c3', 'parent');
  perform pg_temp.rel('b20237a8-4db1-55a2-992a-7ee2e29e5047', 'e3229409-67a3-52aa-a656-6e363f2101b1', 'parent');
  perform pg_temp.rel('b20237a8-4db1-55a2-992a-7ee2e29e5047', '38c6b355-0d10-503d-bdd4-0f0798c347cd', 'parent');
  perform pg_temp.rel('b20237a8-4db1-55a2-992a-7ee2e29e5047', 'eb2de662-029d-5c9f-834d-de0a570275fe', 'parent');
  perform pg_temp.rel('cab0e6d4-14ad-5eae-9e10-68610b4082f3', '27ff14a3-4ec6-504f-a770-62f62e7955cb', 'family');
  perform pg_temp.rel('cab0e6d4-14ad-5eae-9e10-68610b4082f3', 'e3c62b63-83f7-5c3c-be2d-db32f10bc68c', 'family');
  perform pg_temp.rel('98325c62-4ad8-5586-b041-484389b13359', 'c7986fa9-0e8b-534d-bb7b-223310594586', 'parent');
  perform pg_temp.rel('c7986fa9-0e8b-534d-bb7b-223310594586', '9bf3b001-66fc-57b3-8598-593db742ac80', 'parent');
  perform pg_temp.rel('fc49cc3e-813a-5695-af60-7ec9377b991b', 'e87f26a1-0923-50c5-9696-a8b4c05fe74e', 'parent');
  perform pg_temp.rel('e87f26a1-0923-50c5-9696-a8b4c05fe74e', '5dc94500-a0a8-5d1c-ba2a-f0d88f3a4afa', 'parent');
  perform pg_temp.rel('e87f26a1-0923-50c5-9696-a8b4c05fe74e', 'bf539724-fd32-5431-9c88-e7548e0e22a3', 'parent');
  perform pg_temp.rel('bf539724-fd32-5431-9c88-e7548e0e22a3', '720218d6-43f2-5b91-9569-e3035623ebea', 'parent');
  perform pg_temp.rel('db9e0dab-a4e3-5709-8c05-56aed72f89ef', '720218d6-43f2-5b91-9569-e3035623ebea', 'parent');
  perform pg_temp.rel('bf539724-fd32-5431-9c88-e7548e0e22a3', '3fcb50fe-d85d-5ff1-9b27-564d49f6a8a7', 'parent');
  perform pg_temp.rel('bf539724-fd32-5431-9c88-e7548e0e22a3', '1fe94099-0bab-5a72-999c-b63c3e53ff78', 'parent');
  perform pg_temp.rel('1fe94099-0bab-5a72-999c-b63c3e53ff78', '222a3cc7-047d-5374-8135-f162d72b2683', 'parent');
  perform pg_temp.rel('1fe94099-0bab-5a72-999c-b63c3e53ff78', '6b88bac5-ad60-5dd7-b0c9-5e72e2eabaae', 'parent');
  perform pg_temp.rel('9bf3b001-66fc-57b3-8598-593db742ac80', 'c50e171f-b40a-5edf-948d-0762517d097e', 'family');
  perform pg_temp.rel('9bf3b001-66fc-57b3-8598-593db742ac80', 'fc49cc3e-813a-5695-af60-7ec9377b991b', 'family');
  perform pg_temp.rel('fc49cc3e-813a-5695-af60-7ec9377b991b', 'db9e0dab-a4e3-5709-8c05-56aed72f89ef', 'family');
  perform pg_temp.rel('bf539724-fd32-5431-9c88-e7548e0e22a3', 'db9e0dab-a4e3-5709-8c05-56aed72f89ef', 'spouse');
  raise notice 'schema_v119 : % membres ajoutés.', 26;
end $$;
