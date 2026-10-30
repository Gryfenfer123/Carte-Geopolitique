"""Ajoute à la carte des îles que Cliopatria ne dessine pas (ou plus) alors qu'un État les contrôle.

Principe (sans valeur inventée) : chaque règle de `iles_manuelles.json` dit
  - quelles terres (trait de côte Natural Earth, dans une boîte) sont concernées,
  - de quelle année à quelle année l'État les contrôle (avec la source),
  - quel État : celui que Cliopatria dessine, ces années-là, sur le point de référence (capitale), parmi la liste
    `etats` si elle est donnée (évite par exemple d'attribuer Svalbard à l'Allemagne nazie qui « occupe » la Norvège).
Pour chaque ligne de cet État, on crée une ligne « îles » avec le MÊME nom (donc la même couleur, la même fiche),
sur les années communes, avec les terres de la boîte MOINS tout ce qu'une autre ligne dessine déjà ces années-là :
une île ajoutée ne peut donc jamais chevaucher quelqu'un d'autre.
Logique pure : pas de DOM, pas de réseau.
"""
import copy
import json

from shapely.geometry import box, mapping, shape
from shapely.ops import unary_union
from shapely.validation import make_valid
from shapely.geometry import Point

MIN_KM2 = 0.5  # on ignore les restes plus petits (artefacts de découpe)


def lire_regles(chemin):
    with open(chemin, encoding="utf8") as f:
        return json.load(f)


def _geom(ft):
    return make_valid(shape(ft["geometry"])).buffer(0)


def appliquer(entites, dates, regles, terres):
    """entites/dates : listes parallèles (modifiées sur place). terres : liste de géométries shapely (côte)."""
    rapport = []
    for r in regles:
        b = box(*r["boite"])
        plafond = r.get("exclure_polygones_plus_grands_que_km2")
        morceaux = []
        for t in terres:
            if not t.intersects(b):
                continue
            for p in (t.geoms if hasattr(t, "geoms") else [t]):
                if not p.intersects(b):
                    continue
                q = p.intersection(b)
                if q.is_empty:
                    continue
                if plafond and _km2(p) > plafond:
                    continue
                morceaux.append(q)
        iles = unary_union(morceaux)
        pt = Point(*r["reference"])
        n0 = len(entites)
        res = {"id": r["id"], "lignes": []}
        porteurs = [k for k in range(n0)
                    if dates[k]["a"] >= r["de"] and dates[k]["de"] <= r["a"]
                    and (not r.get("etats") or dates[k]["nom"] in r["etats"])
                    and _geom(entites[k]).contains(pt)]
        for k in porteurs:
            de, a = max(dates[k]["de"], r["de"]), min(dates[k]["a"], r["a"])
            # ce que d'autres lignes dessinent déjà sur ces années, dans la boîte
            deja = [_geom(entites[j]).intersection(b) for j in range(len(entites))
                    if dates[j]["a"] >= de and dates[j]["de"] <= a and entites[j]["geometry"] is not None
                    and shape(entites[j]["geometry"]).bounds[0] <= r["boite"][2]
                    and shape(entites[j]["geometry"]).bounds[2] >= r["boite"][0]
                    and shape(entites[j]["geometry"]).bounds[1] <= r["boite"][3]
                    and shape(entites[j]["geometry"]).bounds[3] >= r["boite"][1]
                    and _geom(entites[j]).intersects(b)]
            reste = iles.difference(unary_union(deja)) if deja else iles
            if reste.is_empty or _km2(reste) < MIN_KM2:
                continue
            ft = copy.deepcopy(entites[k])
            ft["geometry"] = mapping(reste)
            ft["properties"]["Area"] = round(_km2(reste))
            ft["properties"]["FromYear"], ft["properties"]["ToYear"] = de, a
            entites.append(ft)
            dates.append({"nom": dates[k]["nom"], "de": de, "a": a, "geometrie": ft["geometry"], "ft": ft})
            res["lignes"].append({"nom": dates[k]["nom"], "de": de, "a": a, "km2": round(_km2(reste))})
        rapport.append(res)
    return rapport


def _km2(g):
    """Surface approchée en km² (projection équivalente simple, suffisante pour un seuil)."""
    import math
    x0, y0, x1, y1 = g.bounds
    k = 111.32 ** 2 * math.cos(math.radians((y0 + y1) / 2))
    return g.area * k
