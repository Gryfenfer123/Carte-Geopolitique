import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]


g = Gen(61, "Allemagne — Wittelsbach : branches palatine, Deux-Ponts, Neubourg, Sulzbach, Landshut et rois de Bavière")
g.notes = [
    "Complète l'arbre Wittelsbach existant (rien n'est supprimé) : relie des membres déjà placés mais sans parents, et ajoute les souverains manquants.",
    "Sources : Wikipédia (pages en anglais des souverains, rubrique famille), et la « Stammliste der Wittelsbacher » (Wikipédia allemand) pour les années des épouses quand la page du mari n'en donne pas.",
    "Épouses d'une dynastie qui a un arbre : créées dans cet arbre puis reliées (Hohenzollern, Habsbourg, Wettin, Lancastre, Danemark, Pays-Bas, Luxembourg). Les autres sont placées ici et signalées.",
    "Prérequis : v60 exécuté (photos) ; aucun lien avec les autres migrations en attente.",
]
WIT = 'Wittelsbach'
g.tree('DE_WIT', 'DEU', 'Wittelsbach', entry=E('e76d91a3'))
g.tree('DE_HOH', 'DEU', 'Hohenzollern', entry=E('39895573'))
g.tree('DE_HAB', 'DEU', 'Habsbourg', entry=E('6b34bc03'))
g.tree('DE_WET', 'DEU', 'Wettin', entry=E('309f20ea'))
g.tree('GB_LAN', 'GBR', 'Maison de Lancastre', entry=E('a393c0e9'))
g.tree('DK_OLD', 'DNK', "Maison d'Oldenbourg", entry=E('7fc4995d'))
g.tree('NL_ORA', 'NLD', "Maison d'Orange Nassau", entry=E('7733ccfd'))
g.tree('LU_NAS', 'LUX', 'Nassau-Weilburg')
g.tree('DE_WEL', 'DEU', 'Welf', entry=E('db5ef554'))
g.reposition = {'DE_WIT'}
P, S = g.par, g.sp

def W(code, name, b, d, title, dyn, g_, tree='DE_WIT', leader=False, approx=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)

def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)

# ---------- Rupert III et la branche palatine (électeurs) ----------
RUP3 = X('0d501e')                       # Rupert du Palatin (roi des Romains)
RUP2 = X('e72019'); BEA = None
W('wi.elis_nur', 'Élisabeth de Hohenzollern-Nuremberg', 1358, 1411, 'Reine des Romains (épouse de Rupert)', 'Hohenzollern (Nuremberg)', 'f', 'DE_HOH',
  approx='dates 1358-1411 : Stammliste der Wittelsbacher (la page de Rupert ne les donne pas)')
P(X('b5beebc9'), 'wi.elis_nur')           # son père : Frédéric V de Nuremberg
S(RUP3, 'wi.elis_nur')
PAL = 'Wittelsbach (Palatinat)'
W('wi.louis3', 'Louis III du Palatinat', 1378, 1436, 'Électeur palatin (1410-1436)', PAL, 'h')
W('wi.stephan', 'Étienne de Palatinat-Simmern-Deux-Ponts', 1385, 1459, 'Comte palatin de Simmern-Deux-Ponts', 'Wittelsbach (Simmern-Deux-Ponts)', 'h')
kids([RUP3, 'wi.elis_nur'], ['wi.louis3', 'wi.stephan'])
W('wi.blanche', 'Blanche de Lancastre', 1392, 1409, 'Électrice palatine, première épouse de Louis III', 'Lancastre', 'f', 'GB_LAN')
P(X('5353d1e7'), 'wi.blanche')
W('wi.mathilde_sav', 'Mathilde de Savoie (électrice palatine)', None, None, 'Électrice palatine, seconde épouse de Louis III', 'Savoie', 'f',
  flag='Maison de Savoie (Italie) : arbre à créer avec l\'Italie', approx='dates non données par la page de Louis III ni par la Stammliste')
S('wi.louis3', 'wi.blanche'); S('wi.louis3', 'wi.mathilde_sav')
W('wi.louis4', 'Louis IV du Palatinat', 1424, 1449, 'Électeur palatin (1436-1449)', PAL, 'h')
W('wi.frederic1_pal', 'Frédéric Ier le Victorieux', 1425, 1476, 'Électeur palatin (1449-1476)', PAL, 'h')
kids(['wi.louis3', 'wi.mathilde_sav'], ['wi.louis4', 'wi.frederic1_pal'])
W('wi.marg_sav', 'Marguerite de Savoie (électrice palatine)', 1420, 1479, 'Électrice palatine', 'Savoie', 'f', flag='Maison de Savoie (Italie) : arbre à créer avec l\'Italie',
  approx='dates 1420-1479 : Stammliste der Wittelsbacher (non données par la page de Louis IV)')
S('wi.louis4', 'wi.marg_sav')
W('wi.philippe', 'Philippe du Palatinat', 1448, 1508, 'Électeur palatin (1476-1508)', PAL, 'h')
kids(['wi.louis4', 'wi.marg_sav'], ['wi.philippe'])

# ---------- Bavière-Landshut (reliée à Étienne II) ----------
LAND = 'Wittelsbach (Bavière-Landshut)'
W('wi.frederic_land', 'Frédéric de Bavière-Landshut', 1339, 1393, 'Duc de Bavière (Landshut)', LAND, 'h')
P(X('cdef06'), 'wi.frederic_land'); P(X('7cc1fb5a'), 'wi.frederic_land')      # Étienne II + Élisabeth de Sicile
W('wi.maddalena', 'Maddalena Visconti', None, None, 'Duchesse de Bavière-Landshut', 'Visconti', 'f', flag='Maison Visconti (Italie) : sans arbre',
  approx='dates non données par la page de Frédéric')
S('wi.frederic_land', 'wi.maddalena')
P('wi.frederic_land', X('55bbdc')); P('wi.maddalena', X('55bbdc'))              # Élisabeth de Bavière-Landshut (1383)
W('wi.henri16', 'Henri XVI le Riche', 1386, 1450, 'Duc de Bavière-Landshut', LAND, 'h')
kids(['wi.frederic_land', 'wi.maddalena'], ['wi.henri16'])
W('wi.marg_aut1', "Marguerite d'Autriche (duchesse de Bavière-Landshut)", None, None, 'Duchesse de Bavière-Landshut', 'Habsbourg', 'f', 'DE_HAB',
  approx='dates non données par la page de Henri XVI')
P(X('f51766e0'), 'wi.marg_aut1')                                                 # Albert IV le Patient
S('wi.henri16', 'wi.marg_aut1')
W('wi.louis9', 'Louis IX le Riche', 1417, 1479, 'Duc de Bavière-Landshut', LAND, 'h')
kids(['wi.henri16', 'wi.marg_aut1'], ['wi.louis9'])
W('wi.amelie_sax', 'Amélie de Saxe (duchesse de Bavière-Landshut)', None, None, 'Duchesse de Bavière-Landshut', 'Wettin', 'f', 'DE_WET',
  approx='dates non données par les pages consultées')
P(X('482240c2'), 'wi.amelie_sax'); P(X('4f4f63e3'), 'wi.amelie_sax')           # Frédéric II le Doux + Marguerite d'Autriche
S('wi.louis9', 'wi.amelie_sax')
GEO = 'pl.george_rich'                                                                # Georges le Riche
kids(['wi.louis9', 'wi.amelie_sax'], [GEO])
W('wi.marg_land', 'Marguerite de Bavière-Landshut', 1456, 1501, 'Électrice palatine', LAND, 'f')
kids(['wi.louis9', 'wi.amelie_sax'], ['wi.marg_land'])
S('wi.philippe', 'wi.marg_land')
W('wi.elis_land', 'Élisabeth de Bavière-Landshut (1478-1504)', 1478, 1504, 'Duchesse héritière de Bavière-Landshut', LAND, 'f')
P(GEO, 'wi.elis_land'); P('pl.hedwig_land', 'wi.elis_land')

# enfants de Philippe : Louis V, Frédéric II, Rupert
W('wi.louis5', 'Louis V du Palatinat', 1478, 1544, 'Électeur palatin (1508-1544)', PAL, 'h')
W('wi.frederic2', 'Frédéric II du Palatinat', 1482, 1556, 'Électeur palatin (1544-1556)', PAL, 'h')
W('wi.rupert_pal', 'Rupert du Palatinat (1481-1504)', 1481, 1504, 'Comte palatin', PAL, 'h')
kids(['wi.philippe', 'wi.marg_land'], ['wi.louis5', 'wi.frederic2', 'wi.rupert_pal'])
W('wi.sibylle', 'Sibylle de Bavière (électrice palatine)', 1489, 1519, 'Électrice palatine', 'Wittelsbach (Bavière-Munich)', 'f',
  approx='naissance 1489 : Stammliste ; la page de Louis V donne seulement la mort (1519)')
P(X('729175'), 'wi.sibylle'); P(X('aba6b16a'), 'wi.sibylle')                 # Albert IV + Cunégonde d'Autriche
S('wi.louis5', 'wi.sibylle')
W('wi.dorothee_dk', 'Dorothée de Danemark', 1520, 1580, 'Électrice palatine', 'Oldenbourg (Danemark)', 'f', 'DK_OLD',
  approx='dates 1520-1580 : Stammliste (non données par la page de Frédéric II)')
P(X('c5804411'), 'wi.dorothee_dk')                                               # Christian II
S('wi.frederic2', 'wi.dorothee_dk')
S('wi.rupert_pal', 'wi.elis_land')
W('wi.ottheinrich', 'Othon-Henri du Palatinat (Ottheinrich)', 1502, 1559, 'Électeur palatin (1556-1559)', PAL, 'h')
kids(['wi.rupert_pal', 'wi.elis_land'], ['wi.ottheinrich'])
W('wi.suzanne', 'Suzanne de Bavière (1502-1543)', 1502, 1543, 'Électrice palatine, épouse d\'Othon-Henri', 'Wittelsbach (Bavière-Munich)', 'f')
P(X('729175'), 'wi.suzanne'); P(X('aba6b16a'), 'wi.suzanne')
S('wi.ottheinrich', 'wi.suzanne')

# ---------- Simmern et Deux-Ponts (issus d'Étienne) ----------
SIM = 'Wittelsbach (Simmern)'
ZW = 'Wittelsbach (Deux-Ponts)'
W('wi.anne_veld', 'Anne de Veldenz', 1390, 1439, 'Comtesse palatine de Simmern-Deux-Ponts', 'Veldenz', 'f', flag='Maison de Veldenz : sans arbre',
  approx='naissance « vers 1390 » : Stammliste ; la page d\'Étienne donne seulement la mort (1439)')
S('wi.stephan', 'wi.anne_veld')
W('wi.fred1_sim', 'Frédéric Ier de Palatinat-Simmern', 1417, 1480, 'Comte palatin de Simmern', SIM, 'h')
W('wi.louis1_zw', 'Louis Ier de Deux-Ponts', 1424, 1489, 'Comte palatin de Deux-Ponts', ZW, 'h')
kids(['wi.stephan', 'wi.anne_veld'], ['wi.fred1_sim', 'wi.louis1_zw'])
W('wi.marg_guel', 'Marguerite de Gueldre', 1436, 1486, 'Comtesse palatine de Simmern', 'Gueldre', 'f', flag='Maison de Gueldre : sans arbre')
S('wi.fred1_sim', 'wi.marg_guel')
W('wi.john1_sim', 'Jean Ier de Palatinat-Simmern', 1459, 1509, 'Comte palatin de Simmern', SIM, 'h')
kids(['wi.fred1_sim', 'wi.marg_guel'], ['wi.john1_sim'])
W('wi.jeanne_ns', 'Jeanne de Nassau-Sarrebruck', 1464, 1521, 'Comtesse palatine de Simmern', 'Nassau-Sarrebruck', 'f', flag='Maison de Nassau-Sarrebruck : sans arbre')
S('wi.john1_sim', 'wi.jeanne_ns')
W('wi.john2_sim', 'Jean II de Palatinat-Simmern', 1492, 1557, 'Comte palatin de Simmern', SIM, 'h')
kids(['wi.john1_sim', 'wi.jeanne_ns'], ['wi.john2_sim'])
W('wi.beatrix_bade', 'Béatrice de Bade', 1492, 1535, 'Comtesse palatine de Simmern', 'Zähringen (Bade)', 'f', flag='Maison de Bade (Zähringen) : sans arbre',
  approx='naissance 1492 : Stammliste ; la page de Jean II donne seulement la mort (1535)')
S('wi.john2_sim', 'wi.beatrix_bade')
W('wi.fred3', 'Frédéric III le Pieux', 1515, 1576, 'Électeur palatin (1559-1576)', SIM, 'h')
kids(['wi.john2_sim', 'wi.beatrix_bade'], ['wi.fred3'])
W('wi.marie_bk', 'Marie de Brandebourg-Kulmbach', 1519, 1567, 'Électrice palatine', 'Hohenzollern (Brandebourg-Kulmbach)', 'f', 'DE_HOH')
S('wi.fred3', 'wi.marie_bk')
W('wi.louis6', 'Louis VI du Palatinat', 1539, 1583, 'Électeur palatin (1576-1583)', SIM, 'h')
W('wi.jean_casimir', 'Jean-Casimir du Palatinat', 1543, 1592, 'Régent du Palatinat, chef du parti calviniste', SIM, 'h')
kids(['wi.fred3', 'wi.marie_bk'], ['wi.louis6', 'wi.jean_casimir', X('09b72e')])   # + Dorothée-Suzanne (déjà placée)
W('wi.elis_hesse2', 'Élisabeth de Hesse (1539-1582)', 1539, 1582, 'Électrice palatine', 'Hesse', 'f', flag='Maison de Hesse : sans arbre')
S('wi.louis6', 'wi.elis_hesse2')
W('wi.fred4', 'Frédéric IV du Palatinat', 1574, 1610, 'Électeur palatin (1583-1610)', SIM, 'h')
kids(['wi.louis6', 'wi.elis_hesse2'], ['wi.fred4'])
W('wi.louise_juliana', "Louise-Julienne d'Orange-Nassau", 1576, 1644, 'Électrice palatine', 'Orange-Nassau', 'f', 'NL_ORA',
  approx='dates 1576-1644 : Stammliste (la page de Frédéric IV ne les donne pas)')
S('wi.fred4', 'wi.louise_juliana')
FV = X('16a707')                                    # Frédéric V (déjà en base, arbre Stuart/Hanovre)
kids(['wi.fred4', 'wi.louise_juliana'], [FV])
kids(['wi.fred4', 'wi.louise_juliana'], [X('b9eb35')])
W('wi.charles_louis', 'Charles Ier Louis du Palatinat', 1617, 1680, 'Électeur palatin (1648-1680)', SIM, 'h')
kids([FV, X('db8342')], ['wi.charles_louis'])
W('wi.charlotte_hk', 'Charlotte de Hesse-Cassel', 1627, 1686, 'Électrice palatine', 'Hesse', 'f', flag='Maison de Hesse : sans arbre',
  approx='dates 1627-1686 : Stammliste')
S('wi.charles_louis', 'wi.charlotte_hk')
W('wi.charles2_pal', 'Charles II du Palatinat', 1651, 1685, 'Électeur palatin (1680-1685), dernier de la lignée de Simmern', SIM, 'h')
kids(['wi.charles_louis', 'wi.charlotte_hk'], ['wi.charles2_pal', X('8ab9ac')])      # + Liselotte (déjà placée)
W('wi.wilhelmine_dk', 'Wilhelmine-Ernestine de Danemark', 1650, 1706, 'Électrice palatine', 'Oldenbourg (Danemark)', 'f', 'DK_OLD',
  approx='dates 1650-1706 : Stammliste')
P(X('555a36dc'), 'wi.wilhelmine_dk')                                              # Frédéric III de Danemark
S('wi.charles2_pal', 'wi.wilhelmine_dk')

# Deux-Ponts : de Louis Ier à Wolfgang
W('wi.jeanne_croy', 'Jeanne de Croÿ', None, None, 'Comtesse palatine de Deux-Ponts', 'Croÿ', 'f', flag='Maison de Croÿ : sans arbre', approx='dates non données par la page de Louis Ier')
S('wi.louis1_zw', 'wi.jeanne_croy')
W('wi.alex_zw', 'Alexandre de Deux-Ponts', 1462, 1514, 'Comte palatin de Deux-Ponts', ZW, 'h')
kids(['wi.louis1_zw', 'wi.jeanne_croy'], ['wi.alex_zw'])
W('wi.marg_hoh', 'Marguerite de Hohenlohe-Neuenstein', 1480, 1522, 'Comtesse palatine de Deux-Ponts', 'Hohenlohe', 'f', flag='Maison de Hohenlohe : sans arbre',
  approx='dates 1480-1522 : page de Louis II')
S('wi.alex_zw', 'wi.marg_hoh')
W('wi.louis2_zw', 'Louis II de Deux-Ponts', 1502, 1532, 'Comte palatin de Deux-Ponts', ZW, 'h')
kids(['wi.alex_zw', 'wi.marg_hoh'], ['wi.louis2_zw'])
W('wi.elis_hesse1', 'Élisabeth de Hesse (1503-1563)', 1503, 1563, 'Comtesse palatine de Deux-Ponts', 'Hesse', 'f', flag='Maison de Hesse : sans arbre',
  approx='dates 1503-1563 : déduites de l\'adresse de la page de Louis II (le texte ne donne que le mariage de 1525)')
S('wi.louis2_zw', 'wi.elis_hesse1')
W('wi.wolfgang_zw', 'Wolfgang de Deux-Ponts', 1526, 1569, 'Comte palatin de Deux-Ponts', ZW, 'h')
kids(['wi.louis2_zw', 'wi.elis_hesse1'], ['wi.wolfgang_zw'])
W('wi.anne_hesse', 'Anne de Hesse (comtesse palatine de Deux-Ponts)', None, None, 'Comtesse palatine de Deux-Ponts', 'Hesse', 'f', flag='Maison de Hesse : sans arbre',
  approx='dates non données par la page de Wolfgang')
S('wi.wolfgang_zw', 'wi.anne_hesse')
W('wi.philippe_louis', 'Philippe-Louis de Neubourg', 1547, 1614, 'Comte palatin de Neubourg', 'Wittelsbach (Neubourg)', 'h')
W('wi.john1_zw', 'Jean Ier de Deux-Ponts', 1550, 1604, 'Comte palatin de Deux-Ponts', ZW, 'h')
W('wi.charles1_birk', 'Charles Ier de Deux-Ponts-Birkenfeld', 1560, 1600, 'Comte palatin de Deux-Ponts-Birkenfeld', 'Wittelsbach (Birkenfeld)', 'h')
kids(['wi.wolfgang_zw', 'wi.anne_hesse'], ['wi.philippe_louis', 'wi.john1_zw', 'wi.charles1_birk'])
W('wi.anne_cleves', 'Anne de Clèves-Juliers', 1552, 1632, 'Comtesse palatine de Neubourg', 'Clèves-Juliers', 'f', flag='Maison de Clèves-Juliers : sans arbre')
S('wi.philippe_louis', 'wi.anne_cleves')
W('wi.mag_jcb', 'Madeleine de Juliers-Clèves-Berg', None, None, 'Comtesse palatine de Deux-Ponts', 'Clèves-Juliers', 'f', flag='Maison de Clèves-Juliers : sans arbre',
  approx='dates non données par la page de Jean Ier')
S('wi.john1_zw', 'wi.mag_jcb')
kids(['wi.john1_zw', 'wi.mag_jcb'], [X('5feee6')])   # Jean Casimir de Kleebourg (déjà placé)
W('wi.dorothee_bl', 'Dorothée de Brunswick-Lunebourg (1570-1649)', 1570, 1649, 'Comtesse palatine de Deux-Ponts-Birkenfeld', 'Welf (Brunswick-Lunebourg)', 'f', 'DE_WEL')
S('wi.charles1_birk', 'wi.dorothee_bl')
W('wi.christian1_birk', 'Christian Ier de Birkenfeld-Bischwiller', 1598, 1654, 'Comte palatin de Birkenfeld-Bischwiller', 'Wittelsbach (Birkenfeld)', 'h')
kids(['wi.charles1_birk', 'wi.dorothee_bl'], ['wi.christian1_birk'])
W('wi.mag_cath', 'Madeleine-Catherine de Deux-Ponts', 1607, 1648, 'Comtesse palatine de Birkenfeld-Bischwiller', ZW, 'f')
kids(['wi.john1_zw', 'wi.mag_jcb'], ['wi.mag_cath'])
S('wi.christian1_birk', 'wi.mag_cath')
W('wi.christian2_birk', 'Christian II de Birkenfeld-Bischwiller', 1637, 1717, 'Comte palatin de Birkenfeld-Bischwiller', 'Wittelsbach (Birkenfeld)', 'h')
kids(['wi.christian1_birk', 'wi.mag_cath'], ['wi.christian2_birk'])
W('wi.kath_agathe', 'Catherine-Agathe de Ribeaupierre (Rappoltstein)', None, None, 'Comtesse palatine de Birkenfeld-Bischwiller', 'Ribeaupierre', 'f', flag='Maison de Ribeaupierre (Rappoltstein) : sans arbre',
  approx='dates non données par la page de Christian III')
S('wi.christian2_birk', 'wi.kath_agathe')
W('wi.christian3', 'Christian III de Deux-Ponts', 1674, 1735, 'Comte palatin de Deux-Ponts-Birkenfeld', ZW, 'h')
kids(['wi.christian2_birk', 'wi.kath_agathe'], ['wi.christian3'])
W('wi.caroline_ns', 'Caroline de Nassau-Sarrebruck', 1704, 1774, 'Comtesse palatine de Deux-Ponts', 'Nassau-Sarrebruck', 'f', flag='Maison de Nassau-Sarrebruck : sans arbre')
S('wi.christian3', 'wi.caroline_ns')
W('wi.fred_michel', 'Frédéric-Michel de Deux-Ponts-Birkenfeld', 1724, 1767, 'Comte palatin de Deux-Ponts-Birkenfeld', ZW, 'h')
kids(['wi.christian3', 'wi.caroline_ns'], ['wi.fred_michel'])

# ---------- Neubourg, Sulzbach ----------
NEU = 'Wittelsbach (Neubourg)'
SUL = 'Wittelsbach (Sulzbach)'
WW = X('fe58a9')                                   # Wolfgang-Guillaume de Neubourg (déjà placé)
kids(['wi.philippe_louis', 'wi.anne_cleves'], [WW])
W('wi.auguste_sulz', 'Auguste de Sulzbach', 1582, 1632, 'Comte palatin de Sulzbach', SUL, 'h')
kids(['wi.philippe_louis', 'wi.anne_cleves'], ['wi.auguste_sulz'])
W('wi.hedwige_gott', 'Hedwige de Holstein-Gottorp', 1603, 1657, 'Comtesse palatine de Sulzbach', 'Holstein-Gottorp', 'f', flag='Maison de Holstein-Gottorp : sans arbre')
S('wi.auguste_sulz', 'wi.hedwige_gott')
W('wi.christian_auguste', 'Christian-Auguste de Sulzbach', 1622, 1708, 'Comte palatin de Sulzbach', SUL, 'h')
kids(['wi.auguste_sulz', 'wi.hedwige_gott'], ['wi.christian_auguste'])
W('wi.amelie_ns', 'Amélie de Nassau-Siegen', None, None, 'Comtesse palatine de Sulzbach', 'Nassau-Siegen', 'f', flag='Maison de Nassau-Siegen : sans arbre',
  approx='dates non données par la page de Christian-Auguste')
S('wi.christian_auguste', 'wi.amelie_ns')
W('wi.theodore', 'Théodore-Eustache de Sulzbach', 1659, 1732, 'Comte palatin de Sulzbach', SUL, 'h')
kids(['wi.christian_auguste', 'wi.amelie_ns'], ['wi.theodore'])
W('wi.marie_eleonore_hr', 'Marie-Éléonore de Hesse-Rotenbourg', 1675, 1720, 'Comtesse palatine de Sulzbach', 'Hesse-Rotenbourg', 'f', flag='Maison de Hesse : sans arbre')
S('wi.theodore', 'wi.marie_eleonore_hr')
W('wi.joseph_charles', 'Joseph-Charles de Sulzbach', 1694, 1729, 'Prince héritier de Sulzbach', SUL, 'h')
W('wi.jean_christian', 'Jean-Christian de Sulzbach', 1700, 1733, 'Comte palatin de Sulzbach', SUL, 'h')
kids(['wi.theodore', 'wi.marie_eleonore_hr'], ['wi.joseph_charles', 'wi.jean_christian'])
# Neubourg : enfants de Philippe-Guillaume
PW, EA = X('1db34b'), X('9ff7e7')
W('wi.jean_guillaume', 'Jean-Guillaume de Neubourg', 1658, 1716, 'Électeur palatin (1690-1716)', NEU, 'h')
W('wi.charles3_philippe', 'Charles III Philippe du Palatinat', 1661, 1742, 'Électeur palatin (1716-1742)', NEU, 'h')
W('wi.marie_anne_neub', 'Marie-Anne de Neubourg', 1667, 1740, "Reine d'Espagne (épouse de Charles II)", NEU, 'f')
W('wi.dorothee_sophie', 'Dorothée-Sophie de Neubourg', 1670, 1748, 'Duchesse de Parme', NEU, 'f')
kids([PW, EA], ['wi.jean_guillaume', 'wi.charles3_philippe', 'wi.marie_anne_neub', 'wi.dorothee_sophie'])
S('wi.marie_anne_neub', X('787d4e3c'))             # Charles II d'Espagne
W('wi.louise_radziwill', 'Louise-Charlotte Radziwiłł', 1667, 1695, 'Électrice palatine', 'Radziwiłł', 'f', flag='Maison Radziwiłł (Pologne-Lituanie) : sans arbre',
  approx='dates 1667-1695 : Stammliste ; la page de Charles III Philippe ne les donne pas')
S('wi.charles3_philippe', 'wi.louise_radziwill')
W('wi.elis_aug_neub', 'Élisabeth-Auguste-Sophie de Neubourg', 1693, 1728, 'Princesse héritière de Sulzbach', NEU, 'f')
kids(['wi.charles3_philippe', 'wi.louise_radziwill'], ['wi.elis_aug_neub'])
S('wi.joseph_charles', 'wi.elis_aug_neub')
W('wi.elis_aug_sulz', 'Élisabeth-Auguste de Sulzbach', 1721, 1794, 'Électrice palatine et de Bavière', SUL, 'f')
W('wi.marie_francoise', 'Marie-Françoise de Sulzbach', 1724, 1794, 'Comtesse palatine de Deux-Ponts-Birkenfeld', SUL, 'f')
kids(['wi.joseph_charles', 'wi.elis_aug_neub'], ['wi.elis_aug_sulz', 'wi.marie_francoise'])
S('wi.fred_michel', 'wi.marie_francoise')
W('wi.marie_henriette', "Marie-Henriette de La Tour d'Auvergne", None, None, 'Comtesse palatine de Sulzbach', 'La Tour d\'Auvergne', 'f', flag='Maison de La Tour d\'Auvergne (France) : sans arbre',
  approx='dates non données par la page de Jean-Christian')
S('wi.jean_christian', 'wi.marie_henriette')
W('wi.charles_theodore', 'Charles-Théodore de Bavière', 1724, 1799, 'Électeur palatin (1742-1799), électeur de Bavière (1777-1799)', SUL, 'h')
kids(['wi.jean_christian', 'wi.marie_henriette'], ['wi.charles_theodore'])
S('wi.charles_theodore', 'wi.elis_aug_sulz')

# ---------- Max IV Joseph et ses enfants ----------
MAX4 = X('bb2cef')
W('wi.charles_auguste_zw', 'Charles II Auguste de Deux-Ponts', 1746, 1795, 'Duc de Deux-Ponts', ZW, 'h')
kids(['wi.fred_michel', 'wi.marie_francoise'], [MAX4, 'wi.charles_auguste_zw', X('7cfd74')])   # + Amélie de Deux-Ponts-Birkenfeld (déjà placée)
W('wi.augusta_wh', 'Auguste-Wilhelmine de Hesse-Darmstadt', None, 1796, 'Première épouse de Maximilien Ier Joseph de Bavière', 'Hesse', 'f', flag='Maison de Hesse : sans arbre',
  approx='naissance non donnée par la page de Maximilien Ier Joseph (mort 1796)')
W('wi.karoline_bade', 'Caroline de Bade (reine de Bavière)', None, None, 'Reine de Bavière, seconde épouse de Maximilien Ier Joseph', 'Zähringen (Bade)', 'f', flag='Maison de Bade (Zähringen) : sans arbre',
  approx='dates non données par la page de Maximilien Ier Joseph')
S(MAX4, 'wi.augusta_wh'); S(MAX4, 'wi.karoline_bade')
LOUIS1 = X('e62118')
kids([MAX4, 'wi.augusta_wh'], [LOUIS1, 'at.caroline_b'])                                   # Louis Ier, Caroline-Auguste
W('wi.karl_theodor_max', 'Charles-Théodore de Bavière (1795-1875)', 1795, 1875, 'Prince de Bavière', WIT, 'h')
kids([MAX4, 'wi.augusta_wh'], ['wi.karl_theodor_max'])
W('wi.marie_anne_saxe', 'Marie-Anne de Bavière (reine de Saxe)', 1805, 1877, 'Reine de Saxe', WIT, 'f')
kids([MAX4, 'wi.karoline_bade'], [X('60853d'), X('2b873f'), 'at.sophie_b', 'at.ludovika_b', 'wi.marie_anne_saxe'])
S('wi.marie_anne_saxe', X('0d0df7'))                                                   # Frédéric-Auguste II de Saxe
# Louis Ier : Otton de Grèce, Max II, Luitpold (mère)
THE = 'gr.therese'
kids([LOUIS1, THE], ['gr.otto'])                                                   # Othon Ier de Grèce
P(THE, X('21becf')); P(THE, X('946deb'))
W('wi.marie_prusse', 'Marie de Prusse (reine de Bavière)', None, None, 'Reine de Bavière', 'Hohenzollern', 'f', 'DE_HOH',
  approx='dates non données par la source consultée')
S(X('21becf'), 'wi.marie_prusse')
kids([X('21becf'), 'wi.marie_prusse'], [X('b37e10'), X('7eacf2')])                      # Louis II, Otton
W('wi.auguste_f', "Auguste-Ferdinande d'Autriche", 1825, 1864, 'Princesse de Bavière', 'Habsbourg-Toscane', 'f', 'DE_HAB')
S(X('946deb'), 'wi.auguste_f')
LUI3 = X('2ba636')
kids([X('946deb'), 'wi.auguste_f'], [LUI3])
for c, n, b, d, t, s_ in (('wi.leopold_b', 'Léopold de Bavière', 1846, 1930, 'Prince de Bavière, maréchal', 'h'),
                          ('wi.therese_b', 'Thérèse de Bavière', 1850, 1925, 'Princesse de Bavière, exploratrice et écrivaine', 'f'),
                          ('wi.arnulf', 'Arnulf de Bavière', 1852, 1907, 'Prince de Bavière', 'h')):
    W(c, n, b, d, t, WIT, s_)
    kids([X('946deb'), 'wi.auguste_f'], [c])
W('wi.marie_therese_este', "Marie-Thérèse d'Autriche-Este", 1849, 1919, 'Reine de Bavière', 'Autriche-Este', 'f', flag='Maison d\'Autriche-Este : sans arbre')
S(LUI3, 'wi.marie_therese_este')
W('wi.rupprecht', 'Rupprecht de Bavière', 1869, 1955, 'Prince héritier de Bavière, maréchal', WIT, 'h')
kids([LUI3, 'wi.marie_therese_este'], ['wi.rupprecht'])
# Marie-Gabrielle en Bavière et Antonia de Luxembourg
MAXB = 'at.max_bav'; LOUISE = 'at.ludovika_b'
W('wi.karl_theodor_b', 'Charles-Théodore en Bavière', 1839, 1909, 'Duc en Bavière, ophtalmologue', WIT, 'h')
kids([MAXB, LOUISE], ['wi.karl_theodor_b'])
W('wi.maria_jose', 'Marie-Josèphe de Portugal (duchesse en Bavière)', 1857, 1943, 'Duchesse en Bavière', 'Bragance (Portugal)', 'f', flag='Maison de Bragance (Portugal) : arbre à créer avec le Portugal',
  approx='dates 1857-1943 : page de Charles-Théodore en Bavière')
S('wi.karl_theodor_b', 'wi.maria_jose')
W('wi.marie_gabrielle', 'Marie-Gabrielle en Bavière', 1878, 1912, 'Princesse héritière de Bavière', WIT, 'f')
kids(['wi.karl_theodor_b', 'wi.maria_jose'], ['wi.marie_gabrielle'])
S('wi.rupprecht', 'wi.marie_gabrielle')
BEL = X('faf70fc6')                                                                    # Élisabeth en Bavière, reine des Belges (déjà en base)
kids(['wi.karl_theodor_b', 'wi.maria_jose'], [BEL])
W('wi.antonia_lux', 'Antonia de Luxembourg', 1899, 1954, 'Princesse héritière de Bavière', 'Nassau-Weilburg', 'f', 'LU_NAS')
kids(['lu.wilhelm4', 'lu.marie_anne'], ['wi.antonia_lux'])
S('wi.rupprecht', 'wi.antonia_lux')
W('wi.albrecht', 'Albrecht de Bavière', 1905, 1996, 'Duc de Bavière, chef de la maison de Wittelsbach', WIT, 'h')
kids(['wi.rupprecht', 'wi.marie_gabrielle'], ['wi.albrecht'])
W('wi.draskovich', 'Maria Draskovich de Trakostjan', 1903, 1969, 'Duchesse de Bavière', 'Draskovich (Croatie)', 'f', flag='Maison Draskovich (Croatie) : sans arbre')
S('wi.albrecht', 'wi.draskovich')
W('wi.franz_b', 'François de Bavière', 1933, None, 'Duc de Bavière, chef de la maison de Wittelsbach', WIT, 'h')
W('wi.max_b', 'Max, duc en Bavière', 1937, None, 'Duc en Bavière', WIT, 'h')
kids(['wi.albrecht', 'wi.draskovich'], ['wi.franz_b', 'wi.max_b'])
W('wi.douglas', 'Élisabeth Douglas', None, None, 'Duchesse en Bavière', 'Douglas', 'f', flag='Famille Douglas (Suède) : sans arbre', approx='dates non données par la page de Max')
S('wi.max_b', 'wi.douglas')
kids(['wi.max_b', 'wi.douglas'], ['li.sophie'])                                         # Sophie (princesse héréditaire de Liechtenstein)

# ---------- liens manquants entre membres déjà placés ----------
P(X('c0c58f'), X('a19b2e')); P(X('28ebec'), X('a19b2e'))            # Rupert Ier le Roux : fils de Rodolphe Ier et Mathilde de Nassau

if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
