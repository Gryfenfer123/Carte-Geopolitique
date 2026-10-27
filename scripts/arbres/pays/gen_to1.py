import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(141, "Tonga (Tupou)")
g.notes = ["Nouvel arbre « Maison Tupou » (Tonga) : 5 personnes, de George Tupou II à Tupou VI. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Page lue : liste des monarques de Tonga. George Tupou I (1797-1893) est écarté : la page n'indique pas son lien avec Tupou II (père de Tupou II non indiqué). Tupou IV : « fils de Sālote Tupou III » (mère) selon la page ; le père n'est pas donné.", 'Tupou VI : vivant.']
g.tree('TO_TUP', 'TON', 'Maison Tupou', section_title='Maison Tupou')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, note=None):
    return g.m('to.' + code, name, b, d, title, 'Maison Tupou', 'TO_TUP', 'h', True, src=W + 'List_of_monarchs_of_Tonga' + (' - ' + note if note else ''))
K('t2', 'George Tupou II', 1874, 1918, 'Roi de Tonga (1893-1918)')
K('t3', 'Sālote Tupou III', 1900, 1965, 'Reine de Tonga (1918-1965)')
K('t4', 'Tāufaʻāhau Tupou IV', 1918, 2006, 'Roi de Tonga (1965-2006)', 'fils de Sālote Tupou III')
K('t5', 'George Tupou V', 1948, 2012, 'Roi de Tonga (2006-2012)')
K('t6', 'Tupou VI', 1959, None, 'Roi de Tonga (depuis 2012)')
for a, b in [('t2','t3'),('t3','t4'),('t4','t5'),('t4','t6')]:
    g.par('to.' + a, 'to.' + b)
g.write()
