# Registre des images — licences (vérifié le 2026-11-01)

Demande de Martin (2026-11-01) : **toutes les images du site doivent être libres de droit**. Inventaire fait dans la base
(`genealogy_members.photo_url`, `dossier_entries.photo_url`, `dossier_categories.image_url`, `dossier_sections.cover_image_url`).

## Bilan
| Origine | Nombre | État |
|---|---|---|
| Wikimedia Commons (liens directs) | 306 membres / 302 fichiers | **Vérifié** : aucun fichier non libre (voir ci-dessous) |
| Wikipédia anglaise (fichier local) | 1 (`Honore_V_Monaco.gif`) | Catégorisé « All free media / auteur mort depuis > 100 ans, domaine public » : libre |
| Fichiers téléversés par les utilisateurs (portraits de membres) | 834 | **Origine inconnue** (noms « photo.jpg » ; téléversés par 3 comptes du 03 au 22/10) |
| Fichiers téléversés (couvertures de catégories, sections, entrées) | 40 | **Non libres pour la plupart** : noms montrant Adobe Stock, Getty Images, Etsy, presse, mème… |

## 1. Images Wikimedia Commons (302 fichiers) — vérifié
Méthode : API Commons (`extmetadata`), script `scripts/images/verifier-licences-wikimedia.js`, rejouable. Aucune image « non libre » (`NonFree`).
- **248 : domaine public** (œuvres anciennes ; auteur mort depuis longtemps ; documents officiels). Aucune obligation légale, mais l'auteur reste cité sur Commons.
- **54 : licence libre avec obligation de citer l'auteur** (liste ci-dessous). Les CC BY-SA imposent en plus que toute version **modifiée** garde la même licence.
- Page de chaque fichier : `https://commons.wikimedia.org/wiki/File:<nom du fichier>` (le nom se lit dans `photo_url`).
- **Points à surveiller** :
  - 2 fichiers ont une mention de restriction « droit à l'image / personnalité » (personnes vivantes) : `Sébastien_vu_Lëtzebuerg,…Wedding_2012.jpg`, `Sophie,_Hereditary_Princess_of_Liechtenstein_(cropped).jpg`.
  - Licences non-CC à lire : « Attribution » (3 photos du gouvernement du Liechtenstein : citer la source), « European Parliament » (`GD_Jean_1994_(cropped).jpg` : réutilisation avec citation), « FAL » (Free Art License, copyleft : `Radu_cel_Frumos_of_Wallachia_2.png`).
  - Une photo à licence « CC BY-SA 4.0 » mais dont l'auteur est l'artiste ancien (`Frederick_Augustus_I_of_Saxony…Bacciarelli`) : probablement une reproduction ; Commons la déclare libre.

### Les 54 fichiers à citation obligatoire (fichier — licence — auteur indiqué sur Commons)
- Saint_Ludmila_icon.jpg — CC BY-SA 2.0 — Иерей Максим Массалитин
- Blagoverny_kniaz_Dmitry_Yurievich_Shemyaka.jpg — CC BY 3.0 — Polar Man
- 1000_Donskoi.jpg — CC BY-SA 3.0 — Дар Ветер
- Князь_Ярослав_Ярославич_Тверской.jpg — CC BY-SA 4.0 — Фреска Архангельского собора
- Princess_Nora_of_Liechtenstein_(cropped).jpg — Attribution — Information und Kommunikation der Regierung, Vaduz
- Marie-Astrid_2025_(cropped).jpg — CC BY 4.0 — SIP / Commission européenne
- Prince_Louis_of_Luxembourg_2025_(cropped).jpg — CC BY 4.0 — (auteur non indiqué sur Commons)
- Prince_Georg_Antonius.jpg — CC0 — Teresa Marenzi & Daniel Bachler
- Ludovico_il_Bavaro.jpeg — CC BY-SA 3.0 — (auteur non indiqué)
- Irina_godunova01_reconstruction.jpg — CC BY-SA 3.0 — Shakko
- Radu_cel_Frumos_of_Wallachia_2.png — FAL — auteur inconnu
- Sébastien_vu_Lëtzebuerg,_Stéphanie_and_Guillaume_Wedding_2012.jpg — CC BY-SA 3.0 lu — Denis Probst (restriction : droit à l'image)
- Guillaume_de_Luxembourg-_1963_201506.jpg — CC BY-SA 4.0 — Sultan Edijingo
- Фреска_с_изображеним_князя_Дмитрия_Переяславского.png — CC BY-SA 4.0 — Архангельский собор
- GD_Jean_1994_(cropped).jpg — European Parliament — Parlement européen
- Beatrycze.jpg — CC BY-SA 3.0 — auteur inconnu
- Joanna_of_Bavaria.jpg — CC BY 3.0 — Parléřova huť
- Busta_Anna_Falcká.jpg, Busta_Anna_Svidnicka.jpg, Busta_Alzbeta_Pomoranska.jpg — CC0 — Packare
- Beatrix_de_Nápoles.jpg — CC BY-SA 3.0 — Chris Furkert
- PremyslOtakarI_bazilikasvJiri.jpg — CC BY 3.0 — User:Acoma
- Anling_2.jpg — CC0 — Brücke-Osteuropa
- Smíchov_729,_Johana_z_Rožmitálu.jpg — CC BY-SA 3.0 — ŠJů
- JanJindra.jpg — CC BY-SA 3.0 — Parléřova huť
- Elizabeth_Charlotte_of_the_Palatinate.jpg — CC BY-SA 3.0 — Franzy89
- Prinsesse_Hedevig_(1581-1641).jpg — CC BY-SA 4.0 — Orf3us
- Leka_of_Albania.jpg — CC BY-SA 4.0 — UKmapper
- Frederik_IX_(cropped)_-_Det_Kongelige_Bibliotek_(KE069531).jpg — CC BY 3.0 — Elfelt & Co.
- GD_Stéphanie_Trounwiessel.jpg — CC BY 4.0 — (auteur non indiqué)
- Leka_Zogu_II.jpg — CC0 — Sobola M
- S.A.S._le_Prince_héréditaire_Jacques_de_Monaco.jpg — CC BY-SA 4.0 — Monegasque2026
- Břetislav_I.-Chrudim2.jpg — CC BY 2.5 — Ben Skála
- Bundesarchiv_Bild_146-2004-0099,_Kaiser_Friedrich_III..jpg — CC BY-SA 3.0 de — Reichard & Lindner (Bundesarchiv)
- Prince_Nikolaus.jpg — Attribution — Landesverwaltung Liechtenstein
- Simeon_Sakskoburggotski.jpg — CC BY 2.5 bg — V. Nikolov
- Vojvoda_Mirko_Petrović-Njegoš_(1863,_Beaufort).png — CC0
- Prince_Constantin_of_Liechtenstein.jpg — CC BY 3.0 — RTVJ
- 2017-07-04-MMPF-WP-IMG_7681_(retouched).jpg — CC BY-SA 4.0 — Grey Geezer, retouche MagentaGreen
- HugoIIIdenario.jpg — CC BY-SA 4.0 — vcoins
- Frederick_Augustus_I_of_Saxony_by_Marcello_Bacciarelli_(ca_1808-1809).png — CC BY-SA 4.0 — Marcello Bacciarelli (reproduction)
- Henry_II_of_Lusignan_(Cropped).jpg — CC BY-SA 4.0 — Кардам
- Anna_Maria_of_Brunswick-Lüneburg.png — CC BY 4.0 — (auteur non indiqué)
- Albert_II_-_08.06.2025_-_Encontro_com_Sua_Alteza_o_Príncipe_de_Mônaco,_Alberto_II_(54574973880).jpg — CC BY-SA 2.0 — Lula Oficial
- Andrius_Kubilius_and_Grand_Duke_Guillaume_V_(3x4_cropped).jpg — CC BY 4.0 — Mathieu Cugnot
- PrinceAlexander_I_w.jpg — CC BY-SA 3.0 — (auteur non indiqué)
- H.M._Queen_Anne-Marie_of_Greece_Allan_Warren_cropped.jpg — CC BY-SA 3.0 — Allan Warren
- ReginaAnaARomaniei.jpg — CC BY-SA 4.0 — MrBoise
- HRH_Crown_Prince_Alexander_II_with_Legion_of_Honour.jpg — CC BY-SA 3.0 — Famille royale de Serbie
- Fotografija_kneginje_Natalije_2.jpg — CC BY-SA 4.0 — Muzej rudničko-takovskog kraja
- Solomoniya_Yurievna_Saburova.jpg — CC BY-SA 4.0 — (auteur non indiqué)
- Prince_Nikolaus_Sebastian.jpg — CC0 — Teresa Marenzi & Daniel Bachler
- Prince_Maximilian_of_Liechtenstein_(born_1969)_at_World_Economic_Forum_Davos_2024.png — CC BY 3.0 — World Economic Forum
- Sophie,_Hereditary_Princess_of_Liechtenstein_(cropped).jpg — Attribution — Roland Korner / Gouvernement du Liechtenstein (restriction : droit à l'image)

## 2. Images téléversées : origine inconnue — NON VÉRIFIABLES en l'état
### 2a. Portraits de membres (834 fichiers dans le stockage `dossier-photos/genealogy/…`)
Le nom d'origine et la source n'ont pas été conservés. Tri par âge de la personne (approximation de la nature de l'image) :
| Tranche (naissance) | Nombre | Risque |
|---|---|---|
| avant 1500 | 538 | faible : peintures, enluminures, sceaux (œuvres tombées dans le domaine public) — mais source à retrouver |
| 1500–1799 | 231 | faible : portraits peints |
| 1800–1849 | 17 | moyen : peinture ou premiers daguerréotypes |
| 1850–1919 | 15 | moyen : photographies anciennes, souvent domaine public selon pays/date |
| après 1920 | 26 | **élevé** : photos récentes, droits d'auteur de photographes probables ; **personnes vivantes : droit à l'image** |
| date inconnue | 7 | à voir (princesses légendaires du Japon, etc.) |

Personnes à photo récente (priorité 1) : Alphonse XII, Marie-Christine d'Autriche, George V, Mary de Teck, Albert Ier, Élisabeth en Bavière, Alphonse XIII,
Victoire-Eugénie de Battenberg, Édouard VIII, George VI, Elizabeth Bowes-Lyon, Léopold III, Astrid de Suède, Marie de las Mercedes, Jean de Bourbon,
Philip Mountbatten, Élisabeth II, Baudouin, Albert II, Paola, Sophie de Grèce, Juan Carlos Ier, Charles III, Anne, Camilla, Andrew, Philippe (Belgique),
Diana, Edward, Philippe VI, Letizia, Mathilde, Meghan Markle, Kate Middleton, William, Harry, **et quatre mineurs** (Élisabeth de Belgique, Leonor, George,
Charlotte et Louis de Galles). Ce sont les cas les plus risqués : photos de presse très probables, personnes vivantes et enfants.

### 2b. Images de couvertures (40 fichiers : catégories, sections « dynasties », entrées)
Les noms de fichiers montrent des images récupérées sur le web, **sans licence libre vérifiable**. Quelques signes :
- Adobe Stock (`adobestock_187854068…`, `…photo-adobe-stock-1660137538`), Getty Images (`gettyimages-56911981`), Shutterstock (`…-260nw-2447752881`), Etsy (`il_570xN…`),
  un mème (`makeitmeme_FHLA0.jpeg`), visuels de presse (`presse08.jpg`, `cc-128`…), éditeurs divers (`1315725-Fantassin_wisigoth`, `20230209153150…`).
- Concernées : 14 catégories (Actualité, Arts, Cinéma, Culture générale, Droit, Économie, Géographie, Histoire, Philosophie, Politique, Relations internationales,
  Sciences, Sociologie, Sport), 5 entrées et 21 sections de dynasties (Bonaparte, Capétiens, Carolingiens ×2, Bourbon, Mérovingiens, Ottoniens, Habsbourg,
  Hohenstaufen, Hohenzollern, Luxembourg, Saliens, Welf, Wettin, Wittelsbach, Valois, Robertiens, Conflits, Relations avec le monde, Religion, Dynastie).
- Une partie a une origine probablement libre (cartes Wikipédia : `Provinces_of_Nepal_german_2018.svg`, blason `Royal_Coat_of_Arms_of_Valois_France.svg`,
  `Robert_Ier_roi_des_Francs.jpg`) mais **la source n'est pas notée**.

## Décision à prendre (Martin)
1. **Couvertures (40)** : les remplacer par des images Wikimedia Commons libres (tableaux du domaine public, cartes, blasons), source notée ici, ou les retirer.
2. **Portraits anciens (≈ 800)** : essayer de retrouver pour chacun la même image sur Commons (comparaison automatique d'empreintes visuelles) ; ce qui est retrouvé
   est relié à sa page Commons (licence, auteur). Le reste : remplacé par l'image libre de Wikipédia/Commons si elle existe.
3. **Photos récentes (≈ 33 + dates inconnues)** : à retirer tant qu'on n'a pas une photo à licence libre (Commons) ; mineurs et personnes vivantes en priorité.
4. **Règle pour toutes les conversations** : n'ajouter une image que si elle vient de Wikimedia Commons (ou est créée par Martin), avec page du fichier, auteur et licence notés ici.
5. **Site** : ajouter une page « Crédits des images » (lien, auteur, licence) alimentée par ce registre.
