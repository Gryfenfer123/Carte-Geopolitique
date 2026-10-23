import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(74, "Danemark — Oldenbourg de Frédéric IV à Christian VIII, et Glücksbourg jusqu'à Frédéric X")
g.notes = [
    "Complète les arbres Oldenbourg et Glücksbourg (rien n'est supprimé).",
    "Sources : Wikipédia en anglais (Frédéric IV, Christian VI, Frédéric V, Christian VII, Frédéric VI, Christian VIII, Frédéric VII, Christian IX, Frédéric VIII, Christian X, Frédéric IX, Marguerite II, Frédéric X). Dates non données = vides ; dates connues ailleurs : notées.",
    "Princesses britanniques (Louise, Caroline-Mathilde, Maud) créées dans les arbres Stuart/Hanovre et Windsor ; Sophie-Madeleine de Brandebourg-Kulmbach dans Hohenzollern ; Juliana-Maria dans Welf. Épouses de familles sans arbre (Mecklembourg, Hesse-Cassel, Reventlow, Vieregg, Augustenbourg, Laborde de Monpezat, Donaldson) : signalées.",
    "Non fait : enfants naturels, mariages morganatiques de Frédéric VII, enfants et épouses de Joachim.",
]
g.tree('DK_OLD', 'DNK', "Maison d'Oldenbourg")
g.tree('DK_GLU', 'DNK', 'Schleswig-Holstein-Glücksbourg')
g.tree('DE_HOH', 'DEU', 'Hohenzollern')
g.tree('DE_WEL', 'DEU', 'Welf', entry=E('db5ef554'))
g.tree('GB_HAN', 'GBR', 'Maison Stuart et Maison de Hanovre', entry=E('a874f93b'))
g.tree('GB_WIN', 'GBR', 'Maison de Saxe-Cobourg et Gotha et Maison Windsor', entry=E('eb82350b'))
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
def M(code, name, b, d, title, g_, tree='DK_OLD', leader=False, approx=None, dyn='Oldenbourg', flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, tree='DK_OLD', approx=None):
    return M(code, name, b, d, title, 'f', tree, dyn=house, approx=approx, flag='Maison %s : sans arbre' % house)

C5 = R('9af9963d')
W('dn.charlotte_amelie', 'Charlotte-Amélie de Hesse-Cassel', 1650, 1714, 'Reine de Danemark et de Norvège', 'Hesse-Cassel', approx='dates connues par ailleurs')
S(C5, 'dn.charlotte_amelie')
M('dn.fred4', 'Frédéric IV', 1671, 1730, 'Roi de Danemark et de Norvège', 'h', leader=True)
kids([C5, 'dn.charlotte_amelie'], ['dn.fred4'])
W('dn.louise_mg', 'Louise de Mecklembourg-Güstrow', None, 1721, 'Reine de Danemark', 'Mecklembourg-Güstrow', approx='naissance non donnée')
W('dn.vieregg', 'Élisabeth-Hélène von Vieregg', None, 1704, 'Reine consort (mariage bigame)', 'von Vieregg', approx='naissance non donnée')
W('dn.reventlow', 'Anne-Sophie Reventlow', None, None, 'Reine de Danemark', 'Reventlow', approx='dates non données par la page')
S('dn.fred4', 'dn.louise_mg'); S('dn.fred4', 'dn.vieregg'); S('dn.fred4', 'dn.reventlow')
M('dn.christian6', 'Christian VI', 1699, 1746, 'Roi de Danemark et de Norvège', 'h', leader=True)
M('dn.charlotte_am2', 'Charlotte-Amélie de Danemark (1706-1782)', 1706, 1782, 'Princesse de Danemark', 'f')
kids(['dn.fred4', 'dn.louise_mg'], ['dn.christian6', 'dn.charlotte_am2'])
M('dn.sophie_mag_bk', 'Sophie-Madeleine de Brandebourg-Kulmbach', 1700, 1770, 'Reine de Danemark', 'f', 'DE_HOH', dyn='Hohenzollern (Brandebourg-Kulmbach)')
S('dn.christian6', 'dn.sophie_mag_bk')
M('dn.fred5', 'Frédéric V', 1723, 1766, 'Roi de Danemark et de Norvège', 'h', leader=True)
kids(['dn.christian6', 'dn.sophie_mag_bk'], ['dn.fred5'])
M('dn.louise_gb', 'Louise de Grande-Bretagne', 1724, 1751, 'Reine de Danemark', 'f', 'GB_HAN', dyn='Hanovre', approx='naissance connue par ailleurs, mort 1751 donnée par la page')
kids([R('5c634b84'), R('25c2cc3f')], ['dn.louise_gb'])
S('dn.fred5', 'dn.louise_gb')
M('dn.juliana_maria', 'Julienne-Marie de Brunswick-Wolfenbüttel', 1729, 1796, 'Reine de Danemark', 'f', 'DE_WEL', dyn='Welf (Brunswick-Wolfenbüttel)')
kids([R('77d734e9'), R('5ddf7e11')], ['dn.juliana_maria'])
S('dn.fred5', 'dn.juliana_maria')
M('dn.wilhelmina_c', 'Wilhelmine-Caroline de Danemark', 1747, 1820, 'Électrice de Hesse', 'f')
M('dn.christian7', 'Christian VII', 1749, 1808, 'Roi de Danemark et de Norvège', 'h', leader=True)
M('dn.louise_dk', 'Louise de Danemark (1750-1831)', 1750, 1831, 'Landgravine de Hesse-Cassel', 'f')
kids(['dn.fred5', 'dn.louise_gb'], ['dn.wilhelmina_c', 'dn.christian7', 'dn.louise_dk', R('59349703')])   # + Sophie-Madeleine
M('dn.fred_hered', "Frédéric, prince héréditaire de Danemark", 1753, 1805, 'Prince héréditaire', 'h')
kids(['dn.fred5', 'dn.juliana_maria'], ['dn.fred_hered'])
M('dn.caroline_mat', 'Caroline-Mathilde de Grande-Bretagne', 1751, 1775, 'Reine de Danemark', 'f', 'GB_HAN', dyn='Hanovre', approx='naissance 1751 déduite de « morte à 23 ans » ; connue par ailleurs')
kids([R('4891ab20'), R('9b566a15')], ['dn.caroline_mat'])
S('dn.christian7', 'dn.caroline_mat')
M('dn.fred6', 'Frédéric VI', 1768, 1839, 'Roi de Danemark et de Norvège', 'h', leader=True)
M('dn.louise_aug', 'Louise-Augusta de Danemark', 1771, 1843, 'Duchesse de Schleswig-Holstein-Augustenbourg', 'f', approx='dates connues par ailleurs ; probablement fille de Struensee selon la page')
kids(['dn.christian7', 'dn.caroline_mat'], ['dn.fred6', 'dn.louise_aug'])
W('dn.sophie_mecl', 'Sophie-Frédérique de Mecklembourg-Schwerin', 1758, 1794, 'Princesse héréditaire de Danemark', 'Mecklembourg-Schwerin', approx='dates connues par ailleurs')
S('dn.fred_hered', 'dn.sophie_mecl')
M('dn.christian8', 'Christian VIII', 1786, 1848, 'Roi de Danemark (et de Norvège en 1814)', 'h', leader=True)
kids(['dn.fred_hered', 'dn.sophie_mecl'], ['dn.christian8'])
W('dn.marie_sophie_h', 'Marie-Sophie de Hesse-Cassel', 1767, 1852, 'Reine de Danemark', 'Hesse-Cassel', approx='dates connues par ailleurs')
S('dn.fred6', 'dn.marie_sophie_h')
M('dn.caroline_f6', 'Caroline de Danemark (1793-1881)', 1793, 1881, 'Princesse de Danemark', 'f')
M('dn.vilhelmine', 'Vilhelmine-Marie de Danemark', 1808, 1891, 'Princesse de Danemark', 'f')
kids(['dn.fred6', 'dn.marie_sophie_h'], ['dn.caroline_f6', 'dn.vilhelmine'])
W('dn.charlotte_ms', 'Charlotte-Frédérique de Mecklembourg-Schwerin', 1784, 1840, 'Princesse de Danemark', 'Mecklembourg-Schwerin', approx='dates connues par ailleurs')
W('dn.caroline_amalie', "Caroline-Amélie d'Augustenbourg", 1796, 1881, 'Reine de Danemark', 'Augustenbourg')
S('dn.christian8', 'dn.charlotte_ms'); S('dn.christian8', 'dn.caroline_amalie')
M('dn.fred7', 'Frédéric VII', 1808, 1863, 'Dernier roi de la ligne principale des Oldenbourg', 'h', leader=True)
kids(['dn.christian8', 'dn.charlotte_ms'], ['dn.fred7'])
S('dn.fred7', 'dn.vilhelmine')
# Glücksbourg
T = 'DK_GLU'
M('dn.fw_glu', 'Frédéric-Guillaume de Schleswig-Holstein-Sonderbourg-Glücksbourg', 1785, 1831, 'Duc de Glücksbourg', 'h', T, dyn='Glücksbourg', approx='dates connues par ailleurs, non données par la page de Christian IX')
W('dn.louise_caroline_h', 'Louise-Caroline de Hesse-Cassel', 1789, 1867, 'Duchesse de Glücksbourg', 'Hesse-Cassel', T, approx='dates connues par ailleurs')
S('dn.fw_glu', 'dn.louise_caroline_h')
kids(['dn.fw_glu', 'dn.louise_caroline_h'], [R('fd479735')])
M('dn.valdemar', 'Valdemar de Danemark', 1858, 1939, 'Prince de Danemark', 'h', T, dyn='Glücksbourg', approx='mort connue par ailleurs')
P(R('fd479735'), 'dn.valdemar'); P(R('7d1a58e1'), 'dn.valdemar')
F8 = R('8b34e776')
S(F8, 'bn.louise_se')
P('bn.louise_se', R('37776074'))
M('dn.haakon7', 'Haakon VII de Norvège', 1872, 1957, 'Roi de Norvège', 'h', T, True, dyn='Glücksbourg', approx='dates données par la page de Frédéric VIII (1872-1957)')
M('dn.louise_f8', 'Louise de Danemark (1875-1906)', 1875, 1906, 'Princesse de Schaumburg-Lippe', 'f', T, dyn='Glücksbourg')
M('dn.harald', 'Harald de Danemark', 1876, 1949, 'Prince de Danemark', 'h', T, dyn='Glücksbourg')
M('dn.thyra_f8', 'Thyra de Danemark (1880-1945)', 1880, 1945, 'Princesse de Danemark', 'f', T, dyn='Glücksbourg')
M('dn.gustav', 'Gustave de Danemark', 1887, 1944, 'Prince de Danemark', 'h', T, dyn='Glücksbourg')
M('dn.dagmar_f8', 'Dagmar de Danemark (1890-1961)', 1890, 1961, 'Princesse de Danemark', 'f', T, dyn='Glücksbourg')
kids([F8, 'bn.louise_se'], ['dn.haakon7', 'dn.louise_f8', 'dn.harald', 'dn.thyra_f8', 'dn.gustav', 'dn.dagmar_f8'])
M('dn.maud', 'Maud de Galles', 1869, 1938, 'Reine de Norvège', 'f', 'GB_WIN', dyn='Saxe-Cobourg et Gotha', approx='dates connues par ailleurs')
kids([R('49a669a2'), R('a43d1cb9')], ['dn.maud'])
S('dn.haakon7', 'dn.maud')
W('dn.alexandrine', 'Alexandrine de Mecklembourg-Schwerin', 1879, 1952, 'Reine de Danemark', 'Mecklembourg-Schwerin', T, approx='dates connues par ailleurs')
S(R('37776074'), 'dn.alexandrine')
M('dn.knud', 'Knud de Danemark', 1900, 1976, 'Prince héréditaire', 'h', T, dyn='Glücksbourg')
kids([R('37776074'), 'dn.alexandrine'], [R('86d4566b'), 'dn.knud'])
M('dn.margrethe', 'Marguerite II de Danemark', 1940, None, 'Reine de Danemark', 'f', T, True, dyn='Glücksbourg')
M('dn.benedikte', 'Bénédicte de Danemark', 1944, None, 'Princesse de Danemark', 'f', T, dyn='Glücksbourg')
kids([R('86d4566b'), R('a78782ce')], ['dn.margrethe', 'dn.benedikte'])
W('dn.henrik', 'Henri de Laborde de Monpezat', 1934, 2018, 'Prince consort du Danemark', 'Laborde de Monpezat', T, approx='dates connues par ailleurs (mort 2018 donnée par la page)')
S('dn.margrethe', 'dn.henrik')
M('dn.fred10', 'Frédéric X', 1968, None, 'Roi de Danemark', 'h', T, True, dyn='Glücksbourg')
M('dn.joachim', 'Joachim de Danemark', 1969, None, 'Prince de Danemark', 'h', T, dyn='Glücksbourg')
kids(['dn.margrethe', 'dn.henrik'], ['dn.fred10', 'dn.joachim'])
W('dn.mary', 'Mary Donaldson', 1972, None, 'Reine de Danemark', 'Donaldson', T, approx='naissance connue par ailleurs')
S('dn.fred10', 'dn.mary')
for c, n, b, gg in [('dn.christian_p', 'Christian de Danemark', 2005, 'h'), ('dn.isabella', 'Isabella de Danemark', 2007, 'f'), ('dn.vincent', 'Vincent de Danemark', 2011, 'h'), ('dn.josephine', 'Joséphine de Danemark', 2011, 'f')]:
    M(c, n, b, None, 'Prince / princesse de Danemark', gg, T, dyn='Glücksbourg')
kids(['dn.fred10', 'dn.mary'], ['dn.christian_p', 'dn.isabella', 'dn.vincent', 'dn.josephine'])
for c in [F8, R('7d1a58e1')]: pass
g.reposition = {'DK_OLD', 'DK_GLU'}
g.write()
