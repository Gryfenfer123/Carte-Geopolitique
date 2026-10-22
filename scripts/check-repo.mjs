#!/usr/bin/env node
// Contrôle de santé du dépôt — aucune dépendance, aucun accès réseau.
// Lancé par `npm run check:repo`, et automatiquement avant chaque déploiement
// et chaque vérification de branche (voir .github/workflows/).
//
// Il existe parce que des fichiers envoyés à la main sur GitHub avaient créé
// des doublons « nom (1).ts » et des copies à la racine : le site publié
// tournait sur une version périmée sans que rien ne le signale.
//
// Ce que le script vérifie (uniquement sur les fichiers suivis par git) :
//   1. aucun nom de fichier de type doublon : « x (1).ts », « x copie.ts »,
//      « x - Copy.ts », « x.bak », « x.orig » ;
//   2. aucun fichier source (.ts .tsx .js .jsx .css) à la racine, hors
//      fichiers de configuration autorisés : le code vit dans src/ ;
//   3. index.html pointe vers un script qui existe ;
//   4. aucun secret : pas de clé « service_role » ni « sb_secret_ » ;
//   5. migrations Supabase : pas deux fichiers avec le même numéro.
//
// Code de sortie : 0 = tout va bien, 1 = au moins un problème (message clair).

import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const racine = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");
const erreurs = [];

const fichiers = execFileSync("git", ["ls-files", "-z"], { cwd: racine, encoding: "utf8" })
  .split("\0")
  .filter(Boolean);

// 1. Noms de fichiers de type doublon ---------------------------------------
const motifDoublon = / \(\d+\)(\.[^/]+)?$| copie(\.[^/]+)?$| - cop(y|ie)(\.[^/]+)?$|\.(bak|orig)$/i;
for (const f of fichiers) {
  if (motifDoublon.test(f)) {
    erreurs.push(
      `Fichier en doublon : « ${f} ». Probablement un envoi manuel dont le navigateur a renommé le fichier. ` +
        `Supprimer cette copie (le vrai fichier doit garder son nom exact).`,
    );
  }
}

// 2. Fichiers source égarés à la racine -------------------------------------
const autorisesALaRacine = new Set(["vite.config.ts"]);
for (const f of fichiers) {
  if (!f.includes("/") && /\.(ts|tsx|js|jsx|css)$/.test(f) && !autorisesALaRacine.has(f)) {
    erreurs.push(
      `Fichier source à la racine : « ${f} ». Le code doit être dans src/ (le build ignore la racine : ` +
        `ce fichier ne serait jamais utilisé).`,
    );
  }
}

// 3. Le point d'entrée de index.html existe ---------------------------------
if (existsSync(path.join(racine, "index.html"))) {
  const html = readFileSync(path.join(racine, "index.html"), "utf8");
  const m = html.match(/<script[^>]+src="([^"]+)"/);
  if (!m) {
    erreurs.push("index.html ne contient aucune balise <script src=…>.");
  } else {
    const cible = m[1].replace(/^\//, "");
    if (!fichiers.includes(cible)) {
      erreurs.push(`index.html charge « ${m[1]} » mais ce fichier n'existe pas dans le dépôt.`);
    }
  }
} else {
  erreurs.push("index.html est introuvable.");
}

// 4. Secrets ------------------------------------------------------------------
// On ignore la documentation et ce script, qui citent ces mots pour les interdire.
const exemptesSecrets = (f) => f.startsWith("docs/") || f === "CLAUDE.md" || f === "README.md" || f === ".env.example" || f === "scripts/check-repo.mjs";
const motifSecret = /service_role|sb_secret_/;
for (const f of fichiers) {
  if (exemptesSecrets(f)) continue;
  if (/\.(png|jpg|jpeg|gif|webp|ico|woff2?|pdf|zip)$/i.test(f)) continue;
  let contenu;
  try {
    contenu = readFileSync(path.join(racine, f), "utf8");
  } catch {
    continue;
  }
  if (motifSecret.test(contenu)) {
    erreurs.push(
      `Secret possible dans « ${f} » (« service_role » ou « sb_secret_ »). Retirer immédiatement, ` +
        `et changer la clé dans Supabase si elle a été publiée.`,
    );
  }
}

// 5. Numéros de migration uniques ---------------------------------------------
const parNumero = new Map();
for (const f of fichiers) {
  const m = f.match(/^supabase\/schema_v(\d+)[^/]*\.sql$/);
  if (!m) continue;
  const n = Number(m[1]);
  parNumero.set(n, [...(parNumero.get(n) ?? []), f]);
}
for (const [n, liste] of parNumero) {
  if (liste.length > 1) {
    erreurs.push(`Deux migrations portent le numéro v${n} : ${liste.join(", ")}. Un numéro = un seul fichier.`);
  }
}

// Résultat ----------------------------------------------------------------------
if (erreurs.length > 0) {
  console.error(`\n✘ check:repo — ${erreurs.length} problème(s) :\n`);
  for (const e of erreurs) console.error(` • ${e}\n`);
  process.exit(1);
}
console.log(`✔ check:repo — ${fichiers.length} fichiers suivis, aucun problème détecté.`);
