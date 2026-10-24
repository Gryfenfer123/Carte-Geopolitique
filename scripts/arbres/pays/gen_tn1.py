import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(125, "Tunisie (Husseinites)")
g.notes = ["Nouvel arbre « Husseinites » (Tunisie) : 19 beys de Tunis, de Husayn Ier à Muhammad VIII al-Amin. Chaque fiche porte l'adresse de la page Wikipédia (anglais) « List of beys of Tunis » dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", 'Liens « famille » (non parent-enfant direct) : Abu l-Hasan Ali Ier est le neveu de Husayn Ier ; Muhammad VI al-Habib est le cousin de Muhammad V (la page ne donne pas leurs parents).', 'Husayn Ier : naissance 1669 (liste des beys) contre 1675 (page de la dynastie husseinite) ; 1669 retenu.', "Dates en année chrétienne (seule l'année est gardée)."]
g.tree('TN_HUS', 'TUN', 'Husseinites', section_title='Husseinites')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('tn.' + code, name, b, d, title, 'Husseinites', 'TN_HUS', 'h', True, src=W + page + (' - ' + note if note else ''))
K('husayn1', 'Husayn Ier ben Ali', 1669, 1740, 'Fondateur de la dynastie husseinite, bey de Tunis (1705-1735)', 'List_of_beys_of_Tunis', 'naissance 1669 (liste) ou 1675 (page de la dynastie)')
K('ali1', 'Ali Ier', 1688, 1756, 'Bey de Tunis (1735-1756)', 'List_of_beys_of_Tunis')
K('muhammad1', 'Muhammad Ier ar-Rachid', 1710, 1759, 'Bey de Tunis (1756-1759)', 'List_of_beys_of_Tunis')
K('ali2', 'Ali II', 1712, 1782, 'Bey de Tunis (1759-1782)', 'List_of_beys_of_Tunis')
K('hammuda', 'Hammouda ben Ali', 1759, 1814, 'Bey de Tunis (1782-1814)', 'List_of_beys_of_Tunis')
K('uthman', 'Uthman ben Ali', 1763, 1814, 'Bey de Tunis (sept.-déc. 1814)', 'List_of_beys_of_Tunis')
K('mahmud', 'Mahmoud ben Muhammad', 1757, 1824, 'Bey de Tunis (1814-1824)', 'List_of_beys_of_Tunis')
K('husayn2', 'Husayn II', 1784, 1835, 'Bey de Tunis (1824-1835)', 'List_of_beys_of_Tunis')
K('mustafa', 'Mustafa ben Mahmoud', 1786, 1837, 'Bey de Tunis (1835-1837)', 'List_of_beys_of_Tunis')
K('ahmad1', 'Ahmad Ier', 1806, 1855, 'Bey de Tunis (1837-1855)', 'List_of_beys_of_Tunis')
K('muhammad2', 'Muhammad II', 1811, 1859, 'Bey de Tunis (1855-1859)', 'List_of_beys_of_Tunis')
K('muhammad3', 'Muhammad III as-Sadiq', 1813, 1882, 'Bey de Tunis (1859-1882)', 'List_of_beys_of_Tunis')
K('ali3', 'Ali III', 1817, 1902, 'Bey de Tunis (1882-1902)', 'List_of_beys_of_Tunis')
K('muhammad4', 'Muhammad IV al-Hadi', 1855, 1906, 'Bey de Tunis (1902-1906)', 'List_of_beys_of_Tunis')
K('muhammad5', 'Muhammad V an-Nasir', 1855, 1922, 'Bey de Tunis (1906-1922)', 'List_of_beys_of_Tunis')
K('muhammad6', 'Muhammad VI al-Habib', 1858, 1929, 'Bey de Tunis (1922-1929)', 'List_of_beys_of_Tunis')
K('ahmad2', 'Ahmad II', 1862, 1942, 'Bey de Tunis (1929-1942)', 'List_of_beys_of_Tunis')
K('muhammad7', 'Muhammad VII al-Munsif', 1881, 1948, 'Bey de Tunis (1942-1943)', 'List_of_beys_of_Tunis')
K('muhammad8', 'Muhammad VIII al-Amin', 1881, 1962, 'Dernier bey de Tunis (1943-1957)', 'List_of_beys_of_Tunis')
for a, b in [('husayn1', 'muhammad1'), ('husayn1', 'ali2'), ('ali2', 'hammuda'), ('ali2', 'uthman'), ('muhammad1', 'mahmud'), ('mahmud', 'husayn2'), ('mahmud', 'mustafa'), ('mustafa', 'ahmad1'), ('husayn2', 'muhammad2'), ('husayn2', 'muhammad3'), ('husayn2', 'ali3'), ('ali3', 'muhammad4'), ('muhammad2', 'muhammad5'), ('ali3', 'ahmad2'), ('muhammad5', 'muhammad7'), ('muhammad6', 'muhammad8')]:
    g.par('tn.' + a, 'tn.' + b)
g.fam('tn.husayn1', 'tn.ali1')
g.fam('tn.muhammad5', 'tn.muhammad6')
g.write()
