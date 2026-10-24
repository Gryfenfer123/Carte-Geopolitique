#!/usr/bin/env python3
"""Audit A3 (LECTURE SEULE) : deux entités différentes se chevauchent-elles la même année ?
Échantillon : une année sur 10 + années-clés. Superficies en projection équivalente (EPSG:6933), contours allégés à 3 km.
Usage : python3 -I a3_chevauchements.py <cliopatria.geojson> <dossier_sortie>"""
import json, sys, os, collections
from multiprocessing import Pool
from pyproj import Transformer
from shapely.geometry import shape
from shapely.ops import transform
from shapely import STRtree, make_valid

src, out = sys.argv[1], sys.argv[2]
T = Transformer.from_crs(4326, 6933, always_xy=True).transform
ANNEES = sorted(set(list(range(-3400, 2025, 10)) + [-500, -323, -27, 117, 476, 800, 1066, 1215, 1453, 1492, 1648, 1789, 1815, 1871, 1914, 1919, 1938, 1945, 1991, 2000, 2024]))
G = []  # (nom, de, a, membres, geom6933)

def init():
    global G
    F = json.load(open(src, encoding="utf8"))["features"]
    G = []
    for f in F:
        p = f["properties"]
        if p["Type"] != "POLITY" or p["Name"].startswith("("):
            continue
        g = shape(f["geometry"])
        if not g.is_valid:
            g = make_valid(g)
        G.append([p["Name"], p["FromYear"], p["ToYear"], p["MemberOf"], g, None])

def proj(i):
    if G[i][5] is None:
        G[i][5] = transform(T, G[i][4]).simplify(3000)
    return G[i][5]

def annee(a):
    ids = [i for i, r in enumerate(G) if r[1] <= a <= r[2]]
    geoms = [proj(i) for i in ids]
    arb = STRtree(geoms)
    res = []
    for k, g in enumerate(geoms):
        for j in arb.query(g):
            if j <= k:
                continue
            try:
                inter = g.intersection(geoms[j]).area / 1e6
            except Exception:
                continue
            m = min(g.area, geoms[j].area) / 1e6
            if inter > 1000 and m > 0 and inter / m > 0.05:
                res.append((G[ids[k]][0], G[ids[j]][0], a, round(inter), round(inter / m, 2), G[ids[k]][3], G[ids[j]][3]))
    return res

if __name__ == "__main__":
    init()
    with Pool(2, initializer=init) as pool:
        tout = [x for l in pool.map(annee, ANNEES, chunksize=8) for x in l]
    paires = collections.defaultdict(list)
    for a, b, y, inter, part, ma, mb in tout:
        paires[tuple(sorted((a, b)))].append((y, inter, part, ma, mb))
    synth = []
    for (a, b), L in paires.items():
        synth.append(dict(a=a, b=b, annees=[L[0][0], L[-1][0]], nb_annees=len(L), max_km2=max(x[1] for x in L), max_part=max(x[2] for x in L),
                          meme_ensemble=bool(L[0][3] and set(L[0][3].split(';')) & set(L[0][4].split(';')))))
    synth.sort(key=lambda s: -s["max_km2"])
    os.makedirs(out, exist_ok=True)
    json.dump(synth, open(os.path.join(out, "a3.json"), "w", encoding="utf8"), ensure_ascii=False, indent=1)
    print(len(ANNEES), "années testées ;", len(synth), "paires qui se chevauchent")
    for s in synth[:40]:
        print(s["a"], "/", s["b"], s["annees"], s["nb_annees"], "années", s["max_km2"], "km²", s["max_part"], "ens" if s["meme_ensemble"] else "")
