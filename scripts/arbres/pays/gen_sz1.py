import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(140, "Eswatini (Dlamini)")
g.notes = ["Nouvel arbre « Rois d'Eswatini » : 4 personnes, de Mbandzeni à Mswati III. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Pages lues : Ngwane V/Bhunu (fils de Mbandzeni, père de Sobhuza II), liste des monarques d'Eswatini (Sobhuza II 1899-1982 fils de Ngwane V ; Mswati III né en 1968, fils de Sobhuza II). Les rois antérieurs ne sont pas liés : la liste ne donne ni dates ni pères. Naissance de Mbandzeni inconnue.", 'Bhunu règne 1895-1899 selon la liste (mère régente Labotsibeni).']
g.tree('SZ_DLA', 'SWZ', 'Rois d\'Eswatini', section_title="Rois d'Eswatini")
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('sz.' + code, name, b, d, title, "Rois d'Eswatini", 'SZ_DLA', 'h', True, src=W + page + (' - ' + note if note else ''))
K('mbandzeni', 'Mbandzeni', None, None, "Roi d'Eswatini (1875-1889)", 'Ngwane_V', 'père de Bhunu selon la page de Ngwane V ; dates de règne : liste des monarques')
K('bhunu', 'Bhunu (Ngwane V)', 1876, 1899, "Roi d'Eswatini (1895-1899)", 'Ngwane_V')
K('sobhuza2', 'Sobhuza II', 1899, 1982, "Roi d'Eswatini (1921-1982)", 'List_of_monarchs_of_Eswatini', 'règne effectif depuis 1921, roi à partir de 1968')
K('mswati3', 'Mswati III', 1968, None, "Roi d'Eswatini (depuis 1986)", 'List_of_monarchs_of_Eswatini')
for a, b in [('mbandzeni','bhunu'),('bhunu','sobhuza2'),('sobhuza2','mswati3')]:
    g.par('sz.' + a, 'sz.' + b)
g.write()
