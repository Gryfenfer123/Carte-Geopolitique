-- arbres_v78.sql — France — Bonaparte : fratrie de Napoléon Ier, Beauharnais, enfants de Louis et de Jérôme, Prince impérial
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Complète l'arbre « Bonaparte » (13 membres au départ ; rien n'est supprimé).
-- Dates : connues par ailleurs (histoire de France), aucune page consultée pour ce lot ; dates douteuses laissées vides.
-- Augusta de Bavière est créée dans l'arbre Wittelsbach. Maisons sans arbre (Beauharnais, Murat, Baciocchi, Clary, Wurtemberg…) : signalées.
-- Non fait : enfants de Joseph, Lucien, Murat ; branche américaine de Jérôme ; Amélie de Leuchtenberg n'est pas reliée à son mari (Pierre Ier du Brésil absent de la base).
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
  if exists (select 1 from public.genealogy_members where id = '471645f5-55c5-50f8-8f99-c8f6146aa024') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('1488e049-c938-457c-b746-3e32fe4539c5','23c92a87-0e99-45c9-b149-e5887bc511f6','276d911e-e2b6-4170-9834-8b358c961430','2cafb38a-4169-4a99-9684-788ecba27725','39dd3223-8155-4300-ba98-14e9fe59f237','3fe14ec2-b6ea-4efe-a755-4a8dc49511cc','580cda52-6706-49c2-aef9-a37eeca9fa40','969467e8-d81c-4c44-81c2-56dbbd00ad51','b47f1c54-e013-530c-94a0-60b20ce47c19','bb2ceff8-3a24-40cf-a9c0-6f307c99c610','e414da9b-4492-586c-b5cc-53ca54ab4bc7','e74c9a1b-b487-5f11-8810-39f58b735c2d','e96686c9-258e-4670-a8c9-e971d022aee6');
  if k <> 13 then raise exception 'Membres préexistants manquants (% sur 13) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  select count(*) into k from public.dossier_entries where id = 'ae0dd55b-e688-4bff-8917-4df1e9786a95' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Bonaparte introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = 'e76d91a3-1b9c-4703-85b3-9f711b6d6199' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Wittelsbach introuvable : rien n''a été fait.'; end if;
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('471645f5-55c5-50f8-8f99-c8f6146aa024', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Élisa Bonaparte', null, 1777, 1820, 'Grande-duchesse de Toscane', 'Bonaparte', 4874, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ced37b4e-36c7-5360-8725-bc193062cce4', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Pauline Bonaparte', null, 1780, 1825, 'Princesse Borghèse', 'Bonaparte', 3384, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('d81ce1b0-fe5a-54cc-8bf6-3de11fe7edc7', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Caroline Bonaparte', null, 1782, 1839, 'Reine de Naples', 'Bonaparte', 2470, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1d521e24-22a0-5093-b62c-1cc3a229ce20', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Joachim Murat', null, 1767, 1815, 'Roi de Naples', 'Murat', 2960, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c27cff0f-ca74-5d17-87ec-dab39c3ee5c3', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Félix Baciocchi', null, 1762, 1841, 'Prince de Lucques, époux d''Élisa', 'Baciocchi', 5364, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('58437982-e5ff-54ab-830b-40248f174a1c', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Julie Clary', null, 1771, 1845, 'Reine de Naples puis d''Espagne, épouse de Joseph', 'Clary', 6354, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('460c77b6-6e46-54c0-8f3a-4036260e7a92', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Alexandre de Beauharnais', null, 1760, 1794, 'Premier mari de Joséphine', 'Beauharnais', 1470, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('50ae0292-a3cd-5e5d-bdde-24774466cb0b', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Eugène de Beauharnais', null, 1781, 1824, 'Vice-roi d''Italie, duc de Leuchtenberg', 'Beauharnais', 798, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('aead0438-df75-5c73-bb4c-19cc5e109237', 'entry', 'e76d91a3-1b9c-4703-85b3-9f711b6d6199', 'Augusta de Bavière', null, 1788, 1851, 'Duchesse de Leuchtenberg', 'Wittelsbach', 258000, 14184, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('2a06f1e7-2139-5451-9a7f-333871e94560', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Auguste de Beauharnais, duc de Leuchtenberg', null, 1810, 1835, 'Prince consort du Portugal (époux de Marie II)', 'Beauharnais', 1655, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('db85428a-e4c4-5b25-9493-642b23431fae', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Amélie de Leuchtenberg', null, 1812, 1873, 'Impératrice du Brésil', 'Beauharnais', 655, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b916cc90-8c48-5314-b9d0-3ea480765ca5', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Théodolinde de Leuchtenberg', null, 1814, 1857, 'Comtesse de Wurtemberg', 'Beauharnais', 2155, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('5c0cce7b-8fdc-55d6-8f53-77e5b5900c80', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Maximilien de Beauharnais, duc de Leuchtenberg', null, 1817, 1852, 'Gendre de Nicolas Ier', 'Beauharnais', 1155, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('1bccc7d5-2a63-5028-88d1-065f0d039276', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Napoléon-Louis Bonaparte', null, 1804, 1831, 'Fils de Louis et Hortense', 'Bonaparte', 3645, 1920, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8a8fadf5-4de1-55f1-aa9c-b9aba93a71c3', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Napoléon Eugène, prince impérial', null, 1856, 1879, 'Fils de Napoléon III', 'Bonaparte', 2900, 2560, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f58d5a0f-54c7-5f04-8682-5ff817880d18', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Catherine de Wurtemberg', null, 1783, 1835, 'Reine de Westphalie', 'Wurtemberg', 4374, 640, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('29d032cf-bfa9-51b3-b5fa-63bcece05853', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Mathilde Bonaparte', null, 1820, 1904, 'Princesse, salonnière', 'Bonaparte', 3710, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('7c66d88e-219b-51f1-81a0-8e4955ec26c8', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 'Napoléon-Jérôme Bonaparte (Plon-Plon)', null, 1822, 1891, 'Prince Napoléon, héritier bonapartiste', 'Bonaparte', 4210, 1280, admin_id, false);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('2cafb38a-4169-4a99-9684-788ecba27725', '471645f5-55c5-50f8-8f99-c8f6146aa024', 'parent');
  perform pg_temp.rel('3fe14ec2-b6ea-4efe-a755-4a8dc49511cc', '471645f5-55c5-50f8-8f99-c8f6146aa024', 'parent');
  perform pg_temp.rel('2cafb38a-4169-4a99-9684-788ecba27725', 'ced37b4e-36c7-5360-8725-bc193062cce4', 'parent');
  perform pg_temp.rel('3fe14ec2-b6ea-4efe-a755-4a8dc49511cc', 'ced37b4e-36c7-5360-8725-bc193062cce4', 'parent');
  perform pg_temp.rel('2cafb38a-4169-4a99-9684-788ecba27725', 'd81ce1b0-fe5a-54cc-8bf6-3de11fe7edc7', 'parent');
  perform pg_temp.rel('3fe14ec2-b6ea-4efe-a755-4a8dc49511cc', 'd81ce1b0-fe5a-54cc-8bf6-3de11fe7edc7', 'parent');
  perform pg_temp.rel('d81ce1b0-fe5a-54cc-8bf6-3de11fe7edc7', '1d521e24-22a0-5093-b62c-1cc3a229ce20', 'spouse');
  perform pg_temp.rel('471645f5-55c5-50f8-8f99-c8f6146aa024', 'c27cff0f-ca74-5d17-87ec-dab39c3ee5c3', 'spouse');
  perform pg_temp.rel('969467e8-d81c-4c44-81c2-56dbbd00ad51', '58437982-e5ff-54ab-830b-40248f174a1c', 'spouse');
  perform pg_temp.rel('460c77b6-6e46-54c0-8f3a-4036260e7a92', 'e96686c9-258e-4670-a8c9-e971d022aee6', 'spouse');
  perform pg_temp.rel('460c77b6-6e46-54c0-8f3a-4036260e7a92', '50ae0292-a3cd-5e5d-bdde-24774466cb0b', 'parent');
  perform pg_temp.rel('e96686c9-258e-4670-a8c9-e971d022aee6', '50ae0292-a3cd-5e5d-bdde-24774466cb0b', 'parent');
  perform pg_temp.rel('460c77b6-6e46-54c0-8f3a-4036260e7a92', '39dd3223-8155-4300-ba98-14e9fe59f237', 'parent');
  perform pg_temp.rel('e96686c9-258e-4670-a8c9-e971d022aee6', '39dd3223-8155-4300-ba98-14e9fe59f237', 'parent');
  perform pg_temp.rel('bb2ceff8-3a24-40cf-a9c0-6f307c99c610', 'aead0438-df75-5c73-bb4c-19cc5e109237', 'parent');
  perform pg_temp.rel('50ae0292-a3cd-5e5d-bdde-24774466cb0b', 'aead0438-df75-5c73-bb4c-19cc5e109237', 'spouse');
  perform pg_temp.rel('50ae0292-a3cd-5e5d-bdde-24774466cb0b', 'b47f1c54-e013-530c-94a0-60b20ce47c19', 'parent');
  perform pg_temp.rel('aead0438-df75-5c73-bb4c-19cc5e109237', 'b47f1c54-e013-530c-94a0-60b20ce47c19', 'parent');
  perform pg_temp.rel('50ae0292-a3cd-5e5d-bdde-24774466cb0b', '2a06f1e7-2139-5451-9a7f-333871e94560', 'parent');
  perform pg_temp.rel('aead0438-df75-5c73-bb4c-19cc5e109237', '2a06f1e7-2139-5451-9a7f-333871e94560', 'parent');
  perform pg_temp.rel('50ae0292-a3cd-5e5d-bdde-24774466cb0b', 'db85428a-e4c4-5b25-9493-642b23431fae', 'parent');
  perform pg_temp.rel('aead0438-df75-5c73-bb4c-19cc5e109237', 'db85428a-e4c4-5b25-9493-642b23431fae', 'parent');
  perform pg_temp.rel('50ae0292-a3cd-5e5d-bdde-24774466cb0b', 'b916cc90-8c48-5314-b9d0-3ea480765ca5', 'parent');
  perform pg_temp.rel('aead0438-df75-5c73-bb4c-19cc5e109237', 'b916cc90-8c48-5314-b9d0-3ea480765ca5', 'parent');
  perform pg_temp.rel('50ae0292-a3cd-5e5d-bdde-24774466cb0b', '5c0cce7b-8fdc-55d6-8f53-77e5b5900c80', 'parent');
  perform pg_temp.rel('aead0438-df75-5c73-bb4c-19cc5e109237', '5c0cce7b-8fdc-55d6-8f53-77e5b5900c80', 'parent');
  perform pg_temp.rel('580cda52-6706-49c2-aef9-a37eeca9fa40', '1bccc7d5-2a63-5028-88d1-065f0d039276', 'parent');
  perform pg_temp.rel('39dd3223-8155-4300-ba98-14e9fe59f237', '1bccc7d5-2a63-5028-88d1-065f0d039276', 'parent');
  perform pg_temp.rel('1488e049-c938-457c-b746-3e32fe4539c5', '8a8fadf5-4de1-55f1-aa9c-b9aba93a71c3', 'parent');
  perform pg_temp.rel('23c92a87-0e99-45c9-b149-e5887bc511f6', '8a8fadf5-4de1-55f1-aa9c-b9aba93a71c3', 'parent');
  perform pg_temp.rel('276d911e-e2b6-4170-9834-8b358c961430', 'f58d5a0f-54c7-5f04-8682-5ff817880d18', 'spouse');
  perform pg_temp.rel('276d911e-e2b6-4170-9834-8b358c961430', '29d032cf-bfa9-51b3-b5fa-63bcece05853', 'parent');
  perform pg_temp.rel('f58d5a0f-54c7-5f04-8682-5ff817880d18', '29d032cf-bfa9-51b3-b5fa-63bcece05853', 'parent');
  perform pg_temp.rel('276d911e-e2b6-4170-9834-8b358c961430', '7c66d88e-219b-51f1-81a0-8e4955ec26c8', 'parent');
  perform pg_temp.rel('f58d5a0f-54c7-5f04-8682-5ff817880d18', '7c66d88e-219b-51f1-81a0-8e4955ec26c8', 'parent');
  perform pg_temp.rel('7c66d88e-219b-51f1-81a0-8e4955ec26c8', 'e414da9b-4492-586c-b5cc-53ca54ab4bc7', 'spouse');
  perform pg_temp.rel('7c66d88e-219b-51f1-81a0-8e4955ec26c8', 'e74c9a1b-b487-5f11-8810-39f58b735c2d', 'parent');
  perform pg_temp.rel('e414da9b-4492-586c-b5cc-53ca54ab4bc7', 'e74c9a1b-b487-5f11-8810-39f58b735c2d', 'parent');
  update public.genealogy_members set pos_x = 490, pos_y = 640 where id = '66d515fd-0f65-48b5-b005-bbc9e956ca7f';
  update public.genealogy_members set pos_x = 980, pos_y = 640 where id = 'e96686c9-258e-4670-a8c9-e971d022aee6';
  update public.genealogy_members set pos_x = 3006, pos_y = 0 where id = '3fe14ec2-b6ea-4efe-a755-4a8dc49511cc';
  update public.genealogy_members set pos_x = 3496, pos_y = 0 where id = '2cafb38a-4169-4a99-9684-788ecba27725';
  update public.genealogy_members set pos_x = 245, pos_y = 1280 where id = '0cc73d16-6bf1-42ca-874e-034d83024020';
  update public.genealogy_members set pos_x = 2655, pos_y = 1920 where id = '1488e049-c938-457c-b746-3e32fe4539c5';
  update public.genealogy_members set pos_x = 3145, pos_y = 1920 where id = '23c92a87-0e99-45c9-b149-e5887bc511f6';
  update public.genealogy_members set pos_x = 5864, pos_y = 640 where id = '969467e8-d81c-4c44-81c2-56dbbd00ad51';
  update public.genealogy_members set pos_x = 3022, pos_y = 1280 where id = '580cda52-6706-49c2-aef9-a37eeca9fa40';
  update public.genealogy_members set pos_x = 2532, pos_y = 1280 where id = '39dd3223-8155-4300-ba98-14e9fe59f237';
  update public.genealogy_members set pos_x = 3884, pos_y = 640 where id = '276d911e-e2b6-4170-9834-8b358c961430';
  update public.genealogy_members set pos_x = 1970, pos_y = 640 where id = 'fd12e9db-5595-4260-a321-ca55a7857ec6';
  update public.genealogy_members set pos_x = 4455, pos_y = 1920 where id = 'e74c9a1b-b487-5f11-8810-39f58b735c2d';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('aead0438-df75-5c73-bb4c-19cc5e109237', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 1288, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('b47f1c54-e013-530c-94a0-60b20ce47c19', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 155, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('e414da9b-4492-586c-b5cc-53ca54ab4bc7', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 4700, 1280, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('5a2dc471-f11e-4d83-a861-7b5d21febeac', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 0, 640, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('fd5a4906-a4ee-5a0d-827f-cfbcd1818951', 'entry', 'ae0dd55b-e688-4bff-8917-4df1e9786a95', 4945, 1920, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v78 : % membres ajoutés.', 18;
end $$;
