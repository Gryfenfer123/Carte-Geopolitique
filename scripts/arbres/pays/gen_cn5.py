import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(82, "Chine — Sui et Tang : de Yang Jian au dernier empereur Tang")
g.notes = [
    "Deux nouveaux arbres : « Sui » et « Tang » (aucun n'existait). Rien n'est supprimé.",
    "Dates et filiations : connues par ailleurs (histoire de Chine), aucune page consultée pour ce lot ; seules les filiations père-fils certaines sont posées. Gongdi de Sui (petit-fils de Yangdi) est relié par un lien « famille ». Années avant J.-C. : négatives (aucune ici).",
    "Wu Zetian : épouse de Gaozong (aussi concubine de Taizong, non représenté) ; elle fonde la dynastie Zhou éphémère (690-705) et porte l'anneau rouge.",
    "Les impératrices Dugu, Zhangsun et la concubine Yang Guifei viennent de familles sans arbre : placées ici et signalées.",
    "Non fait : princes héritiers écartés (Li Jiancheng, Li Chengqian…), autres épouses.",
]
g.tree('CN_SUI', 'CHN', 'Sui', section_title='Sui')
g.tree('CN_TANG', 'CHN', 'Tang', section_title='Tang')
P, S = g.par, g.sp
def M(code, name, b, d, title, dyn, tree, g_='h', leader=True, approx=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, tree, approx=None):
    return M(code, name, b, d, title, house, tree, 'f', False, approx, 'Famille %s : sans arbre' % house)

SU, TG = 'Sui (Yang)', 'Tang (Li)'
M('su.wendi', 'Sui Wendi (Yang Jian)', 541, 604, 'Empereur fondateur des Sui (581-604)', SU, 'CN_SUI')
W('su.dugu', 'Impératrice Dugu Qieluo', 544, 602, 'Épouse de Sui Wendi', 'Dugu', 'CN_SUI')
S('su.wendi', 'su.dugu')
M('su.yangdi', 'Sui Yangdi (Yang Guang)', 569, 618, 'Empereur des Sui (604-618)', SU, 'CN_SUI')
P('su.wendi', 'su.yangdi'); P('su.dugu', 'su.yangdi')
M('su.gongdi', 'Gongdi de Sui (Yang You)', 605, 619, 'Empereur des Sui (617-618), déposé', SU, 'CN_SUI')
g.fam('su.yangdi', 'su.gongdi')

T = [('tg.gaozu', 'Tang Gaozu (Li Yuan)', 566, 635, 'Fondateur des Tang (618-626)', None),
     ('tg.taizong', 'Tang Taizong (Li Shimin)', 598, 649, 'Empereur (626-649)', None),
     ('tg.gaozong', 'Tang Gaozong (Li Zhi)', 628, 683, 'Empereur (649-683)', None),
     ('tg.zhongzong', 'Tang Zhongzong (Li Xian)', 656, 710, 'Empereur (684 puis 705-710)', None),
     ('tg.ruizong', 'Tang Ruizong (Li Dan)', 662, 716, 'Empereur (684-690 puis 710-712)', None),
     ('tg.xuanzong', 'Tang Xuanzong (Li Longji)', 685, 762, 'Empereur (712-756)', None),
     ('tg.suzong', 'Tang Suzong (Li Heng)', 711, 762, 'Empereur (756-762)', None),
     ('tg.daizong', 'Tang Daizong (Li Yu)', 726, 779, 'Empereur (762-779)', None),
     ('tg.dezong', 'Tang Dezong (Li Kuo)', 742, 805, 'Empereur (779-805)', None),
     ('tg.shunzong', 'Tang Shunzong (Li Song)', 761, 806, 'Empereur (805)', None),
     ('tg.xianzong', 'Tang Xianzong (Li Chun)', 778, 820, 'Empereur (805-820)', None),
     ('tg.muzong', 'Tang Muzong (Li Heng)', 795, 824, 'Empereur (820-824)', None),
     ('tg.jingzong', 'Tang Jingzong (Li Zhan)', 809, 827, 'Empereur (824-827)', None),
     ('tg.wenzong', 'Tang Wenzong (Li Ang)', 809, 840, 'Empereur (827-840)', None),
     ('tg.wuzong', 'Tang Wuzong (Li Yan)', 814, 846, 'Empereur (840-846)', None),
     ('tg.xuanzong2', 'Tang Xuanzong II (Li Chen)', 810, 859, 'Empereur (846-859)', None),
     ('tg.yizong', 'Tang Yizong (Li Cui)', 833, 873, 'Empereur (859-873)', None),
     ('tg.xizong', 'Tang Xizong (Li Xuan)', 862, 888, 'Empereur (873-888)', None),
     ('tg.zhaozong', 'Tang Zhaozong (Li Ye)', 867, 904, 'Empereur (888-904)', None),
     ('tg.aidi', 'Tang Aidi (Li Zhu)', 892, 908, 'Dernier empereur Tang (904-907)', None)]
for c, n, b, d, t, a in T:
    M(c, n, b, d, t, TG, 'CN_TANG', approx=a)
F = [('gaozu', 'taizong'), ('taizong', 'gaozong'), ('gaozong', 'zhongzong'), ('gaozong', 'ruizong'), ('ruizong', 'xuanzong'),
     ('xuanzong', 'suzong'), ('suzong', 'daizong'), ('daizong', 'dezong'), ('dezong', 'shunzong'), ('shunzong', 'xianzong'),
     ('xianzong', 'muzong'), ('xianzong', 'xuanzong2'), ('muzong', 'jingzong'), ('muzong', 'wenzong'), ('muzong', 'wuzong'),
     ('xuanzong2', 'yizong'), ('yizong', 'xizong'), ('yizong', 'zhaozong'), ('zhaozong', 'aidi')]
for a, b in F:
    P('tg.' + a, 'tg.' + b)
M('tg.wu', 'Wu Zetian (Wu Zhao)', 624, 705, 'Impératrice, seule femme empereur de Chine (Zhou, 690-705)', 'Wu (Zhou)', 'CN_TANG', 'f', True,
  flag='Famille Wu : sans arbre')
S('tg.gaozong', 'tg.wu'); P('tg.wu', 'tg.zhongzong'); P('tg.wu', 'tg.ruizong')
W('tg.zhangsun', 'Impératrice Zhangsun', 601, 636, 'Épouse de Taizong', 'Zhangsun', 'CN_TANG')
S('tg.taizong', 'tg.zhangsun'); P('tg.zhangsun', 'tg.gaozong')
W('tg.yang_guifei', 'Yang Guifei', 719, 756, 'Concubine de Xuanzong', 'Yang', 'CN_TANG')
S('tg.xuanzong', 'tg.yang_guifei')
g.reposition = {'CN_SUI', 'CN_TANG'}
g.write()
