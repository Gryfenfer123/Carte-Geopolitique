import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(173, 'Birmanie (Toungoo)')
g.notes = ['Nouvel arbre « Toungoo » (Birmanie). Source : page Wikipédia « Toungoo dynasty » (anglais).', 'Seuls deux liens père-fils sont indiqués par la page (Mingyi Nyo → Tabinshwehti ; Bayinnaung → Nanda Bayin). Anaukpetlun est dit petit-fils de Bayinnaung (lien « famille »). Les dates de naissance/mort de la page sont notées comme approximatives et ne sont pas saisies. Les autres rois (Nyaungyan Min, Thalun, Mahadhammaraza Dipadi) ne sont pas reliés : non ajoutés.']
g.tree('MM_TOU', 'MMR', 'Toungoo', section_title='Toungoo')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('tg.' + code, name, b, d, title, 'Toungoo', 'MM_TOU', gnd, True, src=W + page + (' - ' + note if note else ''))
K('min', 'Mingyi Nyo', None, None, 'Roi de Toungoo (1485-1530)', 'Toungoo_dynasty', None, 'h')
K('tab', 'Tabinshwehti', None, None, 'Roi (1530-1550)', 'Toungoo_dynasty', None, 'h')
K('bay', 'Bayinnaung', None, None, 'Roi (1550-1581)', 'Toungoo_dynasty', 'beau-frère de Tabinshwehti', 'h')
K('nan', 'Nanda Bayin', None, None, 'Roi (1581-1599)', 'Toungoo_dynasty', None, 'h')
K('ana', 'Anaukpetlun', None, None, 'Roi (1605-1628)', 'Toungoo_dynasty', 'petit-fils de Bayinnaung', 'h')
g.par('tg.min', 'tg.tab')
g.par('tg.bay', 'tg.nan')
g.fam('tg.bay', 'tg.ana')
g.write()
