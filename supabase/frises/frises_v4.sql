-- ============================================================
-- Atlas Géopolitique — frises_v4 (2026-11-06) : frise « Histoire de l'Allemagne » (découpage en époques et sous-périodes)
--
-- Demande de Martin (2026-11-06) : bornes les plus enseignées ; début de l'Antiquité = -58 (Arioviste/César), Antiquité -> Moyen Âge = 476,
-- Moyen Âge -> époque moderne = 1495, moderne -> contemporaine = 1806, coupure autour de la révolution = 1849, Weimar = 1918.
-- CRÉATION (aucune suppression) de la frise « Histoire de l'Allemagne » dans la section « Chronologie » de l'Allemagne (Histoire > Chronologie) :
--   niveau 1 = 4 époques (Antiquité, Moyen Âge, Époque moderne, Époque contemporaine) ;
--   niveau 2 = une sous-frise par époque (sauf l'Antiquité : aucune sous-borne sourcée), 18 sous-périodes.
-- Aucun événement : seulement le découpage. 1949-1990 = une seule période « Les deux Allemagnes » (frises parallèles RFA/RDA = future fonction de l'outil).
-- Le contenu de test déjà présent pour l'Allemagne (frise « Histoire Allemande », « test », « Guerre », « pipoland ») n'est PAS touché : suppression à valider par Martin.
-- Bornes, sources et désaccords : docs/sources/frises.md (sections Allemagne). Noms des sous-périodes = libellés descriptifs (les bornes sont sourcées, pas les noms).
-- Années seules (conventions d'historiens), sans mois ni jour.
--
-- Prérequis : schema_v27 à v31 et dossiers_v1 exécutés. Idempotent : une 2e exécution ne duplique rien.
-- Exécuté par Claude via le connecteur Supabase (décision de Martin, 2026-11-02).
-- Retour arrière : supprimer la frise « Histoire de l'Allemagne » de Chronologie dans l'appli (ses périodes sont des sous-catégories).
-- ============================================================

do $$
declare
  v_cat uuid := '428a2e75-c8e3-51a1-b12a-bfe7a4018659';
  v_chrono uuid := '5b91dad0-5c27-4f8d-8949-14dc8006a538';
  v_secs uuid[] := array['8d8f41ef-023c-53d9-9ca7-e46bc140079e', 'e69d5bbf-e9f4-5ce2-b443-acbbc4c2c208', '6de25b5c-5b8f-52d1-b1d5-7a76ffd4c7db', '5b86e445-5754-5fa4-9a90-e628078f612d', 'e8e21a18-d256-593c-94f6-57694bca3af4', 'eef4c650-2f41-5b3b-b83a-ff138990a95a', '8bb0e69e-9276-57de-bd0b-c9575e858889', 'f66cc92b-a427-5a6b-b96c-d14a7b33bc36', 'b1b450fd-f399-58e9-96b2-0c14f9cef51c', '355b9ad1-d2ce-5859-99ea-1ed28fd9b42c', '3ae6968e-cda1-5100-ba4b-ece4d8a2fcfb', 'cb4e05e7-211e-5bf4-b7b0-e7962a511e3f', '0ad31f38-6995-5f9b-abf3-d4316c7a03ad', '69cc671f-061d-52c8-98d6-d64004abcec7', 'fdcf1bcf-e0ad-54b4-bfb6-69198a767fac', '3255d692-6a65-596c-88fa-c089d5a7e13b', 'b16a9c4c-c3f7-5e1c-a12c-e4f0fc139d91', '23ffbb6e-2207-53ad-bf82-86d1728af3ec', 'f6908d2c-a172-5bde-bd79-9c17cf212bc8', '69e99bc2-85eb-524b-b88c-b2ef96007bd9', '6db70889-ff97-56db-a28d-02c76259beec', 'e031947b-5ade-50c8-a80b-1c958b3600aa']::uuid[];
  v_ents uuid[] := array['cb284e7e-510e-5e20-a6d2-d7f4c9304bda', '51eac2c8-758f-555d-b7b8-0960d581b35a', '634ddf8a-2f14-5810-bddc-f638d2fc887e', '5c797071-b0b7-5ded-838e-b00428a136a8']::uuid[];
begin
  if not exists (select 1 from public.dossier_sections where id = v_chrono and owner_id = 'DEU' and title = 'Chronologie' and category_id = v_cat) then
    raise exception 'Section Chronologie de l''Allemagne introuvable : rien n''a été fait.';
  end if;

  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('cb284e7e-510e-5e20-a6d2-d7f4c9304bda', 'country', 'DEU', 'frise', 'Histoire de l''Allemagne', v_cat, '5b91dad0-5c27-4f8d-8949-14dc8006a538', '{}', '[{"label": "Gebhardt, Handbuch der deutschen Geschichte, 10e éd. (Klett-Cotta) — tomes 1-23 et bornes", "url": "https://www.lehmanns.ch/media/120933979"}, {"label": "Gebhardt — registre et justification des phases (Klett-Cotta)", "url": "https://klett-cotta.de/_files_media/reading_samples/10606.pdf"}, {"label": "Propyläen Geschichte Deutschlands / Das Reich und die Deutschen — liste des volumes et bornes", "url": "https://www.hendrik.maekeler.eu/handbucher/"}, {"label": "BnF RAMEAU — Allemagne 1871-1918 (Empire allemand)", "url": "https://catalogue.bnf.fr/ark:/12148/cb119347320"}, {"label": "BnF RAMEAU — Saint-Empire 962-1806", "url": "https://catalogue.bnf.fr/ark:/12148/cb15342264g"}, {"label": "Larousse — Allemagne : histoire", "url": "https://www.larousse.fr/encyclopedie/divers/Allemagne%C2%A0_histoire/185779"}, {"label": "Universalis — Allemagne, l''époque des confédérations 1806-1871", "url": "https://www.universalis.fr/encyclopedie/allemagne-histoire-allemagne-moderne-et-contemporaine/2-l-epoque-des-confederations-1806-1871/"}, {"label": "J. Droz, Histoire de l''Allemagne (PUF, Que sais-je ?)", "url": "https://bibliotheques-numeriques.defense.gouv.fr/impression/document/6901005f-cee2-4923-87be-8435d5309e9a"}, {"label": "H. Bogdan, Histoire de l''Allemagne (Perrin)", "url": "https://bibliotheques-numeriques.defense.gouv.fr/impression/document/c6121bbf-32b0-4e99-ba8c-98a79067380d"}, {"label": "M. Broszat (dir.), Zäsuren nach 1945 (IfZ)", "url": "https://open.ifz-muenchen.de/bitstreams/c6983b02-bc57-439b-a0e5-3507b9cc55b4/download"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('8d8f41ef-023c-53d9-9ca7-e46bc140079e', v_cat, 'country', 'DEU', '5b91dad0-5c27-4f8d-8949-14dc8006a538', 'Antiquité', 0, 'cb284e7e-510e-5e20-a6d2-d7f4c9304bda', false, '#7f8c8d', -58, null, null, false, 476, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('e69d5bbf-e9f4-5ce2-b443-acbbc4c2c208', v_cat, 'country', 'DEU', '5b91dad0-5c27-4f8d-8949-14dc8006a538', 'Moyen Âge', 1, 'cb284e7e-510e-5e20-a6d2-d7f4c9304bda', false, '#8e44ad', 476, null, null, false, 1495, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('6de25b5c-5b8f-52d1-b1d5-7a76ffd4c7db', v_cat, 'country', 'DEU', '5b91dad0-5c27-4f8d-8949-14dc8006a538', 'Époque moderne', 2, 'cb284e7e-510e-5e20-a6d2-d7f4c9304bda', false, '#e67e22', 1495, null, null, false, 1806, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('5b86e445-5754-5fa4-9a90-e628078f612d', v_cat, 'country', 'DEU', '5b91dad0-5c27-4f8d-8949-14dc8006a538', 'Époque contemporaine', 3, 'cb284e7e-510e-5e20-a6d2-d7f4c9304bda', false, '#2980b9', 1806, null, null, false, null, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('51eac2c8-758f-555d-b7b8-0960d581b35a', 'country', 'DEU', 'frise', 'Moyen Âge', v_cat, 'e69d5bbf-e9f4-5ce2-b443-acbbc4c2c208', '{}', '[{"label": "Gebhardt, Handbuch der deutschen Geschichte, 10e éd. (Klett-Cotta) — tomes 1-23 et bornes", "url": "https://www.lehmanns.ch/media/120933979"}, {"label": "Gebhardt — registre et justification des phases (Klett-Cotta)", "url": "https://klett-cotta.de/_files_media/reading_samples/10606.pdf"}, {"label": "Propyläen Geschichte Deutschlands / Das Reich und die Deutschen — liste des volumes et bornes", "url": "https://www.hendrik.maekeler.eu/handbucher/"}, {"label": "C.C. Buchner, Das waren Zeiten (Berlin/Brandenburg) — Mittelalter ca. 1000-1500, Frühe Neuzeit ca. 1500-1750", "url": "https://www.ccbuchner.de/_files_media/mediathek/downloads/2744.docx"}, {"label": "Manuel Histoire 2de (Le Quintrec, Nathan 2019) — Périodiser l''histoire", "url": "https://hg-lycee.nathan.fr/9782091728865/assets/tous-les-textes-du-chapitre-introductif-pour-les-dys-2/preview"}, {"label": "F. Mazel, « Un, deux, trois Moyen Âge… », ATALA n°17 (2014)", "url": "https://www.lycee-chateaubriand.fr/wp-content/uploads/sites/2/2017/01/Mazel17.pdf"}, {"label": "P. Hamon, « Du Moyen Âge aux temps modernes : une charnière canonique », ATALA n°17 (2014)", "url": "https://www.lycee-chateaubriand.fr/revue-atala/wp-content/uploads/sites/2/2017/01/Hamon17.pdf"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('e8e21a18-d256-593c-94f6-57694bca3af4', v_cat, 'country', 'DEU', 'e69d5bbf-e9f4-5ce2-b443-acbbc4c2c208', 'Du monde franc à la Francie orientale', 0, '51eac2c8-758f-555d-b7b8-0960d581b35a', false, '#a569bd', 476, null, null, false, 843, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('eef4c650-2f41-5b3b-b83a-ff138990a95a', v_cat, 'country', 'DEU', 'e69d5bbf-e9f4-5ce2-b443-acbbc4c2c208', 'Francie orientale et Ottoniens', 1, '51eac2c8-758f-555d-b7b8-0960d581b35a', false, '#9b59b6', 843, null, null, false, 1024, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('8bb0e69e-9276-57de-bd0b-c9575e858889', v_cat, 'country', 'DEU', 'e69d5bbf-e9f4-5ce2-b443-acbbc4c2c208', 'Les Saliens', 2, '51eac2c8-758f-555d-b7b8-0960d581b35a', false, '#8e44ad', 1024, null, null, false, 1125, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('f66cc92b-a427-5a6b-b96c-d14a7b33bc36', v_cat, 'country', 'DEU', 'e69d5bbf-e9f4-5ce2-b443-acbbc4c2c208', 'Staufer et Interrègne', 3, '51eac2c8-758f-555d-b7b8-0960d581b35a', false, '#7d3c98', 1125, null, null, false, 1273, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('b1b450fd-f399-58e9-96b2-0c14f9cef51c', v_cat, 'country', 'DEU', 'e69d5bbf-e9f4-5ce2-b443-acbbc4c2c208', 'Bas Moyen Âge : des Habsbourg à la réforme d''Empire', 4, '51eac2c8-758f-555d-b7b8-0960d581b35a', false, '#6c3483', 1273, null, null, false, 1495, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('634ddf8a-2f14-5810-bddc-f638d2fc887e', 'country', 'DEU', 'frise', 'Époque moderne', v_cat, '6de25b5c-5b8f-52d1-b1d5-7a76ffd4c7db', '{}', '[{"label": "Gebhardt, Handbuch der deutschen Geschichte, 10e éd. (Klett-Cotta) — tomes 1-23 et bornes", "url": "https://www.lehmanns.ch/media/120933979"}, {"label": "Gebhardt tome 9 (1495-1555), « Periodisierungsprobleme »", "url": "https://www.lehmanns.ch/media/1347592/1"}, {"label": "BnF RAMEAU — Saint-Empire 962-1806", "url": "https://catalogue.bnf.fr/ark:/12148/cb15342264g"}, {"label": "Larousse — Allemagne : histoire", "url": "https://www.larousse.fr/encyclopedie/divers/Allemagne%C2%A0_histoire/185779"}, {"label": "Univ. Regensburg — bibliographie Frühe Neuzeit", "url": "https://uni-regensburg.de/assets/philosophie-kunst-geschichte-gesellschaft/geschichte/staatsexamen/Auswahlbibliographie_Fruehe_Neuzeit.pdf"}, {"label": "Univ. Marburg — Frühe Neuzeit, programme d''études", "url": "https://www.uni-marburg.de/de/fb06/fnz/studium/studium"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('355b9ad1-d2ce-5859-99ea-1ed28fd9b42c', v_cat, 'country', 'DEU', '6de25b5c-5b8f-52d1-b1d5-7a76ffd4c7db', 'Réforme et réforme d''Empire', 0, '634ddf8a-2f14-5810-bddc-f638d2fc887e', false, '#f0b27a', 1495, null, null, false, 1555, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('3ae6968e-cda1-5100-ba4b-ece4d8a2fcfb', v_cat, 'country', 'DEU', '6de25b5c-5b8f-52d1-b1d5-7a76ffd4c7db', 'Âge confessionnel', 1, '634ddf8a-2f14-5810-bddc-f638d2fc887e', false, '#e59866', 1555, null, null, false, 1618, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('cb4e05e7-211e-5bf4-b7b0-e7962a511e3f', v_cat, 'country', 'DEU', '6de25b5c-5b8f-52d1-b1d5-7a76ffd4c7db', 'Guerre de Trente Ans', 2, '634ddf8a-2f14-5810-bddc-f638d2fc887e', false, '#d35400', 1618, null, null, false, 1648, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('0ad31f38-6995-5f9b-abf3-d4316c7a03ad', v_cat, 'country', 'DEU', '6de25b5c-5b8f-52d1-b1d5-7a76ffd4c7db', 'De Westphalie à la guerre de Sept Ans', 3, '634ddf8a-2f14-5810-bddc-f638d2fc887e', false, '#e67e22', 1648, null, null, false, 1763, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('69cc671f-061d-52c8-98d6-d64004abcec7', v_cat, 'country', 'DEU', '6de25b5c-5b8f-52d1-b1d5-7a76ffd4c7db', 'Fin du Saint-Empire', 4, '634ddf8a-2f14-5810-bddc-f638d2fc887e', false, '#f5b041', 1763, null, null, false, 1806, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('5c797071-b0b7-5ded-838e-b00428a136a8', 'country', 'DEU', 'frise', 'Époque contemporaine', v_cat, '5b86e445-5754-5fa4-9a90-e628078f612d', '{}', '[{"label": "Gebhardt, Handbuch der deutschen Geschichte, 10e éd. (Klett-Cotta) — tomes 1-23 et bornes", "url": "https://www.lehmanns.ch/media/120933979"}, {"label": "Gebhardt — registre et justification des phases (Klett-Cotta)", "url": "https://klett-cotta.de/_files_media/reading_samples/10606.pdf"}, {"label": "Universalis — Allemagne, l''époque des confédérations 1806-1871", "url": "https://www.universalis.fr/encyclopedie/allemagne-histoire-allemagne-moderne-et-contemporaine/2-l-epoque-des-confederations-1806-1871/"}, {"label": "J. Droz, Histoire de l''Allemagne (PUF, Que sais-je ?)", "url": "https://bibliotheques-numeriques.defense.gouv.fr/impression/document/6901005f-cee2-4923-87be-8435d5309e9a"}, {"label": "Bavière, LehrplanPLUS Geschichte 8e (dates 1618-1648, 1806, 1815, 1848/49, 1871)", "url": "https://www.lehrplanplus.bayern.de/fachlehrplan/gymnasium/8/geschichte"}, {"label": "Dirlmeier/Gestrich/Reulecke, Kleine deutsche Geschichte — chapitres 1648-1814, 1815-1914, 1914-1945", "url": "https://www.lehmanns.ch/media/116667740"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('fdcf1bcf-e0ad-54b4-bfb6-69198a767fac', v_cat, 'country', 'DEU', '5b86e445-5754-5fa4-9a90-e628078f612d', 'Des confédérations à la révolution de 1848-1849', 0, '5c797071-b0b7-5ded-838e-b00428a136a8', false, '#5d6d7e', 1806, null, null, false, 1849, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('3255d692-6a65-596c-88fa-c089d5a7e13b', v_cat, 'country', 'DEU', '5b86e445-5754-5fa4-9a90-e628078f612d', 'De la révolution à l''unité', 1, '5c797071-b0b7-5ded-838e-b00428a136a8', false, '#34495e', 1849, null, null, false, 1871, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('b16a9c4c-c3f7-5e1c-a12c-e4f0fc139d91', v_cat, 'country', 'DEU', '5b86e445-5754-5fa4-9a90-e628078f612d', 'L''Empire allemand', 2, '5c797071-b0b7-5ded-838e-b00428a136a8', false, '#2471a3', 1871, null, null, false, 1918, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('23ffbb6e-2207-53ad-bf82-86d1728af3ec', v_cat, 'country', 'DEU', '5b86e445-5754-5fa4-9a90-e628078f612d', 'République de Weimar', 3, '5c797071-b0b7-5ded-838e-b00428a136a8', false, '#c0392b', 1918, null, null, false, 1933, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('f6908d2c-a172-5bde-bd79-9c17cf212bc8', v_cat, 'country', 'DEU', '5b86e445-5754-5fa4-9a90-e628078f612d', 'Le IIIe Reich', 4, '5c797071-b0b7-5ded-838e-b00428a136a8', false, '#17202a', 1933, null, null, false, 1945, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('69e99bc2-85eb-524b-b88c-b2ef96007bd9', v_cat, 'country', 'DEU', '5b86e445-5754-5fa4-9a90-e628078f612d', 'Occupation et naissance de deux États', 5, '5c797071-b0b7-5ded-838e-b00428a136a8', false, '#7f8c8d', 1945, null, null, false, 1949, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('6db70889-ff97-56db-a28d-02c76259beec', v_cat, 'country', 'DEU', '5b86e445-5754-5fa4-9a90-e628078f612d', 'Les deux Allemagnes', 6, '5c797071-b0b7-5ded-838e-b00428a136a8', false, '#d4ac0d', 1949, null, null, false, 1990, null, null, false)
  on conflict (id) do nothing;
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, parent_section_id, title, position, period_frise_id, period_is_transition, period_color, period_start_year, period_start_month, period_start_day, period_start_circa, period_end_year, period_end_month, period_end_day, period_end_circa)
  values ('e031947b-5ade-50c8-a80b-1c958b3600aa', v_cat, 'country', 'DEU', '5b86e445-5754-5fa4-9a90-e628078f612d', 'L''Allemagne réunifiée', 7, '5c797071-b0b7-5ded-838e-b00428a136a8', false, '#16a085', 1990, null, null, false, null, null, null, false)
  on conflict (id) do nothing;

  -- ===== Vérifications : si une seule échoue, tout est annulé (le bloc est une seule transaction) =====
  if (select count(*) from public.dossier_sections where id = any(v_secs)) <> 22 then
    raise exception 'Nombre de périodes inattendu : tout est annulé.';
  end if;
  if (select count(*) from public.dossier_entries where id = any(v_ents) and type = 'frise' and owner_id = 'DEU') <> 4 then
    raise exception 'Nombre de frises inattendu : tout est annulé.';
  end if;
  if (select count(*) from public.dossier_sections where parent_section_id = v_chrono and period_frise_id = 'cb284e7e-510e-5e20-a6d2-d7f4c9304bda') <> 4 then
    raise exception 'Nombre d''époques inattendu : tout est annulé.';
  end if;
end $$;
