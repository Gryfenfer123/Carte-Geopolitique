// ---------------------------------------------------------------------------
// Liens entre pays et groupes — porté de l'artifact source
// (realistic_final.html) : linkDocs (~3449), LINKABLE_KINDS = {country,
// group} (~3371, vérifié dans le source — pas de liens pour ports/détroits/
// pipelines/bases/câbles/capitales), gLinks (~2862), linkPathD/
// curvedSegmentD (~9371-9409, tracé courbe + repli par l'antiméridien),
// linksForEntity/isLinkVisible/isCountryLinksHidden (~9411-9438),
// linkYearBounds/linkVisibleInRange/computeLinkYearRange (~9440-9493,
// filtrage par période — frise chronologique), initRangeSlider
// (~9508-9574, curseur double), renderLinksForEntity/renderAllLinks
// (~9576-9618), mode création (linkModeActive/linkPending/
// resolveEntitySelection, ~8417-8441, 9315-9331), éditeur de lien
// (openLinkEditor/saveCurrentLinkImpl/flushLinkSave/closeLinkEditor,
// ~9684-9805), suppression (~9899-9922) et panneau Chronologie
// (renderChronologie/chronoSortKey, ~4760-4869).
//
// Écart assumé par rapport au source : les « fiches auto-générées » pour
// les liens de catégorie « conflit » (AUTO_DOSSIER_RULES/
// syncAutoDossierEntries, ~9807-9896) ne sont PAS portées ici — dossier.ts
// n'expose pas d'API d'ajout/retrait d'entrée de dossier programmatique
// depuis l'extérieur, et cette fonctionnalité n'est pas listée dans la
// mission de portage. Voir le résumé de fin de portage.
// ---------------------------------------------------------------------------

import type { SupabaseClient, Session } from "@supabase/supabase-js";
import * as d3 from "d3";
import { LINK_CATEGORY_META } from "./indicators";

export type LinkEntityKind = "country" | "group";
export type LinkEntityRef = { kind: LinkEntityKind; id: string; label: string };
export type LinkDoc = {
  a: LinkEntityRef;
  b: LinkEntityRef;
  category: string;
  description: string;
  dateStart: string;
  dateEnd: string;
  createdAt: string;
};

export function initLinksSystem(deps: {
  supabase: SupabaseClient;
  getSession: () => Session | null;
  getProfile: () => { id: string; role: string } | null;
  gLinksLayer: d3.Selection<SVGGElement, unknown, HTMLElement | null, unknown>;
  projectLonLat: (lonlat: [number, number]) => [number, number];
  // Centroïde du territoire métropolitain (lon/lat), avant projection —
  // porté de mainlandCentroid()/entityAnchorLonLat() (~9338-9370).
  getCountryAnchor: (isoA3: string) => [number, number] | null;
  getCountryFrenchName: (isoA3: string) => string;
  getGroupMembers: (groupId: string) => Set<string> | undefined;
  entityLabel: (kind: LinkEntityKind, id: string) => string;
  showBanner: (text: string) => void;
  hideBanner: () => void;
  setMapCursor?: (active: boolean) => void;
  // Coordination avec le mode "ajouter pays sur la carte" d'un groupe
  // (src/groups.ts) — porté de resolveEntitySelection()/enterGroupAddMode()
  // qui n'autorisent qu'un seul mode "clic sur la carte" actif à la fois.
  onBeforeLinkMode?: () => void;
  showTip: (event: MouseEvent, label: string) => void;
  hideTip: () => void;
  selectEntity: (kind: LinkEntityKind, id: string) => void;
}) {
  const { supabase } = deps;
  // Point 4a (2026-10-03) : seul un compte admin peut créer/modifier un
  // lien ou masquer les liens d'un pays (voir supabase/schema_v13.sql pour
  // le pendant RLS). Pas de fonction isAdmin() préexistante ici — en créer
  // une, même principe que src/dossier.ts/src/groups.ts.
  function isAdmin(): boolean {
    return deps.getProfile()?.role === "admin" && !document.body.classList.contains("read-only-mode");
  }

  // ---------------------------------------------------------------------
  // DOM injecté une fois — panneau "Chronologie" et éditeur de lien,
  // porté de #chronologie-panel (~1779-1788) et #link-editor (~1816-1847).
  // ---------------------------------------------------------------------
  const root = document.createElement("div");
  root.innerHTML = `
    <div id="link-editor" class="panel side-panel">
      <button class="close-x" id="link-editor-close" aria-label="Fermer">&times;</button>
      <h2 id="link-editor-title">Lien</h2>
      <label class="field-label">Catégorie</label>
      <select id="link-category">
        ${LINK_CATEGORY_META.map((m) => `<option value="${m.id}">${m.label}</option>`).join("")}
      </select>
      <label class="field-label">Description</label>
      <textarea id="link-description" rows="5" placeholder="Détail du lien entre ces deux éléments"></textarea>
      <div class="link-dates">
        <div>
          <label class="field-label">Début</label>
          <input type="text" id="link-date-start" placeholder="ex. 1957">
        </div>
        <div>
          <label class="field-label">Fin</label>
          <input type="text" id="link-date-end" placeholder="en cours si vide">
        </div>
      </div>
      <div class="link-editor-actions">
        <button id="link-delete" class="btn-danger" style="display:none">Supprimer</button>
      </div>
      <div id="link-save-status"></div>
    </div>
  `;
  while (root.firstChild) document.body.appendChild(root.firstChild);
  const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

  const linkDocs = new Map<string, LinkDoc>();
  const linksHiddenByCountry = new Map<string, boolean>();

  // -------------------------------------------------------------------
  // Chargement / persistance — country_links (schema_v7.sql : colonnes
  // entity_a_kind/entity_a_id/entity_a_label, entity_b_*, description,
  // start_date/end_date en text).
  // -------------------------------------------------------------------
  type LinkRow = {
    id: string;
    entity_a_kind: LinkEntityKind;
    entity_a_id: string;
    entity_a_label: string | null;
    entity_b_kind: LinkEntityKind;
    entity_b_id: string;
    entity_b_label: string | null;
    category: string;
    description: string | null;
    start_date: string | null;
    end_date: string | null;
    created_by: string | null;
    created_at: string;
  };
  const linkOwners = new Map<string, string | null>();

  function rowToDoc(row: LinkRow): LinkDoc {
    return {
      a: { kind: row.entity_a_kind, id: row.entity_a_id, label: row.entity_a_label || deps.entityLabel(row.entity_a_kind, row.entity_a_id) },
      b: { kind: row.entity_b_kind, id: row.entity_b_id, label: row.entity_b_label || deps.entityLabel(row.entity_b_kind, row.entity_b_id) },
      category: row.category,
      description: row.description || "",
      dateStart: row.start_date || "",
      dateEnd: row.end_date || "",
      createdAt: row.created_at,
    };
  }

  async function loadLinks() {
    const { data } = await supabase
      .from("country_links")
      .select(
        "id, entity_a_kind, entity_a_id, entity_a_label, entity_b_kind, entity_b_id, entity_b_label, category, description, start_date, end_date, created_by, created_at"
      );
    linkDocs.clear();
    linkOwners.clear();
    (data || []).forEach((row) => {
      const r = row as unknown as LinkRow;
      if (!r.entity_a_id || !r.entity_b_id) return; // ligne pays↔pays pré-v7 non migrée
      linkDocs.set(r.id, rowToDoc(r));
      linkOwners.set(r.id, r.created_by);
    });
  }
  async function loadLinksHidden() {
    const { data } = await supabase.from("countries").select("id, links_hidden");
    linksHiddenByCountry.clear();
    (data || []).forEach((row) => linksHiddenByCountry.set(row.id as string, !!(row as { links_hidden?: boolean }).links_hidden));
  }

  function isCountryLinksHidden(isoA3: string): boolean {
    return !!linksHiddenByCountry.get(isoA3);
  }
  async function setCountryLinksHidden(isoA3: string, hidden: boolean) {
    linksHiddenByCountry.set(isoA3, hidden);
    redraw();
    const session = deps.getSession();
    if (!session || !isAdmin()) return;
    try {
      await supabase
        .from("countries")
        .upsert({ id: isoA3, name_fr: deps.getCountryFrenchName(isoA3), links_hidden: hidden }, { onConflict: "id" });
    } catch {
      /* best-effort : la préférence reste active pour la session en cours */
    }
  }

  // -------------------------------------------------------------------
  // Géométrie des tracés — porté de mainlandCentroid/entityAnchorLonLat
  // (~9338-9370), curvedSegmentD (~9371-9376) et linkPathD (~9377-9409,
  // repli par l'antiméridien identique à celui des câbles sous-marins).
  // -------------------------------------------------------------------
  function entityAnchorLonLat(kind: LinkEntityKind, id: string): [number, number] | null {
    if (kind === "country") return deps.getCountryAnchor(id);
    const members = deps.getGroupMembers(id);
    if (!members || !members.size) return null;
    const pts = Array.from(members)
      .map((iso3) => deps.getCountryAnchor(iso3))
      .filter((p): p is [number, number] => !!p);
    if (!pts.length) return null;
    return [d3.mean(pts, (p) => p[0]) as number, d3.mean(pts, (p) => p[1]) as number];
  }
  function curvedSegmentD(pa: [number, number], pb: [number, number]): string {
    const mx = (pa[0] + pb[0]) / 2,
      my = (pa[1] + pb[1]) / 2;
    const dx = pb[0] - pa[0],
      dy = pb[1] - pa[1];
    const cx = mx - dy * 0.15,
      cy = my + dx * 0.15;
    return "M" + pa[0] + "," + pa[1] + " Q" + cx + "," + cy + " " + pb[0] + "," + pb[1];
  }
  function linkPathD(l: LinkDoc): string {
    const lla = entityAnchorLonLat(l.a.kind, l.a.id);
    const llb = entityAnchorLonLat(l.b.kind, l.b.id);
    if (!lla || !llb) return "";
    const [lonA, latA] = lla,
      [lonB, latB] = llb;
    const dlon = lonB - lonA;
    if (Math.abs(dlon) > 180) {
      const goingEast = dlon < 0;
      const edgeLonA = goingEast ? -180 : 180;
      const edgeLonB = goingEast ? 180 : -180;
      const wrappedLonB = goingEast ? lonB - 360 : lonB + 360;
      const t = (edgeLonA - lonA) / (wrappedLonB - lonA);
      const latMid = latA + t * (latB - latA);
      const pa = deps.projectLonLat([lonA, latA]);
      const pEdgeA = deps.projectLonLat([edgeLonA, latMid]);
      const pEdgeB = deps.projectLonLat([edgeLonB, latMid]);
      const pb = deps.projectLonLat([lonB, latB]);
      return curvedSegmentD(pa, pEdgeA) + " " + curvedSegmentD(pEdgeB, pb);
    }
    const pa = deps.projectLonLat([lonA, latA]);
    const pb = deps.projectLonLat([lonB, latB]);
    return curvedSegmentD(pa, pb);
  }

  function linksForEntity(kind: LinkEntityKind, id: string): [string, LinkDoc][] {
    return Array.from(linkDocs.entries()).filter(
      ([, l]) => (l.a.kind === kind && l.a.id === id) || (l.b.kind === kind && l.b.id === id)
    );
  }
  function isLinkVisible(l: LinkDoc): boolean {
    if (l.a.kind === "country" && isCountryLinksHidden(l.a.id)) return false;
    if (l.b.kind === "country" && isCountryLinksHidden(l.b.id)) return false;
    return true;
  }

  // --- Filtrage par période (frise chronologique) — porté à l'identique
  // de linkYearBounds/linkVisibleInRange/computeLinkYearRange (~9440-9493).
  function linkYearBounds(l: LinkDoc): { start: number; end: number | null } | null {
    const mStart = (l.dateStart || "").trim().match(/-?\d{3,4}/);
    if (!mStart) return null;
    const start = parseInt(mStart[0], 10);
    const mEnd = (l.dateEnd || "").trim().match(/-?\d{3,4}/);
    const end = mEnd ? parseInt(mEnd[0], 10) : null;
    return { start, end };
  }
  function linkVisibleInRange(l: LinkDoc, range: [number, number] | null): boolean {
    if (!range) return true;
    const b = linkYearBounds(l);
    if (!b) return true;
    if (b.start > range[1]) return false;
    if (b.end != null && b.end < range[0]) return false;
    return true;
  }
  function computeLinkYearRange(): [number, number] {
    let mn = Infinity,
      mx = -Infinity;
    const now = new Date().getFullYear();
    linkDocs.forEach((l) => {
      const b = linkYearBounds(l);
      if (!b) return;
      if (b.start < mn) mn = b.start;
      const effectiveEnd = b.end != null ? b.end : now;
      if (effectiveEnd > mx) mx = effectiveEnd;
      if (b.start > mx) mx = b.start;
    });
    if (!isFinite(mn) || !isFinite(mx)) {
      mn = 1800;
      mx = new Date().getFullYear();
    }
    if (mn === mx) {
      mn -= 1;
      mx += 1;
    }
    return [mn, mx];
  }

  function rafThrottle<A extends unknown[]>(fn: (...args: A) => void): (...args: A) => void {
    let scheduled = false;
    let lastArgs: A | null = null;
    return (...args: A) => {
      lastArgs = args;
      if (scheduled) return;
      scheduled = true;
      requestAnimationFrame(() => {
        scheduled = false;
        if (lastArgs) fn(...lastArgs);
      });
    };
  }

  // --- Curseur double (frise chronologique) — porté de initRangeSlider
  // (~9508-9574), adapté pour cibler un conteneur donné (data-rs="...")
  // plutôt que des ids globaux fixes : ce port instancie plusieurs
  // curseurs (frise du bas + une frise par fiche/éditeur ouvert), alors
  // que l'artifact n'avait qu'une seule fiche partagée par tous les types
  // d'éléments.
  type RangeSlider = {
    setBounds(min: number, max: number, keepRange: boolean): void;
    setRange(s: number, e: number): void;
    getRange(): [number, number];
    getBounds(): [number, number];
  };
  function timelineMarkup(): string {
    return `
      <div class="rs-track" data-rs="track">
        <div class="rs-fill" data-rs="fill"></div>
        <div class="rs-handle rs-handle-start" data-rs="handle-start" tabindex="0"><span class="rs-label" data-rs="label-start"></span></div>
        <div class="rs-handle rs-handle-end" data-rs="handle-end" tabindex="0"><span class="rs-label" data-rs="label-end"></span></div>
      </div>`;
  }
  function initRangeSliderIn(container: HTMLElement, onChange: (s: number, e: number) => void): RangeSlider {
    const track = container.querySelector<HTMLElement>('[data-rs="track"]')!;
    const fill = container.querySelector<HTMLElement>('[data-rs="fill"]')!;
    const hStart = container.querySelector<HTMLElement>('[data-rs="handle-start"]')!;
    const hEnd = container.querySelector<HTMLElement>('[data-rs="handle-end"]')!;
    const lStart = container.querySelector<HTMLElement>('[data-rs="label-start"]')!;
    const lEnd = container.querySelector<HTMLElement>('[data-rs="label-end"]')!;
    let min = 1800,
      max = 2026,
      start = min,
      end = max;

    function pct(v: number): number {
      return max === min ? 0 : ((v - min) / (max - min)) * 100;
    }
    function render() {
      const ps = pct(start),
        pe = pct(end);
      hStart.style.left = ps + "%";
      hEnd.style.left = pe + "%";
      fill.style.left = ps + "%";
      fill.style.width = Math.max(0, pe - ps) + "%";
      lStart.textContent = String(Math.round(start));
      lEnd.textContent = String(Math.round(end));
    }
    function valueFromClientX(clientX: number): number {
      const rect = track.getBoundingClientRect();
      let p = rect.width ? (clientX - rect.left) / rect.width : 0;
      p = Math.max(0, Math.min(1, p));
      return min + p * (max - min);
    }
    function bind(handle: HTMLElement, isStart: boolean) {
      handle.addEventListener("pointerdown", (e) => {
        e.preventDefault();
        e.stopPropagation();
        try {
          handle.setPointerCapture(e.pointerId);
        } catch {
          /* ignore */
        }
        const move = (ev: PointerEvent) => {
          let v = Math.round(valueFromClientX(ev.clientX));
          if (isStart) {
            v = Math.min(v, end);
            start = v;
          } else {
            v = Math.max(v, start);
            end = v;
          }
          render();
          onChange(start, end);
        };
        const up = () => {
          try {
            handle.releasePointerCapture(e.pointerId);
          } catch {
            /* ignore */
          }
          window.removeEventListener("pointermove", move);
          window.removeEventListener("pointerup", up);
        };
        window.addEventListener("pointermove", move);
        window.addEventListener("pointerup", up);
      });
    }
    bind(hStart, true);
    bind(hEnd, false);
    render();
    return {
      setBounds(newMin, newMax, keepRange) {
        min = newMin;
        max = newMax;
        if (!keepRange) {
          start = min;
          end = max;
        } else {
          start = Math.max(min, Math.min(start, max));
          end = Math.max(min, Math.min(end, max));
          if (start > end) start = end;
        }
        render();
      },
      setRange(s, e) {
        start = s;
        end = e;
        render();
      },
      getRange: () => [start, end],
      getBounds: () => [min, max],
    };
  }

  // -------------------------------------------------------------------
  // Tracé sur la carte — porté de renderLinksForEntity/renderAllLinks
  // (~9576-9618).
  // -------------------------------------------------------------------
  let currentEntity: { kind: LinkEntityKind; id: string } | null = null;
  let currentEntityRange: [number, number] | null = null;
  let allLinksMode = false;
  let allLinksRange: [number, number] | null = null;

  function renderLinksForEntity(kind: LinkEntityKind, id: string, range: [number, number] | null) {
    deps.gLinksLayer.selectAll("*").remove();
    let relevant = linksForEntity(kind, id).filter(([, l]) => isLinkVisible(l));
    if (range) relevant = relevant.filter(([, l]) => linkVisibleInRange(l, range));
    deps.gLinksLayer
      .selectAll<SVGPathElement, [string, LinkDoc]>("path.link-line")
      .data(relevant, (d) => d[0])
      .join("path")
      .attr("class", (d) => "link-line link-" + (d[1].category || "autre"))
      .attr("d", (d) => linkPathD(d[1]))
      .on("mousemove", (event, d) => {
        const other = d[1].a.kind === kind && d[1].a.id === id ? d[1].b : d[1].a;
        deps.showTip(event, deps.entityLabel(kind, id) + " ↔ " + (other.label || deps.entityLabel(other.kind, other.id)));
      })
      .on("mouseleave", () => deps.hideTip())
      .on("click", (event, d) => {
        event.stopPropagation();
        openLinkEditor({ id: d[0], ...d[1] });
      });
  }
  function renderAllLinks(range: [number, number] | null) {
    deps.gLinksLayer.selectAll("*").remove();
    const entries = Array.from(linkDocs.entries()).filter(([, l]) => linkVisibleInRange(l, range) && isLinkVisible(l));
    const countEl = document.getElementById("timeline-count");
    if (countEl) countEl.textContent = entries.length + (entries.length > 1 ? " liens affichés" : " lien affiché");
    deps.gLinksLayer
      .selectAll<SVGPathElement, [string, LinkDoc]>("path.link-line")
      .data(entries, (d) => d[0])
      .join("path")
      .attr("class", (d) => "link-line link-" + (d[1].category || "autre"))
      .attr("d", (d) => linkPathD(d[1]))
      .on("mousemove", (event, d) => {
        const aLabel = d[1].a.label || deps.entityLabel(d[1].a.kind, d[1].a.id);
        const bLabel = d[1].b.label || deps.entityLabel(d[1].b.kind, d[1].b.id);
        deps.showTip(event, aLabel + " ↔ " + bLabel);
      })
      .on("mouseleave", () => deps.hideTip())
      .on("click", (event, d) => {
        event.stopPropagation();
        openLinkEditor({ id: d[0], ...d[1] });
      });
  }
  // Rappelé par main.ts (resetOverlay) à chaque zoom/déplacement : les
  // tracés dépendent de projectLonLat, qui change avec la vue Leaflet.
  function redraw() {
    if (allLinksMode) renderAllLinks(allLinksRange);
    else if (currentEntity) renderLinksForEntity(currentEntity.kind, currentEntity.id, currentEntityRange);
  }

  // -------------------------------------------------------------------
  // Widget "Liens" injecté dans la fiche pays / l'éditeur de groupe —
  // porté du bloc .links-section de la fiche unifiée (~1730-1747).
  // -------------------------------------------------------------------
  function renderFicheLinksList(list: HTMLElement, kind: LinkEntityKind, id: string, range: [number, number] | null) {
    list.innerHTML = "";
    let relevant = linksForEntity(kind, id);
    if (range) relevant = relevant.filter(([, l]) => linkVisibleInRange(l, range));
    if (!relevant.length) {
      list.innerHTML = '<p class="muted">Aucun lien' + (range ? " sur cette période." : ".") + "</p>";
      return;
    }
    relevant.forEach(([lid, l]) => {
      const other = l.a.kind === kind && l.a.id === id ? l.b : l.a;
      const otherLabel = other.label || deps.entityLabel(other.kind, other.id);
      const row = document.createElement("div");
      row.className = "link-row link-" + (l.category || "autre");
      const dates = l.dateStart ? ' <span class="muted">(' + l.dateStart + "–" + (l.dateEnd || "présent") + ")</span>" : "";
      row.innerHTML = '<span class="link-cat-dot"></span><strong></strong>';
      row.querySelector("strong")!.textContent = otherLabel;
      if (dates) row.insertAdjacentHTML("beforeend", dates);
      row.addEventListener("click", () => openLinkEditor({ id: lid, ...l }));
      list.appendChild(row);
    });
  }

  function renderFicheLinksWidget(container: HTMLElement, kind: LinkEntityKind, id: string, label: string) {
    currentEntity = { kind, id };
    container.innerHTML = "";
    const section = document.createElement("div");
    section.className = "links-section";

    const header = document.createElement("div");
    header.className = "fiche-links-header";
    const title = document.createElement("span");
    title.textContent = "Liens";
    const newBtn = document.createElement("button");
    newBtn.type = "button";
    newBtn.className = "btn-small edit-control";
    newBtn.textContent = "+ Nouveau lien";
    newBtn.addEventListener("click", () => enterLinkModeFor(kind, id, label));
    header.appendChild(title);
    header.appendChild(newBtn);
    section.appendChild(header);

    if (kind === "country") {
      const visLabel = document.createElement("label");
      visLabel.className = "fiche-links-visibility";
      const cb = document.createElement("input");
      cb.type = "checkbox";
      cb.checked = !isCountryLinksHidden(id);
      cb.addEventListener("change", () => setCountryLinksHidden(id, !cb.checked));
      visLabel.appendChild(cb);
      visLabel.appendChild(document.createTextNode("Afficher les liens de ce pays sur la carte"));
      section.appendChild(visLabel);
    }

    const timelineWrap = document.createElement("div");
    timelineWrap.className = "fiche-timeline";
    timelineWrap.innerHTML = '<div class="timeline-top"><span>Filtrer par période</span></div>' + timelineMarkup();
    section.appendChild(timelineWrap);

    const list = document.createElement("div");
    list.className = "fiche-links-list";
    section.appendChild(list);

    container.appendChild(section);

    const [ymin, ymax] = computeLinkYearRange();
    const slider = initRangeSliderIn(
      timelineWrap,
      rafThrottle((s, e) => {
        currentEntityRange = [s, e];
        renderFicheLinksList(list, kind, id, currentEntityRange);
        if (!allLinksMode) renderLinksForEntity(kind, id, currentEntityRange);
      })
    );
    slider.setBounds(ymin, ymax, false);
    currentEntityRange = slider.getRange();
    renderFicheLinksList(list, kind, id, currentEntityRange);
    if (!allLinksMode) renderLinksForEntity(kind, id, currentEntityRange);
  }

  // Appelé quand la fiche pays / l'éditeur de groupe qui affichait ces
  // liens se referme — efface le tracé (sauf en mode "Tous les liens").
  function clearEntityLinks() {
    currentEntity = null;
    currentEntityRange = null;
    if (!allLinksMode) deps.gLinksLayer.selectAll("*").remove();
  }

  function refreshLinkDisplays() {
    if (currentEntity) {
      // Les widgets se re-rendent eux-mêmes via leur prochain appel
      // (ouverture de fiche/éditeur) ; ici on ne redessine que la carte.
      if (!allLinksMode) renderLinksForEntity(currentEntity.kind, currentEntity.id, currentEntityRange);
    }
    if (allLinksMode) renderAllLinks(allLinksRange);
  }

  // -------------------------------------------------------------------
  // Mode création de lien — porté de linkModeActive/linkPending/
  // resolveEntitySelection (~8417-8441, 8960-8971, 9315-9331).
  // -------------------------------------------------------------------
  let linkModeActive = false;
  let linkPending: LinkEntityRef | null = null;

  function exitLinkMode() {
    linkModeActive = false;
    linkPending = null;
    deps.setMapCursor?.(false);
    deps.hideBanner();
  }
  function enterLinkModeFor(kind: LinkEntityKind, id: string, label: string) {
    deps.onBeforeLinkMode?.();
    linkModeActive = true;
    linkPending = { kind, id, label };
    deps.setMapCursor?.(true);
    deps.showBanner(
      "Cliquez sur le second élément (pays ou groupe) pour créer le lien avec « " + label + " »… (Échap pour annuler)"
    );
  }
  // Résout un clic sur un élément "liable" pendant le mode création —
  // porté de resolveEntitySelection() (~8425-8438). Renvoie true si le
  // clic a été consommé (fiche/dossier de la cible NE doit PAS s'ouvrir).
  function resolveLinkClick(kind: LinkEntityKind, id: string, label: string): boolean {
    if (!linkModeActive) return false;
    if (!linkPending) {
      linkPending = { kind, id, label };
      deps.showBanner(
        "Cliquez sur le second élément (pays ou groupe) pour créer le lien avec « " + label + " »… (Échap pour annuler)"
      );
      return true;
    }
    if (linkPending.kind === kind && linkPending.id === id) return true;
    const a = linkPending;
    exitLinkMode();
    openLinkEditor({ a, b: { kind, id, label } });
    return true;
  }
  function handleMapCountryClick(isoA3: string): boolean {
    return resolveLinkClick("country", isoA3, deps.entityLabel("country", isoA3));
  }
  function handleGroupClick(groupId: string, label: string): boolean {
    return resolveLinkClick("group", groupId, label);
  }

  document.addEventListener("keydown", (e) => {
    if (e.key !== "Escape") return;
    if (linkModeActive) exitLinkMode();
    closeLinkEditor();
  });

  // -------------------------------------------------------------------
  // Éditeur de lien — porté de openLinkEditor/saveCurrentLinkImpl/
  // scheduleLinkSave/flushLinkSave/closeLinkEditor (~9684-9805) et de la
  // suppression (~9899-9922).
  // -------------------------------------------------------------------
  const linkEditor = $("link-editor");
  let editingLinkId: string | null = null;
  let pendingLinkA: LinkEntityRef | null = null;
  let pendingLinkB: LinkEntityRef | null = null;

  function newLinkId(): string {
    try {
      return crypto.randomUUID();
    } catch {
      return "local-" + Date.now().toString(36) + "-" + Math.random().toString(36).slice(2, 8);
    }
  }

  let linkOpChain: Promise<void> = Promise.resolve();

  async function saveCurrentLinkImpl() {
    if (!pendingLinkA || !pendingLinkB || !editingLinkId) return;
    const id = editingLinkId;
    const data: LinkDoc = {
      a: { kind: pendingLinkA.kind, id: pendingLinkA.id, label: deps.entityLabel(pendingLinkA.kind, pendingLinkA.id) },
      b: { kind: pendingLinkB.kind, id: pendingLinkB.id, label: deps.entityLabel(pendingLinkB.kind, pendingLinkB.id) },
      category: ($("link-category") as HTMLSelectElement).value,
      description: ($("link-description") as HTMLTextAreaElement).value.trim(),
      dateStart: ($("link-date-start") as HTMLInputElement).value.trim(),
      dateEnd: ($("link-date-end") as HTMLInputElement).value.trim(),
      createdAt: linkDocs.get(id)?.createdAt || new Date().toISOString(),
    };
    linkDocs.set(id, data);
    refreshLinkDisplays();
    const status = $("link-save-status");
    const session = deps.getSession();
    if (!session) {
      status.textContent = "Connectez-vous pour enregistrer.";
      return;
    }
    if (!isAdmin()) {
      status.textContent = "Tu n'as pas les droits d'édition sur cet atlas.";
      return;
    }
    status.textContent = "Enregistrement…";
    try {
      await supabase.from("country_links").upsert({
        id,
        entity_a_kind: data.a.kind,
        entity_a_id: data.a.id,
        entity_a_label: data.a.label,
        entity_b_kind: data.b.kind,
        entity_b_id: data.b.id,
        entity_b_label: data.b.label,
        category: data.category,
        description: data.description,
        start_date: data.dateStart || null,
        end_date: data.dateEnd || null,
        created_by: linkOwners.get(id) || session.user.id,
      });
      linkOwners.set(id, linkOwners.get(id) || session.user.id);
      status.textContent = "Enregistré ✓";
      setTimeout(() => {
        if (status.textContent === "Enregistré ✓") status.textContent = "";
      }, 2500);
    } catch {
      status.textContent = "Erreur d’enregistrement.";
    }
  }
  function queueLinkSave(): Promise<void> {
    linkOpChain = linkOpChain.catch(() => {}).then(saveCurrentLinkImpl);
    return linkOpChain;
  }
  let linkSaveTimer: number | null = null;
  function scheduleLinkSave() {
    if (linkSaveTimer) window.clearTimeout(linkSaveTimer);
    linkSaveTimer = window.setTimeout(() => {
      linkSaveTimer = null;
      queueLinkSave();
    }, 400);
  }
  function flushLinkSave(): Promise<void> {
    if (linkSaveTimer) {
      window.clearTimeout(linkSaveTimer);
      linkSaveTimer = null;
      return queueLinkSave();
    }
    return linkOpChain;
  }
  ["link-description", "link-date-start", "link-date-end"].forEach((id) => $(id).addEventListener("input", scheduleLinkSave));
  $("link-category").addEventListener("change", scheduleLinkSave);

  function openLinkEditor(opts: { id?: string } & Partial<LinkDoc> & { a: LinkEntityRef; b: LinkEntityRef }) {
    linkOpChain = Promise.resolve();
    const isNew = !opts.id;
    editingLinkId = opts.id || newLinkId();
    pendingLinkA = opts.a;
    pendingLinkB = opts.b;
    const aLabel = opts.a.label || deps.entityLabel(opts.a.kind, opts.a.id);
    const bLabel = opts.b.label || deps.entityLabel(opts.b.kind, opts.b.id);
    $("link-editor-title").textContent = aLabel + " ↔ " + bLabel;
    ($("link-category") as HTMLSelectElement).value = opts.category || "diplomatie";
    ($("link-description") as HTMLTextAreaElement).value = opts.description || "";
    ($("link-date-start") as HTMLInputElement).value = opts.dateStart || "";
    ($("link-date-end") as HTMLInputElement).value = opts.dateEnd || "";
    $("link-save-status").textContent = "";
    $("link-delete").style.display = "inline-block";
    ["groups-panel", "indicators-panel", "appearance-panel"].forEach((pid) =>
      document.getElementById(pid)?.classList.remove("open")
    );
    linkEditor.classList.add("open");
    if (isNew) queueLinkSave();
  }
  function closeLinkEditor() {
    if (!linkEditor.classList.contains("open")) return;
    linkEditor.classList.remove("open");
    flushLinkSave().finally(() => {
      editingLinkId = null;
      pendingLinkA = null;
      pendingLinkB = null;
    });
  }
  $("link-editor-close").addEventListener("click", closeLinkEditor);
  $("link-delete").addEventListener("click", async () => {
    if (!editingLinkId) return;
    // eslint-disable-next-line no-alert
    if (!window.confirm("Supprimer ce lien ?")) return;
    if (linkSaveTimer) {
      window.clearTimeout(linkSaveTimer);
      linkSaveTimer = null;
    }
    const id = editingLinkId;
    linkDocs.delete(id);
    closeLinkEditor();
    refreshLinkDisplays();
    linkOpChain = linkOpChain
      .catch(() => {})
      .then(() => supabase.from("country_links").delete().eq("id", id))
      .then(() => undefined)
      .catch(() => {
        /* best-effort : le lien reste supprimé côté client */
      });
  });

  // -------------------------------------------------------------------
  // Panneau "Tous les liens" / frise chronologique du bas — porté de
  // #toggle-all-links / #timeline-bar (~1554-1567) et globalSlider
  // (~9620-9661).
  // -------------------------------------------------------------------
  const timelineBar = $("timeline-bar");
  const globalSlider = initRangeSliderIn(
    timelineBar,
    rafThrottle((s, e) => {
      allLinksRange = [s, e];
      if (allLinksMode) renderAllLinks(allLinksRange);
    })
  );
  $("toggle-all-links").addEventListener("change", (e) => {
    allLinksMode = (e.target as HTMLInputElement).checked;
    if (allLinksMode) {
      const [ymin, ymax] = computeLinkYearRange();
      globalSlider.setBounds(ymin, ymax, false);
      allLinksRange = globalSlider.getRange();
      timelineBar.classList.add("open");
      renderAllLinks(allLinksRange);
    } else {
      timelineBar.classList.remove("open");
      if (currentEntity) renderLinksForEntity(currentEntity.kind, currentEntity.id, currentEntityRange);
      else deps.gLinksLayer.selectAll("*").remove();
    }
  });

  // -------------------------------------------------------------------
  // Bootstrap
  // -------------------------------------------------------------------
  const ready = Promise.all([loadLinks(), loadLinksHidden()]).then(() => {});

  return {
    ready,
    renderFicheLinksWidget,
    clearEntityLinks,
    handleMapCountryClick,
    handleGroupClick,
    isLinkModeActive: () => linkModeActive,
    exitLinkMode,
    redraw,
  };
}
