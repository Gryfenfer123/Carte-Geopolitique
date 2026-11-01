"""Complète les petites îles dont un contour ne couvre qu'une partie : une île est un tout.

POURQUOI (Martin, 2026-11-01, Terre François-Joseph) : les contours de Cliopatria sont des polygones grossiers posés autour des
îles ; une île de l'Arctique n'est couverte qu'à moitié et déborde en mer. Une petite île n'a, en pratique, qu'un seul maître :
si un contour recouvre déjà au moins SEUIL_COUVERT (50 %) d'une île de la côte GSHHG (≤ MAX_KM2), on lui donne le reste de l'île,
SAUF ce qu'une autre ligne dessine déjà sur les mêmes années (aucun nouveau chevauchement). Les îles ≥ MAX_KM2 (Grande-Bretagne,
Honshu…) et les continents ne sont jamais touchés : leurs frontières internes restent celles de Cliopatria.
On ne fait qu'AJOUTER de la terre émergée réelle (jamais de mer) ; chaque ajout est compté dans le rapport.
Logique pure (shapely), sans réseau."""
import json

import numpy as np
import shapely
from shapely import STRtree
from shapely.geometry import shape
from shapely.validation import make_valid

SEUIL_COUVERT = 0.5
MAX_KM2 = 20000
MIN_AJOUT_KM2 = 0.05


def _km2(g):
    import math
    x0, y0, x1, y1 = g.bounds
    return g.area * 111.32 ** 2 * math.cos(math.radians((y0 + y1) / 2))


def petites_iles(polys):
    """Garde les polygones de terre de moins de MAX_KM2 (îles)."""
    return [make_valid(p) for p in polys if _km2(p) <= MAX_KM2]


def charger_iles(chemin_terres):
    with open(chemin_terres, encoding="utf8") as f:
        polys = [make_valid(shape(x["geometry"])) for x in json.load(f)["features"]]
    return [p for p in polys if _km2(p) <= MAX_KM2]


def completer(entites, dates, iles):
    """entites/dates : listes parallèles (modifiées sur place). iles : polygones de terre (petites îles)."""
    arbre_iles = STRtree(iles)
    iles_arr = np.array(iles, dtype=object)
    # mémoire : les voisins ne sont gardés que sous forme simplifiée (0,003° ≈ 300 m) ; le contour exact de chaque ligne
    # n'est construit qu'au moment de la traiter, puis jeté
    geoms = [shapely.simplify(make_valid(shape(ft["geometry"])).buffer(0), 0.003) for ft in entites]
    arbre_lignes = STRtree(geoms)
    rapport = {"lignes_modifiees": 0, "iles_completees": 0, "km2_ajoutes": 0.0, "exemples": []}
    ajouts = {}
    for k in range(len(entites)):
        g = make_valid(shape(entites[k]["geometry"])).buffer(0)
        if g.is_empty:
            continue
        shapely.prepare(g)
        cand = arbre_iles.query(g, predicate="intersects")
        if len(cand) == 0:
            continue
        # les îles entièrement dans le contour n'ont rien à compléter : on les écarte d'un coup (rapide, géométrie préparée)
        cand = cand[~shapely.contains(g, iles_arr[cand])]
        if len(cand) == 0:
            continue
        voisins = None
        morceaux = []
        for i in cand:
            p = iles[i]
            if p.area <= 0:
                continue
            part = g.intersection(p).area / p.area
            if part < SEUIL_COUVERT or part > 0.999:
                continue
            reste = p.difference(g)
            if voisins is None:  # lignes actives en même temps, qui touchent la ligne
                idx = arbre_lignes.query(g.buffer(0.3))
                voisins = [geoms[j] for j in idx if j != k and dates[j]["a"] >= dates[k]["de"] and dates[j]["de"] <= dates[k]["a"]]
            if voisins:
                autres = [v for v in voisins if v.intersects(p)]
                if autres:
                    reste = reste.difference(shapely.union_all(autres))
            if reste.is_empty or _km2(reste) < MIN_AJOUT_KM2:
                continue
            morceaux.append(reste)
        if morceaux:
            ajouts[k] = shapely.union_all(morceaux)
    for k, ajout in ajouts.items():
        nouvelle = shapely.make_valid(make_valid(shape(entites[k]["geometry"])).buffer(0).union(ajout))
        entites[k]["geometry"] = shapely.geometry.mapping(nouvelle)
        dates[k]["geometrie"] = entites[k]["geometry"]
        rapport["lignes_modifiees"] += 1
        rapport["km2_ajoutes"] += _km2(ajout)
        rapport["iles_completees"] += len(shapely.get_parts(ajout))
        if len(rapport["exemples"]) < 30:
            rapport["exemples"].append({"nom": dates[k]["nom"], "de": dates[k]["de"], "a": dates[k]["a"], "km2": round(_km2(ajout))})
    rapport["km2_ajoutes"] = round(rapport["km2_ajoutes"])
    return rapport
