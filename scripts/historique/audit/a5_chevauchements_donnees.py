"""Audit des chevauchements sur les DONNÉES FINALES (public/data/historique) : pour des années échantillons, liste les paires
de lignes actives dont les contours se recouvrent de plus de SEUIL degrés² (≈ 12 000 km² par degré²).
Usage : python3 -I a5_chevauchements_donnees.py <sortie.json> [seuil_deg2=0.005]"""
import json, os, sys
import shapely
from shapely import STRtree
from shapely.geometry import Polygon

RACINE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "public", "data", "historique")
index = json.load(open(os.path.join(RACINE, "index.json"), encoding="utf8"))
E = index.get("echelle", 100)
seuil = float(sys.argv[2]) if len(sys.argv) > 2 else 0.005
traces = {}
for m, (premier, n) in enumerate(index["morceaux"]):
    for k, t in enumerate(json.load(open(os.path.join(RACINE, "geo_%03d.json" % m), encoding="utf8"))):
        traces[premier + k] = t


def poly(t):
    ps = []
    for p in t:
        rings = []
        for a in p:
            x, y = a[0], a[1]; pts = [(x / E, y / E)]
            for i in range(2, len(a), 2):
                x += a[i]; y += a[i + 1]; pts.append((x / E, y / E))
            rings.append(pts)
        ps.append(Polygon(rings[0], rings[1:]))
    return shapely.make_valid(shapely.union_all(ps))


cache = {}
res = {}
annees = list(range(-700, 1500, 50)) + list(range(1500, 2025, 5))
for an in annees:
    act = [l for l in index["lignes"] if l[1] <= an <= l[2] and not index["noms"][index["meta"][l[0]][0]].startswith("(")]
    gs = []
    for l in act:
        if l[3] not in cache:
            cache[l[3]] = poly(traces[l[3]])
        gs.append(cache[l[3]])
    arbre = STRtree(gs)
    for i, g in enumerate(gs):
        for j in arbre.query(g):
            if j <= i:
                continue
            a = g.intersection(gs[j]).area
            if a > seuil:
                x, y = (index["noms"][index["meta"][act[i][0]][0]], index["noms"][index["meta"][act[j][0]][0]])
                k = tuple(sorted((x, y)))
                r = res.setdefault(k, {"de": an, "a": an, "max": 0})
                r["a"] = an; r["max"] = max(r["max"], round(a, 3))
json.dump([{"x": k[0], "y": k[1], **v} for k, v in sorted(res.items(), key=lambda kv: -kv[1]["max"])], open(sys.argv[1], "w"), ensure_ascii=False, indent=0)
print(len(res), "paires avec recouvrement >", seuil, "deg2")
