# Sources — chantier historique (carte historique)

Format : voir `README.md`. Consultation : 2026-10-23 et 2026-10-24.

| Date | Ce qui a été fait / touché | Source | Lien précis | Licence | Fiabilité |
|---|---|---|---|---|---|
| 2026-10-23 | Tous les contours, noms anglais, dates (instantanés) et identifiants de la carte historique | Cliopatria v0.2.1, Seshat Global History Databank (Bennett et al., Scientific Data, 2025) | https://github.com/Seshat-Global-History-Databank/cliopatria ; https://doi.org/10.1038/s41597-025-04516-9 | CC BY 4.0 | secondaire (base de données savante) ; les auteurs avertissent que frontières, noms et dates sont débattus |
| 2026-10-23 | Noms français (1 210 libellés) | Wikidata, libellés français des éléments (identifiants Wikidata de Cliopatria) | https://www.wikidata.org/wiki/Special:EntityData/<Qxxx>.json (une requête par lot) | CC0 | secondaire/tertiaire ; identifiants parfois faux, filtrés (voir `construire_noms_fr.py`) |
| 2026-10-23 | 344 noms français proposés (traductions) | Proposition de Claude, NON sourcée, signalée « à relire » dans la fiche | `scripts/historique/traductions_fr.json` | — | SOURCE MANQUANTE : à valider par Martin |
| 2026-10-24 | Calage des contours sur la côte réelle : retrait de ce qui est en pleine mer | Natural Earth, terres émergées 1:10 m (« ne_10m_land »), fichier GeoJSON du dépôt nvkelso/natural-earth-vector (commit ca96624a, consulté le 2026-10-24) | https://github.com/nvkelso/natural-earth-vector/blob/master/geojson/ne_10m_land.geojson ; https://www.naturalearthdata.com/downloads/10m-physical-vectors/10m-land/ | domaine public (Natural Earth) | secondaire (trait de côte d'AUJOURD'HUI : mer d'Aral, delta du Nil, polders, lac Tchad ont changé) |
| 2026-10-24 | Dates exactes de naissance/disparition d'États : 493 propositions, dont 420 appliquées (voir `corrections_dates_rapport.json`) | Wikidata, propriétés P571 (date de création), P576 (date de dissolution), repli P580/P582 ; l'élément et la propriété de chaque correction sont dans `scripts/historique/corrections_dates_wikidata.txt` | https://www.wikidata.org/wiki/<Qxxx> (élément indiqué sur chaque ligne) | CC0 | tertiaire/à recouper : une correction n'est appliquée que si elle tombe entre deux instantanés de Cliopatria (garde-fou « fenêtre »), sinon elle est refusée |
| 2026-10-24 | Date du traité de Verdun (843) : Francs de l'Ouest / de l'Est / du Milieu | Wikipédia anglais, « Treaty of Verdun » : traité du 10 août 843 | https://en.wikipedia.org/wiki/Treaty_of_Verdun | CC BY-SA 4.0 | tertiaire / à recouper (date unanimement admise) |
| 2026-10-24 | Hugues Capet, début de la monarchie capétienne (987) | Wikipédia anglais, « Hugh Capet » : élu et sacré en juin 987 | https://en.wikipedia.org/wiki/Hugh_Capet | CC BY-SA 4.0 | tertiaire / à recouper |
| 2026-10-24 | Prise de Bagdad par les Mongols (1258) — correction REFUSÉE par le garde-fou (aucune entité ne reprend le territoire) | Wikipédia anglais, « Siege of Baghdad (1258) » : reddition le 10 février 1258 | https://en.wikipedia.org/wiki/Siege_of_Baghdad_(1258) | CC BY-SA 4.0 | tertiaire / à recouper |
| 2026-10-24 | Chute de Kaifeng et début des Song du Sud (1127) | Wikipédia anglais, « Southern Song » : fondation en 1127, incident de Jingkang en 1127 | https://en.wikipedia.org/wiki/Southern_Song | CC BY-SA 4.0 | tertiaire / à recouper |
| 2026-10-24 | Fin des Tang, début des Liang postérieurs (907) | Wikipédia anglais, « Later Liang (Five Dynasties) » : abdication du dernier empereur Tang en 907 | https://en.wikipedia.org/wiki/Later_Liang_(Five_Dynasties) | CC BY-SA 4.0 | tertiaire / à recouper |
| 2026-10-24 | Fin des Yuan en Chine (1368) | Wikipédia anglais, « Yuan dynasty » : Dadu prise le 14 septembre 1368 | https://en.wikipedia.org/wiki/Yuan_dynasty | CC BY-SA 4.0 | tertiaire / à recouper |
| 2026-10-24 | Fondation traditionnelle de l'État ottoman (vers 1299) | Wikipédia anglais, « History of the Ottoman Empire » : date traditionnelle « vers 1299 » | https://en.wikipedia.org/wiki/History_of_the_Ottoman_Empire | CC BY-SA 4.0 | tertiaire ; date approximative |
| 2026-10-24 | Audit des frontières (comparaisons, aucune donnée modifiée) | Historical Basemaps (aourednik, lu seulement) ; Natural Earth pays 1:50 m ; Wikipédia « List of largest empires » ; Wikidata | https://github.com/aourednik/historical-basemaps ; https://en.wikipedia.org/wiki/List_of_largest_empires | GPL-3.0 (lu, rien copié) ; domaine public ; CC BY-SA 4.0 ; CC0 | voir `docs/chantiers/historique_audit_2026-10-24.md` |

## Méthode des dates (important)
- Convention : pour un événement de l'année D, la nouvelle situation s'affiche à partir de l'année D (l'ancienne jusqu'à D-1).
- Les FORMES ne changent pas : on avance ou recule seulement les bornes de chaque ligne. Entre l'ancien instantané et la date
  corrigée, c'est la forme de l'instantané suivant qui est affichée (approximation, pas un contour redessiné).
- Déductions : quand une entité naît plus tôt sur le territoire d'une autre qui s'arrêtait à l'instantané suivant, l'ancienne
  s'arrête la veille (même date, source de la naissance). Idem pour une reprise avancée (une seule entité reprend l'essentiel).
  Ces cas sont marqués « déduit » dans `scripts/historique/corrections_dates_rapport.json`.
- Les dates antérieures à l'an 1 ne sont pas utilisées (la convention d'écriture des années avant J.-C. de Wikidata n'a pas été vérifiée).
