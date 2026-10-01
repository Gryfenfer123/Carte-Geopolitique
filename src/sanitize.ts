// ---------------------------------------------------------------------------
// Sanitisation du texte riche des entrées de dossier — porté à l'identique
// de sanitizeDossierHTML() / DOSSIER_HTML_ALLOWED_TAGS / DOSSIER_STYLE_PROP_RULES
// / DOSSIER_CLASS_RULES dans l'artifact source (realistic_final.html,
// ~lignes 4909-5046). Cette liste blanche est LA frontière de sécurité :
// tout tag ou attribut absent d'ici est supprimé, aussi bien à la
// sauvegarde qu'à l'affichage.
// ---------------------------------------------------------------------------

export const DOSSIER_HTML_ALLOWED_TAGS: Record<string, string[]> = {
  P: ["style"], BR: [], STRONG: [], B: [], EM: [], I: [], U: [],
  // Barré : les navigateurs produisent selon les cas <strike> (execCommand
  // historique) ou <s>/<del> (collage externe) — les trois sont acceptés en
  // lecture, mais tous sans attribut.
  S: [], STRIKE: [], DEL: [], SUP: [], SUB: [], CODE: [], PRE: [], HR: [],
  H2: ["style"], H3: ["style"],
  // UL : class restreinte à 'rt-checklist' (case à cocher maison).
  // LI : class restreinte à 'rt-check' + data-checked ('true'/'false').
  UL: ["class"], OL: [], LI: ["class", "data-checked"],
  BLOCKQUOTE: ["style"],
  TABLE: [], THEAD: [], TBODY: [], TR: [],
  TH: ["colspan", "rowspan"], TD: ["colspan", "rowspan"],
  // SPAN : seul vecteur de couleur / surlignage / taille de police.
  SPAN: ["style", "class"],
  // Liens internes uniquement : jamais de href, jamais d'attributs on* —
  // seuls data-entity-kind/data-entity-id survivent, validés ensuite par
  // sanitizeDossierHTML() (kind connu, cf. INTERNAL_LINK_KINDS).
  A: ["data-entity-kind", "data-entity-id"],
};

// Kinds acceptés pour un lien interne <a data-entity-kind="...">. L'artifact
// source accepte 'country' et 'poi' ; ce portage se limite pour l'instant aux
// pays (les points d'intérêt sont hors périmètre de cette étape).
const INTERNAL_LINK_KINDS = new Set(["country"]);

const DOSSIER_COLOR_RULE =
  /^(#[0-9a-fA-F]{3,8}|rgba?\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\s*(,\s*(0|1|0?\.\d{1,3})\s*)?\))$/;

const DOSSIER_STYLE_PROP_RULES: Record<string, RegExp> = {
  color: DOSSIER_COLOR_RULE,
  "background-color": DOSSIER_COLOR_RULE,
  "text-align": /^(left|right|center|justify)$/,
};

function sanitizeDossierStyleValue(raw: string | null): string {
  if (!raw) return "";
  const out: string[] = [];
  String(raw)
    .split(";")
    .forEach((decl) => {
      const idx = decl.indexOf(":");
      if (idx < 0) return;
      const prop = decl.slice(0, idx).trim().toLowerCase();
      const val = decl.slice(idx + 1).trim();
      const rule = DOSSIER_STYLE_PROP_RULES[prop];
      if (rule && rule.test(val)) out.push(prop + ":" + val);
    });
  return out.join(";");
}

const DOSSIER_CLASS_RULES: Record<string, RegExp> = {
  SPAN: /^rt-fs-(sm|md|lg|xl)$/,
  UL: /^rt-checklist$/,
  LI: /^rt-check$/,
};

function sanitizeAttrValue(tag: string, name: string, value: string): string | null {
  if (name === "style") return sanitizeDossierStyleValue(value);
  if (name === "class") {
    const rule = DOSSIER_CLASS_RULES[tag];
    return rule && rule.test(String(value || "").trim()) ? String(value).trim() : null;
  }
  if (name === "data-checked") return value === "true" ? "true" : "false";
  return value;
}

// IMPORTANT : on parse dans le contenu d'un <template>, jamais dans un <div>
// normal — <template>.content est un DocumentFragment INERTE (spec HTML) :
// aucune image ne se charge, aucun <script> ne s'exécute et aucun
// gestionnaire on*="…" ne se déclenche tant qu'il n'est pas rattaché à un
// document actif. Avec un <div> normal, `div.innerHTML = html` sur une
// chaîne contenant `<img src=x onerror="…">` déclenche le chargement (et
// donc l'échec, et donc le onerror) DÈS l'analyse — avant même d'avoir eu la
// main pour supprimer l'élément.
export function sanitizeDossierHTML(html: string | null | undefined): string {
  const template = document.createElement("template");
  template.innerHTML = String(html || "");
  const tmp = template.content;

  // Nettoyage en profondeur d'abord (bottom-up) : on nettoie toujours les
  // petits-enfants d'un nœud AVANT de décider de garder ou "déballer" ce
  // nœud lui-même.
  (function clean(node: Node) {
    Array.from(node.childNodes).forEach((child) => {
      if (child.nodeType === Node.TEXT_NODE) return;
      if (child.nodeType !== Node.ELEMENT_NODE) {
        node.removeChild(child);
        return;
      }
      const el = child as Element;
      const tag = el.tagName;
      const allowedAttrs = DOSSIER_HTML_ALLOWED_TAGS[tag];
      clean(el);
      if (!allowedAttrs) {
        // Tag non autorisé : on garde son contenu (déjà nettoyé ci-dessus)
        // mais on retire l'élément lui-même.
        while (el.firstChild) node.insertBefore(el.firstChild, el);
        node.removeChild(el);
        return;
      }
      Array.from(el.attributes).forEach((attr) => {
        if (!allowedAttrs.includes(attr.name)) {
          el.removeAttribute(attr.name);
          return;
        }
        const cleaned = sanitizeAttrValue(tag, attr.name, attr.value);
        if (cleaned === null || cleaned === "") el.removeAttribute(attr.name);
        else if (cleaned !== attr.value) el.setAttribute(attr.name, cleaned);
      });
    });
  })(tmp);

  // Second passage, ciblé sur <a> uniquement : ne garder les liens internes
  // que si kind+id sont TOUS LES DEUX présents et que le kind est reconnu.
  Array.from(tmp.querySelectorAll("a")).forEach((a) => {
    const kind = a.getAttribute("data-entity-kind");
    const id = a.getAttribute("data-entity-id");
    if (!kind || !id || !INTERNAL_LINK_KINDS.has(kind)) {
      while (a.firstChild) a.parentNode!.insertBefore(a.firstChild, a);
      a.parentNode!.removeChild(a);
    }
  });

  const out = document.createElement("div");
  out.appendChild(tmp);
  return out.innerHTML;
}

// Conversion HTML riche -> texte brut : ajoute des retours à la ligne entre
// blocs et une puce devant chaque élément de liste, pour rester lisible.
export function htmlToPlainText(html: string | null | undefined): string {
  const tmp = document.createElement("div");
  tmp.innerHTML = sanitizeDossierHTML(html || "");
  tmp.querySelectorAll("li").forEach((li) => {
    li.textContent = "• " + li.textContent;
  });
  tmp.querySelectorAll("p,div,h2,h3,li,tr,blockquote").forEach((el) => {
    el.insertAdjacentText("afterend", "\n");
  });
  return (tmp.textContent || "").replace(/\n{3,}/g, "\n\n").trim();
}

export type DossierEntryLike = {
  type: string;
  body?: string | null;
  label?: string | null;
  url?: string | null;
  caption?: string | null;
  title?: string | null;
  hemicycle?: { title?: string; parties?: { name: string }[]; source?: string } | null;
};

// Texte brut « recherchable/lisible » d'une entrée, quel que soit son type.
export function entryPlainText(entry: DossierEntryLike | null | undefined): string {
  if (!entry) return "";
  if (entry.type === "text") return htmlToPlainText(entry.body || "");
  if (entry.type === "link") return [entry.label, entry.url].filter(Boolean).join(" ");
  if (entry.type === "photo") return entry.caption || "";
  if (entry.type === "hemicycle") {
    const h = entry.hemicycle || {};
    return [entry.title, (h.parties || []).map((p) => p.name).join(" "), h.source].filter(Boolean).join(" ");
  }
  return "";
}

export function wordCountForEntry(entry: DossierEntryLike | null | undefined): number {
  const t = entryPlainText(entry).trim();
  return t ? t.split(/\s+/).length : 0;
}

export function readingTimeMinutes(words: number): number {
  return Math.max(1, Math.round(words / 200));
}

// --- YouTube (vignette + bouton lecture plutôt qu'un <iframe>) -------------
export function extractYouTubeId(url: string | null | undefined): string | null {
  if (!url) return null;
  const m = String(url).match(
    /(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/)|youtu\.be\/)([A-Za-z0-9_-]{6,})/
  );
  return m ? m[1] : null;
}
