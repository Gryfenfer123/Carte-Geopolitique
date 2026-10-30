#!/usr/bin/env python3
"""Fabrique la liste des décisions sur les chevauchements (chantier historique).

Entrées (toutes dans le dépôt) :
  audit/chevauchements_bruts.json   les 179 paires d'entités qui se recouvrent (audit du 2026-10-30)
  audit/chevauchements_infos.json   pour chaque entité : QID Wikidata, titre Wikipédia, dates de la carte
  chevauchements_table.py           le classement (garder / retirer, motif) décidé paire par paire
  wikidata_dates_brut.json          dates Wikidata (CC0) déjà récupérées
Sorties :
  chevauchements_decisions.json     lu par preparer_cliopatria.py (via corrections_formes)
  ../../docs/sources/historique_chevauchements.csv   le document consultable par Martin
Usage : python3 -I generer_decisions_chevauchements.py"""
import csv, json, os, sys

ICI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ICI)
import chevauchements_table as TAB  # noqa: E402


def charger(nom):
    with open(os.path.join(ICI, nom), encoding="utf8") as f:
        return json.load(f)


paires = charger("audit/chevauchements_bruts.json")
infos = charger("audit/chevauchements_infos.json")["info"]
wd = charger("wikidata_dates_brut.json")


def annees(qid, prop):
    v = wd.get(qid, {}).get(prop) or []
    return sorted({x[0] for x in v})


def fiche(nom):
    i = infos.get(nom, {})
    q = i.get("q", "")
    titre = (i.get("w") or nom).replace(" ", "_")
    p571, p576 = annees(q, "P571"), annees(q, "P576")
    return {
        "nom": nom, "qid": q,
        "wikipedia": "https://en.wikipedia.org/wiki/" + titre,
        "wikidata": "https://www.wikidata.org/wiki/" + q if q else "",
        "naissance_wikidata": p571[0] if p571 else None,
        "fin_wikidata": p576[-1] if p576 else None,
        "sur_la_carte": [i.get("de"), i.get("a")],
    }


def soutien(cat, de, a, cut, autre):
    """Les dates Wikidata confirment-elles la coupe ? Un repère, pas une preuve (Wikidata est parfois imprécis)."""
    if cat in ("OCCUPATION", "CONTESTE", "NONTRANCHE"):
        return "sans objet (chevauchement conservé)"
    msgs = []
    if autre["naissance_wikidata"] is not None:
        ok = autre["naissance_wikidata"] <= de + 2
        msgs.append("%s : naissance %s (Wikidata) %s" % (autre["nom"], autre["naissance_wikidata"], "✔ avant %s" % de if ok else "✘ NON CONFIRMÉ (après %s)" % de))
    if cat in ("PERIME", "ANNEXION", "DOUBLON") and cut["fin_wikidata"] is not None:
        ok = cut["fin_wikidata"] <= de + 2
        msgs.append("%s : fin %s (Wikidata) %s" % (cut["nom"], cut["fin_wikidata"], "✔ avant %s" % de if ok else "✘ non confirmé (après %s)" % de))
    return " ; ".join(msgs) if msgs else "pas de date Wikidata exploitable : classement d'après la page Wikipédia citée"


decisions = []
for p in paires:
    x, y = p["x"], p["y"]
    cle = (x, y) if (x, y) in TAB.T else (y, x)
    action, cut, cat, note = TAB.T[cle]
    autre_nom = y if cut == x else x
    par = None
    fen = None
    if action == "R":
        par = autre_nom
        fen = TAB.FENETRES.get((cut, par))
    fx, fy = fiche(x), fiche(y)
    fcut = fx if cut == x else fy
    fautre = fy if cut == x else fx
    d = {
        "x": x, "y": y, "de": p["de"], "a": p["a"], "part_recouverte_pct": round(p["part"] * 100),
        "decision": "retirer" if action == "R" else "garder",
        "categorie": cat,
        "retirer_a": cut if action == "R" else None,
        "zone_de": par,
        "annees": list(fen) if fen else None,
        "motif": TAB.CAT[cat] + ((" " + note) if note else ""),
        "dates_wikidata": {x: [fx["naissance_wikidata"], fx["fin_wikidata"]], y: [fy["naissance_wikidata"], fy["fin_wikidata"]]},
        "controle_dates": soutien(cat, p["de"], p["a"], fcut, fautre) if action == "R" else soutien(cat, p["de"], p["a"], fx, fy),
        "sources": [
            {"titre": "Wikipédia (en) — " + fx["nom"], "lien": fx["wikipedia"], "licence": "CC BY-SA 4.0", "fiabilite": "Bonne (article encyclopédique) ; classement à contre-vérifier sur la page"},
            {"titre": "Wikipédia (en) — " + fy["nom"], "lien": fy["wikipedia"], "licence": "CC BY-SA 4.0", "fiabilite": "Bonne (article encyclopédique) ; classement à contre-vérifier sur la page"},
            {"titre": "Wikidata — dates de création/fin", "lien": fx["wikidata"] or fy["wikidata"], "licence": "CC0", "fiabilite": "Variable selon la référence"},
        ],
    }
    decisions.append(d)

for cut, par, fen, cat, note in TAB.EXTRA:
    fcut, fpar = fiche(cut), fiche(par)
    decisions.append({
        "x": cut, "y": par, "de": fen[0], "a": fen[1], "part_recouverte_pct": None,
        "decision": "retirer", "categorie": cat, "retirer_a": cut, "zone_de": par, "annees": list(fen),
        "motif": TAB.CAT[cat] + " " + note,
        "dates_wikidata": {cut: [fcut["naissance_wikidata"], fcut["fin_wikidata"]], par: [fpar["naissance_wikidata"], fpar["fin_wikidata"]]},
        "controle_dates": soutien(cat, fen[0], fen[1], fcut, fpar),
        "sources": [
            {"titre": "Wikipédia (en) — " + fcut["nom"], "lien": fcut["wikipedia"], "licence": "CC BY-SA 4.0", "fiabilite": "Bonne ; à contre-vérifier"},
            {"titre": "Wikipédia (en) — " + fpar["nom"], "lien": fpar["wikipedia"], "licence": "CC BY-SA 4.0", "fiabilite": "Bonne ; à contre-vérifier"},
        ],
    })

# ── Deuxième passe : ce qui se recouvre encore APRÈS la première série de coupes (audit a4 sur les contours corrigés) ──
# Ces chevauchements viennent surtout des corrections de dates (un État qui naît plus tôt que dans la source se pose sur
# l'ancien) ou de contours « parapluie ». Règle appliquée, la même pour tous, et écrite dans chaque ligne :
#   1. RELAIS : l'ancien État disparaît pendant (ou juste après) le recouvrement et le nouveau naît pendant : on retire
#      la zone au plus ancien à partir de la naissance du nouveau (convention de Martin : nouveau dès l'année D, ancien jusqu'à D-1).
#   2. ENSEMBLE / PARTIE : un contour bien plus grand contient un plus petit (surface du petit < 80 % du grand) : on retire la
#      zone du petit au grand.
#   3. sinon : on retire la zone au plus ancien et on signale « à revoir ».
passe1 = []
for _n in ("audit/chevauchements_apres_passe1.json", "audit/chevauchements_apres_passe2.json", "audit/chevauchements_apres_passe3.json", "audit/chevauchements_apres_passe4.json", "audit/chevauchements_apres_passe5.json"):   # audits successifs, chacun sur le résultat des coupes précédentes
    if os.path.exists(os.path.join(ICI, _n)):
        passe1 += charger(_n)
deja = {tuple(sorted((d["x"], d["y"]))) for d in decisions}
deja |= {tuple(sorted(k)) for k in TAB.T}
A_REVOIR = []
for p in passe1:
    cle = tuple(sorted((p["x"], p["y"])))
    if cle in deja:
        continue
    x, y, lo, hi = p["x"], p["y"], p["de"], p["a"]
    ex = p["existe"]
    # le plus ancien = naissance la plus précoce sur la carte ; à égalité, le plus grand contour
    ancien, jeune = (x, y) if (ex[x][0], -p["aire"][x]) <= (ex[y][0], -p["aire"][y]) else (y, x)
    petit, grand = (x, y) if p["aire"][x] < p["aire"][y] else (y, x)
    ratio = p["aire"][petit] / p["aire"][grand]
    manuel = TAB.PASSE2.get(cle)
    if manuel:
        cat, cut, note = manuel
    elif ex[ancien][1] <= hi + 1 and ex[jeune][0] >= lo - 1:
        cat, cut, note = "RELAIS", ancien, "%s disparaît (dernière année sur la carte : %s) quand %s apparaît (%s)." % (ancien, ex[ancien][1], jeune, ex[jeune][0])
    elif p["part"] < 0.5:
        cat, cut, note = "FRONTIERE", ancien, "Les contours de deux voisins se recouvrent sur une bande de frontière (%d %% du plus petit) ; on retire la zone au plus ancien (%s) — à contre-vérifier." % (round(p["part"] * 100), ancien)
    elif ratio < 0.8:
        cat, cut, note = "ENSEMBLE_PARTIE", grand, "Le contour de %s (plus grand) contient celui de %s." % (grand, petit)
    else:
        cat, cut, note = "A_REVOIR", ancien, "Deux contours de taille proche se recouvrent ; on retire la zone au plus ancien (%s) — à contre-vérifier." % ancien
        A_REVOIR.append((x, y, lo, hi))
    fx, fy = fiche(x), fiche(y)
    if cut is None:   # décision manuelle « garder »
        decisions.append({"x": x, "y": y, "de": lo, "a": hi, "part_recouverte_pct": round(p["part"] * 100), "decision": "garder",
                          "categorie": cat, "retirer_a": None, "zone_de": None, "annees": None, "motif": TAB.CAT[cat] + " " + note,
                          "dates_wikidata": {x: [fx["naissance_wikidata"], fx["fin_wikidata"]], y: [fy["naissance_wikidata"], fy["fin_wikidata"]]},
                          "controle_dates": "sans objet (chevauchement conservé)",
                          "sources": [{"titre": "Wikipédia (en) — " + fx["nom"], "lien": fx["wikipedia"], "licence": "CC BY-SA 4.0", "fiabilite": "Bonne ; à contre-vérifier"},
                                      {"titre": "Wikipédia (en) — " + fy["nom"], "lien": fy["wikipedia"], "licence": "CC BY-SA 4.0", "fiabilite": "Bonne ; à contre-vérifier"}]})
        continue
    par = y if cut == x else x
    fcut, fautre = (fx, fy) if cut == x else (fy, fx)
    decisions.append({
        "x": x, "y": y, "de": lo, "a": hi, "part_recouverte_pct": round(p["part"] * 100),
        "decision": "retirer", "categorie": cat, "retirer_a": cut, "zone_de": par,
        "annees": [lo, hi] if cat == "RELAIS" else None,   # seul un relais est limité à ses années ; les autres sont coupés sur toutes les années communes
        "motif": TAB.CAT[cat] + " " + note,
        "dates_wikidata": {x: [fx["naissance_wikidata"], fx["fin_wikidata"]], y: [fy["naissance_wikidata"], fy["fin_wikidata"]]},
        "controle_dates": soutien("PERIME" if cat == "RELAIS" else "IND", lo, hi, fcut, fautre),
        "sources": [
            {"titre": "Wikipédia (en) — " + fx["nom"], "lien": fx["wikipedia"], "licence": "CC BY-SA 4.0", "fiabilite": "Bonne ; classement automatique à contre-vérifier"},
            {"titre": "Wikipédia (en) — " + fy["nom"], "lien": fy["wikipedia"], "licence": "CC BY-SA 4.0", "fiabilite": "Bonne ; classement automatique à contre-vérifier"},
            {"titre": "Wikidata — dates de création/fin", "lien": fx["wikidata"] or fy["wikidata"], "licence": "CC0", "fiabilite": "Variable selon la référence"},
        ],
    })

with open(os.path.join(ICI, "chevauchements_decisions.json"), "w", encoding="utf8") as f:
    json.dump({"genere": "2026-10-30", "categories": TAB.CAT, "decisions": decisions}, f, ensure_ascii=False, indent=1)

csvp = os.path.join(ICI, "..", "..", "docs", "sources", "historique_chevauchements.csv")
with open(csvp, "w", encoding="utf8", newline="") as f:
    w = csv.writer(f)
    w.writerow(["entité A", "entité B", "années sur la carte", "part recouverte %", "décision", "on retire à", "zone de", "années de la coupe", "catégorie", "motif", "contrôle des dates", "source A", "source B"])
    for d in decisions:
        w.writerow([d["x"], d["y"], "%s à %s" % (d["de"], d["a"]), d["part_recouverte_pct"] if d["part_recouverte_pct"] is not None else "", d["decision"],
                    d["retirer_a"] or "", d["zone_de"] or "", ("%s à %s" % tuple(d["annees"])) if d["annees"] else "", d["categorie"], d["motif"],
                    d["controle_dates"], d["sources"][0]["lien"], d["sources"][1]["lien"]])
print(len(A_REVOIR), "paires « à revoir »")
print(len(decisions), "décisions ;", sum(1 for d in decisions if d["decision"] == "retirer"), "à retirer ;", sum(1 for d in decisions if d["decision"] == "garder"), "conservées")
