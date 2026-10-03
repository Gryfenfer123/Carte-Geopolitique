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

import type { SupabaseClient, Session } from "@supabase/supabase-js";
import * as d3 from "d3";
import type { DossierOwnerKind, DossierOwnerRef } from "./dossier";
import { customConfirm, TRASH_ICON_SVG } from "./dossier";

// --- Types -------------------------------------------------------------

// "family" ajouté à la demande de Martin, 2026-10-03 ("Rajoute un lien =>
// Famille, pour en avoir 3 : Parent, Famille, Mariage") — lien symétrique,
// même traitement que "spouse" (aucun sens parent/enfant), juste un
// troisième type pour un lien de parenté qui n'est ni filiation directe ni
// mariage (ex. frère/sœur, cousin·e, oncle/tante...). Voir
// supabase/schema_v14.sql pour la contrainte CHECK côté base.
type RelationType = "parent" | "spouse" | "family";

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
};

type RelationRow = {
  id: string;
  member_a_id: string;
  member_b_id: string;
  relation_type: RelationType;
  created_by: string | null;
};

// Position d'affichage calculée pour cette ouverture de l'arbre (voir note
// ci-dessus sur les membres étrangers) — distincte de pos_x/pos_y (valeur
// persistée, pertinente uniquement dans l'arbre d'origine du membre).
type DisplayPos = { x: number; y: number };

const CARD_W = 158;
const CARD_H = 176;
// Aspect ratio de la zone photo de la carte (.gen-card-photo, voir
// style.css : largeur 100% de CARD_W, hauteur fixe 82px) — réutilisé comme
// ratio de cadrage dans le recadrage de photo (openCropModal ci-dessous)
// pour que la photo recadrée remplisse exactement cette zone sans bande ni
// recadrage navigateur imprévisible (object-fit: cover s'en charge déjà,
// mais autant livrer une image déjà au bon ratio).
const CARD_PHOTO_RATIO = CARD_W / 82;
// Écart vertical minimum imposé entre un parent et son enfant lors de la
// création d'un lien "parent" (point demandé par Martin, 2026-10-03:
// "même si on peut déplacer, ceux nés plus tôt sont plus haut, ceux plus
// tard plus bas, les enfants sont en dessous") — voir
// enforceParentChildOrder ci-dessous. Le glisser-déposer libre reste
// entièrement possible ensuite : seule la position DE DÉPART est corrigée.
const GENERATION_GAP = 230;
// Pixels par année pour le placement automatique d'un NOUVEAU membre selon
// son année de naissance par rapport aux membres existants de cet arbre
// (voir suggestYFromBirthYear) — purement indicatif, pas une échelle
// temporelle stricte (le glisser-déposer reste libre après coup).
const PX_PER_YEAR = 2.4;

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
  openOwnerTree: (ownerType: string, ownerId: string) => Promise<void>;
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
          <span id="genealogy-link-hint" class="muted"></span>
        </div>
        <div id="genealogy-legend">
          <span class="gen-legend-item"><span class="gen-legend-line gen-legend-parent"></span>Parent &rarr; enfant</span>
          <span class="gen-legend-item"><span class="gen-legend-line gen-legend-family"></span>Famille</span>
          <span class="gen-legend-item"><span class="gen-legend-line gen-legend-spouse"></span>Mariage</span>
          <span class="gen-legend-item"><span class="gen-legend-dot gen-legend-foreign"></span>Membre d'un autre pays</span>
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
      <h2 id="gen-member-heading">Membre</h2>
      <label class="field-label">Nom</label>
      <input type="text" id="gen-m-name" maxlength="160">
      <label class="field-label">Photo</label>
      <div id="gen-m-photo-preview" class="gen-photo-preview"></div>
      <button id="gen-m-photo-btn" class="btn-small edit-control">Changer la photo</button>
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
      <label class="field-label">Notes / biographie</label>
      <textarea id="gen-m-bio" rows="5"></textarea>
      <div id="gen-m-save-status" class="muted"></div>
      <div class="dossier-form-actions" style="margin-top:10px;">
        <button id="gen-m-save" class="btn-primary">Enregistrer</button>
        <button id="gen-m-delete" class="btn-small">Supprimer</button>
      </div>
      <div id="gen-m-relations">
        <label class="field-label">Liens</label>
        <div id="gen-m-relations-list"></div>
        <button id="gen-m-link-foreign" class="btn-small">Lier &agrave; un membre d'un autre pays</button>
      </div>
    </div>

    <div id="gen-relation-modal" class="poi-overlay">
      <div class="poi-overlay-box">
        <h3 id="gen-relation-modal-title">Quel est le lien ?</h3>
        <div id="gen-relation-modal-choices" class="dossier-form-actions" style="flex-direction:column;align-items:stretch;"></div>
        <button id="gen-relation-modal-cancel" class="btn-small" style="margin-top:10px;">Annuler</button>
      </div>
    </div>

    <div id="gen-foreign-search-modal" class="poi-overlay">
      <div class="poi-overlay-box">
        <h3>Lier &agrave; un membre d'un autre pays</h3>
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
    try {
      const { data: memberRows, error: memberErr } = await supabase
        .from("genealogy_members")
        .select("id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader")
        .eq("owner_type", owner.type)
        .eq("owner_id", owner.id);
      if (memberErr) throw memberErr;
      members = (memberRows as MemberRow[] | null) || [];
      const ids = members.map((m) => m.id);
      if (ids.length) {
        const { data: relRows, error: relErr } = await supabase
          .from("genealogy_relations")
          .select("id, member_a_id, member_b_id, relation_type, created_by")
          .or("member_a_id.in.(" + ids.join(",") + "),member_b_id.in.(" + ids.join(",") + ")");
        if (relErr) throw relErr;
        relations = (relRows as RelationRow[] | null) || [];
        const localIds = new Set(ids);
        const foreignIds = new Set<string>();
        relations.forEach((r) => {
          if (!localIds.has(r.member_a_id)) foreignIds.add(r.member_a_id);
          if (!localIds.has(r.member_b_id)) foreignIds.add(r.member_b_id);
        });
        if (foreignIds.size) {
          const { data: fRows } = await supabase
            .from("genealogy_members")
            .select("id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader")
            .in("id", Array.from(foreignIds));
          (fRows as MemberRow[] | null)?.forEach((m) => foreignMembers.set(m.id, m));
        }
      }
    } catch (err) {
      console.error("Échec du chargement de l'arbre (schema_v11.sql exécutée ? réseau indisponible ?) :", err);
      members = [];
      relations = [];
      foreignMembers = new Map();
    }
    displayPos.clear();
    members.forEach((m) => displayPos.set(m.id, { x: m.pos_x, y: m.pos_y }));
    // Position des membres étrangers (voir note en tête de fichier) : à
    // distance fixe du premier membre local auquel ils sont reliés.
    relations.forEach((r) => {
      [r.member_a_id, r.member_b_id].forEach((id) => {
        if (displayPos.has(id) || !foreignMembers.has(id)) return;
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
    renderAll();
    if (!members.length) $("genealogy-empty-hint").style.display = "";
  }

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

  function renderNodes() {
    nodesLayer.innerHTML = "";
    const known = allKnownMembers();
    known.forEach((m) => {
      const pos = displayPos.get(m.id);
      if (!pos) return;
      const isForeign = !(currentOwner && m.owner_type === currentOwner.type && m.owner_id === currentOwner.id);
      const card = document.createElement("div");
      card.className = "gen-card" + (isForeign ? " gen-card-foreign" : "") + (m.is_leader ? " gen-card-leader" : "");
      card.dataset.memberId = m.id;
      card.style.left = pos.x + "px";
      card.style.top = pos.y + "px";
      card.style.width = CARD_W + "px";
      const photoHtml = m.photo_url
        ? '<img src="' + escapeHtml(m.photo_url) + '" alt="">'
        : '<span class="gen-card-initials">' + escapeHtml(initials(m.name)) + "</span>";
      const foreignBadge = isForeign
        ? '<span class="gen-card-flag" title="Membre d\'un autre arbre">&#127757; ' + escapeHtml(foreignOwnerLabel(m)) + "</span>"
        : "";
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

  function linkColor(type: RelationType): string {
    if (type === "parent") return "var(--accent)";
    if (type === "family") return "var(--family-line)";
    return "var(--cable-line)";
  }

  function cardCenter(id: string): { x: number; y: number } | null {
    const p = displayPos.get(id);
    if (!p) return null;
    return { x: p.x + CARD_W / 2, y: p.y + CARD_H / 2 };
  }

  function drawLine(x1: number, y1: number, x2: number, y2: number, type: RelationType, extraClass?: string) {
    const NS = "http://www.w3.org/2000/svg";
    const line = document.createElementNS(NS, "line");
    line.setAttribute("x1", String(x1));
    line.setAttribute("y1", String(y1));
    line.setAttribute("x2", String(x2));
    line.setAttribute("y2", String(y2));
    line.setAttribute("stroke", linkColor(type));
    line.setAttribute("stroke-width", type === "parent" ? "2.4" : "2");
    if (type === "spouse") line.setAttribute("stroke-dasharray", "5,4");
    if (type === "family") line.setAttribute("stroke-dasharray", "1.5,3.5");
    line.setAttribute("class", "gen-link gen-link-" + type + (extraClass ? " " + extraClass : ""));
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
      drawLine(midX, midY, c.x, c.y, "parent", "gen-link-from-marriage");
      mergedParentRelIds.add(p1.id);
      mergedParentRelIds.add(p2.id);
    });
    relations.forEach((r) => {
      if (mergedParentRelIds.has(r.id)) return;
      const a = cardCenter(r.member_a_id);
      const b = cardCenter(r.member_b_id);
      if (!a || !b) return;
      drawLine(a.x, a.y, b.x, b.y, r.relation_type);
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
      const ny = startPosY + dy;
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
      // BUG (2026-10-03, signalé par Martin : "le membre apparaît mais on
      // ne peut pas le bouger... et il fait bug son arbre d'origine") :
      // un membre étranger (gen-card-foreign) a son pos_x/pos_y stocké
      // dans le repère de SON arbre d'origine, pas de celui-ci — sa
      // position ICI est recalculée à la volée (voir loadData, distance
      // fixe depuis le membre local auquel il est relié) et JAMAIS
      // persistée. Avant ce correctif, `isForeign` bloquait le glisser dès
      // le mousedown (voir plus bas) : la carte semblait figée. Désormais
      // le glisser est autorisé pour TOUT le monde (confort visuel, pour
      // écarter une carte étrangère gênante), mais on n'écrit en base QUE
      // pour un membre local (`!isForeign`) — écrire la position calculée
      // ici dans la ligne réelle du membre étranger aurait littéralement
      // déplacé son point d'origine dans SON PROPRE arbre à chaque glisser
      // involontaire, le "cassant" au sens propre. La position d'un
      // membre étranger reste donc purement visuelle pour cette ouverture
      // de l'arbre (recalculée au prochain chargement).
      if (moved && !isForeign) {
        const pos = displayPos.get(member.id)!;
        member.pos_x = pos.x;
        member.pos_y = pos.y;
        await supabase.from("genealogy_members").update({ pos_x: pos.x, pos_y: pos.y }).eq("id", member.id);
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
      if (isForeign) {
        void deps.openOwnerTree(member.owner_type, member.owner_id);
        return;
      }
      if (linkModeActive) {
        handleLinkModeClick(member.id);
        return;
      }
      openMemberPanel(member.id);
    });
  }

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
      addChoice(memberName(aId) + " est le parent de " + memberName(bId), () => createRelation(aId, bId, "parent"));
      addChoice(memberName(bId) + " est le parent de " + memberName(aId), () => createRelation(bId, aId, "parent"));
      addChoice(memberName(aId) + " et " + memberName(bId) + " sont mariés", () => createRelation(aId, bId, "spouse"));
      addChoice(memberName(aId) + " et " + memberName(bId) + " sont de la même famille (sans lien direct)", () => createRelation(aId, bId, "family"));
      $("gen-relation-modal-cancel").onclick = cleanup;
      modal.classList.add("open");
    });
  }

  async function createRelation(aId: string, bId: string, type: RelationType) {
    const session = deps.getSession();
    if (!session) {
      deps.openAuthPanel();
      return;
    }
    if (!isAdmin()) {
      deps.showBanner?.("Tu n'as pas les droits d'édition sur cet atlas.");
      return;
    }
    const { data, error } = await supabase
      .from("genealogy_relations")
      .insert({ member_a_id: aId, member_b_id: bId, relation_type: type, created_by: session.user.id })
      .select("id, member_a_id, member_b_id, relation_type, created_by")
      .single();
    if (error || !data) {
      deps.showBanner?.("Erreur lors de la création du lien.");
      return;
    }
    relations.push(data as RelationRow);
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
  function openMemberPanel(id: string | null) {
    editingMemberId = id;
    photoPendingFile = null;
    $("gen-m-photo-status").textContent = "";
    const m = id ? members.find((x) => x.id === id) || null : null;
    $("gen-member-heading").textContent = m ? "Modifier le membre" : "Nouveau membre";
    ($("gen-m-name") as HTMLInputElement).value = m?.name || "";
    ($("gen-m-birth") as HTMLInputElement).value = m?.birth_year != null ? String(m.birth_year) : "";
    ($("gen-m-death") as HTMLInputElement).value = m?.death_year != null ? String(m.death_year) : "";
    ($("gen-m-title") as HTMLInputElement).value = m?.title || "";
    ($("gen-m-dynasty") as HTMLInputElement).value = m?.dynasty || "";
    ($("gen-m-leader") as HTMLInputElement).checked = m?.is_leader || false;
    ($("gen-m-bio") as HTMLTextAreaElement).value = m?.bio || "";
    $("gen-m-photo-preview").innerHTML = m?.photo_url ? '<img src="' + escapeHtml(m.photo_url) + '" alt="">' : "";
    $("gen-m-save-status").textContent = "";
    ($("gen-m-delete") as HTMLButtonElement).style.display = m && isAdmin() ? "" : "none";
    $("gen-m-relations").style.display = m ? "" : "none";
    if (m) renderRelationsList(m.id);
    $("gen-member-panel").classList.add("open");
  }
  function closeMemberPanel() {
    $("gen-member-panel").classList.remove("open");
    editingMemberId = null;
  }
  $("gen-member-close").addEventListener("click", closeMemberPanel);
  $("genealogy-add-member").addEventListener("click", () => requireAuthOr(() => openMemberPanel(null)));

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
        label = "Famille avec " + memberName(otherId);
      } else if (r.member_a_id === memberId) {
        label = "Parent de " + memberName(otherId);
      } else {
        label = "Enfant de " + memberName(otherId);
      }
      row.innerHTML = '<span>' + escapeHtml(label) + "</span>";
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

  $("gen-m-save").addEventListener("click", async () => {
    const session = deps.getSession();
    if (!session || !currentOwner) {
      deps.openAuthPanel();
      return;
    }
    if (!isAdmin()) {
      deps.showBanner?.("Tu n'as pas les droits d'édition sur cet atlas.");
      return;
    }
    const name = ($("gen-m-name") as HTMLInputElement).value.trim();
    if (!name) {
      $("gen-m-save-status").textContent = "Le nom est obligatoire.";
      return;
    }
    const birthStr = ($("gen-m-birth") as HTMLInputElement).value.trim();
    const deathStr = ($("gen-m-death") as HTMLInputElement).value.trim();
    const birth = birthStr ? parseInt(birthStr, 10) : null;
    const death = deathStr ? parseInt(deathStr, 10) : null;
    const title = ($("gen-m-title") as HTMLInputElement).value.trim() || null;
    const dynasty = ($("gen-m-dynasty") as HTMLInputElement).value.trim() || null;
    const isLeader = ($("gen-m-leader") as HTMLInputElement).checked;
    const bio = ($("gen-m-bio") as HTMLTextAreaElement).value.trim() || null;
    $("gen-m-save-status").textContent = "Enregistrement…";
    try {
      if (editingMemberId) {
        const patch: Record<string, unknown> = {
          name,
          birth_year: Number.isFinite(birth) ? birth : null,
          death_year: Number.isFinite(death) ? death : null,
          title,
          dynasty,
          is_leader: isLeader,
          bio,
        };
        if (photoPendingFile) {
          $("gen-m-photo-status").textContent = "Envoi de la photo…";
          const url = await uploadMemberPhoto(photoPendingFile, editingMemberId);
          if (url) patch.photo_url = url;
          $("gen-m-photo-status").textContent = url ? "" : "Échec de l'envoi de la photo.";
        }
        await supabase.from("genealogy_members").update(patch).eq("id", editingMemberId);
        const m = members.find((x) => x.id === editingMemberId);
        if (m) Object.assign(m, patch);
      } else {
        const center = canvasWrap
          ? { x: (canvasWrap.clientWidth / 2 - zoomTransform.x) / zoomTransform.k, y: (canvasWrap.clientHeight / 2 - zoomTransform.y) / zoomTransform.k }
          : { x: 0, y: 0 };
        // Place le nouveau membre près du centre de la vue actuelle, avec un
        // petit décalage aléatoire pour éviter l'empilement exact si on en
        // crée plusieurs d'affilée — SAUF si une année de naissance a été
        // renseignée et que d'autres membres de cet arbre en ont une aussi :
        // dans ce cas on préfère un Y suggéré par interpolation (voir
        // suggestYFromBirthYear) pour que les plus âgés apparaissent par
        // défaut plus haut que les plus jeunes, sans empêcher de glisser la
        // carte ensuite.
        const suggestedY = suggestYFromBirthYear(Number.isFinite(birth) ? birth : null);
        const pos = {
          x: center.x + Math.random() * 60 - 30,
          y: suggestedY != null ? suggestedY : center.y + Math.random() * 60 - 30,
        };
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
          .select("id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader")
          .single();
        if (error || !data) {
          $("gen-m-save-status").textContent = "Erreur d'enregistrement.";
          return;
        }
        const row = data as MemberRow;
        if (photoPendingFile) {
          $("gen-m-photo-status").textContent = "Envoi de la photo…";
          const url = await uploadMemberPhoto(photoPendingFile, row.id);
          if (url) {
            await supabase.from("genealogy_members").update({ photo_url: url }).eq("id", row.id);
            row.photo_url = url;
          }
          $("gen-m-photo-status").textContent = "";
        }
        members.push(row);
        displayPos.set(row.id, { x: row.pos_x, y: row.pos_y });
        editingMemberId = row.id;
      }
      $("gen-m-save-status").textContent = "Enregistré ✓";
      $("genealogy-empty-hint").style.display = "none";
      renderAll();
    } catch {
      $("gen-m-save-status").textContent = "Erreur d'enregistrement.";
    }
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
  $("gen-m-link-foreign").addEventListener("click", () => {
    if (!editingMemberId) return;
    requireAuthOr(() => openForeignSearch(editingMemberId!));
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
        .select("id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by, is_leader")
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
    await loadData(owner);
  }

  return {
    openForOwner,
  };
}

// Réexporté pour que main.ts puisse typer son owner sans dépendre de
// l'ordre d'import (même DossierOwnerKind que src/dossier.ts).
export type { DossierOwnerKind };
