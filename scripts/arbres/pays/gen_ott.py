import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(81, "Turquie — dynastie ottomane : d'Osman Ier au dernier calife Abdülmecid II")
g.notes = [
    "Nouvel arbre « Ottomans » (aucun n'existait). Rien n'est supprimé.",
    "Dates et filiations des sultans : connues par ailleurs (histoire ottomane), aucune page consultée pour ce lot ; seuls les liens père-fils certains sont posés. Dates incertaines laissées vides.",
    "Hürrem, Nurbanu et Kösem (épouses d'origine hors dynastie, sans maison identifiée) : placées ici et signalées.",
    "Non fait : les princes exécutés ou écartés (Mustafa, Cem, Bayezid fils de Soliman…), les autres épouses, les sultanes ; le compte à 1922 s'arrête au dernier calife.",
]
g.tree('TR_OTT', 'TUR', 'Ottomans', section_title='Ottomans')
P, S = g.par, g.sp
T = 'TR_OTT'
def M(code, name, b, d, title, g_, leader=True, approx=None, flag=None):
    return g.m(code, name, b, d, title, 'Ottomans', T, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, approx=None):
    return M(code, name, b, d, title, 'f', False, approx, 'Origine hors dynastie : sans arbre')
S_ = [('osman1', 'Osman Ier', 1258, 1326, 'Fondateur de la dynastie, bey', 'vers 1258'),
      ('orhan', 'Orhan Ier', 1281, 1362, 'Bey (sultan)', 'naissance vers 1281'),
      ('murad1', 'Mourad Ier', 1326, 1389, 'Sultan', 'naissance vers 1326'),
      ('bayezid1', 'Bayezid Ier', 1360, 1403, 'Sultan', None),
      ('mehmed1', 'Mehmed Ier', 1386, 1421, 'Sultan', None),
      ('murad2', 'Mourad II', 1404, 1451, 'Sultan', None),
      ('mehmed2', 'Mehmed II le Conquérant', 1432, 1481, 'Sultan, conquérant de Constantinople', None),
      ('bayezid2', 'Bayezid II', 1447, 1512, 'Sultan', None),
      ('selim1', 'Selim Ier', 1470, 1520, 'Sultan', 'naissance 1465-1470'),
      ('suleiman1', 'Soliman Ier le Magnifique', 1494, 1566, 'Sultan', None),
      ('selim2', 'Selim II', 1524, 1574, 'Sultan', None),
      ('murad3', 'Mourad III', 1546, 1595, 'Sultan', None),
      ('mehmed3', 'Mehmed III', 1566, 1603, 'Sultan', None),
      ('ahmed1', 'Ahmed Ier', 1590, 1617, 'Sultan', None),
      ('mustafa1', 'Mustafa Ier', 1591, 1639, 'Sultan', None),
      ('osman2', 'Osman II', 1604, 1622, 'Sultan', None),
      ('murad4', 'Mourad IV', 1612, 1640, 'Sultan', None),
      ('ibrahim', 'Ibrahim Ier', 1615, 1648, 'Sultan', None),
      ('mehmed4', 'Mehmed IV', 1642, 1693, 'Sultan', None),
      ('suleiman2', 'Soliman II', 1642, 1691, 'Sultan', None),
      ('ahmed2', 'Ahmed II', 1643, 1695, 'Sultan', None),
      ('mustafa2', 'Mustafa II', 1664, 1703, 'Sultan', None),
      ('ahmed3', 'Ahmed III', 1673, 1736, 'Sultan', None),
      ('mahmud1', 'Mahmud Ier', 1696, 1754, 'Sultan', None),
      ('osman3', 'Osman III', 1699, 1757, 'Sultan', None),
      ('mustafa3', 'Mustafa III', 1717, 1774, 'Sultan', None),
      ('abdulhamid1', 'Abdülhamid Ier', 1725, 1789, 'Sultan', None),
      ('selim3', 'Selim III', 1761, 1808, 'Sultan', None),
      ('mustafa4', 'Mustafa IV', 1779, 1808, 'Sultan', None),
      ('mahmud2', 'Mahmud II', 1785, 1839, 'Sultan', None),
      ('abdulmecid1', 'Abdülmecid Ier', 1823, 1861, 'Sultan', None),
      ('abdulaziz', 'Abdülaziz', 1830, 1876, 'Sultan', None),
      ('murad5', 'Mourad V', 1840, 1904, 'Sultan', None),
      ('abdulhamid2', 'Abdülhamid II', 1842, 1918, 'Sultan', None),
      ('mehmed5', 'Mehmed V Reşad', 1844, 1918, 'Sultan', None),
      ('mehmed6', 'Mehmed VI Vahideddin', 1861, 1926, 'Dernier sultan', None),
      ('abdulmecid2', 'Abdülmecid II', 1868, 1944, 'Dernier calife', None)]
for c, n, b, d, t, a in S_:
    M('ot.' + c, n, b, d, t, 'h', True, a)
F = [('osman1', 'orhan'), ('orhan', 'murad1'), ('murad1', 'bayezid1'), ('bayezid1', 'mehmed1'), ('mehmed1', 'murad2'),
     ('murad2', 'mehmed2'), ('mehmed2', 'bayezid2'), ('bayezid2', 'selim1'), ('selim1', 'suleiman1'),
     ('suleiman1', 'selim2'), ('selim2', 'murad3'), ('murad3', 'mehmed3'), ('mehmed3', 'ahmed1'), ('mehmed3', 'mustafa1'),
     ('ahmed1', 'osman2'), ('ahmed1', 'murad4'), ('ahmed1', 'ibrahim'), ('ibrahim', 'mehmed4'), ('ibrahim', 'suleiman2'),
     ('ibrahim', 'ahmed2'), ('mehmed4', 'mustafa2'), ('mehmed4', 'ahmed3'), ('mustafa2', 'mahmud1'), ('mustafa2', 'osman3'),
     ('ahmed3', 'mustafa3'), ('ahmed3', 'abdulhamid1'), ('mustafa3', 'selim3'), ('abdulhamid1', 'mustafa4'),
     ('abdulhamid1', 'mahmud2'), ('mahmud2', 'abdulmecid1'), ('mahmud2', 'abdulaziz'), ('abdulmecid1', 'murad5'),
     ('abdulmecid1', 'abdulhamid2'), ('abdulmecid1', 'mehmed5'), ('abdulmecid1', 'mehmed6'), ('abdulaziz', 'abdulmecid2')]
for a, b in F:
    P('ot.' + a, 'ot.' + b)
W('ot.hurrem', 'Hürrem Sultan (Roxelane)', 1502, 1558, 'Épouse de Soliman Ier, mère de Selim II', 'naissance vers 1502')
S('ot.suleiman1', 'ot.hurrem'); P('ot.hurrem', 'ot.selim2')
W('ot.nurbanu', 'Nurbanu Sultan', 1525, 1583, 'Épouse de Selim II, mère de Mourad III', 'naissance vers 1525')
S('ot.selim2', 'ot.nurbanu'); P('ot.nurbanu', 'ot.murad3')
W('ot.kosem', 'Kösem Sultan', 1589, 1651, "Épouse d'Ahmed Ier, mère de Mourad IV et d'Ibrahim, régente", 'naissance vers 1589')
S('ot.ahmed1', 'ot.kosem'); P('ot.kosem', 'ot.murad4'); P('ot.kosem', 'ot.ibrahim')
g.reposition = {'TR_OTT'}
g.write()
