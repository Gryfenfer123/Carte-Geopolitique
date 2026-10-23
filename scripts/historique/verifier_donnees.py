#!/usr/bin/env python3
"""Vérifie les données produites par preparer_cliopatria.py.

Usage :
    python3 scripts/historique/verifier_donnees.py [chemin/vers/cliopatria_polities_only_v021.geojson]

1. Contrôles de structure (toujours) : index cohérent, morceaux contigus, anneaux valides, coordonnées plausibles.
2. Contrôle de fidélité (si le fichier d'origine est donné) : pour un échantillon de lignes, compare le contour
   simplifié au contour d'origine (recouvrement = surface commune / surface réunie). Un recouvrement faible
   signalerait une simplification trop forte. Sort avec le code 1 au moindre problème.
"""
import json
import os
import random
import sys

import shapely
from shapely.geometry import Polygon, shape
from shapely.validation import make_valid

RACINE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "public", "data", "historique")
CENTIEMES = 100


def decoder_polygones(trace):
    polys = []
    for poly in trace:
        anneaux = []
        for flat in poly:
            x, y = flat[0], flat[1]
            pts = [(x / CENTIEMES, y / CENTIEMES)]
            for i in range(2, len(flat), 2):
                x += flat[i]
                y += flat[i + 1]
                pts.append((x / CENTIEMES, y / CENTIEMES))
            anneaux.append(pts)
        polys.append(anneaux)
    return polys


def vers_shapely(trace):
    """Tracé codé → une géométrie shapely (union des polygones, réparés si besoin)."""
    parts = []
    for anneaux in decoder_polygones(trace):
        p = Polygon(anneaux[0], anneaux[1:])
        parts.append(p if p.is_valid else make_valid(p))
    return shapely.union_all(parts)


def main():
    erreurs = []
    with open(os.path.join(RACINE, "index.json"), encoding="utf8") as f:
        index = json.load(f)
    lignes, morceaux = index["lignes"], index["morceaux"]

    # --- structure ---------------------------------------------------------------------------------------------
    attendu = 0
    traces = []
    for m, (premier, nombre) in enumerate(morceaux):
        if premier != attendu:
            erreurs.append("morceau %d : premier id %d, attendu %d" % (m, premier, attendu))
        with open(os.path.join(RACINE, "geo_%03d.json" % m), encoding="utf8") as f:
            contenu = json.load(f)
        if len(contenu) != nombre:
            erreurs.append("morceau %d : %d tracés, attendu %d" % (m, len(contenu), nombre))
        traces += contenu
        attendu += nombre
    for k, (meta, debut, fin, trace, ensemble, aire) in enumerate(lignes):
        if not (0 <= meta < len(index["meta"])) or not (0 <= trace < len(traces)):
            erreurs.append("ligne %d : référence hors limites" % k)
        if debut > fin:
            erreurs.append("ligne %d : début %d > fin %d" % (k, debut, fin))
        if ensemble != -1 and not (0 <= ensemble < len(index["noms"])):
            erreurs.append("ligne %d : ensemble hors limites" % k)
    invalides = 0
    for i, trace in enumerate(traces):
        for anneaux in decoder_polygones(trace):
            for pts in anneaux:
                if len(pts) < 3:
                    erreurs.append("tracé %d : anneau de moins de 3 points" % i)
            if not Polygon(anneaux[0], anneaux[1:]).is_valid:
                invalides += 1
                if invalides <= 5:
                    erreurs.append("tracé %d : polygone invalide (croisement)" % i)
                for lon, lat in pts:
                    if not (-180.5 <= lon <= 180.5 and -90.5 <= lat <= 90.5):
                        erreurs.append("tracé %d : coordonnée hors du globe (%s, %s)" % (i, lon, lat))
                        break
    print("structure :", len(lignes), "lignes,", len(traces), "tracés,", len(morceaux), "morceaux ;",
          invalides, "polygone(s) invalide(s) —", "OK" if not erreurs else "%d problème(s)" % len(erreurs))

    # --- fidélité ----------------------------------------------------------------------------------------------
    if len(sys.argv) > 1:
        with open(sys.argv[1], encoding="utf8") as f:
            data = json.load(f)
        originaux = [
            ft for ft in data["features"]
            if ft["properties"]["Type"] == "POLITY" and not ft["properties"]["Name"].startswith("(")
        ]
        originaux.sort(key=lambda ft: (ft["properties"]["FromYear"], ft["properties"]["ToYear"], ft["properties"]["Name"]))
        if len(originaux) != len(lignes):
            erreurs.append("nombre de lignes différent de la source (%d vs %d)" % (len(originaux), len(lignes)))
        else:
            random.seed(7)
            echantillon = random.sample(range(len(lignes)), 1500)
            scores = []
            for k in echantillon:
                ft = originaux[k]
                p = ft["properties"]
                if (p["FromYear"], p["ToYear"]) != (lignes[k][1], lignes[k][2]):
                    erreurs.append("ligne %d : années différentes de la source" % k)
                    continue
                g0 = shape(ft["geometry"])
                if not g0.is_valid:
                    g0 = make_valid(g0)
                g1 = vers_shapely(traces[lignes[k][3]])
                union = g0.union(g1).area
                recouvrement = g0.intersection(g1).area / union if union else 1.0
                scores.append((recouvrement, p["Name"], p["FromYear"], round(g0.area, 3)))
            scores.sort()
            moyen = sum(s[0] for s in scores) / len(scores)
            print("fidélité (échantillon de %d) : recouvrement moyen %.4f ; plus faibles :" % (len(scores), moyen))
            for s in scores[:6]:
                print("   %.3f  %s (%d)  surface %s deg²" % s)
            # Seuils : 0,90 en général ; 0,80 pour les tout petits territoires (< 0,05 deg², soit quelques dizaines de
            # km), que la grille de 1 km ne peut pas reproduire plus finement.
            for s in scores:
                if s[0] < (0.90 if s[3] >= 0.05 else 0.80):
                    erreurs.append("simplification trop forte : %s (%d), recouvrement %.3f" % (s[1], s[2], s[0]))
    if erreurs:
        print("PROBLÈMES :")
        for e in erreurs[:30]:
            print(" -", e)
        sys.exit(1)
    print("Tout est conforme.")


if __name__ == "__main__":
    main()
