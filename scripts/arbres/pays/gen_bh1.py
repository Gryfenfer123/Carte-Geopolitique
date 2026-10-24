import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(122, "Bahreïn (Al Khalifa)")
g.notes = ["Nouvel arbre « Al Khalifa » (Bahreïn) : 12 dirigeants. Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", 'Pages individuelles lues : Isa ben Ali et Isa ben Salman ; les autres fiches viennent du tableau des dirigeants de la page « House of Khalifa », qui ne donne les dates de vie que pour Isa ben Ali, Hamad (1872-1942), Salman (1894-1961), Isa ben Salman et le roi Hamad.', 'Isa ben Salman : naissance 1933 (sa page) contre 1931 (tableau) ; 1933 retenu. Le tableau précise que les deux Hamad sont deux personnes. Le tableau donne seulement « Khalifa » comme père de Muhammad et Ali : lu comme Khalifa ben Salman (non vérifié).', 'Dates en année chrétienne telles que la page les donne.']
g.tree('BH_KHA', 'BHR', 'Al Khalifa', section_title='Al Khalifa')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('bh.' + code, name, b, d, title, 'Al Khalifa', 'BH_KHA', 'h', True, src=W + page + (' - ' + note if note else ''))
K('ahmad', 'Ahmad ben Muhammad (al-Fateh)', None, 1795, 'Premier hakim de Bahreïn (1783-1795)', 'House_of_Khalifa', 'mort 1795 (tableau) ou 1796 (texte de la page)')
K('salman1', 'Salman ben Ahmad', None, None, 'Co-régent de Bahreïn (1795-1825)', 'House_of_Khalifa')
K('abdullah', 'Abdullah ben Ahmad', None, None, 'Co-régent de Bahreïn (1795-1843)', 'House_of_Khalifa')
K('khalifa', 'Khalifa ben Salman', None, None, 'Co-régent de Bahreïn (1825-1834)', 'House_of_Khalifa')
K('muhammad', 'Muhammad ben Khalifa', None, None, 'Hakim de Bahreïn (1834-1868)', 'House_of_Khalifa')
K('ali', 'Ali ben Khalifa', None, None, 'Hakim de Bahreïn (1868-1869)', 'House_of_Khalifa')
K('muhammadA', 'Muhammad ben Abdullah', None, 1877, 'Hakim de Bahreïn (sept.-déc. 1869)', 'House_of_Khalifa')
K('isa1', 'Isa ben Ali', 1848, 1932, 'Hakim de Bahreïn (1869-1923)', 'Isa_bin_Ali_Al_Khalifa')
K('hamad1', 'Hamad ben Isa', 1872, 1942, 'Hakim de Bahreïn (1923-1942)', 'House_of_Khalifa')
K('salman2', 'Salman ben Hamad', 1894, 1961, 'Hakim de Bahreïn (1942-1961)', 'House_of_Khalifa')
K('isa2', 'Isa ben Salman', 1933, 1999, 'Émir de Bahreïn (1961-1999)', 'Isa_bin_Salman_Al_Khalifa')
K('hamad2', 'Hamad ben Isa (roi)', 1950, None, 'Roi de Bahreïn (depuis 1999)', 'House_of_Khalifa')
for a, b in [('ahmad', 'salman1'), ('ahmad', 'abdullah'), ('salman1', 'khalifa'), ('khalifa', 'muhammad'), ('khalifa', 'ali'), ('abdullah', 'muhammadA'), ('ali', 'isa1'), ('isa1', 'hamad1'), ('hamad1', 'salman2'), ('salman2', 'isa2'), ('isa2', 'hamad2')]:
    g.par('bh.' + a, 'bh.' + b)
g.write()
