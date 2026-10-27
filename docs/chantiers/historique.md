# Chantier « historique » (carte historique) — journal

## Dernières nouvelles (la plus récente en haut)
- 2026-10-24 (après-midi) — **Contours calés sur la côte réelle + dates historiques exactes** (demande de Martin ; l'original reste récupérable par `git revert` ou régénération sans options). Côtes : on retire des contours ce qui est en mer (Natural Earth 1:10 m ; micro-États gardés) — `caler_cotes.py`. Dates : 420 débuts/fins d'entités avancés à leur date réelle sourcée (Wikidata CC0 + 6 événements majeurs : Verdun 843, Hugues Capet 987, Song du Sud 1127, Tang/Liang 907, Yuan 1368, Osman 1299), 86 refusées par garde-fou (trou ou hors fenêtre), dont Bagdad 1258 — `corrections_dates.py`, rapport `corrections_dates_rapport.json`. Données ≈ 22 Mo (avant 13). Vérifié : régénération complète, `verifier_donnees.py`, tests du modèle (dont Verdun 842/843), comparaisons avant/après sur images (Europe 842-843-1000, France 1500, Scandinavie 1650), `check:repo`, `build`. Non vérifié : site déployé, relecture historique des 420 corrections (méthode automatique, fenêtre ≤ intervalle entre deux instantanés), rendu sur le fond Esri à fort zoom. Sources : `docs/sources/historique.md`.
- 2026-10-24 — **Audit des frontières (lecture seule, aucune donnée modifiée)** : rapport `docs/chantiers/historique_audit_2026-10-24.md` (chevauchements, noms en retard, identifiants Wikidata partagés, superficies, comparaison Historical Basemaps / Natural Earth) + scripts `scripts/historique/audit/`. Vérifié : mesures reproductibles. Non vérifié : relecture historique cas par cas, suivi GitHub de Cliopatria. En attente des consignes de Martin.
- 2026-10-23 (soir) — **Noms français sur la carte historique** (infobulles, étiquettes, fiche, ensembles) : 1 554 noms, dont 1 210 libellés Wikidata filtrés et **344 traductions proposées par Claude à relire** (listées dans `scripts/historique/traductions_fr.json` ; la fiche l'indique). Vérifié : tests, `check:repo`, `build`, essai navigateur (étiquettes + fiche en français). Non vérifié : relecture historique des 344 traductions, site déployé. Aucune migration.
  Prochaine étape : relecture des traductions par Martin, puis couche « suzeraineté » (Saint-Empire en un bloc).
- 2026-10-23 — **Nouvelle carte historique livrée (Cliopatria, année par année, monde entier)** : remplace historical-basemaps. Données allégées dans `public/data/historique/` (13 Mo), outils dans `scripts/historique/`, crédit CC BY dans la page. Retour arrière possible : commit `a3776d7` (l'étiquette Git n'a pas pu être poussée).
  Prochaine étape : valider avec Martin l'aspect sur le site déployé (fonds de carte Esri), puis choisir entre : couche « suzeraineté » (lignes RELATION), noms français via Wikidata, ou lien territoires ↔ fiches / dirigeants des arbres (migration `historique_v1`).
- 2026-10-23 — étude des sources de données pour la carte historique (voir « Sources étudiées » ci-dessous) ; aucun code touché.
  Prochaine étape : télécharger et inspecter Cliopatria (champs, licence du fichier, liens avec les dynasties) puis décider avec Martin.
- 2026-10-23 — chantier créé (séparé de « carte » à la demande de Martin) ; journal créé ; aucun code touché. Prochaine étape : état des lieux de la carte historique actuelle et recueil de ce que Martin veut construire.

## État de départ (lu dans le code, non encore testé en ligne)
- `src/historicalMap.ts` (310 lignes) : page plein écran avec sa propre carte Leaflet, données « historical-basemaps »
  (GPL-3.0), **54 années fixes** de -123000 à 2010 (pas de curseur continu), GeoJSON chargés à la volée depuis
  raw.githubusercontent.com (« version test » validée par Martin le 2026-10-06), fond physique Esri sans frontières modernes.
- Table `schema_v20.sql` : correspondance territoire historique → fiche, conçue pour l'ancienne source OpenHistoricalMap ;
  usage actuel à vérifier.
- Prochaine migration de ce chantier : **historique_v1** (`supabase/historique/historique_v1.sql`).

## Sources étudiées (2026-10-23, lecture de pages web ; fichiers de données NON encore téléchargés ni inspectés)
Objectif de Martin : carte historique la plus fiable possible **et** interactive (voir à la tête de quel empire était un
dirigeant des arbres généalogiques, ce que cela représente sur la carte).

| Source | Ce qui est établi | Limites |
|---|---|---|
| historical-basemaps (aourednik, GPL-3.0) | Un GeoJSON par année fixe (54 dans notre version), champs NAME / SUBJECTO / PARTOF / BORDERPRECISION (1 approximatif → 3 fixé par le droit international), fond mondial. Les auteurs disent eux-mêmes : travail en cours, précision adaptée à l'échelle mondiale/continentale, à recouper avant usage académique ; sources par polygone non détaillées. | Pas d'identifiant d'entité stable ni de dates de début/fin par entité : relier à un dirigeant ou à une dynastie se ferait par le nom, à la main. Licence GPL-3.0 à examiner si les données sont copiées dans le dépôt. |
| Cliopatria (Seshat, Bennett et al., *Scientific Data* 2025) | Plus de 1 600–1 800 entités politiques, monde entier, 3400 av. J.-C. → 2024, GeoJSON, relecture par experts (procédure Seshat), publié sur Zenodo en CC BY 4.0 (v0.0.1, 49,2 Mo ; une version plus récente existe). Entités avec dates ; certaines liées aux pages Seshat (dirigeants, événements). | Champs exacts, qualité réelle et liens vers Wikipedia/Wikidata **non vérifiés** (pages GitHub et PMC non lues). Les auteurs reconnaissent des inexactitudes possibles. Pas de pas de temps régulier. |
| OpenHistoricalMap | Base communautaire avec vraie continuité par date ; statistiques de couverture publiques. | Jugée « incomplète niveau frontière » par Martin le 2026-10-06 ; couverture réelle non chiffrée dans ce qui a été lu. |
| Euratlas | Très précis. | Europe seulement, payant (160 € par siècle) — écarté le 2026-10-06. |

Pas étudiés pour l'instant : CShapes (frontières 1886–aujourd'hui), GeaCron (propriétaire), Chronas, Wikidata (liens dirigeants ↔ États).

## Livraison du 2026-10-23 : carte historique Cliopatria

**Ce qui existe maintenant**
- Page « Vue historique » : curseur de -3400 à 2024 (année par année), saisie directe de l'année (négatif = avant J.-C.), boutons ±1 / ±10 / ±100,
  lecture automatique (1 à 100 ans par seconde), zones prédéfinies (Monde, Europe, Méditerranée et Proche-Orient, Afrique, Asie, Amériques).
- Survol : nom du territoire et de son ensemble ; l'ensemble entier (ex. Empire espagnol) se surligne. Clic : fiche (période de validité du
  tracé, superficie, liens Wikipédia et Wikidata). Noms des territoires assez grands posés sur la carte, sans chevauchement.
- Couleur = par ensemble (champ `MemberOf` de la source, ex. « Holy Roman Empire »), sinon par entité ; stable à toutes les époques.
- Chargement à la demande : index (0,49 Mo, 0,14 Mo compressé) + morceaux de ~0,45 Mo ; toutes les données = 13 Mo (3,6 Mo compressés).

**Vérifié** (build de production servi en local, vrai navigateur Chromium, sans accès aux fonds de carte Esri) : `check:repo` et `build` passent ;
`scripts/historique/tester-modele.mjs` (logique pure sur les vraies données : 5 425 années toutes non vides, cas Han/Rome/Mongols/Ming/Ottomans/
Qing/Allemagne 1914 présents au bon moment, décodage des 10 018 tracés) ; `verifier_donnees.py` (0 polygone invalide ; recouvrement moyen 99 % avec
les contours d'origine sur 1 500 lignes, le plus faible ≈ 85 % sur de minuscules territoires) ; ouverture/fermeture, survol, clic, fiche, boutons,
clavier, bornes (999999 → 2024, -99999 → -3400, champ vide ignoré), lecture/pause, 100 ans/s sans blocage, affichage mobile 390 px, aucune erreur JS
(hors ressources externes inaccessibles). Rapidité : 20–400 ms par année, 42 Mo de mémoire JS.

**Non vérifié**
- L'apparence avec le vrai fond de carte physique Esri (inaccessible depuis l'environnement de travail ; l'adresse des tuiles est inchangée).
- Le site déployé sur GitHub Pages (onglet Actions à contrôler après le push).
- La précision historique des tracés : on reprend la source telle quelle (voir `public/data/historique/SOURCE.md`), aucun contrôle par un historien.

**Limites connues, à dire à Martin**
- Un tracé vaut pour une **période** (médiane 8 ans, de 1 à plus de 900 ans) : la carte ne change que quand une entité change de tracé.
- Cliopatria ne couvre que les **entités politiques** : les régions sans État cartographié restent vides (ex. Amérique du Nord avant la colonisation).
- Le Saint-Empire n'apparaît pas comme un seul bloc : seul le sous-ensemble « Holy Roman Empire Minor States » est son membre dans la source ;
  la suzeraineté sur les électorats, duchés, etc. est codée dans des lignes de type RELATION (alliance, vassalité, union personnelle), écartées pour l'instant.
- Noms en anglais (ceux de la source). Les identifiants Wikidata permettront d'obtenir des noms français.
- Année 0 : présente dans la source (45 lignes la contiennent), affichée telle quelle ; convention exacte pour les années avant J.-C. non précisée par la source.
- Les couleurs sont tirées d'un code de hachage du nom : deux voisins peuvent parfois avoir des teintes proches.
- Tracés simplifiés : au zoom maximal (8), les contours sont visiblement moins fins que la réalité (précision ≈ 1 km).

**Autres constats**
- La table de la migration `schema_v20` (correspondance territoire → fiche, clé = nom OpenHistoricalMap) n'est lue par aucun code actuel ; elle sera
  remplacée par une table clé = identifiant Wikidata quand on branchera territoires ↔ fiches (`historique_v1`, pas encore écrite).
- `leaflet.vectorgrid` (package.json) et `src/leaflet-vectorgrid.d.ts` ne servaient plus à rien avant ce chantier (reste de la v1 OpenHistoricalMap) : à
  retirer par un commit dédié (fichiers partagés, non touchés ici).
- Le dépôt n'accepte pas l'envoi d'étiquettes Git depuis l'environnement de travail (retour arrière = commit `a3776d7`).

## Pistes pour la suite (rien n'est décidé, à voir avec Martin)
1. **Lien territoires ↔ dossiers** : table `historique_v1` (identifiant Wikidata ↔ entrée de dossier), clic « ouvrir la fiche » dans la vue historique.
2. **Dirigeants des arbres ↔ carte** : table « membre ↔ entité, de telle année à telle année » (sourcée, saisie ou pré-remplie à relire), bouton « voir sur la
   carte » depuis un membre d'arbre, liste des dirigeants depuis un territoire.
3. **Couche suzeraineté** (lignes RELATION : vassalités, alliances, unions personnelles) pour montrer les empires qui dépassent leurs membres directs.
4. **Noms français** via Wikidata (identifiants déjà dans les données).
5. Fond de carte et habillage à revoir avec le fond Esri réel.

## Journal — 2026-10-27 : registre des dates
- Dates Wikidata brutes versionnées, générateur de registre ajouté, `corrections_dates_wikidata.txt` régénéré (599 lignes retenues, dont environ 500 appliquées après garde-fous).
- Données de la carte régénérées (livrées au commit suivant) : 503 corrections de dates appliquées, 109 refusées par les garde-fous ; 12 064 lignes, 22,5 Mo. Tests du modèle OK.
- Reste : 1 179 divergences à arbitrer, changements de forme internes à sourcer un par un.

## Journal — 2026-10-28 : dates plus nombreuses
- Fenêtre de dates assouplie (`SOUPLESSE = 2` dans `corrections_dates.py`), règle des identifiants Wikidata partagés, Wikipédia (infobox) en secours : environ 600 dates de naissance/disparition appliquées (503 la veille).
- Données de la carte régénérées : 602 corrections appliquées, 108 refusées par les garde-fous ; tests du modèle OK.
- Reste : environ 940 divergences (autre entité probable), environ 900 territoires sans date sourcée, changements de forme internes.
- Fiche d'une zone : nouvelle ligne « Existe sur la carte : depuis 1963 (…) » (période de l'entité entière, `periodeEntite` / `formatExistence`) ; l'ancienne ligne devient « Ce contour (cette forme) vaut pour : … » pour ne plus être lue comme une date d'indépendance (cas de l'Algérie, « 2024 » = dernier relevé de forme).

## Journal — 2026-10-28 (suite) : carte à partir de -700, Algérie et recouvrements
- **Début de la carte à -700** (demande de Martin) : curseur de -700 à 2024 (`ANNEE_MIN`), `preparer_cliopatria.py --debut -700` écarte 155 lignes plus anciennes (données régénérées au commit suivant ; en attendant, le curseur seul est limité). **Sauvegarde des données complètes (-3400 à 2024)** : branche GitHub `sauvegarde-historique-donnees-completes` (commit 786c201) ; pour tout remettre : `--debut -3400` (défaut) et `ANNEE_MIN = -3400`.
- **Algérie recouverte par la France (capture de Martin)** : la Ve République avait un contour 1961-2023 de 3,03 M km² contenant l'Algérie (2,32 M km²) ; celui de 2024 (0,68 M km²) est juste. Nouveau module `corrections_formes.py` + règles sourcées `corrections_formes_manuelles.json` : on RETIRE du contour de l'ancien maître la zone de l'État indépendant, seulement pendant les années où les deux existent. 6 règles : Algérie/France, Afrique orientale britannique (Kenya, Ouganda, Zambie, Malawi, Botswana, Lesotho, Rhodésie), Empire colonial britannique (Guyana, Salomon), Royaume-Uni (Oman, Émirats), Antilles néerlandaises (Suriname), Gold Coast (Ghana). Rapport : `corrections_formes_rapport.json`.
- Audit complet des chevauchements (2026-10-28, hors dépôt) : 72 paires récentes ; les autres sont des conventions (zones d'occupation, unions, revendications) et ne sont pas touchées sans décision de Martin.
