import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(86, "Chine — dynastie Qing de Nurhaci à Puyi")
g.notes = ["Nouvel arbre « Qing » (aucun n'existait). Rien n'est supprimé.", 'Dates : connues par ailleurs (histoire de Chine), aucune page consultée pour ce lot. Guangxu et Puyi descendent de Daoguang par le prince Chun (Yixuan) puis Zaifeng, non empereurs.', 'Les impératrices Xiaozhuangwen et Cixi viennent de familles sans arbre (Borjigit, Yehe Nara) : signalées.', 'Non fait : Dorgon et autres princes, épouses autres que Xiaozhuangwen et Cixi.']
g.tree('CN_QING', 'CHN', 'Qing', section_title='Qing')
g.reposition = {'CN_QING'}
P, S = g.par, g.sp
def M(code, name, b, d, title, dyn, tree, g_='h', leader=True, approx=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, tree, approx=None):
    return M(code, name, b, d, title, house, tree, 'f', False, approx, 'Famille %s : sans arbre' % house)
def chain(pref, lst):
    for a, b in lst:
        P(pref + a, pref + b)
QG = 'Qing (Aisin Gioro)'; T = 'CN_QING'
L = [('nurhaci', 'Nurhaci (Qing Taizu)', 1559, 1626, 'Fondateur de la dynastie (khan des Jin postérieurs)', True),
     ('hongtaiji', 'Hong Taiji (Qing Taizong)', 1592, 1643, 'Empereur (1626-1643), fonde officiellement les Qing', True),
     ('shunzhi', 'Shunzhi (Fulin)', 1638, 1661, 'Premier empereur Qing à Pékin (1644-1661)', True),
     ('kangxi', 'Kangxi (Xuanye)', 1654, 1722, 'Empereur (1661-1722)', True),
     ('yongzheng', 'Yongzheng (Yinzhen)', 1678, 1735, 'Empereur (1722-1735)', True),
     ('qianlong', 'Qianlong (Hongli)', 1711, 1799, 'Empereur (1735-1796)', True),
     ('jiaqing', 'Jiaqing (Yongyan)', 1760, 1820, 'Empereur (1796-1820)', True),
     ('daoguang', 'Daoguang (Minning)', 1782, 1850, 'Empereur (1820-1850), guerre de l\'opium', True),
     ('xianfeng', 'Xianfeng (Yizhu)', 1831, 1861, 'Empereur (1850-1861)', True),
     ('tongzhi', 'Tongzhi (Zaichun)', 1856, 1875, 'Empereur (1861-1875)', True),
     ('yixuan', 'Yixuan, prince Chun', 1840, 1891, 'Fils de Daoguang, père de Guangxu', False),
     ('guangxu', 'Guangxu (Zaitian)', 1871, 1908, 'Empereur (1875-1908)', True),
     ('zaifeng', 'Zaifeng, prince Chun', 1883, 1951, 'Régent, père de Puyi', False),
     ('puyi', 'Puyi (Xuantong)', 1906, 1967, 'Dernier empereur de Chine (1908-1912)', True)]
for c, n, b, d, t, ld in L:
    M('qg.' + c, n, b, d, t, QG, T, leader=ld)
chain('qg.', [('nurhaci', 'hongtaiji'), ('hongtaiji', 'shunzhi'), ('shunzhi', 'kangxi'), ('kangxi', 'yongzheng'),
              ('yongzheng', 'qianlong'), ('qianlong', 'jiaqing'), ('jiaqing', 'daoguang'), ('daoguang', 'xianfeng'),
              ('xianfeng', 'tongzhi'), ('daoguang', 'yixuan'), ('yixuan', 'guangxu'), ('yixuan', 'zaifeng'), ('zaifeng', 'puyi')])
W('qg.xiaozhuang', 'Impératrice Xiaozhuangwen', 1613, 1688, 'Épouse de Hong Taiji, mère de Shunzhi', 'Borjigit', T)
S('qg.hongtaiji', 'qg.xiaozhuang'); P('qg.xiaozhuang', 'qg.shunzhi')
W('qg.cixi', 'Cixi', 1835, 1908, 'Impératrice douairière, régente, mère de Tongzhi', 'Yehe Nara', T)
S('qg.xianfeng', 'qg.cixi'); P('qg.cixi', 'qg.tongzhi')

g.write()
