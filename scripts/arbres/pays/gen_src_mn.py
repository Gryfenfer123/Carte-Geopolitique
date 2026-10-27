import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *
from src_outil import appliquer

g = Gen(134, "Sources — Gengiskhanides (v84)")
g.sans_repositionnement = True
g.notes = [
    "12 fiches du tableau « Gengiskhanides (Yuan) » (v84, saisi de mémoire) reçoivent l'adresse de leur page Wikipédia (anglais) dans « Notes / biographie » ; dates corrigées quand la page dit autre chose : Djötchi mort c. 1225 (et non 1227), Djaghataï né c. 1184 (et non 1183), Tolui né 1191 (et non 1192), Houlagou né c. 1217 (et non 1218).",
    "Berke (khan de la Horde d'Or, fils de Djötchi) ajouté. Börte, Sorghaghtani Beki, Chabi, Zhenjin et les empereurs Yuan restent NON sourcés : pages non lues dans ce lot (Börte et Sorghaghtani sont seulement citées comme mères dans les pages de leurs fils). Remarque : la page de Djötchi dit que son père biologique était probablement Chilger-Bökö.",
]
g.tree('MN_GEN', 'CHN', 'Gengiskhanides (Yuan)')
W = 'en:'
L = [
 ('gn.genghis', '=', '=', W+'Genghis_Khan', 'naissance c. 1162 ; mort le 18 ou le 25 août 1227'),
 ('gn.jochi', '=', 1225, W+'Jochi', 'naissance c. 1182, mort c. 1225 ; père officiel Gengis Khan, probablement Chilger-Bökö'),
 ('gn.chagatai', 1184, '=', W+'Chagatai_Khan', 'naissance c. 1184'),
 ('gn.ogedei', '=', '=', W+'%C3%96gedei_Khan', 'naissance c. 1186'),
 ('gn.tolui', 1191, '=', W+'Tolui', None),
 ('gn.batu', '=', '=', W+'Batu_Khan', 'naissance c. 1205'),
 ('gn.guyuk', '=', '=', W+'G%C3%BCy%C3%BCk_Khan', None),
 ('gn.mongke', '=', '=', W+'M%C3%B6ngke_Khan', None),
 ('gn.kublai', '=', '=', W+'Kublai_Khan', None),
 ('gn.hulagu', 1217, '=', W+'Hulagu_Khan', 'naissance c. 1217'),
 ('gn.ariq', '=', '=', W+'Ariq_B%C3%B6ke', 'naissance c. 1219'),
]
appliquer(g, L)
g.m('gn.berke', 'Berke', 1207, 1266, 'Khan de la Horde d\'Or (1257-1266)', 'Gengiskhanides', 'MN_GEN', 'h', True, src='https://en.wikipedia.org/wiki/Berke — naissance c. 1207, mort 1266 ou 1267')
g.par('gn.jochi', 'gn.berke')
g.write()
