# Base de données (Supabase)

L'appli utilise un projet **Supabase** (PostgreSQL + authentification + stockage de fichiers).
L'adresse du projet et la clé « anon » sont dans `.env.production` (voir plus bas pourquoi
c'est acceptable de les commiter). **Aucune migration ne s'applique automatiquement** :
chaque fichier `supabase/schema_vN.sql` est collé et exécuté **à la main par Martin** dans
Supabase → SQL Editor.

## ⚠️ Le dépôt ne permet pas, à ce jour, de reconstruire la base à l'identique

Numéros de migration **absents du dépôt** : **v13, v14, v15, v16, v17, v18, v21, v22, v23, v25**.

Conséquences concrètes :

- Si le projet Supabase était perdu, rejouer les fichiers présents **ne redonnerait pas** la
  base actuelle.
- `schema_v28.sql` dit que l'appli est en régime « administrateur seul » **depuis schema_v13**,
  qui n'existe pas ici. Le régime réel des droits d'écriture ne peut donc pas être vérifié
  depuis le dépôt (voir « Droits d'accès »).

**Action recommandée (à faire une fois, par Martin, ~10 minutes)** : exporter le schéma réel
depuis Supabase (Dashboard → Database → export du schéma, ou `supabase db dump --schema public`)
et le déposer dans `supabase/schema_actuel.sql`, avec la date d'export en première ligne.
Ce fichier devient la référence de l'état réel ; les `schema_vN.sql` restent l'historique.
**Faire aussi une sauvegarde des données** (export CSV/SQL) avant tout gros chantier.

## Tables (d'après les fichiers du dépôt)

| Domaine | Tables |
|---|---|
| Utilisateurs | `profiles` (champ `role`, valeur `admin` pour les administrateurs) |
| Pays | `countries`, `country_leaders` (dirigeants multiples), `country_links` (liens entre pays/groupes) |
| Dossiers | `dossier_categories`, `dossier_sections` (sous-catégories imbriquables, portent aussi les périodes de frise), `dossier_entries` (fiches : texte, photo, lien, hémicycle, généalogie, frise) |
| Groupes | `groups`, `group_members`, `group_categories` |
| Indicateurs | `indicator_categories`, `indicators`, `indicator_values` (chargées par `data_owid_load.sql` ; **l'affichage utilise les JSON statiques**, pas ces tables) |
| Carte | `map_features` (ports, détroits, bases, câbles, pipelines, points d'intérêt), `historical_territory_links` |
| Généalogie | `genealogy_members`, `genealogy_relations`, `genealogy_member_statuses` |
| Frises | `timeline_events`, `timeline_event_fiches`, `timeline_placements`, `timeline_categories` ; `timeline_items` = **ancien prototype, abandonné, volontairement non supprimé** |
| Réglages | `app_settings` |
| Fichiers | bucket de stockage public en lecture : `dossier-photos` |

Fonction clé : `public.is_admin()` (définie en v1) — vrai si l'utilisateur connecté a le rôle
`admin` dans `profiles`. Les règles de sécurité au niveau des lignes (RLS) l'utilisent.

## Droits d'accès — à clarifier

- Lecture : publique (policies `select` publiques).
- Écriture : l'historique est contradictoire dans le dépôt. v1 : admin ; v4/v8 (2026-10-01) :
  tout compte connecté ; puis « admin seul depuis v13 » (fichier absent) ; v28 remet les frises
  en admin seul. Côté navigateur, `isAdmin()` (dans `src/dossier.ts`) exige `role = 'admin'` et
  que le mode lecture soit désactivé.
- **Le navigateur n'est PAS une protection** : la vraie barrière, ce sont les policies RLS en
  base. **À vérifier une fois dans Supabase** (Authentication → Policies) que les tables
  d'édition (dossiers, groupes, liens, généalogie, frises, `map_features`, stockage) n'autorisent
  bien l'écriture qu'aux administrateurs, si c'est le régime voulu.
- Cas à part : les politiques de stockage v4 limitent la modification/suppression d'une photo à
  son propriétaire (`owner = auth.uid()`) ; l'envoi est ouvert à tout compte connecté.

## Clé « anon » commitée : pourquoi c'est acceptable (et ses limites)

`VITE_SUPABASE_ANON_KEY` est une clé **publique par conception** : elle finit de toute façon
dans le JavaScript envoyé à chaque visiteur. Sa sécurité repose **entièrement sur les policies
RLS**. Règles :

- Ne **jamais** commiter une clé `service_role` / `sb_secret_…` (`npm run check:repo` bloque ça).
- Toute nouvelle table : activer la RLS et écrire les policies **dans la même migration**.

## Écrire une nouvelle migration

1. Nom = `supabase/<chantier>/<chantier>_vN.sql` (chantiers : arbres, frises, carte, historique, groupes, dossiers, indicateurs ;
   voir `docs/CHANTIERS.md`), **N = plus grand numéro de ce chantier + 1** (arbres continue à **arbres_v61** ; les autres
   commencent à v1). Les fichiers `schema_v1…v60` ci-dessous gardent leur nom. Jamais deux fichiers avec le même nom.
2. En-tête : date, raison (la demande de Martin), ce que le script ajoute/modifie.
3. **Idempotente** (`if not exists`, `drop policy if exists`…) et **sans suppression de
   données**, sauf accord explicite de Martin.
4. Ne **jamais modifier** une migration déjà exécutée : écrire une migration corrective
   (comme v28, v34, v35).
5. Dire clairement à Martin « ce fichier est à exécuter dans le SQL Editor » : tant que ce
   n'est pas fait, le code qui en dépend ne fonctionne pas en production.
6. Ajouter une ligne ci-dessous.

## Historique des migrations présentes

| Fichier | Contenu |
|---|---|
| v1 | Schéma initial (profils, `is_admin`, pays, dossiers…) |
| v2 | Compléments (dont `map_features`) |
| v3 | Dossiers pour ports / détroits / bases / câbles / pipelines |
| v4 | Fiche pays + système de dossier complet ; bucket `dossier-photos` |
| v5 | Hémicycles, groupes, indicateurs OWID, encyclopédie |
| v6 | Panneau Apparence (couleurs) |
| v7 | Liens entre pays/groupes |
| v8 | Édition ouverte à tout compte connecté (2026-10-01) |
| v9 | Points d'intérêt (`kind='poi'`, colonne `note`) |
| v10 | Image + cadrage sur catégories et sous-catégories |
| v11 | Arbres généalogiques (dynasties) |
| v12 | Dirigeants multiples par pays |
| v19 | Frises — **ancien prototype, abandonné** |
| v20 | Correspondance territoire historique → fiche actuelle (clé = nom OpenHistoricalMap ; **non utilisée** par la carte historique actuelle, voir `chantiers/historique.md`) |
| v24 | Statuts cumulés autour d'un membre (anneaux concentriques) |
| v26 | Subdivisions administratives par pays |
| v27 | Frises — nouveau modèle |
| v28 | Frises — écriture réservée aux administrateurs |
| v29 | Frises — couleurs des périodes, transitions cliquables, points colorés |
| v30 | Frises — hauteur réglée à la main d'un point (tige) |
| v31 | Frises — catégories de points, durée, sous-frise |
| v32 | Arbre généalogique « Luxembourg » (données) |
| v33 | Arbres « Wettin » et « Hohenzollern » (données) |
| v34 | Correctif de v33 |
| v35 | Correctif : ascendants d'Élisabeth de Misnie |
| v36 | Membres d'un autre arbre « épinglés » (`pinned`) |
| v37 | Masquer un membre étranger dans un arbre (`hidden`) sans supprimer ses liens |
| v38 | Données : branche ernestine des Wettin (29 membres, épouses créées dans Wittelsbach / Welf / Glücksbourg) — à exécuter une seule fois |
| v39 | Données : Pologne — arbres Piast, Anjou-Hongrie, Báthory, Leszczyński, Poniatowski (créés) + Jagellon, Vasa, Wiśniowiecki, Sobieski (complétés) ; épouses créées dans Přemyslides / Habsbourg / Saliens / Wittelsbach / Stuart — à exécuter une seule fois, après v38 |
| v40 | Données : Tchéquie — Přemyslides complétés (épouses, frères, fils), arbres « Jagellon » (Bohême-Hongrie) et « Poděbrady » créés — à exécuter après v39 |
| v41 | Données : Hongrie — arbres Árpád, Anjou-Hongrie, Hunyadi, Zápolya (créés) ; épouses créées dans Ottoniens / Capétiens / Barcelone / Habsbourg / Luxembourg / Piast / Wittelsbach ; Adélaïde et Constance de Hongrie, sainte Kinga et Barbara Zápolya rattachées à leur vrai arbre — à exécuter après v40 |
| v42 | Données : Autriche — arbres Babenberg et Habsbourg-Lorraine (créés) ; Hélène de Hongrie (Árpád), Henri (VII) (Hohenstaufen), épouses bavaroises, siciliennes, parmesanes, belge et saxonne créées dans leur arbre ; Agnès de Babenberg, Gertrude, Marguerite et Agnès d'Autriche rattachées à Babenberg — à exécuter après v41 |
| v43 | Données : Russie — arbres Riourikides, Godounov, Romanov (créés) ; épouses créées dans Hohenzollern / Glücksbourg / Welf ; femmes riourikides déplacées depuis Árpád / Piast / Jagellon / Saliens ; Marie-Louise d'Autriche déplacée de Bonaparte vers Habsbourg-Lorraine ; lien avec Maria Alexandrovna (v38) — à exécuter après v41 et v42 |
| v44 | Données : Roumanie — arbres Basarab, Mușat, Hohenzollern-Sigmaringen (créés) ; branche de Sigmaringen dans l'arbre Hohenzollern ; Anne de Bourbon-Parme dans Bourbon-Parme ; liens vers Alfred et Maria Alexandrovna (v38) — à exécuter après v43 |
| v45 | Données : Grèce — arbres Wittelsbach (Othon Ier) et Glücksbourg (Georges Ier → Constantin II) ; épouses créées dans Wettin / Romanov / Hohenzollern / Welf ; Christian X, Frédéric IX, Ingrid et Anne-Marie ajoutés à Glücksbourg (Danemark) ; Hélène de Grèce rattachée — à exécuter après v44 |
| v46 | Données : Bulgarie — arbres Krum, Asen, Chichman, Saxe-Cobourg-Gotha (créés) ; Basarab Ier et Nicolas Alexandre ajoutés à Basarab (Roumanie) ; Anne-Marie de Hongrie (Árpád), Marie-Louise de Bourbon-Parme, Clémentine d'Orléans et ascendants Saxe-Cobourg-Koháry créés dans leur arbre ; dates des premiers khans laissées vides — à exécuter après v45 |
| v47 | Données : Serbie — arbres Nemanjić, Lazarević, Branković, Obrenović, Karađorđević (créés, Yougoslavie incluse) ; Dragana et Jelena Branković rattachées à leur arbre ; Catherine de Hongrie (Árpád), Hélène de Bulgarie (Chichman), Anne de Valachie (Basarab), Alexandra/Olga/Nicolas de Grèce (Glücksbourg) créées dans leur arbre ; Zorka du Monténégro provisoirement signalée — à exécuter après v46 |
| v48 | Données : Monténégro — arbre Petrović-Njegoš (créé) ; Zorka déplacée depuis Karađorđević ; Nicolas Nikolaïevitch l'Ancien et ses fils créés dans Romanov ; Victor-Emmanuel III relié à Jeanne de Savoie — à exécuter après v47 |
| v49 | Données : Bosnie — arbre Kotromanić (créé) ; Élisabeth de Bosnie déplacée depuis Anjou-Hongrie ; Élisabeth de Serbie (Nemanjić), Dorothée de Bulgarie (Chichman), Hélène Branković (Branković), Élisabeth de Gniewkowo (Piast) créées — à exécuter après v48 |
| v50 | Données : Albanie — arbres Kastrioti, Wied, Zogu (créés) ; Jerina Branković créée dans Branković — à exécuter après v49 |
| v51 | Données : Chypre — arbre Lusignan (créé, de Guy de Lusignan à Jacques III) — à exécuter après v50 |
| v52 | Données : Luxembourg — arbre Nassau-Weilburg (grands-ducs, Guillaume de Nassau → Guillaume V) ; Louise de Saxe-Hildburghausen (Wettin), Élisabeth Mikhaïlovna et Michel Pavlovitch (Romanov), Félix et Maria Antonia (Bourbon-Parme), Joséphine-Charlotte (Couronne belge) créées — à exécuter après v51 |
| v53 | Données : Monaco — arbre Grimaldi (Honoré II → Albert II et ses enfants) — à exécuter après v52 |
| v54 | Données : Liechtenstein — arbre Liechtenstein (Karl Ier → Hans-Adam II → Alois et ses enfants) ; Sophie en Bavière créée dans Wittelsbach, Margaretha de Luxembourg reliée — à exécuter après v53 |
| v55 | Données : Ukraine — arbre Riourikides de Galicie-Volhynie (Mstislav II → Iouri II Boleslas) ; Agnès de Pologne, Euphémie, Siemovit, Trojden (Piast), Constance et Marie Laskarina (Árpád), André Iaroslavitch (Riourikides) créés — à exécuter après v54 |
| v56 | Données : Chine (1/…) — arbres Zhou (roi Wen → roi Nan) et Qin (Huiwen → Ziying) ; années avant J.-C. en valeurs négatives — à exécuter après v55 |
| v57 | Données : Chine (2/…) — arbres Han (Gaozu → Xian, avec impératrices) et Xin (Wang Mang) ; années avant J.-C. en négatif — à exécuter après v56 |
| v58 | Données : Chine (3/…) — arbres Cao Wei, Shu Han et Wu oriental (Trois Royaumes) ; Cao Jie reliée à Xian (Han), dame Sun reliée à Liu Bei — à exécuter après v57 |
| v59 | Données : Chine (4/…) — arbre Jin (Sima Yi → Gong de Jin, 57 membres) — à exécuter après v58 |
| v60 | Photos : 209 portraits Wikipédia/Wikimedia ajoutés aux membres sans photo (ne remplace jamais une photo existante) — à exécuter après v59 |
| arbres_v61 | Wittelsbach : branches palatine, Simmern, Deux-Ponts, Neubourg, Sulzbach, Landshut, rois de Bavière (+102 membres, relie les 9 isolés) |
| arbres_v62 | Wettin : Saxe-Weimar, Saxe-Gotha-Altenbourg, Saxe-Altenbourg, descendants de Frédéric-Auguste III, liens polonais/britanniques/belges rangés (+44 membres) ; corrige les parents de Madeleine-Catherine de Deux-Ponts |
| arbres_v63 | Hohenzollern : Kulmbach, Bayreuth, famille de Marie de Prusse, descendants de Guillaume II jusqu'à Georges-Frédéric (+20 membres) |
| arbres_v64 | Welf : chaîne continue d'Albert le Grand à Ernest-Auguste de Hanovre, Calenberg, Dannenberg, Wolfenbüttel-Bevern, maison de Hanovre jusqu'au chef actuel (+54 membres) |
| arbres_v65 | Habsbourg : branche de Toscane (Ferdinand III, Léopold II, Ferdinand IV), liens Wittelsbach, dates manquantes (+9 membres, 2 membres isolés reliés) |
| arbres_v66 | arbres_v66 | Petites dynasties allemandes : 13 membres (enfants de Barberousse, Conradin, Manfred, Liudolf, Conrad II d'Italie) |
| arbres_v67 | Luxembourg et Carolingiens : 12 membres (Henri V, enfants de Charles IV, Zwentibold…) |
| arbres_v68 | Maison de Savoie : arbre créé, 84 membres (comtes, ducs, rois de Sardaigne et d'Italie jusqu'à Emmanuel-Philibert) |
| arbres_v69 | Bourbon-Siciles et Parme complétés : 48 membres (enfants de Ferdinand Ier, François Ier, Ferdinand II ; Parme de Louis d'Étrurie à Élie) |
| arbres_v70 | Orange-Nassau complété : 69 membres (Guillaume le Taciturne → princesse Amalia) |
| arbres_v71 | Couronne belge complétée : 25 membres (enfants de Léopold Ier, Léopold II, Philippe de Flandre, Léopold III, Albert II, Philippe) |
| arbres_v72 | Vasa (Suède) : 27 membres (Gustave Ier, Éric XIV, Charles IX, Gustave II Adolphe, Christine, liens avec Charles X-XII) |
| arbres_v73 | Suède : Holstein-Gottorp (16) et Bernadotte (35) créés, 60 membres au total ; correction de l'arbre en double de v72 |
| arbres_v74 | Danemark : 48 membres (Oldenbourg de Frédéric IV à Frédéric VII ; Glücksbourg de Christian IX à Frédéric X) |
| arbres_v75 | Rois de Norvège : 60 membres (Harald à la Belle Chevelure → Ingrid Alexandra) |
| arbres_v76 | arbres_v76 : Suède médiévale (nouvel arbre, 80 membres) |
| arbres_v77 | arbres_v77 : Bourbons de France et Orléans (51 membres) |
| arbres_v78 | arbres_v78 : Bonaparte (18 membres) |
| arbres_v79 | arbres_v79 : Médicis (nouvel arbre, 45 membres) |
| arbres_v80 | arbres_v80 : Visconti et Sforza (2 nouveaux arbres, 28 membres) |
| arbres_v81 | arbres_v81 : Ottomans (nouvel arbre, 40 membres) |
| arbres_v82 | arbres_v82 : Sui et Tang (2 nouveaux arbres, 27 membres) |
| arbres_v86 | arbres_v83 à v86 : Song (19), Gengiskhanides/Yuan (26), Ming (20), Qing (16) |
| arbres_v87 | arbres_v87 : Empereurs du Japon (nouvel arbre, 124 membres) |
| arbres_v88 | arbres_v88 : shoguns Minamoto, Ashikaga, Oda/Toyotomi, Tokugawa (4 nouveaux arbres, 33 membres) |
| arbres_v89 | arbres_v89 : Corée, dynastie Joseon (nouvel arbre, 34 membres) |
| arbres_v90 | arbres_v90 : compléments Plantagenêts, Lancastre, York, Tudor (23 membres) |
| arbres_v91 | arbres_v91 : Empire byzantin (nouvel arbre, 48 membres) |
| arbres_v92 | arbres_v92 : Écosse, Dunkeld, Balliol, Bruce (35 membres, 2 nouveaux arbres) |
| arbres_v93 | arbres_v93 : Danemark médiéval (25 membres) + correctif de dates v92 |
| arbres_v94 | arbres_v94 : Hauteville (nouvel arbre, 23 membres) |
| arbres_v95 | arbres_v95 : Este, Gonzague, Farnèse (3 nouveaux arbres, 40 membres) |
| arbres_v96 | arbres_v96 : Gediminides, Lituanie (nouvel arbre, 9 membres) |
| arbres_v97 | v97 : Corée, dynastie Goryeo (37 membres, nouvel arbre KR_GOR) |
| arbres_v98 | v98 : Portugal, maison de Bourgogne (23 membres, nouvel arbre PT_BOU) + Pierre de Coimbra et Henri le Navigateur dans Aviz |
| arbres_v99 | v99 : Portugal, maison de Bragance de Pierre III à Manuel II + Brésil impérial (21 membres) |
| arbres_v100 | v100 : Espagne, compléments Habsbourg et Bourbon d'Espagne (13 membres) |
| arbres_v101 | v101 : Navarre, nouvel arbre du royaume (34 membres) |
| arbres_v102 | v102 : Naples, Anjou-Naples et Aragon-Naples (27 membres, 2 nouveaux arbres) |
| arbres_v103 | v103 : Bulgarie, suite des souverains (18 membres, nouvel arbre Terter) |
| arbres_v104 | v104 : Iran, Achéménides, Sassanides, Safavides, Qajars, Pahlavi (49 membres, 5 nouveaux arbres) |
| arbres_v105 | v105 : Égypte — arbres Ptolémées (22) et Dynastie de Méhémet-Ali (15), Fawzia reliée à Fouad Ier |
| arbres_v106 | v106 : Hachémites (Jordanie, Irak) et Al Saoud (31 membres) |
| arbres_v107 | v107 : Alaouites (Maroc), Senoussi (Libye), dynastie salomonide (Éthiopie), 29 membres |
| arbres_v108 | v108 : Moghols, Chakri, Nguyen, Durrani/Barakzaï (50 membres) |
| arbres_v109 | v109 : Bagrationi (Géorgie), Arménie, Hasmonéens et Hérodiens (Israël), 40 membres |
| arbres_v110 | v110 : sources et corrections de dates (Égypte, Fawzia) ; champ Notes rempli |
| `data_owid_load.sql` + `owid_chunks/` | Chargement des données d'indicateurs (rejouable, upserts) — à exécuter après v1 à v7 |
