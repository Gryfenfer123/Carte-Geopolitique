// ---------------------------------------------------------------------------
// Carte historique — logique pure (sans écran, sans réseau), testée par
// scripts/historique/tester-modele.mjs.
//
// Données : Cliopatria v0.2.1 (Seshat Global History Databank, CC BY 4.0),
// préparées par scripts/historique/preparer_cliopatria.py — le format des
// fichiers est décrit en tête de ce script. Une « ligne » dit : de l'année
// `debut` à l'année `fin` incluses, cette entité a CE tracé. Les années sont
// celles de la source (négatives avant J.-C.).
//
// Demande de Martin (2026-10-23) : « l'évolution année après année de
// l'ensemble de la carte du monde » → pour une année donnée on retrouve les
// lignes qui la contiennent ; la source n'a pas un tracé par année mais un
// tracé par période (durée médiane ≈ 8 ans), c'est sa résolution réelle.
// ---------------------------------------------------------------------------

export const ANNEE_MIN = -3400;
export const ANNEE_MAX = 2024;

/** [indexMeta, anneeDebut, anneeFin, idTrace, indexNomEnsemble (-1 si aucun), aireKm2] */
export type Ligne = [meta: number, debut: number, fin: number, trace: number, ensemble: number, aire: number];
/** [indexNom, pageWikipedia, idWikidata, idSeshat] */
export type Meta = [nom: number, wikipedia: string, wikidata: string, seshat: string];

export type HistoriqueIndex = {
  version: string;
  noms: string[];
  meta: Meta[];
  lignes: Ligne[];
  /** [premierIdTrace, nombreDeTraces] pour chaque fichier geo_NNN.json */
  morceaux: [number, number][];
};

/** Un tracé tel que stocké : polygones → anneaux → entiers (voir preparer_cliopatria.py). */
export type TraceCodee = number[][][];

export type TraceDecodee = {
  /** polygones → anneaux → [latitude, longitude] (le 1er anneau est le contour, les suivants des trous) */
  latlngs: [number, number][][][];
  /** centre du plus grand polygone (où poser une étiquette) */
  centre: [number, number];
  /** boîte [[sud, ouest], [nord, est]] du plus grand polygone */
  boite: [[number, number], [number, number]];
};

const CENTIEMES = 100;

/** « 1550 », « 202 av. J.-C. ». L'année 0 existe dans la source : elle est affichée telle quelle. */
export function formatAnnee(annee: number): string {
  return annee < 0 ? `${-annee} av. J.-C.` : String(annee);
}

/** Durée lisible d'une période : « 1547–1551 », « 320 av. J.-C. – 301 av. J.-C. », « 1550 » si une seule année. */
export function formatPeriode(debut: number, fin: number): string {
  if (debut === fin) return formatAnnee(debut);
  return debut < 0 && fin < 0 ? `${-debut}–${-fin} av. J.-C.` : `${formatAnnee(debut)} – ${formatAnnee(fin)}`;
}

/** Ramène une année saisie ou calculée dans les bornes de la source. */
export function bornerAnnee(annee: number): number {
  if (!Number.isFinite(annee)) return ANNEE_MIN;
  return Math.max(ANNEE_MIN, Math.min(ANNEE_MAX, Math.round(annee)));
}

/** Les lignes à peindre pour cette année, les plus grandes d'abord (les petits territoires se dessinent par-dessus). */
export function lignesALAnnee(index: HistoriqueIndex, annee: number): Ligne[] {
  const lignes = index.lignes.filter((l) => l[1] <= annee && annee <= l[2]);
  lignes.sort((a, b) => b[5] - a[5]);
  return lignes;
}

/** « (Holy Roman Empire) » → « Holy Roman Empire ». Les parenthèses de la source marquent un ensemble. */
export function nomSansParentheses(nom: string): string {
  return nom.startsWith("(") && nom.endsWith(")") ? nom.slice(1, -1) : nom;
}

export function nomDeLigne(index: HistoriqueIndex, ligne: Ligne): string {
  return index.noms[index.meta[ligne[0]][0]];
}

/** Le « groupe » d'une ligne : l'ensemble dont elle est membre (ex. Saint-Empire), sinon l'entité elle-même. */
export function groupeDeLigne(index: HistoriqueIndex, ligne: Ligne): string {
  return ligne[4] >= 0 ? nomSansParentheses(index.noms[ligne[4]]) : nomDeLigne(index, ligne);
}

/** Couleur stable d'un groupe : même nom → même couleur à toutes les époques. */
export function couleurDuGroupe(groupe: string): { remplissage: string; contour: string } {
  let h = 2166136261; // FNV-1a
  for (let i = 0; i < groupe.length; i++) {
    h ^= groupe.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  const teinte = (h >>> 0) % 360;
  const sat = 48 + ((h >>> 9) % 22); // 48–69 %
  const clair = 46 + ((h >>> 17) % 14); // 46–59 %
  return { remplissage: `hsl(${teinte} ${sat}% ${clair}%)`, contour: `hsl(${teinte} ${sat}% ${Math.max(18, clair - 24)}%)` };
}

/** Numéro du fichier geo_NNN.json qui contient ce tracé (recherche par dichotomie). */
export function morceauDeTrace(index: HistoriqueIndex, idTrace: number): number {
  let bas = 0;
  let haut = index.morceaux.length - 1;
  while (bas < haut) {
    const milieu = (bas + haut + 1) >> 1;
    if (index.morceaux[milieu][0] <= idTrace) bas = milieu;
    else haut = milieu - 1;
  }
  return bas;
}

/** Les fichiers à charger pour dessiner ces lignes. */
export function morceauxNecessaires(index: HistoriqueIndex, lignes: Ligne[]): number[] {
  const numeros = new Set<number>();
  for (const l of lignes) numeros.add(morceauDeTrace(index, l[3]));
  return [...numeros].sort((a, b) => a - b);
}

/** Décode un tracé stocké en écarts entiers vers des coordonnées prêtes pour la carte. */
export function decoderTrace(trace: TraceCodee): TraceDecodee {
  const latlngs: [number, number][][][] = [];
  let meilleureAire = -1;
  let centre: [number, number] = [0, 0];
  let boite: [[number, number], [number, number]] = [[0, 0], [0, 0]];
  for (const polygone of trace) {
    const anneaux: [number, number][][] = [];
    for (const plat of polygone) {
      let x = plat[0];
      let y = plat[1];
      const points: [number, number][] = [[y / CENTIEMES, x / CENTIEMES]];
      for (let i = 2; i < plat.length; i += 2) {
        x += plat[i];
        y += plat[i + 1];
        points.push([y / CENTIEMES, x / CENTIEMES]);
      }
      anneaux.push(points);
    }
    latlngs.push(anneaux);
    // Aire signée (formule du lacet) et centre de gravité du contour extérieur.
    const ext = anneaux[0];
    let aire2 = 0;
    let cx = 0;
    let cy = 0;
    let sud = Infinity;
    let nord = -Infinity;
    let ouest = Infinity;
    let est = -Infinity;
    for (let i = 0; i < ext.length; i++) {
      const [la0, lo0] = ext[i];
      const [la1, lo1] = ext[(i + 1) % ext.length];
      const croix = lo0 * la1 - lo1 * la0;
      aire2 += croix;
      cx += (lo0 + lo1) * croix;
      cy += (la0 + la1) * croix;
      sud = Math.min(sud, la0);
      nord = Math.max(nord, la0);
      ouest = Math.min(ouest, lo0);
      est = Math.max(est, lo0);
    }
    const aire = Math.abs(aire2) / 2;
    if (aire > meilleureAire) {
      meilleureAire = aire;
      boite = [[sud, ouest], [nord, est]];
      // Un contour quasi plat n'a pas de centre de gravité fiable : on prend le milieu de sa boîte.
      centre = aire2 === 0 ? [(sud + nord) / 2, (ouest + est) / 2] : [cy / (3 * aire2), cx / (3 * aire2)];
      // Contour très concave (ex. croissant) : le centre de gravité peut sortir de la boîte, on le ramène dedans.
      centre = [Math.min(nord, Math.max(sud, centre[0])), Math.min(est, Math.max(ouest, centre[1]))];
    }
  }
  return { latlngs, centre, boite };
}

export function lienWikipedia(meta: Meta): string | null {
  return meta[1] ? `https://en.wikipedia.org/wiki/${encodeURIComponent(meta[1].replace(/ /g, "_"))}` : null;
}

export function lienWikidata(meta: Meta): string | null {
  return /^Q\d+$/.test(meta[2]) ? `https://www.wikidata.org/wiki/${meta[2]}` : null;
}
