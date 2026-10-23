import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(44, "Roumanie — Basarab, Mușat, Hohenzollern-Sigmaringen")
g.notes = [
    "Crée sous Roumanie > Dynastie : Basarab (Valachie), Mușat (Moldavie), Hohenzollern-Sigmaringen (royaume de Roumanie).",
    "Prudence : les généalogies médiévales valaques et moldaves sont lacunaires dans Wikipédia ; seuls les liens attestés par les fiches des personnes sont créés ; beaucoup de naissances sont donc laissées vides (signalées dans le rapport).",
    "Pas inclus : voïvodes valaques/moldaves sans filiation claire, Cuza (prince élu, pas de dynastie), Michel le Brave (rattachement aux Basarab discuté).",
    "Hohenzollern-Sigmaringen : Karl Anton, Josephine de Bade, Léopold et Antonia de Portugal sont créés dans l'arbre Hohenzollern d'Allemagne (branche de Sigmaringen) ; Carol Ier apparaît dans les deux.",
    "Marie de Saxe-Cobourg (Édimbourg) est reliée à Alfred et Maria Alexandrovna (créés par v38 ; si v38 n'a pas été exécuté ces liens sont ignorés avec un avertissement).",
    "Hélène de Grèce, Élisabeth et Marie de Roumanie (reines de Grèce et de Yougoslavie) : créées ici, à rattacher aux arbres grec/serbe ensuite.",
    "Prérequis : v43 exécuté.",
]
g.tree('RO_BAS', 'ROU', 'Basarab')
g.tree('RO_MUS', 'ROU', 'Mușat')
g.tree('RO_HOH', 'ROU', 'Hohenzollern-Sigmaringen')
g.tree('DE_HZ', 'DEU', 'Hohenzollern', entry='39895573-27f3-4112-905b-c9ba7e3c95a1')
g.tree('IT_PAR', 'ITA', 'Maison de Bourbon-Parme', entry=[k for k in ENT if k.startswith('84c9f117')][0])
Gen.FIXB = {uid('member:ro.stephen'): 1435, uid('member:ro.radu1'): 1330, uid('member:ro.aldea'): 1390,
            uid('member:ro.ilias'): 1405, uid('member:ro.stephen2m'): 1405, uid('member:ro.bogdan2'): 1410,
            uid('member:ro.petru_aron'): 1410, uid('member:ro.vlad_monk'): 1435, uid('member:ro.calinichia'): 1335}
P, S = g.par, g.sp

# ================================================================ BASARAB (Valachie)
BS = 'Basarab'
g.m('ro.radu1', 'Radu Ier de Valachie', None, 1383, 'Voïvode de Valachie (v. 1377-1383)', BS, 'RO_BAS', 'h', True, approx='naissance inconnue')
g.m('ro.calinichia', 'Calinichia (épouse de Radu Ier)', None, None, 'Doamna de Valachie', 'Origine incertaine', 'RO_BAS', 'f', flag='Origine incertaine : sans arbre ; dates inconnues', approx='dates inconnues')
g.m('ro.mircea1', 'Mircea Ier l\'Ancien', 1355, 1418, 'Voïvode de Valachie (1386-1418)', BS, 'RO_BAS', 'h', True, approx='naissance « vers 1355 »')
g.m('ro.aldea', 'Alexandre Ier Aldea', None, 1436, 'Voïvode de Valachie (1431-1436)', BS, 'RO_BAS', 'h', True, approx='naissance inconnue')
g.m('ro.vlad2', 'Vlad II Dracul', 1395, 1447, 'Voïvode de Valachie (1436-1442, 1443-1447)', BS, 'RO_BAS', 'h', True, approx='naissance « vers 1395 » (avant 1395 selon d\'autres) ; fils illégitime de Mircea Ier')
g.m('ro.eupraxia', 'Eupraxie (Cneajna) de Moldavie', None, None, 'Épouse de Vlad II Dracul', 'Mușat', 'RO_MUS', 'f', approx='identité et dates incertaines (fille d\'Alexandre le Bon, hypothèse majoritaire)')
g.m('ro.mircea2', 'Mircea II', 1428, 1446, 'Voïvode de Valachie (1442, 1443)', BS, 'RO_BAS', 'h', True, approx='naissance « vers 1428 » ; mort 1446')
g.m('ro.vlad3', 'Vlad III l\'Empaleur (Dracula)', 1431, 1476, 'Voïvode de Valachie (1448, 1456-1462, 1476)', BS, 'RO_BAS', 'h', True, approx='naissance entre 1428 et 1431 ; mort décembre 1476 ou janvier 1477')
g.m('ro.radu3', 'Radu III le Beau', 1437, 1475, 'Voïvode de Valachie (1462-1473, 1474-1475)', BS, 'RO_BAS', 'h', True, approx='naissance « vers 1437 » (avant août 1439) ; mort 1475')
g.m('ro.vlad_monk', 'Vlad IV le Moine', None, 1496, 'Voïvode de Valachie (1481-1495)', BS, 'RO_BAS', 'h', True, approx='naissance inconnue ; fils illégitime de Vlad II et de Călțuna')
g.m('ro.mihnea', 'Mihnea le Mauvais', 1462, 1510, 'Voïvode de Valachie (1508-1509)', BS, 'RO_BAS', 'h', True, approx='mort 1510 (assassiné à Sibiu)')
P('ro.radu1', 'ro.mircea1'); P('ro.calinichia', 'ro.mircea1'); S('ro.radu1', 'ro.calinichia')
for c in ('ro.aldea', 'ro.vlad2'):
    P('ro.mircea1', c)
S('ro.vlad2', 'ro.eupraxia')
for c in ('ro.mircea2', 'ro.vlad3', 'ro.radu3'):
    P('ro.vlad2', c); P('ro.eupraxia', c)
P('ro.vlad2', 'ro.vlad_monk')
P('ro.vlad3', 'ro.mihnea')

# ================================================================ MUȘAT (Moldavie)
MU = 'Mușat'
g.m('ro.alexandru_b', 'Alexandre Ier le Bon', 1375, 1432, 'Voïvode de Moldavie (1400-1432)', MU, 'RO_MUS', 'h', True, approx='naissance « vers 1375 »')
g.m('ro.ilias', 'Iliaș Ier', None, 1448, 'Voïvode de Moldavie (1432-1442, 1435-1443)', MU, 'RO_MUS', 'h', True, approx='naissance inconnue')
g.m('ro.stephen2m', 'Étienne II de Moldavie', None, 1447, 'Voïvode de Moldavie (1434-1447)', MU, 'RO_MUS', 'h', True, approx='naissance inconnue')
g.m('ro.bogdan2', 'Bogdan II', None, 1451, 'Voïvode de Moldavie (1449-1451)', MU, 'RO_MUS', 'h', True, approx='naissance inconnue ; assassiné en octobre 1451')
g.m('ro.petru_aron', 'Petru Aron', None, 1470, 'Voïvode de Moldavie (1451-1457)', MU, 'RO_MUS', 'h', True, approx='naissance inconnue')
g.m('ro.oltea', 'Maria Oltea', None, None, 'Mère d\'Étienne le Grand', 'Origine inconnue', 'RO_MUS', 'f', flag='Origine inconnue : sans arbre ; dates inconnues', approx='dates inconnues')
g.m('ro.stephen', 'Étienne III le Grand', None, 1504, 'Voïvode de Moldavie (1457-1504)', MU, 'RO_MUS', 'h', True, approx='naissance inconnue (entre 1433 et 1440)')
g.m('ro.voichita', 'Maria Voichița', None, 1511, 'Voïvodesse de Moldavie', 'Valachie (Basarab ?)', 'RO_MUS', 'f', flag='Origine valaque (Basarab ?) : à rattacher à l\'arbre Basarab si Martin le valide ; dates non vérifiées', approx='naissance inconnue ; mort 1511 (non revérifiée)')
g.m('ro.bogdan3', 'Bogdan III l\'Aveugle', 1479, 1517, 'Voïvode de Moldavie (1504-1517)', MU, 'RO_MUS', 'h', True)
g.m('ro.petru_rares', 'Petru Rareș', 1483, 1546, 'Voïvode de Moldavie (1527-1538, 1541-1546)', MU, 'RO_MUS', 'h', True, approx='naissance « vers 1483 »')
g.m('ro.jelena', 'Jelena Branković', 1502, 1552, 'Voïvodesse de Moldavie', 'Branković (Serbie)', 'RO_MUS', 'f', flag='Branković (Serbie) : arbre à créer avec la Serbie', approx='naissance « vers 1502 »')
g.m('ro.ilie2', 'Ilie II Rareș', 1531, 1561, 'Voïvode de Moldavie (1546-1551)', MU, 'RO_MUS', 'h', True, approx='mort 1561')
g.m('ro.stephen6', 'Étienne VI Rareș', 1532, 1552, 'Voïvode de Moldavie (1551-1552)', MU, 'RO_MUS', 'h', True, approx='mort 1552')
P('ro.alexandru_b', 'ro.ilias'); P('ro.alexandru_b', 'ro.stephen2m'); P('ro.alexandru_b', 'ro.bogdan2'); P('ro.alexandru_b', 'ro.petru_aron')
P('ro.alexandru_b', 'ro.eupraxia')
P('ro.bogdan2', 'ro.stephen'); P('ro.oltea', 'ro.stephen'); S('ro.bogdan2', 'ro.oltea')
S('ro.stephen', 'ro.voichita')
P('ro.stephen', 'ro.bogdan3'); P('ro.voichita', 'ro.bogdan3')
P('ro.stephen', 'ro.petru_rares')
S('ro.petru_rares', 'ro.jelena')
for c in ('ro.ilie2', 'ro.stephen6'):
    P('ro.petru_rares', c); P('ro.jelena', c)

# ================================================================ HOHENZOLLERN-SIGMARINGEN (royaume)
HS = 'Hohenzollern-Sigmaringen'
g.m('ro.karl_anton', 'Charles-Antoine de Hohenzollern-Sigmaringen', 1811, 1885, 'Prince de Hohenzollern-Sigmaringen, ministre-président de Prusse', HS, 'DE_HZ', 'h')
g.m('ro.josephine', 'Joséphine de Bade', 1813, 1900, 'Princesse de Hohenzollern-Sigmaringen', 'Zähringen (Bade)', 'DE_HZ', 'f', flag='Maison de Bade (Allemagne) : sans arbre')
g.m('ro.leopold_h', 'Léopold de Hohenzollern-Sigmaringen', 1835, 1905, 'Prince de Hohenzollern, candidat au trône d\'Espagne (1870)', HS, 'DE_HZ', 'h')
g.m('ro.antonia', 'Antónia de Portugal', 1845, 1913, 'Princesse de Hohenzollern-Sigmaringen', 'Bragance', 'DE_HZ', 'f', flag='Maison de Bragance (Portugal) : à rattacher à l\'arbre Bragance (fille de Marie II) ; parents non reliés')
g.m('ro.carol1', 'Carol Ier', 1839, 1914, 'Prince (1866) puis premier roi de Roumanie (1881-1914)', HS, 'RO_HOH', 'h', True)
g.m('ro.elisabeth_w', 'Élisabeth de Wied (Carmen Sylva)', 1843, 1916, 'Reine de Roumanie', 'Wied', 'RO_HOH', 'f', flag='Maison de Wied (Allemagne) : sans arbre', approx='dates « 1843 – 1916 » (non revérifiées sur Wikipédia)')
g.m('ro.ferdinand', 'Ferdinand Ier de Roumanie', 1865, 1927, 'Roi de Roumanie (1914-1927)', HS, 'RO_HOH', 'h', True, approx='dates « 1865 – 1927 » (non revérifiées sur Wikipédia)')
g.m('ro.marie_e', 'Marie d\'Édimbourg (reine de Roumanie)', 1875, 1938, 'Reine de Roumanie', 'Saxe-Cobourg et Gotha / Windsor', 'RO_HOH', 'f', approx='dates « 1875 – 1938 » (non revérifiées sur Wikipédia)')
g.m('ro.carol2', 'Carol II', 1893, 1953, 'Roi de Roumanie (1930-1940)', HS, 'RO_HOH', 'h', True)
g.m('ro.zizi', 'Zizi Lambrino', 1898, 1953, 'Première épouse de Carol II (mariage annulé en 1919)', 'Lambrino (noblesse roumaine)', 'RO_HOH', 'f', flag='Famille Lambrino (noblesse roumaine) : sans arbre ; dates non revérifiées', approx='dates « 1898 – 1953 » (non revérifiées)')
g.m('ro.helen', 'Hélène de Grèce et de Danemark', 1896, 1982, 'Reine-mère de Roumanie', 'Glücksbourg (Grèce)', 'RO_HOH', 'f', flag='Glücksbourg (Grèce) : à rattacher à l\'arbre grec (fille de Constantin Ier) ; dates non revérifiées', approx='dates « 1896 – 1982 » (non revérifiées)')
g.m('ro.magda', 'Magda Lupescu', 1895, 1977, 'Troisième épouse de Carol II (1947)', 'Lupescu (Roumanie)', 'RO_HOH', 'f', flag='Famille Lupescu : sans arbre ; dates non revérifiées', approx='dates « 1895 – 1977 » (non revérifiées)')
g.m('ro.michael', 'Michel Ier de Roumanie', 1921, 2017, 'Roi de Roumanie (1927-1930, 1940-1947)', HS, 'RO_HOH', 'h', True)
g.m('ro.anne_p', 'Anne de Bourbon-Parme', 1923, 2016, 'Reine de Roumanie (épouse de Michel Ier)', 'Bourbon-Parme', 'IT_PAR', 'f', approx='naissance 1923 (non revérifiée)')
g.m('ro.margareta', 'Marguerite de Roumanie', 1949, None, 'Gardienne de la Couronne roumaine', HS, 'RO_HOH', 'f')
g.m('ro.elisabeth_r', 'Élisabeth de Roumanie (reine de Grèce)', 1894, 1956, 'Reine de Grèce', HS, 'RO_HOH', 'f', approx='dates « 1894 – 1956 » (non revérifiées)')
g.m('ro.maria_r', 'Marie de Roumanie (Mignon, reine de Yougoslavie)', 1900, 1961, 'Reine de Yougoslavie', HS, 'RO_HOH', 'f', approx='dates « 1900 – 1961 » (non revérifiées)')
g.m('ro.nicolae', 'Nicolas de Roumanie', 1903, 1978, 'Prince, régent (1927-1930)', HS, 'RO_HOH', 'h', approx='dates « 1903 – 1978 » (non revérifiées)')
g.m('ro.robert_p', 'Robert Ier de Parme', 1848, 1907, 'Dernier duc de Parme', 'Bourbon-Parme', 'IT_PAR', 'h', approx='dates « 1848 – 1907 » (non revérifiées)')
g.m('ro.rene_p', 'René de Bourbon-Parme', 1894, 1962, 'Prince de Bourbon-Parme, père d\'Anne', 'Bourbon-Parme', 'IT_PAR', 'h', approx='dates « 1894 – 1962 » (non revérifiées)')

S('ro.karl_anton', 'ro.josephine')
for c in ('ro.leopold_h', 'ro.carol1'):
    P('ro.karl_anton', c); P('ro.josephine', c)
S('ro.leopold_h', 'ro.antonia')
P('ro.leopold_h', 'ro.ferdinand'); P('ro.antonia', 'ro.ferdinand')
S('ro.carol1', 'ro.elisabeth_w')
S('ro.ferdinand', 'ro.marie_e')
g.link_named_parent('ro.marie_e', 'Alfred de Saxe-Cobourg et Gotha', 1844)
g.link_named_parent('ro.marie_e', 'Maria Alexandrovna de Russie', 1853)
for c in ('ro.carol2', 'ro.elisabeth_r', 'ro.maria_r', 'ro.nicolae'):
    P('ro.ferdinand', c); P('ro.marie_e', c)
S('ro.carol2', 'ro.zizi'); S('ro.carol2', 'ro.helen'); S('ro.carol2', 'ro.magda')
P('ro.carol2', 'ro.michael'); P('ro.helen', 'ro.michael')
S('ro.michael', 'ro.anne_p')
P('ro.michael', 'ro.margareta'); P('ro.anne_p', 'ro.margareta')
P('ro.robert_p', 'at.zita')
P('ro.rene_p', 'ro.anne_p')

if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
