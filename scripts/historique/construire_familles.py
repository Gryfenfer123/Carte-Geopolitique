#!/usr/bin/env python3
"""Construit public/data/historique/couleurs.json : la couleur de chaque entité, par FAMILLE d'États.

POURQUOI (Martin, 2026-11-12) : « un code couleur pour un empire et ses successions, c'est primordial ».
Avant : une couleur tirée du nom (le hasard), sans notion de lignée. Maintenant : une UNITÉ de couleur est
  - une FAMILLE (lignée d'États, ex. Rome → Byzance ; définie dans familles/familles.json, avec sources), ou
  - un ENSEMBLE Cliopatria (champ MemberOf, ex. Empire britannique), ou
  - une entité seule (couleur plus discrète : pas de famille connue).
Les membres d'une même famille ont la MÊME teinte et des nuances de clarté qui alternent dans l'ordre chronologique
(deux étapes voisines restent distinguables). Deux unités qui se touchent sur la carte (au même moment) reçoivent des
couleurs aussi éloignées que possible (coloration de graphe sur les voisinages réels, mesurée dans l'espace OKLab).

Seules les familles dont le statut est « source » sont utilisées (voir docs/sources/historique_familles.md).

Usage : python3 -I scripts/historique/construire_familles.py   (après preparer_cliopatria.py ; ne touche pas aux tracés)
"""
import importlib.util
import json
import math
import os
import random
import sys
from collections import defaultdict

import shapely
from shapely import STRtree

ICI = os.path.dirname(os.path.abspath(__file__))
DONNEES = os.path.join(ICI, "..", "..", "public", "data", "historique")
SORTIE = sys.argv[1] if len(sys.argv) > 1 else DONNEES
ECHANTILLON = 25          # on regarde les voisinages tous les 25 ans
DISTANCE_VOISIN = 0.15    # degrés : deux territoires à moins de ça sont « voisins »
TEINTES = list(range(0, 360, 12))   # 30 teintes candidates
CLARTES = (0.52, 0.63, 0.74)        # trois niveaux de clarté de base (OKLCH)
CHROMA_UNITE = 0.15                 # familles et ensembles : couleurs franches
CHROMA_SEUL = 0.085                 # entités seules : plus discrètes
PAS_CLARTE = (-0.065, 0.0, 0.065)   # nuances alternées entre membres successifs d'une famille


def charger(nom, fichier):
    spec = importlib.util.spec_from_file_location(nom, os.path.join(ICI, fichier))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


# ---- couleurs (OKLCH → sRGB) -------------------------------------------------------------------
def oklch_vers_oklab(L, C, h):
    return L, C * math.cos(math.radians(h)), C * math.sin(math.radians(h))


def oklab_vers_srgb(L, a, b):
    l_ = L + 0.3963377774 * a + 0.2158037573 * b
    m_ = L - 0.1055613458 * a - 0.0638541728 * b
    s_ = L - 0.0894841775 * a - 1.2914855480 * b
    l, m, s = l_ ** 3, m_ ** 3, s_ ** 3
    r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    bl = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s

    def gamma(x):
        x = max(0.0, min(1.0, x))
        return 12.92 * x if x <= 0.0031308 else 1.055 * x ** (1 / 2.4) - 0.055

    return gamma(r), gamma(g), gamma(bl)


def hex_de(L, C, h):
    r, g, b = oklab_vers_srgb(*oklch_vers_oklab(L, C, h))
    return "#%02x%02x%02x" % (round(r * 255), round(g * 255), round(b * 255))


def distance(c1, c2):
    a, b = oklch_vers_oklab(*c1), oklch_vers_oklab(*c2)
    return math.dist(a, b)


def main():
    lacs = charger("lacs", "lacs_completes.py")
    index = json.load(open(os.path.join(DONNEES, "index.json"), encoding="utf8"))
    E = index.get("echelle", 100)
    noms = index["noms"]
    sans = lambda n: n.strip("()") if n.startswith("(") and n.endswith(")") else n

    # --- familles (seulement celles qui ont leurs sources) ---
    fam_def = json.load(open(os.path.join(ICI, "familles", "familles.json"), encoding="utf8"))["familles"]
    # TOUTES_FAMILLES=1 : essai visuel seulement (ne jamais publier le résultat)
    familles = [f for f in fam_def if f.get("statut") == "source" or os.environ.get("TOUTES_FAMILLES")]
    print(len(familles), "familles actives sur", len(fam_def), flush=True)
    nom_vers_fam = {}
    toutes = {sans(n) for n in noms}
    for f in familles:
        for m in f["membres"]:
            if m not in toutes:
                sys.exit("Membre inconnu dans l'index : %r (famille %s)" % (m, f["id"]))
            if m in nom_vers_fam:
                sys.exit("Membre dans deux familles : %r" % m)
            nom_vers_fam[m] = f["id"]
    rang = {}
    for f in familles:
        for k, m in enumerate(f["membres"]):
            rang[m] = k

    # --- unités de couleur ---
    def unite(ligne):
        n = sans(noms[index["meta"][ligne[0]][0]])
        g = sans(noms[ligne[4]]) if ligne[4] >= 0 else None
        if n in nom_vers_fam:
            return "f:" + nom_vers_fam[n]
        if g and g in nom_vers_fam:
            return "f:" + nom_vers_fam[g]
        if g:
            return "g:" + g
        return "e:" + n

    lignes = index["lignes"]
    groupe_ligne = [noms[index["meta"][l[0]][0]].startswith("(") for l in lignes]
    unites = {}
    importance = defaultdict(float)
    for i, l in enumerate(lignes):
        if groupe_ligne[i]:
            continue
        u = unite(l)
        unites[i] = u
        importance[u] += (l[5] or 0) * (l[2] - l[1] + 1)
    print(len(importance), "unités de couleur", flush=True)

    # --- voisinages réels (même moment) ---
    traces = {}
    for m, (premier, n) in enumerate(index["morceaux"]):
        for k, t in enumerate(json.load(open(os.path.join(DONNEES, "geo_%03d.json" % m), encoding="utf8"))):
            traces[premier + k] = t
    cache = {}

    def geom(i):
        k = lignes[i][3]
        if k not in cache:
            cache[k] = shapely.simplify(lacs.decoder(traces[k], E), 0.02)
        return cache[k]

    poids = defaultdict(int)
    for an in range(-700, 2025, ECHANTILLON):
        actifs = [i for i in unites if lignes[i][1] <= an <= lignes[i][2]]
        if len(actifs) < 2:
            continue
        gs = [geom(i) for i in actifs]
        arbre = STRtree(gs)
        a, b = arbre.query(gs, predicate="dwithin", distance=DISTANCE_VOISIN)
        for x, y in zip(a, b):
            if x < y:
                u1, u2 = unites[actifs[x]], unites[actifs[y]]
                if u1 != u2:
                    poids[(min(u1, u2), max(u1, u2))] += 1
    voisins = defaultdict(dict)
    for (u1, u2), w in poids.items():
        voisins[u1][u2] = w
        voisins[u2][u1] = w
    print(len(poids), "paires de voisins", flush=True)

    # --- choix des couleurs de base (glouton, puis améliorations) ---
    candidats = [(L, h) for h in TEINTES for L in CLARTES]
    random.seed(7)

    def base(u, choix):
        L, h = choix
        return (L, CHROMA_SEUL if u.startswith("e:") else CHROMA_UNITE, h)

    ordre = sorted(importance, key=lambda u: -importance[u])
    attribue = {}
    usage = defaultdict(int)

    def cout(u, choix):
        c = base(u, choix)
        pire = 9.0
        for v, w in voisins[u].items():
            if v in attribue:
                d = distance(c, base(v, attribue[v]))
                pire = min(pire, d / (1 + 0.15 * math.log(w)))
        return pire - 0.002 * usage[choix]

    for u in ordre:
        attribue[u] = max(candidats, key=lambda ch: cout(u, ch))
        usage[attribue[u]] += 1
    for _ in range(3):
        for u in ordre:
            usage[attribue[u]] -= 1
            attribue[u] = max(candidats, key=lambda ch: cout(u, ch))
            usage[attribue[u]] += 1
    pires = []
    for (u1, u2), w in poids.items():
        pires.append((distance(base(u1, attribue[u1]), base(u2, attribue[u2])), w, u1, u2))
    pires.sort()
    print("distances de voisins les plus faibles (OKLab ; > 0.10 = bien distinguables) :")
    for d, w, u1, u2 in pires[:8]:
        print("  %.3f  (%d échantillons)  %s | %s" % (d, w, u1, u2))

    # --- couleur de chaque entité ---
    couleurs = {}   # nom d'entité ou d'ensemble (sans parenthèses) -> [remplissage, contour]
    unite_de = {}   # idem -> identifiant d'unité
    for i, u in unites.items():
        n = sans(noms[index["meta"][lignes[i][0]][0]])
        L, h = attribue[u]
        if u.startswith("f:"):
            r = rang.get(n)
            if r is None:   # entité qui n'est pas dans la liste mais dont l'ensemble l'est : nuance de l'ensemble
                g = sans(noms[lignes[i][4]])
                r = rang[g]
            L = max(0.5, min(0.9, L + PAS_CLARTE[r % 3]))
        c = base(u, (L, h))
        couleurs[n] = [hex_de(*c), hex_de(max(0.30, c[0] - 0.24), c[1], c[2])]
        unite_de[n] = u
    # étiquettes lisibles des unités
    etiq = {}
    for f in familles:
        etiq["f:" + f["id"]] = f["nom"]
    sortie = {
        "version": 1,
        "unites": {u: etiq.get(u, u[2:]) for u in set(unite_de.values())},
        "couleurs": couleurs,
        "unite_de": unite_de,
    }
    chemin = os.path.join(SORTIE, "couleurs.json")
    with open(chemin, "w", encoding="utf8") as f:
        json.dump(sortie, f, ensure_ascii=False, separators=(",", ":"))
    n_fam = sum(1 for v in unite_de.values() if v.startswith("f:"))
    print("couleurs.json :", len(couleurs), "entités dont", n_fam, "dans une famille ;", round(os.path.getsize(chemin) / 1024), "Ko")


if __name__ == "__main__":
    main()
