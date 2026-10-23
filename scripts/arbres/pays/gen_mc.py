import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(53, "Monaco — Grimaldi")
g.notes = [
    "Crée sous Monaco > Dynastie : Grimaldi (Honoré II -> Albert II et ses enfants). La branche génoise plus ancienne (Francesco Grimaldi 1297, Rainier Ier, Lambert) n'est pas incluse : la page Wikipédia ne donne pas de dates ni de liens.",
    "Épouses avant Honoré III non saisies faute de source consultée ; elles sont à ajouter si Martin le souhaite.",
    "Honoré V : épouse non précisée par la page, laissée vide.",
    "Florestine de Monaco et son mari Guillaume d'Urach sont ajoutés (leur fils Mindaugas II servira pour la Lituanie).",
    "Naissance de Charlène Wittstock (1978) : non donnée par la page, de mémoire, à vérifier.",
    "Prérequis : v52 exécuté.",
]
g.tree('MC_GRI', 'MCO', 'Grimaldi')
FB = {'mc.hercule': 1623, 'mc.catherine_b': 1737, 'mc.aumont': 1759, 'mc.gibert': 1793, 'mc.urach': 1810, 'mc.polignac': 1895,
      'mc.mary': 1850, 'mc.alice': 1858, 'mc.antoinette': 1828, 'mc.grace': 1929, 'mc.charlene': 1978}
Gen.FIXB = {uid('member:' + c): y for c, y in FB.items()}
P, S = g.par, g.sp
GR = 'Grimaldi'
A = 'dates non revérifiées sur la page'
def M(c, n, b, d, t, s, ld=False, ap=None, dyn=GR, fl=None):
    g.m(c, n, b, d, t, dyn, 'MC_GRI', s, ld, flag=fl, approx=ap)
M('mc.honore2', 'Honoré II de Monaco', 1597, 1662, 'Premier prince de Monaco (seigneur en 1604, prince en 1633)', 'h', True)
M('mc.hercule', 'Hercule Grimaldi (marquis des Baux)', 1623, 1651, 'Marquis des Baux, héritier', 'h', ap=A)
M('mc.louis1', 'Louis Ier de Monaco', 1642, 1701, 'Prince de Monaco (1662-1701)', 'h', True, A)
M('mc.antoine', 'Antoine Ier de Monaco', 1661, 1731, 'Prince de Monaco (1701-1731)', 'h', True, A)
M('mc.louise', 'Louise Hippolyte de Monaco', 1697, 1731, 'Princesse de Monaco (1731)', 'f', True, A)
M('mc.jacques1', 'Jacques Ier de Monaco (Goyon de Matignon)', 1689, 1751, 'Prince de Monaco (1731-1733), époux de Louise Hippolyte', 'h', True, A, dyn='Goyon de Matignon (puis Grimaldi)')
P('mc.honore2', 'mc.hercule'); P('mc.hercule', 'mc.louis1'); P('mc.louis1', 'mc.antoine'); P('mc.antoine', 'mc.louise')
S('mc.louise', 'mc.jacques1')
M('mc.honore3', 'Honoré III de Monaco', 1720, 1795, 'Prince de Monaco (1733-1793)', 'h', True)
P('mc.jacques1', 'mc.honore3'); P('mc.louise', 'mc.honore3')
M('mc.catherine_b', 'Maria Caterina Brignole', None, 1813, 'Princesse de Monaco', 'f', ap='naissance non renseignée ; mariage 1751 ou 1757 selon la page', dyn='Brignole (Gênes)', fl='Famille Brignole (Gênes) : sans arbre')
S('mc.honore3', 'mc.catherine_b')
M('mc.honore4', 'Honoré IV de Monaco', 1758, 1819, 'Prince de Monaco (1814-1819)', 'h', True)
P('mc.honore3', 'mc.honore4'); P('mc.catherine_b', 'mc.honore4')
M('mc.aumont', 'Louise d\'Aumont (duchesse de Mazarin)', None, None, 'Princesse de Monaco, duchesse d\'Aumont et de Mazarin', 'f', ap='dates non renseignées ; divorcée en 1798', dyn='d\'Aumont', fl='Famille d\'Aumont (France) : sans arbre')
S('mc.honore4', 'mc.aumont')
M('mc.honore5', 'Honoré V de Monaco', 1778, 1841, 'Prince de Monaco (1819-1841)', 'h', True)
M('mc.florestan', 'Florestan Ier de Monaco', 1785, 1856, 'Prince de Monaco (1841-1856)', 'h', True)
for c in ('mc.honore5', 'mc.florestan'):
    P('mc.honore4', c); P('mc.aumont', c)
M('mc.gibert', 'Caroline Gibert de Lametz', None, None, 'Princesse de Monaco', 'f', ap='dates non renseignées', dyn='Gibert de Lametz (Champagne)', fl='Famille Gibert de Lametz (haute bourgeoisie champenoise) : sans arbre')
S('mc.florestan', 'mc.gibert')
M('mc.charles3', 'Charles III de Monaco', 1818, 1889, 'Prince de Monaco (1856-1889)', 'h', True)
M('mc.florestine', 'Florestine de Monaco (duchesse d\'Urach)', 1833, 1897, 'Princesse de Monaco, duchesse d\'Urach', 'f', ap='mort 1897 non donnée par la page')
for c in ('mc.charles3', 'mc.florestine'):
    P('mc.florestan', c); P('mc.gibert', c)
M('mc.urach', 'Guillaume d\'Urach (duc d\'Urach)', 1810, 1869, 'Duc d\'Urach', 'h', ap=A, dyn='Urach (Wurtemberg)', fl='Maison d\'Urach (Wurtemberg) : sans arbre')
S('mc.florestine', 'mc.urach')
M('mc.antoinette', 'Antoinette de Mérode', 1828, 1864, 'Princesse de Monaco', 'f', dyn='de Mérode (Belgique)', fl='Famille de Mérode (noblesse belge) : sans arbre')
S('mc.charles3', 'mc.antoinette')
M('mc.albert1', 'Albert Ier de Monaco', 1848, 1922, 'Prince de Monaco (1889-1922), océanographe', 'h', True)
P('mc.charles3', 'mc.albert1'); P('mc.antoinette', 'mc.albert1')
M('mc.mary', 'Lady Mary Victoria Hamilton', 1850, 1922, 'Princesse de Monaco (mariage annulé en 1880)', 'f', dyn='Hamilton (Royaume-Uni)', fl='Famille Hamilton (Royaume-Uni) : sans arbre')
M('mc.alice', 'Alice Heine', 1858, 1925, 'Princesse de Monaco', 'f', dyn='Heine (États-Unis)', fl='Famille Heine : sans arbre')
S('mc.albert1', 'mc.mary'); S('mc.albert1', 'mc.alice')
M('mc.louis2', 'Louis II de Monaco', 1870, 1949, 'Prince de Monaco (1922-1949)', 'h', True)
P('mc.albert1', 'mc.louis2'); P('mc.mary', 'mc.louis2')
M('mc.ghislaine', 'Ghislaine Dommanget', 1900, 1991, 'Princesse de Monaco (épouse de Louis II, 1946)', 'f', dyn='Dommanget', fl='Famille Dommanget : sans arbre')
S('mc.louis2', 'mc.ghislaine')
M('mc.charlotte', 'Charlotte de Monaco', 1898, 1977, 'Princesse héréditaire, duchesse de Valentinois', 'f', ap='mort 1977 non donnée par la page, non revérifiée')
P('mc.louis2', 'mc.charlotte')
M('mc.polignac', 'Pierre de Polignac (prince Pierre de Monaco)', 1895, 1964, 'Prince consort', 'h', ap=A, dyn='Polignac (France)', fl='Maison de Polignac (France) : sans arbre')
S('mc.charlotte', 'mc.polignac')
M('mc.rainier3', 'Rainier III de Monaco', 1923, 2005, 'Prince de Monaco (1949-2005)', 'h', True)
P('mc.charlotte', 'mc.rainier3'); P('mc.polignac', 'mc.rainier3')
M('mc.grace', 'Grace Kelly', 1929, 1982, 'Princesse de Monaco, actrice', 'f', ap='naissance 1929 non donnée par la page, non revérifiée', dyn='Kelly (États-Unis)', fl='Famille Kelly (États-Unis) : sans arbre')
S('mc.rainier3', 'mc.grace')
M('mc.caroline', 'Caroline de Monaco', 1957, None, 'Princesse de Hanovre', 'f')
M('mc.albert2', 'Albert II de Monaco', 1958, None, 'Prince de Monaco (depuis 2005)', 'h', True)
M('mc.stephanie', 'Stéphanie de Monaco', 1965, None, 'Princesse', 'f')
for c in ('mc.caroline', 'mc.albert2', 'mc.stephanie'):
    P('mc.rainier3', c); P('mc.grace', c)
M('mc.charlene', 'Charlène Wittstock', 1978, None, 'Princesse de Monaco', 'f', ap='naissance 1978 non donnée par la page, à vérifier', dyn='Wittstock (Afrique du Sud)', fl='Famille Wittstock : sans arbre')
S('mc.albert2', 'mc.charlene')
M('mc.jacques', 'Jacques de Monaco', 2014, None, 'Prince héréditaire de Monaco', 'h')
M('mc.gabriella', 'Gabriella de Monaco', 2014, None, 'Comtesse de Carladès', 'f')
for c in ('mc.jacques', 'mc.gabriella'):
    P('mc.albert2', c); P('mc.charlene', c)
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
