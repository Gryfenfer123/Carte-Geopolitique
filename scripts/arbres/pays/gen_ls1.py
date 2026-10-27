import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(142, "Lesotho (Moshoeshoe)")
g.notes = ["Nouvel arbre « Rois du Lesotho » : 5 personnes en deux branches. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Pages lues : Moshoeshoe I (père Mokhachane, successeur Letsie I) et liste des monarques (Moshoeshoe II fils de Simon Seeiso Griffith). Letsie III : fils de Moshoeshoe II. Les générations entre Letsie I et Seeiso ne sont pas indiquées par ces pages : les deux branches ne sont donc pas reliées. Dates de Letsie I et Seeiso inconnues.", 'Moshoeshoe I : né vers 1786 (date approximative).']
g.tree('LS_MOS', 'LSO', 'Rois du Lesotho', section_title='Rois du Lesotho')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('ls.' + code, name, b, d, title, 'Rois du Lesotho', 'LS_MOS', 'h', True, src=W + page + (' - ' + note if note else ''))
K('m1', 'Moshoeshoe I', 1786, 1870, 'Fondateur du royaume basotho (1822-1870)', 'Moshoeshoe_I', 'naissance vers 1786 ; mort le 11 mars 1870')
K('l1', 'Letsie I', None, 1891, 'Chef suprême des Basotho (1870-1891)', 'Monarchy_of_Lesotho', 'règne 1870-1891 ; fils de Moshoeshoe I selon la page de Moshoeshoe I')
K('seeiso', 'Simon Seeiso Griffith', None, 1940, 'Chef suprême des Basotho (1939-1940)', 'Monarchy_of_Lesotho')
K('m2', 'Moshoeshoe II', 1938, 1996, 'Roi du Lesotho (1960-1990 ; 1995-1996)', 'Monarchy_of_Lesotho')
K('l3', 'Letsie III', 1963, None, 'Roi du Lesotho (1990-1995 ; depuis 1996)', 'Monarchy_of_Lesotho')
for a, b in [('m1','l1'),('seeiso','m2'),('m2','l3')]:
    g.par('ls.' + a, 'ls.' + b)
g.write()
