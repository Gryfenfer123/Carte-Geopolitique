# Architecture

Document destiné à toute personne (ou IA) qui reprend le projet. À mettre à jour **dans le même
commit** que tout changement de structure (nouveau module, nouvelle table, nouveau flux).

## Vue d'ensemble

```
Navigateur (site statique Vite + TypeScript, sans framework)
 ├─ Carte : Leaflet (tuiles) + calque SVG D3 par-dessus (frontières, liens, ports…)
 ├─ Données statiques : public/data/*.json  → chargées par fetch() au démarrage
 └─ Données vivantes  : Supabase (comptes, dossiers, groupes, généalogie, frises…)
                         └─ sécurité = règles RLS en base (voir BASE_DE_DONNEES.md)

GitHub (branche main) ──push──▶ GitHub Actions : vérifie + construit ──▶ GitHub Pages
                                                  (https://<compte>.github.io/Carte-Geopolitique/)
```

- Il n'y a **pas de serveur à nous** : tout tourne dans le navigateur, la base est chez Supabase.
- Le site est publié sous un sous-dossier : ne jamais écrire de chemin absolu `/data/...` ;
  toujours `import.meta.env.BASE_URL + "data/..."` (sinon page blanche en production).

## Pile technique

| Élément | Choix | Remarque |
|---|---|---|
| Construction | Vite 8 + TypeScript 6 | `npm run build` = `tsc` puis `vite build` |
| Carte | Leaflet 1.9 + leaflet.vectorgrid | fonds Esri « World_Dark_Gray_Base » et « World_Imagery » |
| Dessin | D3 7 + topojson-client | calque SVG recalé sur Leaflet par `geobridge.ts` |
| Données | @supabase/supabase-js | authentification + tables + stockage de photos |
| Export image | `html-to-image` (frises) ; assemblage `<canvas>` direct (carte) | `html2canvas` abandonné, voir `DECISIONS.md` |
| Hébergement | GitHub Pages | workflow `.github/workflows/deploy-pages.yml` |

## Organisation du dépôt

```
index.html                 page unique ; charge /src/main.ts
src/                       TOUT le code TypeScript et le CSS (rien d'autre à la racine)
public/data/               données statiques copiées telles quelles dans le site
  countries.geojson          frontières des pays
  raw/*.json                 indicateurs, ports, câbles, pipelines, bases, villes, noms FR, drapeaux…
supabase/                  migrations SQL (exécutées à la main par Martin)
scripts/                   outils hors site (génération de données, vérification du dépôt)
docs/                      cette documentation ; docs/specs = spécifications validées ; docs/archive = historique
.github/workflows/         déploiement + vérifications automatiques
```

Règle : **le code vit uniquement dans `src/`**. `tsconfig.json` n'inclut que `src/`, et
`npm run check:repo` refuse tout fichier source à la racine (c'est ce qui avait causé le site
périmé : des copies à la racine étaient ignorées par le build).

## Les modules de `src/`

| Fichier | Rôle | Taille* |
|---|---|---|
| `main.ts` | Point d'entrée : construit l'interface, crée la carte Leaflet, branche tous les modules ci-dessous, gère connexion, mode lecture, favoris | 2 164 |
| `style.css` | Tout l'habillage visuel | 2 573 |
| `geobridge.ts` | Pont D3 ⇄ Leaflet (projection des coordonnées) | 36 |
| `supabase.ts` | Création du client Supabase à partir des variables `VITE_…` | 20 |
| `dossier.ts` | **Cœur** : fiche pays, dossiers (catégories → sous-catégories → entrées texte / photo / lien / hémicycle / généalogie / frise), recadrage d'images, permissions (`isAdmin`) | 4 487 |
| `sanitize.ts` | Liste blanche du texte riche — **la frontière de sécurité contre le HTML dangereux** | 231 |
| `groups.ts` | Groupes géopolitiques (OTAN, BRICS…) et leurs surbrillances | 865 |
| `indicators.ts` | Indicateurs (carte colorée + valeurs dans la fiche), depuis les JSON statiques | 560 |
| `links.ts` / `linkIndex.ts` | Liens entre pays/groupes tracés sur la carte ; index global de toutes les entités nommées | 916 / 194 |
| `search.ts` | Barre de recherche (noms + contenu des dossiers) | 734 |
| `encyclopedie.ts` | Encyclopédie (notions), semis initial | 95 |
| `genealogy.ts` / `genealogyLayout.ts` | Arbres généalogiques interactifs ; mise en page par échelle de dates | 2 652 / 424 |
| `genealogyRouting.ts` | Tracé des liens : lignes brisées qui contournent les cartes (logique pure) | ~150 |
| `frise.ts` / `friseModel.ts` | Frises chronologiques (interface) / logique pure (dates, périodes, largeurs) | 2 465 / 267 |
| `historicalMap.ts` | Carte historique par époque (OpenHistoricalMap) | 310 |
| `poi.ts` | Points d'intérêt posés sur la carte | 459 |
| `compareExport.ts` | Comparateur de pays, export PNG de la carte, export JSON complet | 466 |
| `countryNames.ts` | Noms français des pays et drapeaux | 74 |
| `imageCrop.ts` | Outil de recadrage d'image | 195 |

\* lignes, au 2026-10-22.

### Comment les modules se parlent

Chaque grand module expose une fonction `initXxxSystem(...)` appelée depuis `main.ts`, à laquelle
on passe des **fonctions de rappel** (callbacks : session courante, profil, fermeture des autres
panneaux, redessin…). Il n'y a pas de gestionnaire d'état central : l'état vit dans les
modules et dans le DOM. Conséquence à connaître : ajouter une fonctionnalité qui touche
plusieurs panneaux oblige à modifier `main.ts` et les `init…` concernés.

### Données : deux sources, des rôles distincts

- **Statique** (`public/data/raw/*.json`) : référentiels qui changent rarement (indicateurs
  OWID, ports, détroits, pipelines, câbles, bases militaires, villes, fleuves, zones naturelles,
  noms français, drapeaux). Modifiés par commit. Pour un indicateur : source et couverture à
  noter (voir `CONVENTIONS.md`).
- **Vivante** (Supabase) : tout ce que Martin saisit (dossiers, groupes, liens, généalogie,
  frises, POI). Modifiée depuis l'interface.

### Droits côté navigateur

`isAdmin()` (dans `dossier.ts`) = profil avec `role = 'admin'` **et** mode lecture désactivé.
Cela masque les boutons ; la protection réelle est la RLS en base (voir `BASE_DE_DONNEES.md`).

## Déploiement

À chaque push sur `main` : `.github/workflows/deploy-pages.yml` installe les dépendances
(`npm ci`), lance `npm run check:repo`, construit (`npm run build`), puis publie `dist/` sur
Pages. **Si une étape échoue, rien n'est publié.** Les autres branches et les pull requests sont
vérifiées par `.github/workflows/verify.yml`. Regarder l'onglet **Actions** du dépôt :
✔ vert = bon, ✘ rouge = on ne publie pas.

## Points faibles connus (état du 2026-10-22)

À lire avant d'embaucher ou de confier le projet à quelqu'un : ce sont les vrais chantiers de
solidité, par ordre d'importance.

1. **Aucun test automatisé** dans le dépôt, alors que la spécification des frises parle de
   logique « testée ». `friseModel.ts` est pur (sans DOM) et se prête bien aux tests : à
   ajouter en premier (Vitest), puis pour les règles de dates et de périodes.
2. **Migrations incomplètes** (v13–v18, v21–v23, v25 absentes) : la base ne peut pas être
   reconstruite depuis le dépôt. Voir `BASE_DE_DONNEES.md`.
3. **Très gros fichiers** : `dossier.ts` (≈ 4 500 lignes), `genealogy.ts`, `frise.ts`,
   `main.ts`, `style.css` (≈ 2 500 chacun). Difficiles à relire et à modifier sans régression.
   À découper par fonctionnalité, **sans changer le comportement**, un morceau à la fois.
4. **Règles d'accès non vérifiables depuis le dépôt** (voir `BASE_DE_DONNEES.md`).
5. **Pas de linter ni de formateur** : le style varie d'un fichier à l'autre.
6. **Un seul fichier JavaScript de ≈ 985 Ko** (≈ 285 Ko compressé) : acceptable aujourd'hui,
   à surveiller. Un avertissement de Vite signale que l'import dynamique de D3 est sans effet
   (D3 est aussi importé statiquement ailleurs).
7. **Fermeture des panneaux latéraux** : `closeOtherSidePanels()` masque les autres panneaux
   sans appeler leur propre logique de fermeture ; une sauvegarde en attente dans la fiche
   pays pourrait ne pas être enregistrée si on ouvre un autre panneau (limite signalée dans
   `docs/archive/PORT_STATUS-2026-10-02.md`, non corrigée à notre connaissance).
8. **Zones naturelles approximatives** : ellipses, pas de vrais contours (limite assumée).
9. **Pas de vérification visuelle automatique** (captures d'écran comparées). Les vérifications
   Playwright de la session du 2026-10-21 ont été faites à la main, non conservées.

Ce qui est **déjà solide** : TypeScript passe en mode `strict` sans aucune erreur ; le
déploiement est reproductible et bloqué en cas d'échec ; la logique des frises est isolée
dans un fichier pur.
