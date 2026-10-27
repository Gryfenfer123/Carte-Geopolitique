import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(148, 'Iran (Seldjoukides)')
g.notes = ["Nouvel arbre « Seldjoukides » (Iran) : 9 personnes, de Mikail à Ahmad Sanjar. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Pages lues : Chaghri Beg (989-1060, fils de Mikail, frère de Tughril), Alp Arslan (1029-1072, fils de Chaghri Beg), Malik-Shah I (1055-1092, fils d'Alp Arslan ; fils : Berkyaruq, Mahmud I, Muhammad I Tapar, Ahmad Sanjar), et « Seljuk Empire » (Tughril 990-1063, mort de Sanjar en 1157). Tughril est relié à Chaghri par un lien « famille » (frère) ; Mikail comme père de Chaghri Beg seulement. Les sultans seldjoukides de Roum (Anatolie) ne sont pas dans cet arbre.", 'Dates absentes pour les fils de Malik-Shah sauf la mort de Sanjar.']
g.tree('IR_SEL', 'IRN', 'Seldjoukides', section_title='Seldjoukides')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('ir.' + code, name, b, d, title, 'Seldjoukides', 'IR_SEL', gnd, True, src=W + page + (' - ' + note if note else ''))
K('mikail', 'Mikail', None, None, 'Père de Chaghri Beg', 'Chaghri_Beg', 'père de Chaghri Beg selon la page de Chaghri Beg', 'h')
K('tughril', 'Tughril', 990, 1063, 'Premier sultan seldjoukide (1037-1063)', 'Seljuk_Empire', 'frère de Chaghri Beg', 'h')
K('chaghri', 'Chaghri Beg', 989, 1060, 'Co-fondateur de la dynastie seldjoukide', 'Chaghri_Beg', None, 'h')
K('alp', 'Alp Arslan', 1029, 1072, 'Sultan seldjoukide (1063-1072)', 'Alp_Arslan', 'fils de Chaghri Beg', 'h')
K('malik', 'Malik-Shah I', 1055, 1092, 'Sultan seldjoukide (1072-1092)', 'Malik-Shah_I', "fils d'Alp Arslan", 'h')
K('berk', 'Berkyaruq', None, None, 'Sultan seldjoukide', 'Malik-Shah_I', 'fils de Malik-Shah I', 'h')
K('mahmud', 'Mahmud I', None, None, 'Sultan seldjoukide, proclamé après 1092', 'Seljuk_Empire', 'fils de Malik-Shah I', 'h')
K('tapar', 'Muhammad I Tapar', None, None, "Sultan seldjoukide (jusqu'en 1118)", 'Malik-Shah_I', 'fils de Malik-Shah I', 'h')
K('sanjar', 'Ahmad Sanjar', None, 1157, 'Sultan seldjoukide (1118-1157)', 'Malik-Shah_I', 'fils de Malik-Shah I ; mort en 1157', 'h')
g.par('ir.mikail', 'ir.chaghri')
g.par('ir.chaghri', 'ir.alp')
g.par('ir.alp', 'ir.malik')
g.par('ir.malik', 'ir.berk')
g.par('ir.malik', 'ir.mahmud')
g.par('ir.malik', 'ir.tapar')
g.par('ir.malik', 'ir.sanjar')
g.fam('ir.chaghri', 'ir.tughril')
g.write()
