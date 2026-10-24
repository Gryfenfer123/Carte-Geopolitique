import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(126, "Yémen (imams Hamid ad-Din)")
g.notes = ["Nouvel arbre « Hamid ad-Din » (Yémen) : 4 imams du royaume mutawakkilite. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", 'Muhammad ben Yahya Hamid ad-Din (père de Yahya) : aucune date lue, fiche sans dates. Les imams yéménites plus anciens ne sont pas saisis (pages sans liens de parenté précis).', 'Dates en année chrétienne telles que la page les donne.']
g.tree('YE_HAM', 'YEM', 'Hamid ad-Din', section_title='Hamid ad-Din')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('ye.' + code, name, b, d, title, 'Hamid ad-Din', 'YE_HAM', 'h', True, src=W + page + (' - ' + note if note else ''))
K('muhammad', 'Muhammad ben Yahya Hamid ad-Din (al-Mansour)', None, None, "Imam zaydite, père de l'imam Yahya", 'List_of_Kings_of_Yemen')
K('yahya', 'Yahya Muhammad Hamid ad-Din', 1869, 1948, 'Imam et roi du Yémen (1918-1948)', 'List_of_Kings_of_Yemen')
K('ahmad', 'Ahmad ben Yahya', 1891, 1962, 'Imam et roi du Yémen (1948-1962)', 'List_of_Kings_of_Yemen')
K('badr', 'Muhammad al-Badr', 1926, 1996, 'Dernier imam du Yémen (1962)', 'List_of_Kings_of_Yemen')
for a, b in [('muhammad', 'yahya'), ('yahya', 'ahmad'), ('ahmad', 'badr')]:
    g.par('ye.' + a, 'ye.' + b)
g.write()
