"""Corriger les FORMES là où un ancien maître recouvre à tort un État devenu indépendant (chantier historique).

POURQUOI (Martin, 2026-10-28, capture d'écran) : dans Cliopatria, la « Cinquième République française » garde de 1961 à
2023 un contour de 3,03 M km² qui contient encore l'Algérie (2,32 M km²), alors que l'Algérie est indépendante depuis 1962.
(La ligne 2024 de la même entité fait 0,68 M km² : le contour moderne est juste.) La carte affichait donc la France par-dessus
l'Algérie. L'audit complet des chevauchements (2026-10-28) a trouvé le même défaut pour d'autres anciennes puissances.

CE QUE FAIT CE MODULE : pour chaque règle de `corrections_formes_manuelles.json` (grand, petits, source), on retire du contour
du « grand » la zone des « petits » pendant les années où les deux existent sur la carte. Les lignes du « grand » qui
traversent le début d'un « petit » sont coupées en deux (avant / après). Aucune zone n'est inventée : on ne fait que
RETIRER une surface déjà dessinée ailleurs par la source. Chaque règle porte sa source (dates d'indépendance Wikidata P571).
Logique pure (shapely), sans accès au réseau.
"""
import copy
import json

from shapely.geometry import shape, mapping
from shapely import make_valid

SEUIL_PART = 0.01   # on ne touche pas un contour dont la surface retirée est inférieure à 1 %


def lire_regles(chemin):
    with open(chemin, encoding="utf8") as f:
        return json.load(f)


def _geom(ft):
    return make_valid(shape(ft["geometry"])).buffer(0)


def appliquer(entites, dates, regles):
    """entites : features GeoJSON ; dates : dicts alignés {nom, de, a, …} (voir preparer_cliopatria.py).
    Modifie les deux listes sur place (ajoute des lignes en cas de coupure) ; renvoie le rapport."""
    rapport = []
    for regle in regles:
        petits = [(i, d) for i, d in enumerate(dates) if d["nom"] in regle["petits"] and d["a"] >= d["de"]]
        resultat = {"id": regle["id"], "grand": regle["grand"], "petits": regle["petits"], "source": regle["source"], "lignes": []}
        for i in [k for k, d in enumerate(dates) if d["nom"] == regle["grand"] and d["a"] >= d["de"]]:
            g = dates[i]
            bornes = {g["de"], g["a"] + 1}
            for _, p in petits:
                for b in (p["de"], p["a"] + 1):
                    if g["de"] < b <= g["a"]:
                        bornes.add(b)
            bornes = sorted(bornes)
            segments = [(bornes[k], bornes[k + 1] - 1) for k in range(len(bornes) - 1)]
            if len(segments) == 1 and not any(p["de"] <= g["de"] and p["a"] >= g["a"] for _, p in petits):
                continue   # aucun petit ne recouvre cette ligne dans le temps
            ft0, geom0 = entites[i], _geom(entites[i])
            if geom0.is_empty:
                continue
            nouveaux = []
            for (s, e) in segments:
                actifs = [_geom(entites[k]) for k, p in petits if p["de"] <= s and p["a"] >= e]
                geom = geom0
                if actifs:
                    retire = actifs[0]
                    for x in actifs[1:]:
                        retire = retire.union(x)
                    geom = geom0.difference(retire)
                perdu = 1 - geom.area / geom0.area if geom0.area else 0
                if actifs and perdu >= SEUIL_PART and not geom.is_empty:
                    nouveaux.append((s, e, geom, perdu))
                else:
                    nouveaux.append((s, e, None, 0.0))
            if all(n[2] is None for n in nouveaux):
                continue
            # la ligne d'origine devient le premier segment, les autres sont ajoutés à la fin des listes
            for k, (s, e, geom, perdu) in enumerate(nouveaux):
                if k == 0:
                    cible_ft, cible_d = ft0, g
                else:
                    cible_ft, cible_d = copy.deepcopy(ft0), dict(g)
                    entites.append(cible_ft)
                    dates.append(cible_d)
                cible_d["de"], cible_d["a"] = s, e
                if geom is not None:
                    cible_ft["geometry"] = mapping(geom)
                    cible_d["geometrie"] = cible_ft["geometry"]
                    cible_ft["properties"]["Area"] = round(ft0["properties"]["Area"] * (1 - perdu))
                resultat["lignes"].append({"de": s, "a": e, "surface_retiree_pct": round(perdu * 100, 1)})
        rapport.append(resultat)
    return rapport
