import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(163, 'Italie (Nerva-Antonins)')
g.notes = ["Nouvel arbre « Nerva-Antonins » (Rome antique, rattaché à l'Italie). Source : page « Nerva–Antonine dynasty » (anglais). La page ne donne que les dates de mort de certains empereurs.", "Succession par adoption : Nerva → Trajan → Hadrien → Antonin le Pieux → Marc Aurèle et Lucius Verus. Ces liens d'adoption sont saisis en « famille » (pas parent-enfant biologique). Seul Commodus est fils biologique (de Marc Aurèle). Faustine, Plotine et Sabine ne sont pas citées sur la page : non ajoutées."]
g.tree('IT_NAN', 'ITA', 'Nerva-Antonins', section_title='Nerva-Antonins')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('na.' + code, name, b, d, title, 'Nerva-Antonins', 'IT_NAN', gnd, True, src=W + page + (' - ' + note if note else ''))
K('ner', 'Nerva', None, None, 'Empereur romain (96-98)', 'Nerva%E2%80%93Antonine_dynasty', None, 'h')
K('tra', 'Trajan', None, None, 'Empereur romain (98-117)', 'Nerva%E2%80%93Antonine_dynasty', 'fils adoptif de Nerva', 'h')
K('had', 'Hadrien', None, 138, 'Empereur romain (117-138)', 'Nerva%E2%80%93Antonine_dynasty', 'fils adoptif de Trajan', 'h')
K('ant', 'Antonin le Pieux', None, None, 'Empereur romain (138-161)', 'Nerva%E2%80%93Antonine_dynasty', "fils adoptif d'Hadrien", 'h')
K('mar', 'Marc Aurèle', None, 180, 'Empereur romain (161-180)', 'Nerva%E2%80%93Antonine_dynasty', "fils adoptif d'Antonin le Pieux", 'h')
K('ver', 'Lucius Verus', None, 169, 'Empereur romain (161-169)', 'Nerva%E2%80%93Antonine_dynasty', "fils adoptif d'Antonin le Pieux", 'h')
K('com', 'Commode', None, 192, 'Empereur romain (177-192)', 'Nerva%E2%80%93Antonine_dynasty', 'fils biologique de Marc Aurèle', 'h')
g.par('na.mar', 'na.com')
g.fam('na.ner', 'na.tra')
g.fam('na.tra', 'na.had')
g.fam('na.had', 'na.ant')
g.fam('na.ant', 'na.mar')
g.fam('na.ant', 'na.ver')
g.write()
