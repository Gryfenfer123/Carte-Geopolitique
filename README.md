# Carte Géopolitique — Prototype moteur tuiles

Ceci est un **prototype autonome** destiné à valider une nouvelle technique de
carte pour le projet Carte Géopolitique : remplacer la projection SVG fixe
(D3.js) actuelle par une **vraie carte à tuiles, zoomable et navigable
librement** (comme Google Maps / OpenStreetMap), avec les frontières des pays
en superposition.

Ce prototype ne contient **pas** encore :
- les fiches pays complètes (dossiers, indicateurs, hémicycles, etc.) ;
- de backend ni de compte utilisateur (Supabase viendra plus tard) ;
- l'édition multi-utilisateur.

Il sert uniquement à prouver que la technique « carte à tuiles + frontières
en overlay » fonctionne bien et peut reprendre l'identité visuelle actuelle
(bleu marine sombre, accent doré, polices Fraunces / IBM Plex Sans).

## Ce qui est utilisé

- **Vite + TypeScript** (pas de framework lourd, projet volontairement
  minimal).
- **Leaflet.js** pour la carte (pan/zoom fluide, molette de zoom, contrôles
  standards).
- Fond de carte **CARTO "Dark Matter"** (gratuit, sans clé API, basé sur les
  données OpenStreetMap) — choisi pour son thème sombre qui s'accorde avec
  la charte actuelle.
- Les **frontières des pays** proviennent du jeu de données déjà utilisé
  dans l'atlas (`countries_50m.geojson`), simplifié (propriétés allégées)
  et copié dans `public/data/countries.geojson`.

## Lancer le projet en local

Prérequis : [Node.js](https://nodejs.org/) (version 18 ou plus récente) et
npm, déjà installés sur la plupart des systèmes récents.

```bash
# 1. Installer les dépendances (une seule fois)
npm install

# 2. Lancer le serveur de développement
npm run dev
```

Puis ouvrez l'adresse affichée dans le terminal (en général
`http://localhost:5173`) dans votre navigateur.

Pour générer une version statique prête à héberger (par exemple sur
Netlify, Vercel, GitHub Pages...) :

```bash
npm run build
```

Le résultat est généré dans le dossier `dist/`. Ce dossier peut être
déposé tel quel sur n'importe quel hébergement statique.

## Remarque sur le fond de carte

Le fond de carte (tuiles CARTO) nécessite un accès Internet classique
depuis le navigateur qui l'affiche. Si les tuiles ne se chargent pas (par
exemple sur un réseau très restreint), un message discret l'indique en
haut de la carte, mais **les frontières des pays restent visibles** sur un
fond sombre uni — l'interaction (survol, clic, panneau d'information)
continue de fonctionner normalement.

## Interaction

- **Molette de la souris** : zoomer / dézoomer.
- **Glisser-déposer** : déplacer la carte.
- **Survol d'un pays** : mise en surbrillance de son territoire.
- **Clic sur un pays** : ouvre une info-bulle avec son nom, et affiche ses
  informations de base dans le panneau à droite (une future étape reliera
  ce panneau aux vraies fiches pays de l'atlas).

## Structure du projet

```
atlas-web/
├── index.html          Page HTML principale (polices, titre)
├── src/
│   ├── main.ts          Logique de la carte (Leaflet, overlay pays, panneau)
│   └── style.css         Thème visuel (couleurs reprises de l'atlas)
├── public/
│   └── data/
│       └── countries.geojson   Frontières des pays (source allégée)
└── package.json
```

## Supabase (authentification + dossiers pays)

Ce prototype est maintenant connecté à un vrai projet Supabase :

- Client : `src/supabase.ts`, configuré via les variables d'environnement
  `VITE_SUPABASE_URL` et `VITE_SUPABASE_ANON_KEY` (fichier `.env.local`,
  **non commité** — voir `.env.example` pour le modèle).
- **Connexion / inscription** : bouton en haut à droite de l'en-tête
  ("Se connecter" → devient le nom d'utilisateur une fois connecté). Le
  panneau gère à la fois la connexion et la création de compte (bascule
  simple entre les deux modes), avec des messages d'erreur en français.
- **Dossier pays** : au clic sur un pays, le panneau affiche désormais les
  entrées existantes (`dossier_entries` où `owner_type='country'` et
  `owner_id` = code ISO A3 du pays), avec un état vide convivial si aucune
  entrée n'existe encore.
- **Ajout d'entrée** : si l'utilisateur est connecté, un petit formulaire
  (titre + texte brut) apparaît sous le dossier du pays sélectionné et
  permet d'ajouter une entrée de type `text`. La liste se rafraîchit
  automatiquement après l'ajout. Le formulaire n'apparaît pas du tout si
  personne n'est connecté (en plus de la sécurité RLS côté serveur).

## Prochaines étapes envisagées

- Remplacer l'aperçu texte brut des entrées par un rendu riche
  (`body_html`) et un éditeur adapté.
- Ajouter la gestion des catégories/sections de dossier (actuellement,
  les entrées créées via ce prototype n'ont pas de `category_id` /
  `section_id` — colonnes nullable dans le schéma actuel).
- Ajouter les couches optionnelles existantes dans l'atlas (ports,
  pipelines, câbles, bases militaires, etc.) comme calques Leaflet
  superposables.
