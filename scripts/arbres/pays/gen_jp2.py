import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(88, "Japon — shoguns : Minamoto, Ashikaga, Oda/Toyotomi et Tokugawa")
g.notes = [
    "Quatre nouveaux arbres : « Minamoto (Kamakura) », « Ashikaga », « Oda et Toyotomi », « Tokugawa » (aucun n'existait). Rien n'est supprimé.",
    "Dates : connues par ailleurs (histoire du Japon), aucune page consultée pour ce lot. Les adoptions et héritiers de branches collatérales (Tokugawa de Kii, de Mito, Hitotsubashi…) sont reliés par un lien « famille », pas par une filiation.",
    "Hōjō Masako (épouse de Yoritomo) vient d'une famille sans arbre : signalée.",
    "Non fait : régents Hōjō, Ashikaga après Yoshimasa (hors Yoshiharu, Yoshiteru, Yoshiaki), enfants et épouses des Tokugawa, Oda après Nobunaga.",
]
g.tree('JP_MIN', 'JPN', 'Minamoto (Kamakura)', section_title='Minamoto (Kamakura)')
g.tree('JP_ASH', 'JPN', 'Ashikaga', section_title='Ashikaga')
g.tree('JP_ODA', 'JPN', 'Oda et Toyotomi', section_title='Oda et Toyotomi')
g.tree('JP_TOK', 'JPN', 'Tokugawa', section_title='Tokugawa')
P, S = g.par, g.sp
def M(code, name, b, d, title, dyn, tree, g_='h', leader=True, approx=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
# Minamoto
MI = 'Minamoto'
M('mi.yoritomo', 'Minamoto no Yoritomo', 1147, 1199, 'Premier shogun (shogunat de Kamakura)', MI, 'JP_MIN')
M('mi.yoriie', 'Minamoto no Yoriie', 1182, 1204, 'Deuxième shogun', MI, 'JP_MIN')
M('mi.sanetomo', 'Minamoto no Sanetomo', 1192, 1219, 'Troisième shogun, dernier Minamoto', MI, 'JP_MIN')
M('mi.masako', 'Hōjō Masako', 1157, 1225, 'Épouse de Yoritomo, « nonne shogun »', 'Hōjō', 'JP_MIN', 'f', False, flag='Famille Hōjō : sans arbre')
S('mi.yoritomo', 'mi.masako')
for c in ('mi.yoriie', 'mi.sanetomo'):
    P('mi.yoritomo', c); P('mi.masako', c)
# Ashikaga
AS = 'Ashikaga'
L = [('takauji', 'Ashikaga Takauji', 1305, 1358, 'Premier shogun Ashikaga'),
     ('yoshiakira', 'Ashikaga Yoshiakira', 1330, 1367, 'Deuxième shogun'),
     ('yoshimitsu', 'Ashikaga Yoshimitsu', 1358, 1408, 'Troisième shogun'),
     ('yoshimochi', 'Ashikaga Yoshimochi', 1386, 1428, 'Quatrième shogun'),
     ('yoshinori', 'Ashikaga Yoshinori', 1394, 1441, 'Sixième shogun'),
     ('yoshimasa', 'Ashikaga Yoshimasa', 1436, 1490, 'Huitième shogun (guerre d\'Ōnin)'),
     ('yoshiharu', 'Ashikaga Yoshiharu', 1511, 1550, 'Douzième shogun'),
     ('yoshiteru', 'Ashikaga Yoshiteru', 1536, 1565, 'Treizième shogun'),
     ('yoshiaki', 'Ashikaga Yoshiaki', 1537, 1597, 'Quinzième et dernier shogun Ashikaga')]
for c, n, b, d, t in L:
    M('as.' + c, n, b, d, t, AS, 'JP_ASH')
for a, b in [('takauji', 'yoshiakira'), ('yoshiakira', 'yoshimitsu'), ('yoshimitsu', 'yoshimochi'), ('yoshimitsu', 'yoshinori'),
             ('yoshinori', 'yoshimasa'), ('yoshiharu', 'yoshiteru'), ('yoshiharu', 'yoshiaki')]:
    P('as.' + a, 'as.' + b)
g.fam('as.yoshimasa', 'as.yoshiharu')
# Oda / Toyotomi
OD = 'Oda et Toyotomi'
M('od.nobunaga', 'Oda Nobunaga', 1534, 1582, 'Seigneur de la guerre, unificateur du Japon', OD, 'JP_ODA')
M('od.hideyoshi', 'Toyotomi Hideyoshi', 1537, 1598, 'Régent (kanpaku), unificateur du Japon', OD, 'JP_ODA')
M('od.hideyori', 'Toyotomi Hideyori', 1593, 1615, 'Fils de Hideyoshi, vaincu à Osaka', OD, 'JP_ODA', leader=False)
P('od.hideyoshi', 'od.hideyori')
M('od.nobuhide', 'Oda Nobuhide', 1510, 1551, 'Père de Nobunaga, seigneur de Owari', OD, 'JP_ODA', leader=False, approx='naissance vers 1510')
M('od.nobutada', 'Oda Nobutada', 1557, 1582, 'Fils aîné de Nobunaga', OD, 'JP_ODA', leader=False)
P('od.nobuhide', 'od.nobunaga'); P('od.nobunaga', 'od.nobutada')
# Tokugawa
TK = 'Tokugawa'
L = [('ieyasu', 'Tokugawa Ieyasu', 1543, 1616, 'Premier shogun Tokugawa'),
     ('hidetada', 'Tokugawa Hidetada', 1579, 1632, 'Deuxième shogun'),
     ('iemitsu', 'Tokugawa Iemitsu', 1604, 1651, 'Troisième shogun'),
     ('ietsuna', 'Tokugawa Ietsuna', 1641, 1680, 'Quatrième shogun'),
     ('tsunayoshi', 'Tokugawa Tsunayoshi', 1646, 1709, 'Cinquième shogun'),
     ('ienobu', 'Tokugawa Ienobu', 1662, 1712, 'Sixième shogun'),
     ('ietsugu', 'Tokugawa Ietsugu', 1709, 1716, 'Septième shogun'),
     ('yoshimune', 'Tokugawa Yoshimune', 1684, 1751, 'Huitième shogun (réformes Kyōhō)'),
     ('ieshige', 'Tokugawa Ieshige', 1712, 1761, 'Neuvième shogun'),
     ('ieharu', 'Tokugawa Ieharu', 1737, 1786, 'Dixième shogun'),
     ('ienari', 'Tokugawa Ienari', 1773, 1841, 'Onzième shogun'),
     ('ieyoshi', 'Tokugawa Ieyoshi', 1793, 1853, 'Douzième shogun'),
     ('iesada', 'Tokugawa Iesada', 1824, 1858, 'Treizième shogun (traité de Harris)'),
     ('iemochi', 'Tokugawa Iemochi', 1846, 1866, 'Quatorzième shogun'),
     ('yoshinobu', 'Tokugawa Yoshinobu', 1837, 1913, 'Quinzième et dernier shogun')]
for c, n, b, d, t in L:
    M('tk.' + c, n, b, d, t, TK, 'JP_TOK')
for a, b in [('ieyasu', 'hidetada'), ('hidetada', 'iemitsu'), ('iemitsu', 'ietsuna'), ('iemitsu', 'tsunayoshi'),
             ('ienobu', 'ietsugu'), ('yoshimune', 'ieshige'), ('ieshige', 'ieharu'), ('ienari', 'ieyoshi'), ('ieyoshi', 'iesada')]:
    P('tk.' + a, 'tk.' + b)
for a, b in [('iemitsu', 'ienobu'), ('ieyasu', 'yoshimune'), ('ieharu', 'ienari'), ('ieyoshi', 'iemochi'), ('ienari', 'yoshinobu')]:
    g.fam('tk.' + a, 'tk.' + b)
g.reposition = {'JP_MIN', 'JP_ASH', 'JP_ODA', 'JP_TOK'}
g.write()
