// Tests de la logique pure de l'outil de croquis (sans navigateur).
// Lancement : bash scripts/croquis/lancer-tests.sh
import assert from "node:assert/strict";
import {
  DEFAULT_STYLE,
  addObjects,
  arrangeObjects,
  newDoc,
  parseDoc,
  removeObjects,
  setGroup,
  uid,
  type PathObject,
  type SketchNode,
  type TextObject,
} from "../../src/sketchModel";
import {
  IDENTITY,
  KAPPA,
  applyMat,
  arrowPolygon,
  bezierAt,
  cornerNode,
  dist,
  ellipseNodes,
  endTangent,
  fitSmooth,
  flatten,
  hitPath,
  lngLatToMerc,
  makeView,
  mercToLngLat,
  mercToPx,
  mulMat,
  nearestOnPath,
  pathBounds,
  pxToMerc,
  rectNodes,
  rotateM,
  scaleM,
  segPts,
  simplifyRdp,
  splitSegment,
  transformObject,
  translateM,
} from "../../src/sketchGeometry";
import { createHistory } from "../../src/sketchHistory";
import { alignObjects, flipObjects, selectionBounds } from "../../src/sketchOps";
import { docToSvg, objectSvg, pathD, strokePx } from "../../src/sketchSvg";

let passed = 0;
function test(name: string, fn: () => void) {
  try {
    fn();
    passed++;
    console.log("  ok  " + name);
  } catch (e) {
    console.error("  ÉCHEC  " + name);
    throw e;
  }
}
const near = (a: number, b: number, eps = 1e-6) => assert.ok(Math.abs(a - b) <= eps, `${a} ≉ ${b} (±${eps})`);

function path(nodes: SketchNode[], closed = false, layerId = "L"): PathObject {
  return { id: uid(), kind: "path", layerId, group: null, nodes, closed, style: { ...DEFAULT_STYLE } };
}
function text(x: number, y: number, layerId = "L"): TextObject {
  return {
    id: uid(), kind: "text", layerId, group: null, p: { x, y }, text: "Paris", fontSize: 18, fontFamily: "sans",
    bold: false, italic: false, color: "#fff", halo: null, anchor: "start", rotation: 0, opacity: 1,
  };
}

console.log("Projection");
test("Mercator : aller-retour longitude/latitude", () => {
  for (const [lng, lat] of [[0, 0], [2.35, 48.85], [-122.4, 37.8], [139.7, 35.7], [180, 60], [-170, -70]]) {
    const r = mercToLngLat(lngLatToMerc(lng, lat));
    near(r.lng, lng, 1e-9);
    near(r.lat, lat, 1e-9);
  }
});
test("Mercator : valeurs connues (Greenwich = 0,0 ; 180° = demi-circonférence)", () => {
  const o = lngLatToMerc(0, 0);
  near(o.x, 0);
  near(o.y, 0, 1e-6);
  near(lngLatToMerc(180, 0).x, 20037508.342789244, 1e-3);
});
test("Vue : mètres → pixels → mètres ; échelle = 256 × 2^zoom pixels pour le monde", () => {
  const v = makeView(10, 45, 5, 1200, 800);
  near(v.k * 2 * 20037508.342789244, 256 * 32, 1e-6);
  const p = lngLatToMerc(12, 47);
  const px = mercToPx(v, p);
  const back = pxToMerc(v, px.x, px.y);
  near(back.x, p.x, 1e-6);
  near(back.y, p.y, 1e-6);
  const c = mercToPx(v, lngLatToMerc(10, 45));
  near(c.x, 600, 1e-6);
  near(c.y, 400, 1e-6);
});

console.log("Courbes de Bézier");
test("Découpe d'un tronçon : la courbe passe par le même point, les deux moitiés se raccordent", () => {
  const nodes: SketchNode[] = [
    { p: { x: 0, y: 0 }, hin: null, hout: { x: 0, y: 100 }, smooth: false },
    { p: { x: 200, y: 0 }, hin: { x: 200, y: 100 }, hout: null, smooth: false },
  ];
  const [p0, p1, p2, p3] = segPts(nodes[0], nodes[1]);
  for (const t of [0.2, 0.5, 0.8]) {
    const out = splitSegment(nodes, false, 0, t);
    assert.equal(out.length, 3);
    const orig = bezierAt(p0, p1, p2, p3, t);
    assert.ok(dist(out[1].p, orig) < 1e-9);
    const [a0, a1, a2, a3] = segPts(out[0], out[1]);
    const [b0, b1, b2, b3] = segPts(out[1], out[2]);
    for (const s of [0, 0.25, 0.5, 0.75, 1]) {
      assert.ok(dist(bezierAt(a0, a1, a2, a3, s), bezierAt(p0, p1, p2, p3, s * t)) < 1e-9);
      assert.ok(dist(bezierAt(b0, b1, b2, b3, s), bezierAt(p0, p1, p2, p3, t + s * (1 - t))) < 1e-9);
    }
  }
});
test("Découpe d'un tronçon droit : nouveau nœud sans poignée au bon endroit", () => {
  const out = splitSegment([cornerNode({ x: 0, y: 0 }), cornerNode({ x: 10, y: 0 })], false, 0, 0.3);
  assert.equal(out.length, 3);
  near(out[1].p.x, 3);
  assert.equal(out[1].hin, null);
});
test("Découpe du tronçon de fermeture d'un tracé fermé : le nœud s'ajoute à la fin", () => {
  const sq = rectNodes({ x: 0, y: 0 }, { x: 10, y: 10 });
  const out = splitSegment(sq, true, 3, 0.5);
  assert.equal(out.length, 5);
  near(out[4].p.x, 0);
  near(out[4].p.y, 5);
});
test("Ellipse : 4 nœuds, cadre exact (écart < 0,03 % du rayon, tolérance connue du cercle en Bézier)", () => {
  const nodes = ellipseNodes({ x: -100, y: -50 }, { x: 100, y: 50 });
  assert.equal(nodes.length, 4);
  const b = pathBounds(nodes, true)!;
  near(b.maxX, 100, 0.03 * 100 / 100 * 1.0 + 0.05);
  near(b.minX, -100, 0.1);
  near(b.maxY, 50, 0.1);
  near(b.minY, -50, 0.1);
  near(KAPPA, 0.5522847498, 1e-9);
  // Chaque point de la courbe est (presque) sur l'ellipse.
  for (const p of flatten(nodes, true, 64)) {
    const e = (p.x / 100) ** 2 + (p.y / 50) ** 2;
    assert.ok(Math.abs(e - 1) < 0.003, `point hors ellipse : ${e}`);
  }
});
test("Cadre d'un rectangle et clic (trait et remplissage)", () => {
  const r = path(rectNodes({ x: 0, y: 0 }, { x: 100, y: 50 }), true);
  assert.deepEqual(pathBounds(r.nodes, true), { minX: 0, minY: 0, maxX: 100, maxY: 50 });
  assert.ok(hitPath(r, { x: 50, y: 25 }, 1, 1), "dans le remplissage");
  assert.ok(hitPath(r, { x: 101, y: 25 }, 2, 1), "sur le bord, avec tolérance");
  assert.ok(!hitPath(r, { x: 150, y: 25 }, 2, 1), "hors de la forme");
  const open = path([cornerNode({ x: 0, y: 0 }), cornerNode({ x: 100, y: 0 })], false);
  open.style = { ...open.style, fill: null };
  assert.ok(hitPath(open, { x: 50, y: 1 }, 2, 1));
  assert.ok(!hitPath(open, { x: 50, y: 30 }, 2, 1));
  const noFill = { ...r, style: { ...r.style, fill: null } };
  assert.ok(!hitPath(noFill, { x: 50, y: 25 }, 1, 1), "sans remplissage, l'intérieur n'est pas cliquable");
});
test("Point le plus proche sur le tracé", () => {
  const nodes = [cornerNode({ x: 0, y: 0 }), cornerNode({ x: 100, y: 0 })];
  const n = nearestOnPath(nodes, false, { x: 30, y: 10 })!;
  near(n.t, 0.3, 0.01);
  near(n.dist, 10, 1e-6);
});

console.log("Transformations");
test("Rotation de 90° autour d'un pivot", () => {
  const p = applyMat(rotateM(Math.PI / 2, { x: 10, y: 10 }), { x: 20, y: 10 });
  near(p.x, 10, 1e-9);
  near(p.y, 20, 1e-9);
});
test("Échelle autour d'un pivot, composition de matrices", () => {
  const p = applyMat(scaleM(2, 3, { x: 1, y: 1 }), { x: 2, y: 2 });
  near(p.x, 3);
  near(p.y, 4);
  const m = mulMat(translateM(5, 0), scaleM(2, 2, { x: 0, y: 0 }));
  const q = applyMat(m, { x: 1, y: 1 });
  near(q.x, 7);
  near(q.y, 2);
  assert.deepEqual(applyMat(IDENTITY, { x: 3, y: 4 }), { x: 3, y: 4 });
});
test("Transformer un objet : les poignées suivent ; un texte garde un corps lisible et tourne", () => {
  const o = path([{ p: { x: 0, y: 0 }, hin: null, hout: { x: 10, y: 0 }, smooth: false }, cornerNode({ x: 20, y: 0 })]);
  const t = transformObject(o, translateM(5, 7)) as PathObject;
  near(t.nodes[0].hout!.x, 15);
  near(t.nodes[0].hout!.y, 7);
  const tx = text(0, 0);
  const r = transformObject(tx, rotateM(Math.PI / 2, { x: 0, y: 0 })) as TextObject;
  near(r.rotation, -90, 1e-9);
  const s = transformObject(tx, scaleM(2, 2, { x: 0, y: 0 })) as TextObject;
  near(s.fontSize, 36, 1e-9);
});

console.log("Main levée");
test("Simplification (Ramer-Douglas-Peucker) : une droite bruitée devient 2 points", () => {
  const pts = Array.from({ length: 50 }, (_, i) => ({ x: i, y: (i % 2) * 0.1 }));
  assert.equal(simplifyRdp(pts, 0.5).length, 2);
});
test("Lissage : un quart de cercle échantillonné est refait avec peu de nœuds, fidèle à 1 %", () => {
  const raw = Array.from({ length: 60 }, (_, i) => {
    const a = (i / 59) * (Math.PI / 2);
    return { x: 100 * Math.cos(a), y: 100 * Math.sin(a) };
  });
  const nodes = fitSmooth(raw, 1.5);
  assert.ok(nodes.length >= 3 && nodes.length <= 12, `nœuds : ${nodes.length}`);
  for (const p of flatten(nodes, false, 24)) {
    assert.ok(Math.abs(Math.hypot(p.x, p.y) - 100) < 1.5, "trop loin du cercle");
  }
});

console.log("Flèches");
test("Pointe de flèche : sommet au bout, base en arrière, direction bien orientée", () => {
  const nodes = [cornerNode({ x: 0, y: 0 }), cornerNode({ x: 100, y: 0 })];
  const t = endTangent(nodes, true)!;
  near(t.dir.x, 1);
  near(t.dir.y, 0);
  const poly = arrowPolygon(t.pt, t.dir, 20, 8);
  assert.deepEqual(poly[0], { x: 100, y: 0 });
  near(poly[1].x, 80);
  near(Math.abs(poly[1].y), 8);
  const s = endTangent(nodes, false)!;
  near(s.dir.x, -1);
  const curved = [{ p: { x: 0, y: 0 }, hin: null, hout: { x: 0, y: 50 }, smooth: false }, cornerNode({ x: 100, y: 100 })];
  near(endTangent(curved, false)!.dir.y, -1);
});

console.log("Historique");
test("Annuler / refaire, nouvelle action efface le « refaire », limite", () => {
  const h = createHistory(0, 3);
  h.push(1);
  h.push(2);
  assert.equal(h.current, 2);
  assert.equal(h.undo(), 1);
  assert.equal(h.undo(), 0);
  assert.equal(h.undo(), null);
  assert.equal(h.redo(), 1);
  h.push(9);
  assert.ok(!h.canRedo());
  for (let i = 0; i < 10; i++) h.push(i);
  let n = 0;
  while (h.undo() !== null) n++;
  assert.equal(n, 3);
});

console.log("Document");
test("Empilement, groupes, suppression", () => {
  let d = newDoc("Test");
  const layer = d.layers[0].id;
  const a = path(rectNodes({ x: 0, y: 0 }, { x: 1, y: 1 }), true, layer);
  const b = path(rectNodes({ x: 2, y: 2 }, { x: 3, y: 3 }), true, layer);
  const c = text(0, 0, layer);
  d = addObjects(d, [a, b, c]);
  d = arrangeObjects(d, new Set([a.id]), "front");
  assert.equal(d.objects[2].id, a.id);
  d = arrangeObjects(d, new Set([a.id]), "back");
  assert.equal(d.objects[0].id, a.id);
  d = arrangeObjects(d, new Set([a.id]), "forward");
  assert.equal(d.objects[1].id, a.id);
  d = arrangeObjects(d, new Set([a.id]), "backward");
  assert.equal(d.objects[0].id, a.id);
  d = setGroup(d, new Set([a.id, b.id]), "g1");
  assert.equal(d.objects.filter((o) => o.group === "g1").length, 2);
  d = removeObjects(d, new Set([a.id]));
  assert.equal(d.objects.length, 2);
});
test("Lecture d'un fichier : aller-retour fidèle, objets douteux écartés, couleurs filtrées", () => {
  let d = newDoc("Migrations pendulaires");
  d = { ...d, sources: "INSEE, exemple" };
  const layer = d.layers[0].id;
  d = addObjects(d, [path(ellipseNodes({ x: 0, y: 0 }, { x: 10, y: 10 }), true, layer), text(5, 5, layer)]);
  const back = parseDoc(JSON.parse(JSON.stringify(d)));
  assert.ok(back);
  assert.equal(back!.objects.length, 2);
  assert.equal(back!.title, "Migrations pendulaires");
  assert.equal(back!.sources, "INSEE, exemple");
  assert.equal(parseDoc({ format: "autre" }), null);
  assert.equal(parseDoc(null), null);
  const evil = JSON.parse(JSON.stringify(d));
  evil.objects[0].style.fill = 'red" onload="alert(1)';
  evil.objects[1].color = '"><script>';
  evil.objects.push({ id: "x", kind: "path", layerId: "inconnu", nodes: [] });
  const clean = parseDoc(evil)!;
  assert.equal(clean.objects.length, 2);
  const p = clean.objects[0] as PathObject;
  assert.ok(!String(p.style.fill).includes('"'));
  assert.ok(!(clean.objects[1] as TextObject).color.includes("<"));
});

console.log("Alignement et miroir");
test("Aligner à gauche / au centre, miroir horizontal", () => {
  const a = path(rectNodes({ x: 0, y: 0 }, { x: 10, y: 10 }), true);
  const b = path(rectNodes({ x: 50, y: 0 }, { x: 70, y: 10 }), true);
  const k = 0.01;
  const left = alignObjects([a, b], "left", k);
  const nb = left.get(b.id) as PathObject;
  near(pathBounds(nb.nodes, true)!.minX, 0);
  assert.equal(left.has(a.id), false);
  const center = alignObjects([a, b], "center", k);
  const na = center.get(a.id) as PathObject;
  near((pathBounds(na.nodes, true)!.minX + pathBounds(na.nodes, true)!.maxX) / 2, 35);
  assert.equal(alignObjects([a], "left", k).size, 0);
  const flipped = flipObjects([a, b], "h", k);
  const fa = flipped.get(a.id) as PathObject;
  near(pathBounds(fa.nodes, true)!.minX, 60);
  const u = selectionBounds([a, b], k)!;
  near(u.maxX, 70);
});

console.log("Rendu SVG et export");
test("Épaisseur : pixels d'écran ou mètres convertis", () => {
  near(strokePx({ ...DEFAULT_STYLE, widthMode: "screen", strokeWidth: 3 }, 0.01), 3);
  near(strokePx({ ...DEFAULT_STYLE, widthMode: "map", strokeWidth: 500 }, 0.01), 5);
});
test("Chemin SVG : droite, courbe, fermeture", () => {
  assert.equal(pathD([cornerNode({ x: 0, y: 0 }), cornerNode({ x: 10, y: 5 })], false), "M0 0L10 5");
  assert.equal(pathD(rectNodes({ x: 0, y: 0 }, { x: 2, y: 2 }), true).endsWith("Z"), true);
  const c = pathD([{ p: { x: 0, y: 0 }, hin: null, hout: { x: 0, y: 5 }, smooth: false }, cornerNode({ x: 10, y: 10 })], false);
  assert.ok(c.includes("C0 5 10 10 10 10"));
});
test("Objet SVG : texte échappé, flèche en plus du trait, opacité", () => {
  const t = { ...text(0, 0), text: "A <b> & \"c\"", opacity: 0.5 };
  const s = objectSvg(t, (p) => p, 1);
  assert.ok(s.includes("&lt;b&gt; &amp; &quot;c&quot;"));
  assert.ok(s.includes('opacity="0.5"'));
  const arrow = path([cornerNode({ x: 0, y: 0 }), cornerNode({ x: 100, y: 0 })]);
  arrow.style = { ...arrow.style, fill: null, arrowEnd: true };
  const sv = objectSvg(arrow, (p) => p, 1);
  assert.equal((sv.match(/<path /g) ?? []).length, 2);
});
test("Export SVG complet : calques nommés, titre, sources, cadre cohérent ; vide = null", () => {
  let d = newDoc("Flux & lignes");
  assert.equal(docToSvg(d), null);
  d = { ...d, sources: "INSEE <exemple>" };
  const layer = d.layers[0].id;
  d = addObjects(d, [path([cornerNode({ x: 0, y: 0 }), cornerNode({ x: 1000, y: 500 })], false, layer), text(500, 250, layer)]);
  const r = docToSvg(d)!;
  assert.ok(r.svg.startsWith("<?xml"));
  assert.ok(r.svg.includes("<title>Flux &amp; lignes</title>"));
  assert.ok(r.svg.includes("INSEE &lt;exemple&gt;"));
  assert.ok(r.svg.includes('inkscape:label="Calque 1"'));
  assert.ok(r.width > 100 && r.height > 50);
  assert.ok(r.svg.includes(`viewBox="0 0 ${r.width} ${r.height}"`));
  const hidden = { ...d, layers: d.layers.map((l) => ({ ...l, visible: false })) };
  assert.equal(docToSvg(hidden), null);
});

console.log(`\n${passed} tests réussis.`);
