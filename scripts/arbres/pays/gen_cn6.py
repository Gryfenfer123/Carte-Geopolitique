import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(83, "Chine — dynastie Song (Nord et Sud) de Taizu à l'empereur Bing")
g.notes = ["Nouvel arbre « Song » (aucun n'existait). Rien n'est supprimé.", 'Dates : connues par ailleurs (histoire de Chine), aucune page consultée pour ce lot. Les adoptions et frères sont reliés par un lien « famille » (pas de filiation).', "L'impératrice Liu (régente) vient d'une famille sans arbre : signalée.", 'Non fait : épouses autres que Liu, princes non empereurs (dont les ancêtres de Yingzong, Xiaozong, Lizong, Duzong).']
g.tree('CN_SONG', 'CHN', 'Song', section_title='Song')
g.reposition = {'CN_SONG'}
P, S = g.par, g.sp
def M(code, name, b, d, title, dyn, tree, g_='h', leader=True, approx=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, tree, approx=None):
    return M(code, name, b, d, title, house, tree, 'f', False, approx, 'Famille %s : sans arbre' % house)
def chain(pref, lst):
    for a, b in lst:
        P(pref + a, pref + b)
SG = 'Song (Zhao)'; T = 'CN_SONG'
L = [('taizu', 'Song Taizu (Zhao Kuangyin)', 927, 976, 'Fondateur des Song (960-976)'),
     ('taizong', 'Song Taizong (Zhao Jiong)', 939, 997, 'Empereur (976-997)'),
     ('zhenzong', 'Song Zhenzong (Zhao Heng)', 968, 1022, 'Empereur (997-1022)'),
     ('renzong', 'Song Renzong (Zhao Zhen)', 1010, 1063, 'Empereur (1022-1063)'),
     ('yingzong', 'Song Yingzong (Zhao Shu)', 1032, 1067, 'Empereur (1063-1067)'),
     ('shenzong', 'Song Shenzong (Zhao Xu)', 1048, 1085, 'Empereur (1067-1085)'),
     ('zhezong', 'Song Zhezong (Zhao Xu)', 1077, 1100, 'Empereur (1085-1100)'),
     ('huizong', 'Song Huizong (Zhao Ji)', 1082, 1135, 'Empereur (1100-1126), capturé par les Jin'),
     ('qinzong', 'Song Qinzong (Zhao Huan)', 1100, 1161, 'Empereur (1126-1127), capturé par les Jin'),
     ('gaozong', 'Song Gaozong (Zhao Gou)', 1107, 1187, 'Premier empereur des Song du Sud (1127-1162)'),
     ('xiaozong', 'Song Xiaozong (Zhao Shen)', 1127, 1194, 'Empereur (1162-1189)'),
     ('guangzong', 'Song Guangzong (Zhao Dun)', 1147, 1200, 'Empereur (1189-1194)'),
     ('ningzong', 'Song Ningzong (Zhao Kuo)', 1168, 1224, 'Empereur (1194-1224)'),
     ('lizong', 'Song Lizong (Zhao Yun)', 1205, 1264, 'Empereur (1224-1264)'),
     ('duzong', 'Song Duzong (Zhao Qi)', 1240, 1274, 'Empereur (1264-1274)'),
     ('gongdi', 'Song Gongdi (Zhao Xian)', 1271, 1323, 'Empereur (1274-1276), se rend aux Mongols'),
     ('duanzong', 'Song Duanzong (Zhao Shi)', 1270, 1278, 'Empereur (1276-1278)'),
     ('bing', 'Song Bing (Zhao Bing)', 1272, 1279, 'Dernier empereur Song (1278-1279)')]
for c, n, b, d, t in L:
    M('sg.' + c, n, b, d, t, SG, T)
chain('sg.', [('taizong', 'zhenzong'), ('zhenzong', 'renzong'), ('yingzong', 'shenzong'), ('shenzong', 'zhezong'),
              ('shenzong', 'huizong'), ('huizong', 'qinzong'), ('huizong', 'gaozong'), ('xiaozong', 'guangzong'),
              ('guangzong', 'ningzong'), ('duzong', 'gongdi'), ('duzong', 'duanzong'), ('duzong', 'bing')])
for a, b in [('taizu', 'taizong'), ('renzong', 'yingzong'), ('gaozong', 'xiaozong'), ('ningzong', 'lizong'), ('lizong', 'duzong')]:
    g.fam('sg.' + a, 'sg.' + b)
W('sg.liu', 'Impératrice douairière Liu', 968, 1033, 'Épouse de Zhenzong, régente de Renzong', 'Liu', T)
S('sg.zhenzong', 'sg.liu'); g.fam('sg.liu', 'sg.renzong')

g.write()
