"""Complète les grands lacs : un lac reste DANS le pays (ou les pays) qui le bordent.

POURQUOI (Martin, 2026-11-03) : les contours de Cliopatria laissent les grands lacs en blanc (Grands Lacs, Tanganyika,
Malawi…) et les frontières « s'arrêtent » à la rive, comme si le lac n'appartenait à personne. Martin veut que le lac
soit colorié comme le pays qui le contient, comme sur une carte politique classique.

RÈGLE (convention de dessin, pas une donnée historique — notée dans docs/sources/historique.md) :
- lacs = GSHHG 2.3.7 (niveau 2), aire ≥ lac_min km², sauf les mers fermées (≥ 300 000 km² : Caspienne) ; les îles
  de lac (niveau 3) sont retirées ;
- pour chaque lac et chaque période pendant laquelle les lignes voisines ne changent pas, la partie du lac (et du liseré
  de terre à ≤ 0,1° de la rive) qui n'appartient encore à aucune ligne est partagée entre les lignes voisines
  (à ≤ 0,3° de la rive) selon le plus proche voisin de la rive (diagrammes de Voronoï des points de rive) : un lac
  frontalier est donc coupé à peu près à mi-distance des rives, ce qui approche la frontière réelle dans le lac ;
- les entités « (…) » (regroupements) ne comptent ni comme voisines ni comme couverture ;
- jamais de chevauchement créé : on n'ajoute que ce qui n'est à aucune ligne active.

Usage : python3 -I lacs_completes.py <dossier_entree> <dossier_sortie> <dossier GSHHG res_f> <terres.geojson> [lac_min=500]
"""
import hashlib
import importlib.util
import json
import os
import sys
from collections import defaultdict

import numpy as np
import shapely
from shapely import STRtree
from shapely.geometry import MultiPoint, Point, Polygon, box, shape

ICI = os.path.dirname(os.path.abspath(__file__))
MAX_MER_KM2 = 300000
VOISIN_MAX = 0.3      # degrés : un voisin doit border le lac à moins de ça
LISERE = 0.1          # degrés : liseré de terre autour du lac qui peut être comblé
PAS_RIVE = 0.03       # degrés : espacement des points de rive
MIN_LIBRE = 2e-4      # deg² : en dessous, rien à ajouter


def charger_module(nom, fichier):
    spec = importlib.util.spec_from_file_location(nom, os.path.join(ICI, fichier))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def decoder(t, E):
    ps = []
    for p in t:
        anneaux = []
        for a in p:
            x, y = a[0], a[1]
            pts = [(x / E, y / E)]
            for i in range(2, len(a), 2):
                x += a[i]; y += a[i + 1]; pts.append((x / E, y / E))
            anneaux.append(pts)
        ps.append(Polygon(anneaux[0], anneaux[1:]))
    return shapely.make_valid(shapely.union_all(ps))


def lire_lacs(dossier_gshhg, lac_min, vers_polygones, lire):
    ile3 = []
    for _, _, arr in lire(os.path.join(dossier_gshhg, "GSHHS_f_Level_3.txt")):
        ile3 += vers_polygones(arr, 0.001)
    arbre_iles = STRtree(ile3)
    lacs = []
    for _, aire, arr in lire(os.path.join(dossier_gshhg, "GSHHS_f_Level_2.txt")):
        if lac_min <= aire < MAX_MER_KM2:
            for p in vers_polygones(arr, 0.001):
                idx = arbre_iles.query(p, predicate="intersects")
                if len(idx):
                    p = p.difference(shapely.union_all([ile3[i] for i in idx]))
                for q in shapely.get_parts(p):
                    if q.geom_type == "Polygon" and not q.is_empty:
                        lacs.append(q)
    return lacs


def partager(libre, lac, actifs, arbre_actifs):
    """Rend {indice_actif: géométrie} : le libre partagé entre voisins (Voronoï des points de rive)."""
    rive = shapely.segmentize(lac.boundary, PAS_RIVE)
    coords = shapely.get_coordinates(rive)
    if len(coords) == 0:
        return {}
    pts = shapely.points(coords)
    paires = arbre_actifs.query_nearest(pts, max_distance=VOISIN_MAX, all_matches=False)
    if paires.shape[1] == 0:
        return {}
    i_pts, i_act = paires
    etiquettes = set(i_act.tolist())
    if len(etiquettes) == 1:
        return {int(i_act[0]): libre}
    pts_ok = coords[i_pts]
    cellules = shapely.voronoi_polygons(MultiPoint(pts_ok), extend_to=libre.envelope.buffer(1.0))
    cells = shapely.get_parts(cellules)
    arbre_p = STRtree(shapely.points(pts_ok))
    par = defaultdict(list)
    for c in cells:
        k = arbre_p.query(c, predicate="contains")
        if len(k):
            par[int(i_act[k[0]])].append(c)
    sortie = {}
    for a, cs in par.items():
        g = shapely.union_all(cs).intersection(libre)
        if not g.is_empty and g.area > 1e-8:
            sortie[a] = g
    return sortie


def main():
    entree, sortie, dossier_gshhg, chemin_terres = sys.argv[1:5]
    lac_min = float(sys.argv[5]) if len(sys.argv) > 5 else 500.0
    prep = charger_module("prep", "preparer_cliopatria.py")
    conv = charger_module("conv", "gshhg_vers_terres.py")
    index = json.load(open(os.path.join(entree, "index.json"), encoding="utf8"))
    E = index.get("echelle", 100)
    traces = {}
    for m, (premier, n) in enumerate(index["morceaux"]):
        for k, t in enumerate(json.load(open(os.path.join(entree, "geo_%03d.json" % m), encoding="utf8"))):
            traces[premier + k] = t
    lignes = index["lignes"]
    groupe = [index["noms"][index["meta"][l[0]][0]].startswith("(") for l in lignes]
    cache = {}

    def geom(i):
        k = lignes[i][3]
        if k not in cache:
            cache[k] = decoder(traces[k], E)
        return cache[k]

    indices = [i for i in range(len(lignes)) if not groupe[i]]
    geoms = [geom(i) for i in indices]
    arbre_l = STRtree(geoms)
    print(len(indices), "lignes non groupées décodées", flush=True)

    lacs = lire_lacs(dossier_gshhg, lac_min, conv.vers_polygones, conv.lire)
    print(len(lacs), "lacs ≥", lac_min, "km²", flush=True)
    terres = [shape(f["geometry"]) for f in json.load(open(chemin_terres, encoding="utf8"))["features"]]
    arbre_t = STRtree(terres)
    print(len(terres), "polygones de terre", flush=True)

    extras = defaultdict(list)  # indice de ligne -> [(t0, t1, id_lac, géométrie)]
    ajoutes = 0
    for n_lac, lac in enumerate(lacs):
        zone = lac.buffer(VOISIN_MAX)
        cand = [int(j) for j in arbre_l.query(zone, predicate="intersects")]
        if not cand:
            continue
        coupes = sorted({max(lignes[indices[j]][1], -10**6) for j in cand} | {lignes[indices[j]][2] + 1 for j in cand})
        terre_loc = None
        for t0, t1 in zip(coupes[:-1], coupes[1:]):
            actifs = [j for j in cand if lignes[indices[j]][1] <= t0 and lignes[indices[j]][2] >= t1 - 1]
            if not actifs:
                continue
            if terre_loc is None:
                zl = lac.buffer(LISERE)
                ids = arbre_t.query(zl, predicate="intersects")
                terre_loc = zl.intersection(shapely.union_all([terres[i] for i in ids])) if len(ids) else lac
                terre_loc = terre_loc.union(lac)
            couverts = shapely.union_all([geoms[j] for j in actifs])
            libre = terre_loc.difference(couverts)
            if libre.is_empty or libre.area < MIN_LIBRE:
                continue
            arbre_a = STRtree([geoms[j] for j in actifs])
            parts = partager(libre, lac, actifs, arbre_a)
            for a, g in parts.items():
                if g.area > 1e-8:
                    extras[indices[actifs[a]]].append((t0, t1 - 1, n_lac, g))
                    ajoutes += 1
        if n_lac % 100 == 99:
            print("  lacs traités :", n_lac + 1, "/", len(lacs), flush=True)
    print(ajoutes, "morceaux de lac ajoutés sur", len(extras), "lignes", flush=True)

    # nouvelles lignes : on découpe chaque ligne concernée aux changements d'extras
    pas = 1 / E
    nouvelles = []  # (de, a, meta, géom_ou_trace_existante, ensemble, aire)
    for i, l in enumerate(lignes):
        if i not in extras:
            nouvelles.append((l[1], l[2], l[0], ("trace", l[3]), l[4], l[5]))
            continue
        base = geom(i)
        coupes = {l[1], l[2] + 1}
        for t0, t1, _, _ in extras[i]:
            for c in (t0, t1 + 1):
                if l[1] < c <= l[2]:
                    coupes.add(c)
        coupes = sorted(coupes)
        segments = []
        for c0, c1 in zip(coupes[:-1], coupes[1:]):
            ex = [(n, g) for t0, t1, n, g in extras[i] if t0 <= c0 and t1 >= c1 - 1]
            cle = tuple(sorted(n for n, _ in ex))
            if segments and segments[-1][2] == cle:
                segments[-1][1] = c1 - 1
            else:
                segments.append([c0, c1 - 1, cle, ex])
        for c0, c1, cle, ex in segments:
            if not ex:
                nouvelles.append((c0, c1, l[0], ("trace", l[3]), l[4], l[5]))
                continue
            g = shapely.union_all([base] + [x for _, x in ex])
            g = shapely.set_precision(g, pas)
            codee = prep.coder_geometrie(g) if not g.is_empty else None
            if codee is None:
                nouvelles.append((c0, c1, l[0], ("trace", l[3]), l[4], l[5]))
            else:
                nouvelles.append((c0, c1, l[0], ("neuf", json.dumps(codee, separators=(",", ":"))), l[4], l[5]))
    nouvelles.sort(key=lambda x: x[0])

    # réemballage (même logique que preparer_cliopatria.py)
    textes, idx_trace, lignes_out = [], {}, []
    for de, a, meta, src, ens, aire in nouvelles:
        texte = json.dumps(traces[src[1]], separators=(",", ":")) if src[0] == "trace" else src[1]
        h = hashlib.md5(texte.encode()).hexdigest()
        if h not in idx_trace:
            idx_trace[h] = len(textes)
            textes.append(texte)
        lignes_out.append([meta, de, a, idx_trace[h], ens, aire])
    morceaux, courant, taille, debut = [], [], 0, 0
    for i, t in enumerate(textes):
        courant.append(t)
        taille += len(t) + 1
        if taille >= prep.TAILLE_MORCEAU:
            morceaux.append((debut, courant))
            debut, courant, taille = i + 1, [], 0
    if courant:
        morceaux.append((debut, courant))
    os.makedirs(sortie, exist_ok=True)
    for old in os.listdir(sortie):
        if old.startswith("geo_") and old.endswith(".json"):
            os.remove(os.path.join(sortie, old))
    for m, (premier, liste) in enumerate(morceaux):
        with open(os.path.join(sortie, "geo_%03d.json" % m), "w", encoding="utf8") as f:
            f.write("[" + ",".join(liste) + "]")
    index2 = dict(index)
    index2["lignes"] = lignes_out
    index2["morceaux"] = [[premier, len(liste)] for premier, liste in morceaux]
    with open(os.path.join(sortie, "index.json"), "w", encoding="utf8") as f:
        json.dump(index2, f, ensure_ascii=False, separators=(",", ":"))
    print(len(lignes_out), "lignes ;", len(textes), "tracés ;", len(morceaux), "morceaux", flush=True)
    json.dump({"lacs": len(lacs), "morceaux_ajoutes": ajoutes, "lignes_touchees": len(extras)},
              open(os.path.join(ICI, "lacs_completes_rapport.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
