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

MARGE = 0.001          # degrés (≈ 0,5 km)
SIMPLIF_TERRE = 0.0025  # degrés (≈ 0,4 km) : inférieur à la grille de sortie (0,01°)
PERTE_MAX = 0.6        # au-delà, l'entité est considérée comme maritime
PETITE_PARTIE_KM2 = 3000
MICRO_ETAT_KM2 = 30000  # en dessous, si le calage retirerait plus de 30 %, on garde la forme (îles/micro-États restent visibles)
LAC_MIN_KM2 = 1000     # seuls les lacs plus grands sont traités comme de l'eau (Natural Earth 10 m, domaine public)
MIN_ILE_DEG2 = 0.00003  # on ignore les îlots < ≈ 0,4 km² (invisibles à la grille de 0,5 km, et très coûteux : des dizaines de milliers)
CASE = 5.0            # taille (degrés) des cases de pré-découpage de la terre


class _CoteNiveau:
    """La côte à UN niveau de détail (tolérance de simplification `simplif`)."""
    def __init__(self, polys, simplif):
        self.simplif = simplif
        arbre_p = STRtree(polys)
        self.cases, self.cotes = [], []
        ext = 0.05  # on construit un peu au-delà de la case pour que la côte ne soit pas coupée au bord de la case
        for x in range(-180, 180, int(CASE)):
            for y in range(-90, 90, int(CASE)):
                b = box(x, y, x + CASE, y + CASE)
                bb = box(x - ext, y - ext, x + CASE + ext, y + CASE + ext)
                idx = arbre_p.query(bb)
                if len(idx) == 0:
                    continue
                morceaux = [polys[i] if polys[i].within(bb) else polys[i].intersection(bb) for i in idx]
                terre = shapely.union_all(morceaux)
                terre = shapely.make_valid(terre.simplify(self.simplif, preserve_topology=True).buffer(MARGE))
                morceau = terre.intersection(b)
                if morceau.is_empty:
                    continue
                self.cases.append((b, morceau))
                # lignes de côte seules (sans les bords artificiels de la case), pour combler les écarts (voir « combler »)
                self.cotes.append(terre.boundary.intersection(b))
        self.arbre = STRtree([b for b, _ in self.cases])
        self._bandes = {}   # (case, d) -> terre de la case à moins de d de la côte (calculé à la demande)

    def terre_autour(self, geom):
        idx = self.arbre.query(geom)
        if len(idx) == 0:
            return None
        return shapely.union_all([self.cases[i][1] for i in idx])

    def couper(self, forme):
        """forme ∩ terre, case par case (une union mondiale de la côte à 100 m est beaucoup trop lourde)."""
        morceaux = []
        for i in self.arbre.query(forme, predicate="intersects"):
            b, terre = self.cases[i]
            part = forme.intersection(b)
            if part.is_empty:
                continue
            m = part.intersection(terre)
            if not m.is_empty:
                morceaux.append(m)
        if not morceaux:
            return shapely.Polygon()
        return shapely.union_all(morceaux)

    def combler(self, geom, d):
        """Ajoute à la forme la terre située à moins de d degrés d'elle ET à moins de d degrés de la côte, mais seulement
        les morceaux qui TOUCHENT la forme (on ne saute jamais un détroit : pas de bande sur la rive d'en face).
        Raison (Martin, 2026-10-30) : après simplification, le contour s'arrête parfois à quelques km de la côte et
        laisse un liseré de terre vide ; le long d'une côte, la frontière doit suivre la côte. On n'ajoute rien à l'intérieur
        des terres (hors bande côtière), donc les frontières terrestres ne bougent pas."""
        d = min(q for q in (0.06, 0.1, 0.15) if q >= min(d, 0.15))   # d arrondi au palier supérieur (bandes mises en cache)
        zone = geom.buffer(d, quad_segs=2)
        idx = self.arbre.query(zone, predicate="intersects")
        if len(idx) == 0:
            return geom
        morceaux = []
        for i in idx:
            if (i, d) not in self._bandes:
                lignes = self.cotes[i].simplify(0.003)   # la bande n'a pas besoin du détail fin de la côte
                self._bandes[(i, d)] = self.cases[i][1].intersection(lignes.buffer(d, quad_segs=2)) if not lignes.is_empty else None
            if self._bandes[(i, d)] is not None:
                morceaux.append(self._bandes[(i, d)])
        if not morceaux:
            return geom
        ajout = shapely.union_all([m.intersection(zone) for m in morceaux]).difference(geom)   # terre de la bande côtière proche de la forme
        gardes = [p for p in shapely.get_parts(ajout) if p.geom_type == "Polygon" and not p.is_empty and p.intersects(geom)]
        if not gardes:
            return geom
        return shapely.make_valid(geom.union(shapely.union_all(gardes)))

    def caler(self, geom, tol=None, comble=0.0):
        """Retourne (nouvelle_geometrie, part_retiree). La forme d'origine est rendue si on ne doit pas toucher.
        tol : tolérance (degrés) de re-simplification du résultat, pour limiter le nombre de sommets."""
        if geom.is_empty:
            return geom, 0.0
        if len(self.arbre.query(geom, predicate="intersects")) == 0:
            return geom, 0.0
        a0 = geom.area
        forme = self.combler(geom, comble) if comble > 0 else geom
        coupe = self.couper(forme)
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


SIMPLIFS = (0.0025, 0.006, 0.012)   # niveaux de détail de la côte (°) : un grand empire n'a pas besoin d'une côte à 250 m
                                     # (sa forme est de toute façon re-simplifiée à 0,5 × sa tolérance, jusqu'à 0,015°)


class Cote:
    def __init__(self, chemin_terre, chemin_lacs=None):
        """chemin_terre : GeoJSON de polygones de terre DISJOINTS (ex. GSHHG converti par gshhg_vers_terres.py, lacs déjà retirés)
        ou Natural Earth (alors `chemin_lacs` permet de retirer les grands lacs)."""
        with open(chemin_terre, encoding="utf8") as f:
            data = json.load(f)
        polys = [make_valid(shape(f["geometry"])) for f in data["features"]]
        polys = [p for p in polys if p.area >= MIN_ILE_DEG2]
        if chemin_lacs:
            with open(chemin_lacs, encoding="utf8") as f:
                lacs = [make_valid(shape(x["geometry"])) for x in json.load(f)["features"]]
            lacs = [l for l in lacs if l.area * 12000 >= LAC_MIN_KM2]
            if lacs:
                grand = shapely.union_all(lacs)
                polys = [p.difference(grand) if p.intersects(grand) else p for p in polys]
        self.niveaux = [_CoteNiveau(polys, s) for s in SIMPLIFS]

    def terre_autour(self, geom):
        return self.niveaux[0].terre_autour(geom)

    def caler(self, geom, tol=None, comble=0.0):
        """Choisit le niveau de détail d'après la tolérance de la forme (tol), puis cale (voir _CoteNiveau.caler)."""
        cible = max(SIMPLIFS[0], (tol or 0) / 2)
        niv = [n for n in self.niveaux if n.simplif <= cible][-1]
        return niv.caler(geom, tol=tol, comble=comble)
