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
## 2026-11-02 — outil « Règnes »
Aucune donnée ajoutée par cet outil (code uniquement). Chaque règne saisi portera ses propres sources dans la colonne `sources` de `timeline_reigns`.
## 2026-11-03 — identité visuelle (polices)
Aucune donnée d'histoire ajoutée. Polices : EB Garamond (Georg Duffner, Octavio Pardo), Archivo Narrow (Omnibus-Type) — Google Fonts, licence SIL Open Font License 1.1, https://fonts.google.com/specimen/EB+Garamond et https://fonts.google.com/specimen/Archivo+Narrow ; fiabilité : source officielle de distribution.
