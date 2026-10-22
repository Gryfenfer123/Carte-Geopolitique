// ---------------------------------------------------------------------------
// Arbres généalogiques (dynasties) — demande de Martin, 2026-10-03 : "ajouter
// des membres, faire un truc bien interactif... zoomable, avec photo,
// possibilité de se balader dedans en glissant, avec des liens entre tous,
// et montrer les croisements entre plusieurs pays".
//
// Schéma : supabase/schema_v11.sql (genealogy_members / genealogy_relations),
// PAS ENCORE EXÉCUTÉ en production au moment de ce portage — ce module
// suppose juste que les deux tables existent (voir ce fichier SQL pour le
// détail owner_type/owner_id, qui suit exactement la même convention que
// dossier_sections/dossier_entries dans src/dossier.ts).
//
// Organisation (mise à jour point 2, 2026-10-03 — changement d'architecture
// confirmé avec Martin) : un arbre par ENTRÉE de dossier de type
// "genealogy" (owner_type="entry", owner_id=l'id de l'entrée — voir
// EntryType/onOpenGenealogyEntry de src/dossier.ts), plutôt qu'un seul
// arbre par pays/groupe comme avant — un dossier peut donc avoir plusieurs
// arbres indépendants (un par dynastie/section), ouverts depuis la carte
// "🌳 <titre>" correspondante dans la barre d'ajout du dossier. Un membre
// appartient à l'arbre dans lequel il a été créé, mais une RELATION entre
// deux membres peut traverser deux arbres
// (ex. mariage franco-espagnol) : genealogy_relations ne contraint pas
// member_a_id/member_b_id à un même owner_id. Un membre d'un autre pays
// apparaissant seulement parce qu'il est lié (classe .gen-card-foreign,
// bordure accent + badge 🌍) ouvre, au clic, SON propre arbre (deps.
// openOwnerTree) au lieu du panneau d'édition.
//
// Positionnement des membres "étrangers" (liés depuis un autre arbre) :
// pos_x/pos_y en base sont exprimés dans le repère du canevas de LEUR
// propre arbre (celui où ils ont été créés), donc inutilisables tels quels
// ici — les réutiliser placerait le membre n'importe où par rapport au
// canevas courant. Choix assumé (à vérifier par Martin si le rendu ne lui
// convient pas) : un membre étranger est positionné à la volée, à distance
// fixe du membre local auquel il est relié, sans jamais écrire cette
// position en base (computeForeignPosition ci-dessous) — un deuxième lien
// vers le même membre étranger depuis un autre membre local le repositionne
// simplement au dernier calcul, ce qui est sans conséquence puisque rien
// n'est persisté.
//
// Pattern du fichier : initXSystem(deps) à l'identique de src/poi.ts/
// src/dossier.ts — DOM construit une fois et injecté dans document.body,
// jamais de framework.
// ---------------------------------------------------------------------------

import { computeLayout, guessFemale, yearToY } from "./genealogyLayout";
import type { SupabaseClient, Session } from "@supabase/supabase-js";
import * as d3 from "d3";
import type { DossierOwnerKind, DossierOwnerRef } from "./dossier";
import { customConfirm, TRASH_ICON_SVG } from "./dossier";
import { ensureLinkIndexLoaded, findLinkTargetForName, type LinkTarget } from "./linkIndex";

// --- Types -------------------------------------------------------------

// "family" ajouté à la demande de Martin, 2026-10-03 ("Rajoute un lien =>
// Famille, pour en avoir 3 : Parent, Famille, Mariage") — lien symétrique,
// même traitement que "spouse" (aucun sens parent/enfant), juste un
// troisième type pour un lien de parenté qui n'est ni filiation directe ni
// mariage (ex. frère/sœur, cousin·e, oncle/tante...). Voir
// supabase/schema_v14.sql pour la contrainte CHECK côté base.
//
// "custom" ajouté à la demande de Martin, 2026-10-06 : "de manière
// générale, la possibilité de créer de nouveaux liens, avec la légende, la
// couleur souhaitée, propre à chaque arbre" — EN PLUS des 3 types
// ci-dessus (confirmé par Martin), un lien dont la couleur/le libellé
// viennent d'une entrée de légende (LegendItem ci-dessous) au lieu d'être
// fixés par le type. Voir supabase/schema_v17.sql.
type RelationType = "parent" | "spouse" | "family" | "custom";

// Légende de couleurs par arbre (supabase/schema_v17.sql, demande de
// Martin, 2026-10-06) — une liste réutilisable de paires (couleur,
// libellé) propre à CET arbre (owner_type/owner_id), utilisée pour :
// entourer un membre (MemberRow.legend_item_id / ForeignStateRow côté
// arbre visiteur) et colorer un lien "custom" (RelationRow.legend_item_id).
// "kind" (schema_v22.sql, demande de Martin, 2026-10-06 : "il faut
// différencier la création d'un lien [...] et un statut [...], ce n'est
// pas la même chose") — une entrée de légende sert SOIT à entourer un
// membre ("status"), SOIT à colorer un lien "personnalisé" ("link"),
// jamais les deux : les deux sélecteurs (anneau sur la fiche membre /
// couleur d'un lien) ne proposent chacun que les entrées de leur kind
// (voir renderLegendOptionsInto).
type LegendItemKind = "status" | "link";
type LegendItem = {
  id: string;
  owner_type: string;
  owner_id: string;
  color: string;
  label: string;
  position: number;
  kind: LegendItemKind;
};

type MemberRow = {
  id: string;
  owner_type: string;
  owner_id: string;
  name: string;
  photo_url: string | null;
  birth_year: number | null;
  death_year: number | null;
  title: string | null;
  dynasty: string | null;
  bio: string | null;
  pos_x: number;
  pos_y: number;
  created_by: string | null;
  // Point demandé par Martin, 2026-10-03 : "mettre la possibilité
  // d'entourer un membre, l'objectif est de mettre tout ceux qui ont
  // dirigés le pays en surbrillance" — case à cocher sur la fiche membre
  // (voir supabase/schema_v15.sql pour la colonne côté base), qui donne
  // en permanence à la carte un style distinct (bordure dorée, voir
  // .gen-card-leader dans style.css) sur l'arbre.
  is_leader: boolean;
  // Anneau de couleur au choix (demande de Martin, 2026-10-06 :
  // "Possibilité d'entourer un membre de la couleur que l'on souhaite
  // avec la légende que l'on souhaite") — null = pas d'anneau, sinon
  // référence une entrée de la légende de SON arbre d'origine. Totalement
  // indépendant de is_leader (qui reste disponible séparément).
  legend_item_id: string | null;
};

type RelationRow = {
  id: string;
  member_a_id: string;
  member_b_id: string;
  relation_type: RelationType;
  created_by: string | null;
  // Couleur/libellé du lien quand relation_type="custom" (demande de
  // Martin, 2026-10-06) — ignoré pour les 3 types existants, qui gardent
  // leur couleur fixe (voir linkColor).
  legend_item_id: string | null;
  // Visibilité croisée au choix (schema_v23.sql, demande de Martin,
  // 2026-10-06) — id du membre à ne JAMAIS faire apparaître comme
  // "étranger" via CE lien précis dans un arbre autre que le sien
  // (typiquement : le membre local, "d'un unique arbre", qu'on ne veut
  // pas voir surgir automatiquement dans l'arbre d'origine de l'autre
  // extrémité du lien, elle-même étrangère). null = comportement normal,
  // visible partout où le lien touche un membre local. Voir loadData.
  hide_member_id: string | null;
};

// Bug + demande de Martin, 2026-10-03 : "quand on bouge un membre d'un
// autre arbre dans son nouvel arbre... ça ne sauvegarde pas sa position"
// + "si un membre d'un autre arbre a dirigé le pays dans son arbre...
// dans l'arbre dans lequel il arrive, il faut la possibilité de le
// cocher (ce point est indépendant dans chaque arbre)" — pos_x/pos_y et
// is_leader sur genealogy_members n'ont de sens que dans l'arbre
// D'ORIGINE du membre (owner_type/owner_id de sa propre ligne). Pour un
// membre étranger vu dans un AUTRE arbre, on a besoin d'un second
// pos_x/pos_y et d'un second is_leader, propres à CETTE PAIRE
// (membre, arbre visiteur) — voir supabase/schema_v16.sql
// (genealogy_foreign_states, clé (member_id, owner_type, owner_id)).
// legend_item_id suit la même logique (schema_v17.sql) : l'anneau d'un
// membre étranger, VU DEPUIS CET ARBRE, référence une entrée de la
// légende de CET ARBRE VISITEUR (pas celle de son arbre d'origine).
type ForeignStateRow = {
  member_id: string;
  pos_x: number | null;
  pos_y: number | null;
  is_leader: boolean;
  // Déprécié depuis schema_v24.sql (statuts cumulés, genealogy_member_statuses
  // ci-dessous) — plus lu/écrit par le code à partir de cette version,
  // laissé en base par prudence (voir le commentaire de schema_v24.sql).
  legend_item_id: string | null;
};

// Statuts CUMULÉS d'un membre (schema_v24.sql, demande de Martin,
// 2026-10-12) — remplace l'ancien anneau unique (MemberRow.legend_item_id
// / ForeignStateRow.legend_item_id ci-dessus, désormais ignorés) : un
// (membre, arbre visiteur) peut avoir N statuts, chacun une entrée de la
// légende de CET arbre (kind="status"). `position` fixe l'ordre d'ajout
// (le plus petit = ajouté en premier = anneau le plus proche de la
// photo) — voir memberRingColors, qui les dessine dans cet ordre puis
// ajoute l'anneau rouge "A dirigé le pays" (is_leader, séparé, TOUJOURS
// le plus extérieur). owner_type/owner_id désigne toujours l'arbre
// VISITEUR (= currentOwner au moment du chargement), qu'il s'agisse d'un
// membre local ou étranger à cet arbre — un seul type de ligne, une seule
// requête par arbre (voir loadMemberStatuses).
type MemberStatusRow = {
  id: string;
  member_id: string;
  owner_type: string;
  owner_id: string;
  legend_item_id: string;
  position: number;
};

// Position d'affichage calculée pour cette ouverture de l'arbre (voir note
// ci-dessus sur les membres étrangers) — distincte de pos_x/pos_y (valeur
// persistée, pertinente uniquement dans l'arbre d'origine du membre).
type DisplayPos = { x: number; y: number };

// Cartes agrandies (demande de Martin, 2026-10-03, puis re-demandé le
// même jour : "agrandit tout le monde, tout doit être plus grand dans
// les arbres, c'est trop petit là") — second passage d'agrandissement
// (~1.35x le précédent, lui-même ~1.4x l'original 158x176/82). Voir
// aussi style.css (.gen-card-photo, .gen-card-name, etc.) pour
// l'habillage assorti.
const CARD_W = 300;
const CARD_H = 340;
const CARD_PHOTO_H = 160;
// Aspect ratio de la zone photo de la carte (.gen-card-photo) — réutilisé
// comme ratio de cadrage dans le recadrage de photo (openCropModal
// ci-dessous) pour que la photo recadrée remplisse exactement cette zone
// sans bande ni recadrage navigateur imprévisible (object-fit: cover s'en
// charge déjà, mais autant livrer une image déjà au bon ratio).
const CARD_PHOTO_RATIO = CARD_W / CARD_PHOTO_H;
// Écart vertical minimum imposé entre un parent et son enfant lors de la
// création d'un lien "parent" (point demandé par Martin, 2026-10-03:
// "même si on peut déplacer, ceux nés plus tôt sont plus haut, ceux plus
// tard plus bas, les enfants sont en dessous") — voir
// enforceParentChildOrder ci-dessous. Le glisser-déposer libre reste
// entièrement possible ensuite : seule la position DE DÉPART est corrigée.
// Agrandi avec les cartes (230 → 300 → 400) pour garder un espacement
// cohérent avec la nouvelle taille.
const GENERATION_GAP = 460;
// Pixels par année pour le placement automatique d'un NOUVEAU membre selon
// son année de naissance par rapport aux membres existants de cet arbre
// (voir suggestYFromBirthYear) — purement indicatif, pas une échelle
// temporelle stricte (le glisser-déposer reste libre après coup).
const PX_PER_YEAR = 18;
// Échelle de dates (demande de Martin, 2026-10-22) : un membre se place à
// une hauteur liée à son année de naissance (yearToY, genealogyLayout.ts) ;
// glisser-déposer reste libre dans une bande de ±BAND_YEARS ans autour de
// cette hauteur — au-delà, la carte est retenue (Maj enfoncée = libre,
// pour relier un conjoint d'une autre époque).
const BAND_YEARS = 40;
const LAYOUT_OPTS = { originYear: 1000, pxPerYear: PX_PER_YEAR };

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function initials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (!parts.length) return "?";
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

function yearsLabel(birth: number | null, death: number | null): string {
  if (birth == null && death == null) return "";
  if (birth != null && death != null) return birth + " – " + death;
  if (birth != null) return "né(e) en " + birth;
  return "mort(e) en " + death;
}

export function initGenealogySystem(deps: {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  getProfile: () => { id: string; role: string } | null;
  openAuthPanel: () => void;
  showBanner?: (msg: string) => void;
  // Libellé lisible d'un owner (pays/groupe/mini-dossier), pour le badge
  // "membre d'un autre arbre" (ex. "Espagne"). Réutilise la même logique
  // que getOwnerLabel() de main.ts (fiches/recherche).
  getOwnerLabel: (ownerType: string, ownerId: string) => string | null;
  // Ferme la vue généalogie courante, ouvre le dossier de l'owner visé PUIS
  // son arbre — orchestré côté main.ts (qui seul connaît getAllCountryRefs/
  // groupsSystem/ficheDossier) ; voir le commentaire de câblage dans
  // main.ts pour le détail de la référence circulaire (même schéma que
  // ficheDeps/linksSystem).
  // focusMemberId optionnel (demande de Martin, 2026-10-06 : "le zoom sur
  // l'arbre B se fasse directement sur le personnage cliqué dans l'arbre
  // A") — centré/ouvert via focusMember() une fois l'arbre B chargé, voir
  // le câblage dans main.ts::openOwnerTree.
  openOwnerTree: (ownerType: string, ownerId: string, focusMemberId?: string) => Promise<void>;
  // Rattachement bidirectionnel membre d'arbre ↔ fiche/sous-catégorie du
  // même nom (demande de Martin, 2026-10-03) — résolution de navigation
  // déléguée à dossier.ts (seul à savoir comment ouvrir le bon dossier
  // pour une section/entrée/pays/groupe), voir resolveLinkTarget/
  // openLinkTarget dans src/dossier.ts.
  openLinkedFiche: (target: LinkTarget) => Promise<void>;
}) {
  const { supabase } = deps;
  // Point 4a (2026-10-03) : seul un compte admin peut modifier un arbre
  // généalogique (voir supabase/schema_v13.sql pour le pendant RLS). Pas de
  // fonction isAdmin() préexistante ici — même principe que
  // src/dossier.ts/src/groups.ts.
  function isAdmin(): boolean {
    return deps.getProfile()?.role === "admin" && !document.body.classList.contains("read-only-mode");
  }
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

  // --- DOM : construit une seule fois -------------------------------------
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="genealogy-view">
      <div id="genealogy-topbar">
        <button id="genealogy-back" class="btn-small">&larr; Retour au dossier</button>
        <h2 id="genealogy-title"></h2>
        <div id="genealogy-toolbar">
          <button id="genealogy-add-member" class="btn-small edit-control">&#43; Membre</button>
          <button id="genealogy-link-mode" class="btn-small edit-control">&#128279; Lier deux membres</button>
          <!-- Légende de couleurs par arbre (demande de Martin, 2026-10-06 :
               "entourer un membre de la couleur que l'on souhaite avec la
               légende que l'on souhaite" + "créer de nouveaux liens, avec
               la légende, la couleur souhaitée, propre à chaque arbre") —
               voir openLegendManager. -->
          <button id="genealogy-auto-layout" class="btn-small edit-control" title="Range tout l'arbre selon les dates : couples sur une même ligne, enfants centrés sous leurs parents">&#128197; Organiser par dates</button>
          <button id="genealogy-auto-layout-undo" class="btn-small edit-control" style="display:none;">&#8630; Annuler l'organisation</button>
          <button id="genealogy-manage-legend" class="btn-small edit-control">&#127912; L&eacute;gende</button>
          <span id="genealogy-link-hint" class="muted"></span>
        </div>
        <div id="genealogy-legend">
          <span class="gen-legend-item"><span class="gen-legend-line gen-legend-parent"></span>Ascendant / Descendant</span>
          <span class="gen-legend-item"><span class="gen-legend-line gen-legend-family"></span>Collatéraux</span>
          <span class="gen-legend-item"><span class="gen-legend-line gen-legend-spouse"></span>Mariage</span>
          <span class="gen-legend-item"><span class="gen-legend-dot gen-legend-foreign"></span>Membre d'un autre arbre</span>
          <!-- Entrées de légende personnalisées de cet arbre (couleurs
               anneaux/liens) — remplies dynamiquement, voir
               renderCustomLegendStrip. -->
          <span id="genealogy-legend-custom"></span>
        </div>
      </div>
      <div id="genealogy-canvas-wrap">
        <div id="genealogy-stage">
          <svg id="genealogy-links-svg"></svg>
          <div id="genealogy-nodes"></div>
        </div>
        <div id="genealogy-empty-hint" class="muted">Aucun membre pour le moment. Utilisez "&#43; Membre" pour commencer l'arbre.</div>
      </div>
    </div>

    <div id="gen-member-panel" class="panel side-panel">
      <button class="close-x" id="gen-member-close" aria-label="Fermer">&times;</button>
      <!-- Bandeau "membre d'un autre arbre" (demande de Martin, 2026-10-03) —
           affiché UNIQUEMENT en mode lecture d'un membre étranger (voir
           openForeignMemberPanel), masqué sinon. Son clic ouvre l'arbre
           d'origine via deps.openOwnerTree, au lieu de naviguer directement
           au clic sur la carte comme avant. -->
      <button type="button" id="gen-m-foreign-banner" style="display:none;"></button>
      <!-- Rattachement bidirectionnel membre ↔ fiche/sous-catégorie du même
           nom (demande de Martin, 2026-10-03) — voir renderFicheLinkBanner. -->
      <button type="button" id="gen-m-fiche-link-banner" class="genealogy-link-banner" style="display:none;"></button>
      <h2 id="gen-member-heading">Membre</h2>
      <label class="field-label">Nom</label>
      <input type="text" id="gen-m-name" maxlength="160">
      <label class="field-label">Photo</label>
      <div id="gen-m-photo-preview" class="gen-photo-preview"></div>
      <div class="dossier-form-actions">
        <button id="gen-m-photo-btn" class="btn-small edit-control">Changer la photo</button>
        <button id="gen-m-photo-recrop-btn" class="btn-small edit-control" style="display:none;">Recadrer</button>
      </div>
      <input type="file" id="gen-m-photo-input" accept="image/*" style="display:none;">
      <div id="gen-m-photo-status" class="muted"></div>
      <label class="field-label">Naissance (année)</label>
      <input type="text" id="gen-m-birth" inputmode="numeric" placeholder="ex. 1515">
      <label class="field-label">Décès (année, optionnel)</label>
      <input type="text" id="gen-m-death" inputmode="numeric" placeholder="ex. 1547">
      <label class="field-label">Titre / fonction</label>
      <input type="text" id="gen-m-title" placeholder="ex. Roi de France">
      <label class="field-label">Dynastie</label>
      <input type="text" id="gen-m-dynasty" placeholder="ex. Valois-Angoulême">
      <label class="gen-m-leader-check"><input type="checkbox" id="gen-m-leader"> A dirigé le pays</label>
      <!-- Statuts CUMULÉS (plusieurs anneaux concentriques) — demande de
           Martin, 2026-10-12 : "il faut que les statuts se cumulent [...]
           si il a un statut qui l'entoure en vert [...] puis 'a gouverné
           le pays', il doit être entouré en vert et autour en rouge".
           Remplace l'ancien <select> à choix unique (gen-m-legend) : un
           membre peut désormais avoir N statuts de la légende de CET
           arbre (genealogy_member_statuses, schema_v24.sql), affichés en
           chips dans l'ordre d'ajout — voir renderMemberStatusChips /
           addMemberStatus / removeMemberStatus. "A dirigé le pays"
           ci-dessus reste un champ séparé (is_leader, inchangé) : son
           anneau rouge est ajouté automatiquement par-dessus, TOUJOURS le
           plus extérieur (voir memberRingColors dans le rendu). -->
      <label class="field-label">Statuts (anneaux cumulables)</label>
      <div id="gen-m-statuses-chips" class="gen-m-statuses-chips"></div>
      <select id="gen-m-status-add"><option value="">+ Ajouter un statut…</option></select>
      <label class="field-label">Notes / biographie</label>
      <textarea id="gen-m-bio" rows="5"></textarea>
      <!-- Bouton "Enregistrer" retiré (demande de Martin, 2026-10-03 :
           "tout doit se faire en temps réel à chaque modification") — voir
           autosaveField()/autoCreateIfNeeded() : chaque champ s'enregistre
           lui-même au blur (au changement pour la case à cocher). -->
      <div id="gen-m-save-status" class="muted"></div>
      <div class="dossier-form-actions" style="margin-top:10px;">
        <button id="gen-m-delete" class="btn-small">Supprimer</button>
        <!-- Retrait "local" d'un membre d'un autre arbre (demande de
             Martin, 2026-10-06 : "Pouvoir supprimer une personne d'un
             autre arbre dans le nouveau sans le supprimer dans l'autre")
             — distinct de #gen-m-delete (qui supprime le membre
             PARTOUT) : ne retire que les liens avec CET arbre, voir
             removeForeignMemberFromThisTree. Affiché uniquement sur le
             panneau d'un membre étranger. -->
        <button id="gen-m-remove-from-tree" class="btn-small" style="display:none;">Retirer de cet arbre</button>
      </div>
      <div id="gen-m-relations">
        <label class="field-label">Liens</label>
        <div id="gen-m-relations-list"></div>
      </div>
      <!-- Bouton "Lier à un membre d'un autre arbre" sorti de #gen-m-relations
           (bug signalé par Martin, 2026-10-16 : "Meinhard III de Bavière est
           membre d'un autre arbre [...] je n'ai pas la possibilité [...] de
           RAJOUTER encore un membre d'un autre arbre lié à lui [...] l'option
           n'apparait pas") — openForeignMemberPanel masque #gen-m-relations
           en entier (display:none, la liste de liens n'a de sens que pour un
           membre LOCAL) puis tentait de réafficher CE bouton seul via son
           propre style.display, sans effet puisqu'un enfant reste masqué
           tant que son parent l'est. Bouton maintenant indépendant : visible
           aussi bien pour un membre local (openMemberPanel) qu'étranger
           (openForeignMemberPanel), voir gen-m-link-foreign plus bas. -->
      <div class="dossier-form-actions">
        <button id="gen-m-link-foreign" class="btn-small">Lier &agrave; un membre d'un autre arbre</button>
      </div>
      <!-- Demande de Martin, 2026-10-22 : faire apparaître, dans l'arbre
           ouvert, les proches d'un membre d'un autre arbre (parents +
           conjoints / enfants) sans recréer de lien. Visibles seulement sur
           le panneau d'un membre étranger (openForeignMemberPanel). -->
      <div class="dossier-form-actions" id="gen-m-show-relatives-row" style="display:none;">
        <button id="gen-m-show-parents" class="btn-small">Afficher ses parents et conjoint(s) ici</button>
        <button id="gen-m-show-children" class="btn-small">Afficher ses enfants ici</button>
      </div>
    </div>

    <div id="gen-relation-modal" class="poi-overlay">
      <div class="poi-overlay-box">
        <h3 id="gen-relation-modal-title">Quel est le lien ?</h3>
        <div id="gen-relation-modal-choices" class="dossier-form-actions" style="flex-direction:column;align-items:stretch;"></div>
        <button id="gen-relation-modal-cancel" class="btn-small" style="margin-top:10px;">Annuler</button>
      </div>
    </div>

    <!-- Choix de la couleur/légende pour un lien "Personnalisé" (demande
         de Martin, 2026-10-06) — second écran après avoir choisi
         "Personnalisé" dans gen-relation-modal, voir
         openCustomLinkLegendModal. -->
    <div id="gen-custom-link-modal" class="poi-overlay">
      <div class="poi-overlay-box">
        <h3>Lien personnalis&eacute;</h3>
        <select id="gen-custom-link-legend"></select>
        <div id="gen-custom-link-hint" class="muted" style="margin-top:6px;"></div>
        <div class="dossier-form-actions" style="margin-top:10px;">
          <button id="gen-custom-link-confirm" class="btn-primary">Valider</button>
          <button id="gen-custom-link-cancel" class="btn-small">Annuler</button>
        </div>
      </div>
    </div>

    <!-- Gestion de la légende de l'arbre (demande de Martin, 2026-10-06) —
         liste des paires (couleur, libellé) de CET arbre, ajout/suppression.
         Voir openLegendManager. -->
    <div id="gen-legend-modal" class="poi-overlay">
      <div class="poi-overlay-box">
        <h3>L&eacute;gende de l'arbre</h3>
        <div id="gen-legend-list"></div>
        <div id="gen-legend-add-row" style="margin-top:10px;">
          <!-- "Statut" (entoure un membre) vs "Lien" (colore une relation)
               — demande de Martin, 2026-10-06 : "il faut différencier la
               création d'un lien [...] et un statut [...], ce n'est pas
               la même chose" (schema_v22.sql). -->
          <div id="gen-legend-kind-row">
            <label><input type="radio" name="gen-legend-kind" value="status" checked> Statut (entoure un membre)</label>
            <label><input type="radio" name="gen-legend-kind" value="link"> Lien (couleur d'une relation)</label>
          </div>
          <div class="dossier-form-actions">
            <input type="color" id="gen-legend-new-color" value="#e63946">
            <input type="text" id="gen-legend-new-label" placeholder="Libell&eacute; (ex. Dirigeants)" maxlength="60">
            <button id="gen-legend-add-btn" class="btn-small">&#43; Ajouter</button>
          </div>
        </div>
        <button id="gen-legend-close" class="btn-small" style="margin-top:10px;">Fermer</button>
      </div>
    </div>

    <div id="gen-foreign-search-modal" class="poi-overlay">
      <div class="poi-overlay-box">
        <h3>Lier &agrave; un membre d'un autre arbre</h3>
        <input type="text" id="gen-foreign-search-input" placeholder="Nom du membre recherch&eacute;…" autocomplete="off">
        <div id="gen-foreign-search-results"></div>
        <button id="gen-foreign-search-cancel" class="btn-small" style="margin-top:10px;">Annuler</button>
      </div>
    </div>

    <div id="gen-photo-crop-modal" class="poi-overlay">
      <div class="poi-overlay-box gen-crop-box">
        <h3>Recadrer la photo</h3>
        <div id="gen-crop-hint">Glissez le cadre pour le déplacer, la poignée (coin) pour le redimensionner.</div>
        <div id="gen-crop-stage">
          <img id="gen-crop-img" alt="">
          <div id="gen-crop-rect"><div id="gen-crop-handle"></div></div>
        </div>
        <div class="dossier-form-actions" style="margin-top:10px;">
          <button id="gen-crop-confirm" class="btn-primary">Valider le cadrage</button>
          <button id="gen-crop-cancel" class="btn-small">Annuler</button>
        </div>
      </div>
    </div>
  `;
  document.body.appendChild(root);

  // --- État ----------------------------------------------------------------
  let currentOwner: DossierOwnerRef | null = null;
  let members: MemberRow[] = [];
  let relations: RelationRow[] = [];
  // Membres référencés par une relation mais appartenant à un autre arbre —
  // chargés à part (voir loadData), rendus en lecture seule (gen-card-foreign).
  let foreignMembers = new Map<string, MemberRow>();
  // Position/is_leader "vus depuis CET arbre" pour un membre étranger —
  // voir ForeignStateRow ci-dessus. Clé = member_id (unique dans le
  // contexte d'un seul arbre ouvert à la fois).
  let foreignStates = new Map<string, ForeignStateRow>();
  // Légende de couleurs de L'ARBRE COURANT (schema_v17.sql, demande de
  // Martin, 2026-10-06) — rechargée à chaque ouverture d'arbre (loadData),
  // comme members/relations.
  let legendItems: LegendItem[] = [];
  // Statuts cumulés de L'ARBRE COURANT (schema_v24.sql, demande de Martin,
  // 2026-10-12) — rechargés à chaque ouverture d'arbre (loadData), comme
  // legendItems. Clé = member_id, valeur = SES statuts dans CET arbre,
  // déjà triés par position ascendante (anneau le plus intérieur en
  // premier) — voir loadMemberStatuses.
  let memberStatuses = new Map<string, MemberStatusRow[]>();
  const displayPos = new Map<string, DisplayPos>();
  let linkModeActive = false;
  let linkFirstId: string | null = null;
  let editingMemberId: string | null = null;
  let photoPendingFile: File | null = null;

  let zoomTransform = d3.zoomIdentity;
  const stage = $("genealogy-stage");
  const canvasWrap = $("genealogy-canvas-wrap");
  const svg = $("genealogy-links-svg") as unknown as SVGSVGElement;
  const nodesLayer = $("genealogy-nodes");

  const zoomBehavior = d3
    .zoom<HTMLDivElement, unknown>()
    .scaleExtent([0.25, 2.5])
    .filter((event: Event) => {
      // Un mousedown/touchstart sur une carte démarre un GLISSER DE MEMBRE
      // (géré à part par attachCardInteractions ci-dessous), pas un pan du
      // canevas — coordination des deux gestes pour qu'ils ne se marchent
      // pas dessus. Tous les autres événements (molette, pan à 2 doigts,
      // double-clic) suivent le comportement par défaut de d3-zoom.
      if (event.type === "mousedown" || event.type === "touchstart") {
        return !(event.target as HTMLElement).closest(".gen-card");
      }
      return true;
    })
    .on("zoom", (event: d3.D3ZoomEvent<HTMLDivElement, unknown>) => {
      zoomTransform = event.transform;
      stage.style.transform = "translate(" + zoomTransform.x + "px," + zoomTransform.y + "px) scale(" + zoomTransform.k + ")";
    });
  d3.select(canvasWrap as unknown as HTMLDivElement).call(zoomBehavior);

  function resetView() {
    zoomTransform = d3.zoomIdentity.translate(canvasWrap.clientWidth / 2 - 400, canvasWrap.clientHeight / 2 - 300);
    d3.select(canvasWrap as unknown as HTMLDivElement).call(zoomBehavior.transform, zoomTransform);
  }

  // Centre le canevas sur un membre précis plutôt que sur le centre par
  // défaut de l'arbre (demande de Martin : "lorsque l'on clique sur un
  // renvoi dans un arbre généalogique, il faudrait que le zoom sur l'arbre
  // B se fasse directement sur le personnage cliqué dans l'arbre A, et non
  // un zoom sur le milieu de l'arbre"). Repose sur displayPos (repère du
  // canevas, même valeurs que celles utilisées par renderNodes pour
  // positionner les cartes), donc fonctionne aussi bien pour un membre
  // LOCAL à cet arbre que pour un membre ÉTRANGER déjà rattaché (sa
  // position dans CET arbre, calculée par computeForeignPosition/loadData).
  function centerOnMember(memberId: string, k = 1) {
    const pos = displayPos.get(memberId);
    if (!pos) return;
    const cx = pos.x + CARD_W / 2;
    const cy = pos.y + CARD_H / 2;
    const clampedK = Math.min(2.5, Math.max(0.25, k));
    const next = d3.zoomIdentity
      .translate(canvasWrap.clientWidth / 2 - cx * clampedK, canvasWrap.clientHeight / 2 - cy * clampedK)
      .scale(clampedK);
    zoomTransform = next;
    d3.select(canvasWrap as unknown as HTMLDivElement).call(zoomBehavior.transform, next);
  }

  // Point 4a (2026-10-03) : distingue "pas connecté" (ouvre le panneau de
  // connexion, comme avant) de "connecté mais pas admin" (message de
  // droits insuffisants — ouvrir openAuthPanel() n'aurait aucun sens
  // puisque l'utilisateur EST déjà connecté).
  function requireAuthOr(action: () => void) {
    if (!deps.getSession()) {
      deps.openAuthPanel();
      return;
    }
    if (!isAdmin()) {
      deps.showBanner?.("Tu n'as pas les droits d'édition sur cet atlas.");
      return;
    }
    action();
  }

  // Chargement de la légende de l'arbre (schema_v17.sql), hors du chemin
  // critique de loadData (voir l'appel "void loadLegendItems(owner)"
  // ci-dessous) : une table pas encore migrée ou un réseau lent/en échec
  // ne fait ici qu'un arbre temporairement sans anneaux de couleur, jamais
  // un arbre qui ne charge pas du tout. Ignore silencieusement un résultat
  // qui arriverait après qu'on a changé d'arbre entre-temps (currentOwner
  // a changé), pour ne jamais appliquer une légende au mauvais arbre.
  async function loadLegendItems(owner: DossierOwnerRef) {
    try {
      const { data: legendRows, error: legendErr } = await supabase
        .from("genealogy_legend_items")
        .select("id, owner_type, owner_id, color, label, position, kind")
        .eq("owner_type", owner.type)
        .eq("owner_id", owner.id)
        .order("position");
      if (legendErr) throw legendErr;
      if (currentOwner !== owner) return;
      legendItems = (legendRows as LegendItem[] | null) || [];
    } catch (legendErr) {
      console.error("Échec du chargement de la légende (schema_v17.sql exécutée ?) :", legendErr);
      if (currentOwner !== owner) return;
      legendItems = [];
    }
    renderCustomLegendStrip();
    renderNodes();
  }

  // Chargement des statuts cumulés de l'arbre (schema_v24.sql), hors du
  // chemin critique de loadData — même principe que loadLegendItems
  // ci-dessus : une table pas encore migrée ou un réseau lent/en échec ne
  // fait qu'un arbre temporairement sans anneaux de statut, jamais un
  // arbre qui ne charge pas du tout.
  async function loadMemberStatuses(owner: DossierOwnerRef) {
    try {
      const { data: rows, error } = await supabase
        .from("genealogy_member_statuses")
        .select("id, member_id, owner_type, owner_id, legend_item_id, position")
        .eq("owner_type", owner.type)
        .eq("owner_id", owner.id)
        .order("position");
      if (error) throw error;
      if (currentOwner !== owner) return;
      const next = new Map<string, MemberStatusRow[]>();
      (rows as MemberStatusRow[] | null)?.forEach((r) => {
        const list = next.get(r.member_id) || [];
        list.push(r);
        next.set(r.member_id, list);
      });
      memberStatuses = next;
    } catch (err) {
      console.error("Échec du chargement des statuts (schema_v24.sql exécutée ?) :", err);
      if (currentOwner !== owner) return;
      memberStatuses = new Map();
    }
    renderNodes();
    if ($("gen-member-panel").classList.contains("open")) renderMemberStatusChips();
  }

  // --- Chargement des données ------------------------------------------------
  // Tout le corps est en try/catch : un échec réseau (sandbox sans accès à
  // supabase.co, ou simplement hors-ligne) peut faire REJETER la promesse
  // fetch sous-jacente au lieu de résoudre avec un objet {error} (constaté en
  // conditions réelles, contrairement à d'autres modules du dossier) — sans
  // ce filet, la vue restait bloquée sur rien (ni cartes, ni message
  // "Aucun membre") au lieu d'afficher un état vide exploitable.
  async function loadData(owner: DossierOwnerRef) {
    nodesLayer.innerHTML = "";
    svg.innerHTML = "";
    $("genealogy-empty-hint").style.display = "none";
    members = [];
    relations = [];
    foreignMembers = new Map();
    foreignStates = new Map();
    legendItems = [];
    memberStatuses = new Map();
    try {
      const { data: memberRows, error: memberErr } = await supabase
        .from("genealogy_members")
        .select(
          "id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader, legend_item_id"
        )
        .eq("owner_type", owner.type)
        .eq("owner_id", owner.id);
      if (memberErr) throw memberErr;
      members = (memberRows as MemberRow[] | null) || [];
      // Légende de cet arbre (schema_v17.sql) — chargée à PART, en tâche de
      // fond (void, jamais attendue ici) : ni une table pas encore migrée,
      // ni un réseau lent/en échec ne doivent retarder ou casser
      // l'affichage des membres/liens eux-mêmes (sans ça, l'arbre entier
      // resterait vide/bloqué tant que cette requête n'a pas fini — bien
      // plus grave qu'un simple manque d'anneaux de couleur). Voir
      // loadLegendItems ci-dessous : elle rafraîchit l'UI concernée
      // (bande de légende + anneaux) une fois résolue, quel que soit le
      // délai.
      void loadLegendItems(owner);
      void loadMemberStatuses(owner);
      const ids = members.map((m) => m.id);
      if (ids.length) {
        const { data: relRows, error: relErr } = await supabase
          .from("genealogy_relations")
          .select("id, member_a_id, member_b_id, relation_type, created_by, legend_item_id, hide_member_id")
          .or("member_a_id.in.(" + ids.join(",") + "),member_b_id.in.(" + ids.join(",") + ")");
        if (relErr) throw relErr;
        relations = (relRows as RelationRow[] | null) || [];
        const localIds = new Set(ids);
        // Visibilité croisée au choix (schema_v23.sql, demande de Martin,
        // 2026-10-06 : "je dois avoir un message pour savoir si je veux
        // faire apparaître la personne A dans l'arbre de la personne B" —
        // exemple donné : lier Emma de Bavière, membre UNIQUEMENT de
        // l'arbre "Test", à Ermengarde, étrangère dans "Test" mais LOCALE
        // aux "Carolingiens" — jusqu'ici, la seule existence de ce lien
        // suffisait à faire automatiquement apparaître Emma dans l'arbre
        // Carolingiens dès qu'il se rechargeait, sans que personne ne l'ait
        // demandé). createRelation (plus bas) demande confirmation et, en
        // cas de refus, enregistre l'id du membre à ne JAMAIS "découvrir"
        // comme étranger via CE lien précis dans hide_member_id. Un lien
        // avec hide_member_id reste normalement visible dans l'arbre
        // D'ORIGINE de ce membre (c'est forcément là qu'il a été créé et
        // qu'il doit rester visible) — on l'exclut donc seulement
        // lorsqu'on charge un AUTRE arbre que celui-ci.
        relations = relations.filter((r) => !r.hide_member_id || localIds.has(r.hide_member_id));
        const foreignIds = new Set<string>();
        relations.forEach((r) => {
          if (!localIds.has(r.member_a_id)) foreignIds.add(r.member_a_id);
          if (!localIds.has(r.member_b_id)) foreignIds.add(r.member_b_id);
        });
        // Membres d'un autre arbre épinglés dans CET arbre (schema_v36.sql,
        // demande de Martin, 2026-10-22) : affichés même sans lien direct
        // avec un membre local (ex. les parents d'un étranger lui-même
        // relié à un local). Requête isolée : si schema_v36.sql n'est pas
        // encore exécutée, on l'ignore sans casser le chargement.
        try {
          const { data: pinRows, error: pinErr } = await supabase
            .from("genealogy_foreign_states")
            .select("member_id")
            .eq("owner_type", owner.type)
            .eq("owner_id", owner.id)
            .eq("pinned", true);
          if (!pinErr) (pinRows as { member_id: string }[] | null)?.forEach((r) => { if (!localIds.has(r.member_id)) foreignIds.add(r.member_id); });
        } catch {
          /* colonne pinned absente : ignoré */
        }
        // Membres étrangers MASQUÉS dans cet arbre (schema_v37.sql, demande
        // de Martin, 2026-10-22) : « Retirer de cet arbre » ne supprime plus
        // aucun lien, il masque seulement le membre ici.
        try {
          const { data: hidRows, error: hidErr } = await supabase
            .from("genealogy_foreign_states")
            .select("member_id")
            .eq("owner_type", owner.type)
            .eq("owner_id", owner.id)
            .eq("hidden", true);
          if (!hidErr) {
            const hidden = new Set((hidRows as { member_id: string }[] | null)?.map((r) => r.member_id) || []);
            hidden.forEach((id) => foreignIds.delete(id));
            relations = relations.filter((r) => !hidden.has(r.member_a_id) && !hidden.has(r.member_b_id));
          }
        } catch {
          /* colonne hidden absente : ignoré */
        }
        if (foreignIds.size) {
          const { data: fRows } = await supabase
            .from("genealogy_members")
            .select(
              "id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader, legend_item_id"
            )
            .in("id", Array.from(foreignIds));
          (fRows as MemberRow[] | null)?.forEach((m) => foreignMembers.set(m.id, m));
          // État "vu depuis cet arbre" (position glissée ici + case "a
          // dirigé le pays" propre à cet arbre) — voir ForeignStateRow.
          const { data: fsRows } = await supabase
            .from("genealogy_foreign_states")
            .select("member_id, pos_x, pos_y, is_leader, legend_item_id")
            .eq("owner_type", owner.type)
            .eq("owner_id", owner.id)
            .in("member_id", Array.from(foreignIds));
          (fsRows as ForeignStateRow[] | null)?.forEach((s) => foreignStates.set(s.member_id, s));

          // BUG signalé par Martin, 2026-10-06 : "si je fais un lien entre
          // 2 personnes d'un autre arbre [...] le lien n'apparaît pas".
          // Cause : la requête ci-dessus (.or("member_a_id.in(ids)...")) ne
          // récupère que les relations touchant au moins un membre LOCAL —
          // une relation entre DEUX membres tous deux étrangers (ex. Louis
          // Ier et Ermengarde, chacun relié à cet arbre seulement via leur
          // enfant local) n'a NI member_a_id NI member_b_id dans `ids`, donc
          // n'est jamais chargée, même si les deux membres eux-mêmes le
          // sont (via d'AUTRES relations). On refait donc un second passage,
          // sur l'ensemble élargi (locaux + étrangers maintenant connus),
          // pour récupérer ces relations purement "étranger ↔ étranger"
          // manquées par le premier filtre — fusionnées sans doublon avec
          // `relations` (déjà peuplé par la requête précédente).
          const extendedIds = Array.from(new Set([...ids, ...Array.from(foreignIds)]));
          const { data: extraRelRows } = await supabase
            .from("genealogy_relations")
            .select("id, member_a_id, member_b_id, relation_type, created_by, legend_item_id, hide_member_id")
            .in("member_a_id", extendedIds)
            .in("member_b_id", extendedIds);
          const knownRelIds = new Set(relations.map((r) => r.id));
          (extraRelRows as RelationRow[] | null)?.forEach((r) => {
            // Même filtre hide_member_id que la requête principale
            // ci-dessus (schema_v23.sql) — cette requête de secours ne
            // doit pas réintroduire par la bande un lien volontairement
            // masqué pour cet arbre.
            if (r.hide_member_id && !localIds.has(r.hide_member_id)) return;
            if (!knownRelIds.has(r.id)) {
              relations.push(r);
              knownRelIds.add(r.id);
            }
          });
        }
      }
    } catch (err) {
      console.error("Échec du chargement de l'arbre (schema_v11.sql exécutée ? réseau indisponible ?) :", err);
      members = [];
      relations = [];
      foreignMembers = new Map();
      foreignStates = new Map();
      legendItems = [];
      memberStatuses = new Map();
    }
    displayPos.clear();
    members.forEach((m) => displayPos.set(m.id, { x: m.pos_x, y: m.pos_y }));
    // Position des membres étrangers : si on l'a déjà glissé et enregistré
    // DANS CET ARBRE (foreignStates, bug corrigé le 2026-10-03), on reprend
    // cette position enregistrée ; sinon, à distance fixe du premier
    // membre local auquel il est relié (comme avant).
    relations.forEach((r) => {
      [r.member_a_id, r.member_b_id].forEach((id) => {
        if (displayPos.has(id) || !foreignMembers.has(id)) return;
        const saved = foreignStates.get(id);
        if (saved && saved.pos_x != null && saved.pos_y != null) {
          displayPos.set(id, { x: saved.pos_x, y: saved.pos_y });
          return;
        }
        const other = displayPos.has(r.member_a_id) ? r.member_a_id : r.member_b_id;
        const anchor = displayPos.get(other === id ? r.member_b_id : other);
        if (!anchor) return;
        let idx = 0;
        relations.forEach((rr) => {
          if (rr.member_a_id === id || rr.member_b_id === id) idx++;
        });
        const angle = (idx * 67) % 360 * (Math.PI / 180);
        displayPos.set(id, { x: anchor.x + Math.cos(angle) * 260, y: anchor.y + Math.sin(angle) * 260 });
      });
    });
    placeRemainingForeign();
    renderAll();
    renderCustomLegendStrip();
    if (!members.length) $("genealogy-empty-hint").style.display = "";
  }

  // --- Échelle de dates ----------------------------------------------------
  // Hauteur "attendue" d'un membre = année de naissance sur l'échelle,
  // décalée de la médiane (hauteur réelle − hauteur de l'échelle) des
  // membres locaux datés de CET arbre : chaque arbre garde son propre
  // repère, donc un arbre ancien non encore organisé n'est pas bousculé.
  function yearForExpectation(m: MemberRow): number | null {
    if (m.birth_year != null) return m.birth_year;
    if (m.death_year != null) return m.death_year - 55;
    return null;
  }
  function treeYBaseline(): number {
    const offs: number[] = [];
    members.forEach((m) => {
      const yr = yearForExpectation(m);
      const pos = displayPos.get(m.id);
      if (yr != null && pos) offs.push(pos.y - yearToY(yr, LAYOUT_OPTS));
    });
    if (!offs.length) return 0;
    offs.sort((a, b) => a - b);
    return offs[Math.floor(offs.length / 2)];
  }
  function expectedY(m: MemberRow): number | null {
    const yr = yearForExpectation(m);
    if (yr == null) return null;
    return treeYBaseline() + yearToY(yr, LAYOUT_OPTS);
  }

  // Organisation automatique (bouton "Organiser par dates").
  let layoutUndo: { local: Map<string, { x: number; y: number }>; foreign: Map<string, { x: number | null; y: number | null }> } | null = null;
  async function applyPositions(local: Map<string, { x: number; y: number }>, foreign: Map<string, { x: number | null; y: number | null }>) {
    if (!currentOwner) return;
    const jobs: Promise<unknown>[] = [];
    local.forEach((p, id) => {
      const m = members.find((x) => x.id === id);
      if (m) {
        m.pos_x = p.x as number;
        m.pos_y = p.y as number;
      }
      jobs.push(Promise.resolve(supabase.from("genealogy_members").update({ pos_x: p.x, pos_y: p.y }).eq("id", id)));
    });
    const rows: Record<string, unknown>[] = [];
    foreign.forEach((p, id) => {
      const st = foreignStates.get(id) || { member_id: id, pos_x: null, pos_y: null, is_leader: false, legend_item_id: null };
      st.pos_x = p.x;
      st.pos_y = p.y;
      foreignStates.set(id, st);
      rows.push({ member_id: id, owner_type: currentOwner!.type, owner_id: currentOwner!.id, pos_x: p.x, pos_y: p.y, is_leader: st.is_leader });
    });
    if (rows.length) jobs.push(Promise.resolve(supabase.from("genealogy_foreign_states").upsert(rows, { onConflict: "member_id,owner_type,owner_id" })));
    await Promise.all(jobs);
    await loadData(currentOwner);
  }
  async function autoLayoutTree() {
    if (!currentOwner || !isAdmin()) return;
    if (!members.length) return;
    if (
      !(await customConfirm(
        "Organiser tout cet arbre selon les dates ?\n\nLes positions de tous les membres (y compris ceux d'autres arbres affichés ici) seront recalculées : couples sur une même ligne, enfants centrés sous leurs parents. Un bouton « Annuler l'organisation » permet de revenir en arrière juste après."
      ))
    )
      return;
    const known = allKnownMembers();
    const nodes = Array.from(known.values()).map((m) => ({ id: m.id, birth: m.birth_year, death: m.death_year, name: m.name, female: guessFemale(m.name, m.title) }));
    const rels = relations.filter((r) => known.has(r.member_a_id) && known.has(r.member_b_id)).map((r) => ({ a: r.member_a_id, b: r.member_b_id, type: r.relation_type }));
    const pos = computeLayout(nodes, rels, {
      cardW: CARD_W,
      cardH: CARD_H,
      ...LAYOUT_OPTS,
      minGen: GENERATION_GAP,
      stdGen: GENERATION_GAP,
      localIds: new Set(members.map((m) => m.id)),
    });
    // Sauvegarde pour pouvoir annuler.
    const undoLocal = new Map<string, { x: number; y: number }>();
    members.forEach((m) => undoLocal.set(m.id, { x: m.pos_x, y: m.pos_y }));
    const undoForeign = new Map<string, { x: number | null; y: number | null }>();
    foreignMembers.forEach((_m, id) => {
      const st = foreignStates.get(id);
      undoForeign.set(id, { x: st?.pos_x ?? null, y: st?.pos_y ?? null });
    });
    const newLocal = new Map<string, { x: number; y: number }>();
    const newForeign = new Map<string, { x: number | null; y: number | null }>();
    pos.forEach((p, id) => {
      if (undoLocal.has(id)) newLocal.set(id, p);
      else if (undoForeign.has(id)) newForeign.set(id, p);
    });
    await applyPositions(newLocal, newForeign);
    layoutUndo = { local: undoLocal, foreign: undoForeign };
    $("genealogy-auto-layout-undo").style.display = "";
    deps.showBanner?.("Arbre organisé selon les dates.");
  }
  $("genealogy-auto-layout").addEventListener("click", () => requireAuthOr(() => void autoLayoutTree()));
  $("genealogy-auto-layout-undo").addEventListener("click", () => {
    const u = layoutUndo;
    if (!u) return;
    layoutUndo = null;
    $("genealogy-auto-layout-undo").style.display = "none";
    requireAuthOr(() => void applyPositions(u.local, u.foreign));
  });

  // Place les membres étrangers qui n'ont pas de position : ceux reliés
  // seulement à un AUTRE étranger (parents d'un étranger, épinglés — demande
  // de Martin, 2026-10-22). Un parent est posé une génération au-dessus de
  // son enfant, un enfant en dessous, un conjoint à côté ; on décale
  // ensuite horizontalement pour éviter de superposer une carte. Position
  // purement calculée (glisser-déposer pour fixer, comme avant).
  function placeRemainingForeign() {
    const free = (x: number, y: number) => {
      for (const p of displayPos.values()) if (Math.abs(p.x - x) < CARD_W + 40 && Math.abs(p.y - y) < 200) return false;
      return true;
    };
    const put = (id: string, x: number, y: number) => {
      let guard = 0;
      while (!free(x, y) && guard++ < 60) x += CARD_W + 40;
      displayPos.set(id, { x, y });
    };
    const pending = Array.from(foreignMembers.keys()).filter((id) => !displayPos.has(id));
    let progress = true;
    while (pending.length && progress) {
      progress = false;
      for (const id of pending.slice()) {
        const saved = foreignStates.get(id);
        if (saved && saved.pos_x != null && saved.pos_y != null) {
          displayPos.set(id, { x: saved.pos_x, y: saved.pos_y });
        } else {
          const r = relations.find((rr) => (rr.member_a_id === id && displayPos.has(rr.member_b_id)) || (rr.member_b_id === id && displayPos.has(rr.member_a_id)));
          if (!r) continue;
          const otherId = r.member_a_id === id ? r.member_b_id : r.member_a_id;
          const o = displayPos.get(otherId)!;
          if (r.relation_type === "parent") put(id, o.x, r.member_a_id === id ? o.y - GENERATION_GAP : o.y + GENERATION_GAP);
          else put(id, o.x + CARD_W + 40, o.y);
        }
        pending.splice(pending.indexOf(id), 1);
        progress = true;
      }
    }
    // Reste sans voisin placé (épinglé sans aucun lien chargé) : rangée en bas.
    let maxY = 0;
    displayPos.forEach((p) => { if (p.y > maxY) maxY = p.y; });
    pending.forEach((id, i) => {
      const saved = foreignStates.get(id);
      if (saved && saved.pos_x != null && saved.pos_y != null) displayPos.set(id, { x: saved.pos_x, y: saved.pos_y });
      else put(id, i * (CARD_W + 40), maxY + GENERATION_GAP);
    });
  }

  // Épingle des membres d'un autre arbre dans CET arbre (colonne pinned de
  // genealogy_foreign_states, schema_v36.sql) : conserve leurs éventuelles
  // position / case « a dirigé le pays » déjà enregistrées.
  async function pinForeignMembers(ids: string[]): Promise<boolean> {
    if (!currentOwner || !ids.length) return true;
    const localIds = new Set(members.map((m) => m.id));
    const rows = Array.from(new Set(ids))
      .filter((id) => !localIds.has(id))
      .map((id) => {
        const st = foreignStates.get(id);
        return {
          member_id: id,
          owner_type: currentOwner!.type,
          owner_id: currentOwner!.id,
          pos_x: st?.pos_x ?? null,
          pos_y: st?.pos_y ?? null,
          is_leader: st?.is_leader ?? false,
          pinned: true,
          hidden: false,
        };
      });
    if (!rows.length) return true;
    const { error } = await supabase.from("genealogy_foreign_states").upsert(rows, { onConflict: "member_id,owner_type,owner_id" });
    if (error) {
      console.error("Épinglage impossible (schema_v36/v37.sql exécutées ?) :", error);
      deps.showBanner?.("Impossible d'afficher ces membres ici : exécute d'abord schema_v36.sql puis schema_v37.sql dans Supabase.");
      return false;
    }
    return true;
  }

  // Bande de légende personnalisée dans le bandeau haut de l'arbre
  // (demande de Martin, 2026-10-06) — un item par entrée de légende de
  // CET arbre, pour compléter la légende fixe (parent/famille/mariage/
  // étranger) déjà affichée.
  function renderCustomLegendStrip() {
    const el = $("genealogy-legend-custom");
    // Puce ronde pour un "statut" (entoure un membre) vs petit trait pour
    // un "lien" (couleur d'une relation) — même distinction visuelle que
    // la légende fixe au-dessus (dot "Membre d'un autre arbre" vs traits
    // Ascendant/Collatéraux/Mariage), pour que la nature de chaque entrée
    // personnalisée se voie d'un coup d'œil (schema_v22.sql).
    el.innerHTML = legendItems
      .map((it) => {
        const swatch =
          it.kind === "link"
            ? '<span class="gen-legend-line" style="border-top-color:' + escapeHtml(it.color) + ';"></span>'
            : '<span class="gen-legend-dot" style="background:' + escapeHtml(it.color) + ';"></span>';
        return '<span class="gen-legend-item">' + swatch + escapeHtml(it.label) + "</span>";
      })
      .join("");
  }

  function legendItemById(id: string | null | undefined): LegendItem | null {
    if (!id) return null;
    return legendItems.find((it) => it.id === id) || null;
  }

  // Remplit un <select> avec "Aucune" + les entrées de légende de l'arbre
  // courant, puis sélectionne `selectedId` — réutilisé par le sélecteur
  // d'anneau du panneau membre (kind="status") et par le modal de lien
  // personnalisé (kind="link") : chacun ne doit proposer que les entrées
  // de SON kind (schema_v22.sql — "différencier la création d'un lien et
  // un statut, ce n'est pas la même chose").
  function renderLegendOptionsInto(select: HTMLSelectElement, selectedId: string | null, noneLabel = "Aucune", kind: LegendItemKind = "status") {
    select.innerHTML = '<option value="">' + escapeHtml(noneLabel) + "</option>";
    legendItems
      .filter((it) => it.kind === kind)
      .forEach((it) => {
        const opt = document.createElement("option");
        opt.value = it.id;
        opt.textContent = it.label;
        select.appendChild(opt);
      });
    select.value = selectedId || "";
  }

  // Id du membre actuellement affiché dans le panneau (local OU étranger —
  // les statuts sont toujours propres à CET arbre pour les deux, voir le
  // commentaire de MemberStatusRow) — null si le panneau est sur un
  // membre tout juste ouvert via "+ Membre" et pas encore enregistré
  // (pas encore d'id, voir createMemberNow).
  function currentStatusMemberId(): string | null {
    return editingMemberId || foreignPanelMemberId;
  }
  // Chips des statuts déjà assignés (ordre d'ajout, le plus ancien
  // d'abord) + select "+ Ajouter un statut…" listant les entrées de
  // légende "status" de CET arbre PAS ENCORE assignées à ce membre.
  function renderMemberStatusChips() {
    const chipsEl = $("gen-m-statuses-chips");
    const addSelect = $("gen-m-status-add") as HTMLSelectElement;
    const memberId = currentStatusMemberId();
    const canEdit = isAdmin() && !!memberId;
    chipsEl.innerHTML = "";
    const current = memberId ? memberStatuses.get(memberId) || [] : [];
    current.forEach((st) => {
      const item = legendItemById(st.legend_item_id);
      if (!item) return;
      const chip = document.createElement("span");
      chip.className = "gen-m-status-chip";
      const dot = document.createElement("span");
      dot.className = "gen-legend-dot";
      dot.style.background = item.color;
      chip.appendChild(dot);
      chip.appendChild(document.createTextNode(item.label));
      if (canEdit) {
        const rm = document.createElement("button");
        rm.type = "button";
        rm.textContent = "×";
        rm.title = "Retirer ce statut";
        rm.addEventListener("click", () => void removeMemberStatus(st.id));
        chip.appendChild(rm);
      }
      chipsEl.appendChild(chip);
    });
    const assignedIds = new Set(current.map((s) => s.legend_item_id));
    addSelect.innerHTML = '<option value="">+ Ajouter un statut…</option>';
    legendItems
      .filter((it) => it.kind === "status" && !assignedIds.has(it.id))
      .forEach((it) => {
        const opt = document.createElement("option");
        opt.value = it.id;
        opt.textContent = it.label;
        addSelect.appendChild(opt);
      });
    addSelect.disabled = !canEdit || !legendItems.some((it) => it.kind === "status" && !assignedIds.has(it.id));
    addSelect.value = "";
  }
  async function addMemberStatus(legendId: string) {
    const memberId = currentStatusMemberId();
    if (!currentOwner || !memberId || !isAdmin() || !legendId) return;
    const current = memberStatuses.get(memberId) || [];
    const nextPosition = current.reduce((max, s) => Math.max(max, s.position), -1) + 1;
    const { data, error } = await supabase
      .from("genealogy_member_statuses")
      .insert({
        member_id: memberId,
        owner_type: currentOwner.type,
        owner_id: currentOwner.id,
        legend_item_id: legendId,
        position: nextPosition,
        created_by: deps.getSession()?.user.id || null,
      })
      .select("id, member_id, owner_type, owner_id, legend_item_id, position")
      .single();
    if (error || !data) return;
    memberStatuses.set(memberId, current.concat([data as MemberStatusRow]));
    renderMemberStatusChips();
    renderAll();
  }
  async function removeMemberStatus(statusRowId: string) {
    const memberId = currentStatusMemberId();
    if (!memberId || !isAdmin()) return;
    await supabase.from("genealogy_member_statuses").delete().eq("id", statusRowId);
    memberStatuses.set(memberId, (memberStatuses.get(memberId) || []).filter((s) => s.id !== statusRowId));
    renderMemberStatusChips();
    renderAll();
  }
  $("gen-m-status-add").addEventListener("change", () => {
    const select = $("gen-m-status-add") as HTMLSelectElement;
    const legendId = select.value;
    if (legendId) void addMemberStatus(legendId);
  });

  function allKnownMembers(): Map<string, MemberRow> {
    const m = new Map<string, MemberRow>();
    members.forEach((x) => m.set(x.id, x));
    foreignMembers.forEach((x, id) => m.set(id, x));
    return m;
  }

  // --- Rendu -----------------------------------------------------------------
  function renderAll() {
    renderNodes();
    renderLinks();
  }

  // "entry" (point 2, 2026-10-03) : le genealogy_members.owner_id d'un
  // membre étranger est désormais l'id d'une ENTRÉE de dossier, pas un
  // pays/groupe directement — deps.getOwnerLabel ne sait résoudre que des
  // owners de dossier classiques. On résout donc ce cas à part, à la
  // volée et en cache (une seule requête par entrée visitée), via
  // dossier_entries (title, owner_type, owner_id) -> deps.getOwnerLabel
  // sur son PROPRE owner — "<pays> — <titre de l'arbre>".
  const entryOwnerLabelCache = new Map<string, string>();
  function resolveEntryOwnerLabel(entryId: string): string {
    const cached = entryOwnerLabelCache.get(entryId);
    if (cached !== undefined) return cached;
    entryOwnerLabelCache.set(entryId, "…");
    void supabase
      .from("dossier_entries")
      .select("title, owner_type, owner_id")
      .eq("id", entryId)
      .maybeSingle()
      .then(({ data }) => {
        let label = "Autre dossier";
        if (data) {
          const parentLabel = deps.getOwnerLabel(data.owner_type as string, data.owner_id as string);
          const title = (data.title as string | null) || "Arbre généalogique";
          label = parentLabel ? parentLabel + " — " + title : title;
        }
        entryOwnerLabelCache.set(entryId, label);
        renderNodes();
      });
    return "…";
  }
  function foreignOwnerLabel(m: MemberRow): string {
    return m.owner_type === "entry" ? resolveEntryOwnerLabel(m.owner_id) : deps.getOwnerLabel(m.owner_type, m.owner_id) || m.owner_type;
  }
  // "A dirigé le pays" est indépendant par arbre pour un membre étranger
  // (demande de Martin, 2026-10-03) : m.is_leader (colonne de sa propre
  // ligne) ne vaut que dans SON arbre d'origine ; dans un autre arbre, on
  // lit plutôt foreignStates (défaut : décoché, comme avant).
  function effectiveIsLeader(m: MemberRow, isForeign: boolean): boolean {
    if (!isForeign) return m.is_leader;
    return foreignStates.get(m.id)?.is_leader || false;
  }
  // Couleur rouge fixe de l'anneau "A dirigé le pays" — même couleur que
  // l'ancien .gen-card-leader (style.css), reprise ici pour pouvoir
  // l'empiler avec les anneaux de statut (voir memberRingColors).
  const LEADER_RING_COLOR = "#e2493f";
  // Anneaux CUMULÉS d'un membre (demande de Martin, 2026-10-12), du plus
  // intérieur (collé à la photo) au plus extérieur :
  //   1. ses statuts (memberStatuses, déjà triés par ordre d'ajout) ;
  //   2. "A dirigé le pays" en dernier (TOUJOURS le plus extérieur de
  //      tous), que ce soit vrai pour ce membre LOCALEMENT (m.is_leader)
  //      ou pour CET arbre visiteur s'il est étranger (foreignStates) —
  //      voir effectiveIsLeader. Scope toujours CET arbre (memberStatuses
  //      est déjà chargé/filtré pour currentOwner, voir loadMemberStatuses).
  function memberRingColors(m: MemberRow, isForeign: boolean): string[] {
    const statuses = memberStatuses.get(m.id) || [];
    const colors = statuses.map((s) => legendItemById(s.legend_item_id)?.color).filter((c): c is string => !!c);
    if (effectiveIsLeader(m, isForeign)) colors.push(LEADER_RING_COLOR);
    return colors;
  }
  // Construit le box-shadow empilé (un cercle concentric par couleur,
  // 3px plus large que le précédent, même épaisseur 2px que l'ancien
  // anneau unique) + le drop shadow habituel de la carte.
  function ringsBoxShadow(colors: string[]): string {
    const rings = colors.map((c, i) => "0 0 0 " + (2 + i * 3) + "px " + c);
    return rings.concat(["0 6px 18px rgba(0,0,0,0.35)"]).join(", ");
  }

  function renderNodes() {
    nodesLayer.innerHTML = "";
    const known = allKnownMembers();
    known.forEach((m) => {
      const pos = displayPos.get(m.id);
      if (!pos) return;
      const isForeign = !(currentOwner && m.owner_type === currentOwner.type && m.owner_id === currentOwner.id);
      const ringColors = memberRingColors(m, isForeign);
      const card = document.createElement("div");
      card.className = "gen-card" + (ringColors.length ? " gen-card-ringed" : "");
      card.dataset.memberId = m.id;
      card.style.left = pos.x + "px";
      card.style.top = pos.y + "px";
      card.style.width = CARD_W + "px";
      if (ringColors.length) {
        card.style.borderColor = ringColors[0];
        card.style.boxShadow = ringsBoxShadow(ringColors);
      } else {
        card.style.borderColor = "";
        card.style.boxShadow = "";
      }
      const photoHtml = m.photo_url
        ? '<img src="' + escapeHtml(m.photo_url) + '" alt="">'
        : '<span class="gen-card-initials">' + escapeHtml(initials(m.name)) + "</span>";
      const foreignBadge = isForeign
        ? '<span class="gen-card-flag" title="Membre d\'un autre arbre">&#127757; ' + escapeHtml(foreignOwnerLabel(m)) + "</span>"
        : "";
      // Demande de Martin, 2026-10-06 : "retirer l'étiquette qui répète la
      // légende au-dessus du nom du personnage, le contour suffit" — la
      // puce .gen-card-ring-chip (couleur + libellé répété au-dessus du
      // nom) faisait doublon avec le contour .gen-card-ringed déjà posé
      // sur la carte (border-color + box-shadow, voir style.css), qui
      // porte à lui seul la même information. Rien d'autre ne change :
      // la couleur reste lisible sur le contour, et le libellé de la
      // légende reste visible dans le panneau du membre (sélecteur
      // "Anneau") et dans la bande de légende en haut de l'arbre.
      card.innerHTML =
        '<div class="gen-card-photo">' + photoHtml + "</div>" +
        foreignBadge +
        '<div class="gen-card-name">' + escapeHtml(m.name) + "</div>" +
        (m.title ? '<div class="gen-card-title-field">' + escapeHtml(m.title) + "</div>" : "") +
        '<div class="gen-card-dates">' + escapeHtml(yearsLabel(m.birth_year, m.death_year)) + "</div>";
      nodesLayer.appendChild(card);
      attachCardInteractions(card, m, isForeign);
    });
  }

  // "custom" (demande de Martin, 2026-10-06) : couleur venant de la
  // légende de l'arbre plutôt que fixée par le type — `legend` est
  // l'entrée résolue (voir legendItemById), ignorée pour les 3 autres
  // types qui gardent leur couleur fixe.
  function linkColor(type: RelationType, legend?: LegendItem | null): string {
    if (type === "custom") return legend?.color || "var(--cable-line)";
    if (type === "parent") return "var(--accent)";
    if (type === "family") return "var(--family-line)";
    return "var(--cable-line)";
  }

  function cardCenter(id: string): { x: number; y: number } | null {
    const p = displayPos.get(id);
    if (!p) return null;
    return { x: p.x + CARD_W / 2, y: p.y + CARD_H / 2 };
  }

  function drawLine(x1: number, y1: number, x2: number, y2: number, type: RelationType, extraClass?: string, legend?: LegendItem | null) {
    const NS = "http://www.w3.org/2000/svg";
    const line = document.createElementNS(NS, "line");
    line.setAttribute("x1", String(x1));
    line.setAttribute("y1", String(y1));
    line.setAttribute("x2", String(x2));
    line.setAttribute("y2", String(y2));
    line.setAttribute("stroke", linkColor(type, legend));
    line.setAttribute("stroke-width", type === "parent" ? "2.4" : "2");
    if (type === "spouse") line.setAttribute("stroke-dasharray", "5,4");
    if (type === "family") line.setAttribute("stroke-dasharray", "1.5,3.5");
    if (type === "custom") line.setAttribute("stroke-dasharray", "2,2.5");
    line.setAttribute("class", "gen-link gen-link-" + type + (extraClass ? " " + extraClass : ""));
    if (legend) line.setAttribute("title", legend.label);
    svg.appendChild(line);
  }

  // Point demandé par Martin, 2026-10-03 : "faire en sorte que la ligne
  // parte du lien de mariage jusqu'à l'enfant (plutôt que faire 2 lignes
  // qui partent de chaque parent), 1 seule qui part du milieu de la ligne
  // qui lie les parents" — pour un enfant dont les DEUX parents sont
  // connus sur cet arbre ET mariés entre eux (relation "spouse" entre les
  // deux), on dessine UNE ligne du milieu de leur trait de mariage
  // jusqu'à l'enfant, à la place des deux traits individuels
  // parent→enfant. Dans tous les autres cas (un seul parent connu sur cet
  // arbre, ou deux parents non mariés entre eux — réponse de Martin :
  // "directement du parent connu" / pas de cas de parents non mariés chez
  // lui) on garde le trait individuel d'origine, un par relation "parent".
  function renderLinks() {
    svg.innerHTML = "";
    const spouseKey = (a: string, b: string) => (a < b ? a + "|" + b : b + "|" + a);
    const spousePairs = new Set<string>();
    relations.forEach((r) => {
      if (r.relation_type === "spouse") spousePairs.add(spouseKey(r.member_a_id, r.member_b_id));
    });
    const parentRelsByChild = new Map<string, RelationRow[]>();
    relations.forEach((r) => {
      if (r.relation_type !== "parent") return;
      const list = parentRelsByChild.get(r.member_b_id) || [];
      list.push(r);
      parentRelsByChild.set(r.member_b_id, list);
    });
    const mergedParentRelIds = new Set<string>();
    parentRelsByChild.forEach((rels, childId) => {
      if (rels.length !== 2) return;
      const [p1, p2] = rels;
      if (p1.member_a_id === p2.member_a_id) return; // même parent listé 2x, rien à fusionner
      if (!spousePairs.has(spouseKey(p1.member_a_id, p2.member_a_id))) return;
      const a = cardCenter(p1.member_a_id);
      const b = cardCenter(p2.member_a_id);
      const c = cardCenter(childId);
      if (!a || !b || !c) return;
      const midX = (a.x + b.x) / 2;
      const midY = (a.y + b.y) / 2;
      // Reliement distinct demandé par Martin pour un membre d'un autre
      // arbre (voir .gen-link-foreign, style.css) — s'applique au trait
      // fusionné dès que l'un des deux parents OU l'enfant est étranger.
      const mergedForeign = foreignMembers.has(p1.member_a_id) || foreignMembers.has(p2.member_a_id) || foreignMembers.has(childId);
      drawLine(midX, midY, c.x, c.y, "parent", "gen-link-from-marriage" + (mergedForeign ? " gen-link-foreign" : ""));
      mergedParentRelIds.add(p1.id);
      mergedParentRelIds.add(p2.id);
    });
    relations.forEach((r) => {
      if (mergedParentRelIds.has(r.id)) return;
      const a = cardCenter(r.member_a_id);
      const b = cardCenter(r.member_b_id);
      if (!a || !b) return;
      const foreignLink = foreignMembers.has(r.member_a_id) || foreignMembers.has(r.member_b_id);
      drawLine(a.x, a.y, b.x, b.y, r.relation_type, foreignLink ? "gen-link-foreign" : undefined, legendItemById(r.legend_item_id));
    });
  }

  // --- Interactions carte (clic / glisser) ------------------------------------
  function attachCardInteractions(card: HTMLDivElement, member: MemberRow, isForeign: boolean) {
    let moved = false;
    let startScreenX = 0;
    let startScreenY = 0;
    let startPosX = 0;
    let startPosY = 0;

    function onMove(ev: MouseEvent | TouchEvent) {
      const p = "touches" in ev ? ev.touches[0] : ev;
      const dx = (p.clientX - startScreenX) / zoomTransform.k;
      const dy = (p.clientY - startScreenY) / zoomTransform.k;
      if (Math.abs(dx) > 3 || Math.abs(dy) > 3) moved = true;
      const nx = startPosX + dx;
      let ny = startPosY + dy;
      // Bande de dates : voir BAND_YEARS. Maj enfoncée = déplacement libre.
      const free = "shiftKey" in ev && (ev as MouseEvent).shiftKey;
      const expY = free ? null : expectedY(member);
      if (expY != null) {
        const band = BAND_YEARS * PX_PER_YEAR;
        ny = Math.min(Math.max(ny, Math.min(expY - band, startPosY)), Math.max(expY + band, startPosY));
      }
      card.style.left = nx + "px";
      card.style.top = ny + "px";
      displayPos.set(member.id, { x: nx, y: ny });
      renderLinks();
    }
    async function onEnd() {
      document.removeEventListener("mousemove", onMove);
      document.removeEventListener("mouseup", onEnd);
      document.removeEventListener("touchmove", onMove);
      document.removeEventListener("touchend", onEnd);
      // Glisser un membre LOCAL écrit directement dans sa ligne
      // genealogy_members (pos_x/pos_y, repère de SON arbre).
      //
      // BUG (2026-10-03, signalé par Martin, puis re-signalé le même jour
      // : "quand on bouge un membre d'un autre arbre... ça ne sauvegarde
      // pas sa position") : écrire la position calculée ICI dans la ligne
      // réelle du membre étranger déplacerait son point d'origine dans
      // SON PROPRE arbre — donc on n'y touche jamais. Mais la position
      // DANS CET ARBRE-CI doit malgré tout être mémorisée : on l'enregistre
      // dans genealogy_foreign_states (clé member_id + arbre visiteur,
      // voir ForeignStateRow/schema_v16.sql), relue par loadData() au
      // prochain chargement de CET arbre précisément.
      if (moved && !isForeign) {
        const pos = displayPos.get(member.id)!;
        member.pos_x = pos.x;
        member.pos_y = pos.y;
        await supabase.from("genealogy_members").update({ pos_x: pos.x, pos_y: pos.y }).eq("id", member.id);
      } else if (moved && isForeign && currentOwner) {
        const pos = displayPos.get(member.id)!;
        const st = foreignStates.get(member.id) || { member_id: member.id, pos_x: null, pos_y: null, is_leader: false, legend_item_id: null };
        st.pos_x = pos.x;
        st.pos_y = pos.y;
        foreignStates.set(member.id, st);
        await supabase.from("genealogy_foreign_states").upsert(
          {
            member_id: member.id,
            owner_type: currentOwner.type,
            owner_id: currentOwner.id,
            pos_x: pos.x,
            pos_y: pos.y,
            is_leader: st.is_leader,
            legend_item_id: st.legend_item_id,
          },
          { onConflict: "member_id,owner_type,owner_id" }
        );
      }
    }
    card.addEventListener("mousedown", (e) => {
      if (!isAdmin()) return;
      moved = false;
      startScreenX = e.clientX;
      startScreenY = e.clientY;
      const pos = displayPos.get(member.id)!;
      startPosX = pos.x;
      startPosY = pos.y;
      document.addEventListener("mousemove", onMove);
      document.addEventListener("mouseup", onEnd);
    });
    card.addEventListener("touchstart", (e) => {
      if (!isAdmin()) return;
      moved = false;
      const t = e.touches[0];
      startScreenX = t.clientX;
      startScreenY = t.clientY;
      const pos = displayPos.get(member.id)!;
      startPosX = pos.x;
      startPosY = pos.y;
      document.addEventListener("touchmove", onMove, { passive: true });
      document.addEventListener("touchend", onEnd);
    });
    card.addEventListener("click", () => {
      if (moved) return;
      // Demande de Martin, 2026-10-06 : "la possibilité de lier 2 membres
      // tous deux issus d'un autre arbre / de faire librement des liens à
      // partir de membres d'un autre arbre" — en mode "Lier deux membres",
      // un membre ÉTRANGER doit pouvoir être choisi comme extrémité du
      // lien exactement comme un membre local (le check doit donc passer
      // AVANT le isForeign ci-dessous, qui sinon ouvrirait systématiquement
      // le panneau en lecture seule à la place).
      if (linkModeActive) {
        handleLinkModeClick(member.id);
        return;
      }
      // Demande de Martin, 2026-10-03 : "il faut que quand on clique
      // dessus il y ait le menu déroulant à droite qui correspond à la
      // personne... donc pas directement dès qu'on clique sur le gars
      // comme maintenant" — on ouvre désormais le panneau (en lecture
      // seule) au lieu de naviguer tout de suite vers l'arbre d'origine ;
      // c'est le bandeau en haut du panneau qui permet d'y aller.
      if (isForeign) {
        openForeignMemberPanel(member);
        return;
      }
      openMemberPanel(member.id);
    });
    // Demande de Martin, 2026-10-06 : "rajoute la possibilité de double
    // clique sur une personne d'un autre arbre, c'est comme si on cliquait
    // sur 'aller à son arbre'" — raccourci au double-clic, en plus du
    // bandeau dans le panneau en lecture seule (openForeignMemberPanel) qui
    // reste disponible pour qui préfère vérifier avant de naviguer. Ignoré
    // en mode "Lier deux membres" (le double-clic y déclencherait deux
    // sélections au lieu d'une navigation) et pour un membre local (rien à
    // "rejoindre", le panneau d'édition s'ouvre déjà au simple clic).
    card.addEventListener("dblclick", () => {
      if (!isForeign || linkModeActive) return;
      void deps.openOwnerTree(member.owner_type, member.owner_id, member.id);
    });
  }

  // --- Gestion de la légende de l'arbre (demande de Martin, 2026-10-06) ------
  // Liste des entrées de légende de CET arbre — ajout (couleur + libellé)
  // et suppression. Supprimer une entrée ne supprime jamais les
  // membres/liens qui l'utilisaient (on delete set null, schema_v17.sql),
  // ils retombent juste sans anneau/couleur — cohérent avec "ne jamais
  // rien supprimer de ce qui est fait".
  // Liste groupée en 2 sections, "Statuts" (anneau de membre) et "Liens"
  // (couleur de relation) — demande de Martin, 2026-10-06 : "il faut
  // différencier la création d'un lien [...] et un statut [...], ce
  // n'est pas la même chose" (schema_v22.sql, voir LegendItemKind).
  function renderLegendManagerGroup(kind: LegendItemKind, heading: string) {
    const items = legendItems.filter((it) => it.kind === kind);
    const section = document.createElement("div");
    section.className = "gen-legend-manager-group";
    const h = document.createElement("div");
    h.className = "gen-legend-manager-heading";
    h.textContent = heading;
    section.appendChild(h);
    if (!items.length) {
      const empty = document.createElement("p");
      empty.className = "muted";
      empty.style.margin = "4px 0";
      empty.textContent = "Aucune entrée pour l'instant.";
      section.appendChild(empty);
      return section;
    }
    items.forEach((it) => {
      const row = document.createElement("div");
      row.className = "gen-relation-row";
      const swatch =
        kind === "link"
          ? '<span class="gen-legend-line" style="border-top-color:' + escapeHtml(it.color) + ';margin-right:7px;"></span>'
          : '<span class="gen-legend-dot" style="background:' + escapeHtml(it.color) + ';margin-right:7px;"></span>';
      row.innerHTML = swatch + "<span>" + escapeHtml(it.label) + "</span>";
      if (isAdmin()) {
        const del = document.createElement("button");
        del.type = "button";
        del.className = "entry-del edit-control";
        del.style.cssText = "position:static;opacity:1;";
        del.innerHTML = TRASH_ICON_SVG;
        del.title = "Supprimer cette entrée de légende";
        del.addEventListener("click", () => void deleteLegendItem(it.id));
        row.appendChild(del);
      }
      section.appendChild(row);
    });
    return section;
  }
  function renderLegendManagerList() {
    const list = $("gen-legend-list");
    list.innerHTML = "";
    list.appendChild(renderLegendManagerGroup("status", "🔵 Statuts — entourent un membre"));
    list.appendChild(renderLegendManagerGroup("link", "— Liens — colorent une relation"));
  }
  // Les chips de statuts du panneau membre sont remplies au MOMENT où il
  // s'ouvre (openMemberPanel/openForeignMemberPanel) — s'il reste ouvert
  // PENDANT qu'on ajoute/supprime une couleur via le gestionnaire de
  // légende (les deux sont accessibles en même temps, le bouton 🎨
  // Légende restant dans le bandeau haut), la liste doit être rafraîchie
  // tout de suite, sans attendre une fermeture/réouverture du panneau.
  function refreshOpenMemberLegendSelect() {
    if (!$("gen-member-panel").classList.contains("open")) return;
    renderMemberStatusChips();
  }
  async function deleteLegendItem(id: string) {
    if (!isAdmin()) return;
    if (!(await customConfirm("Supprimer cette entrée de légende ? Les membres/liens qui l'utilisaient perdront juste leur couleur."))) return;
    await supabase.from("genealogy_legend_items").delete().eq("id", id);
    legendItems = legendItems.filter((it) => it.id !== id);
    renderLegendManagerList();
    renderCustomLegendStrip();
    refreshOpenMemberLegendSelect();
    renderAll();
  }
  async function addLegendItem(color: string, label: string, kind: LegendItemKind) {
    if (!currentOwner || !isAdmin() || !label.trim()) return;
    const session = deps.getSession();
    const { data, error } = await supabase
      .from("genealogy_legend_items")
      .insert({
        owner_type: currentOwner.type,
        owner_id: currentOwner.id,
        color,
        label: label.trim(),
        position: legendItems.length,
        created_by: session?.user.id || null,
        kind,
      })
      .select("id, owner_type, owner_id, color, label, position, kind")
      .single();
    if (error || !data) {
      deps.showBanner?.("Erreur lors de l'ajout de la couleur.");
      return;
    }
    legendItems.push(data as LegendItem);
    renderLegendManagerList();
    renderCustomLegendStrip();
    refreshOpenMemberLegendSelect();
  }
  function openLegendManager() {
    renderLegendManagerList();
    ($("gen-legend-new-color") as HTMLInputElement).value = "#e63946";
    ($("gen-legend-new-label") as HTMLInputElement).value = "";
    (document.querySelector('input[name="gen-legend-kind"][value="status"]') as HTMLInputElement).checked = true;
    ($("gen-legend-add-row") as HTMLDivElement).style.display = isAdmin() ? "" : "none";
    $("gen-legend-modal").classList.add("open");
  }
  $("genealogy-manage-legend").addEventListener("click", () => requireAuthOr(openLegendManager));
  $("gen-legend-close").addEventListener("click", () => $("gen-legend-modal").classList.remove("open"));
  $("gen-legend-add-btn").addEventListener("click", () => {
    const color = ($("gen-legend-new-color") as HTMLInputElement).value;
    const label = ($("gen-legend-new-label") as HTMLInputElement).value;
    const kindInput = document.querySelector('input[name="gen-legend-kind"]:checked') as HTMLInputElement | null;
    const kind: LegendItemKind = kindInput?.value === "link" ? "link" : "status";
    if (!label.trim()) return;
    void addLegendItem(color, label, kind).then(() => {
      ($("gen-legend-new-label") as HTMLInputElement).value = "";
    });
  });

  // --- Mode "Lier deux membres" -----------------------------------------------
  function setLinkMode(active: boolean) {
    linkModeActive = active;
    linkFirstId = null;
    $("genealogy-link-mode").classList.toggle("active-mode", active);
    $("genealogy-link-hint").textContent = active ? "Cliquez un premier membre, puis un second." : "";
    nodesLayer.querySelectorAll(".gen-card.gen-link-selected").forEach((el) => el.classList.remove("gen-link-selected"));
  }
  $("genealogy-link-mode").addEventListener("click", () => {
    requireAuthOr(() => setLinkMode(!linkModeActive));
  });
  function handleLinkModeClick(id: string) {
    if (!linkFirstId) {
      linkFirstId = id;
      nodesLayer.querySelector('[data-member-id="' + id + '"]')?.classList.add("gen-link-selected");
      $("genealogy-link-hint").textContent = "Cliquez le second membre.";
      return;
    }
    if (linkFirstId === id) return;
    const aId = linkFirstId;
    const bId = id;
    setLinkMode(false);
    void openRelationTypeModal(aId, bId);
  }

  function memberName(id: string): string {
    return allKnownMembers().get(id)?.name || "ce membre";
  }

  function openRelationTypeModal(aId: string, bId: string): Promise<void> {
    return new Promise((resolve) => {
      const modal = $("gen-relation-modal");
      const choices = $("gen-relation-modal-choices");
      $("gen-relation-modal-title").textContent = "Quel est le lien entre " + memberName(aId) + " et " + memberName(bId) + " ?";
      choices.innerHTML = "";
      function cleanup() {
        modal.classList.remove("open");
        choices.innerHTML = "";
        resolve();
      }
      function addChoice(label: string, onPick: () => Promise<void>) {
        const b = document.createElement("button");
        b.type = "button";
        b.className = "btn-small";
        b.textContent = label;
        b.addEventListener("click", async () => {
          cleanup();
          await onPick();
        });
        choices.appendChild(b);
      }
      // Renommage demandé par Martin, 2026-10-03 : "la ligne jaune change
      // de dénomination, on change parent-enfant et ça devient
      // Ascendant/Descendant" / la ligne verte en pointillés "famille"
      // devient "Collatéraux" — uniquement les LIBELLÉS affichés, la
      // valeur interne "parent"/"family" (base de données) ne change pas.
      addChoice(memberName(aId) + " est l'ascendant de " + memberName(bId), () => createRelation(aId, bId, "parent"));
      addChoice(memberName(bId) + " est l'ascendant de " + memberName(aId), () => createRelation(bId, aId, "parent"));
      addChoice(memberName(aId) + " et " + memberName(bId) + " sont mariés", () => createRelation(aId, bId, "spouse"));
      addChoice(memberName(aId) + " et " + memberName(bId) + " sont collatéraux (sans lien direct)", () => createRelation(aId, bId, "family"));
      // "custom" (demande de Martin, 2026-10-06 : "de manière générale, la
      // possibilité de créer de nouveaux liens, avec la légende, la
      // couleur souhaitée, propre à chaque arbre") — second écran pour
      // choisir/créer l'entrée de légende avant de créer le lien.
      addChoice(memberName(aId) + " et " + memberName(bId) + " — lien personnalisé…", async () => {
        const legendId = await openCustomLinkLegendModal();
        if (legendId === undefined) return; // annulé
        await createRelation(aId, bId, "custom", legendId);
      });
      $("gen-relation-modal-cancel").onclick = cleanup;
      modal.classList.add("open");
    });
  }

  // Choix de la couleur/légende pour un lien "Personnalisé" — retourne
  // l'id de l'entrée de légende choisie (ou null = aucune couleur
  // particulière), ou undefined si l'utilisateur annule. Si l'arbre n'a
  // encore aucune entrée de légende, propose directement d'en créer une
  // (via openLegendManager) plutôt que de bloquer sur une liste vide.
  function openCustomLinkLegendModal(): Promise<string | null | undefined> {
    return new Promise((resolve) => {
      const modal = $("gen-custom-link-modal");
      const select = $("gen-custom-link-legend") as HTMLSelectElement;
      const hint = $("gen-custom-link-hint");
      renderLegendOptionsInto(select, null, "Aucune couleur particulière", "link");
      hint.textContent = legendItems.some((it) => it.kind === "link")
        ? ""
        : "Aucune couleur \"Lien\" enregistrée pour cet arbre encore — vous pouvez valider sans couleur, ou en créer une via le bouton 🎨 Légende (choisir \"Lien\").";
      function cleanup() {
        modal.classList.remove("open");
      }
      $("gen-custom-link-confirm").onclick = () => {
        cleanup();
        resolve(select.value || null);
      };
      $("gen-custom-link-cancel").onclick = () => {
        cleanup();
        resolve(undefined);
      };
      modal.classList.add("open");
    });
  }

  // Demande de Martin, 2026-10-06 : "quand on crée un lien entre une
  // personne qui est dans son arbre d'origine (personne A) [...] à une
  // personne d'un autre arbre (personne B), je dois avoir un message pour
  // savoir si je veux faire apparaître la personne A dans l'arbre de la
  // personne B [...] actuellement, ça va automatiquement faire apparaître
  // [A] dans l'arbre [de B]. Cela ne doit plus être automatique" — exemple
  // donné : lier Emma de Bavière (membre d'un unique arbre, "Test") à
  // Ermengarde (étrangère dans "Test", locale aux Carolingiens) ne doit
  // plus faire automatiquement réapparaître Emma dans l'arbre Carolingiens
  // au prochain chargement. Ne concerne QUE le cas où exactement un des
  // deux membres est local à CET arbre et l'autre étranger (déjà visible
  // ici via son propre arbre d'origine) : les deux autres cas (tous deux
  // locaux, ou tous deux étrangers) ne posent pas cette question et créent
  // le lien normalement, comme avant.
  async function resolveHideMemberId(aId: string, bId: string): Promise<string | null> {
    const aLocal = members.some((m) => m.id === aId);
    const bLocal = members.some((m) => m.id === bId);
    if (aLocal === bLocal) return null;
    const localId = aLocal ? aId : bId;
    const foreignId = aLocal ? bId : aId;
    const foreignMember = foreignMembers.get(foreignId);
    if (!foreignMember) return null;
    const show = await customConfirm(
      "Faire apparaître " +
        memberName(localId) +
        " dans l'arbre de " +
        memberName(foreignId) +
        " (" +
        foreignOwnerLabel(foreignMember) +
        ") ?\n\nOK : " +
        memberName(localId) +
        " apparaîtra aussi là-bas.\nAnnuler : le lien restera visible uniquement ici, " +
        memberName(localId) +
        " n'apparaîtra jamais dans cet autre arbre via ce lien."
    );
    return show ? null : localId;
  }
  async function createRelation(aId: string, bId: string, type: RelationType, legendId: string | null = null) {
    const session = deps.getSession();
    if (!session) {
      deps.openAuthPanel();
      return;
    }
    if (!isAdmin()) {
      deps.showBanner?.("Tu n'as pas les droits d'édition sur cet atlas.");
      return;
    }
    const hideMemberId = await resolveHideMemberId(aId, bId);
    const { data, error } = await supabase
      .from("genealogy_relations")
      .insert({ member_a_id: aId, member_b_id: bId, relation_type: type, created_by: session.user.id, legend_item_id: legendId, hide_member_id: hideMemberId })
      .select("id, member_a_id, member_b_id, relation_type, created_by, legend_item_id, hide_member_id")
      .single();
    if (error || !data) {
      deps.showBanner?.("Erreur lors de la création du lien.");
      return;
    }
    relations.push(data as RelationRow);
    // Demande de Martin, 2026-10-22 : relier un membre étranger à un AUTRE
    // membre étranger doit faire apparaître le nouveau dans cet arbre
    // (jusqu'ici il n'apparaissait que s'il était lié à un membre local).
    await pinForeignMembers([aId, bId]);
    // Point demandé par Martin, 2026-10-03 : "même si on peut déplacer,
    // [...] les enfants sont en dessous" — dès qu'un lien parent→enfant
    // est créé, on corrige la position de départ de l'enfant s'il se
    // trouve au-dessus (ou pas assez en dessous) de son parent. Le
    // glisser-déposer reste entièrement libre après coup : ceci ne
    // s'applique qu'une fois, à la création du lien.
    if (type === "parent") await enforceParentChildOrder(aId, bId);
    // Un membre étranger référencé par une nouvelle relation n'est pas
    // forcément déjà dans foreignMembers/displayPos — on recharge les
    // données pour rester cohérent plutôt que de dupliquer la logique de
    // positionnement calculé de loadData().
    if (currentOwner) await loadData(currentOwner);
    if (editingMemberId) renderRelationsList(editingMemberId);
  }

  // Ne déplace que des membres LOCAUX à cet arbre (un membre étranger lié
  // depuis un autre pays a sa position recalculée à la volée par
  // computeForeignPosition/loadData à partir de son propre pos_x/pos_y —
  // lui écrire une position ici serait incohérent avec son arbre d'origine).
  async function enforceParentChildOrder(parentId: string, childId: string) {
    const parentPos = displayPos.get(parentId);
    const childPos = displayPos.get(childId);
    const childMember = members.find((m) => m.id === childId);
    if (!parentPos || !childPos || !childMember) return;
    const minChildY = parentPos.y + GENERATION_GAP;
    if (childPos.y >= minChildY) return;
    const newPos = { x: childPos.x, y: minChildY };
    displayPos.set(childId, newPos);
    childMember.pos_y = newPos.y;
    try {
      await supabase.from("genealogy_members").update({ pos_y: newPos.y }).eq("id", childId);
    } catch {
      /* best-effort — loadData() rechargera de toute façon juste après */
    }
  }

  // Placement automatique d'un NOUVEAU membre selon son année de naissance,
  // par interpolation/extrapolation linéaire entre les membres existants de
  // cet arbre dont l'année de naissance est connue (point demandé par
  // Martin, 2026-10-03 : "ceux nés plus tôt sont plus haut, ceux plus tard
  // plus bas"). Retourne null si aucune donnée de comparaison n'est
  // disponible (premier membre de l'arbre, ou aucun autre membre n'a
  // d'année de naissance renseignée) — l'appelant garde alors le
  // positionnement par défaut (centre de la vue).
  function suggestYFromBirthYear(birth: number | null): number | null {
    if (birth == null) return null;
    const known = members.filter((m) => m.birth_year != null && displayPos.has(m.id));
    if (!known.length) return null;
    let before: MemberRow | null = null;
    let after: MemberRow | null = null;
    known.forEach((m) => {
      const by = m.birth_year as number;
      if (by <= birth && (!before || by > (before as MemberRow).birth_year!)) before = m;
      if (by >= birth && (!after || by < (after as MemberRow).birth_year!)) after = m;
    });
    if (before && after && (before as MemberRow).id !== (after as MemberRow).id) {
      const b1 = before as MemberRow;
      const b2 = after as MemberRow;
      const y1 = displayPos.get(b1.id)!.y;
      const y2 = displayPos.get(b2.id)!.y;
      if (b2.birth_year === b1.birth_year) return y1;
      const t = (birth - b1.birth_year!) / (b2.birth_year! - b1.birth_year!);
      return y1 + (y2 - y1) * t;
    }
    const anchor = (before || after) as MemberRow | null;
    if (!anchor) return null;
    const dy = (birth - anchor.birth_year!) * PX_PER_YEAR;
    return displayPos.get(anchor.id)!.y + dy;
  }

  async function deleteRelation(id: string) {
    if (!isAdmin()) return;
    if (!(await customConfirm("Supprimer ce lien ?"))) return;
    await supabase.from("genealogy_relations").delete().eq("id", id);
    relations = relations.filter((r) => r.id !== id);
    renderLinks();
    if (editingMemberId) renderRelationsList(editingMemberId);
  }

  // --- Panneau membre (création / édition) ------------------------------------
  // Quand on consulte un membre d'un autre arbre (foreignPanelMemberId non
  // nul), le panneau est en LECTURE SEULE : champs désactivés, pas de
  // bouton Supprimer/Recadrer/Changer la photo, pas de section Liens, et
  // un bandeau #gen-m-foreign-banner en tête permet de rejoindre son
  // arbre d'origine (voir openForeignMemberPanel ci-dessous).
  let foreignPanelMemberId: string | null = null;
  const GEN_M_FIELD_IDS = ["gen-m-name", "gen-m-birth", "gen-m-death", "gen-m-title", "gen-m-dynasty", "gen-m-bio"];
  function setMemberFieldsDisabled(disabled: boolean) {
    // gen-m-leader n'est PAS inclus ici : sur le panneau d'un membre
    // étranger, cette case reste modifiable (voir openForeignMemberPanel)
    // puisque "a dirigé le pays" est indépendant par arbre, demande de
    // Martin — les autres champs (nom/dates/titre/dynastie/bio) restent
    // en lecture seule, ils ne concernent que l'arbre d'origine.
    GEN_M_FIELD_IDS.forEach((id) => (($(id) as HTMLInputElement | HTMLTextAreaElement).disabled = disabled));
  }
  function refreshPhotoRecropVisibility() {
    const hasPhoto = !!$("gen-m-photo-preview").querySelector("img");
    ($("gen-m-photo-recrop-btn") as HTMLButtonElement).style.display = hasPhoto && !foreignPanelMemberId && isAdmin() ? "" : "none";
  }
  // Rattachement bidirectionnel membre ↔ fiche/sous-catégorie du même nom
  // (demande de Martin, 2026-10-03 : "je souhaite que une personne dans un
  // arbre soit rattachée automatiquement à une fiche de la même personne
  // [...] quelle que soit celui créé en premier"). Cherche une section ou
  // une entrée texte PORTANT CE NOM (voir src/linkIndex.ts) et affiche un
  // lien cliquable si trouvée — jamais d'affichage s'il n'y a rien.
  function renderFicheLinkBanner(name: string | null) {
    const btn = $("gen-m-fiche-link-banner") as HTMLButtonElement;
    const target = name ? findLinkTargetForName(name, ["section", "entry"]) : null;
    if (!target) {
      btn.style.display = "none";
      btn.onclick = null;
      return;
    }
    btn.style.display = "flex";
    btn.textContent = "📄 Voir la fiche « " + name + " » →";
    btn.onclick = () => void deps.openLinkedFiche(target);
  }
  function openMemberPanel(id: string | null) {
    foreignPanelMemberId = null;
    editingMemberId = id;
    photoPendingFile = null;
    $("gen-m-photo-status").textContent = "";
    $("gen-m-foreign-banner").style.display = "none";
    setMemberFieldsDisabled(false);
    ($("gen-m-leader") as HTMLInputElement).disabled = false;
    ($("gen-m-photo-btn") as HTMLButtonElement).style.display = "";
    const m = id ? members.find((x) => x.id === id) || null : null;
    renderFicheLinkBanner(m?.name || null);
    $("gen-member-heading").textContent = m ? "Modifier le membre" : "Nouveau membre";
    ($("gen-m-name") as HTMLInputElement).value = m?.name || "";
    ($("gen-m-birth") as HTMLInputElement).value = m?.birth_year != null ? String(m.birth_year) : "";
    ($("gen-m-death") as HTMLInputElement).value = m?.death_year != null ? String(m.death_year) : "";
    ($("gen-m-title") as HTMLInputElement).value = m?.title || "";
    ($("gen-m-dynasty") as HTMLInputElement).value = m?.dynasty || "";
    ($("gen-m-leader") as HTMLInputElement).checked = m?.is_leader || false;
    ($("gen-m-bio") as HTMLTextAreaElement).value = m?.bio || "";
    $("gen-m-photo-preview").innerHTML = m?.photo_url ? '<img src="' + escapeHtml(m.photo_url) + '" alt="">' : "";
    refreshPhotoRecropVisibility();
    renderMemberStatusChips();
    $("gen-m-save-status").textContent = "";
    ($("gen-m-delete") as HTMLButtonElement).style.display = m && isAdmin() ? "" : "none";
    ($("gen-m-remove-from-tree") as HTMLButtonElement).style.display = "none";
    $("gen-m-relations").style.display = m ? "" : "none";
    $("gen-m-link-foreign").style.display = "";
    $("gen-m-show-relatives-row").style.display = "none";
    if (m) renderRelationsList(m.id);
    $("gen-member-panel").classList.add("open");
  }
  // Demande de Martin, 2026-10-03 : voir le commentaire sur card.addEventListener("click", ...)
  // plus haut — on affiche le membre étranger en lecture seule plutôt que
  // de naviguer directement vers son arbre d'origine.
  function openForeignMemberPanel(m: MemberRow) {
    foreignPanelMemberId = m.id;
    editingMemberId = null;
    photoPendingFile = null;
    $("gen-m-photo-status").textContent = "";
    setMemberFieldsDisabled(true);
    renderFicheLinkBanner(m.name || null);
    $("gen-member-heading").textContent = m.name;
    ($("gen-m-name") as HTMLInputElement).value = m.name || "";
    ($("gen-m-birth") as HTMLInputElement).value = m.birth_year != null ? String(m.birth_year) : "";
    ($("gen-m-death") as HTMLInputElement).value = m.death_year != null ? String(m.death_year) : "";
    ($("gen-m-title") as HTMLInputElement).value = m.title || "";
    ($("gen-m-dynasty") as HTMLInputElement).value = m.dynasty || "";
    // "A dirigé le pays" reste modifiable même en lecture seule (demande
    // de Martin : indépendant par arbre) — valeur lue depuis
    // foreignStates (cet arbre), pas m.is_leader (l'arbre d'origine).
    ($("gen-m-leader") as HTMLInputElement).checked = foreignStates.get(m.id)?.is_leader || false;
    ($("gen-m-leader") as HTMLInputElement).disabled = !isAdmin();
    ($("gen-m-bio") as HTMLTextAreaElement).value = m.bio || "";
    $("gen-m-photo-preview").innerHTML = m.photo_url ? '<img src="' + escapeHtml(m.photo_url) + '" alt="">' : "";
    ($("gen-m-photo-btn") as HTMLButtonElement).style.display = "none";
    ($("gen-m-photo-recrop-btn") as HTMLButtonElement).style.display = "none";
    // Statuts (anneaux cumulés) d'un membre étranger (demande de Martin) :
    // modifiables même en lecture seule, comme "A dirigé le pays" —
    // toujours propres à CET arbre visiteur (memberStatuses est déjà
    // scopé à currentOwner, voir loadMemberStatuses), pas à son arbre
    // d'origine. foreignPanelMemberId est déjà posé plus haut, donc
    // currentStatusMemberId() (utilisé par renderMemberStatusChips)
    // retombe bien sur m.id ici.
    renderMemberStatusChips();
    const banner = $("gen-m-foreign-banner") as HTMLButtonElement;
    banner.style.display = "flex";
    banner.textContent = foreignOwnerLabel(m);
    banner.onclick = () => void deps.openOwnerTree(m.owner_type, m.owner_id, m.id);
    $("gen-m-save-status").textContent = "";
    ($("gen-m-delete") as HTMLButtonElement).style.display = "none";
    // Retrait "local" (demande de Martin, 2026-10-06) — voir
    // removeForeignMemberFromThisTree : ne touche jamais au membre ni à
    // ses liens dans SON arbre d'origine, seulement à cet arbre-ci.
    ($("gen-m-remove-from-tree") as HTMLButtonElement).style.display = isAdmin() ? "" : "none";
    $("gen-m-relations").style.display = "none";
    // Demande de Martin, 2026-10-06 : "la possibilité de lier 2 membres
    // tous deux issus d'un autre arbre / de faire librement des liens à
    // partir de membres d'un autre arbre" — jusqu'ici ce bouton n'existait
    // que sur le panneau d'un membre LOCAL (ce qui empêchait de créer un
    // lien dont les DEUX extrémités sont étrangères à cet arbre) ; visible
    // aussi en lecture seule ici, comme "A dirigé le pays"/l'anneau de
    // couleur ci-dessus, le lien lui-même n'étant pas propre à un arbre en
    // particulier (voir gen-m-link-foreign ci-dessous, qui lit maintenant
    // editingMemberId OU foreignPanelMemberId) — visibilité non filtrée par
    // isAdmin() ici non plus (même convention que openMemberPanel
    // ci-dessus : le droit est vérifié au clic, via requireAuthOr).
    $("gen-m-link-foreign").style.display = "";
    $("gen-m-show-relatives-row").style.display = isAdmin() ? "flex" : "none";
    $("gen-member-panel").classList.add("open");
  }
  function closeMemberPanel() {
    $("gen-member-panel").classList.remove("open");
    editingMemberId = null;
    foreignPanelMemberId = null;
  }
  $("gen-member-close").addEventListener("click", closeMemberPanel);
  $("genealogy-add-member").addEventListener("click", () => requireAuthOr(() => openMemberPanel(null)));
  ($("gen-m-photo-recrop-btn") as HTMLButtonElement).addEventListener("click", () => {
    if (!editingMemberId || foreignPanelMemberId) return;
    const m = members.find((x) => x.id === editingMemberId);
    if (!m?.photo_url) return;
    requireAuthOr(() => openCropModal(m.photo_url as string));
  });

  function renderRelationsList(memberId: string) {
    const list = $("gen-m-relations-list");
    list.innerHTML = "";
    const mine = relations.filter((r) => r.member_a_id === memberId || r.member_b_id === memberId);
    if (!mine.length) {
      list.innerHTML = '<p class="muted" style="margin:4px 0;">Aucun lien pour le moment.</p>';
      return;
    }
    mine.forEach((r) => {
      const otherId = r.member_a_id === memberId ? r.member_b_id : r.member_a_id;
      const row = document.createElement("div");
      row.className = "gen-relation-row";
      let label: string;
      if (r.relation_type === "spouse") {
        label = "Marié(e) à " + memberName(otherId);
      } else if (r.relation_type === "family") {
        label = "Collatéraux avec " + memberName(otherId);
      } else if (r.relation_type === "custom") {
        const legend = legendItemById(r.legend_item_id);
        label = (legend ? legend.label : "Lien personnalisé") + " avec " + memberName(otherId);
      } else if (r.member_a_id === memberId) {
        label = "Ascendant de " + memberName(otherId);
      } else {
        label = "Descendant de " + memberName(otherId);
      }
      const legendForRow = r.relation_type === "custom" ? legendItemById(r.legend_item_id) : null;
      const swatch = legendForRow ? '<span class="gen-legend-dot" style="background:' + escapeHtml(legendForRow.color) + ';margin-right:5px;"></span>' : "";
      row.innerHTML = '<span>' + swatch + escapeHtml(label) + "</span>";
      if (isAdmin()) {
        const del = document.createElement("button");
        del.type = "button";
        del.className = "entry-del edit-control";
        del.style.cssText = "position:static;opacity:1;";
        del.innerHTML = TRASH_ICON_SVG;
        del.title = "Supprimer ce lien";
        del.addEventListener("click", () => deleteRelation(r.id));
        row.appendChild(del);
      }
      list.appendChild(row);
    });
  }

  $("gen-m-photo-btn").addEventListener("click", () => {
    if (!deps.getSession()) {
      deps.openAuthPanel();
      return;
    }
    if (!isAdmin()) {
      deps.showBanner?.("Tu n'as pas les droits d'édition sur cet atlas.");
      return;
    }
    ($("gen-m-photo-input") as HTMLInputElement).click();
  });
  // Point demandé par Martin, 2026-10-03 : "faut ajouter la possibilité
  // de recadrer la photo" — on ne prend plus le fichier tel quel, on
  // ouvre d'abord l'outil de cadrage (openCropModal ci-dessous), qui
  // produit lui-même le photoPendingFile final (un Blob recadré, pas le
  // fichier original) une fois "Valider le cadrage" cliqué. Factorisé en
  // fonction à part pour être appelable aussi bien depuis le <input
  // type=file> que depuis un glisser-déposer (voir plus bas, point
  // demandé par Martin : "possibilité... de la glisser sur l'emplacement,
  // sans nécessairement ouvrir le dossier des téléchargements").
  function loadFileIntoCrop(file: File | null) {
    if (!file || !file.type.startsWith("image/")) return;
    const reader = new FileReader();
    reader.onload = () => openCropModal(String(reader.result));
    reader.readAsDataURL(file);
  }
  ($("gen-m-photo-input") as HTMLInputElement).addEventListener("change", (e) => {
    const file = (e.target as HTMLInputElement).files?.[0] || null;
    (e.target as HTMLInputElement).value = "";
    loadFileIntoCrop(file);
  });
  // Glisser-déposer direct d'une image sur l'emplacement photo — plus
  // besoin de passer par "Changer la photo" puis le sélecteur de fichiers
  // natif du système. Gating identique aux autres actions d'édition
  // (session + isAdmin) via requireAuthOr.
  const photoDropZone = $("gen-m-photo-preview");
  photoDropZone.addEventListener("dragover", (e) => {
    e.preventDefault();
    if (deps.getSession() && isAdmin()) photoDropZone.classList.add("gen-photo-drop-active");
  });
  photoDropZone.addEventListener("dragleave", () => {
    photoDropZone.classList.remove("gen-photo-drop-active");
  });
  photoDropZone.addEventListener("drop", (e) => {
    e.preventDefault();
    photoDropZone.classList.remove("gen-photo-drop-active");
    const file = e.dataTransfer?.files?.[0] || null;
    if (!file) return;
    requireAuthOr(() => loadFileIntoCrop(file));
  });

  // --- Recadrage de la photo (point demandé par Martin, 2026-10-03) ----------
  // Petit outil de cadrage maison : rectangle à l'aspect ratio fixe
  // (CARD_PHOTO_RATIO), déplaçable en glissant le cadre, redimensionnable en
  // glissant la poignée du coin (#gen-crop-handle), toujours à cet aspect
  // ratio. Les coordonnées de travail (cropRect, cropDisplayW/H) sont en
  // pixels D'AFFICHAGE (taille CSS de l'image dans #gen-crop-stage) ; la
  // conversion vers les pixels réels de l'image (naturalWidth/Height) ne se
  // fait qu'au moment de dessiner sur le canvas final, dans
  // gen-crop-confirm.
  let cropNaturalW = 0;
  let cropDisplayW = 0;
  let cropDisplayH = 0;
  let cropRect = { x: 0, y: 0, w: 0, h: 0 };
  let cropDragMode: "move" | "resize" | null = null;
  let cropDragStartX = 0;
  let cropDragStartY = 0;
  let cropStartRect = { x: 0, y: 0, w: 0, h: 0 };

  function paintCropRect() {
    const rectEl = $("gen-crop-rect");
    rectEl.style.left = cropRect.x + "px";
    rectEl.style.top = cropRect.y + "px";
    rectEl.style.width = cropRect.w + "px";
    rectEl.style.height = cropRect.h + "px";
  }
  function openCropModal(dataUrl: string) {
    const img = $("gen-crop-img") as HTMLImageElement;
    // "Recadrer" (bouton #gen-m-photo-recrop-btn) rouvre ce modal avec la
    // photo_url DÉJÀ en ligne (pas une data: URL locale) — crossOrigin
    // est nécessaire pour que drawImage()/toBlob() plus bas ne "tainte"
    // pas le canvas (sans effet sur les data: URL du flux normal).
    img.crossOrigin = "anonymous";
    img.src = dataUrl;
    img.onload = () => {
      cropNaturalW = img.naturalWidth;
      // La largeur/hauteur AFFICHÉE découle du CSS (width:100%, max-width
      // 420px sur #gen-crop-stage) — on ne peut la mesurer qu'après layout,
      // d'où le requestAnimationFrame.
      requestAnimationFrame(() => {
        const rect = img.getBoundingClientRect();
        cropDisplayW = rect.width;
        cropDisplayH = rect.height;
        // Rectangle initial : le plus grand possible à CARD_PHOTO_RATIO,
        // centré dans l'image affichée.
        let w = cropDisplayW;
        let h = w / CARD_PHOTO_RATIO;
        if (h > cropDisplayH) {
          h = cropDisplayH;
          w = h * CARD_PHOTO_RATIO;
        }
        cropRect = { x: (cropDisplayW - w) / 2, y: (cropDisplayH - h) / 2, w, h };
        paintCropRect();
      });
    };
    $("gen-photo-crop-modal").classList.add("open");
  }
  function closeCropModal() {
    $("gen-photo-crop-modal").classList.remove("open");
  }
  $("gen-crop-rect").addEventListener("mousedown", (e) => {
    if ((e.target as HTMLElement).id === "gen-crop-handle") return;
    cropDragMode = "move";
    cropDragStartX = e.clientX;
    cropDragStartY = e.clientY;
    cropStartRect = { ...cropRect };
    e.preventDefault();
  });
  $("gen-crop-handle").addEventListener("mousedown", (e) => {
    cropDragMode = "resize";
    cropDragStartX = e.clientX;
    cropDragStartY = e.clientY;
    cropStartRect = { ...cropRect };
    e.stopPropagation();
    e.preventDefault();
  });
  document.addEventListener("mousemove", (e) => {
    if (!cropDragMode) return;
    const dx = e.clientX - cropDragStartX;
    const dy = e.clientY - cropDragStartY;
    if (cropDragMode === "move") {
      const x = Math.max(0, Math.min(cropStartRect.x + dx, cropDisplayW - cropStartRect.w));
      const y = Math.max(0, Math.min(cropStartRect.y + dy, cropDisplayH - cropStartRect.h));
      cropRect = { ...cropStartRect, x, y };
    } else {
      // Redimensionne depuis le coin bas-droit, aspect ratio verrouillé —
      // borné pour ne jamais sortir de l'image ni passer sous une taille
      // minimale utilisable.
      let w = Math.max(40, cropStartRect.w + dx);
      w = Math.min(w, cropDisplayW - cropStartRect.x, (cropDisplayH - cropStartRect.y) * CARD_PHOTO_RATIO);
      const h = w / CARD_PHOTO_RATIO;
      cropRect = { x: cropStartRect.x, y: cropStartRect.y, w, h };
    }
    paintCropRect();
  });
  document.addEventListener("mouseup", () => {
    cropDragMode = null;
  });
  $("gen-crop-cancel").addEventListener("click", closeCropModal);
  $("gen-crop-confirm").addEventListener("click", () => {
    const img = $("gen-crop-img") as HTMLImageElement;
    if (!cropDisplayW || !cropNaturalW) {
      closeCropModal();
      return;
    }
    const scale = cropNaturalW / cropDisplayW;
    const sx = cropRect.x * scale;
    const sy = cropRect.y * scale;
    const sw = cropRect.w * scale;
    const sh = cropRect.h * scale;
    const outW = 480;
    const outH = Math.round(outW / CARD_PHOTO_RATIO);
    const canvas = document.createElement("canvas");
    canvas.width = outW;
    canvas.height = outH;
    const ctx = canvas.getContext("2d");
    if (!ctx) {
      closeCropModal();
      return;
    }
    ctx.drawImage(img, sx, sy, sw, sh, 0, 0, outW, outH);
    canvas.toBlob(
      (blob) => {
        if (blob) {
          photoPendingFile = new File([blob], "photo.jpg", { type: "image/jpeg" });
          $("gen-m-photo-preview").innerHTML = '<img src="' + canvas.toDataURL("image/jpeg", 0.9) + '" alt="">';
          refreshPhotoRecropVisibility();
          // Temps réel (demande de Martin, 2026-10-03 : "retire le bouton
          // enregistrer, tout doit se faire en temps réel") : si on
          // modifie/recadre la photo d'un membre déjà créé, on l'envoie et
          // on l'enregistre tout de suite, sans attendre un clic ailleurs.
          // Pour un membre pas encore créé (editingMemberId nul), le
          // fichier reste en attente dans photoPendingFile — il sera
          // envoyé à la toute première sauvegarde (voir createMemberNow).
          if (editingMemberId) void autosavePhotoNow(photoPendingFile);
        }
        closeCropModal();
      },
      "image/jpeg",
      0.9,
    );
  });

  async function uploadMemberPhoto(file: File, memberId: string): Promise<string | null> {
    if (!currentOwner) return null;
    const path =
      "genealogy/" + currentOwner.type + "-" + currentOwner.id + "/" + memberId + "-" + Date.now() + "-" + file.name.replace(/[^a-zA-Z0-9._-]/g, "_");
    const { error } = await supabase.storage.from("dossier-photos").upload(path, file, { upsert: false });
    if (error) return null;
    const { data } = supabase.storage.from("dossier-photos").getPublicUrl(path);
    return data.publicUrl;
  }

  // Envoi + enregistrement immédiat d'une nouvelle photo (recadrée) pour un
  // membre déjà créé — remplace l'ancien flux qui attendait un clic sur
  // "Enregistrer".
  async function autosavePhotoNow(file: File) {
    if (!editingMemberId || !isAdmin()) return;
    const id = editingMemberId;
    $("gen-m-photo-status").textContent = "Envoi de la photo…";
    const url = await uploadMemberPhoto(file, id);
    if (!url) {
      $("gen-m-photo-status").textContent = "Échec de l'envoi de la photo.";
      return;
    }
    await supabase.from("genealogy_members").update({ photo_url: url }).eq("id", id);
    const m = members.find((x) => x.id === id);
    if (m) m.photo_url = url;
    photoPendingFile = null;
    $("gen-m-photo-status").textContent = "";
    renderAll();
  }

  // --- Sauvegarde en temps réel (plus de bouton "Enregistrer", demande de
  // Martin, 2026-10-03 : "retire le bouton enregistrer, tout doit se
  // faire en temps réel à chaque modification, sans avoir besoin de
  // cliquer sur le bouton") -------------------------------------------------
  // Première sauvegarde d'un membre tout juste ouvert via "+ Membre" :
  // insère la ligne dès que le nom (seul champ obligatoire) est renseigné,
  // avec les valeurs actuelles de TOUS les champs du panneau — reprend
  // exactement la logique de positionnement/upload-photo qui vivait avant
  // dans le handler de clic sur "Enregistrer".
  async function createMemberNow(): Promise<MemberRow | null> {
    const session = deps.getSession();
    if (!session || !currentOwner) {
      deps.openAuthPanel();
      return null;
    }
    if (!isAdmin()) {
      deps.showBanner?.("Tu n'as pas les droits d'édition sur cet atlas.");
      return null;
    }
    const name = ($("gen-m-name") as HTMLInputElement).value.trim();
    if (!name) return null;
    const birthStr = ($("gen-m-birth") as HTMLInputElement).value.trim();
    const deathStr = ($("gen-m-death") as HTMLInputElement).value.trim();
    const birth = birthStr ? parseInt(birthStr, 10) : null;
    const death = deathStr ? parseInt(deathStr, 10) : null;
    const title = ($("gen-m-title") as HTMLInputElement).value.trim() || null;
    const dynasty = ($("gen-m-dynasty") as HTMLInputElement).value.trim() || null;
    const isLeader = ($("gen-m-leader") as HTMLInputElement).checked;
    const bio = ($("gen-m-bio") as HTMLTextAreaElement).value.trim() || null;
    $("gen-m-save-status").textContent = "Enregistrement…";
    const center = canvasWrap
      ? { x: (canvasWrap.clientWidth / 2 - zoomTransform.x) / zoomTransform.k, y: (canvasWrap.clientHeight / 2 - zoomTransform.y) / zoomTransform.k }
      : { x: 0, y: 0 };
    const suggestedY = suggestYFromBirthYear(Number.isFinite(birth) ? birth : null);
    const pos = {
      x: center.x + Math.random() * 60 - 30,
      y: suggestedY != null ? suggestedY : center.y + Math.random() * 60 - 30,
    };
    try {
      const { data, error } = await supabase
        .from("genealogy_members")
        .insert({
          owner_type: currentOwner.type,
          owner_id: currentOwner.id,
          name,
          birth_year: Number.isFinite(birth) ? birth : null,
          death_year: Number.isFinite(death) ? death : null,
          title,
          dynasty,
          is_leader: isLeader,
          bio,
          pos_x: pos.x,
          pos_y: pos.y,
          created_by: session.user.id,
        })
        .select(
          "id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader, legend_item_id"
        )
        .single();
      if (error || !data) {
        $("gen-m-save-status").textContent = "Erreur d'enregistrement.";
        return null;
      }
      const row = data as MemberRow;
      if (photoPendingFile) {
        $("gen-m-photo-status").textContent = "Envoi de la photo…";
        const url = await uploadMemberPhoto(photoPendingFile, row.id);
        if (url) {
          await supabase.from("genealogy_members").update({ photo_url: url }).eq("id", row.id);
          row.photo_url = url;
        }
        photoPendingFile = null;
        $("gen-m-photo-status").textContent = "";
      }
      members.push(row);
      displayPos.set(row.id, { x: row.pos_x, y: row.pos_y });
      editingMemberId = row.id;
      $("gen-member-heading").textContent = "Modifier le membre";
      ($("gen-m-delete") as HTMLButtonElement).style.display = isAdmin() ? "" : "none";
      $("gen-m-relations").style.display = "";
      renderRelationsList(row.id);
      // Les statuts (anneaux cumulés) dépendent d'un memberId réel — le
      // panneau était ouvert sans id tant que ce membre n'existait pas
      // encore (voir currentStatusMemberId), donc le select "+ Ajouter un
      // statut…" était désactivé jusqu'ici : on le réactive maintenant
      // que editingMemberId est posé.
      renderMemberStatusChips();
      refreshPhotoRecropVisibility();
      $("gen-m-save-status").textContent = "Enregistré ✓";
      $("genealogy-empty-hint").style.display = "none";
      renderAll();
      // Le panneau a été ouvert avant que le nom n'existe (renderFicheLinkBanner
      // appelé avec name=null dans openMemberPanel) — maintenant que le membre
      // est créé avec son nom, on peut (re)vérifier le rattachement vers une
      // fiche/sous-catégorie du même nom (demande de Martin, 2026-10-03).
      renderFicheLinkBanner(row.name || null);
      return row;
    } catch {
      $("gen-m-save-status").textContent = "Erreur d'enregistrement.";
      return null;
    }
  }
  // Sauvegarde d'un champ modifié sur un membre déjà créé — ré-envoie
  // l'ensemble des champs du panneau (plus simple et sûr qu'un diff
  // champ-par-champ, le coût est négligeable pour un usage personnel).
  async function handleFieldAutosave() {
    if (foreignPanelMemberId) return; // panneau en lecture seule
    if (!editingMemberId) {
      await createMemberNow();
      return;
    }
    if (!isAdmin()) return;
    const birthStr = ($("gen-m-birth") as HTMLInputElement).value.trim();
    const deathStr = ($("gen-m-death") as HTMLInputElement).value.trim();
    const birth = birthStr ? parseInt(birthStr, 10) : null;
    const death = deathStr ? parseInt(deathStr, 10) : null;
    const patch: Record<string, unknown> = {
      name: ($("gen-m-name") as HTMLInputElement).value.trim(),
      birth_year: Number.isFinite(birth) ? birth : null,
      death_year: Number.isFinite(death) ? death : null,
      title: ($("gen-m-title") as HTMLInputElement).value.trim() || null,
      dynasty: ($("gen-m-dynasty") as HTMLInputElement).value.trim() || null,
      is_leader: ($("gen-m-leader") as HTMLInputElement).checked,
      bio: ($("gen-m-bio") as HTMLTextAreaElement).value.trim() || null,
    };
    $("gen-m-save-status").textContent = "Enregistrement…";
    try {
      await supabase.from("genealogy_members").update(patch).eq("id", editingMemberId);
      const m = members.find((x) => x.id === editingMemberId);
      if (m) Object.assign(m, patch);
      $("gen-m-save-status").textContent = "Enregistré ✓";
      renderAll();
      // Idem : si le nom a été modifié pour correspondre (ou plus
      // correspondre) à une fiche/sous-catégorie, la bannière doit suivre.
      renderFicheLinkBanner((patch.name as string) || null);
    } catch {
      $("gen-m-save-status").textContent = "Erreur d'enregistrement.";
    }
  }
  GEN_M_FIELD_IDS.forEach((id) => {
    $(id).addEventListener("blur", () => void handleFieldAutosave());
  });
  // "A dirigé le pays" sur le panneau d'un membre ÉTRANGER (demande de
  // Martin : indépendant par arbre) — on n'enregistre PAS via le même
  // chemin que les membres locaux (handleFieldAutosave, qui écrirait sur
  // genealogy_members, la ligne de l'arbre d'ORIGINE), mais via
  // genealogy_foreign_states, propre à l'arbre actuellement ouvert.
  async function saveForeignLeaderFlag(memberId: string, checked: boolean) {
    if (!currentOwner || !isAdmin()) return;
    const st = foreignStates.get(memberId) || { member_id: memberId, pos_x: null, pos_y: null, is_leader: false, legend_item_id: null };
    st.is_leader = checked;
    foreignStates.set(memberId, st);
    await supabase.from("genealogy_foreign_states").upsert(
      {
        member_id: memberId,
        owner_type: currentOwner.type,
        owner_id: currentOwner.id,
        pos_x: st.pos_x,
        pos_y: st.pos_y,
        is_leader: checked,
        legend_item_id: st.legend_item_id,
      },
      { onConflict: "member_id,owner_type,owner_id" }
    );
    renderAll();
  }
  $("gen-m-leader").addEventListener("change", () => {
    if (foreignPanelMemberId) {
      void saveForeignLeaderFlag(foreignPanelMemberId, ($("gen-m-leader") as HTMLInputElement).checked);
      return;
    }
    void handleFieldAutosave();
  });
  // Anneau de couleur UNIQUE (ancien <select> gen-m-legend) — remplacé
  // par les statuts cumulés (schema_v24.sql, demande de Martin,
  // 2026-10-12) : voir renderMemberStatusChips/addMemberStatus/
  // removeMemberStatus, qui écrivent directement dans
  // genealogy_member_statuses (toujours scopé à currentOwner, qu'il
  // s'agisse d'un membre local ou étranger — plus de distinction
  // local/étranger nécessaire à l'écriture, contrairement à "A dirigé le
  // pays" ci-dessus qui reste sur son propre mécanisme).
  // Retrait "local" d'un membre d'un autre arbre (demande de Martin,
  // 2026-10-06 : "Pouvoir supprimer une personne d'un autre arbre dans le
  // nouveau sans le supprimer dans l'autre [...] il faut pouvoir
  // modifier, exploiter un membre d'un autre arbre facilement") — masque
  // seulement le membre dans CET arbre. Plus AUCUN lien n'est supprimé
  // (correctif 2026-10-22).
  async function removeForeignMemberFromThisTree(memberId: string) {
    if (!currentOwner || !isAdmin()) return;
    if (!(await customConfirm("Retirer ce membre de cet arbre ? Il restera inchangé dans son arbre d'origine."))) return;
    // BUG signalé par Martin, 2026-10-06 : "si je supprime un membre d'un
    // arbre, dans un arbre qui n'est pas le sien, il ne doit y avoir aucun
    // impact sur les liens de son arbre d'origine". Avant ce correctif, on
    // supprimait TOUTES les relations touchant ce membre présentes dans
    // `relations` — qui, depuis le correctif du 2026-10-06 sur les liens
    // entre deux membres étrangers (voir loadData), peut aussi contenir
    // une relation entre CE membre et un AUTRE membre étranger (ex. son
    // conjoint, tous deux d'un pays tiers) : cette relation-là n'a rien à
    // voir avec CET arbre-ci, elle existe (et doit continuer d'exister)
    // dans leur arbre d'origine commun. On ne retire donc que les
    // relations qui touchent un membre LOCAL à cet arbre — celles qui ont
    // effectivement "attiré" ce membre étranger ici — jamais une relation
    // entre deux membres tous deux étrangers à cet arbre.
    // Nouveau comportement (2026-10-22) : AUCUN lien n'est supprimé. Les liens
    // réels (ex. Sophie de Brandebourg → Christian II) appartiennent à
    // l'arbre d'origine ; ici on se contente de masquer le membre (colonne
    // hidden de genealogy_foreign_states, schema_v37.sql).
    const st = foreignStates.get(memberId);
    const { error } = await supabase.from("genealogy_foreign_states").upsert(
      {
        member_id: memberId,
        owner_type: currentOwner.type,
        owner_id: currentOwner.id,
        pos_x: st?.pos_x ?? null,
        pos_y: st?.pos_y ?? null,
        is_leader: st?.is_leader ?? false,
        pinned: false,
        hidden: true,
      },
      { onConflict: "member_id,owner_type,owner_id" }
    );
    if (error) {
      console.error("Masquage impossible (schema_v37.sql exécutée ?) :", error);
      deps.showBanner?.("Impossible de retirer ce membre : exécute d'abord schema_v37.sql dans Supabase.");
      return;
    }
    relations = relations.filter((r) => r.member_a_id !== memberId && r.member_b_id !== memberId);
    foreignMembers.delete(memberId);
    foreignStates.delete(memberId);
    displayPos.delete(memberId);
    closeMemberPanel();
    renderAll();
  }
  $("gen-m-remove-from-tree").addEventListener("click", () => {
    if (!foreignPanelMemberId) return;
    void removeForeignMemberFromThisTree(foreignPanelMemberId);
  });

  // Affiche dans CET arbre les proches (déjà liés dans leur arbre d'origine)
  // d'un membre étranger : parents + conjoint(s), ou enfants — sans créer
  // aucun lien (demande de Martin, 2026-10-22).
  async function showRelativesHere(memberId: string, kind: "parents" | "children") {
    if (!currentOwner || !isAdmin()) return;
    const localIds = new Set(members.map((m) => m.id));
    const { data, error } = await supabase
      .from("genealogy_relations")
      .select("id, member_a_id, member_b_id, relation_type, hide_member_id")
      .or("member_a_id.eq." + memberId + ",member_b_id.eq." + memberId);
    if (error) {
      deps.showBanner?.("Erreur lors de la lecture des liens.");
      return;
    }
    const ids: string[] = [];
    ((data as RelationRow[] | null) || []).forEach((r) => {
      if (r.hide_member_id && !localIds.has(r.hide_member_id)) return;
      const other = r.member_a_id === memberId ? r.member_b_id : r.member_a_id;
      if (kind === "parents") {
        if (r.relation_type === "spouse" || (r.relation_type === "parent" && r.member_b_id === memberId)) ids.push(other);
      } else if (r.relation_type === "parent" && r.member_a_id === memberId) ids.push(other);
    });
    const fresh = ids.filter((id) => !localIds.has(id) && !foreignMembers.has(id));
    if (!ids.length) {
      deps.showBanner?.(kind === "parents" ? "Aucun parent ni conjoint enregistré pour ce membre." : "Aucun enfant enregistré pour ce membre.");
      return;
    }
    if (!fresh.length) {
      deps.showBanner?.("Ces proches sont déjà affichés dans cet arbre.");
      return;
    }
    if (await pinForeignMembers(fresh)) await loadData(currentOwner);
  }
  $("gen-m-show-parents").addEventListener("click", () => {
    if (foreignPanelMemberId) void showRelativesHere(foreignPanelMemberId, "parents");
  });
  $("gen-m-show-children").addEventListener("click", () => {
    if (foreignPanelMemberId) void showRelativesHere(foreignPanelMemberId, "children");
  });

  $("gen-m-delete").addEventListener("click", async () => {
    if (!editingMemberId || !isAdmin()) return;
    if (!(await customConfirm("Supprimer ce membre et tous ses liens ?"))) return;
    const id = editingMemberId;
    await supabase.from("genealogy_relations").delete().or("member_a_id.eq." + id + ",member_b_id.eq." + id);
    await supabase.from("genealogy_members").delete().eq("id", id);
    members = members.filter((m) => m.id !== id);
    relations = relations.filter((r) => r.member_a_id !== id && r.member_b_id !== id);
    displayPos.delete(id);
    closeMemberPanel();
    renderAll();
    if (!members.length) $("genealogy-empty-hint").style.display = "";
  });

  // --- Lien vers un membre d'un autre pays (recherche globale) ----------------
  // Source du lien : le membre local en cours d'édition (editingMemberId),
  // OU, depuis le panneau en lecture seule d'un membre étranger déjà
  // affiché dans cet arbre (foreignPanelMemberId) — demande de Martin,
  // 2026-10-06 : permet de créer un lien dont les DEUX extrémités sont
  // étrangères à cet arbre (ex. relier deux membres d'un même arbre
  // d'origine, tous deux déjà rattachés individuellement à celui-ci).
  $("gen-m-link-foreign").addEventListener("click", () => {
    const fromId = editingMemberId || foreignPanelMemberId;
    if (!fromId) return;
    requireAuthOr(() => openForeignSearch(fromId));
  });
  function openForeignSearch(fromId: string) {
    const modal = $("gen-foreign-search-modal");
    const input = $("gen-foreign-search-input") as HTMLInputElement;
    const results = $("gen-foreign-search-results");
    input.value = "";
    results.innerHTML = "";
    modal.classList.add("open");
    setTimeout(() => input.focus(), 30);
    let debounce: number | null = null;
    async function runSearch() {
      const q = input.value.trim();
      if (q.length < 2) {
        results.innerHTML = "";
        return;
      }
      const { data } = await supabase
        .from("genealogy_members")
        .select("id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader, legend_item_id")
        .ilike("name", "%" + q + "%")
        .neq("id", fromId)
        .limit(15);
      results.innerHTML = "";
      ((data as MemberRow[] | null) || []).forEach((m) => {
        const row = document.createElement("button");
        row.type = "button";
        row.className = "btn-small gen-foreign-result";
        row.style.cssText = "display:block;width:100%;text-align:left;margin-top:4px;";
        const ownerLabel = foreignOwnerLabel(m);
        row.textContent = m.name + " — " + ownerLabel + (m.title ? " (" + m.title + ")" : "");
        row.addEventListener("click", async () => {
          modal.classList.remove("open");
          foreignMembers.set(m.id, m);
          await openRelationTypeModal(fromId, m.id);
        });
        results.appendChild(row);
      });
      if (!results.children.length) results.innerHTML = '<p class="muted" style="margin:4px 0;">Aucun résultat.</p>';
    }
    input.oninput = () => {
      if (debounce) window.clearTimeout(debounce);
      debounce = window.setTimeout(runSearch, 250);
    };
    $("gen-foreign-search-cancel").onclick = () => modal.classList.remove("open");
  }

  // --- Ouverture / fermeture de la vue plein écran ----------------------------
  $("genealogy-back").addEventListener("click", () => {
    $("genealogy-view").classList.remove("open");
    setLinkMode(false);
    closeMemberPanel();
  });

  async function openForOwner(owner: DossierOwnerRef) {
    currentOwner = owner;
    $("genealogy-title").textContent = "Généalogie — " + owner.label;
    $("genealogy-view").classList.add("open");
    setLinkMode(false);
    closeMemberPanel();
    resetView();
    // Rafraîchit l'index de liens en parallèle (voir le même appel dans
    // dossier.ts/openDossierForOwner) — pour que le rattachement
    // bidirectionnel membre ↔ fiche tienne compte des sections/entrées
    // créées ailleurs depuis la dernière ouverture d'un arbre.
    void ensureLinkIndexLoaded(supabase, true);
    await loadData(owner);
  }

  // Ouvre la fiche d'un membre déjà chargé (son arbre vient d'être ouvert
  // par deps.openOwnerTree côté main.ts) — utilisé par le rattachement
  // bidirectionnel (ficheDeps.openGenealogyMember, src/main.ts) et par la
  // recherche unifiée (résultat "genealogy-member", src/search.ts).
  function focusMember(memberId: string) {
    // Centre d'abord le canevas sur le membre (voir centerOnMember
    // ci-dessus), PUIS ouvre son panneau — l'ordre inverse laisserait le
    // panneau masquer la carte pendant l'animation de pan/zoom.
    centerOnMember(memberId);
    const local = members.find((x) => x.id === memberId);
    if (local) {
      openMemberPanel(local.id);
      return;
    }
    const foreign = foreignMembers.get(memberId);
    if (foreign) openForeignMemberPanel(foreign);
  }

  // Ferme la vue plein écran de l'arbre (mêmes effets que le bouton
  // "← " — voir #genealogy-back ci-dessus) — utilisé quand on navigue
  // AILLEURS depuis l'intérieur de l'arbre (ex. la bannière "Voir la
  // fiche →" d'un membre, dossier.ts::resolveLinkTarget) : sans ça, la
  // vue de l'arbre restait affichée au-dessus/derrière le dossier ouvert
  // ensuite, et son canvas interceptait les clics par-dessus (bug
  // constaté en testant le rattachement bidirectionnel, 2026-10-06).
  function closeView() {
    $("genealogy-view").classList.remove("open");
    setLinkMode(false);
    closeMemberPanel();
  }

  return {
    openForOwner,
    focusMember,
    closeView,
  };
}

// Réexporté pour que main.ts puisse typer son owner sans dépendre de
// l'ordre d'import (même DossierOwnerKind que src/dossier.ts).
export type { DossierOwnerKind };
