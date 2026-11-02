-- ============================================================
-- groupes_v3 — dossier d'EXEMPLE « OTAN » (2/3) : Fonctionnement, Actions et compétences
-- Prérequis : groupes_v1 exécuté (catégories). groupes_v2 recommandé (même exemple), pas obligatoire.
-- Idempotente (ids fixes, ON CONFLICT DO NOTHING). Ne supprime rien.
-- Retour arrière : voir groupes_v2.sql (même balise de tag « Exemple OTAN »).
-- ============================================================

create temp table if not exists src(k text primary key, label text, url text);
insert into src(k,label,url) values
 ('nac','North Atlantic Council — nato.int','https://www.nato.int/en/about-us/organization/nato-structure/north-atlantic-council-nac'),
 ('what_is_html','What is NATO? (version HTML) — nato.int','https://nato.int/en/what-is-nato.html'),
 ('mc','Military Committee — nato.int','https://www.nato.int/en/about-us/organization/nato-structure/nato-military-committee/military-committee'),
 ('mc_chair','Chair of the Military Committee — nato.int','https://www.nato.int/en/about-us/organization/nato-structure/chair-of-the-military-committee'),
 ('sg','NATO Secretary General — nato.int','https://www.nato.int/en/about-us/organization/nato-structure/nato-secretary-general'),
 ('sg_what','What is a NATO Secretary General? — nato.int (1er oct. 2024)','https://www.nato.int/cps/en/natohq/news_229134.htm?selectedLocale=en'),
 ('rutte','Mark Rutte — nato.int','https://www.nato.int/en/about-us/organization/who-we-are/nato-secretaries-general/mark-rutte'),
 ('rutte_office','Mark Rutte takes office as NATO Secretary General — nato.int','https://www.nato.int/en/news-and-events/articles/news/2024/10/01/mark-rutte-takes-office-as-nato-secretary-general'),
 ('rutte_choice','NATO Allies select Mark Rutte as next Secretary General — nato.int','https://www.nato.int/cps/en/natohq/news_227064.htm'),
 ('shekerinska','Keynote de la secrétaire générale adjointe Radmila Shekerinska, 8 déc. 2025 — nato.int','https://www.nato.int/en/news-and-events/events/transcripts/2025/12/08/keynote-address-by-nato-deputy-secretary-general-radmila-shekerinska-at-harvard-kennedy-school-belfer-center'),
 ('who','Who we are — nato.int','https://www.nato.int/en/about-us/organization/who-we-are'),
 ('shape_cmd','Military Command Structure — SHAPE','https://shape.nato.int/military_command_structure'),
 ('ncs_pdf','The NATO Command Structure (fiche, ACT)','https://www.act.nato.int/wp-content/uploads/2023/05/1802-Factsheet-NATO-Command-Structure_en.pdf'),
 ('sact','Supreme Allied Commander Transformation — nato.int','https://www.nato.int/en/about-us/organization/nato-structure/supreme-allied-commander-transformation-sact?selectedLocale=ru'),
 ('npg','Nuclear Planning Group — nato.int','https://www.nato.int/en/about-us/organization/nato-structure/nuclear-planning-group-npg'),
 ('funding','Funding NATO — nato.int','https://www.nato.int/en/what-we-do/introduction-to-nato/funding-nato'),
 ('npa','NATO Parliamentary Assembly — nato.int','https://www.nato.int/en/what-we-do/partnerships-and-cooperation/nato-parliamentary-assembly'),
 ('npa2','Why a Parliamentary Assembly for NATO? — nato-pa.int','https://www.nato-pa.int/content/why-parliamentary-assembly-nato'),
 ('hq','NATO Headquarters — nato.int','https://www.nato.int/cps/en/natohq/topics_49284.htm?selectedLocale=uk'),
 ('knowyour','Know Your NATO 1949-1959 — archives de l''OTAN','https://archives.nato.int/uploads/r/null/1/3/137350/0067_Know_your_NATO_1949-1959_ENG.pdf'),
 ('short_hist','A short history of NATO — nato.int','https://www.nato.int/en/about-us/nato-history/a-short-history-of-nato'),
 ('strat','NATO 2022 Strategic Concept — nato.int','https://www.nato.int/en/about-us/official-texts-and-resources/strategic-concepts/nato-2022-strategic-concept'),
 ('strat_pdf','Strategic Concept 2022, texte intégral (PDF)','https://www.act.nato.int/wp-content/uploads/2023/05/290622-strategic-concept.pdf'),
 ('ndc','NATO''s New Strategic Concept — NATO Defense College','https://www.ndc.nato.int/natos-new-strategic-concept/'),
 ('art5','Collective defence and Article 5 — nato.int','https://nato.int/en/what-we-do/introduction-to-nato/collective-defence-and-article-5'),
 ('art5_old','Collective defence - Article 5 — nato.int','https://www.nato.int/cps/en/natohq/110496.htm?selectedLocale=en'),
 ('crisis','Crisis management — nato.int','https://www.nato.int/en/what-we-do/introduction-to-nato/crisis-management'),
 ('nuclear','NATO''s nuclear deterrence policy and forces — nato.int','https://www.nato.int/en/what-we-do/deterrence-and-defence/natos-nuclear-deterrence-policy-and-forces'),
 ('nuc_share','NATO''s Nuclear Sharing Arrangements (fiche, 2022)','https://www.nato.int/content/dam/nato/legacy-wcm/media_pdf/2022/2/pdf/220204-factsheet-nuclear-sharing-arrangements_en.pdf'),
 ('armscontrol','Arms control, disarmament and non-proliferation — nato.int','https://www.nato.int/en/what-we-do/wider-activities/arms-control-disarmament-and-non-proliferation'),
 ('efp','Strengthening NATO''s eastern flank — nato.int','https://www.nato.int/en/what-we-do/deterrence-and-defence/strengthening-natos-eastern-flank'),
 ('efp_lc','Enhanced Forward Presence — Allied Land Command','https://lc.nato.int/operations/enhanced-forward-presence-efp'),
 ('rap','Readiness Action Plan — nato.int','https://nato.int/cps/ru/natohq/topics_119353.htm?selectedLocale=en'),
 ('deterrence','Deterrence and defence — nato.int','https://www.nato.int/en/what-we-do/deterrence-and-defence/deterrence-and-defence'),
 ('stmt2022','Statement by NATO Heads of State and Government, 24 mars 2022','https://www.nato.int/en/about-us/official-texts-and-resources/official-texts/2022/03/24/statement-by-nato-heads-of-state-and-government'),
 ('madrid','Madrid Summit Declaration, 29 juin 2022 — nato.int','https://www.nato.int/en/about-us/official-texts-and-resources/official-texts/2022/06/29/madrid-summit-declaration'),
 ('ops','NATO operations and missions — nato.int','https://www.nato.int/en/what-we-do/operations-and-missions/nato-operations-and-missions'),
 ('ops_list','Operations and missions (liste) — nato.int','https://www.nato.int/en/what-we-do/operations-and-missions'),
 ('kosovo','NATO''s role in Kosovo — nato.int','https://www.nato.int/en/what-we-do/operations-and-missions/natos-role-in-kosovo'),
 ('bosnia','Peace support operations in Bosnia and Herzegovina (1995-2004) — nato.int','https://www.nato.int/en/what-we-do/operations-and-missions/peace-support-operations-in-bosnia-and-herzegovina-1995-2004'),
 ('bih','Relations with Bosnia and Herzegovina — nato.int','https://www.nato.int/en/what-we-do/partnerships-and-cooperation/relations-with-bosnia-and-herzegovina?selectedLocale=ic'),
 ('un_rel','Relations with the United Nations — nato.int','https://nato.int/cps/en/natohq/topics_50321.htm'),
 ('nato_delivers','NATO Delivers: Yesterday, Today and Tomorrow (2012) — nato.int','https://www.nato.int/cps/en/natohq/news_87430.htm'),
 ('mar','NATO''s maritime activities — nato.int','https://www.nato.int/en/what-we-do/operations-and-missions/natos-maritime-activities'),
 ('hague_over','Overview — 2025 NATO Summit in The Hague — nato.int','https://www.nato.int/en/news-and-events/events/2025/6/overview---2025-nato-summit-in-the-hague'),
 ('hague_decl','The Hague Summit Declaration, 25 juin 2025 — nato.int','https://www.nato.int/en/about-us/official-texts-and-resources/official-texts/2025/06/25/the-hague-summit-declaration'),
 ('ukraine','Relations with Ukraine — nato.int','https://www.nato.int/en/what-we-do/partnerships-and-cooperation/relations-with-ukraine'),
 ('partners','NATO''s partnerships — nato.int','https://www.nato.int/en/what-we-do/partnerships-and-cooperation/natos-partnerships'),
 ('enlarge','Enlargement and Article 10 — nato.int','https://www.nato.int/en/what-we-do/partnerships-and-cooperation/enlargement-and-article-10'),
 ('libya_waw','Résolution 1973 et opération en Libye (Weapons and Warfare)','https://weaponsandwarfare.com/?p=21133'),
 ('straight','Setting the record straight — nato.int','https://www.nato.int/en/what-we-do/wider-activities/natos-approach-to-counter-information-threats/setting-the-record-straight'),
 ('npa_lang','AP-OTAN, offre d''emploi (langues officielles anglais/français)','https://www.nato-pa.int/content/parliamentary-activities-coordinator'),
 ('ct2004','Expanding NATO''s counter-terrorism role (2004) — nato.int','https://www.nato.int/en/news-and-events/events/transcripts/2004/07/01/expanding-natos-counter-terrorism-role')
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

-- ===================== FONCTIONNEMENT =====================
select pg_temp.s('fon-politique','Fonctionnement','Le niveau politique',10);
select pg_temp.s('fon-militaire','Fonctionnement','Le niveau militaire',20);
select pg_temp.s('fon-nucleaire','Fonctionnement','Le nucléaire',30);
select pg_temp.s('fon-argent','Fonctionnement','L''argent',40);
select pg_temp.s('fon-autres','Fonctionnement','Autres organes, lieux et langues',50);

select pg_temp.e('Fonctionnement','fon-politique',60,'Le consensus : la règle d''or',
$$<ul>
<li><strong>Pas de vote, pas de majorité.</strong> Les décisions du Conseil de l'Atlantique nord sont prises à l'unanimité, par accord commun. Chaque Allié a le même droit d'exprimer son avis et de participer au consensus.</li>
<li><strong>Cela vaut pour tous les comités</strong>, y compris le Groupe des plans nucléaires.</li>
<li><strong>Cela s'applique aux grands choix :</strong> inviter un pays à adhérer, choisir un secrétaire général (les Alliés négocient jusqu'à ce qu'un seul candidat fasse consensus), lancer une opération.</li>
<li><strong>Après une décision commune,</strong> chaque Allié choisit lui-même s'il contribue à une opération et comment.</li>
<li><strong>Conséquence pratique :</strong> un seul Allié peut retarder ou bloquer une décision collective. L'adhésion de la Suède, retardée vingt mois, en est un exemple (voir « Relations, tensions et critiques »).</li>
</ul>$$,
 array['nac','sg_what','enlarge','ops','npg']);

select pg_temp.e('Fonctionnement','fon-politique',61,'Le Conseil de l''Atlantique nord (NAC)',
$$<p>Le NAC est l'organe politique principal de l'OTAN et l'autorité au sommet d'un réseau de comités. C'est le <strong>seul organe créé par le traité</strong> (article 9, en 1949), et le seul à pouvoir créer des organes subsidiaires.</p>
<ul>
<li><strong>Qui y siège :</strong> chaque pays est représenté par un représentant permanent (ambassadeur), assisté d'une délégation nationale.</li>
<li><strong>Qui le préside :</strong> le secrétaire général ; en son absence, le secrétaire général adjoint.</li>
<li><strong>À quel rythme :</strong> au moins une fois par semaine, ou dès que nécessaire, à différents niveaux (ambassadeurs, ministres, chefs d'État et de gouvernement lors des sommets). Une décision du Conseil a la même valeur quel que soit le niveau de réunion.</li>
<li><strong>Le doyen :</strong> l'ambassadeur le plus ancien porte le titre de doyen du Conseil, fonction surtout honorifique, sauf pour convoquer et présider lors du choix d'un nouveau secrétaire général.</li>
<li><strong>Présidence tournante :</strong> aux réunions des ministres des Affaires étrangères, le ministre d'un pays assume la présidence d'honneur ; elle change chaque année selon l'ordre alphabétique anglais.</li>
<li><strong>Soutien :</strong> un secrétaire du Conseil et un petit secrétariat ; plus largement, l'ensemble du Secrétariat international.</li>
</ul>$$,
 array['nac','what_is_html']);

select pg_temp.e('Fonctionnement','fon-politique',62,'Le secrétaire général et le Secrétariat international',
$$<ul>
<li><strong>Le rôle :</strong> plus haut fonctionnaire international de l'OTAN. Il préside le NAC et d'autres comités clés (Groupe des plans nucléaires, Conseil OTAN-Ukraine, Conseil OTAN-Russie, Conseil de partenariat euro-atlantique, Commission OTAN-Géorgie), porte-parole de l'organisation et chef du Secrétariat international. Il peut proposer des sujets et user de ses bons offices en cas de différend entre Alliés.</li>
<li><strong>Le choix :</strong> une personnalité politique d'un pays membre, désignée par consensus, pour quatre ans, renouvelable avec l'accord de tous. Le poste est traditionnellement tenu par un Européen. Jens Stoltenberg a ainsi été prolongé quatre fois pour dix ans au total.</li>
<li><strong>Mark Rutte :</strong> désigné par le Conseil le 26 juin 2024, en fonction depuis le 1er octobre 2024. Ses trois priorités annoncées : une OTAN forte et des défenses crédibles ; un soutien accru à l'Ukraine ; des partenariats renforcés.</li>
<li><strong>Secrétaire générale adjointe :</strong> Radmila Shekerinska (en fonction en décembre 2025 selon un discours publié par l'OTAN).</li>
<li><strong>Le Secrétariat international</strong> appuie le NAC et ses comités : bureau du secrétaire général, six divisions dirigées par des secrétaires généraux adjoints, plus des offices dirigés par des directeurs.</li>
</ul>$$,
 array['sg','sg_what','rutte','rutte_office','rutte_choice','shekerinska','who']);

select pg_temp.e('Fonctionnement','fon-militaire',63,'Le Comité militaire',
$$<p>Le Comité militaire (MC) est la plus haute autorité militaire de l'OTAN et le plus ancien organe permanent après le Conseil : les deux ont été créés quelques mois après l'Alliance (première réunion du MC le 6 octobre 1949).</p>
<ul>
<li><strong>Composition :</strong> un officier supérieur (en général trois étoiles) par pays, représentant son chef d'état-major (« MILREP »). Les chefs d'état-major eux-mêmes se réunissent trois fois par an. L'Islande, sans forces armées, est représentée par un civil.</li>
<li><strong>Rôle :</strong> donner au Conseil et au Groupe des plans nucléaires un avis militaire par consensus, orienter les deux commandants stratégiques, traduire les décisions politiques en directives militaires. Son avis est demandé avant toute autorisation d'opération par le Conseil.</li>
<li><strong>Le président :</strong> élu parmi les chefs d'état-major pour trois ans, traditionnellement un officier non américain de rang quatre étoiles. L'amiral Giuseppe Cavo Dragone a pris ses fonctions le 17 janvier 2025.</li>
<li><strong>Appui :</strong> l'État-major militaire international (IMS), son organe exécutif.</li>
</ul>$$,
 array['mc','mc_chair','who']);

select pg_temp.e('Fonctionnement','fon-militaire',64,'La structure de commandement',
$$<p>La structure de commandement de l'OTAN (NCS) est l'ossature militaire permanente : des quartiers généraux multinationaux, répartis géographiquement et financés en commun. Elle comprend deux commandements stratégiques.</p>
<h3>Commandement allié des opérations (ACO)</h3>
<ul>
<li>Chargé de la planification et de la conduite de toutes les opérations militaires de l'OTAN, selon les directives du Conseil.</li>
<li>Dirigé par le SACEUR, traditionnellement un officier américain, qui est aussi commandant du commandement européen des États-Unis. Quartier général : SHAPE, à Mons (Belgique).</li>
<li>Niveau opérationnel : trois commandements interarmées (Brunssum aux Pays-Bas, Naples en Italie, Norfolk en Virginie). Niveau tactique : commandements terrestre, maritime et aérien.</li>
</ul>
<h3>Commandement allié pour la transformation (ACT)</h3>
<ul>
<li>Chargé de l'adaptation militaire de l'Alliance ; quartier général à Norfolk (Virginie).</li>
<li>Depuis 2009, c'est un officier général français qui le dirige (l'amiral Pierre Vandier selon la page consultée). De 2002 à 2009, c'était un officier américain.</li>
</ul>
<p><strong>À ne pas confondre :</strong> la structure de commandement (permanente) et la <em>structure de forces</em> de l'OTAN, un réservoir de forces et de quartiers généraux nationaux ou multinationaux mis à disposition de l'Alliance de façon permanente ou temporaire.</p>$$,
 array['shape_cmd','ncs_pdf','sact','mc']);

select pg_temp.e('Fonctionnement','fon-nucleaire',65,'Le Groupe des plans nucléaires (NPG)',
$$<ul>
<li><strong>Création :</strong> décembre 1966, sur recommandation d'un comité de ministres de la Défense présidé par l'Américain Robert McNamara. Première réunion les 6-7 avril 1967 à Washington (ministres du Canada, d'Italie, des Pays-Bas, de Turquie, du Royaume-Uni, des États-Unis et d'Allemagne de l'Ouest).</li>
<li><strong>Rôle :</strong> organe de consultation et de décision sur tout ce qui touche à la dissuasion nucléaire (politique, doctrine, planification, posture, capacités, exercices, sûreté et sécurité des armes). Le NAC lui délègue ces sujets.</li>
<li><strong>Membres :</strong> tous les Alliés, dotés ou non de l'arme nucléaire, sauf la France qui a choisi de ne pas y participer. La rotation des sièges a pris fin en 1979.</li>
<li><strong>Fonctionnement :</strong> présidé par le secrétaire général, réuni en général au niveau des ministres de la Défense ; décisions par consensus. Préparé par un groupe d'état-major ; un Groupe de haut niveau, présidé par les États-Unis, conseille sur la politique et la posture.</li>
</ul>$$,
 array['npg','nuclear']);

select pg_temp.e('Fonctionnement','fon-argent',66,'Qui paie quoi : financement commun et contributions nationales',
$$<ul>
<li><strong>La plus grosse part est nationale (« indirecte ») :</strong> chaque pays finance ses propres forces et capacités, qu'il met à disposition de l'OTAN pour la dissuasion, la défense et les opérations.</li>
<li><strong>Le financement commun (« direct ») :</strong> environ 4,6 milliards d'euros en 2025 (0,3 % des dépenses de défense cumulées des Alliés), jusqu'à 5,3 milliards en 2026. Tous les Alliés y contribuent selon une clé de répartition tirée de leur revenu national brut.</li>
</ul>
<table>
<tr><th>Budget commun</th><th>Ce qu'il finance</th><th>D'où vient l'argent</th></tr>
<tr><td>Budget civil</td><td>Le siège de Bruxelles et le Secrétariat international ; la consultation et la prise de décision</td><td>Surtout les ministères des Affaires étrangères</td></tr>
<tr><td>Budget militaire</td><td>La structure de commandement intégrée, l'État-major militaire international, les commandements stratégiques, la force aérienne d'alerte avancée (AWACS), les opérations et missions de l'Alliance</td><td>Surtout les budgets nationaux de défense</td></tr>
<tr><td>Programme d'investissement NSIP</td><td>Les infrastructures et systèmes de commandement : bases aériennes et navales, communications par satellite, oléoducs de carburant</td><td>Les ministères de la Défense</td></tr>
</table>
<p>Les États fournissent et paient eux-mêmes les militaires qui servent dans la structure de commandement ou en opération. Les plafonds sont annuels, alignés sur l'année civile ; les Alliés fixent aussi des chiffres de planification à moyen terme. Trois instances veillent sur l'argent : le Conseil de politique et de planification des ressources, le Comité du budget et le Comité d'investissement.</p>$$,
 array['funding']);

select pg_temp.e('Fonctionnement','fon-argent',67,'Les clés de répartition du financement commun (2026-2027)',
$$<p>Les parts ci-dessous, en pourcentage du budget commun, sont valables du 1er janvier 2026 au 31 décembre 2027 pour l'Alliance à 32. Elles se fondent sur le revenu national brut de chaque pays.</p>
<table>
<tr><th>Pays</th><th>Part</th></tr>
<tr><td>Allemagne</td><td>14,9039 %</td></tr>
<tr><td>États-Unis</td><td>14,9039 %</td></tr>
<tr><td>Royaume-Uni</td><td>10,3277 %</td></tr>
<tr><td>France</td><td>10,1023 %</td></tr>
<tr><td>Italie</td><td>7,9925 %</td></tr>
<tr><td>Canada</td><td>6,5845 %</td></tr>
<tr><td>Türkiye</td><td>6,3010 %</td></tr>
<tr><td>Espagne</td><td>5,7782 %</td></tr>
<tr><td>Pays-Bas</td><td>3,5014 %</td></tr>
<tr><td>Pologne</td><td>3,3813 %</td></tr>
<tr><td>Belgique</td><td>2,0716 %</td></tr>
<tr><td>Suède</td><td>1,9787 %</td></tr>
<tr><td>Norvège</td><td>1,6803 %</td></tr>
<tr><td>Roumanie</td><td>1,6098 %</td></tr>
<tr><td>Danemark</td><td>1,2870 %</td></tr>
<tr><td>Tchéquie</td><td>1,1624 %</td></tr>
<tr><td>Portugal</td><td>1,0701 %</td></tr>
<tr><td>Finlande</td><td>0,9295 %</td></tr>
<tr><td>Grèce</td><td>0,9228 %</td></tr>
<tr><td>Hongrie</td><td>0,8608 %</td></tr>
<tr><td>Islande</td><td>0,0849 %</td></tr>
<tr><td>Monténégro (la plus petite part)</td><td>0,0362 %</td></tr>
</table>
<p>Les 10 autres pays (Albanie, Bulgarie, Croatie, Estonie, Lettonie, Lituanie, Luxembourg, Macédoine du Nord, Slovaquie, Slovénie) ont chacun moins de 0,5 %. Les États-Unis et l'Allemagne ont la même part. Le total fait 100 %.</p>$$,
 array['funding']);

select pg_temp.e('Fonctionnement','fon-autres',68,'L''Assemblée parlementaire de l''OTAN',
$$<ul>
<li><strong>Ce que c'est :</strong> une organisation interparlementaire créée en 1955, qui réunit des parlementaires des pays membres pour discuter de sécurité. Elle est <strong>institutionnellement séparée de l'OTAN</strong>, mais sert de lien avec les parlements nationaux.</li>
<li><strong>Ce qu'elle n'est pas :</strong> elle n'a pas de rôle direct de contrôle des politiques de l'OTAN. Elle sert surtout à faire connaître et débattre ces politiques et à donner une indication de l'opinion parlementaire.</li>
<li><strong>Organisation :</strong> un président (parlementaire d'un pays membre), un secrétariat international à Bruxelles, cinq commissions et huit sous-commissions ; ses rapports sont adoptés à la majorité. Elle s'ouvre aussi aux parlementaires de pays partenaires.</li>
<li><strong>Langues de travail :</strong> anglais et français.</li>
</ul>$$,
 array['npa','npa2','npa_lang']);

select pg_temp.e('Fonctionnement','fon-autres',69,'Le siège et les langues',
$$<ul>
<li><strong>Siège :</strong> le quartier général de l'OTAN est son centre politique et administratif, à Bruxelles, boulevard Léopold III. Il permet aux représentants et experts des pays membres de se consulter en continu, élément clé de la décision par consensus.</li>
<li><strong>Un siège déplacé :</strong> d'abord à Paris, il passe à Bruxelles en octobre 1967, après le départ de la France du commandement intégré. Le SHAPE, lui, s'installe en Belgique, près de Mons.</li>
<li><strong>Langues :</strong> l'anglais et le français sont les langues officielles de l'OTAN (selon une publication officielle de 1959), et les communiqués sont publiés dans les deux.</li>
</ul>$$,
 array['hq','short_hist','knowyour']);

-- ===================== ACTIONS ET COMPÉTENCES =====================
select pg_temp.s('act-defense','Actions et compétences','Défense collective et dissuasion',10);
select pg_temp.s('act-ops','Actions et compétences','Opérations et missions',20);
select pg_temp.s('act-part','Actions et compétences','Partenariats, soutien et résilience',30);

select pg_temp.e('Actions et compétences','act-defense',70,'Les trois tâches fondamentales du Concept stratégique 2022',
$$<ol>
<li><strong>Dissuasion et défense</strong> — la « colonne vertébrale » de l'engagement de l'article 5. Elle repose sur un dosage de capacités nucléaires, conventionnelles et de défense antimissile, complétées par l'espace et le cyber, selon une approche « à 360 degrés » (toutes menaces, toutes directions).</li>
<li><strong>Prévention et gestion des crises</strong> — prévenir les crises, gérer les conflits, stabiliser les situations d'après-conflit, en coordination notamment avec l'ONU.</li>
<li><strong>Sécurité coopérative</strong> — partenariats et dialogue avec d'autres pays et organisations.</li>
</ol>
<p>Le texte ajoute des priorités transversales : la résilience nationale et collective, l'innovation technologique, le changement climatique, la sécurité humaine et l'agenda « Femmes, paix et sécurité ».</p>
<p><strong>L'analyse des menaces :</strong> la Russie y est désignée comme la menace la plus importante et la plus directe pour la sécurité des Alliés. Sont aussi cités le terrorisme, l'instabilité au Moyen-Orient et en Afrique, la cybersécurité, les technologies émergentes, l'érosion du contrôle des armements et, pour la première fois, la Chine (ses ambitions et ses politiques coercitives). Le texte affirme que l'OTAN ne cherche pas la confrontation et ne représente pas une menace pour la Russie.</p>$$,
 array['strat','strat_pdf','ndc','deterrence','un_rel']);

select pg_temp.e('Actions et compétences','act-defense',71,'L''article 5 : ce qu''il impose vraiment',
$$<ul>
<li><strong>Le principe :</strong> une attaque armée contre un Allié est considérée comme une attaque contre tous. Cela transforme le droit de légitime défense collective (article 51 de la Charte de l'ONU) en obligation d'assistance mutuelle.</li>
<li><strong>Une obligation individuelle :</strong> chaque Allié décide lui-même de la forme de son aide, pourvu qu'elle serve à « restaurer et maintenir la sécurité de la zone nord-atlantique ». L'assistance peut, ou non, inclure la force armée. Il n'y a pas d'automatisme militaire.</li>
<li><strong>Deux conditions pour l'activer :</strong> qu'un Allié ait subi une « attaque armée » (appréciée de bonne foi par les Alliés) et qu'il demande ou accepte une action collective au titre de l'article 5. Le traité ne prévoit aucune procédure précise de déclenchement.</li>
<li><strong>Une attaque purement interne</strong> (par exemple un acte terroriste sans composante internationale) ne déclenche pas l'article 5.</li>
<li><strong>Menaces hybrides :</strong> selon le Concept stratégique de 2022, des opérations hybrides contre des Alliés pourraient atteindre le niveau d'une attaque armée et conduire le Conseil à invoquer l'article 5.</li>
<li><strong>Un jalon rare :</strong> l'article 5 n'a été invoqué qu'une fois (2001), mais il sous-tend toute la dissuasion : exercices, forces permanentes, présence avancée.</li>
</ul>$$,
 array['art5','strat_pdf']);

select pg_temp.e('Actions et compétences','act-defense',72,'11 septembre 2001 : la seule invocation de l''article 5',
$$<ol>
<li><strong>11 septembre 2001 :</strong> le Conseil condamne les attentats contre les États-Unis et exprime sa solidarité.</li>
<li><strong>12 septembre (soir) :</strong> en moins de 24 heures, les Alliés conviennent que si l'attaque est avérée venir de l'étranger, elle relèvera de l'article 5. Le secrétaire général Lord Robertson en informe le secrétaire général de l'ONU.</li>
<li><strong>2 octobre :</strong> après un exposé américain sur l'enquête, le Conseil juge que les attentats relèvent de l'article 5.</li>
<li><strong>4 octobre :</strong> huit mesures de soutien : partage de renseignements, droits de survol et accès aux ports et aérodromes, aide aux États menacés du fait de leur soutien à la coalition, déploiement de forces navales en Méditerranée orientale, envoi d'avions radar AWACS aux États-Unis.</li>
<li><strong>9 octobre 2001 – mi-mai 2002 : opération Eagle Assist,</strong> première opération antiterroriste de l'OTAN : sept avions AWACS, 830 membres d'équipage de 13 pays, plus de 360 sorties au-dessus des États-Unis. C'est la première fois que des moyens de l'OTAN sont déployés dans le cadre de l'article 5.</li>
<li><strong>Opération Active Endeavour (2001-2016) :</strong> surveillance antiterroriste en Méditerranée avec les forces navales permanentes.</li>
</ol>
<p>Cette réponse a aussi mené l'OTAN à ses premières opérations hors de la zone euro-atlantique, dont l'Afghanistan.</p>$$,
 array['art5','art5_old','crisis','ops_list','ct2004']);

select pg_temp.e('Actions et compétences','act-defense',73,'La dissuasion nucléaire et le « partage nucléaire »',
$$<ul>
<li><strong>Le principe :</strong> pour l'OTAN, les armes nucléaires sont un élément central de sa dissuasion, à côté des moyens conventionnels et de défense antimissile. Leur but déclaré : préserver la paix, empêcher la coercition, dissuader l'agression. Tant qu'elles existent, l'OTAN restera une « alliance nucléaire ». La politique nucléaire a été mise à jour en 2024.</li>
<li><strong>Trois puissances nucléaires :</strong> États-Unis, France, Royaume-Uni. Les forces stratégiques des États-Unis sont, selon l'OTAN, la garantie suprême de la sécurité de l'Alliance. Les forces indépendantes britanniques et françaises ont un rôle dissuasif propre. Le Royaume-Uni a mis ses forces sous protection des Alliés de l'OTAN depuis 1962 ; la France reste hors du Groupe des plans nucléaires.</li>
<li><strong>Le partage nucléaire :</strong> des armes nucléaires américaines (bombes B-61) sont déployées en Europe sous contrôle et garde exclusifs des États-Unis ; elles seraient emportées par des avions à double capacité fournis volontairement par sept Alliés. L'OTAN précise que ce qui est partagé, ce sont la mission, les responsabilités politiques et les décisions, <em>pas les armes</em>. Tout emploi supposerait l'accord politique du NPG et l'autorisation du président américain (et du Premier ministre britannique).</li>
<li><strong>Historique :</strong> les premières armes nucléaires américaines arrivent en Europe en 1954 ; le NPG est créé en 1966. Depuis la guerre froide, l'OTAN dit avoir réduit de plus de 90 % son stock d'armes nucléaires terrestres en Europe. Un exercice annuel de dissuasion, « Steadfast Noon », est organisé.</li>
<li><strong>Traité de non-prolifération :</strong> l'OTAN affirme que ses arrangements sont conformes au TNP, qui est entré en vigueur en 1970 et en a tenu compte lors de sa négociation. Cette position est contestée par certains pays (voir « Relations, tensions et critiques »).</li>
</ul>$$,
 array['nuclear','nuc_share','armscontrol','npg']);

select pg_temp.e('Actions et compétences','act-defense',74,'La présence avancée à l''Est (2014-2026)',
$$<p>Avant 2014, il n'y avait pas de déploiement permanent de troupes multinationales de l'OTAN dans la partie orientale de l'Alliance. La présence actuelle s'est construite en étapes :</p>
<ul>
<li><strong>2014 :</strong> après l'annexion de la Crimée par la Russie, plan d'action pour la réactivité (Readiness Action Plan) et renforcement de la Force de réaction de l'OTAN.</li>
<li><strong>2016 (sommet de Varsovie) :</strong> décision d'une présence avancée renforcée. <strong>2017 :</strong> quatre groupements tactiques multinationaux en Estonie, Lettonie, Lituanie et Pologne.</li>
<li><strong>24 mars 2022 :</strong> sommet extraordinaire ; quatre groupements de plus en Bulgarie, Hongrie, Roumanie et Slovaquie, soit huit au total, ce qui double les troupes sur place.</li>
<li><strong>Madrid, juin 2022 :</strong> possibilité de passer des bataillons à la taille d'une brigade « là où et quand c'est nécessaire » ; nouveau modèle de forces de l'OTAN, avec plus de troupes à haut niveau de préparation.</li>
<li><strong>2026 :</strong> neuf groupements, avec la Finlande.</li>
</ul>
<table>
<tr><th>Pays d'accueil</th><th>Nation-cadre</th><th>Contributeurs (selon la page de l'OTAN consultée)</th></tr>
<tr><td>Finlande</td><td>Suède</td><td>Danemark, France, Islande, Italie, Norvège, Royaume-Uni</td></tr>
<tr><td>Hongrie</td><td>Hongrie</td><td>Croatie, Italie, Türkiye, États-Unis</td></tr>
<tr><td>Lettonie</td><td>Canada</td><td>Albanie, Tchéquie, Danemark, Islande, Italie, Monténégro, Macédoine du Nord, Pologne, Slovaquie, Slovénie, Espagne, Suède</td></tr>
<tr><td>Lituanie</td><td>Allemagne</td><td>Belgique, Tchéquie, Luxembourg, Pays-Bas, Norvège</td></tr>
<tr><td>Pologne</td><td>États-Unis</td><td>Croatie, Roumanie, Royaume-Uni</td></tr>
<tr><td>Roumanie</td><td>France</td><td>Belgique, Luxembourg, Espagne</td></tr>
<tr><td>Slovaquie</td><td>Espagne</td><td>Tchéquie, Portugal, Roumanie, Slovénie</td></tr>
</table>
<p>Les groupements d'Estonie et de Bulgarie ne figurent pas dans l'extrait consulté : leurs nations-cadres restent à compléter. Les groupements sont fournis de façon volontaire et par rotation, et intégrés à la structure de commandement de l'OTAN.</p>$$,
 array['efp','efp_lc','rap','deterrence','stmt2022','straight']);

select pg_temp.e('Actions et compétences','act-defense',75,'Après février 2022 : plans de défense et nouveau modèle de forces',
$$<ul>
<li><strong>Réaction immédiate :</strong> après l'invasion de l'Ukraine, les Alliés activent les plans de défense de l'OTAN, déploient des éléments de la Force de réaction (pour la première fois, l'élément de plus haut niveau de préparation est envoyé en Roumanie) et placent 40 000 soldats, avec d'importants moyens aériens et navals, sous commandement direct de l'OTAN sur le flanc est.</li>
<li><strong>Madrid, 29 juin 2022 :</strong> nouveau Concept stratégique ; nouvelle « base de référence » pour la dissuasion et la défense ; renforcement de la défense aérienne et antimissile intégrée ; plus d'exercices de haute intensité.</li>
<li><strong>Un volet maritime :</strong> les Forces navales permanentes fournissent une capacité maritime continue ; la sécurité maritime est jugée essentielle (la liberté de navigation, les routes commerciales).</li>
<li><strong>Un plan de capacités :</strong> en 2025, les ministres de la Défense approuvent de nouveaux objectifs de capacités, que l'objectif de 5 % du PIB doit financer.</li>
</ul>$$,
 array['rap','stmt2022','madrid','mar','deterrence']);

select pg_temp.e('Actions et compétences','act-ops',76,'Bosnie-Herzégovine (1992-2004) : première intervention militaire',
$$<ul>
<li><strong>28 février 1994 :</strong> en surveillant la zone d'exclusion aérienne, l'OTAN mène ses premiers combats : quatre avions de combat serbes de Bosnie sont abattus.</li>
<li><strong>Août-septembre 1995 :</strong> à la demande des Casques bleus, frappes aériennes (opération Deadeye, 30 août, puis Deliberate Force, 12 jours), qui contribuent à ouvrir la voie à un accord de paix.</li>
<li><strong>Décembre 1995 :</strong> après les accords de Dayton (14 décembre), l'OTAN déploie l'IFOR (environ 60 000 hommes, mandat de l'ONU), puis, en décembre 1996, la SFOR (environ 32 000 hommes) jusqu'en décembre 2004. C'est sa première grande opération de réponse aux crises.</li>
<li><strong>Suites :</strong> l'OTAN garde un quartier général à Sarajevo et soutient l'opération européenne EUFOR Althea au titre des accords « Berlin Plus ».</li>
</ul>$$,
 array['bosnia','ops','un_rel','bih']);

select pg_temp.e('Actions et compétences','act-ops',77,'Kosovo : campagne aérienne de 1999 et KFOR',
$$<ul>
<li><strong>Mars-juin 1999 :</strong> campagne aérienne de 78 jours lancée par l'OTAN, pour arrêter et inverser la catastrophe humanitaire qui se déroulait au Kosovo.</li>
<li><strong>10 juin 1999 :</strong> résolution 1244 du Conseil de sécurité de l'ONU. <strong>12 juin :</strong> premiers éléments de la KFOR ; le retrait des forces serbes est achevé le 20 juin.</li>
<li><strong>La KFOR aujourd'hui :</strong> environ 4 500 à 4 700 soldats de 31 pays alliés et partenaires (selon les pages), pour un environnement sûr et la liberté de circulation, en coordination avec la police du Kosovo et la mission européenne EULEX. Elle est commandée depuis le commandement interarmées de Naples.</li>
<li><strong>2008 :</strong> tâches supplémentaires (formation de la Force de sécurité du Kosovo). <strong>2010-2011 :</strong> réduction à environ 5 000 hommes.</li>
<li><strong>2023 :</strong> après des violences, jusqu'à 1 000 soldats supplémentaires, le plus grand renforcement de la mission en dix ans.</li>
<li><strong>2026 :</strong> début de l'intégration de policiers kosovars à la protection du monastère de Visoki Dečani, dernier site sous protection fixe de la KFOR.</li>
<li>L'OTAN soutient l'accord de normalisation Belgrade-Pristina de 2013, négocié par l'UE.</li>
</ul>
<p>La légalité de la campagne aérienne de 1999 est débattue : voir « Relations, tensions et critiques ».</p>$$,
 array['kosovo','ops','un_rel']);

select pg_temp.e('Actions et compétences','act-ops',78,'Afghanistan (2001-2021)',
$$<ul>
<li><strong>2001 :</strong> après le 11 septembre, la Force internationale d'assistance à la sécurité (FIAS/ISAF) est créée à la demande des autorités afghanes, sous mandat de l'ONU.</li>
<li><strong>Août 2003 – décembre 2014 :</strong> l'OTAN prend la tête de la FIAS, l'une des plus grandes opérations internationales de gestion de crise, avec des contributions de plus de 50 pays. Mission : former les forces afghanes et permettre aux autorités d'assurer la sécurité du pays pour éviter qu'il ne redevienne un refuge pour terroristes. Des équipes de reconstruction provinciales, dirigées par des pays contributeurs, y contribuent.</li>
<li><strong>Fin 2014 :</strong> la responsabilité de la sécurité est transférée à l'armée et à la police afghanes.</li>
<li><strong>1er janvier 2015 – début septembre 2021 :</strong> mission « Resolute Support » (conseil et formation), avec un pôle à Kaboul/Bagram et quatre antennes (Mazar-e Charif, Hérat, Kandahar, Laghman).</li>
</ul>$$,
 array['ops','un_rel','art5']);

select pg_temp.e('Actions et compétences','act-ops',79,'Libye (2011) : opération Unified Protector',
$$<ul>
<li><strong>Contexte :</strong> en février 2011, le régime de Kadhafi s'en prend à des civils ; le Conseil de sécurité adopte la résolution 1973 le 17 mars 2011 (protection des civils par tous les moyens nécessaires, zone d'exclusion aérienne, embargo sur les armes).</li>
<li><strong>27 mars 2011 :</strong> les Alliés décident de prendre en charge toute l'opération militaire. L'OTAN applique l'embargo sur les armes, la zone d'exclusion aérienne et des mesures de protection des civils.</li>
<li><strong>Fin :</strong> opération terminée en octobre 2011.</li>
<li>La question de savoir si le mandat a été dépassé fait l'objet d'un débat (voir « Relations, tensions et critiques »).</li>
</ul>$$,
 array['un_rel','nato_delivers','ops_list','libya_waw']);

select pg_temp.e('Actions et compétences','act-ops',80,'Autres missions : Irak, mer Égée, Méditerranée, piraterie, catastrophes',
$$<table>
<tr><th>Mission</th><th>Période</th><th>Nature</th></tr>
<tr><td>Mission OTAN en Irak</td><td>en cours</td><td>Mission de conseil et de renforcement des capacités, sans combat, pour aider les institutions de sécurité irakiennes à empêcher le retour de Daech</td></tr>
<tr><td>Opération Sea Guardian</td><td>en cours</td><td>Sécurité maritime en Méditerranée</td></tr>
<tr><td>Aide à la crise des réfugiés en mer Égée</td><td>en cours (liste de l'OTAN)</td><td>Surveillance et soutien</td></tr>
<tr><td>Coopération avec l'Union africaine</td><td>en cours</td><td>Soutien</td></tr>
<tr><td>Opération Active Endeavour</td><td>2001-2016</td><td>Antiterrorisme en Méditerranée</td></tr>
<tr><td>Lutte contre la piraterie</td><td>2008-2016</td><td>Opération maritime</td></tr>
<tr><td>Aide à l'Irak (formation)</td><td>2004-2011</td><td>Formation des forces irakiennes</td></tr>
<tr><td>Secours après le séisme au Pakistan</td><td>2005-2006</td><td>Aide humanitaire</td></tr>
<tr><td>Opérations de soutien à la paix en Macédoine du Nord</td><td>2001-2003</td><td>Stabilisation</td></tr>
</table>
<p>Pendant toute la guerre froide, l'OTAN n'a mené aucune opération, de l'article 5 ou autre : sa fonction était de dissuader le pacte de Varsovie.</p>$$,
 array['ops','ops_list','crisis']);

select pg_temp.e('Actions et compétences','act-part',81,'Le soutien à l''Ukraine',
$$<ul>
<li><strong>Cadre :</strong> l'Ukraine n'est pas membre ; elle est partenaire, avec un Conseil OTAN-Ukraine (qui a remplacé en 2023 la Commission OTAN-Ukraine, dont l'existence remontait à 1997).</li>
<li><strong>Depuis 2014 :</strong> l'OTAN dit avoir aidé à former et équiper des dizaines de milliers de soldats ukrainiens. Depuis l'invasion de 2022, les Alliés, à titre national, fournissent l'aide militaire. L'OTAN estime que les Alliés ont fourni 99 % de l'aide militaire reçue par l'Ukraine (chiffre cité par l'OTAN au sommet de La Haye) et ont engagé plus de 35 milliards d'euros d'aide supplémentaire en 2025.</li>
<li><strong>Madrid 2022 :</strong> renforcement du « paquet d'assistance complet » (équipements non létaux, cyberdéfense, modernisation du secteur de défense).</li>
<li><strong>La Haye 2025 :</strong> les Alliés comptent désormais les contributions directes à la défense de l'Ukraine et à son industrie de défense dans leurs dépenses de défense.</li>
<li><strong>Position sur la paix :</strong> l'OTAN soutient une paix « juste et durable » et refuse de reconnaître l'annexion de la Crimée et de quatre régions annexées en septembre 2022.</li>
</ul>
<p>Ces chiffres sont ceux de l'OTAN elle-même ; ils n'ont pas été recoupés avec une source indépendante.</p>$$,
 array['ukraine','hague_over','hague_decl','madrid']);

select pg_temp.e('Actions et compétences','act-part',82,'Résilience, cyber, espace et menaces hybrides',
$$<ul>
<li><strong>Résilience :</strong> le Concept stratégique la définit comme une responsabilité nationale et un engagement collectif, enraciné dans l'article 3 : protéger les infrastructures critiques, les chaînes d'approvisionnement, les systèmes de santé et l'énergie, et assurer la continuité du gouvernement.</li>
<li><strong>Cyber et espace :</strong> l'OTAN veut garantir l'accès au cyberespace et à l'espace et défendre ses réseaux ; la transformation numérique de la structure de commandement est annoncée.</li>
<li><strong>Menaces hybrides :</strong> coercition politique, économique, énergétique ou informationnelle par des États ou des acteurs non étatiques. Leur niveau peut, dans certains cas, justifier l'article 5 (voir plus haut).</li>
<li><strong>5 % du PIB :</strong> la déclaration de La Haye affecte jusqu'à 1,5 point de PIB à ce type de dépenses (protection des infrastructures, réseaux, préparation civile, innovation, base industrielle de défense).</li>
<li><strong>Industrie :</strong> plan d'action pour la production de défense, approuvé au sommet de 2025.</li>
</ul>$$,
 array['strat_pdf','hague_decl','mar']);
