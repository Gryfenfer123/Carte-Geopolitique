# Chantier « groupes » — journal

Code : `groups.ts`, `links.ts`, `linkIndex.ts` (+ le mode groupe de `dossier.ts`). Migrations : `supabase/groupes/groupes_vN.sql`.

## Dernières nouvelles (la plus récente en haut)
- 2026-11-02 (2) — **dossier d'exemple « OTAN » ultra rempli** : 60 entrées de texte (≈ 10 800 mots) réparties dans les 7 catégories et 21 sous-catégories, chacune sourcée (132 liens au total, `docs/sources/groupes.md`). Migrations `groupes_v2`, `groupes_v3`, `groupes_v4` **exécutées par Claude sur la base avec l'accord de Martin**. Vérifié : texte, nombre et adresses des sources des 60 entrées identiques aux fichiers du dépôt ; aucune entrée sans catégorie ni sans source ; seules des balises acceptées par `sanitize.ts` ; affichage testé sur le site déployé (dossier OTAN : 7 thèmes, 61 entrées, tableau des 32 membres lisible, sources cliquables). Non vérifié : relecture humaine des contenus (étiquette « À relire 02/11/2026 »), affichage sur mobile et en mode « Modifier ». Points ouverts : écarts entre sources et données non sourcées, listés dans `docs/sources/groupes.md`.
  Prochaine étape : Martin relit et dit quoi changer ; puis reproduire ce modèle sur les autres groupes (UE, BRICS, OPEP…), un par un, avec sources.
- 2026-11-02 — les dossiers de groupes ont 7 grandes catégories communes (Présentation ; Origines et raison d'être ; Membres et adhésion ; Fonctionnement ; Actions et compétences ; Poids et chiffres ; Relations, tensions et critiques) au lieu du dossier « plat ». Migration `groupes_v1` **exécutée par Claude sur la base avec l'accord de Martin**. Vérifié : 7 catégories présentes en base (espace `group`), catégories des pays et de l'encyclopédie inchangées, `check:repo`, `build`. Non vérifié : affichage à l'écran (ouvrir le dossier d'un groupe). Les textes déjà écrits dans les 25 groupes restent « non classés » (aucun déplacement).
  Prochaine étape : Martin répartit/valide les textes existants ; contenu des catégories groupe par groupe (avec sources).

## Constat de départ (2026-11-02)
- 25 groupes en base (14 du semis d'origine + groupes créés ensuite : UE, OTAN partenaires, GNL, minerais critiques…).
- Droits : tout compte connecté peut modifier `group_members` (audit 2026-10-30, à traiter par le chantier `acces`).
