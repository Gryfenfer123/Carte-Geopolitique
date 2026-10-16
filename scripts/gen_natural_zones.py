#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Génère des "zones" (polygones GeoJSON approximatifs) pour
public/data/raw/NATURAL_FEATURES.json, pour remplacer les triangles fixes
par de vraies formes délimitées qui changent d'échelle avec le zoom de la
carte (demande de Martin, 2026-10-16 : "Revoir les zones naturelles, je ne
veux pas des triangles partout, mais de belle zone délimité").

IMPORTANT — limite honnête : cet environnement n'a pas accès aux jeux de
données de frontières géographiques réelles (Natural Earth, GADM...), donc
ces polygones ne sont PAS les contours cartographiques exacts des déserts/
massifs/forêts/fosses. Ce sont des ellipses "organiques" (contour légèrement
irrégulier, pas une ellipse parfaite) centrées sur le point existant,
dimensionnées :
  - à partir de la surface réelle connue (déserts/forêts, en km²) quand
    elle est identifiable depuis la note existante ou de connaissance
    générale,
  - ou d'une bande orientée selon le relevé/l'azimut réel approximatif de
    la chaîne/fosse (montagnes/fosses océaniques), de longueur plafonnée
    pour rester lisible (une vraie chaîne de 7000 km tracée en ligne droite
    depuis un seul point traverserait des zones hors de propos),
  - ou d'un petit blob arrondi pour les volcans/massifs isolés (entités
    ponctuelles, pas de "surface" réelle à représenter).
"""
import json
import math
import hashlib

SRC = "public/data/raw/NATURAL_FEATURES.json"

KM_PER_DEG_LAT = 111.0

def km_per_deg_lon(lat):
    return 111.320 * math.cos(math.radians(lat))

# Surface connue (km²) pour les déserts et forêts, approximation de
# connaissance générale cohérente avec les notes existantes.
AREA_KM2 = {
    "Sahara": 9_200_000,
    "Désert de Gobi": 1_300_000,
    "Désert d'Atacama": 105_000,
    "Désert du Kalahari": 900_000,
    "Désert Mojave": 124_000,
    "Désert d'Arabie": 2_330_000,
    "Taklamakan": 270_000,
    "Désert du Namib": 81_000,
    "Désert de Simpson": 170_000,
    "Grand désert de Victoria": 350_000,
    "Désert de Sonora": 310_000,
    "Désert de Patagonie": 670_000,
    "Désert du Thar": 200_000,
    "Désert du Karakoum": 350_000,
    "Désert de Chihuahua": 450_000,
    "Désert du Néguev": 12_000,
    "Désert de Dasht-e Lut": 480_000,
    "Forêt amazonienne": 5_500_000,
    "Forêt du bassin du Congo": 2_000_000,
    "Taïga sibérienne": 12_000_000,
    "Forêt boréale canadienne": 3_000_000,
    "Forêts de Bornéo": 740_000,
    "Forêt tropicale de Daintree": 1_200,
    "Sundarbans": 10_000,
    "Forêt noire (Schwarzwald)": 6_000,
    "Forêt amazonienne péruvienne": 370_000,
    "Forêt de Valdivie": 248_000,
    "Forêt de Białowieża": 1_500,
    "Forêt de Tongass": 68_000,
    "Forêt de Madagascar (Masoala)": 2_100,
}

# Bande orientée (longueur en km, cap à 1500 pour rester lisible, azimut en
# degrés depuis le nord, sens horaire) pour les chaînes de montagnes et les
# fosses océaniques — connaissance générale de leur orientation réelle.
BAND_KM_BEARING = {
    "Himalaya (Everest)": (1500, 110),
    "Alpes (Mont Blanc)": (1200, 75),
    "Andes (Aconcagua)": (1500, 10),
    "Montagnes Rocheuses": (1500, 15),
    "Atlas": (900, 65),
    "Monts Oural": (1200, 5),
    "Caucase (Mont Elbrouz)": (700, 105),
    "Pyrénées": (430, 100),
    "Monts Altaï": (900, 120),
    "Monts Zagros": (1200, 130),
    "Drakensberg": (900, 25),
    "Karakoram (K2)": (500, 110),
    "Appalaches": (1500, 35),
    "Alpes scandinaves": (1200, 15),
    "Tian Shan": (1200, 95),
    "Hindū Kush": (800, 100),
    "Fosse des Mariannes": (1500, 15),
    "Fosse des Tonga": (1200, 5),
    "Fosse des Philippines": (1200, 10),
    "Fosse Kermadec": (1200, 5),
    "Fosse de Porto Rico": (800, 80),
    "Fosse de Java (Sonde)": (1200, 115),
    "Fosse Pérou-Chili (Atacama)": (1500, 10),
    "Fosse des Kouriles-Kamtchatka": (1200, 25),
    "Fosse des Nouvelles-Hébrides": (900, 5),
    "Fosse du Japon": (900, 15),
}

# Massifs/pics isolés traités comme un petit blob rond plutôt qu'une bande
# allongée (pas une vraie "chaîne" continue sur la carte à cette échelle).
ISOLATED_MASSIF = {"Kilimandjaro"}


def seed_from_name(name):
    h = hashlib.sha1(name.encode("utf-8")).hexdigest()
    return int(h[:8], 16)


def ellipse_params(feature):
    name = feature["name"]
    ftype = feature["type"]
    if name in BAND_KM_BEARING and name not in ISOLATED_MASSIF:
        length_km, bearing = BAND_KM_BEARING[name]
        a_km = length_km / 2
        b_km = a_km / 7.0  # bande étroite (chaîne/fosse)
        return a_km, b_km, bearing
    if name in AREA_KM2:
        area = AREA_KM2[name]
        aspect = 1.6 if ftype == "desert" else 1.35
        # aire ellipse = pi*a*b, a = aspect*b => b = sqrt(area/(pi*aspect))
        b_km = math.sqrt(area / (math.pi * aspect))
        a_km = aspect * b_km
        bearing = (seed_from_name(name) % 180)  # orientation générique stable
        return a_km, b_km, bearing
    if ftype == "volcan" or name in ISOLATED_MASSIF:
        r_km = 45 if name in ISOLATED_MASSIF else 24
        return r_km, r_km * 0.92, (seed_from_name(name) % 180)
    if ftype == "fosse":
        a_km, b_km = 450, 65
        return a_km, b_km, (seed_from_name(name) % 180)
    if ftype == "montagne":
        a_km, b_km = 450, 65
        return a_km, b_km, (seed_from_name(name) % 180)
    # repli générique (desert/foret sans surface connue)
    a_km, b_km = 300, 220
    return a_km, b_km, (seed_from_name(name) % 180)


def build_polygon(feature, n=40):
    lon0, lat0, name = feature["lon"], feature["lat"], feature["name"]
    a_km, b_km, bearing_deg = ellipse_params(feature)
    bearing = math.radians(bearing_deg)
    seed = seed_from_name(name)
    phase1 = (seed % 360) * math.pi / 180.0
    phase2 = ((seed >> 8) % 360) * math.pi / 180.0
    dlat_per_km = 1.0 / KM_PER_DEG_LAT
    dlon_per_km = 1.0 / km_per_deg_lon(lat0)
    pts = []
    for i in range(n):
        phi = (2 * math.pi * i) / n
        # contour "organique" : ellipse de base + 2 harmoniques basse
        # fréquence (irrégularité douce, pas un simple cercle/ellipse nu)
        wobble = 1 + 0.14 * math.sin(2 * phi + phase1) + 0.07 * math.sin(3 * phi + phase2)
        px = a_km * math.cos(phi) * wobble
        py = b_km * math.sin(phi) * wobble
        north_km = px * math.cos(bearing) - py * math.sin(bearing)
        east_km = px * math.sin(bearing) + py * math.cos(bearing)
        lat = lat0 + north_km * dlat_per_km
        lon = lon0 + east_km * dlon_per_km
        pts.append([round(lon, 4), round(lat, 4)])
    pts.append(pts[0])
    return {"type": "Polygon", "coordinates": [pts]}


def main():
    with open(SRC, encoding="utf-8") as f:
        data = json.load(f)
    for feature in data:
        feature["geometry"] = build_polygon(feature)
    with open(SRC, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print("OK —", len(data), "zones générées dans", SRC)


if __name__ == "__main__":
    main()
