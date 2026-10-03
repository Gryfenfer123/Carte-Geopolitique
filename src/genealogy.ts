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
// Organisation retenue (confirmée par Martin) : UN arbre par dossier
// (owner_type/owner_id identique à DossierOwnerRef de src/dossier.ts), ouvert
// depuis ce dossier via le bouton "🌳 Généalogie" (câblé dans dossier.ts,
// deps.onOpenGenealogy). Un membre appartient à l'arbre dans lequel il a été
// créé, mais une RELATION entre deux membres peut traverser deux arbres
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
import { customConfirm } from "./dossier";

// --- Types -------------------------------------------------------------

type RelationType = "parent" | "spouse";

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
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

  // --- DOM : construit une seule fois -------------------------------------
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="genealogy-view">
      <div id="genealogy-topbar">
        <button id="genealogy-back" class="btn-small">&larr; Retour au dossier</button>
        <h2 id="genealogy-title"></h2>
        <div id="genealogy-toolbar">
          <button id="genealogy-add-member" class="btn-small">&#43; Membre</button>
          <button id="genealogy-link-mode" class="btn-small">&#128279; Lier deux membres</button>
          <span id="genealogy-link-hint" class="muted"></span>
        </div>
        <div id="genealogy-legend">
          <span class="gen-legend-item"><span class="gen-legend-line gen-legend-parent"></span>Parent &rarr; enfant</span>
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
      <button id="gen-m-photo-btn" class="btn-small">Changer la photo</button>
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

  function requireAuthOr(action: () => void) {
    if (!deps.getSession()) {
      deps.openAuthPanel();
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
        .select("id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by")
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
            .select("id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by")
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

  function renderNodes() {
    nodesLayer.innerHTML = "";
    const known = allKnownMembers();
    known.forEach((m) => {
      const pos = displayPos.get(m.id);
      if (!pos) return;
      const isForeign = !(currentOwner && m.owner_type === currentOwner.type && m.owner_id === currentOwner.id);
      const card = document.createElement("div");
      card.className = "gen-card" + (isForeign ? " gen-card-foreign" : "");
      card.dataset.memberId = m.id;
      card.style.left = pos.x + "px";
      card.style.top = pos.y + "px";
      card.style.width = CARD_W + "px";
      const photoHtml = m.photo_url
        ? '<img src="' + escapeHtml(m.photo_url) + '" alt="">'
        : '<span class="gen-card-initials">' + escapeHtml(initials(m.name)) + "</span>";
      const foreignBadge = isForeign
        ? '<span class="gen-card-flag" title="Membre d\'un autre arbre">&#127757; ' + escapeHtml(deps.getOwnerLabel(m.owner_type, m.owner_id) || m.owner_type) + "</span>"
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
    return type === "parent" ? "var(--accent)" : "var(--cable-line)";
  }

  function renderLinks() {
    svg.innerHTML = "";
    const NS = "http://www.w3.org/2000/svg";
    relations.forEach((r) => {
      const a = displayPos.get(r.member_a_id);
      const b = displayPos.get(r.member_b_id);
      if (!a || !b) return;
      const ax = a.x + CARD_W / 2;
      const ay = a.y + CARD_H / 2;
      const bx = b.x + CARD_W / 2;
      const by = b.y + CARD_H / 2;
      const line = document.createElementNS(NS, "line");
      line.setAttribute("x1", String(ax));
      line.setAttribute("y1", String(ay));
      line.setAttribute("x2", String(bx));
      line.setAttribute("y2", String(by));
      line.setAttribute("stroke", linkColor(r.relation_type));
      line.setAttribute("stroke-width", r.relation_type === "parent" ? "2.4" : "2");
      if (r.relation_type === "spouse") line.setAttribute("stroke-dasharray", "5,4");
      line.setAttribute("class", "gen-link gen-link-" + r.relation_type);
      svg.appendChild(line);
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
      if (moved && !isForeign) {
        const pos = displayPos.get(member.id)!;
        member.pos_x = pos.x;
        member.pos_y = pos.y;
        await supabase.from("genealogy_members").update({ pos_x: pos.x, pos_y: pos.y }).eq("id", member.id);
      }
    }
    card.addEventListener("mousedown", (e) => {
      if (isForeign || !deps.getSession()) return;
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
      if (isForeign || !deps.getSession()) return;
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
    // Un membre étranger référencé par une nouvelle relation n'est pas
    // forcément déjà dans foreignMembers/displayPos — on recharge les
    // données pour rester cohérent plutôt que de dupliquer la logique de
    // positionnement calculé de loadData().
    if (currentOwner) await loadData(currentOwner);
    if (editingMemberId) renderRelationsList(editingMemberId);
  }

  async function deleteRelation(id: string) {
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
    ($("gen-m-bio") as HTMLTextAreaElement).value = m?.bio || "";
    $("gen-m-photo-preview").innerHTML = m?.photo_url ? '<img src="' + escapeHtml(m.photo_url) + '" alt="">' : "";
    $("gen-m-save-status").textContent = "";
    ($("gen-m-delete") as HTMLButtonElement).style.display = m ? "" : "none";
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
      } else if (r.member_a_id === memberId) {
        label = "Parent de " + memberName(otherId);
      } else {
        label = "Enfant de " + memberName(otherId);
      }
      row.innerHTML = '<span>' + escapeHtml(label) + "</span>";
      const del = document.createElement("button");
      del.type = "button";
      del.className = "entry-del";
      del.style.cssText = "position:static;opacity:1;";
      del.textContent = "×";
      del.title = "Supprimer ce lien";
      del.addEventListener("click", () => deleteRelation(r.id));
      row.appendChild(del);
      list.appendChild(row);
    });
  }

  $("gen-m-photo-btn").addEventListener("click", () => {
    if (!deps.getSession()) {
      deps.openAuthPanel();
      return;
    }
    ($("gen-m-photo-input") as HTMLInputElement).click();
  });
  ($("gen-m-photo-input") as HTMLInputElement).addEventListener("change", (e) => {
    const file = (e.target as HTMLInputElement).files?.[0] || null;
    (e.target as HTMLInputElement).value = "";
    if (!file) return;
    photoPendingFile = file;
    const reader = new FileReader();
    reader.onload = () => {
      $("gen-m-photo-preview").innerHTML = '<img src="' + String(reader.result) + '" alt="">';
    };
    reader.readAsDataURL(file);
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
        // crée plusieurs d'affilée.
        const pos = { x: center.x + Math.random() * 60 - 30, y: center.y + Math.random() * 60 - 30 };
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
            bio,
            pos_x: pos.x,
            pos_y: pos.y,
            created_by: session.user.id,
          })
          .select("id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by")
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
    if (!editingMemberId) return;
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
        .select("id, owner_type, owner_id, name, photo_url, birth_year, death_year, title, dynasty, bio, pos_x, pos_y, created_by")
        .ilike("name", "%" + q + "%")
        .neq("id", fromId)
        .limit(15);
      results.innerHTML = "";
      ((data as MemberRow[] | null) || []).forEach((m) => {
        const row = document.createElement("button");
        row.type = "button";
        row.className = "btn-small gen-foreign-result";
        row.style.cssText = "display:block;width:100%;text-align:left;margin-top:4px;";
        const ownerLabel = deps.getOwnerLabel(m.owner_type, m.owner_id) || m.owner_type;
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
