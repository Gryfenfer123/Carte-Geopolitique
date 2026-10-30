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
SEUIL_PART_PETIT = 0.1   # ou si la zone retirée couvre au moins 10 % de la surface du petit
SEUIL_RESTE_VIDE = 0.985   # au-delà de 98,5 % retiré, il ne reste qu'une frange : la ligne disparaît sur ces années


def lire_regles(chemin):
    with open(chemin, encoding="utf8") as f:
        return json.load(f)


def regles_depuis_decisions(chemin):
    """Transforme chevauchements_decisions.json (une décision par paire) en règles : pour chaque entité « à qui on retire »
    (et chaque fenêtre d'années), la liste des zones à lui retirer. Seules les décisions « retirer » comptent."""
    with open(chemin, encoding="utf8") as f:
        decisions = json.load(f)["decisions"]
    groupes = {}
    for d in decisions:
        if d["decision"] != "retirer":
            continue
        cle = (d["retirer_a"], tuple(d["annees"]) if d.get("annees") else None)
        g = groupes.setdefault(cle, {"petits": [], "motifs": [], "sources": []})
        g["petits"].append(d["zone_de"])
        g["motifs"].append("%s (%s) : %s" % (d["zone_de"], d["categorie"], d["motif"]))
        g["sources"].append({"titre": d["sources"][0]["titre"] if d["sources"][0]["titre"].endswith(d["retirer_a"]) else d["sources"][1]["titre"],
                             "lien": d["sources"][0]["lien"], "decision": "%s / %s" % (d["x"], d["y"])})
    regles = []
    for (cut, fen), g in sorted(groupes.items(), key=lambda kv: (kv[0][0], str(kv[0][1]))):
        regle = {"id": "chev-" + cut.lower().replace(" ", "-").replace("'", "") + ("-%s-%s" % fen if fen else ""),
                 "grand": cut, "petits": sorted(set(g["petits"])), "motif": " | ".join(g["motifs"]),
                 "source": {"titre": "voir docs/sources/historique_chevauchements.csv (une ligne par décision)", "lien": "", "licence": "CC BY-SA 4.0 / CC0", "fiabilite": "voir le document"}}
        if fen:
            regle["annees"] = list(fen)
        regles.append(regle)
    return regles


def _geom(ft):
    return make_valid(shape(ft["geometry"])).buffer(0)


def appliquer(entites, dates, regles):
    """entites : features GeoJSON ; dates : dicts alignés {nom, de, a, …} (voir preparer_cliopatria.py).
    Modifie les deux listes sur place (ajoute des lignes en cas de coupure) ; renvoie le rapport."""
    rapport = []
    for regle in regles:
        fen = regle.get("annees")   # [de, a] : on ne coupe que sur ces années (sinon : toutes les années communes)
        petits = []
        for i, d in enumerate(dates):
            if d["nom"] in regle["petits"] and d["a"] >= d["de"]:
                de_p, a_p = (max(d["de"], fen[0]), min(d["a"], fen[1])) if fen else (d["de"], d["a"])
                if a_p >= de_p:
                    petits.append((i, {"de": de_p, "a": a_p}))
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
                # une petite zone dans un grand contour (ex. la Crète dans l'Empire ottoman) pèse < 1 % du grand mais couvre
                # une bonne part du petit : on retire aussi dans ce cas
                substantiel = any(x.area > 0 and geom0.intersection(x).area >= SEUIL_PART_PETIT * x.area for x in actifs)
                if actifs and (geom.is_empty or perdu >= SEUIL_RESTE_VIDE):
                    nouveaux.append((s, e, "VIDE", 1.0))      # entièrement recouvert : la ligne disparaît sur ces années
                elif actifs and (perdu >= SEUIL_PART or substantiel):
                    nouveaux.append((s, e, geom, perdu))
                else:
                    nouveaux.append((s, e, None, 0.0))
            if all(n[2] is None for n in nouveaux):
                continue
            # la ligne d'origine devient le premier segment, les autres sont ajoutés à la fin des listes
            for k, (s, e, geom, perdu) in enumerate(nouveaux):
                if isinstance(geom, str):          # "VIDE"
                    if k == 0:                      # la ligne d'origine devient un intervalle vide (écartée plus tard)
                        g["a"] = g["de"] - 1
                    resultat["lignes"].append({"de": s, "a": e, "surface_retiree_pct": 100.0, "supprimee": True})
                    continue
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
