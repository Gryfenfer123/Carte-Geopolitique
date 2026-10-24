#!/usr/bin/env python3
"""Audit B1 (LECTURE SEULE) : part de chaque tracé qui se trouve EN MER (hors terres actuelles + 15 km de marge).
Source des côtes : Natural Earth 10 m (paquet npm world-atlas, domaine public). Attention : certaines côtes ont changé
(delta du Nil, Mésopotamie avant -2000, mer d'Aral, polders) → les cas très anciens sont à lire avec prudence.
Usage : python3 -I b1_terre.py <cliopatria.geojson> <land10.geojson> <dossier_sortie>"""
import json, sys, os
from multiprocessing import Pool
from pyproj import Transformer
from shapely.geometry import shape
from shapely.ops import transform
from shapely import STRtree, make_valid, box, unary_union, clip_by_rect

src, landf, out = sys.argv[1:4]
T = Transformer.from_crs(4326, 6933, always_xy=True).transform
LAND = None

def init():
    global LAND
    l = json.load(open(landf))
    gs = []
    for f in l["features"]:
        g = shape(f["geometry"])
        for p in (g.geoms if hasattr(g, "geoms") else [g]):
            gs.append(transform(T, p).simplify(1500).buffer(15000))
    LAND = unary_union(gs)  # une seule fois : terres actuelles élargies de 15 km

def mesure(args):
    i, geo, p = args
    g = shape(geo)
    if not g.is_valid:
        g = make_valid(g)
    gp = make_valid(transform(T, g).simplify(2000))
    if gp.is_empty or gp.area < 1e6:
        return None
    x0, y0, x1, y1 = gp.bounds
    terre = clip_by_rect(LAND, x0 - 1, y0 - 1, x1 + 1, y1 + 1)  # découpe rapide à la boîte du tracé
    try:
        dehors = gp.difference(terre).area if not terre.is_empty else gp.area
    except Exception:
        gp = gp.buffer(0)
        dehors = gp.difference(terre.buffer(0)).area if not terre.is_empty else gp.area
    return dict(nom=p["Name"], de=p["FromYear"], a=p["ToYear"], aire=round(gp.area / 1e6), mer_km2=round(dehors / 1e6), mer_part=round(dehors / gp.area, 3))

if __name__ == "__main__":
    F = json.load(open(src, encoding="utf8"))["features"]
    tasks = [(i, f["geometry"], f["properties"]) for i, f in enumerate(F) if f["properties"]["Type"] == "POLITY" and not f["properties"]["Name"].startswith("(")]
    with Pool(2, initializer=init) as pool:
        res = [r for r in pool.map(mesure, tasks, chunksize=50) if r]
    os.makedirs(out, exist_ok=True)
    json.dump(res, open(os.path.join(out, "b1.json"), "w", encoding="utf8"), ensure_ascii=False)
    gros = sorted([r for r in res if r["mer_part"] > 0.2 and r["mer_km2"] > 3000], key=lambda r: -r["mer_km2"])
    print(len(res), "lignes mesurées ;", len(gros), "avec >20 % en mer et >3000 km² en mer")
    for r in gros[:50]:
        print(r["nom"], r["de"], r["a"], "mer", r["mer_km2"], "km² /", r["aire"], r["mer_part"])
