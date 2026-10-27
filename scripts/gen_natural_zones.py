#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Génère public/data/raw/NATURAL_FEATURES.json à partir de VRAIS contours.

Refonte du 2026-10-28 (demande de Martin : les anciennes « zones » étaient des
ellipses approximatives mal placées). Règle du projet : rien n'est pris s'il
n'est pas sourcé. Ce script ne garde donc QUE ce qui a une source :

  - déserts et chaînes de montagnes : polygones Natural Earth 1:10m
    « geography_regions_polys » (domaine public) ;
  - sommets de volcans/montagnes : points Natural Earth 1:10m
    « geography_regions_elevation_points » (altitude fournie par la source).

Source : https://github.com/nvkelso/natural-earth-vector (version figée v5.1.2).
Licence : domaine public (https://www.naturalearthdata.com/about/terms-of-use/).

Ce qui n'est PAS ici (pas de source exploitable à ce jour) : forêts, fosses
océaniques, volcans absents de Natural Earth (Stromboli, Kilauea, Cotopaxi,
Nyiragongo, Mont St Helens, Eyjafjallajökull, Ol Doinyo Lengai, caldeira de
Yellowstone), Désert d'Arabie, Désert de Mojave, Désert de Patagonie.
Voir docs/chantiers/carte.md.

Usage :  python3 scripts/gen_natural_zones.py [dossier_cache]
Le dossier de cache (défaut : /tmp/natural_earth_cache) reçoit les fichiers
téléchargés ; l'accès réseau n'est nécessaire que s'ils n'y sont pas déjà.
"""
import json
import math
import os
import sys
import urllib.request

NE_TAG = "v5.1.2"
NE_BASE = f"https://raw.githubusercontent.com/nvkelso/natural-earth-vector/{NE_TAG}/geojson/"
POLYS = "ne_10m_geography_regions_polys.geojson"
POINTS = "ne_10m_geography_regions_elevation_points.geojson"
OUT = "public/data/raw/NATURAL_FEATURES.json"
COORD_DECIMALS = 3  # ~110 m : largement sous la précision de la source à l'échelle de la carte

# nom affiché  ->  (type, NAME exact dans Natural Earth, classe attendue)
POLY_MAP = [
    ("Sahara", "desert", "SAHARA", "Desert"),
    ("Désert de Gobi", "desert", "GOBI DESERT", "Desert"),
    ("Désert d'Atacama", "desert", "DESIERTO DE ATACAMA", "Desert"),
    ("Désert du Kalahari", "desert", "KALAHARI DESERT", "Desert"),
    ("Taklamakan", "desert", "TAKLIMAKAN DESERT", "Desert"),
    ("Désert du Namib", "desert", "NAMIB DESERT", "Desert"),
    ("Désert de Simpson", "desert", "Simpson Desert", "Desert"),
    ("Grand désert de Victoria", "desert", "GREAT VICTORIA DESERT", "Desert"),
    ("Désert de Sonora", "desert", "SONORAN DESERT", "Desert"),
    ("Désert du Thar", "desert", "THAR DESERT", "Desert"),
    ("Désert du Karakoum", "desert", "GARAGUM DESERT", "Desert"),
    ("Désert de Chihuahua", "desert", "CHIHUAHUAN DESERT", "Desert"),
    ("Désert du Néguev", "desert", "Negev Desert", "Desert"),
    ("Désert de Dasht-e Lut", "desert", "LUT DESERT", "Desert"),
    ("Himalaya (Everest)", "montagne", "HIMALAYAS", "Range/mtn"),
    ("Alpes (Mont Blanc)", "montagne", "ALPS", "Range/mtn"),
    ("Andes (Aconcagua)", "montagne", "ANDES", "Range/mtn"),
    ("Montagnes Rocheuses", "montagne", "ROCKY MOUNTAINS", "Range/mtn"),
    ("Atlas", "montagne", "ATLAS MOUNTAINS", "Range/mtn"),
    ("Monts Oural", "montagne", "URAL MOUNTAINS", "Range/mtn"),
    ("Caucase (Mont Elbrouz)", "montagne", "CAUCASUS MTS.", "Range/mtn"),
    ("Pyrénées", "montagne", "PYRENEES", "Range/mtn"),
    ("Monts Altaï", "montagne", "ALTAY MOUNTAINS", "Range/mtn"),
    ("Monts Zagros", "montagne", "ZAGROS MOUNTAINS", "Range/mtn"),
    ("Drakensberg", "montagne", "DRAKENSBERG", "Range/mtn"),
    ("Karakoram (K2)", "montagne", "KARAKORAM RA.", "Range/mtn"),
    ("Appalaches", "montagne", "APPALACHIAN MTS.", "Range/mtn"),
    ("Alpes scandinaves", "montagne", "KJØLEN MOUNTAINS", "Range/mtn"),
    ("Tian Shan", "montagne", "TIAN SHAN", "Range/mtn"),
    ("Hindū Kush", "montagne", "HINDU KUSH", "Range/mtn"),
]

# nom affiché -> (type, name exact dans la couche de points Natural Earth)
POINT_MAP = [
    ("Kilimandjaro", "montagne", "Mount Kilimanjaro"),
    ("Etna", "volcan", "Monte Etna"),
    ("Vésuve", "volcan", "Vesuvio"),
    ("Mont Fuji", "volcan", "Fuji"),
    ("Krakatoa", "volcan", "Krakatau"),
    ("Popocatépetl", "volcan", "Volcán Popocatépetl"),
    ("Merapi", "volcan", "Gunung Merapi"),
    ("Pinatubo", "volcan", "Mount Pinatubo"),
    ("Mont Erebus", "volcan", "Mount Erebus"),
]


def load(cache, name):
    os.makedirs(cache, exist_ok=True)
    path = os.path.join(cache, NE_TAG + "_" + name)
    if not os.path.exists(path):
        with urllib.request.urlopen(NE_BASE + name, timeout=120) as r, open(path, "wb") as f:
            f.write(r.read())
    with open(path, encoding="utf-8") as f:
        return json.load(f)["features"]


def rnd(c):
    return [round(c[0], COORD_DECIMALS), round(c[1], COORD_DECIMALS)]


def clean_ring(ring):
    out = []
    for c in ring:
        p = rnd(c)
        if not out or p != out[-1]:
            out.append(p)
    return out if len(out) >= 4 else None


def clean_geometry(g):
    if g["type"] == "Polygon":
        polys = [g["coordinates"]]
    elif g["type"] == "MultiPolygon":
        polys = g["coordinates"]
    else:
        raise ValueError("géométrie inattendue : " + g["type"])
    res = []
    for poly in polys:
        rings = [clean_ring(r) for r in poly]
        if rings[0] is None:
            continue  # morceau devenu dégénéré à cette précision
        res.append([r for r in rings if r is not None])
    if not res:
        raise ValueError("géométrie vide après arrondi")
    if len(res) == 1:
        return {"type": "Polygon", "coordinates": res[0]}
    return {"type": "MultiPolygon", "coordinates": res}


def ring_area_centroid(ring):
    a = cx = cy = 0.0
    for (x0, y0), (x1, y1) in zip(ring, ring[1:]):
        cr = x0 * y1 - x1 * y0
        a += cr
        cx += (x0 + x1) * cr
        cy += (y0 + y1) * cr
    if abs(a) < 1e-12:
        return 0.0, ring[0][0], ring[0][1]
    return a / 2, cx / (3 * a), cy / (3 * a)


def anchor(g):
    """Point de repère (lon, lat) = centroïde du plus grand morceau."""
    polys = [g["coordinates"]] if g["type"] == "Polygon" else g["coordinates"]
    best = max((ring_area_centroid(p[0]) for p in polys), key=lambda t: abs(t[0]))
    return round(best[1], 3), round(best[2], 3)


def main():
    cache = sys.argv[1] if len(sys.argv) > 1 else "/tmp/natural_earth_cache"
    polys = load(cache, POLYS)
    points = load(cache, POINTS)

    by_name = {}
    for ft in polys:
        by_name.setdefault(ft["properties"]["NAME"], []).append(ft)
    pts_by_name = {}
    for ft in points:
        pts_by_name.setdefault(ft["properties"]["name"], []).append(ft)

    out = []
    for fr, typ, ne_name, cls in POLY_MAP:
        found = by_name.get(ne_name, [])
        assert len(found) == 1, f"{ne_name}: {len(found)} correspondance(s) (attendu 1)"
        p = found[0]["properties"]
        assert p["FEATURECLA"] == cls, f"{ne_name}: classe {p['FEATURECLA']} != {cls}"
        geom = clean_geometry(found[0]["geometry"])
        lon, lat = anchor(geom)
        out.append({
            "name": fr, "type": typ, "lon": lon, "lat": lat,
            "note": "Contour : Natural Earth (domaine public).",
            "geometry": geom,
            "source": f"Natural Earth {NE_TAG}, ne_10m_geography_regions_polys, NAME={ne_name}, Wikidata {p.get('WIKIDATAID')}",
        })
    for fr, typ, ne_name in POINT_MAP:
        found = pts_by_name.get(ne_name, [])
        assert len(found) == 1, f"{ne_name}: {len(found)} point(s) (attendu 1)"
        p = found[0]["properties"]
        lon, lat = found[0]["geometry"]["coordinates"][:2]
        alt = p.get("elevation")
        note = "Position du sommet : Natural Earth (domaine public)."
        if alt:
            note = f"Altitude du sommet : {int(alt)} m (Natural Earth, domaine public)."
        out.append({
            "name": fr, "type": typ, "lon": round(lon, 4), "lat": round(lat, 4),
            "note": note,
            "source": f"Natural Earth {NE_TAG}, ne_10m_geography_regions_elevation_points, name={ne_name}",
        })

    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")
    n_poly = sum(1 for e in out if "geometry" in e)
    print(f"{len(out)} entrées écrites dans {OUT} ({n_poly} contours, {len(out) - n_poly} points).")


if __name__ == "__main__":
    main()
