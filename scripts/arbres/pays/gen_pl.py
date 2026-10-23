import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(39, "Pologne — dynasties qui ont régné sur la Pologne (Piast, Anjou-Hongrie, Jagellon, Báthory, Vasa, Wiśniowiecki, Sobieski, Leszczyński, Poniatowski)")
g.notes = [
    "Demande de Martin (2026-10-23) : arbres des dynasties de chaque pays, en commençant par la Pologne, ordre chronologique.",
    "Crée 4 arbres sous Pologne > Dynastie : Piast, Anjou-Hongrie, Báthory, Leszczyński, Poniatowski (5 arbres) ; complète 4 arbres existants : Jagellon, Vasa, Wiśniowiecki, Sobieski.",
    "Règle suivie : une épouse issue d'une dynastie qui a un arbre est créée dans CET arbre (Přemyslides, Habsbourg, Saliens, Wittelsbach, Stuart) puis reliée ;",
    "une épouse issue d'une famille sans arbre (pour l'instant) est placée dans l'arbre de son mari ET listée dans le compte rendu (« placée là où elle n'est pas censée être »).",
    "Les membres déjà dans ta base (Henri III, Venceslas II, Marie Leszczynska, Max II Emmanuel, Auguste II/III…) sont retrouvés par identifiant, jamais recréés.",
    "Les positions sont calculées sur l'échelle de dates (comme « Organiser par dates »). Aucune photo : elles seront ajoutées plus tard.",
]

# ------------------------------------------------------------------ arbres
g.tree('PL_PIAST', 'POL', 'Piast')
g.tree('PL_ANJ', 'POL', 'Anjou-Hongrie')
g.tree('PL_JAG', 'POL', 'Jagellon', entry='2330c043-bc06-4464-92c0-dbc885739729')
g.tree('PL_BAT', 'POL', 'Báthory')
g.tree('PL_VASA', 'POL', 'Vasa', entry='2ad4a20e-d7a2-4732-9a7f-b29093b07ceb')
g.tree('PL_WIS', 'POL', 'Wiśniowiecki', entry='0cb6865f-ba59-4231-848e-3621da99abc5')
g.tree('PL_SOB', 'POL', 'Sobieski', entry='f94b6d1d-87d2-46cd-8cc2-3fa4f25d49b1')
g.tree('PL_LES', 'POL', 'Leszczyński')
g.tree('PL_PON', 'POL', 'Poniatowski')
# arbres d'autres dynasties (épouses)
g.tree('CZ_PREM', 'CZE', 'Přemyslides', entry='b53dda9c-6240-43c2-8503-91cda7693dd1')
g.tree('DE_HAB', 'DEU', 'Habsbourg', entry='6b34bc03-d0ad-4c48-a485-f541cecafd5d')
g.tree('DE_SAL', 'DEU', 'Saliens', entry='bd5ca9f3-1ab0-4056-81d7-56ece7b0eee8')
g.tree('DE_WIT', 'DEU', 'Wittelsbach', entry='e76d91a3-1b9c-4703-85b3-9f711b6d6199')
g.tree('GB_STU', 'GBR', 'Maison Stuart', entry='56be697f-1d07-4e30-84e1-075968b949dd')
g.reposition = {'PL_JAG', 'PL_VASA', 'PL_WIS', 'PL_SOB'}

PI = 'Piast'
# =============================================================== PIAST
# (dates : Wikipédia ; « approx » = fourchette ou « vers »)
g.m('pl.mieszko1', 'Mieszko Ier', 930, 992, 'Duc des Polanes (vers 960-992), premier souverain historique de Pologne', PI, 'PL_PIAST', 'h', True, approx='naissance « vers 930 » (Wikipédia donne aussi vers 940)')
g.m('pl.dobrawa', 'Dobrawa de Bohême', 940, 977, 'Duchesse des Polanes', 'Přemyslides', 'CZ_PREM', 'f', approx='naissance « vers 940/945 »')
g.m('pl.oda', 'Oda de Haldensleben', 955, 1023, 'Duchesse des Polanes', 'Haldensleben (marche du Nord)', 'PL_PIAST', 'f', flag='Famille de Haldensleben (marche du Nord, Allemagne) : sans arbre', approx='naissance entre 955 et 960')
g.m('pl.boles1', 'Boleslas Ier le Vaillant', 967, 1025, 'Duc de Pologne, premier roi de Pologne (couronné en 1025)', PI, 'PL_PIAST', 'h', True)
g.m('pl.emnilda', 'Emnilda de Lusace', 972, 1017, 'Duchesse de Pologne', 'Lusace (Dobromir)', 'PL_PIAST', 'f', flag='Famille slave de Lusace : sans arbre', approx='naissance « vers 970-975 », mort « 1017 au plus tard »')
g.m('pl.mieszko2', 'Mieszko II Lambert', 990, 1034, 'Roi de Pologne (1025-1031), puis duc (1032-1034)', PI, 'PL_PIAST', 'h', True, approx='naissance « vers 990 »')
g.m('pl.richeza', 'Richeza de Lotharingie', 995, 1063, 'Reine de Pologne', 'Ézzonides (Lotharingie)', 'PL_PIAST', 'f', flag='Ézzonides (comtes palatins de Lotharingie) : sans arbre', approx='naissance entre 995 et 1000')
g.m('pl.casimir1', 'Casimir Ier le Restaurateur', 1016, 1058, 'Duc de Pologne', PI, 'PL_PIAST', 'h', True)
g.m('pl.dobroniega', 'Marie Dobroniega de Kiev', 1012, 1087, 'Duchesse de Pologne', 'Rurikides (Kiev)', 'PL_PIAST', 'f', flag='Rurikides (Kiev/Russie) : arbre à créer avec la Russie/Ukraine', approx='naissance « avant/vers 1012 »')
g.m('pl.boles2', 'Boleslas II le Hardi', 1042, 1081, 'Duc (1058-1076) puis roi de Pologne (1076-1079)', PI, 'PL_PIAST', 'h', True, approx='naissance vers 1042')
g.m('pl.wladh', 'Ladislas Ier Herman', 1044, 1102, 'Duc de Pologne', PI, 'PL_PIAST', 'h', True)
g.m('pl.judith_boh', 'Judith de Bohême', 1056, 1086, 'Duchesse de Pologne', 'Přemyslides', 'CZ_PREM', 'f')
g.m('pl.judith_sw', 'Judith de Souabe', 1054, 1105, 'Reine de Hongrie, puis duchesse de Pologne', 'Saliens', 'DE_SAL', 'f', approx='mort « vers 1105 » (contesté)')
g.m('pl.zbigniew', 'Zbigniew', 1073, 1113, 'Duc de Pologne (1102-1107)', PI, 'PL_PIAST', 'h', False, approx='naissance vers 1070/1073')
g.m('pl.boles3', 'Boleslas III Bouche-Torse', 1086, 1138, 'Duc de Pologne', PI, 'PL_PIAST', 'h', True)
g.m('pl.zbyslava', 'Zbyslava de Kiev', 1087, 1114, 'Duchesse de Pologne', 'Rurikides (Kiev)', 'PL_PIAST', 'f', flag='Rurikides (Kiev/Russie) : arbre à créer avec la Russie/Ukraine', approx='naissance vers 1085/1090, mort « vers 1114 »')
g.m('pl.salomea', 'Salomée de Berg', 1099, 1144, 'Duchesse de Pologne', 'Berg', 'PL_PIAST', 'f', flag='Comtes de Berg (Allemagne) : sans arbre', approx='naissance entre 1093 et 1101')
g.m('pl.wlad2', 'Ladislas II l\'Exilé', 1105, 1159, 'Haut-duc de Pologne (1138-1146)', PI, 'PL_PIAST', 'h', True)
g.m('pl.agnes_bab', 'Agnès de Babenberg', 1110, 1163, 'Haute-duchesse de Pologne', 'Babenberg (Autriche)', 'PL_PIAST', 'f', flag='Babenberg (Autriche) : arbre à créer avec l\'Autriche', approx='naissance vers 1108/1113, mort 1160-1163')
g.m('pl.boles4', 'Boleslas IV le Frisé', 1125, 1173, 'Haut-duc de Pologne (1146-1173)', PI, 'PL_PIAST', 'h', True, approx='naissance vers 1122/1125')
g.m('pl.mieszko3', 'Mieszko III le Vieux', 1127, 1202, 'Haut-duc de Pologne', PI, 'PL_PIAST', 'h', True, approx='naissance vers 1125/1127')
g.m('pl.casimir2', 'Casimir II le Juste', 1138, 1194, 'Haut-duc de Pologne (1177-1194)', PI, 'PL_PIAST', 'h', True)
g.m('pl.helena_zn', 'Hélène de Znojmo', 1141, 1204, 'Haute-duchesse de Pologne', 'Přemyslides (branche de Znojmo)', 'CZ_PREM', 'f', approx='naissance vers 1140/1142, mort vers 1202/1206')
g.m('pl.leszek1', 'Leszek Ier le Blanc', 1184, 1227, 'Haut-duc de Pologne', PI, 'PL_PIAST', 'h', True, approx='naissance vers 1184/1185')
g.m('pl.grzym', 'Grzymisława de Loutsk', 1190, 1258, 'Haute-duchesse de Pologne', 'Rurikides (Loutsk)', 'PL_PIAST', 'f', flag='Rurikides (Volhynie/Ukraine) : arbre à créer', approx='naissance entre 1185 et 1195, mort en 1258')
g.m('pl.konrad1', 'Conrad Ier de Mazovie', 1188, 1247, 'Duc de Mazovie, haut-duc de Pologne (1229-1232, 1241-1243)', PI, 'PL_PIAST', 'h', False, approx='naissance vers 1187/1188')
g.m('pl.agafia', 'Agafia de Rus', 1190, 1248, 'Duchesse de Mazovie', 'Rurikides', 'PL_PIAST', 'f', flag='Rurikides (Russie) : arbre à créer', approx='naissance vers 1190, mort vers 1248')
g.m('pl.boles5', 'Boleslas V le Chaste', 1226, 1279, 'Haut-duc de Pologne (1243-1279)', PI, 'PL_PIAST', 'h', True)
g.m('pl.kinga', 'Cunégonde de Hongrie (sainte Kinga)', 1224, 1292, 'Haute-duchesse de Pologne, sainte', 'Árpád (Hongrie)', 'PL_PIAST', 'f', flag='Árpád (Hongrie) : arbre à créer avec la Hongrie')
g.m('pl.casimir_k', 'Casimir Ier de Couïavie', 1211, 1267, 'Duc de Couïavie', PI, 'PL_PIAST', 'h', False, approx='naissance vers 1211')
g.m('pl.constance', 'Constance de Wrocław', 1224, 1255, 'Duchesse de Couïavie', PI, 'PL_PIAST', 'f', approx='naissance 1221-1227, mort 1253-1257 (valeurs au milieu des fourchettes)')
g.m('pl.euphro', 'Euphrosyne d\'Opole', 1229, 1292, 'Duchesse de Couïavie', PI, 'PL_PIAST', 'f', approx='naissance vers 1228/1230')
g.m('pl.leszek2', 'Leszek II le Noir', 1241, 1288, 'Haut-duc de Pologne (1279-1288)', PI, 'PL_PIAST', 'h', True, approx='naissance vers 1240/1242')
g.m('pl.wlad1', 'Ladislas Ier le Bref', 1261, 1333, 'Haut-duc (1306-1320), puis roi de Pologne (1320-1333)', PI, 'PL_PIAST', 'h', True, approx='naissance entre le 3 mars 1260 et le 19 janvier 1261')
g.m('pl.jadwiga_k', 'Jadwiga de Kalisz', 1266, 1339, 'Reine de Pologne', PI, 'PL_PIAST', 'f', approx='naissance vers 1266')
g.m('pl.casimir3', 'Casimir III le Grand', 1310, 1370, 'Roi de Pologne', PI, 'PL_PIAST', 'h', True)
g.m('pl.aldona', 'Aldona de Lituanie', 1309, 1339, 'Reine de Pologne', 'Gediminides (Lituanie)', 'PL_PIAST', 'f', flag='Gediminides (Lituanie) : arbre à créer avec la Lituanie', approx='naissance vers 1309')
g.m('pl.adelaide', 'Adélaïde de Hesse', 1324, 1371, 'Reine de Pologne', 'Maison de Hesse', 'PL_PIAST', 'f', flag='Maison de Hesse (landgraves) : sans arbre', approx='naissance vers 1324, mort après 1371')
g.m('pl.hedwig_sagan', 'Hedwige de Żagań', 1348, 1390, 'Reine de Pologne', PI, 'PL_PIAST', 'f', approx='naissance « avant 1350 » (1348 retenu au milieu de la fourchette) — à vérifier')
g.m('pl.elisabeth_pl', 'Élisabeth de Pologne (reine de Hongrie)', 1305, 1380, 'Reine de Hongrie, régente de Pologne', PI, 'PL_PIAST', 'f')
g.m('pl.elisabeth_pom', 'Élisabeth de Pologne (duchesse de Poméranie)', 1326, 1361, 'Duchesse de Poméranie', PI, 'PL_PIAST', 'f', approx='naissance vers 1326')
g.m('pl.anna_celje', 'Anne de Pologne (comtesse de Celje)', 1366, 1425, 'Comtesse de Celje', PI, 'PL_PIAST', 'f')
# lignée silésienne
g.m('pl.henri1', 'Henri Ier le Barbu', 1167, 1238, 'Duc de Silésie, haut-duc de Pologne (1232-1238)', PI, 'PL_PIAST', 'h', True, approx='naissance entre 1165 et 1170')
g.m('pl.hedwig_and', 'Hedwige de Silésie (sainte Hedwige d\'Andechs)', 1174, 1243, 'Duchesse de Silésie, sainte', 'Andechs-Méranie', 'PL_PIAST', 'f', flag='Andechs-Méranie (Bavière) : sans arbre', approx='naissance vers 1174')
g.m('pl.henri2', 'Henri II le Pieux', 1196, 1241, 'Duc de Silésie, haut-duc de Pologne (1238-1241)', PI, 'PL_PIAST', 'h', True, approx='naissance vers 1196')
g.m('pl.anne_boh', 'Anne de Bohême', 1201, 1265, 'Duchesse de Silésie', 'Přemyslides', 'CZ_PREM', 'f', approx='naissance vers 1201')
g.m('pl.henri3', 'Henri III le Blanc', 1228, 1266, 'Duc de Silésie à Wrocław', PI, 'PL_PIAST', 'h', False, approx='naissance 1227-1230')
g.m('pl.judith_maz', 'Judith de Mazovie', 1224, 1261, 'Duchesse de Silésie', PI, 'PL_PIAST', 'f', approx='naissance 1222-1227, mort 1257-1265 (valeurs au milieu des fourchettes)')
g.m('pl.henri4', 'Henri IV Probus', 1258, 1290, 'Duc de Wrocław, haut-duc de Pologne (1288-1290)', PI, 'PL_PIAST', 'h', True, approx='naissance vers 1258')
# Grande-Pologne
g.m('pl.przemysl1', 'Przemysł Ier de Grande-Pologne', 1220, 1257, 'Duc de Grande-Pologne', PI, 'PL_PIAST', 'h', False, approx='naissance vers 1220')
g.m('pl.elisabeth_wr', 'Élisabeth de Wrocław', 1228, 1265, 'Duchesse de Grande-Pologne', PI, 'PL_PIAST', 'f', approx='naissance 1224-1232 (milieu de fourchette)')
g.m('pl.przemysl2', 'Przemysł II', 1257, 1296, 'Haut-duc (1290-1291), puis roi de Pologne (1295-1296)', PI, 'PL_PIAST', 'h', True)
g.m('pl.elisabeth_rich', 'Élisabeth Richeza de Pologne', 1288, 1335, 'Reine de Bohême et de Pologne', PI, 'PL_PIAST', 'f')

# ---- relations Piast
P, S = g.par, g.sp
S('pl.mieszko1', 'pl.dobrawa'); S('pl.mieszko1', 'pl.oda')
P(Xname('Boleslas Ier « le Cruel »', 915), 'pl.dobrawa')
P('pl.mieszko1', 'pl.boles1'); P('pl.dobrawa', 'pl.boles1')
S('pl.boles1', 'pl.emnilda')
P('pl.boles1', 'pl.mieszko2'); P('pl.emnilda', 'pl.mieszko2')
S('pl.mieszko2', 'pl.richeza')
P('pl.mieszko2', 'pl.casimir1'); P('pl.richeza', 'pl.casimir1')
S('pl.casimir1', 'pl.dobroniega')
for c in ('pl.boles2', 'pl.wladh'):
    P('pl.casimir1', c); P('pl.dobroniega', c)
S('pl.wladh', 'pl.judith_boh'); S('pl.wladh', 'pl.judith_sw')
P(X('1fb35d8e'), 'pl.judith_boh')                       # Vratislav II
P(X('48b533d0'), 'pl.judith_sw')                        # Henri III le Noir
P('pl.wladh', 'pl.zbigniew')
P('pl.wladh', 'pl.boles3'); P('pl.judith_boh', 'pl.boles3')
S('pl.boles3', 'pl.zbyslava'); S('pl.boles3', 'pl.salomea')
P('pl.boles3', 'pl.wlad2'); P('pl.zbyslava', 'pl.wlad2')
for c in ('pl.boles4', 'pl.mieszko3', 'pl.casimir2'):
    P('pl.boles3', c); P('pl.salomea', c)
S('pl.wlad2', 'pl.agnes_bab')
S('pl.casimir2', 'pl.helena_zn')
for c in ('pl.leszek1', 'pl.konrad1'):
    P('pl.casimir2', c); P('pl.helena_zn', c)
S('pl.leszek1', 'pl.grzym')
P('pl.leszek1', 'pl.boles5'); P('pl.grzym', 'pl.boles5')
S('pl.boles5', 'pl.kinga')
S('pl.konrad1', 'pl.agafia')
P('pl.konrad1', 'pl.casimir_k'); P('pl.agafia', 'pl.casimir_k')
S('pl.casimir_k', 'pl.constance'); S('pl.casimir_k', 'pl.euphro')
P('pl.casimir_k', 'pl.leszek2'); P('pl.constance', 'pl.leszek2')
P('pl.casimir_k', 'pl.wlad1'); P('pl.euphro', 'pl.wlad1')
S('pl.wlad1', 'pl.jadwiga_k')
for c in ('pl.casimir3', 'pl.elisabeth_pl'):
    P('pl.wlad1', c); P('pl.jadwiga_k', c)
S('pl.casimir3', 'pl.aldona'); S('pl.casimir3', 'pl.adelaide'); S('pl.casimir3', 'pl.hedwig_sagan')
P('pl.casimir3', 'pl.elisabeth_pom'); P('pl.aldona', 'pl.elisabeth_pom')
P('pl.casimir3', 'pl.anna_celje'); P('pl.hedwig_sagan', 'pl.anna_celje')
P('pl.elisabeth_pom', X('eaa833a2'))                    # Élisabeth de Poméranie (impératrice)
# Silésie
S('pl.henri1', 'pl.hedwig_and')
P('pl.henri1', 'pl.henri2'); P('pl.hedwig_and', 'pl.henri2')
S('pl.henri2', 'pl.anne_boh')
P(X('86690abf'), 'pl.anne_boh')                         # Ottokar Ier
P('pl.henri2', 'pl.henri3'); P('pl.anne_boh', 'pl.henri3')
P('pl.henri2', 'pl.constance'); P('pl.anne_boh', 'pl.constance')
P('pl.henri2', 'pl.elisabeth_wr'); P('pl.anne_boh', 'pl.elisabeth_wr')
S('pl.henri3', 'pl.judith_maz')
P('pl.konrad1', 'pl.judith_maz'); P('pl.agafia', 'pl.judith_maz')
P('pl.henri3', 'pl.henri4'); P('pl.judith_maz', 'pl.henri4')
S('pl.przemysl1', 'pl.elisabeth_wr')
P('pl.przemysl1', 'pl.przemysl2'); P('pl.elisabeth_wr', 'pl.przemysl2')
P('pl.przemysl2', 'pl.elisabeth_rich')
S('pl.elisabeth_rich', X('59b7e461'))                   # Venceslas II
# liens avec les Přemyslides : Venceslas III (roi de Pologne 1305-1306) épinglé dans l'arbre Piast
g.pin(X('ff7a1a6f'), 'PL_PIAST')

# ================================================================ ANJOU-HONGRIE
AJ = 'Anjou-Hongrie (Capétiens d\'Anjou)'
g.m('pl.louis1', 'Louis Ier le Grand', 1326, 1382, 'Roi de Hongrie (1342-1382) et de Pologne (1370-1382)', AJ, 'PL_ANJ', 'h', True)
g.m('pl.elisabeth_bos', 'Élisabeth de Bosnie', 1340, 1387, 'Reine de Hongrie et de Pologne', 'Kotromanić (Bosnie)', 'PL_ANJ', 'f', flag='Kotromanić (Bosnie) : sans arbre', approx='naissance 1339/1340')
g.m('pl.hedwige_aj', 'Hedwige d\'Anjou', 1373, 1399, 'Roi (reine) de Pologne (1384-1399)', AJ, 'PL_ANJ', 'f', True, approx='naissance entre octobre 1373 et février 1374')
P('pl.elisabeth_pl', 'pl.louis1')
S('pl.louis1', 'pl.elisabeth_bos')
P('pl.louis1', 'pl.hedwige_aj'); P('pl.elisabeth_bos', 'pl.hedwige_aj')
P('pl.louis1', X('8921ecd5')); P('pl.elisabeth_bos', X('8921ecd5'))   # Marie d'Anjou-Hongrie

# ================================================================ JAGELLON (arbre existant complété)
JG = 'Jagellon'
g.m('pl.jogaila', 'Ladislas II Jagellon', 1362, 1434, 'Grand-duc de Lituanie, roi de Pologne (1386-1434)', JG, 'PL_JAG', 'h', True, approx='naissance entre 1352 et 1362 (recherches récentes : vers 1362)')
g.m('pl.anna_cilli', 'Anne de Celje', 1386, 1416, 'Reine de Pologne', 'Comtes de Celje (Slovénie)', 'PL_JAG', 'f', flag='Comtes de Celje (Slovénie) : arbre à créer avec la Slovénie')
g.m('pl.sofia_h', 'Sophie de Halchany', 1405, 1461, 'Reine de Pologne', 'Halchany (Lituanie)', 'PL_JAG', 'f', flag='Famille Halchany (noblesse lituanienne) : sans arbre', approx='naissance vers 1405')
g.m('pl.wlad3', 'Ladislas III Jagellon', 1424, 1444, 'Roi de Pologne et de Hongrie', JG, 'PL_JAG', 'h', True)
g.m('pl.casimir4', 'Casimir IV Jagellon', 1427, 1492, 'Roi de Pologne, grand-duc de Lituanie', JG, 'PL_JAG', 'h', True)
g.m('pl.elis_aut', 'Élisabeth d\'Autriche', 1436, 1505, 'Reine de Pologne', 'Habsbourg', 'DE_HAB', 'f', approx='naissance 1436 (Wikipédia ; d\'autres sources : 1437)')
g.m('pl.hedwig_land', 'Hedwige Jagellon (duchesse de Bavière-Landshut)', 1457, 1502, 'Duchesse de Bavière-Landshut', JG, 'PL_JAG', 'f')
g.m('pl.george_rich', 'Georges le Riche', 1455, 1503, 'Duc de Bavière-Landshut', 'Wittelsbach', 'DE_WIT', 'h', approx='dates à confirmer (non revérifiées sur Wikipédia)')
g.m('pl.jean_albert', 'Jean Ier Albert', 1459, 1501, 'Roi de Pologne', JG, 'PL_JAG', 'h', True)
g.m('pl.alexandre', 'Alexandre Jagellon', 1461, 1506, 'Roi de Pologne, grand-duc de Lituanie', JG, 'PL_JAG', 'h', True)
g.m('pl.helene_mosc', 'Hélène de Moscou', 1476, 1513, 'Reine de Pologne, grande-duchesse de Lituanie', 'Rurikides (Moscou)', 'PL_JAG', 'f', flag='Rurikides (Moscou/Russie) : arbre à créer avec la Russie')
g.m('pl.sigismond1', 'Sigismond Ier le Vieux', 1467, 1548, 'Roi de Pologne, grand-duc de Lituanie', JG, 'PL_JAG', 'h', True)
g.m('pl.barbara_z', 'Barbara Zápolya', 1495, 1515, 'Reine de Pologne', 'Zápolya (Hongrie)', 'PL_JAG', 'f', flag='Zápolya (Hongrie/Transylvanie) : arbre à créer avec la Hongrie')
g.m('pl.bona', 'Bona Sforza', 1494, 1557, 'Reine de Pologne', 'Sforza (Milan)', 'PL_JAG', 'f', flag='Sforza (Milan, Italie) : arbre à créer avec l\'Italie')
g.m('pl.isabelle', 'Isabelle Jagellon', 1519, 1559, 'Reine de Hongrie', JG, 'PL_JAG', 'f')
g.m('pl.sophie_br', 'Sophie Jagellon (duchesse de Brunswick-Lunebourg)', 1522, 1575, 'Duchesse de Brunswick-Lunebourg', JG, 'PL_JAG', 'f')
g.m('pl.anna_jag', 'Anne Jagellon (reine de Pologne)', 1523, 1596, 'Reine (co-souveraine) de Pologne', JG, 'PL_JAG', 'f', True)
g.m('pl.catherine_jag', 'Catherine Jagellon', 1526, 1583, 'Reine de Suède', JG, 'PL_JAG', 'f')
g.m('pl.barbara_rad', 'Barbe Radziwiłł', 1520, 1551, 'Reine de Pologne', 'Radziwiłł (Lituanie)', 'PL_JAG', 'f', flag='Radziwiłł (noblesse lituanienne) : sans arbre', approx='à confirmer (non revérifiée)')
sig2 = X('6b557a17'); sophie_ex = X('dcef0122'); barbara_ex = X('9573bbb5'); hedwig_ex = X('39fde483'); anne_ex = X('f06f9b33')
S('pl.hedwige_aj', 'pl.jogaila'); S('pl.jogaila', 'pl.anna_cilli'); S('pl.jogaila', 'pl.sofia_h')
P('pl.anna_celje', 'pl.anna_cilli')
P('pl.jogaila', 'pl.wlad3'); P('pl.sofia_h', 'pl.wlad3')
P('pl.jogaila', 'pl.casimir4'); P('pl.sofia_h', 'pl.casimir4')
S('pl.casimir4', 'pl.elis_aut')
P(X('ec151f43'), 'pl.elis_aut'); P(X('7ee22818'), 'pl.elis_aut')     # Albert II et Élisabeth de Luxembourg
for c in ('pl.hedwig_land', 'pl.jean_albert', 'pl.alexandre', 'pl.sigismond1', sophie_ex, barbara_ex):
    P('pl.casimir4', c); P('pl.elis_aut', c)
S('pl.hedwig_land', 'pl.george_rich')
S('pl.alexandre', 'pl.helene_mosc')
S('pl.sigismond1', 'pl.barbara_z'); S('pl.sigismond1', 'pl.bona')
P('pl.sigismond1', hedwig_ex); P('pl.barbara_z', hedwig_ex)
for c in ('pl.isabelle', sig2, 'pl.sophie_br', 'pl.anna_jag', 'pl.catherine_jag'):
    P('pl.sigismond1', c); P('pl.bona', c)
S(sig2, 'pl.barbara_rad')
g.pin(X('16d23914'), 'PL_JAG')                         # Henri III de Valois, roi de Pologne 1573-1574

# ================================================================ BÁTHORY
BA = 'Báthory'
g.m('pl.bat8', 'Étienne VIII Báthory', 1477, 1534, 'Voïvode de Transylvanie', BA, 'PL_BAT', 'h', False)
g.m('pl.telegdi', 'Catherine Telegdi', None, None, 'Noble hongroise', 'Telegdi (Hongrie)', 'PL_BAT', 'f', flag='Famille Telegdi (Hongrie) : sans arbre ; dates inconnues (non trouvées)')
g.m('pl.stefan', 'Étienne Báthory', 1533, 1586, 'Prince de Transylvanie, roi de Pologne (1576-1586)', BA, 'PL_BAT', 'h', True)
S('pl.bat8', 'pl.telegdi')
P('pl.bat8', 'pl.stefan'); P('pl.telegdi', 'pl.stefan')
S('pl.stefan', 'pl.anna_jag')

# ================================================================ VASA (arbre existant complété)
VA = 'Vasa'
g.m('pl.john3', 'Jean III de Suède', 1537, 1592, 'Roi de Suède', 'Vasa (Suède)', 'PL_VASA', 'h', False, flag='Vasa de Suède : à déplacer dans l\'arbre Vasa de la Suède (père de Sigismond III)')
g.m('pl.sigismond3', 'Sigismond III Vasa', 1566, 1632, 'Roi de Pologne (1587-1632), roi de Suède (1592-1599)', VA, 'PL_VASA', 'h', True)
g.m('pl.anne_aut1', 'Anne d\'Autriche (reine de Pologne)', 1573, 1598, 'Reine de Pologne et de Suède', 'Habsbourg', 'DE_HAB', 'f')
g.m('pl.constance_aut', 'Constance d\'Autriche', 1588, 1631, 'Reine de Pologne', 'Habsbourg', 'DE_HAB', 'f')
g.m('pl.jean2', 'Jean II Casimir', 1609, 1672, 'Roi de Pologne (1648-1668)', VA, 'PL_VASA', 'h', True)
g.m('pl.gonzague', 'Marie-Louise de Gonzague', 1611, 1667, 'Reine de Pologne', 'Gonzague (Mantoue)', 'PL_VASA', 'f', flag='Gonzague (Mantoue, Italie) : arbre à créer avec l\'Italie')
wl4 = X('93abf290'); cec = X('41a459cf')
S('pl.john3', 'pl.catherine_jag')
P('pl.john3', 'pl.sigismond3'); P('pl.catherine_jag', 'pl.sigismond3')
S('pl.sigismond3', 'pl.anne_aut1'); S('pl.sigismond3', 'pl.constance_aut')
P('pl.sigismond3', wl4); P('pl.anne_aut1', wl4)
P('pl.sigismond3', 'pl.jean2'); P('pl.constance_aut', 'pl.jean2')
P(X('323fddf6'), 'pl.anne_aut1'); P(X('323fddf6'), 'pl.constance_aut')   # Charles II d'Autriche intérieure
P(X('1ee9ec54'), 'pl.anne_aut1'); P(X('1ee9ec54'), 'pl.constance_aut')    # Marie-Anne de Bavière (mère)
S(wl4, 'pl.gonzague'); S('pl.jean2', 'pl.gonzague')

# ================================================================ WIŚNIOWIECKI
WI = 'Wiśniowiecki'
g.m('pl.jeremi', 'Jérémie Wiśniowiecki', 1612, 1651, 'Prince, voïvode de Ruthénie', WI, 'PL_WIS', 'h', False)
g.m('pl.gryzelda', 'Gryzelda Constance Zamoyska', 1623, 1672, 'Princesse Wiśniowiecka', 'Zamoyski', 'PL_WIS', 'f', flag='Famille Zamoyski (noblesse polonaise) : sans arbre')
mich = X('4e4bdfb0')
S('pl.jeremi', 'pl.gryzelda'); P('pl.jeremi', mich); P('pl.gryzelda', mich)

# ================================================================ SOBIESKI
SO = 'Sobieski'
g.m('pl.jean3', 'Jean III Sobieski', 1629, 1696, 'Roi de Pologne (1674-1696)', SO, 'PL_SOB', 'h', True)
g.m('pl.marysienka', 'Marie-Casimire de La Grange d\'Arquien', 1641, 1716, 'Reine de Pologne', 'La Grange d\'Arquien (France)', 'PL_SOB', 'f', flag='Famille d\'Arquien (noblesse française) : sans arbre')
g.m('pl.jakub', 'Jacques-Louis Sobieski', 1667, 1737, 'Prince héritier de Pologne', SO, 'PL_SOB', 'h', False)
g.m('pl.hedwig_neu', 'Hedwige-Élisabeth de Neubourg', 1673, 1722, 'Princesse Sobieska', 'Wittelsbach (Palatinat-Neubourg)', 'DE_WIT', 'f')
g.m('pl.clementina', 'Marie-Clémentine Sobieska', 1702, 1735, 'Reine titulaire d\'Angleterre (Jacobite)', SO, 'PL_SOB', 'f')
g.m('pl.old_pret', 'Jacques-François-Édouard Stuart', 1688, 1766, 'Prétendant jacobite au trône d\'Angleterre (« Jacques III »)', 'Stuart', 'GB_STU', 'h')
thr = X('f8628f61')
S('pl.jean3', 'pl.marysienka')
P('pl.jean3', 'pl.jakub'); P('pl.marysienka', 'pl.jakub')
P('pl.jean3', thr); P('pl.marysienka', thr)
S('pl.jakub', 'pl.hedwig_neu')
P(X('1db34b87'), 'pl.hedwig_neu')                     # Philippe-Guillaume de Neubourg
P('pl.jakub', 'pl.clementina'); P('pl.hedwig_neu', 'pl.clementina')
S('pl.clementina', 'pl.old_pret')
P(X('72e625f7'), 'pl.old_pret')                       # Jacques II

# ================================================================ LESZCZYŃSKI
LE = 'Leszczyński'
g.m('pl.rafal', 'Raphaël Leszczyński', 1650, 1703, 'Grand trésorier de la Couronne', LE, 'PL_LES', 'h', False, approx='naissance 1650 (non revérifiée)')
g.m('pl.stanislas1', 'Stanislas Ier Leszczyński', 1677, 1766, 'Roi de Pologne (1704-1709, 1733-1736), duc de Lorraine', LE, 'PL_LES', 'h', True)
g.m('pl.opalinska', 'Catherine Opalińska', 1680, 1747, 'Reine de Pologne', 'Opaliński', 'PL_LES', 'f', flag='Famille Opaliński (noblesse polonaise) : sans arbre', approx='à confirmer (non revérifiée)')
S('pl.stanislas1', 'pl.opalinska')
P('pl.rafal', 'pl.stanislas1')
mar = X('05d39234')
P('pl.stanislas1', mar); P('pl.opalinska', mar)

# ================================================================ PONIATOWSKI
PO = 'Poniatowski'
g.m('pl.pon_pere', 'Stanislas Poniatowski', 1676, 1762, 'Castellan de Cracovie', PO, 'PL_PON', 'h', False)
g.m('pl.czartor', 'Constance Czartoryska', 1700, 1759, 'Princesse Czartoryska', 'Czartoryski', 'PL_PON', 'f', flag='Famille Czartoryski (noblesse polono-lituanienne) : sans arbre')
g.m('pl.stanislas2', 'Stanislas II Auguste Poniatowski', 1732, 1798, 'Dernier roi de Pologne (1764-1795)', PO, 'PL_PON', 'h', True)
S('pl.pon_pere', 'pl.czartor')
P('pl.pon_pere', 'pl.stanislas2'); P('pl.czartor', 'pl.stanislas2')

if __name__ == '__main__':
    print(g.write())
    print(len(g.M), len(g.R))
