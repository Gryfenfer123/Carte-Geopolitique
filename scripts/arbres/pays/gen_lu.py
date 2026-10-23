import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(52, "Luxembourg — Nassau-Weilburg (grands-ducs)")
g.notes = [
    "Crée sous Luxembourg > Dynastie : Nassau-Weilburg (Guillaume de Nassau -> Adolphe -> Guillaume IV -> Marie-Adélaïde, Charlotte -> Jean -> Henri -> Guillaume V). Les rois néerlandais, grands-ducs de 1815 à 1890, restent dans l'arbre Orange-Nassau (Pays-Bas).",
    "L'arbre démarre à Guillaume, duc de Nassau, père d'Adolphe (le duché de Nassau est allemand : pas d'arbre allemand propre ici, décision à valider).",
    "Créés dans leur arbre : Louise de Saxe-Hildburghausen (Wettin), Élisabeth Mikhaïlovna et son père (Romanov), Félix de Bourbon-Parme et sa mère Maria Antonia du Portugal (Bourbon-Parme), Joséphine-Charlotte de Belgique (Couronne belge).",
    "Non inclus : les sœurs de Charlotte (dont Antonia, épouse du prince héritier Rupprecht de Bavière) et la maison médiévale de Luxembourg (déjà en base, v32).",
    "Prérequis : v51 exécuté.",
]
g.tree('LU_NAS', 'LUX', 'Nassau-Weilburg')
g.tree('DE_WET', 'DEU', 'Wettin', entry='309f20ea-3b5d-453b-87f9-286b7f1e6c60')
g.tree('RU_ROM', 'RUS', 'Romanov')
g.tree('IT_PAR', 'ITA', 'Maison de Bourbon-Parme', entry=E('84c9f117'))
g.tree('BE_COU', 'BEL', 'Couronne belge', entry=E('b4e42a0f'))
g.reposition = {'RU_ROM'}
FB = {'lu.maria_antonia': 1862, 'lu.hildburg': 1794, 'lu.stephanie': 1984, 'lu.mestre': 1956}
Gen.FIXB = {uid('member:' + c): y for c, y in FB.items()}
P, S = g.par, g.sp
NA = 'Nassau-Weilburg'
g.m('lu.wilhelm', 'Guillaume, duc de Nassau', 1792, 1839, 'Duc de Nassau (1816-1839)', NA, 'LU_NAS', 'h', True)
g.m('lu.louise', 'Louise de Saxe-Hildburghausen', 1794, 1825, 'Duchesse de Nassau', 'Wettin (Saxe-Hildburghausen)', 'DE_WET', 'f', approx='dates 1794-1825 (non données par la page, non revérifiées)')
S('lu.wilhelm', 'lu.louise')
g.fam('lu.louise', 'gr.therese')
g.m('lu.adolphe', 'Adolphe de Luxembourg', 1817, 1905, 'Duc de Nassau (1839-1866), grand-duc de Luxembourg (1890-1905)', NA, 'LU_NAS', 'h', True)
P('lu.wilhelm', 'lu.adolphe'); P('lu.louise', 'lu.adolphe')
g.m('ru.michael_p', 'Michel Pavlovitch de Russie', 1798, 1849, 'Grand-duc de Russie', 'Romanov', 'RU_ROM', 'h', approx='dates 1798-1849 (non revérifiées)')
P('ru.paul1', 'ru.michael_p'); P('ru.maria_f', 'ru.michael_p')
g.m('lu.elizabeth_m', 'Élisabeth Mikhaïlovna de Russie', 1826, 1845, 'Duchesse de Nassau (1844-1845)', 'Romanov', 'RU_ROM', 'f', approx='dates 1826-1845 (naissance non donnée par la page)')
P('ru.michael_p', 'lu.elizabeth_m')
S('lu.adolphe', 'lu.elizabeth_m')
g.m('lu.adelheid', 'Adélaïde-Marie d\'Anhalt-Dessau', 1833, 1916, 'Grande-duchesse de Luxembourg', 'Anhalt-Dessau', 'LU_NAS', 'f', flag='Maison d\'Anhalt-Dessau (Allemagne) : sans arbre', approx='dates 1833-1916 (non données par la page, non revérifiées)')
S('lu.adolphe', 'lu.adelheid')
g.m('lu.wilhelm4', 'Guillaume IV de Luxembourg', 1852, 1912, 'Grand-duc de Luxembourg (1905-1912)', NA, 'LU_NAS', 'h', True)
g.m('lu.hilda', 'Hilda de Nassau (grande-duchesse de Bade)', 1864, 1952, 'Grande-duchesse de Bade', NA, 'LU_NAS', 'f')
for c in ('lu.wilhelm4', 'lu.hilda'):
    P('lu.adolphe', c); P('lu.adelheid', c)
g.m('lu.marie_anne', 'Marie-Anne de Portugal (grande-duchesse de Luxembourg)', 1861, 1942, 'Grande-duchesse de Luxembourg', 'Bragance (Portugal)', 'LU_NAS', 'f', flag='Maison de Bragance (Portugal) : arbre à créer avec le Portugal', approx='dates 1861-1942 (non données par la page, non revérifiées)')
S('lu.wilhelm4', 'lu.marie_anne')
g.m('lu.marie_adelaide', 'Marie-Adélaïde de Luxembourg', 1894, 1924, 'Grande-duchesse de Luxembourg (1912-1919)', NA, 'LU_NAS', 'f', True)
g.m('lu.charlotte', 'Charlotte de Luxembourg', 1896, 1985, 'Grande-duchesse de Luxembourg (1919-1964)', NA, 'LU_NAS', 'f', True, approx='mort le 9 juillet 1985 (la page donne aussi le 6 dans l\'en-tête)')
for c in ('lu.marie_adelaide', 'lu.charlotte'):
    P('lu.wilhelm4', c); P('lu.marie_anne', c)
g.m('lu.maria_antonia', 'Maria Antonia de Portugal (duchesse de Parme)', 1862, 1959, 'Duchesse de Parme', 'Bragance (Portugal)', 'IT_PAR', 'f', flag='Maison de Bragance (Portugal) : arbre à créer avec le Portugal', approx='dates 1862-1959 (non revérifiées)')
S('ro.robert_p', 'lu.maria_antonia')
P('ro.robert_p', 'at.zita'); P('lu.maria_antonia', 'at.zita')
g.m('lu.felix', 'Félix de Bourbon-Parme', 1893, 1970, 'Prince consort de Luxembourg', 'Bourbon-Parme', 'IT_PAR', 'h', approx='naissance 1893 non donnée par la page, non revérifiée ; mort 1970')
P('ro.robert_p', 'lu.felix'); P('lu.maria_antonia', 'lu.felix')
S('lu.charlotte', 'lu.felix')
kids = [('lu.jean', 'Jean de Luxembourg', 1921, 2019, 'Grand-duc de Luxembourg (1964-2000)', 'h', True),
        ('lu.elisabeth', 'Élisabeth de Luxembourg', 1922, 2011, 'Princesse, duchesse de Hohenberg', 'f', False),
        ('lu.marie_adelaide2', 'Marie-Adélaïde de Luxembourg (1924-2007)', 1924, 2007, 'Princesse', 'f', False),
        ('lu.marie_gabrielle', 'Marie-Gabrielle de Luxembourg', 1925, 2023, 'Princesse', 'f', False),
        ('lu.charles', 'Charles de Luxembourg', 1927, 1977, 'Prince', 'h', False),
        ('lu.alix', 'Alix de Luxembourg', 1929, 2019, 'Princesse de Ligne', 'f', False)]
for c, n, b, d, t, s, ld in kids:
    g.m(c, n, b, d, t, NA, 'LU_NAS', s, ld)
    P('lu.charlotte', c); P('lu.felix', c)
g.m('lu.josephine', 'Joséphine-Charlotte de Belgique', 1927, 2005, 'Grande-duchesse de Luxembourg', 'Saxe-Cobourg-Gotha (Belgique)', 'BE_COU', 'f', approx='dates 1927-2005 (non données par la page, non revérifiées)')
P(X('348b2f89'), 'lu.josephine'); P(X('e05064a0'), 'lu.josephine')
S('lu.jean', 'lu.josephine')
g.m('lu.henri', 'Henri de Luxembourg', 1955, None, 'Grand-duc de Luxembourg (2000-2025)', NA, 'LU_NAS', 'h', True)
for c, n, b in (('lu.marie_astrid', 'Marie-Astrid de Luxembourg', 1954), ('lu.jean2', 'Jean de Luxembourg (né en 1957)', 1957), ('lu.margaretha', 'Margaretha de Luxembourg', 1957), ('lu.guillaume_p', 'Guillaume de Luxembourg (né en 1963)', 1963)):
    g.m(c, n, b, None, 'Prince(sse) de Luxembourg', NA, 'LU_NAS', 'f' if c in ('lu.marie_astrid', 'lu.margaretha') else 'h', approx='naissance non donnée par la page, non revérifiée')
for c in ('lu.henri', 'lu.marie_astrid', 'lu.jean2', 'lu.margaretha', 'lu.guillaume_p'):
    P('lu.jean', c); P('lu.josephine', c)
g.m('lu.mestre', 'María Teresa Mestre y Batista', 1956, None, 'Grande-duchesse de Luxembourg', 'Mestre (Cuba)', 'LU_NAS', 'f', flag='Famille Mestre (Cuba) : sans arbre', approx='naissance 1956 non donnée par la page, non revérifiée')
S('lu.henri', 'lu.mestre')
for c, n, b, ld in (('lu.guillaume5', 'Guillaume V de Luxembourg', 1981, True), ('lu.felix_p', 'Félix de Luxembourg', 1984, False), ('lu.louis', 'Louis de Luxembourg', 1986, False), ('lu.alexandra', 'Alexandra de Luxembourg', 1991, False), ('lu.sebastien', 'Sébastien de Luxembourg', 1992, False)):
    g.m(c, n, b, None, 'Grand-duc de Luxembourg (depuis 2025)' if c == 'lu.guillaume5' else 'Prince(sse) de Luxembourg', NA, 'LU_NAS', 'f' if c == 'lu.alexandra' else 'h', ld)
    P('lu.henri', c); P('lu.mestre', c)
g.m('lu.stephanie', 'Stéphanie de Lannoy', 1984, None, 'Grande-duchesse héritière puis grande-duchesse de Luxembourg', 'Lannoy (Belgique)', 'LU_NAS', 'f', flag='Famille de Lannoy (noblesse belge) : sans arbre')
S('lu.guillaume5', 'lu.stephanie')
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
