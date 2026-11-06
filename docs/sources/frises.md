# Sources — chantier frises chronologiques

Format : voir `README.md`. Consultation : 2026-11-01 (les pages Wikipédia peuvent changer).
Ce fichier couvre l'**exemple « Histoire de France »** (`supabase/frises/frises_v1.sql`). Chaque fiche créée par
ce script porte aussi ses sources dans le champ « sources » de la fiche (titre + lien).

> **2026-11-02 — le test « Histoire de France » (frises_v1) a été supprimé** de la base par `frises_v3` à la demande de Martin
> (« c'était un test, on reprend sur des bases saines »). Les lignes de la section « Lots sourcés » ci-dessous ne décrivent donc plus
> aucune donnée en base ; elles sont gardées comme historique de recherche seulement (aucune de ces dates n'est reprise sans
> nouveau recoupement, et Wikipédia n'est pas une preuve : barème de `README.md`).

## Méthode et limites
- Les pages Wikipédia ont été lues avec un outil de lecture qui **perd certains jours/mois** (dates écrites par
  modèles). Une date n'est donc retenue que si elle est **écrite dans le texte lu**, ou recoupée par une 2e source
  (Larousse, World History Encyclopedia, VL Média). Les dates absentes des textes lus n'ont **pas** été utilisées :
  Waterloo, sacre de Napoléon, Louis XIV (avènement/mort), bataille de Castillon (jour), signature de l'édit de
  Nantes (mois), armistice de 1918, etc. Les points concernés sont à ajouter plus tard, avec leur source.
- Aucune date n'a été prise de mémoire sans source ci-dessous. Les découpages (« grandes périodes ») sont une
  convention d'étude, pas une vérité unique.

## Lots sourcés
| Date | Ce qui a été fait / touché | Source | Lien précis | Licence | Fiabilité |
|---|---|---|---|---|---|
| 2026-11-01 | Frise 1 : période « Gaule romaine » (début −58, guerre des Gaules 58-50 ; fin 486, bataille de Soissons) ; points Alésia (−52) et Soissons (486) | Wikipédia — Gaule romaine | https://fr.wikipedia.org/wiki/Gaule_romaine | CC BY-SA 4.0 | tertiaire / à recouper ; **début −58 déduit** de « Guerre des Gaules (58-50) » |
| 2026-11-01 | Frise 1 : périodes Mérovingiens (fin 751) et Carolingiens (751) ; point « Pépin le Bref enferme Childéric III » (751) | Wikipédia — Mérovingiens | https://fr.wikipedia.org/wiki/M%C3%A9rovingiens | CC BY-SA 4.0 | tertiaire / à recouper ; **Mérovingiens commencent en 486 dans la frise** (Soissons) alors que la page cite 481 (avènement de Clovis) : choix pour avoir une borne partagée |
| 2026-11-01 | Frise 1 : Carolingiens 751→987, Capétiens directs 987→1328, début des Valois (1328) ; point « Hugues Capet » (987) | Wikipédia — Capétiens directs | https://fr.wikipedia.org/wiki/Cap%C3%A9tiens_directs | CC BY-SA 4.0 | tertiaire / à recouper ; jour de l'élection absent du texte (année seule) |
| 2026-11-01 | Frise 1 : Valois / Bourbons (frontière 1589, accession d'Henri IV) | Wikipédia — Ancien Régime | https://fr.wikipedia.org/wiki/Ancien_R%C3%A9gime | CC BY-SA 4.0 | tertiaire / à recouper ; **fin des Valois = 1589 déduite** (la page donne 1589 pour le début de l'Ancien Régime) |
| 2026-11-01 | Frise 1 : Consulat 1799-1802, Empire 1804-1814, Restauration 1814-1830, monarchie de Juillet 1830-1848, IIe République 1848-1852, Second Empire 1852-1870, IIIe République 1870, Vichy 1940-1944, IVe 1946-1958, Ve 1958 | Wikipédia — Liste des régimes politiques de la France | https://fr.wikipedia.org/wiki/Liste_des_r%C3%A9gimes_politiques_de_la_France | CC BY-SA 4.0 | tertiaire / à recouper ; années seules |
| 2026-11-01 | Frise 1 : recoupement des bornes 1814, 1848, 1940, 1946, 1958 et de l'ordre des régimes | Geneawiki — Histoire de la France | https://fr.geneawiki.com/wiki/Histoire_de_la_France | licence du site : inconnue (à régler avant publication) | tertiaire ; **divergences** : Second Empire jusqu'en 1871 et IIIe République 1871 (la frise garde 1870), Capétiens « jusqu'en 1795 » (erreur manifeste, ignorée) |
| 2026-11-01 | Frise 1 : point « Couronnement impérial de Charlemagne » (25 déc. 800 = « jour de Noël de l'an 800 ») | Wikipédia — Charlemagne | https://fr.wikipedia.org/wiki/Charlemagne | CC BY-SA 4.0 | tertiaire / à recouper ; le « 25 » est déduit de « Noël » |
| 2026-11-01 | Frise 1 : point « Guerre de Cent Ans » (1337 → 1453) | Wikipédia — Guerre de Cent Ans | https://fr.wikipedia.org/wiki/Guerre_de_Cent_Ans | CC BY-SA 4.0 | tertiaire / à recouper ; années seules |
| 2026-11-01 | Frise 1 : points « Édit de Nantes » (1598) et « Révocation » (octobre 1685) | Wikipédia — Édit de Nantes | https://fr.wikipedia.org/wiki/%C3%89dit_de_Nantes | CC BY-SA 4.0 | tertiaire / à recouper ; mois de 1598 absent du texte lu, jour de 1685 absent |
| 2026-11-01 | Frise 1 : point « Première Guerre mondiale » (1914 → 1918) | Wikipédia — Première Guerre mondiale | https://fr.wikipedia.org/wiki/Premi%C3%A8re_Guerre_mondiale | CC BY-SA 4.0 | tertiaire / à recouper ; années seules |
| 2026-11-01 | Frise 1 : point « Appel du 18 juin 1940 » (18 juin 1940) | Wikipédia — Appel du 18 Juin | https://fr.wikipedia.org/wiki/Appel_du_18_Juin | CC BY-SA 4.0 | tertiaire / à recouper ; date lue dans le titre de l'article |
| 2026-11-01 | Frise 1 : point « Référendum sur la Constitution de la Ve République » (28 sept. 1958) | Wikipédia — Cinquième République (France) | https://fr.wikipedia.org/wiki/Cinqui%C3%A8me_R%C3%A9publique_(France) | CC BY-SA 4.0 | tertiaire / à recouper |
| 2026-11-01 | Frise 2 (Révolution) : bornes 5 mai 1789 (États généraux), 21 sept. 1792, 26 oct. 1795 ; fin de la Constituante 1er oct. 1791 ; début de la Législative 1er oct. 1791, fin 20 sept. 1792 ; points États généraux, Jeu de paume (20 juin 1789), 4 août, Déclaration (26 août), Varennes (20 juin 1791), Constitution 1791 (13 sept.), guerre à l'Autriche (20 avril 1792), 10 août 1792, Valmy (20 sept.), proclamation de la République (21 sept. 1792) | Wikipédia — Chronologie de la Révolution française | https://fr.wikipedia.org/wiki/Chronologie_de_la_R%C3%A9volution_fran%C3%A7aise | CC BY-SA 4.0 | tertiaire / à recouper ; **borne partagée 21 sept. 1792** entre Législative (fin 20 sept.) et Convention (début 21 sept.) |
| 2026-11-01 | Frise 2 : recoupement des mêmes dates + fuite du roi « 20-25 juin 1791 », traité de Campoformio (18 oct. 1797), campagne d'Égypte (19 mai 1798), coup d'État du 18 brumaire (9 nov. 1799), Directoire (début 26 oct. 1795), ratification de la Constitution de l'an III (22 août 1795), exécution de Louis XVI (21 janv. 1793), arrestation des Girondins (2 juin 1793), 9-10 thermidor (27-28 juil. 1794) | Larousse — Révolution française (1789-1799) | https://www.larousse.fr/dictionnaires/college/R%C3%A9volution_fran%C3%A7aise/34995 | droits Larousse (consultation / citation de faits) | secondaire (encyclopédie). **Divergence** : Larousse place la proclamation de la République le 22 sept. 1792 ; la frise garde le 21 (abolition de la royauté, Wikipédia) |
| 2026-11-01 | Frise 3 (Convention) : abolition de la royauté (21 sept. 1792), procès de Louis XVI (10 déc. 1792), exécution (21 janv. 1793), Comité de salut public (6 avril 1793), arrestation des Girondins (2 juin 1793), loi du 22 prairial (10 juin 1794), chute de Robespierre 9 thermidor (27 juil. 1794) | Wikipédia — Convention nationale | https://fr.wikipedia.org/wiki/Convention_nationale | CC BY-SA 4.0 | tertiaire / à recouper |
| 2026-11-01 | Frise 3 : Terreur (5 sept. 1793 → 28 juil. 1794), loi des suspects (17 sept. 1793), Tribunal révolutionnaire (10 mars 1793), loi du 22 prairial (10 juin 1794) | Larousse — la Terreur | https://www.larousse.fr/encyclopedie/divers/la_Terreur/146370 | droits Larousse | secondaire (encyclopédie) |
| 2026-11-01 | Frise 3 : Marat (13 juil. 1793), loi des suspects (17 sept.), Marie-Antoinette (16 oct. 1793), Hébert (24 mars 1794), Danton (5 avril 1794), loi de prairial, chute puis exécution de Robespierre (27 / 28 juil. 1794), Comité de salut public « avril 1793 » | World History Encyclopedia — Règne de la Terreur (traduction française) | https://www.worldhistory.org/trans/fr/1-21142/regne-de-la-terreur/ | CC BY-NC-SA 3.0 | secondaire ; le texte se contredit sur Robespierre (arrêté le 27, guillotiné le 28 : retenu) |
| 2026-11-01 | Frise 3 : recoupement Marat, Terreur (5 sept. 1793 → 28 juil. 1794), loi des suspects, Marie-Antoinette, exécution de Robespierre | VL Média — C'était quoi la Terreur ? | https://vl-media.fr/cetait-quoi-la-terreur-instauree-sous-la-revolution-francaise-en-1793/ | inconnue (à régler avant publication) | tertiaire (média de vulgarisation), utilisé seulement pour recouper |
| 2026-11-01 | Frise 2 : début du Directoire (26 oct. 1795) ; fin 18 brumaire | Wikipédia — Directoire | https://fr.wikipedia.org/wiki/Directoire | CC BY-SA 4.0 | tertiaire / à recouper ; date grégorienne de brumaire absente du texte (9 nov. tirée de Larousse) |

## Noms et bornes qui sont des conventions (à valider)
- « Convention girondine » (21 sept. 1792 → 2 juin 1793), « Convention montagnarde » (→ 27 juil. 1794) et « Convention thermidorienne » (→ 26 oct. 1795) : les mots « montagnarde » et « thermidorienne » et les dates 27 juil. 1794 et 26 oct. 1795 viennent de la Chronologie Wikipédia ; « girondine » et la borne du 2 juin 1793 (arrestation des Girondins) sont un **choix de découpage**, signalé ici comme **à recouper**.
- Les points « à la frontière » (par ex. 9 thermidor, 27 juil. 1794) se rangent dans la période qui commence ce jour-là.

## frises_v3 — découpage de l'histoire de France (2026-11-02)
Consultation : 2026-11-02. Barème appliqué : `README.md` (≥ 2 sources indépendantes dont ≥ 1 universitaire/institutionnelle ;
convention établie retenue avec divergence notée). Sources universitaires/institutionnelles = **U** : notices **BnF RAMEAU**
(vedettes-matière « France — dates »), collections **Belin/Cornette** et **Seuil** (notices des Bibliothèques numériques de la Défense), revue
**ATALA n°17 (2014)** (Mazel, Hamon, Inglebert), **Inrap**, manuels de lycée (Nathan) = programmes officiels (B).
Résultat de recoupement : « concordantes » = au moins 2 sources dont 1 U s'accordent ; « divergence » = le désaccord est noté.

| Borne retenue | Sources (U = universitaire/institutionnelle) | Résultat | Autres dates trouvées (non retenues) |
|---|---|---|---|
| **476** (Antiquité → Moyen Âge) | U : RAMEAU « France 476-1483 (Moyen âge) » ; U : Mazel (ATALA) ; B : Nathan 2de, Orléans-Tours | concordantes, **convention établie** | 481 (Clovis, volume Belin), 486 (fin de la Gaule romaine), 496 |
| **987** (haut MA → MA central) | U : RAMEAU « France 987-1328 (Capétiens) » ; U : Seuil (Barthélemy) ; Larousse | concordantes | an mil / XIe s. (Mazel, Nathan : tripartition par siècles Ve-Xe, XIe-XIIIe, XIVe-XVe) |
| **1328** (MA central → bas MA) | U : RAMEAU « 1328-1589 (Valois) » ; U : Belin (Cassard 1180-1328 ; Bove 1328-1453) ; Larousse | concordantes | 1300 (siècles : Nathan, Seuil Bourin/Demurger), 1348 |
| **1492** (Moyen Âge → moderne) | U : Hamon (ATALA : 1492 « la plus évoquée aujourd'hui ») ; B : programmes (Nathan, Orléans-Tours, BO) | concordantes, **convention établie** | 1453 (Belin Hamon ; la plus ancienne), 1483 (RAMEAU « Moyen âge 476-1483 »), 1517 |
| **1562** (Renaissance → guerres de religion) | U : RAMEAU « France 1562-1598 (Guerres de religion) » (vedette portée par la notice Belin Le Roux) ; B : programmes | concordantes | 1559 (Belin Le Roux ; Larousse) |
| **1598** (guerres de religion → monarchie absolue) | U : RAMEAU (même vedette) ; B : programmes (édit de Nantes) | **divergence** | 1589 (Larousse), 1629 (Belin Le Roux : paix d'Alès) |
| **1715** (absolue → Lumières) | U : Belin (Drévillon : mort de Louis XIV, 1er sept. 1715 ; Beaurepaire 1715-1789) ; U : Seuil/Zysberg (1715-1786) ; Larousse | concordantes | — |
| **1789** (moderne → contemporaine) | U : RAMEAU « France 1789-1799 (Révolution) » ; U : Belin (1789-1815) ; B : programmes | concordantes, **convention établie** | 1815 (minorité : historiens modernistes) |
| **1799** (Révolution → Consulat) | U : RAMEAU « 1789-1799 (Révolution) » et « 1799-1815 (Consulat et Empire) » ; U : Bertaud (Colin) ; Seuil | concordantes | — |
| **1815** (Empire → Restauration) | U : RAMEAU « 1799-1815 (Consulat et Empire) » ; U : Seuil (1815-1848) ; U : Belin (Aprile 1815-1870) | **divergence mineure** | 1814 (RAMEAU « Restauration 1814-1830 » ; programmes) |
| **1870** (→ IIIe République) | U : RAMEAU « 1870-1940 (3e République) » (4 sept. 1870) ; U : Belin (Duclert 1870-1914) | concordantes | 1871 (Seuil Mayeur 1871-1898) |
| **1914** | U : Belin (Duclert ; Beaupré 1914-1945) ; U : Seuil (1898-1914 / 1914-1929) | concordantes | — |
| **1945** | U : Belin (Zancarini-Fournel 1945-2005) ; U : RAMEAU « France 1945-… » | concordantes | 1944 (Seuil), 1946 (IVe République) |
| **−52** (Gaule indépendante → romaine) | U : Inrap (âge du Fer −800 → −52, conquête) ; U : Delaplace & France, *Histoire des Gaules* ; B : programmes (Alésia) | concordantes | −121/−118 (Narbonnaise), −58 (début de la guerre des Gaules) |
| **235** (Haut-Empire → crise) | U : Y. Roman, *Le Haut-Empire romain 27 av. J.-C.-235* (notice) ; Universalis ; Delaplace & France (chapitre « 235-406 ») | concordantes | 192 (Commode), fin IIIe s. (Inrap) |
| **284** (crise → Bas-Empire) | U : RAMEAU « Rome 284-476 (Bas-Empire) » (notice P. Brown) ; World History Encyclopedia (tertiaire) | **à valider** : une seule source universitaire indépendante lue | 250 (OCLA), 150 (Brown, début de l'Antiquité tardive) |

### Points qui n'atteignent PAS le barème (signalés à Martin, non cachés)
- **Début de l'Antiquité pour la France : ≈ −600** (fondation de Marseille ; début de la Gaule écrite). C'est un **choix de Claude**, pas une
  convention établie : la convention de l'Antiquité est l'écriture (−3500/−3300, programmes officiels), qui n'a pas de sens local en Gaule ;
  les archéologues (Inrap) placent l'Antiquité en France à −52 ; *Histoire des Gaules* (Delaplace & France) commence au VIe s. av. J.-C.
  Sources : Inrap (frise : ≈ −600 fondation de Marseille), Delaplace & France. **À valider par Martin.**
- **« Crise du IIIe siècle » (235 → 284) comme sous-période à part** : portée par World History Encyclopedia (tertiaire) ; Delaplace & France
  traitent 235-406 d'un bloc. **À valider** (sinon fusionner avec le Bas-Empire).
- **Noms des sous-périodes** (« Monarchie absolue », « Monarchie des Lumières », « La France de 1870 à 1914 »…) : libellés descriptifs de Claude ;
  les bornes sont sourcées, pas les noms.
- **Années seules** : aucune borne ne porte de mois/jour (ce sont des conventions d'historiens) ; −600 est marqué « vers ».
- **Non lu en entier** : les sommaires complets des volumes Belin/Seuil (seuls titres, dates et résumés d'éditeur ont été lus).
- **Liens** (tous consultés le 2026-11-02) : ATALA — https://www.lycee-chateaubriand.fr/wp-content/uploads/sites/2/2017/01/Mazel17.pdf ,
  https://www.lycee-chateaubriand.fr/revue-atala/wp-content/uploads/sites/2/2017/01/Hamon17.pdf ,
  https://www.lycee-chateaubriand.fr/revue-atala/wp-content/uploads/sites/2/2014/06/Inglebert17.pdf ;
  RAMEAU — https://catalogue.bnf.fr/ark:/12148/cb11941855d (3e République), https://catalogue.bnf.fr/ark:/12148/cb119418484 (1789-1815),
  https://catalogue.bnf.fr/ark:/12148/cb11941853q (Restauration) ; Inrap — https://multimedia.inrap.fr/archeologie-preventive/periode/8/Age-du-Bronze-et-age-du-Fer ;
  Belin/Seuil : notices Bibliothèques numériques de la Défense (liens complets dans le champ « sources » des frises en base).
  Licences : notices et pages en consultation, aucun texte repris ; liens uniquement.
## Histoire de l'Allemagne — recherche du découpage (2026-11-06) — PROPOSITION, rien écrit en base
Consultation : 2026-11-06. Barème : `README.md`. **U** = universitaire/institutionnelle : **Gebhardt, *Handbuch der deutschen Geschichte*,
10e éd. (Klett-Cotta, 2001-2014)** = manuel de référence de l'histoire allemande (volumes de tête de série lus : sommaires et préfaces),
**Propyläen Geschichte Deutschlands**, **Siedler Deutsche Geschichte / Das Reich und die Deutschen**, **Neue Deutsche Geschichte (Beck)**,
**Enzyklopädie deutscher Geschichte (Oldenbourg)**, **Oldenbourg Grundriss der Geschichte**, notices **BnF RAMEAU**, **Larousse**,
**Universalis**, PUF *Que sais-je ?* (Droz, Chapoutot), Colin (Roth), Perrin (Bogdan), Dunod ; programmes d'universités allemandes
(Marburg, Frankfurt, Regensburg) et de lycée (C.C. Buchner « Das waren Zeiten », Berlin/Brandenburg) = manuels (B).
**Limite** : seuls sommaires, tables des matières, préfaces et notices ont été lus (pas les chapitres entiers).

| Borne | Sources (U = universitaire/institutionnelle) | Résultat | Autres dates trouvées |
|---|---|---|---|
| **1495** (Moyen Âge → Frühe Neuzeit) | U : Gebhardt (tomes 9-12 « 1495-1806 », éd. Reinhard ; tome 8 jusqu'à 1495) ; U : G. Schmidt, *Geschichte des alten Reiches 1495-1806* (Beck 1999) ; U : A. Gotthard, *Das Alte Reich 1495-1806* ; B : univ. Marburg, Frankfurt (Cordes) | concordantes, **convention établie en Allemagne** | 1517 (Boockmann, *Deutschland 1125-1517* ; Schilling 1517-1648 ; Burkhardt), 1490 (Propyläen Moraw 1250-1490 ; Lutz 1490-1648), 1500 (Marburg, Vocelka ; manuel Buchner : Moyen Âge « ca. 1000-ca. 1500 »), 1492 (programmes français, cf. frise France). Reinhard consacre un § entier au problème (« Beginn und Ende der Frühen Neuzeit ») ; Boockmann relativise lui-même la coupure vers 1500 |
| **1806** (Frühe Neuzeit → époque contemporaine) | U : Gebhardt (tomes 9-12 jusqu'à 1806, tomes 13-17 « 1806-1918 », éd. Kocka) ; U : Universalis (« époque des confédérations 1806-1871 ») ; U : Chapoutot, *Histoire de l'Allemagne de 1806 à nos jours* (PUF) ; BnF RAMEAU « Saint-Empire 962-1806 » ; Larousse (« fin du Ier Reich 1648-1806 ») | concordantes | 1789 (RAMEAU « Allemagne 1789-1900 » ; Gebhardt reconnaît le « long XIXe s. » « non sans controverse »), 1815 (Marburg : FNZ jusqu'à 1815 ; Droz, Roth : 1815-…) |
| **843** (Verdun : début de la Francie orientale) | U : BnF RAMEAU « Germanie, Royaume de 843-962 » et « Allemagne 843-1273 » ; U : F. Prinz, *Grundlagen und Anfänge* (Beck, « Ostfrankenreich 843-918 ») ; U : Ehlers, *Die Entstehung des Deutschen Reiches* (EdG 31, sujets 843-1100) ; DHM (Berlin) | concordantes **comme étape**, mais voir « désaccords » | 911 (Haller 1959), 919 (Schlesinger 1975…), 962 |
| **1024** (Ottoniens → Saliens) | U : Gebhardt (tome 3 jusqu'à 1024 ; tome 4 « Salierzeit 1024-1125 ») ; U : Propyläen (Fried « bis 1024 » ; Keller « 1024-1250 ») ; U : Prinz (Ottoniens 919-1024) ; Larousse (Saxons 919-1024) | concordantes | — |
| **1125 / 1138** (Saliens → Staufer) | U : Gebhardt (tome 4 jusqu'à 1125 ; tome 5 « 1125-1198 », Haverkamp) ; U : Boockmann (« 1125-1517 ») ; Larousse (Francs 1024-1138, Staufer 1138-1250) | **divergence** | 1138 (Larousse), Keller traite Saliens + Staufer d'un bloc (1024-1250) |
| **1250 / 1273** (Staufer → Interrègne → Habsbourg) | U : Gebhardt (tome 6 « 1198-1273 » ; tome 7a à partir de 1273) ; U : Propyläen (Moraw « 1250-1490 ») ; U : BnF « Allemagne 843-1273 » ; Larousse (Interrègne 1250-1273) | **divergence mineure** | Gebhardt traite l'Interrègne comme jalon (1198-1273) |
| **1555 / 1618 / 1648** (Frühe Neuzeit) | U : Gebhardt (tome 9 « 1495-1555 » ; tome 10 « Konfessionelles Zeitalter 1555-1618 ; Dreißigjähriger Krieg 1618-1648 ») ; Larousse (guerre de Trente Ans 1618-1648 ; « 1648-1806 ») ; U : Universalis (« importance de la date de 1648 ») ; U : Schilling, *Höfe und Allianzen 1648-1763* (Siedler) | concordantes | 1517-1648 (Schilling, Vocelka, Jung), 1490-1648 (Lutz) |
| **1763** (→ fin du Reich) | U : Gebhardt tome 12 (Demel, « 1763-1806 ») ; U : Schilling (1648-1763) ; U : Möller, *Fürstenstaat oder Bürgernation 1763-1815* | concordantes | 1789 (Vocelka : Révolution comme limite) |
| **1815 / 1849 / 1866 / 1871** | U : Gebhardt (tome 14 « 1806-1848/49 » ; tome 15 « 1849-1871 » ; tome 16 « 1871-1918 ») ; U : Droz (PUF : 1815-1850, 1850-1871) ; U : Larousse (Confédération du Rhin 1806-1814 ; Confédération germanique 1815-1866 ; 1848-49 ; Confédération du Nord 1867) ; U : Universalis (1806-1871) | concordantes (le détail des sous-périodes varie) | 1814/1815 |
| **1871** (→ Reich) | U : BnF RAMEAU « Allemagne 1871-1918 (Empire allemand) » : 18 janv. 1871 → 9 nov. 1918 ; U : Gebhardt tome 16 ; U : Droz ; U : Bogdan ; U : Roth (Colin) ; Larousse ; Dunod | concordantes, **convention établie** | — |
| **1890** (Reich bismarckien → wilhelmien) | U : Droz (1871-1890 / 1890-1918) ; Larousse ; Dunod (Abbad/Flonneau) | concordantes | — |
| **1918 / 1919** (→ Weimar) | U : BnF RAMEAU « 1918-1933 (République de Weimar) » ; U : Gebhardt (« 20e s. 1918-2000 ») ; U : Droz, Bogdan (1918-1933) | **divergence mineure** | 1919 (Larousse, Dunod, Universalis « Weimar 1919-1933 ») |
| **1933** (→ IIIe Reich) | U : BnF RAMEAU « 1933-1945 » ; U : Droz, Bogdan ; Larousse ; Dunod | concordantes | — |
| **1945 / 1949** (→ occupation → deux États) | U : BnF RAMEAU « 1945-1949 » et « 1945-1990 » ; U : Gebhardt tome 22 (Benz/Scholz, « Besatzung 1945-1949 ; DDR 1949-1990 ») ; U : Broszat (dir.), *Zäsuren nach 1945* (IfZ) : « 1945/49 et 1989/90 » ; U : Wirsching (1945 = plus profonde césure) ; Larousse | concordantes | 1944 |
| **1949-1990** (RFA et RDA, **deux États en même temps**) | U : Gebhardt tome 23 (Wolfrum, « Bundesrepublik 1949-1990 ») ; U : Benz/Scholz (DDR 1949-1990) ; U : RAMEAU « 1945-1990 » | concordantes | — |
| **1990** (réunification) | U : BnF RAMEAU « 1989-1990 (Unification) » et « 1990-… » ; U : Droz (« La réunification ») ; U : Broszat (1989/90) | concordantes | 1989 (chute du Mur) |

### Désaccords et points qui n'atteignent PAS le barème (à décider par Martin)
- **Début de l'« histoire allemande »** : **énorme désaccord, sans date convenue**. Ancien : 919 (Schlesinger 1975…) ; aujourd'hui, presque unanimement
  (Jarnut, Fried, Ehlers, cités par Koch, univ. Paderborn) : **pas de date fondatrice, un long processus**, 843 / 911 / 919 / 962 étant des étapes.
  Le Gebhardt commence à la Spätantike (IVe s.) et traite la Francie orientale dans le cadre franc (714/715-887/888). **Aucune date n'est donc écrite** tant que Martin n'a pas tranché.
- **Frontière Antiquité → Moyen Âge pour l'Allemagne** : pas de date allemande nette (Gebhardt tome 1 : « Europäische Grundlagen deutscher Geschichte, 4e-8e s. » ; Wolfram, *Das Reich und die Germanen. Zwischen Antike und Mittelalter*).
  La convention européenne 476 existe mais n'est pas la division des manuels allemands. **À décider.**
- **Début de la période « Antiquité » en Germanie** : aucune source lue ne donne de borne de début (Germanen, Rome, limes) → **non sourcé, rien écrit**.
- **RFA/RDA simultanées** : l'outil de frise sait-il montrer deux périodes en parallèle (1949-1990) ? **À vérifier dans la spec avant de construire**.
- **Noms des sous-périodes** : libellés descriptifs de Claude (les bornes sont sourcées, pas les noms), sauf termes d'historiens : « Konfessionelles Zeitalter », « Interrègne », « Vormärz ».
- **Années seules** : aucune borne ne porte de mois/jour (sauf RAMEAU 1871 : 18 janvier ; 1918 : 9 novembre, à ne pas utiliser sans autre source).
- **Liens** (consultés le 2026-11-06) : Gebhardt (Klett-Cotta) — https://www.lehmanns.ch/media/120933979 (tomes 1-23, bornes) ,
  https://klett-cotta.de/_files_media/reading_samples/10606.pdf (registre, justification des phases) ,
  https://www.klett-cotta.de/_files_media/reading_samples/3057.pdf (tome 14, 1806-1848/49) ,
  https://www.lehmanns.ch/media/1347592/1 (tome 9, « Periodisierungsprobleme ») , https://www.lehmanns.ch/media/69948/1 (tome 23, Wolfrum) ;
  Propyläen / Das Reich und die Deutschen — https://www.hendrik.maekeler.eu/handbucher/ (liste des volumes et bornes) ;
  Prinz, *Grundlagen und Anfänge* — https://www.lehmanns.ch/media/1064838/1 ; Ehlers — https://neu.aggb-katalog.de/vufind/Record/ifz.206312 ;
  Koch (Paderborn) — https://digital.ub.uni-paderborn.de/download/pdf/6461713.pdf ; DHM — https://www.dhm.de/mediathek/der-rhein-von-basel-bis-koblenz/chronologie-der-deutsch-franzoesischen-geschichte/strassburger-eide/ ;
  RAMEAU — https://catalogue.bnf.fr/ark:/12148/cb119347320 (1871-1918), https://catalogue.bnf.fr/ark:/12148/cb15342264g (Saint-Empire 962-1806), https://catalogue.bnf.fr/ark:/12148/cb119744471 (843-1273), https://catalogue.bnf.fr/ark:/12148/cb119347309 (1789-1900), https://plus.cobiss.net/cobiss/up/en/sgc/8694376 (liste des vedettes 1918-1990) ;
  Larousse — https://www.larousse.fr/encyclopedie/divers/Allemagne%C2%A0_histoire/185779 ; Universalis — https://www.universalis.fr/encyclopedie/allemagne-histoire-allemagne-moderne-et-contemporaine/2-l-epoque-des-confederations-1806-1871/ ;
  Droz (PUF) — https://bibliotheques-numeriques.defense.gouv.fr/impression/document/6901005f-cee2-4923-87be-8435d5309e9a ; Bogdan (Perrin) — https://bibliotheques-numeriques.defense.gouv.fr/impression/document/c6121bbf-32b0-4e99-ba8c-98a79067380d ;
  Broszat, *Zäsuren nach 1945* — https://open.ifz-muenchen.de/bitstreams/c6983b02-bc57-439b-a0e5-3507b9cc55b4/download ; Benz/Scholz — https://cir.nii.ac.jp/crid/1130000794434588672?lang=en ;
  Marburg — https://www.uni-marburg.de/de/fb06/fnz/studium/studium ; Regensburg — https://uni-regensburg.de/assets/philosophie-kunst-geschichte-gesellschaft/geschichte/staatsexamen/Auswahlbibliographie_Fruehe_Neuzeit.pdf ;
  Buchner — https://www.ccbuchner.de/_files_media/mediathek/downloads/2744.docx .
  Licences : consultation seule, aucun texte repris ; liens uniquement.

### Allemagne — peuples d'avant le Saint-Empire (Saxons, Thuringiens, Alamans, Bavarois…) — pistes, 2026-11-06, RIEN écrit en base
- **Cadre savant** : la théorie de l'ethnogenèse (R. Wenskus, *Stammesbildung und Verfassung*, 1961 ; W. Pohl, *Die Germanen*, EdG 57, 2000 ; J. Jarnut) : ces « peuples » sont des groupes qui se forment et se recomposent, pas des tribus fixes. Il faut donc écrire « peuples/gentes » avec prudence. Sources : https://epub.oeaw.ac.at/0xc1aa5576 0x00390713.pdf (Pohl), https://journals.ub.uni-heidelberg.de/index.php/gfa/article/view/75206/68876 (compte rendu citant Jarnut), https://neu.aggb-katalog.de/vufind/Record/fzh.31089834X (Pohl, notice).
- **Dates lues (U = universitaire/institutionnelle)** : Thuringiens soumis par les Francs en **531** (U : Universalis « Thuringiens, Alamans et Bavarois » ; U : Haus der Bayerischen Geschichte, https://archiv.hdbg.de/polges/pages/druck/kapitel1.pdf) → concordantes. Alamans soumis par Clovis en **496/497**, « faits et dates discutés » (U : Dictionnaire historique de la Suisse, https://hls-dhs-dss.ch/fr/articles/008027) → **à ne pas écrire sans 2e source** ; 1re mention des Alamans au début du IIIe s. (U : Universalis). Bavarois (788) et Saxons (804) : **seule source = blog non savant (jassa.org) → non sourcé, rien à écrire.**
- Liens : https://www.universalis.fr/encyclopedie/thuringiens-alamans-et-bavarois/ ; https://hls-dhs-dss.ch/fr/articles/008027 .

### Allemagne — dates enseignées (programmes, manuels, séries universitaires), 2026-11-06
Demande de Martin : « dates officielles, utilisées par les universitaires et/ou dans les manuels ». Lu : extraits de programmes (pas les programmes entiers).
- **Programmes officiels (B)** : Bavière (ISB, LehrplanPLUS 8e, « Grundlegende Daten und Begriffe » : 800, 1618-1648, **1806 Ende des HRR**, 1789, **1815**, 1832, **1848/49**, **1871**, 1914-1918) — https://www.lehrplanplus.bayern.de/fachlehrplan/gymnasium/8/geschichte , https://edumedia-depot.gei.de/bitstream/handle/11163/3824/883967774_1990_A.pdf?sequence=2 (voir aussi la version 2009 : https://edumedia-depot.gei.de/bitstream/handle/11163/1005/774613378_2009_A.pdf?sequence=2) ; Sarre (1815-1850, 1850-1890, 1890-1918, Weimar, NS, « Deutschland nach 1945 ») — https://www.uni-saarland.de/fr/fachrichtung/geschichte/institut/fachdidaktik-geschichte/gudig-die-lernwerkstatt-geschichtsunterrichtdigital/der-grosse-gudig-werkzeugkasten/material-geordnet-nach-den-saarlaendischen-lehrplaenen.html ; NRW (« lange 19. Jh. », Weimarer Republik, NS et 2e GM, « seit 1945 ») — https://schulentwicklung.nrw.de/materialdatenbank/material/download/12143 ; Berlin-Brandenburg, manuel Buchner (Mittelalter ca. 1000-1500, Frühe Neuzeit ca. 1500-1750) — https://www.ccbuchner.de/_files_media/mediathek/downloads/2744.docx .
- **Manuel franco-allemand (Nathan/Klett)** : 3 tomes « Antiquité → 1815 », « Congrès de Vienne → 1945 », « depuis 1945 » : **1815** et **1945** sont ses coupures — https://collections.ushmm.org/search/catalog/bib233475 , https://nrw.digibib.net/search/hbzvk/record/(DE-605)HT017183870 .
- **Université** : Gebhardt (voir plus haut) ; manuel d'histoire allemande avec chapitres « Westfälischer Frieden → Wiener Kongress (1648-1814) », « Wiener Kongress → 1914 », « 1914-1945 », « Weimar », « 1933 » (Dirlmeier, Gestrich, Reulecke) — https://www.lehmanns.ch/media/116667740 ; classification de la bibliothèque de l'univ. Trèves « Zeitgeschichte I : 1918/19-1945 ; II : 1945- » — https://www.uni-trier.de/en/bibliothek/ueber-uns/fachspezifische-informationen/geschichte-mittlere-und-neuere/aufstellungssystematik .
- **Résultat** : dates confirmées par programmes/manuels ET universitaires = **1648, 1806, 1815, 1848/49, 1871, 1914, 1933, 1945, 1949, 1990** (1918/1919 : les deux existent). Dates **seulement dans le Gebhardt** (pas retrouvées dans les programmes lus) : 1495, 1555, 1763, 1849, 1125, 1250/1273. Le Moyen Âge n'a pas de bornes scolaires fines (Buchner : « ca. 1000-1500 ») ; tripartition universitaire usuelle frühes/hohes/spätes Mittelalter avec bornes variables (Goetz 500-1050 ; Hartmann 750-1250 : https://www.uni-erfurt.de/fileadmin/fakultaet/philosophische/Mittelalterliche_Geschichte/Texte/Allg._Bibliographie_2017.pdf).

### Allemagne — début de l'Antiquité (recherche du 2026-11-06) : candidat **−58**, à valider par Martin
- **−58** (campagne de César et victoire sur Arioviste, premier contact écrit durable avec la Germanie rhénane) : U : A. Fahrmeir, *Deutsche Geschichte* (Beck, extrait bpb : la « guerre des Gaules » 58 av. J.-C. amène Rome au Rhin en 55) https://www.bpb.de/system/files/dokument_pdf/Fahrmeir%2C%20Deutsche%20Geschichte%20%28Leseprobe%29.pdf ; U : Universalis « Germanie » (Rome, à partir du Ier s. av. J.-C. ; Arioviste vaincu en 58) https://www.universalis.fr/encyclopedie/germanie/ ; U : R. Fellmann (prof. émérite, univ. Berne), « Rome et les Germains ou l'enjeu du Rhin » (58) https://www.clio.fr/BIBLIOTHEQUE/pdf/pdf_rome_et_les_germains_ou_l_enjeu_du_rhin.pdf ; U : A. Volkmann (univ. Francfort) « Die Germanen » (César 58-51/50) https://opus.bibliothek.uni-wuerzburg.de/files/5424/A._Volkmann_Die_Germanen.pdf ; U : programmes d'archéologie de Ratisbonne et Munich (la vorgeschichtliche Eisenzeit / Latènezeit finit avec la conquête romaine, Ier s. av. J.-C.) https://homepages.uni-regensburg.de/~kog02554/Kommentare/vvz-vfg-ws-12_13.pdf , https://www.vfp-archaeologie.uni-muenchen.de/aktuelles/kvv_wise_2021.pdf → concordantes.
- **Autres dates trouvées (non retenues)** : −12 (campagnes de Drusus au-delà du Rhin, Volkmann ; Universalis −9 Elbe), −15 (début de la Frühgeschichte pour l'Autriche, fiche scolaire), −27 (début de la « römische Kaiserzeit », Landesamt Sachsen), 85 apr. J.-C. (provinces de Germanie ; source non savante seule), ≈ −500 (début de l'âge du fer germanique, Clio) ; la convention générale de l'Antiquité (écriture, −3300/−3500) n'a pas de sens local.
- **Limite** : −58 est la date où l'histoire écrite commence pour la Germanie rhénane et où la Vorgeschichte finit, pas une « date officielle de l'Antiquité allemande » : aucun manuel lu ne définit le début de l'Antiquité pour l'Allemagne.

## 2026-11-02 — outil « Règnes »
Aucune donnée ajoutée par cet outil (code uniquement). Chaque règne saisi portera ses propres sources dans la colonne `sources` de `timeline_reigns`.
## 2026-11-03 — identité visuelle (polices)
Aucune donnée d'histoire ajoutée. Polices : EB Garamond (Georg Duffner, Octavio Pardo), Archivo Narrow (Omnibus-Type) — Google Fonts, licence SIL Open Font License 1.1, https://fonts.google.com/specimen/EB+Garamond et https://fonts.google.com/specimen/Archivo+Narrow ; fiabilité : source officielle de distribution.
