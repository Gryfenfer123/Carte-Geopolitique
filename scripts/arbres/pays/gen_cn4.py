import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(59, "Chine — Jin (Sima) : Jin occidentaux et orientaux")
g.notes = [
    "Chine, étape 4 : dynastie Jin (Sima), de Sima Yi à Gong de Jin (Jin occidentaux 266-316 puis orientaux 317-420), un seul arbre.",
    "Sources : pages Wikipédia anglaises de chaque empereur. Filiation Sima Zhou -> Sima Jin -> Yuan de Jin : non confirmée par les pages consultées, ajoutée de connaissance générale (marquée « à vérifier »).",
    "Deux « Sima Yan » apparaissent dans la liste des fils de Wu : seul le prince Xiao de Wu (281-311), père de Min, est créé ; l'autre (prince de Dai, né en 272) est omis.",
    "Les Seize Royaumes (Han-Zhao, Zhao postérieur, Yan, Qin, Liang…) ne sont pas traités ici (à décider).",
    "Prérequis : v58 exécuté.",
]
g.tree('CN_JIN', 'CHN', 'Jin (Sima)')
P, S = g.par, g.sp
SM = 'Sima (Jin)'
FB = {}
def J(c, n, b, d, t, s='h', ld=False, ap=None, fb=None, dyn=SM):
    g.m(c, n, b, d, t, dyn, 'CN_JIN', s, ld, approx=ap)
    if fb is not None:
        FB[uid('member:' + c)] = fb
def Wf(c, n, b, d, t, clan, ap=None, fb=None):
    g.m(c, n, b, d, t, clan, 'CN_JIN', 'f', False, flag=f'Famille consort {clan} (Chine) : sans arbre', approx=ap)
    if fb is not None:
        FB[uid('member:' + c)] = fb
EMP = 'Empereur de Chine'
J('jn.fang', 'Sima Fang', None, None, 'Père de Sima Yi', ap='dates non renseignées', fb=150)
J('jn.yi', 'Sima Yi (Jin Xuandi)', 179, 251, 'Régent des Wei, ancêtre des Jin (empereur à titre posthume)', ld=True, ap='mort le 7 septembre 251 ; mère non nommée')
P('jn.fang', 'jn.yi')
Wf('jn.zhang', 'Zhang Chunhua (impératrice Xuanmu)', None, None, 'Épouse de Sima Yi', 'Zhang', ap='dates non renseignées', fb=185)
S('jn.yi', 'jn.zhang')
J('jn.shi', 'Sima Shi (Jin Jingdi)', 208, 255, 'Régent des Wei (251-255)', ld=True, ap='mort le 23 mars 255')
J('jn.zhao', 'Sima Zhao (Jin Wendi)', 211, 265, 'Régent des Wei (255-265)', ld=True, ap='mort le 6 septembre 265')
J('jn.zhou', 'Sima Zhou (prince de Langya)', None, None, 'Fils de Sima Yi (avec dame Fu)', ap='dates non renseignées', fb=227)
for c in ('jn.shi', 'jn.zhao', 'jn.zhou'):
    P('jn.yi', c)
for c in ('jn.shi', 'jn.zhao'):
    P('jn.zhang', c)
Wf('jn.xiahouhui', 'Xiahou Hui (impératrice Jinghuai)', 211, 234, 'Première épouse de Sima Shi', 'Xiahou')
Wf('jn.yanghuiyu', 'Yang Huiyu (impératrice Jingxian)', 214, 278, 'Épouse de Sima Shi', 'Yang')
S('jn.shi', 'jn.xiahouhui'); S('jn.shi', 'jn.yanghuiyu')
Wf('jn.wangyuanji', 'Wang Yuanji (impératrice Wenming)', 217, 268, 'Épouse de Sima Zhao, mère de Sima Yan', 'Wang (Donghai)')
S('jn.zhao', 'jn.wangyuanji')
J('jn.wu', 'Wu de Jin (Sima Yan)', 236, 290, EMP + ' (265 à 290), fondateur des Jin occidentaux', ld=True, ap='mort le 16 mai 290')
P('jn.zhao', 'jn.wu'); P('jn.wangyuanji', 'jn.wu')
Wf('jn.yangyan', 'Impératrice Wuyuan (Yang Yan)', 238, 274, 'Impératrice de Chine', 'Yang')
Wf('jn.yangzhi', 'Impératrice Wudao (Yang Zhi)', 259, 292, 'Impératrice de Chine', 'Yang')
S('jn.wu', 'jn.yangyan'); S('jn.wu', 'jn.yangzhi')
J('jn.hui', 'Hui de Jin (Sima Zhong)', 259, 307, EMP + ' (290 à 307)', ld=True, ap='mort le 8 janvier 307')
P('jn.wu', 'jn.hui'); P('jn.yangyan', 'jn.hui')
J('jn.simajian', 'Sima Jian (prince Xian de Qin)', 262, 291, 'Fils de Wu', fb=None)
J('jn.simaying', 'Sima Ying (prince de Chengdu)', 279, 306, 'Fils de Wu, prince de Chengdu')
J('jn.simayan_w', 'Sima Yan (prince Xiao de Wu)', 281, 311, 'Fils de Wu, père de Min', ap='distinct du prince de Dai du même nom')
J('jn.huai', 'Huai de Jin (Sima Chi)', 284, 313, EMP + ' (307 à 311), empoisonné en captivité', ld=True, ap='mort le 14 mars 313')
for c in ('jn.simajian', 'jn.simaying', 'jn.simayan_w', 'jn.huai'):
    P('jn.wu', c)
Wf('jn.wang_h', 'Dame Wang Yuanji (王媛姬, mère de Huai)', None, None, 'Concubine de Wu, mère de Huai', 'Wang', ap='dates non renseignées ; ne pas confondre avec l\'impératrice Wang Yuanji (王元姬)', fb=262)
S('jn.wu', 'jn.wang_h'); P('jn.wang_h', 'jn.huai')
Wf('jn.jianan', 'Jia Nanfeng (impératrice Huijia)', 257, 300, 'Impératrice de Chine, au cœur de la guerre des Huit Princes', 'Jia')
Wf('jn.yangxianrong', 'Yang Xianrong (impératrice Xianwen)', None, 322, 'Impératrice de Chine (300)', 'Yang', ap='naissance non renseignée', fb=265)
Wf('jn.xiejiu', 'Xie Jiu (Shuyuan)', None, 300, 'Concubine de Wu puis de Hui, mère du prince héritier', 'Xie', ap='naissance non renseignée', fb=255)
for c in ('jn.jianan', 'jn.yangxianrong', 'jn.xiejiu'):
    S('jn.hui', c)
J('jn.simayu', 'Sima Yu (prince héritier Minhuai)', 278, 300, 'Prince héritier, fils de Hui', fb=None)
P('jn.hui', 'jn.simayu'); P('jn.xiejiu', 'jn.simayu')
Wf('jn.lianglanbi', 'Liang Lanbi', None, None, 'Impératrice de Chine (épouse de Huai)', 'Liang', ap='dates non renseignées', fb=285)
S('jn.huai', 'jn.lianglanbi')
J('jn.min', 'Min de Jin (Sima Ye)', 300, 318, 'Dernier empereur des Jin occidentaux (313 à 316)', ld=True, ap='mort le 7 février 318')
Wf('jn.xun', 'Dame Xun (fille de Xun Xu)', None, None, 'Mère de Min', 'Xun', ap='dates non renseignées', fb=282)
S('jn.simayan_w', 'jn.xun')
P('jn.simayan_w', 'jn.min'); P('jn.xun', 'jn.min')
# Jin orientaux
J('jn.jin_s', 'Sima Jin (prince de Langya)', None, 290, 'Prince de Langya, père de Yuan', ap='naissance non renseignée ; filiation avec Sima Zhou à vérifier (connaissance générale)', fb=250)
P('jn.zhou', 'jn.jin_s')
Wf('jn.xiahouguangji', 'Xiahou Guangji', None, None, 'Princesse consort de Langya, mère de Yuan', 'Xiahou', ap='dates non renseignées', fb=255)
S('jn.jin_s', 'jn.xiahouguangji')
J('jn.yuan', 'Yuan de Jin (Sima Rui)', 276, 323, EMP + ' (318 à 323), fondateur des Jin orientaux', ld=True, ap='mort le 3 janvier 323 ; rumeur d\'une autre paternité (Niu Jin)')
P('jn.jin_s', 'jn.yuan'); P('jn.xiahouguangji', 'jn.yuan')
Wf('jn.yu_mengmu', 'Impératrice Yuanjing (Yu Mengmu)', 277, 312, 'Impératrice de Chine', 'Yu')
Wf('jn.zheng', 'Zheng Achun (impératrice douairière Jianwenxuan)', None, 326, 'Concubine de Yuan, mère de Jianwen', 'Zheng', ap='naissance non renseignée', fb=285)
S('jn.yuan', 'jn.yu_mengmu'); S('jn.yuan', 'jn.zheng')
J('jn.ming', 'Ming de Jin (Sima Shao)', 299, 325, EMP + ' (323 à 325)', ld=True, ap='mort le 18 octobre 325')
P('jn.yuan', 'jn.ming'); P('jn.yu_mengmu', 'jn.ming')
J('jn.simapou', 'Sima Pou (prince de Langya)', 300, 317, 'Fils de Yuan')
J('jn.simachong', 'Sima Chong (prince de Donghai)', 311, 341, 'Fils de Yuan')
J('jn.simaxi', 'Sima Xi (prince de Wuling)', 316, 381, 'Fils de Yuan')
for c in ('jn.simapou', 'jn.simachong', 'jn.simaxi'):
    P('jn.yuan', c)
for c in ('jn.simapou',):
    P('jn.yu_mengmu', c)
Wf('jn.yu_wenjun', 'Yu Wenjun (impératrice Mingmu)', 297, 328, 'Impératrice de Chine', 'Yu')
S('jn.ming', 'jn.yu_wenjun')
J('jn.cheng', 'Cheng de Jin (Sima Yan)', 321, 342, EMP + ' (325 à 342)', ld=True, ap='naissance décembre 321 ou janvier 322 ; mort le 26 juillet 342')
J('jn.kang', 'Kang de Jin (Sima Yue)', 322, 344, EMP + ' (342 à 344)', ld=True, ap='mort le 17 novembre 344')
for c in ('jn.cheng', 'jn.kang'):
    P('jn.ming', c); P('jn.yu_wenjun', c)
Wf('jn.du', 'Du Lingyang (impératrice Chenggong)', 321, 341, 'Impératrice de Chine', 'Du')
Wf('jn.zhou_c', 'Consort Zhou (mère d\'Ai et de Fei)', None, 363, 'Concubine de Cheng', 'Zhou', ap='naissance non renseignée', fb=325)
S('jn.cheng', 'jn.du'); S('jn.cheng', 'jn.zhou_c')
Wf('jn.chu', 'Chu Suanzi (impératrice Kangxian)', 324, 384, 'Impératrice de Chine', 'Chu')
S('jn.kang', 'jn.chu')
J('jn.mu', 'Mu de Jin (Sima Dan)', 343, 361, EMP + ' (344 à 361)', ld=True, ap='mort le 10 juillet 361')
P('jn.kang', 'jn.mu'); P('jn.chu', 'jn.mu')
Wf('jn.hefani', 'He Fani (impératrice Muzhang)', 339, 404, 'Impératrice de Chine', 'He')
S('jn.mu', 'jn.hefani')
J('jn.ai', 'Ai de Jin (Sima Pi)', 341, 365, EMP + ' (361 à 365)', ld=True, ap='mort le 30 mars 365')
J('jn.fei', 'Fei de Jin (Sima Yi)', 342, 386, EMP + ' (365 à 371), déposé', ld=True, ap='mort le 23 novembre 386')
for c in ('jn.ai', 'jn.fei'):
    P('jn.cheng', c); P('jn.zhou_c', c)
Wf('jn.wangmuzhi', 'Wang Muzhi (impératrice Aijing)', None, 365, 'Impératrice de Chine', 'Wang (Taiyuan)', ap='naissance non renseignée', fb=342)
S('jn.ai', 'jn.wangmuzhi')
Wf('jn.yudaolian', 'Yu Daolian (impératrice Xiao)', None, 366, 'Impératrice de Chine', 'Yu', ap='naissance non renseignée', fb=343)
S('jn.fei', 'jn.yudaolian')
J('jn.jianwen', 'Jianwen de Jin (Sima Yu)', 320, 372, EMP + ' (371 à 372)', ld=True, ap='mort le 12 septembre 372 ; mère : Zheng Achun (texte) ou impératrice douairière Jianwenxuan (infobox, même personne)')
P('jn.yuan', 'jn.jianwen'); P('jn.zheng', 'jn.jianwen')
Wf('jn.wangjianji', 'Wang Jianji (impératrice Jianwenshun)', None, 348, 'Épouse de Jianwen', 'Wang (Taiyuan)', ap='naissance non renseignée', fb=322)
Wf('jn.lilingrong', 'Li Lingrong (impératrice douairière Xiaowuwen)', None, 400, 'Concubine de Jianwen, mère de Xiaowu', 'Li', ap='naissance donnée 351 par la source, incompatible avec Xiaowu (362) : laissée vide', fb=335)
S('jn.jianwen', 'jn.wangjianji'); S('jn.jianwen', 'jn.lilingrong')
J('jn.xiaowu', 'Xiaowu de Jin (Sima Yao)', 362, 396, EMP + ' (372 à 396)', ld=True, ap='mort le 6 novembre 396')
J('jn.daozi', 'Sima Daozi (prince de Kuaiji)', None, None, 'Fils de Jianwen, régent', ap='dates non renseignées', fb=364)
for c in ('jn.xiaowu', 'jn.daozi'):
    P('jn.jianwen', c); P('jn.lilingrong' if c == 'jn.xiaowu' else 'jn.zheng', c) if c == 'jn.xiaowu' else None
Wf('jn.wangfahui', 'Wang Fahui (impératrice Xiaowuding)', 360, 380, 'Impératrice de Chine', 'Wang (Taiyuan)')
Wf('jn.chenguinu', 'Chen Guinü (impératrice douairière Ande)', 362, 390, 'Concubine de Xiaowu, mère d\'An et de Gong', 'Chen')
S('jn.xiaowu', 'jn.wangfahui'); S('jn.xiaowu', 'jn.chenguinu')
J('jn.an', 'An de Jin (Sima Dezong)', 382, 419, EMP + ' (396 à 419)', ld=True, ap='naissance 382 ou 383 ; mort le 28 janvier 419')
J('jn.gong', 'Gong de Jin (Sima Dewen)', 386, 421, 'Dernier empereur des Jin (419 à 420)', ld=True, ap='mort en octobre ou novembre 421 (étouffé)')
for c in ('jn.an', 'jn.gong'):
    P('jn.xiaowu', c); P('jn.chenguinu', c)
Wf('jn.wangshenai', 'Wang Shen\'ai (impératrice Anxi)', 384, 412, 'Impératrice de Chine', 'Wang (Langya)')
S('jn.an', 'jn.wangshenai')
Wf('jn.chulingyuan', 'Chu Lingyuan (impératrice Gongsi)', 384, 436, 'Impératrice de Chine', 'Chu')
S('jn.gong', 'jn.chulingyuan')
Gen.FIXB = FB
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
