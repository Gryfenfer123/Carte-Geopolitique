import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(165, 'Italie (Sévères)')
g.notes = ["Nouvel arbre « Sévères » (Rome antique, rattaché à l'Italie). Source : page « Severan dynasty » (anglais).", "Julia Domna et Julia Maesa sont dites sœurs. Élagabal et Sévère Alexandre sont cousins (leurs mères sont les filles de Maesa). Le texte rapporte aussi la rumeur, répandue par Maesa, qu'Élagabal serait un fils illégitime de Caracalla : non retenue comme filiation. Sévère Alexandre : naissance « v. 209 » (année saisie 209)."]
g.tree('IT_SEV', 'ITA', 'Sévères', section_title='Sévères')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('sv.' + code, name, b, d, title, 'Sévères', 'IT_SEV', gnd, True, src=W + page + (' - ' + note if note else ''))
K('sep', 'Septime Sévère', 145, 211, 'Empereur romain (193-211)', 'Severan_dynasty', None, 'h')
K('jdo', 'Julia Domna', None, None, 'Épouse de Septime Sévère', 'Severan_dynasty', None, 'f')
K('car', 'Caracalla', 188, 217, 'Empereur romain (règne 192-217 selon la page)', 'Severan_dynasty', 'fils aîné de Septime Sévère', 'h')
K('get', 'Geta', 189, 211, 'Empereur romain (211)', 'Severan_dynasty', 'fils cadet de Septime Sévère', 'h')
K('jma', 'Julia Maesa', None, None, 'Sœur de Julia Domna', 'Severan_dynasty', None, 'f')
K('jso', 'Julia Soaemias', None, None, "Fille de Maesa, mère d'Élagabal", 'Severan_dynasty', None, 'f')
K('jmm', 'Julia Mamaea', None, None, 'Fille de Maesa, mère de Sévère Alexandre', 'Severan_dynasty', None, 'f')
K('ela', 'Élagabal', 203, 222, 'Empereur romain (218-222)', 'Severan_dynasty', None, 'h')
K('sal', 'Sévère Alexandre', 209, 235, 'Empereur romain (222-235)', 'Severan_dynasty', 'naissance « v. 209 »', 'h')
g.par('sv.sep', 'sv.car')
g.par('sv.sep', 'sv.get')
g.par('sv.jdo', 'sv.car')
g.par('sv.jdo', 'sv.get')
g.par('sv.jma', 'sv.jso')
g.par('sv.jma', 'sv.jmm')
g.par('sv.jso', 'sv.ela')
g.par('sv.jmm', 'sv.sal')
g.fam('sv.jdo', 'sv.jma')
g.sp('sv.sep', 'sv.jdo')
g.write()
