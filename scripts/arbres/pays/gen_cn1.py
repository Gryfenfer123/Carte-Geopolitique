import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(56, "Chine — Zhou et Qin")
g.notes = [
    "Première étape de la Chine, par ordre chronologique : Zhou (roi Wen → roi Nan) et Qin (roi Huiwen → Ziying).",
    "Pas de Xia ni de Shang : dynasties semi-légendaires ou connues seulement par des généalogies tardives, sans source datée fiable (à décider avec Martin).",
    "Zhou : les dates avant 841 av. J.-C. sont tentatives ; je n'ai saisi ni naissance ni mort, seulement la durée du règne dans le titre (pas de date inventée). Seule la ligne masculine de père en fils est modélisée ; épouses et frères omis sauf Tai Ren, Tai Si, Bo Yikao et le duc de Zhou.",
    "Qin : Ziying a une filiation incertaine (fils, frère, neveu ou cousin de Qin Er Shi selon les sources) : relié par un lien « famille » à Qin Er Shi, pas par une filiation.",
    "Années avant J.-C. : valeurs négatives (comme pour les empereurs du Japon).",
    "Prérequis : v55 exécuté.",
]
g.tree('CN_ZHO', 'CHN', 'Zhou')
g.tree('CN_QIN', 'CHN', 'Qin')
P, S = g.par, g.sp
ZH = 'Zhou (Ji)'
QN = 'Qin (Ying)'
A = 'dates tentatives (règne selon Wikipédia anglais) ; naissance et mort non renseignées'
FBz = {}
def Z(c, n, reign_start, reign_end, t, ld=True, d=None, b=None, ap=A, s='h'):
    FBz[uid('member:' + c)] = b if b is not None else reign_start
    g.m(c, n, b, d, t, ZH, 'CN_ZHO', s, ld, approx=ap)
g.m('cn.ji', 'Roi Ji de Zhou (Ji Li)', None, None, 'Père du roi Wen, titre posthume', ZH, 'CN_ZHO', 'h', False, approx='dates non renseignées')
FBz[uid('member:cn.ji')] = -1190
g.m('cn.tairen', 'Tai Ren', None, None, 'Mère du roi Wen', 'Ren (Zhi)', 'CN_ZHO', 'f', False, flag='Famille Ren (Zhi) : sans arbre', approx='dates non renseignées')
FBz[uid('member:cn.tairen')] = -1190
S('cn.ji', 'cn.tairen')
g.m('cn.wen', 'Roi Wen de Zhou (Ji Chang)', -1152, -1050, 'Seigneur de l\'Ouest, fondateur de la puissance des Zhou', ZH, 'CN_ZHO', 'h', True, approx='dates traditionnelles ; mort -1050, -1056 ou -1047 selon les sources')
P('cn.ji', 'cn.wen'); P('cn.tairen', 'cn.wen')
g.m('cn.taisi', 'Tai Si', None, None, 'Épouse du roi Wen', 'Si (Sì)', 'CN_ZHO', 'f', False, flag='Famille Si : sans arbre', approx='dates non renseignées')
FBz[uid('member:cn.taisi')] = -1150
S('cn.wen', 'cn.taisi')
g.m('cn.boyikao', 'Bo Yikao', None, None, 'Fils aîné du roi Wen', ZH, 'CN_ZHO', 'h', False, approx='dates non renseignées')
FBz[uid('member:cn.boyikao')] = -1120
g.m('cn.zhougong', 'Ji Dan (duc de Zhou)', None, None, 'Régent sous le roi Cheng', ZH, 'CN_ZHO', 'h', True, approx='dates non renseignées')
FBz[uid('member:cn.zhougong')] = -1100
for c in ('cn.boyikao', 'cn.zhougong'):
    P('cn.wen', c); P('cn.taisi', c)
Wz = [('cn.wu', 'Roi Wu de Zhou (Ji Fa)', -1046, -1043, 'Roi des Zhou (-1046 à -1043), renverse les Shang'),
      ('cn.cheng', 'Roi Cheng de Zhou (Ji Song)', -1042, -1021, 'Roi des Zhou (-1042 à -1021)'),
      ('cn.kang', 'Roi Kang de Zhou (Ji Zhao)', -1020, -996, 'Roi des Zhou (-1020 à -996)'),
      ('cn.zhao', 'Roi Zhao de Zhou (Ji Xia)', -995, -977, 'Roi des Zhou (-995 à -977)'),
      ('cn.mu', 'Roi Mu de Zhou (Ji Man)', -976, -922, 'Roi des Zhou (-976 à -922)'),
      ('cn.gong', 'Roi Gong de Zhou (Ji Yihu)', -922, -900, 'Roi des Zhou (-922 à -900)'),
      ('cn.yih', 'Roi Yi de Zhou (Ji Jian)', -899, -892, 'Roi des Zhou (-899 à -892)'),
      ('cn.xiao', 'Roi Xiao de Zhou (Ji Pifang)', -891, -886, 'Roi des Zhou (-891 à -886)'),
      ('cn.yi2', 'Roi Yi de Zhou (Ji Xie)', -885, -878, 'Roi des Zhou (-885 à -878)'),
      ('cn.li', 'Roi Li de Zhou (Ji Hu)', -877, -841, 'Roi des Zhou (-877 à -841), chassé par une révolte'),
      ('cn.xuan', 'Roi Xuan de Zhou (Ji Jing)', -827, -782, 'Roi des Zhou (-827 à -782)'),
      ('cn.you', 'Roi You de Zhou (Ji Gongnie)', -781, -771, 'Dernier roi des Zhou occidentaux (-781 à -771), tué par les Quanrong')]
for c, n, a, b, t in Wz:
    Z(c, n, a, b, t)
g.setdates  # no-op reference
P('cn.wen', 'cn.wu'); P('cn.wu', 'cn.cheng'); P('cn.cheng', 'cn.kang'); P('cn.kang', 'cn.zhao'); P('cn.zhao', 'cn.mu')
P('cn.mu', 'cn.gong'); P('cn.gong', 'cn.yih'); P('cn.mu', 'cn.xiao'); P('cn.yih', 'cn.yi2'); P('cn.yi2', 'cn.li'); P('cn.li', 'cn.xuan'); P('cn.xuan', 'cn.you')
Ez = [('cn.ping', 'Roi Ping de Zhou (Ji Yijiu)', -770, -720, 'Roi des Zhou (-770 à -720), déplace la capitale à l\'est'),
      ('cn.huan', 'Roi Huan de Zhou (Ji Lin)', -719, -697, 'Roi des Zhou (-719 à -697)'),
      ('cn.zhuang', 'Roi Zhuang de Zhou (Ji Tuo)', -696, -682, 'Roi des Zhou (-696 à -682)'),
      ('cn.xi', 'Roi Xi de Zhou (Ji Huqi)', -681, -677, 'Roi des Zhou (-681 à -677)'),
      ('cn.hui', 'Roi Hui de Zhou (Ji Lang)', -676, -652, 'Roi des Zhou (-676 à -652)'),
      ('cn.xiang', 'Roi Xiang de Zhou (Ji Zheng)', -651, -619, 'Roi des Zhou (-651 à -619)'),
      ('cn.qing', 'Roi Qing de Zhou (Ji Renchen)', -618, -613, 'Roi des Zhou (-618 à -613)'),
      ('cn.kuang', 'Roi Kuang de Zhou (Ji Ban)', -612, -607, 'Roi des Zhou (-612 à -607)'),
      ('cn.ding', 'Roi Ding de Zhou (Ji Yu)', -606, -586, 'Roi des Zhou (-606 à -586)'),
      ('cn.jian', 'Roi Jian de Zhou (Ji Yi)', -585, -572, 'Roi des Zhou (-585 à -572)'),
      ('cn.ling', 'Roi Ling de Zhou (Ji Xiexin)', -571, -545, 'Roi des Zhou (-571 à -545)'),
      ('cn.jing1', 'Roi Jing de Zhou (Ji Gui)', -544, -521, 'Roi des Zhou (-544 à -521)'),
      ('cn.dao', 'Roi Dao de Zhou (Ji Meng)', -520, -520, 'Roi des Zhou (-520, moins d\'un an)'),
      ('cn.jing2', 'Roi Jing de Zhou (Ji Gai)', -519, -476, 'Roi des Zhou (-519 à -476)'),
      ('cn.yuan', 'Roi Yuan de Zhou (Ji Ren)', -475, -469, 'Roi des Zhou (-475 à -469)'),
      ('cn.zhending', 'Roi Zhending de Zhou (Ji Jie)', -468, -442, 'Roi des Zhou (-468 à -442)'),
      ('cn.ai', 'Roi Ai de Zhou (Ji Quji)', -441, -441, 'Roi des Zhou (-441, moins d\'un an)'),
      ('cn.si', 'Roi Si de Zhou (Ji Shu)', -441, -441, 'Roi des Zhou (-441, moins d\'un an)'),
      ('cn.kao', 'Roi Kao de Zhou (Ji Wei)', -440, -426, 'Roi des Zhou (-440 à -426)'),
      ('cn.weilie', 'Roi Weilie de Zhou (Ji Wu)', -425, -402, 'Roi des Zhou (-425 à -402)'),
      ('cn.an', 'Roi An de Zhou (Ji Jiao)', -401, -376, 'Roi des Zhou (-401 à -376)'),
      ('cn.lie', 'Roi Lie de Zhou (Ji Xi)', -375, -369, 'Roi des Zhou (-375 à -369)'),
      ('cn.xian', 'Roi Xian de Zhou (Ji Bian)', -368, -321, 'Roi des Zhou (-368 à -321)'),
      ('cn.shenjing', 'Roi Shenjing de Zhou (Ji Ding)', -320, -315, 'Roi des Zhou (-320 à -315)'),
      ('cn.nan', 'Roi Nan de Zhou (Ji Yan)', -314, -256, 'Dernier roi des Zhou (-314 à -256), la dynastie s\'éteint avec lui')]
for c, n, a, b, t in Ez:
    Z(c, n, a, b, t)
P('cn.you', 'cn.ping'); g.fam('cn.ping', 'cn.huan')
for a, b in (('huan', 'zhuang'), ('zhuang', 'xi'), ('xi', 'hui'), ('hui', 'xiang'), ('xiang', 'qing'), ('qing', 'kuang'), ('qing', 'ding'), ('ding', 'jian'),
             ('jian', 'ling'), ('ling', 'jing1'), ('jing1', 'dao'), ('jing1', 'jing2'), ('jing2', 'yuan'), ('yuan', 'zhending'),
             ('zhending', 'ai'), ('zhending', 'si'), ('zhending', 'kao'), ('kao', 'weilie'), ('weilie', 'an'), ('an', 'lie'), ('an', 'xian'),
             ('xian', 'shenjing'), ('shenjing', 'nan')):
    P('cn.' + a, 'cn.' + b)
# --- Qin
FBq = {}
def Q(c, n, b, d, t, s='h', ld=False, ap=None, dyn=QN, fl=None, fb=None):
    g.m(c, n, b, d, t, dyn, 'CN_QIN', s, ld, flag=fl, approx=ap)
    if fb is not None:
        FBq[uid('member:' + c)] = fb
Q('cn.huiwen', 'Huiwen de Qin', -356, -311, 'Roi de Qin (-338 à -311)', ld=True)
Q('cn.wei_q', 'Reine Huiwen (de Wei)', None, -305, 'Reine de Qin', 'f', ap='naissance non renseignée', dyn='Wei', fl='Maison de Wei (royaume de Wei) : sans arbre', fb=-340)
Q('cn.mi', 'Reine douairière Xuan (Lady Mi)', None, -265, 'Reine douairière de Qin, régente', 'f', ap='naissance non renseignée', dyn='Mi (Chu)', fl='Clan Mi (royaume de Chu) : sans arbre', fb=-340)
S('cn.huiwen', 'cn.wei_q'); S('cn.huiwen', 'cn.mi')
Q('cn.wu_q', 'Wu de Qin (prince Dang)', -329, -307, 'Roi de Qin (-310 à -307)', ld=True)
P('cn.huiwen', 'cn.wu_q'); P('cn.wei_q', 'cn.wu_q')
Q('cn.zhaoxiang', 'Zhaoxiang de Qin (prince Ji)', -325, -251, 'Roi de Qin (-306 à -251)', ld=True)
P('cn.huiwen', 'cn.zhaoxiang'); P('cn.mi', 'cn.zhaoxiang')
Q('cn.tang', 'Reine douairière Tang', None, None, 'Reine douairière de Qin', 'f', ap='dates non renseignées', dyn='Tang (Qin)', fl='Famille Tang : sans arbre', fb=-320)
S('cn.zhaoxiang', 'cn.tang')
Q('cn.xiaowen', 'Xiaowen de Qin (Lord Anguo)', -302, -250, 'Roi de Qin (-250, trois jours)', ld=True, ap='mort 14 novembre -250')
P('cn.zhaoxiang', 'cn.xiaowen'); P('cn.tang', 'cn.xiaowen')
Q('cn.xia', 'Reine douairière Xia', None, None, 'Reine douairière de Qin', 'f', ap='dates non renseignées', dyn='Xia (Qin)', fl='Famille Xia : sans arbre', fb=-295)
S('cn.xiaowen', 'cn.xia')
Q('cn.zhuangxiang', 'Zhuangxiang de Qin (Zichu)', -281, -247, 'Roi de Qin (-250 à -247)', ld=True)
P('cn.xiaowen', 'cn.zhuangxiang'); P('cn.xia', 'cn.zhuangxiang')
Q('cn.zhao_q', 'Reine douairière Zhao', None, None, 'Reine douairière de Qin', 'f', ap='dates non renseignées', dyn='Zhao', fl='Famille Zhao (royaume de Zhao) : sans arbre ; présentée par Lü Buwei', fb=-275)
S('cn.zhuangxiang', 'cn.zhao_q')
Q('cn.shihuang', 'Qin Shi Huang (Ying Zheng)', -259, -210, 'Premier empereur de Chine (-221 à -210)', ld=True, ap='mort le 12 juillet -210 (d\'autres calculs : 11 ou 18 juillet, 10 septembre)')
P('cn.zhuangxiang', 'cn.shihuang'); P('cn.zhao_q', 'cn.shihuang')
Q('cn.chengjiao', 'Zhao Chengjiao', None, None, 'Demi-frère de Qin Shi Huang (infobox)', ap='dates non renseignées', fb=-258)
P('cn.zhuangxiang', 'cn.chengjiao')
Q('cn.fusu', 'Fusu', None, -210, 'Fils aîné et prince héritier de Qin Shi Huang', ap='naissance non renseignée ; mort vers août-septembre -210 (suicide forcé)', fb=-240)
Q('cn.huhai', 'Qin Er Shi (Huhai)', -229, -207, 'Second empereur (-210 à -207)', ld=True, ap='mort vers octobre -207')
P('cn.shihuang', 'cn.fusu'); P('cn.shihuang', 'cn.huhai')
Q('cn.huji', 'Hu Ji', None, None, 'Mère probable de Qin Er Shi', 'f', ap='dates non renseignées ; maternité « probable » selon la page', dyn='Hu (peuples du Nord)', fl='Origine « barbare » (Hu) : sans arbre', fb=-250)
P('cn.huji', 'cn.huhai')
Q('cn.ziying', 'Ziying', None, -206, 'Dernier souverain de Qin (-207), tué par Xiang Yu', ld=True, ap='naissance non renseignée ; filiation incertaine (fils de Fusu, frère, neveu ou cousin de Qin Er Shi selon les sources)', fb=-228)
g.fam('cn.huhai', 'cn.ziying')
Gen.FIXB = {**FBz, **FBq}
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
