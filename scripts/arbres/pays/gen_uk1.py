import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(90, "Angleterre — compléments Plantagenêts, Lancastre, York, Tudor et Beaufort")
g.notes = [
    "Complète les arbres Plantagenêts, Lancastre, York et Tudor (rien n'est supprimé, aucun nouvel arbre).",
    "Dates : connues par ailleurs (histoire d'Angleterre), aucune page consultée pour ce lot ; incertaines = vides.",
    "Marguerite de France (2e épouse d'Édouard Ier) et Isabelle de France (épouse de Richard II) sont créées dans l'arbre Capétiens/Valois ; Marguerite d'York dans l'arbre York. Épouses de familles sans arbre (Provence, Bretagne, Anjou, Neville, Howard, Parr, Clèves, Swynford, Beauchamp) : signalées.",
    "À corriger par Martin : « Richard Plantagenêt » (arbre York) est noté mort en 1411 ; c'est le duc d'York (1411-1460) dont 1411 est la naissance. Non modifié.",
    "Non fait : bâtards, filles cadettes, branches Mortimer/Neville/Percy, Plantagenêts d'Irlande.",
]
g.tree('GB_PLA', 'GBR', 'Les Plantagenêts', entry=E('177fd0be'))
g.tree('GB_LAN', 'GBR', 'Maison de Lancastre', entry=E('a393c0e9'))
g.tree('GB_YOR', 'GBR', 'Maison de York', entry=E('cafb6b0e'))
g.tree('GB_TUD', 'GBR', 'Maison de Tudor', entry=E('cb705982'))
g.tree('FR_CAP', 'FRA', 'Capétiens', entry=E('6f093aa5'))
g.tree('FR_VAL', 'FRA', 'Valois', entry=E('a92b4627'))
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
def M(code, name, b, d, title, g_, tree, leader=False, approx=None, dyn='Angleterre', flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, tree, approx=None):
    return M(code, name, b, d, title, 'f', tree, dyn=house, approx=approx, flag='Maison %s : sans arbre' % house)
PL, LA, YO, TU = 'GB_PLA', 'GB_LAN', 'GB_YOR', 'GB_TUD'
H2, AQ, RCL, JSX, H3, E1, E2, E3, PH, RII = [R(x) for x in ('4433a65f', 'ba3d69dd', '2413e6b1', 'db456e5e', '6594dce9', '7ba4c964', '19c2c965', '2ff35ebb', '5888696e', '21731a19')]
# Henri II / Aliénor
M('uk.geoffrey_br', 'Geoffroy Plantagenêt, duc de Bretagne', 1158, 1186, 'Fils de Henri II', 'h', PL)
kids([H2, AQ], ['uk.geoffrey_br'])
W('uk.constance_br', 'Constance de Bretagne', 1161, 1201, 'Duchesse de Bretagne', 'Bretagne', PL)
S('uk.geoffrey_br', 'uk.constance_br')
M('uk.arthur', 'Arthur Ier de Bretagne', 1187, 1203, 'Duc de Bretagne, rival de Jean sans Terre', 'h', PL)
kids(['uk.geoffrey_br', 'uk.constance_br'], ['uk.arthur'])
W('uk.berengaria', 'Bérengère de Navarre', None, 1230, 'Reine d\'Angleterre, épouse de Richard Cœur de Lion', 'Navarre', PL, approx='naissance vers 1165-1170')
S(RCL, 'uk.berengaria')
EP = R('14a47148'); g.pin(EP, PL)
M('uk.edmund_c', 'Edmond Crouchback, comte de Lancastre', 1245, 1296, 'Fils de Henri III', 'h', PL)
kids([H3, EP], ['uk.edmund_c'])
M('fr.marguerite_f', 'Marguerite de France', 1279, 1318, "Reine d'Angleterre, 2e épouse d'Édouard Ier", 'f', 'FR_CAP', dyn='Capétiens')
P(R('d52e8bf8'), 'fr.marguerite_f'); S(E1, 'fr.marguerite_f'); g.pin('fr.marguerite_f', PL)
M('uk.thomas_w', 'Thomas de Woodstock, duc de Gloucester', 1355, 1397, 'Fils d\'Édouard III', 'h', PL)
kids([E3, PH], ['uk.thomas_w'])
for c in ('1ba9e0b5', '6c49d7a5', '1e714a2a'):
    P(E3, R(c)); P(PH, R(c)); g.pin(R(c), PL)
ANNE = R('d6878cd3'); S(RII, ANNE); g.pin(ANNE, PL)
M('fr.isabelle_ric', 'Isabelle de France', 1389, 1409, "Reine d'Angleterre, 2e épouse de Richard II", 'f', 'FR_VAL', dyn='Valois')
kids([R('7e00a532'), R('d182cf95')], ['fr.isabelle_ric'])
S(RII, 'fr.isabelle_ric'); g.pin('fr.isabelle_ric', PL)
# Lancastre
W('uk.margaret_anjou', "Marguerite d'Anjou", 1430, 1482, "Reine d'Angleterre, épouse de Henri VI", 'Anjou', LA)
S(R('9a912814'), 'uk.margaret_anjou')
M('uk.edward_wm', 'Édouard de Westminster', 1453, 1471, 'Prince de Galles, fils de Henri VI', 'h', LA)
kids([R('9a912814'), 'uk.margaret_anjou'], ['uk.edward_wm'])
# Beaufort
W('uk.swynford', 'Catherine Swynford', 1350, 1403, 'Duchesse de Lancastre, 3e épouse de Jean de Gand', 'Swynford', LA, approx='naissance vers 1350')
S(R('1e714a2a'), 'uk.swynford')
M('uk.jbeaufort1', 'Jean Beaufort, comte de Somerset', 1373, 1410, 'Fils de Jean de Gand et Catherine Swynford', 'h', LA)
kids([R('1e714a2a'), 'uk.swynford'], ['uk.jbeaufort1'])
M('uk.jbeaufort2', 'Jean Beaufort, duc de Somerset', 1404, 1444, 'Père de Marguerite Beaufort', 'h', LA)
P('uk.jbeaufort1', 'uk.jbeaufort2'); P('uk.jbeaufort1', R('2f8a0105')); g.pin(R('2f8a0105'), LA)
W('uk.beauchamp', 'Marguerite Beauchamp de Bletso', 1410, 1482, 'Mère de Marguerite Beaufort', 'Beauchamp', LA)
S('uk.jbeaufort2', 'uk.beauchamp')
kids(['uk.jbeaufort2', 'uk.beauchamp'], [R('9ce36f9a')]); g.pin(R('9ce36f9a'), LA)
# York
RY = R('d36cc690')
g.xsetdates(X('d36cc690'), 1411, None)
M('uk.clarence', 'Georges, duc de Clarence', 1449, 1478, 'Frère d\'Édouard IV', 'h', YO)
M('uk.rutland', 'Edmond, comte de Rutland', 1443, 1460, 'Frère d\'Édouard IV', 'h', YO)
M('uk.margaret_york', 'Marguerite d\'York', 1446, 1503, 'Duchesse de Bourgogne', 'f', YO)
kids([RY, R('979dc6cd')], ['uk.clarence', 'uk.rutland', 'uk.margaret_york'])
S('uk.margaret_york', R('0f711845')); g.pin(R('0f711845'), YO)
W('uk.anne_neville', 'Anne Neville', 1456, 1485, "Reine d'Angleterre, épouse de Richard III", 'Neville', YO)
S(R('f0d30c28'), 'uk.anne_neville')
M('uk.edward_mid', 'Édouard de Middleham', 1473, 1484, 'Prince de Galles, fils de Richard III', 'h', YO)
kids([R('f0d30c28'), 'uk.anne_neville'], ['uk.edward_mid'])
M('uk.richard_shrew', 'Richard de Shrewsbury', 1473, 1483, 'Prince de la Tour, fils d\'Édouard IV', 'h', YO)
kids([R('2cdc2957'), R('bb057c6a')], ['uk.richard_shrew'])
# Tudor
H8 = R('8a173251')
W('uk.anne_cleves', 'Anne de Clèves', 1515, 1557, '4e épouse d\'Henri VIII', 'La Marck-Clèves', TU)
W('uk.cath_howard', 'Catherine Howard', 1523, 1542, '5e épouse d\'Henri VIII', 'Howard', TU, approx='naissance vers 1523')
W('uk.cath_parr', 'Catherine Parr', 1512, 1548, '6e épouse d\'Henri VIII', 'Parr', TU)
for c in ('uk.anne_cleves', 'uk.cath_howard', 'uk.cath_parr'):
    S(H8, c)
PHS = R('8ee8a84e'); S(R('a53405b2'), PHS); g.pin(PHS, TU)

for t in ('GB_PLA', 'GB_LAN', 'GB_YOR', 'GB_TUD'):
    pass
g.reposition = {'GB_PLA', 'GB_LAN', 'GB_YOR', 'GB_TUD'}
g.write()
