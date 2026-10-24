#!/usr/bin/env python3
"""Audit A1 (LECTURE SEULE) : cohérence des champs de Cliopatria (sans géométrie).
Usage : python3 -I a1_attributs.py <cliopatria.geojson> <dossier_sortie>"""
import json, sys, os, collections, statistics

src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
F = json.load(open(src, encoding="utf8"))["features"]
P = [f["properties"] for f in F]
R = {}
pol = [p for p in P if p["Type"] == "POLITY"]
rel = [p for p in P if p["Type"] == "RELATION"]
umb = [p for p in pol if p["Name"].startswith("(")]
ent = [p for p in pol if not p["Name"].startswith("(")]
R["comptes"] = dict(total=len(P), polity=len(pol), relation=len(rel), ensembles=len(umb), entites=len(ent))

R["dates_inversees"] = [(p["Name"], p["FromYear"], p["ToYear"]) for p in P if p["FromYear"] > p["ToYear"]]
R["annee_0"] = sorted({p["Name"] for p in P if p["FromYear"] == 0 or p["ToYear"] == 0})[:40]
d = [p["ToYear"] - p["FromYear"] + 1 for p in ent]
R["duree_lignes"] = dict(mediane=statistics.median(d), min=min(d), max=max(d), une_annee=sum(x == 1 for x in d))

# Identité : QID absents, QID partagés par des noms différents, noms avec plusieurs QID
R["sans_qid"] = sorted({p["Name"] for p in ent if not p["Wikidata"]})
R["sans_wikipedia"] = sorted({p["Name"] for p in ent if not p["Wikipedia"]})
par_qid = collections.defaultdict(set)
par_nom = collections.defaultdict(set)
for p in ent:
    if p["Wikidata"]:
        par_qid[p["Wikidata"]].add(p["Name"])
    par_nom[p["Name"]].add(p["Wikidata"])
R["qid_partage_par_plusieurs_noms"] = {q: sorted(n) for q, n in par_qid.items() if len(n) > 1}
R["nom_avec_plusieurs_qid"] = {n: sorted(q) for n, q in par_nom.items() if len(q) > 1}

# Continuité par entité (clé = nom) : chevauchements d'années (deux tracés la même année) et trous
par = collections.defaultdict(list)
for p in ent:
    par[p["Name"]].append((p["FromYear"], p["ToYear"], p["Area"]))
chev, trous, sauts = [], [], []
for n, L in par.items():
    L.sort()
    for a, b in zip(L, L[1:]):
        if b[0] <= a[1]:
            chev.append((n, a[:2], b[:2]))
        elif b[0] > a[1] + 1:
            trous.append((n, a[1], b[0], b[0] - a[1] - 1))
        r = max(a[2], b[2]) / max(1.0, min(a[2], b[2]))
        if b[0] == a[1] + 1 and r > 5 and max(a[2], b[2]) > 50000:
            sauts.append((n, a[1], b[0], round(a[2]), round(b[2]), round(r, 1)))
R["meme_entite_deux_traces_meme_annee"] = chev
R["trous_dans_la_vie_d_une_entite"] = sorted(trous, key=lambda t: -t[3])[:200]
R["nb_trous"] = len(trous)
R["sauts_de_superficie_x5"] = sorted(sauts, key=lambda t: -t[5])[:200]
R["nb_sauts"] = len(sauts)

# Superficies extrêmes
R["tres_grandes"] = sorted(((p["Name"], p["FromYear"], p["ToYear"], round(p["Area"])) for p in ent), key=lambda t: -t[3])[:40]
R["tres_petites"] = sorted(((p["Name"], p["FromYear"], p["ToYear"], round(p["Area"])) for p in ent if p["Area"] < 200), key=lambda t: t[3])[:60]
R["nb_aire_inf_200km2"] = sum(p["Area"] < 200 for p in ent)

# Ensembles : composants existants, membres déclarés, durées
noms_ent = {p["Name"] for p in pol}
manq = collections.defaultdict(set)
for p in umb:
    for c in filter(None, (x.strip() for x in p["Components"].split(";"))):
        if c not in noms_ent:
            manq[p["Name"]].add(c)
R["composants_introuvables"] = {k: sorted(v) for k, v in manq.items()}
memb_inconnus = sorted({m.strip() for p in ent for m in p["MemberOf"].split(";") if m.strip() and m.strip() not in noms_ent})
R["memberof_inconnus"] = memb_inconnus

# Couverture temporelle : nombre d'entités par année (échantillon tous les 50 ans) — repère les « déserts »
cnt = {}
for a in range(-3400, 2025, 50):
    cnt[a] = sum(1 for p in ent if p["FromYear"] <= a <= p["ToYear"])
R["entites_par_annee_pas50"] = cnt
vides = [a for a in range(-3400, 2025) if not any(p["FromYear"] <= a <= p["ToYear"] for p in ent)]
R["annees_sans_aucune_entite"] = vides[:50]

# Relations
R["relations_types"] = collections.Counter(p["Name"].split("(")[0].strip() for p in rel).most_common(15)
json.dump(R, open(os.path.join(out, "a1.json"), "w", encoding="utf8"), ensure_ascii=False, indent=1, default=list)
for k, v in R.items():
    s = json.dumps(v, ensure_ascii=False, default=list)
    print(k, "→", s[:300])
