// ---------------------------------------------------------------------------
// Frises — vue « pro » : couloirs par catégorie (comme les outils de gestion de
// projet / d'histoire), cartes lisibles, en-tête collant (périodes + dates) et
// colonne de couloirs collante. Ce module ne fait que construire le DOM à partir
// de données déjà calculées par frise.ts ; il n'accède pas à la base.
// ---------------------------------------------------------------------------

import "./friseProView.css";
import { packLane, type PackItem } from "./friseProLayout";

export type ProEvent = {
  id: string;
  title: string;
  x: number;
  x2: number; // = x pour un point sans durée
  dateText: string;
  photo: string | null;
  priority: number;
};
export type ProLane = { key: string; name: string; color: string; events: ProEvent[]; hidden: boolean; total: number };
export type ProArgs = {
  lanes: ProLane[];
  trackW: number;
  gutterW: number;
  cap: number;
  rowPx: number;
  textWidth: (s: string) => number;
  onSelect: (id: string, el: HTMLElement) => void;
  onHover: (id: string, el: HTMLElement) => void;
  onLeave: () => void;
  onToggleLane: (key: string) => void;
  reigns: HTMLElement | null;
};
export type ProLanes = { el: HTMLElement; cards: Map<string, HTMLElement>; setGuide: (x: number | null) => void };

export function buildProLanes(a: ProArgs): ProLanes {
  const root = document.createElement("div");
  root.className = "tl-pro-lanes";
  const cards = new Map<string, HTMLElement>();
  const cardH = a.rowPx - 12;

  const gutter = (lane: { name: string; color: string; count: number; hidden: boolean; key?: string }): HTMLElement => {
    const g = document.createElement("div");
    g.className = "tl-pro-gutter";
    g.style.setProperty("--c", lane.color);
    g.style.width = a.gutterW + "px";
    const name = document.createElement("span");
    name.className = "tl-pro-lane-name";
    name.textContent = lane.name;
    const n = document.createElement("span");
    n.className = "tl-pro-lane-count";
    n.textContent = String(lane.count);
    g.append(name, n);
    if (lane.key) {
      const key = lane.key;
      g.title = lane.hidden ? "Afficher « " + lane.name + " »" : "Masquer « " + lane.name + " »";
      g.addEventListener("click", () => a.onToggleLane(key));
      g.classList.add("clickable");
    }
    if (lane.hidden) g.classList.add("off");
    return g;
  };

  if (a.reigns) {
    const row = document.createElement("div");
    row.className = "tl-pro-row tl-pro-reignrow";
    row.appendChild(gutter({ name: "Règnes", color: "var(--accent)", count: 0, hidden: false }));
    (row.querySelector(".tl-pro-lane-count") as HTMLElement).remove();
    const track = document.createElement("div");
    track.className = "tl-pro-track";
    track.style.width = a.trackW + "px";
    track.style.height = a.reigns.style.height || "34px";
    track.appendChild(a.reigns);
    row.appendChild(track);
    root.appendChild(row);
  }

  for (const lane of a.lanes) {
    const row = document.createElement("div");
    row.className = "tl-pro-row" + (lane.hidden ? " off" : "");
    row.appendChild(gutter({ name: lane.name, color: lane.color, count: lane.total, hidden: lane.hidden, key: lane.key }));
    const track = document.createElement("div");
    track.className = "tl-pro-track";
    track.style.width = a.trackW + "px";
    row.appendChild(track);
    root.appendChild(row);
    if (lane.hidden) {
      track.style.height = "34px";
      continue;
    }
    const sized = lane.events.map((e) => {
      const w = Math.min(Math.max(a.textWidth(e.title) + 30, 118), 252);
      return { e, w, span: Math.max(w, e.x2 - e.x) };
    });
    const items: PackItem[] = sized.map((s) => ({ id: s.e.id, x: s.e.x, w: s.span, priority: s.e.priority }));
    const packed = packLane(items, a.cap);
    const rows = Math.max(1, packed.rows);
    const dotsH = packed.dots.length ? 24 : 0;
    track.style.height = rows * a.rowPx + dotsH + 10 + "px";
    const byId = new Map(sized.map((s) => [s.e.id, s]));
    for (const [id, r] of packed.row) {
      const s = byId.get(id)!;
      const e = s.e;
      const top = 8 + r * a.rowPx;
      if (e.x2 - e.x > 6) {
        const bar = document.createElement("span");
        bar.className = "tl-card-span";
        bar.style.cssText = `left:${e.x}px;width:${e.x2 - e.x}px;top:${top + cardH + 2}px;background:${lane.color}`;
        track.appendChild(bar);
      }
      const card = document.createElement("button");
      card.type = "button";
      card.className = "tl-card";
      card.style.cssText = `left:${e.x}px;top:${top}px;width:${s.w}px;height:${cardH}px;--c:${lane.color}`;
      const d = document.createElement("span");
      d.className = "tl-card-d";
      d.textContent = e.dateText;
      const t = document.createElement("span");
      t.className = "tl-card-t";
      t.textContent = e.title;
      card.append(d, t);
      if (e.photo) {
        const img = document.createElement("img");
        img.src = e.photo;
        img.alt = "";
        img.loading = "lazy";
        card.appendChild(img);
        card.classList.add("has-photo");
      }
      card.title = e.title;
      card.addEventListener("click", (ev) => {
        ev.stopPropagation();
        a.onSelect(e.id, card);
      });
      card.addEventListener("mouseenter", () => a.onHover(e.id, card));
      card.addEventListener("mouseleave", a.onLeave);
      track.appendChild(card);
      cards.set(e.id, card);
    }
    for (const id of packed.dots) {
      const e = byId.get(id)!.e;
      const dot = document.createElement("button");
      dot.type = "button";
      dot.className = "tl-dotchip";
      dot.style.cssText = `left:${e.x - 6}px;top:${rows * a.rowPx + 14}px;background:${lane.color}`;
      dot.title = e.dateText + " — " + e.title;
      dot.addEventListener("click", (ev) => {
        ev.stopPropagation();
        a.onSelect(e.id, dot);
      });
      track.appendChild(dot);
      cards.set(id, dot);
    }
  }

  // Ligne repère verticale (survol / sélection).
  const guide = document.createElement("div");
  guide.className = "tl-guide";
  root.appendChild(guide);
  const setGuide = (x: number | null) => {
    if (x === null) guide.style.display = "none";
    else {
      guide.style.display = "block";
      guide.style.left = a.gutterW + x + "px";
    }
  };
  setGuide(null);
  return { el: root, cards, setGuide };
}
