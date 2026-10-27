import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(135, "Afrique du Sud (rois zoulous)")
g.notes = ["Nouvel arbre « Rois zoulous » (Afrique du Sud) : 10 personnes de Senzangakhona à Misuzulu. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", 'Deux pages donnent des détails différents : « Solomon kaDinuzulu » (liste des rois, 1891-1933) est appelé « Phumuzuzulu » (1890-1933) dans la page de la famille royale ; une seule fiche, dates de la liste. Goodwill Zwelithini : règne 1968 (liste) ou 1971 (famille royale) ; Misuzulu : 2021 ou 2022. Senzangakhona : sans dates.', 'Dates en année chrétienne ; « c. » = approximatif.']
g.tree('ZA_ZUL', 'ZAF', 'Rois zoulous', section_title='Rois zoulous')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd=None):
    return g.m('za.' + code, name, b, d, title, 'Rois zoulous', 'ZA_ZUL', (gnd or 'h'), True, src=W + page + (' - ' + note if note else ''))
K('senzangakhona', 'Senzangakhona', None, None, 'Chef zoulou, père de Shaka, Dingane et Mpande', 'Zulu_royal_family')
K('shaka', 'Shaka', 1787, 1828, 'Roi des Zoulous (1816-1828)', 'List_of_Zulu_kings', 'naissance c. juillet 1787')
K('dingane', 'Dingane', 1795, 1840, 'Roi des Zoulous (1828-1840)', 'List_of_Zulu_kings', 'naissance c. 1795')
K('mpande', 'Mpande', 1798, 1872, 'Roi des Zoulous (1840-1872)', 'List_of_Zulu_kings', 'naissance c. 1798')
K('cetshwayo', 'Cetshwayo', 1834, 1884, 'Roi des Zoulous (1872-1879 ; 1883-1884)', 'List_of_Zulu_kings')
K('dinuzulu', 'Dinuzulu', 1868, 1913, 'Roi des Zoulous (1884-1913)', 'List_of_Zulu_kings', 'naissance c. 1868')
K('solomon', 'Solomon kaDinuzulu (Phumuzuzulu)', 1891, 1933, 'Roi des Zoulous (1913-1933)', 'List_of_Zulu_kings', 'appelé Phumuzuzulu (1890-1933) dans la page de la famille royale')
K('bhekuzulu', 'Cyprian Bhekuzulu', 1924, 1968, 'Roi des Zoulous (1948-1968)', 'List_of_Zulu_kings')
K('zwelithini', 'Goodwill Zwelithini', 1948, 2021, 'Roi des Zoulous (1968-2021)', 'List_of_Zulu_kings', 'règne depuis 1968 (liste) ou 1971 (famille royale)')
K('misuzulu', 'Misuzulu', 1974, None, 'Roi des Zoulous (depuis 2021)', 'List_of_Zulu_kings', 'règne depuis 2021 (liste) ou 2022 (famille royale)')
for a, b in [('senzangakhona', 'shaka'), ('senzangakhona', 'dingane'), ('senzangakhona', 'mpande'), ('mpande', 'cetshwayo'), ('cetshwayo', 'dinuzulu'), ('dinuzulu', 'solomon'), ('solomon', 'bhekuzulu'), ('bhekuzulu', 'zwelithini'), ('zwelithini', 'misuzulu')]:
    g.par('za.' + a, 'za.' + b)
g.write()
