import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(121, "Qatar (Al Thani)")
g.notes = [
    "Nouvel arbre « Al Thani » (Qatar) : 8 émirs de Mohammed ben Thani à Tamim. Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.",
    "Non saisis (aucune page lue) : Thani ben Mohammed (père de Mohammed ben Thani), Hamad ben Abdullah (père de Khalifa), Ahmad ben Mohammed. Khalifa (cousin d'Ahmad, mais non confirmé par une page lue) forme donc une branche séparée dans l'arbre.",
    "Dates en année chrétienne telles que la page les donne ; « c. » = approximatif. Hamad ben Khalifa : la page indique 1952–2026.",
]
g.tree('QA_THA', 'QAT', 'Al Thani', section_title='Al Thani')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('qa.' + code, name, b, d, title, 'Al Thani', 'QA_THA', 'h', True, src=W + page + (' — ' + note if note else ''))
K('mohammed', 'Mohammed ben Thani', 1788, 1878, 'Cheikh de Doha, fondateur de la dynastie', 'Mohammed_bin_Thani', 'naissance c. 1788 ; règne 1851-1878 (l\'encadré de succession dit 1876)')
K('jassim', 'Jassim ben Mohammed', 1825, 1913, 'Fondateur de l\'État du Qatar (1878-1913)', 'Jassim_bin_Mohammed_Al_Thani', 'naissance c. 1825')
K('abdullah', 'Abdullah ben Jassim', 1880, 1957, 'Cheikh du Qatar (1913-1949)', 'Abdullah_bin_Jassim_Al_Thani')
K('ali', 'Ali ben Abdullah', 1895, 1974, 'Cheikh du Qatar (1949-1960)', 'Ali_bin_Abdullah_Al_Thani')
K('ahmad', 'Ahmad ben Ali', 1922, 1977, 'Émir du Qatar (1960-1972)', 'Ahmad_bin_Ali_Al_Thani')
K('khalifa', 'Khalifa ben Hamad', 1932, 2016, 'Émir du Qatar (1972-1995)', 'Khalifa_bin_Hamad_Al_Thani', 'père Hamad ben Abdullah (non saisi)')
K('hamad', 'Hamad ben Khalifa', 1952, 2026, 'Émir du Qatar (1995-2013)', 'Hamad_bin_Khalifa_Al_Thani')
K('tamim', 'Tamim ben Hamad', 1980, None, 'Émir du Qatar (depuis 2013)', 'Tamim_bin_Hamad_Al_Thani')
for a, b in [('mohammed','jassim'),('jassim','abdullah'),('abdullah','ali'),('ali','ahmad'),('khalifa','hamad'),('hamad','tamim')]:
    g.par('qa.' + a, 'qa.' + b)
g.write()
