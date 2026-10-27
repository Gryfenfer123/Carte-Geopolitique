import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(133, "Birmanie (Konbaung)")
g.notes = ["Nouvel arbre « Konbaung » (Birmanie) : 10 rois et un prince, d'Alaungpaya à Thibaw. Chaque fiche porte l'adresse de la page Wikipédia (anglais) du roi dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Thado Minsaw, fils de Bodawpaya et père de Bagyidaw et Tharrawaddy : fiche sans dates (aucune page lue). Les rois du XIXe siècle sont tous reliés par les pages lues ; le père d'Alaungpaya (Min Nyo San) n'est pas saisi.", 'Dates en année chrétienne telles que la page les donne.']
g.tree('MM_KON', 'MMR', 'Konbaung', section_title='Konbaung')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('mm.' + code, name, b, d, title, 'Konbaung', 'MM_KON', 'h', True, src=W + page + (' - ' + note if note else ''))
K('alaungpaya', 'Alaungpaya', 1714, 1760, 'Fondateur de la dynastie Konbaung (1752-1760)', 'Alaungpaya')
K('naungdawgyi', 'Naungdawgyi', 1734, 1763, 'Roi de Birmanie (1760-1763)', 'Naungdawgyi')
K('hsinbyushin', 'Hsinbyushin', 1736, 1776, 'Roi de Birmanie (1763-1776)', 'Hsinbyushin')
K('bodawpaya', 'Bodawpaya', 1745, 1819, 'Roi de Birmanie (1782-1819)', 'Bodawpaya')
K('thado', 'Thado Minsaw', None, None, 'Prince, fils de Bodawpaya', 'Bodawpaya')
K('bagyidaw', 'Bagyidaw', 1784, 1846, 'Roi de Birmanie (1819-1837)', 'Bagyidaw')
K('tharrawaddy', 'Tharrawaddy', 1787, 1846, 'Roi de Birmanie (1837-1846)', 'Tharrawaddy_Min')
K('pagan', 'Pagan Min', 1811, 1880, 'Roi de Birmanie (1846-1853)', 'Pagan_Min')
K('mindon', 'Mindon', 1808, 1878, 'Roi de Birmanie (1853-1878)', 'Mindon_Min')
K('thibaw', 'Thibaw', 1859, 1916, 'Dernier roi de Birmanie (1878-1885)', 'Thibaw_Min')
for a, b in [('alaungpaya', 'naungdawgyi'), ('alaungpaya', 'hsinbyushin'), ('alaungpaya', 'bodawpaya'), ('bodawpaya', 'thado'), ('thado', 'bagyidaw'), ('thado', 'tharrawaddy'), ('tharrawaddy', 'pagan'), ('tharrawaddy', 'mindon'), ('mindon', 'thibaw')]:
    g.par('mm.' + a, 'mm.' + b)
g.write()
