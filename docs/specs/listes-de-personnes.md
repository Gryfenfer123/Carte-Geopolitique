# Listes de personnes — spécification

**État : BROUILLON du 2026-11-12, à valider par Martin.** Rien n'est codé. Les choix marqués « proposé »
sont pris en autonomie et à confirmer ; on ne les rouvre pas sans Martin une fois validés.

## 1. Le but (demande de Martin, 2026-11-12)

Même principe que les arbres généalogiques, mais **sans arbre** : pouvoir faire des **listes de personnes**
(les présidents, des dirigeants, etc. — « peu importe »). Comme dans les arbres, on voit **la photo de chaque
personne**, et on peut **tous les voir alignés**.

## 2. Ce que ça donne pour Martin (proposé)

- Dans un dossier (pays ou groupe), un bouton **« + Liste de personnes »**, comme « + Généalogie » et « + Frise ».
  La liste apparaît dans le dossier comme une entrée (type `liste`), avec un beau bouton « Liste — Présidents de la Ve République ».
- Un clic ouvre la liste en **plein écran**, comme les arbres : des **cartes avec photo** alignées.
- Trois façons de voir la même liste (boutons en haut) : **Ligne** (toutes les cartes alignées sur une rangée, on
  fait défiler — vue par défaut), **Grille** (retour à la ligne, tout visible d'un coup), **Tableau** (compact, triable).
- Chaque carte : **photo, nom, fonction, période** (ex. « 1959 – 1969 »), une ligne de note. Un clic ouvre la fiche
  détaillée de la personne (texte plus long, sources).
- **Ordre** : manuel (glisser-déposer) ou automatique (par date de début, par nom).
- **Étiquettes** libres (parti, camp, pays…) avec **filtre** : n'afficher que ceux d'une étiquette.
- Ajout d'une personne : formulaire (nom, fonction, dates, note, étiquettes, sources) + photo **recadrée comme dans
  les arbres** (même outil de recadrage, `imageCrop.ts`).

## 3. Paliers de livraison (proposé)

1. **Liste simple** : créer une liste dans un dossier, ajouter/modifier/supprimer/réordonner des personnes, vue Ligne + Grille, photo.
2. **Confort** : vue Tableau, tri, étiquettes et filtres, recherche dans la liste, export image (comme les arbres/frises).
3. **Réutilisation** : ajouter une personne **depuis un arbre généalogique** existant (sa photo et ses dates sont reprises) ;
   la même personne dans plusieurs listes sans la ressaisir.
4. **Listes liées à la carte** : cliquer un nom → zoom sur le pays ; liste « tous les chefs d'État actuels » alimentée par plusieurs pays.

## 4. Choix techniques (proposé)

- **Même système que les arbres et les frises** : une entrée de dossier d'un nouveau type `liste` (la contrainte de la
  table `dossier_entries` devra être étendue : **migration, donc accord de Martin d'abord**).
- **Tables nouvelles** (pas de mélange avec `genealogy_members`, qui appartient au chantier `arbres`) :
  `liste_items` (une ligne par personne : entrée parente, position, nom, photo, fonction, début, fin, note, étiquettes, sources).
  Lecture publique ; droits d'écriture alignés sur le chantier `acces` ; RLS incluse.
- **Photos** : bucket existant `dossier-photos`, chemin `listes/<entrée>/<personne>-….` ; recadrage réutilisé.
- **Nouveaux modules** : `liste.ts` (plein écran), `listeModel.ts` (logique pure : tri, filtre, ordre, testée), `liste.css`.
  Une ligne de branchement dans `dossier.ts` pour l'entrée, rien d'autre ; `genealogy.ts` et `dossier.ts` ne grossissent pas.
- **Données** : aucune personne n'est ajoutée sans source (`docs/sources/listes.md`) ; portraits seulement s'ils sont
  libres de droits (Wikimedia Commons), licence notée.

## 5. Points à confirmer par Martin

- La **vue Ligne par défaut** te convient-elle (ou plutôt la grille) ?
- Une personne qui est dans deux listes : on la **ressaisit** au palier 1 (simple), on la **partage** au palier 3. OK ?
- Autre chose à montrer sur chaque carte (drapeau du pays, parti, âge…) ?
- Ordre de travail : palier 1 d'abord, puis tu essaies.
