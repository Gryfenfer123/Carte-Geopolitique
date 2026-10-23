# Base de données (Supabase)

L'appli utilise un projet **Supabase** (PostgreSQL + authentification + stockage de fichiers).
L'adresse du projet et la clé « anon » sont dans `.env.production` (voir plus bas pourquoi
c'est acceptable de les commiter). **Aucune migration ne s'applique automatiquement** :
chaque fichier `supabase/schema_vN.sql` est collé et exécuté **à la main par Martin** dans
Supabase → SQL Editor.

## ⚠️ Le dépôt ne permet pas, à ce jour, de reconstruire la base à l'identique

Numéros de migration **absents du dépôt** : **v13, v14, v15, v16, v17, v18, v21, v22, v23, v25**.

Conséquences concrètes :

- Si le projet Supabase était perdu, rejouer les fichiers présents **ne redonnerait pas** la
  base actuelle.
- `schema_v28.sql` dit que l'appli est en régime « administrateur seul » **depuis schema_v13**,
  qui n'existe pas ici. Le régime réel des droits d'écriture ne peut donc pas être vérifié
  depuis le dépôt (voir « Droits d'accès »).

**Action recommandée (à faire une fois, par Martin, ~10 minutes)** : exporter le schéma réel
depuis Supabase (Dashboard → Database → export du schéma, ou `supabase db dump --schema public`)
et le déposer dans `supabase/schema_actuel.sql`, avec la date d'export en première ligne.
Ce fichier devient la référence de l'état réel ; les `schema_vN.sql` restent l'historique.
**Faire aussi une sauvegarde des données** (export CSV/SQL) avant tout gros chantier.

## Tables (d'après les fichiers du dépôt)

| Domaine | Tables |
|---|---|
| Utilisateurs | `profiles` (champ `role`, valeur `admin` pour les administrateurs) |
| Pays | `countries`, `country_leaders` (dirigeants multiples), `country_links` (liens entre pays/groupes) |
| Dossiers | `dossier_categories`, `dossier_sections` (sous-catégories imbriquables, portent aussi les périodes de frise), `dossier_entries` (fiches : texte, photo, lien, hémicycle, généalogie, frise) |
| Groupes | `groups`, `group_members`, `group_categories` |
| Indicateurs | `indicator_categories`, `indicators`, `indicator_values` (chargées par `data_owid_load.sql` ; **l'affichage utilise les JSON statiques**, pas ces tables) |
| Carte | `map_features` (ports, détroits, bases, câbles, pipelines, points d'intérêt), `historical_territory_links` |
| Généalogie | `genealogy_members`, `genealogy_relations`, `genealogy_member_statuses` |
| Frises | `timeline_events`, `timeline_event_fiches`, `timeline_placements`, `timeline_categories` ; `timeline_items` = **ancien prototype, abandonné, volontairement non supprimé** |
| Réglages | `app_settings` |
| Fichiers | bucket de stockage public en lecture : `dossier-photos` |

Fonction clé : `public.is_admin()` (définie en v1) — vrai si l'utilisateur connecté a le rôle
`admin` dans `profiles`. Les règles de sécurité au niveau des lignes (RLS) l'utilisent.

## Droits d'accès — à clarifier

- Lecture : publique (policies `select` publiques).
- Écriture : l'historique est contradictoire dans le dépôt. v1 : admin ; v4/v8 (2026-10-01) :
  tout compte connecté ; puis « admin seul depuis v13 » (fichier absent) ; v28 remet les frises
  en admin seul. Côté navigateur, `isAdmin()` (dans `src/dossier.ts`) exige `role = 'admin'` et
  que le mode lecture soit désactivé.
- **Le navigateur n'est PAS une protection** : la vraie barrière, ce sont les policies RLS en
  base. **À vérifier une fois dans Supabase** (Authentication → Policies) que les tables
  d'édition (dossiers, groupes, liens, généalogie, frises, `map_features`, stockage) n'autorisent
  bien l'écriture qu'aux administrateurs, si c'est le régime voulu.
- Cas à part : les politiques de stockage v4 limitent la modification/suppression d'une photo à
  son propriétaire (`owner = auth.uid()`) ; l'envoi est ouvert à tout compte connecté.

## Clé « anon » commitée : pourquoi c'est acceptable (et ses limites)

`VITE_SUPABASE_ANON_KEY` est une clé **publique par conception** : elle finit de toute façon
dans le JavaScript envoyé à chaque visiteur. Sa sécurité repose **entièrement sur les policies
RLS**. Règles :

- Ne **jamais** commiter une clé `service_role` / `sb_secret_…` (`npm run check:repo` bloque ça).
- Toute nouvelle table : activer la RLS et écrire les policies **dans la même migration**.

## Écrire une nouvelle migration

1. Numéro = plus grand numéro existant + 1 (aujourd'hui : **v37**). Fichier
   `supabase/schema_v37.sql`. Jamais deux fichiers avec le même numéro.
2. En-tête : date, raison (la demande de Martin), ce que le script ajoute/modifie.
3. **Idempotente** (`if not exists`, `drop policy if exists`…) et **sans suppression de
   données**, sauf accord explicite de Martin.
4. Ne **jamais modifier** une migration déjà exécutée : écrire une migration corrective
   (comme v28, v34, v35).
5. Dire clairement à Martin « ce fichier est à exécuter dans le SQL Editor » : tant que ce
   n'est pas fait, le code qui en dépend ne fonctionne pas en production.
6. Ajouter une ligne ci-dessous.

## Historique des migrations présentes

| Fichier | Contenu |
|---|---|
| v1 | Schéma initial (profils, `is_admin`, pays, dossiers…) |
| v2 | Compléments (dont `map_features`) |
| v3 | Dossiers pour ports / détroits / bases / câbles / pipelines |
| v4 | Fiche pays + système de dossier complet ; bucket `dossier-photos` |
| v5 | Hémicycles, groupes, indicateurs OWID, encyclopédie |
| v6 | Panneau Apparence (couleurs) |
| v7 | Liens entre pays/groupes |
| v8 | Édition ouverte à tout compte connecté (2026-10-01) |
| v9 | Points d'intérêt (`kind='poi'`, colonne `note`) |
| v10 | Image + cadrage sur catégories et sous-catégories |
| v11 | Arbres généalogiques (dynasties) |
| v12 | Dirigeants multiples par pays |
| v19 | Frises — **ancien prototype, abandonné** |
| v20 | Correspondance territoire historique → fiche actuelle |
| v24 | Statuts cumulés autour d'un membre (anneaux concentriques) |
| v26 | Subdivisions administratives par pays |
| v27 | Frises — nouveau modèle |
| v28 | Frises — écriture réservée aux administrateurs |
| v29 | Frises — couleurs des périodes, transitions cliquables, points colorés |
| v30 | Frises — hauteur réglée à la main d'un point (tige) |
| v31 | Frises — catégories de points, durée, sous-frise |
| v32 | Arbre généalogique « Luxembourg » (données) |
| v33 | Arbres « Wettin » et « Hohenzollern » (données) |
| v34 | Correctif de v33 |
| v35 | Correctif : ascendants d'Élisabeth de Misnie |
| v36 | Membres d'un autre arbre « épinglés » (`pinned`) |
| v37 | Masquer un membre étranger dans un arbre (`hidden`) sans supprimer ses liens |
| v38 | Données : branche ernestine des Wettin (29 membres, épouses créées dans Wittelsbach / Welf / Glücksbourg) — à exécuter une seule fois |
| v39 | Données : Pologne — arbres Piast, Anjou-Hongrie, Báthory, Leszczyński, Poniatowski (créés) + Jagellon, Vasa, Wiśniowiecki, Sobieski (complétés) ; épouses créées dans Přemyslides / Habsbourg / Saliens / Wittelsbach / Stuart — à exécuter une seule fois, après v38 |
| v40 | Données : Tchéquie — Přemyslides complétés (épouses, frères, fils), arbres « Jagellon » (Bohême-Hongrie) et « Poděbrady » créés — à exécuter après v39 |
| v41 | Données : Hongrie — arbres Árpád, Anjou-Hongrie, Hunyadi, Zápolya (créés) ; épouses créées dans Ottoniens / Capétiens / Barcelone / Habsbourg / Luxembourg / Piast / Wittelsbach ; Adélaïde et Constance de Hongrie, sainte Kinga et Barbara Zápolya rattachées à leur vrai arbre — à exécuter après v40 |
| v42 | Données : Autriche — arbres Babenberg et Habsbourg-Lorraine (créés) ; Hélène de Hongrie (Árpád), Henri (VII) (Hohenstaufen), épouses bavaroises, siciliennes, parmesanes, belge et saxonne créées dans leur arbre ; Agnès de Babenberg, Gertrude, Marguerite et Agnès d'Autriche rattachées à Babenberg — à exécuter après v41 |
| `data_owid_load.sql` + `owid_chunks/` | Chargement des données d'indicateurs (rejouable, upserts) — à exécuter après v1 à v7 |
