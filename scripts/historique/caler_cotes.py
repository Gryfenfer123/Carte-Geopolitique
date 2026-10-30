"""Caler les formes de la carte historique sur la côte réelle (chantier historique, 2026-10-24).

POURQUOI (Martin) : en zoomant, les contours de Cliopatria débordent en mer ou s'écartent de la côte. On ne
peut pas inventer ce qui manque (zone où le contour reste en deçà de la côte : aucune source), mais on peut
retirer ce qui est en mer : une frontière terrestre ne passe pas en pleine mer.

SOURCE DU TRAIT DE CÔTE : Natural Earth « land » 1:10 m (domaine public), fichier GeoJSON du dépôt
nvkelso/natural-earth-vector (état du 2026-10-24, commit ca96624a) :
    curl -L -o terres_10m.geojson https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_10m_land.geojson
(Le fichier du paquet npm « world-atlas » NE CONVIENT PAS : son tracé de l'Eurasie est invalide à cause de
l'antiméridien et coupait tout le nord de la Scandinavie et de la Russie.) Les lacs comptent comme de la terre
(les frontières traversent les lacs) ; seules les mers (et la mer Caspienne) sont retirées.

RÈGLES (on ne fait que RETIRER de la surface, jamais en ajouter) :
  - forme ∩ terre (la terre est élargie de MARGE degrés pour ne pas créer de filets le long de la côte) ;
  - une PARTIE de la forme (île, enclave) entièrement en mer et de petite taille est GARDÉE telle quelle
    (probable île absente des données de côte) ;
  - un micro-État / archipel (< MICRO_ETAT_KM2) dont plus de 30 % partirait en mer est gardé tel quel (sinon il
    deviendrait invisible : les contours de Cliopatria y sont des taches autour des îles) ;
  - si le résultat perd plus de PERTE_MAX de la surface, l'entité est jugée « maritime » (thalassocratie, etc.)
    et la forme d'origine est gardée.
Limite connue : le trait de côte est celui d'AUJOURD'HUI (mer d'Aral, delta du Nil, polders néerlandais,
lac Tchad ont changé). Seuls les endroits où la côte actuelle est plus « mer » qu'autrefois sont touchés.
"""
import json

import shapely
from shapely import STRtree, make_valid
from shapely.geometry import box, shape

MARGE = 0.005          # degrés (≈ 0,5 km)
SIMPLIF_TERRE = 0.004  # degrés (≈ 0,4 km) : inférieur à la grille de sortie (0,01°)
PERTE_MAX = 0.6        # au-delà, l'entité est considérée comme maritime
PETITE_PARTIE_KM2 = 3000
MICRO_ETAT_KM2 = 30000  # en dessous, si le calage retirerait plus de 30 %, on garde la forme (îles/micro-États restent visibles)
CASE = 10.0            # taille (degrés) des cases de pré-découpage de la terre


class Cote:
    def __init__(self, chemin_terre):
        with open(chemin_terre, encoding="utf8") as f:
            data = json.load(f)
        terre = shapely.union_all([make_valid(shape(f["geometry"])) for f in data["features"]])
        terre = shapely.union_all([p for p in shapely.get_parts(terre) if p.geom_type == "Polygon"])
        terre = shapely.make_valid(terre.simplify(SIMPLIF_TERRE, preserve_topology=True).buffer(MARGE))
        # pré-découpage en cases pour que chaque forme ne soit comparée qu'à la terre voisine
        self.cases = []
        for x in range(-180, 180, int(CASE)):
            for y in range(-90, 90, int(CASE)):
                b = box(x, y, x + CASE, y + CASE)
                morceau = terre.intersection(b)
                if not morceau.is_empty:
                    self.cases.append((b, morceau))
        self.arbre = STRtree([b for b, _ in self.cases])
        # lignes de côte seules (sans les bords artificiels des cases), pour combler les écarts (voir « combler »)
        cote = terre.boundary
        self.cotes = [cote.intersection(b) for b, _ in self.cases]

    def terre_autour(self, geom):
        idx = self.arbre.query(geom)
        if len(idx) == 0:
            return None
        return shapely.union_all([self.cases[i][1] for i in idx])

    def combler(self, geom, d):
        """Ajoute à la forme la terre située à moins de d degrés d'elle ET à moins de d degrés de la côte, mais seulement
        les morceaux qui TOUCHENT la forme (on ne saute jamais un détroit : pas de bande sur la rive d'en face).
        Raison (Martin, 2026-10-30) : après simplification, le contour s'arrête parfois à quelques km de la côte et
        laisse un liseré de terre vide ; le long d'une côte, la frontière doit suivre la côte. On n'ajoute rien à l'intérieur
        des terres (hors bande côtière), donc les frontières terrestres ne bougent pas."""
        zone = geom.buffer(d)
        idx = self.arbre.query(zone)
        if len(idx) == 0:
            return geom
        terre = shapely.union_all([self.cases[i][1] for i in idx])
        lignes = shapely.union_all([self.cotes[i] for i in idx])
        if lignes.is_empty:
            return geom
        ajout = terre.intersection(zone).intersection(lignes.buffer(d)).difference(geom)
        gardes = [p for p in shapely.get_parts(ajout) if p.geom_type == "Polygon" and not p.is_empty and p.intersects(geom)]
        if not gardes:
            return geom
        return shapely.make_valid(geom.union(shapely.union_all(gardes)))

    def caler(self, geom, tol=None, comble=0.0):
        """Retourne (nouvelle_geometrie, part_retiree). La forme d'origine est rendue si on ne doit pas toucher.
        tol : tolérance (degrés) de re-simplification du résultat, pour limiter le nombre de sommets."""
        if geom.is_empty:
            return geom, 0.0
        terre = self.terre_autour(geom)
        if terre is None:
            return geom, 0.0
        a0 = geom.area
        forme = self.combler(geom, comble) if comble > 0 else geom
        coupe = forme.intersection(terre)
        if coupe.is_empty or coupe.area < (1 - PERTE_MAX) * a0:
            return geom, 0.0
        import math
        km2 = a0 * 111.32 ** 2 * math.cos(math.radians(geom.centroid.y))
        if km2 < MICRO_ETAT_KM2 and coupe.area < 0.7 * a0:
            return geom, 0.0
        # petites parties d'origine entièrement en mer : on les garde
        gardees = []
        for partie in shapely.get_parts(geom):
            if partie.geom_type != "Polygon" or partie.is_empty:
                continue
            if partie.area * 12000 < PETITE_PARTIE_KM2 and not partie.intersects(coupe):  # ≈ 12 000 km² par degré² à moyenne latitude
                gardees.append(partie)
        resultat = shapely.union_all([coupe] + gardees) if gardees else coupe
        resultat = shapely.make_valid(resultat)
        parties = [p for p in shapely.get_parts(resultat) if p.geom_type == "Polygon" and not p.is_empty]
        resultat = shapely.union_all(parties)
        if tol:
            simple = resultat.simplify(tol, preserve_topology=True)
            if not simple.is_empty:
                resultat = simple
        return resultat, 1 - resultat.area / a0
