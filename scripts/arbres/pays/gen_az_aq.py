import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(156, 'Azerbaïdjan (Aq Qoyunlu)')
g.notes = ["Nouvel arbre « Aq Qoyunlu » (Azerbaïdjan) : 7 personnes. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Tout vient de la page « Aq Qoyunlu » : Khalil, Yaqub, Ughurlu Muhammad et Rustam sont fils d'Uzun Hasan (pour Rustam un passage dit fils de Maqsud) ; Baysungur fils de Yaqub ; Ahmad Bey fils d'Ughurlu Muhammad. Alvand, Sultan Murad, Mohammad et Qasim ne sont pas ajoutés (liens trop vagues). Qara Yuluk Uthman (fondateur) non ajouté : lien avec Uzun Hasan non indiqué. Aucune date de naissance."]
g.tree('AZ_AQQ', 'AZE', 'Aq Qoyunlu', section_title='Aq Qoyunlu')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('aq.' + code, name, b, d, title, 'Aq Qoyunlu', 'AZ_AQQ', gnd, True, src=W + page + (' - ' + note if note else ''))
K('uzun', 'Uzun Hasan', None, 1478, 'Souverain Aq Qoyunlu (1452-1478)', 'Aq_Qoyunlu', "mort au début de 1478 ; pas d'année de naissance sur la page", 'h')
K('khal', 'Khalil Mirza', None, None, 'Souverain Aq Qoyunlu (quelques mois en 1478)', 'Aq_Qoyunlu', "fils d'Uzun Hasan", 'h')
K('yaq', 'Yaqub', None, None, 'Souverain Aq Qoyunlu (1478-1490)', 'Aq_Qoyunlu', "fils d'Uzun Hasan, frère cadet de Khalil", 'h')
K('ugh', 'Ughurlu Muhammad', None, None, "Fils aîné d'Uzun Hasan", 'Aq_Qoyunlu', "fils aîné d'Uzun Hasan", 'h')
K('rus', 'Rustam', None, None, 'Souverain Aq Qoyunlu (1493-1497 ou 1478-1490 selon les passages)', 'Aq_Qoyunlu', "fils d'Uzun Hasan (un passage dit fils de Maqsud)", 'h')
K('bay', 'Baysungur', None, 1493, 'Souverain Aq Qoyunlu (détrôné en 1491)', 'Aq_Qoyunlu', 'fils de Yaqub ; tué en 1493', 'h')
K('ahb', 'Ahmad Bey', None, 1497, 'Souverain Aq Qoyunlu (1497)', 'Aq_Qoyunlu', "fils d'Ughurlu Muhammad ; mort en décembre 1497", 'h')
g.par('aq.uzun', 'aq.khal')
g.par('aq.uzun', 'aq.yaq')
g.par('aq.uzun', 'aq.ugh')
g.par('aq.uzun', 'aq.rus')
g.par('aq.yaq', 'aq.bay')
g.par('aq.ugh', 'aq.ahb')
g.write()
