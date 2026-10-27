import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(152, 'Rwanda (Bami)')
g.notes = ["Nouvel arbre « Bami du Rwanda » : 5 personnes, de Mutara II à Mutara III. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Pages lues : Mutara II (père de Rwabugiri d'après la page de Rwabugiri ; sa propre page ne nomme pas son père), Kigeli IV Rwabugiri (fils de Mutara II ; fils : Musinga biologique, Rutarindwa adopté), Rutarindwa (sa page : père Rwabugiri), Musinga (1883-1944), Mutara III (1911-1959, fils de Musinga). Rutarindwa est relié comme fils (la page de Rwabugiri précise « adopté »). Kigeli V Ndahindurwa, demi-frère de Mutara III, n'est pas ajouté."]
g.tree('RW_BAM', 'RWA', 'Bami du Rwanda', section_title='Bami du Rwanda')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('rw.' + code, name, b, d, title, 'Bami du Rwanda', 'RW_BAM', gnd, True, src=W + page + (' - ' + note if note else ''))
K('mut2', 'Mutara II Rwogera', None, 1867, 'Mwami du Rwanda (1845-1867)', 'Mutara_II_of_Rwanda', 'père de Rwabugiri selon la page de Kigeli IV Rwabugiri ; mort en 1867', 'h')
K('rwab', 'Kigeli IV Rwabugiri', 1840, 1895, 'Mwami du Rwanda (1867-1895)', 'Kigeli_IV_Rwabugiri', 'naissance vers 1840 ; mort en septembre 1895', 'h')
K('rut', 'Mibambwe IV Rutarindwa', None, 1896, 'Mwami du Rwanda (1895-1896)', 'Mibambwe_IV_Rutarindwa', 'fils adoptif de Rwabugiri selon la page de Rwabugiri ; sa propre page le dit « fils » ; mort en décembre 1896', 'h')
K('mus', 'Yuhi V Musinga', 1883, 1944, 'Mwami du Rwanda (1896-1931)', 'Yuhi_Musinga', 'fils biologique de Rwabugiri selon la page de Rwabugiri', 'h')
K('mut3', 'Mutara III Rudahigwa', 1911, 1959, 'Mwami du Rwanda (1931-1959)', 'Mutara_III_Rudahigwa', 'fils de Musinga', 'h')
g.par('rw.mut2', 'rw.rwab')
g.par('rw.rwab', 'rw.rut')
g.par('rw.rwab', 'rw.mus')
g.par('rw.mus', 'rw.mut3')
g.write()
