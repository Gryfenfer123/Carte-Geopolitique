import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(89, "Corée — dynastie Joseon (Yi) de Taejo à Sunjong, avec l'Empire coréen")
g.notes = [
    "Nouvel arbre « Joseon » (aucun n'existait). Rien n'est supprimé.",
    "Source de la liste des rois : Wikipédia en anglais, « List of monarchs of Korea » (noms et règnes) ; dates de vie et filiations : connues par ailleurs (histoire coréenne), car la page ne les imprime pas. Les successions par adoption ou par collatéral (Seonjo, Injo, Cheoljong, Gojong…) passent par les princes intermédiaires ou par un lien « famille ».",
    "La reine Min (impératrice Myeongseong) vient d'une famille sans arbre : signalée.",
    "Non fait : Goryeo et Silla (la page ne donne pas de dates de vie ; à faire avec des sources dédiées), épouses des rois, princes non rois (hors intermédiaires dynastiques).",
]
g.tree('KR_JOS', 'KOR', 'Joseon', section_title='Joseon')
P, S = g.par, g.sp
YI = 'Joseon (Yi)'; T = 'KR_JOS'
def M(code, name, b, d, title, g_='h', leader=True, approx=None, flag=None):
    return g.m(code, name, b, d, title, YI, T, g_, leader, approx=approx, flag=flag)
L = [('taejo', 'Taejo (Yi Seong-gye)', 1335, 1408, 'Fondateur de Joseon (1392-1398)'),
     ('jeongjong', 'Jeongjong (Yi Bang-gwa)', 1357, 1419, 'Roi (1398-1400)'),
     ('taejong', 'Taejong (Yi Bang-won)', 1367, 1422, 'Roi (1400-1418)'),
     ('sejong', 'Sejong le Grand (Yi Do)', 1397, 1450, 'Roi (1418-1450), inventeur du hangeul'),
     ('munjong', 'Munjong (Yi Hyang)', 1414, 1452, 'Roi (1450-1452)'),
     ('danjong', 'Danjong (Yi Hong-wi)', 1441, 1457, 'Roi (1452-1455)'),
     ('sejo', 'Sejo (Yi Yu)', 1417, 1468, 'Roi (1455-1468)'),
     ('yejong', 'Yejong (Yi Hwang)', 1450, 1469, 'Roi (1468-1469)'),
     ('seongjong', 'Seongjong (Yi Hyeol)', 1457, 1494, 'Roi (1469-1494)'),
     ('yeonsan', 'Yeonsangun (Yi Yung)', 1476, 1506, 'Roi (1494-1506), détrôné'),
     ('jungjong', 'Jungjong (Yi Yeok)', 1488, 1544, 'Roi (1506-1544)'),
     ('injong', 'Injong (Yi Ho)', 1515, 1545, 'Roi (1544-1545)'),
     ('myeongjong', 'Myeongjong (Yi Hwan)', 1534, 1567, 'Roi (1545-1567)'),
     ('seonjo', 'Seonjo (Yi Yeon)', 1552, 1608, 'Roi (1567-1608), guerre d\'Imjin'),
     ('gwanghae', 'Gwanghaegun (Yi Hon)', 1575, 1641, 'Roi (1608-1623), détrôné'),
     ('injo', 'Injo (Yi Jong)', 1595, 1649, 'Roi (1623-1649)'),
     ('hyojong', 'Hyojong (Yi Ho)', 1619, 1659, 'Roi (1649-1659)'),
     ('hyeonjong', 'Hyeonjong (Yi Yeon)', 1641, 1674, 'Roi (1659-1674)'),
     ('sukjong', 'Sukjong (Yi Sun)', 1661, 1720, 'Roi (1674-1720)'),
     ('gyeongjong', 'Gyeongjong (Yi Yun)', 1688, 1724, 'Roi (1720-1724)'),
     ('yeongjo', 'Yeongjo (Yi Geum)', 1694, 1776, 'Roi (1724-1776)'),
     ('jeongjo', 'Jeongjo (Yi San)', 1752, 1800, 'Roi (1776-1800)'),
     ('sunjo', 'Sunjo (Yi Gong)', 1790, 1834, 'Roi (1800-1834)'),
     ('heonjong', 'Heonjong (Yi Hwan)', 1827, 1849, 'Roi (1834-1849)'),
     ('cheoljong', 'Cheoljong (Yi Byeon)', 1831, 1864, 'Roi (1849-1864)'),
     ('gojong', 'Gojong (Yi Myeong-bok)', 1852, 1919, 'Roi (1864-1897) puis premier empereur coréen (1897-1907)'),
     ('sunjong', 'Sunjong (Yi Cheok)', 1874, 1926, 'Dernier empereur de Corée (1907-1910)')]
for c, n, b, d, t in L:
    M('kr.' + c, n, b, d, t)
M('kr.deokjong', 'Deokjong (prince héritier Uigyeong)', 1438, 1457, 'Père de Seongjong, roi à titre posthume', leader=False)
M('kr.deokheung', 'Prince Deokheung', 1530, 1559, 'Père de Seonjo', leader=False)
M('kr.jeongwon', 'Prince Jeongwon (Wonjong)', 1580, 1619, 'Père d\'Injo, roi à titre posthume', leader=False)
M('kr.sado', 'Prince héritier Sado', 1735, 1762, 'Père de Jeongjo', leader=False)
M('kr.hyomyeong', 'Prince héritier Hyomyeong', 1809, 1830, 'Père de Heonjong', leader=False)
M('kr.daewongun', 'Heungseon Daewongun (Yi Ha-eung)', 1820, 1898, 'Régent, père de Gojong', leader=False)
M('kr.min', 'Impératrice Myeongseong (reine Min)', 1851, 1895, 'Épouse de Gojong, assassinée', 'f', False, flag='Famille Min (Yeoheung) : sans arbre')
for a, b in [('taejo', 'jeongjong'), ('taejo', 'taejong'), ('taejong', 'sejong'), ('sejong', 'munjong'), ('munjong', 'danjong'),
             ('sejong', 'sejo'), ('sejo', 'yejong'), ('sejo', 'deokjong'), ('deokjong', 'seongjong'), ('seongjong', 'yeonsan'),
             ('seongjong', 'jungjong'), ('jungjong', 'injong'), ('jungjong', 'myeongjong'), ('jungjong', 'deokheung'),
             ('deokheung', 'seonjo'), ('seonjo', 'gwanghae'), ('seonjo', 'jeongwon'), ('jeongwon', 'injo'), ('injo', 'hyojong'),
             ('hyojong', 'hyeonjong'), ('hyeonjong', 'sukjong'), ('sukjong', 'gyeongjong'), ('sukjong', 'yeongjo'),
             ('yeongjo', 'sado'), ('sado', 'jeongjo'), ('jeongjo', 'sunjo'), ('sunjo', 'hyomyeong'), ('hyomyeong', 'heonjong'),
             ('daewongun', 'gojong'), ('gojong', 'sunjong')]:
    P('kr.' + a, 'kr.' + b)
g.fam('kr.yeongjo', 'kr.cheoljong'); g.fam('kr.sunjo', 'kr.cheoljong'); g.fam('kr.cheoljong', 'kr.gojong')
S('kr.gojong', 'kr.min'); P('kr.min', 'kr.sunjong')
g.reposition = {'KR_JOS'}
g.write()
