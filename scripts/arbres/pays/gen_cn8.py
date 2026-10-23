import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(85, "Chine — dynastie Ming de Hongwu à Chongzhen")
g.notes = ["Nouvel arbre « Ming » (aucun n'existait). Rien n'est supprimé.", 'Dates : connues par ailleurs (histoire de Chine), aucune page consultée pour ce lot. Jiajing descend de Chenghua par son père Zhu Youyuan (prince de Xing), non empereur.', 'Les impératrices Ma et Xu viennent de familles sans arbre : signalées.', 'Non fait : princes non empereurs hors Zhu Biao et Zhu Youyuan, autres épouses.']
g.tree('CN_MING', 'CHN', 'Ming', section_title='Ming')
g.reposition = {'CN_MING'}
P, S = g.par, g.sp
def M(code, name, b, d, title, dyn, tree, g_='h', leader=True, approx=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, tree, approx=None):
    return M(code, name, b, d, title, house, tree, 'f', False, approx, 'Famille %s : sans arbre' % house)
def chain(pref, lst):
    for a, b in lst:
        P(pref + a, pref + b)
MG = 'Ming (Zhu)'; T = 'CN_MING'
L = [('hongwu', 'Ming Taizu (Zhu Yuanzhang, Hongwu)', 1328, 1398, 'Fondateur des Ming (1368-1398)', True),
     ('biao', 'Zhu Biao', 1355, 1392, 'Prince héritier, mort avant son père', False),
     ('jianwen', 'Jianwen (Zhu Yunwen)', 1377, 1402, 'Empereur (1398-1402)', True),
     ('yongle', 'Yongle (Zhu Di)', 1360, 1424, 'Empereur (1402-1424)', True),
     ('hongxi', 'Hongxi (Zhu Gaochi)', 1378, 1425, 'Empereur (1424-1425)', True),
     ('xuande', 'Xuande (Zhu Zhanji)', 1399, 1435, 'Empereur (1425-1435)', True),
     ('zhengtong', 'Zhengtong / Tianshun (Zhu Qizhen)', 1427, 1464, 'Empereur (1435-1449 et 1457-1464)', True),
     ('jingtai', 'Jingtai (Zhu Qiyu)', 1428, 1457, 'Empereur (1449-1457)', True),
     ('chenghua', 'Chenghua (Zhu Jianshen)', 1447, 1487, 'Empereur (1464-1487)', True),
     ('hongzhi', 'Hongzhi (Zhu Youtang)', 1470, 1505, 'Empereur (1487-1505)', True),
     ('zhengde', 'Zhengde (Zhu Houzhao)', 1491, 1521, 'Empereur (1505-1521)', True),
     ('youyuan', 'Zhu Youyuan, prince de Xing', 1476, 1519, 'Père de Jiajing', False),
     ('jiajing', 'Jiajing (Zhu Houcong)', 1507, 1567, 'Empereur (1521-1567)', True),
     ('longqing', 'Longqing (Zhu Zaiji)', 1537, 1572, 'Empereur (1567-1572)', True),
     ('wanli', 'Wanli (Zhu Yijun)', 1563, 1620, 'Empereur (1572-1620)', True),
     ('taichang', 'Taichang (Zhu Changluo)', 1582, 1620, 'Empereur (1620)', True),
     ('tianqi', 'Tianqi (Zhu Youjiao)', 1605, 1627, 'Empereur (1620-1627)', True),
     ('chongzhen', 'Chongzhen (Zhu Youjian)', 1611, 1644, 'Dernier empereur Ming (1627-1644)', True)]
for c, n, b, d, t, ld in L:
    M('mg.' + c, n, b, d, t, MG, T, leader=ld)
chain('mg.', [('hongwu', 'biao'), ('biao', 'jianwen'), ('hongwu', 'yongle'), ('yongle', 'hongxi'), ('hongxi', 'xuande'),
              ('xuande', 'zhengtong'), ('xuande', 'jingtai'), ('zhengtong', 'chenghua'), ('chenghua', 'hongzhi'),
              ('hongzhi', 'zhengde'), ('chenghua', 'youyuan'), ('youyuan', 'jiajing'), ('jiajing', 'longqing'),
              ('longqing', 'wanli'), ('wanli', 'taichang'), ('taichang', 'tianqi'), ('taichang', 'chongzhen')])
W('mg.ma', 'Impératrice Ma', 1332, 1382, 'Épouse de Hongwu', 'Ma', T)
S('mg.hongwu', 'mg.ma'); P('mg.ma', 'mg.biao')
W('mg.xu', 'Impératrice Xu', 1362, 1407, 'Épouse de Yongle', 'Xu', T)
S('mg.yongle', 'mg.xu'); P('mg.xu', 'mg.hongxi')

g.write()
