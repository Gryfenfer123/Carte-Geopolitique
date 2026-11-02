-- ============================================================
-- groupes_v4 — dossier d'EXEMPLE « OTAN » (3/3) : Poids et chiffres, Relations/tensions/critiques
-- Prérequis : groupes_v1 exécuté (catégories). groupes_v2 et v3 recommandés (même exemple).
-- Idempotente (ids fixes, ON CONFLICT DO NOTHING). Ne supprime rien.
-- Retour arrière : voir groupes_v2.sql (balise de tag « Exemple OTAN »).
-- Les entrées de « Relations, tensions et critiques » présentent les positions des deux côtés,
-- avec leurs sources ; aucune opinion propre au projet.
-- ============================================================

create temp table if not exists src(k text primary key, label text, url text);
insert into src(k,label,url) values
 ('sgar25','Rapport annuel 2025 du secrétaire général (26 mars 2026) — nato.int','https://www.nato.int/en/news-and-events/articles/news/2026/03/26/nato-secretary-generals-annual-report-shows-significant-increase-in-defence-investment-from-europe-and-canada'),
 ('fivepct','Defence investment and NATO''s 5% commitment — nato.int','https://www.nato.int/en/what-we-do/introduction-to-nato/defence-expenditures-and-natos-5-commitment'),
 ('sgar24','Rapport annuel 2024 du secrétaire général (PDF) — nato.int','https://www.nato.int/content/dam/nato/legacy-wcm/media_pdf/2025/4/pdf/sgar24-en.pdf'),
 ('defexp25','Defence Expenditure of NATO Countries (2014-2025) — nato.int (août 2025)','https://www.nato.int/content/dam/nato/webready/documents/finance/def-exp-2025-en.pdf'),
 ('defexp24','Defence Expenditure of NATO Countries (2014-2024) — nato.int (juin 2024)','https://www.nato.int/content/dam/nato/legacy-wcm/media_pdf/2024/6/pdf/240617-def-exp-2024-en.pdf'),
 ('reuters26','Reuters, 26 mars 2026 : forte hausse des dépenses de défense de l''Europe et du Canada','https://www.internazionale.it/ultime-notizie-reuters/2026/03/26/nato-sees-sharp-increase-in-europe-s-and-canada-s-defence-spending'),
 ('defmatters','Defence Matters : l''OTAN dit que l''Europe et le Canada ont fortement augmenté leurs dépenses en 2025','https://defencematters.eu/?p=4710'),
 ('ukdj','UK Defence Journal : dépenses de l''OTAN, 1 590 Md$ attendus en 2025','https://ukdefencejournal.org.uk/nato-defence-spending-set-to-reach-1-6-trillion-in-2025/'),
 ('sabah','Daily Sabah : tous les Alliés sur la bonne voie pour 2 % en 2025','https://www.dailysabah.com/world/nato-reveals-all-members-on-track-to-hit-2-spending-goal-in-2025/news/amp'),
 ('gaze','The Gaze : dépenses de défense de l''OTAN 2025','https://thegaze.media/news/nato-defence-spending-surges-with-most-allies-set-to-hit-2-gdp-target-in-2025'),
 ('startmag','Startmag : combien les pays de l''OTAN ont investi en 2025','https://en.startmag.it/spazio-e-difesa/defense-spending-here-is-how-much-nato-countries-invested-in-2025/'),
 ('eunews','Eunews : l''Italie dans le rapport annuel 2025 de l''OTAN','https://www.eunews.it/en/wp-json/wp/v2/posts/448857'),
 ('deterrence','Deterrence and defence — nato.int','https://www.nato.int/en/what-we-do/deterrence-and-defence/deterrence-and-defence'),
 ('hague_decl','The Hague Summit Declaration, 25 juin 2025 — nato.int','https://www.nato.int/en/about-us/official-texts-and-resources/official-texts/2025/06/25/the-hague-summit-declaration'),
 ('hague_concl','NATO concludes historic Summit in The Hague — nato.int','https://www.nato.int/en/news-and-events/articles/news/2025/06/27/nato-concludes-historic-summit-in-the-hague'),
 ('funding','Funding NATO — nato.int','https://www.nato.int/en/what-we-do/introduction-to-nato/funding-nato'),
 ('b2022','NATO agrees 2022 civil and military budgets — nato.int','https://www.nato.int/cps/en/natolive/news_190369.htm'),
 ('b2023','NATO agrees 2023 budgets — nato.int','https://www.nato.int/cps/en/natohq/news_210091.htm?selectedLocale=en'),
 ('b2024','NATO agrees 2024 budgets — nato.int','https://www.nato.int/en/news-and-events/articles/news/2023/12/13/nato-agrees-2024-budgets-demonstrating-allied-solidarity-in-addressing-shared-security-challenges'),
 ('b2025','Allies agree NATO''s 2025 common-funded budgets — nato.int','https://nato.int/en/news-and-events/articles/news/2024/12/17/allies-agree-natos-2025-common-funded-budgets'),
 ('b2026','NATO agrees its 2026 common funded budgets — nato.int','https://www.nato.int/en/news-and-events/articles/news/2025/12/17/nato-agrees-its-2026-common-funded-budgets-strengthening-allied-resolve-in-a-new-era-of-collective-defence'),
 ('cfrp25','The 2025-2029 Common Funding Resource Plan — nato.int','https://nato.int/en/about-us/official-texts-and-resources/official-texts/2024/07/18/the-2025-2029-common-funding-resource-plan'),
 ('nsip24','NSIP : activité financière au 31 décembre 2024 — nato.int','https://www.nato.int/content/dam/nato/webready/documents/finance/NSIP-2024-fin-act.pdf'),
 ('efp','Strengthening NATO''s eastern flank — nato.int','https://www.nato.int/en/what-we-do/deterrence-and-defence/strengthening-natos-eastern-flank'),
 ('kosovo','NATO''s role in Kosovo — nato.int','https://www.nato.int/en/what-we-do/operations-and-missions/natos-role-in-kosovo'),
 ('ops','NATO operations and missions — nato.int','https://www.nato.int/en/what-we-do/operations-and-missions/nato-operations-and-missions'),
 ('bosnia','Peace support operations in Bosnia and Herzegovina — nato.int','https://www.nato.int/en/what-we-do/operations-and-missions/peace-support-operations-in-bosnia-and-herzegovina-1995-2004'),
 ('nuc_share','NATO''s Nuclear Sharing Arrangements (fiche, 2022)','https://www.nato.int/content/dam/nato/legacy-wcm/media_pdf/2022/2/pdf/220204-factsheet-nuclear-sharing-arrangements_en.pdf'),
 ('nuclear','NATO''s nuclear deterrence policy and forces — nato.int','https://www.nato.int/en/what-we-do/deterrence-and-defence/natos-nuclear-deterrence-policy-and-forces'),
 ('nato_home','OTAN — page d''accueil (nato.int)','https://www.nato.int/en'),
 ('russia','Relations with Russia — nato.int','https://nato.int/en/what-we-do/partnerships-and-cooperation/relations-with-russia'),
 ('nrc','NATO-Russia Council — nato.int','https://www.nato.int/en/about-us/organization/nato-structure/nato-russia-council'),
 ('nrc_fr','Les relations OTAN-Russie (fiche, février 2022)','https://www.nato.int/content/dam/nato/legacy-wcm/media_pdf/2022/2/pdf/220214-factsheet_NATO-Russia_Relations_fr.pdf'),
 ('suspend14','Measures following NATO Ministers'' decision to suspend all practical cooperation with Russia (2014)','https://nato.int/cps/en/natolive/news_108902.htm'),
 ('straight','Setting the record straight — nato.int','https://www.nato.int/en/what-we-do/wider-activities/natos-approach-to-counter-information-threats/setting-the-record-straight'),
 ('strat','NATO 2022 Strategic Concept — nato.int','https://www.nato.int/en/about-us/official-texts-and-resources/strategic-concepts/nato-2022-strategic-concept'),
 ('strat_pdf','Strategic Concept 2022, texte intégral (PDF)','https://www.act.nato.int/wp-content/uploads/2023/05/290622-strategic-concept.pdf'),
 ('ndc','NATO''s New Strategic Concept — NATO Defense College','https://www.ndc.nato.int/natos-new-strategic-concept/'),
 ('stmt2022','Statement by NATO Heads of State and Government, 24 mars 2022','https://www.nato.int/en/about-us/official-texts-and-resources/official-texts/2022/03/24/statement-by-nato-heads-of-state-and-government'),
 ('ukraine','Relations with Ukraine — nato.int','https://www.nato.int/en/what-we-do/partnerships-and-cooperation/relations-with-ukraine'),
 ('bulwark','The Bulwark : The Real Reasons Putin Feels Threatened by NATO','https://www.thebulwark.com/p/the-real-reasons-putin-feels-threatened-by-nato'),
 ('hnn','History News Network : analyse des thèses réalistes sur l''élargissement','https://historynewsnetwork.org/article/185210'),
 ('motyl','European Leadership Network : Mearsheimer, « logique impeccable, faits erronés » (Motyl, 2014)','https://europeanleadershipnetwork.org/commentary/the-ukraine-crisis-according-to-john-j-mearsheimer-impeccable-logic-wrong-facts/'),
 ('usp','Étude universitaire : NATO enlargement — evaluating its consequences in Russia','https://edisciplinas.usp.br/mod/resource/view.php?id=4972988'),
 ('hill','The Hill : critique de l''argument de Mearsheimer','https://digital-release.thehill.com/?p=3884025'),
 ('enlarge','Enlargement and Article 10 — nato.int','https://www.nato.int/en/what-we-do/partnerships-and-cooperation/enlargement-and-article-10'),
 ('bucharest','Bucharest Summit Declaration — nato.int','https://www.nato.int/cps/en/natolive/official_texts_8443.htm'),
 ('def2022','NATO Defence Ministers reaffirm open door policy (17 fév. 2022) — nato.int','https://www.nato.int/en/news-and-events/articles/news/2022/02/17/nato-defence-ministers-reaffirm-their-strong-commitment-to-open-door-policy-and-the-importance-of-partnerships'),
 ('rutte_office','Mark Rutte takes office as NATO Secretary General — nato.int','https://www.nato.int/en/news-and-events/articles/news/2024/10/01/mark-rutte-takes-office-as-nato-secretary-general'),
 ('ap_spain','AP : l''Espagne obtient un accord pour être exclue de l''objectif de 5 % (juin 2025)','https://www.therepublic.com/?p=803284'),
 ('fortune_spain','Fortune/Bloomberg : l''Espagne obtient une exemption (23 juin 2025)','https://www.fortune.com/europe/2025/06/23/spain-wins-exemption-nato-5-defense-spending-goal-pedro-sanchez-trump'),
 ('fmt','Reuters via Free Malaysia Today : l''OTAN relève son objectif, l''Espagne dit se retirer','https://www.freemalaysiatoday.com/category/world/2025/06/23/nato-agrees-to-higher-defence-spending-goal-spain-says-it-is-opting-out'),
 ('sw_inq','Reuters : la Turquie approuve l''adhésion de la Suède après 20 mois','https://newsinfo.inquirer.net/1893482/turkey-approves-swedens-nato-membership-bid-after-20-month-delay'),
 ('sw_fe','Reuters : la Turquie sur le point d''approuver l''adhésion de la Suède','https://thefinancialexpress.com.bd/world/turkey-set-to-approve-swedens-nato-membership-bid-after-long-delay'),
 ('sw_neos','Neos Kosmos : la Turquie ratifie l''adhésion de la Suède','https://neoskosmos.com/en/2024/01/24/news/turkey-ratifies-swedens-nato-membership-after-protracted-delay/'),
 ('sw_bday','Reuters (BusinessDay) : la Turquie pourrait ratifier « sous quelques semaines » (nov. 2023)','https://www.businessday.co.za/bd/world/europe/2023-11-29-turkey-may-ratify-swedens-nato-membership-bid-within-weeks'),
 ('sw_ap','AP : la Turquie finalise la ratification (25 janv. 2024)','https://www.nsnews.com/world-news/turkey-formally-ratifies-swedens-nato-membership-leaving-hungary-as-only-ally-yet-to-endorse-it-8162685'),
 ('sw_bbg','Bloomberg : la Suède se rapproche de l''OTAN, la Hongrie demande des discussions','https://news.yahoo.com/sweden-edges-closer-joining-nato-105945007.html'),
 ('dtic','Thèse (DTIC) : le différend gréco-turc en mer Égée et l''OTAN','https://apps.dtic.mil/sti/tr/pdf/ADA389730.pdf'),
 ('csm1983','Christian Science Monitor, 6 mai 1983 : Greece and Turkey are talking','https://csmonitor.com/1983/0506/050664.html'),
 ('carnegie','Carnegie Endowment, 3 sept. 2020','https://carnegieendowment.org/2020/09/03/four-schools-of-thought-that-now-divide-gop-on-foreign-policy-pub-82643'),
 ('courthouse','AFP : Turkey v. Greece, a long history of disputes','https://www.courthousenews.com/turkey-v-greece-a-long-history-of-disputes/'),
 ('france_nato','France and NATO — nato.int','https://www.nato.int/cps/en/natohq/declassified_160672.htm'),
 ('shape_fr','SHAPE in France — shape.nato.int','https://shape.nato.int/about-us/what-is-shape/shape-in-france'),
 ('short_hist','A short history of NATO — nato.int','https://www.nato.int/en/about-us/nato-history/a-short-history-of-nato'),
 ('members_os','NATO member countries (France 1966-2009) — nato.int','https://www.nato.int/cps/en/natohq/topics_52044.htm?os=av'),
 ('macron_axios','Axios, 7 nov. 2019 : Macron parle de « mort cérébrale » de l''OTAN','https://www.axios.com/2019/11/07/macron-interview-nato-alliance-trump-brain-dead'),
 ('macron_globe','The Globe and Mail / Presse canadienne, nov. 2019','https://www.theglobeandmail.com/amp/politics/article-trudeau-says-nato-is-still-important-despite-macrons-warning-of/'),
 ('macron_afp','AFP via Business Recorder : Macron et la « mort cérébrale »','https://www.brecorder.com/news/542657'),
 ('haglund','Haglund, « NATO''s Macronian peril » (chapitre universitaire)','https://www.queensu.ca/politics/sites/polswww/files/uploaded_files/Faculty%20Pages/9780367706937c04_p101-118.pdf'),
 ('crs','CRS, Kosovo and NATO: Selected Issues of International Law (28 avril 1999)','https://www.everycrsreport.com/reports/RL30152.html'),
 ('asil','ASIL : The Kosovo Situation and NATO Military Action','https://asil.org/node/1304'),
 ('karnavas','Michael G. Karnavas : humanitarian intervention au Kosovo (séminaire Brown)','https://michaelgkarnavas.net/blog/?p=416'),
 ('studia','Studia Securitatis 2023 : opérations de maintien de la paix au Kosovo après 1999','https://magazines.ulbsibiu.ro/studiasecuritatis/wp-content/uploads/STUDIA-SECURITATIS-No.-2-2023-1-256-269.pdf'),
 ('raf','RAF Air Power Review : la Libye, la responsabilité de protéger et la force militaire','https://www.raf.mod.uk/what-we-do/centre-for-air-and-space-power-studies/aspr/apr-vol17-iss3-2-pdf/'),
 ('iemed','IEMed : NATO''s Intervention in Libya — Assessment and Implications','https://www.iemed2.upcnet.es/wp-content/uploads/2021/02/NATOs-Intervention-in-Libya-Assessment-and-Implications.pdf'),
 ('mspace','Essai universitaire (Manitoba) : l''OTAN et les résolutions 1970/1973','https://mspace.lib.umanitoba.ca/bitstreams/4e47d9fc-d1a2-4130-9fd0-ae6484fdbfb7/download'),
 ('un_rel','Relations with the United Nations — nato.int','https://nato.int/cps/en/natohq/topics_50321.htm'),
 ('armscontrol','Arms control, disarmament and non-proliferation — nato.int','https://www.nato.int/en/what-we-do/wider-activities/arms-control-disarmament-and-non-proliferation'),
 ('stolt2021','Discours du secrétaire général, 2 nov. 2021 — nato.int','https://www.nato.int/en/news-and-events/events/transcripts/2021/11/02/speech'),
 ('bih','Relations with Bosnia and Herzegovina — nato.int (accords Berlin Plus)','https://www.nato.int/en/what-we-do/partnerships-and-cooperation/relations-with-bosnia-and-herzegovina?selectedLocale=ic'),
 ('guideline','Defence expenditures and NATO''s 2% guideline — nato.int','https://www.nato.int/cps/ic/natohq/topics_49198.htm'),
 ('defpost','The Defense Post : l''objectif de 5 % « déraisonnable » pour l''Espagne (20 juin 2025)','https://thedefensepost.com/2025/06/20/nato-spending-unreasonable-spain/amp/'),
 ('babel','Reuters : la Turquie retarde de nouveau la ratification pour la Suède (Babel)','https://babel.ua/en/news/100947-reuters-turkey-once-again-postponed-the-ratification-of-sweden-s-accession-to-nato')
on conflict (k) do nothing;

create or replace function pg_temp.s(k text, cat text, t text, pos int) returns void language plpgsql as $f$
begin
  insert into public.dossier_sections (id, category_id, owner_type, owner_id, title, position)
  select md5('otan-sec:'||k)::uuid, c.id, 'group', 'ffdd3a51-8c60-53f0-baa3-bbb944672416', t, pos
  from public.dossier_categories c where c.space='group' and c.name=cat
  on conflict (id) do nothing;
end $f$;

create or replace function pg_temp.e(cat text, sec text, ord int, t text, b text, keys text[]) returns void language plpgsql as $f$
begin
  insert into public.dossier_entries (id, section_id, category_id, owner_type, owner_id, type, title, body_html, tags, sources, status, created_at, updated_at)
  select md5('otan-ent:'||t)::uuid,
         case when sec is null then null else md5('otan-sec:'||sec)::uuid end,
         c.id, 'group', 'ffdd3a51-8c60-53f0-baa3-bbb944672416', 'text', t, b,
         array['Sourcé','Exemple OTAN','À relire 02/11/2026'],
         (select coalesce(jsonb_agg(jsonb_build_object('label',x.label,'url',x.url) order by array_position(keys,x.k)),'[]'::jsonb) from src x where x.k = any(keys)),
         'published',
         timestamptz '2026-11-02 21:00:00+01' + ord * interval '1 second',
         timestamptz '2026-11-02 21:00:00+01' + ord * interval '1 second'
  from public.dossier_categories c where c.space='group' and c.name=cat
  on conflict (id) do nothing;
end $f$;

-- ===================== POIDS ET CHIFFRES =====================
select pg_temp.s('poi-depenses','Poids et chiffres','Les dépenses de défense',10);
select pg_temp.s('poi-budgets','Poids et chiffres','Les budgets communs',20);
select pg_temp.s('poi-forces','Poids et chiffres','Forces et présence',30);
select pg_temp.s('poi-manque','Poids et chiffres','À compléter',40);

select pg_temp.e('Poids et chiffres','poi-depenses',90,'2025 : pour la première fois, tous les Alliés atteignent 2 % du PIB',
$$<ul>
<li><strong>Le constat :</strong> dans son rapport annuel 2025, présenté le 26 mars 2026, le secrétaire général indique que pour la première fois tous les Alliés ont déclaré des dépenses de défense égales ou supérieures à l'objectif de 2 % du PIB fixé en 2014. En 2014, seuls trois Alliés l'atteignaient ; en 2024, vingt-deux.</li>
<li><strong>Europe et Canada :</strong> hausse d'environ 20 % en 2025 par rapport à 2024 (en termes réels), soit plus de 90 milliards de dollars (prix de 2021), près de 139 milliards en valeur courante. Leur effort cumulé passe de 1,4 % de leur PIB en 2014 à 2,3 % en 2025, pour plus de 571 milliards de dollars (prix de 2021).</li>
<li><strong>Ensemble de l'Alliance :</strong> 2,77 % du PIB consacrés à la défense en 2025 ; les États-Unis représentent environ 60 % des dépenses de défense de l'Alliance.</li>
<li><strong>Au-delà de 3,5 % :</strong> selon la presse qui cite le rapport, trois pays — Pologne, Lituanie et Lettonie — ont dépassé 3,5 % du PIB en 2025.</li>
<li><strong>Total :</strong> les estimations d'août 2025 évoquaient environ 1 590 milliards de dollars en prix courants ; le rapport de mars 2026 parle de plus de 1 400 milliards en prix constants de 2021. Les deux chiffres ne sont pas comparables (bases de prix différentes).</li>
</ul>
<p>L'OTAN précise que sa définition des dépenses de défense peut différer des chiffres des budgets nationaux ou de la presse.</p>$$,
 array['sgar25','fivepct','sgar24','reuters26','defmatters','startmag','ukdj']);

select pg_temp.e('Poids et chiffres','poi-depenses',91,'L''engagement de La Haye : 5 % du PIB en 2035',
$$<ul>
<li><strong>Décision :</strong> le 25 juin 2025, à La Haye, les chefs d'État et de gouvernement des 32 Alliés s'engagent à consacrer 5 % du PIB par an à la défense d'ici 2035.</li>
<li><strong>Deux étages :</strong> au moins <strong>3,5 %</strong> pour les besoins de défense proprement dits et les objectifs de capacités de l'OTAN ; jusqu'à <strong>1,5 %</strong> pour des dépenses liées à la défense et à la sécurité au sens large (infrastructures critiques, réseaux, préparation civile et résilience, innovation, base industrielle de défense).</li>
<li><strong>Suivi :</strong> chaque Allié remet des plans annuels montrant une trajectoire crédible et progressive ; la trajectoire sera réexaminée en 2029.</li>
<li><strong>Ukraine :</strong> les contributions directes à la défense de l'Ukraine et à son industrie de défense comptent dans ces dépenses.</li>
<li><strong>S'appuie sur</strong> l'engagement de 2014 (2 % du PIB et 20 % des dépenses pour les grands équipements).</li>
<li><strong>Une exception contestée :</strong> l'Espagne a affirmé ne pas être tenue par ce seuil (voir « Relations, tensions et critiques »).</li>
</ul>$$,
 array['hague_decl','fivepct','hague_concl','deterrence']);

select pg_temp.e('Poids et chiffres','poi-depenses',92,'Du seuil de 2 % (2006, 2014) au 5 % (2025) : les étapes',
$$<table>
<tr><th>Date</th><th>Décision ou constat</th></tr>
<tr><td>2006</td><td>Les ministres de la Défense s'accordent sur un repère : 2 % du PIB pour la défense.</td></tr>
<tr><td>2014 (sommet du pays de Galles)</td><td>Engagement d'investissement de défense : arrêter les baisses de budget, aller vers 2 % du PIB en dix ans et consacrer au moins 20 % des dépenses aux grands équipements et à la recherche associée. Cette année-là, seuls trois Alliés atteignent 2 %.</td></tr>
<tr><td>2024</td><td>Vingt-deux Alliés atteignent 2 %. Europe et Canada : 2,02 % de leur PIB cumulé.</td></tr>
<tr><td>2025 (La Haye)</td><td>Engagement de 5 % du PIB d'ici 2035 (3,5 % + 1,5 %).</td></tr>
<tr><td>2025 (résultats)</td><td>Les 32 Alliés atteignent ou dépassent 2 % pour la première fois.</td></tr>
</table>$$,
 array['deterrence','guideline','fivepct','sgar24','sgar25']);

select pg_temp.e('Poids et chiffres','poi-depenses',93,'Dépenses de défense par pays (% du PIB)',
$$<p>Extraits des tableaux publiés par l'OTAN (estimations ; elles sont révisées à chaque publication).</p>
<table>
<tr><th>Pays</th><th>2014</th><th>2024 (estimation de juin 2024)</th><th>2025 (estimation d'août 2025)</th></tr>
<tr><td>États-Unis</td><td>3,71</td><td>3,38</td><td>3,22</td></tr>
<tr><td>Allemagne</td><td>1,19</td><td>2,12</td><td>—</td></tr>
<tr><td>Pologne</td><td>1,88</td><td>4,12</td><td>4,48 (presse)</td></tr>
<tr><td>Espagne</td><td>0,92</td><td>1,28</td><td>2,00</td></tr>
<tr><td>Royaume-Uni</td><td>2,14</td><td>—</td><td>2,40</td></tr>
<tr><td>Suède</td><td>1,07</td><td>—</td><td>2,51</td></tr>
<tr><td>Türkiye</td><td>1,45</td><td>—</td><td>2,33</td></tr>
<tr><td>Lituanie</td><td>—</td><td>—</td><td>4,00 (presse)</td></tr>
<tr><td>Lettonie</td><td>—</td><td>—</td><td>3,73 (presse)</td></tr>
<tr><td>Estonie</td><td>—</td><td>—</td><td>3,38 (presse)</td></tr>
<tr><td>Italie</td><td>—</td><td>—</td><td>2,01 (presse, d'après le rapport annuel)</td></tr>
</table>
<p>En dollars constants de 2021, l'OTAN estime les dépenses américaines à 747,2 milliards en 2014 et 845,3 milliards en 2025, celles du Royaume-Uni à 62,7 puis 81,3 milliards, celles de l'Espagne à 12,2 puis 33,6 milliards, celles de la Suède à 5,8 puis 16,6 milliards, celles de la Türkiye à 8,4 puis 22,2 milliards.</p>
<p>« Presse » : chiffres repris par des médias à partir des publications de l'OTAN, non lus directement dans le tableau de l'OTAN. Le tableau complet (32 pays) est à compléter.</p>$$,
 array['defexp25','defexp24','sabah','gaze','eunews']);

select pg_temp.e('Poids et chiffres','poi-depenses',94,'Le poids des États-Unis dans l''Alliance',
$$<ul>
<li><strong>2024 (estimation) :</strong> les États-Unis représentent 53 % du PIB cumulé des Alliés et 64 % de leurs dépenses de défense (en prix courants).</li>
<li><strong>2025 :</strong> environ 60 % des dépenses de défense de l'Alliance, selon le rapport de mars 2026 cité par Reuters.</li>
<li>L'OTAN observe que la part américaine baisse à mesure que les autres Alliés augmentent leurs dépenses.</li>
</ul>
<p>Ces proportions mesurent l'effort de défense global des Alliés ; elles ne mesurent pas ce que chacun verse à l'OTAN elle-même (voir les budgets communs : l'Allemagne et les États-Unis y ont la même part de 14,9 %).</p>$$,
 array['sgar24','reuters26','defmatters','funding']);

select pg_temp.e('Poids et chiffres','poi-budgets',95,'Les budgets communs de 2022 à 2026',
$$<table>
<tr><th>Année</th><th>Budget civil</th><th>Budget militaire</th><th>Plafond NSIP</th></tr>
<tr><td>2022</td><td>289,1 M€</td><td>1,56 Md€</td><td>790 M€</td></tr>
<tr><td>2023</td><td>370,8 M€ (+27,8 %)</td><td>1,96 Md€ (+25,8 %)</td><td>1 Md€ (+26,6 %)</td></tr>
<tr><td>2024</td><td>438,1 M€ (+18,2 %)</td><td>2,03 Md€ (+12 %)</td><td>1 324,4 M€</td></tr>
<tr><td>2025</td><td>483,3 M€ (+10 %)</td><td>2,37 Md€ (+9 %)</td><td>1 722,5 M€ (plafond recommandé)</td></tr>
<tr><td>2026</td><td>528,2 M€</td><td>2,42 Md€</td><td>2,2 Md€</td></tr>
</table>
<p>Au total, le financement commun direct représente environ 4,6 milliards d'euros en 2025 et jusqu'à 5,3 milliards en 2026, soit environ 0,3 % des dépenses de défense cumulées des Alliés en 2025. Les pourcentages entre parenthèses sont les hausses annoncées par l'OTAN d'une année sur l'autre.</p>$$,
 array['b2022','b2023','b2024','b2025','b2026','cfrp25','nsip24','funding']);

select pg_temp.e('Poids et chiffres','poi-forces',96,'Forces et présence en chiffres',
$$<table>
<tr><th>Élément</th><th>Chiffre</th><th>Date / remarque</th></tr>
<tr><td>Population couverte par la garantie de défense</td><td>environ un milliard d'habitants</td><td>chiffre de l'OTAN</td></tr>
<tr><td>Troupes sous commandement direct de l'OTAN sur le flanc est</td><td>plus de 40 000, avec d'importants moyens aériens et navals</td><td>depuis mars 2022</td></tr>
<tr><td>Groupements tactiques multinationaux à l'Est</td><td>4 en 2017, 8 en 2022, 9 en 2026</td><td>le neuvième est en Finlande</td></tr>
<tr><td>KFOR (Kosovo)</td><td>environ 4 500 à 4 700 soldats de 31 pays</td><td>selon les pages consultées</td></tr>
<tr><td>IFOR / SFOR (Bosnie)</td><td>environ 60 000 / 32 000</td><td>1995-1996 / 1996-2004</td></tr>
<tr><td>FIAS (Afghanistan)</td><td>plus de 50 pays contributeurs</td><td>2003-2014 sous commandement de l'OTAN</td></tr>
<tr><td>Campagne aérienne au Kosovo</td><td>78 jours</td><td>mars-juin 1999</td></tr>
<tr><td>Avions à double capacité (nucléaire)</td><td>7 Alliés contributeurs</td><td>fiche de l'OTAN de 2022</td></tr>
<tr><td>Réduction du stock nucléaire en Europe depuis la guerre froide</td><td>plus de 90 %</td><td>chiffre de l'OTAN</td></tr>
<tr><td>Pays partenaires</td><td>35</td><td>dont 16 dans le Partenariat pour la paix</td></tr>
</table>$$,
 array['nato_home','efp','kosovo','bosnia','ops','nuc_share','nuclear']);

select pg_temp.e('Poids et chiffres','poi-manque',97,'Chiffres à compléter (non sourcés pour l''instant)',
$$<p>Pour respecter la règle « rien sans source », les données suivantes n'ont pas été ajoutées faute de source fiable lue :</p>
<ul>
<li>population totale et PIB cumulé de l'Alliance (hors les parts relatives de 2024 déjà citées) ;</li>
<li>effectifs militaires par pays (la source habituelle, le Military Balance de l'IISS, n'a pas été consultée) ;</li>
<li>le tableau complet des dépenses de défense des 32 pays pour 2025 (seuls des extraits sont repris) ;</li>
<li>la liste exacte des sept pays qui fournissent des avions à double capacité ;</li>
<li>les nations-cadres des groupements tactiques d'Estonie et de Bulgarie ;</li>
<li>le détail de l'aide militaire à l'Ukraine pays par pays.</li>
</ul>$$,
 array['nato_home']);

-- ===================== RELATIONS, TENSIONS ET CRITIQUES =====================
select pg_temp.s('rel-russie','Relations, tensions et critiques','Avec la Russie',10);
select pg_temp.s('rel-ukraine','Relations, tensions et critiques','Ukraine, Géorgie et la porte ouverte',20);
select pg_temp.s('rel-allies','Relations, tensions et critiques','Tensions entre Alliés',30);
select pg_temp.s('rel-debats','Relations, tensions et critiques','Interventions et doctrine : les débats',40);
select pg_temp.s('rel-autres','Relations, tensions et critiques','Autres relations',50);

select pg_temp.e('Relations, tensions et critiques','rel-russie',100,'La Russie : de la coopération à la rupture',
$$<ul>
<li><strong>Après la guerre froide :</strong> la Russie rejoint le Conseil de coopération nord-atlantique (1991), puis le Conseil de partenariat euro-atlantique (1997). Le <strong>Conseil OTAN-Russie</strong> est créé le 28 mai 2002, à Rome, comme enceinte de consultation et de coopération entre égaux. Les domaines de coopération incluent le contre-terrorisme, le sauvetage de sous-marins et la planification civile d'urgence.</li>
<li><strong>Avril 2014 :</strong> après l'annexion de la Crimée, que l'OTAN juge illégale et illégitime, les ministres suspendent toute coopération pratique civile et militaire (décision du 1er avril), tout en gardant des canaux de communication. Le Conseil OTAN-Russie se réunit onze fois entre 2016 et 2022.</li>
<li><strong>Octobre 2021 :</strong> la Russie suspend les activités de sa mission auprès de l'OTAN ; le bureau d'information de l'OTAN à Moscou est fermé.</li>
<li><strong>12 janvier 2022 :</strong> dernière réunion du Conseil OTAN-Russie. L'OTAN dit avoir rejeté une proposition russe d'accord de sécurité jugée contraire à sa politique de la porte ouverte.</li>
<li><strong>Depuis février 2022 :</strong> le dialogue politique est entièrement suspendu ; au sommet de Madrid (juin 2022), les Alliés déclarent ne plus pouvoir considérer la Russie comme un partenaire. Les Alliés disent rester prêts à garder des canaux de communication pour limiter les risques. Selon l'OTAN, les relations sont au plus bas depuis la guerre froide.</li>
<li><strong>Le diagnostic de l'OTAN :</strong> le Concept stratégique 2022 désigne la Russie comme la menace la plus importante et la plus directe. L'OTAN affirme aussi ne pas être une menace pour la Russie. L'OTAN accuse la Biélorussie, l'Iran et la Corée du Nord de faciliter la guerre.</li>
<li><strong>Sanctions :</strong> les Alliés ont imposé de lourdes sanctions à la Russie depuis 2022.</li>
</ul>
<p>Cette entrée résume les positions de l'OTAN, telles que publiées par elle. Les arguments des critiques sont présentés dans l'entrée suivante.</p>$$,
 array['russia','nrc','nrc_fr','suspend14','strat','stmt2022','straight']);

select pg_temp.e('Relations, tensions et critiques','rel-russie',101,'L''élargissement : menace ou garantie de stabilité ? Un débat',
$$<h3>La position de l'OTAN</h3>
<ul>
<li>L'élargissement ne menace aucun pays ; il vise la stabilité et la coopération. La décision d'inviter un pays appartient aux seuls Alliés et à l'aspirant : aucun État tiers n'a de droit de veto.</li>
<li>Avant 2014, il n'y avait pas de présence permanente de troupes multinationales de l'OTAN dans la partie orientale de l'Alliance ; les quatre groupements de 2016-2017 répondent aux actions russes en Ukraine.</li>
</ul>
<h3>La position de dirigeants russes, telle que rapportée</h3>
<ul>
<li>Moscou a présenté l'OTAN comme une menace. Selon un commentaire américain, avant l'invasion de 2022, M. Poutine a demandé que l'Alliance retire ses troupes aux positions de 1997. Selon l'OTAN, la Russie a aussi proposé un accord de sécurité jugé incompatible avec la porte ouverte. (Les textes russes eux-mêmes n'ont pas été consultés.)</li>
</ul>
<h3>Les critiques de l'élargissement (école « réaliste »)</h3>
<ul>
<li>Le politologue John Mearsheimer soutient de longue date que l'élargissement de l'OTAN vers l'est a été la cause principale de la dégradation des relations avec la Russie et, finalement, de la guerre en Ukraine (The Hill). Selon un historien qui commente ses travaux, il estime que les dirigeants russes ont perçu cet élargissement comme intrinsèquement menaçant (History News Network).</li>
</ul>
<h3>Les réponses à ces critiques</h3>
<ul>
<li>Un politologue américain (Motyl) reproche à cette thèse de s'appuyer sur des faits inexacts et de relever de la perception plus que de la logique réaliste.</li>
<li>Une étude universitaire conclut que l'élargissement a été une source majeure d'irritation pour Moscou mais qu'il n'y a guère de preuve qu'il ait réellement menacé la Russie ; elle y voit surtout le reflet du déclin de son statut.</li>
<li>Un autre commentateur estime que la menace perçue était politique (l'exemple d'États voisins démocratiques et prospères) plutôt que militaire ; un troisième observe que l'entrée de la Finlande et de la Suède n'a pas provoqué de démonstrations de force russes.</li>
</ul>
<p>Le débat reste ouvert entre spécialistes ; ce dossier n'y prend pas position.</p>$$,
 array['straight','nrc_fr','bulwark','hnn','hill','motyl','usp','enlarge']);

select pg_temp.e('Relations, tensions et critiques','rel-ukraine',102,'Ukraine et Géorgie : la porte ouverte, sans calendrier',
$$<ul>
<li><strong>Avril 2008, Bucarest :</strong> les Alliés conviennent que l'Ukraine et la Géorgie deviendront membres, sans leur ouvrir immédiatement le Plan d'action pour l'adhésion.</li>
<li><strong>Mai 2002 :</strong> le président ukrainien Leonid Koutchma annonce l'objectif d'une adhésion à terme ; <strong>avril 2005 :</strong> dialogue intensifié avec l'Ukraine ; <strong>septembre 2006 :</strong> dialogue intensifié proposé à la Géorgie.</li>
<li><strong>Position de l'OTAN :</strong> la décision d'adhésion revient aux Alliés et aux pays aspirants, « et à personne d'autre » ; l'OTAN réaffirme sa « porte ouverte » (février 2022, juin 2022).</li>
<li><strong>Priorité du secrétaire général Rutte (octobre 2024) :</strong> soutenir davantage l'Ukraine et la rapprocher de l'OTAN.</li>
<li><strong>Après 2022 :</strong> l'OTAN soutient un règlement juste et durable par la négociation, dit refuser de reconnaître les annexions, et rappelle que les cessez-le-feu de 2014 et 2015 ont été violés.</li>
</ul>
<p>Aucune date d'adhésion n'est fixée. Les positions opposées sur l'élargissement sont présentées dans l'entrée précédente.</p>$$,
 array['bucharest','enlarge','def2022','rutte_office','ukraine']);

select pg_temp.e('Relations, tensions et critiques','rel-allies',103,'Le partage du fardeau : la pression américaine',
$$<ul>
<li><strong>Le problème :</strong> les États-Unis supportent environ 60 % des dépenses de défense de l'Alliance en 2025, et en 2014 seuls trois Alliés atteignaient le repère de 2 % du PIB.</li>
<li><strong>La pression :</strong> le président américain Donald Trump a, à plusieurs reprises, exigé des Alliés qu'ils dépensent nettement plus ; son administration soutient que les Européens doivent à terme assumer la responsabilité principale de la défense conventionnelle du continent (Reuters).</li>
<li><strong>La réponse :</strong> le sommet de La Haye (juin 2025) porte le seuil à 5 % du PIB en 2035, conformément à cette demande selon Reuters. L'OTAN présente cette décision comme garantissant un « partage plus équitable » du fardeau.</li>
<li><strong>Un point de vue européen :</strong> le Premier ministre espagnol Pedro Sánchez dit partager l'idée que l'Europe doit se charger davantage de sa propre défense, mais juge le seuil de 5 % incompatible avec sa vision.</li>
</ul>$$,
 array['reuters26','fmt','ap_spain','hague_concl','sgar25']);

select pg_temp.e('Relations, tensions et critiques','rel-allies',104,'L''Espagne et le seuil de 5 % (juin 2025)',
$$<ul>
<li><strong>Avant le sommet :</strong> quelques jours avant le sommet de La Haye (24-25 juin 2025), M. Sánchez écrit au secrétaire général que l'Espagne ne peut pas s'engager sur 5 %, objectif qu'il juge « déraisonnable ». Il affirme que l'Espagne remplira ses engagements en dépensant 2,1 % du PIB.</li>
<li><strong>L'accord annoncé :</strong> le 22 juin, M. Sánchez annonce, après un échange de lettres avec M. Rutte, que l'Espagne est exclue de l'objectif de 5 % et que la formule n'inclura plus « tous les Alliés » (AP). Fortune et Bloomberg parlent d'une exemption obtenue après des jours de tractations.</li>
<li><strong>Un texte final ambigu :</strong> dans les paragraphes 2 et 3 de la déclaration de La Haye publiée par l'OTAN, les Alliés s'engagent à investir 5 % ; aucune exception n'y figure dans l'extrait consulté. La portée réelle de l'exemption espagnole reste donc contestée.</li>
<li><strong>Réaction américaine :</strong> M. Trump qualifie l'Espagne de pays qui paie trop peu (« low payer ») et critique ses dépenses.</li>
<li><strong>Les chiffres :</strong> l'Espagne consacrait environ 1,28 % de son PIB à la défense en 2024 et 2,00 % en 2025 selon les estimations de l'OTAN.</li>
</ul>$$,
 array['ap_spain','defpost','fortune_spain','fmt','hague_decl','defexp24','defexp25']);

select pg_temp.e('Relations, tensions et critiques','rel-allies',105,'La Suède : vingt mois d''attente (Turquie et Hongrie)',
$$<ul>
<li><strong>Le blocage :</strong> la Finlande est admise en avril 2023 ; la Turquie et la Hongrie, elles, retardent la ratification pour la Suède, dont la candidature a été déposée en mai 2022.</li>
<li><strong>Les raisons turques :</strong> Ankara reprochait à Stockholm de ne pas assez lutter contre des militants kurdes, notamment en refusant des extraditions. Le président Erdoğan a aussi lié la ratification à la vente d'avions F-16 par les États-Unis, puis, à un moment, à l'adhésion de la Turquie à l'Union européenne. Selon Reuters, ce retard a frustré des alliés et permis à la Turquie d'obtenir des concessions.</li>
<li><strong>La Hongrie :</strong> elle n'a jamais précisé publiquement ses conditions. Le gouvernement hongrois a invoqué les critiques de responsables suédois sur l'état de la démocratie hongroise ; M. Orbán a invité le Premier ministre suédois à venir « négocier ». Les responsables suédois répondent qu'il n'y avait rien à négocier.</li>
<li><strong>Le dénouement :</strong> le parlement turc approuve le 23 janvier 2024, la Hongrie est la dernière à ratifier, la Suède devient membre le 7 mars 2024.</li>
<li><strong>Leçon :</strong> la règle du consensus donne à chaque Allié un pouvoir de blocage sur l'élargissement.</li>
</ul>$$,
 array['sw_inq','sw_fe','sw_neos','sw_bday','sw_ap','sw_bbg','babel']);

select pg_temp.e('Relations, tensions et critiques','rel-allies',106,'Grèce et Turquie : deux Alliés en différend',
$$<ul>
<li><strong>Chypre, 1974 :</strong> après un coup d'État mené par des officiers grecs de la Garde nationale chypriote contre le gouvernement de Mgr Makarios, la Turquie intervient militairement dans l'île (juillet 1974).</li>
<li><strong>Conséquence pour l'OTAN :</strong> la Grèce se retire de la structure militaire intégrée de 1974 à 1980 ; la Turquie demande alors une plus grande part des responsabilités de l'OTAN en mer Égée.</li>
<li><strong>La mer Égée :</strong> les deux pays se disputent l'espace aérien, les eaux territoriales (la Grèce a 6 milles d'eaux territoriales mais 10 d'espace aérien), le plateau continental et la militarisation d'îles. Selon une thèse militaire américaine, ce différend a aussi apporté confusion, retards et blocages dans la planification de défense de l'OTAN.</li>
<li><strong>Une médiation américaine :</strong> selon un centre de recherche, ce n'est pas l'OTAN en tant que telle mais les États-Unis qui ont empêché la guerre en 1974.</li>
<li><strong>Plus récemment :</strong> l'AFP décrit de vives querelles entre les deux Alliés sur les réserves de gaz naturel en Méditerranée orientale.</li>
</ul>$$,
 array['dtic','csm1983','carnegie','courthouse']);

select pg_temp.e('Relations, tensions et critiques','rel-allies',107,'La France : le départ de 1966, le retour de 2009, la « mort cérébrale » de 2019',
$$<ul>
<li><strong>1966 :</strong> le général de Gaulle annonce que la France quittera le commandement militaire intégré (annonce publique le 21 février, décision du gouvernement le 10 mars). Les quartiers généraux alliés et les forces étrangères doivent quitter le sol français avant le 1er avril 1967 ; les armes étrangères, dont nucléaires, y sont interdites. La France reste un Allié.</li>
<li><strong>Un désaccord toléré :</strong> selon l'OTAN, l'épisode montre que l'Alliance, à la différence du pacte de Varsovie, peut tolérer des désaccords entre membres.</li>
<li><strong>Retour par étapes :</strong> accord Valentin-Ferber (1974), approbation du Concept stratégique de 1991, réunions des ministres de la Défense à partir de 1994, officiers français dans les commandements à partir de 2003, annonce de la pleine participation en avril 2009 (sommet de Strasbourg/Kehl). Depuis 2009, un officier français commande l'ACT. La France reste en dehors du Groupe des plans nucléaires.</li>
<li><strong>Novembre 2019 :</strong> dans un entretien à The Economist, le président Emmanuel Macron juge que l'OTAN connaît la « mort cérébrale », en citant l'absence de coordination stratégique entre les États-Unis et leurs alliés (retrait américain du nord de la Syrie sans consultation) et l'action de la Turquie en Syrie. Il s'interroge aussi sur la portée de l'article 5.</li>
<li><strong>Réactions :</strong> la chancelière Angela Merkel est vivement critique ; le président Trump qualifie les propos de très désagréables ; le secrétaire général Jens Stoltenberg s'entretient avec M. Macron à Paris avant le sommet de Londres de décembre 2019.</li>
</ul>$$,
 array['france_nato','shape_fr','short_hist','members_os','macron_axios','macron_globe','macron_afp','haglund']);

select pg_temp.e('Relations, tensions et critiques','rel-debats',108,'Kosovo 1999 : une intervention légale ?',
$$<ul>
<li><strong>Les faits :</strong> l'OTAN mène une campagne aérienne de 78 jours (mars-juin 1999) contre la République fédérale de Yougoslavie, sans autorisation explicite du Conseil de sécurité de l'ONU. La résolution 1244 (10 juin 1999) vient après les frappes, pour encadrer l'après-guerre et la présence de la KFOR.</li>
<li><strong>Le débat juridique :</strong> pour de nombreux juristes, la Charte de l'ONU n'admet l'usage de la force que par légitime défense ou avec l'accord du Conseil de sécurité. Un rapport du Congrès américain (CRS, 1999) note que si l'on tient la souveraineté et la non-intervention pour des principes absolus, l'action de l'OTAN les viole clairement ; il ajoute que le débat sur l'intervention humanitaire se poursuit. Le secrétaire général de l'ONU Kofi Annan estimait que seul le Conseil de sécurité peut décider qu'une situation interne justifie une intervention armée.</li>
<li><strong>La formule de la Commission indépendante sur le Kosovo (2000) :</strong> l'intervention était « illégale mais légitime » (faute d'autorisation préalable de l'ONU, mais pour prévenir une catastrophe humanitaire).</li>
<li><strong>Les défenseurs :</strong> le Royaume-Uni a soutenu qu'une « nécessité humanitaire écrasante » pouvait justifier le recours à la force sans aval du Conseil.</li>
<li><strong>Les opposants :</strong> la Russie et la Chine, membres permanents du Conseil de sécurité, ont critiqué l'opération.</li>
</ul>$$,
 array['kosovo','crs','asil','karnavas','studia']);

select pg_temp.e('Relations, tensions et critiques','rel-debats',109,'Libye 2011 : protéger les civils ou changer le régime ?',
$$<ul>
<li><strong>Le mandat :</strong> la résolution 1973 du Conseil de sécurité est adoptée par dix voix pour et cinq abstentions (Brésil, Chine, Allemagne, Inde, Russie). Elle autorise, selon une source consultée, « tous les moyens nécessaires » pour protéger les civils.</li>
<li><strong>La critique :</strong> de nombreux analystes et gouvernements reprochent à l'OTAN et à ses partenaires d'être allés au-delà du mandat en soutenant en pratique la chute du régime Kadhafi (« dérive de la mission »). Selon l'étude de la Royal Air Force citée ci-dessous, ces critiques ont aussi alimenté, dans le débat sur la « responsabilité de protéger », une réticence marquée à de nouvelles interventions.</li>
<li><strong>La défense :</strong> une étude de la Royal Air Force soutient que la campagne aérienne a respecté la lettre et l'esprit du mandat, et que le changement de régime n'était pas un objectif stratégique de l'OTAN. D'autres soulignent que le Conseil national de transition libyen refusait une feuille de route de l'Union africaine et voulait le départ de Kadhafi.</li>
<li><strong>Les suites :</strong> les critiques lient l'intervention à l'instabilité durable de la Libye ; les défenseurs rappellent l'objectif humanitaire initial.</li>
</ul>$$,
 array['un_rel','mspace','iemed','raf']);

select pg_temp.e('Relations, tensions et critiques','rel-debats',110,'Le partage nucléaire et le traité de non-prolifération',
$$<ul>
<li><strong>La position de l'OTAN :</strong> ses arrangements de partage nucléaire sont conformes au traité de non-prolifération (TNP, en vigueur depuis 1970) ; les États-Unis conservent la garde des armes, et les articles I et II du TNP interdisent le <em>transfert</em> d'armes nucléaires. Ces arrangements existaient avant le TNP, étaient connus des négociateurs, et la Russie, selon l'OTAN, ne les contestait pas avant 2015.</li>
<li><strong>Le désarmement :</strong> le secrétaire général a déclaré en 2021 que le traité sur l'interdiction des armes nucléaires ne remplit pas les conditions d'un désarmement équilibré et vérifiable, et que renoncer à la dissuasion sans garantie que d'autres fassent de même est une option dangereuse.</li>
<li><strong>Les contestataires :</strong> l'OTAN réfute dans une rubrique « mythes et faits » l'idée que le partage nucléaire contredirait le TNP. Cette rubrique ne cite pas les critiques et leurs arguments : leurs sources restent à ajouter.</li>
</ul>$$,
 array['armscontrol','nuc_share','stolt2021','nuclear']);

select pg_temp.e('Relations, tensions et critiques','rel-autres',111,'Chine, Union européenne, ONU : les autres relations',
$$<ul>
<li><strong>Chine :</strong> le Concept stratégique 2022 est le premier à mentionner la Chine ; ses ambitions et ses politiques coercitives sont dites défier les intérêts, la sécurité et les valeurs des Alliés. La Chine n'est pas classée « menace » (analyse du Collège de défense de l'OTAN). En mars 2022, les dirigeants alliés ont demandé à la Chine de ne pas soutenir la guerre de la Russie ni l'aider à contourner les sanctions.</li>
<li><strong>Union européenne :</strong> coopération sur la dissuasion, la défense, les menaces hybrides ; accords « Berlin Plus » permettant à l'UE d'utiliser des moyens de l'OTAN, par exemple pour EUFOR Althea en Bosnie. Le 28 octobre 2026, le secrétaire général a reçu le commissaire européen à la Défense et à l'Espace, Andrius Kubilius, à Bruxelles.</li>
<li><strong>ONU :</strong> les résolutions du Conseil de sécurité ont fourni le mandat des opérations de l'OTAN dans les Balkans occidentaux, en Afghanistan et en Libye, ainsi que de sa première mission de formation en Irak. Le Concept stratégique de 2022 prévoit de renforcer la coopération avec l'ONU.</li>
<li><strong>Dans l'atlas :</strong> voir aussi les groupes « OTAN — Partenariat pour la paix », « OTAN — Partenaires dans le monde », « UE — États membres (27) », « UE — Pays candidats », « Membres permanents du Conseil de sécurité de l'ONU (P5) » et « Puissances nucléaires ».</li>
</ul>$$,
 array['ndc','strat','stmt2022','bih','nato_home','un_rel']);
