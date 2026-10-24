import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(128, "Irlande (Dál gCais / Ua Briain)")
g.notes = ["Nouvel arbre « Dál gCais / Ua Briain » (Irlande) : 7 personnes autour de Brian Boru. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Pages lues : Brian Boru, Toirdelbach Ua Briain, Muirchertach Ua Briain, liste des grands rois d'Irlande. Cennétig, Murchad et Tadc sont sans dates (aucune page lue pour eux). Donnchad : mort 1064 d'après la liste des grands rois.", 'Autres fils de Brian cités mais non saisis : Conchobar, Flann, Domhnall.']
g.tree('IE_BRI', 'IRL', 'Dál gCais', section_title='Dál gCais')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('ie.' + code, name, b, d, title, 'Dál gCais', 'IE_BRI', 'h', True, src=W + page + (' - ' + note if note else ''))
K('cennetig', 'Cennétig mac Lorcáin', None, None, 'Roi de Thomond, père de Brian Boru', 'Brian_Boru')
K('brian', 'Brian Boru', 941, 1014, "Grand roi d'Irlande (1002-1014)", 'Brian_Boru', 'naissance c. 941 ; mort 23 avril 1014')
K('murchad', 'Murchad mac Briain', None, None, 'Fils aîné de Brian Boru', 'Brian_Boru')
K('donnchad', 'Donnchad mac Briain', None, 1064, 'Roi de Munster, fils de Brian Boru', 'Brian_Boru', "mort 1064 d'après la liste des grands rois d'Irlande")
K('tadc', 'Tadc mac Briain', None, None, 'Fils de Brian Boru, père de Toirdelbach', 'Brian_Boru')
K('toirdelbach', 'Toirdelbach Ua Briain', 1009, 1086, 'Roi de Munster, grand roi avec opposition', 'Toirdelbach_Ua_Briain')
K('muirchertach', 'Muirchertach Ua Briain', 1050, 1119, 'Roi de Munster, grand roi avec opposition', 'Muirchertach_Ua_Briain', 'naissance c. 1050')
for a, b in [('cennetig', 'brian'), ('brian', 'murchad'), ('brian', 'donnchad'), ('brian', 'tadc'), ('tadc', 'toirdelbach'), ('toirdelbach', 'muirchertach')]:
    g.par('ie.' + a, 'ie.' + b)
g.write()
