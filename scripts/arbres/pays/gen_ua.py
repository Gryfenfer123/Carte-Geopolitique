import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(55, "Ukraine — Riourikides de Galicie-Volhynie")
g.notes = [
    "Crée sous Ukraine > Dynastie : Riourikides (Galicie-Volhynie) (Mstislav II Iziaslavitch -> Roman le Grand -> Daniel -> Léon Ier -> Iouri Ier -> André et Léon II -> Iouri II Boleslas).",
    "Choix : la Rus' de Kiev est dans l'arbre russe (v43) ; la branche de Galicie-Volhynie a son propre arbre ici. La Rus' de Kiev n'est pas dupliquée.",
    "Dates : naissances et morts de la page Wikipédia ; Iouri Ier : la page donne plusieurs dates possibles (naissance 1252, 1257 ou 1262 ; mort 1308 ou 1315).",
    "Créés dans leur arbre : Agnès de Pologne, Euphémie de Couïavie, Siemovit Ier et Trojden Ier de Mazovie (Piast), Constance et Marie Laskarina (Árpád / sans arbre), André Iaroslavitch (Rurikides russes).",
    "Cunégonde de Halicz (épouse d'Ottokar II) reste dans Přemyslides : sa filiation avec la maison de Galicie n'est pas établie ici.",
    "Prérequis : v54 exécuté.",
]
g.tree('UA_RUR', 'UKR', 'Riourikides (Galicie-Volhynie)')
g.tree('PL_PIAST', 'POL', 'Piast')
g.tree('HU_ARP', 'HUN', 'Árpád')
g.tree('RU_RUR', 'RUS', 'Riourikides')
g.reposition = {'PL_PIAST', 'HU_ARP', 'RU_RUR'}
FBc = {'ua.mstislav2': 1125, 'ua.agnes': 1137, 'ua.predslava': 1170, 'ua.anna_e': 1175, 'ua.anna_n': 1205, 'ua.constance': 1237,
       'ua.maria_lask': 1206, 'ua.svarn': 1230, 'ua.mstislav_d': 1235, 'ua.roman_d': 1230, 'ua.yaroslavna': 1255, 'ua.euphemia': 1265,
       'ua.siemowit': 1215, 'ua.trojden': 1284, 'ua.ustynia': 1225, 'ua.andrei_y': 1222, 'ua.pereyaslava': 1230}
Gen.FIXB = {uid('member:' + c): y for c, y in FBc.items()}
P, S = g.par, g.sp
RU = 'Riourikides (Galicie-Volhynie)'
A = 'dates non revérifiées sur la page'
def M(c, n, b, d, t, s, ld=False, ap=None, dyn=RU, fl=None, tree='UA_RUR'):
    g.m(c, n, b, d, t, dyn, tree, s, ld, flag=fl, approx=ap)
M('ua.mstislav2', 'Mstislav II Iziaslavitch', None, 1170, 'Grand-prince de Kiev', 'h', True, ap='naissance non renseignée ; mort 1170 (non donnée par la page, non revérifiée)', dyn='Riourikides (Kiev)')
M('ua.agnes', 'Agnès de Pologne (princesse de Kiev)', None, None, 'Princesse de Kiev', 'f', ap='dates non renseignées ; fille de Boleslas III', dyn='Piast', tree='PL_PIAST')
P('pl.boles3', 'ua.agnes')
S('ua.mstislav2', 'ua.agnes')
M('ua.roman', 'Roman Mstislavitch le Grand', 1152, 1205, 'Prince de Volhynie (1170), de Galicie (1199)', 'h', True, ap='naissance « vers le 4 avril 1152 » ; mort 19 juin 1205 (la page donne aussi le 14 octobre)')
P('ua.mstislav2', 'ua.roman'); P('ua.agnes', 'ua.roman')
M('ua.predslava', 'Predslava Rourikovna', None, None, 'Princesse de Volhynie (répudiée)', 'f', ap='dates non renseignées ; fille de Rourik Rostislavitch', dyn='Riourikides (Kiev/Smolensk)')
M('ua.anna_e', 'Anne-Euphrosyne (Anna Angelina)', None, None, 'Princesse de Galicie-Volhynie', 'f', ap='dates non renseignées ; ascendance incertaine (fille d\'Isaac II Ange selon une théorie)', dyn='Ange (Byzance)', fl='Maison Ange (Byzance) : arbre à créer avec la Grèce/Turquie ; ascendance incertaine')
S('ua.roman', 'ua.predslava'); S('ua.roman', 'ua.anna_e')
M('ua.daniel', 'Daniel Romanovitch de Galicie', 1201, 1266, 'Prince de Galicie-Volhynie, roi de Ruthénie (1253-1264)', 'h', True, ap='mort 1266 (anciennes sources : 1264)')
P('ua.roman', 'ua.daniel'); P('ua.anna_e', 'ua.daniel')
M('ua.anna_n', 'Anne de Novgorod (Mstislavna)', None, None, 'Princesse de Galicie-Volhynie', 'f', ap='morte avant 1252 ; naissance non renseignée ; fille de Mstislav le Hardi')
S('ua.daniel', 'ua.anna_n')
M('ua.leo1', 'Léon Ier de Galicie', 1228, 1301, 'Prince de Galicie (1264-1301), fonde Lviv comme capitale', 'h', True, ap='naissance « vers 1228 », mort « vers 1301 »')
M('ua.svarn', 'Svarn Danilovitch', None, 1269, 'Prince de Chełm, grand-prince de Lituanie (1264-1267)', 'h', ap='naissance non renseignée')
M('ua.roman_d', 'Roman Danilovitch', 1230, 1261, 'Prince de Ruthénie noire', 'h', ap='naissance « vers 1230 », mort « vers 1261 »')
M('ua.mstislav_d', 'Mstislav Danilovitch', None, None, 'Prince de Loutsk puis de Volhynie (1289-après 1300)', 'h', ap='naissance non renseignée ; mort après 1300')
M('ua.pereyaslava', 'Pereïaslava Danilovna', None, 1283, 'Princesse, duchesse de Mazovie', 'f', ap='naissance non renseignée')
M('ua.ustynia', 'Oustinia Danilovna', None, None, 'Princesse, grande-princesse de Vladimir', 'f', ap='dates non renseignées')
for c in ('ua.leo1', 'ua.svarn', 'ua.roman_d', 'ua.mstislav_d', 'ua.pereyaslava', 'ua.ustynia'):
    P('ua.daniel', c); P('ua.anna_n', c)
M('ua.siemowit', 'Siemovit Ier de Mazovie', 1215, 1262, 'Duc de Mazovie', 'h', ap='dates 1215-1262 (non données par la page, non revérifiées) ; parents non créés', dyn='Piast', tree='PL_PIAST')
S('ua.pereyaslava', 'ua.siemowit')
M('ua.andrei_y', 'André Iaroslavitch de Vladimir', 1222, 1264, 'Grand-prince de Vladimir (1248-1252)', 'h', ap='dates 1222-1264 (non données par la page, non revérifiées)', dyn='Riourikides', tree='RU_RUR')
P('ru.yaroslav2', 'ua.andrei_y')
S('ua.andrei_y', 'ua.ustynia')
M('ua.constance', 'Constance de Hongrie (princesse de Galicie)', None, None, 'Princesse de Galicie', 'f', ap='dates non renseignées', dyn='Árpád', tree='HU_ARP')
M('ua.maria_lask', 'Marie Laskarina (reine de Hongrie)', 1206, 1270, 'Reine de Hongrie', 'f', ap='dates 1206-1270 non données par la page, non revérifiées', dyn='Laskaris (Nicée)', fl='Maison Laskaris (Nicée, Byzance) : arbre à créer avec la Grèce/Turquie', tree='HU_ARP')
P('hu.bela4', 'ua.constance'); P('ua.maria_lask', 'ua.constance')
S('hu.bela4', 'ua.maria_lask')
S('ua.leo1', 'ua.constance')
M('ua.yuri1', 'Iouri Ier de Galicie', 1252, 1308, 'Roi de Ruthénie (1301-1308)', 'h', True, ap='naissance 1252, 1257 ou 1262 ; mort 1308 ou 1315 (selon la page)')
P('ua.leo1', 'ua.yuri1'); P('ua.constance', 'ua.yuri1')
M('ua.yaroslavna', 'Iaroslavna de Tver', None, 1286, 'Première épouse d\'Iouri Ier', 'f', ap='naissance non renseignée ; morte vers 1286', dyn='Riourikides (Tver)')
M('ua.euphemia', 'Euphémie de Couïavie', None, 1308, 'Épouse d\'Iouri Ier', 'f', ap='naissance non renseignée ; filiation non précisée', dyn='Piast', tree='PL_PIAST')
S('ua.yuri1', 'ua.yaroslavna'); S('ua.yuri1', 'ua.euphemia')
M('ua.andrew', 'André de Galicie', None, 1323, 'Prince de Ruthénie (1308-1323)', 'h', True, ap='naissance non renseignée')
M('ua.leo2', 'Léon II de Galicie', None, 1323, 'Prince de Ruthénie (1308-1323)', 'h', True, ap='naissance non renseignée')
M('ua.maria_h', 'Marie de Galicie (duchesse de Mazovie)', None, 1341, 'Princesse de Ruthénie, duchesse de Mazovie', 'f', ap='naissance non renseignée')
for c in ('ua.andrew', 'ua.leo2', 'ua.maria_h'):
    P('ua.yuri1', c); P('ua.euphemia', c)
M('ua.trojden', 'Trojden Ier de Mazovie', 1284, 1341, 'Duc de Mazovie', 'h', ap='dates 1284-1341 (non données par la page, non revérifiées) ; parents non créés', dyn='Piast', tree='PL_PIAST')
S('ua.maria_h', 'ua.trojden')
M('ua.yuri2', 'Iouri II Boleslas', 1308, 1340, 'Prince de Galicie-Volhynie (1323-1340), empoisonné par les boyards', 'h', True, ap='naissance 1308 non donnée par la page, non revérifiée')
P('ua.trojden', 'ua.yuri2'); P('ua.maria_h', 'ua.yuri2')
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
