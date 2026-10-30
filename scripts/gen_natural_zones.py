#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Génère public/data/raw/NATURAL_FEATURES.json à partir de VRAIES données sourcées.

Refonte du 2026-10-28 (les anciennes « zones » étaient des ellipses mal placées),
étendue le 2026-10-30 à plus de couverture mondiale. Règle du projet : rien n'est
pris s'il n'est pas sourcé. Ce script ne garde donc QUE ce qui a une source :

  - déserts, montagnes, plateaux, plaines, bassins, zones humides, toundra,
    vallées : polygones Natural Earth 1:10m « geography_regions_polys »
    (domaine public) ;
  - sommet du Kilimandjaro : point Natural Earth « geography_regions_elevation_points » ;
  - volcans : base Global Volcanism Program (Smithsonian Institution), copie du
    jeu « volcano.csv / eruptions.csv » du dépôt public rfordatascience/tidytuesday
    (semaine 2020-05-12). Fichiers vérifiés par empreinte SHA-256 (ci-dessous).

Natural Earth : https://github.com/nvkelso/natural-earth-vector (version figée v5.1.2),
domaine public (https://www.naturalearthdata.com/about/terms-of-use/).

Sélection des volcans : tous ceux du GVP ayant connu au moins une éruption d'indice
d'explosivité VEI >= 5, plus la liste d'origine du projet (Etna, Vésuve, Fuji, Krakatoa,
Popocatépetl, Merapi, Pinatubo, Erebus, Stromboli, Kilauea, Cotopaxi, Nyiragongo,
St Helens, Eyjafjallajökull, Ol Doinyo Lengai, Yellowstone).

NON couvert (pas de source exploitable à ce jour) : forêts, fosses océaniques,
Antarctique (la projection de la carte ne l'affiche pas correctement), îles et
archipels (déjà couverts par les pays). Voir docs/chantiers/carte.md.

Usage :  python3 scripts/gen_natural_zones.py [dossier_cache]
Le dossier de cache (défaut : /tmp/natural_earth_cache) reçoit les fichiers
téléchargés ; l'accès réseau n'est nécessaire que s'ils n'y sont pas déjà.
"""
import csv
import hashlib
import json
import os
import sys
import urllib.request

NE_TAG = "v5.1.2"
NE_BASE = f"https://raw.githubusercontent.com/nvkelso/natural-earth-vector/{NE_TAG}/geojson/"
POLYS = "ne_10m_geography_regions_polys.geojson"
POINTS = "ne_10m_geography_regions_elevation_points.geojson"

GVP_BASE = "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-05-12/"
GVP_FILES = {
    "volcano.csv": "3ab7c7b02f813d68512a360d1f2da23098409b564a70f0e84610db8fdad9f8f8",
    "eruptions.csv": "460d4f5afcd23465ff30a50973d04ffb63cc4cabb845cdf40db44bf27005db1f",
}
GVP_MIN_VEI = 5

OUT = "public/data/raw/NATURAL_FEATURES.json"
COORD_DECIMALS = 3  # ~110 m : largement sous la précision de la source à l'échelle de la carte

# (nom affiché, type, NAME exact dans Natural Earth, classe(s) attendue(s)[, plusieurs morceaux])
D, M, P, PL, B, W, T, V = "desert", "montagne", "plateau", "plaine", "bassin", "zone_humide", "toundra", "vallee"
DES, RNG, PLT, PLN, LOW, BAS, DEP, WET, DEL, TUN, VAL, GOR = (
    "Desert", "Range/mtn", "Plateau", "Plain", "Lowland", "Basin", "Depression",
    "Wetlands", "Delta", "Tundra", "Valley", "Gorge",
)
POLY_MAP = [
    # --- Déserts (ensemble de la première version + extension) ---
    ("Sahara", D, "SAHARA", DES),
    ("Désert de Gobi", D, "GOBI DESERT", DES),
    ("Désert d'Atacama", D, "DESIERTO DE ATACAMA", DES),
    ("Désert du Kalahari", D, "KALAHARI DESERT", DES),
    ("Taklamakan", D, "TAKLIMAKAN DESERT", DES),
    ("Désert du Namib", D, "NAMIB DESERT", DES),
    ("Désert de Simpson", D, "Simpson Desert", DES),
    ("Grand désert de Victoria", D, "GREAT VICTORIA DESERT", DES),
    ("Désert de Sonora", D, "SONORAN DESERT", DES),
    ("Désert du Thar", D, "THAR DESERT", DES),
    ("Désert du Karakoum", D, "GARAGUM DESERT", DES),
    ("Désert de Chihuahua", D, "CHIHUAHUAN DESERT", DES),
    ("Désert du Néguev", D, "Negev Desert", DES),
    ("Désert de Dasht-e Lut", D, "LUT DESERT", DES),
    ("Désert libyque", D, "LIBYAN DESERT", DES),
    ("Désert du Kyzylkoum", D, "QIZILQUM DESERT", DES),
    ("Rub al-Khali", D, "RUB’ AL KHALI", DES),
    ("Ténéré", D, "Ténéré", DES),
    ("Désert occidental (Égypte)", D, "WESTERN DESERT", DES),
    ("El Djouf", D, "El Djouf", DES),
    ("Grand désert de sable", D, "GREAT SANDY DESERT", DES),
    ("Désert de Nubie", D, "NUBIAN DESERT", DES),
    ("Désert Arabique (désert oriental)", D, "Eastern Desert", DES),
    ("Désert de Syrie", D, "SYRIAN DESERT", DES),
    ("Désert d'Ordos (Mu Us)", D, "Mu Us Desert", DES),
    ("Hamada du Drâa", D, "Hamada du Drâa", DES),
    ("Steppe de la Faim (Betpak-Dala)", D, "BETPAQDALA DESERT", DES),
    ("Erg Chech", D, "‘Erg Chech", DES),
    ("Grand Erg oriental", D, "Grand Erg Oriental", DES),
    ("Grand Erg occidental", D, "Grand Erg Occidental", DES),
    ("Hamada de Tinrhert", D, "Hamada de Tinrhert", DES),
    ("Désert de Chalbi", D, "Chalbi Desert", DES),
    ("Désert du Danakil", D, "Danakil", DES),
    ("Désert de Gibson", D, "Gibson Desert", DES),
    ("Mourzouq", D, "Idhän Murzuq", DES),
    ("Désert Strzelecki", D, "Strzelecki Desert", DES),
    ("Désert du Néfoud", D, "An Nafud Desert", DES),
    ("Désert de Margo", D, "Margo Desert", DES),
    ("Désert de Tanami", D, "Tanami Desert", DES),
    ("Dasht-e Kavir", D, "Kavir Desert", DES),
    ("Désert du Registan", D, "Rigestan", DES),
    ("Erg Iguidi", D, "‘Erg Iguidi", DES),
    # --- Montagnes (ensemble de la première version) ---
    ("Himalaya (Everest)", M, "HIMALAYAS", RNG),
    ("Alpes (Mont Blanc)", M, "ALPS", RNG),
    ("Andes (Aconcagua)", M, "ANDES", RNG),
    ("Montagnes Rocheuses", M, "ROCKY MOUNTAINS", RNG),
    ("Atlas", M, "ATLAS MOUNTAINS", RNG),
    ("Monts Oural", M, "URAL MOUNTAINS", RNG),
    ("Caucase (Mont Elbrouz)", M, "CAUCASUS MTS.", RNG),
    ("Pyrénées", M, "PYRENEES", RNG),
    ("Monts Altaï", M, "ALTAY MOUNTAINS", RNG),
    ("Monts Zagros", M, "ZAGROS MOUNTAINS", RNG),
    ("Drakensberg", M, "DRAKENSBERG", RNG),
    ("Karakoram (K2)", M, "KARAKORAM RA.", RNG),
    ("Appalaches", M, "APPALACHIAN MTS.", RNG),
    ("Alpes scandinaves", M, "KJØLEN MOUNTAINS", RNG),
    ("Tian Shan", M, "TIAN SHAN", RNG),
    ("Hindū Kush", M, "HINDU KUSH", RNG),
    # --- Montagnes (extension) ---
    ("Chaîne Brooks", M, "BROOKS RANGE", RNG),
    ("Cordillère australienne (Great Dividing Range)", M, "GREAT DIVIDING RANGE", RNG),
    ("Monts Mackenzie", M, "MACKENZIE MTS.", RNG),
    ("Hauts plateaux d'Éthiopie", M, "ETHIOPIAN HIGHLANDS", RNG),
    ("Monts Iablonovy", M, "YABLONOVYY RANGE", RNG),
    ("Grand Khingan", M, "GREATER KHINGAN RANGE", RNG),
    ("Monts de Verkhoïansk", M, "VERKHOYANSK RANGE", RNG),
    ("Monts Stanovoï", M, "STANOVOY RANGE", RNG),
    ("Kunlun", M, "KUNLUN MOUNTAINS", RNG),
    ("Chaîne Côtière (Colombie-Britannique)", M, "COAST MOUNTAINS", RNG),
    ("Sierra Madre occidentale", M, "SIERRA MADRE OCCIDENTAL", RNG),
    ("Carpates", M, "CARPATHIAN MOUNTAINS", RNG),
    ("Saïan oriental", M, "EASTERN SAYAN MTS.", RNG),
    ("Saïan occidental", M, "Western Sayan Mts.", RNG),
    ("Chaîne annamitique", M, "CHAÎNE ANNAMITIQUE", RNG),
    ("Sierra Madre del Sur", M, "Sierra Madre del Sur", RNG),
    ("Sikhote-Aline", M, "SIKHOTE-ALIN’ RANGE", RNG),
    ("Monts Qilian", M, "QUILIAN MOUNTAINS", RNG),
    ("Chaîne d'Alaska", M, "ALASKA RANGE", RNG),
    ("Sierra Madre orientale", M, "SIERRA MADRE ORIENTAL", RNG),
    ("Hautes terres de Nouvelle-Guinée", M, "NEW GUINEA HIGHLANDS", RNG),
    ("Chaînes côtières du Pacifique", M, "COAST RANGES", RNG),
    ("Chaîne des Cascades", M, "CASCADE RANGE", RNG),
    ("Ahaggar", M, "AHAGGAR MTS.", RNG),
    ("Ghâts orientaux", M, "EASTERN GHATS", RNG),
    ("Ghâts occidentaux", M, "WESTERN GHATS", RNG),
    ("Monts Khentii", M, "Hentiyn Mts.", RNG),
    ("Monts Khangaï", M, "Hangayn Mts.", RNG),
    ("Petit Khingan", M, "Lesser Khingan Range", RNG),
    ("Alpes dinariques", M, "Dinaric Alps", RNG),
    ("Monts de Cristal", M, "CRYSTAL MOUNTAINS", RNG),
    ("Monts Koryak", M, "Koryak Range", RNG),
    ("Monts Tcherski", M, "CHERSKIY RANGE", RNG),
    ("Monts Qinling", M, "Qinling Mountains", RNG),
    ("Tibesti", M, "TIBESTI MTS.", RNG),
    ("Pamir", M, "PAMIRS", RNG),
    ("Monts de la Kolyma", M, "KOLYMA RANGE", RNG),
    ("Monts du Hedjaz", M, "HEJAZ MTS.", RNG),
    ("Monts Asir", M, "ASIR MTS.", RNG),
    ("Monts Taihang", M, "Taihang Mts.", RNG),
    ("Monts Nanling", M, "Nan Ling Mts.", RNG),
    ("Monts Wuyi", M, "Wuyi Mts.", RNG),
    ("Altyn-Tagh", M, "ALTUN MTS.", RNG),
    ("Tarbagataï", M, "Tarbagatay Ra.", RNG),
    ("Sierra Nevada (États-Unis)", M, "SIERRA NEVADA", RNG),
    ("Siwaliks", M, "Siwalik Hills", RNG),
    ("Monts Vindhya", M, "Vindhya Range", RNG),
    ("Monts Satpura", M, "Satpura Range", RNG),
    ("Elbourz", M, "ELBURZ MTS.", RNG),
    ("Chaîne pontique", M, "PONTIC MOUNTAINS", RNG),
    ("Apennins", M, "APPENNINI", RNG),
    ("Kopet-Dag", M, "Kopet Dag Mts .", RNG),
    ("Monts Taurus", M, "Taurus Mts.", RNG),
    ("Grand Balkan (Stara Planina)", M, "Balkan Mts.", RNG),
    ("Tatras", M, "Tatra Mts.", RNG),
    ("Monts Hajar", M, "Al Hajar Mts.", RNG),
    ("Rif", M, "Er Rif", RNG),
    ("Cordillère Cantabrique", M, "Cord. Cantábrica", RNG),
    ("Pinde", M, "Pindus Mts.", RNG),
    ("Sierra Morena", M, "Sierra Morena", RNG),
    ("Alpes du Sud (Nouvelle-Zélande)", M, "SOUTHERN ALPS", RNG),
    ("Bukit Barisan", M, "Barisan Mountains", RNG),
    ("Blue Ridge", M, "Blue Ridge", RNG),
    ("Adirondacks", M, "Adirondack Mts.", RNG),
    ("Monts Ouachita", M, "Ouachita Mts.", RNG),
    # --- Plateaux ---
    ("Plateau de Sibérie centrale", P, "CENTRAL SIBERIAN PLATEAU", PLT),
    ("Plateau brésilien", P, "BRAZILIAN HIGHLANDS", PLT),
    ("Plateau tibétain", P, "PLATEAU OF TIBET", PLT),
    ("Plateau du Mato Grosso", P, "PLANALTO DO MATO GROSSO", PLT),
    ("Plateau occidental australien", P, "WESTERN PLATEAU", PLT),
    ("Plateau des Guyanes", P, "GUIANA SHIELD", PLT),
    ("Plateau de Mongolie", P, "MONGOLIAN PLATEAU", PLT),
    ("Plateau du Katanga", P, "KATANGA PLATEAU", PLT),
    ("Plateau mexicain", P, "ALTI-PLANICIE MEXICANA", PLT),
    ("Plateau du Yunnan-Guizhou", P, "YUNGUI PLATEAU", PLT),
    ("Deccan", P, "DECCAN PLATEAU", PLT),
    ("Plateau du Colorado", P, "COLORADO PLATEAU", PLT),
    ("Altiplano", P, "ALTIPLANO", PLT),
    ("Plateau du Columbia", P, "COLUMBIA PLAT.", PLT),
    ("Plateau central de Russie", P, "CENTRAL RUSSIAN UPLAND", PLT),
    ("Plateau de lœss", P, "Loess Plateau", PLT),
    ("Plateau de l'Adamaoua", P, "Adamawa Plateau", PLT),
    ("Plateau de Bié", P, "Bié Plateau", PLT),
    ("Plateau de Poutorana", P, "PUTORANA PLATEAU", PLT),
    ("Monts Ozarks", P, "Ozark Plateau", PLT),
    ("Plateau de Khorat", P, "Khorat Plat.", PLT),
    ("Fouta-Djalon", P, "Fouta Djallon", PLT),
    ("Plateau d'Oust-Ourt", P, "Ustyurt Plateau", PLT),
    ("Plateau d'Edwards", P, "Edwards Plateau", PLT),
    ("Plateau des Allegheny", P, "ALLEGHENY PLATEAU", PLT),
    ("Plateau de Cumberland", P, "CUMBERLAND PLAT.", PLT),
    ("Massif central", P, "Massif Central", PLT),
    ("Gilf al-Kabir", P, "Jilf al Kabir Plateau", PLT),
    ("Plateau Shan", P, "SHAN PLATEAU", PLT),
    ("Chota Nâgpur", P, "Chota Nägpur Plateau", PLT),
    ("Kimberley", P, "KIMBERLEY PLATEAU", PLT),
    # --- Plaines, steppes, basses terres ---
    ("Sahel", PL, "SAHEL", PLN),
    ("Plaine d'Europe du Nord", PL, "NORTHERN EUROPEAN PLAIN", PLN),
    ("Grandes Plaines", PL, "GREAT PLAINS", PLN),
    ("Steppe kazakhe", PL, "KAZAKH STEPPE", PLN),
    ("Steppe pontique", PL, "PONTIC STEPPE", PLN),
    ("Dépression de Touran", PL, "TURAN LOWLAND", PLN),
    ("Pampa", PL, "PAMPAS", PLN),
    ("Gran Chaco", PL, "GRAN CHACO", PLN),
    ("Plaine côtière atlantique (États-Unis)", PL, "COASTAL PLAIN", PLN),
    ("Grande plaine du Nord de la Chine", PL, "NORTH CHINA PLAIN", PLN),
    ("Plaine indo-gangétique", PL, "GANGES PLAIN", PLN),
    ("Plaine de Mandchourie", PL, "MANCHURIAN PLAIN", PLN),
    ("Llanos", PL, "LLANOS", PLN),
    ("Plaine de Nullarbor", PL, "NULLARBOR PLAIN", PLN),
    ("Alföld (Grande plaine hongroise)", PL, "Alföld", PLN),
    ("Plaine du Serengeti", PL, "Serengeti Plains", PLN),
    ("Llano Estacado", PL, "Llano Estacado", PLN),
    ("Plaine de Sibérie occidentale", PL, "WESTERN SIBERIAN PLAIN", LOW),
    ("Plaine de Sibérie septentrionale", PL, "NORTH SIBERIAN LOWLAND", LOW),
    ("Dépression caspienne", PL, "CASPIAN DEPRESSION", LOW),
    ("Plaine de la Kolyma", PL, "KOLYMA LOWLAND", LOW),
    # --- Bassins ---
    ("Bassin amazonien", B, "AMAZON BASIN", BAS),
    ("Bassin du Congo", B, "CONGO BASIN", BAS),
    ("Grand bassin artésien", B, "GREAT ARTESIAN BASIN", BAS),
    ("Bassin Murray-Darling", B, "MURRAY-DARLING BASIN", BAS),
    ("Grand Bassin (États-Unis)", B, "GREAT BASIN", BAS),
    ("Bassin du Tarim", B, "TARIM BASIN", BAS),
    ("Bassin du Sichuan", B, "SICHUAN BASIN", BAS),
    ("Bassin de Djoungarie", B, "Junggar Basin", BAS),
    ("Bassin de Qaidam", B, "Qaidam Basin", BAS),
    ("Dépression du Bodélé", B, "Bodélé Depression", DEP),
    # --- Zones humides et deltas ---
    ("Pantanal", W, "PANTANAL", WET),
    ("Sundarbans", W, "Sundarbans", WET),
    ("Delta du Gange", W, "Ganges Delta", DEL),
    ("Delta de la Léna", W, "Lena Delta", DEL),
    ("Delta du Niger", W, "Niger Delta", DEL),
    ("Delta de l'Amazone", W, "Amazon Delta", DEL),
    # --- Toundra ---
    ("Toundra de Bolchezemelskaïa", T, "Bol’shezemel’skaya Tundra", TUN),
    ("Barren Grounds", T, "BARREN GROUNDS", TUN),
    # --- Vallées et gorges (plusieurs morceaux de même nom : fusionnés) ---
    ("Vallée du Grand Rift", V, "GREAT RIFT VALLEY", VAL),
    ("Grand Canyon", V, "Grand Canyon", GOR),
    ("Vallée centrale (Californie)", V, "Central Valley", VAL),
]
MULTI_OK = {"GREAT RIFT VALLEY"}  # NAME présent plusieurs fois dans Natural Earth

# nom affiché, type, name exact dans la couche de points Natural Earth
POINT_MAP = [
    ("Kilimandjaro", M, "Mount Kilimanjaro"),
]

# Volcans d'origine du projet : nom GVP exact -> nom affiché (français)
GVP_ORIGINAL = {
    "Etna": "Etna",
    "Vesuvius": "Vésuve",
    "Fujisan": "Mont Fuji",
    "Krakatau": "Krakatoa",
    "Popocatepetl": "Popocatépetl",
    "Merapi": "Merapi",
    "Pinatubo": "Pinatubo",
    "Erebus": "Mont Erebus",
    "Stromboli": "Stromboli",
    "Kilauea": "Kilauea",
    "Cotopaxi": "Cotopaxi",
    "Nyiragongo": "Nyiragongo",
    "St. Helens": "Mont St Helens",
    "Eyjafjallajokull": "Eyjafjallajökull",
    "Lengai, Ol Doinyo": "Ol Doinyo Lengai",
    "Yellowstone": "Caldeira de Yellowstone",
}
VOLCANO_TYPE_FR = {
    "Stratovolcano": "Stratovolcan", "Stratovolcano(es)": "Stratovolcans",
    "Caldera": "Caldeira", "Caldera(s)": "Caldeiras",
    "Shield": "Volcan bouclier", "Shield(s)": "Volcans boucliers",
    "Pyroclastic shield": "Bouclier pyroclastique", "Complex": "Complexe volcanique",
    "Lava dome(s)": "Dômes de lave", "Subglacial": "Volcan sous-glaciaire",
}


def download(url, path):
    with urllib.request.urlopen(url, timeout=180) as r, open(path, "wb") as f:
        f.write(r.read())


def load_ne(cache, name):
    os.makedirs(cache, exist_ok=True)
    path = os.path.join(cache, NE_TAG + "_" + name)
    if not os.path.exists(path):
        download(NE_BASE + name, path)
    with open(path, encoding="utf-8") as f:
        return json.load(f)["features"]


def load_gvp(cache, name):
    os.makedirs(cache, exist_ok=True)
    path = os.path.join(cache, "gvp_" + name)
    if not os.path.exists(path):
        download(GVP_BASE + name, path)
    with open(path, "rb") as f:
        data = f.read()
    got = hashlib.sha256(data).hexdigest()
    if got != GVP_FILES[name]:
        raise SystemExit(f"{name}: empreinte SHA-256 inattendue ({got}) — la source a changé, à revérifier.")
    return list(csv.DictReader(data.decode("utf-8").splitlines()))


def rnd(c):
    return [round(c[0], COORD_DECIMALS), round(c[1], COORD_DECIMALS)]


def clean_ring(ring):
    out = []
    for c in ring:
        p = rnd(c)
        if not out or p != out[-1]:
            out.append(p)
    return out if len(out) >= 4 else None


def polys_of(g):
    if g["type"] == "Polygon":
        return [g["coordinates"]]
    if g["type"] == "MultiPolygon":
        return g["coordinates"]
    raise ValueError("géométrie inattendue : " + g["type"])


def clean_geometry(geoms):
    res = []
    for g in geoms:
        for poly in polys_of(g):
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


def area_deg2(g):
    return sum(abs(ring_area_centroid(p[0])[0]) for p in polys_of(g))


def anchor(g):
    """Point de repère (lon, lat) = centroïde du plus grand morceau."""
    best = max((ring_area_centroid(p[0]) for p in polys_of(g)), key=lambda t: abs(t[0]))
    return round(best[1], 3), round(best[2], 3)


def lon_span(g):
    xs = [c[0] for p in polys_of(g) for r in p for c in r]
    return max(xs) - min(xs)


def gvp_display_name(raw):
    # « Chichon, El » -> « El Chichon » (simple remise dans l'ordre, rien d'ajouté)
    if ", " in raw:
        a, b = raw.split(", ", 1)
        return f"{b} {a}"
    return raw


def main():
    cache = sys.argv[1] if len(sys.argv) > 1 else "/tmp/natural_earth_cache"
    polys = load_ne(cache, POLYS)
    points = load_ne(cache, POINTS)
    volcanoes = load_gvp(cache, "volcano.csv")
    eruptions = load_gvp(cache, "eruptions.csv")

    by_name = {}
    for ft in polys:
        by_name.setdefault(ft["properties"]["NAME"], []).append(ft)
    pts_by_name = {}
    for ft in points:
        pts_by_name.setdefault(ft["properties"]["name"], []).append(ft)

    zones = []
    for fr, typ, ne_name, cls in POLY_MAP:
        found = by_name.get(ne_name, [])
        want = 2 if ne_name in MULTI_OK else 1
        assert len(found) == want, f"{ne_name}: {len(found)} correspondance(s) (attendu {want})"
        ids = set()
        for ft in found:
            p = ft["properties"]
            assert p["FEATURECLA"] in ((cls,) if isinstance(cls, str) else cls), \
                f"{ne_name}: classe {p['FEATURECLA']} != {cls}"
            ids.add(str(p.get("WIKIDATAID")))
        geom = clean_geometry([ft["geometry"] for ft in found])
        assert lon_span(geom) < 300, f"{ne_name}: traverse l'antiméridien"
        lon, lat = anchor(geom)
        zones.append({
            "name": fr, "type": typ, "lon": lon, "lat": lat,
            "note": "Contour : Natural Earth (domaine public).",
            "geometry": geom,
            "source": f"Natural Earth {NE_TAG}, ne_10m_geography_regions_polys, NAME={ne_name}, Wikidata {'/'.join(sorted(ids))}",
            "_area": area_deg2(geom),
        })
    # grandes zones d'abord (dessinées dessous), petites ensuite (au-dessus, cliquables)
    zones.sort(key=lambda z: -z["_area"])
    for z in zones:
        del z["_area"]

    out = list(zones)

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

    # --- Volcans (Smithsonian GVP) ---
    max_vei = {}
    for r in eruptions:
        try:
            v = int(float(r["vei"]))
        except (ValueError, TypeError):
            continue
        n = r["volcano_number"]
        max_vei[n] = max(max_vei.get(n, -1), v)
    names_count = {}
    for r in volcanoes:
        names_count[r["volcano_name"]] = names_count.get(r["volcano_name"], 0) + 1
    by_vname = {r["volcano_name"]: r for r in volcanoes}
    originals = set()
    for gname in GVP_ORIGINAL:
        assert names_count.get(gname) == 1, f"volcan {gname}: {names_count.get(gname)} entrée(s) GVP"
        originals.add(by_vname[gname]["volcano_number"])
    used = set(z["name"] for z in out)
    vol_out = []
    for r in volcanoes:
        n = r["volcano_number"]
        if not (n in originals or max_vei.get(n, -1) >= GVP_MIN_VEI):
            continue
        fr = GVP_ORIGINAL.get(r["volcano_name"]) or gvp_display_name(r["volcano_name"])
        assert fr not in used, f"nom en double : {fr}"
        used.add(fr)
        elev = r["elevation"]
        typ_fr = VOLCANO_TYPE_FR.get(r["primary_volcano_type"], r["primary_volcano_type"])
        parts = []
        if elev not in ("", None):
            parts.append(f"Altitude : {int(float(elev))} m")
        parts.append(f"Type : {typ_fr}")
        if n in max_vei:
            parts.append(f"Plus forte éruption connue : VEI {max_vei[n]}")
        vol_out.append({
            "name": fr, "type": "volcan",
            "lon": round(float(r["longitude"]), 3), "lat": round(float(r["latitude"]), 3),
            "note": ". ".join(parts) + ". (Smithsonian GVP)",
            "source": f"Smithsonian Global Volcanism Program, volcano_number={n} (copie tidytuesday 2020-05-12)",
        })
    vol_out.sort(key=lambda e: (e["lat"] < 0, e["name"]))
    out.extend(vol_out)

    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")
    n_poly = sum(1 for e in out if "geometry" in e)
    print(f"{len(out)} entrées écrites dans {OUT} ({n_poly} contours, {len(out) - n_poly} points dont {len(vol_out)} volcans).")


if __name__ == "__main__":
    main()
