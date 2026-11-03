// ---------------------------------------------------------------------------
// Frises — volet de détail (panneau à droite) : extrait de texte d'une fiche.
// Texte brut uniquement (aucun HTML repris) : rien à assainir, rien à injecter.
// ---------------------------------------------------------------------------

import type { SupabaseClient } from "@supabase/supabase-js";

const cache = new Map<string, string | null>();

/** Début lisible (≈ max caractères, coupé à une fin de phrase ou de mot) du texte d'une fiche. */
export async function fetchExcerpt(supabase: SupabaseClient, entryId: string, max = 560): Promise<string | null> {
  if (cache.has(entryId)) return cache.get(entryId) ?? null;
  const { data, error } = await supabase.from("dossier_entries").select("body_html").eq("id", entryId).maybeSingle();
  if (error || !data) return null;
  const html = (data as { body_html: string | null }).body_html;
  let out: string | null = null;
  if (html) {
    const doc = new DOMParser().parseFromString(html, "text/html");
    const text = (doc.body.textContent ?? "").replace(/\s+/g, " ").trim();
    out = text ? cutText(text, max) : null;
  }
  cache.set(entryId, out);
  return out;
}

export function cutText(text: string, max: number): string {
  if (text.length <= max) return text;
  const head = text.slice(0, max);
  const sentence = Math.max(head.lastIndexOf(". "), head.lastIndexOf("! "), head.lastIndexOf("? "));
  if (sentence > max * 0.5) return head.slice(0, sentence + 1);
  const word = head.lastIndexOf(" ");
  return (word > 0 ? head.slice(0, word) : head) + "…";
}
