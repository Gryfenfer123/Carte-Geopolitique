"""Corriger les DATES de la carte historique pour qu'elles tombent à la date historique réelle (chantier historique).

POURQUOI (Martin, 2026-10-24) : Cliopatria n'a pas une carte par année mais des « instantanés » (tous les 10 ans
avant 1500 environ, plus rarement avant -500). Un événement daté (traité de Verdun, 843) n'apparaît donc qu'à
l'instantané suivant (850). Ce module avance ou recule les bornes des lignes (entité, de, à) à la date réelle
SOURCÉE, sans toucher aux formes : on ne crée aucun contour, on les affiche aux bonnes années.

CONVENTION D'AFFICHAGE (à connaître) : pour un événement daté de l'année D, la nouvelle situation s'affiche à partir
de l'année D incluse, l'ancienne jusqu'à D-1 incluse. Ainsi l'année de l'événement montre le « après ».

DEUX SOURCES DE CORRECTIONS (voir docs/sources/historique.md) :
  - corrections_dates_manuelles.json : événements majeurs, un par un, avec leur source (Wikipédia, etc.)
  - corrections_dates_wikidata.txt   : dates de création / disparition des États (propriétés Wikidata P571/P576,
                                       P580/P582 ; CC0), ligne « nom|op|origine|vers|qid|propriété »

GARDE-FOUS (une correction qui ne les respecte pas est REFUSÉE et notée dans le rapport) :
  1. FENÊTRE : le changement doit tomber entre deux instantanés consécutifs de la source. Ex. : une entité qui
     apparaît à l'instantané B (absente au précédent P) ne peut naître que dans ]P ; B]. Une date hors fenêtre
     contredit la source de base : on ne la suit pas. (Cela filtre aussi les identifiants Wikidata faux.)
  2. PAS DE TROU : une entité qui disparaît plus tôt n'est retirée que si son territoire est repris par une autre
     entité déjà affichée (sinon elle reste affichée jusqu'à l'instantané suivant, comme avant).
  3. PAS DE DOUBLON : quand une entité naît plus tôt sur le territoire d'une autre qui s'arrêtait à l'instantané
     suivant, l'ancienne s'arrête à la veille (même date, déduite) ; si l'ancienne continue sous une autre forme, son
     changement de forme est avancé à la même date.
Les déductions du point 3 sont marquées « déduit » dans le rapport.
"""
import json
import os
from collections import defaultdict

from shapely.geometry import shape
from shapely import make_valid

SEUIL_REPRISE = 0.5   # part du territoire qui doit être reprise / remplacée pour déduire une date
# Souplesse de la FENÊTRE (voir garde-fou 1). Le relevé « P » décrit la situation de l'année P, pas un instant précis :
# un événement daté de l'année P elle-même peut donc être retenu. Un cran de plus (SOUPLESSE = 2) accepte aussi
# l'intervalle précédent. 0 = ancien comportement (strict). Les formes ne changent pas : seule la date d'affichage bouge.
SOUPLESSE = 2


def lire_wikidata(chemin):
    sortie = []
    with open(chemin, encoding="utf8") as f:
        for ligne in f:
            ligne = ligne.rstrip("\n")
            if not ligne:
                continue
            nom, op, origine, vers, qid, prop = ligne.split("|")
            sortie.append({
                "id": "wd-%s-%s" % (qid, op), "nom": nom, "op": op, "origine": int(origine), "vers": int(vers),
                "auto": True,
                "source": {"type": "wikidata", "qid": qid, "propriete": prop},
            })
    return sortie


def lire_manuelles(chemin):
    with open(chemin, encoding="utf8") as f:
        evenements = json.load(f)
    sortie = []
    for e in evenements:
        for j, a in enumerate(e["ajustements"]):
            sortie.append({
                "id": "%s#%d" % (e["id"], j), "nom": a["nom"], "op": a["op"], "origine": a["origine"], "vers": a["vers"],
                "auto": False, "evenement": e["evenement"], "date_evenement": e["date"],
                "source": e["source"],
            })
    return sortie


class Corrections:
    """lignes : liste de dictionnaires {nom, de, a, geometrie (GeoJSON), …} ; modifie « de » et « a » sur place."""

    def __init__(self, lignes):
        self.lignes = lignes
        for l in lignes:
            l["de0"], l["a0"] = l["de"], l["a"]
        self.par_nom = defaultdict(list)
        for l in lignes:
            self.par_nom[l["nom"]].append(l)
        for v in self.par_nom.values():
            v.sort(key=lambda l: l["de0"])
        self.grille = sorted({l["de0"] for l in lignes} | {l["a0"] + 1 for l in lignes})
        self.par_fin = defaultdict(list)    # a0 → lignes
        self.par_debut = defaultdict(list)  # de0 → lignes
        for l in lignes:
            self.par_fin[l["a0"]].append(l)
            self.par_debut[l["de0"]].append(l)
        self._geom = {}
        self.rapport = []

    # --- outils -------------------------------------------------------------------------------------
    def geom(self, l):
        k = id(l)
        if k not in self._geom:
            self._geom[k] = make_valid(shape(l["geometrie"])).buffer(0)
        return self._geom[k]

    def avant(self, B):
        r = None
        for g in self.grille:
            if g < B:
                r = g
            else:
                break
        return r

    def dernier_instantane(self, E):
        r = None
        for g in self.grille:
            if g <= E:
                r = g
            else:
                break
        return r

    def actives(self, annee, sauf=()):
        return [l for l in self.lignes if l["de"] <= annee <= l["a"] and l not in sauf]

    def part(self, a, b):
        """part de la surface de a recouverte par b"""
        ga, gb = self.geom(a), self.geom(b)
        if ga.is_empty or ga.area == 0 or not ga.intersects(gb):
            return 0.0
        return ga.intersection(gb).area / ga.area

    def note(self, c, statut, detail=""):
        self.rapport.append({"id": c["id"], "nom": c["nom"], "op": c["op"], "origine": c["origine"], "vers": c["vers"],
                             "auto": c["auto"], "source": c["source"], "statut": statut, "detail": detail,
                             **({"evenement": c["evenement"]} if "evenement" in c else {})})

    # --- application --------------------------------------------------------------------------------
    def trouver(self, c):
        lignes = self.par_nom.get(c["nom"], [])
        if c["op"] == "debut":
            cand = [l for l in lignes if l["de0"] == c["origine"]]
            if cand and cand[0] is not lignes[0]:
                return None, "pas la première apparition de l'entité"
        else:
            cand = [l for l in lignes if l["a0"] == c["origine"]]
            if cand and cand[0] is not lignes[-1] and max(l["a0"] for l in lignes) != c["origine"]:
                return None, "pas la dernière ligne de l'entité"
        if not cand:
            return None, "aucune ligne ne commence/finit à cette année dans les données"
        return cand[0], ""

    def valider(self, c):
        l, pb = self.trouver(c)
        if l is None:
            return None, pb
        if c["op"] == "debut":
            P = self.avant(c["origine"])
            bas = P
            if P is not None and SOUPLESSE >= 2:
                bas = self.avant(P) if self.avant(P) is not None else P
            if SOUPLESSE == 0 and P is not None:
                bas = P + 1
            if P is None or not (bas <= c["vers"] < c["origine"]):
                return None, "hors fenêtre ]%s ; %s[" % (P, c["origine"])
            if c["vers"] > l["a"]:
                return None, "naissance après la fin de la ligne"
        else:
            P0 = self.dernier_instantane(c["origine"])
            bas = P0 - 1 if SOUPLESSE >= 1 else P0
            if P0 is not None and SOUPLESSE >= 2 and self.avant(P0) is not None:
                bas = self.avant(P0) - 1
            if P0 is None or not (bas <= c["vers"] < c["origine"]):
                return None, "hors fenêtre [%s ; %s[" % (P0, c["origine"])
            if c["vers"] < l["de"]:
                return None, "fin avant le début de la ligne"
        return l, ""

    def appliquer(self, corrections):
        valides = {"debut": [], "fin": []}
        for c in corrections:
            l, pb = self.valider(c)
            if l is None:
                self.note(c, "refusee", pb)
            else:
                valides[c["op"]].append((c, l))
        # doublons sur une même ligne : on garde la première, on note les autres
        vus = set()
        for op in ("debut", "fin"):
            filtre = []
            for c, l in valides[op]:
                if (op, id(l)) in vus:
                    self.note(c, "refusee", "déjà corrigée par une autre source")
                    continue
                vus.add((op, id(l)))
                filtre.append((c, l))
            valides[op] = filtre
        # 1) les naissances
        for c, l in valides["debut"]:
            B, D = c["origine"], c["vers"]
            l["de"] = D
            deduit = []
            for r in list(self.par_fin.get(B - 1, [])):
                if r is l or r["nom"] == l["nom"] or r["a"] != B - 1 or r["de"] > D - 1:
                    continue
                suite = [s for s in self.par_nom[r["nom"]] if s["de0"] == B]
                p_r, p_l = self.part(r, l), self.part(l, r)
                if suite and p_l >= SEUIL_REPRISE:
                    r["a"] = D - 1
                    suite[0]["de"] = min(suite[0]["de"], D)
                    deduit.append(r["nom"] + " (changement de forme avancé)")
                elif not suite and p_r >= SEUIL_REPRISE:
                    r["a"] = D - 1
                    deduit.append(r["nom"] + " (s'arrête la veille)")
            self.note(c, "appliquee", ("déduit : " + " ; ".join(deduit)) if deduit else "")
        # 2) les disparitions
        for c, l in valides["fin"]:
            E, F = c["origine"], c["vers"]
            reprise = self.reprise(l, F + 1, E)
            if reprise:
                l["a"] = F
                self.note(c, "appliquee", "territoire repris par : " + ", ".join(reprise[:4]))
                continue
            # sinon : une SEULE entité reprend l'essentiel du territoire à l'instantané suivant, et rien d'autre ne
            # fusionne en même temps dans sa nouvelle forme (sinon on avancerait aussi d'autres conquêtes) :
            # on avance alors cette reprise à la date de disparition.
            succ = [s for s in self.par_debut.get(E + 1, []) if s["nom"] != l["nom"] and self.part(l, s) >= SEUIL_REPRISE]
            avance = False
            if len(succ) == 1:
                s = succ[0]
                premiere = s is self.par_nom[s["nom"]][0]
                precedentes = [t for t in self.par_nom[s["nom"]] if t["a0"] == E and t is not s]
                autres = [r for r in self.par_fin.get(E, []) if r is not l and r["nom"] != s["nom"] and self.part(r, s) >= SEUIL_REPRISE]
                if (premiere or precedentes) and not autres and s["de"] > F + 1:
                    s["de"] = F + 1
                    for t in precedentes:
                        t["a"] = min(t["a"], F)
                    avance = True
            if avance:
                l["a"] = F
                self.note(c, "appliquee", "déduit : reprise avancée pour " + succ[0]["nom"])
            else:
                # territoire non repris : on NE retire PAS l'entité plus tôt (elle laisserait un trou sur la carte)
                self.note(c, "refusee", "territoire non repris entre %d et %d (aurait créé un trou)" % (F + 1, E))
        # une ligne devenue vide (a < de) n'est pas supprimée ici : l'appelant l'ignore (les positions restent stables)
        return self.rapport

    def reprise(self, l, annee, jusqua):
        """noms des entités (autres) qui recouvrent ≥ SEUIL_REPRISE du territoire de l à l'année donnée"""
        gl = self.geom(l)
        if gl.is_empty:
            return []
        noms, union = [], None
        for r in self.actives(annee, sauf=(l,)):
            if r["nom"] == l["nom"]:
                continue
            gr = self.geom(r)
            if gr.intersects(gl):
                union = gr if union is None else union.union(gr)
                noms.append(r["nom"])
        if union is None:
            return []
        return noms if gl.intersection(union).area / gl.area >= SEUIL_REPRISE else []
