-- schema_v54.sql — Liechtenstein — princes de Liechtenstein
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Crée sous Liechtenstein > Dynastie : Liechtenstein (Karl Ier -> Hans-Adam II -> Alois et ses enfants).
-- Décision à valider : la maison est d'origine autrichienne ; faute d'arbre autrichien pour elle, toute la lignée princière (depuis Karl Ier, 1608) est dans l'arbre liechtensteinois, bien que la principauté du Liechtenstein n'existe que depuis 1719.
-- Les lignes collatérales (Hartmann III, Philipp Erasme, Emmanuel) ne sont incluses que pour relier les princes entre eux ; leurs dates et filiations sont de ma connaissance générale et marquées « non revérifiées ».
-- Anne-Marie (1699-1753) : la page la dit « ruling in her own right » ; non marquée comme dirigeante (à trancher).
-- Épouses sans arbre signalées ; Sophie de Bavière est créée dans l'arbre Wittelsbach, Margaretha de Luxembourg (v52) est reliée à Nikolaus.
-- Prérequis : v53 exécuté.
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
  if exists (select 1 from public.genealogy_members where id = '069ce5a2-d045-5998-a592-e4bc55676734') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('8108ca03-b4b1-552d-b057-ba034af0b982');
  if k <> 1 then raise exception 'Membres préexistants manquants (% sur 1) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  -- Arbre « Liechtenstein » (LIE)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'LIE' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour LIE : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Liechtenstein';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('73cc5f95-7a4d-5960-944d-126cf0aeb211', cat_id, 'country', 'LIE', top, 'Liechtenstein', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '73cc5f95-7a4d-5960-944d-126cf0aeb211';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'country', 'LIE', 'genealogy', 'Liechtenstein', cat_id, sec, admin_id);
  select count(*) into k from public.dossier_entries where id = 'e76d91a3-1b9c-4703-85b3-9f711b6d6199' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Wittelsbach introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '6cd1705d-246d-59e6-975a-2cba83ec30f3' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Nassau-Weilburg introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('069ce5a2-d045-5998-a592-e4bc55676734', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Karl Ier de Liechtenstein', null, 1569, 1627, 'Prince de Liechtenstein (1608)', 'Liechtenstein', 1374, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7cf456ac-ce3f-58e0-88dd-9689a7e89688', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Anna Maria Šemberová de Boskovice', null, null, null, 'Princesse de Liechtenstein', 'Boskovice (Moravie)', 1877, 0, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b4b032fe-d29f-54f5-b036-ae504bf63b10', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Charles Eusèbe de Liechtenstein', null, 1611, 1684, 'Prince de Liechtenstein (1627-1684)', 'Liechtenstein', 1880, 774, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('48d1a02a-e9d1-5ad2-993b-5f1aa88e4615', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Hartmann III de Liechtenstein', null, 1613, 1686, 'Prince', 'Liechtenstein', 1371, 774, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ac6100fd-d31d-56aa-8bd5-af6da41c3f90', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Jeanne-Béatrice de Dietrichstein', null, null, null, 'Princesse de Liechtenstein', 'Dietrichstein', 2420, 774, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2c368b8d-3d00-5304-bda8-2a2d72e7e151', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Hans-Adam Ier de Liechtenstein', null, 1662, 1712, 'Prince de Liechtenstein (1684-1712), acquiert Schellenberg et Vaduz', 'Liechtenstein', 2150, 1674, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f437be00-b3d0-53bc-91ab-1d77fc38231b', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Erdmuthe-Marie-Thérèse de Dietrichstein', null, null, null, 'Princesse de Liechtenstein', 'Dietrichstein', 2530, 1674, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c2c8f107-7600-5e2f-905c-4a21c3aae981', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Antoine-Florian de Liechtenstein', null, 1656, 1721, 'Prince de Liechtenstein (1718-1721)', 'Liechtenstein', 1002, 1638, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('fe81575b-8e8e-579c-a985-c641772fb23d', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Éléonore-Barbara de Thun-Hohenstein', null, null, null, 'Princesse de Liechtenstein', 'Thun-Hohenstein', 488, 1638, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d04a4af7-0fd5-5c59-b8a7-d49ca450ab02', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Philippe-Érasme de Liechtenstein', null, 1664, 1704, 'Prince', 'Liechtenstein', 1740, 1638, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5b9179a3-cc73-5987-b376-49d240c04492', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Joseph-Venceslas Ier de Liechtenstein', null, 1696, 1772, 'Prince de Liechtenstein (1712-1718, 1748-1772)', 'Liechtenstein', 1330, 2259, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('19723825-3b9b-5270-8e83-435f0a2ea5ce', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Joseph-Jean-Adam de Liechtenstein', null, 1690, 1732, 'Prince de Liechtenstein (1721-1732)', 'Liechtenstein', 540, 2259, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('37a9dc57-42b5-51b9-a62c-454ae022c179', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Anne-Marie de Liechtenstein', null, 1699, 1753, 'Princesse, régente (selon la page : « ruled in her own right »)', 'Liechtenstein', 950, 2259, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8651c9bb-82d9-5a76-86a1-1f1e4cf79c93', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Marie-Anne d''Oettingen-Spielberg', null, null, null, 'Princesse de Liechtenstein', 'Oettingen-Spielberg', 0, 2259, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('389a967c-455f-590b-bbaa-372090c64b10', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Jean-Népomucène-Charles de Liechtenstein', null, 1724, 1748, 'Prince de Liechtenstein (1732-1748)', 'Liechtenstein', 270, 2790, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('67c455b9-0f36-59e9-b989-e7fcebe4e01e', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Marie-Josepha de Harrach', null, null, null, 'Princesse de Liechtenstein', 'Harrach', 650, 2790, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a1c2fc8c-1cb3-5546-a7de-ab2fe8c1d590', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Emmanuel de Liechtenstein', null, 1700, 1771, 'Prince, père de François-Joseph Ier', 'Liechtenstein', 1740, 2358, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7b497b37-942e-570d-b66c-8c0851bc42db', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'François-Joseph Ier de Liechtenstein', null, 1726, 1781, 'Prince de Liechtenstein (1772-1781)', 'Liechtenstein', 1740, 2826, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8bfcd898-1b98-5e58-a9fc-172522620dae', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Léopoldine de Sternberg', null, null, null, 'Princesse de Liechtenstein', 'Sternberg', 2261, 2826, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('042ac223-6e07-5340-9079-2c6109e65ea2', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Aloys Ier de Liechtenstein', null, 1759, 1805, 'Prince de Liechtenstein (1781-1805)', 'Liechtenstein', 1795, 3429, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e98c1c7d-ff99-5f17-8b75-1d87be657842', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Jean Ier Joseph de Liechtenstein', null, 1760, 1836, 'Prince de Liechtenstein (1805-1836)', 'Liechtenstein', 2205, 3429, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c39e67f9-60b2-5d36-ab7a-57a1fb48a422', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Caroline de Manderscheid-Blankenheim', null, null, null, 'Princesse de Liechtenstein', 'Manderscheid-Blankenheim', 1415, 3429, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('75956b3e-8c88-58df-8b4a-64bdac6bff68', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Josépha de Fürstenberg-Weitra', null, null, null, 'Princesse de Liechtenstein', 'Fürstenberg-Weitra', 2745, 3429, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b9f5a22d-79c7-58c5-9940-2d55531a2b88', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Aloys II de Liechtenstein', null, 1796, 1858, 'Prince de Liechtenstein (1836-1858)', 'Liechtenstein', 2475, 4086, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b9c17442-780c-5330-b7ab-44b73c398fa8', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Françoise Kinsky de Wchinitz et Tettau', null, 1813, 1881, 'Princesse de Liechtenstein', 'Kinsky (Bohême)', 3157, 4086, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('de5dec15-1f99-5b02-b199-04763e77524a', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Jean II de Liechtenstein', null, 1840, 1929, 'Prince de Liechtenstein (1858-1929), non marié', 'Liechtenstein', 2136, 4974, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3e99b200-4b53-5ece-929e-162acd80fd65', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'François Ier de Liechtenstein', null, 1853, 1938, 'Prince de Liechtenstein (1929-1938)', 'Liechtenstein', 3496, 4974, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c814da38-7a69-5599-a70e-3c6b616898c1', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Henriette de Liechtenstein', null, 1843, 1931, 'Princesse, épouse d''Alfred', 'Liechtenstein', 3086, 4974, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f34fc30f-80cf-5588-a553-2e2d7af89006', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Élisabeth von Gutmann', null, null, null, 'Princesse de Liechtenstein', 'Gutmann (Autriche)', 3876, 4974, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d1b6a42e-7993-526a-a963-8ffe821617e7', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Alfred de Liechtenstein', null, 1842, 1907, 'Prince, époux de sa cousine Henriette', 'Liechtenstein', 2546, 4974, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('476ff9f3-2d54-55be-aa45-3912191fe4bc', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Alois de Liechtenstein', null, 1869, 1955, 'Prince, père de François-Joseph II', 'Liechtenstein', 2816, 5434, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('a06a73b7-f8da-5de0-9fd3-79c90a0a690e', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Élisabeth-Amélie d''Autriche', null, 1878, 1960, 'Princesse de Liechtenstein', 'Habsbourg-Lorraine (archiduchesse)', 3356, 5434, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aeb20806-fbde-5e54-bb27-4978bda4f808', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'François-Joseph II de Liechtenstein', null, 1906, 1989, 'Prince de Liechtenstein (1938-1989)', 'Liechtenstein', 3086, 6066, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('6efad058-696f-5987-88db-8a4d3017c099', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Georgina von Wilczek', null, 1921, 1989, 'Princesse de Liechtenstein', 'Wilczek (Autriche)', 3895, 6066, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b0077813-48d9-51b1-bd34-ab8fd63d6a48', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Hans-Adam II de Liechtenstein', null, 1945, null, 'Prince de Liechtenstein (depuis 1989)', 'Liechtenstein', 2671, 6858, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5b1a76f0-3656-50ca-a3cd-9892a39c0d0b', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Philipp de Liechtenstein', null, 1946, null, 'Prince', 'Liechtenstein', 3901, 6858, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('9c941436-6d18-500e-b4fb-fc9edfea57ae', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Nikolaus de Liechtenstein', null, 1947, null, 'Prince', 'Liechtenstein', 4311, 6858, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('012d3353-a68a-57be-b84e-170de228876c', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Norberta (Nora) de Liechtenstein', null, 1950, null, 'Princesse', 'Liechtenstein', 3081, 6858, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c8c80075-e63e-5d1f-824e-29eea8d9b1b6', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'François-Josef-Venceslas de Liechtenstein', null, 1962, 1991, 'Prince', 'Liechtenstein', 3491, 6858, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5c92a685-d57e-565b-9be0-83b5d49a649d', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Marie Kinsky de Wchinitz et Tettau', null, 1940, 2021, 'Princesse de Liechtenstein', 'Kinsky (Bohême)', 1696, 6858, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2875dbd7-b3a2-5dd4-b29b-02513c680b6c', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Alois de Liechtenstein (prince héréditaire)', null, 1968, null, 'Prince héréditaire, régent depuis 2004', 'Liechtenstein', 1568, 7318, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f49ffc4a-43b6-5c4f-bf65-514c22e20cba', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Maximilien de Liechtenstein', null, 1969, null, 'Prince', 'Liechtenstein', 1978, 7318, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8f6cccd8-b2cd-520b-974a-3a874a6a2664', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Constantin de Liechtenstein', null, 1972, 2023, 'Prince', 'Liechtenstein', 2388, 7318, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5b1fa248-b9d9-5651-8fb7-f792b19f2092', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Tatjana de Liechtenstein', null, 1973, null, 'Princesse', 'Liechtenstein', 2798, 7318, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f293a639-40a6-5174-b7f4-8cc9b393269e', 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Sophie en Bavière (princesse héréditaire de Liechtenstein)', null, 1967, null, 'Princesse héréditaire de Liechtenstein', 'Wittelsbach', 114000, 17406, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('385403bb-de7b-5166-9463-8868a9327cd5', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Joseph-Venceslas de Liechtenstein', null, 1995, null, 'Prince(sse) de Liechtenstein', 'Liechtenstein', 466, 7778, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d1ca5f35-4fbe-55a4-b1da-1827f6693be8', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Marie-Caroline de Liechtenstein', null, 1996, null, 'Prince(sse) de Liechtenstein', 'Liechtenstein', 876, 7778, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0a5b552d-476f-5dbd-903c-647857782f5b', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Georges de Liechtenstein', null, 1999, null, 'Prince(sse) de Liechtenstein', 'Liechtenstein', 1286, 7778, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e98bc6b1-49c2-5623-aba2-4cee10449030', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 'Nicolas de Liechtenstein', null, 2000, null, 'Prince(sse) de Liechtenstein', 'Liechtenstein', 1696, 7778, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('069ce5a2-d045-5998-a592-e4bc55676734', '7cf456ac-ce3f-58e0-88dd-9689a7e89688', 'spouse');
  perform pg_temp.rel('069ce5a2-d045-5998-a592-e4bc55676734', 'b4b032fe-d29f-54f5-b036-ae504bf63b10', 'parent');
  perform pg_temp.rel('7cf456ac-ce3f-58e0-88dd-9689a7e89688', 'b4b032fe-d29f-54f5-b036-ae504bf63b10', 'parent');
  perform pg_temp.rel('069ce5a2-d045-5998-a592-e4bc55676734', '48d1a02a-e9d1-5ad2-993b-5f1aa88e4615', 'parent');
  perform pg_temp.rel('7cf456ac-ce3f-58e0-88dd-9689a7e89688', '48d1a02a-e9d1-5ad2-993b-5f1aa88e4615', 'parent');
  perform pg_temp.rel('b4b032fe-d29f-54f5-b036-ae504bf63b10', 'ac6100fd-d31d-56aa-8bd5-af6da41c3f90', 'spouse');
  perform pg_temp.rel('b4b032fe-d29f-54f5-b036-ae504bf63b10', '2c368b8d-3d00-5304-bda8-2a2d72e7e151', 'parent');
  perform pg_temp.rel('ac6100fd-d31d-56aa-8bd5-af6da41c3f90', '2c368b8d-3d00-5304-bda8-2a2d72e7e151', 'parent');
  perform pg_temp.rel('2c368b8d-3d00-5304-bda8-2a2d72e7e151', 'f437be00-b3d0-53bc-91ab-1d77fc38231b', 'spouse');
  perform pg_temp.rel('48d1a02a-e9d1-5ad2-993b-5f1aa88e4615', 'c2c8f107-7600-5e2f-905c-4a21c3aae981', 'parent');
  perform pg_temp.rel('c2c8f107-7600-5e2f-905c-4a21c3aae981', 'fe81575b-8e8e-579c-a985-c641772fb23d', 'spouse');
  perform pg_temp.rel('48d1a02a-e9d1-5ad2-993b-5f1aa88e4615', 'd04a4af7-0fd5-5c59-b8a7-d49ca450ab02', 'parent');
  perform pg_temp.rel('d04a4af7-0fd5-5c59-b8a7-d49ca450ab02', '5b9179a3-cc73-5987-b376-49d240c04492', 'parent');
  perform pg_temp.rel('c2c8f107-7600-5e2f-905c-4a21c3aae981', '19723825-3b9b-5270-8e83-435f0a2ea5ce', 'parent');
  perform pg_temp.rel('fe81575b-8e8e-579c-a985-c641772fb23d', '19723825-3b9b-5270-8e83-435f0a2ea5ce', 'parent');
  perform pg_temp.rel('c2c8f107-7600-5e2f-905c-4a21c3aae981', '37a9dc57-42b5-51b9-a62c-454ae022c179', 'parent');
  perform pg_temp.rel('fe81575b-8e8e-579c-a985-c641772fb23d', '37a9dc57-42b5-51b9-a62c-454ae022c179', 'parent');
  perform pg_temp.rel('5b9179a3-cc73-5987-b376-49d240c04492', '37a9dc57-42b5-51b9-a62c-454ae022c179', 'spouse');
  perform pg_temp.rel('19723825-3b9b-5270-8e83-435f0a2ea5ce', '8651c9bb-82d9-5a76-86a1-1f1e4cf79c93', 'spouse');
  perform pg_temp.rel('19723825-3b9b-5270-8e83-435f0a2ea5ce', '389a967c-455f-590b-bbaa-372090c64b10', 'parent');
  perform pg_temp.rel('8651c9bb-82d9-5a76-86a1-1f1e4cf79c93', '389a967c-455f-590b-bbaa-372090c64b10', 'parent');
  perform pg_temp.rel('389a967c-455f-590b-bbaa-372090c64b10', '67c455b9-0f36-59e9-b989-e7fcebe4e01e', 'spouse');
  perform pg_temp.rel('d04a4af7-0fd5-5c59-b8a7-d49ca450ab02', 'a1c2fc8c-1cb3-5546-a7de-ab2fe8c1d590', 'parent');
  perform pg_temp.rel('a1c2fc8c-1cb3-5546-a7de-ab2fe8c1d590', '7b497b37-942e-570d-b66c-8c0851bc42db', 'parent');
  perform pg_temp.rel('7b497b37-942e-570d-b66c-8c0851bc42db', '8bfcd898-1b98-5e58-a9fc-172522620dae', 'spouse');
  perform pg_temp.rel('7b497b37-942e-570d-b66c-8c0851bc42db', '042ac223-6e07-5340-9079-2c6109e65ea2', 'parent');
  perform pg_temp.rel('8bfcd898-1b98-5e58-a9fc-172522620dae', '042ac223-6e07-5340-9079-2c6109e65ea2', 'parent');
  perform pg_temp.rel('7b497b37-942e-570d-b66c-8c0851bc42db', 'e98c1c7d-ff99-5f17-8b75-1d87be657842', 'parent');
  perform pg_temp.rel('8bfcd898-1b98-5e58-a9fc-172522620dae', 'e98c1c7d-ff99-5f17-8b75-1d87be657842', 'parent');
  perform pg_temp.rel('042ac223-6e07-5340-9079-2c6109e65ea2', 'c39e67f9-60b2-5d36-ab7a-57a1fb48a422', 'spouse');
  perform pg_temp.rel('e98c1c7d-ff99-5f17-8b75-1d87be657842', '75956b3e-8c88-58df-8b4a-64bdac6bff68', 'spouse');
  perform pg_temp.rel('e98c1c7d-ff99-5f17-8b75-1d87be657842', 'b9f5a22d-79c7-58c5-9940-2d55531a2b88', 'parent');
  perform pg_temp.rel('75956b3e-8c88-58df-8b4a-64bdac6bff68', 'b9f5a22d-79c7-58c5-9940-2d55531a2b88', 'parent');
  perform pg_temp.rel('b9f5a22d-79c7-58c5-9940-2d55531a2b88', 'b9c17442-780c-5330-b7ab-44b73c398fa8', 'spouse');
  perform pg_temp.rel('b9f5a22d-79c7-58c5-9940-2d55531a2b88', 'de5dec15-1f99-5b02-b199-04763e77524a', 'parent');
  perform pg_temp.rel('b9c17442-780c-5330-b7ab-44b73c398fa8', 'de5dec15-1f99-5b02-b199-04763e77524a', 'parent');
  perform pg_temp.rel('b9f5a22d-79c7-58c5-9940-2d55531a2b88', '3e99b200-4b53-5ece-929e-162acd80fd65', 'parent');
  perform pg_temp.rel('b9c17442-780c-5330-b7ab-44b73c398fa8', '3e99b200-4b53-5ece-929e-162acd80fd65', 'parent');
  perform pg_temp.rel('b9f5a22d-79c7-58c5-9940-2d55531a2b88', 'c814da38-7a69-5599-a70e-3c6b616898c1', 'parent');
  perform pg_temp.rel('b9c17442-780c-5330-b7ab-44b73c398fa8', 'c814da38-7a69-5599-a70e-3c6b616898c1', 'parent');
  perform pg_temp.rel('3e99b200-4b53-5ece-929e-162acd80fd65', 'f34fc30f-80cf-5588-a553-2e2d7af89006', 'spouse');
  perform pg_temp.rel('d1b6a42e-7993-526a-a963-8ffe821617e7', 'c814da38-7a69-5599-a70e-3c6b616898c1', 'spouse');
  perform pg_temp.rel('d1b6a42e-7993-526a-a963-8ffe821617e7', '476ff9f3-2d54-55be-aa45-3912191fe4bc', 'parent');
  perform pg_temp.rel('c814da38-7a69-5599-a70e-3c6b616898c1', '476ff9f3-2d54-55be-aa45-3912191fe4bc', 'parent');
  perform pg_temp.rel('476ff9f3-2d54-55be-aa45-3912191fe4bc', 'a06a73b7-f8da-5de0-9fd3-79c90a0a690e', 'spouse');
  perform pg_temp.rel('476ff9f3-2d54-55be-aa45-3912191fe4bc', 'aeb20806-fbde-5e54-bb27-4978bda4f808', 'parent');
  perform pg_temp.rel('a06a73b7-f8da-5de0-9fd3-79c90a0a690e', 'aeb20806-fbde-5e54-bb27-4978bda4f808', 'parent');
  perform pg_temp.rel('aeb20806-fbde-5e54-bb27-4978bda4f808', '6efad058-696f-5987-88db-8a4d3017c099', 'spouse');
  perform pg_temp.rel('aeb20806-fbde-5e54-bb27-4978bda4f808', 'b0077813-48d9-51b1-bd34-ab8fd63d6a48', 'parent');
  perform pg_temp.rel('6efad058-696f-5987-88db-8a4d3017c099', 'b0077813-48d9-51b1-bd34-ab8fd63d6a48', 'parent');
  perform pg_temp.rel('aeb20806-fbde-5e54-bb27-4978bda4f808', '5b1a76f0-3656-50ca-a3cd-9892a39c0d0b', 'parent');
  perform pg_temp.rel('6efad058-696f-5987-88db-8a4d3017c099', '5b1a76f0-3656-50ca-a3cd-9892a39c0d0b', 'parent');
  perform pg_temp.rel('aeb20806-fbde-5e54-bb27-4978bda4f808', '9c941436-6d18-500e-b4fb-fc9edfea57ae', 'parent');
  perform pg_temp.rel('6efad058-696f-5987-88db-8a4d3017c099', '9c941436-6d18-500e-b4fb-fc9edfea57ae', 'parent');
  perform pg_temp.rel('aeb20806-fbde-5e54-bb27-4978bda4f808', '012d3353-a68a-57be-b84e-170de228876c', 'parent');
  perform pg_temp.rel('6efad058-696f-5987-88db-8a4d3017c099', '012d3353-a68a-57be-b84e-170de228876c', 'parent');
  perform pg_temp.rel('aeb20806-fbde-5e54-bb27-4978bda4f808', 'c8c80075-e63e-5d1f-824e-29eea8d9b1b6', 'parent');
  perform pg_temp.rel('6efad058-696f-5987-88db-8a4d3017c099', 'c8c80075-e63e-5d1f-824e-29eea8d9b1b6', 'parent');
  perform pg_temp.rel('9c941436-6d18-500e-b4fb-fc9edfea57ae', '8108ca03-b4b1-552d-b057-ba034af0b982', 'spouse');
  perform pg_temp.rel('b0077813-48d9-51b1-bd34-ab8fd63d6a48', '5c92a685-d57e-565b-9be0-83b5d49a649d', 'spouse');
  perform pg_temp.rel('b0077813-48d9-51b1-bd34-ab8fd63d6a48', '2875dbd7-b3a2-5dd4-b29b-02513c680b6c', 'parent');
  perform pg_temp.rel('5c92a685-d57e-565b-9be0-83b5d49a649d', '2875dbd7-b3a2-5dd4-b29b-02513c680b6c', 'parent');
  perform pg_temp.rel('b0077813-48d9-51b1-bd34-ab8fd63d6a48', 'f49ffc4a-43b6-5c4f-bf65-514c22e20cba', 'parent');
  perform pg_temp.rel('5c92a685-d57e-565b-9be0-83b5d49a649d', 'f49ffc4a-43b6-5c4f-bf65-514c22e20cba', 'parent');
  perform pg_temp.rel('b0077813-48d9-51b1-bd34-ab8fd63d6a48', '8f6cccd8-b2cd-520b-974a-3a874a6a2664', 'parent');
  perform pg_temp.rel('5c92a685-d57e-565b-9be0-83b5d49a649d', '8f6cccd8-b2cd-520b-974a-3a874a6a2664', 'parent');
  perform pg_temp.rel('b0077813-48d9-51b1-bd34-ab8fd63d6a48', '5b1fa248-b9d9-5651-8fb7-f792b19f2092', 'parent');
  perform pg_temp.rel('5c92a685-d57e-565b-9be0-83b5d49a649d', '5b1fa248-b9d9-5651-8fb7-f792b19f2092', 'parent');
  perform pg_temp.rel('2875dbd7-b3a2-5dd4-b29b-02513c680b6c', 'f293a639-40a6-5174-b7f4-8cc9b393269e', 'spouse');
  perform pg_temp.rel('2875dbd7-b3a2-5dd4-b29b-02513c680b6c', '385403bb-de7b-5166-9463-8868a9327cd5', 'parent');
  perform pg_temp.rel('f293a639-40a6-5174-b7f4-8cc9b393269e', '385403bb-de7b-5166-9463-8868a9327cd5', 'parent');
  perform pg_temp.rel('2875dbd7-b3a2-5dd4-b29b-02513c680b6c', 'd1ca5f35-4fbe-55a4-b1da-1827f6693be8', 'parent');
  perform pg_temp.rel('f293a639-40a6-5174-b7f4-8cc9b393269e', 'd1ca5f35-4fbe-55a4-b1da-1827f6693be8', 'parent');
  perform pg_temp.rel('2875dbd7-b3a2-5dd4-b29b-02513c680b6c', '0a5b552d-476f-5dbd-903c-647857782f5b', 'parent');
  perform pg_temp.rel('f293a639-40a6-5174-b7f4-8cc9b393269e', '0a5b552d-476f-5dbd-903c-647857782f5b', 'parent');
  perform pg_temp.rel('2875dbd7-b3a2-5dd4-b29b-02513c680b6c', 'e98bc6b1-49c2-5623-aba2-4cee10449030', 'parent');
  perform pg_temp.rel('f293a639-40a6-5174-b7f4-8cc9b393269e', 'e98bc6b1-49c2-5623-aba2-4cee10449030', 'parent');
  update public.genealogy_members set pos_x = 3204, pos_y = 0 where id = '47d9c703-1d1f-58d5-944d-4d6de1538bc8';
  update public.genealogy_members set pos_x = 3474, pos_y = 460 where id = '31249974-67d1-5b9b-833c-ee42d4c79311';
  update public.genealogy_members set pos_x = 3959, pos_y = 460 where id = 'b270132d-7430-5d22-8d7f-d80e5f7510a0';
  update public.genealogy_members set pos_x = 3511, pos_y = 1188 where id = '58a06e35-f0e9-5a48-8dae-883cce479dad';
  update public.genealogy_members set pos_x = 3921, pos_y = 1188 where id = '1db79383-9fe2-533f-b22d-e215710f903c';
  update public.genealogy_members set pos_x = 3011, pos_y = 1188 where id = 'cc35611b-92b2-59ad-84ec-af6f0b1c43dc';
  update public.genealogy_members set pos_x = 3056, pos_y = 1854 where id = '4c925250-cc0a-5275-b7b7-8c1bc9abbf04';
  update public.genealogy_members set pos_x = 3466, pos_y = 1854 where id = '6c5caa00-9096-5666-a103-6670e255692c';
  update public.genealogy_members set pos_x = 3100, pos_y = 2388 where id = '13a298b4-6887-559d-9b09-21e559d0fdb4';
  update public.genealogy_members set pos_x = 3510, pos_y = 2388 where id = '1fccc06d-b827-550f-914d-2097bfba207a';
  update public.genealogy_members set pos_x = 3920, pos_y = 2388 where id = '8a252fbb-00c7-5d6d-9262-c2cc79ac5b86';
  update public.genealogy_members set pos_x = 4330, pos_y = 2388 where id = 'dc687316-31b3-5688-954c-2c20ffb22b9a';
  update public.genealogy_members set pos_x = 4740, pos_y = 2388 where id = '69a6e43d-c2de-5cd3-be52-a569bcd6e190';
  update public.genealogy_members set pos_x = 5150, pos_y = 2388 where id = '5be6c288-129b-5d31-9f0b-d4088ffc831e';
  update public.genealogy_members set pos_x = 1764, pos_y = 2974 where id = 'ab4b99c0-768a-5ddf-b889-f18fff55975f';
  update public.genealogy_members set pos_x = 2174, pos_y = 2974 where id = '0fb1172e-701a-57a8-a35c-2fad8792fe82';
  update public.genealogy_members set pos_x = 2584, pos_y = 2974 where id = 'c82f84ad-4ea5-5da8-a230-993f8ac85831';
  update public.genealogy_members set pos_x = 3404, pos_y = 2974 where id = '8108ca03-b4b1-552d-b057-ba034af0b982';
  update public.genealogy_members set pos_x = 2994, pos_y = 2974 where id = '10914306-fdab-5c7b-9d11-df2dce1c99a0';
  update public.genealogy_members set pos_x = 636, pos_y = 2974 where id = 'b1738020-792b-51c5-9983-564a902cfbb7';
  update public.genealogy_members set pos_x = 380, pos_y = 3506 where id = 'dfaf518d-79ef-5202-9432-d0b2e9206c44';
  update public.genealogy_members set pos_x = 1200, pos_y = 3506 where id = '6b272392-44dd-5b53-a641-8015dc16809e';
  update public.genealogy_members set pos_x = 790, pos_y = 3506 where id = '0651dbc9-4915-5dc6-9ee8-5d3c766ebf31';
  update public.genealogy_members set pos_x = 1610, pos_y = 3506 where id = '72ac0a85-b316-5bdd-aa90-26b8dbdc8898';
  update public.genealogy_members set pos_x = 2020, pos_y = 3506 where id = '19908c82-d94c-5f58-9e3a-95c36558a02d';
  update public.genealogy_members set pos_x = 0, pos_y = 3506 where id = '85a335e5-5c48-5e25-94be-c685e07c2bda';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('8108ca03-b4b1-552d-b057-ba034af0b982', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 4691, 6858, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f293a639-40a6-5174-b7f4-8cc9b393269e', 'entry', 'fcf82ede-c8f9-5d8e-9473-aa880362dff4', 593, 7318, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('9c941436-6d18-500e-b4fb-fc9edfea57ae', 'entry', '6cd1705d-246d-59e6-975a-2cba83ec30f3', 3784, 2974, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('5a6fd836-8bfb-51bf-a3c9-6b1e626262ce', 'entry', '6cd1705d-246d-59e6-975a-2cba83ec30f3', 3744, 0, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('6bd40d83-ed29-579c-a494-b01e7c398b43', 'entry', '6cd1705d-246d-59e6-975a-2cba83ec30f3', 3094, 460, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f65f36f4-f4e3-57ba-83e8-a74ecbc31788', 'entry', '6cd1705d-246d-59e6-975a-2cba83ec30f3', 4783, 1854, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('31f64675-cdf0-5ebc-b178-202a637bfc43', 'entry', '6cd1705d-246d-59e6-975a-2cba83ec30f3', 2069, 2388, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v54 : % membres ajoutés.', 49;
end $$;
