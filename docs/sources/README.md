# Registre des sources

**Règle impérative (décidée par Martin le 2026-10-24)** : tout travail qui apporte une donnée, un
fait, une date, une image ou un texte est **sourcé systématiquement, au moment où il est fait**.
**Rien n'est pris s'il n'est pas sourcé** : sans source identifiable, on n'ajoute pas (ou on le
signale comme « à sourcer » et on ne l'affiche pas comme acquis).

Un jour, ces fichiers serviront à écrire le grand document de sources du projet. Il faut donc que
chaque ligne soit utilisable seule, des mois plus tard.

## Barème de preuve (décidé par Martin le 2026-11-02) — il PRIME sur le reste
Martin veut des données **sursourcées, surrecoupées, uniquement des faits non contestés, issus de la littérature
universitaire**. Il est inconcevable de publier quelque chose de faux ou d'approximatif.

1. **Pour être écrit (base ou dépôt), un fait doit avoir au moins DEUX sources indépendantes, dont au moins UNE
   universitaire ou institutionnelle** : livre ou article scientifique (presses universitaires, revue à comité de lecture),
   ouvrage de référence savant (ex. *Oxford Dictionary of National Biography*, *Dictionnaire de biographie française*,
   *Neue Deutsche Biographie*, *Encyclopaedia of Islam*), bibliothèque ou archive nationale (BnF/Gallica, data.bnf.fr,
   Deutsche Nationalbibliothek…), organisme officiel pour les données statistiques. Plus il y a de sources concordantes, mieux c'est ;
   les sources en d'autres langues (langue du pays concerné) sont bienvenues, voire nécessaires.
2. **Wikipédia et Wikidata ne sont PAS des preuves** : ce sont des pistes pour trouver les vraies sources (leurs notes et
   bibliographies). Une donnée qui n'a que Wikipédia/Wikidata derrière elle n'est pas écrite.
3. **Désaccord entre spécialistes (précisé par Martin le 2026-11-02)** — trois cas :
   - **Convention établie** (la datation ou la version enseignée, usuelle dans les manuels et ouvrages de référence) : on **utilise
     la convention**, même s'il existe un désaccord ; on peut noter la divergence en une ligne dans le registre et/ou la fiche.
   - **Désaccord mineur** sans convention nette : on prend la position majoritaire des sources savantes, en notant la divergence.
   - **Énorme désaccord notable**, sans convention retenue : **on n'écrit rien dans la base, on le note dans le registre comme
     « désaccord », et on demande à Martin.**
   Dans tous les cas on ne choisit jamais « en silence » : la convention retenue et la source qui la porte sont écrites.
4. **Les sources qui se contredisent** ou qui se recopient (une seule source d'origine répétée) comptent pour une seule.
5. **Aucune valeur de mémoire.** Une connaissance « générale » de l'IA n'est jamais une source.
6. **Dans le doute, on ne pousse pas** (ni GitHub ni Supabase) : on le signale à Martin comme « non vérifié ».
7. Chaque ligne du registre indique : quelle donnée, quelles sources (≥ 2, précisées), laquelle est universitaire, et le
   résultat du recoupement (« concordantes » / « divergence : … »). Le niveau de fiabilité est celui de la meilleure source
   *indépendante*, pas de la plus nombreuse.

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
