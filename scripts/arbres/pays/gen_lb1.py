import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(129, "Liban (Chéhab)")
g.notes = ["Nouvel arbre « Chéhab » (Liban) : émirs du Mont-Liban de la lignée de Haydar. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", 'Pages lues : Shihab dynasty, Bashir Shihab II, Yusuf Shihab. Les pages ne donnent pas de dates de naissance sauf pour Yusuf et Bashir II. Musa (père de Haydar), Husayn (père de Bashir Ier) et Bashir Ier ne sont pas saisis ; Bashir III non saisi (parenté non indiquée).', "Bashir II est cousin de Yusuf (page de Bashir II) : lien « famille ». Son père est nommé Qasim Shihab, mais la parenté avec le Qasim fils de Mulhim n'est pas établie par les pages : non relié.", 'Dates en année chrétienne telles que la page les donne.']
g.tree('LB_CHE', 'LBN', 'Chéhab', section_title='Chéhab')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('lb.' + code, name, b, d, title, 'Chéhab', 'LB_CHE', 'h', True, src=W + page + (' - ' + note if note else ''))
K('haydar', 'Haydar Chéhab', None, 1732, 'Émir du Mont-Liban (1711-1732)', 'Shihab_dynasty', 'chassé en 1709, rétabli en 1711')
K('mulhim', 'Mulhim Chéhab', None, 1759, 'Émir du Mont-Liban (1732-1753)', 'Shihab_dynasty')
K('mansur', 'Mansour Chéhab', None, None, 'Émir du Mont-Liban (démission en 1770)', 'Shihab_dynasty')
K('ahmad', 'Ahmad Chéhab', None, None, "Prétendant à l'émirat, fils de Haydar", 'Shihab_dynasty')
K('qasim', 'Qasim Chéhab', None, None, 'Émir du Mont-Liban (1760)', 'Shihab_dynasty')
K('yusuf', 'Yusuf Chéhab', 1748, 1790, 'Émir du Mont-Liban (1770-1789)', 'Yusuf_Shihab')
K('bashir2', 'Bachir II Chéhab', 1767, 1850, 'Émir du Mont-Liban (1789-1840)', 'Bashir_Shihab_II')
for a, b in [('haydar', 'mulhim'), ('haydar', 'mansur'), ('haydar', 'ahmad'), ('mulhim', 'qasim'), ('mulhim', 'yusuf')]:
    g.par('lb.' + a, 'lb.' + b)
g.fam('lb.yusuf', 'lb.bashir2')
g.write()
