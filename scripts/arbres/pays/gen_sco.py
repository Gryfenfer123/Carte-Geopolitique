import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(92, "Écosse — maison de Dunkeld (de Malcolm II à Alexandre III), Balliol, et ancêtres Bruce")
g.notes = [
    "Nouveaux arbres « Dunkeld » et « Balliol » ; compléments dans les arbres Alpin, Bruce, Wessex, Plantagenêts et Rollonides (rien n'est supprimé).",
    "Dates : connues par ailleurs (histoire d'Écosse), aucune page consultée pour ce lot ; les dates médiévales anciennes sont approximatives (notées).",
    "Sainte Marguerite (Wessex), Jeanne et Marguerite d'Angleterre (Plantagenêts) sont créées dans leurs arbres. Autres épouses et ancêtres de familles sans arbre (Crínán, Gruoch, Huntingdon, Galloway, Brus, Carrick, Balliol père) : signalés.",
    "Non fait : enfants naturels, Macbeth au-delà de Lulach, comtes de Mar/Carrick, branche de Donald III Bàn.",
]
g.tree('SC_DUN', 'GBR', 'Dunkeld', section_title='Dunkeld')
g.tree('SC_BAL', 'GBR', 'Balliol', section_title='Balliol')
g.tree('SC_ALP', 'GBR', "Maison d'Alpin", entry=E('80f1cfdd'))
g.tree('SC_BRU', 'GBR', 'Maison de Bruce', entry=E('20fcf3c0'))
g.tree('GB_WSX', 'GBR', 'Maison de Wessex et de Godwin', entry=E('324177bb'))
g.tree('GB_PLA', 'GBR', 'Les Plantagenêts', entry=E('177fd0be'))
g.tree('GB_NOR', 'GBR', 'Les Rollonides et Blois', entry=E('b545151c'))
g.tree('NO_KIN', 'NOR', 'Rois de Norvège', entry=E('e54ea4ad'))
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
def M(code, name, b, d, title, g_, tree, leader=False, approx=None, dyn='Écosse', flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, tree, g_='f', approx=None):
    return M(code, name, b, d, title, g_, tree, dyn=house, approx=approx, flag='Maison %s : sans arbre' % house)
D, A, BR, BA = 'SC_DUN', 'SC_ALP', 'SC_BRU', 'SC_BAL'
# Malcolm II -> Duncan I
M('sc.malcolm2', 'Malcolm II', 954, 1034, "Roi d'Écosse", 'h', A, True, 'naissance vers 954', 'Alpin')
P(R('ad10272c'), 'sc.malcolm2'); g.pin('sc.malcolm2', D)
M('sc.bethoc', 'Bethoc', None, None, 'Fille de Malcolm II', 'f', D, approx='dates non données')
P('sc.malcolm2', 'sc.bethoc')
W('sc.crinan', 'Crínán de Dunkeld', None, 1045, 'Abbé laïc de Dunkeld', 'Crínán', D, 'h', 'naissance non donnée')
S('sc.crinan', 'sc.bethoc')
M('sc.duncan1', 'Duncan Ier', 1001, 1040, "Roi d'Écosse", 'h', D, True, 'naissance vers 1001', 'Dunkeld')
kids(['sc.crinan', 'sc.bethoc'], ['sc.duncan1'])
M('sc.macbeth', 'Macbeth', 1005, 1057, "Roi d'Écosse (1040-1057)", 'h', D, True, 'naissance vers 1005 ; petit-fils de Malcolm II par sa mère (incertain)', 'Moray')
g.fam('sc.malcolm2', 'sc.macbeth')
W('sc.gruoch', 'Gruoch', 1015, 1058, "Reine d'Écosse, épouse de Macbeth", 'Moray', D, approx='naissance vers 1015')
S('sc.macbeth', 'sc.gruoch')
M('sc.lulach', 'Lulach', 1032, 1058, "Roi d'Écosse (1057-1058)", 'h', D, True, 'naissance vers 1032 ; beau-fils de Macbeth', 'Moray')
P('sc.gruoch', 'sc.lulach'); g.fam('sc.macbeth', 'sc.lulach')
# Malcolm III et Marguerite
M('sc.malcolm3', 'Malcolm III Canmore', 1031, 1093, "Roi d'Écosse", 'h', D, True, 'naissance vers 1031', 'Dunkeld')
P('sc.duncan1', 'sc.malcolm3')
M('wx.margaret', 'Marguerite d\'Écosse (sainte Marguerite)', 1045, 1093, "Reine d'Écosse", 'f', 'GB_WSX', dyn='Wessex')
kids([R('e4c68318'), R('2d42f36b')], ['wx.margaret'])
S('sc.malcolm3', 'wx.margaret'); g.pin('wx.margaret', D)
M('sc.duncan2', 'Duncan II', 1060, 1094, "Roi d'Écosse", 'h', D, True, 'naissance vers 1060', 'Dunkeld')
M('sc.edgar', 'Édgar d\'Écosse', 1074, 1107, "Roi d'Écosse", 'h', D, True, 'naissance vers 1074', 'Dunkeld')
M('sc.alexander1', 'Alexandre Ier', 1078, 1124, "Roi d'Écosse", 'h', D, True, 'naissance vers 1078', 'Dunkeld')
M('sc.david1', 'David Ier', 1084, 1153, "Roi d'Écosse", 'h', D, True, 'naissance vers 1084', 'Dunkeld')
kids(['sc.malcolm3'], ['sc.duncan2'])
kids(['sc.malcolm3', 'wx.margaret'], ['sc.edgar', 'sc.alexander1', 'sc.david1', R('7d6f1565')])
g.pin(R('7d6f1565'), D)
M('sc.henry', 'Henri de Huntingdon, comte de Northumbrie', 1114, 1152, 'Prince héritier, fils de David Ier', 'h', D, approx='naissance vers 1114', dyn='Dunkeld')
P('sc.david1', 'sc.henry')
W('sc.ada', 'Ada de Warenne', 1120, 1178, 'Comtesse de Huntingdon, mère de Malcolm IV et de Guillaume', 'Warenne', D, approx='naissance vers 1120')
S('sc.henry', 'sc.ada')
M('sc.malcolm4', 'Malcolm IV', 1141, 1165, "Roi d'Écosse", 'h', D, True, dyn='Dunkeld')
M('sc.william1', 'Guillaume le Lion', 1143, 1214, "Roi d'Écosse", 'h', D, True, dyn='Dunkeld')
M('sc.david_h', 'David de Huntingdon', 1144, 1219, 'Comte de Huntingdon, frère de Guillaume le Lion', 'h', D, dyn='Dunkeld')
kids(['sc.henry', 'sc.ada'], ['sc.malcolm4', 'sc.william1', 'sc.david_h'])
M('sc.alexander2', 'Alexandre II', 1198, 1249, "Roi d'Écosse", 'h', D, True, dyn='Dunkeld')
P('sc.william1', 'sc.alexander2')
M('pl.joan_john', "Jeanne d'Angleterre", 1210, 1238, "Reine d'Écosse, épouse d'Alexandre II", 'f', 'GB_PLA', dyn='Plantagenêts')
P(R('db456e5e'), 'pl.joan_john'); S('sc.alexander2', 'pl.joan_john'); g.pin('pl.joan_john', D)
W('sc.marie_coucy', 'Marie de Coucy', None, 1284, 'Reine d\'Écosse, 2e épouse d\'Alexandre II', 'Coucy', D, approx='naissance vers 1218')
S('sc.alexander2', 'sc.marie_coucy')
M('sc.alexander3', 'Alexandre III', 1241, 1286, "Roi d'Écosse", 'h', D, True, dyn='Dunkeld')
kids(['sc.alexander2', 'sc.marie_coucy'], ['sc.alexander3'])
M('pl.margaret_eng', "Marguerite d'Angleterre", 1240, 1275, "Reine d'Écosse, épouse d'Alexandre III", 'f', 'GB_PLA', dyn='Plantagenêts')
kids([R('6594dce9'), R('14a47148')], ['pl.margaret_eng'])
S('sc.alexander3', 'pl.margaret_eng'); g.pin('pl.margaret_eng', D)
M('sc.margaret_maid', 'Marguerite de Norvège (la Vierge de Norvège)', 1283, 1290, "Reine d'Écosse, morte en route", 'f', D, True, dyn='Norvège')
kids(['sc.alexander3'], ['sc.margaret_maid'])
M('sc.margaret_sc', "Marguerite d'Écosse, reine de Norvège", 1261, 1283, "Reine de Norvège, fille d'Alexandre III", 'f', D, dyn='Dunkeld')
kids(['sc.alexander3', 'pl.margaret_eng'], ['sc.margaret_sc'])
P('sc.margaret_sc', 'sc.margaret_maid'); P(R('2bbe0128'), 'sc.margaret_maid'); S(R('2bbe0128'), 'sc.margaret_sc'); g.pin(R('2bbe0128'), D)
# Huntingdon -> Bruce et Balliol
W('sc.maud_chester', 'Maud de Chester', 1171, 1233, 'Comtesse de Huntingdon, épouse de David', 'Chester', D)
S('sc.david_h', 'sc.maud_chester')
M('sc.isabel_h', 'Isabelle de Huntingdon', 1199, 1251, 'Fille de David de Huntingdon', 'f', D, approx='naissance vers 1199', dyn='Dunkeld')
M('sc.margaret_h', 'Marguerite de Huntingdon', 1194, 1228, 'Fille de David de Huntingdon, mère de Devorguilla', 'f', D, approx='naissance vers 1194', dyn='Dunkeld')
kids(['sc.david_h', 'sc.maud_chester'], ['sc.isabel_h', 'sc.margaret_h'])
M('sc.bruce5', 'Robert de Brus, 5e seigneur d\'Annandale', 1210, 1295, 'Le Compétiteur, prétendant au trône', 'h', BR, dyn='Bruce')
kids(['sc.isabel_h'], ['sc.bruce5'])
M('sc.bruce6', 'Robert de Brus, 6e seigneur d\'Annandale', 1243, 1304, 'Père de Robert Ier', 'h', BR, dyn='Bruce')
P('sc.bruce5', 'sc.bruce6')
W('sc.marjorie_c', 'Marjorie de Carrick', None, 1292, 'Comtesse de Carrick, mère de Robert Ier', 'Carrick', BR, approx='naissance non donnée')
S('sc.bruce6', 'sc.marjorie_c'); kids(['sc.bruce6', 'sc.marjorie_c'], [R('aa3f4985')])
g.pin(R('aa3f4985'), BR)
W('sc.devorguilla', 'Devorguilla de Galloway', 1210, 1290, 'Dame de Galloway, mère de Jean Balliol', 'Galloway', BA, approx='naissance vers 1210')
P('sc.margaret_h', 'sc.devorguilla')
W('sc.john_bal_sr', 'Jean de Balliol (père)', 1208, 1268, 'Fondateur du Balliol College, époux de Devorguilla', 'Balliol', BA, 'h', 'naissance vers 1208')
S('sc.john_bal_sr', 'sc.devorguilla')
M('sc.john_balliol', 'Jean Balliol', 1249, 1314, "Roi d'Écosse (1292-1296)", 'h', BA, True, 'naissance vers 1249', 'Balliol')
kids(['sc.john_bal_sr', 'sc.devorguilla'], ['sc.john_balliol'])
M('sc.edward_balliol', 'Édouard Balliol', 1283, 1367, "Roi d'Écosse (1332-1356)", 'h', BA, True, 'naissance vers 1283', 'Balliol')
P('sc.john_balliol', 'sc.edward_balliol')

g.reposition = {'SC_DUN', 'SC_BAL', 'SC_BRU', 'SC_ALP'}
g.write()
