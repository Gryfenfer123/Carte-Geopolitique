# Registre des sources

**Règle impérative (décidée par Martin le 2026-10-24)** : tout travail qui apporte une donnée, un
fait, une date, une image ou un texte est **sourcé systématiquement, au moment où il est fait**.
**Rien n'est pris s'il n'est pas sourcé** : sans source identifiable, on n'ajoute pas (ou on le
signale comme « à sourcer » et on ne l'affiche pas comme acquis).

Un jour, ces fichiers serviront à écrire le grand document de sources du projet. Il faut donc que
chaque ligne soit utilisable seule, des mois plus tard.

## Où noter
Un fichier **par chantier** (pas de collision entre conversations) : `docs/sources/<chantier>.md`
(arbres, frises, historique, carte, groupes, dossiers, indicateurs, acces, croquis). Une ligne par source
utilisée, ajoutée **dans le même commit** que le travail.

## Format d'une ligne (tableau Markdown)
| Date | Ce qui a été fait / touché | Source (titre, auteur ou organisme) | Lien précis | Licence / droits | Fiabilité |
|---|---|---|---|---|---|

- **Lien précis** : la page exacte (pas la page d'accueil), avec la date de consultation si le contenu change.
- **Licence** : ex. CC BY-SA 4.0, domaine public, données ouvertes, « inconnue » (à régler avant publication).
  Images : auteur + licence de chaque fichier (ex. Wikimedia Commons).
- **Fiabilité** : primaire (source d'époque, institution), secondaire (livre, encyclopédie), tertiaire/à recouper (Wikipédia seule).
- Plusieurs éléments d'une même source (ex. 40 dynasties tirées de la même page) : une ligne par
  source, avec la liste de ce qu'elle couvre.

## Cas particuliers
- Données dans la base : la source est notée ici **et**, si la table a un champ source, dedans.
- Donnée approximative ou incertaine : on l'écrit dans la colonne « Fiabilité ».
- Source introuvable après le fait : on le note « SOURCE MANQUANTE » (ne jamais en inventer une) ; ça devient une tâche de vérification.
