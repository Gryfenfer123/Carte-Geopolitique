import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(138, "Malaisie (sultans de Johor)")
g.notes = ["Nouvel arbre « Sultans de Johor » (Malaisie) : 6 personnes, de Daeng Ibrahim à l'actuel sultan. Johor est un seul des États à monarchie de Malaisie ; les autres familles royales ne sont pas encore faites. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Dates et pères pris sur la page « Sultan of Johor » (liste), sauf Daeng Ibrahim (1810-1862, sa page). Sultan actuel : vivant. Le sultan actuel est le 5e de la liste ; Ibrahim Iskandar porte aussi le titre de « Ibrahim of Johor » (1895-1959)."]
g.tree('MY_JOH', 'MYS', 'Sultans de Johor', section_title='Sultans de Johor')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('my.' + code, name, b, d, title, 'Sultans de Johor', 'MY_JOH', 'h', True, src=W + page + (' - ' + note if note else ''))
K('daeng', 'Daeng Ibrahim', 1810, 1862, 'Temenggong de Johor (1841-1862)', 'Temenggong_Daeng_Ibrahim')
K('abubakar', 'Abu Bakar de Johor', 1833, 1895, 'Maharaja puis sultan de Johor (sultan 1886-1895)', 'Sultan_of_Johor')
K('ibrahim', 'Ibrahim de Johor', 1873, 1959, 'Sultan de Johor (1895-1959)', 'Sultan_of_Johor')
K('ismail', 'Ismail de Johor', 1894, 1981, 'Sultan de Johor (1959-1981)', 'Sultan_of_Johor')
K('iskandar', 'Iskandar de Johor', 1932, 2010, 'Sultan de Johor (1981-2010)', 'Sultan_of_Johor')
K('ibrahim2', 'Ibrahim Ismail de Johor', 1958, None, 'Sultan de Johor (depuis 2010)', 'Sultan_of_Johor')
for a, b in [('daeng','abubakar'),('abubakar','ibrahim'),('ibrahim','ismail'),('ismail','iskandar'),('iskandar','ibrahim2')]:
    g.par('my.' + a, 'my.' + b)
g.write()
