import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(130, "Népal (Shah)")
g.notes = ["Nouvel arbre « Shah » (Népal) : 13 rois de Prithvi Narayan Shah à Gyanendra, avec son père Nara Bhupal (sans dates). Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Prithvi Bir Bikram est « petit-fils » de Surendra (le père, non nommé par la page, n'est pas saisi) : lien « famille ». Tribhuvan et Gyanendra ont chacun deux règnes ; une seule fiche chacun. Gyanendra : né en 1947, vivant.", 'Dates en année chrétienne telles que la page les donne.']
g.tree('NP_SHA', 'NPL', 'Shah', section_title='Shah')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('np.' + code, name, b, d, title, 'Shah', 'NP_SHA', 'h', True, src=W + page + (' - ' + note if note else ''))
K('narabhupal', 'Nara Bhupal Shah', None, None, 'Roi de Gorkha, père de Prithvi Narayan Shah', 'List_of_monarchs_of_Nepal')
K('prithvi', 'Prithvi Narayan Shah', 1723, 1775, 'Roi du Népal (1743-1775), unificateur du pays', 'List_of_monarchs_of_Nepal')
K('pratap', 'Pratap Singh Shah', 1751, 1777, 'Roi du Népal (1775-1777)', 'List_of_monarchs_of_Nepal')
K('rana', 'Rana Bahadur Shah', 1775, 1806, 'Roi du Népal (1777-1799)', 'List_of_monarchs_of_Nepal')
K('girvan', 'Girvan Yuddha Bikram Shah', 1797, 1816, 'Roi du Népal (1799-1816)', 'List_of_monarchs_of_Nepal')
K('rajendra', 'Rajendra Bikram Shah', 1813, 1881, 'Roi du Népal (1816-1847)', 'List_of_monarchs_of_Nepal')
K('surendra', 'Surendra Bikram Shah', 1829, 1881, 'Roi du Népal (1847-1881)', 'List_of_monarchs_of_Nepal')
K('prithvibir', 'Prithvi Bir Bikram Shah', 1875, 1911, 'Roi du Népal (1881-1911)', 'List_of_monarchs_of_Nepal')
K('tribhuvan', 'Tribhuvan Bir Bikram Shah', 1906, 1955, 'Roi du Népal (1911-1950 ; 1951-1955)', 'List_of_monarchs_of_Nepal')
K('mahendra', 'Mahendra Bir Bikram Shah', 1920, 1972, 'Roi du Népal (1955-1972)', 'List_of_monarchs_of_Nepal')
K('birendra', 'Birendra Bir Bikram Shah', 1945, 2001, 'Roi du Népal (1972-2001), assassiné', 'List_of_monarchs_of_Nepal')
K('dipendra', 'Dipendra Bir Bikram Shah', 1971, 2001, 'Roi du Népal (1er-4 juin 2001)', 'List_of_monarchs_of_Nepal')
K('gyanendra', 'Gyanendra Bir Bikram Shah', 1947, None, 'Roi du Népal (1950-1951 ; 2001-2008)', 'List_of_monarchs_of_Nepal')
for a, b in [('narabhupal', 'prithvi'), ('prithvi', 'pratap'), ('pratap', 'rana'), ('rana', 'girvan'), ('girvan', 'rajendra'), ('rajendra', 'surendra'), ('prithvibir', 'tribhuvan'), ('tribhuvan', 'mahendra'), ('mahendra', 'birendra'), ('birendra', 'dipendra'), ('mahendra', 'gyanendra')]:
    g.par('np.' + a, 'np.' + b)
g.fam('np.surendra', 'np.prithvibir')
g.write()
