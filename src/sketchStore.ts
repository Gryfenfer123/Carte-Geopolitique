// Outil de croquis — stockage PROVISOIRE dans le navigateur (localStorage).
//
// Décision du 2026-10-27 : on construit d'abord l'outil ; le rangement définitif dans les
// dossiers pays/groupes (base Supabase, donc migration à exécuter par Martin) viendra après son
// accord. En attendant, les croquis ne vivent que dans CE navigateur : l'export JSON/SVG sert de
// sauvegarde. Même interface qu'un futur stockage en base : seul ce fichier sera remplacé.

import { parseDoc, type SketchDoc } from "./sketchModel";

const KEY_DOCS = "croquis:docs:v1";
const KEY_SHOWN = "croquis:affiches:v1";

function readJson(key: string): unknown {
  try {
    const raw = localStorage.getItem(key);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

function writeJson(key: string, value: unknown): boolean {
  try {
    localStorage.setItem(key, JSON.stringify(value));
    return true;
  } catch {
    return false; // stockage plein ou interdit : l'appelant prévient l'utilisateur
  }
}

export function loadAllDocs(): SketchDoc[] {
  const raw = readJson(KEY_DOCS);
  if (!Array.isArray(raw)) return [];
  return raw.map(parseDoc).filter((d): d is SketchDoc => d !== null);
}

/** Enregistre (ou remplace) un croquis. Renvoie false si le navigateur refuse d'écrire. */
export function saveDoc(doc: SketchDoc): boolean {
  const all = loadAllDocs();
  const i = all.findIndex((d) => d.id === doc.id);
  if (i >= 0) all[i] = doc;
  else all.push(doc);
  return writeJson(KEY_DOCS, all);
}

export function removeDoc(id: string): void {
  writeJson(
    KEY_DOCS,
    loadAllDocs().filter((d) => d.id !== id),
  );
}

export function loadShown(): string[] {
  const raw = readJson(KEY_SHOWN);
  return Array.isArray(raw) ? raw.filter((x): x is string => typeof x === "string") : [];
}

export function saveShown(ids: string[]): void {
  writeJson(KEY_SHOWN, ids);
}
