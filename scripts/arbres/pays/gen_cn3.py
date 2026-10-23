import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(58, "Chine — Trois Royaumes (Cao Wei, Shu Han, Wu oriental)")
g.notes = [
    "Chine, étape 3 : trois arbres, Cao Wei (Cao Cao -> Cao Huan), Shu Han (Liu Bei -> Liu Shan et enfants) et Wu oriental (Sun Jian -> Sun Hao).",
    "Cao Jie (fille de Cao Cao) est créée dans l'arbre Cao Wei et reliée à Liu Xie (Han Xian, v57). Dame Sun (sœur de Sun Quan) est créée dans le Wu oriental et reliée à Liu Bei.",
    "Filiations contestées : Cao Fang (probablement petit-fils de Cao Zhang, adopté par Cao Rui) ; Cao Rui (certains historiens : fils de Yuan Xi) ; mère de Liu Shan (dame Gan dans le texte, impératrice Zhaolie dans l'infobox) ; mère de Sun Xiu (consort Wang ou impératrice Jinghuai). Rapport au cas par cas.",
    "Liu Bei est un descendant revendiqué des Han ; aucun lien n'est tracé car aucune page consultée ne le donne.",
    "Prérequis : v57 exécuté.",
]
g.tree('CN_WEI', 'CHN', 'Cao Wei')
g.tree('CN_SHU', 'CHN', 'Shu Han')
g.tree('CN_WU', 'CHN', 'Wu oriental')
P, S = g.par, g.sp
CW, LS, SW = 'Cao (Wei)', 'Liu (Shu Han)', 'Sun (Wu)'
FB = {}
def T(c, n, b, d, t, s, ld, dyn, tree, ap=None, fb=None, fl=None):
    g.m(c, n, b, d, t, dyn, tree, s, ld, flag=fl, approx=ap)
    if fb is not None:
        FB[uid('member:' + c)] = fb
def Wf(c, n, b, d, t, clan, tree, ap=None, fb=None):
    T(c, n, b, d, t, 'f', False, clan, tree, ap, fb, fl=f'Famille consort {clan} (Chine) : sans arbre')
# --- Cao Wei
T('tk.caosong', 'Cao Song', None, None, 'Père de Cao Cao', 'h', False, CW, 'CN_WEI', 'dates non renseignées', 120)
T('tk.caocao', 'Cao Cao', 155, 220, 'Roi de Wei, fondateur de fait des Wei (empereur Wu à titre posthume)', 'h', True, CW, 'CN_WEI', 'naissance « vers 155 » ; mort le 15 mars 220')
P('tk.caosong', 'tk.caocao')
Wf('tk.dingshi', 'Dame Ding (épouse de Cao Cao)', None, None, 'Première épouse de Cao Cao', 'Ding', 'CN_WEI', 'dates non renseignées', 155)
Wf('tk.bianshi', 'Dame Bian (impératrice Wuxuan)', None, None, 'Épouse de Cao Cao, mère de Cao Pi', 'Bian', 'CN_WEI', 'dates non renseignées', 160)
S('tk.caocao', 'tk.dingshi'); S('tk.caocao', 'tk.bianshi')
T('tk.caoang', 'Cao Ang', None, 197, 'Fils aîné de Cao Cao, tué à Wancheng', 'h', False, CW, 'CN_WEI', 'naissance non renseignée', 175)
P('tk.caocao', 'tk.caoang')
T('tk.caopi', 'Cao Pi (Wei Wendi)', 187, 226, 'Premier empereur de Wei (220 à 226)', 'h', True, CW, 'CN_WEI', 'naissance « fin 187 » ; mort le 29 juin 226')
T('tk.caozhi', 'Cao Zhi', None, None, 'Prince de Chen, poète', 'h', False, CW, 'CN_WEI', 'dates non renseignées', 192)
T('tk.caozhang', 'Cao Zhang', None, 223, 'Prince de Rencheng', 'h', False, CW, 'CN_WEI', 'naissance non renseignée', 190)
T('tk.caoyu', 'Cao Yu (prince de Yan)', None, None, 'Fils de Cao Cao, père de Cao Huan', 'h', False, CW, 'CN_WEI', 'dates non renseignées', 200)
for c in ('tk.caopi', 'tk.caozhi', 'tk.caozhang'):
    P('tk.caocao', c); P('tk.bianshi', c)
P('tk.caocao', 'tk.caoyu')
T('tk.caojie', 'Cao Jie (impératrice Xianmu)', 197, 260, 'Impératrice de Han, épouse de Xian', 'f', False, CW, 'CN_WEI', 'dates 197-260 (rapport sur la page Xian)')
P('tk.caocao', 'tk.caojie')
S('hn.xian', 'tk.caojie')
Wf('tk.zhen', 'Impératrice Wenzhao (dame Zhen)', 183, 221, 'Impératrice de Wei', 'Zhen', 'CN_WEI')
Wf('tk.guonv', 'Impératrice Wende (Guo Nüwang)', 184, 235, 'Impératrice de Wei', 'Guo', 'CN_WEI')
S('tk.caopi', 'tk.zhen'); S('tk.caopi', 'tk.guonv')
T('tk.caorui', 'Cao Rui (Wei Mingdi)', 204, 239, 'Deuxième empereur de Wei (226 à 239)', 'h', True, CW, 'CN_WEI', 'naissance 204 ou 205 ; mort le 22 janvier 239 ; certains historiens le disent fils de Yuan Xi')
P('tk.caopi', 'tk.caorui'); P('tk.zhen', 'tk.caorui')
Wf('tk.mao_c', 'Impératrice Mingdao (clan Mao)', None, 237, 'Impératrice de Wei', 'Mao', 'CN_WEI', 'naissance non renseignée', 205)
Wf('tk.guo_c', 'Impératrice Mingyuan (clan Guo)', None, 264, 'Impératrice de Wei', 'Guo', 'CN_WEI', 'naissance non renseignée', 210)
S('tk.caorui', 'tk.mao_c'); S('tk.caorui', 'tk.guo_c')
T('tk.caolin', 'Cao Lin (prince de Donghai)', None, 251, 'Fils de Cao Pi, père de Cao Mao', 'h', False, CW, 'CN_WEI', 'naissance non renseignée', 210)
P('tk.caopi', 'tk.caolin')
T('tk.caokai', 'Cao Kai (prince de Rencheng)', None, None, 'Fils de Cao Zhang (selon une hypothèse)', 'h', False, CW, 'CN_WEI', 'dates non renseignées ; filiation hypothétique', 212)
P('tk.caozhang', 'tk.caokai')
T('tk.caofang', 'Cao Fang (Wei Shaodi)', 232, 274, 'Troisième empereur de Wei (239 à 254), déposé', 'h', True, CW, 'CN_WEI', 'filiation biologique incertaine : probablement fils de Cao Kai ; adopté par Cao Rui')
P('tk.caokai', 'tk.caofang'); g.fam('tk.caorui', 'tk.caofang')
Wf('tk.zhen_f', 'Impératrice Huai (Zhen, épouse de Cao Fang)', None, 251, 'Impératrice de Wei', 'Zhen', 'CN_WEI', 'naissance non renseignée ; épousée en 243', 232)
Wf('tk.zhang_f', 'Impératrice Zhang (épouse de Cao Fang)', None, None, 'Impératrice de Wei, déposée en 254', 'Zhang', 'CN_WEI', 'dates non renseignées', 232)
Wf('tk.wang_f', 'Impératrice Wang (épouse de Cao Fang)', None, None, 'Impératrice de Wei (254)', 'Wang', 'CN_WEI', 'dates non renseignées', 232)
for c in ('tk.zhen_f', 'tk.zhang_f', 'tk.wang_f'):
    S('tk.caofang', c)
T('tk.caomao', 'Cao Mao (Wei Gaoguixiang gong)', 241, 260, 'Quatrième empereur de Wei (254 à 260), tué lors d\'un coup d\'État', 'h', True, CW, 'CN_WEI', 'mort le 2 juin 260 ; mère non nommée')
P('tk.caolin', 'tk.caomao')
Wf('tk.bian_m', 'Impératrice Bian (épouse de Cao Mao)', None, None, 'Impératrice de Wei', 'Bian', 'CN_WEI', 'dates non renseignées', 241)
S('tk.caomao', 'tk.bian_m')
T('tk.caohuan', 'Cao Huan (Wei Yuandi)', 246, 302, 'Cinquième et dernier empereur de Wei (260 à 266)', 'h', True, CW, 'CN_WEI', 'mort 302 (infobox ; entre février 302 et février 303 selon une note) ; mère non confirmée')
P('tk.caoyu', 'tk.caohuan')
Wf('tk.bian_h', 'Impératrice Bian (épouse de Cao Huan)', None, None, 'Impératrice de Wei (263)', 'Bian', 'CN_WEI', 'dates non renseignées', 246)
S('tk.caohuan', 'tk.bian_h')
# --- Shu Han
T('tk.liuhong_s', 'Liu Hong (père de Liu Bei)', None, None, 'Père de Liu Bei', 'h', False, LS, 'CN_SHU', 'dates non renseignées', 130)
T('tk.liubei', 'Liu Bei (Shu Han Zhaolie)', 161, 223, 'Fondateur et empereur du Shu Han (221 à 223)', 'h', True, LS, 'CN_SHU', 'mort le 10 juin 223 ; mère non nommée')
P('tk.liuhong_s', 'tk.liubei')
Wf('tk.gan', 'Dame Gan', None, None, 'Concubine de Liu Bei, mère de Liu Shan (selon le texte)', 'Gan', 'CN_SHU', 'dates non renseignées', 180)
Wf('tk.wu_s', 'Impératrice Wu (Mu)', None, None, 'Épouse de Liu Bei (impératrice douairière Mu)', 'Wu', 'CN_SHU', 'dates non renseignées', 180)
Wf('tk.mi', 'Dame Mi', None, None, 'Épouse de Liu Bei', 'Mi', 'CN_SHU', 'dates non renseignées', 180)
for c in ('tk.gan', 'tk.wu_s', 'tk.mi'):
    S('tk.liubei', c)
T('tk.liushan', 'Liu Shan (Shu Han Houzhu)', 207, 271, 'Deuxième et dernier empereur du Shu Han (223 à 263)', 'h', True, LS, 'CN_SHU', 'mère : dame Gan (texte) ou impératrice Zhaolie (infobox)')
P('tk.liubei', 'tk.liushan'); P('tk.gan', 'tk.liushan')
T('tk.liuyong', 'Liu Yong (prince de Ganling)', None, None, 'Fils de Liu Bei', 'h', False, LS, 'CN_SHU', 'dates non renseignées', 210)
T('tk.liuli', 'Liu Li (prince de Anping)', None, None, 'Fils de Liu Bei', 'h', False, LS, 'CN_SHU', 'dates non renseignées', 212)
for c in ('tk.liuyong', 'tk.liuli'):
    P('tk.liubei', c)
Wf('tk.zhang_s1', 'Impératrice Jing\'ai (Zhang)', None, 237, 'Impératrice du Shu Han, fille de Zhang Fei', 'Zhang (Zhang Fei)', 'CN_SHU', 'naissance non renseignée', 207)
Wf('tk.zhang_s2', 'Impératrice Zhang (cadette)', None, None, 'Impératrice du Shu Han (238), sœur cadette de Jing\'ai', 'Zhang (Zhang Fei)', 'CN_SHU', 'dates non renseignées', 210)
S('tk.liushan', 'tk.zhang_s1'); S('tk.liushan', 'tk.zhang_s2')
Wf('tk.li_s', 'Dame Li (Li Zhaoyi)', None, None, 'Concubine de Liu Shan, mère de Liu Xuan', 'Li', 'CN_SHU', 'dates non renseignées', 205)
S('tk.liushan', 'tk.li_s')
T('tk.liuxuan', 'Liu Xuan (prince héritier du Shu Han)', 224, 264, 'Prince héritier', 'h', False, LS, 'CN_SHU', 'mort en mars 264')
P('tk.liushan', 'tk.liuxuan'); P('tk.li_s', 'tk.liuxuan')
for c, n, d, fb in (('tk.liuyao', 'Liu Yao (prince d\'Anding)', None, 226), ('tk.liucong', 'Liu Cong (prince de Xihe)', 262, 228), ('tk.liuzan', 'Liu Zan', None, 230), ('tk.liuchen', 'Liu Chen (prince de Beidi)', 263, 232), ('tk.liuxun', 'Liu Xun (prince de Xinxing)', None, 234), ('tk.liuqian', 'Liu Qian', None, 236)):
    T(c, n, None, d, 'Fils de Liu Shan', 'h', False, LS, 'CN_SHU', 'naissance non renseignée' + ('' if d else ' ; mort non renseignée'), fb)
    P('tk.liushan', c)
# --- Wu oriental
T('tk.sunjian', 'Sun Jian', 155, 191, 'Chef militaire, père de Sun Ce et de Sun Quan', 'h', False, SW, 'CN_WU', 'mort 191 (autres sources : 192 ou 193)')
Wf('tk.lady_wu', 'Dame Wu (impératrice Wulie)', None, None, 'Épouse de Sun Jian', 'Wu', 'CN_WU', 'dates non renseignées', 160)
S('tk.sunjian', 'tk.lady_wu')
T('tk.sunce', 'Sun Ce', 175, 200, 'Fondateur du pouvoir des Sun au Jiangdong', 'h', False, SW, 'CN_WU', 'mort le 5 mai 200')
T('tk.sunquan', 'Sun Quan (Wu Dadi)', 182, 252, 'Premier empereur du Wu oriental (229 à 252)', 'h', True, SW, 'CN_WU', 'mort le 21 mai 252 (âge selon le Sanguozhi : 71)')
T('tk.sunyi', 'Sun Yi', None, None, 'Frère cadet de Sun Quan', 'h', False, SW, 'CN_WU', 'dates non renseignées', 184)
T('tk.sunkuang', 'Sun Kuang', None, None, 'Frère cadet de Sun Quan', 'h', False, SW, 'CN_WU', 'dates non renseignées', 186)
T('tk.ladysun', 'Dame Sun (Sun Shangxiang)', None, None, 'Sœur cadette de Sun Quan, épouse de Liu Bei', 'f', False, SW, 'CN_WU', 'dates non renseignées', 188)
for c in ('tk.sunce', 'tk.sunquan', 'tk.sunyi', 'tk.sunkuang', 'tk.ladysun'):
    P('tk.sunjian', c); P('tk.lady_wu', c)
S('tk.liubei', 'tk.ladysun')
T('tk.sunshao', 'Sun Shao', None, None, 'Fils posthume de Sun Ce', 'h', False, SW, 'CN_WU', 'dates non renseignées', 200)
P('tk.sunce', 'tk.sunshao')
Wf('tk.pan', 'Impératrice Pan (mère de Sun Liang)', None, 252, 'Concubine de Sun Quan, impératrice en 251', 'Pan', 'CN_WU', 'naissance non renseignée', 205)
Wf('tk.wang_dayi', 'Impératrice Dayi (Wang)', None, None, 'Concubine de Sun Quan, mère de Sun He et de Sun Ba', 'Wang', 'CN_WU', 'dates non renseignées', 200)
Wf('tk.wang_jh', 'Impératrice Jinghuai (Wang)', None, None, 'Concubine de Sun Quan (mère de Sun Xiu selon l\'infobox)', 'Wang', 'CN_WU', 'dates non renseignées ; maternité de Sun Xiu : consort Wang selon le texte', 205)
for c in ('tk.pan', 'tk.wang_dayi', 'tk.wang_jh'):
    S('tk.sunquan', c)
T('tk.sundeng', 'Sun Deng (prince héritier Xuan)', 209, 241, 'Prince héritier du Wu', 'h', False, SW, 'CN_WU', 'dates 209-241 (page homonymie Sun Deng)')
T('tk.sunlu', 'Sun Lü (marquis de Jianchang)', None, None, 'Fils de Sun Quan', 'h', False, SW, 'CN_WU', 'dates non renseignées', 214)
T('tk.sunhe', 'Sun He (prince héritier, puis prince de Nanyang)', 224, 253, 'Prince héritier du Wu, père de Sun Hao', 'h', False, SW, 'CN_WU', 'mort fin 253')
T('tk.sunba', 'Sun Ba (prince de Lu)', None, 250, 'Fils de Sun Quan', 'h', False, SW, 'CN_WU', 'naissance non renseignée', 226)
T('tk.sunfen', 'Sun Fen (prince de Qi)', None, 270, 'Fils de Sun Quan', 'h', False, SW, 'CN_WU', 'naissance non renseignée', 230)
T('tk.sunxiu', 'Sun Xiu (Wu Jingdi)', 235, 264, 'Troisième empereur du Wu (258 à 264)', 'h', True, SW, 'CN_WU', 'mort le 3 septembre 264 ; mère : consort Wang (texte) ou impératrice Jinghuai (infobox)')
T('tk.sunliang', 'Sun Liang (Wu)', 243, 260, 'Deuxième empereur du Wu (252 à 258), déposé', 'h', True, SW, 'CN_WU', 'naissance 243 ou 244')
for c in ('tk.sundeng', 'tk.sunlu', 'tk.sunfen'):
    P('tk.sunquan', c)
for c in ('tk.sunhe', 'tk.sunba'):
    P('tk.sunquan', c); P('tk.wang_dayi', c)
P('tk.sunquan', 'tk.sunxiu'); P('tk.wang_jh', 'tk.sunxiu')
P('tk.sunquan', 'tk.sunliang'); P('tk.pan', 'tk.sunliang')
Wf('tk.he_l', 'Dame He (mère de Sun Hao)', None, None, 'Concubine de Sun He, impératrice douairière He', 'He', 'CN_WU', 'dates non renseignées', 235)
S('tk.sunhe', 'tk.he_l')
T('tk.sunhao', 'Sun Hao (Wu Modi)', 242, 284, 'Quatrième et dernier empereur du Wu (264 à 280)', 'h', True, SW, 'CN_WU', 'naissance 242 (pied de page : 243) ; mort janvier ou février 284')
P('tk.sunhe', 'tk.sunhao'); P('tk.he_l', 'tk.sunhao')
Wf('tk.quan', 'Impératrice Quan (épouse de Sun Liang)', None, None, 'Impératrice du Wu (253)', 'Quan', 'CN_WU', 'dates non renseignées', 245)
S('tk.sunliang', 'tk.quan')
Wf('tk.zhu_j', 'Impératrice Jing (dame Zhu)', None, None, 'Impératrice du Wu, épouse de Sun Xiu', 'Zhu', 'CN_WU', 'dates non renseignées', 240)
S('tk.sunxiu', 'tk.zhu_j')
T('tk.sunwan', 'Sun Wan (prince héritier)', None, 266, 'Fils aîné de Sun Xiu', 'h', False, SW, 'CN_WU', 'naissance non renseignée', 255)
P('tk.sunxiu', 'tk.sunwan'); P('tk.zhu_j', 'tk.sunwan')
Wf('tk.teng', 'Impératrice Teng (épouse de Sun Hao)', None, None, 'Impératrice du Wu', 'Teng', 'CN_WU', 'dates non renseignées', 245)
S('tk.sunhao', 'tk.teng')
Gen.FIXB = FB
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
