-- arbres_v95.sql — Italie — Este (Ferrare), Gonzague (Mantoue) et Farnèse (Parme)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Trois nouveaux arbres : « Este », « Gonzague » et « Farnèse » (aucun n'existait). Béatrice d'Este (arbre Sforza), Éléonore de Gonzague (Habsbourg), Élisabeth Farnèse (Bourbon d'Espagne), Marguerite d'Autriche (Médicis) et Éléonore de Médicis y sont affichées. Rien n'est supprimé.
-- Dates : connues par ailleurs (histoire d'Italie), aucune page consultée pour ce lot.
-- Renée de France est créée dans l'arbre Valois, Éléonore d'Autriche dans l'arbre Habsbourg, Marguerite de Médicis dans l'arbre Médicis, Marie de Portugal et son père dans l'arbre Aviz. Autres épouses de familles sans arbre (Aragon-Naples, Borgia, Bretagne, Brandebourg, Aldobrandini…) : signalées.
-- Non fait : branche de Modène (Este après 1597), Gonzague-Nevers, Montferrat, enfants cadets et cardinaux.
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
  if exists (select 1 from public.genealogy_members where id = '4571fe56-dda2-520f-967a-cc68318d2bad') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('2df9c2fd-8fd9-4bb4-b23a-f064afb0e301','376de58a-617f-5d5a-98cc-79695efc3ede','507c3d51-bc0e-5fd3-98f4-d80f2a501503','5539ea53-f47b-5952-883b-23c7429e5bb5','60980970-8d53-5628-b0dd-7baadfa1e7e7','66e055eb-cc8d-4e44-89ba-2e0e78821d30','927ddf7d-6da1-4ccb-b1e3-493ca40de381','995c8249-ac49-4468-babb-61ce8ce60709','9d06c682-eab3-5cac-81f3-0233c71b71e1','d8bc083b-3136-4c78-b005-900b69ebbab1','e2b87c64-43e9-4446-9f59-84b65f42386d','f06f9b33-6613-4380-af93-2d6493ffb942','f388aa57-8aca-54ed-9b7d-1973561af12f');
  if k <> 13 then raise exception 'Membres préexistants manquants (% sur 13) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Este » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Este';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('d31465f3-3e5e-5c53-9e76-ab543875ae6b', cat_id, 'country', 'ITA', top, 'Este', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := 'd31465f3-3e5e-5c53-9e76-ab543875ae6b';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('46971805-4ab8-5166-a475-2b53e19d6f12', 'country', 'ITA', 'genealogy', 'Este', cat_id, sec, admin_id);
  -- Arbre « Gonzague » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Gonzague';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('6063e3ea-51bc-5a0a-a925-2e6260626b32', cat_id, 'country', 'ITA', top, 'Gonzague', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '6063e3ea-51bc-5a0a-a925-2e6260626b32';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('2660365e-f536-5ec5-a3c3-fe4b028a1111', 'country', 'ITA', 'genealogy', 'Gonzague', cat_id, sec, admin_id);
  -- Arbre « Farnèse » (ITA)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'ITA' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour ITA : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Farnèse';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('8c26e7bc-21b6-58de-8d71-999bfa85be06', cat_id, 'country', 'ITA', top, 'Farnèse', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '8c26e7bc-21b6-58de-8d71-999bfa85be06';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('08ddd858-acce-5597-b66f-0a93557a9abd', 'country', 'ITA', 'genealogy', 'Farnèse', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = 'a92b4627-d9e5-4325-81ed-8b3dfebacf5b' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Valois introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '6b34bc03-d0ad-4c48-a485-f541cecafd5d' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Habsbourg introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '31ab743f-533f-5c1b-b317-728a4e0067b5' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Médicis introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = 'efb44952-74d4-4e3e-8247-8c1003978d3d' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Maison d''Aviz introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('4571fe56-dda2-520f-967a-cc68318d2bad', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'Niccolò III d''Este', null, 1383, 1441, 'Marquis de Ferrare', 'Este', 500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('78881a6d-d8db-5d97-903e-d698e3b0ec19', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'Leonello d''Este', null, 1407, 1450, 'Marquis de Ferrare', 'Este', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c276b670-1776-5c04-82c3-8f52daf66035', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'Borso d''Este', null, 1413, 1471, 'Premier duc de Ferrare', 'Este', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('61dcdaea-ba35-5ed6-aac7-604aeb97dd1d', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'Hercule Ier d''Este', null, 1431, 1505, 'Duc de Ferrare', 'Este', 1000, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('75ca12f3-659c-501e-8ea2-7485ac2033df', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'Alphonse Ier d''Este', null, 1476, 1534, 'Duc de Ferrare', 'Este', 1995, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('848fc0c9-a83d-5613-8bd6-704a42a55239', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'Hercule II d''Este', null, 1508, 1559, 'Duc de Ferrare', 'Este', 2240, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('99cace75-4c94-56ce-ac8d-f819885fd5e5', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'Alphonse II d''Este', null, 1533, 1597, 'Dernier duc de Ferrare', 'Este', 2240, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8363433f-d262-5817-b13d-a8c5ab88e7cd', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'César d''Este', null, 1562, 1628, 'Premier duc de Modène', 'Este', 3730, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a810968f-0a99-50c7-8a00-63b1ec538b50', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'Éléonore d''Aragon (Naples)', null, 1450, 1493, 'Duchesse de Ferrare', 'Aragon-Naples', 1490, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7029062f-c4e5-5b91-9676-ec306b024a07', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'Isabelle d''Este', null, 1474, 1539, 'Marquise de Mantoue', 'Este', 495, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('03d5e693-81ed-56af-8df7-5c7267aab302', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'Hippolyte d''Este (cardinal)', null, 1479, 1520, 'Cardinal, fils d''Hercule Ier', 'Este', 1495, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aaadf55b-cf7d-55b3-aac5-aa7eda9c58a6', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 'Lucrèce Borgia', null, 1480, 1519, 'Duchesse de Ferrare', 'Borgia', 2485, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2340da59-514f-5bfd-9416-9a054f75b804', 'entry', 'a92b4627-d9e5-4325-81ed-8b3dfebacf5b', 'Renée de France', null, 1510, 1574, 'Duchesse de Ferrare', 'Valois', 360000, 9180, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('04270c2e-1ba0-5183-850f-8ff9735280f6', 'entry', 'a92b4627-d9e5-4325-81ed-8b3dfebacf5b', 'Anne de Bretagne', null, 1477, 1514, 'Reine de France, duchesse de Bretagne', 'Bretagne', 360340, 8586, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0a27277d-f6c9-5d6b-846b-66d8b240cc81', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 'Jean-François Ier de Gonzague', null, 1395, 1444, 'Premier marquis de Mantoue', 'Gonzague', 995, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('da0571a0-4874-56c4-9158-36c3f4c86154', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 'Louis III de Gonzague', null, 1412, 1478, 'Marquis de Mantoue', 'Gonzague', 995, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('634453f2-cd3e-534b-9f79-c035c8fdeb2c', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 'Frédéric Ier de Gonzague', null, 1441, 1484, 'Marquis de Mantoue', 'Gonzague', 750, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bbc0fa82-d383-5bb5-ad6b-c732a0aed529', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 'François II de Gonzague', null, 1466, 1519, 'Marquis de Mantoue', 'Gonzague', 750, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ca1e4e2b-3599-50ac-81eb-2369decea1e2', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 'Frédéric II de Gonzague', null, 1500, 1540, 'Premier duc de Mantoue', 'Gonzague', 505, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('625226bb-c595-56fa-8eb0-bd84fb0012b5', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 'Guillaume de Gonzague', null, 1538, 1587, 'Duc de Mantoue', 'Gonzague', 505, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b915a25d-f5c5-5478-9be2-27b12d8040ca', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 'Vincent Ier de Gonzague', null, 1562, 1612, 'Duc de Mantoue', 'Gonzague', 750, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0769f60c-68e9-5b5a-9468-ce5f6b55c37a', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 'François IV de Gonzague', null, 1586, 1612, 'Duc de Mantoue', 'Gonzague', 0, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('58a2d401-3784-5c82-b554-85c7fd2d4f6b', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 'Ferdinand de Gonzague', null, 1587, 1626, 'Duc de Mantoue', 'Gonzague', 500, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e25bcf2d-5fd6-5675-add8-b0dd5904e3a1', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 'Vincent II de Gonzague', null, 1594, 1627, 'Dernier duc de Mantoue de la ligne directe', 'Gonzague', 1000, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('79fd79b5-c301-5d2b-8fb4-e2cfdfa0026e', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 'Barbara de Brandebourg', null, 1423, 1481, 'Marquise de Mantoue', 'Brandebourg-Hohenzollern', 505, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('08ed8425-1c08-5ec4-a1fa-fe57109b3c02', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 'Marguerite de Médicis (Parme)', null, 1612, 1679, 'Duchesse de Parme', 'Médicis', 3257, 5120, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('098f6f03-0d2b-54ba-8dad-9c34518c3f6d', 'entry', '6b34bc03-d0ad-4c48-a485-f541cecafd5d', 'Éléonore d''Autriche', null, 1534, 1594, 'Duchesse de Mantoue', 'Habsbourg', 360000, 9612, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('90f60e13-ebf7-5f6f-ad11-e6aea0486c84', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 'Paul III (Alexandre Farnèse)', null, 1468, 1549, 'Pape, fondateur de la puissance Farnèse', 'Farnèse', 500, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('435d087e-08f1-5a1f-9204-52d3fc7c06f8', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 'Pierre-Louis Farnèse', null, 1503, 1547, 'Premier duc de Parme', 'Farnèse', 500, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('bbfa580b-0da5-50c6-b1cd-33bbe96ebedd', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 'Octave Farnèse', null, 1524, 1586, 'Duc de Parme', 'Farnèse', 500, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a6463f97-7793-5030-aa76-ac1cb5eafa53', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 'Alexandre Farnèse', null, 1545, 1592, 'Duc de Parme, gouverneur des Pays-Bas espagnols', 'Farnèse', 745, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0d0c4fcb-9e22-53d9-bfa7-37f489eb7ddf', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 'Ranuce Ier Farnèse', null, 1569, 1622, 'Duc de Parme', 'Farnèse', 990, 2560, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d00f5289-4b96-5c65-a752-c7a5e31c84e0', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 'Édouard Ier Farnèse', null, 1612, 1646, 'Duc de Parme', 'Farnèse', 745, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d2a7e39a-aa35-5294-986a-c153d4439135', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 'Ranuce II Farnèse', null, 1630, 1694, 'Duc de Parme', 'Farnèse', 990, 3840, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6360dcd6-5ebe-5f86-8c30-4252f5480e2a', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 'Édouard II Farnèse', null, 1666, 1693, 'Prince héréditaire de Parme', 'Farnèse', 490, 4480, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('51ee16bf-c6e8-5973-8223-81e575e697da', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 'François Farnèse', null, 1678, 1727, 'Duc de Parme', 'Farnèse', 990, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1e1b0e68-819f-5ff2-a918-4962d42e69fd', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 'Antoine Farnèse', null, 1679, 1731, 'Dernier duc Farnèse de Parme', 'Farnèse', 1490, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f1118947-f685-59d1-bd64-d4fbd7ae0716', 'entry', 'efb44952-74d4-4e3e-8247-8c1003978d3d', 'Édouard de Portugal, duc de Guimarães', null, 1515, 1540, 'Fils de Manuel Ier', 'Aviz', 360000, 9270, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('61ef5944-acd9-5010-9508-b208d4618343', 'entry', 'efb44952-74d4-4e3e-8247-8c1003978d3d', 'Marie de Portugal (Guimarães)', null, 1538, 1577, 'Duchesse de Parme', 'Aviz', 360340, 9684, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a7de4963-6036-5840-80bc-60cbf0355ad3', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 'Marguerite Aldobrandini', null, 1588, 1646, 'Duchesse de Parme', 'Aldobrandini', 500, 2560, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('4571fe56-dda2-520f-967a-cc68318d2bad', '78881a6d-d8db-5d97-903e-d698e3b0ec19', 'parent');
  perform pg_temp.rel('4571fe56-dda2-520f-967a-cc68318d2bad', 'c276b670-1776-5c04-82c3-8f52daf66035', 'parent');
  perform pg_temp.rel('4571fe56-dda2-520f-967a-cc68318d2bad', '61dcdaea-ba35-5ed6-aac7-604aeb97dd1d', 'parent');
  perform pg_temp.rel('61dcdaea-ba35-5ed6-aac7-604aeb97dd1d', 'a810968f-0a99-50c7-8a00-63b1ec538b50', 'spouse');
  perform pg_temp.rel('61dcdaea-ba35-5ed6-aac7-604aeb97dd1d', '7029062f-c4e5-5b91-9676-ec306b024a07', 'parent');
  perform pg_temp.rel('a810968f-0a99-50c7-8a00-63b1ec538b50', '7029062f-c4e5-5b91-9676-ec306b024a07', 'parent');
  perform pg_temp.rel('61dcdaea-ba35-5ed6-aac7-604aeb97dd1d', '75ca12f3-659c-501e-8ea2-7485ac2033df', 'parent');
  perform pg_temp.rel('a810968f-0a99-50c7-8a00-63b1ec538b50', '75ca12f3-659c-501e-8ea2-7485ac2033df', 'parent');
  perform pg_temp.rel('61dcdaea-ba35-5ed6-aac7-604aeb97dd1d', '03d5e693-81ed-56af-8df7-5c7267aab302', 'parent');
  perform pg_temp.rel('a810968f-0a99-50c7-8a00-63b1ec538b50', '03d5e693-81ed-56af-8df7-5c7267aab302', 'parent');
  perform pg_temp.rel('61dcdaea-ba35-5ed6-aac7-604aeb97dd1d', 'f388aa57-8aca-54ed-9b7d-1973561af12f', 'parent');
  perform pg_temp.rel('a810968f-0a99-50c7-8a00-63b1ec538b50', 'f388aa57-8aca-54ed-9b7d-1973561af12f', 'parent');
  perform pg_temp.rel('75ca12f3-659c-501e-8ea2-7485ac2033df', 'aaadf55b-cf7d-55b3-aac5-aa7eda9c58a6', 'spouse');
  perform pg_temp.rel('75ca12f3-659c-501e-8ea2-7485ac2033df', '848fc0c9-a83d-5613-8bd6-704a42a55239', 'parent');
  perform pg_temp.rel('aaadf55b-cf7d-55b3-aac5-aa7eda9c58a6', '848fc0c9-a83d-5613-8bd6-704a42a55239', 'parent');
  perform pg_temp.rel('d8bc083b-3136-4c78-b005-900b69ebbab1', '04270c2e-1ba0-5183-850f-8ff9735280f6', 'spouse');
  perform pg_temp.rel('d8bc083b-3136-4c78-b005-900b69ebbab1', '2340da59-514f-5bfd-9416-9a054f75b804', 'parent');
  perform pg_temp.rel('04270c2e-1ba0-5183-850f-8ff9735280f6', '2340da59-514f-5bfd-9416-9a054f75b804', 'parent');
  perform pg_temp.rel('d8bc083b-3136-4c78-b005-900b69ebbab1', '66e055eb-cc8d-4e44-89ba-2e0e78821d30', 'parent');
  perform pg_temp.rel('04270c2e-1ba0-5183-850f-8ff9735280f6', '66e055eb-cc8d-4e44-89ba-2e0e78821d30', 'parent');
  perform pg_temp.rel('848fc0c9-a83d-5613-8bd6-704a42a55239', '2340da59-514f-5bfd-9416-9a054f75b804', 'spouse');
  perform pg_temp.rel('848fc0c9-a83d-5613-8bd6-704a42a55239', '99cace75-4c94-56ce-ac8d-f819885fd5e5', 'parent');
  perform pg_temp.rel('99cace75-4c94-56ce-ac8d-f819885fd5e5', '8363433f-d262-5817-b13d-a8c5ab88e7cd', 'family');
  perform pg_temp.rel('0a27277d-f6c9-5d6b-846b-66d8b240cc81', 'da0571a0-4874-56c4-9158-36c3f4c86154', 'parent');
  perform pg_temp.rel('da0571a0-4874-56c4-9158-36c3f4c86154', '634453f2-cd3e-534b-9f79-c035c8fdeb2c', 'parent');
  perform pg_temp.rel('634453f2-cd3e-534b-9f79-c035c8fdeb2c', 'bbc0fa82-d383-5bb5-ad6b-c732a0aed529', 'parent');
  perform pg_temp.rel('bbc0fa82-d383-5bb5-ad6b-c732a0aed529', 'ca1e4e2b-3599-50ac-81eb-2369decea1e2', 'parent');
  perform pg_temp.rel('ca1e4e2b-3599-50ac-81eb-2369decea1e2', '625226bb-c595-56fa-8eb0-bd84fb0012b5', 'parent');
  perform pg_temp.rel('625226bb-c595-56fa-8eb0-bd84fb0012b5', 'b915a25d-f5c5-5478-9be2-27b12d8040ca', 'parent');
  perform pg_temp.rel('b915a25d-f5c5-5478-9be2-27b12d8040ca', '0769f60c-68e9-5b5a-9468-ce5f6b55c37a', 'parent');
  perform pg_temp.rel('b915a25d-f5c5-5478-9be2-27b12d8040ca', '58a2d401-3784-5c82-b554-85c7fd2d4f6b', 'parent');
  perform pg_temp.rel('b915a25d-f5c5-5478-9be2-27b12d8040ca', 'e25bcf2d-5fd6-5675-add8-b0dd5904e3a1', 'parent');
  perform pg_temp.rel('bbc0fa82-d383-5bb5-ad6b-c732a0aed529', '7029062f-c4e5-5b91-9676-ec306b024a07', 'spouse');
  perform pg_temp.rel('7029062f-c4e5-5b91-9676-ec306b024a07', 'ca1e4e2b-3599-50ac-81eb-2369decea1e2', 'parent');
  perform pg_temp.rel('da0571a0-4874-56c4-9158-36c3f4c86154', '79fd79b5-c301-5d2b-8fb4-e2cfdfa0026e', 'spouse');
  perform pg_temp.rel('79fd79b5-c301-5d2b-8fb4-e2cfdfa0026e', '634453f2-cd3e-534b-9f79-c035c8fdeb2c', 'parent');
  perform pg_temp.rel('507c3d51-bc0e-5fd3-98f4-d80f2a501503', '08ed8425-1c08-5ec4-a1fa-fe57109b3c02', 'parent');
  perform pg_temp.rel('9d06c682-eab3-5cac-81f3-0233c71b71e1', '08ed8425-1c08-5ec4-a1fa-fe57109b3c02', 'parent');
  perform pg_temp.rel('b915a25d-f5c5-5478-9be2-27b12d8040ca', '376de58a-617f-5d5a-98cc-79695efc3ede', 'spouse');
  perform pg_temp.rel('b915a25d-f5c5-5478-9be2-27b12d8040ca', 'e2b87c64-43e9-4446-9f59-84b65f42386d', 'parent');
  perform pg_temp.rel('376de58a-617f-5d5a-98cc-79695efc3ede', 'e2b87c64-43e9-4446-9f59-84b65f42386d', 'parent');
  perform pg_temp.rel('995c8249-ac49-4468-babb-61ce8ce60709', '098f6f03-0d2b-54ba-8dad-9c34518c3f6d', 'parent');
  perform pg_temp.rel('f06f9b33-6613-4380-af93-2d6493ffb942', '098f6f03-0d2b-54ba-8dad-9c34518c3f6d', 'parent');
  perform pg_temp.rel('625226bb-c595-56fa-8eb0-bd84fb0012b5', '098f6f03-0d2b-54ba-8dad-9c34518c3f6d', 'spouse');
  perform pg_temp.rel('098f6f03-0d2b-54ba-8dad-9c34518c3f6d', 'b915a25d-f5c5-5478-9be2-27b12d8040ca', 'parent');
  perform pg_temp.rel('90f60e13-ebf7-5f6f-ad11-e6aea0486c84', '435d087e-08f1-5a1f-9204-52d3fc7c06f8', 'parent');
  perform pg_temp.rel('435d087e-08f1-5a1f-9204-52d3fc7c06f8', 'bbfa580b-0da5-50c6-b1cd-33bbe96ebedd', 'parent');
  perform pg_temp.rel('bbfa580b-0da5-50c6-b1cd-33bbe96ebedd', 'a6463f97-7793-5030-aa76-ac1cb5eafa53', 'parent');
  perform pg_temp.rel('a6463f97-7793-5030-aa76-ac1cb5eafa53', '0d0c4fcb-9e22-53d9-bfa7-37f489eb7ddf', 'parent');
  perform pg_temp.rel('0d0c4fcb-9e22-53d9-bfa7-37f489eb7ddf', 'd00f5289-4b96-5c65-a752-c7a5e31c84e0', 'parent');
  perform pg_temp.rel('d00f5289-4b96-5c65-a752-c7a5e31c84e0', 'd2a7e39a-aa35-5294-986a-c153d4439135', 'parent');
  perform pg_temp.rel('d2a7e39a-aa35-5294-986a-c153d4439135', '6360dcd6-5ebe-5f86-8c30-4252f5480e2a', 'parent');
  perform pg_temp.rel('d2a7e39a-aa35-5294-986a-c153d4439135', '51ee16bf-c6e8-5973-8223-81e575e697da', 'parent');
  perform pg_temp.rel('d2a7e39a-aa35-5294-986a-c153d4439135', '1e1b0e68-819f-5ff2-a918-4962d42e69fd', 'parent');
  perform pg_temp.rel('bbfa580b-0da5-50c6-b1cd-33bbe96ebedd', '60980970-8d53-5628-b0dd-7baadfa1e7e7', 'spouse');
  perform pg_temp.rel('60980970-8d53-5628-b0dd-7baadfa1e7e7', 'a6463f97-7793-5030-aa76-ac1cb5eafa53', 'parent');
  perform pg_temp.rel('927ddf7d-6da1-4ccb-b1e3-493ca40de381', 'f1118947-f685-59d1-bd64-d4fbd7ae0716', 'parent');
  perform pg_temp.rel('f1118947-f685-59d1-bd64-d4fbd7ae0716', '61ef5944-acd9-5010-9508-b208d4618343', 'parent');
  perform pg_temp.rel('a6463f97-7793-5030-aa76-ac1cb5eafa53', '61ef5944-acd9-5010-9508-b208d4618343', 'spouse');
  perform pg_temp.rel('61ef5944-acd9-5010-9508-b208d4618343', '0d0c4fcb-9e22-53d9-bfa7-37f489eb7ddf', 'parent');
  perform pg_temp.rel('0d0c4fcb-9e22-53d9-bfa7-37f489eb7ddf', 'a7de4963-6036-5840-80bc-60cbf0355ad3', 'spouse');
  perform pg_temp.rel('a7de4963-6036-5840-80bc-60cbf0355ad3', 'd00f5289-4b96-5c65-a752-c7a5e31c84e0', 'parent');
  perform pg_temp.rel('d00f5289-4b96-5c65-a752-c7a5e31c84e0', '08ed8425-1c08-5ec4-a1fa-fe57109b3c02', 'spouse');
  perform pg_temp.rel('08ed8425-1c08-5ec4-a1fa-fe57109b3c02', 'd2a7e39a-aa35-5294-986a-c153d4439135', 'parent');
  perform pg_temp.rel('6360dcd6-5ebe-5f86-8c30-4252f5480e2a', '5539ea53-f47b-5952-883b-23c7429e5bb5', 'spouse');
  perform pg_temp.rel('6360dcd6-5ebe-5f86-8c30-4252f5480e2a', '2df9c2fd-8fd9-4bb4-b23a-f064afb0e301', 'parent');
  perform pg_temp.rel('5539ea53-f47b-5952-883b-23c7429e5bb5', '2df9c2fd-8fd9-4bb4-b23a-f064afb0e301', 'parent');
  update public.genealogy_members set pos_x = 2057, pos_y = 0 where id = '15974c82-b86f-5053-b6fe-2e377024f361';
  update public.genealogy_members set pos_x = 1567, pos_y = 0 where id = '94fd6cfc-8880-58b4-9350-eabe6a188060';
  update public.genealogy_members set pos_x = 1529, pos_y = 640 where id = '0daae3a4-4738-56e9-be9c-30d30c2ce5ff';
  update public.genealogy_members set pos_x = 2235, pos_y = 640 where id = '92299032-2e3c-552e-83f2-ec10f8094385';
  update public.genealogy_members set pos_x = 1039, pos_y = 640 where id = '2eeccb07-f268-50c3-a933-624ef80d1231';
  update public.genealogy_members set pos_x = 947, pos_y = 1280 where id = 'f110cd83-3c6b-5876-a7c0-ca43f325840c';
  update public.genealogy_members set pos_x = 1447, pos_y = 1280 where id = '487ed0a7-70ee-5f7f-871e-67b92c3da18d';
  update public.genealogy_members set pos_x = 457, pos_y = 1280 where id = '1d12dc56-e857-5d2c-a2ab-d89c5c325d85';
  update public.genealogy_members set pos_x = 1156, pos_y = 1920 where id = '07d33fc7-3eb4-5479-b0df-a1edf2619da7';
  update public.genealogy_members set pos_x = 0, pos_y = 1920 where id = 'a82bed61-7d43-5ec4-a576-bbe12aa7fa93';
  update public.genealogy_members set pos_x = 1646, pos_y = 1920 where id = '473d1033-81e4-5174-9e01-12cfebc276e3';
  update public.genealogy_members set pos_x = 990, pos_y = 2560 where id = '22f423cd-89ba-5255-9d98-37a1c8956efd';
  update public.genealogy_members set pos_x = 1990, pos_y = 2560 where id = '5caa0f9c-5e16-5e32-a071-2526f2dec9fd';
  update public.genealogy_members set pos_x = 1490, pos_y = 2560 where id = '82197180-d29c-5b7f-9595-0c1b74f0aef6';
  update public.genealogy_members set pos_x = 0, pos_y = 2560 where id = 'bbf70094-e263-5337-968f-a3fae7835bd4';
  update public.genealogy_members set pos_x = 1637, pos_y = 3200 where id = '35efa46f-84ba-54ee-bd24-916f7ad2ba55';
  update public.genealogy_members set pos_x = 500, pos_y = 2560 where id = '64ae5624-7b99-5426-a103-e2d1aac61d65';
  update public.genealogy_members set pos_x = 647, pos_y = 3200 where id = '5f0e9877-fa0a-5ff6-b50c-19eab2fded6a';
  update public.genealogy_members set pos_x = 1137, pos_y = 3200 where id = 'ee400799-a106-5fc8-adad-0a556e0807d8';
  update public.genealogy_members set pos_x = 490, pos_y = 3840 where id = '2f14d3ea-6f2f-52e1-a38f-44d63b72de76';
  update public.genealogy_members set pos_x = 2235, pos_y = 1280 where id = '84f2ab55-9f1e-59cf-9b68-1bb7ac20c27f';
  update public.genealogy_members set pos_x = 2245, pos_y = 1920 where id = '57f560f5-8ba8-5d1e-abd2-7ffcd3721259';
  update public.genealogy_members set pos_x = 2735, pos_y = 1920 where id = '387d26db-cc1c-5e89-91f4-d53946159d36';
  update public.genealogy_members set pos_x = 2490, pos_y = 2560 where id = 'be0c6999-1699-5080-8530-c74129fc3684';
  update public.genealogy_members set pos_x = 2980, pos_y = 2560 where id = '3cbb56f4-c550-5ab8-acfe-3fd06489b0c5';
  update public.genealogy_members set pos_x = 2735, pos_y = 3200 where id = '38414dbd-38b9-56b3-a1e6-5a7f32927af4';
  update public.genealogy_members set pos_x = 3225, pos_y = 3200 where id = '8974197c-5642-5687-9532-cd5838830e02';
  update public.genealogy_members set pos_x = 1980, pos_y = 3840 where id = '98562bc3-d046-5922-b744-acd374c2056b';
  update public.genealogy_members set pos_x = 2970, pos_y = 3840 where id = '061bcb61-8db7-5caf-be4c-cda052d67e1d';
  update public.genealogy_members set pos_x = 3960, pos_y = 3840 where id = '3263323d-5323-56ec-8009-9252393b9031';
  update public.genealogy_members set pos_x = 2470, pos_y = 3840 where id = '8cfd9ecd-4064-5fe0-be57-f2b12094b2cd';
  update public.genealogy_members set pos_x = 1611, pos_y = 4480 where id = '376de58a-617f-5d5a-98cc-79695efc3ede';
  update public.genealogy_members set pos_x = 3460, pos_y = 3840 where id = 'b68e21d4-1f1f-54a6-816a-c0bc17451299';
  update public.genealogy_members set pos_x = 3215, pos_y = 4480 where id = '507c3d51-bc0e-5fd3-98f4-d80f2a501503';
  update public.genealogy_members set pos_x = 3761, pos_y = 5120 where id = '02d920d4-bab9-5ae6-852e-cb65b82bde80';
  update public.genealogy_members set pos_x = 4251, pos_y = 5120 where id = '34cf979b-f42a-5f06-901b-ec4f7db09108';
  update public.genealogy_members set pos_x = 4006, pos_y = 5760 where id = '29b7c014-3fb2-5182-bbda-39ad4a34de24';
  update public.genealogy_members set pos_x = 4252, pos_y = 6400 where id = '78598cea-314f-520a-a1ad-ae3ded159e85';
  update public.genealogy_members set pos_x = 3752, pos_y = 6400 where id = '6fe70583-e9b4-5bcd-81d2-7fc22ad59c12';
  update public.genealogy_members set pos_x = 4752, pos_y = 6400 where id = 'd8a54c67-b656-552c-9589-601a14cdccb9';
  update public.genealogy_members set pos_x = 5242, pos_y = 6400 where id = '008ef7cc-1350-5c86-93c1-5ed1011345cf';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f388aa57-8aca-54ed-9b7d-1973561af12f', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 995, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('2340da59-514f-5bfd-9416-9a054f75b804', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 2730, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('bbc0fa82-d383-5bb5-ad6b-c732a0aed529', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 5, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('ca1e4e2b-3599-50ac-81eb-2369decea1e2', 'entry', '46971805-4ab8-5166-a475-2b53e19d6f12', 495, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('7029062f-c4e5-5b91-9676-ec306b024a07', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 260, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('376de58a-617f-5d5a-98cc-79695efc3ede', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 260, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('e2b87c64-43e9-4446-9f59-84b65f42386d', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 1500, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('098f6f03-0d2b-54ba-8dad-9c34518c3f6d', 'entry', '2660365e-f536-5ec5-a3c3-fe4b028a1111', 995, 3200, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('60980970-8d53-5628-b0dd-7baadfa1e7e7', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 990, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('61ef5944-acd9-5010-9508-b208d4618343', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 1235, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('08ed8425-1c08-5ec4-a1fa-fe57109b3c02', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 1235, 3200, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('5539ea53-f47b-5952-883b-23c7429e5bb5', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 0, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('2df9c2fd-8fd9-4bb4-b23a-f064afb0e301', 'entry', '08ddd858-acce-5597-b66f-0a93557a9abd', 490, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('9d06c682-eab3-5cac-81f3-0233c71b71e1', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 3705, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('b915a25d-f5c5-5478-9be2-27b12d8040ca', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 1121, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('e2b87c64-43e9-4446-9f59-84b65f42386d', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 1611, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('d00f5289-4b96-5c65-a752-c7a5e31c84e0', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 2767, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('d2a7e39a-aa35-5294-986a-c153d4439135', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 3257, 5760, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('401b55d7-2a9c-44f3-991e-f677a497b2db', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 990, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('60980970-8d53-5628-b0dd-7baadfa1e7e7', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 0, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('b5893e2e-7ed2-4ac8-a900-a22c0e50fdf6', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 1490, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('2b61583b-5e1e-456a-90b9-0758f126db75', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 2111, 4480, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('895a4460-54b6-53fe-a2ba-0d52fb3d63f2', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 4496, 5760, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('32b5e90e-4358-5a9f-b97a-dda04286d882', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 3262, 6400, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('17b5c283-4ef7-514c-be16-29ad5b2e4cca', 'entry', '31ab743f-533f-5c1b-b317-728a4e0067b5', 2735, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v95 : % membres ajoutés.', 40;
end $$;
