"""Registre des dates de la carte historique + génération des corrections de dates issues de Wikidata.

POURQUOI (Martin, 2026-10-27) : « reprendre l'ensemble des dates qui marquent des changements de frontière, pour
absolument chaque territoire dans l'histoire, et sourcer chacun des changements dans un document à part ».

CE QUE FAIT CE SCRIPT (aucun accès réseau : les dates Wikidata sont lues dans wikidata_dates_brut.json) :
  1. lit Cliopatria (le fichier source de la carte) et les dates Wikidata (propriétés P571 création, P576 dissolution,
     P580 début, P582 fin ; données CC0, consultées le 2026-10-27) ;
  2. choisit, pour chaque territoire, la date Wikidata utilisable (voir « Règles de choix ») et écrit
     corrections_dates_wikidata.txt, que corrections_dates.py applique ensuite avec ses garde-fous ;
  3. écrit le REGISTRE : une ligne par changement de frontière (naissance, disparition, changement de forme), avec
     la date de la carte d'origine, la date Wikidata, la date finale affichée, le statut et la source.
     -> docs/sources/historique_dates_registre.csv  (lisible dans un tableur ; Martin le consulte via la page publiée).

RÈGLES DE CHOIX d'une date Wikidata (documentées pour être contestables) :
  - on ignore les valeurs « dépréciées » (rang deprecated), les années avant J.-C. (le moteur ne gère que les années ≥ 1)
    et les valeurs imprécises (précision siècle ou décennie : « vers 900 » ne date pas un événement) ;
  - on ne garde que les valeurs qui tombent dans la fenêtre autorisée par la carte (entre deux relevés consécutifs,
    cf. corrections_dates.py) ; s'il en reste plusieurs différentes : rang « préféré » d'abord, sinon celle qui a une
    référence dans Wikidata ; si c'est encore ambigu, on ne tranche pas (statut « ambigu ») ;
  - une valeur hors fenêtre n'est PAS appliquée : elle est notée « divergence » (Wikidata et Cliopatria ne parlent
    pas du même événement, ou l'un des deux se trompe) pour être examinée à la main.

Lancer :  python3 -I scripts/historique/generer_registre_dates.py <cliopatria.geojson> [dossier_registre]
"""
import csv
import json
import os
import sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from corrections_dates import Corrections, lire_manuelles  # noqa: E402

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.join(ICI, "..", "..")
DATE_CONSULTATION = "2026-10-27"
PRECISION_MIN = 9  # 9 = année, 10 = mois, 11 = jour ; 7 = siècle, 8 = décennie (trop imprécis)
SEUIL_FORME = 0.15  # changement de forme « notable » : l'aire varie d'au moins 15 %


def lien_wikidata(qid, prop):
    return "https://www.wikidata.org/wiki/%s#%s" % (qid, prop)


def valeurs(w, props):
    """[(année, précision, préféré, nb_références, propriété)] des valeurs non dépréciées"""
    sortie = []
    for p in props:
        for v in w.get(p, []):
            sortie.append((v[0], v[3], v[4] == 1, v[5], p))
    return sortie


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    source = sys.argv[1]
    sortie = sys.argv[2] if len(sys.argv) > 2 else os.path.join(RACINE, "docs", "sources")
    os.makedirs(sortie, exist_ok=True)

    with open(os.path.join(ICI, "wikidata_dates_brut.json"), encoding="utf8") as f:
        wd = json.load(f)
    with open(os.path.join(ICI, "wikipedia_dates_brut.json"), encoding="utf8") as f:
        wp = json.load(f)["valeurs"]    # {qid: [titre, année_début|null, année_fin|null]} (infobox Wikipédia, secours)
    with open(os.path.join(RACINE, "public", "data", "historique", "noms_fr.json"), encoding="utf8") as f:
        noms_fr = json.load(f)["fr"]
    with open(source, encoding="utf8") as f:
        data = json.load(f)
    entites = [ft for ft in data["features"]
               if ft["properties"]["Type"] == "POLITY" and not ft["properties"]["Name"].startswith("(")]
    entites.sort(key=lambda ft: (ft["properties"]["FromYear"], ft["properties"]["ToYear"], ft["properties"]["Name"]))
    dates = [{"nom": ft["properties"]["Name"], "de": ft["properties"]["FromYear"], "a": ft["properties"]["ToYear"],
              "geometrie": ft["geometry"], "aire": ft["properties"]["Area"]} for ft in entites]
    qid_de = {}
    for ft in entites:
        qid_de.setdefault(ft["properties"]["Name"], ft["properties"]["Wikidata"])

    moteur = Corrections(dates)
    manuelles = lire_manuelles(os.path.join(ICI, "corrections_dates_manuelles.json"))

    def fr(nom):
        n = nom[1:-1] if nom.startswith("(") and nom.endswith(")") else nom
        return noms_fr.get(n, n)

    # ---- 1) choix des dates Wikidata ------------------------------------------------------------------
    choix = []          # corrections à appliquer (format de corrections_dates.lire_wikidata)
    decisions = {}      # (nom, op) -> dict pour le registre (avant application)
    for nom, lignes in moteur.par_nom.items():
        premiere, derniere = lignes[0], lignes[-1]
        qid = qid_de.get(nom, "")
        w = wd.get(qid, {}) if qid else {}
        freres = [n for n, q in qid_de.items() if q == qid and n != nom and n in moteur.par_nom] if qid else []
        for op, props, origine in (("debut", ("P571", "P580"), premiere["de0"]), ("fin", ("P576", "P582"), derniere["a0"])):
            vals = valeurs(w, props)
            info = {"nom": nom, "op": op, "qid": qid, "origine": origine, "wd": vals, "choix": None, "statut": "", "detail": ""}
            decisions[(nom, op)] = info
            if not qid:
                info["statut"], info["detail"] = "source manquante", "pas d'identifiant Wikidata dans Cliopatria"
                continue
            if freres:
                # même identifiant Wikidata donné à plusieurs territoires de Cliopatria : la date n'appartient qu'à celui
                # qui apparaît le premier (création) / disparaît le dernier (fin) ; en cas d'égalité, on ne tranche pas.
                if op == "debut":
                    mien, autres = origine, [moteur.par_nom[n][0]["de0"] for n in freres]
                    ok = all(mien < a for a in autres)
                else:
                    mien, autres = origine, [moteur.par_nom[n][-1]["a0"] for n in freres]
                    ok = all(mien > a for a in autres)
                if not ok:
                    info["statut"], info["detail"] = "source manquante", "identifiant Wikidata %s partagé par plusieurs territoires de Cliopatria : date non attribuable à celui-ci" % qid
                    continue
            exacte = [v for v in vals if v[1] >= PRECISION_MIN and v[0] >= 1]
            if not exacte and qid in wp:
                # secours : l'année de l'infobox Wikipédia (anglais), seulement si Wikidata n'a RIEN d'utilisable
                a_wp = wp[qid][1 if op == "debut" else 2]
                if a_wp is not None and a_wp >= 1:
                    exacte = vals = [(a_wp, 9, False, 0, "WP")]
                    info["wd"] = vals
                    w = w or {"wp": True}
            if not w:
                info["statut"], info["detail"] = "source manquante", "identifiant Wikidata sans date"
                continue
            if not vals:
                info["statut"], info["detail"] = "source manquante", "Wikidata ne donne pas de date de %s" % ("création" if op == "debut" else "fin")
                continue
            if not exacte:
                info["statut"], info["detail"] = "imprécis", "date Wikidata trop imprécise (siècle/décennie) ou avant J.-C."
                continue
            cible = origine if op == "debut" else origine + 1   # année où la carte d'origine montre le changement
            if any(v[0] == cible for v in exacte):
                info["statut"], info["detail"] = "identique", "la carte d'origine a déjà cette date"
                info["choix"] = cible
                continue
            valides = {}
            for v in exacte:
                vers = v[0] if op == "debut" else v[0] - 1
                c = {"nom": nom, "op": op, "origine": origine, "vers": vers}
                ligne, pb = moteur.valider(c)
                if ligne is not None:
                    valides.setdefault(v[0], []).append(v)
                else:
                    info.setdefault("hors", []).append((v[0], pb))
            if not valides:
                pbs = "; ".join("%d : %s" % (a, pb) for a, pb in info.get("hors", [])[:3])
                info["statut"], info["detail"] = "divergence", "date Wikidata hors de la fenêtre de la carte (" + pbs + ")"
                continue
            if len(valides) > 1:
                pref = {a for a, vs in valides.items() if any(v[2] for v in vs)}
                ref = {a for a, vs in valides.items() if any(v[3] > 0 for v in vs)}
                retenu = pref if len(pref) == 1 else (ref if len(pref) != 1 and len(ref) == 1 else set())
                if len(retenu) != 1:
                    info["statut"], info["detail"] = "ambigu", "plusieurs dates Wikidata possibles : " + ", ".join(str(a) for a in sorted(valides))
                    continue
                annee = next(iter(retenu))
            else:
                annee = next(iter(valides))
            vs = valides[annee]
            prop = vs[0][4]
            vers = annee if op == "debut" else annee - 1
            choix.append({"id": "wd-%s-%s" % (qid, op), "nom": nom, "op": op, "origine": origine, "vers": vers, "auto": True,
                          "source": {"type": "wikidata", "qid": qid, "propriete": prop}})
            info["choix"] = annee
            info["prop"] = prop

    # ---- 2) application (mêmes garde-fous que pour la carte) ---------------------------------------
    # Les événements manuels passent en premier : ils l'emportent sur Wikidata pour une même ligne.
    rapport = moteur.appliquer(manuelles + choix)
    rap = {r["id"]: r for r in rapport}
    par_cle = {}
    for r in rapport:
        par_cle[(r["nom"], r["op"])] = r

    # ---- 3) fichier lu par le moteur -----------------------------------------------------------------
    with open(os.path.join(ICI, "corrections_dates_wikidata.txt"), "w", encoding="utf8") as f:
        for c in choix:
            f.write("%s|%s|%d|%d|%s|%s\n" % (c["nom"], c["op"], c["origine"], c["vers"], c["source"]["qid"], c["source"]["propriete"]))
    with open(os.path.join(ICI, "corrections_dates_rapport.json"), "w", encoding="utf8") as f:
        json.dump(rapport, f, ensure_ascii=False, indent=0)

    # ---- 4) registre ----------------------------------------------------------------------------------
    registre = []

    def wd_texte(vals):
        return " ; ".join(sorted({"%d (%s)" % (v[0], v[4]) for v in vals}, key=lambda s: int(s.split()[0])))

    for (nom, op), info in sorted(decisions.items(), key=lambda kv: (kv[1]["origine"], kv[0][0], kv[0][1])):
        lignes = moteur.par_nom[nom]
        l0 = lignes[0] if op == "debut" else lignes[-1]
        orig = info["origine"] if op == "debut" else info["origine"] + 1
        manu = [r for r in rapport if r["nom"] == nom and r["op"] == op and not r["auto"]]
        r = manu[0] if manu else par_cle.get((nom, op))
        statut, detail = info["statut"], info["detail"]
        final = orig
        source = lien_wikidata(info["qid"], info.get("prop", "P571" if op == "debut" else "P576")) if info["qid"] else ""
        fiab = "Wikidata, CC0 ; fiabilité variable selon la référence (voir Wikidata)"
        licence = "CC0" if info["qid"] else ""
        if info.get("prop") == "WP":
            source = "https://en.wikipedia.org/wiki/" + wp[info["qid"]][0].replace(" ", "_")
            fiab = "Wikipédia (infobox, année seule) ; fiabilité moyenne, à recouper"
            licence = "CC BY-SA 4.0"
        if r is not None:
            if r["statut"] == "appliquee":
                statut = "appliquée"
                final = r["vers"] if op == "debut" else r["vers"] + 1
                detail = r["detail"]
            else:
                statut = "refusée"
                detail = r["detail"]
            if not r["auto"]:   # événement saisi à la main, avec sa propre source
                src = r["source"]
                source, licence, fiab = src["lien"], src["licence"], src["fiabilite"]
                detail = ("Événement : " + r["evenement"] + (" — " + detail if detail else "")).strip()
        registre.append({
            "type": "naissance" if op == "debut" else "disparition", "nom": nom, "nom_fr": fr(nom), "qid": info["qid"],
            "date_carte_origine": orig, "date_wikidata": wd_texte(info["wd"]) if info["wd"] else "", "date_finale": final,
            "statut": statut, "detail": detail, "source": source, "licence": licence,
            "fiabilite": fiab if (info["qid"] or r is not None and not r["auto"]) else "SOURCE MANQUANTE",
        })
    # changements de forme internes (une ligne de plus pour une même entité, sans interruption)
    for nom, lignes in moteur.par_nom.items():
        for a, b in zip(lignes, lignes[1:]):
            if b["de0"] > a["a0"] + 1:
                continue   # interruption : l'entité disparaît puis réapparaît, ce n'est pas un changement de forme
            aire_a, aire_b = a.get("aire") or 0, b.get("aire") or 0
            variation = (aire_b - aire_a) / aire_a if aire_a else 0
            registre.append({
                "type": "changement de forme" + (" notable" if abs(variation) >= SEUIL_FORME else ""),
                "nom": nom, "nom_fr": fr(nom), "qid": qid_de.get(nom, ""),
                "date_carte_origine": b["de0"], "date_wikidata": "", "date_finale": b["de"],
                "statut": "à sourcer" if b["de"] == b["de0"] else "avancé (déduit)",
                "detail": "aire %+d %% (relevé précédent %d)" % (round(variation * 100), a["de0"]),
                "source": "", "licence": "", "fiabilite": "SOURCE MANQUANTE (Cliopatria seule : date du relevé, pas de l'événement)",
            })
    registre.sort(key=lambda x: (x["date_carte_origine"], x["nom"], x["type"]))

    champs = ["type", "nom", "nom_fr", "qid", "date_carte_origine", "date_wikidata", "date_finale", "statut", "detail",
              "source", "licence", "fiabilite"]
    with open(os.path.join(sortie, "historique_dates_registre.csv"), "w", encoding="utf8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=champs)
        w.writeheader()
        w.writerows(registre)
    bilan = defaultdict(int)
    for x in registre:
        bilan[(x["type"].split(" notable")[0], x["statut"])] += 1
    for k, v in sorted(bilan.items()):
        print("%-22s %-18s %5d" % (k[0], k[1], v))
    print("Registre :", len(registre), "lignes ;", len(choix), "dates Wikidata retenues pour application")


if __name__ == "__main__":
    main()
