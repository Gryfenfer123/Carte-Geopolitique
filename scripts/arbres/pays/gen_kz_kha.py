import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(160, 'Kazakhstan (Khanat kazakh)')
g.notes = ['Nouvel arbre « Khanat kazakh » (Kazakhstan). Sources : pages Wikipédia « Kazakh Khanate » et « List of Kazakh khans », notées dans chaque fiche et dans docs/sources/arbres.md.', "Seules les filiations écrites sur la page sont saisies : Kasym fils de Janibek ; Haqnazar fils de Kasym ; Shygai fils d'Adiq Sultan, lui-même fils de Janibek (Adiq non ajouté : lien « famille » Janibek→Shygai) ; Tauekel et Esim fils de Shygai. Les autres khans ne sont pas reliés par la page. Dates de règne de Kerei différentes selon les passages (1456-1473 / 1465-1480)."]
g.tree('KZ_KHA', 'KAZ', 'Khanat kazakh', section_title='Khanat kazakh')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('kz.' + code, name, b, d, title, 'Khanat kazakh', 'KZ_KHA', gnd, True, src=W + page + (' - ' + note if note else ''))
K('ker', 'Kerei Khan', None, None, 'Khan kazakh (1456-1473)', 'Kerei_Khan', None, 'h')
K('jan', 'Janibek Khan', None, None, 'Khan kazakh (1473-1480)', 'Janybek_Khan', None, 'h')
K('kas', 'Kasym Khan', None, None, 'Khan kazakh (1511-1518)', 'Kasym_Khan', 'fils de Janibek', 'h')
K('haq', 'Haqnazar Khan', None, None, 'Khan kazakh (1538-1580)', 'Kazakh_Khanate', 'fils de Kasym', 'h')
K('shy', 'Shygai Khan', None, None, 'Khan kazakh (1580-1582)', 'Kazakh_Khanate', "fils d'Adiq Sultan, petit-fils de Janibek", 'h')
K('tau', 'Tauekel Khan', None, None, 'Khan kazakh (1582-1598)', 'Kazakh_Khanate', 'fils de Shygai', 'h')
K('esi', 'Esim Khan', None, None, 'Khan kazakh (1598-1628)', 'Kazakh_Khanate', 'fils de Shygai', 'h')
g.par('kz.jan', 'kz.kas')
g.par('kz.kas', 'kz.haq')
g.par('kz.shy', 'kz.tau')
g.par('kz.shy', 'kz.esi')
g.fam('kz.jan', 'kz.shy')
g.write()
