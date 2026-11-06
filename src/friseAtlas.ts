// ---------------------------------------------------------------------------
// Frises — « Vue Atlas » (inspirée des frises illustrées : bandeau des époques en
// haut, règle des dates, puis des cartes illustrées sous la règle, un sommaire à gauche).
// Construit uniquement du DOM à partir de données déjà calculées par frise.ts.
// ---------------------------------------------------------------------------

import "./friseAtlas.css";

export type AtlasItem = {
  id: string;
  title: string;
  dateText: string;
  color: string;
  x: number;
  x2: number;
  photo: string | null;
  hasSub: boolean;
};

export type AtlasOptions = {
  total: number; // largeur de la frise (px)
  height: number; // hauteur disponible (px)
  k: number; // échelle relative (1 = taille de base)
  band: HTMLElement; // bandeau des époques (buildBand)
  ruler: HTMLElement; // règle graduée (buildRuler)
  rulerH: number;
  items: AtlasItem[];
  onOpen: (id: string, el: HTMLElement) => void;
  onHover: (id: string, el: HTMLElement) => void;
  onLeave: () => void;
  register: (id: string, el: HTMLElement) => void;
  onZoomAt: (el: HTMLElement) => void; // zoom centré sur un groupe d'événements trop serrés
  reservedBottom: number; // place laissée en bas (mini-carte)
};

function el<K extends keyof HTMLElementTagNameMap>(tag: K, className?: string): HTMLElementTagNameMap[K] {
  const e = document.createElement(tag);
  if (className) e.className = className;
  return e;
}

/** Rangs d'affectation « premier rang libre » ; au-delà de maxLanes : -1 (simple pastille). */
export function assignCardLanes(xs: number[], width: number, maxLanes: number, gap = 8): number[] {
  const lastRight: number[] = [];
  return xs.map((x) => {
    let lane = 0;
    while (lane < lastRight.length && lastRight[lane] > x - gap) lane++;
    if (lane >= maxLanes) return -1;
    lastRight[lane] = x + width;
    return lane;
  });
}

function openClusterList(box: HTMLElement, badge: HTMLElement, items: AtlasItem[], o: AtlasOptions) {
  box.querySelectorAll(".tl-acluster-pop").forEach((n) => n.remove());
  const pop = el("div", "tl-acluster-pop");
  pop.style.left = badge.style.left;
  const head = el("div", "tl-acluster-head");
  head.textContent = items.length + " événements très proches";
  pop.appendChild(head);
  for (const it of items) {
    const b = el("button", "tl-acluster-item");
    b.type = "button";
    const d = el("span", "tl-acluster-date");
    d.textContent = it.dateText;
    const t = el("span");
    t.textContent = it.title;
    b.append(d, t);
    b.addEventListener("click", (ev) => {
      ev.stopPropagation();
      pop.remove();
      o.onOpen(it.id, badge);
    });
    pop.appendChild(b);
  }
  const zoom = el("button", "tl-acluster-zoom");
  zoom.type = "button";
  zoom.textContent = "Zoomer ici";
  zoom.addEventListener("click", (ev) => {
    ev.stopPropagation();
    pop.remove();
    o.onZoomAt(badge);
  });
  pop.appendChild(zoom);
  pop.addEventListener("click", (ev) => ev.stopPropagation());
  box.appendChild(pop);
  const close = () => {
    pop.remove();
    document.removeEventListener("click", close);
  };
  setTimeout(() => document.addEventListener("click", close), 0);
}

export function buildAtlas(o: AtlasOptions): HTMLElement {
  const k = o.k;
  const root = el("div", "tl-atlas-body");
  root.style.width = o.total + "px";
  root.style.height = o.height + "px";

  // Hauteurs fixes : zone du haut (cartes au-dessus), bandeau des époques, règle, zone du bas.
  // Ainsi la frise reste au centre de l'écran, avec des événements des deux côtés.
  const bandH = Math.round(76 * k);
  const sideH = Math.max(0, Math.floor((o.height - bandH - o.rulerH - o.reservedBottom) / 2));
  const lineY = sideH + bandH + o.rulerH; // ligne des dates, en haut du bas ; repère de la zone du haut

  const upBox = el("div", "tl-atlas-up");
  upBox.style.height = sideH + "px";
  root.appendChild(upBox);
  o.band.classList.add("tl-atlas-band");
  o.band.style.height = bandH + "px";
  root.appendChild(o.band);
  const rulerBox = el("div", "tl-atlas-ruler");
  rulerBox.style.height = o.rulerH + "px";
  rulerBox.appendChild(o.ruler);
  root.appendChild(rulerBox);
  const lanes = el("div", "tl-atlas-lanes");
  lanes.style.height = sideH + "px";
  root.appendChild(lanes);

  const anyPhoto = o.items.some((i) => i.photo);
  const cardW = Math.round(158 * k);
  const cardH = Math.round((anyPhoto ? 112 : 54) * k);
  const gap = Math.round(8 * k);
  const margin = Math.round(12 * k);
  const maxLanes = Math.max(1, Math.floor((sideH - margin + gap) / (cardH + gap)));

  // Les événements alternent au-dessus / en dessous de la règle : deux fois plus de place.
  const sorted = [...o.items].sort((a, b) => a.x - b.x);
  const upItems = sorted.filter((_, i) => i % 2 === 1);
  const downItems = sorted.filter((_, i) => i % 2 === 0);
  const laneUp = assignCardLanes(upItems.map((i) => i.x), cardW, maxLanes);
  const laneDown = assignCardLanes(downItems.map((i) => i.x), cardW, maxLanes);
  const place: { it: AtlasItem; up: boolean; lane: number }[] = [
    ...upItems.map((it, i) => ({ it, up: true, lane: laneUp[i] })),
    ...downItems.map((it, i) => ({ it, up: false, lane: laneDown[i] })),
  ];

  // Événements sans place pour une carte : on les REGROUPE en pastilles « N » (comme les cartes en ligne),
  // au lieu de les laisser se superposer. Un clic liste tous les événements du groupe.
  const overflow = place.filter((q) => q.lane < 0).sort((a, b) => a.it.x - b.it.x);
  const groups: AtlasItem[][] = [];
  for (const q of overflow) {
    const g = groups[groups.length - 1];
    if (g && q.it.x - g[g.length - 1].x < 24 * k) g.push(q.it);
    else groups.push([q.it]);
  }
  const grouped = new Set<string>();
  groups.filter((g) => g.length > 1).forEach((g) => {
    g.forEach((i) => grouped.add(i.id));
    const cx = (g[0].x + g[g.length - 1].x) / 2;
    const badge = el("button", "tl-acluster");
    badge.type = "button";
    badge.style.left = cx + "px";
    badge.textContent = String(g.length);
    badge.title = g.map((i) => i.dateText + " · " + i.title).join("\n");
    badge.addEventListener("click", (ev) => {
      ev.stopPropagation();
      openClusterList(lanes, badge, g, o);
    });
    lanes.appendChild(badge);
  });

  place.forEach(({ it, up, lane }) => {
    if (grouped.has(it.id)) return; // représenté par sa pastille de groupe
    // Durée : trait sur la ligne des dates.
    if (it.x2 - it.x > 3) {
      const bar = el("span", "tl-abar");
      bar.style.left = it.x + "px";
      bar.style.width = it.x2 - it.x + "px";
      bar.style.background = it.color;
      lanes.appendChild(bar);
    }
    const box = up ? upBox : lanes;
    // Zone du bas : y compté depuis la ligne. Zone du haut : y compté depuis le haut de la zone.
    const top = up ? sideH - margin - (lane + 1) * cardH - lane * gap : margin + lane * (cardH + gap);
    if (lane >= 0) {
      const line = el("span", "tl-aline");
      line.style.left = it.x + "px";
      if (up) {
        line.style.top = top + cardH / 2 + "px";
        line.style.height = lineY - (top + cardH / 2) + "px";
      } else {
        line.style.top = "0px";
        line.style.height = top + cardH / 2 + "px";
      }
      line.style.background = it.color;
      box.appendChild(line);
    }
    const dot = el("button", "tl-dot tl-adot");
    dot.type = "button";
    dot.style.left = it.x + "px";
    dot.style.top = up ? lineY + "px" : "0px";
    dot.style.background = it.color;
    dot.setAttribute("aria-label", it.title);
    box.appendChild(dot);

    let target: HTMLElement = dot;
    if (lane >= 0) {
      const card = el("button", "tl-acard" + (it.hasSub ? " has-sub" : ""));
      card.type = "button";
      card.style.left = it.x + "px";
      card.style.top = top + "px";
      card.style.width = cardW + "px";
      card.style.height = cardH + "px";
      card.style.borderLeftColor = it.color;
      if (anyPhoto) {
        if (it.photo) {
          const img = el("img", "tl-acard-img");
          img.src = it.photo;
          img.alt = "";
          img.loading = "lazy";
          img.draggable = false;
          card.appendChild(img);
        } else {
          const ph = el("span", "tl-acard-img tl-acard-ph");
          ph.style.background = `linear-gradient(135deg, ${it.color}55, ${it.color}15)`;
          card.appendChild(ph);
        }
      }
      const d = el("span", "tl-acard-date");
      d.textContent = it.dateText;
      const t = el("span", "tl-acard-title");
      t.textContent = it.title + (it.hasSub ? "  ›" : "");
      card.append(d, t);
      box.appendChild(card);
      target = card;
      card.addEventListener("click", (ev) => {
        ev.stopPropagation();
        o.onOpen(it.id, card);
      });
      card.addEventListener("mouseenter", () => o.onHover(it.id, card));
      card.addEventListener("mouseleave", o.onLeave);
    }
    dot.addEventListener("click", (ev) => {
      ev.stopPropagation();
      o.onOpen(it.id, target);
    });
    dot.addEventListener("mouseenter", () => o.onHover(it.id, dot));
    dot.addEventListener("mouseleave", o.onLeave);
    o.register(it.id, target);
  });
  return root;
}

export type SideEntry = { name: string; color: string | null; dates: string; onClick: () => void };

/** Barre latérale : titre, sous-titre, sommaire des périodes. */
export function buildSidebar(side: HTMLElement, o: { title: string; subtitle: string; count: number; entries: SideEntry[] }) {
  side.innerHTML = "";
  const h = el("h2", "tl-side-title");
  h.textContent = o.title;
  h.hidden = !o.title; // le titre est déjà dans la barre du haut : une seule fois
  const sub = el("div", "tl-side-sub");
  sub.textContent = o.subtitle;
  const rule = el("div", "tl-side-rule");
  const help = el("p", "tl-side-help");
  help.textContent = "Au fil de la frise, clique sur un événement pour accéder à plus d'informations.";
  const count = el("div", "tl-side-count");
  count.textContent = o.count + (o.count > 1 ? " événements" : " événement");
  const nav = el("nav", "tl-side-nav");
  nav.setAttribute("aria-label", "Sommaire");
  for (const e of o.entries) {
    const b = el("button", "tl-side-item");
    b.type = "button";
    const dot = el("span", "tl-side-dot");
    if (e.color) dot.style.background = e.color;
    const name = el("span", "tl-side-name");
    name.textContent = e.name;
    const d = el("span", "tl-side-dates");
    d.textContent = e.dates;
    b.append(dot, name, d);
    b.addEventListener("click", e.onClick);
    nav.appendChild(b);
  }
  side.append(h, sub, rule, help, count, nav);
}
