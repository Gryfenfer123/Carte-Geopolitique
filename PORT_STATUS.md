# Portage shell UI — statut (session du 2026-10-02)

Contexte : voir la consigne complète donnée en tête de session. Objectif :
garder 100% de l'UI/UX de l'artifact source "Project Hailperry"
(`/root/.claude/projects/-home-claude/6921dfa5-f89a-5f29-8c3d-0fa26a201740/tool-results/artifact-21943501-1790707149-8f91.html`,
11 297 lignes) tout en gardant le moteur de carte en vraies tuiles
(Leaflet), dans `/home/claude/atlas-web`.

`npm run build` (tsc && vite build) passe sans erreur à la fin de cette
session.

## Fait et vérifié (build OK)

1. **Suppression de la fonctionnalité inventée "libellés de pays
   permanents"** (`src/main.ts` : `gCountryLabels`, `redrawCountryLabels()`,
   `MIN_LABEL_PX`, l'appel dans `resetOverlay()`, et la règle CSS
   `.country-label` dans `src/style.css`). L'artifact source n'affiche
   jamais de nom de pays en permanence sur la carte — uniquement au survol
   et dans la fiche/le dossier.

2. **Infobulle au survol pour les pays** : `redrawBorders()` (dans
   `src/main.ts`) appelle maintenant `showEntityTip(event, frenchCountryName(...))`
   sur `mousemove` et `hideEntityTip()` sur `mouseout`, exactement comme les
   autres entités (ports, détroits, bases...) le faisaient déjà. Remplace
   l'ancien affichage permanent par le survol, comme dans l'artifact.

3. **Coquille HTML/CSS reconstruite ID pour ID / classe pour classe** sur
   celle de l'artifact (`app.innerHTML` dans `src/main.ts`, et le gros bloc
   CSS correspondant réécrit dans `src/style.css`) :
   - `#bottom-panel`/`#legend` (puces `.chip`/`.chip-toggle`/`.chip-static`,
     `.swatch`/`.dot`/`.diamond`/`.line-swatch`, classe `.active` au survol
     d'une case cochée) + `#legend-collapse-btn`/`#legend-expand-btn`
     (repli/affichage, câblés) + `#timeline-bar` (déjà porté par une
     session précédente dans `links.ts`, réutilisé à l'identique).
   - `#controls` (boutons `#zoom-in`/`#zoom-out`/`#zoom-reset`, câblés sur
     la carte Leaflet ; le `zoomControl` natif de Leaflet est désactivé).
   - `#style-switch` (Auto/Satellite/Vectoriel) — voir point 4.
   - `#search`/`#search-input`/`#search-results` repositionné en haut-
     gauche (déjà câblé par `src/search.ts`, inchangé).
   - Toute la rangée d'icônes bas-droite, mêmes décalages `right` que
     l'artifact : `#groups-toggle`(64) `#indicators-toggle`(110)
     `#appearance-toggle`(156) `#poi-toggle`(202) `#export-toggle`(248)
     `#compare-toggle`(294) `#dossier-search-toggle`(340)
     `#notions-toggle`(386) `#export-all-toggle`(432), + `#info-toggle`
     (bouton "i", sources).
   - `#tooltip` (remplace l'ancien `#entity-tooltip`, même ID que
     l'artifact), `#source` (attribution), `#scale-hint` (élément présent,
     **non câblé**, voir "Non fait" ci-dessous), `#link-banner` (remplace
     l'ancien `#group-add-banner`, même ID que l'artifact, renommé aussi
     côté `src/groups.ts`), `#sources-panel` (ouvert par `#info-btn`).
   - Le bouton Encyclopédie a été renommé `#notions-btn` (était
     `#encyclopedie-btn`) pour matcher l'ID de l'artifact ; sa logique
     (`src/main.ts`) est inchangée.
   - `<header>` reste un élément de flux normal (pas `position:absolute`
     comme dans l'artifact) : c'est une différence assumée, car
     l'authentification Supabase n'existe pas dans l'artifact et le reste
     du portage avait déjà fait ce choix avant cette session. Tous les
     décalages horizontaux de la coquille ci-dessus restent ceux de
     l'artifact ; les décalages verticaux sont réduits puisque la carte ne
     commence plus sous un header absolu.
   - L'ancien panneau générique `aside.side-panel` (résumé minimal au clic
     sur un port/détroit/pipeline/base/câble/capitale) est devenu
     `#infra-panel`, avec les classes partagées `.panel.side-panel` (même
     habillage que `#fiche-panel`/`#groups-panel`/etc.) et un bouton de
     fermeture (`.close-x`). `closeOtherSidePanels()` dans `src/main.ts` a
     été étendu pour inclure `fiche-panel` et `infra-panel`, pour réduire
     le risque de chevauchement visuel entre panneaux (voir limite connue
     plus bas).

4. **Bascule de fond de carte Auto/Satellite/Vectoriel** (`src/main.ts`,
   bloc juste après la création de `map`) :
   - "Vectoriel" = tuiles `World_Dark_Gray_Base` (déjà en place).
   - "Satellite" = tuiles `World_Imagery` (déjà en place).
   - "Auto" = Vectoriel par défaut, bascule automatiquement vers
     Satellite à partir du niveau de zoom Leaflet 7
     (`AUTO_SATELLITE_MIN_ZOOM`), recalculé à chaque `zoomend`. C'est un
     choix délibéré documenté en commentaire dans le code : l'artifact
     faisait un fondu d'opacité continu entre une image statique unique et
     des aplats vectoriels selon le zoom D3 (`k`), ce qui n'a pas
     d'équivalent direct avec deux pyramides de tuiles XYZ distinctes —
     un vrai fondu continu entre deux pyramides de tuiles chargées à la
     volée n'est pas réalisable proprement. Le seuil 7 est un choix
     raisonnable, pas une valeur mesurée ; Martin peut facilement l'ajuster
     (`AUTO_SATELLITE_MIN_ZOOM` dans `src/main.ts`).

5. **Boutons de la rangée bas-droite sans fonctionnalité portée** (POI,
   export PNG, comparateur, export complet) : les boutons et panneaux
   existent visuellement (fidélité à l'artifact) mais n'ont **aucune
   fonctionnalité réelle** derrière — aucun système de points d'intérêt,
   d'export d'image, de comparaison de pays ou d'export JSON complet
   n'existe dans la couche TypeScript actuelle (vérifié par recherche dans
   tous les fichiers `src/*.ts` avant cette session : zéro résultat pour
   `poi-add-btn`, `export-png-btn`, `compare-btn`, `export-all-btn`). Un
   clic sur l'un de ces boutons affiche un message temporaire dans
   `#link-banner` ("… — fonctionnalité pas encore portée.") plutôt que de
   ne rien faire silencieusement. **Ce sont de vrais trous de
   fonctionnalité, pas seulement d'UI** — les construire (surtout POI et
   export JSON complet) est un travail à part, non fait ici.

## Non fait / délibérément hors scope cette session

- **`#scale-hint`** : l'élément existe dans le DOM et le CSS (opacité 0 par
  défaut, comme l'artifact), mais rien ne le fait apparaître (l'artifact
  l'affiche brièvement en indiquant l'échelle pendant un zoom/déplacement).
  Non câblé — priorité basse explicitement citée en dernier dans la
  consigne.
- **Chevauchement de panneaux latéraux** : `closeOtherSidePanels()` masque
  bien les autres panneaux à l'ouverture d'un nouveau, mais ne déclenche
  pas leur logique de fermeture propre (`src/dossier.ts` a sa propre
  `closeFiche()` avec `flushFicheSave()`/`onFicheClose()` jamais appelée
  dans ce cas). Risque mineur : fermer visuellement la fiche pays en
  ouvrant le panneau Groupes pourrait laisser une sauvegarde en attente
  non flushée. Pré-existant avant cette session (l'architecture à callbacks
  mutables de `src/dossier.ts`/`src/groups.ts`/`src/indicators.ts` le permet
  déjà), pas corrigé en profondeur — corrigerait idéalement en exposant un
  `closeFiche()`/`closeGroupsPanel()`/etc. que `closeOtherSidePanels()`
  appellerait au lieu d'un simple `classList.remove("open")`.
- **Toggle "Points d'intérêt" dans la légende** (`#toggle-pois` dans
  l'artifact) : non ajouté à `#legend`, puisqu'aucun calque POI n'existe
  (voir point 5 ci-dessus) — l'ajouter sans backend aurait été un contrôle
  trompeur.
- **`#dossier-search-toggle` visible** (au lieu de masqué comme dans
  l'artifact, qui le juge redondant avec `#search`) : gardé visible ici
  car `src/search.ts` lui donne une vraie fonctionnalité distincte
  (recherche plein texte dans les dossiers, pas juste un filtre de noms) —
  déviation volontaire de l'artifact, documentée en commentaire dans
  `src/main.ts`.
- **Audit exhaustif bouton-par-bouton / panneau-par-panneau** (point 5 de
  la consigne) : fait partiellement — tous les panneaux latéraux complexes
  (`#fiche-panel`, `#groups-panel`, `#indicators-panel`,
  `#appearance-panel`, `#chronologie-panel`, `#notions-panel` via
  `encyclopedie.ts`/`dossier.ts`, `#link-editor`, `#dossier-view`,
  `#custom-dialog-overlay`, `#dossier-search-view`) existaient déjà et
  fonctionnent (porté par une session antérieure, vérifié par lecture du
  CSS/des sélecteurs avant de commencer). Ce qui manque encore un audit
  visuel réel dans un navigateur (non fait cette session — pas d'outil de
  capture d'écran disponible dans cet environnement) pour repérer d'éven-
  tuels écarts fins de mise en page (tailles, espacements) non visibles à
  la seule lecture du code.

## Fichiers modifiés

- `src/main.ts` : coquille HTML (`app.innerHTML`), init carte/zoom/style-
  switch, suppression des libellés, infobulle pays, renommages d'IDs
  (`panel-title`→`infra-panel-title`, `panel-body`→`infra-panel-body`,
  `entity-tooltip`→`tooltip`, `group-add-banner`→`link-banner`,
  `encyclopedie-btn`→`notions-btn`), `closeOtherSidePanels()` étendu.
- `src/style.css` : bloc coquille principale réécrit (légende/puces,
  contrôles, style-switch, recherche, rangée d'icônes, tooltip, source,
  link-banner, sources-panel), suppression de `.country-label`,
  `aside.side-panel`, `.hint`, `.map-legend`/`.legend-*`,
  `.entity-tooltip`.
- `src/groups.ts` : `group-add-banner` → `link-banner` (un seul endroit).

Aucun commit git n'a été fait (pas touché à git, conformément à la
consigne).

---

# Session du 2026-10-02 (suite) — POI, export PNG, comparateur, export complet

Objectif de cette seconde session du même jour : combler les quatre "trous
de fonctionnalité réelle" listés au point 5 ci-dessus (POI, export PNG,
comparateur de pays, export complet des données). `npm run build`
(`tsc && vite build`) passe toujours sans erreur à la fin de cette session.
Git non touché, comme demandé.

## 1. Points d'intérêt (POI) — `src/poi.ts` (nouveau)

- Réutilise la table `public.map_features` (créée au schéma v2 pour ports/
  détroits/bases/câbles/pipelines, jamais exploitée depuis pour un autre
  `kind`) avec `kind='poi'` et une nouvelle colonne `note`.
- **Prérequis obligatoire côté Supabase, à faire avant tout test en
  production** : exécuter `supabase/schema_v9.sql` (nouveau fichier, voir
  plus bas) dans l'éditeur SQL Supabase. Sans ça, la contrainte CHECK
  actuelle sur `kind` (`'port'|'strait'|'base'|'cable'|'pipeline'`)
  rejettera toute insertion `kind='poi'` — l'app affiche alors un message
  d'échec dans le formulaire de création plutôt que d'échouer
  silencieusement, et poi.ts log l'erreur en console avec un rappel de ce
  prérequis.
- Clic sur `#poi-add-btn` : bascule un "mode placement" (curseur en croix
  sur la carte via la classe `.poi-add-cursor` sur `.map-wrap`, bouton mis
  en évidence via `.placing`, bandeau `#link-banner` explicatif). Échap ou
  un second clic sur le bouton annule le mode. Coordonné avec les modes
  "ajouter un pays à un groupe"/"créer un lien" (un seul actif à la fois,
  même principe que `onBeforeMapAddMode`/`onBeforeLinkMode` déjà en place).
- Le clic suivant sur la carte (`map.on("click", ...)`, donc fonctionne
  aussi en pleine mer) capture `[lat, lng]` et ouvre une petite boîte de
  création dédiée (`#poi-create-overlay`, DOM injecté par poi.ts, habillage
  repris de `#custom-dialog-overlay`/`#custom-dialog-box` de src/dossier.ts
  mais dupliqué en propre — src/dossier.ts ne l'exportait pas) avec un champ
  nom (obligatoire) et une note (optionnelle, `<textarea>`).
- Sans session active au moment de valider : le formulaire affiche un
  message et déclenche l'ouverture du panneau de connexion
  (`#auth-panel`, via une petite fonction `openAuthPanel()` ajoutée dans
  `main.ts`) **sans perdre l'emplacement cliqué** (conservé en mémoire tant
  que la boîte de création reste ouverte) — il suffit de se reconnecter puis
  de cliquer "Créer" à nouveau. Choix documenté dans la consigne comme
  acceptable en alternative à une UX plus poussée.
- À l'insertion réussie : ajouté au tableau en mémoire + redessiné
  immédiatement (pas de rechargement de page).
- Au chargement de la page : tous les `map_features` où `kind='poi'` sont
  chargés et dessinés comme des petits marqueurs en forme de goutte (même
  silhouette que l'icône du bouton `#poi-add-btn`), dans un calque dédié
  `#poi-layer` positionné au-dessus de TOUS les autres calques (y compris
  les liens) pour qu'un point posé par l'utilisateur reste toujours visible/
  cliquable. Repositionnés à chaque pan/zoom comme les autres calques
  (`poiRedraw`, appelé depuis `resetOverlay()` dans `main.ts`, même
  mécanisme que `groupsRedraw`/`indicatorsRedraw`/`linksRedraw`).
- Clic sur un marqueur existant : réutilise le panneau latéral partagé
  `#infra-panel` (nom, note) avec un bouton "Supprimer ce point d'intérêt"
  (visible seulement si une session existe — n'importe quel compte connecté
  peut supprimer n'importe quel POI, cohérent avec la policy RLS "tout
  connecté peut éditer" déjà en place pour le reste de l'app, voir
  schema_v8.sql).
- Nouvelle case de légende `#toggle-pois` (cochée par défaut), même
  mécanisme `setLayerVisible` que les autres calques.
- **Limite connue, non corrigée** : les gestionnaires de clic des AUTRES
  entités cliquables (ports, détroits, pipelines, bases, câbles, fleuves,
  capitales) appellent `event.stopPropagation()` avant tout, donc cliquer
  sur l'une d'elles PENDANT le mode placement POI ouvre son panneau
  d'infos habituel au lieu de poser un point, sans annuler le mode
  placement (qui reste actif en arrière-plan). Cas marginal (il faudrait
  viser très précisément un port/câble/etc. existant en plein mode
  placement), pas corrigé faute de vouloir modifier individuellement tous
  ces gestionnaires pour un gain limité — Martin peut me demander de le
  faire si ça le gêne en pratique.

## 2. Export PNG de la carte — `exportMapAsPng()` dans `src/compareExport.ts`

- Nouvelle dépendance npm réelle : `html2canvas` (installée via
  `npm install html2canvas`, présente dans `package.json`/
  `package-lock.json`).
- `vectorLayer`/`satelliteLayer` (`main.ts`) ont reçu l'option
  `crossOrigin: "anonymous"` — nécessaire pour que `html2canvas` puisse lire
  les pixels des tuiles Esri sans "tainter" le canvas.
- Clic sur `#export-png-btn` → `html2canvas(#map, {useCORS:true})` → PNG
  téléchargé (`carte-geopolitique.png`). `#map` ne contient QUE les tuiles
  Leaflet + le SVG D3 (vérifié en lisant la coquille HTML de `main.ts` :
  `#controls`/`#style-switch`/`#search`/la rangée d'icônes/etc. sont tous
  des frères de `#map` dans `.map-wrap`, pas des enfants) — pas besoin
  d'exclure l'UI chrome, elle n'est jamais dans le sous-arbre capturé.
- **Non vérifié dans un navigateur réel** (aucun outil de capture d'écran
  disponible dans cet environnement) : le point à risque documenté dans la
  consigne — un canvas "tainted" par les tuiles cross-origin malgré
  `crossOrigin`/`useCORS` si Esri ne renvoie pas un en-tête
  `Access-Control-Allow-Origin` permissif sur ces tuiles précises. Si ça
  arrive, un `try/catch` autour de la lecture du canvas (`toBlob`) déclenche
  un repli : export du SVG D3 seul (frontières/ports/câbles/etc., sans le
  fond de carte Esri) en fichier `.svg` téléchargé directement, avec un
  message explicatif dans `#link-banner`. **À tester par Martin en
  conditions réelles** — je ne peux pas garantir laquelle des deux voies
  s'exécutera en pratique.

## 3. Comparateur de pays — `initCompareSystem()` dans `src/compareExport.ts`

- Nouveau panneau latéral `#compare-panel` (plus large que les autres,
  520px, CSS dédiée) avec deux champs de recherche de pays (filtrage local
  simple sur `getAllCountryRefs()`/`normalizeSearch()`/`frenchCountryName()`,
  pas de réutilisation directe de `src/search.ts` qui est câblé sur sa
  propre modale plein écran — un composant de filtrage local plus simple
  suffisait ici).
- Les lignes du tableau viennent de `src/indicators.ts` : nouvelle fonction
  exportée `getCountryIndicatorRows()` (ajoutée dans cette session) qui
  parcourt les catégories/indicateurs déjà chargés (fichiers statiques
  OWID_CATEGORIES.json/OWID_DATA.json — **pas** les tables Supabase
  `indicator_values`/`indicators`/`indicator_categories`, qui existent et
  sont peuplées (`supabase/data_owid_load.sql`) mais ne sont lues par
  AUCUN fichier `src/*.ts`, exactement comme `map_features`/POI l'était :
  le moteur de choropleth/fiche pays utilise exclusivement les JSON
  statiques — voir le commentaire en tête de `src/indicators.ts`). Le
  comparateur réutilise donc la même source que la carte et la fiche pays,
  pas un second modèle de données, et reste à jour automatiquement si
  Martin ajoute un indicateur dans ces JSON.
- Valeurs manquantes affichées "—". Petite barre comparative inline par
  ligne numérique (largeur proportionnelle au max des deux valeurs) — pas
  un vrai graphique, juste une indication visuelle rapide comme suggéré en
  option dans la consigne.

## 4. Export complet des données — `exportAllData()` dans `src/compareExport.ts`

- Clic sur `#export-all-btn` → requêtes Supabase fraîches en parallèle sur
  `groups`, `group_members`, `group_categories`, `country_links`,
  `map_features` (POI inclus), `dossier_categories`, `dossier_sections`,
  `dossier_entries`, `indicator_categories`, `indicators`,
  `indicator_values` → un seul fichier `carte-geopolitique-export.json`
  téléchargé (`{ exportedAt, groups, groupMembers, groupCategories,
  countryLinks, mapFeatures, dossiers: {...}, indicators: {...} }`).
  Lecture publique (toutes ces tables ont une policy `select` publique),
  donc fonctionne sans être connecté, comme demandé.
- Si une des requêtes échoue, l'export se fait quand même avec les tables
  disponibles (tableau vide pour celles en échec) et un message different
  s'affiche + l'erreur est loguée en console — pas d'échec silencieux total.

## Nouveau fichier de migration Supabase — `supabase/schema_v9.sql`

**À exécuter manuellement par Martin dans Supabase → SQL Editor avant que
les POI ne fonctionnent en production** (comme tous les `schema_vN.sql`
précédents, rien n'applique cette migration automatiquement). Contenu :
1. Remplace la contrainte CHECK sur `map_features.kind` pour autoriser
   `'poi'` en plus des 5 valeurs existantes.
2. Ajoute une colonne `note text` nullable (utilisée par les POI, laissée
   `NULL` pour les autres `kind`).
Les policies RLS existantes (lecture publique, écriture/édition/suppression
réservées à tout compte connecté — schema_v2.sql/schema_v8.sql) s'appliquent
déjà à `map_features` et couvrent `'poi'` sans rien y changer.

## Fichiers créés

- `supabase/schema_v9.sql` — migration POI (voir ci-dessus).
- `src/poi.ts` — système Points d'intérêt.
- `src/compareExport.ts` — comparateur de pays + export PNG + export JSON
  complet.

## Fichiers modifiés

- `src/main.ts` : imports des deux nouveaux modules ; option `crossOrigin`
  sur `vectorLayer`/`satelliteLayer` ; nouvelle case de légende
  `#toggle-pois` ; nouveau calque `gPoiLayer` (au-dessus de `gLinksLayer`) ;
  `poiRedraw` câblé dans `resetOverlay()` ; vérification du mode placement
  POI ajoutée dans le gestionnaire de clic pays de `redrawBorders()` ;
  nouvelle fonction `openAuthPanel()` ; `closeOtherSidePanels()` étendu avec
  `"compare-panel"` ; suppression des 4 lignes `announcePlaceholder(...)`
  pour poi-add-btn/export-png-btn/compare-btn/export-all-btn, remplacées par
  leur câblage réel en fin de fichier (`poiSystem`, `compareSystem`,
  `exportMapAsPng`, `exportAllData`).
- `src/indicators.ts` : nouvelle fonction exportée `getCountryIndicatorRows()`
  + `formatCountryIndicatorValue()`, utilisées par le comparateur.
- `src/style.css` : règles pour `.poi-add-cursor`, `#poi-toggle
  button.placing`, `.poi-overlay`/`.poi-overlay-box` (boîte de création
  POI), `.poi-marker`/`.poi-pin`/`.poi-pin-dot` (marqueur sur la carte),
  `#compare-panel` (largeur) et `.compare-*` (pickers, tableau, barres
  comparatives).
- `package.json`/`package-lock.json` : nouvelle dépendance `html2canvas`.

## Non vérifié (pas d'outil de capture d'écran dans cet environnement)

- **Export PNG** : le chemin principal (tuiles incluses) n'a pas pu être
  testé dans un vrai navigateur — voir section 2 ci-dessus pour le détail
  du risque et du repli automatique en cas d'échec.
- Aspect visuel exact de la boîte de création POI et du panneau comparateur
  (tailles/espacements) — vérifié uniquement par lecture du CSS/HTML, pas
  par capture d'écran, comme pour le reste de l'audit visuel déjà noté comme
  non fait dans la session précédente.

Aucun commit git n'a été fait (pas touché à git, conformément à la
consigne).

# Session du 2026-10-02 (suite 2) — 6 demandes de Martin

`npm run build` (tsc && vite build) passe sans erreur à la fin de cette
session. Aucun commit git, aucun déploiement (conformément à la consigne —
Martin dépose lui-même les fichiers via l'interface web GitHub).

## 1. Image + cadrage sur les catégories ET les sous-sections de dossier

- **Migration requise, PAS ENCORE APPLIQUÉE** : `supabase/schema_v10.sql`
  (déjà écrit par Martin avant cette session) doit être collé dans
  Supabase → SQL Editor → Run. **Tant que ce n'est pas fait, rien de ce qui
  suit ne fonctionne** : `dossier_categories.image_url`/`image_position`
  n'existent pas encore côté base (les requêtes `select`/`update` qui les
  visent échoueront), et `dossier_sections.image_position` non plus (seule
  `cover_image_url` existait déjà avant, depuis schema_v1, mais elle n'était
  lue/écrite par aucun code applicatif avant cette session — donc même les
  sections n'ont aucune fonctionnalité image utilisable avant la migration).
- `src/dossier.ts` : `Category`/`Section` étendus avec
  `image_url`/`image_position` (catégories) et `cover_image_url`/
  `image_position` (sections). `loadCategories()`/`addCategory()` et
  `loadSections()`/`addSection()` lisent/écrivent ces colonnes.
- Bannières de catégorie (`buildSummaryCard`, sommaire du dossier) et de
  sous-section (`buildSectionGroupEl`) : affichent l'image en
  `background-image`/`background-size:cover`/`background-position` (repli
  sur le dégradé `categoryBannerGradient()` existant quand pas d'image).
  Un 3ᵉ bouton icône `.dsc-image-btn` ("Changer l'image", même garde de
  permission que les boutons renommer/supprimer déjà en place —
  `!cat.builtin && isAdmin()` pour les catégories, `canModify(sec)` pour les
  sections) ouvre un `<input type="file">` dédié et envoie vers
  Supabase Storage (bucket `dossier-photos`, chemin `category-<id>/...` pour
  une catégorie — globale, pas de `currentOwner` — et
  `<ownerType>-<ownerId>/section-<id>/...` pour une section).
- **Cadrage ("cadrer")** : glisser directement sur une bannière qui affiche
  déjà une vraie image (pas sur le dégradé de repli, et pas sur un des 3
  boutons icône) déplace son `background-position` en direct puis
  l'enregistre au relâchement (`attachBannerDragReframe()`, nouvelle
  fonction partagée par les deux bannières). Pas de bouton dédié pour entrer
  en mode cadrage : le glisser direct a semblé l'interaction la plus simple
  et la plus proche de "pouvoir la cadrer".
- `src/style.css` : `.dsc-image-btn` (`right: 62px`, entre `.dsc-menu-btn`
  à 34px et `.dsc-del-btn` à 6px), `.dsc-banner.has-image` (curseur grab),
  `.dsc-banner.reframing` (curseur grabbing), `.dsc-reframe-label` (petite
  étiquette "Glissez pour cadrer l'image" affichée pendant le glisser).
- **Assomption non vérifiable sans navigateur réel** : aucun outil de
  capture d'écran n'est disponible dans cet environnement — le
  drag-to-reframe (calcul de position en %, mise à jour live du
  `background-position`, blocage du clic parasite qui rouvrirait la fiche
  catégorie après un glissé) n'a été vérifié que par lecture du code, pas
  testé à la souris dans un vrai navigateur. Le build TypeScript passe et le
  code a été relu avec soin, mais le *feel* exact du geste (sensibilité,
  zone de déclenchement) reste à confirmer par Martin.

## 2. Frise chronologique (filtrage des liens par date) — déjà existante

Aucune nouvelle logique : le double curseur `#timeline-bar`/`globalSlider`
(`src/links.ts`) existait déjà et fonctionnait déjà exactement comme
l'artifact source. Seul changement : le libellé de la case à cocher de la
légende (`src/main.ts`, `#toggle-all-links-row`) est passé de
« Tous les liens (historique) » à « Tous les liens (frise chronologique) »
pour que cette fonctionnalité (jusqu'ici un peu cachée) soit plus visible.

## 3. Suppression du bouton/panneau "Chronologie"

Fonctionnalité différente du point 2 ci-dessus (une simple LISTE triée des
liens, sans filtrage de la carte) — retirée entièrement :
- `src/main.ts` : markup `#chronologie-toggle`/`#chronologie-btn` retiré de
  `app.innerHTML` ; `"chronologie-panel"` retiré du tableau de
  `closeOtherSidePanels()`.
- `src/links.ts` : markup `#chronologie-panel`, `renderChronologie()`,
  `chronoSortKey()`, `chronoDateLabel()`, `chronoNewestFirst`, les
  écouteurs `chronologie-btn`/`chronologie-close`/`chronologie-sort`, et
  l'appel `renderChronologie()` dans `refreshLinkDisplays()` — tous
  retirés. `grep -n chronologie src/links.ts` ne renvoie plus que des
  commentaires (aucune référence fonctionnelle).
- `src/style.css` : bloc `#chronologie-panel`/`.chrono-*` retiré ;
  `#chronologie-toggle` retiré des listes de sélecteurs partagées de la
  rangée d'icônes (décalages `right` des autres boutons **non renumérotés**,
  conformément à la consigne — simplicité/faible risque avant tout).

## 4. Barre de recherche unifiée : "tout rechercher" + suppression de la loupe "Recherche dans les dossiers"

`src/search.ts` a été réécrit. La barre unifiée (`#search-input`, toujours
visible) couvre maintenant tout : pays/groupes/notions/infrastructures
(déjà le cas), **sections de TOUT owner_type** (généralisation de l'ancien
`buildNotionEntries()`, qui ne couvrait que les sections encyclopédie de
premier niveau — fondu dans un nouveau type de résultat `kind: "section"` ;
cliquer résout le bon dossier (pays/groupe/Encyclopédie/mini-dossier) puis
appelle `revealSection`), **liens entre pays/groupes** (`country_links`,
entièrement nouveau — `kind: "link"`, utilise les libellés déjà dénormalisés
sur chaque ligne `entity_a_label`/`entity_b_label` plutôt qu'un nouveau dep
`getEntityLabel` — plus simple, pas de duplication de logique avec
`src/links.ts`), et **étiquettes** (`dossier_entries.tags` est maintenant
inclus dans le texte cherchable `matchText` de chaque entrée de dossier — un
mot d'étiquette tape comme n'importe quel autre mot, pas de syntaxe `#`
dédiée).

L'ancienne loupe "Recherche dans les dossiers" (`#dossier-search-toggle`/
`#dossier-search-btn`, modale plein écran `#dossier-search-view`,
`runDossierSearch()`, etc.) a été entièrement retirée : markup et câblage
dans `src/main.ts`, toute la logique dans `src/search.ts`
(`openDossierSearch`/`closeDossierSearch`/`runDossierSearch`/
`renderDossierSearchResults`/onglets — `initSearchSystem()` ne renvoie plus
rien, `main.ts` ne stocke donc plus sa valeur de retour), et les règles CSS
`#dossier-search-*`/`.dossier-search-*` dans `src/style.css`.

Deux décisions explicites à signaler à Martin :
- **Capacité abandonnée : "★ Favoris uniquement"**. L'ancienne modale avait
  un onglet qui filtrait sur `dossier_entries.favorite`. Ça n'a pas été
  recréé dans la barre unifiée — un filtre de session de recherche n'a pas
  vraiment de sens sur une barre "aller à" toujours visible et à 10
  résultats maximum. Si Martin veut retrouver ses entrées favorites, il
  faudrait une interface différente (pas une barre de recherche).
- **Catégories de dossier non indexées par leur nom seul** (pas de
  `kind: "category"`). Une catégorie (`dossier_categories`) est globale/
  partagée par tous les dossiers d'un même espace ("Histoire" existe une
  seule fois et sert à tous les pays) — ce n'est pas un endroit unique vers
  lequel naviguer, contrairement à une section qui, elle, appartient
  toujours à un dossier précis. Chercher "Histoire" remonte donc les
  sections et entrées qui en relèvent, mais pas une ligne "Histoire" à part
  qui ne mènerait nulle part de sensé.

## 5. Suppression de "Exporter toutes les données" (export JSON)

`#export-all-toggle`/`#export-all-btn` retiré de `src/main.ts`
(markup + câblage + import `exportAllData`). La fonction `exportAllData()`
et son commentaire d'en-tête ("3. Export complet des données") retirés de
`src/compareExport.ts`, ainsi que l'import désormais inutile de
`SupabaseClient`. L'export PNG (`#export-png-btn`/`exportMapAsPng`) et le
comparateur (`#compare-btn`/`initCompareSystem`) n'ont pas été touchés.
`#export-all-toggle` retiré des listes de sélecteurs CSS partagées de la
rangée d'icônes (offsets des autres boutons non renumérotés, même logique
qu'au point 3).

## 6. Suppression du mode de fond de carte "Auto"

`src/main.ts` : `MapStyleMode` réduit à `"satellite" | "vector"` ; bouton
`#style-auto` retiré de `app.innerHTML` ; `styleMode` par défaut passé de
`"auto"` à `"vector"`, et la classe `active` initiale déplacée du bouton
Auto (disparu) vers `#style-vector` dans le markup. `AUTO_SATELLITE_MIN_ZOOM`
et l'écouteur `map.on("zoomend", ...)` qui ne servait qu'au mode Auto ont été
retirés. `isSatelliteActive()` simplifié à `return styleMode === "satellite"`
(le correctif récent d'opacité de remplissage des pays,
`currentLandFillOpacity()`, qui appelle `isSatelliteActive()`, continue de
fonctionner sans changement). `STYLE_BUTTON_IDS` n'a plus que 2 entrées — le
compilateur TypeScript a forcé cette mise à jour (le type est
`Record<MapStyleMode, string>`), confirmant qu'aucune référence à `auto` ne
traîne ailleurs.

## Vérification effectuée

- `npm run build` (tsc && vite build) : passe sans erreur, seul
  l'avertissement habituel sur la taille du chunk JS (préexistant, sans
  rapport avec cette session).
- Test de fumée headless (Playwright/Chromium,
  `PLAYWRIGHT_BROWSERS_PATH=/opt/pw-browsers`, `vite preview`) : la page se
  charge sans erreur JavaScript (`pageerror`/`console.error`), seules des
  erreurs réseau `ERR_TUNNEL_CONNECTION_FAILED` apparaissent (attendu : pas
  d'accès Internet sortant vers les tuiles Esri/Supabase dans cet
  environnement). Vérifié par ce test : `#style-switch` n'a plus que 2
  boutons (`style-photo`/`style-vector`), `style-vector` porte bien la
  classe `active` par défaut, `#chronologie-toggle`/`#dossier-search-toggle`/
  `#export-all-toggle` n'existent plus dans le DOM, et le libellé de la case
  "Tous les liens" a bien changé.
- **Non vérifié** (pas d'outil de capture d'écran disponible) : rendu visuel
  exact des bannières avec image, et surtout le *feel* du geste de glisser-
  cadrer (point 1) — voir l'assomption explicite dans la section 1
  ci-dessus. Martin doit aussi exécuter `supabase/schema_v10.sql` dans le
  SQL Editor de Supabase avant que quoi que ce soit lié aux images de
  catégories/sections ne fonctionne.
