-- ============================================================
-- Atlas Géopolitique — frises_v3 (2026-11-02) : « Histoire de France » REFAITE sur des bases saines
--
-- Demande de Martin (2026-11-02) : « tout reprendre depuis le début ». L'exemple de frises_v1 était un TEST :
--   1) SUPPRESSION du test (autorisée explicitement par Martin) : les 21 sections-périodes, les 3 frises, les 40 fiches vides et
--      les 40 événements créés par frises_v1, repérés un par un par leurs identifiants fixes (liste ci-dessous).
--      Garde-fou : le script s'arrête sans rien supprimer si une fiche ou une section qui n'est pas de frises_v1 se trouve dans ces
--      sections (contenu de Martin). Rien d'autre n'est touché : ni Dynastie, ni Religion, ni aucune autre catégorie.
--   2) CRÉATION de la frise « Histoire de France » DANS la section « Chronologie » de la France (Histoire > Chronologie) :
--      niveau 1 = 4 grandes époques (Antiquité, Moyen Âge, Époque moderne, Époque contemporaine) ;
--      niveau 2 = une sous-frise par époque, découpée en 17 sous-périodes (chacune est aussi une sous-catégorie).
--      Aucun événement pour l'instant : seulement le découpage. Les niveaux suivants (dynasties, régimes) viendront après validation.
-- Choix des bornes : par convergence des sources universitaires (RAMEAU/BnF, collections Belin et Seuil, revue ATALA, programmes) ;
-- chaque borne et ses désaccords sont notés dans docs/sources/frises.md. Aucune date n'est inventée ; les années seules ne portent
-- ni mois ni jour parce que ce sont des conventions d'historiens.
--
-- Prérequis : schema_v27 à v31 et dossiers_v1 exécutés (déjà fait) ; indépendant de frises_v2 (règnes, autre conversation). Idempotent : une 2e exécution ne supprime plus rien et ne duplique rien.
-- Exécuté par Claude via le connecteur Supabase sur demande de Martin (2026-11-02) ; d'habitude c'est Martin qui exécute.
-- Retour arrière : supprimer la frise « Histoire de France » de Chronologie dans l'appli (ses périodes sont des sous-catégories).
-- ============================================================

do $$
declare
  v_cat uuid := '428a2e75-c8e3-51a1-b12a-bfe7a4018659';
  v_chrono uuid := '3a8c7d65-c6ec-4c13-ab9c-7992eaa3fc43';
  v1 uuid[] := array[
    '0124946e-25b4-5dfe-bc45-e34c217dfa5f', '01d0d2b5-9261-5435-ade4-88da692951c3', '03b88264-96a9-50a4-a758-1ea2cd5c2cf8',
    '042bc341-eb1f-5395-abab-c5eab3bb8161', '04e1f939-e2a0-5b6e-88f7-81091c85a2cf', '06a67556-47a3-5d1f-8f34-853303863b13',
    '0bb6b755-6ee4-52fe-a693-76df674e9b3b', '13be365d-f910-5d36-bd62-9f30b79eb775', '151c1e91-3d91-5963-80fc-20d847643734',
    '162ec7c4-c7de-5da7-aaba-39fe86218388', '17577b30-a2bd-5bfa-bc72-e02430a3f013', '17966944-5676-5ae6-ba0d-6575cff7572d',
    '1860f7c9-6782-5e7d-8ff8-10387d016ec2', '1a4575a8-e0a7-5a2c-871d-bfe767eec0c6', '1cdac680-7cc2-55ca-a1dc-81943dbf6470',
    '1ec62c89-9e4c-5ba5-822b-ced7ed7c782c', '1f4a6996-5a93-5cda-bcbb-030b38d8babe', '20858d62-8c77-56bf-b388-f6ff46106609',
    '2133fe7d-4fa9-5ca3-844f-3577a654b30a', '228a7a8d-4734-51cd-b7bc-4a531a703b05', '2365b170-4bc1-5430-8c17-71ad7bd3f208',
    '27014d3c-a2ad-5b91-8b6d-1f8cf8f68430', '27ed30d6-f8f5-5c7d-bbdb-8f1bc9e8e8cd', '282c049a-3d8e-51ef-8ae6-c56a08c9cd81',
    '2b2412b4-c8c2-520d-a009-7568a7ef5ea7', '2bd0b4e6-2bec-5653-b393-e0b3c358979c', '320546b4-92dd-594d-852f-d7fadbbeb12e',
    '33492926-05ec-5a02-b2f8-a5a8afd379b6', '33a1e03c-837c-5ab3-81b7-4329cd89dfa2', '378e19ef-b811-5a70-ad00-36a18026b8e9',
    '3b8e33a9-867c-59be-acee-7357166acb32', '3c42444c-06cc-5a3a-8064-34021d923aef', '3eb2b0f2-6dbb-5264-9e17-5b57589d0f26',
    '3fbd7540-3d66-51bb-9843-74a163d1c365', '40850e53-99c8-5dea-91e7-8c4febb1138d', '42cab9d8-e03e-5a71-a099-c99960326b27',
    '43187448-6485-52ac-ad43-8d38f7e4bab5', '47aa243e-f875-53ac-afc4-ec41579edef1', '502c74ef-7a02-59eb-8c43-08cb859c5cb3',
    '59dc2072-9348-5019-898a-f54f3001fa03', '5d98c88a-782c-5307-9c6e-36bb18016e0d', '5ef0bfdc-3169-50a1-b935-f482e76b592b',
    '619c27f0-63ed-5bdb-a0e3-20592b34e5d8', '629d90d4-be52-55eb-b8ae-08629c38f46c', '68f74953-578f-5be5-a472-62d92a1a87e0',
    '6f589c0e-db68-58db-b3e3-8e2b121dcc81', '6f905e4d-5000-5e81-b6d3-43cdd25df3f9', '70b7f0f8-2a97-5c8b-b1f8-b54a6821a8b7',
    '72c27cc1-341d-594b-a4ed-c38c6cc73d3f', '735d89fe-8c62-52a4-ac46-5902c8d015ba', '73d6785d-2258-5552-af12-7208582b73d2',
    '77cd3849-2ba6-53ec-bf10-456350b6cbf0', '7d3ae92a-c03a-511a-87a3-4e15d5c0fc00', '848767d7-ce9a-5521-a8d7-ac213f0d41a7',
    '851da89f-90ac-562f-b971-60b5c453e97c', '85ef899f-e951-54fc-a232-a94730dda025', '87d66cff-89f1-5828-b557-685fe356812c',
    '887acb7d-dd20-583a-a5a7-7abd5d56f6cd', '8ba34d4f-8eed-5ec8-97fc-fcb6d760249d', '8f443aa9-7bc4-5148-9572-957232b5943f',
    '91247df2-b696-5937-ab72-d08739350853', '961105ff-aed2-5ef1-94dd-e95732a909c9', '9af0d39b-4961-53b1-a7d3-67a1f823be1a',
    '9b866563-a7b5-5ed0-abfb-143868b08e48', '9c8819d0-3170-5e7f-a36c-b55290e5c712', '9d8ad0b1-d55c-5f64-aeb8-65c6175de927',
    'a120fc70-aabd-543c-8239-bcf7f671d4eb', 'a15ef7b4-7e25-5b99-abb5-f890ae39f49c', 'a2e85e80-8231-5fa3-affe-c321732f9c69',
    'a43d1576-b25a-5de4-bf84-dcdc259ae93d', 'a4883c69-500b-5142-985f-d38dee62a5d5', 'a4cf3e25-64bb-57a9-82b8-de859c6408a4',
    'b2526c4e-01fc-5deb-a8bf-40ca64a44698', 'b2e53bad-b81c-5bc2-8824-cb3be8826f77', 'b4e0d5ed-043f-5f60-9c21-8af0f54e1780',
    'b5be7ff6-1762-5a91-843e-49fa80c47b9d', 'b66a04ed-8e46-50a7-9cbe-dcbe944370c1', 'b883eef9-1929-547c-bae8-22dd4424a828',
    'b9f196b6-4801-5e39-afec-641da98239d0', 'ba59ec79-faa2-5dd9-b01b-5a9107867b0a', 'bba89647-678b-5e71-bcf4-769b1db6cf38',
    'bf7141eb-24a6-5d00-8f78-d58f3b2d1d26', 'c298ebb4-75d8-5115-a43e-09ea63fab7d2', 'c98269e0-f76e-5791-a002-17104d64b069',
    'ca058cc3-93f3-5a34-a73b-bbf3f563189d', 'ce7c870e-78ae-5255-b946-d9cd2ac29272', 'd17b3bb7-cafd-57c3-a2cb-25c71cc44796',
    'd2f5a55f-b998-5a2b-bf52-f19f39732152', 'd6dfc43b-649b-52b6-bd4a-b1b920ec8dc2', 'd9290bc1-b1ff-599f-a48a-4f98f58bc381',
    'db573b82-6695-520b-ad64-73d35336125c', 'ddf9af1b-5910-57b6-8ca4-b37c7bb68577', 'de5c629c-315f-530f-a38f-ae885cf668e4',
    'de9a29ac-e49b-54a6-98a5-f46b594e2ebd', 'e13b6edb-aa17-56ac-917a-2debc83d161c', 'e768ffc6-f5cb-551d-9aa7-c17ed9bea616',
    'e9c6ede1-0d1a-5145-b9d3-cecaa4e4e001', 'ec97a884-95fb-59e5-968c-ea5c2c649826', 'eef22a5d-069c-590b-bc5c-fbe3e7177717',
    'f7d287ba-e06c-538e-ac5c-a7e40abe1f00', 'f8864958-c0f6-5480-b9e2-d0d73a598ba6', 'f95047e5-18b9-5450-a1ad-4144eb27bd26',
    'f9a84574-f852-5121-a1d1-3fff9ea9a201', 'fa46d363-4fb8-52a1-aab2-594181b88c3f'
  ]::uuid[];
  n_foreign int;
begin
  if not exists (select 1 from public.dossier_sections where id = v_chrono and owner_id = 'FRA' and title = 'Chronologie' and category_id = v_cat) then
    raise exception 'Section Chronologie de la France introuvable : rien n''a été fait.';
  end if;

  -- ===== 1) Suppression du test frises_v1 (ciblée par identifiants) =====
  select count(*) into n_foreign from (
    select id from public.dossier_entries where section_id = any(v1) and not (id = any(v1))
    union all
    select id from public.dossier_sections where parent_section_id = any(v1) and not (id = any(v1))
  ) x;
  if n_foreign > 0 then
    raise exception 'Du contenu qui n''est pas de frises_v1 se trouve dans les sections du test (% éléments) : suppression annulée.', n_foreign;
  end if;
  delete from public.timeline_events where id = any(v1);          -- supprime aussi placements et liens événement-fiche (cascade)
  delete from public.dossier_sections where id = any(v1);         -- supprime les sous-sections et les fiches qu'elles contiennent (cascade)
  delete from public.dossier_entries where id = any(v1);          -- frises et fiches restantes

  -- ===== 2) Nouvelle frise « Histoire de France » dans Chronologie =====
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('486c6ee6-fc5e-5f26-8c8c-9eacf0dc0d37', 'country', 'FRA', 'frise', 'Histoire de France', v_cat, '3a8c7d65-c6ec-4c13-ab9c-7992eaa3fc43', '{}', '[{"label": "Manuel Histoire 2de (Le Quintrec, Nathan 2019) — Périodiser l''histoire", "url": "https://hg-lycee.nathan.fr/9782091728865/assets/tous-les-textes-du-chapitre-introductif-pour-les-dys-2/preview"}, {"label": "Exercice de périodisation 2de, académie d''Orléans-Tours", "url": "https://pedagogie-archive.ac-orleans-tours.fr/fileadmin/user_upload/hg/Lycee/Lyc%C3%A9e-NouveauxProgrammes-2019/Seconde-NouveauxProgrammes2019/periodisation/exercice-periodisation-seconde-fardel-coannault.pdf"}, {"label": "F. Mazel, « Un, deux, trois Moyen Âge… », ATALA n°17 (2014)", "url": "https://www.lycee-chateaubriand.fr/wp-content/uploads/sites/2/2017/01/Mazel17.pdf"}, {"label": "P. Hamon, « Du Moyen Âge aux temps modernes : une charnière canonique », ATALA n°17 (2014)", "url": "https://www.lycee-chateaubriand.fr/revue-atala/wp-content/uploads/sites/2/2017/01/Hamon17.pdf"}, {"label": "H. Inglebert, « De quoi l''Antiquité tardive est-elle le nom ? », ATALA n°17 (2014)", "url": "https://www.lycee-chateaubriand.fr/revue-atala/wp-content/uploads/sites/2/2014/06/Inglebert17.pdf"}, {"label": "Larousse — France : histoire (jusqu''en 1958)", "url": "https://www.larousse.fr/encyclopedie/divers/France%C2%A0_histoire_jusquen_1958/185545"}, {"label": "BnF RAMEAU — France 1870-1940 (3e République) (4 sept. 1870 → 10 juil. 1940)", "url": "https://catalogue.bnf.fr/ark:/12148/cb11941855d"}, {"label": "BnF RAMEAU — France 1789-1815 (1789-1799 Révolution, 1792-1804 1re République)", "url": "https://catalogue.bnf.fr/ark:/12148/cb119418484"}, {"label": "Seuil — Nouvelle histoire de la France contemporaine (20 vol.), liste des volumes et bornes", "url": "https://bibliotheques-numeriques.defense.gouv.fr/impression/document/9a0cdcab-5465-45d5-b0f6-ee5b0908b17c"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('b5d62a70-5aed-56c7-ade1-430e5615063c', v_cat, 'country', 'FRA', '3a8c7d65-c6ec-4c13-ab9c-7992eaa3fc43', 'Antiquité', 0, '486c6ee6-fc5e-5f26-8c8c-9eacf0dc0d37', false, '#7f8c8d', -600, null, null, true, 476, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('0bae5eef-c88a-59d4-9b63-288856f55452', v_cat, 'country', 'FRA', '3a8c7d65-c6ec-4c13-ab9c-7992eaa3fc43', 'Moyen Âge', 1, '486c6ee6-fc5e-5f26-8c8c-9eacf0dc0d37', false, '#8e44ad', 476, null, null, false, 1492, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('836933cf-a823-5bfa-be58-32af7b6e1a52', v_cat, 'country', 'FRA', '3a8c7d65-c6ec-4c13-ab9c-7992eaa3fc43', 'Époque moderne', 2, '486c6ee6-fc5e-5f26-8c8c-9eacf0dc0d37', false, '#e67e22', 1492, null, null, false, 1789, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('ec7ad5d8-8548-5222-bf41-2a696f1adce1', v_cat, 'country', 'FRA', '3a8c7d65-c6ec-4c13-ab9c-7992eaa3fc43', 'Époque contemporaine', 3, '486c6ee6-fc5e-5f26-8c8c-9eacf0dc0d37', false, '#2980b9', 1789, null, null, false, null, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('82a61634-cdf7-52b8-a293-2e5163ff745d', 'country', 'FRA', 'frise', 'Antiquité', v_cat, 'b5d62a70-5aed-56c7-ade1-430e5615063c', '{}', '[{"label": "Manuel Histoire 2de (Le Quintrec, Nathan 2019) — Périodiser l''histoire", "url": "https://hg-lycee.nathan.fr/9782091728865/assets/tous-les-textes-du-chapitre-introductif-pour-les-dys-2/preview"}, {"label": "Exercice de périodisation 2de, académie d''Orléans-Tours", "url": "https://pedagogie-archive.ac-orleans-tours.fr/fileadmin/user_upload/hg/Lycee/Lyc%C3%A9e-NouveauxProgrammes-2019/Seconde-NouveauxProgrammes2019/periodisation/exercice-periodisation-seconde-fardel-coannault.pdf"}, {"label": "Inrap — Âge du Bronze et âge du Fer (frise générale)", "url": "https://multimedia.inrap.fr/archeologie-preventive/periode/8/Age-du-Bronze-et-age-du-Fer"}, {"label": "Delaplace & France, Histoire des Gaules (VIe s. av. J.-C. – VIe s. ap. J.-C.), Armand Colin — sommaire", "url": "https://www.abdelmagidzarrouki.com/2013-05-06-14-45-36/finish/853-histoire/71946-delaplace-et-france-histoire-des-gaules-vie-siecle-av-jc-vie-siecle-ap-jc/0"}, {"label": "H. Inglebert, « De quoi l''Antiquité tardive est-elle le nom ? », ATALA n°17 (2014)", "url": "https://www.lycee-chateaubriand.fr/revue-atala/wp-content/uploads/sites/2/2014/06/Inglebert17.pdf"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('66686992-5b5f-547c-b024-98859a83bd22', v_cat, 'country', 'FRA', 'b5d62a70-5aed-56c7-ade1-430e5615063c', 'Gaule indépendante', 0, '82a61634-cdf7-52b8-a293-2e5163ff745d', false, '#95a5a6', -600, null, null, true, -52, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('df7006a4-4300-5e3b-aa8a-4faa122d4d9e', v_cat, 'country', 'FRA', 'b5d62a70-5aed-56c7-ade1-430e5615063c', 'Gaule romaine : conquête et Haut-Empire', 1, '82a61634-cdf7-52b8-a293-2e5163ff745d', false, '#7f8c8d', -52, null, null, false, 235, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('3ac0871a-10cc-5a70-8413-6463a0296f08', v_cat, 'country', 'FRA', 'b5d62a70-5aed-56c7-ade1-430e5615063c', 'Crise du IIIe siècle', 2, '82a61634-cdf7-52b8-a293-2e5163ff745d', false, '#6c7a7b', 235, null, null, false, 284, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('d43245db-e458-56c8-8444-15d0bf844bf6', v_cat, 'country', 'FRA', 'b5d62a70-5aed-56c7-ade1-430e5615063c', 'Bas-Empire et Antiquité tardive', 3, '82a61634-cdf7-52b8-a293-2e5163ff745d', false, '#566573', 284, null, null, false, 476, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('9eee0fcc-82f4-5581-a116-2954fe59ad03', 'country', 'FRA', 'frise', 'Moyen Âge', v_cat, '0bae5eef-c88a-59d4-9b63-288856f55452', '{}', '[{"label": "Manuel Histoire 2de (Le Quintrec, Nathan 2019) — Périodiser l''histoire", "url": "https://hg-lycee.nathan.fr/9782091728865/assets/tous-les-textes-du-chapitre-introductif-pour-les-dys-2/preview"}, {"label": "Exercice de périodisation 2de, académie d''Orléans-Tours", "url": "https://pedagogie-archive.ac-orleans-tours.fr/fileadmin/user_upload/hg/Lycee/Lyc%C3%A9e-NouveauxProgrammes-2019/Seconde-NouveauxProgrammes2019/periodisation/exercice-periodisation-seconde-fardel-coannault.pdf"}, {"label": "F. Mazel, « Un, deux, trois Moyen Âge… », ATALA n°17 (2014)", "url": "https://www.lycee-chateaubriand.fr/wp-content/uploads/sites/2/2017/01/Mazel17.pdf"}, {"label": "P. Hamon, « Du Moyen Âge aux temps modernes : une charnière canonique », ATALA n°17 (2014)", "url": "https://www.lycee-chateaubriand.fr/revue-atala/wp-content/uploads/sites/2/2017/01/Hamon17.pdf"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('5acb3fb0-b901-56fe-a847-2be5e5570a23', v_cat, 'country', 'FRA', '0bae5eef-c88a-59d4-9b63-288856f55452', 'Haut Moyen Âge', 0, '9eee0fcc-82f4-5581-a116-2954fe59ad03', false, '#a569bd', 476, null, null, false, 987, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('23ad583d-e551-55f0-9f8c-483c222fbe91', v_cat, 'country', 'FRA', '0bae5eef-c88a-59d4-9b63-288856f55452', 'Moyen Âge central', 1, '9eee0fcc-82f4-5581-a116-2954fe59ad03', false, '#8e44ad', 987, null, null, false, 1328, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('6ffe1445-6dc5-5eb8-98d4-30049102b8b9', v_cat, 'country', 'FRA', '0bae5eef-c88a-59d4-9b63-288856f55452', 'Bas Moyen Âge', 2, '9eee0fcc-82f4-5581-a116-2954fe59ad03', false, '#6c3483', 1328, null, null, false, 1492, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('59c0dfae-b354-5a64-aac8-b68f53b4f857', 'country', 'FRA', 'frise', 'Époque moderne', v_cat, '836933cf-a823-5bfa-be58-32af7b6e1a52', '{}', '[{"label": "Manuel Histoire 2de (Le Quintrec, Nathan 2019) — Périodiser l''histoire", "url": "https://hg-lycee.nathan.fr/9782091728865/assets/tous-les-textes-du-chapitre-introductif-pour-les-dys-2/preview"}, {"label": "Exercice de périodisation 2de, académie d''Orléans-Tours", "url": "https://pedagogie-archive.ac-orleans-tours.fr/fileadmin/user_upload/hg/Lycee/Lyc%C3%A9e-NouveauxProgrammes-2019/Seconde-NouveauxProgrammes2019/periodisation/exercice-periodisation-seconde-fardel-coannault.pdf"}, {"label": "P. Hamon, « Du Moyen Âge aux temps modernes : une charnière canonique », ATALA n°17 (2014)", "url": "https://www.lycee-chateaubriand.fr/revue-atala/wp-content/uploads/sites/2/2017/01/Hamon17.pdf"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('a52a77d1-e9d1-5eb4-944d-39767ab173b5', v_cat, 'country', 'FRA', '836933cf-a823-5bfa-be58-32af7b6e1a52', 'Renaissance et guerres d''Italie', 0, '59c0dfae-b354-5a64-aac8-b68f53b4f857', false, '#f0b27a', 1492, null, null, false, 1562, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('296d4e6e-d1f9-54a7-9480-6e992b430e57', v_cat, 'country', 'FRA', '836933cf-a823-5bfa-be58-32af7b6e1a52', 'Guerres de religion', 1, '59c0dfae-b354-5a64-aac8-b68f53b4f857', false, '#d35400', 1562, null, null, false, 1598, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('ce27b714-98ca-57b8-acf3-0adccfe3d1b6', v_cat, 'country', 'FRA', '836933cf-a823-5bfa-be58-32af7b6e1a52', 'Monarchie absolue', 2, '59c0dfae-b354-5a64-aac8-b68f53b4f857', false, '#e67e22', 1598, null, null, false, 1715, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('ae4258b7-7222-527d-9285-d20381964578', v_cat, 'country', 'FRA', '836933cf-a823-5bfa-be58-32af7b6e1a52', 'Monarchie des Lumières', 3, '59c0dfae-b354-5a64-aac8-b68f53b4f857', false, '#f5b041', 1715, null, null, false, 1789, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('ef559c42-c46f-5122-b1bf-45118179ac3b', 'country', 'FRA', 'frise', 'Époque contemporaine', v_cat, 'ec7ad5d8-8548-5222-bf41-2a696f1adce1', '{}', '[{"label": "Manuel Histoire 2de (Le Quintrec, Nathan 2019) — Périodiser l''histoire", "url": "https://hg-lycee.nathan.fr/9782091728865/assets/tous-les-textes-du-chapitre-introductif-pour-les-dys-2/preview"}, {"label": "Exercice de périodisation 2de, académie d''Orléans-Tours", "url": "https://pedagogie-archive.ac-orleans-tours.fr/fileadmin/user_upload/hg/Lycee/Lyc%C3%A9e-NouveauxProgrammes-2019/Seconde-NouveauxProgrammes2019/periodisation/exercice-periodisation-seconde-fardel-coannault.pdf"}, {"label": "BnF RAMEAU — France 1789-1815 (1789-1799 Révolution, 1792-1804 1re République)", "url": "https://catalogue.bnf.fr/ark:/12148/cb119418484"}, {"label": "Belin/Cornette — La Révolution inachevée 1815-1870 (Aprile), bibliographie ICES", "url": "https://ices.fr/wp-content/uploads/2023/11/Bibliographie-France-1815-1870-Hyperliens-PDF.pdf"}, {"label": "Belin/Cornette — La France du temps présent 1945-2005 (Zancarini-Fournel, Delacroix)", "url": "https://bibliotheques-numeriques.defense.gouv.fr/impression/document/9cb5d548-bb87-4172-8f46-5b4f8988d5e2"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('6f89c5e0-6178-54da-83c2-a829bf9c5eeb', v_cat, 'country', 'FRA', 'ec7ad5d8-8548-5222-bf41-2a696f1adce1', 'Révolution française', 0, 'ef559c42-c46f-5122-b1bf-45118179ac3b', false, '#c0392b', 1789, null, null, false, 1799, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('71fe13de-a79d-5b57-89f6-a38d5a03ef9d', v_cat, 'country', 'FRA', 'ec7ad5d8-8548-5222-bf41-2a696f1adce1', 'Consulat et Premier Empire', 1, 'ef559c42-c46f-5122-b1bf-45118179ac3b', false, '#a04000', 1799, null, null, false, 1815, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('d5f98ce4-b366-519d-aa98-cfbed6facd8d', v_cat, 'country', 'FRA', 'ec7ad5d8-8548-5222-bf41-2a696f1adce1', 'De la Restauration au Second Empire', 2, 'ef559c42-c46f-5122-b1bf-45118179ac3b', false, '#5d6d7e', 1815, null, null, false, 1870, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('5fd6ea08-a8bc-598c-94db-d18d17a1762b', v_cat, 'country', 'FRA', 'ec7ad5d8-8548-5222-bf41-2a696f1adce1', 'La France de 1870 à 1914', 3, 'ef559c42-c46f-5122-b1bf-45118179ac3b', false, '#2471a3', 1870, null, null, false, 1914, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('426a5f08-4c14-53d0-a9ac-b45cd4c8875d', v_cat, 'country', 'FRA', 'ec7ad5d8-8548-5222-bf41-2a696f1adce1', 'La France de 1914 à 1945', 4, 'ef559c42-c46f-5122-b1bf-45118179ac3b', false, '#34495e', 1914, null, null, false, 1945, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('a14c7206-ffb5-5db1-9350-bc0961d0aef2', v_cat, 'country', 'FRA', 'ec7ad5d8-8548-5222-bf41-2a696f1adce1', 'La France depuis 1945', 5, 'ef559c42-c46f-5122-b1bf-45118179ac3b', false, '#16a085', 1945, null, null, false, null, null, null, false)
  on conflict (id) do nothing;
  -- ===== 3) Vérifications : si une seule échoue, tout est annulé (le bloc est une seule transaction) =====
  if (select count(*) from public.dossier_sections where id = any(v1)) <> 0
     or (select count(*) from public.dossier_entries where id = any(v1)) <> 0
     or (select count(*) from public.timeline_events where id = any(v1)) <> 0 then
    raise exception 'Le test frises_v1 n''a pas été entièrement supprimé : tout est annulé.';
  end if;
  if (select count(*) from public.dossier_sections where parent_section_id = v_chrono and period_frise_id = '486c6ee6-fc5e-5f26-8c8c-9eacf0dc0d37') <> 4 then
    raise exception 'Nombre d''époques inattendu : tout est annulé.';
  end if;
  if (select count(*) from public.dossier_sections s join public.dossier_entries e on e.id = s.period_frise_id
        where e.owner_id = 'FRA' and e.title in ('Histoire de France','Antiquité','Moyen Âge','Époque moderne','Époque contemporaine')) <> 21 then
    raise exception 'Nombre de périodes inattendu : tout est annulé.';
  end if;
  if (select count(*) from public.dossier_entries where owner_id = 'FRA' and type = 'frise') <> 5 then
    raise exception 'Nombre de frises inattendu : tout est annulé.';
  end if;
end $$;
