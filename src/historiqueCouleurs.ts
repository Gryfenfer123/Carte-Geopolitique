// Couleurs des États par FAMILLE (lignée d'États), voir docs/DECISIONS.md et scripts/historique/construire_familles.py.
// Logique pure (sans DOM) : le fichier couleurs.json est produit par le script ; ici on ne fait que le lire.
import { couleurDuGroupe, nomSansParentheses } from "./historiqueModel";

export type CouleursFamilles = {
  version: number;
  unites: Record<string, string>; // unité de couleur → libellé (ex. "f:rome" → "Rome et Byzance")
  couleurs: Record<string, [string, string]>; // nom d'entité (anglais, sans parenthèses) → [remplissage, contour]
  unite_de: Record<string, string>; // nom d'entité → unité
};

/** Couleur d'une entité : celle du fichier si on la connaît, sinon l'ancienne couleur tirée du nom. */
export function couleurEntite(c: CouleursFamilles | null, nomEntite: string, groupe: string): { remplissage: string; contour: string } {
  const sans = nomSansParentheses(nomEntite);
  const v = c?.couleurs[sans];
  return v ? { remplissage: v[0], contour: v[1] } : couleurDuGroupe(groupe);
}

/** Clé de surbrillance : l'unité de couleur (famille, ensemble…) si connue, sinon le groupe. */
export function cleUnite(c: CouleursFamilles | null, nomEntite: string, groupe: string): string {
  return c?.unite_de[nomSansParentheses(nomEntite)] ?? groupe;
}

/** Libellé de la famille si l'entité appartient à une famille de couleurs (convention), sinon null. */
export function familleDe(c: CouleursFamilles | null, nomEntite: string): string | null {
  const u = c?.unite_de[nomSansParentheses(nomEntite)];
  return u && u.startsWith("f:") ? c!.unites[u] ?? null : null;
}
