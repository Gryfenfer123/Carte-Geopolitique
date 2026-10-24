#!/usr/bin/env python3
"""Audit D (LECTURE SEULE) : image côte à côte Cliopatria (gauche) / historical-basemaps (droite) à une année donnée,
pour une revue visuelle. Usage : python3 -I d_rendu.py <cliopatria.geojson> <hb/geojson> <dossier_sortie> annee:fichier_hb ...
(ex. 1914:world_1914.geojson)"""
import json, sys, os, zlib
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon as MP
from matplotlib.collections import PatchCollection

src, hbdir, out = sys.argv[1:4]
jobs = [a.split(":") for a in sys.argv[4:]]
F = json.load(open(src, encoding="utf8"))["features"]
ent = [f for f in F if f["properties"]["Type"] == "POLITY" and not f["properties"]["Name"].startswith("(")]

def couleur(nom):
    h = zlib.crc32(nom.encode()) & 0xFFFFFFFF
    return plt.cm.hsv((h % 360) / 360.0)[:3] + (0.75,)

def patches(geom):
    polys = geom["coordinates"] if geom["type"] == "MultiPolygon" else [geom["coordinates"]]
    return [MP(p[0], closed=True) for p in polys]

def dessine(ax, items, titre, etiq=True):
    for nom, geom in items:
        for p in patches(geom):
            p.set_facecolor(couleur(nom)); p.set_edgecolor("k"); p.set_linewidth(0.3); ax.add_patch(p)
    ax.set_xlim(-170, 180); ax.set_ylim(-60, 80); ax.set_aspect(1.2); ax.set_title(titre, fontsize=10)
    ax.set_xticks([]); ax.set_yticks([])

os.makedirs(out, exist_ok=True)
for a, f in jobs:
    y = int(a)
    cl = sorted([(x["properties"]["MemberOf"].split(";")[0] or x["properties"]["Name"], x["properties"]["Area"], x["geometry"]) for x in ent
                 if x["properties"]["FromYear"] <= y <= x["properties"]["ToYear"]], key=lambda t: -t[1])
    hb = json.load(open(os.path.join(hbdir, f), encoding="utf8"))["features"]
    hbi = [((h["properties"].get("SUBJECTO") or h["properties"].get("NAME") or "?"), h["geometry"]) for h in hb if h["geometry"]]
    fig, axs = plt.subplots(1, 2, figsize=(18, 6.2))
    dessine(axs[0], [(n, g) for n, _, g in cl], f"Cliopatria v0.2.1 — {y} ({len(cl)} entités)")
    dessine(axs[1], hbi, f"historical-basemaps — {f} ({len(hbi)} polygones)")
    fig.tight_layout(); fig.savefig(os.path.join(out, f"cmp_{y}.png"), dpi=70); plt.close(fig)
    print("ok", y)
