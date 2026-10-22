-- schema_v34.sql — Correctif pour la 1re version de schema_v33 (déjà lancée) :
--  * Wettin réduit à la partie utile à l'histoire allemande (supprime les membres en trop, ainsi que leurs liens),
--  * Auguste II déplacé dans l'arbre polonais « Wettin » (pont allemand ↔ polonais),
--  * nouvelles positions des Wettin conservés, anneau rouge limité au plus haut pouvoir (+ Auguste III),
--  * légende « Branche ernestine » (vert) / « Branche albertine » (bleu) et anneaux correspondants.
-- À lancer UNE fois, seulement si schema_v33 (1re version) a déjà été exécuté. Ne touche ni aux photos ni aux textes
-- des membres conservés. Le script s'arrête sans rien écrire si quelque chose ne correspond pas.

do $$
declare
  admin_id constant uuid := '96d2f891-6b9e-4967-89ed-18f83270ef28';
  sec_wet constant uuid := '4f726329-6d33-4bbc-b629-faa0815e49a0';
  sec_hoh constant uuid := '301b9c78-ecb6-45b7-b5ab-8758d6cd2a87';
  pol_tree constant uuid := '7482cd8d-c426-4789-b4ec-48fe08c8d4ae';
  tree_wet uuid;
  tree_hoh uuid;
  leg_ern uuid;
  leg_alb uuid;
  n int;
begin
  select count(*) into n from public.dossier_entries where section_id = sec_wet and type = 'genealogy';
  if n <> 1 then raise exception 'Arbre Wettin (Allemagne) introuvable ou en double (% trouvés) : rien n''a été fait.', n; end if;
  select id into tree_wet from public.dossier_entries where section_id = sec_wet and type = 'genealogy';
  select count(*) into n from public.dossier_entries where section_id = sec_hoh and type = 'genealogy';
  if n <> 1 then raise exception 'Arbre Hohenzollern (Allemagne) introuvable ou en double (% trouvés) : rien n''a été fait.', n; end if;
  select id into tree_hoh from public.dossier_entries where section_id = sec_hoh and type = 'genealogy';
  if exists (select 1 from public.genealogy_legend_items where owner_type = 'entry' and owner_id = tree_wet::text and label in ('Branche ernestine','Branche albertine')) then
    raise exception 'Correctif déjà appliqué : rien n''a été fait.';
  end if;

  create function pg_temp.ext(prefix text) returns uuid language plpgsql stable as $f$
  declare r uuid; k int;
  begin
    select count(*) into k from public.genealogy_members where id::text like prefix || '%';
    if k <> 1 then raise exception 'Membre existant introuvable ou ambigu : % (% résultats)', prefix, k; end if;
    select id into r from public.genealogy_members where id::text like prefix || '%';
    return r;
  end $f$;
  create function pg_temp.mem(own text, nm text, b int) returns uuid language plpgsql stable as $f$
  declare r uuid; k int;
  begin
    select count(*) into k from public.genealogy_members where owner_id = own and name = nm and birth_year is not distinct from b;
    if k <> 1 then raise exception 'Membre introuvable ou ambigu : % (% résultats)', nm, k; end if;
    select id into r from public.genealogy_members where owner_id = own and name = nm and birth_year is not distinct from b;
    return r;
  end $f$;

  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Albert Ier « le Fier »' and birth_year is not distinct from 1158;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Albert II « le Dégénéré »' and birth_year is not distinct from 1240;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Augusta Reuss d''Ebersdorf' and birth_year is not distinct from 1757;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Catherine de Henneberg' and birth_year is not distinct from 1334;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Conrad Ier « le Pieux »' and birth_year is not distinct from 1098;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Constance d''Autriche' and birth_year is not distinct from 1212;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Ernest-Frédéric de Saxe-Cobourg-Saalfeld' and birth_year is not distinct from 1724;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Élisabeth de Lobdeburg-Arnshaugk' and birth_year is not distinct from 1286;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Ernest Ier de Saxe-Cobourg et Gotha' and birth_year is not distinct from 1784;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Ernest II de Saxe-Cobourg et Gotha' and birth_year is not distinct from 1818;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Ernest Ier « le Pieux »' and birth_year is not distinct from 1601;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Frédéric Ier de Saxe-Gotha-Altenbourg' and birth_year is not distinct from 1646;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Frédéric II de Saxe-Gotha-Altenbourg' and birth_year is not distinct from 1676;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'François-Josias de Saxe-Cobourg-Saalfeld' and birth_year is not distinct from 1697;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'François de Saxe-Cobourg-Saalfeld' and birth_year is not distinct from 1750;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Frédéric Ier « le Mordu »' and birth_year is not distinct from 1257;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Frédéric II « le Sérieux »' and birth_year is not distinct from 1310;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Frédéric III « le Sévère »' and birth_year is not distinct from 1332;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Hedwige de Brandebourg' and birth_year is not distinct from 1140;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Henri III « l''Illustre »' and birth_year is not distinct from 1215;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Jean II de Saxe-Weimar' and birth_year is not distinct from 1570;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Jean-Ernest IV de Saxe-Saalfeld' and birth_year is not distinct from 1658;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Jean-Guillaume de Saxe-Weimar' and birth_year is not distinct from 1530;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Jutta de Thuringe' and birth_year is not distinct from 1184;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Louise de Saxe-Gotha-Altenbourg' and birth_year is not distinct from 1800;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Madeleine-Augusta d''Anhalt-Zerbst' and birth_year is not distinct from 1679;
  delete from public.genealogy_members where owner_id = '19aed0d5-8c4a-4125-b821-8fc6bc357dab' and name = 'Marguerite de Sicile' and birth_year is not distinct from 1241;
  delete from public.genealogy_members where owner_id = 'e76d91a3-1b9c-4703-85b3-9f711b6d6199' and name = 'Mathilde de Bavière' and birth_year is not distinct from 1313;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Othon Ier « le Riche »' and birth_year is not distinct from 1125;
  delete from public.genealogy_members where owner_id = tree_wet::text and name = 'Thierry Ier « l''Exilé »' and birth_year is not distinct from 1162;
  update public.genealogy_members set owner_id = pol_tree::text, pos_x = 417, pos_y = -130, is_leader = true where id = pg_temp.mem(tree_wet::text, 'Frédéric-Auguste Ier « Auguste II le Fort »', 1670);
  update public.genealogy_members set pos_x = 0, pos_y = 0 where id = pg_temp.mem(tree_wet::text, 'Frédéric Ier « le Belliqueux »', 1370);
  update public.genealogy_members set pos_x = 0, pos_y = 420 where id = pg_temp.mem(tree_wet::text, 'Frédéric II « le Doux »', 1412);
  update public.genealogy_members set pos_x = -500, pos_y = 420 where id = pg_temp.mem(tree_wet::text, 'Catherine de Saxe', 1421);
  update public.genealogy_members set pos_x = 500, pos_y = 840 where id = pg_temp.mem(tree_wet::text, 'Anne de Saxe', 1437);
  update public.genealogy_members set pos_x = -1500, pos_y = 840 where id = pg_temp.mem(tree_wet::text, 'Ernest de Saxe', 1441);
  update public.genealogy_members set pos_x = 2000, pos_y = 840 where id = pg_temp.mem(tree_wet::text, 'Albert III « le Courageux »', 1443);
  update public.genealogy_members set pos_x = 2450, pos_y = 840 where id = pg_temp.mem(tree_wet::text, 'Sidonie de Bohême', 1449);
  update public.genealogy_members set pos_x = -2100, pos_y = 1260 where id = pg_temp.mem(tree_wet::text, 'Frédéric III « le Sage »', 1463);
  update public.genealogy_members set pos_x = -1500, pos_y = 1260 where id = pg_temp.mem(tree_wet::text, 'Jean « le Constant »', 1468);
  update public.genealogy_members set pos_x = -1000, pos_y = 1260 where id = pg_temp.mem(tree_wet::text, 'Sophie de Mecklembourg', 1481);
  update public.genealogy_members set pos_x = 1500, pos_y = 1260 where id = pg_temp.mem(tree_wet::text, 'Georges « le Barbu »', 1471);
  update public.genealogy_members set pos_x = 2500, pos_y = 1260 where id = pg_temp.mem(tree_wet::text, 'Henri IV « le Pieux »', 1473);
  update public.genealogy_members set pos_x = 3000, pos_y = 1260 where id = pg_temp.mem(tree_wet::text, 'Catherine de Mecklembourg', 1487);
  update public.genealogy_members set pos_x = -1500, pos_y = 1680 where id = pg_temp.mem(tree_wet::text, 'Jean-Frédéric Ier « le Magnanime »', 1503);
  update public.genealogy_members set pos_x = -1000, pos_y = 1680 where id = pg_temp.mem(tree_wet::text, 'Sibylle de Clèves', 1512);
  update public.genealogy_members set pos_x = 1500, pos_y = 1680 where id = pg_temp.mem(tree_wet::text, 'Madeleine de Saxe', 1507);
  update public.genealogy_members set pos_x = 2500, pos_y = 1680 where id = pg_temp.mem(tree_wet::text, 'Maurice', 1521);
  update public.genealogy_members set pos_x = 2950, pos_y = 1680 where id = pg_temp.mem(tree_wet::text, 'Agnès de Hesse', 1527);
  update public.genealogy_members set pos_x = 3500, pos_y = 1680 where id = pg_temp.mem(tree_wet::text, 'Auguste Ier', 1526);
  update public.genealogy_members set pos_x = 3500, pos_y = 2100 where id = pg_temp.mem(tree_wet::text, 'Christian Ier', 1560);
  update public.genealogy_members set pos_x = 3000, pos_y = 2520 where id = pg_temp.mem(tree_wet::text, 'Christian II', 1583);
  update public.genealogy_members set pos_x = 4000, pos_y = 2520 where id = pg_temp.mem(tree_wet::text, 'Jean-Georges Ier', 1585);
  update public.genealogy_members set pos_x = 4000, pos_y = 2940 where id = pg_temp.mem(tree_wet::text, 'Jean-Georges II', 1613);
  update public.genealogy_members set pos_x = 4000, pos_y = 3360 where id = pg_temp.mem(tree_wet::text, 'Jean-Georges III', 1647);
  update public.genealogy_members set pos_x = 3500, pos_y = 3780 where id = pg_temp.mem(tree_wet::text, 'Jean-Georges IV', 1668);
  update public.genealogy_members set pos_x = 4500, pos_y = 4620 where id = pg_temp.mem(tree_wet::text, 'Frédéric-Christian', 1722);
  update public.genealogy_members set pos_x = 5400, pos_y = 4620 where id = pg_temp.mem(tree_wet::text, 'François-Xavier de Saxe', 1730);
  update public.genealogy_members set pos_x = 4000, pos_y = 5040 where id = pg_temp.mem(tree_wet::text, 'Frédéric-Auguste Ier « le Juste »', 1750);
  update public.genealogy_members set pos_x = 5000, pos_y = 5040 where id = pg_temp.mem(tree_wet::text, 'Antoine Ier', 1755);
  update public.genealogy_members set pos_x = 6000, pos_y = 5040 where id = pg_temp.mem(tree_wet::text, 'Maximilien de Saxe', 1759);
  update public.genealogy_members set pos_x = 6000, pos_y = 5460 where id = pg_temp.mem(tree_wet::text, 'Frédéric-Auguste II', 1797);
  update public.genealogy_members set pos_x = 6900, pos_y = 5460 where id = pg_temp.mem(tree_wet::text, 'Jean Ier', 1801);
  update public.genealogy_members set pos_x = 6900, pos_y = 5880 where id = pg_temp.mem(tree_wet::text, 'Albert Ier', 1828);
  update public.genealogy_members set pos_x = 7400, pos_y = 5880 where id = pg_temp.mem(tree_wet::text, 'Carola de Vasa', 1833);
  update public.genealogy_members set pos_x = 8000, pos_y = 5880 where id = pg_temp.mem(tree_wet::text, 'Georges Ier', 1832);
  update public.genealogy_members set pos_x = 8000, pos_y = 6300 where id = pg_temp.mem(tree_wet::text, 'Frédéric-Auguste III', 1865);
  update public.genealogy_members set pos_x = -3000, pos_y = 0 where id = pg_temp.mem(tree_wet::text, 'Élisabeth de Misnie', 1329);
  update public.genealogy_members set pos_x = -3000, pos_y = 420 where id = pg_temp.mem(tree_wet::text, 'Marguerite de Thuringe', 1449);
  update public.genealogy_members set pos_x = -3000, pos_y = 840 where id = pg_temp.mem(tree_wet::text, 'Augusta de Saxe-Weimar-Eisenach', 1811);
  update public.genealogy_members set is_leader = false where owner_id in (tree_wet::text, tree_hoh::text) and is_leader;
  update public.genealogy_members set is_leader = true where id = pg_temp.mem(tree_hoh::text, 'Guillaume Ier', 1797);
  update public.genealogy_members set is_leader = true where id = pg_temp.mem(tree_hoh::text, 'Frédéric III', 1831);
  update public.genealogy_members set is_leader = true where id = pg_temp.mem(tree_hoh::text, 'Guillaume II', 1859);
  update public.genealogy_members set is_leader = true where id = pg_temp.ext('ae05a240');
  insert into public.genealogy_legend_items (owner_type, owner_id, color, label, position, created_by, kind)
  values ('entry', tree_wet::text, '#1a9850', 'Branche ernestine', 0, admin_id, 'status') returning id into leg_ern;
  insert into public.genealogy_legend_items (owner_type, owner_id, color, label, position, created_by, kind)
  values ('entry', tree_wet::text, '#1f4fbf', 'Branche albertine', 1, admin_id, 'status') returning id into leg_alb;
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Ernest de Saxe', 1441), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Frédéric III « le Sage »', 1463), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Jean « le Constant »', 1468), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Sophie de Mecklembourg', 1481), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Jean-Frédéric Ier « le Magnanime »', 1503), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Sibylle de Clèves', 1512), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Augusta de Saxe-Weimar-Eisenach', 1811), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem('e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Élisabeth de Bavière', 1443), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.ext('0c89f180'), 'entry', tree_wet::text, leg_ern, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Albert III « le Courageux »', 1443), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Sidonie de Bohême', 1449), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Georges « le Barbu »', 1471), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Henri IV « le Pieux »', 1473), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Catherine de Mecklembourg', 1487), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Madeleine de Saxe', 1507), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Maurice', 1521), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Agnès de Hesse', 1527), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Auguste Ier', 1526), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Christian Ier', 1560), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Christian II', 1583), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Jean-Georges Ier', 1585), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Jean-Georges II', 1613), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Jean-Georges III', 1647), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Jean-Georges IV', 1668), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Frédéric-Christian', 1722), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'François-Xavier de Saxe', 1730), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Frédéric-Auguste Ier « le Juste »', 1750), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Antoine Ier', 1755), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Maximilien de Saxe', 1759), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Frédéric-Auguste II', 1797), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Jean Ier', 1801), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Albert Ier', 1828), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Carola de Vasa', 1833), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Georges Ier', 1832), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_wet::text, 'Frédéric-Auguste III', 1865), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem('2330c043-bc06-4464-92c0-dbc885739729', 'Barbara Jagellon', 1478), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem('7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Anne de Danemark', 1532), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_hoh::text, 'Sophie de Brandebourg', 1568), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem('7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Hedwige de Danemark', 1581), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_hoh::text, 'Madeleine-Sibylle de Prusse', 1586), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(tree_hoh::text, 'Madeleine-Sibylle de Brandebourg-Bayreuth', 1612), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem('7fc4995d-01af-4a5b-8344-817566b6f3c2', 'Anne-Sophie de Danemark', 1647), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem(pol_tree::text, 'Frédéric-Auguste Ier « Auguste II le Fort »', 1670), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.ext('ae05a240'), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.ext('bb30cf99'), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem('e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Marie-Antoinette de Bavière', 1724), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem('e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Amélie de Deux-Ponts-Birkenfeld', 1752), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem('84c9f117-4375-499a-8634-b87e7515ec6a', 'Caroline de Bourbon-Parme', 1770), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem('e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Amélie de Bavière', 1801), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem('14db1138-55b4-48b7-b4de-c79e51127284', 'Marie-Anne de Portugal', 1843), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  insert into public.genealogy_member_statuses (member_id, owner_type, owner_id, legend_item_id, position, created_by) values (pg_temp.mem('6b34bc03-d0ad-4c48-a485-f541cecafd5d', 'Louise-Antoinette de Habsbourg-Toscane', 1870), 'entry', tree_wet::text, leg_alb, 0, admin_id);
  raise notice 'Correctif appliqué : Wettin réduit, pont polonais, légende des branches.';
end $$;
