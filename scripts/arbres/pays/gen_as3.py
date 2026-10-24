import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(108, "Moghols (Inde), Chakri (Thaïlande), Nguyen (Vietnam), Durrani et Barakzaï (Afghanistan)")
g.notes = [
    "Quatre nouveaux arbres : « Empire moghol » (Inde), « Dynastie Chakri » (Thaïlande), « Dynastie des Nguyen » (Vietnam), « Durrani et Barakzaï » (Afghanistan). Aucun n'existait.",
    "Dates : connues par ailleurs, aucune page consultée pour ce lot. Naissance vide quand inconnue ; approximations signalées. Sirikit (Thaïlande) : seule la naissance est saisie, la date de décès n'a pas été vérifiée.",
    "Vietnam : Duc Duc et Dong Khanh sont des fils adoptifs de Tu Duc ; leur filiation biologique n'est pas saisie (signalé). Afghanistan : Dost Mohammad Khan (Barakzaï) n'est pas relié aux Durrani ; Nadir Shah est saisi sans parent.",
    "Non fait : autres empereurs moghols, sultanat de Delhi, rois du Laos/Cambodge/Birmanie, cadets.",
]
g.tree('IN_MOG', 'IND', 'Empire moghol', section_title='Empire moghol')
g.tree('TH_CHA', 'THA', 'Dynastie Chakri', section_title='Dynastie Chakri')
g.tree('VN_NGU', 'VNM', 'Dynastie des Nguyen', section_title='Dynastie des Nguyen')
g.tree('AF_DUR', 'AFG', 'Durrani et Barakzaï', section_title='Durrani et Barakzaï')
P, S = g.par, g.sp
def M(code, name, b, d, title, dyn, tree, g_='h', leader=True, approx=None, flag=None):
    return g.m('as.' + code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
AP = 'Naissance approximative.'
D = lambda *a, **k: M(*a, dyn='Empire moghol', tree='IN_MOG', **k)
D('babur', 'Babur', 1483, 1530, 'Fondateur de l\'Empire moghol (1526-1530)')
D('humayun', 'Humayun', 1508, 1556, 'Empereur moghol (1530-1556)')
D('akbar', 'Akbar', 1542, 1605, 'Empereur moghol (1556-1605)')
D('jahangir', 'Jahangir', 1569, 1627, 'Empereur moghol (1605-1627)')
D('nurjahan', 'Nur Jahan', 1577, 1645, 'Impératrice, épouse de Jahangir', g_='f', leader=False)
D('shahjahan', 'Shah Jahan', 1592, 1666, 'Empereur moghol (1628-1658), bâtisseur du Taj Mahal')
D('mumtaz', 'Mumtaz Mahal', 1593, 1631, 'Impératrice, épouse de Shah Jahan', g_='f', leader=False)
D('dara', 'Dara Shikoh', 1615, 1659, 'Prince héritier, fils aîné de Shah Jahan', leader=False)
D('aurangzeb', 'Aurangzeb', 1618, 1707, 'Empereur moghol (1658-1707)')
D('bahadur1', 'Bahadur Shah Ier', 1643, 1712, 'Empereur moghol (1707-1712)')
D('jahandar', 'Jahandar Shah', 1661, 1713, 'Empereur moghol (1712-1713)')
D('alamgir2', 'Alamgir II', 1699, 1759, 'Empereur moghol (1754-1759)')
D('shahalam2', 'Shah Alam II', 1728, 1806, 'Empereur moghol (1760-1806)')
D('akbar2', 'Akbar II', 1760, 1837, 'Empereur moghol (1806-1837)')
D('bahadur2', 'Bahadur Shah II', 1775, 1862, 'Dernier empereur moghol (1837-1857)')
for a, b in [('babur', 'humayun'), ('humayun', 'akbar'), ('akbar', 'jahangir'), ('jahangir', 'shahjahan'), ('nurjahan', 'shahjahan') if False else ('shahjahan', 'dara'),
             ('shahjahan', 'aurangzeb'), ('mumtaz', 'dara'), ('mumtaz', 'aurangzeb'), ('aurangzeb', 'bahadur1'), ('bahadur1', 'jahandar'), ('jahandar', 'alamgir2'),
             ('alamgir2', 'shahalam2'), ('shahalam2', 'akbar2'), ('akbar2', 'bahadur2')]:
    P('as.' + a, 'as.' + b)
S('as.jahangir', 'as.nurjahan'); S('as.shahjahan', 'as.mumtaz')
C = lambda *a, **k: M(*a, dyn='Dynastie Chakri', tree='TH_CHA', **k)
C('r1', 'Rama Ier', 1737, 1809, 'Roi du Siam (1782-1809), fondateur de la dynastie Chakri')
C('r2', 'Rama II', 1767, 1824, 'Roi du Siam (1809-1824)')
C('r3', 'Rama III', 1788, 1851, 'Roi du Siam (1824-1851)')
C('r4', 'Rama IV (Mongkut)', 1804, 1868, 'Roi du Siam (1851-1868)')
C('r5', 'Rama V (Chulalongkorn)', 1853, 1910, 'Roi du Siam (1868-1910)')
C('r6', 'Rama VI (Vajiravudh)', 1881, 1925, 'Roi du Siam (1910-1925)')
C('r7', 'Rama VII (Prajadhipok)', 1893, 1941, 'Roi du Siam (1925-1935)')
C('mahidol', 'Mahidol Adulyadej', 1892, 1929, 'Prince de Songkhla, père de Rama VIII et Rama IX', leader=False)
C('srina', 'Srinagarindra', 1900, 1995, 'Princesse mère, épouse de Mahidol', g_='f', leader=False)
C('r8', 'Rama VIII (Ananda Mahidol)', 1925, 1946, 'Roi de Thaïlande (1935-1946)')
C('r9', 'Rama IX (Bhumibol Adulyadej)', 1927, 2016, 'Roi de Thaïlande (1946-2016)')
C('sirikit', 'Sirikit', 1932, None, 'Reine de Thaïlande, épouse de Rama IX', g_='f', leader=False, flag='Date de décès non vérifiée ; famille sans arbre')
C('r10', 'Rama X (Vajiralongkorn)', 1952, None, 'Roi de Thaïlande (depuis 2016)')
for a, b in [('r1', 'r2'), ('r2', 'r3'), ('r2', 'r4'), ('r4', 'r5'), ('r5', 'r6'), ('r5', 'r7'), ('r5', 'mahidol'), ('mahidol', 'r8'), ('mahidol', 'r9'),
             ('srina', 'r8'), ('srina', 'r9'), ('r9', 'r10'), ('sirikit', 'r10')]:
    P('as.' + a, 'as.' + b)
S('as.mahidol', 'as.srina'); S('as.r9', 'as.sirikit')
N = lambda *a, **k: M(*a, dyn='Dynastie des Nguyen', tree='VN_NGU', **k)
N('gialong', 'Gia Long', 1762, 1820, 'Empereur du Viêt Nam (1802-1820), fondateur des Nguyen')
N('minhmang', 'Minh Mang', 1791, 1841, 'Empereur du Viêt Nam (1820-1841)')
N('thieutri', 'Thieu Tri', 1807, 1847, 'Empereur du Viêt Nam (1841-1847)')
N('tuduc', 'Tu Duc', 1829, 1883, 'Empereur du Viêt Nam (1847-1883)')
N('ducduc', 'Duc Duc', 1852, 1883, 'Empereur du Viêt Nam (1883, trois jours)', flag='Fils adoptif de Tu Duc ; filiation biologique non saisie')
N('dongkhanh', 'Dong Khanh', 1864, 1889, 'Empereur du Viêt Nam (1885-1889)', flag='Fils adoptif de Tu Duc ; filiation biologique non saisie')
N('thanhthai', 'Thanh Thai', 1879, 1954, 'Empereur du Viêt Nam (1889-1907), déposé')
N('duytan', 'Duy Tan', 1900, 1945, 'Empereur du Viêt Nam (1907-1916), déposé')
N('khaidinh', 'Khai Dinh', 1885, 1925, 'Empereur du Viêt Nam (1916-1925)')
N('baodai', 'Bao Dai', 1913, 1997, 'Dernier empereur du Viêt Nam (1926-1945)')
for a, b in [('gialong', 'minhmang'), ('minhmang', 'thieutri'), ('thieutri', 'tuduc'), ('ducduc', 'thanhthai'), ('thanhthai', 'duytan'),
             ('dongkhanh', 'khaidinh'), ('khaidinh', 'baodai')]:
    P('as.' + a, 'as.' + b)
F = lambda *a, **k: M(*a, dyn='Durrani et Barakzaï', tree='AF_DUR', **k)
F('ahmad', 'Ahmad Shah Durrani', 1722, 1772, 'Fondateur de l\'Empire durrani (1747-1772)')
F('timur', 'Timur Shah Durrani', 1748, 1793, 'Émir de l\'Empire durrani (1772-1793)')
F('zaman', 'Zaman Shah Durrani', 1770, 1844, 'Émir de l\'Empire durrani (1793-1801)', approx=AP)
F('shuja', 'Shah Shuja Durrani', 1785, 1842, 'Émir de l\'Empire durrani (1803-1809, 1839-1842)')
F('dost', 'Dost Mohammad Khan', 1793, 1863, 'Émir d\'Afghanistan (1826-1863), fondateur des Barakzaï', flag='Lien avec les Durrani non saisi')
F('afzal', 'Mohammad Afzal Khan', None, 1867, 'Émir d\'Afghanistan (1866-1867), fils de Dost Mohammad', leader=False)
F('sher', 'Sher Ali Khan', 1825, 1879, 'Émir d\'Afghanistan (1863-1879)')
F('abdur', 'Abdur Rahman Khan', 1844, 1901, 'Émir d\'Afghanistan (1880-1901)')
F('habib', 'Habibullah Khan', 1872, 1919, 'Émir d\'Afghanistan (1901-1919)')
F('aman', 'Amanullah Khan', 1892, 1960, 'Émir puis roi d\'Afghanistan (1919-1929)')
F('nadir', 'Nadir Shah', 1883, 1933, 'Roi d\'Afghanistan (1929-1933)', flag='Ascendance non saisie')
F('zahir', 'Mohammad Zaher Shah', 1914, 2007, 'Roi d\'Afghanistan (1933-1973)')
for a, b in [('ahmad', 'timur'), ('timur', 'zaman'), ('timur', 'shuja'), ('dost', 'afzal'), ('dost', 'sher'), ('afzal', 'abdur'), ('abdur', 'habib'),
             ('habib', 'aman'), ('nadir', 'zahir')]:
    P('as.' + a, 'as.' + b)
g.reposition = {'IN_MOG', 'TH_CHA', 'VN_NGU', 'AF_DUR'}
g.write()
