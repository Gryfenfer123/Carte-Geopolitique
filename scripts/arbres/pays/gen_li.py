import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(54, "Liechtenstein — princes de Liechtenstein")
g.notes = [
    "Crée sous Liechtenstein > Dynastie : Liechtenstein (Karl Ier -> Hans-Adam II -> Alois et ses enfants).",
    "Décision à valider : la maison est d'origine autrichienne ; faute d'arbre autrichien pour elle, toute la lignée princière (depuis Karl Ier, 1608) est dans l'arbre liechtensteinois, bien que la principauté du Liechtenstein n'existe que depuis 1719.",
    "Les lignes collatérales (Hartmann III, Philipp Erasme, Emmanuel) ne sont incluses que pour relier les princes entre eux ; leurs dates et filiations sont de ma connaissance générale et marquées « non revérifiées ».",
    "Anne-Marie (1699-1753) : la page la dit « ruling in her own right » ; non marquée comme dirigeante (à trancher).",
    "Épouses sans arbre signalées ; Sophie de Bavière est créée dans l'arbre Wittelsbach, Margaretha de Luxembourg (v52) est reliée à Nikolaus.",
    "Prérequis : v53 exécuté.",
]
g.tree('LI_LIE', 'LIE', 'Liechtenstein')
g.tree('DE_WIT', 'DEU', 'Wittelsbach', entry='e76d91a3-1b9c-4703-85b3-9f711b6d6199')
g.tree('LU_NAS', 'LUX', 'Nassau-Weilburg')
FB = {k: v for k, v in {}.items()}
P, S = g.par, g.sp
LI = 'Liechtenstein'
A = 'dates non revérifiées sur la page'
FBc = {'li.anna_s': 1570, 'li.johanna': 1615, 'li.erdmuthe': 1665, 'li.eleonore': 1660, 'li.leopoldine': 1733, 'li.karoline': 1768,
       'li.josepha': 1776, 'li.franziska': 1813, 'li.elisabeth_g': 1875, 'li.elisabeth_a': 1878, 'li.georgina': 1921, 'li.marie_k': 1940,
       'li.henriette': 1843, 'li.sophie': 1967, 'li.maria_oet': 1695, 'li.harrach': 1725}
Gen.FIXB = {uid('member:' + c): y for c, y in FBc.items()}
def M(c, n, b, d, t, s, ld=False, ap=None, dyn=LI, fl=None, tree='LI_LIE'):
    g.m(c, n, b, d, t, dyn, tree, s, ld, flag=fl, approx=ap)
def W(c, n, b, d, org, ap=None):
    M(c, n, b, d, 'Princesse de Liechtenstein', 'f', ap=ap, dyn=org, fl=f'Maison/famille {org} : sans arbre')
M('li.karl1', 'Karl Ier de Liechtenstein', 1569, 1627, 'Prince de Liechtenstein (1608)', 'h', True)
W('li.anna_s', 'Anna Maria Šemberová de Boskovice', None, None, 'Boskovice (Moravie)', 'dates non renseignées')
S('li.karl1', 'li.anna_s')
M('li.karl_e', 'Charles Eusèbe de Liechtenstein', 1611, 1684, 'Prince de Liechtenstein (1627-1684)', 'h', True)
M('li.hartmann3', 'Hartmann III de Liechtenstein', 1613, 1686, 'Prince', 'h', ap=A)
for c in ('li.karl_e', 'li.hartmann3'):
    P('li.karl1', c); P('li.anna_s', c)
W('li.johanna', 'Jeanne-Béatrice de Dietrichstein', None, None, 'Dietrichstein', 'dates non renseignées')
S('li.karl_e', 'li.johanna')
M('li.hans_adam1', 'Hans-Adam Ier de Liechtenstein', 1662, 1712, 'Prince de Liechtenstein (1684-1712), acquiert Schellenberg et Vaduz', 'h', True)
P('li.karl_e', 'li.hans_adam1'); P('li.johanna', 'li.hans_adam1')
W('li.erdmuthe', 'Erdmuthe-Marie-Thérèse de Dietrichstein', None, None, 'Dietrichstein', 'dates non renseignées')
S('li.hans_adam1', 'li.erdmuthe')
M('li.anton_f', 'Antoine-Florian de Liechtenstein', 1656, 1721, 'Prince de Liechtenstein (1718-1721)', 'h', True)
P('li.hartmann3', 'li.anton_f')
W('li.eleonore', 'Éléonore-Barbara de Thun-Hohenstein', None, None, 'Thun-Hohenstein', 'dates non renseignées')
S('li.anton_f', 'li.eleonore')
M('li.philipp_e', 'Philippe-Érasme de Liechtenstein', 1664, 1704, 'Prince', 'h', ap=A)
P('li.hartmann3', 'li.philipp_e')
M('li.joseph_w', 'Joseph-Venceslas Ier de Liechtenstein', 1696, 1772, 'Prince de Liechtenstein (1712-1718, 1748-1772)', 'h', True)
P('li.philipp_e', 'li.joseph_w')
M('li.joseph_ja', 'Joseph-Jean-Adam de Liechtenstein', 1690, 1732, 'Prince de Liechtenstein (1721-1732)', 'h', True)
M('li.anna_maria', 'Anne-Marie de Liechtenstein', 1699, 1753, 'Princesse, régente (selon la page : « ruled in her own right »)', 'f')
for c in ('li.joseph_ja', 'li.anna_maria'):
    P('li.anton_f', c); P('li.eleonore', c)
S('li.joseph_w', 'li.anna_maria')
W('li.maria_oet', 'Marie-Anne d\'Oettingen-Spielberg', None, None, 'Oettingen-Spielberg', 'dates non renseignées')
S('li.joseph_ja', 'li.maria_oet')
M('li.johann_nk', 'Jean-Népomucène-Charles de Liechtenstein', 1724, 1748, 'Prince de Liechtenstein (1732-1748)', 'h', True)
P('li.joseph_ja', 'li.johann_nk'); P('li.maria_oet', 'li.johann_nk')
W('li.harrach', 'Marie-Josepha de Harrach', None, None, 'Harrach', 'dates non renseignées')
S('li.johann_nk', 'li.harrach')
M('li.emanuel', 'Emmanuel de Liechtenstein', 1700, 1771, 'Prince, père de François-Joseph Ier', 'h', ap=A)
P('li.philipp_e', 'li.emanuel')
M('li.franz_j1', 'François-Joseph Ier de Liechtenstein', 1726, 1781, 'Prince de Liechtenstein (1772-1781)', 'h', True)
P('li.emanuel', 'li.franz_j1')
W('li.leopoldine', 'Léopoldine de Sternberg', None, None, 'Sternberg', 'dates non renseignées')
S('li.franz_j1', 'li.leopoldine')
M('li.aloys1', 'Aloys Ier de Liechtenstein', 1759, 1805, 'Prince de Liechtenstein (1781-1805)', 'h', True)
M('li.johann1', 'Jean Ier Joseph de Liechtenstein', 1760, 1836, 'Prince de Liechtenstein (1805-1836)', 'h', True)
for c in ('li.aloys1', 'li.johann1'):
    P('li.franz_j1', c); P('li.leopoldine', c)
W('li.karoline', 'Caroline de Manderscheid-Blankenheim', None, None, 'Manderscheid-Blankenheim', 'dates non renseignées')
S('li.aloys1', 'li.karoline')
W('li.josepha', 'Josépha de Fürstenberg-Weitra', None, None, 'Fürstenberg-Weitra', 'dates non renseignées')
S('li.johann1', 'li.josepha')
M('li.aloys2', 'Aloys II de Liechtenstein', 1796, 1858, 'Prince de Liechtenstein (1836-1858)', 'h', True)
P('li.johann1', 'li.aloys2'); P('li.josepha', 'li.aloys2')
W('li.franziska', 'Françoise Kinsky de Wchinitz et Tettau', 1813, 1881, 'Kinsky (Bohême)')
S('li.aloys2', 'li.franziska')
M('li.johann2', 'Jean II de Liechtenstein', 1840, 1929, 'Prince de Liechtenstein (1858-1929), non marié', 'h', True)
M('li.franz1', 'François Ier de Liechtenstein', 1853, 1938, 'Prince de Liechtenstein (1929-1938)', 'h', True)
M('li.henriette', 'Henriette de Liechtenstein', 1843, 1931, 'Princesse, épouse d\'Alfred', 'f', ap=A)
for c in ('li.johann2', 'li.franz1', 'li.henriette'):
    P('li.aloys2', c); P('li.franziska', c)
W('li.elisabeth_g', 'Élisabeth von Gutmann', None, None, 'Gutmann (Autriche)', 'dates non renseignées')
S('li.franz1', 'li.elisabeth_g')
M('li.alfred', 'Alfred de Liechtenstein', 1842, 1907, 'Prince, époux de sa cousine Henriette', 'h')
S('li.alfred', 'li.henriette')
M('li.alois_p', 'Alois de Liechtenstein', 1869, 1955, 'Prince, père de François-Joseph II', 'h', ap=A)
P('li.alfred', 'li.alois_p'); P('li.henriette', 'li.alois_p')
W('li.elisabeth_a', 'Élisabeth-Amélie d\'Autriche', 1878, 1960, 'Habsbourg-Lorraine (archiduchesse)', 'dates 1878-1960 non données par la page, non revérifiées')
S('li.alois_p', 'li.elisabeth_a')
M('li.franz_j2', 'François-Joseph II de Liechtenstein', 1906, 1989, 'Prince de Liechtenstein (1938-1989)', 'h', True)
P('li.alois_p', 'li.franz_j2'); P('li.elisabeth_a', 'li.franz_j2')
W('li.georgina', 'Georgina von Wilczek', 1921, 1989, 'Wilczek (Autriche)')
S('li.franz_j2', 'li.georgina')
M('li.hans_adam2', 'Hans-Adam II de Liechtenstein', 1945, None, 'Prince de Liechtenstein (depuis 1989)', 'h', True)
M('li.philipp', 'Philipp de Liechtenstein', 1946, None, 'Prince', 'h')
M('li.nikolaus', 'Nikolaus de Liechtenstein', 1947, None, 'Prince', 'h')
M('li.nora', 'Norberta (Nora) de Liechtenstein', 1950, None, 'Princesse', 'f')
M('li.franz_w', 'François-Josef-Venceslas de Liechtenstein', 1962, 1991, 'Prince', 'h')
for c in ('li.hans_adam2', 'li.philipp', 'li.nikolaus', 'li.nora', 'li.franz_w'):
    P('li.franz_j2', c); P('li.georgina', c)
S('li.nikolaus', 'lu.margaretha')
W('li.marie_k', 'Marie Kinsky de Wchinitz et Tettau', 1940, 2021, 'Kinsky (Bohême)', 'naissance 1940 déduite (morte à 81 ans le 21 août 2021)')
S('li.hans_adam2', 'li.marie_k')
M('li.alois', 'Alois de Liechtenstein (prince héréditaire)', 1968, None, 'Prince héréditaire, régent depuis 2004', 'h', True)
M('li.maximilian', 'Maximilien de Liechtenstein', 1969, None, 'Prince', 'h')
M('li.constantin', 'Constantin de Liechtenstein', 1972, 2023, 'Prince', 'h')
M('li.tatjana', 'Tatjana de Liechtenstein', 1973, None, 'Princesse', 'f')
for c in ('li.alois', 'li.maximilian', 'li.constantin', 'li.tatjana'):
    P('li.hans_adam2', c); P('li.marie_k', c)
g.m('li.sophie', 'Sophie en Bavière (princesse héréditaire de Liechtenstein)', 1967, None, 'Princesse héréditaire de Liechtenstein', 'Wittelsbach', 'DE_WIT', 'f')
S('li.alois', 'li.sophie')
for c, n, b, s in (('li.joseph_wm', 'Joseph-Venceslas de Liechtenstein', 1995, 'h'), ('li.marie_c', 'Marie-Caroline de Liechtenstein', 1996, 'f'), ('li.georg', 'Georges de Liechtenstein', 1999, 'h'), ('li.nikolaus2', 'Nicolas de Liechtenstein', 2000, 'h')):
    M(c, n, b, None, 'Prince(sse) de Liechtenstein', s)
    P('li.alois', c); P('li.sophie', c)
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
