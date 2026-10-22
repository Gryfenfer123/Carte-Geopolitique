-- schema_v35.sql — Rend à Élisabeth de Misnie ses ascendants (arbre Wettin d'Allemagne).
-- Cause : en réduisant l'arbre Wettin, j'avais supprimé son père (Frédéric II « le Sérieux ») et sa mère
-- (Mathilde de Bavière), donc elle apparaissait seule. On les rétablit, avec Frédéric III « le Sévère »
-- et son épouse Catherine de Henneberg, pour que la lignée reste continue jusqu'à Frédéric Ier le Belliqueux.
--  * Frédéric II, Frédéric III, Catherine de Henneberg -> arbre Wettin (Allemagne)
--      (Catherine : la famille de Henneberg n'a pas d'arbre chez toi, donc créée ici — à déplacer plus tard si besoin)
--  * Mathilde de Bavière -> arbre Wittelsbach (elle y est d'origine), reliée à son père, déjà présent dans ta base
-- À lancer UNE fois. S'arrête sans rien écrire si quelque chose ne correspond pas.

do $$
declare
  admin_id constant uuid := '96d2f891-6b9e-4967-89ed-18f83270ef28';
  sec_wet constant uuid := '4f726329-6d33-4bbc-b629-faa0815e49a0';
  wit_tree constant text := 'e76d91a3-1b9c-4703-85b3-9f711b6d6199';
  tree_wet uuid;
  n int;
  v_el uuid; v_fb uuid; v_f2 uuid; v_f3 uuid; v_ch uuid; v_mb uuid; v_lp uuid; ymax float;
begin
  select count(*) into n from public.dossier_entries where section_id = sec_wet and type = 'genealogy';
  if n <> 1 then raise exception 'Arbre Wettin (Allemagne) introuvable ou en double (% trouvés) : rien n''a été fait.', n; end if;
  select id into tree_wet from public.dossier_entries where section_id = sec_wet and type = 'genealogy';

  select count(*) into n from public.genealogy_members where owner_id = tree_wet::text and name = 'Élisabeth de Misnie' and birth_year = 1329;
  if n <> 1 then raise exception 'Élisabeth de Misnie introuvable ou en double : rien n''a été fait.'; end if;
  select id into v_el from public.genealogy_members where owner_id = tree_wet::text and name = 'Élisabeth de Misnie' and birth_year = 1329;
  select count(*) into n from public.genealogy_members where owner_id = tree_wet::text and name = 'Frédéric Ier « le Belliqueux »' and birth_year = 1370;
  if n <> 1 then raise exception 'Frédéric Ier le Belliqueux introuvable : rien n''a été fait.'; end if;
  select id into v_fb from public.genealogy_members where owner_id = tree_wet::text and name = 'Frédéric Ier « le Belliqueux »' and birth_year = 1370;
  if exists (select 1 from public.genealogy_relations where member_b_id = v_el and relation_type = 'parent') then
    raise exception 'Élisabeth de Misnie a déjà des parents : rien n''a été fait.';
  end if;
  select count(*) into n from public.genealogy_members where id::text like '32744ff5%';
  if n <> 1 then raise exception 'Père de Mathilde de Bavière introuvable (% résultats) : rien n''a été fait.', n; end if;
  select id into v_lp from public.genealogy_members where id::text like '32744ff5%';

  select coalesce(max(pos_y), -420) + 420 into ymax from public.genealogy_members where owner_id = wit_tree;

  insert into public.genealogy_members (owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
  values ('entry', tree_wet::text, 'Frédéric II « le Sérieux »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Dresden_F%C3%BCrstenzug_084_%28cropped%29_-_Frederick_II%2C_Margrave_of_Meissen.JPG/330px-Dresden_F%C3%BCrstenzug_084_%28cropped%29_-_Frederick_II%2C_Margrave_of_Meissen.JPG', 1310, 1349, 'Margrave de Misnie, landgrave de Thuringe', 'Maison de Wettin', -1500, -840, admin_id, false)
  returning id into v_f2;
  insert into public.genealogy_members (owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
  values ('entry', tree_wet::text, 'Frédéric III « le Sévère »', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Friedrich_Strenge_Albrechtsburg-2.jpg/330px-Friedrich_Strenge_Albrechtsburg-2.jpg', 1332, 1381, 'Landgrave de Thuringe, margrave de Misnie', 'Maison de Wettin', 0, -420, admin_id, false)
  returning id into v_f3;
  insert into public.genealogy_members (owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
  values ('entry', tree_wet::text, 'Catherine de Henneberg', null, 1334, 1397, 'Margravine de Misnie', 'Henneberg / Wettin', 450, -420, admin_id, false)
  returning id into v_ch;
  insert into public.genealogy_members (owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader)
  values ('entry', wit_tree, 'Mathilde de Bavière', null, 1313, 1346, 'Margravine de Misnie', 'Wittelsbach', 6400, ymax, admin_id, false)
  returning id into v_mb;

  insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values
    (v_f2, v_mb, 'spouse', admin_id),
    (v_lp, v_mb, 'parent', admin_id),
    (v_f2, v_f3, 'parent', admin_id), (v_mb, v_f3, 'parent', admin_id),
    (v_f2, v_el, 'parent', admin_id), (v_mb, v_el, 'parent', admin_id),
    (v_f3, v_ch, 'spouse', admin_id),
    (v_f3, v_fb, 'parent', admin_id), (v_ch, v_fb, 'parent', admin_id);
  raise notice 'Ascendants d''Élisabeth de Misnie rétablis (4 membres, 9 liens).';
end $$;
