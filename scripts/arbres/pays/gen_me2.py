import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(106, "Hachémites (Jordanie, Irak) et Al Saoud (Arabie saoudite)")
g.notes = [
    "Trois nouveaux arbres : « Hachémites » (Jordanie), « Hachémites (Irak) » et « Al Saoud » (Arabie saoudite). Hussein ibn Ali (chérif de La Mecque) est dans l'arbre de Jordanie et affiché aussi dans celui d'Irak, où il est relié à son fils Fayçal Ier.",
    "Dates : connues par ailleurs, aucune page consultée pour ce lot. Naissances inconnues laissées vides ; naissance approximative signalée quand elle l'est.",
    "Al Saoud : seuls les rois, leurs ancêtres directs et la mère des « Soudayri » sont saisis. Le premier État saoudien est coupé de la lignée de Fayçal ben Turki (chaînon Abdallah ben Mohammed non saisi, donc Turki n'est pas relié à Mohammed ben Saoud).",
    "Non fait : princes cadets, épouses de la plupart des rois, Hachémites du Hedjaz au-delà d'Ali, dynastie rachidide.",
]
g.tree('JO_HAS', 'JOR', 'Hachémites', section_title='Hachémites')
g.tree('IQ_HAS', 'IRQ', 'Hachémites (Irak)', section_title='Hachémites (Irak)')
g.tree('SA_SAO', 'SAU', 'Al Saoud', section_title='Al Saoud')
P, S = g.par, g.sp
def M(code, name, b, d, title, dyn, tree, g_='h', leader=True, approx=None, flag=None):
    return g.m('me.' + code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
H = 'Hachémites'
J = lambda *a, **k: M(*a, dyn=H, tree='JO_HAS', **k)
J('hus', 'Hussein ibn Ali', 1854, 1931, 'Chérif de La Mecque, roi du Hedjaz (1916-1924), meneur de la Révolte arabe')
J('ali', 'Ali ibn Hussein', 1879, 1935, 'Roi du Hedjaz (1924-1925)')
J('abd1', 'Abdallah Ier de Jordanie', 1882, 1951, 'Émir puis roi de Jordanie (1921-1951)')
J('misha', 'Misha\'al bint Fahd', None, None, 'Épouse de Abdallah Ier', g_='f', leader=False, flag='Famille sans arbre')
J('talal', 'Talal de Jordanie', 1909, 1972, 'Roi de Jordanie (1951-1952)')
J('zein', 'Zein al-Sharaf', 1916, 1994, 'Reine de Jordanie, épouse de Talal', g_='f', leader=False, flag='Famille sans arbre')
J('hus2', 'Hussein de Jordanie', 1935, 1999, 'Roi de Jordanie (1952-1999)')
J('muna', 'Muna al-Hussein', 1941, None, 'Princesse, deuxième épouse du roi Hussein', g_='f', leader=False, flag='Famille sans arbre')
J('abd2', 'Abdallah II de Jordanie', 1962, None, 'Roi de Jordanie (depuis 1999)')
J('rania', 'Rania al-Abdullah', 1970, None, 'Reine de Jordanie, épouse d\'Abdallah II', g_='f', leader=False, flag='Famille sans arbre')
J('husc', 'Hussein de Jordanie (prince héritier)', 1994, None, 'Prince héritier de Jordanie', leader=False)
for a, b in [('hus', 'ali'), ('hus', 'abd1'), ('abd1', 'talal'), ('talal', 'hus2'), ('hus2', 'abd2'), ('muna', 'abd2'), ('abd2', 'husc'), ('rania', 'husc'), ('misha', 'talal'), ('zein', 'hus2')]:
    P('me.' + a, 'me.' + b)
S('me.abd1', 'me.misha'); S('me.talal', 'me.zein'); S('me.hus2', 'me.muna'); S('me.abd2', 'me.rania')
I = lambda *a, **k: M(*a, dyn='Hachémites (Irak)', tree='IQ_HAS', **k)
I('fay1', 'Fayçal Ier d\'Irak', 1885, 1933, 'Roi de Syrie (1920) puis d\'Irak (1921-1933)')
I('ghazi', 'Ghazi d\'Irak', 1912, 1939, 'Roi d\'Irak (1933-1939)')
I('aliya', 'Aliya bint Ali', 1911, 1950, 'Reine d\'Irak, épouse de Ghazi', g_='f', leader=False)
I('fay2', 'Fayçal II d\'Irak', 1935, 1958, 'Dernier roi d\'Irak (1939-1958)')
I('abdilah', 'Abd al-Ilah', 1913, 1958, 'Régent d\'Irak (1939-1953)', leader=False)
g.pin('me.hus', 'IQ_HAS'); g.pin('me.ali', 'IQ_HAS')
for a, b in [('hus', 'fay1'), ('fay1', 'ghazi'), ('ali', 'aliya'), ('ghazi', 'fay2'), ('aliya', 'fay2'), ('ali', 'abdilah')]:
    P('me.' + a, 'me.' + b)
S('me.ghazi', 'me.aliya')
SA = 'Al Saoud'
A = lambda *a, **k: M(*a, dyn=SA, tree='SA_SAO', **k)
A('mohammed', 'Mohammed ibn Saoud', None, 1765, 'Émir de Diriyya, fondateur du premier État saoudien')
A('abdulaziz1', 'Abdulaziz ibn Mohammed', 1720, 1803, 'Imam du premier État saoudien (1765-1803)', approx='Naissance approximative.')
A('saud1', 'Saoud ibn Abdulaziz (Saoud le Grand)', 1748, 1814, 'Imam du premier État saoudien (1803-1814)', approx='Naissance approximative.')
A('turki', 'Turki ibn Abdallah', None, 1834, 'Fondateur du second État saoudien (1824-1834)', flag='Ascendance non saisie')
A('faisal1', 'Fayçal ibn Turki', None, 1865, 'Émir du Nejd (1834-1865)')
A('abdrahman', 'Abdul Rahman ibn Fayçal', 1850, 1928, 'Dernier émir du Nejd, père d\'Ibn Saoud')
A('abdulaziz', 'Abdulaziz ibn Saoud (Ibn Saoud)', 1875, 1953, 'Fondateur et premier roi d\'Arabie saoudite (1932-1953)')
A('hassa', 'Hassa bint Ahmad al-Soudaïri', None, 1969, 'Épouse d\'Ibn Saoud, mère des « Soudayri »', g_='f', leader=False, flag='Famille Soudayri : sans arbre')
A('saud', 'Saoud ben Abdelaziz', 1902, 1969, 'Roi d\'Arabie saoudite (1953-1964)')
A('faisal', 'Fayçal ben Abdelaziz', 1906, 1975, 'Roi d\'Arabie saoudite (1964-1975)')
A('khalid', 'Khaled ben Abdelaziz', 1913, 1982, 'Roi d\'Arabie saoudite (1975-1982)')
A('fahd', 'Fahd ben Abdelaziz', 1921, 2005, 'Roi d\'Arabie saoudite (1982-2005)')
A('abdullah', 'Abdallah ben Abdelaziz', 1924, 2015, 'Roi d\'Arabie saoudite (2005-2015)')
A('salman', 'Salmane ben Abdelaziz', 1935, None, 'Roi d\'Arabie saoudite (depuis 2015)')
A('mbs', 'Mohammed ben Salmane', 1985, None, 'Prince héritier, Premier ministre (depuis 2022)')
for a, b in [('mohammed', 'abdulaziz1'), ('abdulaziz1', 'saud1'), ('turki', 'faisal1'), ('faisal1', 'abdrahman'), ('abdrahman', 'abdulaziz'),
             ('abdulaziz', 'saud'), ('abdulaziz', 'faisal'), ('abdulaziz', 'khalid'), ('abdulaziz', 'fahd'), ('abdulaziz', 'abdullah'), ('abdulaziz', 'salman'),
             ('hassa', 'fahd'), ('hassa', 'salman'), ('salman', 'mbs')]:
    P('me.' + a, 'me.' + b)
S('me.abdulaziz', 'me.hassa')
g.reposition = {'JO_HAS', 'IQ_HAS', 'SA_SAO'}
g.write()
