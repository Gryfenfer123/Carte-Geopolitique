# Journal des décisions

Chaque ligne : une décision prise, sa date, sa raison, et où on la retrouve dans le dépôt.
**On n'y revient pas sans en discuter avec Martin.** Quand une nouvelle décision est prise,
on ajoute une ligne en bas (ne jamais réécrire l'historique : si une décision est remplacée,
on ajoute la nouvelle et on note « remplace … » dessus).

Les dates et les raisons ci-dessous viennent des commentaires du code, des migrations SQL et
des documents de session. Quand une date n'est pas connue, c'est indiqué.

| Date | Décision | Raison / contexte | Où |
|---|---|---|---|
| (prototype) | Carte à **vraies tuiles** (Leaflet) avec frontières des pays en superposition, au lieu de la projection SVG fixe D3 | Pouvoir zoomer et naviguer librement comme sur une carte en ligne | `README.md`, `src/main.ts`, `src/geobridge.ts` |
| (prototype) | Projet volontairement **minimal** : Vite + TypeScript, pas de framework | Garder le projet simple à reprendre | `package.json` |
| (prototype) | Données et comptes dans **Supabase** (authentification, dossiers pays) | Base partagée avec comptes utilisateurs | `src/supabase.ts`, `supabase/` |
| (déploiement) | Publication sur **GitHub Pages** sous `/Carte-Geopolitique/` | Hébergement statique gratuit. Sans le `base` dans Vite : page blanche et 404 sur le JS/CSS | `vite.config.ts`, `.github/workflows/deploy-pages.yml` |
| 2026-10-01 | Édition ouverte à tout compte connecté | Retour de Martin | `supabase/schema_v8.sql` — **remplacé ensuite**, voir ligne suivante |
| avant 2026-10-21 | Régime « **administrateur seul** » pour l'écriture dans l'appli | Cité dans schema_v28 comme existant « depuis schema_v13 ». **schema_v13 n'est pas dans le dépôt** : à vérifier dans Supabase | `supabase/schema_v28.sql`, `src/dossier.ts` (`isAdmin`) |
| 2026-10-02 | Deux fonds de carte seulement, tous deux Esri (sans clé API) : **Vectoriel** (gris sombre sans libellés) et **Satellite**. Le mode « Auto » (bascule automatique selon le zoom) a été **retiré à la demande de Martin** | Les fonds avec libellés affichent la langue d'origine, non modifiable sans clé | `src/main.ts` (commentaire au-dessus de `vectorLayer`) |
| 2026-10-02 | Pas de libellés de pays affichés en permanence sur la carte : nom au survol et dans la fiche seulement | Une fonctionnalité avait été inventée en trop lors du portage ; retirée | `docs/archive/PORT_STATUS-2026-10-02.md` |
| 2026-10-03 | Arbres généalogiques des dynasties, interactifs et pouvant croiser plusieurs pays | Demande de Martin | `src/genealogy.ts`, `supabase/schema_v11.sql` |
| 2026-10-06 | Carte historique (vue par époque, curseur) | Demande de Martin | `src/historicalMap.ts`, `supabase/schema_v20.sql` |
| 2026-10-14 | Un **groupe** a un dossier « plat » (pas de catégories/sous-catégories comme un pays) | Demande de Martin | `src/dossier.ts` |
| 2026-10-16 | Zones naturelles = **ellipses approximatives**, pas de vrais contours | Pas d'accès aux jeux de frontières géographiques réelles. Limite assumée et écrite dans le script | `scripts/gen_natural_zones.py` |
| 2026-10-16 → 21 | Indicateurs OWID chargés depuis des sources fiables (CIA Factbook, Banque mondiale, OMS/UNICEF, UNESCO, ITU, OCDE, FAS) via les pages Wikipédia « List of countries by … » | Le téléchargement direct des CSV OWID était bloqué dans l'environnement de travail | `public/data/raw/OWID_DATA.json`, `OWID_CATEGORIES.json` |
| 2026-10-21 | **4 indicateurs retirés** faute de source fiable à large couverture : `dette_publique_pct_pib`, `exportations_armement`, `scolarisation_secondaire`, `scolarisation_superieur` | On n'affiche pas de données inventées ou trop lacunaires | `public/data/raw/OWID_*.json` |
| 2026-10-21 | Export PNG : assemblage direct sur un `<canvas>`, **sans** `html2canvas` | `html2canvas` plaçait mal le calque SVG des pays | `src/compareExport.ts` |
| 2026-10-21 | **Frises : nouveau modèle** (période = sous-catégorie, événement lié à ≥ 1 fiche, une fiche par pays pour un événement commun, pas de frise mondiale) | Prototype abandonné, spécification validée | `docs/specs/frises-chronologiques.md` |
| 2026-10-22 | Arbres généalogiques : mise en page selon une échelle de dates ; membres d'un autre arbre « épinglés » | Demandes de Martin | `src/genealogyLayout.ts`, `supabase/schema_v36.sql` |
| 2026-10-22 | Suppression des copies mortes à la racine (`main.ts`, `dossier.ts`, `frise.ts`, `style.css`, `historicalMap.ts`, `leaflet-vectorgrid.d.ts`) | Restes d'uploads manuels, jamais utilisés par le build (sortie du build identique avant/après). Cause racine d'un incident : site déployé sur une version périmée pendant plusieurs jours | commit « Supprime les copies mortes… » |
| 2026-10-22 | Garde-fous automatiques : `npm run check:repo` + vérification à chaque push + TypeScript en mode `strict` | Ne plus dépendre de la parole d'une IA pour savoir si le dépôt est sain | `scripts/check-repo.mjs`, `.github/workflows/`, `tsconfig.json` |
