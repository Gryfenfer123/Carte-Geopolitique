import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(84, "Chine — Gengiskhanides : Gengis Khan, ses fils, les grands khans et les empereurs Yuan")
g.notes = ["Nouvel arbre « Gengiskhanides (Yuan) » (aucun n'existait). Rien n'est supprimé.", 'Dates : connues par ailleurs (histoire mongole), aucune page consultée pour ce lot ; la naissance de Gengis Khan (vers 1162) est discutée.', 'Börte, Sorghaghtani Beki et Chabi viennent de familles sans arbre : placées ici et signalées.', "Non fait : Ilkhanat (Houlagou et descendants), Horde d'Or au-delà de Batu, Djaghataïdes, autres fils et épouses."]
g.tree('MN_GEN', 'CHN', 'Gengiskhanides (Yuan)', section_title='Gengiskhanides (Yuan)')
g.reposition = {'MN_GEN'}
P, S = g.par, g.sp
def M(code, name, b, d, title, dyn, tree, g_='h', leader=True, approx=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, tree, approx=None):
    return M(code, name, b, d, title, house, tree, 'f', False, approx, 'Famille %s : sans arbre' % house)
def chain(pref, lst):
    for a, b in lst:
        P(pref + a, pref + b)
GN = 'Gengiskhanides'; T = 'MN_GEN'
L = [('genghis', 'Gengis Khan (Temüjin)', 1162, 1227, 'Fondateur de l\'Empire mongol', 'naissance vers 1162 (discutée)'),
     ('jochi', 'Djötchi', 1182, 1227, 'Fils aîné de Gengis Khan', None),
     ('chagatai', 'Djaghataï', 1183, 1242, 'Fils de Gengis Khan, khan du Djaghataï', None),
     ('ogedei', 'Ögödei', 1186, 1241, 'Grand khan (1229-1241)', None),
     ('tolui', 'Tolui', 1192, 1232, 'Fils cadet de Gengis Khan, régent', None),
     ('batu', 'Batu Khan', 1205, 1255, 'Fondateur de la Horde d\'Or', None),
     ('guyuk', 'Güyük', 1206, 1248, 'Grand khan (1246-1248)', None),
     ('mongke', 'Möngke', 1209, 1259, 'Grand khan (1251-1259)', None),
     ('kublai', 'Kubilaï Khan (Yuan Shizu)', 1215, 1294, 'Grand khan, fondateur de la dynastie Yuan (1271-1294)', None),
     ('hulagu', 'Houlagou', 1218, 1265, 'Fondateur de l\'Ilkhanat', None),
     ('ariq', 'Ariq Böke', 1219, 1266, 'Prétendant au grand khanat', None),
     ('zhenjin', 'Zhenjin', 1243, 1286, 'Prince héritier, fils de Kubilaï', None),
     ('gammala', 'Gammala', 1263, 1302, 'Petit-fils de Kubilaï', None),
     ('darmabala', 'Darmabala', 1264, 1292, 'Petit-fils de Kubilaï', None),
     ('temur', 'Temür Khan (Yuan Chengzong)', 1265, 1307, 'Empereur Yuan (1294-1307)', None),
     ('kulug', 'Külüg Khan (Yuan Wuzong)', 1281, 1311, 'Empereur Yuan (1307-1311)', None),
     ('ayur', 'Ayurbarwada (Yuan Renzong)', 1285, 1320, 'Empereur Yuan (1311-1320)', None),
     ('gegeen', 'Gegeen Khan (Yuan Yingzong)', 1303, 1323, 'Empereur Yuan (1320-1323)', None),
     ('yesun', 'Yesün Temür (Taiding)', 1293, 1328, 'Empereur Yuan (1323-1328)', None),
     ('kusala', 'Kusala (Yuan Mingzong)', 1300, 1329, 'Empereur Yuan (1329)', None),
     ('tugh', 'Tugh Temür (Yuan Wenzong)', 1304, 1332, 'Empereur Yuan (1328-1332)', None),
     ('rinchin', 'Rinchinbal (Yuan Ningzong)', 1326, 1332, 'Empereur Yuan (1332)', None),
     ('toghon', 'Toghon Temür (Yuan Huizong)', 1320, 1370, 'Dernier empereur Yuan (1333-1368)', None)]
for c, n, b, d, t, a in L:
    M('gn.' + c, n, b, d, t, GN, T, approx=a)
W('gn.borte', 'Börte', 1161, 1230, 'Première épouse de Gengis Khan', 'Khongirad', T)
for c in ('jochi', 'chagatai', 'ogedei', 'tolui'):
    P('gn.genghis', 'gn.' + c); P('gn.borte', 'gn.' + c)
S('gn.genghis', 'gn.borte')
P('gn.jochi', 'gn.batu'); P('gn.ogedei', 'gn.guyuk')
W('gn.sorghaghtani', 'Sorghaghtani Beki', 1190, 1252, 'Épouse de Tolui, mère de quatre grands khans', 'Kerait', T,
  approx='naissance vers 1190')
S('gn.tolui', 'gn.sorghaghtani')
for c in ('mongke', 'kublai', 'hulagu', 'ariq'):
    P('gn.tolui', 'gn.' + c); P('gn.sorghaghtani', 'gn.' + c)
W('gn.chabi', 'Chabi', 1216, 1281, 'Impératrice, épouse de Kubilaï', 'Khongirad', T)
S('gn.kublai', 'gn.chabi')
P('gn.kublai', 'gn.zhenjin'); P('gn.chabi', 'gn.zhenjin')
chain('gn.', [('zhenjin', 'gammala'), ('zhenjin', 'darmabala'), ('zhenjin', 'temur'), ('darmabala', 'kulug'),
              ('darmabala', 'ayur'), ('ayur', 'gegeen'), ('gammala', 'yesun'), ('kulug', 'kusala'), ('kulug', 'tugh'),
              ('kusala', 'toghon'), ('kusala', 'rinchin')])

g.write()
