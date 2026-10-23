# Chantier « arbres » — journal

## Dernières nouvelles (la plus récente en haut)

- 2026-10-23 — v67 : Luxembourg + Carolingiens complétés (12 membres). Allemagne : reste les petites maisons royales (Conradiens, Supplinbourg, Nassau, Schwarzburg).

- 2026-10-23 — v66 : Hohenstaufen/Ottoniens/Saliens complétés (13 membres). Reste : Luxembourg, Carolingiens, puis autres pays d'Europe.

- 2026-10-23 — arbres_v65 livrée (Habsbourg : branche de Toscane, 2 isolées reliées, parents de Marie-Anne de Bavière et Jeanne-Sophie, dates d'Éléonore de Gonzague/d'Autriche ; Habsbourg et Habsbourg-Lorraine remis en ordre). Prochaine étape : Luxembourg, Hohenstaufen, Ottoniens, Saliens, Carolingiens.

- 2026-10-23 — arbres_v64 livrée (Welf : +54 membres, 1 seul bloc relié ; de Brunswick-Lunebourg à la maison de Hanovre actuelle, Wolfenbüttel-Bevern). Prochaine étape : Habsbourg.

- 2026-10-23 — arbres_v63 livrée (Hohenzollern : +20 membres ; parents de Marie de Brandebourg-Kulmbach, Madeleine-Sibylle, Christiane-Éberhardine, Marie de Prusse ; empereur Guillaume II jusqu'au chef actuel de la maison). Prochaine étape : Welf.

- 2026-10-23 — arbres_v62 livrée (Wettin : +44 membres, 1 seul bloc relié, 0 chevauchement ; Saxe-Weimar jusqu'à Guillaume-Ernest, Saxe-Gotha-Altenbourg, Saxe-Altenbourg ; corrige une erreur de v61 sur Madeleine-Catherine de Deux-Ponts). Prochaine étape : Hohenzollern, Welf, Habsbourg.

- 2026-10-23 — arbres_v61 livrée (Wittelsbach : +102 membres, branches palatine, Simmern, Deux-Ponts, Neubourg, Sulzbach, Landshut, rois de Bavière jusqu'à aujourd'hui ; plus aucun membre isolé ; testée sur base locale, 0 chevauchement). À exécuter par Martin. Prochaine étape : Wettin, Welf, Hohenzollern, Habsbourg (membres non reliés), puis le reste de l'Europe.
- 2026-10-23 — journal créé ; arbres : v60 (photos) livrée, Chine arrêtée aux Jin ; prochaine étape : Dynasties du Sud et du Nord.

Code : `src/genealogy.ts`, `genealogyLayers.ts`, `genealogyBus.ts`, `genealogyLod.ts/.css`, `genealogyLayersWorker.ts`,
`genealogyLayout.ts`, `genealogyRouting.ts`. Outils de remplissage : [`scripts/arbres/`](../../scripts/arbres/README.md).
Prochaine migration : **arbres_v68** (`supabase/arbres/arbres_v68.sql`) — générateur : `Gen(68, "…")`.  (v67 livrée, à exécuter par Martin si ce n'est pas déjà fait.)

## Règles de contenu (décidées par Martin — ne pas rouvrir)
- Un pays n'a que les dynasties qui ont **régné sur lui**. Dynastie étrangère : branche principale dans son pays
  d'origine ; la branche qui a régné ailleurs a son arbre dans le pays concerné, reliée à l'origine. Saint-Empire :
  l'Empire relève de l'arbre allemand.
- Partir du couple originel ; n'ajouter que les descendants (hommes et femmes) au rôle historique (régent,
  activité politique, mariage important), **toujours avec leur mère/épouse**.
- Épouse d'une dynastie qui a un arbre → **créée dans cet arbre puis reliée**. Épouse d'une famille **sans** arbre →
  placée dans l'arbre en cours et **signalée** à Martin.
- Membres venus d'un autre arbre : seulement ceux liés directement (mariage) ; leurs enfants seulement s'ils sont mariés
  à un membre de l'arbre, ou de rôle politique majeur (roi, empereur…), ou parents d'un roi/empereur. Pas de ducs de
  petits duchés éteints. (Pas encore appliqué rétroactivement aux anciens arbres : élagage proposé, accord attendu.)
- Anneau rouge (`is_leader`) : seulement le plus haut pouvoir sur le pays. Photos centrées sur le visage.
- Années avant J.-C. en valeurs négatives. **Jamais de donnée inventée** ; date inconnue = vide + signalée.

## Mise en page « Organiser par dates »
Calcul en couches (33 ans par ligne), enfants sous parents d'abord, couples côte à côte ensuite, conjoint entre les
deux familles, traits en peigne, recuit simulé (~30 s dans un worker), dézoom jusqu'à 0,03 avec noms réservés aux
membres à anneau rouge. Duplication d'un conjoint : dernier recours, **non implémentée**. Voir `DECISIONS.md`.
Limites : optimalité non garantie (≈ 7–12 croisements sur Habsbourg) ; durée réelle sur l'ordinateur de Martin non mesurée.

## Contenu déjà en base (migrations v38 → v59 exécutées par Martin ; v60 = photos)
Allemagne (Habsbourg, Saliens, Wittelsbach, Hohenstaufen, Ottoniens, Luxembourg, Wettin, Hohenzollern, Welf), France
(Capétiens, Bourbon-Orléans), Stuart, Barcelone, Bourbon-Siciles, Bourbon-Parme, Couronne belge, Glücksbourg (Danemark),
Pologne (v39), Tchéquie (v40), Hongrie (v41), Autriche (v42), Russie (v43), Roumanie (v44), Grèce (v45), Bulgarie (v46),
Serbie (v47), Monténégro (v48), Bosnie (v49), Albanie (v50), Chypre (v51), Luxembourg (v52), Monaco (v53), Liechtenstein
(v54), Ukraine (v55), **Chine** : Zhou+Qin (v56), Han+Xin (v57), Trois Royaumes (v58), Jin (v59). Choix : Croatie sautée ;
Xia/Shang exclus ; Zhou sans dates inventées.

## Reste à faire
1. Chine : Dynasties du Sud et du Nord (Liu Song, Qi, Liang, Chen ; Wei du Nord/de l'Est/de l'Ouest, Qi du Nord, Zhou du
   Nord), Sui, Tang (+ Wu Zhou), Cinq Dynasties et principaux Dix Royaumes, Liao, Song, Jin jurchen, Yuan (branche de
   Kubilaï), Ming, Qing (Aisin Gioro).
2. Autres pays : Corée, Japon (compléter), Vietnam, Mongolie, Perse/Iran, Ottomans, Égypte, Éthiopie, Inde/Moghols,
   Thaïlande ; Europe : Italie, compléments Allemagne, unions Pologne-Lituanie / Suède / Norvège / Finlande / Estonie /
   Lettonie, Biélorussie, Moldavie, Slovénie/Celje, Danemark, Pays-Bas/Belgique.
3. Élaguer les anciens arbres (règle des membres étrangers) — accord de Martin attendu.
4. Script de rattachement des épouses signalées quand leur arbre existera.
5. Photos : ~924 membres sans portrait (liste dans `scripts/photos/`), à compléter à la main ou par une 2e récolte.

## Points à relire (signalés)
≈ 356 personnes placées hors de leur arbre (`flags` du registre) ; ≈ 712 dates approximatives (`dateflags`) ; filiation
Sima Zhou → Sima Jin → Yuan de Jin non confirmée ; fautes de saisie de la base d'origine (Vratislav II 1061, Boleslas II
920, Victoire 1768/1786, Hedwige de Żagań) ; entrées parasites à nettoyer par Martin (« tesq », « On est en direct ? »,
« Geoffroy Stammegna », doublon Nassau `8e0f6e5d`, doublon Luxembourg `cbce1152`, « MAISON DE HABSBOURG » `49c99143`,
« Charles 1er de Habsbourg » `2b832845`).
