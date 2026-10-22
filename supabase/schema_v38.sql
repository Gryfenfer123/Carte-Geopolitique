-- schema_v38.sql — Branche ernestine des Wettin, d'après l'affiche « German Royal Family Tree » (demande de Martin, 2026-10-22).
-- Ajoute (rien n'est supprimé ni modifié) :
--  * ~25 membres dans l'arbre Wettin (Allemagne) : de Jean-Guillaume de Saxe-Weimar jusqu'à Charles-Édouard, dernier duc de Saxe-Cobourg et Gotha,
--    avec leurs épouses ; anneau vert « Branche ernestine » pour les ernestins (anneau bleu pour Sophie-Hedwige, branche albertine de Saxe-Mersebourg) ;
--  * 3 épouses créées dans l'arbre de leur dynastie d'origine : Dorothée-Suzanne (Wittelsbach), Sophie-Antoinette (Welf), Victoria-Adélaïde (Glücksbourg) ;
--  * les liens, y compris vers des membres DÉJÀ présents dans tes autres arbres (Albert, reine Victoria, Victoire de Saxe-Cobourg-Saalfeld, Léopold Ier, Jean-Frédéric Ier, Sibylle de Clèves),
--    retrouvés par identifiant et jamais recréés ; leur position dans l'arbre Wettin est enregistrée.
-- Dates : Wikipédia (fiches des personnes) ; 2 dates vérifiées par recherche web (Sophie-Antoinette, Maria Alexandrovna).
-- Prérequis : schema_v36.sql déjà exécutée. À lancer UNE fois (Supabase -> SQL Editor -> Run). Le script s'arrête sans rien écrire si quelque chose ne correspond pas.
-- Ensuite, sur le site : ouvre l'arbre Wettin et clique sur « Organiser par dates ».

do $$
declare
  admin_id constant uuid := '96d2f891-6b9e-4967-89ed-18f83270ef28';
  tree_wet constant uuid := '309f20ea-3b5d-453b-87f9-286b7f1e6c60';
  leg_ern uuid;
  leg_alb uuid;
  n int;
begin
  select count(*) into n from public.dossier_entries where id = tree_wet and type = 'genealogy';
  if n <> 1 then raise exception 'Arbre Wettin introuvable : rien n''a été fait.'; end if;
  if exists (select 1 from public.genealogy_members where owner_id = tree_wet::text and name = 'Jean-Guillaume de Saxe-Weimar') then
    raise exception 'Branche ernestine déjà ajoutée : rien n''a été fait.';
  end if;
  select id into leg_ern from public.genealogy_legend_items where owner_type = 'entry' and owner_id = tree_wet::text and label = 'Branche ernestine';
  select id into leg_alb from public.genealogy_legend_items where owner_type = 'entry' and owner_id = tree_wet::text and label = 'Branche albertine';
  if leg_ern is null or leg_alb is null then raise exception 'Légende Branche ernestine/albertine introuvable : rien n''a été fait.'; end if;
  create temp table _m (code text primary key, id uuid not null default gen_random_uuid()) on commit drop;

  insert into _m(code) values ('jguil');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean-Guillaume de Saxe-Weimar', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Jean-Guillaume-de-Saxe-Weimar.jpg/330px-Jean-Guillaume-de-Saxe-Weimar.jpg', 1530, 1573, 'Duc de Saxe-Weimar', 'Maison de Wettin', 6400, 2880, admin_id, false from _m where code = 'jguil';
  insert into _m(code) values ('dsim');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Dorothée-Suzanne de Simmern', null, 1544, 1592, 'Duchesse de Saxe-Weimar', 'Wittelsbach (Palatinat-Simmern)', 6900, 5470, admin_id, false from _m where code = 'dsim';
  insert into _m(code) values ('fw1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Frédéric-Guillaume Ier de Saxe-Altenbourg', null, 1562, 1602, 'Duc de Saxe-Altenbourg, régent de l''électorat de Saxe (1591-1601)', 'Maison de Wettin', 6000, 3456, admin_id, false from _m where code = 'fw1';
  insert into _m(code) values ('jean2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean II de Saxe-Weimar', 'https://upload.wikimedia.org/wikipedia/commons/b/bf/Johann_of_Saxe-Weimar-Jena.jpg', 1570, 1605, 'Duc de Saxe-Weimar', 'Maison de Wettin', 6700, 3600, admin_id, false from _m where code = 'jean2';
  insert into _m(code) values ('dman');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Dorothée-Marie d''Anhalt', null, 1574, 1617, 'Duchesse de Saxe-Weimar', 'Anhalt / Wettin', 7080, 3600, admin_id, false from _m where code = 'dman';
  insert into _m(code) values ('je1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean-Ernest Ier de Saxe-Weimar', null, 1594, 1626, 'Duc de Saxe-Weimar (1605-1620)', 'Maison de Wettin', 6200, 4032, admin_id, false from _m where code = 'je1';
  insert into _m(code) values ('guil');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Guillaume de Saxe-Weimar', null, 1598, 1662, 'Duc de Saxe-Weimar (1620-1662)', 'Maison de Wettin', 6600, 4104, admin_id, false from _m where code = 'guil';
  insert into _m(code) values ('ernestp');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Ernest Ier « le Pieux »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Ernest_I%2C_duke_of_Saxe-Gotha-Altenburg.jpg/330px-Ernest_I%2C_duke_of_Saxe-Gotha-Altenburg.jpg', 1601, 1675, 'Duc de Saxe-Gotha (1640-1675)', 'Maison de Wettin', 7100, 4158, admin_id, false from _m where code = 'ernestp';
  insert into _m(code) values ('esas');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Élisabeth-Sophie de Saxe-Altenbourg', null, 1619, 1680, 'Duchesse de Saxe-Gotha', 'Maison de Wettin', 7480, 4158, admin_id, false from _m where code = 'esas';
  insert into _m(code) values ('je4');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Jean-Ernest IV de Saxe-Cobourg-Saalfeld', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Johannernstsaalfeld.jpg/330px-Johannernstsaalfeld.jpg', 1658, 1729, 'Duc de Saxe-Cobourg-Saalfeld (1699-1729)', 'Maison de Wettin', 7100, 5184, admin_id, false from _m where code = 'je4';
  insert into _m(code) values ('shm');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Sophie-Hedwige de Saxe-Mersebourg', null, 1660, 1686, 'Duchesse de Saxe-Saalfeld', 'Wettin (branche albertine de Saxe-Mersebourg)', 7480, 5184, admin_id, false from _m where code = 'shm';
  insert into _m(code) values ('cjw');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Charlotte-Johanne de Waldeck-Wildungen', null, 1664, 1699, 'Duchesse de Saxe-Saalfeld', 'Waldeck / Wettin', 6720, 5184, admin_id, false from _m where code = 'cjw';
  insert into _m(code) values ('ce2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Christian-Ernest II de Saxe-Cobourg-Saalfeld', null, 1683, 1745, 'Duc de Saxe-Cobourg-Saalfeld (1729-1745)', 'Maison de Wettin', 7500, 5634, admin_id, false from _m where code = 'ce2';
  insert into _m(code) values ('fjos');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'François-Josias de Saxe-Cobourg-Saalfeld', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Francis_Josias%2C_duke_of_Saxe-Coburg-Saalfeld.jpg/330px-Francis_Josias%2C_duke_of_Saxe-Coburg-Saalfeld.jpg', 1697, 1764, 'Duc de Saxe-Cobourg-Saalfeld (1745-1764)', 'Maison de Wettin', 6720, 5886, admin_id, false from _m where code = 'fjos';
  insert into _m(code) values ('asr');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Anne-Sophie de Schwarzbourg-Rudolstadt', null, 1700, 1780, 'Duchesse de Saxe-Cobourg-Saalfeld', 'Schwarzbourg / Wettin', 7100, 5886, admin_id, false from _m where code = 'asr';
  insert into _m(code) values ('efred');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Ernest-Frédéric de Saxe-Cobourg-Saalfeld', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Ernesto_Federico_de_Wettin_Saalfeld.jpg/330px-Ernesto_Federico_de_Wettin_Saalfeld.jpg', 1724, 1800, 'Duc de Saxe-Cobourg-Saalfeld (1764-1800)', 'Maison de Wettin', 6900, 6372, admin_id, false from _m where code = 'efred';
  insert into _m(code) values ('sab');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', 'db5ef554-cbb9-448f-89fa-b656bf1d1147', 'Sophie-Antoinette de Brunswick-Wolfenbüttel', null, 1724, 1802, 'Duchesse de Saxe-Cobourg-Saalfeld', 'Welf', 4300, 1000, admin_id, false from _m where code = 'sab';
  insert into _m(code) values ('fran');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'François de Saxe-Cobourg-Saalfeld', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fb/Johann_Heinrich_Schr%C3%B6der_-_Herzog_Franz_Friedrich_Anton_von_Sachsen-Coburg-Saalfeld.jpg/330px-Johann_Heinrich_Schr%C3%B6der_-_Herzog_Franz_Friedrich_Anton_von_Sachsen-Coburg-Saalfeld.jpg', 1750, 1806, 'Duc de Saxe-Cobourg-Saalfeld (1800-1806)', 'Maison de Wettin', 6900, 6840, admin_id, false from _m where code = 'fran';
  insert into _m(code) values ('augr');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Augusta Reuss d''Ebersdorf', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Augusta_di_Reuss-Ebersdorf%2C_duchessa_di_Sassonia-Coburgo-Saalfeld.jpg/330px-Augusta_di_Reuss-Ebersdorf%2C_duchessa_di_Sassonia-Coburgo-Saalfeld.jpg', 1757, 1831, 'Duchesse de Saxe-Cobourg-Saalfeld', 'Reuss / Wettin', 7280, 6840, admin_id, false from _m where code = 'augr';
  insert into _m(code) values ('ernest1');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Ernest Ier de Saxe-Cobourg et Gotha', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Ernst_I%2C_Duke_of_Saxe-Coburg_and_Gotha_-_Dawe_1818-19.jpg/330px-Ernst_I%2C_Duke_of_Saxe-Coburg_and_Gotha_-_Dawe_1818-19.jpg', 1784, 1844, 'Duc de Saxe-Cobourg-Saalfeld (1806), puis de Saxe-Cobourg et Gotha (1826-1844)', 'Maison de Wettin', 6600, 7452, admin_id, false from _m where code = 'ernest1';
  insert into _m(code) values ('louise');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Louise de Saxe-Gotha-Altenbourg', null, 1800, 1831, 'Duchesse de Saxe-Cobourg et Gotha', 'Maison de Wettin', 6980, 7452, admin_id, false from _m where code = 'louise';
  insert into _m(code) values ('ernest2');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Ernest II de Saxe-Cobourg et Gotha', 'https://upload.wikimedia.org/wikipedia/commons/0/02/ErnstIIofSCG.jpg', 1818, 1893, 'Duc de Saxe-Cobourg et Gotha (1844-1893)', 'Maison de Wettin', 6400, 8064, admin_id, false from _m where code = 'ernest2';
  insert into _m(code) values ('alex');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Alexandrine de Bade', null, 1820, 1904, 'Duchesse de Saxe-Cobourg et Gotha', 'Zähringen (Bade) / Wettin', 6780, 8064, admin_id, false from _m where code = 'alex';
  insert into _m(code) values ('alfred');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Alfred de Saxe-Cobourg et Gotha', null, 1844, 1900, 'Duc d''Édimbourg, duc de Saxe-Cobourg et Gotha (1893-1900)', 'Maison de Wettin', 7200, 8532, admin_id, false from _m where code = 'alfred';
  insert into _m(code) values ('maria');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Maria Alexandrovna de Russie', null, 1853, 1920, 'Duchesse d''Édimbourg, duchesse de Saxe-Cobourg et Gotha', 'Romanov', 7580, 8532, admin_id, false from _m where code = 'maria';
  insert into _m(code) values ('leo');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Léopold, duc d''Albany', null, 1853, 1884, 'Duc d''Albany, fils de la reine Victoria', 'Maison de Wettin', 8000, 8694, admin_id, false from _m where code = 'leo';
  insert into _m(code) values ('helena');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Hélène de Waldeck-Pyrmont', null, 1861, 1922, 'Duchesse d''Albany', 'Waldeck / Wettin', 8380, 8694, admin_id, false from _m where code = 'helena';
  insert into _m(code) values ('charles');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', tree_wet::text, 'Charles-Édouard de Saxe-Cobourg et Gotha', null, 1884, 1954, 'Dernier duc de Saxe-Cobourg et Gotha (1900-1918)', 'Maison de Wettin', 8100, 9252, admin_id, false from _m where code = 'charles';
  insert into _m(code) values ('vadel');
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
    select id, 'entry', '78bf5e64-5a01-48df-8ae2-e80934de7e4d', 'Victoria-Adélaïde de Schleswig-Holstein', null, 1885, 1970, 'Duchesse de Saxe-Cobourg et Gotha', 'Schleswig-Holstein-Sonderbourg-Glücksbourg', 700, 1700, admin_id, false from _m where code = 'vadel';

  create function pg_temp.ext(prefix text) returns uuid language plpgsql stable as $f$
  declare r uuid; k int;
  begin
    select count(*) into k from public.genealogy_members where id::text like prefix || '%';
    if k <> 1 then raise exception 'Membre existant introuvable ou ambigu : % (% résultats)', prefix, k; end if;
    select id into r from public.genealogy_members where id::text like prefix || '%';
    return r;
  end $f$;
  create function pg_temp.res(c text) returns uuid language plpgsql stable as $f$
  declare r uuid;
  begin
    if c like 'x:%' then return pg_temp.ext(substr(c, 3)); end if;
    select id into r from _m where code = c;
    if r is null then raise exception 'Code inconnu : %', c; end if;
    return r;
  end $f$;
  create function pg_temp.rel(a text, b text, t text) returns void language plpgsql as $f$
  declare ia uuid := pg_temp.res(a); ib uuid := pg_temp.res(b);
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = ia and member_b_id = ib) or (t = 'spouse' and member_a_id = ib and member_b_id = ia))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (ia, ib, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform set_config('app.admin', admin_id::text, true);

  perform pg_temp.rel('jguil', 'dsim', 'spouse');
  perform pg_temp.rel('x:f9e89eb5', 'jguil', 'parent');
  perform pg_temp.rel('x:451744d2', 'jguil', 'parent');
  perform pg_temp.rel('jguil', 'fw1', 'parent');
  perform pg_temp.rel('dsim', 'fw1', 'parent');
  perform pg_temp.rel('jguil', 'jean2', 'parent');
  perform pg_temp.rel('dsim', 'jean2', 'parent');
  perform pg_temp.rel('jean2', 'dman', 'spouse');
  perform pg_temp.rel('jean2', 'je1', 'parent');
  perform pg_temp.rel('dman', 'je1', 'parent');
  perform pg_temp.rel('jean2', 'guil', 'parent');
  perform pg_temp.rel('dman', 'guil', 'parent');
  perform pg_temp.rel('jean2', 'ernestp', 'parent');
  perform pg_temp.rel('dman', 'ernestp', 'parent');
  perform pg_temp.rel('ernestp', 'esas', 'spouse');
  perform pg_temp.rel('ernestp', 'je4', 'parent');
  perform pg_temp.rel('esas', 'je4', 'parent');
  perform pg_temp.rel('je4', 'shm', 'spouse');
  perform pg_temp.rel('je4', 'cjw', 'spouse');
  perform pg_temp.rel('je4', 'ce2', 'parent');
  perform pg_temp.rel('shm', 'ce2', 'parent');
  perform pg_temp.rel('je4', 'fjos', 'parent');
  perform pg_temp.rel('cjw', 'fjos', 'parent');
  perform pg_temp.rel('fjos', 'asr', 'spouse');
  perform pg_temp.rel('fjos', 'efred', 'parent');
  perform pg_temp.rel('asr', 'efred', 'parent');
  perform pg_temp.rel('efred', 'sab', 'spouse');
  perform pg_temp.rel('efred', 'fran', 'parent');
  perform pg_temp.rel('sab', 'fran', 'parent');
  perform pg_temp.rel('fran', 'augr', 'spouse');
  perform pg_temp.rel('fran', 'ernest1', 'parent');
  perform pg_temp.rel('augr', 'ernest1', 'parent');
  perform pg_temp.rel('fran', 'x:55c3b278', 'parent');
  perform pg_temp.rel('augr', 'x:55c3b278', 'parent');
  perform pg_temp.rel('fran', 'x:a1f6258c', 'parent');
  perform pg_temp.rel('augr', 'x:a1f6258c', 'parent');
  perform pg_temp.rel('ernest1', 'louise', 'spouse');
  perform pg_temp.rel('ernest1', 'ernest2', 'parent');
  perform pg_temp.rel('louise', 'ernest2', 'parent');
  perform pg_temp.rel('ernest1', 'x:0d53db23', 'parent');
  perform pg_temp.rel('louise', 'x:0d53db23', 'parent');
  perform pg_temp.rel('ernest2', 'alex', 'spouse');
  perform pg_temp.rel('x:0d53db23', 'x:11b2db35', 'spouse');
  perform pg_temp.rel('x:0d53db23', 'alfred', 'parent');
  perform pg_temp.rel('x:11b2db35', 'alfred', 'parent');
  perform pg_temp.rel('x:0d53db23', 'leo', 'parent');
  perform pg_temp.rel('x:11b2db35', 'leo', 'parent');
  perform pg_temp.rel('alfred', 'maria', 'spouse');
  perform pg_temp.rel('leo', 'helena', 'spouse');
  perform pg_temp.rel('leo', 'charles', 'parent');
  perform pg_temp.rel('helena', 'charles', 'parent');
  perform pg_temp.rel('charles', 'vadel', 'spouse');
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('jguil'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('fw1'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('jean2'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('je1'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('guil'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('ernestp'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('esas'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('je4'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('ce2'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('fjos'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('efred'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('fran'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('ernest1'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('louise'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('ernest2'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('alfred'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('leo'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('charles'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.res('shm'), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values (pg_temp.res('dsim'), 'entry', tree_wet, 6780, 2880, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values (pg_temp.res('sab'), 'entry', tree_wet, 7280, 6372, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values (pg_temp.res('x:55c3b278'), 'entry', tree_wet, 7500, 7488, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values (pg_temp.res('x:a1f6258c'), 'entry', tree_wet, 7900, 7560, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values (pg_temp.res('x:0d53db23'), 'entry', tree_wet, 7200, 8082, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values (pg_temp.res('x:11b2db35'), 'entry', tree_wet, 7580, 8082, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values (pg_temp.res('vadel'), 'entry', tree_wet, 8480, 9252, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'Branche ernestine ajoutée : % membres.', (select count(*) from _m);
end $$;
