-- ============================================================
-- Atlas Géopolitique — frises_v1 (2026-11-01) : EXEMPLE « Histoire de France »
--
-- Demande de Martin (2026-11-01) : un exemple concret pour voir ce que donne
-- le système de frises en poupées russes. Ce script CRÉE DES DONNÉES (aucune
-- table n'est modifiée, rien n'est supprimé) :
--   * niveau 1 — frise « Histoire de France » (dossier Histoire de la France) :
--     14 grandes périodes, 11 points (+ la prise de la Bastille remontée) ;
--   * niveau 2 — sous-frise de la période « Révolution française » :
--     4 périodes (Constituante, Législative, Convention, Directoire), 13 points
--     + 5 points remontés de la Convention ;
--   * niveau 3 — sous-frise de la période « Convention nationale » :
--     3 périodes (girondine, montagnarde, thermidorienne), 16 points.
-- Chaque point a une fiche VIDE (au nom de l'événement) rangée dans la
-- sous-catégorie de sa période, avec ses sources dans le champ « sources ».
-- Plusieurs points sont placés sur DEUX frises (même événement, pas une copie).
-- Sources de chaque date : docs/sources/frises.md.
--
-- Nécessite schema_v27 à v31 (déjà exécutés). Idempotent : les identifiants sont
-- fixes, une 2e exécution ne duplique rien. Aucune donnée existante n'est touchée.
-- Pour tout retirer : supprimer la frise « Histoire de France » (France > Histoire) et ses
-- sous-catégories-périodes depuis l'appli.
--
-- À coller dans Supabase → SQL Editor → New query → Run.
-- ============================================================

do $$
declare
  v_cat uuid;
begin
  select id into v_cat from public.dossier_categories
    where name = 'Histoire' and space = 'country' limit 1;
  if v_cat is null then
    raise exception 'Catégorie « Histoire » introuvable : exemple non créé.';
  end if;
  if not exists (select 1 from public.countries where id = 'FRA') then
    raise exception 'Pays FRA introuvable : exemple non créé.';
  end if;

  -- ===== Niveau 1 : Histoire de France =====
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', 'country', 'FRA', 'frise', 'Histoire de France', v_cat, null, '{}', '[]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('de5c629c-315f-530f-a38f-ae885cf668e4', v_cat, 'country', 'FRA', null, 'Gaule romaine', 0, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#7f8c8d', -58, null, null, 486, null, null)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('282c049a-3d8e-51ef-8ae6-c56a08c9cd81', v_cat, 'country', 'FRA', null, 'Mérovingiens', 1, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#8e44ad', 486, null, null, 751, null, null)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('6f905e4d-5000-5e81-b6d3-43cdd25df3f9', v_cat, 'country', 'FRA', null, 'Carolingiens', 2, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#2980b9', 751, null, null, 987, null, null)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('87d66cff-89f1-5828-b557-685fe356812c', v_cat, 'country', 'FRA', null, 'Capétiens directs', 3, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#16a085', 987, null, null, 1328, null, null)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('9d8ad0b1-d55c-5f64-aeb8-65c6175de927', v_cat, 'country', 'FRA', null, 'Valois', 4, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#d4ac0d', 1328, null, null, 1589, null, null)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('8f443aa9-7bc4-5148-9572-957232b5943f', v_cat, 'country', 'FRA', null, 'Bourbons (Ancien Régime)', 5, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#e67e22', 1589, null, null, 1789, 5, 5)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('a43d1576-b25a-5de4-bf84-dcdc259ae93d', v_cat, 'country', 'FRA', null, 'Révolution française', 6, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#c0392b', 1789, 5, 5, 1799, 11, 9)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('1a4575a8-e0a7-5a2c-871d-bfe767eec0c6', v_cat, 'country', 'FRA', null, 'Consulat et Premier Empire', 7, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#a04000', 1799, 11, 9, 1814, null, null)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('06a67556-47a3-5d1f-8f34-853303863b13', v_cat, 'country', 'FRA', null, 'Restauration et monarchie de Juillet', 8, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#5d6d7e', 1814, null, null, 1848, null, null)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('17577b30-a2bd-5bfa-bc72-e02430a3f013', v_cat, 'country', 'FRA', null, 'Deuxième République et Second Empire', 9, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#27ae60', 1848, null, null, 1870, null, null)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('2b2412b4-c8c2-520d-a009-7568a7ef5ea7', v_cat, 'country', 'FRA', null, 'Troisième République', 10, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#2471a3', 1870, null, null, 1940, null, null)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('320546b4-92dd-594d-852f-d7fadbbeb12e', v_cat, 'country', 'FRA', null, 'État français et Libération', 11, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#34495e', 1940, null, null, 1946, null, null)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('8ba34d4f-8eed-5ec8-97fc-fcb6d760249d', v_cat, 'country', 'FRA', null, 'Quatrième République', 12, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#af7ac5', 1946, null, null, 1958, null, null)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('e9c6ede1-0d1a-5145-b9d3-cecaa4e4e001', v_cat, 'country', 'FRA', null, 'Cinquième République', 13, 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', false, '#1abc9c', 1958, null, null, null, null, null)
  on conflict (id) do nothing;

  -- ===== Niveau 2 : Révolution française =====
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', 'country', 'FRA', 'frise', 'Révolution française', v_cat, 'a43d1576-b25a-5de4-bf84-dcdc259ae93d', '{}', '[]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('72c27cc1-341d-594b-a4ed-c38c6cc73d3f', v_cat, 'country', 'FRA', 'a43d1576-b25a-5de4-bf84-dcdc259ae93d', 'États généraux et Assemblée constituante', 0, '33492926-05ec-5a02-b2f8-a5a8afd379b6', false, '#e67e22', 1789, 5, 5, 1791, 10, 1)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('04e1f939-e2a0-5b6e-88f7-81091c85a2cf', v_cat, 'country', 'FRA', 'a43d1576-b25a-5de4-bf84-dcdc259ae93d', 'Assemblée législative', 1, '33492926-05ec-5a02-b2f8-a5a8afd379b6', false, '#d4ac0d', 1791, 10, 1, 1792, 9, 21)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('ec97a884-95fb-59e5-968c-ea5c2c649826', v_cat, 'country', 'FRA', 'a43d1576-b25a-5de4-bf84-dcdc259ae93d', 'Convention nationale', 2, '33492926-05ec-5a02-b2f8-a5a8afd379b6', false, '#c0392b', 1792, 9, 21, 1795, 10, 26)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('a4cf3e25-64bb-57a9-82b8-de859c6408a4', v_cat, 'country', 'FRA', 'a43d1576-b25a-5de4-bf84-dcdc259ae93d', 'Directoire', 3, '33492926-05ec-5a02-b2f8-a5a8afd379b6', false, '#5d6d7e', 1795, 10, 26, 1799, 11, 9)
  on conflict (id) do nothing;

  -- ===== Niveau 3 : Convention nationale =====
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', 'country', 'FRA', 'frise', 'Convention nationale', v_cat, 'ec97a884-95fb-59e5-968c-ea5c2c649826', '{}', '[]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('a15ef7b4-7e25-5b99-abb5-f890ae39f49c', v_cat, 'country', 'FRA', 'ec97a884-95fb-59e5-968c-ea5c2c649826', 'Convention girondine', 0, '887acb7d-dd20-583a-a5a7-7abd5d56f6cd', false, '#2980b9', 1792, 9, 21, 1793, 6, 2)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('20858d62-8c77-56bf-b388-f6ff46106609', v_cat, 'country', 'FRA', 'ec97a884-95fb-59e5-968c-ea5c2c649826', 'Convention montagnarde', 1, '887acb7d-dd20-583a-a5a7-7abd5d56f6cd', false, '#c0392b', 1793, 6, 2, 1794, 7, 27)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_end_year, period_end_month, period_end_day)
  values ('735d89fe-8c62-52a4-ac46-5902c8d015ba', v_cat, 'country', 'FRA', 'ec97a884-95fb-59e5-968c-ea5c2c649826', 'Convention thermidorienne', 2, '887acb7d-dd20-583a-a5a7-7abd5d56f6cd', false, '#16a085', 1794, 7, 27, 1795, 10, 26)
  on conflict (id) do nothing;

  -- ===== Points, fiches et placements =====
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('848767d7-ce9a-5521-a8d7-ac213f0d41a7', 'Bataille d''Alésia', -52, null, null, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('bf7141eb-24a6-5d00-8f78-d58f3b2d1d26', 'country', 'FRA', 'text', 'Bataille d''Alésia', v_cat, 'de5c629c-315f-530f-a38f-ae885cf668e4', '{}', '[{"label": "Wikipédia — Gaule romaine", "url": "https://fr.wikipedia.org/wiki/Gaule_romaine"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('bf7141eb-24a6-5d00-8f78-d58f3b2d1d26', '848767d7-ce9a-5521-a8d7-ac213f0d41a7') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', '848767d7-ce9a-5521-a8d7-ac213f0d41a7', 'up', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('ca058cc3-93f3-5a34-a73b-bbf3f563189d', 'Bataille de Soissons', 486, null, null, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('b66a04ed-8e46-50a7-9cbe-dcbe944370c1', 'country', 'FRA', 'text', 'Bataille de Soissons', v_cat, '282c049a-3d8e-51ef-8ae6-c56a08c9cd81', '{}', '[{"label": "Wikipédia — Gaule romaine", "url": "https://fr.wikipedia.org/wiki/Gaule_romaine"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('b66a04ed-8e46-50a7-9cbe-dcbe944370c1', 'ca058cc3-93f3-5a34-a73b-bbf3f563189d') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', 'ca058cc3-93f3-5a34-a73b-bbf3f563189d', 'down', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('b4e0d5ed-043f-5f60-9c21-8af0f54e1780', 'Pépin le Bref enferme Childéric III (fin des Mérovingiens)', 751, null, null, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('e13b6edb-aa17-56ac-917a-2debc83d161c', 'country', 'FRA', 'text', 'Pépin le Bref enferme Childéric III (fin des Mérovingiens)', v_cat, '6f905e4d-5000-5e81-b6d3-43cdd25df3f9', '{}', '[{"label": "Wikipédia — Mérovingiens", "url": "https://fr.wikipedia.org/wiki/M%C3%A9rovingiens"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('e13b6edb-aa17-56ac-917a-2debc83d161c', 'b4e0d5ed-043f-5f60-9c21-8af0f54e1780') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', 'b4e0d5ed-043f-5f60-9c21-8af0f54e1780', 'up', (select id from public.timeline_categories where name = 'Dynastie' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('1860f7c9-6782-5e7d-8ff8-10387d016ec2', 'Couronnement impérial de Charlemagne', 800, 12, 25, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('9af0d39b-4961-53b1-a7d3-67a1f823be1a', 'country', 'FRA', 'text', 'Couronnement impérial de Charlemagne', v_cat, '6f905e4d-5000-5e81-b6d3-43cdd25df3f9', '{}', '[{"label": "Wikipédia — Charlemagne", "url": "https://fr.wikipedia.org/wiki/Charlemagne"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('9af0d39b-4961-53b1-a7d3-67a1f823be1a', '1860f7c9-6782-5e7d-8ff8-10387d016ec2') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', '1860f7c9-6782-5e7d-8ff8-10387d016ec2', 'down', (select id from public.timeline_categories where name = 'Dynastie' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('5d98c88a-782c-5307-9c6e-36bb18016e0d', 'Hugues Capet, début des Capétiens', 987, null, null, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('629d90d4-be52-55eb-b8ae-08629c38f46c', 'country', 'FRA', 'text', 'Hugues Capet, début des Capétiens', v_cat, '87d66cff-89f1-5828-b557-685fe356812c', '{}', '[{"label": "Wikipédia — Capétiens directs", "url": "https://fr.wikipedia.org/wiki/Cap%C3%A9tiens_directs"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('629d90d4-be52-55eb-b8ae-08629c38f46c', '5d98c88a-782c-5307-9c6e-36bb18016e0d') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', '5d98c88a-782c-5307-9c6e-36bb18016e0d', 'up', (select id from public.timeline_categories where name = 'Dynastie' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year, date_end_month, date_end_day, date_end_circa) values ('70b7f0f8-2a97-5c8b-b1f8-b54a6821a8b7', 'Guerre de Cent Ans', 1337, null, null, false, 1453, null, null, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('b2e53bad-b81c-5bc2-8824-cb3be8826f77', 'country', 'FRA', 'text', 'Guerre de Cent Ans', v_cat, '9d8ad0b1-d55c-5f64-aeb8-65c6175de927', '{}', '[{"label": "Wikipédia — Guerre de Cent Ans", "url": "https://fr.wikipedia.org/wiki/Guerre_de_Cent_Ans"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('b2e53bad-b81c-5bc2-8824-cb3be8826f77', '70b7f0f8-2a97-5c8b-b1f8-b54a6821a8b7') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', '70b7f0f8-2a97-5c8b-b1f8-b54a6821a8b7', 'down', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('1cdac680-7cc2-55ca-a1dc-81943dbf6470', 'Édit de Nantes', 1598, null, null, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('b5be7ff6-1762-5a91-843e-49fa80c47b9d', 'country', 'FRA', 'text', 'Édit de Nantes', v_cat, '8f443aa9-7bc4-5148-9572-957232b5943f', '{}', '[{"label": "Wikipédia — Édit de Nantes", "url": "https://fr.wikipedia.org/wiki/%C3%89dit_de_Nantes"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('b5be7ff6-1762-5a91-843e-49fa80c47b9d', '1cdac680-7cc2-55ca-a1dc-81943dbf6470') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', '1cdac680-7cc2-55ca-a1dc-81943dbf6470', 'up', (select id from public.timeline_categories where name = 'Religion' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('b9f196b6-4801-5e39-afec-641da98239d0', 'Révocation de l''édit de Nantes (édit de Fontainebleau)', 1685, 10, null, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('961105ff-aed2-5ef1-94dd-e95732a909c9', 'country', 'FRA', 'text', 'Révocation de l''édit de Nantes (édit de Fontainebleau)', v_cat, '8f443aa9-7bc4-5148-9572-957232b5943f', '{}', '[{"label": "Wikipédia — Édit de Nantes", "url": "https://fr.wikipedia.org/wiki/%C3%89dit_de_Nantes"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('961105ff-aed2-5ef1-94dd-e95732a909c9', 'b9f196b6-4801-5e39-afec-641da98239d0') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', 'b9f196b6-4801-5e39-afec-641da98239d0', 'down', (select id from public.timeline_categories where name = 'Religion' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year, date_end_month, date_end_day, date_end_circa) values ('3eb2b0f2-6dbb-5264-9e17-5b57589d0f26', 'Première Guerre mondiale', 1914, null, null, false, 1918, null, null, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('bba89647-678b-5e71-bcf4-769b1db6cf38', 'country', 'FRA', 'text', 'Première Guerre mondiale', v_cat, '2b2412b4-c8c2-520d-a009-7568a7ef5ea7', '{}', '[{"label": "Wikipédia — Première Guerre mondiale", "url": "https://fr.wikipedia.org/wiki/Premi%C3%A8re_Guerre_mondiale"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('bba89647-678b-5e71-bcf4-769b1db6cf38', '3eb2b0f2-6dbb-5264-9e17-5b57589d0f26') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', '3eb2b0f2-6dbb-5264-9e17-5b57589d0f26', 'up', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('1f4a6996-5a93-5cda-bcbb-030b38d8babe', 'Appel du 18 juin 1940', 1940, 6, 18, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('40850e53-99c8-5dea-91e7-8c4febb1138d', 'country', 'FRA', 'text', 'Appel du 18 juin 1940', v_cat, '320546b4-92dd-594d-852f-d7fadbbeb12e', '{}', '[{"label": "Wikipédia — Appel du 18 Juin", "url": "https://fr.wikipedia.org/wiki/Appel_du_18_Juin"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('40850e53-99c8-5dea-91e7-8c4febb1138d', '1f4a6996-5a93-5cda-bcbb-030b38d8babe') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', '1f4a6996-5a93-5cda-bcbb-030b38d8babe', 'down', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('7d3ae92a-c03a-511a-87a3-4e15d5c0fc00', 'Référendum sur la Constitution de la Ve République', 1958, 9, 28, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('ddf9af1b-5910-57b6-8ca4-b37c7bb68577', 'country', 'FRA', 'text', 'Référendum sur la Constitution de la Ve République', v_cat, 'e9c6ede1-0d1a-5145-b9d3-cecaa4e4e001', '{}', '[{"label": "Wikipédia — Cinquième République (France)", "url": "https://fr.wikipedia.org/wiki/Cinqui%C3%A8me_R%C3%A9publique_(France)"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('ddf9af1b-5910-57b6-8ca4-b37c7bb68577', '7d3ae92a-c03a-511a-87a3-4e15d5c0fc00') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', '7d3ae92a-c03a-511a-87a3-4e15d5c0fc00', 'up', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('85ef899f-e951-54fc-a232-a94730dda025', 'Ouverture des États généraux', 1789, 5, 5, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('3b8e33a9-867c-59be-acee-7357166acb32', 'country', 'FRA', 'text', 'Ouverture des États généraux', v_cat, '72c27cc1-341d-594b-a4ed-c38c6cc73d3f', '{}', '[{"label": "Wikipédia — Révolution française", "url": "https://fr.wikipedia.org/wiki/R%C3%A9volution_fran%C3%A7aise"}, {"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('3b8e33a9-867c-59be-acee-7357166acb32', '85ef899f-e951-54fc-a232-a94730dda025') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', '85ef899f-e951-54fc-a232-a94730dda025', 'up', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('f95047e5-18b9-5450-a1ad-4144eb27bd26', 'Serment du Jeu de paume', 1789, 6, 20, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('73d6785d-2258-5552-af12-7208582b73d2', 'country', 'FRA', 'text', 'Serment du Jeu de paume', v_cat, '72c27cc1-341d-594b-a4ed-c38c6cc73d3f', '{}', '[{"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('73d6785d-2258-5552-af12-7208582b73d2', 'f95047e5-18b9-5450-a1ad-4144eb27bd26') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', 'f95047e5-18b9-5450-a1ad-4144eb27bd26', 'down', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('2365b170-4bc1-5430-8c17-71ad7bd3f208', 'Prise de la Bastille', 1789, 7, 14, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('a4883c69-500b-5142-985f-d38dee62a5d5', 'country', 'FRA', 'text', 'Prise de la Bastille', v_cat, '72c27cc1-341d-594b-a4ed-c38c6cc73d3f', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}, {"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('a4883c69-500b-5142-985f-d38dee62a5d5', '2365b170-4bc1-5430-8c17-71ad7bd3f208') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', '2365b170-4bc1-5430-8c17-71ad7bd3f208', 'up', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('ba59ec79-faa2-5dd9-b01b-5a9107867b0a', '2365b170-4bc1-5430-8c17-71ad7bd3f208', 'up', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('162ec7c4-c7de-5da7-aaba-39fe86218388', 'Nuit du 4 août : abolition des privilèges', 1789, 8, 4, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('33a1e03c-837c-5ab3-81b7-4329cd89dfa2', 'country', 'FRA', 'text', 'Nuit du 4 août : abolition des privilèges', v_cat, '72c27cc1-341d-594b-a4ed-c38c6cc73d3f', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}, {"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('33a1e03c-837c-5ab3-81b7-4329cd89dfa2', '162ec7c4-c7de-5da7-aaba-39fe86218388') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', '162ec7c4-c7de-5da7-aaba-39fe86218388', 'down', (select id from public.timeline_categories where name = 'Économie et société' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('5ef0bfdc-3169-50a1-b935-f482e76b592b', 'Déclaration des droits de l''homme et du citoyen', 1789, 8, 26, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('f7d287ba-e06c-538e-ac5c-a7e40abe1f00', 'country', 'FRA', 'text', 'Déclaration des droits de l''homme et du citoyen', v_cat, '72c27cc1-341d-594b-a4ed-c38c6cc73d3f', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}, {"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('f7d287ba-e06c-538e-ac5c-a7e40abe1f00', '5ef0bfdc-3169-50a1-b935-f482e76b592b') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', '5ef0bfdc-3169-50a1-b935-f482e76b592b', 'up', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year, date_end_month, date_end_day, date_end_circa) values ('2bd0b4e6-2bec-5653-b393-e0b3c358979c', 'Fuite du roi et arrestation à Varennes', 1791, 6, 20, false, 1791, 6, 25, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('b2526c4e-01fc-5deb-a8bf-40ca64a44698', 'country', 'FRA', 'text', 'Fuite du roi et arrestation à Varennes', v_cat, '72c27cc1-341d-594b-a4ed-c38c6cc73d3f', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}, {"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('b2526c4e-01fc-5deb-a8bf-40ca64a44698', '2bd0b4e6-2bec-5653-b393-e0b3c358979c') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', '2bd0b4e6-2bec-5653-b393-e0b3c358979c', 'down', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('9c8819d0-3170-5e7f-a36c-b55290e5c712', 'Louis XVI accepte la Constitution de 1791', 1791, 9, 13, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('91247df2-b696-5937-ab72-d08739350853', 'country', 'FRA', 'text', 'Louis XVI accepte la Constitution de 1791', v_cat, '72c27cc1-341d-594b-a4ed-c38c6cc73d3f', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}, {"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('91247df2-b696-5937-ab72-d08739350853', '9c8819d0-3170-5e7f-a36c-b55290e5c712') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', '9c8819d0-3170-5e7f-a36c-b55290e5c712', 'up', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('151c1e91-3d91-5963-80fc-20d847643734', 'Déclaration de guerre à l''Autriche', 1792, 4, 20, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('17966944-5676-5ae6-ba0d-6575cff7572d', 'country', 'FRA', 'text', 'Déclaration de guerre à l''Autriche', v_cat, '04e1f939-e2a0-5b6e-88f7-81091c85a2cf', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}, {"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('17966944-5676-5ae6-ba0d-6575cff7572d', '151c1e91-3d91-5963-80fc-20d847643734') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', '151c1e91-3d91-5963-80fc-20d847643734', 'down', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('619c27f0-63ed-5bdb-a0e3-20592b34e5d8', 'Journée du 10 août 1792 : chute de la monarchie', 1792, 8, 10, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('d9290bc1-b1ff-599f-a48a-4f98f58bc381', 'country', 'FRA', 'text', 'Journée du 10 août 1792 : chute de la monarchie', v_cat, '04e1f939-e2a0-5b6e-88f7-81091c85a2cf', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}, {"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('d9290bc1-b1ff-599f-a48a-4f98f58bc381', '619c27f0-63ed-5bdb-a0e3-20592b34e5d8') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', '619c27f0-63ed-5bdb-a0e3-20592b34e5d8', 'up', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('f9a84574-f852-5121-a1d1-3fff9ea9a201', 'Bataille de Valmy', 1792, 9, 20, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('2133fe7d-4fa9-5ca3-844f-3577a654b30a', 'country', 'FRA', 'text', 'Bataille de Valmy', v_cat, '04e1f939-e2a0-5b6e-88f7-81091c85a2cf', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}, {"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('2133fe7d-4fa9-5ca3-844f-3577a654b30a', 'f9a84574-f852-5121-a1d1-3fff9ea9a201') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', 'f9a84574-f852-5121-a1d1-3fff9ea9a201', 'down', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('d2f5a55f-b998-5a2b-bf52-f19f39732152', 'Traité de Campoformio', 1797, 10, 18, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('42cab9d8-e03e-5a71-a099-c99960326b27', 'country', 'FRA', 'text', 'Traité de Campoformio', v_cat, 'a4cf3e25-64bb-57a9-82b8-de859c6408a4', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('42cab9d8-e03e-5a71-a099-c99960326b27', 'd2f5a55f-b998-5a2b-bf52-f19f39732152') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', 'd2f5a55f-b998-5a2b-bf52-f19f39732152', 'up', (select id from public.timeline_categories where name = 'Traité' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('d17b3bb7-cafd-57c3-a2cb-25c71cc44796', 'Début de la campagne d''Égypte', 1798, 5, 19, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('6f589c0e-db68-58db-b3e3-8e2b121dcc81', 'country', 'FRA', 'text', 'Début de la campagne d''Égypte', v_cat, 'a4cf3e25-64bb-57a9-82b8-de859c6408a4', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('6f589c0e-db68-58db-b3e3-8e2b121dcc81', 'd17b3bb7-cafd-57c3-a2cb-25c71cc44796') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', 'd17b3bb7-cafd-57c3-a2cb-25c71cc44796', 'down', (select id from public.timeline_categories where name = 'Relations avec le monde' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('0bb6b755-6ee4-52fe-a693-76df674e9b3b', 'Coup d''État du 18 brumaire an VIII', 1799, 11, 9, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('fa46d363-4fb8-52a1-aab2-594181b88c3f', 'country', 'FRA', 'text', 'Coup d''État du 18 brumaire an VIII', v_cat, 'a4cf3e25-64bb-57a9-82b8-de859c6408a4', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}, {"label": "Wikipédia — Directoire", "url": "https://fr.wikipedia.org/wiki/Directoire"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('fa46d363-4fb8-52a1-aab2-594181b88c3f', '0bb6b755-6ee4-52fe-a693-76df674e9b3b') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', '0bb6b755-6ee4-52fe-a693-76df674e9b3b', 'up', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('b883eef9-1929-547c-bae8-22dd4424a828', 'Abolition de la royauté', 1792, 9, 21, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('0124946e-25b4-5dfe-bc45-e34c217dfa5f', 'country', 'FRA', 'text', 'Abolition de la royauté', v_cat, 'a15ef7b4-7e25-5b99-abb5-f890ae39f49c', '{}', '[{"label": "Wikipédia — Convention nationale", "url": "https://fr.wikipedia.org/wiki/Convention_nationale"}, {"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('0124946e-25b4-5dfe-bc45-e34c217dfa5f', 'b883eef9-1929-547c-bae8-22dd4424a828') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', 'b883eef9-1929-547c-bae8-22dd4424a828', 'up', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', 'b883eef9-1929-547c-bae8-22dd4424a828', 'up', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('d6dfc43b-649b-52b6-bd4a-b1b920ec8dc2', 'Ouverture du procès de Louis XVI', 1792, 12, 10, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('db573b82-6695-520b-ad64-73d35336125c', 'country', 'FRA', 'text', 'Ouverture du procès de Louis XVI', v_cat, 'a15ef7b4-7e25-5b99-abb5-f890ae39f49c', '{}', '[{"label": "Wikipédia — Convention nationale", "url": "https://fr.wikipedia.org/wiki/Convention_nationale"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('db573b82-6695-520b-ad64-73d35336125c', 'd6dfc43b-649b-52b6-bd4a-b1b920ec8dc2') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', 'd6dfc43b-649b-52b6-bd4a-b1b920ec8dc2', 'down', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('1ec62c89-9e4c-5ba5-822b-ced7ed7c782c', 'Exécution de Louis XVI', 1793, 1, 21, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('43187448-6485-52ac-ad43-8d38f7e4bab5', 'country', 'FRA', 'text', 'Exécution de Louis XVI', v_cat, 'a15ef7b4-7e25-5b99-abb5-f890ae39f49c', '{}', '[{"label": "Wikipédia — Convention nationale", "url": "https://fr.wikipedia.org/wiki/Convention_nationale"}, {"label": "Wikipédia — Chronologie de la Révolution française", "url": "https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise"}, {"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('43187448-6485-52ac-ad43-8d38f7e4bab5', '1ec62c89-9e4c-5ba5-822b-ced7ed7c782c') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', '1ec62c89-9e4c-5ba5-822b-ced7ed7c782c', 'up', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', '1ec62c89-9e4c-5ba5-822b-ced7ed7c782c', 'up', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('27014d3c-a2ad-5b91-8b6d-1f8cf8f68430', 'Création du Tribunal révolutionnaire', 1793, 3, 10, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('851da89f-90ac-562f-b971-60b5c453e97c', 'country', 'FRA', 'text', 'Création du Tribunal révolutionnaire', v_cat, 'a15ef7b4-7e25-5b99-abb5-f890ae39f49c', '{}', '[{"label": "Larousse — la Terreur", "url": "https://www.larousse.fr/encyclopedie/divers/la_Terreur/146370"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('851da89f-90ac-562f-b971-60b5c453e97c', '27014d3c-a2ad-5b91-8b6d-1f8cf8f68430') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', '27014d3c-a2ad-5b91-8b6d-1f8cf8f68430', 'down', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('27ed30d6-f8f5-5c7d-bbdb-8f1bc9e8e8cd', 'Création du Comité de salut public', 1793, 4, 6, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('de9a29ac-e49b-54a6-98a5-f46b594e2ebd', 'country', 'FRA', 'text', 'Création du Comité de salut public', v_cat, 'a15ef7b4-7e25-5b99-abb5-f890ae39f49c', '{}', '[{"label": "Wikipédia — Convention nationale", "url": "https://fr.wikipedia.org/wiki/Convention_nationale"}, {"label": "World History Encyclopedia — Règne de la Terreur", "url": "https://www.worldhistory.org/trans/fr/1-21142/regne-de-la-terreur/"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('de9a29ac-e49b-54a6-98a5-f46b594e2ebd', '27ed30d6-f8f5-5c7d-bbdb-8f1bc9e8e8cd') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', '27ed30d6-f8f5-5c7d-bbdb-8f1bc9e8e8cd', 'up', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('03b88264-96a9-50a4-a758-1ea2cd5c2cf8', 'Arrestation des Girondins', 1793, 6, 2, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('47aa243e-f875-53ac-afc4-ec41579edef1', 'country', 'FRA', 'text', 'Arrestation des Girondins', v_cat, '20858d62-8c77-56bf-b388-f6ff46106609', '{}', '[{"label": "Wikipédia — Convention nationale", "url": "https://fr.wikipedia.org/wiki/Convention_nationale"}, {"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('47aa243e-f875-53ac-afc4-ec41579edef1', '03b88264-96a9-50a4-a758-1ea2cd5c2cf8') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', '03b88264-96a9-50a4-a758-1ea2cd5c2cf8', 'down', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('9b866563-a7b5-5ed0-abfb-143868b08e48', 'Assassinat de Marat', 1793, 7, 13, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('3fbd7540-3d66-51bb-9843-74a163d1c365', 'country', 'FRA', 'text', 'Assassinat de Marat', v_cat, '20858d62-8c77-56bf-b388-f6ff46106609', '{}', '[{"label": "World History Encyclopedia — Règne de la Terreur", "url": "https://www.worldhistory.org/trans/fr/1-21142/regne-de-la-terreur/"}, {"label": "VL Média — C''était quoi la Terreur ?", "url": "https://vl-media.fr/cetait-quoi-la-terreur-instauree-sous-la-revolution-francaise-en-1793/"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('3fbd7540-3d66-51bb-9843-74a163d1c365', '9b866563-a7b5-5ed0-abfb-143868b08e48') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', '9b866563-a7b5-5ed0-abfb-143868b08e48', 'up', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year, date_end_month, date_end_day, date_end_circa) values ('378e19ef-b811-5a70-ad00-36a18026b8e9', 'La Terreur (seconde Terreur)', 1793, 9, 5, false, 1794, 7, 28, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('59dc2072-9348-5019-898a-f54f3001fa03', 'country', 'FRA', 'text', 'La Terreur (seconde Terreur)', v_cat, '20858d62-8c77-56bf-b388-f6ff46106609', '{}', '[{"label": "Larousse — la Terreur", "url": "https://www.larousse.fr/encyclopedie/divers/la_Terreur/146370"}, {"label": "VL Média — C''était quoi la Terreur ?", "url": "https://vl-media.fr/cetait-quoi-la-terreur-instauree-sous-la-revolution-francaise-en-1793/"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('59dc2072-9348-5019-898a-f54f3001fa03', '378e19ef-b811-5a70-ad00-36a18026b8e9') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', '378e19ef-b811-5a70-ad00-36a18026b8e9', 'down', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', '378e19ef-b811-5a70-ad00-36a18026b8e9', 'down', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('042bc341-eb1f-5395-abab-c5eab3bb8161', 'Loi des suspects', 1793, 9, 17, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('eef22a5d-069c-590b-bc5c-fbe3e7177717', 'country', 'FRA', 'text', 'Loi des suspects', v_cat, '20858d62-8c77-56bf-b388-f6ff46106609', '{}', '[{"label": "Larousse — la Terreur", "url": "https://www.larousse.fr/encyclopedie/divers/la_Terreur/146370"}, {"label": "World History Encyclopedia — Règne de la Terreur", "url": "https://www.worldhistory.org/trans/fr/1-21142/regne-de-la-terreur/"}, {"label": "VL Média — C''était quoi la Terreur ?", "url": "https://vl-media.fr/cetait-quoi-la-terreur-instauree-sous-la-revolution-francaise-en-1793/"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('eef22a5d-069c-590b-bc5c-fbe3e7177717', '042bc341-eb1f-5395-abab-c5eab3bb8161') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', '042bc341-eb1f-5395-abab-c5eab3bb8161', 'up', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('a2e85e80-8231-5fa3-affe-c321732f9c69', 'Exécution de Marie-Antoinette', 1793, 10, 16, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('77cd3849-2ba6-53ec-bf10-456350b6cbf0', 'country', 'FRA', 'text', 'Exécution de Marie-Antoinette', v_cat, '20858d62-8c77-56bf-b388-f6ff46106609', '{}', '[{"label": "World History Encyclopedia — Règne de la Terreur", "url": "https://www.worldhistory.org/trans/fr/1-21142/regne-de-la-terreur/"}, {"label": "VL Média — C''était quoi la Terreur ?", "url": "https://vl-media.fr/cetait-quoi-la-terreur-instauree-sous-la-revolution-francaise-en-1793/"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('77cd3849-2ba6-53ec-bf10-456350b6cbf0', 'a2e85e80-8231-5fa3-affe-c321732f9c69') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', 'a2e85e80-8231-5fa3-affe-c321732f9c69', 'down', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('a120fc70-aabd-543c-8239-bcf7f671d4eb', 'Exécution d''Hébert et de ses partisans', 1794, 3, 24, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('c98269e0-f76e-5791-a002-17104d64b069', 'country', 'FRA', 'text', 'Exécution d''Hébert et de ses partisans', v_cat, '20858d62-8c77-56bf-b388-f6ff46106609', '{}', '[{"label": "World History Encyclopedia — Règne de la Terreur", "url": "https://www.worldhistory.org/trans/fr/1-21142/regne-de-la-terreur/"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('c98269e0-f76e-5791-a002-17104d64b069', 'a120fc70-aabd-543c-8239-bcf7f671d4eb') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', 'a120fc70-aabd-543c-8239-bcf7f671d4eb', 'up', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('3c42444c-06cc-5a3a-8064-34021d923aef', 'Exécution de Danton', 1794, 4, 5, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('13be365d-f910-5d36-bd62-9f30b79eb775', 'country', 'FRA', 'text', 'Exécution de Danton', v_cat, '20858d62-8c77-56bf-b388-f6ff46106609', '{}', '[{"label": "World History Encyclopedia — Règne de la Terreur", "url": "https://www.worldhistory.org/trans/fr/1-21142/regne-de-la-terreur/"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('13be365d-f910-5d36-bd62-9f30b79eb775', '3c42444c-06cc-5a3a-8064-34021d923aef') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', '3c42444c-06cc-5a3a-8064-34021d923aef', 'down', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('502c74ef-7a02-59eb-8c43-08cb859c5cb3', 'Loi du 22 prairial an II', 1794, 6, 10, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('228a7a8d-4734-51cd-b7bc-4a531a703b05', 'country', 'FRA', 'text', 'Loi du 22 prairial an II', v_cat, '20858d62-8c77-56bf-b388-f6ff46106609', '{}', '[{"label": "Larousse — la Terreur", "url": "https://www.larousse.fr/encyclopedie/divers/la_Terreur/146370"}, {"label": "Wikipédia — Convention nationale", "url": "https://fr.wikipedia.org/wiki/Convention_nationale"}, {"label": "World History Encyclopedia — Règne de la Terreur", "url": "https://www.worldhistory.org/trans/fr/1-21142/regne-de-la-terreur/"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('228a7a8d-4734-51cd-b7bc-4a531a703b05', '502c74ef-7a02-59eb-8c43-08cb859c5cb3') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', '502c74ef-7a02-59eb-8c43-08cb859c5cb3', 'up', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('e768ffc6-f5cb-551d-9aa7-c17ed9bea616', '9 thermidor an II : chute de Robespierre', 1794, 7, 27, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('c298ebb4-75d8-5115-a43e-09ea63fab7d2', 'country', 'FRA', 'text', '9 thermidor an II : chute de Robespierre', v_cat, '735d89fe-8c62-52a4-ac46-5902c8d015ba', '{}', '[{"label": "Wikipédia — Convention nationale", "url": "https://fr.wikipedia.org/wiki/Convention_nationale"}, {"label": "World History Encyclopedia — Règne de la Terreur", "url": "https://www.worldhistory.org/trans/fr/1-21142/regne-de-la-terreur/"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('c298ebb4-75d8-5115-a43e-09ea63fab7d2', 'e768ffc6-f5cb-551d-9aa7-c17ed9bea616') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', 'e768ffc6-f5cb-551d-9aa7-c17ed9bea616', 'down', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', 'e768ffc6-f5cb-551d-9aa7-c17ed9bea616', 'down', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('68f74953-578f-5be5-a472-62d92a1a87e0', 'Exécution de Robespierre', 1794, 7, 28, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('01d0d2b5-9261-5435-ade4-88da692951c3', 'country', 'FRA', 'text', 'Exécution de Robespierre', v_cat, '735d89fe-8c62-52a4-ac46-5902c8d015ba', '{}', '[{"label": "World History Encyclopedia — Règne de la Terreur", "url": "https://www.worldhistory.org/trans/fr/1-21142/regne-de-la-terreur/"}, {"label": "VL Média — C''était quoi la Terreur ?", "url": "https://vl-media.fr/cetait-quoi-la-terreur-instauree-sous-la-revolution-francaise-en-1793/"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('01d0d2b5-9261-5435-ade4-88da692951c3', '68f74953-578f-5be5-a472-62d92a1a87e0') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', '68f74953-578f-5be5-a472-62d92a1a87e0', 'up', (select id from public.timeline_categories where name = 'Crise' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa) values ('ce7c870e-78ae-5255-b946-d9cd2ac29272', 'Constitution de l''an III', 1795, 8, 22, false) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('f8864958-c0f6-5480-b9e2-d0d73a598ba6', 'country', 'FRA', 'text', 'Constitution de l''an III', v_cat, '735d89fe-8c62-52a4-ac46-5902c8d015ba', '{}', '[{"label": "Larousse — Révolution française (1789-1799)", "url": "https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995"}, {"label": "Wikipédia — Convention nationale", "url": "https://fr.wikipedia.org/wiki/Convention_nationale"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('f8864958-c0f6-5480-b9e2-d0d73a598ba6', 'ce7c870e-78ae-5255-b946-d9cd2ac29272') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('887acb7d-dd20-583a-a5a7-7abd5d56f6cd', 'ce7c870e-78ae-5255-b946-d9cd2ac29272', 'down', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('33492926-05ec-5a02-b2f8-a5a8afd379b6', 'ce7c870e-78ae-5255-b946-d9cd2ac29272', 'down', (select id from public.timeline_categories where name = 'Institution politique' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;

  raise notice 'Exemple « Histoire de France » créé (ou déjà présent).';
end $$;

-- Vérification (facultative) : doit renvoyer 3 frises et 21 périodes (40 événements au total).
--   select (select count(*) from public.dossier_entries where type='frise' and owner_id='FRA') as frises,
--          (select count(*) from public.dossier_sections where period_frise_id in
--             (select id from public.dossier_entries where type='frise' and owner_id='FRA')) as periodes;
