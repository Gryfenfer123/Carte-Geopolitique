import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(159, 'Inde (Maurya)')
g.notes = ['Nouvel arbre « Maurya » (Inde). Sources : pages Wikipédia (anglais) notées dans chaque fiche et dans docs/sources/arbres.md.', "Aucune date de naissance/mort n'est donnée par les pages. Dasharatha est décrit comme petit-fils d'Ashoka sans nom de père sur la page : relié à Ashoka par un lien « famille ». Samprati est « fils de Kunala » (fils d'Ashoka, non ajouté) et petit-fils d'Ashoka : lien « famille ». Les dates de règne d'Ashoka varient selon les passages."]
g.tree('IN_MAU', 'IND', 'Maurya', section_title='Maurya')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('mu.' + code, name, b, d, title, 'Maurya', 'IN_MAU', gnd, True, src=W + page + (' - ' + note if note else ''))
K('chm', 'Chandragupta Maurya', None, None, "Fondateur de l'empire maurya (v. 321-298 av. J.-C.)", 'Chandragupta_Maurya', None, 'h')
K('bin', 'Bindusara', None, None, 'Empereur maurya (v. 298-272 av. J.-C.)', 'Bindusara', None, 'h')
K('ash', 'Ashoka', None, None, 'Empereur maurya (268-232 av. J.-C.)', 'Ashoka_Maurya_The_Great', None, 'h')
K('das', 'Dasharatha Maurya', None, None, 'Empereur maurya (232-224 av. J.-C.)', 'Dasharatha_Maurya', "petit-fils d'Ashoka", 'h')
K('sap', 'Samprati', None, None, 'Empereur maurya (224-215 av. J.-C.)', 'Maurya_Empire', "fils de Kunala (fils d'Ashoka), petit-fils d'Ashoka", 'h')
g.par('mu.chm', 'mu.bin')
g.par('mu.bin', 'mu.ash')
g.fam('mu.ash', 'mu.das')
g.fam('mu.ash', 'mu.sap')
g.write()
