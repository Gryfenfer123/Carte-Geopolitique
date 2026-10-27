import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(131, "Bhoutan (Wangchuck)")
g.notes = ["Nouvel arbre « Wangchuck » (Bhoutan) : 6 personnes de Jigme Namgyal au roi actuel. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", 'Pages lues pour chaque personne sauf Jigme Dorji (père confirmé par la page de Jigme Singye, ses dates viennent de la page de la dynastie). Ugyen Wangchuck : né en 1862 (sa page) contre 1861 (page de la dynastie) ; 1862 retenu. Jigme Singye et Jigme Khesar : vivants.', 'Dates en année chrétienne telles que la page les donne.']
g.tree('BT_WAN', 'BTN', 'Wangchuck', section_title='Wangchuck')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('bt.' + code, name, b, d, title, 'Wangchuck', 'BT_WAN', 'h', True, src=W + page + (' - ' + note if note else ''))
K('namgyal', 'Jigme Namgyal', 1825, 1881, 'Dru Desi, père du premier roi', 'Jigme_Namgyel')
K('ugyen', 'Ugyen Wangchuck', 1862, 1926, 'Premier roi du Bhoutan (1907-1926)', 'Ugyen_Wangchuck', 'naissance 1862 (sa page) ou 1861 (page de la dynastie)')
K('jigme2', 'Jigme Wangchuck', 1905, 1952, 'Deuxième roi du Bhoutan (1926-1952)', 'Jigme_Wangchuck')
K('dorji', 'Jigme Dorji Wangchuck', 1929, 1972, 'Troisième roi du Bhoutan (1952-1972)', 'Wangchuck_dynasty')
K('singye', 'Jigme Singye Wangchuck', 1955, None, 'Quatrième roi du Bhoutan (1972-2006)', 'Jigme_Singye_Wangchuck')
K('khesar', 'Jigme Khesar Namgyel Wangchuck', 1980, None, 'Cinquième roi du Bhoutan (depuis 2006)', 'Wangchuck_dynasty')
for a, b in [('namgyal', 'ugyen'), ('ugyen', 'jigme2'), ('jigme2', 'dorji'), ('dorji', 'singye'), ('singye', 'khesar')]:
    g.par('bt.' + a, 'bt.' + b)
g.write()
