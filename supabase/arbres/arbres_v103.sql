-- arbres_v103.sql — Bulgarie — suite des souverains (premier empire, Asen, Terter, Chichman)
-- Ajouts uniquement : rien n'est supprimé ni modifié (sauf la position des cartes des arbres listés « repositionnés »).
-- Complète les arbres Krum, Asen et Chichman (créés en v46) et crée « Terter ». Rien n'est supprimé.
-- Source : Wikipédia en anglais, « List of Bulgarian monarchs » (noms, filiations et règnes). La page ne donne aucune date de vie : seules les années de mort sûres sont renseignées (d'après les règnes), les naissances sont laissées vides plutôt qu'inventées (signalé).
-- Non fait : Asparoukh et Tervel, Siméon-Samuel (Cométopoules), prétendants de Vidin, Mitso Asen, Smilets, Ivaylo, Tchaka (maisons non reliées à ces arbres), épouses.
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
  if exists (select 1 from public.genealogy_members where id = '74d91cf2-024c-5926-adde-2874af326b6c') then raise exception 'Script déjà exécuté : rien n''a été fait.'; end if;
  select count(*) into k from public.genealogy_members where id in ('37c8c29c-0573-5fac-9ed7-5a2d3c99d47e','aafcd9a8-3eef-56f2-9d9b-619b71d18abb','d39ce982-b84f-50d1-91ea-5d6e68d174b7','da935432-8ffb-5434-959d-c2cb6e130d9e','f50fa150-8051-5a38-b9a2-acc79937578a');
  if k <> 5 then raise exception 'Membres préexistants manquants (% sur 5) : un script précédent n''a pas été exécuté ? Rien n''a été fait.', k; end if;
  select count(*) into k from public.dossier_entries where id = '0a72b913-7a9e-52cf-8758-69cca71db95b' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Krum introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Asen introuvable : rien n''a été fait.'; end if;
  select count(*) into k from public.dossier_entries where id = '34b77462-0e0c-59cc-a278-220823c60067' and type = 'genealogy';
  if k <> 1 then raise exception 'Arbre Chichman introuvable : rien n''a été fait.'; end if;
  -- Arbre « Terter » (BGR)
  select id into top from public.dossier_sections where owner_type = 'country' and owner_id = 'BGR' and title = 'Dynastie' and parent_section_id is null and category_id = cat_id;
  if top is null then raise exception 'Section Dynastie introuvable pour BGR : rien n''a été fait.'; end if;
  select id into sec from public.dossier_sections where parent_section_id = top and title = 'Terter';
  if sec is null then
    insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, created_by)
    values ('80144df7-e7cc-52c7-904f-619826fd264b', cat_id, 'country', 'BGR', top, 'Terter', (select coalesce(max(position), -1) + 1 from public.dossier_sections where parent_section_id = top), admin_id);
    sec := '80144df7-e7cc-52c7-904f-619826fd264b';
  end if;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, created_by)
  values ('90949041-47fc-54f2-a8be-fb78a454b5ef', 'country', 'BGR', 'genealogy', 'Terter', cat_id, sec, admin_id);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('74d91cf2-024c-5926-adde-2874af326b6c', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Malamir', null, null, 836, 'Khan de Bulgarie (831-836)', 'Krum', 1402, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('440181e1-4e87-5732-929a-77fcb5191c60', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Zvinitsa', null, null, null, 'Père de Presian Ier', 'Krum', 839, 1280, admin_id, false);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ae40f5c1-34f6-56ad-b3be-f025b552d1a4', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Presian Ier', null, null, 852, 'Khan de Bulgarie (836-852)', 'Krum', 839, 1920, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('8b2ab3fc-4c64-5dd7-b6c0-ce2c5dbf4181', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Vladimir', null, null, 893, 'Knèze de Bulgarie (889-893)', 'Krum', 990, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('190248c5-d194-57dd-b9ac-5444b4042147', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Boris II', null, null, null, 'Tsar de Bulgarie (969-977)', 'Krum', 12, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b79f29e6-c1c9-5dc2-bdb8-0ad9082031b5', 'entry', '0a72b913-7a9e-52cf-8758-69cca71db95b', 'Roman', null, null, 997, 'Tsar de Bulgarie (977-997)', 'Krum', 512, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('57f11593-7b96-55dc-b52d-d97476b154e7', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 'Ivan Asen Ier', null, null, 1196, 'Tsar de Bulgarie (v. 1188-1196)', 'Asen', 490, 3200, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e7e77612-778e-578a-a2a5-a731de8eb8d7', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 'Pierre II (Théodore-Pierre)', null, null, 1197, 'Tsar de Bulgarie (1185-1197)', 'Asen', 2980, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('c2eba8a9-4c7e-5fb9-8d8b-cd84c702a422', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 'Kaloyan', null, null, 1207, 'Tsar de Bulgarie (1196-1207)', 'Asen', 3980, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('0a84240a-3453-59a7-98a2-417b5a70ca06', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 'Boril', null, null, null, 'Tsar de Bulgarie (1207-1218), neveu de Kaloyan', 'Asen', 4980, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('ef9c7b74-1d48-5a39-b8aa-66e26048893d', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 'Michel Asen Ier', null, null, 1256, 'Tsar de Bulgarie (1246-1256)', 'Asen', 637, 4480, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('e69e8f0a-003b-50d3-8326-e0d764ab0480', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 'Constantin Ier Tikh Asen', null, null, 1277, 'Tsar de Bulgarie (1257-1277)', 'Asen', 1980, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('24a47649-a60c-5967-8edd-92e0ea08bbd6', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 'Michel Asen II', null, null, 1279, 'Tsar de Bulgarie (1277-1279)', 'Asen', 1980, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('f4b44cc8-992b-55c0-aad7-559c52047eae', 'entry', '90949041-47fc-54f2-a8be-fb78a454b5ef', 'Georges Ier Terter', null, null, 1308, 'Tsar de Bulgarie (1280-1292)', 'Terter', 0, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('83920605-6684-575f-bbac-992cf080c9b2', 'entry', '90949041-47fc-54f2-a8be-fb78a454b5ef', 'Théodore Svetoslav', null, null, 1322, 'Tsar de Bulgarie (1300-1322)', 'Terter', 0, 640, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('3cc46fc8-25a2-521c-9098-cfc1e86f6a16', 'entry', '90949041-47fc-54f2-a8be-fb78a454b5ef', 'Georges II Terter', null, null, 1323, 'Tsar de Bulgarie (1322-1323)', 'Terter', 0, 1280, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('b4c2e461-552c-55c3-b5bb-a2aa573965c2', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 'Michel III Chichman', null, null, 1330, 'Tsar de Bulgarie (1323-1330), mort à Velbazhd', 'Chichman', 4970, 0, admin_id, true);
  insert into public.genealogy_members (id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, pos_x, pos_y, created_by, is_leader) values ('954e6f16-bf9c-5582-8136-223c62b814c8', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 'Ivan Stéphane', null, null, 1373, 'Tsar de Bulgarie (1330-1331)', 'Chichman', 4970, 640, admin_id, true);
  perform set_config('app.admin', admin_id::text, true);
  create function pg_temp.rel(a uuid, b uuid, t text) returns void language plpgsql as $f$
  begin
    if exists (select 1 from public.genealogy_relations where relation_type = t and ((member_a_id = a and member_b_id = b) or (t = 'spouse' and member_a_id = b and member_b_id = a))) then return; end if;
    insert into public.genealogy_relations (member_a_id, member_b_id, relation_type, created_by) values (a, b, t, current_setting('app.admin', true)::uuid);
  end $f$;
  perform pg_temp.rel('f50fa150-8051-5a38-b9a2-acc79937578a', '74d91cf2-024c-5926-adde-2874af326b6c', 'parent');
  perform pg_temp.rel('f50fa150-8051-5a38-b9a2-acc79937578a', '440181e1-4e87-5732-929a-77fcb5191c60', 'parent');
  perform pg_temp.rel('440181e1-4e87-5732-929a-77fcb5191c60', 'ae40f5c1-34f6-56ad-b3be-f025b552d1a4', 'parent');
  perform pg_temp.rel('ae40f5c1-34f6-56ad-b3be-f025b552d1a4', 'd39ce982-b84f-50d1-91ea-5d6e68d174b7', 'parent');
  perform pg_temp.rel('d39ce982-b84f-50d1-91ea-5d6e68d174b7', '8b2ab3fc-4c64-5dd7-b6c0-ce2c5dbf4181', 'parent');
  perform pg_temp.rel('aafcd9a8-3eef-56f2-9d9b-619b71d18abb', '190248c5-d194-57dd-b9ac-5444b4042147', 'parent');
  perform pg_temp.rel('aafcd9a8-3eef-56f2-9d9b-619b71d18abb', 'b79f29e6-c1c9-5dc2-bdb8-0ad9082031b5', 'parent');
  perform pg_temp.rel('57f11593-7b96-55dc-b52d-d97476b154e7', '37c8c29c-0573-5fac-9ed7-5a2d3c99d47e', 'parent');
  perform pg_temp.rel('57f11593-7b96-55dc-b52d-d97476b154e7', 'e7e77612-778e-578a-a2a5-a731de8eb8d7', 'family');
  perform pg_temp.rel('57f11593-7b96-55dc-b52d-d97476b154e7', 'c2eba8a9-4c7e-5fb9-8d8b-cd84c702a422', 'family');
  perform pg_temp.rel('c2eba8a9-4c7e-5fb9-8d8b-cd84c702a422', '0a84240a-3453-59a7-98a2-417b5a70ca06', 'family');
  perform pg_temp.rel('37c8c29c-0573-5fac-9ed7-5a2d3c99d47e', 'ef9c7b74-1d48-5a39-b8aa-66e26048893d', 'parent');
  perform pg_temp.rel('e69e8f0a-003b-50d3-8326-e0d764ab0480', '24a47649-a60c-5967-8edd-92e0ea08bbd6', 'parent');
  perform pg_temp.rel('37c8c29c-0573-5fac-9ed7-5a2d3c99d47e', 'e69e8f0a-003b-50d3-8326-e0d764ab0480', 'family');
  perform pg_temp.rel('f4b44cc8-992b-55c0-aad7-559c52047eae', '83920605-6684-575f-bbac-992cf080c9b2', 'parent');
  perform pg_temp.rel('83920605-6684-575f-bbac-992cf080c9b2', '3cc46fc8-25a2-521c-9098-cfc1e86f6a16', 'parent');
  perform pg_temp.rel('b4c2e461-552c-55c3-b5bb-a2aa573965c2', '954e6f16-bf9c-5582-8136-223c62b814c8', 'parent');
  perform pg_temp.rel('b4c2e461-552c-55c3-b5bb-a2aa573965c2', 'da935432-8ffb-5434-959d-c2cb6e130d9e', 'family');
  update public.genealogy_members set pos_x = 1190, pos_y = 0 where id = '442d8814-0367-5532-b1a7-bc2f01010a67';
  update public.genealogy_members set pos_x = 1190, pos_y = 640 where id = 'f50fa150-8051-5a38-b9a2-acc79937578a';
  update public.genealogy_members set pos_x = 839, pos_y = 2560 where id = 'd39ce982-b84f-50d1-91ea-5d6e68d174b7';
  update public.genealogy_members set pos_x = 349, pos_y = 2560 where id = '51083024-15ba-53ee-81b4-55f160a1c5a2';
  update public.genealogy_members set pos_x = 490, pos_y = 3200 where id = '9c7ad2d4-7814-5077-91b1-b80ae6f46059';
  update public.genealogy_members set pos_x = 0, pos_y = 3200 where id = '70f78979-070d-586e-9fa7-ad62eb1ea3d4';
  update public.genealogy_members set pos_x = 245, pos_y = 3840 where id = 'aafcd9a8-3eef-56f2-9d9b-619b71d18abb';
  update public.genealogy_members set pos_x = 735, pos_y = 3840 where id = '7a6f0c3c-c256-5183-be38-2c4c2c78c401';
  update public.genealogy_members set pos_x = 490, pos_y = 3840 where id = '37c8c29c-0573-5fac-9ed7-5a2d3c99d47e';
  update public.genealogy_members set pos_x = 980, pos_y = 3840 where id = '8efec647-51a7-5073-a9ab-c9146a28449b';
  update public.genealogy_members set pos_x = 137, pos_y = 4480 where id = '4a442e40-84d6-578f-ad83-fea3518acb37';
  update public.genealogy_members set pos_x = 1127, pos_y = 5760 where id = 'da935432-8ffb-5434-959d-c2cb6e130d9e';
  update public.genealogy_members set pos_x = 1617, pos_y = 5760 where id = 'ddc60b67-d62a-5419-9f61-e10bf8227483';
  update public.genealogy_members set pos_x = 637, pos_y = 5760 where id = '2989a941-71dc-5d94-937d-6951289fe316';
  update public.genealogy_members set pos_x = 1480, pos_y = 6400 where id = 'bed0f6f7-104b-5a4f-84b0-83b74fa70c7c';
  update public.genealogy_members set pos_x = 2480, pos_y = 6400 where id = 'fa785a13-2507-5f82-b1cb-9cb239a2606e';
  update public.genealogy_members set pos_x = 1980, pos_y = 6400 where id = '7210ef6c-b8b3-5423-a686-4e3845df557d';
  update public.genealogy_members set pos_x = 490, pos_y = 6400 where id = 'e7974fe1-0552-5358-b2f4-135dd0d7e6e1';
  update public.genealogy_members set pos_x = 0, pos_y = 6400 where id = '340ddfac-8ec9-570a-ad62-0bd13c45d01a';
  update public.genealogy_members set pos_x = 3480, pos_y = 5760 where id = '047dd9dd-229b-5319-a101-fb17caba3388';
  update public.genealogy_members set pos_x = 1980, pos_y = 7040 where id = '21d8f861-933c-5c97-b0e4-766a8b1c4589';
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('f2b2fe73-515d-5ef7-a650-f5479d515f6d', 'entry', '4870d4cf-cb2b-5ffe-9af9-f0f85752a59a', 0, 3840, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('3a415b95-e9e3-5b4a-aed8-3e026ef3fa5f', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 1617, 5120, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('4db92756-efa0-5e81-8ead-8b72213cc88a', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 980, 6400, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('4156a461-5d32-52a9-af05-6419740fdc26', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 3970, 5760, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('362d9580-e6cf-5184-b533-930e33c87ded', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 3480, 6400, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  insert into public.genealogy_foreign_states (member_id, owner_type, owner_id, pos_x, pos_y, is_leader, pinned) values ('2c808656-ddf2-5071-a5c6-f99d11b60202', 'entry', '34b77462-0e0c-59cc-a278-220823c60067', 2470, 7040, false, true) on conflict (member_id, owner_type, owner_id) do update set pos_x = excluded.pos_x, pos_y = excluded.pos_y, pinned = true;
  raise notice 'schema_v103 : % membres ajoutés.', 18;
end $$;
