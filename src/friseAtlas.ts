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

export function buildAtlas(o: AtlasOptions): HTMLElement {
  const k = o.k;
  const root = el("div", "tl-atlas-body");
  root.style.width = o.total + "px";
  root.style.height = o.height + "px";

  o.band.classList.add("tl-atlas-band");
  root.appendChild(o.band);
  const rulerBox = el("div", "tl-atlas-ruler");
  rulerBox.style.height = o.rulerH + "px";
  rulerBox.appendChild(o.ruler);
  root.appendChild(rulerBox);

  const bandH = o.band.offsetHeight || 46 * k;
  void bandH;
  const lanes = el("div", "tl-atlas-lanes");
  root.appendChild(lanes);

  const anyPhoto = o.items.some((i) => i.photo);
  const cardW = Math.round(184 * k);
  const cardH = Math.round((anyPhoto ? 132 : 64) * k);
  const gap = Math.round(10 * k);
  const bandHeight = Math.round(48 * k);
  const areaH = Math.max(0, o.height - bandHeight - o.rulerH - o.reservedBottom - 16);
  const maxLanes = Math.max(1, Math.floor((areaH + gap) / (cardH + gap)));

  const sorted = [...o.items].sort((a, b) => a.x - b.x);
  const laneOf = assignCardLanes(sorted.map((i) => i.x), cardW, maxLanes);

  sorted.forEach((it, idx) => {
    const lane = laneOf[idx];
    // Durée : trait sur la ligne de départ des cartes.
    if (it.x2 - it.x > 3) {
      const bar = el("span", "tl-abar");
      bar.style.left = it.x + "px";
      bar.style.width = it.x2 - it.x + "px";
      bar.style.background = it.color;
      lanes.appendChild(bar);
    }
    const top = lane < 0 ? 0 : 14 * k + lane * (cardH + gap);
    if (lane >= 0) {
      const line = el("span", "tl-aline");
      line.style.left = it.x + "px";
      line.style.height = top + cardH / 2 + "px";
      line.style.background = it.color;
      lanes.appendChild(line);
    }
    const dot = el("button", "tl-dot tl-adot");
    dot.type = "button";
    dot.style.left = it.x + "px";
    dot.style.background = it.color;
    dot.setAttribute("aria-label", it.title);
    lanes.appendChild(dot);

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
      lanes.appendChild(card);
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
