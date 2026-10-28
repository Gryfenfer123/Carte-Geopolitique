import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(170, 'Afghanistan (Ghurides)')
g.notes = ['Nouvel arbre « Ghurides » (Afghanistan). Sources : pages Wikipédia « Ghurid dynasty » et « Muhammad of Ghor » (anglais).', "Seules les relations écrites sur les pages sont saisies : Sam Ier père de Ghiyath al-Din Muhammad et de Muhammad de Ghor ; Sayf al-Din Muhammad fils d'Ala al-Din Husayn ; Sayf al-Din Suri, Qutb al-Din Muhammad, Sam Ier et Ala al-Din Husayn sont dits frères (liens « famille » avec Sayf al-Din Suri) ; Fakhr al-Din Masud « oncle » de Ghiyath al-Din (lien « famille »). Naissance de Muhammad de Ghor : « vers 1144 » (estimation de la page)."]
g.tree('AF_GHU', 'AFG', 'Ghurides', section_title='Ghurides')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('gh.' + code, name, b, d, title, 'Ghurides', 'AF_GHU', gnd, True, src=W + page + (' - ' + note if note else ''))
K('suri', 'Sayf al-Din Suri', None, None, 'Souverain ghouride (1146-1149)', 'Ghurid_dynasty', "frère de Qutb al-Din Muhammad, de Baha al-Din Sam Ier et d'Ala al-Din Husayn", 'h')
K('qutb', 'Qutb al-Din Muhammad', None, 1149, 'Frère de Sayf al-Din Suri', 'Ghurid_dynasty', None, 'h')
K('sam1', 'Baha al-Din Sam Ier', None, 1149, 'Souverain ghouride (1149)', 'Ghurid_dynasty', 'mort en 1149', 'h')
K('husayn', 'Ala al-Din Husayn', None, 1161, 'Souverain ghouride (1149-1161)', 'Ghurid_dynasty', None, 'h')
K('smuh', 'Sayf al-Din Muhammad', None, 1163, 'Souverain ghouride (1161-1163)', 'Ghurid_dynasty', "fils d'Ala al-Din Husayn", 'h')
K('masud', 'Fakhr al-Din Masud', None, None, 'Souverain à Bamiyan (1152-1163)', 'Ghurid_dynasty', 'oncle de Ghiyath al-Din Muhammad', 'h')
K('ghiy', 'Ghiyath al-Din Muhammad', None, 1203, 'Souverain ghouride (1163-1203)', 'Ghurid_dynasty', 'mort le 13 mars 1203', 'h')
K('mog', 'Muhammad de Ghor', 1144, 1206, 'Souverain ghouride (1203-1206)', 'Muhammad_of_Ghor', 'naissance « vers 1144 » (estimation) ; mort le 15 mars 1206 ; frère cadet de Ghiyath al-Din Muhammad', 'h')
g.par('gh.husayn', 'gh.smuh')
g.par('gh.sam1', 'gh.ghiy')
g.par('gh.sam1', 'gh.mog')
g.fam('gh.suri', 'gh.qutb')
g.fam('gh.suri', 'gh.sam1')
g.fam('gh.suri', 'gh.husayn')
g.fam('gh.masud', 'gh.ghiy')
g.write()
