-- schema_v32.sql — Arbre généalogique « Luxembourg » (dynasties allemandes)
-- À lancer dans le SQL Editor de Supabase (une seule fois). Rien n'est supprimé ni modifié :
-- il ne fait QUE des ajouts (1 arbre, ses membres, et quelques membres dans les arbres d'origine
-- des épouses : Valois, Wittelsbach, Přemyslides), plus les liens.
-- Les membres déjà présents dans tes autres arbres (Charles IV le Bel, Bonne de Luxembourg,
-- Richard II, Albert II, etc.) sont RETROUVÉS par leur identifiant et reliés, jamais recréés.
-- Si un identifiant n'est pas trouvé, le script s'arrête sans rien écrire.

do $$
declare
  admin_id constant uuid := '96d2f891-6b9e-4967-89ed-18f83270ef28';
  sec_id constant uuid := '9925f2fb-baee-4d72-a995-813386f58598';  -- Allemagne > Dynastie > Luxembourg
  cat_id constant uuid := '428a2e75-c8e3-51a1-b12a-bfe7a4018659';
  tree_id uuid;
begin
  if exists (select 1 from public.dossier_entries where section_id = sec_id and type = 'genealogy') then
    raise exception 'Un arbre existe déjà dans la sous-catégorie Luxembourg (Allemagne) : rien n''a été fait.';
  end if;

  insert into public.dossier_entries (owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('country', 'DEU', 'genealogy', 'Luxembourg', cat_id, sec_id, admin_id)
  returning id into tree_id;

  create temp table _m (code text primary key, id uuid not null default gen_random_uuid()) on commit drop;

  insert into _m(code) values ('h6');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Henri VI de Luxembourg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Hendrik_VI_van_Luxemburg.jpg/330px-Hendrik_VI_van_Luxemburg.jpg', 1240, 1288, 'Comte de Luxembourg', 'Maison de Luxembourg', 0, 0, admin_id, false from _m where code = 'h6';
  insert into _m(code) values ('beav');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Béatrice d''Avesnes', null, null, 1321, 'Comtesse de Luxembourg', 'Avesnes / Luxembourg', 400, 0, admin_id, false from _m where code = 'beav';
  insert into _m(code) values ('baud');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Baudouin de Luxembourg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Ausschnitt_Codex_Balduini_Trevi.jpg/330px-Ausschnitt_Codex_Balduini_Trevi.jpg', 1285, 1354, 'Archevêque-électeur de Trèves', 'Maison de Luxembourg', -500, 420, admin_id, false from _m where code = 'baud';
  insert into _m(code) values ('h7');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Henri VII de Luxembourg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Henry_Lux.jpg/330px-Henry_Lux.jpg', 1275, 1313, 'Roi des Romains, Empereur du Saint-Empire', 'Maison de Luxembourg', 0, 420, admin_id, true from _m where code = 'h7';
  insert into _m(code) values ('mbra');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Marguerite de Brabant', null, 1276, 1311, 'Reine de Germanie', 'Brabant / Luxembourg', 400, 420, admin_id, false from _m where code = 'mbra';
  insert into _m(code) values ('marie');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Marie de Luxembourg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/01/Mariage_de_Charles_IV_le_Bel_et_de_Marie_de_Luxembourg.jpg/330px-Mariage_de_Charles_IV_le_Bel_et_de_Marie_de_Luxembourg.jpg', 1305, 1324, 'Reine de France et de Navarre', 'Maison de Luxembourg', -500, 840, admin_id, false from _m where code = 'marie';
  insert into _m(code) values ('jean');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Jean l''Aveugle', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/01/Jean_de_Luxemembourg%2C_Roi_de_Boheme_dit_%22l%27Aveugle%22.png/330px-Jean_de_Luxemembourg%2C_Roi_de_Boheme_dit_%22l%27Aveugle%22.png', 1296, 1346, 'Roi de Bohême, comte de Luxembourg', 'Maison de Luxembourg', 400, 840, admin_id, false from _m where code = 'jean';
  insert into _m(code) values ('bbou');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Béatrice de Bourbon', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Beatrycze.jpg/330px-Beatrycze.jpg', 1320, 1383, 'Reine de Bohême', 'Bourbon / Luxembourg', 1200, 840, admin_id, false from _m where code = 'bbou';
  insert into _m(code) values ('jhen');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Jean-Henri de Moravie', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/JanJindra.jpg/330px-JanJindra.jpg', 1322, 1375, 'Margrave de Moravie, comte de Tyrol', 'Maison de Luxembourg', -2150, 1260, admin_id, false from _m where code = 'jhen';
  insert into _m(code) values ('mopa');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Marguerite d''Opava', null, 1330, 1363, 'Margravine de Moravie', 'Přemyslides d''Opava / Luxembourg', -2650, 1260, admin_id, false from _m where code = 'mopa';
  insert into _m(code) values ('c4');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Charles IV', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Charles_IV-John_Ocko_votive_picture-fragment.jpg/330px-Charles_IV-John_Ocko_votive_picture-fragment.jpg', 1316, 1378, 'Roi de Bohême, Roi des Romains, Empereur du Saint-Empire', 'Maison de Luxembourg', 400, 1260, admin_id, true from _m where code = 'c4';
  insert into _m(code) values ('asch');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Anne de Schweidnitz', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Busta_Anna_Svidnicka.jpg/330px-Busta_Anna_Svidnicka.jpg', 1339, 1362, 'Reine de Bohême, Reine de Germanie, Impératrice du Saint-Empire', 'Piast de Schweidnitz / Luxembourg', 900, 1260, admin_id, false from _m where code = 'asch';
  insert into _m(code) values ('epom');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Élisabeth de Poméranie', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Busta_Alzbeta_Pomoranska.jpg/330px-Busta_Alzbeta_Pomoranska.jpg', 1347, 1393, 'Impératrice du Saint-Empire, Reine de Bohême', 'Poméranie / Luxembourg', 1400, 1260, admin_id, false from _m where code = 'epom';
  insert into _m(code) values ('w1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Wenceslas Ier de Luxembourg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Wenceslaus_of_Luxembourg.jpg/330px-Wenceslaus_of_Luxembourg.jpg', 1337, 1383, 'Duc de Luxembourg, de Brabant et de Limbourg', 'Maison de Luxembourg', 2600, 1260, admin_id, false from _m where code = 'w1';
  insert into _m(code) values ('jbra');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Jeanne de Brabant', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/JohannavanBrabant.jpg/330px-JohannavanBrabant.jpg', 1322, 1406, 'Duchesse de Brabant et de Limbourg', 'Brabant / Luxembourg', 3100, 1260, admin_id, false from _m where code = 'jbra';
  insert into _m(code) values ('jobst');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Jobst de Moravie', 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Jo%C5%A1t_Lucembursk%C3%BD.jpg/330px-Jo%C5%A1t_Lucembursk%C3%BD.jpg', 1351, 1411, 'Margrave de Moravie et de Brandebourg, Roi des Romains (élu en 1410)', 'Maison de Luxembourg', -2400, 1680, admin_id, true from _m where code = 'jobst';
  insert into _m(code) values ('proc');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Procope de Moravie', null, 1355, 1405, 'Margrave de Moravie', 'Maison de Luxembourg', -1900, 1680, admin_id, false from _m where code = 'proc';
  insert into _m(code) values ('e58');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Élisabeth de Bohême', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Elisabeth_of_Bohemia%2C_wife_of_Albert_III_of_Austria.jpg/330px-Elisabeth_of_Bohemia%2C_wife_of_Albert_III_of_Austria.jpg', 1358, 1373, 'Duchesse d''Autriche', 'Maison de Luxembourg', -1400, 1680, admin_id, false from _m where code = 'e58';
  insert into _m(code) values ('a66');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Anne de Bohême', 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Richard2_Anna.jpg/330px-Richard2_Anna.jpg', 1366, 1394, 'Reine d''Angleterre', 'Maison de Luxembourg', -900, 1680, admin_id, false from _m where code = 'a66';
  insert into _m(code) values ('w4');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Wenceslas IV', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Vasikzfrkronik.jpg/330px-Vasikzfrkronik.jpg', 1361, 1419, 'Roi de Bohême, Roi des Romains (déposé en 1400)', 'Maison de Luxembourg', -400, 1680, admin_id, true from _m where code = 'w4';
  insert into _m(code) values ('sig');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Sigismond', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Pisanello_024b.jpg/330px-Pisanello_024b.jpg', 1368, 1437, 'Roi de Hongrie, Roi des Romains, Roi de Bohême, Empereur du Saint-Empire', 'Maison de Luxembourg', 400, 1680, admin_id, true from _m where code = 'sig';
  insert into _m(code) values ('mhon');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Marie d''Anjou-Hongrie', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/M%C3%A1ria_Thur%C3%B3czy.jpg/330px-M%C3%A1ria_Thur%C3%B3czy.jpg', 1371, 1395, 'Reine de Hongrie', 'Anjou-Hongrie / Luxembourg', 900, 1680, admin_id, false from _m where code = 'mhon';
  insert into _m(code) values ('barb');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Barbe de Cilli', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Barbara_of_Celje_-_Meister_der_Chronik_des_Konzils_von_Konstanz_001.jpg/330px-Barbara_of_Celje_-_Meister_der_Chronik_des_Konzils_von_Konstanz_001.jpg', 1392, 1451, 'Impératrice du Saint-Empire, Reine de Germanie, de Hongrie et de Bohême', 'Cilli / Luxembourg', 1400, 1680, admin_id, false from _m where code = 'barb';
  insert into _m(code) values ('jgor');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Jean de Görlitz', null, 1370, 1396, 'Duc de Görlitz', 'Maison de Luxembourg', 2200, 1680, admin_id, false from _m where code = 'jgor';
  insert into _m(code) values ('rmec');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Richarde-Catherine de Mecklembourg', null, null, null, 'Duchesse de Görlitz', 'Mecklembourg / Luxembourg', 2700, 1680, admin_id, false from _m where code = 'rmec';
  insert into _m(code) values ('e09');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Élisabeth de Luxembourg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/AlzbetaLuc.jpg/330px-AlzbetaLuc.jpg', 1409, 1442, 'Reine de Germanie, de Hongrie et de Bohême', 'Maison de Luxembourg', 900, 2100, admin_id, false from _m where code = 'e09';
  insert into _m(code) values ('egor');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_id::text, 'Élisabeth de Görlitz', 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Elisabeth_von_G%C3%B6rlitz.png/330px-Elisabeth_von_G%C3%B6rlitz.png', 1390, 1451, 'Duchesse de Luxembourg', 'Maison de Luxembourg', 2450, 2100, admin_id, false from _m where code = 'egor';
  insert into _m(code) values ('blan');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'a92b4627-d9e5-4325-81ed-8b3dfebacf5b', 'Blanche de Valois', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Karl_IV_Blanca_Valois.jpg/330px-Karl_IV_Blanca_Valois.jpg', 1317, 1348, 'Reine de Bohême', 'Valois', 3800, 4200, admin_id, false from _m where code = 'blan';
  insert into _m(code) values ('apal');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Anne du Palatinat', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Busta_Anna_Falck%C3%A1.jpg/330px-Busta_Anna_Falck%C3%A1.jpg', 1329, 1353, 'Reine de Germanie et de Bohême', 'de Wittelsbach', 5400, 9000, admin_id, false from _m where code = 'apal';
  insert into _m(code) values ('jbav');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Jeanne de Bavière', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Joanna_of_Bavaria.jpg/330px-Joanna_of_Bavaria.jpg', 1362, 1386, 'Reine de Germanie et de Bohême', 'de Wittelsbach', 5400, 9500, admin_id, false from _m where code = 'jbav';
  insert into _m(code) values ('soph');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Sophie de Bavière', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/VaclavaZofie.jpg/330px-VaclavaZofie.jpg', 1376, 1428, 'Reine de Germanie et de Bohême', 'de Wittelsbach', 5400, 10000, admin_id, false from _m where code = 'soph';
  insert into _m(code) values ('ebo');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'b53dda9c-6240-43c2-8503-91cda7693dd1', 'Élisabeth de Bohême', null, 1292, 1330, 'Reine de Bohême, comtesse de Luxembourg', 'Přemyslides / Luxembourg', 400, 5880, admin_id, false from _m where code = 'ebo';

  -- Retrouve un membre déjà existant (autre arbre) par le début de son identifiant.
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

  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('h6'), pg_temp.res('h7'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('beav'), pg_temp.res('h7'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('h6'), pg_temp.res('baud'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('beav'), pg_temp.res('baud'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('h6'), pg_temp.res('beav'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('h7'), pg_temp.res('mbra'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('h7'), pg_temp.res('jean'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mbra'), pg_temp.res('jean'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('h7'), pg_temp.res('marie'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mbra'), pg_temp.res('marie'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jean'), pg_temp.res('ebo'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jean'), pg_temp.res('bbou'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jean'), pg_temp.res('c4'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ebo'), pg_temp.res('c4'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jean'), pg_temp.res('jhen'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ebo'), pg_temp.res('jhen'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jean'), pg_temp.res('w1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('bbou'), pg_temp.res('w1'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jean'), pg_temp.res('x:6cd952e4'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ebo'), pg_temp.res('x:6cd952e4'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jean'), pg_temp.res('x:907a4463'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('ebo'), pg_temp.res('x:907a4463'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:59b7e461'), pg_temp.res('ebo'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:9269a040'), pg_temp.res('marie'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jhen'), pg_temp.res('x:520b2098'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jhen'), pg_temp.res('mopa'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jhen'), pg_temp.res('x:3704d557'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jhen'), pg_temp.res('jobst'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mopa'), pg_temp.res('jobst'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jhen'), pg_temp.res('proc'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('mopa'), pg_temp.res('proc'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('w1'), pg_temp.res('jbra'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('c4'), pg_temp.res('blan'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('c4'), pg_temp.res('apal'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('c4'), pg_temp.res('asch'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('c4'), pg_temp.res('epom'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:7c52a8e5'), pg_temp.res('blan'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('c4'), pg_temp.res('x:eb64fd92'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('blan'), pg_temp.res('x:eb64fd92'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('c4'), pg_temp.res('e58'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('asch'), pg_temp.res('e58'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('e58'), pg_temp.res('x:de98029d'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('c4'), pg_temp.res('w4'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('asch'), pg_temp.res('w4'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('w4'), pg_temp.res('jbav'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('w4'), pg_temp.res('soph'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:200c824a'), pg_temp.res('jbav'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('x:6f923d08'), pg_temp.res('soph'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('c4'), pg_temp.res('a66'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('epom'), pg_temp.res('a66'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('a66'), pg_temp.res('x:21731a19'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('c4'), pg_temp.res('sig'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('epom'), pg_temp.res('sig'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sig'), pg_temp.res('mhon'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sig'), pg_temp.res('barb'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('c4'), pg_temp.res('jgor'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('epom'), pg_temp.res('jgor'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jgor'), pg_temp.res('rmec'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('sig'), pg_temp.res('e09'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('barb'), pg_temp.res('e09'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('e09'), pg_temp.res('x:ec151f43'), 'spouse', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('jgor'), pg_temp.res('egor'), 'parent', admin_id);
  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (pg_temp.res('rmec'), pg_temp.res('egor'), 'parent', admin_id);

  raise notice 'Arbre Luxembourg créé : % membres, % liens.', (select count(*) from _m), 63;
end $$;
