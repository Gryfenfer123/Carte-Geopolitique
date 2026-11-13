-- ============================================================
-- Atlas Géopolitique — frises_v6 (2026-11-13) : Allemagne, période « Antiquité » — 8 événements sourcés
--
-- Demande de Martin (2026-11-13) : « on va faire par période ». CRÉATION seulement (aucune suppression) : pour chaque événement un point
-- sur la frise « Histoire de l'Allemagne » (frises_v4) + une fiche rangée dans la période « Antiquité » (fiche sans texte : titre, date et sources).
-- Chaque date a au moins 2 sources dont une universitaire (docs/sources/frises.md, § « Allemagne — période Antiquité »).
-- Désaccords notés : ≈260 (« Limesfall » contesté), 406 (405 selon Kulikowski), ≈85 et ≈98 (circa). Années seules.
-- Les catégories (couleurs) sont lues par leur nom dans timeline_categories ; si un nom manque, le script s'arrête sans rien écrire.
-- Prérequis : frises_v4 exécuté. Idempotent. Exécuté par Claude via le connecteur Supabase (décision de Martin, 2026-11-02).
-- Retour arrière : supprimer les points (et leurs fiches) dans la période Antiquité de la frise de l'Allemagne.
-- ============================================================
do $$
declare
  v_cat uuid := '428a2e75-c8e3-51a1-b12a-bfe7a4018659';
begin
  if not exists (select 1 from public.dossier_sections where id = '8d8f41ef-023c-53d9-9ca7-e46bc140079e' and owner_id = 'DEU' and title = 'Antiquité')
     or not exists (select 1 from public.dossier_entries where id = 'cb284e7e-510e-5e20-a6d2-d7f4c9304bda' and owner_id = 'DEU' and type = 'frise') then
    raise exception 'La frise ou la période Antiquité de l''Allemagne (frises_v4) est introuvable : rien n''a été fait.';
  end if;
  if (select count(distinct name) from public.timeline_categories where name in ('Conflit')) <> 1 then
    raise exception 'Une catégorie de couleur est introuvable dans timeline_categories : rien n''a été fait.';
  end if;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year) values ('44b13c28-93d9-551f-9c8f-4b0e89f79320', 'Victoire de César sur Arioviste', -58, null, null, false, null) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('959860aa-d899-550f-9455-46cd1f3d0431', 'country', 'DEU', 'text', 'Victoire de César sur Arioviste', v_cat, '8d8f41ef-023c-53d9-9ca7-e46bc140079e', '{}', '[{"label": "A. Fahrmeir, Deutsche Geschichte (Beck), extrait bpb", "url": "https://www.bpb.de/system/files/dokument_pdf/Fahrmeir%2C%20Deutsche%20Geschichte%20%28Leseprobe%29.pdf"}, {"label": "R. Fellmann (univ. Berne), « Rome et les Germains ou l''enjeu du Rhin »", "url": "https://www.clio.fr/BIBLIOTHEQUE/pdf/pdf_rome_et_les_germains_ou_l_enjeu_du_rhin.pdf"}, {"label": "A. Volkmann (univ. Francfort), « Die Germanen »", "url": "https://opus.bibliothek.uni-wuerzburg.de/files/5424/A._Volkmann_Die_Germanen.pdf"}, {"label": "Universalis — Germanie", "url": "https://www.universalis.fr/encyclopedie/germanie/"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('959860aa-d899-550f-9455-46cd1f3d0431', '44b13c28-93d9-551f-9c8f-4b0e89f79320') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('cb284e7e-510e-5e20-a6d2-d7f4c9304bda', '44b13c28-93d9-551f-9c8f-4b0e89f79320', 'up', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year) values ('7f789566-7b04-5ef1-97c0-761bef80677e', 'Campagnes de Drusus entre Rhin et Elbe', -12, null, null, false, -9) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('7bdd2450-e507-5cab-b6dd-5cec33f3243f', 'country', 'DEU', 'text', 'Campagnes de Drusus entre Rhin et Elbe', v_cat, '8d8f41ef-023c-53d9-9ca7-e46bc140079e', '{}', '[{"label": "Historisches Lexikon der Schweiz — Drusus", "url": "https://hls-dhs-dss.ch/articles/010323"}, {"label": "Article univ. de Padoue sur les campagnes de Drusus (4 campagnes, 12-9 av. J.-C.)", "url": "https://fc.cab.unipd.it/fedora/objects/o:460044/methods/bdef:Content/download"}, {"label": "J. Asbach, « Die Überlieferung der germanischen Kriege des Augustus », Bonner Jahrbücher", "url": "https://journals.ub.uni-heidelberg.de/index.php/bjb/article/view/45319/38762"}, {"label": "Hamburg Geschichtsbuch — Die Römer an der Elbe (matériel scolaire)", "url": "https://geschichtsbuch.hamburg.de/wp-content/uploads/sites/255/2017/08/QUELLEN-Die-Römer-an-der-Elbe.kor_.pdf"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('7bdd2450-e507-5cab-b6dd-5cec33f3243f', '7f789566-7b04-5ef1-97c0-761bef80677e') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('cb284e7e-510e-5e20-a6d2-d7f4c9304bda', '7f789566-7b04-5ef1-97c0-761bef80677e', 'down', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year) values ('d2162a38-4736-55ec-9011-47da27357b3d', 'Défaite de Varus (Teutobourg)', 9, null, null, false, null) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('bdcc5dce-0bba-5325-8f54-7a3eae6e0325', 'country', 'DEU', 'text', 'Défaite de Varus (Teutobourg)', v_cat, '8d8f41ef-023c-53d9-9ca7-e46bc140079e', '{}', '[{"label": "HIMA (Univ. de Bourgogne) — Rome''s First Frontier", "url": "https://preo.ube.fr/hima/index.php?id=2345"}, {"label": "Britannica — Battle of the Teutoburg Forest", "url": "https://www.britannica.com/event/Battle-of-the-Teutoburg-Forest"}, {"label": "Musée et parc archéologique de Kalkriese — The Varus Battle", "url": "https://www.kalkriese-varusschlacht.de/en/the-varus-battle.html"}, {"label": "Livius — Kalkriese", "url": "https://www.livius.org/articles/battle/teutoburg-forest-9-ce/kalkriese"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('bdcc5dce-0bba-5325-8f54-7a3eae6e0325', 'd2162a38-4736-55ec-9011-47da27357b3d') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('cb284e7e-510e-5e20-a6d2-d7f4c9304bda', 'd2162a38-4736-55ec-9011-47da27357b3d', 'up', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year) values ('a56ce38d-2da2-5524-a2e5-bf907e11fa6a', 'Rome renonce à conquérir la Germanie au-delà du Rhin (rappel de Germanicus)', 16, null, null, false, null) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('5bf818bb-1c5c-5cd4-848d-dfb3e1ed995f', 'country', 'DEU', 'text', 'Rome renonce à conquérir la Germanie au-delà du Rhin (rappel de Germanicus)', v_cat, '8d8f41ef-023c-53d9-9ca7-e46bc140079e', '{}', '[{"label": "HIMA (Univ. de Bourgogne) — Rome''s First Frontier", "url": "https://preo.ube.fr/hima/index.php?id=2345"}, {"label": "Tijdschrift voor Geschiedenis 124 (2011) — Germanicus, Tacitus et les campagnes de Germanie (14-16)", "url": "https://www.aup-online.com/content/journals/10.5117/TVGESCH2011.3.KERR"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('5bf818bb-1c5c-5cd4-848d-dfb3e1ed995f', 'a56ce38d-2da2-5524-a2e5-bf907e11fa6a') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('cb284e7e-510e-5e20-a6d2-d7f4c9304bda', 'a56ce38d-2da2-5524-a2e5-bf907e11fa6a', 'down', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year) values ('aaad86a0-030b-5890-a24a-1fe0d3a984b1', 'Création des provinces de Germanie supérieure et inférieure', 85, null, null, true, null) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('2b65f21b-4a0f-54b0-9a4f-b08e81da1592', 'country', 'DEU', 'text', 'Création des provinces de Germanie supérieure et inférieure', v_cat, '8d8f41ef-023c-53d9-9ca7-e46bc140079e', '{}', '[{"label": "HIMA (Univ. de Bourgogne) — Rome''s First Frontier", "url": "https://preo.ube.fr/hima/index.php?id=2345"}, {"label": "A. Schäfer, Propylaeum (univ. Heidelberg) — Domitien et la frontière du Rhin (84/85)", "url": "https://books.ub.uni-heidelberg.de/propylaeum/catalog/view/1414/2602/118901"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('2b65f21b-4a0f-54b0-9a4f-b08e81da1592', 'aaad86a0-030b-5890-a24a-1fe0d3a984b1') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('cb284e7e-510e-5e20-a6d2-d7f4c9304bda', 'aaad86a0-030b-5890-a24a-1fe0d3a984b1', 'up', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year) values ('a5fb38ca-2ee9-5e48-ace5-f7b6ca067d25', 'Tacite écrit la Germanie', 98, null, null, true, null) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('bd1ca600-d8e1-5e71-8084-248ab446439a', 'country', 'DEU', 'text', 'Tacite écrit la Germanie', v_cat, '8d8f41ef-023c-53d9-9ca7-e46bc140079e', '{}', '[{"label": "BnF data — Tacite, La Germanie (date : 98)", "url": "https://data.bnf.fr/fr/12244271/tacite_la_germanie/fr.pdf"}, {"label": "Thèse univ. de São Paulo — traduction de la Germania (98)", "url": "https://teses.usp.br/teses/disponiveis/8/8143/tde-20042012-114933/publico/2011_MariaCeciliaALSilvadeAndrade_VRev.pdf"}, {"label": "Britannica — Tacitus", "url": "https://www.britannica.com/biography/Tacitus-Roman-historian"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('bd1ca600-d8e1-5e71-8084-248ab446439a', 'a5fb38ca-2ee9-5e48-ace5-f7b6ca067d25') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('cb284e7e-510e-5e20-a6d2-d7f4c9304bda', 'a5fb38ca-2ee9-5e48-ace5-f7b6ca067d25', 'down', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year) values ('912adaa3-8074-530a-9d81-a2ff6d1ba80b', 'Abandon du limes de Germanie supérieure et de Rhétie (« Limesfall »)', 260, null, null, true, null) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('bb7faae4-7fb1-525d-acb2-18819e321a76', 'country', 'DEU', 'text', 'Abandon du limes de Germanie supérieure et de Rhétie (« Limesfall »)', v_cat, '8d8f41ef-023c-53d9-9ca7-e46bc140079e', '{}', '[{"label": "S. Heeren, « The theory of Limesfall », Germania 94 (2016)", "url": "https://journals.ub.uni-heidelberg.de/index.php/germania/article/view/39072/32733"}, {"label": "H. U. Nuber, « Das Ende des Obergermanisch-Raetischen Limes » (Propylaeum, univ. Heidelberg)", "url": "https://books.ub.uni-heidelberg.de/propylaeum/catalog/view/1029/1755/97665"}, {"label": "K. Weidemann, Jahrbuch RGZM 19 (1972)", "url": "https://journals.ub.uni-heidelberg.de/index.php/jahrb-rgzm/article/view/43720/37218"}, {"label": "G. Fingerlin, Alemannisches Jahrbuch 2006", "url": "https://alemannisches-institut.de/html/img/pool/AlemJb2006Fingerlin1.pdf"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('bb7faae4-7fb1-525d-acb2-18819e321a76', '912adaa3-8074-530a-9d81-a2ff6d1ba80b') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('cb284e7e-510e-5e20-a6d2-d7f4c9304bda', '912adaa3-8074-530a-9d81-a2ff6d1ba80b', 'up', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;
  insert into public.timeline_events (id, title, date_year, date_month, date_day, date_circa, date_end_year) values ('bf5106eb-2d80-5e80-be7b-4f3faaa8fb4c', 'Passage du Rhin par Vandales, Alains et Suèves', 406, null, null, false, null) on conflict (id) do nothing;
  insert into public.dossier_entries (id, owner_type, owner_id, type, title, category_id, section_id, tags, sources, status)
  values ('8313044b-2a1d-5f0c-a1c7-41439fae9b9c', 'country', 'DEU', 'text', 'Passage du Rhin par Vandales, Alains et Suèves', v_cat, '8d8f41ef-023c-53d9-9ca7-e46bc140079e', '{}', '[{"label": "Chronica (univ. de Szeged) — les participants à l''invasion de 406", "url": "https://ojs.bibl.u-szeged.hu/index.php/chronica/article/download/10743/10634/11103"}, {"label": "Historisches Lexikon der Schweiz — Völkerwanderung", "url": "https://hls-dhs-dss.ch/de/articles/017148/"}, {"label": "Discussion de la date (405 ou 406), article universitaire", "url": "https://www.academia.edu/3894084"}]'::jsonb, 'published')
  on conflict (id) do nothing;
  insert into public.timeline_event_fiches (entry_id, event_id) values ('8313044b-2a1d-5f0c-a1c7-41439fae9b9c', 'bf5106eb-2d80-5e80-be7b-4f3faaa8fb4c') on conflict (entry_id) do nothing;
  insert into public.timeline_placements (frise_entry_id, event_id, side, category_id)
  values ('cb284e7e-510e-5e20-a6d2-d7f4c9304bda', 'bf5106eb-2d80-5e80-be7b-4f3faaa8fb4c', 'down', (select id from public.timeline_categories where name = 'Conflit' limit 1))
  on conflict (frise_entry_id, event_id) do nothing;

  -- ===== Vérifications : si une seule échoue, tout est annulé =====
  if (select count(*) from public.timeline_events where id = any(array['44b13c28-93d9-551f-9c8f-4b0e89f79320', '7f789566-7b04-5ef1-97c0-761bef80677e', 'd2162a38-4736-55ec-9011-47da27357b3d', 'a56ce38d-2da2-5524-a2e5-bf907e11fa6a', 'aaad86a0-030b-5890-a24a-1fe0d3a984b1', 'a5fb38ca-2ee9-5e48-ace5-f7b6ca067d25', '912adaa3-8074-530a-9d81-a2ff6d1ba80b', 'bf5106eb-2d80-5e80-be7b-4f3faaa8fb4c']::uuid[])) <> 8 then
    raise exception 'Nombre d''événements inattendu : tout est annulé.';
  end if;
  if (select count(*) from public.timeline_event_fiches where event_id = any(array['44b13c28-93d9-551f-9c8f-4b0e89f79320', '7f789566-7b04-5ef1-97c0-761bef80677e', 'd2162a38-4736-55ec-9011-47da27357b3d', 'a56ce38d-2da2-5524-a2e5-bf907e11fa6a', 'aaad86a0-030b-5890-a24a-1fe0d3a984b1', 'a5fb38ca-2ee9-5e48-ace5-f7b6ca067d25', '912adaa3-8074-530a-9d81-a2ff6d1ba80b', 'bf5106eb-2d80-5e80-be7b-4f3faaa8fb4c']::uuid[])) <> 8 then
    raise exception 'Nombre de fiches inattendu : tout est annulé.';
  end if;
  if (select count(*) from public.timeline_placements where frise_entry_id = 'cb284e7e-510e-5e20-a6d2-d7f4c9304bda' and event_id = any(array['44b13c28-93d9-551f-9c8f-4b0e89f79320', '7f789566-7b04-5ef1-97c0-761bef80677e', 'd2162a38-4736-55ec-9011-47da27357b3d', 'a56ce38d-2da2-5524-a2e5-bf907e11fa6a', 'aaad86a0-030b-5890-a24a-1fe0d3a984b1', 'a5fb38ca-2ee9-5e48-ace5-f7b6ca067d25', '912adaa3-8074-530a-9d81-a2ff6d1ba80b', 'bf5106eb-2d80-5e80-be7b-4f3faaa8fb4c']::uuid[])) <> 8 then
    raise exception 'Nombre de placements inattendu : tout est annulé.';
  end if;
end $$;
