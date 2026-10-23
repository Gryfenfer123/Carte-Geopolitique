import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *


def E(p):
    return [k for k in ENT if k.startswith(p)][0]


g = Gen(42, "Autriche — Babenberg et Habsbourg-Lorraine")
g.notes = [
    "Crée sous Autriche > Dynastie : Babenberg (976-1246) et Habsbourg-Lorraine (François II/Ier d'Autriche -> Charles Ier).",
    "Les Habsbourg « d'avant » (jusqu'à Léopold II) restent dans l'arbre Habsbourg d'Allemagne (Saint-Empire) ; Léopold II y apparaît comme membre étranger dans l'arbre Habsbourg-Lorraine.",
    "Rattache à Babenberg : Agnès de Babenberg (reine de Pologne, ex-Piast), Gertrude et Marguerite de Babenberg (ex-Přemyslides), Agnès d'Autriche (reine de Hongrie, ex-Árpád).",
    "Épouses d'autres dynasties créées dans leur arbre : Hélène de Hongrie (Árpád), Henri (VII) (Hohenstaufen), Sophie/Caroline-Auguste/Ludovique et Élisabeth de Bavière (Wittelsbach), Marie-Thérèse de Naples et Marie-Annonciade (Bourbon-Siciles), Zita (Bourbon-Parme), Stéphanie (Belgique), Marie-Josèphe de Saxe (Wettin).",
    "Marie-Louise d'Autriche (arbre Bonaparte) n'est pas déplacée : elle apparaît dans l'arbre Habsbourg-Lorraine comme membre étranger.",
    "Prérequis : v41 exécuté.",
]
g.tree('AT_BAB', 'AUT', 'Babenberg')
g.tree('AT_HL', 'AUT', 'Habsbourg-Lorraine')
g.tree('HU_ARP', 'HUN', 'Árpád')
g.tree('PL_PIAST', 'POL', 'Piast')
g.tree('CZ_PREM', 'CZE', 'Přemyslides', entry='b53dda9c-6240-43c2-8503-91cda7693dd1')
g.tree('DE_HOH', 'DEU', 'Hohenstaufen', entry='19aed0d5-8c4a-4125-b821-8fc6bc357dab')
g.tree('DE_WIT', 'DEU', 'Wittelsbach', entry='e76d91a3-1b9c-4703-85b3-9f711b6d6199')
g.tree('DE_WET', 'DEU', 'Wettin', entry='309f20ea-3b5d-453b-87f9-286b7f1e6c60')
g.tree('IT_BS', 'ITA', 'Maison de Bourbon-Siciles', entry=E('8c602f56'))
g.tree('IT_PAR', 'ITA', 'Maison de Bourbon-Parme', entry=E('84c9f117'))
g.tree('BE_COU', 'BEL', 'Couronne belge', entry=E('b4e42a0f'))
g.reposition = {'HU_ARP', 'PL_PIAST', 'CZ_PREM'}
Gen.FIXB = {'1fb35d8e-0c0e-4218-bdfe-02b7e21890a9': 1035, 'a73a4282-9de1-4aca-84e3-7fdf6a5f0f37': 940}

P, S = g.par, g.sp
BA = 'Babenberg'

# ================================================================ BABENBERG
g.m('at.leopold1', 'Léopold Ier l\'Illustre', 940, 994, 'Margrave d\'Autriche (976-994)', BA, 'AT_BAB', 'h', True, approx='naissance « vers 940 »')
g.m('at.richardis', 'Richarde de Sualafeld', None, None, 'Margravine d\'Autriche', 'Sualafeld (Bavière)', 'AT_BAB', 'f', flag='Famille de Sualafeld (Bavière) : sans arbre ; dates inconnues', approx='dates inconnues')
g.m('at.henry1', 'Henri Ier le Fort', 965, 1018, 'Margrave d\'Autriche (994-1018)', BA, 'AT_BAB', 'h', True, approx='naissance « vers 965 »')
g.m('at.adalbert1', 'Adalbert Ier le Victorieux', 985, 1055, 'Margrave d\'Autriche (1018-1055)', BA, 'AT_BAB', 'h', True, approx='naissance « vers 985 »')
g.m('at.frozza', 'Frozza Orseolo', None, None, 'Margravine d\'Autriche', 'Orseolo (Venise)', 'AT_BAB', 'f', flag='Orseolo (Venise/Hongrie) : sans arbre ; dates non renseignées', approx='dates non renseignées')
g.m('at.ernest', 'Ernest le Brave', 1027, 1075, 'Margrave d\'Autriche (1055-1075)', BA, 'AT_BAB', 'h', True)
g.m('at.adelaide_e', 'Adélaïde d\'Eilenburg', None, None, 'Margravine d\'Autriche', 'Wettin (Eilenburg)', 'AT_BAB', 'f', flag='Maison de Wettin (comtes d\'Eilenburg) : sans lien établi avec l\'arbre Wettin ; dates non renseignées', approx='dates non renseignées')
g.m('at.leopold2', 'Léopold II le Beau', 1050, 1095, 'Margrave d\'Autriche (1075-1095)', BA, 'AT_BAB', 'h', True)
g.m('at.ida', 'Ida de Formbach-Ratelnberg', None, None, 'Margravine d\'Autriche', 'Formbach-Ratelnberg (Bavière)', 'AT_BAB', 'f', flag='Comtes de Formbach (Bavière) : sans arbre ; dates non renseignées', approx='dates non renseignées')
g.m('at.leopold3', 'Léopold III le Saint', 1073, 1136, 'Margrave d\'Autriche (1095-1136), saint', BA, 'AT_BAB', 'h', True)
g.m('at.leopold4', 'Léopold IV le Généreux', 1108, 1141, 'Margrave d\'Autriche (1136-1141), duc de Bavière', BA, 'AT_BAB', 'h', True)
g.m('at.henry2', 'Henri II Jasomirgott', 1107, 1177, 'Margrave (1141-1156) puis premier duc d\'Autriche (1156-1177)', BA, 'AT_BAB', 'h', True)
g.m('at.theodora_k', 'Théodora Comnène', 1134, 1184, 'Duchesse d\'Autriche', 'Comnène (Byzance)', 'AT_BAB', 'f', flag='Comnène (Empire byzantin) : arbre à créer avec la Grèce', approx='dates « vers 1134 – 1184 »')
g.m('at.leopold5', 'Léopold V le Vertueux', 1157, 1194, 'Duc d\'Autriche (1177-1194) et de Styrie (1192)', BA, 'AT_BAB', 'h', True)
g.m('at.helena', 'Hélène de Hongrie (duchesse d\'Autriche)', 1158, 1199, 'Duchesse d\'Autriche', 'Árpád', 'HU_ARP', 'f', approx='naissance « vers 1158 »')
g.m('at.frederick1', 'Frédéric Ier le Catholique', 1175, 1198, 'Duc d\'Autriche (1194-1198)', BA, 'AT_BAB', 'h', True)
g.m('at.leopold6', 'Léopold VI le Glorieux', 1176, 1230, 'Duc d\'Autriche et de Styrie (1198-1230)', BA, 'AT_BAB', 'h', True)
g.m('at.theodora_a', 'Théodora Ange', None, None, 'Duchesse d\'Autriche', 'Ange (Byzance)', 'AT_BAB', 'f', flag='Maison Ange (Empire byzantin) : arbre à créer avec la Grèce ; dates non renseignées', approx='dates non renseignées')
g.m('at.henry_prof', 'Henri le Profane (Henri de Mödling)', 1208, 1228, 'Duc de Mödling', BA, 'AT_BAB', 'h', False)
g.m('at.agnes_thu', 'Agnès de Thuringe', None, None, 'Duchesse de Mödling', 'Ludowingiens (Thuringe)', 'AT_BAB', 'f', flag='Ludowingiens (landgraves de Thuringe) : sans arbre ; dates non renseignées', approx='dates non renseignées')
g.m('at.gertrude_m', 'Gertrude de Babenberg (héritière de Mödling)', 1226, 1288, 'Duchesse de Mödling, prétendante à l\'Autriche', BA, 'AT_BAB', 'f', False)
g.m('at.frederick2', 'Frédéric II le Querelleur', 1211, 1246, 'Duc d\'Autriche et de Styrie (1230-1246), dernier Babenberg', BA, 'AT_BAB', 'h', True)
g.m('at.sophia_l', 'Sophie Lascaris (épouse de Frédéric II)', None, None, 'Duchesse d\'Autriche', 'Lascaris (Nicée)', 'AT_BAB', 'f', flag='Lascaris (Empire de Nicée) : arbre à créer avec la Grèce ; dates non renseignées', approx='dates non renseignées')
g.m('at.agnes_mer', 'Agnès de Méranie', None, None, 'Duchesse d\'Autriche', 'Andechs-Méranie', 'AT_BAB', 'f', flag='Comtes d\'Andechs-Méranie (Bavière) : sans arbre ; dates non renseignées', approx='dates non renseignées')
g.m('at.henry7', 'Henri (VII) de Hohenstaufen', 1211, 1242, 'Roi des Romains (1220-1235), corégent', 'Hohenstaufen', 'DE_HOH', 'h', approx='naissance 1211 ; mort 12 février 1242')

P('at.leopold1', 'at.henry1'); P('at.richardis', 'at.henry1')
P('at.leopold1', 'at.adalbert1'); P('at.richardis', 'at.adalbert1')
S('at.leopold1', 'at.richardis')
S('at.adalbert1', 'at.frozza')
P('at.adalbert1', 'at.ernest'); P('at.frozza', 'at.ernest')
S('at.ernest', 'at.adelaide_e')
P('at.ernest', 'at.leopold2'); P('at.adelaide_e', 'at.leopold2')
S('at.leopold2', 'at.ida')
P('at.leopold2', 'at.leopold3'); P('at.ida', 'at.leopold3')
agnesF = X('660c7413')
S('at.leopold3', agnesF)
P(X('50dba002'), agnesF); P(X('04dd1dfb'), agnesF)                # Henri IV et Berthe de Savoie
for c in ('at.leopold4', 'at.henry2', 'cz.gertrude', 'pl.agnes_bab'):
    P('at.leopold3', c); P(agnesF, c)
S('at.henry2', X('a6ef68a0')); S('at.henry2', 'at.theodora_k')       # Gertrude de Saxe (Süpplingenburg), Théodora Comnène
for c in ('at.leopold5', 'hu.agnes_aut'):
    P('at.henry2', c); P('at.theodora_k', c)
S('at.leopold5', 'at.helena')
P('hu.geza2', 'at.helena'); P('hu.euphrosyne', 'at.helena')
for c in ('at.frederick1', 'at.leopold6'):
    P('at.leopold5', c); P('at.helena', c)
S('at.leopold6', 'at.theodora_a')
for c in ('at.henry_prof', 'at.frederick2', 'cz.margaret_bab'):
    P('at.leopold6', c); P('at.theodora_a', c)
S('at.henry_prof', 'at.agnes_thu')
P('at.henry_prof', 'at.gertrude_m'); P('at.agnes_thu', 'at.gertrude_m')
S('at.frederick2', 'at.sophia_l'); S('at.frederick2', 'at.agnes_mer')
# Henri (VII) : fils de Frédéric II de Hohenstaufen et de Constance d'Aragon ; épouse Marguerite de Babenberg
P(X('df121566'), 'at.henry7'); P('hu.constance_ar', 'at.henry7')
S('at.henry7', 'cz.margaret_bab')

# ================================================================ HABSBOURG-LORRAINE
HL = 'Habsbourg-Lorraine'
g.m('at.francis2', 'François II/Ier d\'Autriche', 1768, 1835, 'Dernier empereur du Saint-Empire (1792-1806), premier empereur d\'Autriche (1804-1835)', HL, 'AT_HL', 'h', True)
g.m('at.elis_wurt', 'Élisabeth de Wurtemberg', 1767, 1790, 'Archiduchesse d\'Autriche', 'Wurtemberg', 'AT_HL', 'f', flag='Maison de Wurtemberg (Allemagne) : sans arbre')
g.m('at.mt_naples', 'Marie-Thérèse de Naples et de Sicile', 1772, 1807, 'Impératrice d\'Autriche', 'Bourbon-Siciles', 'IT_BS', 'f')
g.m('at.ludovica_e', 'Marie-Ludovique d\'Autriche-Este', 1787, 1816, 'Impératrice d\'Autriche', 'Autriche-Este', 'AT_HL', 'f', flag='Maison d\'Autriche-Este (Italie) : sans arbre')
g.m('at.caroline_b', 'Caroline-Auguste de Bavière', 1792, 1873, 'Impératrice d\'Autriche', 'Wittelsbach', 'DE_WIT', 'f')
g.m('at.ferdinand1', 'Ferdinand Ier d\'Autriche', 1793, 1875, 'Empereur d\'Autriche (1835-1848)', HL, 'AT_HL', 'h', True)
g.m('at.maria_anna_s', 'Marie-Anne de Savoie', 1803, 1884, 'Impératrice d\'Autriche', 'Savoie', 'AT_HL', 'f', flag='Maison de Savoie (Italie) : arbre à créer avec l\'Italie')
g.m('at.francis_charles', 'François-Charles d\'Autriche', 1802, 1878, 'Archiduc, père de François-Joseph', HL, 'AT_HL', 'h')
g.m('at.sophie_b', 'Sophie de Bavière (archiduchesse)', 1805, 1872, 'Archiduchesse d\'Autriche', 'Wittelsbach', 'DE_WIT', 'f')
g.m('at.franz_joseph', 'François-Joseph Ier', 1830, 1916, 'Empereur d\'Autriche (1848-1916), roi de Hongrie', HL, 'AT_HL', 'h', True)
g.m('at.sisi', 'Élisabeth de Bavière (Sissi)', 1837, 1898, 'Impératrice d\'Autriche, reine de Hongrie', 'Wittelsbach', 'DE_WIT', 'f')
g.m('at.max_bav', 'Maximilien en Bavière', 1808, 1888, 'Duc en Bavière, père de Sissi', 'Wittelsbach', 'DE_WIT', 'h')
g.m('at.ludovika_b', 'Louise de Bavière (duchesse en Bavière)', 1808, 1892, 'Duchesse en Bavière, mère de Sissi', 'Wittelsbach', 'DE_WIT', 'f')
g.m('at.rudolf', 'Rodolphe de Habsbourg-Lorraine', 1858, 1889, 'Prince héritier d\'Autriche-Hongrie', HL, 'AT_HL', 'h')
g.m('at.stephanie', 'Stéphanie de Belgique', 1864, 1945, 'Princesse héritière d\'Autriche-Hongrie', 'Saxe-Cobourg (Belgique)', 'BE_COU', 'f')
g.m('at.karl_ludwig', 'Charles-Louis d\'Autriche', 1833, 1896, 'Archiduc, père de François-Ferdinand et d\'Otton', HL, 'AT_HL', 'h')
g.m('at.annunziata', 'Marie-Annonciade de Bourbon-Siciles', 1843, 1871, 'Archiduchesse d\'Autriche', 'Bourbon-Siciles', 'IT_BS', 'f')
g.m('at.franz_ferdinand', 'François-Ferdinand d\'Autriche', 1863, 1914, 'Archiduc héritier, assassiné à Sarajevo (1914)', HL, 'AT_HL', 'h')
g.m('at.sophie_chotek', 'Sophie Chotek', 1868, 1914, 'Duchesse de Hohenberg', 'Chotek (Bohême)', 'AT_HL', 'f', flag='Famille Chotek (noblesse tchèque) : sans arbre')
g.m('at.otto_franz', 'Otton-François d\'Autriche', 1865, 1906, 'Archiduc, père de Charles Ier', HL, 'AT_HL', 'h')
g.m('at.maria_josepha', 'Marie-Josèphe de Saxe (archiduchesse)', 1867, 1944, 'Archiduchesse d\'Autriche', 'Wettin', 'DE_WET', 'f')
g.m('at.charles1', 'Charles Ier d\'Autriche', 1887, 1922, 'Dernier empereur d\'Autriche et roi de Hongrie (1916-1918)', HL, 'AT_HL', 'h', True)
g.m('at.zita', 'Zita de Bourbon-Parme', 1892, 1989, 'Impératrice d\'Autriche, reine de Hongrie', 'Bourbon-Parme', 'IT_PAR', 'f')
g.m('at.otto', 'Otto de Habsbourg-Lorraine', 1912, 2011, 'Prince héritier, chef de la maison, député européen', HL, 'AT_HL', 'h')

lII = X('5c2c9042')
P(lII, 'at.francis2'); P(X('2f5ade1a'), 'at.francis2')                # Léopold II, Marie-Louise d'Espagne
S('at.francis2', 'at.elis_wurt'); S('at.francis2', 'at.mt_naples'); S('at.francis2', 'at.ludovica_e'); S('at.francis2', 'at.caroline_b')
P(X('8b9e281c'), 'at.mt_naples'); P(X('4ec820bc'), 'at.mt_naples')   # Ferdinand Ier des Deux-Siciles, Marie-Caroline
P(X('bb2ceff8'), 'at.caroline_b'); P(X('bb2ceff8'), 'at.sophie_b'); P(X('bb2ceff8'), 'at.ludovika_b')
mlou = X('5a2dc471')
for c in ('at.ferdinand1', mlou, 'at.francis_charles'):
    P('at.francis2', c); P('at.mt_naples', c)
S('at.ferdinand1', 'at.maria_anna_s')
S('at.francis_charles', 'at.sophie_b')
for c in ('at.franz_joseph', 'at.karl_ludwig'):
    P('at.francis_charles', c); P('at.sophie_b', c)
S('at.max_bav', 'at.ludovika_b')
P('at.max_bav', 'at.sisi'); P('at.ludovika_b', 'at.sisi')
S('at.franz_joseph', 'at.sisi')
P('at.franz_joseph', 'at.rudolf'); P('at.sisi', 'at.rudolf')
S('at.rudolf', 'at.stephanie'); P(X('166bd086'), 'at.stephanie')       # Léopold II de Belgique
S('at.karl_ludwig', 'at.annunziata')
for c in ('at.franz_ferdinand', 'at.otto_franz'):
    P('at.karl_ludwig', c); P('at.annunziata', c)
S('at.franz_ferdinand', 'at.sophie_chotek')
S('at.otto_franz', 'at.maria_josepha')
P(X('3eb3cec7'), 'at.maria_josepha'); P(X('26f73795'), 'at.maria_josepha')   # Georges Ier de Saxe, Marie-Anne de Portugal
for c in ('at.charles1',):
    P('at.otto_franz', c); P('at.maria_josepha', c)
S('at.charles1', 'at.zita')
P('at.charles1', 'at.otto'); P('at.zita', 'at.otto')

# ================================================================ rattachements
g.move('pl.agnes_bab', 'AT_BAB', 'Babenberg')
g.move('cz.gertrude', 'AT_BAB', 'Babenberg'); g.setdates('cz.gertrude', 1118, 1150)
g.move('cz.margaret_bab', 'AT_BAB', 'Babenberg')
g.move('hu.agnes_aut', 'AT_BAB', 'Babenberg')

if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
