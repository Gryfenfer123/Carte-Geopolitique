// ---------------------------------------------------------------------------
// Carte historique — chargement des données (réseau + mémoire).
//
// L'index (≈ 0,6 Mo, quelques dizaines de Ko une fois compressé par le serveur)
// est chargé une fois ; les tracés, eux, sont répartis en ~28 fichiers de
// ~450 Ko classés dans l'ordre où les entités apparaissent dans l'histoire :
// on ne télécharge que ceux dont l'année affichée a besoin, puis on les garde.
// Format : voir scripts/historique/preparer_cliopatria.py.
// ---------------------------------------------------------------------------

import { morceauDeTrace, morceauxNecessaires } from "./historiqueModel";
import type { HistoriqueIndex, Ligne, NomsFr, TraceCodee } from "./historiqueModel";

const BASE = import.meta.env.BASE_URL + "data/historique/";

let promesseIndex: Promise<HistoriqueIndex> | null = null;
const charges = new Map<number, TraceCodee[]>();
const enCours = new Map<number, Promise<void>>();

export function chargerIndex(): Promise<HistoriqueIndex> {
  if (!promesseIndex) {
    promesseIndex = fetch(BASE + "index.json")
      .then((r) => {
        if (!r.ok) throw new Error("HTTP " + r.status);
        return r.json() as Promise<HistoriqueIndex>;
      })
      .catch((e) => {
        promesseIndex = null; // permet de réessayer plus tard
        throw e;
      });
  }
  return promesseIndex;
}

let promesseNoms: Promise<NomsFr | null> | null = null;

/** Noms français (noms_fr.json). Jamais bloquant : en cas d'échec on affiche les noms d'origine. */
export function chargerNomsFr(): Promise<NomsFr | null> {
  promesseNoms ??= fetch(BASE + "noms_fr.json")
    .then((r) => {
      if (!r.ok) throw new Error("HTTP " + r.status);
      return r.json() as Promise<NomsFr>;
    })
    .catch((e) => {
      console.warn("Vue historique : noms français indisponibles, noms d'origine affichés", e);
      return null;
    });
  return promesseNoms;
}

function chargerMorceau(numero: number): Promise<void> {
  if (charges.has(numero)) return Promise.resolve();
  let p = enCours.get(numero);
  if (!p) {
    p = fetch(BASE + "geo_" + String(numero).padStart(3, "0") + ".json")
      .then((r) => {
        if (!r.ok) throw new Error("HTTP " + r.status);
        return r.json() as Promise<TraceCodee[]>;
      })
      .then((traces) => {
        charges.set(numero, traces);
      })
      .finally(() => {
        enCours.delete(numero);
      });
    enCours.set(numero, p);
  }
  return p;
}

/** Charge (si besoin) tous les fichiers nécessaires pour dessiner ces lignes. */
export function assurerTraces(index: HistoriqueIndex, lignes: Ligne[]): Promise<void> {
  return Promise.all(morceauxNecessaires(index, lignes).map(chargerMorceau)).then(() => undefined);
}

/** Le tracé codé d'une ligne, s'il est déjà chargé. */
export function traceChargee(index: HistoriqueIndex, idTrace: number): TraceCodee | undefined {
  const numero = morceauDeTrace(index, idTrace);
  return charges.get(numero)?.[idTrace - index.morceaux[numero][0]];
}
