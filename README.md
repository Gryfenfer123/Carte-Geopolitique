# Carte Géopolitique

Atlas interactif du monde pour les études de relations internationales : une vraie carte à
tuiles (zoomable librement) avec, pour chaque pays, un dossier de notes structuré, et des
liens entre pays, des groupes (OTAN, BRICS…), des indicateurs chiffrés, des arbres
généalogiques de dynasties et des frises chronologiques.

Projet personnel de Martin. Site publié automatiquement sur GitHub Pages.

## Ce que l'appli permet (d'après le code actuel)

- **Carte** à vraies tuiles (Leaflet), fonds Vectoriel ou Satellite, frontières des pays en
  surbrillance au survol, subdivisions administratives, zoom et déplacement libres.
- **Fiche et dossier par pays** : catégories → sous-catégories → entrées (texte riche, photo
  recadrable, lien, hémicycle, arbre généalogique, frise), favoris, historique des versions.
- **Groupes géopolitiques** et **liens** entre pays/groupes tracés sur la carte.
- **Indicateurs** (santé, éducation, économie, numérique…) affichés en carte colorée et dans
  les fiches ; **comparateur** de deux pays.
- **Arbres généalogiques** des dynasties, interactifs, croisant plusieurs pays.
- **Frises chronologiques** : périodes, sous-frises, événements (en cours de construction —
  voir `docs/specs/frises-chronologiques.md`).
- **Carte historique** par époque ; **encyclopédie** de notions ; **points d'intérêt** ;
  ports, détroits, pipelines, câbles sous-marins, bases militaires, fleuves, zones naturelles.
- **Recherche** dans les noms et le contenu des dossiers ; **exports** PNG de la carte et JSON
  complet des données ; **mode lecture** ; comptes (connexion).

## Documentation

| Pour… | Lire |
|---|---|
| Comprendre comment c'est construit, et ses faiblesses connues | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| Travailler sur le projet (règles obligatoires) | [`docs/CONVENTIONS.md`](docs/CONVENTIONS.md) et [`CLAUDE.md`](CLAUDE.md) |
| Savoir ce qui est décidé et pourquoi | [`docs/DECISIONS.md`](docs/DECISIONS.md) |
| La base de données, les migrations, les droits | [`docs/BASE_DE_DONNEES.md`](docs/BASE_DE_DONNEES.md) |
| Les frises chronologiques | [`docs/specs/frises-chronologiques.md`](docs/specs/frises-chronologiques.md) |

## Lancer le projet sur son ordinateur

Prérequis : [Node.js](https://nodejs.org/) 20 ou plus récent (le déploiement utilise Node 20).

```bash
npm ci          # installer les dépendances (une seule fois)
cp .env.example .env.local   # puis renseigner les deux valeurs Supabase
npm run dev     # serveur de développement → http://localhost:5173
```

Les deux valeurs de `.env.local` (`VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`) se trouvent
dans le tableau de bord Supabase (Project Settings → API). Sans elles, la carte s'affiche mais
les dossiers et la connexion ne fonctionnent pas.

## Vérifier avant de publier

```bash
npm run check:repo   # dépôt sain : pas de doublon, pas de secret, pas de fichier égaré
npm run build        # typage strict + construction ; doit passer sans erreur
```

## Publication

À chaque push sur `main`, GitHub Actions (`.github/workflows/deploy-pages.yml`) vérifie le
dépôt, construit le site et le publie sur GitHub Pages sous `/Carte-Geopolitique/`.
**Si une vérification échoue, rien n'est publié** : regarder l'onglet *Actions* du dépôt
(✔ vert = publié, ✘ rouge = bloqué, avec le détail de l'erreur).
Les autres branches et les pull requests sont vérifiées par `verify.yml`, sans publication.

## Structure

```
index.html            page unique
src/                  tout le code (TypeScript) et le CSS
public/data/          données statiques (frontières, indicateurs, ports, câbles…)
supabase/             migrations SQL (exécutées à la main dans Supabase)
scripts/              outils hors site (vérification du dépôt, génération de données)
docs/                 documentation, spécifications, archives
.github/workflows/    déploiement et vérifications automatiques
```

Détail module par module : [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Sources de données et licences

- Fonds de carte : tuiles Esri (World_Dark_Gray_Base, World_Imagery).
- Frontières : jeu de données de pays (`public/data/countries.geojson`).
- Indicateurs : compilés à partir de sources publiques (CIA Factbook, Banque mondiale,
  OMS/UNICEF, UNESCO, ITU, OCDE, FAS) ; voir `docs/DECISIONS.md`.
- Drapeaux : « flag-icons » (licence MIT).
- Carte historique : OpenHistoricalMap.
