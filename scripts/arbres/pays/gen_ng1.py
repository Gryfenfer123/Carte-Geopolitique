import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(153, 'Nigeria (Oba du Bénin)')
g.notes = ["Nouvel arbre « Oba du Bénin » (Nigeria) : 3 personnes seulement. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Page « Eweka dynasty » : Uwakhuahen et Ehenmihen sont fils d'Eweka I ; les dates dépendent de la chronologie d'Egharevba (naissance d'Eweka I vers 1171, couronnement vers 1200 ; l'historien Roese propose vers 1320). Les autres Oba (Ewuare, Esigie, Ozolua…) n'ont pas de parenté ni de date sur la page : non ajoutés. Dynastie traditionnelle, dates très incertaines."]
g.tree('NG_EWE', 'NGA', 'Oba du Bénin', section_title='Oba du Bénin')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('ng.' + code, name, b, d, title, 'Oba du Bénin', 'NG_EWE', gnd, True, src=W + page + (' - ' + note if note else ''))
K('eweka', 'Eweka I', None, None, "Premier Oba de la dynastie d'Edo (couronné vers 1200)", 'Eweka_dynasty', "naissance vers 1171 selon la chronologie d'Egharevba ; père traditionnel : Oranmiyan", 'h')
K('uwa', 'Uwakhuahen', None, None, 'Oba du Bénin (vers 1230)', 'Eweka_dynasty', "fils aîné d'Eweka I", 'h')
K('ehen', 'Ehenmihen', None, None, 'Oba du Bénin', 'Eweka_dynasty', "autre fils d'Eweka I ; succède à Uwakhuahen", 'h')
g.par('ng.eweka', 'ng.uwa')
g.par('ng.eweka', 'ng.ehen')
g.write()
