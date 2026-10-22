# Frises chronologiques — spécification (validée avec Martin le 2026-10-21)

> Statut : **document de référence.** Toute modification du comportement des frises
> commence par une modification de ce fichier, validée par Martin.
> Mise en œuvre : `src/friseModel.ts` (logique pure), `src/frise.ts` (interface),
> `supabase/schema_v27.sql` à `schema_v31.sql` (base de données).

Les anciennes frises (prototype `src/frise.ts` + table `timeline_items`, schema_v19) sont abandonnées : fond ET forme à refaire. Rien à conserver. La forme visuelle (zoom, couleurs, rendu) sera traitée dans un second temps, une fois le modèle ci-dessous construit.

## 1. Frise

- Une frise est une **entrée de dossier** (type `frise`) que l'on peut placer n'importe où : pays, groupe, catégorie, sous-catégorie à n'importe quelle profondeur — comme un arbre généalogique ou un hémicycle.
- Elle n'est pas propre à un pays : on peut en faire pour un pays, un groupe (BRICS, OTAN…) ou tout autre sujet.
- Il n'y a PAS de frise mondiale générale. Chaque pays aura, à terme, sa frise générale d'histoire (prévue dans Histoire > « Conflits, traités et crises », les autres catégories d'Histoire étant Dynastie, Religion, Institution politique, Économie et société, Relations avec le monde, Territoire), et on peut ajouter des frises thématiques (ex. une frise dans Religion).
- Une frise est une suite d'éléments rangés en catégories qui s'ouvrent vers d'autres catégories, des événements, ou les deux.

## 2. Périodes et sous-frises

- **Une période EST toujours une sous-catégorie** (même objet : renommer, déplacer, supprimer l'un fait la même chose sur l'autre — synchronisation totale par construction). Pas de période sans sous-catégorie.
- Une frise se découpe en périodes. Chaque pays/frise a son propre découpage (Antiquité / Moyen Âge n'était qu'un exemple).
- **Pas de chevauchement** de périodes.
- La fin d'une période et le début de la suivante sont **la même date** (borne partagée) : on n'enregistre que le début de chaque période, la fin est le début de la suivante.
- Cas de transition : si entre deux périodes il y a un vide qui n'est pas un simple événement, on laisse un **trou grisé** dans la frise, avec la situation indiquée (texte). Ce n'est pas une période à part entière. Cas rare : en général une seule date fixe la frontière.
- Chaque période peut, si on le souhaite, avoir **sa propre frise** (limitée à cette période) = une frise placée dans la période, qui peut elle-même contenir des périodes ayant leur frise, **sans limite de profondeur**.
- Les bornes d'une période apparaissent comme début et fin de sa frise enfant.

## 3. Événements

- Un événement = un objet unique (titre + date) **obligatoirement lié à au moins une fiche** (entrée de dossier). Exemple : « Traité de Verdun, 843 » ↔ sa fiche dans Histoire.
- Navigation dans les deux sens : de l'événement vers la fiche, et de la fiche vers la frise.
- Une frise parente ne montre que ses propres événements importants (pas de remontée automatique des événements enfants). On peut choisir de faire apparaître certains événements d'une frise enfant sur la frise parente : c'est alors **le même événement** (référence, jamais une copie).
- Un événement peut figurer sur plusieurs frises (générale + thématique, pays différents) toujours comme un seul objet.

## 4. Fiches : liaison, création, synchronisation

- Ajouter un événement : relier une fiche **existante** (recherche par nom, la fiche reste dans sa catégorie) OU **créer automatiquement** une fiche (vide, au nom de l'événement).
- Une fiche créée depuis une frise se range là où se trouve la frise, dans la **sous-catégorie qui correspond à la période**.
- Quand Martin crée **lui-même** une fiche dans une sous-catégorie d'Histoire qui correspond à une période, elle se place automatiquement sur la frise, à la bonne période, à la date indiquée (le formulaire de création a donc un champ date dans une période).
- Depuis une fiche existante ailleurs (ex. Édit de Nantes dans Religion), on peut la « placer sur une frise » sans la déplacer.

## 5. Dates

- Toujours la date la plus précise possible : année seule, ou mois, ou jour (pas toujours le jour exact, surtout dans l'histoire ancienne).
- Indicateur d'approximation (« vers ») et dates avant Jésus-Christ (année négative).
- La date apparaît partout : sur la frise, sur la fiche. La fiche s'appelle simplement « Traité de Verdun » ; la date exacte se voit au clic sur la frise et sur la fiche.

## 6. Événement commun à plusieurs pays — DÉCIDÉ (2026-10-21)

**Une fiche DIFFÉRENTE par pays** (le traité de Versailles n'est pas le même du point de vue allemand et français : chaque pays a son texte, sa description personnelle), mais toutes **liées au même événement**. Accès entre ces fiches « super simple » : depuis une fiche, on accède directement aux fiches du même événement dans les autres pays (ex. tous les pays signataires du traité de Versailles). L'événement lui-même (titre + date) est unique et apparaît sur la frise de chaque pays concerné. Le pays d'une fiche est celui du dossier qui la contient.
Pas de « fiche générale » obligatoire (décision de ne pas en créer pour l'instant ; le modèle n'empêche pas d'en ajouter une plus tard).

## 7. Divers

- Navigation en fil d'Ariane : conservée pour l'instant (comme le reste de l'appli), à revoir plus tard si trop lourde.
- Modification : **réservée aux administrateurs**, comme le reste de l'appli (`is_admin()` côté base ; en mode lecture l'édition est désactivée). schema_v27 avait mis « tout compte connecté » par erreur ; corrigé par schema_v28.

## 7bis. Rendu visuel des événements (croquis de Martin, 2026-10-21) — pour l'étape 3

- Bande horizontale entre deux lignes, avec le nom de la période. Des dates de la bande part une **tige verticale** vers le bas (ou vers le haut, option par événement).
- Plusieurs événements à la même date : ils partent en **branches empilées**, chacun avec sa couleur (les segments de tige prennent la couleur de la branche), le texte au bout de la branche.
- Les événements partent toujours de la bande centrale de la frise.
- À trancher avec Martin : la couleur a-t-elle un sens (type d'événement) ou est-elle libre ? ordre des événements à date identique ? que montre l'étiquette ?

## 8. Modèle technique et avancement

- `dossier_sections` : + `period_frise_id`, `period_start_*`, `period_end_*` (fin seulement pour un trou de transition ou la dernière période), `transition_label` (schema_v27).
- `timeline_events` (titre, date année/mois/jour/circa, `sort_key`), `timeline_event_fiches` (une fiche → un seul événement ; un événement → plusieurs fiches, une par pays), `timeline_placements` (événement ↔ frise, par référence).
- Un événement sans fiche est supprimé automatiquement (déclencheur).
- Une période d'une frise est rangée sous la section où la frise est posée (`parent_section_id` = section de la frise).
- « Retirer de la frise » ne supprime jamais la sous-catégorie : elle cesse seulement d'être une période.

Plan :
1. Migration SQL v27 (exécutée par Martin) + v28 (droits admin seul, **à exécuter par Martin**).
2. **FAIT (poussé le 2026-10-21)** : frises et périodes — création (nouvelle sous-catégorie ou sous-catégorie existante), modification, retrait, bornes partagées, trous de transition, sous-frises, fil d'Ariane, bornes de la période affichées en sous-frise. Code : `src/friseModel.ts` (logique pure, testée) + `src/frise.ts`.
3. Événements : relier/créer une fiche, date, navigation dans les deux sens, accès aux fiches des autres pays ; rendu en tiges et branches colorées (voir 7bis).
4. Placements multiples, remontée sur la frise parente, placement automatique des fiches créées à la main.

> Note de maintenance (2026-10-22) : les migrations v29 à v31 (couleurs des périodes,
> transitions cliquables, hauteur de tige réglée à la main, catégories de points avec
> durée et sous-frise) ont été ajoutées après la rédaction du plan ci-dessus : l'étape 3
> est donc au moins partiellement entamée dans le code. L'état exact de chaque étape
> reste à confirmer avec Martin avant de la déclarer terminée. Ne pas se fier à ce plan
> comme tableau d'avancement.
> Aucun test automatisé n'existe dans le dépôt à ce jour, malgré la mention « testée »
> ci-dessus : voir `docs/ARCHITECTURE.md`, section « Points faibles connus ».
