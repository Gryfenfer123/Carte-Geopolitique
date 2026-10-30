#!/usr/bin/env python3
"""Audit A4 (LECTURE SEULE) : après les corrections de dates et de formes, quelles entités se recouvrent encore ?
Même méthode que a3 mais sur les contours CORRIGÉS (fichier écrit par `preparer_cliopatria.py --arret-apres-formes`).
Pour chaque paire (recouvrement d'au moins 50 % du plus petit des deux contours) on note : années communes, part recouverte,
intervalle d'existence de chaque entité sur la carte, surface de chaque contour (degrés², sans correction de latitude : sert
seulement à comparer deux contours entre eux).
Usage : python3 -I a4_chevauchements_corriges.py <_apres_formes.geojson> <sortie.json>"""
import json, sys, collections
from shapely.geometry import shape
from shapely import STRtree, make_valid

SEUIL = float(sys.argv[3]) if len(sys.argv) > 3 else 0.5   # part minimale du plus petit contour recouverte
F = json.load(open(sys.argv[1], encoding="utf8"))["features"]
L = []
iv = collections.defaultdict(lambda: [9999, -9999])
for ft in F:
    p = ft["properties"]
    if p["Type"] != "POLITY" or p["Name"].startswith("(") or p["ToYear"] < -700:
        continue
    g = make_valid(shape(ft["geometry"])).buffer(0)
    if g.is_empty:
        continue
    L.append((p["Name"], p["FromYear"], p["ToYear"], p.get("MemberOf") or "", g, g.area))
    iv[p["Name"]][0] = min(iv[p["Name"]][0], p["FromYear"])
    iv[p["Name"]][1] = max(iv[p["Name"]][1], p["ToYear"])
T = STRtree([x[4] for x in L])
res = {}
for i, (n, d, a, m, g, ar) in enumerate(L):
    for j in T.query(g):
        if j <= i:
            continue
        n2, d2, a2, m2, g2, ar2 = L[j]
        if n == n2 or (m and m == m2):
            continue
        lo, hi = max(d, d2), min(a, a2)
        if lo > hi:
            continue
        inter = g.intersection(g2).area
        part = inter / min(ar, ar2)
        if part < SEUIL:
            continue
        k = tuple(sorted((n, n2)))
        e = res.setdefault(k, {"de": lo, "a": hi, "part": part, "deg2": inter, "m": [m, m2] if (n, n2) == k else [m2, m],
                               "aire": {n: ar, n2: ar2}})
        e["de"], e["a"] = min(e["de"], lo), max(e["a"], hi)
        e["part"], e["deg2"] = max(e["part"], part), max(e["deg2"], inter)
        e["aire"][n], e["aire"][n2] = max(e["aire"][n], ar), max(e["aire"][n2], ar2)
sortie = [{"x": k[0], "y": k[1], **v, "existe": {k[0]: iv[k[0]], k[1]: iv[k[1]]}} for k, v in res.items()]
sortie.sort(key=lambda x: -x["deg2"])
json.dump(sortie, open(sys.argv[2], "w", encoding="utf8"), ensure_ascii=False, indent=0)
print(len(sortie), "paires")
