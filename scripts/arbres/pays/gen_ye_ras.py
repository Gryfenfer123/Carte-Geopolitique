import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(157, 'Yémen (Rasoulides)')
g.notes = ["Nouvel arbre « Rasoulides » (Yémen) : 4 personnes en deux couples père-fils. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Page « Rasulid dynasty » : seules deux filiations sont indiquées (Yusuf I fils d'Umar I ; Ismail I fils d'al-Abbas). Les autres sultans ne sont pas reliés par la page et ne sont pas ajoutés. Les dates de règne de la liste et du texte divergent parfois."]
g.tree('YE_RAS', 'YEM', 'Rasoulides', section_title='Rasoulides')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('ra.' + code, name, b, d, title, 'Rasoulides', 'YE_RAS', gnd, True, src=W + page + (' - ' + note if note else ''))
K('umar1', 'Al-Mansur Umar I', None, 1249, 'Premier sultan rasoulide du Yémen (1229-1249)', 'Rasulid_dynasty', 'assassiné en 1249', 'h')
K('yus1', 'Al-Muzaffar Yusuf I', None, 1295, 'Sultan rasoulide (1249-1295)', 'Rasulid_dynasty', "fils d'Umar I", 'h')
K('abb', 'Al-Afdal al-Abbas', None, None, 'Sultan rasoulide (1363-1377)', 'Rasulid_dynasty', None, 'h')
K('ism1', 'Al-Ashraf Ismail I', None, None, 'Sultan rasoulide (1377-1400)', 'Rasulid_dynasty', "fils d'al-Abbas ; fin de règne 1400 ou 1401 selon la page", 'h')
g.par('ra.umar1', 'ra.yus1')
g.par('ra.abb', 'ra.ism1')
g.write()
