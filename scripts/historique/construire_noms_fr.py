#!/usr/bin/env python3
"""Construit public/data/historique/noms_fr.json : le nom FRANÇAIS de chaque entité de la carte historique.

POURQUOI (Martin, 2026-10-23) : « remplacer tout avec des noms en français ». Cliopatria n'a que des noms anglais.
Deux origines, toujours distinguées dans le fichier produit :
  1. WIKIDATA (libellé français de l'élément Wikidata lié à l'entité, données CC0) — fichier brut
     scripts/historique/wikidata_fr_brut.json, récupéré le 2026-10-23 puis FILTRÉ : on ne garde un libellé que si le
     libellé anglais Wikidata ressemble au nom Cliopatria (sinon l'identifiant Wikidata pointe vers autre chose :
     « Cao Cao » pour une dynastie, « live » pour la Livonie…). Les cas douteux repérés à la main sont dans EXCLUS.
  2. TRADUCTIONS PROPOSÉES PAR CLAUDE (scripts/historique/traductions_fr.json) pour tout le reste : listées dans
     « traduits », À RELIRE par Martin.
Un nom sans français reste en anglais à l'écran. Rien n'est inventé : pas de traduction = nom d'origine.

Usage : python3 scripts/historique/construire_noms_fr.py   (après preparer_cliopatria.py ; ne change pas les tracés)
Les numéros du fichier brut sont les positions dans index.json → à regénérer si l'index est régénéré
(vérification ci-dessous : la liste des noms doit avoir la taille attendue).
"""
import json
import os

ICI = os.path.dirname(os.path.abspath(__file__))
DONNEES = os.path.join(ICI, "..", "..", "public", "data", "historique")
NB_NOMS_ATTENDU = 1590

# Positions dont le libellé Wikidata est hors-sujet (personne, parti, « histoire de… », peuple au lieu de l'État, etc.)
EXCLUS = {49, 217, 903, 1404, 1381, 1384, 1352, 1488, 1489, 1037, 1277, 1016, 1017, 1033, 1020, 558, 1209, 1319,
          1347, 869, 1410, 1422, 285, 936, 962, 275, 1402, 207, 1166, 1247, 1192, 1424, 154, 1025, 1026, 1367,
          600, 632, 636, 1290, 106, 1145, 1316,
          # 2e passe de relecture (le libellé Wikidata désigne une autre entité : « République populaire de Chine » pour la
          # Chine de 1914, « Corée du Nord » pour la Corée du Sud, etc.) :
          28, 52, 55, 59, 102, 172, 232, 269, 273, 293, 294, 303, 409, 530, 541, 543, 622, 660, 668, 674, 685, 753,
          757, 864, 898, 902, 1001, 1132, 1144, 1164, 1165, 1204, 1265, 1339, 1351, 1353, 1363, 1403, 1408, 1421,
          1309, 1428, 1439, 1445, 1458, 1475, 1548, 1550, 1552, 1553, 1578}


def sans_parentheses(n):
    return n[1:-1] if n.startswith("(") and n.endswith(")") else n


def main():
    with open(os.path.join(DONNEES, "index.json"), encoding="utf8") as f:
        index = json.load(f)
    noms = index["noms"]
    assert len(noms) == NB_NOMS_ATTENDU, "index.json a changé : régénérer wikidata_fr_brut.json"
    with open(os.path.join(ICI, "wikidata_fr_brut.json"), encoding="utf8") as f:
        brut = json.load(f)
    with open(os.path.join(ICI, "traductions_fr.json"), encoding="utf8") as f:
        trad = {k.strip(): v for k, v in json.load(f).items() if not k.startswith("_")}

    fr, traduits = {}, []
    for i, v in brut.items():
        i = int(i)
        if i in EXCLUS or not v.strip():
            continue
        fr.setdefault(sans_parentheses(noms[i]), v)
    for en, v in trad.items():
        if en not in fr:  # Wikidata (vérifié) passe avant nos propositions
            fr[en] = v
            traduits.append(en)
    # Noms réellement affichables : entités (meta) + ensembles (champ MemberOf, parfois « (A);(B) »)
    voulus = {sans_parentheses(noms[m[0]]) for m in index["meta"]}
    for ligne in index["lignes"]:
        if ligne[4] >= 0:
            for p in noms[ligne[4]].split(";"):
                voulus.add(sans_parentheses(p.strip()))
    manquants = sorted(n for n in voulus if n not in fr)
    sortie = {"version": 1, "fr": dict(sorted(fr.items())), "traduits": sorted(traduits)}
    with open(os.path.join(DONNEES, "noms_fr.json"), "w", encoding="utf8") as f:
        json.dump(sortie, f, ensure_ascii=False, separators=(",", ":"))
    print(f"{len(fr)} noms français ({len(fr) - len(traduits)} Wikidata, {len(traduits)} traductions à relire)")
    print(f"{len(voulus)} noms affichables, {len(manquants)} sans français :", manquants[:60])


if __name__ == "__main__":
    main()
