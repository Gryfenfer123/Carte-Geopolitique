import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(107, "Maroc (Alaouites), Libye (Senoussi), Éthiopie (dynastie salomonide)")
g.notes = [
    "Trois nouveaux arbres : « Alaouites » (Maroc), « Senoussi » (Libye), « Dynastie salomonide » (Éthiopie). Aucun n'existait.",
    "Dates : connues par ailleurs, aucune page consultée pour ce lot. Naissance laissée vide quand inconnue ; approximations signalées.",
    "Alaouites : le chaînon Hicham (père d'Abderrahmane, fils de Mohammed III) n'est pas saisi ; Abderrahmane est donc sans parent dans l'arbre. Ali Chérif relié à Rachid et Ismaïl.",
    "Éthiopie : Ras Makonnen (père de Haile Selassie) est saisi sans lien vers Menelik II (cousin, lien non saisi).",
    "Non fait : Tunisie (beys husseinites), Algérie, autres sultans alaouites, nombreux cadets.",
]
g.tree('MA_ALA', 'MAR', 'Alaouites', section_title='Alaouites')
g.tree('LY_SEN', 'LBY', 'Senoussi', section_title='Senoussi')
g.tree('ET_SAL', 'ETH', 'Dynastie salomonide', section_title='Dynastie salomonide')
P, S = g.par, g.sp
def M(code, name, b, d, title, dyn, tree, g_='h', leader=True, approx=None, flag=None):
    return g.m('af.' + code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
AP = 'Naissance approximative.'
A = lambda *a, **k: M(*a, dyn='Alaouites', tree='MA_ALA', **k)
A('ali', 'Moulay Ali Chérif', None, 1659, 'Ancêtre des Alaouites, prince du Tafilalet', leader=False)
A('rachid', 'Moulay Rachid', 1631, 1672, 'Sultan du Maroc (1666-1672), fondateur de la dynastie alaouite')
A('ismail', 'Moulay Ismaïl', 1645, 1727, 'Sultan du Maroc (1672-1727)')
A('abdallah', 'Moulay Abdallah', 1694, 1757, 'Sultan du Maroc (plusieurs règnes)')
A('mohammed3', 'Mohammed III ben Abdallah', 1710, 1790, 'Sultan du Maroc (1757-1790)')
A('yazid', 'Moulay Yazid', 1750, 1792, 'Sultan du Maroc (1790-1792)', approx=AP)
A('slimane', 'Moulay Slimane', 1766, 1822, 'Sultan du Maroc (1792-1822)')
A('abderrahmane', 'Abd al-Rahman du Maroc', 1778, 1859, 'Sultan du Maroc (1822-1859)', flag='Ascendance non saisie')
A('mohammed4', 'Mohammed IV du Maroc', 1803, 1873, 'Sultan du Maroc (1859-1873)')
A('hassan1', 'Hassan Ier du Maroc', 1836, 1894, 'Sultan du Maroc (1873-1894)')
A('aziz', 'Abd al-Aziz du Maroc', 1878, 1943, 'Sultan du Maroc (1894-1908)')
A('hafid', 'Abd al-Hafid du Maroc', 1875, 1937, 'Sultan du Maroc (1908-1912)')
A('youssef', 'Moulay Youssef', 1882, 1927, 'Sultan du Maroc (1912-1927)')
A('mohammed5', 'Mohammed V du Maroc', 1909, 1961, 'Sultan puis roi du Maroc (1927-1961)')
A('hassan2', 'Hassan II du Maroc', 1929, 1999, 'Roi du Maroc (1961-1999)')
A('mohammed6', 'Mohammed VI du Maroc', 1963, None, 'Roi du Maroc (depuis 1999)')
A('hassanh', 'Moulay Hassan (prince héritier)', 2003, None, 'Prince héritier du Maroc', leader=False)
for a, b in [('ali', 'rachid'), ('ali', 'ismail'), ('ismail', 'abdallah'), ('abdallah', 'mohammed3'), ('mohammed3', 'yazid'), ('mohammed3', 'slimane'),
             ('abderrahmane', 'mohammed4'), ('mohammed4', 'hassan1'), ('hassan1', 'aziz'), ('hassan1', 'hafid'), ('hassan1', 'youssef'),
             ('youssef', 'mohammed5'), ('mohammed5', 'hassan2'), ('hassan2', 'mohammed6'), ('mohammed6', 'hassanh')]:
    P('af.' + a, 'af.' + b)
L = lambda *a, **k: M(*a, dyn='Senoussi', tree='LY_SEN', **k)
L('mohammed', 'Mohammed ibn Ali as-Senoussi', 1787, 1859, 'Fondateur de la confrérie senoussie')
L('mahdi', 'Mohammed al-Mahdi as-Senoussi', 1844, 1902, 'Chef de la confrérie senoussie', leader=False)
L('idris', 'Idris Ier de Libye', 1889, 1983, 'Roi de Libye (1951-1969)')
P('af.mohammed', 'af.mahdi'); P('af.mahdi', 'af.idris')
E_ = lambda *a, **k: M(*a, dyn='Dynastie salomonide', tree='ET_SAL', **k)
E_('sahle', 'Sahle Selassie', 1795, 1847, 'Négus du Choa (1813-1847)')
E_('melekot', 'Haile Melekot', 1824, 1855, 'Roi du Choa (1847-1855)', leader=False)
E_('menelik', 'Menelik II', 1844, 1913, 'Empereur d\'Éthiopie (1889-1913)')
E_('zewditu', 'Zewditu Ire', 1876, 1930, 'Impératrice d\'Éthiopie (1916-1930)', g_='f')
E_('makonnen', 'Ras Makonnen', 1852, 1906, 'Gouverneur du Harar, père de Haile Selassie', leader=False, flag='Lien avec Menelik II non saisi')
E_('hailes', 'Haile Selassie Ier', 1892, 1975, 'Empereur d\'Éthiopie (1930-1974)')
E_('menen', 'Menen Asfaw', 1889, 1962, 'Impératrice d\'Éthiopie, épouse de Haile Selassie', g_='f', leader=False)
E_('amha', 'Amha Selassie Ier', 1916, 1997, 'Dernier empereur d\'Éthiopie (1974, en exil)')
E_('zera', 'Zera Yacob Amha Selassie', 1953, None, 'Prétendant au trône d\'Éthiopie', leader=False)
for a, b in [('sahle', 'melekot'), ('melekot', 'menelik'), ('menelik', 'zewditu'), ('makonnen', 'hailes'), ('hailes', 'amha'), ('menen', 'amha'), ('amha', 'zera')]:
    P('af.' + a, 'af.' + b)
S('af.hailes', 'af.menen')
g.reposition = {'MA_ALA', 'LY_SEN', 'ET_SAL'}
g.write()
