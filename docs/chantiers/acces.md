# Chantier « acces » — journal

## Dernières nouvelles (la plus récente en haut)
- 2026-10-23 — chantier créé par la conversation de pilotage ; audit des droits actuels préparé (`scripts/acces/audit-droits.sql`,
  à exécuter par Martin en lecture seule) ; prochaine étape : lire les résultats, puis concevoir les rôles.

## Feuille de route d'ouverture (voulue par Martin, 2026-10-23, dans cet ordre)
1. **Rôles et panneau d'administration** (ce chantier, en premier) : lecture seule / contributeur (modifie certains éléments) /
   éditeur (modifie tout) / administrateur (gère aussi les comptes et les rôles) ; panneau de contrôle pour les administrateurs ;
   règles d'accès vérifiées en base (la vraie barrière est la RLS, pas les boutons masqués).
2. **Sources et droits** : tout ce qui est récupéré est sourcé ; licences respectées (auteur + licence affichés pour les images
   Wikimedia, textes sous licence) ; juridiquement propre avant toute ouverture. Les 209 portraits de `schema_v60` sont des liens
   directs Wikimedia SANS mention d'auteur/licence : à traiter.
3. **Explications techniques pour Martin** : comment fonctionnent Supabase, GitHub, l'hébergement ; perspectives (serveurs, coûts,
   limites de l'offre gratuite, montée en charge).
4. **Protection et structure** : protéger le projet, éventuelle société (SAS) avec les associés, conditions d'utilisation,
   éventuelle partie premium (abonnement). Point à discuter avec un professionnel du droit ; le dépôt GitHub est PUBLIC et sans
   licence déclarée (à décider : licence ou dépôt privé).

## Conception proposée (à valider avec Martin avant de coder)
- Rôles : `reader` (compte, lecture + favoris), `contributor`, `editor`, `admin`. Table `profiles.role` existante à étendre.
- Une seule fonction de décision en base (`has_role(...)`) utilisée par TOUTES les règles RLS ; le navigateur ne fait que masquer.
- Les contributeurs publient d'abord directement (avec historique et retour arrière) ; une file de « propositions à valider »
  viendra à l'ouverture publique.
- Panneau d'administration : liste des comptes, changement de rôle, journal des modifications récentes.
- Toute migration de droits est annoncée clairement à Martin avant exécution (irréversible = demander d'abord).

## Journal
- 2026-10-30 : audit complet (`docs/audits/AUDIT_2026-10-30.md`). Premier chantier technique : garde-fou global des échecs de base
  (`src/dbGuard.ts`, `npm run test:dbguard`). Vérifié : 16 cas de logique pure, et dans un navigateur avec base simulée (démarrage normal sans alerte,
  lecture 500, écriture 403, suppression « 0 ligne », réseau coupé). Non vérifié : contre la vraie base (mon navigateur de test ne l'atteint pas) — à regarder à l'usage.
  Suite : filtrer les schémas des liens (`link_url`), puis `acces_v1` (droits trop ouverts) après accord de Martin.
