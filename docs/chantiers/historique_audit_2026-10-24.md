# Audit des frontières de la carte historique — 2026-10-24

Chantier : historique. **Lecture seule : aucune donnée du site n'a été modifiée.** Données auditées : Cliopatria v0.2.1 (13 797 lignes, 12 064 entités dessinées).
Outils : `scripts/historique/audit/` (a1 attributs, a2 géométrie, a3 chevauchements, b1 terre/mer, b2 frontières actuelles, b3 Historical Basemaps, d_rendu images).

## Sources de comparaison
- **Historical Basemaps** (aourednik, 53 dates de -3000 à 2010, GPL-3.0 : lu seulement, rien copié).
- **Natural Earth** (frontières 50 m et terres 10 m, domaine public) : frontières actuelles et trait de côte.
- **Wikipédia** « List of largest empires » (superficies maximales), **Wikidata** (dates, superficies, libellés), **suivi des problèmes de Cliopatria sur GitHub** (#16, #18 à #28, audit d'un tiers).
- Rendus côte à côte Cliopatria / Historical Basemaps (-500, 100, 1279, 1815…).

Légende : **[Erreur]** quelque chose est faux ; **[Convention]** les sources divergent par choix de découpage, pas par faute ; **[Lacune]** il manque quelque chose ; **[Incertain]** je ne peux pas trancher. Niveau de confiance : *certain* (mesuré, reproductible) / *probable* / *à vérifier*.

## Ce qui va bien (mesuré)
- Aucune date inversée, aucune entité absente d'une année entre -3400 et 2024 (chaque année a au moins une entité). *certain*
- Aucune forme ne traverse le méridien ±180° d'un seul tenant (pas de bandes parasites sur la carte). *certain*
- Superficie annoncée = superficie recalculée (écart < 10 % pour toutes les formes > 1 000 km²). *certain*
- Les formes suivent bien la côte : sur 12 064 entités, **aucune** n'a plus de 30 % de sa surface en mer (marge de 15 km) ; les formes autour de la Baltique (Suède, Finlande, Novgorod) sortaient à 25-30 % mais **c'était un défaut de mon fichier de côtes** (le tracé de l'Eurasie du paquet npm world-atlas est invalide et coupait le nord de la Scandinavie) ; ce chiffre est donc à ne pas retenir (corrigé le 2026-10-24 avec le fichier Natural Earth officiel). *la mesure initiale « moins de 30 % en mer » reste à refaire avec le bon fichier*
- Les 13 formes invalides (géométrie) sont toutes des lignes « ensemble » entre parenthèses (ex. « (Kingdom of France) »), non dessinées par le site. *certain*

## 1. Graves (visibles sur la carte)

### 1.1 Chevauchements entre entités différentes — [Erreur] ou [Convention] selon le cas
185 paires d'entités se recouvrent sur au moins une des années testées sans appartenir au même ensemble ; **54** se recouvrent à plus de 50 % pendant 3 années testées ou plus. Les plus gros (recouvrement maximal en km²) :
- République française (Ve) / Algérie, 1970-2020 : 2,3 M km², 100 % *(erreur probable : l'Algérie indépendante est recouverte par la France)*
- Horde bleue / Horde d'or, 1390-1400 : 1,8 M km² *(même État sous deux noms : doublon)*
- Assyrie égyptienne / Empire néo-assyrien, -650 à -620 : 1,4 M km² *(deux revendications sur la même terre)*
- Parti communiste chinois / URSS (1940), / République de Chine (1945), / Rép. du Turkestan oriental (1945) *(zones d'influence contradictoires)*
- Himyarites / Axoum, 290-600 : 0,3 M km² ; Rus' de Kiev / Principauté de Tchernigov, 1060-1230 ; Grand Empire seldjoukide / Hamdanides, 1080-1120.
- « Kingdom of Great Britain » / Oman, 1980-2020 : 0,3 M km² (nom d'entité qui paraît inadapté à cette date et à ce lieu).
*Confiance : certain pour les chiffres ; la nature (doublon, suzeraineté volontaire, erreur) est à trancher cas par cas.* Liste complète : `audit/a3.json` (dans l'espace de travail, régénérable avec `a3_chevauchements.py`).

### 1.2 Noms en retard ou inadaptés à l'année affichée — [Erreur]
Cliopatria garde le dernier nom connu d'un territoire sur toute sa durée, d'où des libellés anachroniques :
- 2024 : « Netherlands Antilles » (dissoute en 2010), « Estado Novo » (6 779 km², nom d'un régime fini en 1974), « Mujahideen » (68 714 km² en Syrie), « Gaza/Hamas », « Russian-occupied territories ». Le premier est certain ; les autres sont des choix de l'auteur à qualifier. *certain pour « Netherlands Antilles »/« Estado Novo », à vérifier pour le reste*
- 1914 : « Kingdom of Great Britain » (état qui n'existe plus depuis 1801) là où la source de comparaison indique le Royaume-Uni. 1938 : « Kingdom of Great Britain » encore, « Second Spanish Republic ».
- 1900-1938 : « British Africa », « German Africa » : agrégats modernes, pas des États.
*Effet sur le site : le nom affiché (même traduit) est faux pour l'année. Une table « nom valable de telle année à telle année » corrigerait cela.*

### 1.3 Identifiants Wikidata partagés par des noms différents — [Erreur] (115 cas)
Un même identifiant sert à des entités distinctes, ce qui fausserait tout lien futur fiche ↔ territoire et les noms français. Exemples : Q5349053 pour 12 noms chinois (Chang-shan, Dai, Henan, Jiaodong…), Q1068371 pour « Chauhan Dynasty » et « Han Dynasty », Q555994 pour « Aq Qoyunlu » et « Lu », Q41137 pour Assyrie et Syrie, Q7183 pour « Qin Dynasty » et « Zhai », Q229 pour « Cyprus Condominium » et « République de Chypre ». Certains sont légitimes (phases d'un même État : Song du Nord/du Sud ; Francs/Carolingiens), d'autres sont des erreurs de rapprochement. *certain pour le nombre ; tri des légitimes/erreurs à faire*
Autres : « Timurid Empire » sans identifiant ni lien Wikipédia ; deux noms avec deux identifiants (« Scandinavian minor kingdoms »).
*Déjà traité côté noms français : j'ai exclu ou remplacé à la main les libellés incohérents, mais les identifiants eux-mêmes restent faux dans la source.*

## 2. Moyens

### 2.1 Superficies maximales comparées à Wikipédia — [Convention] / [Incertain]
(Cliopatria, forme la plus grande de l'entité, contre la liste Wikipédia ; les deux sont des estimations.)
| Entité | Cliopatria | Wikipédia | Écart |
|---|---|---|---|
| Empire mongol | 27,4 M km² (1279) | 24,0 | +14 % |
| URSS | 24,6 (1946) | 22,3 | +10 % |
| Empire russe | 23,1 (1900) | 22,8 | +1 % |
| Dynastie Tang | 8,7 (661) | 5,4 | +62 % (protectorats inclus ?) |
| Empire portugais | 8,1 (1820) | 5,5 | +47 % (revendications ?) |
| Yuan | 14,3 (1352) | 11,0 | +30 %, et la forme maximale tombe 40 ans après le sommet connu (1310) |
| Califat abbasside | 8,2 (778) | 11,1 | −27 % |
| Xiongnu | 5,6 (-144) | 9,0 | −38 % |
| Empire ottoman | 4,3 (1595) | 5,2 (1683) | −18 % et sommet décalé de ~90 ans |
| Qing | 12,5 (1794) | 14,7 | −15 % |
| Empire britannique | 4,2 (« British Empire » seul) | 35,5 | non comparable : Cliopatria répartit l'empire en plusieurs entités (British Raj, British Africa…) |
| Rome, Achéménides, Han, Ming, Rashidun, Timourides, Séleucides… | à ±15 % | | cohérent |
Lecture : un écart n'est pas une erreur en soi (les estimations Wikipédia sont elles-mêmes disputées). Les écarts à regarder en priorité : **Yuan 1352**, **Tang**, **Xiongnu**, **Ottoman**. *probable*

### 2.2 Comparaison avec Historical Basemaps (53 dates)
- Le nombre de zones en désaccord fort (recouvrement avec le meilleur polygone HB < 0,4) monte de 0 (-3000) à ~30 (1000-1200, 1500-1700), puis redescend à 0-8 après 1900.
- Cas typiques, presque tous de **découpage** (Convention) : Chu/Wu/Jin/Yue contre « États Zhou » (-500) ; Hafsides, Zayyanides, Almohades contre Mérinides (1279) ; Kushans, Xianbei, Xiongnu contre un polygone « 1 » (100) ; Funj, Darfour, Ouaddaï (1700-1815) ; Khiva, Boukhara, Kokand contre « Turan » (1815).
- Cas qui ressemblent à de vraies **divergences** : Empire mongol 1279 (27,4 M km² contre « Grand Khanat » : HB dessine moins) ; Turk Shahis 800 contre Califat abbasside ; Almohades 1279 (Cliopatria montre encore une zone là où HB montre les Mérinides) ; Alodia/Makuria/Mali 1492 ; Groenland 1815 et 1914 contre Danemark (conventions de rattachement).
- Faiblesse connue d'HB (donc à ne pas lire comme erreur de Cliopatria) : polygones d'« aires culturelles » grossiers (« Khoisan », « chasseurs-cueilleurs ») sans État.
*Confiance : mesure certaine ; chaque cas demande une lecture historique pour décider qui a raison.*

### 2.3 Entités de très petite taille ou isolées — [Incertain]
49 formes font moins de 200 km² (Mercie de 884 à 925 : 44 km² ; empire hunnique 633-673 : 46 km² ; Saint-Marin 47 km² ; Monaco 94 km²). Pour les États minuscules réels (Monaco, Saint-Marin) c'est normal. Pour **Mercie** et **Huns**, 44-46 km² est invraisemblable pour des royaumes : probablement un point-repère. *probable*

### 2.4 Sauts de superficie d'une année à l'autre (200 cas, facteur ≥ 5) — [Incertain]
Exemples : Han (an 5 → 6 : 4,5 M km² → 143 km²), Mexique fédéral 1864-1865, Safavides 1726-1727, Songhaï 1594-1595, Huns 468-469, Portugal 1910-1911 (1,9 M km² → 562 km²), Goguryeo 673-674. Plusieurs sont des **points résiduels** après la chute d'un État (un point de quelques centaines de km² qui reste affiché) : visibles sur la carte comme de petites taches. *certain pour la mesure ; à regarder un par un*

### 2.5 Entités à durée « trouée » — [Convention]
414 trous dans la vie d'entités de même nom (ex. « Later Zhou » -257 → 960 : 1 216 ans ; Géorgie 1009-1918 ; royaume d'Italie 969-1862 ; Serbie 1351-1880). Ce sont des réutilisations de nom pour des États séparés dans le temps. Pas une erreur, mais il faut ne pas supposer qu'un nom = une continuité (et ça gêne le lien fiche ↔ territoire). *certain*

## 3. Mineurs

### 3.1 Frontières actuelles (2024) contre Natural Earth
- 192 entités Cliopatria en 2024, 241 pays Natural Earth. 
- **Réserve (ajoutée le 2026-10-24)** : ces frontières actuelles viennent aussi du paquet npm world-atlas, dont les tracés qui franchissent l'antiméridien (Russie, Fidji…) sont fragiles : les chiffres de la Russie (0,64) et de Fidji (0,09) ne sont pas fiables et sont à refaire avec un fichier Natural Earth officiel.
- Recouvrement correct (> 0,85) pour la plupart des pays moyens et grands. En dessous : Russie 0,64, Syrie 0,63, Israël 0,66, Maroc 0,68 (le Sahara occidental est couvert à 5 % : choix politique), Arménie 0,66, Malawi 0,66 (lac), Somalie 0,71 (Somaliland vraisemblablement séparé), Grèce 0,79, Azerbaïdjan 0,77…
- **Petits États et îles** (Fidji 0,09, Vanuatu, Seychelles, Cap-Vert, Sainte-Lucie, Malte, Bahreïn, Antigua…) : recouvrement très faible, **mais c'est en partie un artefact de ma mesure** (simplification de 3 km qui efface les petites îles). *à re-mesurer avant de conclure*
- **Absences de l'année 2024** (pays Natural Earth sans entité Cliopatria correspondante ou couvert à moins de 70 %) : Samoa, Polynésie française, Kiribati, Tonga, Mariannes du Nord, Îles Caïmans, Saint-Christophe-et-Niévès, Niue, Îles Turques-et-Caïques (11 %), Sahara occidental (5 %), Fidji (30 %), Comores (56 %), Antarctique (0 %, normal).
- Monaco apparaît à côté de la France sans recouvrement mesurable (« France 0,00 »), ce qui suggère que Monaco est dessiné hors de sa position réelle à cette résolution ; à contrôler à l'œil.
*Confiance : à vérifier.*

### 3.2 Années 0 et conventions de dates — [Convention]
Six entités commencent à « l'an 0 » (Indo-Grecs, Indo-Scythes, Judée, Parthes, Empire romain, Yuezhi) : il n'y a pas d'an 0 historique, c'est un artefact de format. Aucune conséquence visible.

### 3.3 Zones de la carte sans État
Cliopatria ne dessine que les États ; les peuples sans État (nomades, chasseurs-cueilleurs, Amérique du Nord indigène avant 1500, Sibérie, Australie, Sahara) apparaissent comme du vide. Historical Basemaps les dessine comme « aires culturelles ». [Lacune] voulue, mais le vide peut se lire comme « territoire inhabité ». Cela se corrige par une mention sur la carte ou par une couche séparée.

## 4. Ce que dit le suivi de problèmes de Cliopatria
Le dépôt `Seshat-Global-History-Databank/cliopatria` contient un audit d'un tiers (#16, #18 à #28) qui recense des erreurs de découpage, de dates et de recoupements par région. Je n'ai pas pu lire la pièce jointe CSV de #28 (inaccessible depuis ici). Je n'ai pas fait de tri détaillé entité par entité de ce suivi : **non vérifié** dans ce rapport. À faire si Martin le demande.

## Ce qui n'est pas vérifié
- Aucune relecture historique entité par entité (seuls des cas types ont été comparés aux rendus).
- Chevauchements : échantillonnage toutes les 10 années et dates clés, pas année par année.
- Comparaison à Historical Basemaps limitée à ses 53 dates ; HB n'est pas lui-même une référence exacte.
- Mesure Natural Earth des petites îles non fiable (voir 3.1).
- Contenu détaillé des 11 problèmes GitHub de Cliopatria (§4).

## Pistes de corrections (à choisir par Martin ; rien n'est décidé)
1. Table de **noms valables par période** (corrige 1.2) et correction des identifiants Wikidata faux (1.3).
2. **Liste d'exclusions** : points résiduels (2.4), formes minuscules suspectes (2.3), doublons (Horde bleue/d'or, Assyrie égyptienne…).
3. Résolution des **chevauchements** les plus lourds (1.1) en choisissant qui garde la zone, avec source.
4. Re-mesure plus fine des petits États et vérification visuelle de Monaco.
5. Mention « zones sans État » sur la carte.
