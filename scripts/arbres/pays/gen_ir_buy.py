import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(151, 'Iran (Bouyides)')
g.notes = ["Nouvel arbre « Bouyides » (Iran) : 6 personnes. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Page « Buyid dynasty » : Ali, Hasan et Ahmad fils de Buya ; Muayyad al-Dawla fils de Rukn al-Dawla (Hasan) ; Fakhr al-Dawla frère de Muayyad (lien « famille »). Adud al-Dawla n'est pas ajouté : la page ne donne pas son père. Aucune date de naissance ou de mort."]
g.tree('IR_BUY', 'IRN', 'Bouyides', section_title='Bouyides')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('ib.' + code, name, b, d, title, 'Bouyides', 'IR_BUY', gnd, True, src=W + page + (' - ' + note if note else ''))
K('buya', 'Buya', None, None, 'Père des trois premiers émirs bouyides', 'Buyid_dynasty', "père d'Ali, Hasan et Ahmad", 'h')
K('ali', 'Ali ibn Buya (Imad al-Dawla)', None, None, 'Émir de Fars (934-949)', 'Buyid_dynasty', None, 'h')
K('hasan', 'Hasan ibn Buya (Rukn al-Dawla)', None, None, 'Émir de Ray (935-976)', 'Buyid_dynasty', None, 'h')
K('ahmad', 'Ahmad ibn Buya (Muizz al-Dawla)', None, None, "Émir d'Irak (945-967)", 'Buyid_dynasty', None, 'h')
K('muayyad', 'Muayyad al-Dawla', None, None, 'Émir de Ray puis Hamadan (976-983)', 'Buyid_dynasty', 'fils de Rukn al-Dawla', 'h')
K('fakhr', 'Fakhr al-Dawla', None, None, 'Émir de Ray (976-980 ; 984-997)', 'Buyid_dynasty', 'frère de Muayyad al-Dawla selon la page', 'h')
g.par('ib.buya', 'ib.ali')
g.par('ib.buya', 'ib.hasan')
g.par('ib.buya', 'ib.ahmad')
g.par('ib.hasan', 'ib.muayyad')
g.fam('ib.muayyad', 'ib.fakhr')
g.write()
