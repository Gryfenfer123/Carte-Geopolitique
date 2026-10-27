import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(144, 'Madagascar (Merina)')
g.notes = ["Nouvel arbre « Monarchie merina » (Madagascar) : 7 personnes, d'Andrianampoinimerina à Ranavalona III. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Toutes les données viennent de la page « List of Imerina monarchs ». Cette page ne donne ni père ni mère pour la plupart des rois (donc les rois avant Andrianampoinimerina ne sont pas dans l'arbre). Elle indique : Radama I fils d'Andrianampoinimerina ; Ranavalona I épouse de Radama I ; Radama II dont Ranavalona I est « parent » (sexe non précisé) ; Rasoherina et Ranavalona II épouses de Radama II ; Ranavalona III nièce de Ranavalona II et petite-fille de Radama I (ligne exacte non donnée : lien « famille »).", 'Ranavalona I est donnée comme mère de Radama II par lien « parent » : formulation de la page ambiguë, à vérifier.']
g.tree('MG_MER', 'MDG', 'Monarchie merina', section_title='Monarchie merina')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('mg.' + code, name, b, d, title, 'Monarchie merina', 'MG_MER', gnd, True, src=W + page + (' - ' + note if note else ''))
K('andr', 'Andrianampoinimerina', 1745, None, "Roi d'Imerina (1787-1810)", 'List_of_Imerina_monarchs', "naissance 1745 (indiquée seulement dans l'encadré de la page)", 'h')
K('radama1', 'Radama I', 1793, 1828, 'Roi de Madagascar (1810-1828)', 'List_of_Imerina_monarchs', None, 'h')
K('rana1', 'Ranavalona I', 1778, 1861, 'Reine de Madagascar (1828-1861)', 'List_of_Imerina_monarchs', 'épouse de Radama I selon la liste', 'f')
K('radama2', 'Radama II', 1829, 1863, 'Roi de Madagascar (1861-1863)', 'List_of_Imerina_monarchs', 'assassiné ; Ranavalona I figure comme parent', 'h')
K('raso', 'Rasoherina', 1814, 1868, 'Reine de Madagascar (1863-1868)', 'List_of_Imerina_monarchs', 'épouse de Radama II selon la liste', 'f')
K('rana2', 'Ranavalona II', 1829, 1883, 'Reine de Madagascar (1868-1883)', 'List_of_Imerina_monarchs', 'épouse de Radama II selon la liste', 'f')
K('rana3', 'Ranavalona III', 1861, 1917, 'Dernière reine de Madagascar (1883-1897)', 'List_of_Imerina_monarchs', 'nièce de Ranavalona II et petite-fille de Radama I selon la liste', 'f')
g.par('mg.andr', 'mg.radama1')
g.par('mg.rana1', 'mg.radama2')
g.fam('mg.rana2', 'mg.rana3')
g.fam('mg.radama1', 'mg.rana3')
g.sp('mg.radama1', 'mg.rana1')
g.sp('mg.radama2', 'mg.raso')
g.sp('mg.radama2', 'mg.rana2')
g.write()
