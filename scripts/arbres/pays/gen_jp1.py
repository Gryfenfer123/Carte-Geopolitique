import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(87, "Japon — famille impériale historique : de l'empereur Ōjin (15e) à Naruhito (126e)")
g.notes = [
    "Nouvel arbre « Empereurs du Japon » qui prolonge l'arbre « Empereurs légendaires » (Chūai et Jingū y sont affichés). Rien n'est supprimé.",
    "Source : Wikipédia en anglais, « List of emperors of Japan » (dates, numéros et pères tels qu'imprimés). Filiations non imprimées : complétées par des liens « famille » (frères, grands-parents) ou par l'histoire connue (Kōgyoku/Saimei et Kōken/Shōtoku sont une seule personne à deux règnes).",
    "Empereurs 15 à 25 et Kenzō/Ninken : dates de la tradition non retenues (laissées vides), car semi-légendaires.",
    "Empereurs de la Cour du Nord (Kōgon…Go-Komatsu) inclus avec leur filiation. Épouses de familles sans arbre (Ichijō, Kujō, Shōda…) : placées ici et signalées.",
    "Non fait : princes non empereurs, autres épouses et concubines, branches des princes collatéraux (miyake), shoguns.",
]
g.tree('JP_IMP', 'JPN', 'Empereurs du Japon', section_title='Empereurs du Japon')
g.tree('JP_LEG', 'JPN', 'Empereurs légendaires', entry=E('325e416c'))
P, S = g.par, g.sp
def M(code, name, b, d, title, g_='h', leader=True, approx=None, flag=None):
    return g.m(code, name, b, d, title, 'Famille impériale du Japon', 'JP_IMP', g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, approx=None):
    return g.m(code, name, b, d, title, house, 'JP_IMP', 'f', False, approx=approx, flag='Famille %s : sans arbre' % house)
TR = 'dates de la tradition non retenues'
# (code, nom, naissance, mort, numéro, genre, approx)
L = [('ojin', 'Ōjin', None, None, 15, 'h', TR), ('nintoku', 'Nintoku', None, None, 16, 'h', TR),
     ('richu', 'Richū', None, None, 17, 'h', TR), ('hanzei', 'Hanzei', None, None, 18, 'h', TR),
     ('ingyo', 'Ingyō', None, None, 19, 'h', TR), ('anko', 'Ankō', None, None, 20, 'h', TR),
     ('yuryaku', 'Yūryaku', None, None, 21, 'h', TR), ('seinei', 'Seinei', None, None, 22, 'h', TR),
     ('kenzo', 'Kenzō', None, None, 23, 'h', TR), ('ninken', 'Ninken', None, None, 24, 'h', TR),
     ('buretsu', 'Buretsu', None, None, 25, 'h', TR),
     ('keitai', 'Keitai', 450, 531, 26, 'h', 'dates traditionnelles'), ('ankan', 'Ankan', 466, 536, 27, 'h', 'dates traditionnelles'),
     ('senka', 'Senka', 466, 539, 28, 'h', 'dates traditionnelles'), ('kinmei', 'Kinmei', 509, 571, 29, 'h', 'dates traditionnelles'),
     ('bidatsu', 'Bidatsu', 538, 585, 30, 'h', None), ('yomei', 'Yōmei', None, 587, 31, 'h', 'naissance imprimée (517) incohérente avec celle de Kinmei, laissée vide'),
     ('sushun', 'Sushun', None, 592, 32, 'h', 'naissance imprimée (522) incohérente avec celle de Kinmei, laissée vide'), ('suiko', 'Suiko', 554, 628, 33, 'f', None),
     ('jomei', 'Jomei', 593, 641, 34, 'h', None), ('kogyoku', 'Kōgyoku / Saimei', 594, 661, '35 et 37', 'f', 'une seule personne, deux règnes'),
     ('kotoku', 'Kōtoku', 597, 654, 36, 'h', None), ('tenji', 'Tenji', 626, 672, 38, 'h', None),
     ('kobun', 'Kōbun', 648, 672, 39, 'h', None), ('tenmu', 'Tenmu', 622, 686, 40, 'h', None),
     ('jito', 'Jitō', 646, 703, 41, 'f', None), ('monmu', 'Monmu', 683, 707, 42, 'h', None),
     ('genmei', 'Genmei', 660, 721, 43, 'f', None), ('gensho', 'Genshō', 681, 748, 44, 'f', None),
     ('shomu', 'Shōmu', 701, 756, 45, 'h', None), ('koken', 'Kōken / Shōtoku', 718, 770, '46 et 48', 'f', 'une seule personne, deux règnes'),
     ('junnin', 'Junnin', 733, 765, 47, 'h', None), ('konin', 'Kōnin', 708, 782, 49, 'h', None),
     ('kanmu', 'Kanmu', 736, 806, 50, 'h', None), ('heizei', 'Heizei', 773, 824, 51, 'h', None),
     ('saga', 'Saga', 785, 842, 52, 'h', None), ('junna', 'Junna', 786, 840, 53, 'h', None),
     ('ninmyo', 'Ninmyō', 808, 850, 54, 'h', None), ('montoku', 'Montoku', 827, 858, 55, 'h', None),
     ('seiwa', 'Seiwa', 850, 881, 56, 'h', None), ('yozei', 'Yōzei', 869, 949, 57, 'h', None),
     ('koko', 'Kōkō', 830, 887, 58, 'h', None), ('uda', 'Uda', 866, 931, 59, 'h', None),
     ('daigo', 'Daigo', 884, 930, 60, 'h', None), ('suzaku', 'Suzaku', 921, 952, 61, 'h', None),
     ('murakami', 'Murakami', 924, 967, 62, 'h', None), ('reizei', 'Reizei', 949, 1011, 63, 'h', None),
     ('enyu', "En'yū", 958, 991, 64, 'h', None), ('kazan', 'Kazan', 968, 1008, 65, 'h', None),
     ('ichijo', 'Ichijō', 980, 1011, 66, 'h', None), ('sanjo', 'Sanjō', 975, 1017, 67, 'h', None),
     ('goichijo', 'Go-Ichijō', 1008, 1036, 68, 'h', None), ('gosuzaku', 'Go-Suzaku', 1009, 1045, 69, 'h', None),
     ('goreizei', 'Go-Reizei', 1025, 1068, 70, 'h', None), ('gosanjo', 'Go-Sanjō', 1032, 1073, 71, 'h', None),
     ('shirakawa', 'Shirakawa', 1053, 1129, 72, 'h', None), ('horikawa', 'Horikawa', 1079, 1107, 73, 'h', None),
     ('toba', 'Toba', 1103, 1156, 74, 'h', None), ('sutoku', 'Sutoku', 1119, 1164, 75, 'h', None),
     ('konoe', 'Konoe', 1139, 1155, 76, 'h', None), ('goshirakawa', 'Go-Shirakawa', 1127, 1192, 77, 'h', None),
     ('nijo', 'Nijō', 1143, 1165, 78, 'h', None), ('rokujo', 'Rokujō', 1164, 1176, 79, 'h', None),
     ('takakura', 'Takakura', 1161, 1181, 80, 'h', None), ('antoku', 'Antoku', 1178, 1185, 81, 'h', None),
     ('gotoba', 'Go-Toba', 1180, 1239, 82, 'h', None), ('tsuchimikado', 'Tsuchimikado', 1196, 1231, 83, 'h', None),
     ('juntoku', 'Juntoku', 1197, 1242, 84, 'h', None), ('chukyo', 'Chūkyō', 1218, 1234, 85, 'h', None),
     ('gohorikawa', 'Go-Horikawa', 1212, 1234, 86, 'h', None), ('shijo', 'Shijō', 1231, 1242, 87, 'h', None),
     ('gosaga', 'Go-Saga', 1220, 1272, 88, 'h', None), ('gofukakusa', 'Go-Fukakusa', 1243, 1304, 89, 'h', None),
     ('kameyama', 'Kameyama', 1249, 1305, 90, 'h', None), ('gouda', 'Go-Uda', 1267, 1324, 91, 'h', None),
     ('fushimi', 'Fushimi', 1265, 1317, 92, 'h', None), ('gofushimi', 'Go-Fushimi', 1288, 1336, 93, 'h', None),
     ('gonijo', 'Go-Nijō', 1285, 1308, 94, 'h', None), ('hanazono', 'Hanazono', 1297, 1348, 95, 'h', None),
     ('godaigo', 'Go-Daigo', 1288, 1339, 96, 'h', None), ('gomurakami', 'Go-Murakami', 1328, 1368, 97, 'h', None),
     ('chokei', 'Chōkei', 1343, 1394, 98, 'h', None), ('gokameyama', 'Go-Kameyama', 1347, 1424, 99, 'h', 'naissance vers 1347'),
     ('kogon', 'Kōgon (Cour du Nord)', 1313, 1364, 'Nord 1', 'h', None), ('komyo', 'Kōmyō (Cour du Nord)', 1322, 1380, 'Nord 2', 'h', None),
     ('suko', 'Sukō (Cour du Nord)', 1334, 1398, 'Nord 3', 'h', None), ('gokogon', 'Go-Kōgon (Cour du Nord)', 1338, 1374, 'Nord 4', 'h', None),
     ('goenyu', "Go-En'yū (Cour du Nord)", 1359, 1393, 'Nord 5', 'h', None),
     ('gokomatsu', 'Go-Komatsu', 1377, 1433, '100 (Nord 6)', 'h', None),
     ('shoko', 'Shōkō', 1401, 1428, 101, 'h', None), ('gohanazono', 'Go-Hanazono', 1419, 1471, 102, 'h', None),
     ('gotsuchimikado', 'Go-Tsuchimikado', 1442, 1500, 103, 'h', None), ('gokashiwabara', 'Go-Kashiwabara', 1462, 1526, 104, 'h', None),
     ('gonara', 'Go-Nara', 1495, 1557, 105, 'h', None), ('ogimachi', 'Ōgimachi', 1517, 1593, 106, 'h', None),
     ('goyozei', 'Go-Yōzei', 1571, 1617, 107, 'h', None), ('gomizunoo', 'Go-Mizunoo', 1596, 1680, 108, 'h', None),
     ('meisho', 'Meishō', 1624, 1696, 109, 'f', None), ('gokomyo', 'Go-Kōmyō', 1633, 1654, 110, 'h', None),
     ('gosai', 'Go-Sai', 1638, 1685, 111, 'h', None), ('reigen', 'Reigen', 1654, 1732, 112, 'h', None),
     ('higashiyama', 'Higashiyama', 1675, 1710, 113, 'h', None), ('nakamikado', 'Nakamikado', 1702, 1737, 114, 'h', None),
     ('sakuramachi', 'Sakuramachi', 1720, 1750, 115, 'h', None), ('momozono', 'Momozono', 1741, 1762, 116, 'h', None),
     ('gosakuramachi', 'Go-Sakuramachi', 1740, 1813, 117, 'f', None), ('gomomozono', 'Go-Momozono', 1758, 1779, 118, 'h', None),
     ('kokaku', 'Kōkaku', 1771, 1840, 119, 'h', None), ('ninko', 'Ninkō', 1800, 1846, 120, 'h', None),
     ('komei', 'Kōmei', 1831, 1867, 121, 'h', None), ('meiji', 'Meiji', 1852, 1912, 122, 'h', None),
     ('taisho', 'Taishō', 1879, 1926, 123, 'h', None), ('showa', 'Shōwa (Hirohito)', 1901, 1989, 124, 'h', None),
     ('akihito', 'Akihito', 1933, None, 125, 'h', None), ('naruhito', 'Naruhito', 1960, None, 126, 'h', None)]
for c, n, b, d, no, gg, a in L:
    t = 'Empereur du Japon' if gg == 'h' else 'Impératrice régnante du Japon'
    ti = f'{t} (n° {no})' if isinstance(no, int) or str(no)[0].isdigit() else f'{t} de la Cour du Nord ({no})'
    M('jp.' + c, n, b, d, ti, gg, True, a)
ch = [('ojin', 'nintoku'), ('nintoku', 'richu'), ('nintoku', 'hanzei'), ('nintoku', 'ingyo'), ('ingyo', 'anko'), ('ingyo', 'yuryaku'),
      ('yuryaku', 'seinei'), ('ninken', 'buretsu'), ('keitai', 'ankan'), ('keitai', 'senka'), ('keitai', 'kinmei'),
      ('kinmei', 'bidatsu'), ('kinmei', 'yomei'), ('kinmei', 'sushun'), ('kinmei', 'suiko'), ('jomei', 'tenji'), ('jomei', 'tenmu'),
      ('tenji', 'kobun'), ('tenji', 'jito'), ('tenji', 'genmei'), ('genmei', 'monmu'), ('genmei', 'gensho'), ('monmu', 'shomu'),
      ('shomu', 'koken'), ('konin', 'kanmu'), ('kanmu', 'heizei'), ('kanmu', 'saga'), ('kanmu', 'junna'), ('saga', 'ninmyo'),
      ('ninmyo', 'montoku'), ('montoku', 'seiwa'), ('seiwa', 'yozei'), ('ninmyo', 'koko'), ('koko', 'uda'), ('uda', 'daigo'),
      ('daigo', 'suzaku'), ('daigo', 'murakami'), ('murakami', 'reizei'), ('murakami', 'enyu'), ('reizei', 'kazan'),
      ('reizei', 'sanjo'), ('enyu', 'ichijo'), ('ichijo', 'goichijo'), ('ichijo', 'gosuzaku'), ('gosuzaku', 'goreizei'),
      ('gosuzaku', 'gosanjo'), ('gosanjo', 'shirakawa'), ('shirakawa', 'horikawa'), ('horikawa', 'toba'), ('toba', 'sutoku'),
      ('toba', 'konoe'), ('toba', 'goshirakawa'), ('goshirakawa', 'nijo'), ('nijo', 'rokujo'), ('goshirakawa', 'takakura'),
      ('takakura', 'antoku'), ('takakura', 'gotoba'), ('gotoba', 'tsuchimikado'), ('gotoba', 'juntoku'), ('juntoku', 'chukyo'),
      ('gohorikawa', 'shijo'), ('tsuchimikado', 'gosaga'), ('gosaga', 'gofukakusa'), ('gosaga', 'kameyama'), ('kameyama', 'gouda'),
      ('gofukakusa', 'fushimi'), ('fushimi', 'gofushimi'), ('gouda', 'gonijo'), ('fushimi', 'hanazono'), ('gouda', 'godaigo'),
      ('godaigo', 'gomurakami'), ('gomurakami', 'chokei'), ('gomurakami', 'gokameyama'), ('gofushimi', 'kogon'),
      ('gofushimi', 'komyo'), ('kogon', 'suko'), ('kogon', 'gokogon'), ('gokogon', 'goenyu'), ('goenyu', 'gokomatsu'),
      ('gokomatsu', 'shoko'), ('gotsuchimikado', 'gokashiwabara'), ('gohanazono', 'gotsuchimikado'), ('gokashiwabara', 'gonara'),
      ('gonara', 'ogimachi'), ('goyozei', 'gomizunoo'), ('gomizunoo', 'meisho'), ('gomizunoo', 'gokomyo'), ('gomizunoo', 'gosai'),
      ('gomizunoo', 'reigen'), ('reigen', 'higashiyama'), ('higashiyama', 'nakamikado'), ('nakamikado', 'sakuramachi'),
      ('sakuramachi', 'momozono'), ('sakuramachi', 'gosakuramachi'), ('momozono', 'gomomozono'), ('kokaku', 'ninko'),
      ('ninko', 'komei'), ('komei', 'meiji'), ('meiji', 'taisho'), ('taisho', 'showa'), ('showa', 'akihito'), ('akihito', 'naruhito')]
for a, b in ch:
    P('jp.' + a, 'jp.' + b)
P(R('81d076e4'), 'jp.ojin'); P(R('8f2a81a6'), 'jp.ojin'); g.pin(R('81d076e4'), 'JP_IMP'); g.pin(R('8f2a81a6'), 'JP_IMP')
# liens « famille » (frères, grands-parents, descendants éloignés)
fam = [('richu', 'kenzo'), ('kenzo', 'ninken'), ('ojin', 'keitai'), ('bidatsu', 'jomei'), ('kogyoku', 'kotoku'),
       ('tenji', 'konin'), ('tenmu', 'junnin'), ('takakura', 'gohorikawa'), ('suko', 'gohanazono'), ('ogimachi', 'goyozei'),
       ('higashiyama', 'kokaku')]
for a, b in fam:
    g.fam('jp.' + a, 'jp.' + b)
for c in ('tenji', 'tenmu'):
    P('jp.kogyoku', 'jp.' + c)
S('jp.jomei', 'jp.kogyoku'); S('jp.tenmu', 'jp.jito')
# époques modernes
W('jp.shoken', 'Impératrice Shōken (Ichijō Haruko)', 1849, 1914, 'Épouse de Meiji', 'Ichijō')
S('jp.meiji', 'jp.shoken')
W('jp.naruko', 'Yanagiwara Naruko', 1855, 1943, 'Concubine de Meiji, mère de Taishō', 'Yanagiwara')
S('jp.meiji', 'jp.naruko'); P('jp.naruko', 'jp.taisho')
W('jp.sadako', 'Impératrice Teimei (Kujō Sadako)', 1884, 1951, 'Épouse de Taishō', 'Kujō')
S('jp.taisho', 'jp.sadako'); P('jp.sadako', 'jp.showa')
W('jp.nagako', 'Impératrice Kōjun (Nagako)', 1903, 2000, 'Épouse de Shōwa', 'Kuni')
S('jp.showa', 'jp.nagako'); P('jp.nagako', 'jp.akihito')
W('jp.michiko', 'Impératrice Michiko (Shōda)', 1934, None, 'Épouse d\'Akihito', 'Shōda')
S('jp.akihito', 'jp.michiko'); P('jp.michiko', 'jp.naruhito')
W('jp.masako', 'Impératrice Masako (Owada)', 1963, None, 'Épouse de Naruhito', 'Owada')
S('jp.naruhito', 'jp.masako')
M('jp.aiko', 'Aiko, princesse Toshi', 2001, None, 'Princesse, fille de Naruhito', 'f', False)
kids = [('naruhito', 'aiko'), ('masako', 'aiko')]
for a, b in kids:
    P('jp.' + a, 'jp.' + b)
M('jp.fumihito', 'Fumihito, prince Akishino', 1965, None, 'Prince héritier présomptif', 'h', False)
M('jp.hisahito', 'Hisahito', 2006, None, 'Prince, fils de Fumihito', 'h', False)
for p in ('akihito', 'michiko'):
    P('jp.' + p, 'jp.fumihito')
P('jp.fumihito', 'jp.hisahito')

g.reposition = {'JP_IMP'}
g.write()
