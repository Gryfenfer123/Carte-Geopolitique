import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(171, 'Iran (Ilkhans)')
g.notes = ['Nouvel arbre « Ilkhans » (Iran). Sources : pages Wikipédia « Ilkhanate » et « Ghazan » (anglais).', "Tolui est le père de Houlagou. Ahmad Tegüder est dit frère d'Abaqa, Gaykhatu frère d'Arghun, Öljaitü frère de Ghazan (liens « famille »). Ghazan est fils d'Arghun (page « Ghazan »). Naissance de Ghazan : 5 novembre 1271 selon la page « Ghazan », 1272 selon la liste de la page « Ilkhanate » (1271 retenu). Baydu (cousin de Gaykhatu) n'est pas ajouté faute de lien précis."]
g.tree('IR_ILK', 'IRN', 'Ilkhans', section_title='Ilkhans')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('il.' + code, name, b, d, title, 'Ilkhans', 'IR_ILK', gnd, True, src=W + page + (' - ' + note if note else ''))
K('tol', 'Tolui', None, None, 'Père de Houlagou', 'Ilkhanate', None, 'h')
K('hul', 'Houlagou', 1217, 1265, 'Premier ilkhan (1256-1265)', 'Ilkhanate', None, 'h')
K('aba', 'Abaqa', 1234, 1282, 'Ilkhan (1265-1282)', 'Ilkhanate', None, 'h')
K('ahm', 'Ahmad Tegüder', 1233, 1284, 'Ilkhan (1282-1284)', 'Ilkhanate', "frère d'Abaqa", 'h')
K('arg', 'Arghun', None, 1292, 'Ilkhan (1284-1291)', 'Ilkhanate', 'naissance 1258 sur la page « Ilkhanate » : incompatible avec Ghazan né en 1271, non saisie', 'h')
K('gay', 'Gaykhatu', None, 1295, 'Ilkhan (1291-1295)', 'Ilkhanate', "frère d'Arghun", 'h')
K('gha', 'Ghazan', 1271, 1304, 'Ilkhan (1295-1304)', 'Ghazan', 'né le 5 novembre 1271 ; mort le 11 mai 1304', 'h')
K('olj', 'Öljaitü', 1280, 1316, 'Ilkhan (1304-1316)', 'Ilkhanate', 'frère de Ghazan', 'h')
K('abu', 'Abu Saïd', 1305, 1335, 'Ilkhan (1316-1335)', 'Ilkhanate', None, 'h')
g.par('il.tol', 'il.hul')
g.par('il.hul', 'il.aba')
g.par('il.aba', 'il.arg')
g.par('il.arg', 'il.gha')
g.par('il.olj', 'il.abu')
g.fam('il.aba', 'il.ahm')
g.fam('il.arg', 'il.gay')
g.fam('il.gha', 'il.olj')
g.write()
