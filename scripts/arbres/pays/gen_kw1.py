import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(120, "Koweït (Al Sabah)")
g.notes = [
    "Nouvel arbre « Al Sabah » (Koweït) : 15 émirs. Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.",
    "Sabah Ier et Abdullah Ier : pas de page lue (accès refusé) ; Sabah Ier daté d'après la liste des émirs, Abdullah Ier sans dates, lien avec Sabah Ier en « famille » faute de page confirmant la filiation. Muhammad Ier (émir 1892-1896) non saisi : aucune donnée lue.",
    "Lien « famille » (non parent-enfant) : Abdullah II (frère de Mubarak, non confirmé par une page lue) n'est pas saisi non plus.",
    "Dates en année chrétienne telles que la page les donne ; « c. » = approximatif.",
]
g.tree('KW_SAB', 'KWT', 'Al Sabah', section_title='Al Sabah')
P = g.par
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('kw.' + code, name, b, d, title, 'Al Sabah', 'KW_SAB', 'h', True, src=W + page + (' — ' + note if note else ''))
K('sabah1', 'Sabah Ier ben Jaber', 1700, 1762, 'Premier cheikh du Koweït (1752-1762)', 'List_of_emirs_of_Kuwait', 'naissance c. 1700 ; page de la liste des émirs')
K('abdullah1', 'Abdullah Ier ben Sabah', None, None, 'Cheikh du Koweït (1762-1814)', 'List_of_emirs_of_Kuwait', 'dates non lues ; lien avec Sabah Ier en « famille » (père non confirmé par une page lue) ; père de Jaber Ier d\'après la page de Jaber Ier')
K('jaber1', 'Jaber Ier', 1775, 1859, 'Cheikh du Koweït (1814-1859)', 'Jaber_I_Al-Sabah')
K('sabah2', 'Sabah II', 1784, 1866, 'Cheikh du Koweït (1859-1866)', 'Sabah_II_Al-Sabah', 'naissance c. 1784 ; INCOHÉRENT avec Jaber Ier (né 1775, soit 9 ans d\'écart) : à vérifier avec une autre source')
K('abdullah2', 'Abdullah II', 1814, 1892, 'Cheikh du Koweït (1866-1892)', 'Abdullah_II_Al-Sabah', 'naissance c. 1814')
K('mubarak', 'Moubarak le Grand', 1837, 1915, 'Cheikh du Koweït (1896-1915)', 'Mubarak_Al-Sabah', 'naissance c. 1837')
K('jaber2', 'Jaber II', 1860, 1917, 'Cheikh du Koweït (1915-1917)', 'Jaber_II_Al-Sabah')
K('salim', 'Salim al-Moubarak', 1864, 1921, 'Cheikh du Koweït (1917-1921)', 'Salim_Al-Mubarak_Al-Sabah')
K('ahmad', 'Ahmad al-Jaber', 1885, 1950, 'Cheikh du Koweït (1921-1950)', 'Ahmad_Al-Jaber_Al-Sabah')
K('abdullah3', 'Abdullah al-Salim', 1895, 1965, 'Premier émir du Koweït indépendant (1950-1965)', 'Abdullah_Al-Salim_Al-Sabah')
K('sabah3', 'Sabah al-Salim', 1913, 1977, 'Émir du Koweït (1965-1977)', 'Sabah_Al-Salim_Al-Sabah')
K('jaber3', 'Jaber al-Ahmad', 1926, 2006, 'Émir du Koweït (1977-2006)', 'Jaber_Al-Ahmad_Al-Sabah')
K('saad', 'Saad al-Abdullah', 1930, 2008, 'Émir du Koweït (15-24 janvier 2006)', 'Saad_Al-Abdullah_Al-Salim_Al-Sabah')
K('sabah4', 'Sabah al-Ahmad', 1929, 2020, 'Émir du Koweït (2006-2020)', 'Sabah_Al-Ahmad_Al-Jaber_Al-Sabah')
K('nawaf', 'Nawaf al-Ahmad', 1937, 2023, 'Émir du Koweït (2020-2023)', 'Nawaf_Al-Ahmad_Al-Jaber_Al-Sabah')
K('mishal', 'Mishal al-Ahmad', 1940, None, 'Émir du Koweït (depuis 2023)', 'Mishal_Al-Ahmad_Al-Jaber_Al-Sabah')
for a, b in [('abdullah1','jaber1'),('jaber1','sabah2'),('sabah2','abdullah2'),('sabah2','mubarak'),('mubarak','jaber2'),('mubarak','salim'),
             ('jaber2','ahmad'),('salim','abdullah3'),('salim','sabah3'),('abdullah3','saad'),('ahmad','jaber3'),('ahmad','sabah4'),('ahmad','nawaf'),('ahmad','mishal')]:
    P('kw.' + a, 'kw.' + b)
g.fam('kw.sabah1','kw.abdullah1')
g.write()
