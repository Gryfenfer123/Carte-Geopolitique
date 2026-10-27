// Outil de croquis — le calque de dessin posé sur la carte Leaflet.
//
// Un élément SVG couvre la carte ; à chaque déplacement ou zoom, on recalcule les positions en
// pixels à partir des coordonnées en mètres Web Mercator (voir sketchGeometry.ts) : le dessin
// reste donc exactement accroché à la géographie. Pendant l'animation de zoom de Leaflet, on
// reproduit la même mise à l'échelle autour du même point pour que le dessin ne « saute » pas.

import type L from "leaflet";
import { makeView, lngLatToMerc, mercToPx, type View } from "./sketchGeometry";
import type { SketchDoc } from "./sketchModel";
import { docInnerSvg } from "./sketchSvg";

const SVG_NS = "http://www.w3.org/2000/svg";

export type OverlayDrawer = (v: View) => string;

export type SketchView = {
  svg: SVGSVGElement;
  /** Zone qui reçoit les clics quand un outil de dessin est actif. */
  captureRect: SVGRectElement;
  getView(): View;
  requestRender(): void;
  /** Croquis affichés en lecture seule. */
  setViewDocs(docs: SketchDoc[]): void;
  /** Croquis en cours de modification (dessiné par-dessus les autres). */
  setEditingDoc(doc: SketchDoc | null): void;
  /** Dessins temporaires de l'éditeur (cadre de sélection, poignées, aperçus). */
  setOverlay(fn: OverlayDrawer | null): void;
  /** Mode édition : la zone de capture reçoit les clics. */
  setInteractive(on: boolean): void;
  /** Laisse passer les clics vers la carte (touche Espace, outil Main). */
  setPassThrough(on: boolean): void;
  setCursor(css: string): void;
  destroy(): void;
};

function easeOut(t: number): number {
  // Approximation de cubic-bezier(0, 0, 0.25, 1) utilisée par Leaflet pour son animation de zoom.
  const u = 1 - t;
  return 1 - u * u * u;
}

export function createSketchView(map: L.Map): SketchView {
  const host = map.getContainer();
  const svg = document.createElementNS(SVG_NS, "svg");
  svg.classList.add("sk-svg");
  const captureRect = document.createElementNS(SVG_NS, "rect");
  captureRect.classList.add("sk-capture");
  captureRect.setAttribute("x", "0");
  captureRect.setAttribute("y", "0");
  captureRect.setAttribute("width", "100%");
  captureRect.setAttribute("height", "100%");
  const gDocs = document.createElementNS(SVG_NS, "g");
  const gOver = document.createElementNS(SVG_NS, "g");
  svg.append(captureRect, gDocs, gOver);
  host.appendChild(svg);

  let viewDocs: SketchDoc[] = [];
  let editing: SketchDoc | null = null;
  let overlay: OverlayDrawer | null = null;
  let frame = 0;
  let anim: { t0: number; dur: number; scale: number; ox: number; oy: number; guard: number } | null = null;

  function getView(): View {
    const c = map.getCenter();
    const s = map.getSize();
    return makeView(c.lng, c.lat, map.getZoom(), s.x, s.y);
  }

  function render() {
    frame = 0;
    if (anim) return;
    const v = getView();
    const mapper = (p: { x: number; y: number }) => mercToPx(v, p);
    let html = "";
    for (const d of viewDocs) html += docInnerSvg(d, mapper, v.k);
    if (editing) html += docInnerSvg(editing, mapper, v.k);
    gDocs.innerHTML = html;
    gOver.innerHTML = overlay ? overlay(v) : "";
  }

  function requestRender() {
    if (!frame) frame = requestAnimationFrame(render);
  }

  function setTransform(tr: string | null) {
    for (const g of [gDocs, gOver]) {
      if (tr) g.setAttribute("transform", tr);
      else g.removeAttribute("transform");
    }
  }

  function tickAnim() {
    if (!anim) return;
    const t = Math.min(1, (performance.now() - anim.t0) / anim.dur);
    const s = 1 + (anim.scale - 1) * easeOut(t);
    setTransform(`translate(${anim.ox} ${anim.oy}) scale(${s}) translate(${-anim.ox} ${-anim.oy})`);
    if (t < 1) requestAnimationFrame(tickAnim);
  }

  function endAnim() {
    if (!anim) return;
    window.clearTimeout(anim.guard);
    anim = null;
    setTransform(null);
    render();
  }

  // Leaflet annonce l'animation de zoom (point d'ancrage et zoom visé) : on la rejoue.
  function onZoomAnim(e: L.ZoomAnimEvent) {
    const v0 = getView();
    const scale = Math.pow(2, e.zoom - map.getZoom());
    if (Math.abs(scale - 1) < 1e-6) return;
    const tc = lngLatToMerc(e.center.lng, e.center.lat);
    const offX = (tc.x - v0.cx) * v0.k;
    const offY = -(tc.y - v0.cy) * v0.k;
    const f = 1 - 1 / scale;
    anim = {
      t0: performance.now(),
      dur: 250,
      scale,
      ox: v0.w / 2 + offX / f,
      oy: v0.h / 2 + offY / f,
      guard: window.setTimeout(endAnim, 600),
    };
    tickAnim();
  }

  const onMove = () => requestRender();
  map.on("move zoom viewreset resize moveend", onMove);
  map.on("zoomanim", onZoomAnim);
  map.on("zoomend", endAnim);

  return {
    svg,
    captureRect,
    getView,
    requestRender,
    setViewDocs(docs) {
      viewDocs = docs;
      requestRender();
    },
    setEditingDoc(doc) {
      editing = doc;
      requestRender();
    },
    setOverlay(fn) {
      overlay = fn;
      requestRender();
    },
    setInteractive(on) {
      svg.classList.toggle("sk-active", on);
    },
    setPassThrough(on) {
      svg.classList.toggle("sk-pass", on);
    },
    setCursor(css) {
      captureRect.style.cursor = css;
    },
    destroy() {
      map.off("move zoom viewreset resize moveend", onMove);
      map.off("zoomanim", onZoomAnim);
      map.off("zoomend", endAnim);
      svg.remove();
    },
  };
}
