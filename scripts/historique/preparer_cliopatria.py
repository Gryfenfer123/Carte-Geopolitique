#!/usr/bin/env python3
"""Prépare les données Cliopatria pour la carte historique du site.

POURQUOI CE SCRIPT (Martin, 2026-10-23) : la carte historique doit montrer l'évolution année par année du
monde entier. La source retenue est Cliopatria (Seshat Global History Databank, licence CC BY 4.0), mais son
fichier fait 172 Mo : on ne peut pas l'envoyer tel quel dans un navigateur. Ce script le transforme en
fichiers légers (index + morceaux de tracés) que le site charge à la demande, SANS rien inventer :
on ne fait que (1) simplifier légèrement les contours, (2) coder les coordonnées plus court.
Ce sont des modifications à indiquer (exigence de la licence CC BY) : voir public/data/historique/SOURCE.md.

SOURCE (à télécharger soi-même, elle n'est pas dans le dépôt) :
  https://github.com/Seshat-Global-History-Databank/cliopatria  → fichier cliopatria.geojson.zip (version 0.2.1)
  Décompresser, puis :
      pip install shapely
      python3 scripts/historique/preparer_cliopatria.py chemin/vers/cliopatria_polities_only_v021.geojson \\
              [dossier_sortie] [--terres chemin/vers/terres_10m.geojson] [--sans-dates]
  (--terres : trait de côte réel, voir caler_cotes.py et extraire_terres.mjs ; --sans-dates : n'applique pas les
   corrections de dates, voir corrections_dates.py)

CE QUI EST GARDÉ / ÉCARTÉ
  - gardé : les lignes de type POLITY dont le nom ne commence pas par « ( » = les entités qu'on peint sur la
    carte. Les entités entre parenthèses, ex. « (Holy Roman Empire) », sont des ENSEMBLES (union de leurs
    membres, champ Components) : on ne les peint pas (ce serait doubler leurs membres) mais on retient leur nom
    comme « groupe » de chaque membre (champ MemberOf) pour colorer et surligner les ensembles.
  - écarté pour l'instant : les lignes de type RELATION (alliances, vassalités, unions personnelles) : ce sont
    des zones qui chevauchent les entités ; elles pourront devenir une couche à part plus tard.

FORMAT PRODUIT (dans public/data/historique/)
  index.json   {version, noms[], meta[], lignes[], morceaux[]}
      noms[i]            : un nom (entité ou ensemble)
      meta[j]            : [indexNom, pageWikipedia, idWikidata, idSeshat]  (valeurs distinctes)
      lignes[k]          : [indexMeta, anneeDebut, anneeFin, idTrace, indexNomEnsemble(-1 si aucun), aireKm2]
                           une ligne = « de anneeDebut à anneeFin incluses, cette entité a CE tracé »
      morceaux[m]        : [premierIdTrace, nombreDeTraces]  → fichier geo_<mmm>.json
  geo_NNN.json  liste de tracés ; un tracé = liste de polygones ; un polygone = liste d'anneaux (le 1er = contour,
                les suivants = trous) ; un anneau = suite d'entiers [x0, y0, dx1, dy1, …] en centièmes de degré
                (x = longitude, y = latitude ; le 1er point est absolu, les suivants sont des écarts ; le point
                de fermeture n'est pas répété).
"""
import hashlib
import json
import math
import multiprocessing
import os
import sys

import shapely
from shapely.geometry import mapping, shape
from shapely.validation import make_valid

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from caler_cotes import Cote  # noqa: E402  (calage sur la côte réelle)
from corrections_dates import Corrections, lire_manuelles, lire_wikidata  # noqa: E402  (dates réelles)
import corrections_formes  # noqa: E402  (retire d'un contour un État indépendant recouvert à tort)

VERSION_SOURCE = "0.2.1"
CENTIEMES = 100  # précision des coordonnées : 0,01° ≈ 1 km
TAILLE_MORCEAU = 450_000  # octets visés par fichier de tracés (le site ne charge que ceux dont il a besoin)


def tolerance(geom):
    """Simplification proportionnelle à la taille de la forme : les petits territoires gardent du détail,
    les grands empires sont allégés davantage (au plus ≈ 8 km, invisible à l'échelle du monde)."""
    minx, miny, maxx, maxy = geom.bounds
    largeur, hauteur = max(maxx - minx, 0.01), max(maxy - miny, 0.01)
    return min(0.08, max(0.01, 0.012 * math.sqrt(largeur * hauteur)))


def coder_anneau(coords):
    """Anneau → entiers [x0, y0, dx1, dy1, …] ; retourne None si l'anneau devient dégénéré."""
    points = []
    for lon, lat in coords:
        p = (round(lon * CENTIEMES), round(lat * CENTIEMES))
        if not points or p != points[-1]:
            points.append(p)
    if len(points) > 1 and points[0] == points[-1]:
        points.pop()  # point de fermeture non répété
    if len(points) < 3:
        return None
    flat = [points[0][0], points[0][1]]
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        flat += [x1 - x0, y1 - y0]
    return flat


def coder_geometrie(geom):
    """Géométrie shapely → liste de polygones codés (liste d'anneaux). None si tout est dégénéré."""
    polys = []
    g = mapping(geom)
    morceaux = g["coordinates"] if g["type"] == "MultiPolygon" else [g["coordinates"]]
    for poly in morceaux:
        anneaux = []
        for i, anneau in enumerate(poly):
            a = coder_anneau(anneau)
            if a is None:
                if i == 0:
                    anneaux = []
                    break
                continue  # un trou dégénéré est simplement ignoré
            anneaux.append(a)
        if anneaux:
            polys.append(anneaux)
    return polys or None


def simplifier(geom):
    """Simplifie CHAQUE partie séparément, avec une tolérance adaptée à sa propre taille.
    (Réglée sur l'ensemble, la tolérance d'un empire éparpillé — comptoirs, îles — écrasait ses petites parties :
    constaté sur « First French colonial empire » 1805 et « Republic of Venice » 1285, recouvrement ≈ 0,7–0,85.)"""
    sortie = []
    for partie in shapely.get_parts(geom):
        if partie.geom_type != "Polygon":
            continue  # points/lignes parasites issus d'une réparation de géométrie
        s = partie.simplify(tolerance(partie), preserve_topology=True)
        sortie.append(partie if s.is_empty else s)
    return shapely.union_all(sortie)  # fusionne d'éventuels recouvrements entre parties après simplification


COTE = None  # trait de côte réel (objet Cote), fixé dans main() ; hérité par les processus enfants (fork)
COMBLER = True  # combler les liserés de terre vide entre le contour et la côte (--sans-comblage pour désactiver)
FACTEUR_COTE = 0.5  # tolérance de re-simplification après calage = FACTEUR_COTE × tolérance de la forme


def preparer_trace(geometrie_geojson):
    geom = shape(geometrie_geojson)
    if not geom.is_valid:
        geom = make_valid(geom)
    # set_precision cale les points sur la grille de 0,01° ET répare les croisements que l'arrondi
    # ferait apparaître : les polygones produits sont toujours valides (contrôlé par verifier_donnees.py).
    pas = 1 / CENTIEMES
    lisse = simplifier(geom)
    if COTE is not None:
        # on ne fait que RETIRER ce qui est en pleine mer (voir caler_cotes.py)
        d_comble = min(0.12, max(0.02, 2 * tolerance(geom))) if COMBLER else 0.0   # voir Cote.combler (écarts à la côte)
        cale, _ = COTE.caler(lisse, tol=max(0.004, FACTEUR_COTE * tolerance(geom)), comble=d_comble)
        if not cale.is_empty:
            lisse = cale
    simple = shapely.set_precision(lisse, pas)
    codee = coder_geometrie(simple) if not simple.is_empty else None
    if codee is None:  # tout petit territoire écrasé par la grille : on garde le contour d'origine
        codee = coder_geometrie(shapely.set_precision(geom, pas))
    return codee


ENTITES = []  # lignes à dessiner (partagé avec les processus enfants)


def _texte_trace(i):
    codee = preparer_trace(ENTITES[i]["geometry"])
    if codee is None:
        return None
    return json.dumps(codee, separators=(",", ":"))


def main():
    global COTE
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    options = [a for a in sys.argv[1:] if a.startswith("--")]
    terres = None
    if "--terres" in sys.argv:  # le chemin suit l'option : on le retire des arguments positionnels
        terres = sys.argv[sys.argv.index("--terres") + 1]
        args = [a for a in args if a != terres]
    if len(args) < 1:
        sys.exit(__doc__)
    source = args[0]
    dossier_sortie = args[1] if len(args) > 1 else os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "..", "..", "public", "data", "historique"
    )
    appliquer_dates = "--sans-dates" not in options
    global COMBLER
    COMBLER = "--sans-comblage" not in options
    # --debut -700 : la carte commence à cette année (décision de Martin, 2026-10-28). Les lignes qui finissent avant sont
    # écartées, celles qui la traversent sont raccourcies. Défaut : tout garder (-3400). Les données complètes sont
    # sauvegardées sur la branche GitHub « sauvegarde-historique-donnees-completes ».
    debut_carte = -3400
    if "--debut" in sys.argv:
        debut_carte = int(sys.argv[sys.argv.index("--debut") + 1])
        args = [a for a in args if a != str(debut_carte)]
    if terres:
        print("Trait de côte réel :", terres)
        COTE = Cote(terres)
    os.makedirs(dossier_sortie, exist_ok=True)

    print("Lecture de", source)
    with open(source, encoding="utf8") as f:
        data = json.load(f)
    entites = [
        ft for ft in data["features"]
        if ft["properties"]["Type"] == "POLITY" and not ft["properties"]["Name"].startswith("(")
    ]
    entites.sort(key=lambda ft: (ft["properties"]["FromYear"], ft["properties"]["ToYear"], ft["properties"]["Name"]))
    print(len(entites), "lignes à dessiner sur", len(data["features"]))
    ENTITES[:] = [ft for ft in entites]

    noms, idx_nom = [], {}

    def nom(n):
        if n not in idx_nom:
            idx_nom[n] = len(noms)
            noms.append(n)
        return idx_nom[n]

    # Corrections de dates (voir corrections_dates.py) : seules les bornes (de, à) changent, jamais les formes.
    dates = [{"nom": ft["properties"]["Name"], "de": ft["properties"]["FromYear"], "a": ft["properties"]["ToYear"],
              "geometrie": ft["geometry"], "ft": ft} for ft in entites]
    if appliquer_dates:
        d = os.path.dirname(os.path.abspath(__file__))
        corrections = lire_manuelles(os.path.join(d, "corrections_dates_manuelles.json")) + \
            lire_wikidata(os.path.join(d, "corrections_dates_wikidata.txt"))
        moteur = Corrections(dates)
        rapport = moteur.appliquer(corrections)
        with open(os.path.join(d, "corrections_dates_rapport.json"), "w", encoding="utf8") as f:
            json.dump(rapport, f, ensure_ascii=False, indent=0)
        nb = {}
        for r in rapport:
            nb[r["statut"]] = nb.get(r["statut"], 0) + 1
        print("Corrections de dates :", nb)

    if appliquer_dates:
        d = os.path.dirname(os.path.abspath(__file__))
        rapport_formes = corrections_formes.appliquer(
            entites, dates, corrections_formes.lire_regles(os.path.join(d, "corrections_formes_manuelles.json")))
        with open(os.path.join(d, "corrections_formes_rapport.json"), "w", encoding="utf8") as f:
            json.dump(rapport_formes, f, ensure_ascii=False, indent=0)
        for r in rapport_formes:
            print("Forme corrigée :", r["id"], "—", len(r["lignes"]), "ligne(s)")
        # les lignes ajoutées par une coupure sont rangées par année de début (ordre attendu pour les morceaux)
        ordre = sorted(range(len(entites)), key=lambda k: (dates[k]["de"], dates[k]["a"], dates[k]["nom"]))
        entites[:] = [entites[k] for k in ordre]
        dates[:] = [dates[k] for k in ordre]
    if debut_carte > -3400:
        gardees = [k for k in range(len(entites)) if dates[k]["a"] >= max(debut_carte, dates[k]["de"])]
        print("Début de la carte :", debut_carte, "—", len(entites) - len(gardees), "ligne(s) écartée(s)")
        for k in gardees:
            dates[k]["de"] = max(dates[k]["de"], debut_carte)
        entites[:] = [entites[k] for k in gardees]
        dates[:] = [dates[k] for k in gardees]
    ENTITES[:] = [ft for ft in entites]

    # Les tracés sont calculés en parallèle (le calage sur la côte est coûteux).
    print("Calcul des tracés…")
    with multiprocessing.get_context("fork").Pool(2) as pool:
        # Reprise après interruption (la machine de travail peut être arrêtée en cours de calcul) : les tracés déjà
        # calculés sont gardés dans un fichier « _reprise.jsonl » du dossier de sortie, un par ligne, dans l'ordre.
        # Le fichier n'est réutilisé que si la signature (nombre de lignes, options, version du code) est identique.
        signature = "%d|%s|%s|%s" % (len(entites), COMBLER, debut_carte, hashlib.md5(
            (open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "caler_cotes.py"), encoding="utf8").read()
             + open(__file__, encoding="utf8").read()).encode()).hexdigest()[:10])
        chemin_reprise = os.path.join(dossier_sortie, "_reprise.jsonl")
        textes = []
        if os.path.exists(chemin_reprise):
            with open(chemin_reprise, encoding="utf8") as f:
                lignes_r = f.read().split("\n")
            if lignes_r and lignes_r[0] == signature:
                textes = [json.loads(x) for x in lignes_r[1:] if x]
                print("  reprise : %d tracés déjà calculés" % len(textes), flush=True)
        if not textes:
            with open(chemin_reprise, "w", encoding="utf8") as f:
                f.write(signature + "\n")
        reste = range(len(textes), len(entites))
        tampon = []
        for k, t in enumerate(pool.imap(_texte_trace, reste, chunksize=40), start=len(textes)):
            textes.append(t)
            tampon.append(json.dumps(t))
            if k % 250 == 249:
                with open(chemin_reprise, "a", encoding="utf8") as f:
                    f.write("\n".join(tampon) + "\n")
                tampon = []
            if k % 1000 == 999:
                print("  tracés calculés :", k + 1, "/", len(entites), flush=True)
    if os.path.exists(chemin_reprise):
        os.remove(chemin_reprise)

    metas, idx_meta = [], {}
    traces, idx_trace = [], {}  # traces[id] = (codage JSON compact)
    lignes = []
    for i, ft in enumerate(entites):
        p = ft["properties"]
        cle_meta = (p["Name"], p["Wikipedia"], p["Wikidata"], p["SeshatID"])
        if cle_meta not in idx_meta:
            idx_meta[cle_meta] = len(metas)
            metas.append([nom(p["Name"]), p["Wikipedia"], p["Wikidata"], p["SeshatID"]])
        texte = textes[i]
        if texte is None:
            sys.exit("Tracé vide pour " + p["Name"] + " " + str(p["FromYear"]))
        h = hashlib.md5(texte.encode()).hexdigest()
        if h not in idx_trace:
            idx_trace[h] = len(traces)
            traces.append(texte)
        ensemble = nom(p["MemberOf"]) if p["MemberOf"] else -1
        d_ligne = dates[i]
        if d_ligne["a"] < d_ligne["de"]:
            continue  # ligne rendue vide par une correction de dates
        lignes.append([idx_meta[cle_meta], d_ligne["de"], d_ligne["a"], idx_trace[h], ensemble, round(p["Area"])])
    print(len(traces), "tracés distincts (au lieu de", len(lignes), "lignes)")

    # Découpage des tracés en morceaux d'environ TAILLE_MORCEAU octets, dans l'ordre de première apparition
    # dans le temps : un visiteur qui parcourt les siècles ne télécharge que les morceaux utiles.
    # (les lignes sont triées par année de début : l'ordre de première apparition = ordre des identifiants,
    #  car idx_trace est attribué au fil de ce parcours)
    morceaux, courant, taille, debut = [], [], 0, 0
    for i, t in enumerate(traces):
        courant.append(t)
        taille += len(t) + 1
        if taille >= TAILLE_MORCEAU:
            morceaux.append((debut, courant))
            debut, courant, taille = i + 1, [], 0
    if courant:
        morceaux.append((debut, courant))
    for old in os.listdir(dossier_sortie):
        if old.startswith("geo_") and old.endswith(".json"):
            os.remove(os.path.join(dossier_sortie, old))
    for m, (premier, liste) in enumerate(morceaux):
        with open(os.path.join(dossier_sortie, "geo_%03d.json" % m), "w", encoding="utf8") as f:
            f.write("[" + ",".join(liste) + "]")

    index = {
        "version": VERSION_SOURCE,
        "noms": noms,
        "meta": metas,
        "lignes": lignes,
        "morceaux": [[premier, len(liste)] for premier, liste in morceaux],
    }
    with open(os.path.join(dossier_sortie, "index.json"), "w", encoding="utf8") as f:
        json.dump(index, f, ensure_ascii=False, separators=(",", ":"))
    total = sum(os.path.getsize(os.path.join(dossier_sortie, n)) for n in os.listdir(dossier_sortie) if n.endswith(".json"))
    print(len(morceaux), "morceaux ; total", round(total / 1e6, 1), "Mo dans", os.path.normpath(dossier_sortie))


if __name__ == "__main__":
    main()
