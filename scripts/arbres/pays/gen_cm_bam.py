import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(161, 'Cameroun (Bamoun)')
g.notes = ['Nouvel arbre « Bamoun » (Cameroun). Sources : pages Wikipédia « List of rulers of the Bamum » et « Ibrahim Njoya », notées dans chaque fiche et dans docs/sources/arbres.md.', 'Seules les filiations écrites sur les pages sont saisies : Njoya fils de Nsangou ; Seidou Njimoluh Njoya fils de Njoya ; Ibrahim Mbombo Njoya petit-fils de Njoya (père non vérifié ici : lien « famille »). Les rois plus anciens (Nchare Yen…) sont dans la liste sans parenté : non ajoutés. Njoya : naissance c. 1860, mort c. 1933 ; âge au décès incohérent entre infobox et texte.']
g.tree('CM_BAM', 'CMR', 'Bamoun', section_title='Bamoun')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('bam.' + code, name, b, d, title, 'Bamoun', 'CM_BAM', gnd, True, src=W + page + (' - ' + note if note else ''))
K('nsa', 'Nsangou', None, None, 'Mfon des Bamoun (1865-1884)', 'List_of_rulers_of_the_Bamum', 'père de Njoya ; liste : règne 1865-1884 (date de mort non indiquée)', 'h')
K('njo', 'Ibrahim Njoya', 1860, 1933, 'Mfon des Bamoun (1889-1931/33)', 'Ibrahim_Njoya', 'naissance et mort « c. »', 'h')
K('sei', 'Seidou Njimoluh Njoya', None, None, 'Mfon des Bamoun (1933-1992)', 'Seidou_Njimoluh_Njoya', 'fils de Njoya', 'h')
K('mbo', 'Ibrahim Mbombo Njoya', None, None, 'Mfon des Bamoun (1992-2021)', 'Ibrahim_Mbombo_Njoya', 'petit-fils de Njoya', 'h')
g.par('bam.nsa', 'bam.njo')
g.par('bam.njo', 'bam.sei')
g.fam('bam.njo', 'bam.mbo')
g.write()
