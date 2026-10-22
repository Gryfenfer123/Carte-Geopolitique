-- schema_v33.sql — Arbres généalogiques « Wettin » et « Hohenzollern » (dynasties allemandes)
-- À lancer dans le SQL Editor de Supabase (une seule fois). Rien n'est supprimé ni modifié :
-- il ne fait QUE des ajouts : 2 arbres (Allemagne > Dynastie > Wettin et > Hohenzollern), leurs membres,
-- quelques membres créés dans les arbres d'origine des épouses (Wittelsbach, Habsbourg, Hohenstaufen, Welf,
-- Oldenbourg, Jagellon, Orange-Nassau, Hanovre, Saxe-Cobourg, Bourbon-Parme, Bragance), plus les liens.
-- Les membres déjà présents dans tes autres arbres sont RETROUVÉS par leur identifiant et reliés, jamais recréés.
-- Si un identifiant n'est pas trouvé, le script s'arrête sans rien écrire.

do $$
declare
  admin_id constant uuid := '96d2f891-6b9e-4967-89ed-18f83270ef28';
  sec_wet constant uuid := '4f726329-6d33-4bbc-b629-faa0815e49a0';  -- Allemagne > Dynastie > Wettin
  sec_hoh constant uuid := '301b9c78-ecb6-45b7-b5ab-8758d6cd2a87';  -- Allemagne > Dynastie > Hohenzollern
  cat_id constant uuid := '428a2e75-c8e3-51a1-b12a-bfe7a4018659';
  tree_wet uuid;
  tree_hoh uuid;
begin
  if exists (select 1 from public.dossier_entries where section_id in (sec_wet, sec_hoh) and type = 'genealogy') then
    raise exception 'Un arbre existe déjà dans la sous-catégorie Wettin ou Hohenzollern (Allemagne) : rien n''a été fait.';
  end if;
  if (select count(*) from public.dossier_sections where id in (sec_wet, sec_hoh)) <> 2 then
    raise exception 'Sous-catégories Wettin / Hohenzollern introuvables : rien n''a été fait.';
  end if;

  insert into public.dossier_entries (owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('country', 'DEU', 'genealogy', 'Wettin', cat_id, sec_wet, admin_id) returning id into tree_wet;
  insert into public.dossier_entries (owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('country', 'DEU', 'genealogy', 'Hohenzollern', cat_id, sec_hoh, admin_id) returning id into tree_hoh;

  create temp table _m (code text primary key, id uuid not null default gen_random_uuid()) on commit drop;

  insert into _m(code) values ('conrad');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Conrad Ier « le Pieux »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Dresden_Fuerstenzug_Konrad_der_Grosse.jpg/330px-Dresden_Fuerstenzug_Konrad_der_Grosse.jpg', 1098, 1157, 'Margrave de Misnie et de Lusace', 'Maison de Wettin', 0, 0, admin_id, false from _m where code = 'conrad';
  insert into _m(code) values ('otto');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Othon Ier « le Riche »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Freiberg_Otto_der_Reiche_Brunnendenkmal.jpg/330px-Freiberg_Otto_der_Reiche_Brunnendenkmal.jpg', 1125, 1190, 'Margrave de Misnie', 'Maison de Wettin', 0, 420, admin_id, false from _m where code = 'otto';
  insert into _m(code) values ('hedw');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Hedwige de Brandebourg', null, 1140, 1203, 'Margravine de Misnie', 'Ascanie / Wettin', 450, 420, admin_id, false from _m where code = 'hedw';
  insert into _m(code) values ('albert1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Albert Ier « le Fier »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Dresden_F%C3%BCrstenzug_081.JPG/330px-Dresden_F%C3%BCrstenzug_081.JPG', 1158, 1195, 'Margrave de Misnie', 'Maison de Wettin', -600, 840, admin_id, false from _m where code = 'albert1';
  insert into _m(code) values ('thierry');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Thierry Ier « l''Exilé »', null, 1162, 1221, 'Margrave de Misnie et de Basse-Lusace', 'Maison de Wettin', 0, 840, admin_id, false from _m where code = 'thierry';
  insert into _m(code) values ('jutta');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jutta de Thuringe', null, 1184, 1235, 'Margravine de Misnie', 'Ludowingiens / Wettin', 450, 840, admin_id, false from _m where code = 'jutta';
  insert into _m(code) values ('henri3');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Henri III « l''Illustre »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Codex_Manesse_Markgraf_Heinrich_von_Mei%C3%9Fen.jpg/330px-Codex_Manesse_Markgraf_Heinrich_von_Mei%C3%9Fen.jpg', 1215, 1288, 'Margrave de Misnie, landgrave de Thuringe', 'Maison de Wettin', 0, 1260, admin_id, false from _m where code = 'henri3';
  insert into _m(code) values ('constance');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Constance d''Autriche', null, 1212, 1243, 'Margravine de Misnie', 'Babenberg / Wettin', 450, 1260, admin_id, false from _m where code = 'constance';
  insert into _m(code) values ('albert2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Albert II « le Dégénéré »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Marketa_Albercht2.jpg/330px-Marketa_Albercht2.jpg', 1240, 1314, 'Landgrave de Thuringe, margrave de Misnie', 'Maison de Wettin', 0, 1680, admin_id, false from _m where code = 'albert2';
  insert into _m(code) values ('fred1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric Ier « le Mordu »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Dresden_F%C3%BCrstenzug_084_%28cropped%29_-_Frederick_I%2C_Margrave_of_Meissen.JPG/330px-Dresden_F%C3%BCrstenzug_084_%28cropped%29_-_Frederick_I%2C_Margrave_of_Meissen.JPG', 1257, 1323, 'Margrave de Misnie, landgrave de Thuringe', 'Maison de Wettin', 0, 2100, admin_id, false from _m where code = 'fred1';
  insert into _m(code) values ('elob');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Élisabeth de Lobdeburg-Arnshaugk', null, 1286, 1359, 'Margravine de Misnie', 'Lobdeburg-Arnshaugk / Wettin', 450, 2100, admin_id, false from _m where code = 'elob';
  insert into _m(code) values ('fred2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric II « le Sérieux »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Dresden_F%C3%BCrstenzug_084_%28cropped%29_-_Frederick_II%2C_Margrave_of_Meissen.JPG/330px-Dresden_F%C3%BCrstenzug_084_%28cropped%29_-_Frederick_II%2C_Margrave_of_Meissen.JPG', 1310, 1349, 'Margrave de Misnie, landgrave de Thuringe', 'Maison de Wettin', 0, 2520, admin_id, false from _m where code = 'fred2';
  insert into _m(code) values ('elmis');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Élisabeth de Misnie', null, 1329, 1375, 'Burgravine de Nuremberg', 'Maison de Wettin', -500, 2940, admin_id, false from _m where code = 'elmis';
  insert into _m(code) values ('fred3');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric III « le Sévère »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Friedrich_Strenge_Albrechtsburg-2.jpg/330px-Friedrich_Strenge_Albrechtsburg-2.jpg', 1332, 1381, 'Landgrave de Thuringe, margrave de Misnie', 'Maison de Wettin', 0, 2940, admin_id, false from _m where code = 'fred3';
  insert into _m(code) values ('cathhen');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Catherine de Henneberg', null, 1334, 1397, 'Margravine de Misnie', 'Henneberg / Wettin', 450, 2940, admin_id, false from _m where code = 'cathhen';
  insert into _m(code) values ('fredb');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric Ier « le Belliqueux »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Friedrich_I._von_Sachsen%2C_1370-1428_%28AT_KHM_GG4792%29.jpg/330px-Friedrich_I._von_Sachsen%2C_1370-1428_%28AT_KHM_GG4792%29.jpg', 1370, 1428, 'Margrave de Misnie, 1er électeur de Saxe (1423)', 'Maison de Wettin', 0, 3360, admin_id, false from _m where code = 'fredb';
  insert into _m(code) values ('fredd');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric II « le Doux »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Friedrich_II._der_Sanftm%C3%BCtige%2C_Kurf%C3%BCrst_von_Sachsen_%28AT_KHM_GG4793%29.jpg/330px-Friedrich_II._der_Sanftm%C3%BCtige%2C_Kurf%C3%BCrst_von_Sachsen_%28AT_KHM_GG4793%29.jpg', 1412, 1464, 'Électeur de Saxe', 'Maison de Wettin', 0, 3780, admin_id, false from _m where code = 'fredd';
  insert into _m(code) values ('cathsax');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Catherine de Saxe', null, 1421, 1476, 'Électrice de Brandebourg', 'Maison de Wettin', -500, 3780, admin_id, false from _m where code = 'cathsax';
  insert into _m(code) values ('anna');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Anne de Saxe', 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Albrecht_Achilles_Gripsholm.JPG/330px-Albrecht_Achilles_Gripsholm.JPG', 1437, 1512, 'Électrice de Brandebourg', 'Maison de Wettin', 500, 4200, admin_id, false from _m where code = 'anna';
  insert into _m(code) values ('ernest');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Ernest de Saxe', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Ernst_Kurf%C3%BCrst_von_Sachsen%2C_1441-1486_%28AT_KHM_GG4795%29.jpg/330px-Ernst_Kurf%C3%BCrst_von_Sachsen%2C_1441-1486_%28AT_KHM_GG4795%29.jpg', 1441, 1486, 'Électeur de Saxe, landgrave de Thuringe (ligne ernestine)', 'Maison de Wettin', -1500, 4200, admin_id, false from _m where code = 'ernest';
  insert into _m(code) values ('albertc');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Albert III « le Courageux »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Herzog-Albrecht-der-Beherzt.jpg/330px-Herzog-Albrecht-der-Beherzt.jpg', 1443, 1500, 'Duc de Saxe (ligne albertine)', 'Maison de Wettin', 2000, 4200, admin_id, false from _m where code = 'albertc';
  insert into _m(code) values ('sidonie');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Sidonie de Bohême', 'https://upload.wikimedia.org/wikipedia/commons/4/48/Sidonie_von_Podiebrad.jpg', 1449, 1510, 'Duchesse de Saxe', 'Poděbrady / Wettin', 2450, 4200, admin_id, false from _m where code = 'sidonie';
  insert into _m(code) values ('freds');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric III « le Sage »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Kurf%C3%BCrst-Friedrich-III-von-Sachsen.jpg/330px-Kurf%C3%BCrst-Friedrich-III-von-Sachsen.jpg', 1463, 1525, 'Électeur de Saxe', 'Maison de Wettin', -2100, 4620, admin_id, false from _m where code = 'freds';
  insert into _m(code) values ('jeanc');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean « le Constant »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Lucas_Cranach_the_Elder_-_Portrait_of_Johann_the_Steadfast_1509.jpg/330px-Lucas_Cranach_the_Elder_-_Portrait_of_Johann_the_Steadfast_1509.jpg', 1468, 1532, 'Électeur de Saxe', 'Maison de Wettin', -1500, 4620, admin_id, false from _m where code = 'jeanc';
  insert into _m(code) values ('sophiem');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Sophie de Mecklembourg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Sophie_of_Mecklenburg_%281481%E2%80%931503%29.jpg/330px-Sophie_of_Mecklenburg_%281481%E2%80%931503%29.jpg', 1481, 1503, 'Électrice de Saxe', 'Mecklembourg / Wettin', -1000, 4620, admin_id, false from _m where code = 'sophiem';
  insert into _m(code) values ('jf1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean-Frédéric Ier « le Magnanime »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/Lucas_Cranach_d._%C3%84._044.jpg/330px-Lucas_Cranach_d._%C3%84._044.jpg', 1503, 1554, 'Électeur de Saxe (1532-1547), duc de Saxe', 'Maison de Wettin', -1500, 5040, admin_id, false from _m where code = 'jf1';
  insert into _m(code) values ('sibylle');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Sibylle de Clèves', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Bemberg_Fondation_Toulouse_-_Portrait_de_Sibylle_de_Cl%C3%A8ve%2C_%C3%A9lectrice_de_Saxe_-_Lucas_I_Cranach_-_Inv.1086_Huile_sur_panneau_1531.jpg/330px-Bemberg_Fondation_Toulouse_-_Portrait_de_Sibylle_de_Cl%C3%A8ve%2C_%C3%A9lectrice_de_Saxe_-_Lucas_I_Cranach_-_Inv.1086_Huile_sur_panneau_1531.jpg', 1512, 1554, 'Électrice de Saxe', 'La Marck-Clèves / Wettin', -1000, 5040, admin_id, false from _m where code = 'sibylle';
  insert into _m(code) values ('jguil');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean-Guillaume de Saxe-Weimar', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Jean-Guillaume-de-Saxe-Weimar.jpg/330px-Jean-Guillaume-de-Saxe-Weimar.jpg', 1530, 1573, 'Duc de Saxe-Weimar', 'Maison de Wettin', -1500, 5460, admin_id, false from _m where code = 'jguil';
  insert into _m(code) values ('jean2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean II de Saxe-Weimar', 'https://upload.wikimedia.org/wikipedia/commons/b/bf/Johann_of_Saxe-Weimar-Jena.jpg', 1570, 1605, 'Duc de Saxe-Weimar', 'Maison de Wettin', -1500, 5880, admin_id, false from _m where code = 'jean2';
  insert into _m(code) values ('ernestp');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Ernest Ier « le Pieux »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Ernest_I%2C_duke_of_Saxe-Gotha-Altenburg.jpg/330px-Ernest_I%2C_duke_of_Saxe-Gotha-Altenburg.jpg', 1601, 1675, 'Duc de Saxe-Gotha', 'Maison de Wettin', -1500, 6300, admin_id, false from _m where code = 'ernestp';
  insert into _m(code) values ('fgo1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric Ier de Saxe-Gotha-Altenbourg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Frederick_I_of_Saxe-Gotha-Altenburg.jpg/330px-Frederick_I_of_Saxe-Gotha-Altenburg.jpg', 1646, 1691, 'Duc de Saxe-Gotha-Altenbourg', 'Maison de Wettin', -2300, 6720, admin_id, false from _m where code = 'fgo1';
  insert into _m(code) values ('jeanern');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean-Ernest IV de Saxe-Saalfeld', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Johannernstsaalfeld.jpg/330px-Johannernstsaalfeld.jpg', 1658, 1729, 'Duc de Saxe-Saalfeld', 'Maison de Wettin', -900, 6720, admin_id, false from _m where code = 'jeanern';
  insert into _m(code) values ('fgo2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric II de Saxe-Gotha-Altenbourg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/FriedrichIISaGoAlt.jpg/330px-FriedrichIISaGoAlt.jpg', 1676, 1732, 'Duc de Saxe-Gotha-Altenbourg', 'Maison de Wettin', -2300, 7140, admin_id, false from _m where code = 'fgo2';
  insert into _m(code) values ('madaug');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Madeleine-Augusta d''Anhalt-Zerbst', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Magdalena_Augusta_von_Anhalt-Zerbst.jpg/330px-Magdalena_Augusta_von_Anhalt-Zerbst.jpg', 1679, 1740, 'Duchesse de Saxe-Gotha-Altenbourg', 'Anhalt-Zerbst / Wettin', -1800, 7140, admin_id, false from _m where code = 'madaug';
  insert into _m(code) values ('fjos');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'François-Josias de Saxe-Cobourg-Saalfeld', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Francis_Josias%2C_duke_of_Saxe-Coburg-Saalfeld.jpg/330px-Francis_Josias%2C_duke_of_Saxe-Coburg-Saalfeld.jpg', 1697, 1764, 'Duc de Saxe-Cobourg-Saalfeld', 'Maison de Wettin', -900, 7140, admin_id, false from _m where code = 'fjos';
  insert into _m(code) values ('efred');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Ernest-Frédéric de Saxe-Cobourg-Saalfeld', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Ernesto_Federico_de_Wettin_Saalfeld.jpg/330px-Ernesto_Federico_de_Wettin_Saalfeld.jpg', 1724, 1800, 'Duc de Saxe-Cobourg-Saalfeld', 'Maison de Wettin', -900, 7560, admin_id, false from _m where code = 'efred';
  insert into _m(code) values ('fran');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'François de Saxe-Cobourg-Saalfeld', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fb/Johann_Heinrich_Schr%C3%B6der_-_Herzog_Franz_Friedrich_Anton_von_Sachsen-Coburg-Saalfeld.jpg/330px-Johann_Heinrich_Schr%C3%B6der_-_Herzog_Franz_Friedrich_Anton_von_Sachsen-Coburg-Saalfeld.jpg', 1750, 1806, 'Duc de Saxe-Cobourg-Saalfeld', 'Maison de Wettin', -900, 7980, admin_id, false from _m where code = 'fran';
  insert into _m(code) values ('augreuss');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Augusta Reuss d''Ebersdorf', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Augusta_di_Reuss-Ebersdorf%2C_duchessa_di_Sassonia-Coburgo-Saalfeld.jpg/330px-Augusta_di_Reuss-Ebersdorf%2C_duchessa_di_Sassonia-Coburgo-Saalfeld.jpg', 1757, 1831, 'Duchesse de Saxe-Cobourg-Saalfeld', 'Reuss / Wettin', -400, 7980, admin_id, false from _m where code = 'augreuss';
  insert into _m(code) values ('ernest1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Ernest Ier de Saxe-Cobourg et Gotha', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Ernst_I%2C_Duke_of_Saxe-Coburg_and_Gotha_-_Dawe_1818-19.jpg/330px-Ernst_I%2C_Duke_of_Saxe-Coburg_and_Gotha_-_Dawe_1818-19.jpg', 1784, 1844, 'Duc de Saxe-Cobourg et Gotha', 'Maison de Wettin', -1200, 8400, admin_id, false from _m where code = 'ernest1';
  insert into _m(code) values ('louisegotha');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Louise de Saxe-Gotha-Altenbourg', null, 1800, 1831, 'Duchesse de Saxe-Cobourg et Gotha', 'Maison de Wettin', -700, 8400, admin_id, false from _m where code = 'louisegotha';
  insert into _m(code) values ('ernest2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Ernest II de Saxe-Cobourg et Gotha', 'https://upload.wikimedia.org/wikipedia/commons/0/02/ErnstIIofSCG.jpg', 1818, 1893, 'Duc de Saxe-Cobourg et Gotha', 'Maison de Wettin', -1200, 8820, admin_id, false from _m where code = 'ernest2';
  insert into _m(code) values ('georges');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Georges « le Barbu »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Georg_der_B%C3%A4rtige_2.jpg/330px-Georg_der_B%C3%A4rtige_2.jpg', 1471, 1539, 'Duc de Saxe', 'Maison de Wettin', 1500, 4620, admin_id, false from _m where code = 'georges';
  insert into _m(code) values ('henrip');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Henri IV « le Pieux »', 'https://upload.wikimedia.org/wikipedia/commons/1/15/Lucas_Cranach_d._%C3%84._042_small.jpg', 1473, 1541, 'Duc de Saxe', 'Maison de Wettin', 2500, 4620, admin_id, false from _m where code = 'henrip';
  insert into _m(code) values ('catm');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Catherine de Mecklembourg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/06/Lucas_Cranach_the_Elder_-_Duchess_Katharina_von_Mecklenburg_-_Google_Art_ProjectFXD_crop.jpg/330px-Lucas_Cranach_the_Elder_-_Duchess_Katharina_von_Mecklenburg_-_Google_Art_ProjectFXD_crop.jpg', 1487, 1561, 'Duchesse de Saxe', 'Mecklembourg / Wettin', 3000, 4620, admin_id, false from _m where code = 'catm';
  insert into _m(code) values ('madsax');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Madeleine de Saxe', 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Portrait_of_Magdalena_of_Saxony%2C_Wife_of_Elector_Joachim_II_of_Brandenburg%2C_c._1529%2C_by_Lucas_Cranach_the_Elder_-_Art_Institute_of_Chicago_-_DSC00095.JPG/330px-Portrait_of_Magdalena_of_Saxony%2C_Wife_of_Elector_Joachim_II_of_Brandenburg%2C_c._1529%2C_by_Lucas_Cranach_the_Elder_-_Art_Institute_of_Chicago_-_DSC00095.JPG', 1507, 1534, 'Électrice de Brandebourg', 'Maison de Wettin', 1500, 5040, admin_id, false from _m where code = 'madsax';
  insert into _m(code) values ('maurice');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Maurice', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Moritz_Sachsen.JPG/330px-Moritz_Sachsen.JPG', 1521, 1553, 'Duc de Saxe, électeur de Saxe (1547)', 'Maison de Wettin', 2500, 5040, admin_id, false from _m where code = 'maurice';
  insert into _m(code) values ('agnes');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Agnès de Hesse', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Agnes_of_Hesse.JPG/330px-Agnes_of_Hesse.JPG', 1527, 1555, 'Électrice de Saxe', 'Hesse / Wettin', 2950, 5040, admin_id, false from _m where code = 'agnes';
  insert into _m(code) values ('auguste');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Auguste Ier', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Lucas_Cranach_d._J._012_detail.jpg/330px-Lucas_Cranach_d._J._012_detail.jpg', 1526, 1586, 'Électeur de Saxe', 'Maison de Wettin', 3500, 5040, admin_id, false from _m where code = 'auguste';
  insert into _m(code) values ('chr1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Christian Ier', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Christian_I_of_Saxony.jpg/330px-Christian_I_of_Saxony.jpg', 1560, 1591, 'Électeur de Saxe', 'Maison de Wettin', 3500, 5460, admin_id, false from _m where code = 'chr1';
  insert into _m(code) values ('chr2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Christian II', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Zacharias_Wehme_-_Prince_Elector_Christian_II_of_Saxony_%28ca._1601-1606%29_-_Google_Art_Project.jpg/330px-Zacharias_Wehme_-_Prince_Elector_Christian_II_of_Saxony_%28ca._1601-1606%29_-_Google_Art_Project.jpg', 1583, 1611, 'Électeur de Saxe', 'Maison de Wettin', 3000, 5880, admin_id, false from _m where code = 'chr2';
  insert into _m(code) values ('jg1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean-Georges Ier', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Johann_Georg_I_Saxony.jpg/330px-Johann_Georg_I_Saxony.jpg', 1585, 1656, 'Électeur de Saxe', 'Maison de Wettin', 4000, 5880, admin_id, false from _m where code = 'jg1';
  insert into _m(code) values ('jg2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean-Georges II', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Johan_Georg_II_Johann_Fink%2C_vor_1675.jpg/330px-Johan_Georg_II_Johann_Fink%2C_vor_1675.jpg', 1613, 1680, 'Électeur de Saxe', 'Maison de Wettin', 4000, 6300, admin_id, false from _m where code = 'jg2';
  insert into _m(code) values ('jg3');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean-Georges III', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/1647_Johann_Georg.JPG/330px-1647_Johann_Georg.JPG', 1647, 1691, 'Électeur de Saxe', 'Maison de Wettin', 4000, 6720, admin_id, false from _m where code = 'jg3';
  insert into _m(code) values ('jg4');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean-Georges IV', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Johann_Georg_IV_von_Sachsen.jpg/330px-Johann_Georg_IV_von_Sachsen.jpg', 1668, 1694, 'Électeur de Saxe', 'Maison de Wettin', 3500, 7140, admin_id, false from _m where code = 'jg4';
  insert into _m(code) values ('fa1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric-Auguste Ier « Auguste II le Fort »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/August_der_Starke_%281670-1733%29.jpg/330px-August_der_Starke_%281670-1733%29.jpg', 1670, 1733, 'Électeur de Saxe, roi de Pologne (Auguste II)', 'Maison de Wettin', 4500, 7140, admin_id, true from _m where code = 'fa1';
  insert into _m(code) values ('fc');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric-Christian', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Anton_raphael_mengs_portrait_of_friedrich_christian_prince_of_saxony_t111526%29.jpg/330px-Anton_raphael_mengs_portrait_of_friedrich_christian_prince_of_saxony_t111526%29.jpg', 1722, 1763, 'Électeur de Saxe (1763)', 'Maison de Wettin', 4500, 7980, admin_id, false from _m where code = 'fc';
  insert into _m(code) values ('xav');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'François-Xavier de Saxe', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Franciszek_Ksawery_Wettin.jpeg/330px-Franciszek_Ksawery_Wettin.jpeg', 1730, 1806, 'Administrateur de Saxe (1763-1768), comte de Lusace', 'Maison de Wettin', 5400, 7980, admin_id, false from _m where code = 'xav';
  insert into _m(code) values ('fa3');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric-Auguste Ier « le Juste »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Frederick_Augustus_I_of_Saxony_by_Marcello_Bacciarelli_%28ca_1808-1809%29.png/330px-Frederick_Augustus_I_of_Saxony_by_Marcello_Bacciarelli_%28ca_1808-1809%29.png', 1750, 1827, 'Électeur puis 1er roi de Saxe (1806), duc de Varsovie', 'Maison de Wettin', 4000, 8400, admin_id, false from _m where code = 'fa3';
  insert into _m(code) values ('antoine');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Antoine Ier', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Anton-sachsen.jpg/330px-Anton-sachsen.jpg', 1755, 1836, 'Roi de Saxe', 'Maison de Wettin', 5000, 8400, admin_id, false from _m where code = 'antoine';
  insert into _m(code) values ('maxs');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Maximilien de Saxe', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Maximilian_Saxony.jpg/330px-Maximilian_Saxony.jpg', 1759, 1838, 'Prince de Saxe', 'Maison de Wettin', 6000, 8400, admin_id, false from _m where code = 'maxs';
  insert into _m(code) values ('fa2k');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric-Auguste II', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Friedrich_August_II_of_Saxony.jpg/330px-Friedrich_August_II_of_Saxony.jpg', 1797, 1854, 'Roi de Saxe', 'Maison de Wettin', 6000, 8820, admin_id, false from _m where code = 'fa2k';
  insert into _m(code) values ('jeans');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean Ier', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Louis_Ferdinand_von_Rayski_-_K%C3%B6nig_Johann_von_Sachsen%2C_1870.jpg/330px-Louis_Ferdinand_von_Rayski_-_K%C3%B6nig_Johann_von_Sachsen%2C_1870.jpg', 1801, 1873, 'Roi de Saxe', 'Maison de Wettin', 6900, 8820, admin_id, false from _m where code = 'jeans';
  insert into _m(code) values ('alberts');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Albert Ier', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/AK_Portrait_K%C3%B6nig_Albert_von_Sachsen_in_Uniform.png/330px-AK_Portrait_K%C3%B6nig_Albert_von_Sachsen_in_Uniform.png', 1828, 1902, 'Roi de Saxe', 'Maison de Wettin', 6900, 9240, admin_id, false from _m where code = 'alberts';
  insert into _m(code) values ('carola');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Carola de Vasa', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Carola_of_Vasa_Queen_of_Saxe.jpg/330px-Carola_of_Vasa_Queen_of_Saxe.jpg', 1833, 1907, 'Reine de Saxe', 'Holstein-Gottorp (Vasa) / Wettin', 7400, 9240, admin_id, false from _m where code = 'carola';
  insert into _m(code) values ('georgess');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Georges Ier', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/George_of_Saxony_by_Nicola_Perscheid_c1900.jpg/330px-George_of_Saxony_by_Nicola_Perscheid_c1900.jpg', 1832, 1904, 'Roi de Saxe', 'Maison de Wettin', 8000, 9240, admin_id, false from _m where code = 'georgess';
  insert into _m(code) values ('fa3k');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric-Auguste III', 'https://upload.wikimedia.org/wikipedia/commons/9/92/Friedrich_August_III_von_Sachsen_in_Paradeuniform.jpg', 1865, 1932, 'Dernier roi de Saxe (abdique en 1918)', 'Maison de Wettin', 8000, 9660, admin_id, false from _m where code = 'fa3k';
  insert into _m(code) values ('mthur');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Marguerite de Thuringe', null, 1449, 1501, 'Électrice de Brandebourg', 'Maison de Wettin', -500, 5040, admin_id, false from _m where code = 'mthur';
  insert into _m(code) values ('augweim');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Augusta de Saxe-Weimar-Eisenach', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Augusta_von_Preussen.jpg/330px-Augusta_von_Preussen.jpg', 1811, 1890, 'Reine de Prusse, impératrice allemande', 'Maison de Wettin', -500, 6300, admin_id, false from _m where code = 'augweim';
  insert into _m(code) values ('f5');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric V de Nuremberg', null, 1332, 1398, 'Burgrave de Nuremberg', 'Maison de Hohenzollern', 0, 0, admin_id, false from _m where code = 'f5';
  insert into _m(code) values ('f6');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric Ier de Brandebourg', null, 1371, 1440, 'Burgrave de Nuremberg (Frédéric VI), électeur de Brandebourg (1415)', 'Maison de Hohenzollern', 0, 420, admin_id, false from _m where code = 'f6';
  insert into _m(code) values ('f2b');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric II « Dents de fer »', 'https://upload.wikimedia.org/wikipedia/commons/7/7a/1440_friedrich_II.jpg', 1413, 1471, 'Électeur de Brandebourg', 'Maison de Hohenzollern', -500, 840, admin_id, false from _m where code = 'f2b';
  insert into _m(code) values ('albach');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Albert III Achille', 'https://upload.wikimedia.org/wikipedia/commons/b/ba/AlbrechtAchilles.jpg', 1414, 1486, 'Électeur de Brandebourg (1470)', 'Maison de Hohenzollern', 500, 840, admin_id, false from _m where code = 'albach';
  insert into _m(code) values ('mbade');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Marguerite de Bade', null, 1431, 1457, 'Margravine de Brandebourg-Ansbach', 'Zähringen (Bade) / Hohenzollern', 1000, 840, admin_id, false from _m where code = 'mbade';
  insert into _m(code) values ('fansb');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric II « l''Ancien » de Brandebourg-Ansbach', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Sebald_Friedrich2.JPG/330px-Sebald_Friedrich2.JPG', 1460, 1536, 'Margrave de Brandebourg-Ansbach-Kulmbach', 'Maison de Hohenzollern', 0, 1260, admin_id, false from _m where code = 'fansb';
  insert into _m(code) values ('jcic');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Jean Cicéron', 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/JohannCicero1500.JPG/330px-JohannCicero1500.JPG', 1455, 1499, 'Électeur de Brandebourg', 'Maison de Hohenzollern', 900, 1260, admin_id, false from _m where code = 'jcic';
  insert into _m(code) values ('albpr');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Albert de Brandebourg-Ansbach', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Albrecht_von_Hohenzollern.jpg/330px-Albrecht_von_Hohenzollern.jpg', 1490, 1568, 'Grand maître de l''ordre Teutonique, 1er duc de Prusse (1525)', 'Maison de Hohenzollern', 0, 1680, admin_id, false from _m where code = 'albpr';
  insert into _m(code) values ('j1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Joachim Ier Nestor', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Joachim_I._Nestor.jpg/330px-Joachim_I._Nestor.jpg', 1484, 1535, 'Électeur de Brandebourg', 'Maison de Hohenzollern', 900, 1680, admin_id, false from _m where code = 'j1';
  insert into _m(code) values ('albfred');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Albert-Frédéric', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/AlbrechtFriedrichPreu%C3%9Fen.1612.JPG/330px-AlbrechtFriedrichPreu%C3%9Fen.1612.JPG', 1553, 1618, 'Duc de Prusse', 'Maison de Hohenzollern', 0, 2100, admin_id, false from _m where code = 'albfred';
  insert into _m(code) values ('mecl');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Marie-Éléonore de Clèves', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Marie_Eleonore_von_J%C3%BClich-Kleve-Berg_%281550-1608%29%2C_Herzogin_von_Preu%C3%9Fen_c.1600.jpg/330px-Marie_Eleonore_von_J%C3%BClich-Kleve-Berg_%281550-1608%29%2C_Herzogin_von_Preu%C3%9Fen_c.1600.jpg', 1550, 1608, 'Duchesse de Prusse', 'La Marck-Clèves / Hohenzollern', 450, 2100, admin_id, false from _m where code = 'mecl';
  insert into _m(code) values ('j2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Joachim II Hector', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Lucas_Cranach_d._%C3%84._043.jpg/330px-Lucas_Cranach_d._%C3%84._043.jpg', 1505, 1571, 'Électeur de Brandebourg', 'Maison de Hohenzollern', 900, 2100, admin_id, false from _m where code = 'j2';
  insert into _m(code) values ('msp');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Madeleine-Sibylle de Prusse', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Magdalene_Sibylle_of_Prussia_-_Gem%C3%A4ldegalerie_Alte_Meister_%28cropped%29.jpg/330px-Magdalene_Sibylle_of_Prussia_-_Gem%C3%A4ldegalerie_Alte_Meister_%28cropped%29.jpg', 1586, 1659, 'Électrice de Saxe', 'Maison de Hohenzollern', -500, 2520, admin_id, false from _m where code = 'msp';
  insert into _m(code) values ('jgeo');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Jean II Georges « l''Économe »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/JohannGeorg1564.JPG/330px-JohannGeorg1564.JPG', 1525, 1598, 'Électeur de Brandebourg', 'Maison de Hohenzollern', 900, 2520, admin_id, false from _m where code = 'jgeo';
  insert into _m(code) values ('sliegn');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Sophie de Liegnitz', null, 1525, 1546, 'Électrice de Brandebourg', 'Piast de Legnica / Hohenzollern', 1350, 2520, admin_id, false from _m where code = 'sliegn';
  insert into _m(code) values ('sophiebr');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Sophie de Brandebourg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Andreas_Riehl_-_Sophia_of_Brandenburg%2C_Electress_of_Saxony_-_R%C3%BCstkammer.jpg/330px-Andreas_Riehl_-_Sophia_of_Brandenburg%2C_Electress_of_Saxony_-_R%C3%BCstkammer.jpg', 1568, 1622, 'Électrice de Saxe', 'Maison de Hohenzollern', 1800, 2520, admin_id, false from _m where code = 'sophiebr';
  insert into _m(code) values ('jfred');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Joachim-Frédéric', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/JoachimFriedrichBrandenburg1600.JPG/330px-JoachimFriedrichBrandenburg1600.JPG', 1546, 1608, 'Électeur de Brandebourg', 'Maison de Hohenzollern', 900, 2940, admin_id, false from _m where code = 'jfred';
  insert into _m(code) values ('ckus');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Catherine de Brandebourg-Küstrin', null, 1549, 1602, 'Électrice de Brandebourg', 'Maison de Hohenzollern', 1350, 2940, admin_id, false from _m where code = 'ckus';
  insert into _m(code) values ('jsig');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Jean-Sigismond', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Johann_Sigismund_Grunewald.jpg/330px-Johann_Sigismund_Grunewald.jpg', 1572, 1619, 'Électeur de Brandebourg, duc de Prusse (1618)', 'Maison de Hohenzollern', 900, 3360, admin_id, false from _m where code = 'jsig';
  insert into _m(code) values ('annepr');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Anne de Prusse', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Anna_of_Prussia%2C_Duchess_of_Prussia_%281576-1625%29.jpg/330px-Anna_of_Prussia%2C_Duchess_of_Prussia_%281576-1625%29.jpg', 1576, 1625, 'Électrice de Brandebourg, duchesse héritière de Prusse', 'Maison de Hohenzollern', 450, 3360, admin_id, false from _m where code = 'annepr';
  insert into _m(code) values ('gw');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Georges-Guillaume', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/GeorgWilhelm.1635.Ausschnitt.JPG/330px-GeorgWilhelm.1635.Ausschnitt.JPG', 1595, 1640, 'Électeur de Brandebourg', 'Maison de Hohenzollern', 450, 3780, admin_id, false from _m where code = 'gw';
  insert into _m(code) values ('ge');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric-Guillaume « le Grand Électeur »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Flink%2C_Govaert_-_Friedrich_Wilhelm_I_-_Schloss_Charlottenburg.jpeg/330px-Flink%2C_Govaert_-_Friedrich_Wilhelm_I_-_Schloss_Charlottenburg.jpeg', 1620, 1688, 'Électeur de Brandebourg, duc de Prusse', 'Maison de Hohenzollern', 450, 4200, admin_id, false from _m where code = 'ge';
  insert into _m(code) values ('f1pr');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric Ier', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/FriedrichI.1713.JPG/330px-FriedrichI.1713.JPG', 1657, 1713, 'Électeur de Brandebourg (Frédéric III), 1er roi en Prusse (1701)', 'Maison de Hohenzollern', 450, 4620, admin_id, false from _m where code = 'f1pr';
  insert into _m(code) values ('fw1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric-Guillaume Ier « le Roi-Sergent »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Friedrich_Wilhelm_I_1713.jpg/330px-Friedrich_Wilhelm_I_1713.jpg', 1688, 1740, 'Roi en Prusse', 'Maison de Hohenzollern', 450, 5040, admin_id, false from _m where code = 'fw1';
  insert into _m(code) values ('f2pr');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric II « le Grand »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Friedrich_Zweite_Alt.jpg/330px-Friedrich_Zweite_Alt.jpg', 1712, 1786, 'Roi de Prusse', 'Maison de Hohenzollern', 0, 5460, admin_id, false from _m where code = 'f2pr';
  insert into _m(code) values ('aw');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Auguste-Guillaume de Prusse', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/August_Wilhelm_%281722-58%29%2C_prins_van_Pruisen_Rijksmuseum_SK-A-886.jpeg/330px-August_Wilhelm_%281722-58%29%2C_prins_van_Pruisen_Rijksmuseum_SK-A-886.jpeg', 1722, 1758, 'Prince de Prusse', 'Maison de Hohenzollern', 900, 5460, admin_id, false from _m where code = 'aw';
  insert into _m(code) values ('fw2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric-Guillaume II', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Anton_Graff_-_Frederick_William_II_of_Prussia.png/330px-Anton_Graff_-_Frederick_William_II_of_Prussia.png', 1744, 1797, 'Roi de Prusse', 'Maison de Hohenzollern', 900, 5880, admin_id, false from _m where code = 'fw2';
  insert into _m(code) values ('fhd');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédérique-Louise de Hesse-Darmstadt', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Friederike_Luise_von_Hessen-Darmstadt_%28Therbusch%29_crop.jpg/330px-Friederike_Luise_von_Hessen-Darmstadt_%28Therbusch%29_crop.jpg', 1751, 1805, 'Reine de Prusse', 'Hesse-Darmstadt / Hohenzollern', 1350, 5880, admin_id, false from _m where code = 'fhd';
  insert into _m(code) values ('fw3');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric-Guillaume III', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Friedrich_Wilhelm_III.%2C_K%C3%B6nig_von_Preu%C3%9Fen_%28unbekannter_Maler%29.jpg/330px-Friedrich_Wilhelm_III.%2C_K%C3%B6nig_von_Preu%C3%9Fen_%28unbekannter_Maler%29.jpg', 1770, 1840, 'Roi de Prusse', 'Maison de Hohenzollern', 900, 6300, admin_id, false from _m where code = 'fw3';
  insert into _m(code) values ('louise');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Louise de Mecklembourg-Strelitz', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Grassi%2C_Josef_Mathias_-_Luise_von_Mecklenburg-Strelitz.jpg/330px-Grassi%2C_Josef_Mathias_-_Luise_von_Mecklenburg-Strelitz.jpg', 1776, 1810, 'Reine de Prusse', 'Mecklembourg-Strelitz / Hohenzollern', 1350, 6300, admin_id, false from _m where code = 'louise';
  insert into _m(code) values ('fw4');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric-Guillaume IV', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/FWIV.jpg/330px-FWIV.jpg', 1795, 1861, 'Roi de Prusse', 'Maison de Hohenzollern', 450, 6720, admin_id, false from _m where code = 'fw4';
  insert into _m(code) values ('g1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Guillaume Ier', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/B%C3%BClow%2C_Hans_-_Emperor_Wilhelm_I_-_Marburg.jpg/330px-B%C3%BClow%2C_Hans_-_Emperor_Wilhelm_I_-_Marburg.jpg', 1797, 1888, 'Roi de Prusse (1861), 1er empereur allemand (1871)', 'Maison de Hohenzollern', 1350, 6720, admin_id, true from _m where code = 'g1';
  insert into _m(code) values ('f3');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Frédéric III', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Bundesarchiv_Bild_146-2004-0099%2C_Kaiser_Friedrich_III..jpg/330px-Bundesarchiv_Bild_146-2004-0099%2C_Kaiser_Friedrich_III..jpg', 1831, 1888, 'Empereur allemand et roi de Prusse (1888)', 'Maison de Hohenzollern', 1350, 7140, admin_id, true from _m where code = 'f3';
  insert into _m(code) values ('g2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Guillaume II', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Kaiser_Wilhelm_II_of_Germany_-_1902.jpg/330px-Kaiser_Wilhelm_II_of_Germany_-_1902.jpg', 1859, 1941, 'Empereur allemand et roi de Prusse (1888-1918)', 'Maison de Hohenzollern', 1350, 7560, admin_id, true from _m where code = 'g2';
  insert into _m(code) values ('avic');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Augusta-Victoria de Schleswig-Holstein', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Bundesarchiv_Bild_102-01286%2C_Kaiserin_Auguste_Viktoria.jpg/330px-Bundesarchiv_Bild_102-01286%2C_Kaiserin_Auguste_Viktoria.jpg', 1858, 1921, 'Impératrice allemande et reine de Prusse', 'Schleswig-Holstein-Augustenbourg / Hohenzollern', 1800, 7560, admin_id, false from _m where code = 'avic';
  insert into _m(code) values ('kp');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Guillaume de Prusse (Kronprinz)', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Kronprinz_Wilhelm_1._Leib-Husarenregiment.jpg/330px-Kronprinz_Wilhelm_1._Leib-Husarenregiment.jpg', 1882, 1951, 'Prince héritier de l''Empire allemand et de Prusse', 'Maison de Hohenzollern', 1350, 7980, admin_id, false from _m where code = 'kp';
  insert into _m(code) values ('cec');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Cécilie de Mecklembourg-Schwerin', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Cecilie_of_Mecklenburg-Schwerin_Crown_Princess_of_Germany_and_Prussia.jpg/330px-Cecilie_of_Mecklenburg-Schwerin_Crown_Princess_of_Germany_and_Prussia.jpg', 1886, 1954, 'Princesse héritière d''Allemagne et de Prusse', 'Mecklembourg-Schwerin / Hohenzollern', 1800, 7980, admin_id, false from _m where code = 'cec';
  insert into _m(code) values ('msbay');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Madeleine-Sibylle de Brandebourg-Bayreuth', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Magdalena_Sibylla_von_Brandenburg-Bayreuth%2C_Kurf%C3%BCrstin_von_Sachsen.png/330px-Magdalena_Sibylla_von_Brandenburg-Bayreuth%2C_Kurf%C3%BCrstin_von_Sachsen.png', 1612, 1687, 'Électrice de Saxe', 'Maison de Hohenzollern', -1100, 3360, admin_id, false from _m where code = 'msbay';
  insert into _m(code) values ('chri');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_hoh::text, 'Christiane-Éberhardine de Brandebourg-Bayreuth', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Christiane_Eberhardine_von_Brandenburg-Bayreuth.PNG/330px-Christiane_Eberhardine_von_Brandenburg-Bayreuth.PNG', 1671, 1727, 'Reine de Pologne, électrice de Saxe', 'Maison de Hohenzollern', -1100, 3780, admin_id, false from _m where code = 'chri';
  insert into _m(code) values ('mathb');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Mathilde de Bavière', null, 1313, 1346, 'Margravine de Misnie', 'Wittelsbach', 6400, 0, admin_id, false from _m where code = 'mathb';
  insert into _m(code) values ('elbl');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Élisabeth de Bavière-Landshut', 'https://upload.wikimedia.org/wikipedia/commons/6/62/Elisabeth_von_Bayern-Landshut.jpg', 1383, 1442, 'Burgravine de Nuremberg, électrice de Brandebourg', 'Wittelsbach', 6400, 420, admin_id, false from _m where code = 'elbl';
  insert into _m(code) values ('elb43');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Élisabeth de Bavière', null, 1443, 1484, 'Électrice de Saxe', 'Wittelsbach', 6400, 840, admin_id, false from _m where code = 'elb43';
  insert into _m(code) values ('elcpal');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Élisabeth-Charlotte du Palatinat', 'https://upload.wikimedia.org/wikipedia/commons/3/36/Elizabeth_Charlotte_of_the_Palatinate.jpg', 1597, 1660, 'Électrice de Brandebourg', 'Wittelsbach', 6400, 1260, admin_id, false from _m where code = 'elcpal';
  insert into _m(code) values ('amdp');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Amélie de Deux-Ponts-Birkenfeld', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Brandt_Maria_Amalie_Auguste.jpg/330px-Brandt_Maria_Amalie_Auguste.jpg', 1752, 1828, 'Reine de Saxe', 'Wittelsbach', 6400, 1680, admin_id, false from _m where code = 'amdp';
  insert into _m(code) values ('mab');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Marie-Antoinette de Bavière', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Maria_Antonia_Walpurgis_von_Bayern%2C_Mengs%2C_1752.jpg/330px-Maria_Antonia_Walpurgis_von_Bayern%2C_Mengs%2C_1752.jpg', 1724, 1780, 'Électrice de Saxe', 'Wittelsbach', 6400, 2100, admin_id, false from _m where code = 'mab';
  insert into _m(code) values ('amb');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Amélie de Bavière', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Stieler_-_Amalie_Auguste_of_Bavaria_-_Galerie_Neue_Meister.jpg/330px-Stieler_-_Amalie_Auguste_of_Bavaria_-_Galerie_Neue_Meister.jpg', 1801, 1877, 'Reine de Saxe', 'Wittelsbach', 6400, 2520, admin_id, false from _m where code = 'amb';
  insert into _m(code) values ('elb01');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Élisabeth-Louise de Bavière', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Elisabet_%281801-1873%29%2C_drottning_av_Preussen.jpg/330px-Elisabet_%281801-1873%29%2C_drottning_av_Preussen.jpg', 1801, 1873, 'Reine de Prusse', 'Wittelsbach', 6400, 2940, admin_id, false from _m where code = 'elb01';
  insert into _m(code) values ('margaut');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '6b34bc03-d0ad-4c48-a485-f541cecafd5d', 'Marguerite d''Autriche', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Margaretha_von_Habsburg%2C_duchess_of_Saxony.jpg/330px-Margaretha_von_Habsburg%2C_duchess_of_Saxony.jpg', 1416, 1486, 'Électrice de Saxe', 'Habsbourg', 10800, 0, admin_id, false from _m where code = 'margaut';
  insert into _m(code) values ('lt');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '6b34bc03-d0ad-4c48-a485-f541cecafd5d', 'Louise-Antoinette de Habsbourg-Toscane', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Luise_von_Toskana.jpg/330px-Luise_von_Toskana.jpg', 1870, 1947, 'Princesse héritière puis reine consort de Saxe (divorcée en 1903)', 'Habsbourg-Toscane', 10800, 420, admin_id, false from _m where code = 'lt';
  insert into _m(code) values ('margsic');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '19aed0d5-8c4a-4125-b821-8fc6bc357dab', 'Marguerite de Sicile', 'https://upload.wikimedia.org/wikipedia/commons/7/7d/MarketaStaufska.jpg', 1241, 1270, 'Landgravine de Thuringe, margravine de Misnie', 'Hohenstaufen', 2500, 0, admin_id, false from _m where code = 'margsic';
  insert into _m(code) values ('cathbr');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'db5ef554-cbb9-448f-89fa-b656bf1d1147', 'Catherine de Brunswick-Lunebourg', 'https://upload.wikimedia.org/wikipedia/commons/d/d0/Catherine%2C_electress_of_Saxony.jpg', 1395, 1442, 'Électrice de Saxe', 'Welf', 2700, 0, admin_id, false from _m where code = 'cathbr';
  insert into _m(code) values ('abb');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'db5ef554-cbb9-448f-89fa-b656bf1d1147', 'Anne-Marie de Brunswick-Calenberg-Göttingen', 'https://upload.wikimedia.org/wikipedia/commons/0/08/Anna_Maria_of_Brunswick-L%C3%BCneburg.png', 1532, 1568, 'Duchesse de Prusse', 'Welf', 2700, 420, admin_id, false from _m where code = 'abb';
  insert into _m(code) values ('lbw');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'db5ef554-cbb9-448f-89fa-b656bf1d1147', 'Louise-Amélie de Brunswick-Wolfenbüttel', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Pesne_-_Louise_Amalie_of_Brunswick-Wolfenb%C3%BCttel_-_Neues_Palais%2C_cropped.png/330px-Pesne_-_Louise_Amalie_of_Brunswick-Wolfenb%C3%BCttel_-_Neues_Palais%2C_cropped.png', 1722, 1780, 'Princesse de Prusse', 'Welf', 2700, 840, admin_id, false from _m where code = 'lbw';
  insert into _m(code) values ('ecb');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'db5ef554-cbb9-448f-89fa-b656bf1d1147', 'Élisabeth-Christine de Brunswick-Wolfenbüttel-Bevern', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Koningin_elisabeth_christine.jpg/330px-Koningin_elisabeth_christine.jpg', 1715, 1797, 'Reine de Prusse', 'Welf', 2700, 1260, admin_id, false from _m where code = 'ecb';
  insert into _m(code) values ('eldk');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Élisabeth de Danemark', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Elisabeth_von_D%C3%A4nemark%2C_Kurf%C3%BCrstin_von_Brandenburg.jpg/330px-Elisabeth_von_D%C3%A4nemark%2C_Kurf%C3%BCrstin_von_Brandenburg.jpg', 1485, 1555, 'Électrice de Brandebourg', 'Maison d''Oldenbourg', 2800, 0, admin_id, false from _m where code = 'eldk';
  insert into _m(code) values ('dorodk');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Dorothée de Danemark', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Prinsesse_Dorothea_%281504-1547%29.jpg/330px-Prinsesse_Dorothea_%281504-1547%29.jpg', 1504, 1547, 'Duchesse de Prusse', 'Maison d''Oldenbourg', 2800, 420, admin_id, false from _m where code = 'dorodk';
  insert into _m(code) values ('annedk');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Anne de Danemark', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Saxonia_Museum_fuer_saechsische_Vaterlandskunde_III_44.jpg/330px-Saxonia_Museum_fuer_saechsische_Vaterlandskunde_III_44.jpg', 1532, 1585, 'Électrice de Saxe', 'Maison d''Oldenbourg', 2800, 840, admin_id, false from _m where code = 'annedk';
  insert into _m(code) values ('hdk');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Hedwige de Danemark', 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/Prinsesse_Hedevig_%281581-1641%29.jpg/330px-Prinsesse_Hedevig_%281581-1641%29.jpg', 1581, 1641, 'Électrice de Saxe', 'Maison d''Oldenbourg', 2800, 1260, admin_id, false from _m where code = 'hdk';
  insert into _m(code) values ('asdk');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Anne-Sophie de Danemark', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Anna_Sophie_of_Denmark_electress_of_Saxony.jpg/330px-Anna_Sophie_of_Denmark_electress_of_Saxony.jpg', 1647, 1717, 'Électrice de Saxe', 'Maison d''Oldenbourg', 2800, 1680, admin_id, false from _m where code = 'asdk';
  insert into _m(code) values ('sophjag');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '2330c043-bc06-4464-92c0-dbc885739729', 'Sophie Jagellon', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Sophia_von_Polen.jpg/330px-Sophia_von_Polen.jpg', 1464, 1512, 'Margravine de Brandebourg-Ansbach', 'Jagellon', 1100, 0, admin_id, false from _m where code = 'sophjag';
  insert into _m(code) values ('barbej');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '2330c043-bc06-4464-92c0-dbc885739729', 'Barbara Jagellon', 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Lucas_Cranach_d.%C3%84._-_Bildnis_Barbara_von_Sachsen_%28Gem%C3%A4ldegalerie%2C_Berlin%29.jpg/330px-Lucas_Cranach_d.%C3%84._-_Bildnis_Barbara_von_Sachsen_%28Gem%C3%A4ldegalerie%2C_Berlin%29.jpg', 1478, 1534, 'Duchesse de Saxe', 'Jagellon', 1100, 420, admin_id, false from _m where code = 'barbej';
  insert into _m(code) values ('hedj');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '2330c043-bc06-4464-92c0-dbc885739729', 'Hedwige Jagellon', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Jadwiga_Jagiellonka.jpg/330px-Jadwiga_Jagiellonka.jpg', 1513, 1573, 'Électrice de Brandebourg', 'Jagellon', 1100, 840, admin_id, false from _m where code = 'hedj';
  insert into _m(code) values ('lhor');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '7733ccfd-7fea-44af-9339-713120d3bbf2', 'Louise-Henriette d''Orange-Nassau', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Louisehenriettevannassau.jpg/330px-Louisehenriettevannassau.jpg', 1627, 1667, 'Électrice de Brandebourg', 'Maison d''Orange-Nassau', 900, 0, admin_id, false from _m where code = 'lhor';
  insert into _m(code) values ('scha');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'a874f93b-cfe3-4fae-ae11-a8e7493b5cf1', 'Sophie-Charlotte de Hanovre', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Sophie_Charlotte_von_Hannover.jpg/330px-Sophie_Charlotte_von_Hannover.jpg', 1668, 1705, 'Reine en Prusse', 'Maison de Hanovre', 3200, 0, admin_id, false from _m where code = 'scha';
  insert into _m(code) values ('sdh');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'a874f93b-cfe3-4fae-ae11-a8e7493b5cf1', 'Sophie-Dorothée de Hanovre', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Queen_Sophie_Dorothea_of_Prussia.jpg/330px-Queen_Sophie_Dorothea_of_Prussia.jpg', 1687, 1757, 'Reine en Prusse', 'Maison de Hanovre', 3200, 420, admin_id, false from _m where code = 'sdh';
  insert into _m(code) values ('vicky');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'eb82350b-5e34-490e-bb73-9235d4baf763', 'Victoria du Royaume-Uni (princesse royale)', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Vit%C3%B3ria%2C_Imperatriz-vi%C3%BAva_da_Alemanha.jpg/330px-Vit%C3%B3ria%2C_Imperatriz-vi%C3%BAva_da_Alemanha.jpg', 1840, 1901, 'Impératrice allemande et reine de Prusse (1888)', 'Maison de Saxe-Cobourg et Gotha', 4000, 0, admin_id, false from _m where code = 'vicky';
  insert into _m(code) values ('cbp');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '84c9f117-4375-499a-8634-b87e7515ec6a', 'Caroline de Bourbon-Parme', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Caroline_of_Parma%2C_hereditary_princess_of_Saxony.jpg/330px-Caroline_of_Parma%2C_hereditary_princess_of_Saxony.jpg', 1770, 1804, 'Princesse de Saxe', 'Maison de Bourbon-Parme', 1500, 0, admin_id, false from _m where code = 'cbp';
  insert into _m(code) values ('mapor');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '14db1138-55b4-48b7-b4de-c79e51127284', 'Marie-Anne de Portugal', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/MariaAnnasaxe.jpg/330px-MariaAnnasaxe.jpg', 1843, 1884, 'Reine de Saxe', 'Maison de Bragance', 3000, 0, admin_id, false from _m where code = 'mapor';

  create function pg_temp.ext(prefix text) returns uuid language plpgsql as $f$
  declare r uuid; k int;
  begin
    select count(*) into k from public.genealogy_members where id::text like prefix || '%';
    if k <> 1 then raise exception 'Membre existant introuvable ou ambigu : % (% résultats)', prefix, k; end if;
    select id into r from public.genealogy_members where id::text like prefix || '%';
    return r;
  end $f$;
  create function pg_temp.res(c text) returns uuid language plpgsql as $f$
  declare r uuid;
  begin
    if c like 'x:%' then return pg_temp.ext(substr(c, 3)); end if;
    select id into r from _m where code = c;
    if r is null then raise exception 'Code inconnu : %', c; end if;
    return r;
  end $f$;

  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('conrad'), pg_temp.res('otto'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('otto'), pg_temp.res('hedw'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('otto'), pg_temp.res('albert1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('hedw'), pg_temp.res('albert1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('otto'), pg_temp.res('thierry'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('hedw'), pg_temp.res('thierry'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('thierry'), pg_temp.res('jutta'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('thierry'), pg_temp.res('henri3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jutta'), pg_temp.res('henri3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('henri3'), pg_temp.res('constance'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('henri3'), pg_temp.res('albert2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('constance'), pg_temp.res('albert2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albert2'), pg_temp.res('margsic'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albert2'), pg_temp.res('fred1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('margsic'), pg_temp.res('fred1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:df121566'), pg_temp.res('margsic'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fred1'), pg_temp.res('elob'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fred1'), pg_temp.res('fred2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('elob'), pg_temp.res('fred2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fred2'), pg_temp.res('mathb'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:32744ff5'), pg_temp.res('mathb'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fred2'), pg_temp.res('fred3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mathb'), pg_temp.res('fred3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fred2'), pg_temp.res('elmis'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mathb'), pg_temp.res('elmis'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fred3'), pg_temp.res('cathhen'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fred3'), pg_temp.res('fredb'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('cathhen'), pg_temp.res('fredb'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fredb'), pg_temp.res('cathbr'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fredb'), pg_temp.res('fredd'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('cathbr'), pg_temp.res('fredd'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fredb'), pg_temp.res('cathsax'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('cathbr'), pg_temp.res('cathsax'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fredd'), pg_temp.res('margaut'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:2d92d33a'), pg_temp.res('margaut'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:caf9c57d'), pg_temp.res('margaut'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fredd'), pg_temp.res('ernest'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('margaut'), pg_temp.res('ernest'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fredd'), pg_temp.res('albertc'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('margaut'), pg_temp.res('albertc'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fredd'), pg_temp.res('anna'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('margaut'), pg_temp.res('anna'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ernest'), pg_temp.res('elb43'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:d01790e1'), pg_temp.res('elb43'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:e73c1296'), pg_temp.res('elb43'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ernest'), pg_temp.res('freds'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('elb43'), pg_temp.res('freds'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ernest'), pg_temp.res('jeanc'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('elb43'), pg_temp.res('jeanc'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ernest'), pg_temp.res('x:0c89f180'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('elb43'), pg_temp.res('x:0c89f180'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jeanc'), pg_temp.res('sophiem'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jeanc'), pg_temp.res('jf1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sophiem'), pg_temp.res('jf1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jf1'), pg_temp.res('sibylle'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jf1'), pg_temp.res('jguil'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sibylle'), pg_temp.res('jguil'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jguil'), pg_temp.res('jean2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jean2'), pg_temp.res('ernestp'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ernestp'), pg_temp.res('fgo1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ernestp'), pg_temp.res('jeanern'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fgo1'), pg_temp.res('fgo2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fgo2'), pg_temp.res('madaug'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fgo2'), pg_temp.res('x:9b566a15'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('madaug'), pg_temp.res('x:9b566a15'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jeanern'), pg_temp.res('fjos'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fjos'), pg_temp.res('efred'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('efred'), pg_temp.res('fran'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fran'), pg_temp.res('augreuss'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fran'), pg_temp.res('ernest1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('augreuss'), pg_temp.res('ernest1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fran'), pg_temp.res('x:a1f6258c'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('augreuss'), pg_temp.res('x:a1f6258c'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fran'), pg_temp.res('x:55c3b278'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('augreuss'), pg_temp.res('x:55c3b278'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ernest1'), pg_temp.res('louisegotha'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ernest1'), pg_temp.res('ernest2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('louisegotha'), pg_temp.res('ernest2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ernest1'), pg_temp.res('x:0d53db23'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('louisegotha'), pg_temp.res('x:0d53db23'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albertc'), pg_temp.res('sidonie'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albertc'), pg_temp.res('georges'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sidonie'), pg_temp.res('georges'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albertc'), pg_temp.res('henrip'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sidonie'), pg_temp.res('henrip'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('georges'), pg_temp.res('barbej'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('georges'), pg_temp.res('madsax'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('barbej'), pg_temp.res('madsax'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('henrip'), pg_temp.res('catm'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('henrip'), pg_temp.res('maurice'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('catm'), pg_temp.res('maurice'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('henrip'), pg_temp.res('auguste'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('catm'), pg_temp.res('auguste'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('maurice'), pg_temp.res('agnes'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('auguste'), pg_temp.res('annedk'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('auguste'), pg_temp.res('chr1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('annedk'), pg_temp.res('chr1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('chr1'), pg_temp.res('sophiebr'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('chr1'), pg_temp.res('chr2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sophiebr'), pg_temp.res('chr2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('chr1'), pg_temp.res('jg1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sophiebr'), pg_temp.res('jg1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('chr2'), pg_temp.res('hdk'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jg1'), pg_temp.res('msp'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jg1'), pg_temp.res('jg2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('msp'), pg_temp.res('jg2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jg2'), pg_temp.res('msbay'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jg2'), pg_temp.res('jg3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('msbay'), pg_temp.res('jg3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jg3'), pg_temp.res('asdk'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jg3'), pg_temp.res('jg4'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('asdk'), pg_temp.res('jg4'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jg3'), pg_temp.res('fa1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('asdk'), pg_temp.res('fa1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fa1'), pg_temp.res('chri'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fa1'), pg_temp.res('x:ae05a240'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('chri'), pg_temp.res('x:ae05a240'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:ae05a240'), pg_temp.res('fc'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:bb30cf99'), pg_temp.res('fc'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:ae05a240'), pg_temp.res('xav'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:bb30cf99'), pg_temp.res('xav'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:ae05a240'), pg_temp.res('x:a9d7aa31'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:bb30cf99'), pg_temp.res('x:a9d7aa31'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:ae05a240'), pg_temp.res('x:0cd7f2c2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:bb30cf99'), pg_temp.res('x:0cd7f2c2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fc'), pg_temp.res('mab'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:0ce70be1'), pg_temp.res('mab'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:975fb883'), pg_temp.res('mab'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fc'), pg_temp.res('fa3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mab'), pg_temp.res('fa3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fc'), pg_temp.res('antoine'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mab'), pg_temp.res('antoine'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fc'), pg_temp.res('maxs'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mab'), pg_temp.res('maxs'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fa3'), pg_temp.res('amdp'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('maxs'), pg_temp.res('cbp'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:9a0cd092'), pg_temp.res('cbp'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:2cb1bbdb'), pg_temp.res('cbp'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('maxs'), pg_temp.res('fa2k'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('cbp'), pg_temp.res('fa2k'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('maxs'), pg_temp.res('jeans'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('cbp'), pg_temp.res('jeans'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jeans'), pg_temp.res('amb'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:bb2ceff8'), pg_temp.res('amb'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jeans'), pg_temp.res('alberts'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('amb'), pg_temp.res('alberts'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jeans'), pg_temp.res('georgess'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('amb'), pg_temp.res('georgess'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('alberts'), pg_temp.res('carola'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('georgess'), pg_temp.res('mapor'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('georgess'), pg_temp.res('fa3k'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mapor'), pg_temp.res('fa3k'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fa3k'), pg_temp.res('lt'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f5'), pg_temp.res('elmis'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f5'), pg_temp.res('f6'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('elmis'), pg_temp.res('f6'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f5'), pg_temp.res('x:6a00a186'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('elmis'), pg_temp.res('x:6a00a186'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f6'), pg_temp.res('elbl'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f6'), pg_temp.res('f2b'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('elbl'), pg_temp.res('f2b'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f6'), pg_temp.res('albach'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('elbl'), pg_temp.res('albach'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f2b'), pg_temp.res('cathsax'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albach'), pg_temp.res('mbade'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albach'), pg_temp.res('anna'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albach'), pg_temp.res('jcic'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mbade'), pg_temp.res('jcic'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albach'), pg_temp.res('fansb'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('anna'), pg_temp.res('fansb'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fansb'), pg_temp.res('sophjag'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fansb'), pg_temp.res('albpr'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sophjag'), pg_temp.res('albpr'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albpr'), pg_temp.res('dorodk'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:7c5d6558'), pg_temp.res('dorodk'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:d62c9d39'), pg_temp.res('dorodk'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albpr'), pg_temp.res('abb'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albpr'), pg_temp.res('albfred'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('abb'), pg_temp.res('albfred'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albfred'), pg_temp.res('mecl'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albfred'), pg_temp.res('annepr'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mecl'), pg_temp.res('annepr'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('albfred'), pg_temp.res('msp'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mecl'), pg_temp.res('msp'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jcic'), pg_temp.res('mthur'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jcic'), pg_temp.res('j1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mthur'), pg_temp.res('j1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jcic'), pg_temp.res('x:d62c9d39'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mthur'), pg_temp.res('x:d62c9d39'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('j1'), pg_temp.res('eldk'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:7a0dd6cf'), pg_temp.res('eldk'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:0c89f180'), pg_temp.res('eldk'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('j1'), pg_temp.res('j2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('eldk'), pg_temp.res('j2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('j2'), pg_temp.res('madsax'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('j2'), pg_temp.res('hedj'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('j2'), pg_temp.res('jgeo'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('madsax'), pg_temp.res('jgeo'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jgeo'), pg_temp.res('sliegn'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jgeo'), pg_temp.res('sophiebr'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jgeo'), pg_temp.res('jfred'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sliegn'), pg_temp.res('jfred'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jfred'), pg_temp.res('ckus'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jfred'), pg_temp.res('jsig'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ckus'), pg_temp.res('jsig'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jfred'), pg_temp.res('x:bf1d098c'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ckus'), pg_temp.res('x:bf1d098c'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jsig'), pg_temp.res('annepr'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jsig'), pg_temp.res('gw'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('annepr'), pg_temp.res('gw'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('gw'), pg_temp.res('elcpal'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('gw'), pg_temp.res('ge'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('elcpal'), pg_temp.res('ge'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ge'), pg_temp.res('lhor'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ge'), pg_temp.res('f1pr'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('lhor'), pg_temp.res('f1pr'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f1pr'), pg_temp.res('scha'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:84913c2a'), pg_temp.res('scha'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:3e8ca0aa'), pg_temp.res('scha'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f1pr'), pg_temp.res('fw1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('scha'), pg_temp.res('fw1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fw1'), pg_temp.res('sdh'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:275a9db4'), pg_temp.res('sdh'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:659a9a00'), pg_temp.res('sdh'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fw1'), pg_temp.res('f2pr'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sdh'), pg_temp.res('f2pr'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fw1'), pg_temp.res('aw'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sdh'), pg_temp.res('aw'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f2pr'), pg_temp.res('ecb'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('aw'), pg_temp.res('lbw'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('aw'), pg_temp.res('fw2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('lbw'), pg_temp.res('fw2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fw2'), pg_temp.res('fhd'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fw2'), pg_temp.res('fw3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fhd'), pg_temp.res('fw3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fw3'), pg_temp.res('louise'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fw3'), pg_temp.res('fw4'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('louise'), pg_temp.res('fw4'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fw3'), pg_temp.res('g1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('louise'), pg_temp.res('g1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('fw4'), pg_temp.res('elb01'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('g1'), pg_temp.res('augweim'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('g1'), pg_temp.res('f3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('augweim'), pg_temp.res('f3'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f3'), pg_temp.res('vicky'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:0d53db23'), pg_temp.res('vicky'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:11b2db35'), pg_temp.res('vicky'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('f3'), pg_temp.res('g2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('vicky'), pg_temp.res('g2'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('g2'), pg_temp.res('avic'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('g2'), pg_temp.res('kp'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('avic'), pg_temp.res('kp'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('kp'), pg_temp.res('cec'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:555a36dc'), pg_temp.res('asdk'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:9cf848f8'), pg_temp.res('asdk'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:cc9ca1f6'), pg_temp.res('annedk'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:8a2b6b83'), pg_temp.res('annedk'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:d5423c1a'), pg_temp.res('hdk'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:2e636bc1'), pg_temp.res('hdk'), 'parent', admin_id);

  raise notice 'Arbres Wettin et Hohenzollern créés : % membres, % liens.', (select count(*) from _m), 259;
end $$;
