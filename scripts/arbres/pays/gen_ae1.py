import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(123, "Émirats arabes unis (Al Nahyan)")
g.notes = ["Nouvel arbre « Al Nahyan » (Abou Dhabi) : 15 dirigeants. Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", 'Pages individuelles lues : Zayed ben Sultan et Khalifa ben Zayed ; les autres fiches viennent du tableau des dirigeants de la page « House of Nahyan ».', "Dhiyab ben Isa : son père Isa n'est pas nommé dans la page (non saisi). Dates inconnues laissées vides.", 'Dates en année chrétienne telles que la page les donne.']
g.tree('AE_NAH', 'ARE', 'Al Nahyan', section_title='Al Nahyan')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('ae.' + code, name, b, d, title, 'Al Nahyan', 'AE_NAH', 'h', True, src=W + page + (' - ' + note if note else ''))
K('dhiyab', 'Dhiyab ben Isa', 1700, 1793, "Cheikh d'Abou Dhabi (1761-1793)", 'House_of_Nahyan')
K('shakhbutD', 'Shakhbut ben Dhiyab', None, None, "Cheikh d'Abou Dhabi (1793-1816)", 'House_of_Nahyan')
K('muhammad', 'Muhammad ben Shakhbut', None, None, "Cheikh d'Abou Dhabi (1816-1818)", 'House_of_Nahyan')
K('tahnun', 'Tahnun ben Shakhbut', None, 1833, "Cheikh d'Abou Dhabi (1818-1833)", 'House_of_Nahyan')
K('khalifaS', 'Khalifa ben Shakhbut', None, 1845, "Cheikh d'Abou Dhabi (1833-1845)", 'House_of_Nahyan')
K('saeed', 'Saïd ben Tahnun', None, 1855, "Cheikh d'Abou Dhabi (1845-1855)", 'House_of_Nahyan')
K('zayed1', 'Zayed ben Khalifa (Zayed le Grand)', 1835, 1909, "Cheikh d'Abou Dhabi (1855-1909)", 'House_of_Nahyan')
K('tahnoun', 'Tahnoun ben Zayed', 1857, 1912, "Cheikh d'Abou Dhabi (1909-1912)", 'House_of_Nahyan')
K('hamdan', 'Hamdan ben Zayed', None, 1922, "Cheikh d'Abou Dhabi (1912-1922)", 'House_of_Nahyan')
K('sultan', 'Sultan ben Zayed', None, 1926, "Cheikh d'Abou Dhabi (1922-1926)", 'House_of_Nahyan')
K('saqr', 'Saqr ben Zayed', None, 1928, "Cheikh d'Abou Dhabi (1926-1928)", 'House_of_Nahyan')
K('shakhbutS', 'Shakhbut ben Sultan', 1905, 1989, "Cheikh d'Abou Dhabi (1928-1966)", 'House_of_Nahyan')
K('zayed2', 'Zayed ben Sultan', 1918, 2004, 'Premier président des Émirats arabes unis (1971-2004)', 'Zayed_bin_Sultan_Al_Nahyan')
K('khalifa', 'Khalifa ben Zayed', 1948, 2022, 'Président des Émirats arabes unis (2004-2022)', 'Khalifa_bin_Zayed_Al_Nahyan')
K('mohamed', 'Mohamed ben Zayed', 1961, None, 'Président des Émirats arabes unis (depuis 2022)', 'House_of_Nahyan')
for a, b in [('dhiyab', 'shakhbutD'), ('shakhbutD', 'muhammad'), ('shakhbutD', 'tahnun'), ('shakhbutD', 'khalifaS'), ('tahnun', 'saeed'), ('khalifaS', 'zayed1'), ('zayed1', 'tahnoun'), ('zayed1', 'hamdan'), ('zayed1', 'sultan'), ('zayed1', 'saqr'), ('sultan', 'shakhbutS'), ('sultan', 'zayed2'), ('zayed2', 'khalifa'), ('zayed2', 'mohamed')]:
    g.par('ae.' + a, 'ae.' + b)
g.write()
