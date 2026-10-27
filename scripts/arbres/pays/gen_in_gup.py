import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(158, 'Inde (Gupta)')
g.notes = ["Nouvel arbre « Gupta » (Inde). Chaque fiche porte l'adresse de la page Wikipédia (anglais) ; sources aussi dans docs/sources/arbres.md.", "Pages « Gupta Empire » et « List of Gupta emperors » : aucune date de naissance ou de mort n'est donnée, seulement des dates de règne. Ramagupta (« frère de Chandragupta » selon la page, sans autre précision), Purugupta (« frère » de Skandagupta), Budhagupta et Narasimhagupta ne sont pas rattachés à un père par la page : liens non saisis ou notés."]
g.tree('IN_GUP', 'IND', 'Gupta', section_title='Gupta')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('gu.' + code, name, b, d, title, 'Gupta', 'IN_GUP', gnd, True, src=W + page + (' - ' + note if note else ''))
K('gup', 'Sri Gupta', None, None, 'Fondateur de la dynastie (fin IIIe s.)', 'Srigupta', None, 'h')
K('gha', 'Ghatotkacha', None, None, 'Roi gupta (v. 280/290-319)', 'List_of_Gupta_emperors', None, 'h')
K('ch1', 'Chandragupta Ier', None, None, 'Empereur gupta (319-335)', 'Chandragupta_I', None, 'h')
K('sam', 'Samudragupta', None, None, 'Empereur gupta (335-375)', 'Samudragupta', None, 'h')
K('ch2', 'Chandragupta II', None, None, 'Empereur gupta (375-415)', 'Candra_Gupta_II', None, 'h')
K('ku1', 'Kumaragupta Ier', None, None, 'Empereur gupta (415-455)', 'Gupta_Empire', None, 'h')
K('ska', 'Skandagupta', None, None, 'Empereur gupta (455-467)', 'Gupta_Empire', None, 'h')
K('pur', 'Purugupta', None, None, 'Empereur gupta (467-473)', 'Gupta_Empire', 'présenté comme « frère » de Skandagupta (même ascendance), père non indiqué', 'h')
K('bud', 'Budhagupta', None, None, 'Empereur gupta (476-495)', 'Gupta_Empire', 'père non indiqué', 'h')
K('nar', 'Narasimhagupta Baladitya', None, None, 'Empereur gupta (495-530)', 'Gupta_Empire', 'père non indiqué', 'h')
K('vaj', 'Vajra', None, None, 'Fils de Narasimhagupta', 'Gupta_Empire', None, 'h')
g.par('gu.gup', 'gu.gha')
g.par('gu.gha', 'gu.ch1')
g.par('gu.ch1', 'gu.sam')
g.par('gu.sam', 'gu.ch2')
g.par('gu.ch2', 'gu.ku1')
g.par('gu.ku1', 'gu.ska')
g.par('gu.nar', 'gu.vaj')
g.fam('gu.ska', 'gu.pur')
g.write()
