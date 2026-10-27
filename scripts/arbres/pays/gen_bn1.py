import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(137, "Brunéi (Maison de Bolkiah)")
g.notes = ["Nouvel arbre « Maison de Bolkiah » (Brunéi) : 7 personnes, du sultan Omar Ali Saifuddin II au prince héritier. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Pages lues : Hashim Jalilul Alam Aqamaddin (père Omar Ali Saifuddin II), Muhammad Jamalul Alam II (fils de Hashim), Ahmad Tajuddin et Omar Ali Saifuddien III (fils de Muhammad Jamalul Alam II), Hassanal Bolkiah (fils d'Omar Ali Saifuddien III), Al-Muhtadee Billah (fils de Hassanal Bolkiah). La page d'Omar Ali Saifuddin II ne donne pas sa naissance : laissée vide. Seule la lignée directe est représentée (pas toute la famille).", 'Ahmad Tajuddin n\'a pas de fils cité par sa page (que des filles) : la couronne passe à son frère.']
g.tree('BN_BOL', 'BRN', 'Maison de Bolkiah', section_title='Maison de Bolkiah')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('bn.' + code, name, b, d, title, 'Maison de Bolkiah', 'BN_BOL', 'h', True, src=W + page + (' - ' + note if note else ''))
K('oas2', 'Omar Ali Saifuddin II', None, 1852, 'Sultan de Brunéi (1828-1852)', 'Omar_Ali_Saifuddin_II')
K('hashim', 'Hashim Jalilul Alam Aqamaddin', 1825, 1906, 'Sultan de Brunéi (1885-1906)', 'Hashim_Jalilul_Alam_Aqamaddin')
K('mja2', 'Muhammad Jamalul Alam II', 1889, 1924, 'Sultan de Brunéi (1906-1924)', 'Muhammad_Jamalul_Alam_II')
K('tajuddin', 'Ahmad Tajuddin', 1912, 1950, 'Sultan de Brunéi (1924-1950)', 'Ahmad_Tajuddin')
K('oas3', 'Omar Ali Saifuddien III', 1914, 1986, 'Sultan de Brunéi (1950-1967)', 'Omar_Ali_Saifuddien_III')
K('hassanal', 'Hassanal Bolkiah', 1946, None, 'Sultan de Brunéi (depuis 1967)', 'Hassanal_Bolkiah')
K('muhtadee', 'Al-Muhtadee Billah', 1974, None, 'Prince héritier de Brunéi', 'Al-Muhtadee_Billah')
for a, b in [('oas2','hashim'),('hashim','mja2'),('mja2','tajuddin'),('mja2','oas3'),('oas3','hassanal'),('hassanal','muhtadee')]:
    g.par('bn.' + a, 'bn.' + b)
g.write()
