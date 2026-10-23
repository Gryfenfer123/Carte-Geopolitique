import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(63, "Allemagne — Hohenzollern : branches de Brandebourg-Kulmbach et Bayreuth, famille de Marie de Prusse, empereurs et chef actuel de la maison")
g.notes = [
    "Complète l'arbre Hohenzollern (rien n'est supprimé) : parents de Marie de Brandebourg-Kulmbach (Casimir et Suzanne de Bavière), de Madeleine-Sibylle et Christiane-Éberhardine de Brandebourg-Bayreuth, de Marie de Prusse (reine de Bavière) ; descendants de Guillaume II et du Kronprinz jusqu'à Georges-Frédéric (chef de la maison).",
    "Sources : Wikipédia en anglais (pages de chaque personne : parents, épouses, enfants avec dates). Dates non données = vides et signalées.",
    "Suzanne de Bavière (Wittelsbach, déjà créée en v61) est reliée à son premier mari Casimir : elle a épousé ensuite Othon-Henri du Palatinat.",
    "Épouses de familles sans arbre (Anhalt, Reuss, Hesse-Hombourg, Wurtemberg, Castell-Rüdenhausen, Isenbourg) : placées ici et signalées. Kira Kirillovna : arbre Romanov (ses parents sont à ajouter avec la Russie).",
    "La branche catholique de Hohenzollern-Sigmaringen reste un bloc séparé (liée à la Roumanie) : le lien avec la branche de Brandebourg remonte au XIIIᵉ siècle, hors périmètre.",
    "Prérequis : v61 et v62 exécutés.",
]
g.tree('DE_HOH', 'DEU', 'Hohenzollern', entry=E('39895573'))
g.tree('DE_WET', 'DEU', 'Wettin', entry=E('309f20ea'))
g.tree('DE_WIT', 'DEU', 'Wittelsbach', entry=E('e76d91a3'))
g.tree('RU_ROM', 'RUS', 'Romanov')
g.reposition = {'DE_HOH'}
P, S = g.par, g.sp

def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)

def H(code, name, b, d, title, dyn, g_, tree='DE_HOH', leader=False, approx=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)

# ---------- Brandebourg-Kulmbach : parents de Marie ----------
H('ho.casimir', 'Casimir de Brandebourg-Kulmbach', 1481, 1527, 'Margrave de Brandebourg-Kulmbach', 'Hohenzollern (Brandebourg-Kulmbach)', 'h')
kids([X('d4f92d'), X('dcef01')], ['ho.casimir'])           # Frédéric l'Ancien d'Ansbach + Sophie Jagellon
S('ho.casimir', 'wi.suzanne')                               # Suzanne de Bavière (créée en v61)
kids(['ho.casimir', 'wi.suzanne'], ['wi.marie_bk'])           # Marie de Brandebourg-Kulmbach (électrice palatine)

# ---------- Brandebourg-Bayreuth : Madeleine-Sibylle et Christiane-Éberhardine ----------
H('ho.elisabeth_anhalt', "Élisabeth d'Anhalt-Zerbst", None, None, 'Électrice de Brandebourg (troisième épouse de Jean-Georges)', 'Anhalt', 'f', flag="Maison d'Anhalt : sans arbre",
  approx='dates non données par la page de Christian de Bayreuth')
S(X('560e43'), 'ho.elisabeth_anhalt')
H('ho.christian_bay', 'Christian de Brandebourg-Bayreuth', 1581, 1655, 'Margrave de Brandebourg-Bayreuth', 'Hohenzollern (Brandebourg-Bayreuth)', 'h')
kids([X('560e43'), 'ho.elisabeth_anhalt'], ['ho.christian_bay'])
H('ho.marie_prusse_bay', 'Marie de Prusse (margravine de Bayreuth)', 1579, 1649, 'Margravine de Brandebourg-Bayreuth', 'Hohenzollern (Prusse)', 'f')
kids([X('4eb64b'), X('d2ebd7')], ['ho.marie_prusse_bay'])
S('ho.christian_bay', 'ho.marie_prusse_bay')
kids(['ho.christian_bay', 'ho.marie_prusse_bay'], [X('f632cf')])      # Madeleine-Sibylle (épouse de Jean-Georges II)
H('ho.erdmann', 'Erdmann-Auguste de Brandebourg-Bayreuth', 1615, 1651, 'Prince héritier de Brandebourg-Bayreuth', 'Hohenzollern (Brandebourg-Bayreuth)', 'h')
kids(['ho.christian_bay', 'ho.marie_prusse_bay'], ['ho.erdmann'])
H('ho.sophie_ansbach', 'Sophie de Brandebourg-Ansbach', None, None, 'Princesse héritière de Brandebourg-Bayreuth', 'Hohenzollern (Brandebourg-Ansbach)', 'f',
  approx='dates non données par la page de Christian-Ernst')
S('ho.erdmann', 'ho.sophie_ansbach')
H('ho.christian_ernst', 'Christian-Ernst de Brandebourg-Bayreuth', 1644, 1712, 'Margrave de Brandebourg-Bayreuth', 'Hohenzollern (Brandebourg-Bayreuth)', 'h')
kids(['ho.erdmann', 'ho.sophie_ansbach'], ['ho.christian_ernst'])
H('ho.erdmuthe', 'Erdmuthe-Sophie de Saxe', None, 1670, 'Margravine de Brandebourg-Bayreuth, première épouse de Christian-Ernst', 'Wettin', 'f', 'DE_WET',
  approx='naissance non donnée par la page de Christian-Ernst')
kids([X('987c85'), X('f632cf')], ['ho.erdmuthe'])         # Jean-Georges II + Madeleine-Sibylle
S('ho.christian_ernst', 'ho.erdmuthe')
H('ho.sophie_louise_wur', 'Sophie-Louise de Wurtemberg', None, 1702, 'Margravine de Brandebourg-Bayreuth, seconde épouse de Christian-Ernst', 'Wurtemberg', 'f', flag='Maison de Wurtemberg : sans arbre',
  approx='naissance non donnée par la page de Christian-Ernst')
S('ho.christian_ernst', 'ho.sophie_louise_wur')
kids(['ho.christian_ernst', 'ho.sophie_louise_wur'], [X('591417')])   # Christiane-Éberhardine

# ---------- Marie de Prusse, reine de Bavière ----------
g.setdates('wi.marie_prusse', 1825, 1889)
H('ho.guillaume_prince', 'Guillaume de Prusse (1783-1851)', 1783, 1851, 'Prince de Prusse, frère de Frédéric-Guillaume III', 'Hohenzollern', 'h')
kids([X('7d51ed'), X('f73ebc')], ['ho.guillaume_prince'])
H('ho.marie_anne_hh', 'Marie-Anne de Hesse-Hombourg', None, 1846, 'Princesse de Prusse', 'Hesse-Hombourg', 'f', flag='Maison de Hesse-Hombourg : sans arbre',
  approx='naissance non donnée par la page de Guillaume de Prusse')
S('ho.guillaume_prince', 'ho.marie_anne_hh')
kids(['ho.guillaume_prince', 'ho.marie_anne_hh'], ['wi.marie_prusse'])

# ---------- Guillaume II, ses épouses et descendants ----------
W2 = X('0f6290')
H('ho.hermine', 'Hermine Reuss de Greiz', 1887, 1947, 'Seconde épouse de Guillaume II', 'Reuss', 'f', flag='Maison Reuss : sans arbre')
S(W2, 'ho.hermine')
H('ho.viktoria_luise', 'Victoria-Louise de Prusse', 1892, 1980, 'Princesse de Prusse, duchesse de Brunswick', 'Hohenzollern', 'f')
kids([W2, X('a09965')], ['ho.viktoria_luise'])
KP = X('935858')                                           # Guillaume, Kronprinz
H('ho.guillaume_kp2', 'Guillaume de Prusse (1906-1940)', 1906, 1940, 'Fils aîné du Kronprinz', 'Hohenzollern', 'h')
H('ho.louis_ferdinand', 'Louis-Ferdinand de Prusse (1907-1994)', 1907, 1994, 'Chef de la maison de Hohenzollern', 'Hohenzollern', 'h')
kids([KP, X('5bb14b')], ['ho.guillaume_kp2', 'ho.louis_ferdinand'])
H('ho.kira', 'Kira Kirillovna de Russie', 1909, 1967, 'Princesse de Prusse', 'Romanov', 'f', 'RU_ROM',
  flag="Ses parents (Cyrille Vladimirovitch et Victoria-Mélita) sont à ajouter avec l'arbre de Russie", approx='naissance 1909 : à revérifier (la page de Louis-Ferdinand ne donne que la mort, 1967)')
S('ho.louis_ferdinand', 'ho.kira')
H('ho.louis_ferdinand2', 'Louis-Ferdinand de Prusse (1944-1977)', 1944, 1977, 'Prince de Prusse, père de Georges-Frédéric', 'Hohenzollern', 'h')
kids(['ho.louis_ferdinand', 'ho.kira'], ['ho.louis_ferdinand2'])
H('ho.donata', 'Donata de Castell-Rüdenhausen', 1950, 2015, 'Princesse de Prusse', 'Castell-Rüdenhausen', 'f', flag='Maison de Castell-Rüdenhausen : sans arbre')
S('ho.louis_ferdinand2', 'ho.donata')
H('ho.georges_frederic', 'Georges-Frédéric de Prusse', 1976, None, 'Chef actuel de la maison de Hohenzollern', 'Hohenzollern', 'h')
kids(['ho.louis_ferdinand2', 'ho.donata'], ['ho.georges_frederic'])
H('ho.sophie_isenburg', "Sophie d'Isenbourg", None, None, 'Princesse de Prusse', 'Isenbourg', 'f', flag='Maison d\'Isenbourg : sans arbre',
  approx='dates non données par la page de Georges-Frédéric')
S('ho.georges_frederic', 'ho.sophie_isenburg')

if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
