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

## 7bis. Rendu visuel des événements (croquis de Martin, 2026-10-21)

- Bande horizontale entre deux lignes, avec le nom de la période. Des dates de la bande part une **tige verticale** vers le bas (ou vers le haut, option par événement).
- Plusieurs événements à la même date : ils partent en **branches empilées**, chacun avec sa couleur (les segments de tige prennent la couleur de la branche), le texte au bout de la branche.
- Les événements partent toujours de la bande centrale de la frise.
- **Mis en œuvre** (`frise.ts`, `schema_v29` à `schema_v31`) : tiges, côté haut/bas choisi par point, branches empilées automatiquement quand deux points se gênent, hauteur de tige réglable à la main (glisser le point), durée = barre entre deux tiges.
- **Questions du croquis tranchées par défaut le 2026-10-23, À VALIDER par Martin** : la couleur est celle de la **catégorie** du point (table `timeline_categories`, modifiable par le bouton « Catégories »), pas une couleur libre ; à date identique les points sont rangés de gauche à droite par date puis empilés par niveaux ; l'étiquette montre le **titre** seul, les dates apparaissent au survol et dans la carte ouverte au clic.

## 8. Modèle technique et avancement

- `dossier_sections` : + `period_frise_id`, `period_start_*`, `period_end_*` (fin seulement pour un trou de transition ou la dernière période), `transition_label` (schema_v27).
- `timeline_events` (titre, date année/mois/jour/circa, `sort_key`), `timeline_event_fiches` (une fiche → un seul événement ; un événement → plusieurs fiches, une par pays), `timeline_placements` (événement ↔ frise, par référence).
- Un événement sans fiche est supprimé automatiquement (déclencheur).
- Une période d'une frise est rangée sous la section où la frise est posée (`parent_section_id` = section de la frise).
- « Retirer de la frise » ne supprime jamais la sous-catégorie : elle cesse seulement d'être une période.

Plan :
1. Migration SQL v27 (exécutée par Martin) + v28 (droits admin seul, **à exécuter par Martin**).
2. **FAIT (poussé le 2026-10-21)** : frises et périodes — création (nouvelle sous-catégorie ou sous-catégorie existante), modification, retrait, bornes partagées, trous de transition, sous-frises, fil d'Ariane, bornes de la période affichées en sous-frise. Code : `src/friseModel.ts` (logique pure, testée) + `src/frise.ts`.
3. **FAIT** — Événements : relier/créer une fiche, date, navigation dans les deux sens, accès aux fiches des autres pays ; rendu en tiges et branches colorées (voir 7bis).
4. Placements multiples, remontée sur la frise parente, placement automatique des fiches créées à la main :
   - **FAIT (2026-10-23)** : *placements multiples* — bouton « Frises » sur la carte d'un point : voir sur quelles frises il apparaît (et les ouvrir), l'ajouter à une autre frise (recherche par titre), le retirer d'une frise ; c'est toujours le même événement (référence). *Remontée sur la frise parente* — même dialogue : « Afficher aussi sur la frise parente » (un placement de plus sur la frise parente). Fiche ouverte depuis un point présent sur plusieurs frises : « Voir sur la frise » propose la liste. Code : `src/friseEvents.ts` (base), `src/friseMulti.ts` (dialogue), `src/friseDateFields.ts`.
   - **Aussi 2026-10-23** : une fiche créée depuis « + Point » se range désormais dans la **sous-catégorie de la période qui contient la date du point** (§4) ; avant, elle allait dans le dossier où la frise est posée.
   - **FAIT (2026-10-23)** : « Placer sur une frise » depuis une fiche existante (bouton dans la lecture de la fiche, même dialogue) ; placement automatique des fiches créées à la main : dans le formulaire « + Texte », si la sous-catégorie choisie est une période de frise, un bloc « Date » facultatif apparaît ; avec une date, le point est créé et placé sur la frise (`src/friseAutoPlace.ts`). Étape 4 terminée.

> Note (2026-10-23) : l'avancement ci-dessus a été relu dans le code ; il est à jour à cette date.
> Aucune migration n'a été nécessaire pour les placements multiples : `timeline_placements`
> (clé primaire = frise + événement, droits administrateur seul depuis `schema_v28`/`v29`)
> les permettait déjà.
> Aucun test automatisé n'existe dans le dépôt à ce jour : voir `docs/ARCHITECTURE.md`,
> section « Points faibles connus ».

## 9. Choix faits en autonomie (2026-10-23), à valider par Martin

- « Retirer » un point d'une frise est refusé s'il n'est que sur cette frise (il faut alors « Modifier » puis « Supprimer le point », qui supprime l'événement, jamais la fiche).
- Ajouter un point à une autre frise est refusé si sa date (ou sa fin) tombe hors de cette frise ; les frises sans période propre (sous-frise d'un événement avec durée) ne peuvent pas être contrôlées : l'ajout passe, le point n'y est visible que si sa date est dans la frise.
- Le point ajouté à une autre frise reprend le côté (haut/bas), la catégorie et la couleur qu'il a sur la frise d'où l'on vient.
- La remontée proposée dans le dialogue concerne la frise **parente directe**. Pour une frise plus haut (grand-parent), utiliser la recherche « Chercher une frise par titre ».
- Pas d'indicateur visuel, sur la frise parente, des points venus d'une sous-frise (non demandé).
- Placement automatique d'une fiche créée à la main : la date est **facultative** ; sans date, la fiche est créée normalement, sans point.
- La date doit tomber dans la période de la sous-catégorie choisie ; sinon la fiche n'est pas créée, le formulaire reste ouvert avec le texte tapé, et un message explique le refus.
- Les brouillons ne sont pas placés sur la frise.
- Le point créé automatiquement est placé côté « haut », sans catégorie ; sa couleur est celle de la période. Modifiable ensuite via « Modifier ».
- Une erreur de placement ne bloque jamais la création de la fiche (message affiché, fiche conservée).
