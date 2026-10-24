#!/usr/bin/env python3
"""Audit B3 (LECTURE SEULE) : Cliopatria v0.2.1 contre historical-basemaps (aourednik, GPL-3.0 : on LIT seulement,
rien n'est copié dans le dépôt) aux années où les deux existent.
Pour chaque année : couverture (km²) des deux sources ; entités Cliopatria dont le meilleur voisin HB recouvre < 40 % ;
polygones HB > 300 000 km² non couverts à > 50 % par Cliopatria. Superficies en projection équivalente, contours à 5 km.
Usage : python3 -I b3_historical_basemaps.py <cliopatria.geojson> <dossier hb/geojson> <dossier_sortie>"""
import json, sys, os, re, glob
from multiprocessing import Pool
from pyproj import Transformer
from shapely.geometry import shape
from shapely.ops import transform, unary_union
from shapely import STRtree, make_valid

src, hbdir, out = sys.argv[1:4]
T = Transformer.from_crs(4326, 6933, always_xy=True).transform
C = []

def charge(g):
    g = shape(g)
    if not g.is_valid:
        g = make_valid(g)
    return make_valid(transform(T, g).simplify(5000)).buffer(0)

def init():
    global C
    F = json.load(open(src, encoding="utf8"))["features"]
    C = [(f["properties"]["Name"], f["properties"]["FromYear"], f["properties"]["ToYear"], f["geometry"]) for f in F
         if f["properties"]["Type"] == "POLITY" and not f["properties"]["Name"].startswith("(")]

def annee_de(fichier):
    m = re.search(r"world_(bc)?(\d+)\.geojson", fichier)
    return -int(m.group(2)) if m.group(1) else int(m.group(2))

def un(fichier):
    y = annee_de(fichier)
    if y < -3000:
        return None
    cl = [(n, charge(g)) for n, a, b, g in C if a <= y <= b]
    hb = []
    for f in json.load(open(fichier, encoding="utf8"))["features"]:
        if f["geometry"] is None:
            continue
        p = f["properties"]
        try:
            hb.append((p.get("NAME") or p.get("SUBJECTO") or "(sans nom)", charge(f["geometry"])))
        except Exception:
            pass
    ucl = unary_union([g for _, g in cl]); uhb = unary_union([g for _, g in hb if g.area > 0])
    res = dict(annee=y, nb_clio=len(cl), nb_hb=len(hb), clio_km2=round(ucl.area / 1e6), hb_km2=round(uhb.area / 1e6),
               commun_km2=round(ucl.intersection(uhb).area / 1e6), seulement_clio=round(ucl.difference(uhb).area / 1e6), seulement_hb=round(uhb.difference(ucl).area / 1e6),
               desaccords=[], hb_sans_clio=[])
    arbre = STRtree([g for _, g in hb])
    for n, g in cl:
        if g.area < 1e11:
            continue
        best, bn = 0, ""
        for j in arbre.query(g):
            inter = g.intersection(hb[j][1]).area
            iou = inter / (g.area + hb[j][1].area - inter)
            if iou > best:
                best, bn = iou, hb[j][0]
        part = max((g.intersection(hb[j][1]).area for j in arbre.query(g)), default=0) / g.area
        if best < 0.4:
            res["desaccords"].append((n, round(g.area / 1e6), bn, round(best, 2)))
    arc = STRtree([g for _, g in cl])
    for n, g in hb:
        if g.area < 3e11:
            continue
        couvert = unary_union([g.intersection(cl[j][1]) for j in arc.query(g)]).area / g.area if len(arc.query(g)) else 0
        if couvert < 0.5:
            res["hb_sans_clio"].append((n, round(g.area / 1e6), round(couvert, 2)))
    return res

if __name__ == "__main__":
    fichiers = sorted(glob.glob(os.path.join(hbdir, "world_*.geojson")), key=annee_de)
    with Pool(2, initializer=init) as pool:
        R = [r for r in pool.map(un, fichiers) if r]
    os.makedirs(out, exist_ok=True)
    json.dump(R, open(os.path.join(out, "b3.json"), "w", encoding="utf8"), ensure_ascii=False, indent=1)
    for r in R:
        print(r["annee"], "clio", r["clio_km2"], "hb", r["hb_km2"], "commun", r["commun_km2"], "| désaccords", len(r["desaccords"]), "hb sans clio", len(r["hb_sans_clio"]))
