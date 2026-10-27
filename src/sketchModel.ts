// Outil de croquis — modèle de données (logique pure : aucun DOM, aucune base).
//
// Demande de Martin (2026-10-27) : un éditeur « à la Illustrator » dessiné DIRECTEMENT sur la
// carte. Tous les points sont stockés en MÈTRES Web Mercator (EPSG:3857, la projection des
// tuiles de la carte) : un dessin reste donc accroché à la géographie et garde exactement la
// même forme à tous les zooms. Voir docs/specs/croquis.md.
//
// Convention : les documents et les objets sont IMMUABLES. On ne modifie jamais un objet en
// place, on en fabrique un nouveau (c'est ce qui rend l'historique annuler/refaire trivial).

export type Pt = { x: number; y: number };

/** Un point d'ancrage d'une courbe de Bézier ; `hin`/`hout` = poignées, en positions ABSOLUES. */
export type SketchNode = { p: Pt; hin: Pt | null; hout: Pt | null; smooth: boolean };

export type WidthMode = "screen" | "map";
export type DashKind = "solid" | "dashed" | "dotted";
export type CapKind = "butt" | "round" | "square";
export type JoinKind = "miter" | "round" | "bevel";

export type SketchStyle = {
  fill: string | null;
  fillOpacity: number;
  stroke: string | null;
  /** Pixels d'écran si widthMode = "screen", mètres sur le terrain si "map". */
  strokeWidth: number;
  widthMode: WidthMode;
  dash: DashKind;
  cap: CapKind;
  join: JoinKind;
  /** Opacité de l'objet entier (0 à 1). */
  opacity: number;
  arrowStart: boolean;
  arrowEnd: boolean;
  /** Longueur de la pointe, en multiple de l'épaisseur du trait. */
  arrowSize: number;
};

export type PathObject = {
  id: string;
  kind: "path";
  layerId: string;
  group: string | null;
  nodes: SketchNode[];
  closed: boolean;
  style: SketchStyle;
};

export type TextAnchor = "start" | "middle" | "end";

export type TextObject = {
  id: string;
  kind: "text";
  layerId: string;
  group: string | null;
  /** Point d'ancrage (début de la ligne de base). */
  p: Pt;
  text: string;
  /** Taille en pixels d'écran. */
  fontSize: number;
  fontFamily: string;
  bold: boolean;
  italic: boolean;
  color: string;
  /** Couleur du contour de lisibilité (halo) ; null = aucun. */
  halo: string | null;
  anchor: TextAnchor;
  /** Degrés, sens horaire à l'écran. */
  rotation: number;
  opacity: number;
};

export type SketchObject = PathObject | TextObject;

export type SketchLayer = { id: string; name: string; visible: boolean; locked: boolean };

export type SketchDoc = {
  format: "croquis";
  version: 1;
  id: string;
  title: string;
  /** Sources des données utilisées dans le croquis (règle du projet : tout est sourcé). */
  sources: string;
  /** Du fond vers le dessus. */
  layers: SketchLayer[];
  /** Ordre d'empilement à l'intérieur d'un calque : du fond vers le dessus. */
  objects: SketchObject[];
  createdAt: string;
  updatedAt: string;
};

export const FONTS: { id: string; label: string; css: string }[] = [
  { id: "sans", label: "Sans empattement", css: "system-ui, 'Segoe UI', Arial, sans-serif" },
  { id: "serif", label: "Avec empattement", css: "Georgia, 'Times New Roman', serif" },
  { id: "mono", label: "Chasse fixe", css: "'Courier New', Consolas, monospace" },
  { id: "condensed", label: "Condensée", css: "'Arial Narrow', 'Roboto Condensed', Arial, sans-serif" },
];

export const DEFAULT_STYLE: SketchStyle = {
  fill: "#e8b34a",
  fillOpacity: 0.35,
  stroke: "#e8b34a",
  strokeWidth: 2.5,
  widthMode: "screen",
  dash: "solid",
  cap: "round",
  join: "round",
  opacity: 1,
  arrowStart: false,
  arrowEnd: false,
  arrowSize: 4,
};

export type TextDefaults = Pick<
  TextObject,
  "fontSize" | "fontFamily" | "bold" | "italic" | "color" | "halo" | "anchor" | "opacity"
>;

export const DEFAULT_TEXT: TextDefaults = {
  fontSize: 18,
  fontFamily: "sans",
  bold: false,
  italic: false,
  color: "#ffffff",
  halo: "#0a0e18",
  anchor: "start",
  opacity: 1,
};

export function uid(): string {
  const c = (globalThis as { crypto?: { randomUUID?: () => string } }).crypto;
  if (c && typeof c.randomUUID === "function") return c.randomUUID().replace(/-/g, "").slice(0, 12);
  return Math.random().toString(36).slice(2, 8) + Math.random().toString(36).slice(2, 8);
}

export function newLayer(name: string): SketchLayer {
  return { id: uid(), name, visible: true, locked: false };
}

export function newDoc(title: string): SketchDoc {
  const now = new Date().toISOString();
  return {
    format: "croquis",
    version: 1,
    id: uid(),
    title,
    sources: "",
    layers: [newLayer("Calque 1")],
    objects: [],
    createdAt: now,
    updatedAt: now,
  };
}

// ---------------------------------------------------------------------------
// Opérations immuables sur un document
// ---------------------------------------------------------------------------

export function withObjects(doc: SketchDoc, objects: SketchObject[]): SketchDoc {
  return { ...doc, objects, updatedAt: new Date().toISOString() };
}

export function withLayers(doc: SketchDoc, layers: SketchLayer[], objects?: SketchObject[]): SketchDoc {
  return { ...doc, layers, objects: objects ?? doc.objects, updatedAt: new Date().toISOString() };
}

export function addObjects(doc: SketchDoc, objs: SketchObject[]): SketchDoc {
  return withObjects(doc, [...doc.objects, ...objs]);
}

export function removeObjects(doc: SketchDoc, ids: ReadonlySet<string>): SketchDoc {
  return withObjects(
    doc,
    doc.objects.filter((o) => !ids.has(o.id)),
  );
}

/** Remplace les objets dont l'identifiant est dans `repl` (les autres sont gardés tels quels). */
export function replaceObjects(doc: SketchDoc, repl: ReadonlyMap<string, SketchObject>): SketchDoc {
  return withObjects(
    doc,
    doc.objects.map((o) => repl.get(o.id) ?? o),
  );
}

export function layerIndex(doc: SketchDoc, layerId: string): number {
  return doc.layers.findIndex((l) => l.id === layerId);
}

export type ArrangeMode = "front" | "back" | "forward" | "backward";

export function arrangeObjects(doc: SketchDoc, ids: ReadonlySet<string>, mode: ArrangeMode): SketchDoc {
  const objs = doc.objects.slice();
  const isSel = (o: SketchObject) => ids.has(o.id);
  if (mode === "front") return withObjects(doc, [...objs.filter((o) => !isSel(o)), ...objs.filter(isSel)]);
  if (mode === "back") return withObjects(doc, [...objs.filter(isSel), ...objs.filter((o) => !isSel(o))]);
  if (mode === "forward") {
    for (let i = objs.length - 2; i >= 0; i--) {
      if (isSel(objs[i]) && !isSel(objs[i + 1])) [objs[i], objs[i + 1]] = [objs[i + 1], objs[i]];
    }
  } else {
    for (let i = 1; i < objs.length; i++) {
      if (isSel(objs[i]) && !isSel(objs[i - 1])) [objs[i], objs[i - 1]] = [objs[i - 1], objs[i]];
    }
  }
  return withObjects(doc, objs);
}

/** Regroupe les objets (un identifiant de groupe commun) ; `null` = dégrouper. */
export function setGroup(doc: SketchDoc, ids: ReadonlySet<string>, group: string | null): SketchDoc {
  return withObjects(
    doc,
    doc.objects.map((o) => (ids.has(o.id) ? { ...o, group } : o)),
  );
}

/** Ordre de dessin réel : par calque (du fond vers le dessus), puis ordre d'empilement. */
export function objectsInDrawOrder(doc: SketchDoc): SketchObject[] {
  const out: SketchObject[] = [];
  for (const layer of doc.layers) {
    for (const o of doc.objects) if (o.layerId === layer.id) out.push(o);
  }
  return out;
}

// ---------------------------------------------------------------------------
// Lecture / validation (fichier JSON importé ou stockage local) — jamais de confiance aveugle
// ---------------------------------------------------------------------------

const COLOR_RE = /^(#[0-9a-fA-F]{3,8}|rgba?\([\d\s.,%]+\)|[a-zA-Z]{3,20})$/;

export function sanitizeColor(c: unknown, fallback: string | null): string | null {
  if (c === null) return null;
  return typeof c === "string" && COLOR_RE.test(c.trim()) ? c.trim() : fallback;
}

function num(v: unknown, fallback: number, min = -Infinity, max = Infinity): number {
  return typeof v === "number" && Number.isFinite(v) ? Math.min(max, Math.max(min, v)) : fallback;
}

function pt(v: unknown): Pt | null {
  if (!v || typeof v !== "object") return null;
  const r = v as Record<string, unknown>;
  return typeof r.x === "number" && typeof r.y === "number" && Number.isFinite(r.x) && Number.isFinite(r.y)
    ? { x: r.x, y: r.y }
    : null;
}

function oneOf<T extends string>(v: unknown, allowed: readonly T[], fallback: T): T {
  return typeof v === "string" && (allowed as readonly string[]).includes(v) ? (v as T) : fallback;
}

export function coerceStyle(v: unknown): SketchStyle {
  const r = (v && typeof v === "object" ? v : {}) as Record<string, unknown>;
  const d = DEFAULT_STYLE;
  return {
    fill: "fill" in r ? sanitizeColor(r.fill, d.fill) : d.fill,
    fillOpacity: num(r.fillOpacity, d.fillOpacity, 0, 1),
    stroke: "stroke" in r ? sanitizeColor(r.stroke, d.stroke) : d.stroke,
    strokeWidth: num(r.strokeWidth, d.strokeWidth, 0, 1e9),
    widthMode: oneOf(r.widthMode, ["screen", "map"] as const, d.widthMode),
    dash: oneOf(r.dash, ["solid", "dashed", "dotted"] as const, d.dash),
    cap: oneOf(r.cap, ["butt", "round", "square"] as const, d.cap),
    join: oneOf(r.join, ["miter", "round", "bevel"] as const, d.join),
    opacity: num(r.opacity, 1, 0, 1),
    arrowStart: r.arrowStart === true,
    arrowEnd: r.arrowEnd === true,
    arrowSize: num(r.arrowSize, d.arrowSize, 1, 30),
  };
}

function coerceNode(v: unknown): SketchNode | null {
  if (!v || typeof v !== "object") return null;
  const r = v as Record<string, unknown>;
  const p = pt(r.p);
  if (!p) return null;
  return { p, hin: pt(r.hin), hout: pt(r.hout), smooth: r.smooth === true };
}

function coerceObject(v: unknown, layerIds: ReadonlySet<string>): SketchObject | null {
  if (!v || typeof v !== "object") return null;
  const r = v as Record<string, unknown>;
  const id = typeof r.id === "string" && r.id ? r.id : uid();
  const layerId = typeof r.layerId === "string" && layerIds.has(r.layerId) ? r.layerId : "";
  if (!layerId) return null;
  const group = typeof r.group === "string" && r.group ? r.group : null;
  if (r.kind === "path") {
    if (!Array.isArray(r.nodes)) return null;
    const nodes = r.nodes.map(coerceNode).filter((n): n is SketchNode => n !== null);
    if (nodes.length < 2) return null;
    return { id, kind: "path", layerId, group, nodes, closed: r.closed === true, style: coerceStyle(r.style) };
  }
  if (r.kind === "text") {
    const p = pt(r.p);
    if (!p || typeof r.text !== "string") return null;
    const fontIds = FONTS.map((f) => f.id);
    return {
      id,
      kind: "text",
      layerId,
      group,
      p,
      text: r.text.slice(0, 2000),
      fontSize: num(r.fontSize, DEFAULT_TEXT.fontSize, 4, 400),
      fontFamily: oneOf(r.fontFamily, fontIds, "sans"),
      bold: r.bold === true,
      italic: r.italic === true,
      color: sanitizeColor(r.color, "#ffffff") ?? "#ffffff",
      halo: "halo" in r ? sanitizeColor(r.halo, null) : DEFAULT_TEXT.halo,
      anchor: oneOf(r.anchor, ["start", "middle", "end"] as const, "start"),
      rotation: num(r.rotation, 0, -3600, 3600),
      opacity: num(r.opacity, 1, 0, 1),
    };
  }
  return null;
}

/** Valide et nettoie un document venant d'un fichier ou du stockage ; null si inutilisable. */
export function parseDoc(raw: unknown): SketchDoc | null {
  if (!raw || typeof raw !== "object") return null;
  const r = raw as Record<string, unknown>;
  if (r.format !== "croquis" || r.version !== 1) return null;
  if (!Array.isArray(r.layers) || !Array.isArray(r.objects)) return null;
  const layers: SketchLayer[] = [];
  for (const l of r.layers) {
    if (!l || typeof l !== "object") continue;
    const lr = l as Record<string, unknown>;
    if (typeof lr.id !== "string" || !lr.id) continue;
    layers.push({
      id: lr.id,
      name: typeof lr.name === "string" ? lr.name.slice(0, 80) : "Calque",
      visible: lr.visible !== false,
      locked: lr.locked === true,
    });
  }
  if (layers.length === 0) return null;
  const ids = new Set(layers.map((l) => l.id));
  const objects = r.objects.map((o) => coerceObject(o, ids)).filter((o): o is SketchObject => o !== null);
  const now = new Date().toISOString();
  return {
    format: "croquis",
    version: 1,
    id: typeof r.id === "string" && r.id ? r.id : uid(),
    title: typeof r.title === "string" ? r.title.slice(0, 160) : "Croquis",
    sources: typeof r.sources === "string" ? r.sources.slice(0, 5000) : "",
    layers,
    objects,
    createdAt: typeof r.createdAt === "string" ? r.createdAt : now,
    updatedAt: typeof r.updatedAt === "string" ? r.updatedAt : now,
  };
}
