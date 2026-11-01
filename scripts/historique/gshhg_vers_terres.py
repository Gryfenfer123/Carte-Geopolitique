"""Convertit la côte GSHHG « pleine résolution » (≈ 100 m) en un GeoJSON de terres émergées SANS les grands lacs.

POURQUOI (Martin, 2026-11-01) : les contours devaient mieux suivre les côtes et les rives des lacs ; Natural Earth 10 m
(≈ 1 km, très grossier dans l'Arctique : Terre François-Joseph, archipel canadien) ne suffit pas.

SOURCE : GSHHG 2.3.7 (Wessel & Smith), dépôt https://github.com/GenericMappingTools/gshhg-gmt, dossier GSHHS/res_f
(fichiers texte). Licence LGPL v3 (données ; usage et mention d'origine). Niveaux : 1 = terre, 2 = lac, 3 = île dans un lac,
4 = étang dans une île. L'Antarctique est ignoré (aucun État historique dessiné au-delà de 60° S).
  git clone --depth 1 https://github.com/GenericMappingTools/gshhg-gmt
Usage : python3 -I gshhg_vers_terres.py <dossier res_f> <sortie.geojson> [lac_min_km2=100] [tolerance_deg=0.001]
Logique pure (shapely), sans réseau."""
import json
import os
import sys

import numpy as np
import shapely
from shapely import STRtree
from shapely.geometry import Polygon, box, mapping
from shapely.affinity import translate

FICHIERS_TERRE = ["GSHHS_f_Eurasia.txt", "GSHHS_f_Africa.txt", "GSHHS_f_NAmerica.txt", "GSHHS_f_SAmerica.txt",
                  "GSHHS_f_Australia.txt", "GSHHS_f_Level_1a.txt", "GSHHS_f_Level_1b.txt"]


def lire(chemin):
    """Rend la liste de (niveau, aire_km2, tableau Nx2) du fichier GSHHS."""
    sortie = []
    entete, pts = None, []
    with open(chemin, encoding="utf8") as f:
        for ligne in f:
            if ligne.startswith("#"):
                continue
            if ligne.startswith(">"):
                if entete is not None:
                    sortie.append((entete[0], entete[1], np.array(pts, dtype=float)))
                m = ligne.split()
                niveau = int(m[m.index("L") + 2])
                aire = float(m[m.index("A") + 2])
                entete, pts = (niveau, aire), []
            else:
                x, y = ligne.split()[:2]
                pts.append((float(x), float(y)))
    if entete is not None:
        sortie.append((entete[0], entete[1], np.array(pts, dtype=float)))
    return sortie


def vers_polygones(arr, tol):
    """Polygone(s) en longitude -180..180 (les contours qui passent 180° E sont coupés en deux)."""
    p = shapely.make_valid(Polygon(arr)).simplify(tol, preserve_topology=True)
    if p.is_empty:
        return []
    if arr[:, 0].max() > 180:
        a = p.intersection(box(-360, -90, 180, 90))
        b = translate(p.intersection(box(180, -90, 540, 90)), xoff=-360)
        p = shapely.union_all([a, b])
    return [q for q in shapely.get_parts(p) if q.geom_type == "Polygon" and not q.is_empty]


def main():
    dossier, sortie = sys.argv[1], sys.argv[2]
    lac_min = float(sys.argv[3]) if len(sys.argv) > 3 else 100.0
    tol = float(sys.argv[4]) if len(sys.argv) > 4 else 0.001
    terres, lacs, iles_lacs = [], [], []
    for nom in FICHIERS_TERRE:
        for niveau, aire, arr in lire(os.path.join(dossier, nom)):
            if niveau == 1:
                terres += vers_polygones(arr, tol)
        print(nom, len(terres), flush=True)
    for niveau, aire, arr in lire(os.path.join(dossier, "GSHHS_f_Level_2.txt")):
        if aire >= lac_min:
            lacs += vers_polygones(arr, tol)
    for niveau, aire, arr in lire(os.path.join(dossier, "GSHHS_f_Level_3.txt")):
        iles_lacs += vers_polygones(arr, tol)
    print("terres", len(terres), "lacs", len(lacs), "îles de lacs", len(iles_lacs), flush=True)
    arbre = STRtree(lacs)
    final = []
    for t in terres:
        idx = arbre.query(t)
        if len(idx):
            t = t.difference(shapely.union_all([lacs[i] for i in idx]))
        final += [q for q in shapely.get_parts(t) if q.geom_type == "Polygon" and not q.is_empty]
    # îles dans les lacs (niveau 3) : on les remet seulement si leur lac a été retiré (≥ lac_min) ; sinon elles sont déjà dans la terre
    arbre_l = STRtree(lacs)
    for ile in iles_lacs:
        if len(arbre_l.query(ile)) and any(l.contains(ile.representative_point()) for l in lacs):
            final.append(ile)
    feats = [{"type": "Feature", "properties": {}, "geometry": mapping(g)} for g in final]
    with open(sortie, "w", encoding="utf8") as f:
        json.dump({"type": "FeatureCollection", "features": feats}, f, separators=(",", ":"))
    print(len(feats), "polygones de terre ;", round(os.path.getsize(sortie) / 1e6, 1), "Mo")


if __name__ == "__main__":
    main()
