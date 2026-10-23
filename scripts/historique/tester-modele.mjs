#!/usr/bin/env node
// Teste la logique pure de la carte historique (src/historiqueModel.ts) sur les VRAIES données du dépôt
// (public/data/historique/). Lancer : node scripts/historique/tester-modele.mjs   (Node 22.18 ou plus récent,
// qui sait lire le TypeScript directement). Sortie 0 = tout passe, 1 = au moins un échec.
import { readFileSync } from "node:fs";
import path from "node:path";
import * as M from "../../src/historiqueModel.ts";

const racine = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..", "..", "public", "data", "historique");
const index = JSON.parse(readFileSync(path.join(racine, "index.json"), "utf8"));
const morceaux = index.morceaux.map((_, i) => JSON.parse(readFileSync(path.join(racine, `geo_${String(i).padStart(3, "0")}.json`), "utf8")));
const trace = (id) => {
  const m = M.morceauDeTrace(index, id);
  return morceaux[m][id - index.morceaux[m][0]];
};

let echecs = 0;
const verifier = (condition, message) => {
  if (!condition) {
    echecs++;
    console.error("  ✘ " + message);
  }
};
const noms = (annee) => new Set(M.lignesALAnnee(index, annee).map((l) => M.nomDeLigne(index, l)));
const groupes = (annee) => new Set(M.lignesALAnnee(index, annee).map((l) => M.groupeDeLigne(index, l)));

// Affichage des années
verifier(M.formatAnnee(1550) === "1550", "formatAnnee(1550)");
verifier(M.formatAnnee(-202) === "202 av. J.-C.", "formatAnnee(-202)");
verifier(M.formatAnnee(0) === "0", "formatAnnee(0)");
verifier(M.formatPeriode(1547, 1551) === "1547 – 1551", "formatPeriode ap. J.-C.");
verifier(M.formatPeriode(-320, -301) === "320–301 av. J.-C.", "formatPeriode av. J.-C.");
verifier(M.formatPeriode(1550, 1550) === "1550", "formatPeriode une seule année");
verifier(M.bornerAnnee(99999) === M.ANNEE_MAX && M.bornerAnnee(-99999) === M.ANNEE_MIN, "bornerAnnee");
verifier(M.bornerAnnee(NaN) === M.ANNEE_MIN, "bornerAnnee(NaN)");
verifier(M.nomSansParentheses("(Holy Roman Empire)") === "Holy Roman Empire" && M.nomSansParentheses("France") === "France", "nomSansParentheses");

// Chaque année de la source a au moins un territoire à peindre, et jamais deux fois la même ligne
for (let a = M.ANNEE_MIN; a <= M.ANNEE_MAX; a++) {
  const l = M.lignesALAnnee(index, a);
  if (l.length === 0) verifier(false, `aucune ligne en ${a}`);
  for (let i = 1; i < l.length; i++) if (l[i - 1][5] < l[i][5]) { verifier(false, `tri par aire cassé en ${a}`); break; }
}

// Cas de test historiques (Martin : Saint-Empire, Chine, Mongols, Ottomans…)
const attendu = [
  [-500, "Achaemenid Empire"], [-100, "Roman Republic"], [100, "Han Dynasty"], [100, "Roman Empire"], [750, "Abbasid Caliphate"],
  [800, "Byzantine Empire"], [1250, "Mongol Empire"], [1500, "Ming Dynasty"], [1550, "Ottoman Empire"], [1550, "Kingdom of France"],
  [1550, "Holy Roman Empire Minor States"], [1700, "Qing Dynasty"], [1900, "Qing Dynasty"], [1914, "German Empire"], [1914, "Austria-Hungary"],
];
for (const [annee, nom] of attendu) verifier(noms(annee).has(nom), `« ${nom} » devrait figurer en ${annee}`);
verifier(!noms(1500).has("Qing Dynasty"), "Qing ne doit pas exister en 1500");
verifier(!noms(100).has("Ming Dynasty"), "Ming ne doit pas exister en 100");

// Groupes : les membres du Saint-Empire partagent le groupe « Holy Roman Empire »
verifier(groupes(1550).has("Holy Roman Empire"), "groupe « Holy Roman Empire » en 1550");
verifier(!groupes(1550).has("(Holy Roman Empire)"), "les parenthèses doivent disparaître du groupe");
const c1 = M.couleurDuGroupe("Holy Roman Empire");
verifier(c1.remplissage === M.couleurDuGroupe("Holy Roman Empire").remplissage, "couleur stable pour un même groupe");
verifier(c1.remplissage !== M.couleurDuGroupe("Kingdom of France").remplissage, "couleurs différentes pour deux groupes différents");
verifier(/^hsl\(\d+ \d+% \d+%\)$/.test(c1.remplissage) && /^hsl\(\d+ \d+% \d+%\)$/.test(c1.contour), "format de couleur");

// Morceaux : la recherche par dichotomie retrouve bien le bon fichier pour chaque tracé
let total = 0;
index.morceaux.forEach(([premier, nombre], m) => {
  total += nombre;
  verifier(morceaux[m].length === nombre, `morceau ${m} : nombre de tracés`);
  for (const id of [premier, premier + nombre - 1]) verifier(M.morceauDeTrace(index, id) === m, `morceauDeTrace(${id}) ≠ ${m}`);
});
verifier(total === Math.max(...index.lignes.map((l) => l[3])) + 1, "nombre total de tracés = plus grand identifiant + 1");
const n1550 = M.morceauxNecessaires(index, M.lignesALAnnee(index, 1550));
verifier(n1550.length > 0 && n1550.length <= index.morceaux.length && n1550.every((x, i) => i === 0 || n1550[i - 1] < x), "morceauxNecessaires trié et sans doublon");

// Décodage : tous les tracés se décodent, restent sur le globe, et l'étiquette tombe dans la boîte du plus grand polygone
let invalides = 0;
for (let id = 0; id < total; id++) {
  const d = M.decoderTrace(trace(id));
  const [[s, o], [n, e]] = d.boite;
  if (!(d.centre[0] >= s && d.centre[0] <= n && d.centre[1] >= o && d.centre[1] <= e)) invalides++;
  for (const anneaux of d.latlngs) for (const anneau of anneaux) for (const [la, lo] of anneau) {
    if (!(la >= -90.5 && la <= 90.5 && lo >= -180.5 && lo <= 180.5)) { verifier(false, `tracé ${id} hors du globe`); break; }
  }
}
verifier(invalides === 0, `${invalides} tracé(s) dont le centre sort de la boîte`);

// Exemple concret : la France de 1550 doit se décoder en un territoire situé à peu près au bon endroit
const france = M.lignesALAnnee(index, 1550).find((l) => M.nomDeLigne(index, l) === "Kingdom of France");
const df = M.decoderTrace(trace(france[3]));
verifier(df.centre[0] > 42 && df.centre[0] < 51 && df.centre[1] > -5 && df.centre[1] < 8, `centre du royaume de France en 1550 : ${df.centre}`);

// Liens
const meta = index.meta[france[0]];
verifier((M.lienWikidata(meta) ?? "").startsWith("https://www.wikidata.org/wiki/Q"), "lien Wikidata");
verifier((M.lienWikipedia(meta) ?? "").startsWith("https://en.wikipedia.org/wiki/"), "lien Wikipédia");
verifier(M.lienWikidata(["x", "", "", ""]) === null && M.lienWikipedia(["x", "", "", ""]) === null, "liens absents → null");

// Noms français
const nomsFr = JSON.parse(readFileSync(path.join(racine, "noms_fr.json"), "utf8"));
verifier(M.nomAffiche(nomsFr, "Ming Dynasty") === "Dynastie Ming", `Ming : ${M.nomAffiche(nomsFr, "Ming Dynasty")}`);
verifier(M.nomAffiche(nomsFr, "(Holy Roman Empire)") === "Saint-Empire romain germanique", "ensemble entre parenthèses → français");
verifier(M.nomAffiche(nomsFr, "(Kingdom of the Franks);(Merovingian Empire)") === "Royaume des Francs / Empire mérovingien", "ensemble double");
verifier(M.nomAffiche(null, "Ming Dynasty") === "Ming Dynasty", "sans fichier français → nom d'origine");
verifier(M.nomAffiche(nomsFr, "Nom inconnu xyz") === "Nom inconnu xyz", "nom inconnu → inchangé");
verifier(M.nomAffiche({ version: 1, fr: { x: "élam" }, traduits: [] }, "x") === "Élam", "première lettre en majuscule");
verifier(M.estTraduction(nomsFr, "Roman Empire") === true && M.estTraduction(nomsFr, "Ming Dynasty") === false, "drapeau traduction");
const sansFr = new Set();
for (const m of index.meta) if (!nomsFr.fr[M.nomSansParentheses(index.noms[m[0]])]) sansFr.add(index.noms[m[0]]);
verifier(sansFr.size === 0, `${sansFr.size} entité(s) sans nom français : ${[...sansFr].slice(0, 5)}`);
verifier(nomsFr.traduits.every((n) => n in nomsFr.fr), "chaque traduction listée existe");

if (echecs > 0) {
  console.error(`\n✘ ${echecs} échec(s)`);
  process.exit(1);
}
console.log(`✔ historiqueModel : tous les tests passent (${index.lignes.length} lignes, ${total} tracés, ${M.ANNEE_MAX - M.ANNEE_MIN + 1} années contrôlées)`);
