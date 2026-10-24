import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(127, "Croatie (Trpimirović)")
g.notes = ["Nouvel arbre « Trpimirović » (Croatie) : 16 ducs et rois croates (845-1091). Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", 'Aucune date de naissance dans les pages ; seules les années de règne et deux morts (Zdeslav 879, Étienne II 1091) sont données. Les fiches sont donc sans dates de vie : les règnes sont dans le titre. La page précise que la chronologie des IXe-Xe siècles est contestée.', 'Liens parent-enfant retenus seulement quand les pages le disent. Liens « famille » (non parent-enfant) : Tomislav (« peut-être fils de Muncimir »), Trpimir II (« frère cadet ou fils de Tomislav »), Demetrius Zvonimir (cousin de Pierre Krešimir IV), Étienne II (neveu de Pierre Krešimir IV). Domagoj (autre dynastie) non saisi.', "Michel Krešimir II et Miroslav sont frères ; les deux pages donnent aussi Gojslav et Krešimir III comme frères de Svetoslav Suronja, fils d'Étienne Držislav."]
g.tree('HR_TRP', 'HRV', 'Trpimirović', section_title='Trpimirović')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('hr.' + code, name, b, d, title, 'Trpimirović', 'HR_TRP', 'h', True, src=W + page + (' - ' + note if note else ''))
K('trpimir1', 'Trpimir Ier', None, None, 'Duc de Croatie, fondateur de la dynastie (c. 845-864)', 'List_of_dukes_and_kings_of_Croatia')
K('zdeslav', 'Zdeslav', None, 879, 'Duc de Croatie (864 ; 878-879)', 'List_of_dukes_and_kings_of_Croatia', 'mort en mai 879 (tué par Branimir)')
K('muncimir', 'Muncimir', None, None, 'Duc de Croatie (892-910)', 'List_of_dukes_and_kings_of_Croatia')
K('tomislav', 'Tomislav', None, None, 'Premier roi de Croatie (925-928)', 'List_of_dukes_and_kings_of_Croatia')
K('trpimir2', 'Trpimir II', None, None, 'Roi de Croatie (928-935)', 'List_of_dukes_and_kings_of_Croatia')
K('kresimir1', 'Krešimir Ier', None, None, 'Roi de Croatie (935-945)', 'List_of_dukes_and_kings_of_Croatia')
K('miroslav', 'Miroslav', None, None, 'Roi de Croatie (945-949)', 'List_of_dukes_and_kings_of_Croatia')
K('kresimir2', 'Michel Krešimir II', None, None, 'Roi de Croatie (949-969)', 'List_of_dukes_and_kings_of_Croatia')
K('drzislav', 'Étienne Držislav', None, None, 'Roi de Croatie (969-997)', 'List_of_dukes_and_kings_of_Croatia', 'fils de Michel Krešimir II selon la liste des ducs et rois')
K('svetoslav', 'Svetoslav Suronja', None, None, 'Roi de Croatie (997-1000)', 'List_of_dukes_and_kings_of_Croatia')
K('gojslav', 'Gojslav', None, None, 'Roi de Croatie (1000-1020)', 'List_of_dukes_and_kings_of_Croatia')
K('kresimir3', 'Krešimir III', None, None, 'Roi de Croatie (1000-1030)', 'List_of_dukes_and_kings_of_Croatia')
K('stephen1', 'Étienne Ier', None, None, 'Roi de Croatie (1030-1058)', 'List_of_dukes_and_kings_of_Croatia')
K('petar', 'Pierre Krešimir IV', None, None, 'Roi de Croatie (1058-1074)', 'List_of_dukes_and_kings_of_Croatia')
K('zvonimir', 'Demetrius Zvonimir', None, None, 'Roi de Croatie (1075-1089)', 'List_of_dukes_and_kings_of_Croatia')
K('stephen2', 'Étienne II', None, 1091, 'Dernier roi de la dynastie (1089-1091)', 'List_of_dukes_and_kings_of_Croatia')
for a, b in [('trpimir1', 'zdeslav'), ('trpimir1', 'muncimir'), ('kresimir1', 'miroslav'), ('trpimir2', 'kresimir1'), ('kresimir2', 'drzislav'), ('drzislav', 'svetoslav'), ('drzislav', 'gojslav'), ('drzislav', 'kresimir3'), ('kresimir3', 'stephen1'), ('stephen1', 'petar')]:
    g.par('hr.' + a, 'hr.' + b)
g.fam('hr.miroslav', 'hr.kresimir2')
g.fam('hr.muncimir', 'hr.tomislav')
g.fam('hr.tomislav', 'hr.trpimir2')
g.fam('hr.petar', 'hr.zvonimir')
g.fam('hr.petar', 'hr.stephen2')
g.write()
