// ---------------------------------------------------------------------------
// Index global de toutes les entités "nommées" de l'app (pays, groupes,
// sous-catégories de dossier, fiches/entrées texte, personnes d'un arbre
// généalogique) — sert à DEUX fonctionnalités demandées par Martin,
// 2026-10-03 :
//
// 1. Liens automatiques dans les textes de dossier (autoLinkHtml) :
//    "Liens automatiques dans les textes vers une fiche créée plus tard
//    (rétroactif) + lien seulement à la première mention (façon
//    Wikipédia)". Comme l'index est reconstruit à chaque ouverture d'un
//    dossier/arbre (voir ensureLinkIndexLoaded, appelé par main.ts), une
//    entité créée APRÈS qu'un texte mentionnant son nom ait été écrit
//    devient automatiquement un lien dès que l'index est rafraîchi — pas
//    besoin de ré-éditer le texte ni de mécanisme de migration : le texte
//    stocké ne contient jamais le lien lui-même, seulement le nom brut,
//    et c'est CE module qui le transforme en lien à chaque rendu.
//
// 2. Rattachement automatique bidirectionnel "membre d'arbre généalogique
//    ↔ fiche encyclopédie du même nom" (ex. "Pépin le Bref" dans un arbre
//    doit se lier à la sous-sous-sous-catégorie "Pépin le Bref") : voir
//    findLinkTargetForName(), utilisé par dossier.ts (bannière sur la page
//    d'une section/la vue de lecture d'une entrée) et genealogy.ts
//    (bannière sur la fiche d'un membre), chacun cherchant une
//    correspondance de nom dans l'AUTRE sens.
//
// Portée volontairement simple (accord explicite de Martin) : une personne
// se rattache à une FICHE (entrée texte) OU une SOUS-CATÉGORIE du même nom
// exact (insensible à la casse) ; en cas d'ambiguïté (plusieurs entités
// partagent le même nom), la première trouvée gagne.
// ---------------------------------------------------------------------------

import type { SupabaseClient } from "@supabase/supabase-js";
import type { DossierOwnerKind } from "./dossier";

export type LinkTarget =
  | { kind: "country"; slug: string }
  | { kind: "group"; id: string }
  | { kind: "section"; ownerType: DossierOwnerKind; ownerId: string; categoryId: string | null; sectionId: string }
  | { kind: "entry"; ownerType: DossierOwnerKind; ownerId: string; categoryId: string | null; entryId: string }
  | { kind: "genealogy-member"; ownerType: string; ownerId: string; memberId: string };

export type LinkIndexEntry = { label: string; target: LinkTarget };

type SectionRow = { id: string; owner_type: DossierOwnerKind; owner_id: string; category_id: string | null; title: string };
type TextEntryRow = { id: string; owner_type: DossierOwnerKind; owner_id: string; category_id: string | null; title: string | null };
type MemberRow = { id: string; owner_type: string; owner_id: string; name: string };

type RawCache = { sections: SectionRow[]; entries: TextEntryRow[]; members: MemberRow[] };
let cache: RawCache | null = null;
let loading: Promise<RawCache> | null = null;

export async function ensureLinkIndexLoaded(supabase: SupabaseClient, force = false): Promise<RawCache> {
  if (cache && !force) return cache;
  if (loading) return loading;
  loading = (async () => {
    const [secRes, entRes, memRes] = await Promise.all([
      supabase.from("dossier_sections").select("id, owner_type, owner_id, category_id, title"),
      supabase.from("dossier_entries").select("id, owner_type, owner_id, category_id, title").eq("type", "text"),
      supabase.from("genealogy_members").select("id, owner_type, owner_id, name"),
    ]);
    const next: RawCache = {
      sections: (secRes.data || []) as SectionRow[],
      entries: (entRes.data || []) as TextEntryRow[],
      members: (memRes.data || []) as MemberRow[],
    };
    cache = next;
    return next;
  })();
  try {
    return await loading;
  } finally {
    loading = null;
  }
}

export function getLinkIndexCache(): RawCache {
  return cache || { sections: [], entries: [], members: [] };
}

// Pour un pré-chargement "une seule fois" (voir search.ts) : évite de
// ré-attacher un .then(...) à chaque frappe une fois l'index déjà en
// cache (sinon .then() résout quasi immédiatement et ré-déclenche la
// recherche, qui ré-attache un .then(), etc. — boucle de microtâches
// infinie qui gèle l'onglet).
export function isLinkIndexLoaded(): boolean {
  return cache !== null;
}

// Toutes les entrées "nom → cible" connues, pour l'auto-lien de texte.
// `countries`/`groups` sont fournis par l'appelant (déjà en mémoire côté
// main.ts, pas besoin de les recharger ici).
export function buildLinkIndexEntries(opts: {
  countries: { slug: string; label: string }[];
  groups: { id: string; label: string }[];
}): LinkIndexEntry[] {
  const out: LinkIndexEntry[] = [];
  opts.countries.forEach((c) => {
    if (c.label) out.push({ label: c.label, target: { kind: "country", slug: c.slug } });
  });
  opts.groups.forEach((g) => {
    if (g.label) out.push({ label: g.label, target: { kind: "group", id: g.id } });
  });
  getLinkIndexCache().sections.forEach((s) => {
    if (s.title) out.push({ label: s.title, target: { kind: "section", ownerType: s.owner_type, ownerId: s.owner_id, categoryId: s.category_id, sectionId: s.id } });
  });
  getLinkIndexCache().entries.forEach((e) => {
    if (e.title) out.push({ label: e.title, target: { kind: "entry", ownerType: e.owner_type, ownerId: e.owner_id, categoryId: e.category_id, entryId: e.id } });
  });
  getLinkIndexCache().members.forEach((m) => {
    if (m.name) out.push({ label: m.name, target: { kind: "genealogy-member", ownerType: m.owner_type, ownerId: m.owner_id, memberId: m.id } });
  });
  return out;
}

// Rattachement bidirectionnel par nom exact (insensible à la casse) — voir
// l'en-tête du fichier. `excludeKinds` sert à ce qu'un membre ne se
// "retrouve" pas lui-même (dossier.ts cherche un membre matching pour une
// section/entrée ; genealogy.ts cherche une section/entrée matching pour un
// membre).
export function findLinkTargetForName(name: string, wantKinds: LinkTarget["kind"][]): LinkTarget | null {
  const key = (name || "").trim().toLowerCase();
  if (key.length < 2) return null;
  if (wantKinds.includes("genealogy-member")) {
    const m = getLinkIndexCache().members.find((x) => (x.name || "").trim().toLowerCase() === key);
    if (m) return { kind: "genealogy-member", ownerType: m.owner_type, ownerId: m.owner_id, memberId: m.id };
  }
  if (wantKinds.includes("section")) {
    const s = getLinkIndexCache().sections.find((x) => (x.title || "").trim().toLowerCase() === key);
    if (s) return { kind: "section", ownerType: s.owner_type, ownerId: s.owner_id, categoryId: s.category_id, sectionId: s.id };
  }
  if (wantKinds.includes("entry")) {
    const e = getLinkIndexCache().entries.find((x) => (x.title || "").trim().toLowerCase() === key);
    if (e) return { kind: "entry", ownerType: e.owner_type, ownerId: e.owner_id, categoryId: e.category_id, entryId: e.id };
  }
  return null;
}

// Auto-lien de texte — "première mention seulement" (façon Wikipédia) :
// `alreadyLinked` est local à CHAQUE appel (donc à chaque entrée de texte
// rendue séparément), jamais partagé entre deux entrées différentes.
export function autoLinkHtml(html: string, entries: LinkIndexEntry[]): string {
  if (!html) return html;
  const seen = new Map<string, LinkIndexEntry>();
  entries.forEach((e) => {
    const key = e.label.trim().toLowerCase();
    if (key.length >= 3 && !seen.has(key)) seen.set(key, e);
  });
  const sorted = Array.from(seen.values()).sort((a, b) => b.label.length - a.label.length);
  if (!sorted.length) return html;
  const escRe = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const pattern = new RegExp("\\b(" + sorted.map((e) => escRe(e.label)).join("|") + ")\\b", "gi");
  const byLower = new Map(sorted.map((e) => [e.label.toLowerCase(), e]));
  const template = document.createElement("template");
  template.innerHTML = html;
  const frag = template.content;
  const alreadyLinked = new Set<string>();
  (function walk(node: Node) {
    Array.from(node.childNodes).forEach((child) => {
      if (child.nodeType === Node.ELEMENT_NODE) {
        if ((child as Element).tagName === "A") return;
        walk(child);
        return;
      }
      if (child.nodeType !== Node.TEXT_NODE) return;
      const text = child.textContent || "";
      pattern.lastIndex = 0;
      if (!pattern.test(text)) return;
      pattern.lastIndex = 0;
      const out = document.createDocumentFragment();
      let last = 0;
      let m: RegExpExecArray | null;
      while ((m = pattern.exec(text))) {
        const key = m[0].toLowerCase();
        if (m.index > last) out.appendChild(document.createTextNode(text.slice(last, m.index)));
        if (alreadyLinked.has(key)) {
          out.appendChild(document.createTextNode(m[0]));
        } else {
          const info = byLower.get(key)!;
          const a = document.createElement("a");
          a.dataset.linkTarget = JSON.stringify(info.target);
          a.textContent = m[0];
          out.appendChild(a);
          alreadyLinked.add(key);
        }
        last = m.index + m[0].length;
      }
      if (last < text.length) out.appendChild(document.createTextNode(text.slice(last)));
      child.replaceWith(out);
    });
  })(frag);
  const div = document.createElement("div");
  div.appendChild(frag);
  return div.innerHTML;
}
