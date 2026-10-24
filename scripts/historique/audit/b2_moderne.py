#!/usr/bin/env python3
"""Audit B2 (LECTURE SEULE) : Cliopatria 2024 contre les frontières actuelles Natural Earth 50 m (npm world-atlas, domaine public).
Pour chaque entité de 2024 : meilleur pays Natural Earth et recouvrement (IoU) ; pour chaque pays NE : part couverte par Cliopatria.
Usage : python3 -I b2_moderne.py <cliopatria.geojson> <countries50.geojson> [annee=2024]"""
import json, sys
from pyproj import Transformer
from shapely.geometry import shape
from shapely.ops import transform, unary_union
from shapely import STRtree, make_valid
T = Transformer.from_crs(4326, 6933, always_xy=True).transform
an = int(sys.argv[3]) if len(sys.argv) > 3 else 2024
def pj(g):
    g = shape(g)
    return make_valid(transform(T, g).simplify(3000)).buffer(0)
cl = [(f["properties"]["Name"], pj(f["geometry"])) for f in json.load(open(sys.argv[1], encoding="utf8"))["features"]
      if f["properties"]["Type"] == "POLITY" and not f["properties"]["Name"].startswith("(") and f["properties"]["FromYear"] <= an <= f["properties"]["ToYear"]]
ne = [(f["properties"]["name"], pj(f["geometry"])) for f in json.load(open(sys.argv[2]))["features"]]
print(an, ":", len(cl), "entités Cliopatria ;", len(ne), "pays Natural Earth")
arb = STRtree([g for _, g in ne])
print("\n== Entités Cliopatria : meilleur pays NE (IoU < 0,85) ==")
for n, g in sorted(cl, key=lambda t: -t[1].area):
    best, bn = 0, ""
    for j in arb.query(g):
        i = g.intersection(ne[j][1]).area
        iou = i / (g.area + ne[j][1].area - i)
        if iou > best: best, bn = iou, ne[j][0]
    if best < 0.85: print(f"  {n} ({g.area/1e6:.0f} km²) ~ {bn} IoU {best:.2f}")
u = unary_union([g for _, g in cl]); arc = STRtree([g for _, g in cl])
print("\n== Pays Natural Earth mal couverts par Cliopatria (< 70 %) ==")
for n, g in sorted(ne, key=lambda t: -t[1].area):
    if g.area < 1e8: continue
    c = g.intersection(u).area / g.area
    if c < 0.7: print(f"  {n} ({g.area/1e6:.0f} km²) couvert à {c:.0%}")
