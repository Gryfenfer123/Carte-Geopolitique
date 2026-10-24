#!/usr/bin/env python3
"""Audit A2 (LECTURE SEULE) : géométrie des lignes Cliopatria d'origine.
- superficie géodésique recalculée vs champ Area ; validité ; nombre de parties ; boîte ; passage de l'antiméridien.
Usage : python3 -I a2_geometrie.py <cliopatria.geojson> <dossier_sortie>"""
import json, sys, os
from multiprocessing import Pool
from pyproj import Geod
from shapely.geometry import shape

GEOD = Geod(ellps="WGS84")
src, out = sys.argv[1], sys.argv[2]

def mesure(args):
    i, f = args
    p = f["properties"]
    g = shape(f["geometry"])
    valide = g.is_valid
    aire = 0.0
    for poly in (g.geoms if g.geom_type == "MultiPolygon" else [g]):
        a, _ = GEOD.geometry_area_perimeter(poly.exterior)
        aire += abs(a)
        for h in poly.interiors:
            b, _ = GEOD.geometry_area_perimeter(h)
            aire -= abs(b)
    x0, y0, x1, y1 = g.bounds
    return dict(i=i, nom=p["Name"], de=p["FromYear"], a=p["ToYear"], type=p["Type"], aire_champ=p["Area"],
                aire_calc=aire / 1e6, valide=valide, parties=len(g.geoms) if g.geom_type == "MultiPolygon" else 1,
                bbox=[round(v, 2) for v in (x0, y0, x1, y1)], largeur=round(x1 - x0, 1))

if __name__ == "__main__":
    F = json.load(open(src, encoding="utf8"))["features"]
    with Pool(2) as pool:
        res = pool.map(mesure, list(enumerate(F)), chunksize=200)
    os.makedirs(out, exist_ok=True)
    json.dump(res, open(os.path.join(out, "a2.json"), "w", encoding="utf8"), ensure_ascii=False)
    ecarts = [r for r in res if r["aire_champ"] > 0 and abs(r["aire_calc"] / r["aire_champ"] - 1) > 0.05]
    print("lignes", len(res), "invalides", sum(not r["valide"] for r in res), "écart superficie >5 %:", len(ecarts))
    print("antiméridien (largeur>300°):", sum(r["largeur"] > 300 for r in res))
