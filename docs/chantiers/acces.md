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
- 2026-11-01 : vérification des licences d'images (demande de Martin : tout doit être libre). Registre : `docs/sources/images.md` ; script `scripts/images/verifier-licences-wikimedia.js`.
  Vérifié : 302 fichiers Commons, aucun non libre. Non vérifiable : 874 fichiers téléversés (origine perdue), dont 40 couvertures manifestement issues du web (Adobe Stock, Getty…) et ~33 photos récentes de personnes vivantes. Aucune image supprimée ni modifiée (accord de Martin à demander).

## 2026-11-02 — Migrations par l'IA + barème de preuve
- Décision de Martin : l'IA exécute elle-même les migrations (connecteur Supabase) ; Martin ne copie plus rien. Mis à jour : `CLAUDE.md` (règles 6, 8, 10), `docs/CONVENTIONS.md` (§0, §5, §7), `docs/BASE_DE_DONNEES.md`. Les en-têtes des anciens fichiers SQL (« à coller dans SQL Editor ») ne sont pas modifiés (migrations exécutées).
- Décision de Martin : barème de preuve maximal (`docs/sources/README.md`). Vérification globale ouverte par la France : `docs/audits/VERIF_FRANCE.md`.
- Reste hors dépôt : instructions du projet claude.ai et documents `claude/lisez-moi-chaque-session.md` / `claude/contexte-complet-projet.md` (dire encore « Martin exécute les migrations »).
- 2026-11-02 (précision de Martin) : désaccord entre spécialistes → convention enseignée retenue et notée ; énorme désaccord sans convention → rien écrit + question à Martin (`docs/sources/README.md` §3).
