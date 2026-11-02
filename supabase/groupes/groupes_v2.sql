-- ============================================================
-- groupes_v2 — dossier d'EXEMPLE « OTAN » (1/3) : Présentation, Origines, Membres
-- Prérequis : groupes_v1 exécuté (catégories de dossier de groupe).
-- Demande de Martin (2026-11-02) : un dossier d'OTAN ultra rempli et sourcé, comme modèle.
-- Ajoute des sous-catégories et des entrées de texte au groupe OTAN
-- (id ffdd3a51-8c60-53f0-baa3-bbb944672416). Idempotente (ids fixes, ON CONFLICT DO NOTHING).
-- Ne supprime rien. L'entrée « OTAN » déjà présente est seulement rangée (catégorie Membres).
-- Chaque entrée porte ses sources (champ sources) ; le détail est aussi dans docs/sources/groupes.md.
-- Retour arrière : delete from public.dossier_entries where owner_id='ffdd3a51-8c60-53f0-baa3-bbb944672416'
--   and tags @> array['Exemple OTAN']; (les sous-catégories partent avec : delete idem dans dossier_sections).
-- ============================================================

create temp table if not exists src(k text primary key, label text, url text);
insert into src(k,label,url) values
 ('nato_home','OTAN — page d''accueil (nato.int)','https://www.nato.int/en'),
 ('what_is','What is NATO? — nato.int','https://www.nato.int/en/what-is-nato'),
 ('members','NATO member countries — nato.int','https://www.nato.int/en/about-us/organization/nato-member-countries'),
 ('members_old','NATO member countries (dates d''adhésion) — nato.int','https://www.nato.int/cps/en/natohq/topics_52044.htm'),
 ('treaty','Le traité de l''Atlantique nord, 4 avril 1949 — nato.int','https://www.nato.int/en/about-us/official-texts-and-resources/official-texts/1949/04/04/the-north-atlantic-treaty'),
 ('founding','Founding treaty — nato.int','https://www.nato.int/en/about-us/organization/founding-treaty'),
 ('short_hist','A short history of NATO — nato.int','https://www.nato.int/en/about-us/nato-history/a-short-history-of-nato'),
 ('art5','Collective defence and Article 5 — nato.int','https://nato.int/en/what-we-do/introduction-to-nato/collective-defence-and-article-5'),
 ('hq','NATO Headquarters — nato.int','https://www.nato.int/cps/en/natohq/topics_49284.htm?selectedLocale=uk'),
 ('rutte','Mark Rutte — nato.int','https://www.nato.int/en/about-us/organization/who-we-are/nato-secretaries-general/mark-rutte'),
 ('strat','NATO 2022 Strategic Concept — nato.int','https://www.nato.int/en/about-us/official-texts-and-resources/strategic-concepts/nato-2022-strategic-concept'),
 ('strat_pdf','Strategic Concept 2022, texte intégral (PDF)','https://www.act.nato.int/wp-content/uploads/2023/05/290622-strategic-concept.pdf'),
 ('nac','North Atlantic Council — nato.int','https://www.nato.int/en/about-us/organization/nato-structure/north-atlantic-council-nac'),
 ('mc','Military Committee — nato.int','https://www.nato.int/en/about-us/organization/nato-structure/nato-military-committee/military-committee'),
 ('shape_cmd','Military Command Structure — SHAPE','https://shape.nato.int/military_command_structure'),
 ('npg','Nuclear Planning Group — nato.int','https://www.nato.int/en/about-us/organization/nato-structure/nuclear-planning-group-npg'),
 ('funding','Funding NATO — nato.int','https://www.nato.int/en/what-we-do/introduction-to-nato/funding-nato'),
 ('ncs_pdf','The NATO Command Structure (fiche, ACT)','https://www.act.nato.int/wp-content/uploads/2023/05/1802-Factsheet-NATO-Command-Structure_en.pdf'),
 ('knowyour','Know Your NATO 1949-1959 — archives de l''OTAN','https://archives.nato.int/uploads/r/null/1/3/137350/0067_Know_your_NATO_1949-1959_ENG.pdf'),
 ('nato1956','The North Atlantic Treaty Organization, Paris 1956 — archives de l''OTAN','https://archives.nato.int/uploads/r/null/1/4/145629/0006_North_Atlantic_Treaty_Organization_1956_ENG.pdf'),
 ('milstru','The beginnings of NATO''s military structure — nato.int','https://www.nato.int/docu/nato-mil-stru/nato-mil-stru-e.pdf'),
 ('us_nato','The United States and NATO — nato.int','https://www.nato.int/en/about-us/nato-history/history-by-theme/my-country-and-nato/united-states-and-nato'),
 ('uk_nato','The United Kingdom and NATO — nato.int','https://nato.int/cps/en/natohq/declassified_162351.htm?selectedLocale=en'),
 ('de_nato','Germany and NATO — nato.int','https://www.nato.int/en/about-us/nato-history/history-by-theme/my-country-and-nato/germany-and-nato'),
 ('de_2005','Germany''s accession to NATO: 50 years on — nato.int','https://www.nato.int/en/news-and-events/events/transcripts/2005/04/01/germanys-accession-to-nato-50-years-on'),
 ('shape_fr','SHAPE in France — shape.nato.int','https://shape.nato.int/about-us/what-is-shape/shape-in-france'),
 ('strat_all','Strategic Concepts — nato.int','https://www.nato.int/en/about-us/official-texts-and-resources/strategic-concepts'),
 ('enlarge','Enlargement and Article 10 — nato.int','https://www.nato.int/en/what-we-do/partnerships-and-cooperation/enlargement-and-article-10'),
 ('bucharest','Bucharest Summit Declaration — nato.int','https://www.nato.int/cps/en/natolive/official_texts_8443.htm'),
 ('prot_grtr','Protocole d''adhésion de la Grèce et de la Turquie (1951) — nato.int','https://www.nato.int/en/about-us/official-texts-and-resources/official-texts/1951/10/22/protocol-to-the-north-atlantic-treaty-on-the-accession-of-greece-and-turkey'),
 ('stolt2019','Keynote speech du secrétaire général, 18 mars 2019 — nato.int','https://www.nato.int/en/news-and-events/events/transcripts/2019/03/18/keynote-speech'),
 ('partners','NATO''s partnerships — nato.int','https://www.nato.int/en/what-we-do/partnerships-and-cooperation/natos-partnerships'),
 ('bih','Relations with Bosnia and Herzegovina — nato.int','https://www.nato.int/en/what-we-do/partnerships-and-cooperation/relations-with-bosnia-and-herzegovina?selectedLocale=ic'),
 ('sw_inq','Reuters : la Turquie approuve l''adhésion de la Suède après 20 mois de retard','https://newsinfo.inquirer.net/1893482/turkey-approves-swedens-nato-membership-bid-after-20-month-delay'),
 ('sw_bl','Reuters : Turkey approves Sweden''s Nato membership bid (BusinessLive)','https://www.businesslive.co.za/amp/bd/world/europe/2024-01-23-turkey-approves-swedens-nato-membership-bid/'),
 ('dtic','Thèse (DTIC) : le différend gréco-turc en mer Égée et l''OTAN','https://apps.dtic.mil/sti/tr/pdf/ADA389730.pdf'),
 ('csm1983','Christian Science Monitor, 6 mai 1983 : Greece and Turkey are talking','https://csmonitor.com/1983/0506/050664.html'),
 ('france_nato','France and NATO — nato.int','https://www.nato.int/cps/en/natohq/declassified_160672.htm'),
 ('mc_iceland','Military Committee — nato.int (Islande : représentant civil)','https://www.nato.int/en/about-us/organization/nato-structure/nato-military-committee/military-committee'),
 ('babel','Reuters : la Turquie retarde de nouveau la ratification pour la Suède (Babel)','https://babel.ua/en/news/100947-reuters-turkey-once-again-postponed-the-ratification-of-sweden-s-accession-to-nato'),
 ('wikiwand','Member states of NATO — Wikiwand (tertiaire)','https://wikiwand.com/en/articles/Member_states_of_NATO')
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

-- ===================== PRÉSENTATION =====================
select pg_temp.e('Présentation', null, 10, 'L''OTAN en bref',
$$<p><strong>L'Organisation du traité de l'Atlantique nord (OTAN, NATO en anglais)</strong> est une alliance politique et militaire de 32 pays d'Europe et d'Amérique du Nord. Sa mission affichée est de défendre ses membres et leur un milliard d'habitants. Les États membres, appelés « Alliés », sont souverains et décident ensemble par consensus.</p>
<table>
<tr><th>Fiche d'identité</th><th></th></tr>
<tr><td>Nom et sigle</td><td>Organisation du traité de l'Atlantique nord — OTAN (NATO)</td></tr>
<tr><td>Acte fondateur</td><td>Traité de l'Atlantique nord (« traité de Washington »), signé le 4 avril 1949 à Washington par 12 pays</td></tr>
<tr><td>Membres</td><td>32 ; le dernier arrivé est la Suède (7 mars 2024)</td></tr>
<tr><td>Élargissements</td><td>10 vagues : 1952, 1955, 1982, 1999, 2004, 2009, 2017, 2020, 2023, 2024</td></tr>
<tr><td>Siège</td><td>Bruxelles (Belgique), boulevard Léopold III</td></tr>
<tr><td>Secrétaire général</td><td>Mark Rutte (14e), en fonction depuis le 1er octobre 2024 ; ancien Premier ministre des Pays-Bas</td></tr>
<tr><td>Organe politique principal</td><td>Conseil de l'Atlantique nord (NAC)</td></tr>
<tr><td>Texte stratégique en vigueur</td><td>Concept stratégique 2022, approuvé à Madrid le 29 juin 2022</td></tr>
<tr><td>Trois tâches fondamentales</td><td>Dissuasion et défense ; prévention et gestion des crises ; sécurité coopérative</td></tr>
<tr><td>Nature déclarée</td><td>Alliance défensive</td></tr>
</table>
<p>Ce dossier suit sept grandes catégories communes à tous les groupes de l'atlas : présentation, origines, membres, fonctionnement, actions, chiffres, relations et critiques.</p>$$,
 array['nato_home','what_is','members','founding','hq','rutte','strat']);

select pg_temp.e('Présentation', null, 11, 'Ce que l''OTAN est, et ce qu''elle n''est pas',
$$<ul>
<li><strong>Une alliance d'États souverains, pas un super-État.</strong> Au Conseil de l'Atlantique nord, il n'y a ni vote ni décision à la majorité : une décision n'existe que si tous les Alliés l'acceptent.</li>
<li><strong>Un forum politique autant qu'une alliance militaire.</strong> Le Concept stratégique 2022 la décrit comme le cadre transatlantique pour se consulter, se coordonner et agir sur la sécurité de ses membres.</li>
<li><strong>Une armée surtout empruntée aux États.</strong> L'essentiel des forces et des capacités reste national (contributions dites « indirectes »). Les budgets communs de l'OTAN, soit environ 4,6 milliards d'euros en 2025, ne représentent que 0,3 % des dépenses de défense cumulées des Alliés ; ils financent surtout le siège, la structure de commandement et des infrastructures.</li>
<li><strong>Une garantie réservée aux membres.</strong> L'article 5 (défense collective) ne couvre pas les pays partenaires, qui n'ont pas non plus le même pouvoir de décision.</li>
<li><strong>Une zone de garantie limitée.</strong> L'article 6 du traité la définit : territoires en Europe et en Amérique du Nord, territoire de la Turquie, îles de l'Atlantique nord au nord du tropique du Cancer, ainsi que les forces, navires et avions dans ces zones.</li>
<li><strong>Trois membres dotés de l'arme nucléaire :</strong> les États-Unis, la France et le Royaume-Uni.</li>
</ul>$$,
 array['nac','funding','ncs_pdf','what_is','treaty','strat']);

select pg_temp.e('Présentation', null, 12, 'Glossaire : les sigles de l''OTAN',
$$<table>
<tr><th>Sigle</th><th>Signification</th></tr>
<tr><td>NAC</td><td>Conseil de l'Atlantique nord : principal organe politique de décision, seul organe créé par le traité (art. 9)</td></tr>
<tr><td>NPG</td><td>Groupe des plans nucléaires : organe suprême sur les questions nucléaires (créé en 1966)</td></tr>
<tr><td>MC</td><td>Comité militaire : plus haute autorité militaire, formé des représentants des chefs d'état-major</td></tr>
<tr><td>SACEUR / SACT</td><td>Commandant suprême des forces alliées en Europe / commandant suprême pour la transformation</td></tr>
<tr><td>ACO / ACT</td><td>Commandement allié des opérations / commandement allié pour la transformation : les deux commandements stratégiques</td></tr>
<tr><td>SHAPE</td><td>Grand quartier général des puissances alliées en Europe, à Mons (Belgique)</td></tr>
<tr><td>NSIP</td><td>Programme OTAN d'investissement au service de la sécurité (infrastructures et systèmes de commandement financés en commun)</td></tr>
<tr><td>MAP</td><td>Plan d'action pour l'adhésion, étape préparatoire pour un pays candidat (lancé en 1999)</td></tr>
<tr><td>PfP</td><td>Partenariat pour la paix, programme de coopération avec des pays partenaires de l'espace euro-atlantique</td></tr>
<tr><td>eFP / FLF</td><td>Présence avancée renforcée / forces terrestres avancées : groupements tactiques multinationaux déployés à l'est de l'Alliance</td></tr>
<tr><td>DCA</td><td>Avions à double capacité (conventionnelle et nucléaire)</td></tr>
<tr><td>KFOR</td><td>Force de l'OTAN au Kosovo, déployée depuis juin 1999</td></tr>
</table>$$,
 array['nac','npg','mc','shape_cmd','funding','enlarge','strat_all']);

-- ===================== ORIGINES ET RAISON D'ÊTRE =====================
select pg_temp.s('orig-contexte','Origines et raison d''être','Le contexte de 1947-1949',10);
select pg_temp.s('orig-traite','Origines et raison d''être','Le traité de Washington',20);
select pg_temp.s('orig-orga','Origines et raison d''être','De l''alliance à l''organisation (1949-1955)',30);
select pg_temp.s('orig-reperes','Origines et raison d''être','Repères chronologiques 1947-2026',40);

select pg_temp.e('Origines et raison d''être','orig-contexte',20,'L''Europe d''après-guerre et la crainte soviétique',
$$<p>Selon l'OTAN, les rivalités entre l'Union soviétique et les puissances occidentales, présentes depuis 1917, resurgissent à la fin de la Seconde Guerre mondiale : intérêts et idéologies opposés, querelles sur les traités de paix et les réparations. Les Occidentaux démobilisent alors leurs armées.</p>
<h3>Les événements qui font basculer l'opinion (1948)</h3>
<ul>
<li><strong>Le coup de Prague :</strong> en 1948, le Parti communiste tchécoslovaque, avec un soutien discret de l'URSS, renverse le gouvernement élu.</li>
<li><strong>Le blocus de Berlin-Ouest :</strong> les Soviétiques bloquent les accès à la partie occidentale de la ville ; un pont aérien allié dure du 24 juin 1948 au 12 mai 1949.</li>
<li><strong>Des pressions directes</strong> sur la Norvège, la Grèce et la Turquie.</li>
</ul>
<h3>Premières réponses européennes</h3>
<ul>
<li>Mars 1947 : traité de Dunkerque entre le Royaume-Uni et la France, alliance de 50 ans.</li>
<li>Janvier 1948 : le ministre britannique des Affaires étrangères Ernest Bevin plaide pour un traité d'alliance et d'assistance mutuelle.</li>
<li>17 mars 1948 : traité de Bruxelles (Belgique, France, Luxembourg, Pays-Bas, Royaume-Uni), à l'origine de l'Union occidentale.</li>
</ul>$$,
 array['founding','short_hist','uk_nato','knowyour','milstru']);

select pg_temp.e('Origines et raison d''être','orig-contexte',21,'Pourquoi une alliance transatlantique',
$$<p>L'OTAN explique qu'on a conclu que seul un accord de sécurité vraiment transatlantique pouvait dissuader l'agression soviétique, tout en empêchant le retour d'un militarisme européen et en préparant l'intégration politique de l'Europe.</p>
<ul>
<li><strong>Côté américain :</strong> en juin 1948, le Sénat vote la résolution Vandenberg, qui permet aux États-Unis de participer en temps de paix à un système de défense mutuelle. Dès 1948, des discussions secrètes réunissent au Pentagone des responsables britanniques, canadiens et américains ; elles s'élargiront ensuite à d'autres futurs Alliés.</li>
<li><strong>L'ONU jugée insuffisante :</strong> une publication de l'OTAN de 1959 explique que le Conseil de sécurité avait été paralysé par les vetos soviétiques, et que le coup de Prague et le blocus de Berlin avaient montré qu'on ne pouvait compter sur lui seul pour se protéger. (Point de vue de l'OTAN elle-même.)</li>
<li><strong>Le traité s'appuie sur la Charte de l'ONU :</strong> il la cite à cinq reprises et fonde la défense collective sur son article 51 (droit de légitime défense, individuelle ou collective).</li>
</ul>$$,
 array['short_hist','us_nato','knowyour','art5']);

select pg_temp.e('Origines et raison d''être','orig-contexte',22,'La négociation du traité (décembre 1948 – mars 1949)',
$$<ul>
<li><strong>10 décembre 1948 :</strong> début des négociations formelles à Washington, au sein du comité des ambassadeurs. Le Luxembourg y envoie son propre représentant.</li>
<li><strong>8 mars 1949 :</strong> début des dernières sessions, auxquelles sont invités le Danemark, l'Islande, l'Italie, la Norvège et le Portugal, retenus surtout pour leur valeur stratégique.</li>
<li><strong>La Suède refuse</strong> tout lien avec l'OTAN, par attachement à sa neutralité ; <strong>l'Islande</strong> lie son adhésion à celle du Danemark et de la Norvège.</li>
</ul>
<h3>Deux désaccords notables</h3>
<ul>
<li><strong>L'étendue géographique :</strong> les États-Unis et le Royaume-Uni voient l'alliance comme régionale ; la France, comme d'autres, voudrait un rôle plus mondial. L'article 6 tranche en faveur d'une zone délimitée.</li>
<li><strong>La force de l'engagement :</strong> les Européens voulaient que les États-Unis s'engagent automatiquement à envoyer leurs forces ; les Américains ont refusé une promesse aussi précise. D'où la formule souple de l'article 5 : chaque Allié prend « les mesures qu'il juge nécessaires », sans type d'aide imposé.</li>
</ul>$$,
 array['founding','art5']);

select pg_temp.e('Origines et raison d''être','orig-contexte',23,'Signature et ratification (4 avril – 25 juillet 1949)',
$$<p>Le traité est signé le <strong>4 avril 1949</strong> à Washington (Departmental Auditorium) par les ministres des Affaires étrangères de 12 pays : Belgique (Paul-Henri Spaak), Canada (Lester B. Pearson), Danemark (Gustav Rasmussen), États-Unis (Dean Acheson), France (Robert Schuman), Islande (Bjarni Benediktsson), Italie (Carlo Sforza), Luxembourg (Joseph Bech), Pays-Bas (D. U. Stikker), Norvège (Halvard M. Lange), Portugal (José Caeiro da Matta) et Royaume-Uni (Ernest Bevin).</p>
<ul>
<li>Dans les cinq mois suivant la signature, les parlements des 12 pays ratifient le traité.</li>
<li>États-Unis : le Sénat ratifie le 21 juillet 1949 par 83 voix contre 13 ; le président Truman signe l'instrument d'adhésion le 25 juillet 1949.</li>
<li>Le texte est bref : 14 articles, un peu plus de 1 000 mots.</li>
</ul>$$,
 array['members','us_nato','art5','founding']);

select pg_temp.e('Origines et raison d''être','orig-traite',30,'Les articles essentiels du traité de Washington',
$$<table>
<tr><th>Article</th><th>Ce qu'il dit (en résumé)</th></tr>
<tr><td>Préambule</td><td>Attachement à la Charte de l'ONU, à la démocratie, à la liberté individuelle et à l'État de droit ; volonté d'unir les efforts pour la défense collective et la préservation de la paix.</td></tr>
<tr><td>Art. 2</td><td>Ouvre la porte à une coopération non militaire entre les Alliés.</td></tr>
<tr><td>Art. 3</td><td>Base de la coopération pour la préparation militaire ; invoqué aujourd'hui aussi pour la résilience civile des Alliés.</td></tr>
<tr><td>Art. 4</td><td>Les parties se consultent chaque fois que l'intégrité territoriale, l'indépendance politique ou la sécurité de l'une d'elles est menacée.</td></tr>
<tr><td>Art. 5</td><td>Une attaque armée contre un ou plusieurs Alliés en Europe ou en Amérique du Nord est considérée comme dirigée contre tous ; chacun aide, individuellement et de concert, par les actions qu'il juge nécessaires, y compris l'emploi de la force armée. Les mesures sont signalées au Conseil de sécurité de l'ONU.</td></tr>
<tr><td>Art. 6</td><td>Définit les territoires et zones concernés. Le texte d'origine mentionnait les départements français d'Algérie ; le protocole de 1951 sur la Grèce et la Turquie l'a modifié pour y inclure le territoire de la Turquie.</td></tr>
<tr><td>Art. 9</td><td>Crée le Conseil, où chaque partie est représentée ; il peut créer des organes subsidiaires. C'est le seul organe créé par le traité.</td></tr>
<tr><td>Art. 10</td><td>Adhésion : ouverte à tout autre État européen en mesure de favoriser les principes du traité et de contribuer à la sécurité de la zone nord-atlantique.</td></tr>
<tr><td>Art. 13</td><td>Après vingt ans d'existence du traité, une partie peut cesser d'en être membre.</td></tr>
<tr><td>Art. 14</td><td>Les textes anglais et français font également foi ; l'original est déposé aux archives du gouvernement américain.</td></tr>
</table>$$,
 array['treaty','nato1956','short_hist','art5','strat_pdf','nac','france_nato','prot_grtr']);

select pg_temp.e('Origines et raison d''être','orig-orga',40,'Des signatures à une organisation militaire (1949-1952)',
$$<p>Le traité de 1949 avait créé des Alliés, mais pas une structure militaire capable de coordonner leurs actions. Selon l'OTAN, ce sont l'explosion de la première bombe atomique soviétique (1949) et le début de la guerre de Corée (1950) qui accélèrent les choses.</p>
<ul>
<li><strong>17 septembre 1949 :</strong> première réunion du Conseil de l'Atlantique nord. <strong>6 octobre 1949 :</strong> première réunion du Comité militaire.</li>
<li><strong>26 septembre 1950 :</strong> le Conseil approuve la création d'une force militaire intégrée sous commandement centralisé.</li>
<li><strong>2 avril 1951 :</strong> création du SHAPE à Rocquencourt, près de Versailles ; le général américain Dwight D. Eisenhower en est le premier commandant suprême (SACEUR).</li>
<li><strong>1952 :</strong> création d'un secrétariat civil permanent à Paris ; Lord Ismay (Royaume-Uni) devient le premier secrétaire général. La conférence de Lisbonne (1952) instaure une session permanente du Conseil.</li>
<li><strong>18 février 1952 :</strong> adhésion de la Grèce et de la Turquie ; <strong>mai 1955 :</strong> adhésion de la République fédérale d'Allemagne. En réaction, l'URSS et ses alliés forment le <strong>pacte de Varsovie le 14 mai 1955</strong>.</li>
</ul>
<p>Plus tard, la France quitte le commandement militaire intégré (1966) : le SHAPE s'installe à Casteau, près de Mons (Belgique), en mars 1967, et le siège politique à Bruxelles en octobre 1967.</p>$$,
 array['short_hist','milstru','us_nato','members','shape_fr','de_nato']);

select pg_temp.e('Origines et raison d''être','orig-reperes',50,'Repères chronologiques 1947-2026',
$$<ul>
<li><strong>1947</strong> — traité de Dunkerque (France – Royaume-Uni).</li>
<li><strong>17 mars 1948</strong> — traité de Bruxelles (Union occidentale).</li>
<li><strong>4 avril 1949</strong> — signature du traité de l'Atlantique nord par 12 pays.</li>
<li><strong>1950-1951</strong> — force intégrée approuvée (26 septembre 1950) ; création du SHAPE (2 avril 1951).</li>
<li><strong>18 février 1952</strong> — Grèce et Turquie. <strong>Mai 1955</strong> — Allemagne ; 14 mai 1955 : pacte de Varsovie.</li>
<li><strong>1966-1967</strong> — la France quitte le commandement intégré ; création du Groupe des plans nucléaires (décembre 1966) ; rapport Harmel (décembre 1967), qui fixe la double ligne dissuasion-détente.</li>
<li><strong>30 mai 1982</strong> — adhésion de l'Espagne.</li>
<li><strong>Décembre 1991</strong> — création du Conseil de coopération nord-atlantique (rebaptisé Conseil de partenariat euro-atlantique en 1997).</li>
<li><strong>28 février 1994</strong> — premiers combats de l'histoire de l'OTAN (Bosnie). <strong>Décembre 1995</strong> — déploiement de l'IFOR après les accords de Dayton.</li>
<li><strong>12 mars 1999</strong> — Tchéquie, Hongrie, Pologne ; <strong>mars-juin 1999</strong> — campagne aérienne au Kosovo ; <strong>12 juin 1999</strong> — arrivée de la KFOR.</li>
<li><strong>12 septembre 2001</strong> — première invocation de l'article 5 (11 septembre).</li>
<li><strong>Août 2003</strong> — l'OTAN prend la tête de la FIAS en Afghanistan.</li>
<li><strong>29 mars 2004</strong> — sept nouveaux membres ; <strong>1er avril 2009</strong> — Albanie et Croatie ; <strong>avril 2009</strong> — la France annonce sa pleine participation aux structures militaires.</li>
<li><strong>27 mars 2011</strong> — l'OTAN prend en charge toute l'opération en Libye.</li>
<li><strong>Avril 2014</strong> — suspension de la coopération pratique avec la Russie ; <strong>septembre 2014</strong> — sommet du pays de Galles (engagement de 2 % du PIB).</li>
<li><strong>2016-2017</strong> — décision puis déploiement de quatre groupements tactiques à l'est ; <strong>5 juin 2017</strong> — Monténégro ; <strong>27 mars 2020</strong> — Macédoine du Nord.</li>
<li><strong>24 février 2022</strong> — invasion à grande échelle de l'Ukraine par la Russie ; <strong>29 juin 2022</strong> — Concept stratégique de Madrid.</li>
<li><strong>4 avril 2023</strong> — Finlande ; <strong>7 mars 2024</strong> — Suède ; <strong>1er octobre 2024</strong> — Mark Rutte devient secrétaire général.</li>
<li><strong>24-25 juin 2025</strong> — sommet de La Haye : engagement à investir 5 % du PIB dans la défense d'ici 2035.</li>
<li><strong>26 mars 2026</strong> — rapport annuel 2025 : pour la première fois, tous les Alliés atteignent 2 % du PIB.</li>
</ul>$$,
 array['short_hist','milstru','members_old','knowyour','enlarge','art5','shape_fr','strat_all','members','rutte']);

-- ===================== MEMBRES ET ADHÉSION =====================
select pg_temp.s('mem-pays','Membres et adhésion','Les 32 pays',10);
select pg_temp.s('mem-entree','Membres et adhésion','Entrer dans l''OTAN',20);
select pg_temp.s('mem-statuts','Membres et adhésion','Partenaires et aspirants',30);
select pg_temp.s('mem-sortie','Membres et adhésion','Rester à part, se retirer',40);

update public.dossier_entries
   set category_id=(select id from public.dossier_categories where space='group' and name='Membres et adhésion'),
       section_id=md5('otan-sec:mem-pays')::uuid,
       created_at='2026-11-02 21:00:30+01'
 where id='505b3bbd-62b5-53c2-8fa8-27eee8b74261' and category_id is null;

select pg_temp.e('Membres et adhésion','mem-pays',31,'Tableau des 32 membres et dates d''adhésion',
$$<table>
<tr><th>Pays</th><th>Adhésion</th><th>Vague</th></tr>
<tr><td>Belgique, Canada, Danemark, États-Unis, France, Islande, Italie, Luxembourg, Norvège, Pays-Bas, Portugal, Royaume-Uni</td><td>1949 (signature le 4 avril ; ratifications en moins de cinq mois)</td><td>Fondateurs</td></tr>
<tr><td>Grèce, Türkiye</td><td>18 février 1952</td><td>1952</td></tr>
<tr><td>Allemagne (RFA à l'époque)</td><td>6 mai 1955 selon l'OTAN (une publication officielle de 1956 indique le 5 mai)</td><td>1955</td></tr>
<tr><td>Espagne</td><td>30 mai 1982</td><td>1982</td></tr>
<tr><td>Tchéquie, Hongrie, Pologne</td><td>12 mars 1999</td><td>1999</td></tr>
<tr><td>Bulgarie, Estonie, Lettonie, Lituanie, Roumanie, Slovaquie, Slovénie</td><td>29 mars 2004</td><td>2004</td></tr>
<tr><td>Albanie, Croatie</td><td>1er avril 2009</td><td>2009</td></tr>
<tr><td>Monténégro</td><td>5 juin 2017</td><td>2017</td></tr>
<tr><td>Macédoine du Nord</td><td>27 mars 2020</td><td>2020</td></tr>
<tr><td>Finlande</td><td>4 avril 2023 (dépôt de l'instrument d'adhésion)</td><td>2023</td></tr>
<tr><td>Suède</td><td>7 mars 2024 (dépôt de l'instrument d'adhésion)</td><td>2024</td></tr>
</table>
<p>L'OTAN indique que 20 pays ont rejoint les 12 fondateurs en 10 vagues d'élargissement. Notez que la page de l'OTAN consultée donne la date « 6 mai 1955 » pour l'Allemagne, alors qu'un livret officiel de l'OTAN de 1956 parle du 5 mai 1955 : l'écart est signalé dans le registre des sources.</p>$$,
 array['members_old','members','nato1956','de_nato']);

select pg_temp.e('Membres et adhésion','mem-pays',32,'Les dix vagues d''élargissement',
$$<ul>
<li><strong>1952 — Grèce et Türkiye.</strong> Pour l'OTAN, leur adhésion limitait l'influence communiste en Grèce, pays qui sortait de la guerre civile, et soulageait la Turquie de la pression soviétique sur l'accès à des routes maritimes essentielles. Le protocole d'adhésion est signé à Londres le 22 octobre 1951.</li>
<li><strong>1955 — Allemagne fédérale.</strong> Aboutissement de plusieurs années de débats, alors que l'opinion allemande refusait le réarmement et que la France avait proposé une Communauté européenne de défense. Protocole signé à Paris en octobre 1954. L'URSS riposte par le pacte de Varsovie (14 mai 1955).</li>
<li><strong>1982 — Espagne.</strong></li>
<li><strong>1999 — Tchéquie, Hongrie, Pologne.</strong> Invitées au sommet de Madrid de 1997 après l'étude de 1995 sur l'élargissement ; premiers anciens membres du pacte de Varsovie à entrer. Le Plan d'action pour l'adhésion (MAP) est lancé en avril 1999 au sommet de Washington.</li>
<li><strong>2004 — sept pays</strong> (Bulgarie, Estonie, Lettonie, Lituanie, Roumanie, Slovaquie, Slovénie), tous entrés dans le MAP en 1999.</li>
<li><strong>2009 — Albanie et Croatie.</strong> Invitées au sommet de Bucarest (2-4 avril 2008) ; protocoles signés le 9 juillet 2008.</li>
<li><strong>2017 — Monténégro.</strong> Invité à entamer les pourparlers d'adhésion le 2 décembre 2015.</li>
<li><strong>2020 — Macédoine du Nord.</strong> Protocole signé le 6 février 2019, après l'accord entre Athènes et Skopje sur la question du nom qui a mis fin à près de trois décennies de différend.</li>
<li><strong>2023 — Finlande</strong> et <strong>2024 — Suède</strong> (voir l'entrée suivante).</li>
</ul>$$,
 array['members_old','members','enlarge','bucharest','de_nato','stolt2019','prot_grtr']);

select pg_temp.e('Membres et adhésion','mem-entree',33,'Comment on entre : l''article 10 et le plan d''action pour l''adhésion',
$$<p><strong>La règle :</strong> l'article 10 ouvre l'adhésion à tout autre État européen en mesure de favoriser les principes du traité et de contribuer à la sécurité de la zone nord-atlantique. C'est la base de la « politique de la porte ouverte ».</p>
<p><strong>Qui décide :</strong> toute invitation est décidée par le Conseil de l'Atlantique nord, par consensus entre tous les Alliés. L'OTAN insiste qu'aucun pays tiers n'a son mot à dire.</p>
<h3>Les étapes habituelles</h3>
<ol>
<li>Le pays déclare son intérêt et engage un dialogue intensifié avec l'OTAN sur ses ambitions et ses réformes.</li>
<li>Il peut être invité au Plan d'action pour l'adhésion (MAP) pour se préparer. Y participer ne garantit pas l'adhésion.</li>
<li>Les Alliés l'invitent à entamer les pourparlers d'adhésion.</li>
<li>Les Alliés signent un protocole d'adhésion, puis chaque Allié le ratifie selon sa procédure nationale.</li>
<li>Le pays dépose son instrument d'adhésion auprès du gouvernement des États-Unis (dépositaire du traité) : il devient membre à cette date.</li>
</ol>
<p><strong>Les critères :</strong> les candidats doivent remplir des critères politiques, économiques et militaires fixés par l'étude sur l'élargissement de 1995.</p>$$,
 array['enlarge','members','treaty','prot_grtr','what_is']);

select pg_temp.e('Membres et adhésion','mem-entree',34,'Finlande et Suède : l''élargissement de 2022-2024',
$$<ul>
<li><strong>18 mai 2022 :</strong> après l'invasion à grande échelle de l'Ukraine, les ambassadeurs de Finlande et de Suède remettent ensemble leurs lettres de candidature. Les deux pays abandonnent une neutralité ou un non-alignement de longue date.</li>
<li><strong>29-30 juin 2022 (Madrid) :</strong> les Alliés les invitent officiellement. Les pourparlers d'adhésion s'achèvent le 4 juillet 2022.</li>
<li><strong>4 avril 2023 :</strong> la Finlande devient membre. Elle partage une frontière d'environ 1 340 km avec la Russie.</li>
<li><strong>La Suède attend :</strong> la Turquie et la Hongrie tardent à ratifier. Le parlement turc approuve le 23 janvier 2024, après 20 mois de retard ; la Hongrie reste alors la dernière à ratifier. La Suède devient membre le 7 mars 2024.</li>
</ul>
<p>Voir la catégorie « Relations, tensions et critiques » pour les raisons avancées par Ankara et Budapest.</p>$$,
 array['enlarge','members_old','sw_inq','sw_bl','babel']);

select pg_temp.e('Membres et adhésion','mem-statuts',35,'Les pays aspirants : Bosnie-Herzégovine, Géorgie, Ukraine',
$$<p>L'OTAN indique que trois pays partenaires ont déclaré vouloir adhérer : la <strong>Bosnie-Herzégovine</strong>, la <strong>Géorgie</strong> et l'<strong>Ukraine</strong>. Aucun n'est membre.</p>
<ul>
<li><strong>2008 (sommet de Bucarest) :</strong> les Alliés accueillent favorablement les aspirations de l'Ukraine et de la Géorgie et conviennent que ces pays deviendront membres de l'OTAN ; le MAP est présenté comme l'étape suivante. Le même sommet invite la Bosnie-Herzégovine et le Monténégro à un dialogue intensifié.</li>
<li><strong>Décembre 2008 :</strong> les ministres des Affaires étrangères choisissent d'aider les deux pays dans le cadre de la Commission OTAN-Ukraine (devenue Conseil OTAN-Ukraine) et de la Commission OTAN-Géorgie, sans décider de leur entrée dans le MAP.</li>
<li><strong>22 avril 2010 :</strong> la Bosnie-Herzégovine est invitée à rejoindre le MAP ; son premier programme national annuel peut être accepté depuis décembre 2018, la question de l'enregistrement des biens immobiliers de défense au nom de l'État restant essentielle.</li>
<li><strong>Juin 2022 (Madrid) :</strong> les Alliés réaffirment la porte ouverte et promettent d'intensifier leur soutien à ces trois pays.</li>
</ul>
<p>Aucune date d'adhésion n'est fixée dans les sources consultées.</p>$$,
 array['enlarge','bucharest','bih']);

select pg_temp.e('Membres et adhésion','mem-statuts',36,'Les partenaires de l''OTAN',
$$<p>L'OTAN entretient des relations avec <strong>35 pays non membres</strong> et avec diverses organisations internationales, qu'elle appelle partenaires. L'objectif : renforcer la sécurité hors du territoire de l'Alliance, ce qui la rend elle-même plus sûre. Les partenaires n'ont pas le même pouvoir de décision que les membres et ne sont pas couverts par l'article 5.</p>
<ul>
<li><strong>Partenariat pour la paix (PfP) :</strong> programme de coopération pratique bilatérale avec 16 pays de l'espace euro-atlantique, parmi lesquels l'Arménie, l'Autriche, l'Azerbaïdjan, la Bosnie-Herzégovine, la Géorgie, l'Irlande et le Kazakhstan (liste partielle dans la source consultée).</li>
<li><strong>Partenaires aux « opportunités renforcées » :</strong> quatre pays — Australie, Géorgie, Jordanie, Ukraine — bénéficient d'une coopération plus poussée (participation facilitée aux exercices, consultations régulières).</li>
<li><strong>Renforcement des capacités de défense :</strong> la Bosnie-Herzégovine, la Géorgie, l'Irak, la Jordanie, la Mauritanie, la Moldavie, la Tunisie et l'ONU y participent.</li>
</ul>
<p>Dans l'atlas, voir aussi les groupes « OTAN — Partenariat pour la paix » et les autres groupes liés à l'OTAN.</p>$$,
 array['partners','what_is']);

select pg_temp.e('Membres et adhésion','mem-sortie',37,'Rester à part, se retirer : l''article 13 et les cas particuliers',
$$<ul>
<li><strong>Le retrait :</strong> l'article 13 permet à un pays, après vingt ans d'existence du traité, de cesser d'en être partie. Cette échéance (1969) a créé un malaise à l'OTAN au moment de la crise avec la France, discuté au Conseil sans conséquence. Aucun retrait n'est signalé dans les sources consultées ; une source tertiaire (Wikiwand) l'affirme explicitement.</li>
<li><strong>France (1966-2009) :</strong> elle quitte le commandement militaire intégré en 1966, tout en restant membre de l'Alliance ; elle y revient pleinement en avril 2009. Elle ne siège toujours pas au Groupe des plans nucléaires.</li>
<li><strong>Grèce (1974-1980) :</strong> après la crise de Chypre en 1974, elle se retire de la structure militaire intégrée et demande sa réintégration en 1980.</li>
<li><strong>Islande :</strong> n'a pas de forces armées ; un civil la représente au Comité militaire.</li>
</ul>$$,
 array['france_nato','dtic','csm1983','mc_iceland','wikiwand','npg']);
