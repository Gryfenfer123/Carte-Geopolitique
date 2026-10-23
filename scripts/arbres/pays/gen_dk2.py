import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(93, "Danemark médiéval — Estridsen et Valdemar : de Sven II à Valdemar IV ; correctif des dates de la maison de Huntingdon (v92)")
g.notes = [
    "Complète l'arbre « Maison d'Estridsen » (3 membres au départ ; rien n'est supprimé).",
    "Dates : connues par ailleurs (histoire du Danemark), aucune page consultée pour ce lot ; les dates médiévales anciennes sont approximatives (notées).",
    "Dagmar de Bohême est créée dans l'arbre Přemyslides. Autres épouses de familles sans arbre (Sophie de Minsk, Bérengère de Portugal, Agnès de Brandebourg, Helvig de Slesvig, Ulf) : signalées.",
    "Correctif de v92 : la mère d'Isabelle de Huntingdon n'est pas Maud de Chester (dates incompatibles) ; les dates d'Isabelle (vers 1176) et de Maud (naissance vide) sont rectifiées. Les liens parentaux de v92 restent (incertains).",
    "Non fait : Magnus le Fort, enfants cadets, branche d'Abel, maison de Bavière (Christophe III) entre Éric de Poméranie et Christian Ier.",
]
g.tree('DK_EST', 'DNK', "Maison d'Estridsen", entry=E('f2e02253'))
g.tree('DK_JEL', 'DNK', 'Maison de Jelling', entry=E('3a16424c'))
g.tree('CZ_PRE', 'CZE', 'Přemyslides', entry=E('b53dda9c'))
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
T = 'DK_EST'
def M(code, name, b, d, title, g_, tree=T, leader=True, approx=None, dyn='Estridsen', flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, g_='f', approx=None, tree=T):
    return M(code, name, b, d, title, g_, tree, False, approx, house, 'Maison %s : sans arbre' % house)
g.setdates('sc.isabel_h', 1176, 1251)
g.setdates('sc.maud_chester', None, 1233)
M('dk.estrid', 'Estrid Svendsdatter', 990, 1057, 'Fille de Sven à la Barbe fourchue, mère de Sven II', 'f', 'DK_JEL', False, 'naissance vers 990', 'Jelling')
P(R('1e2890c2'), 'dk.estrid'); g.pin('dk.estrid', T)
W('dk.ulf', 'Ulf Thorgilsson', None, 1026, 'Jarl, père de Sven II', 'Ulf', 'h', 'naissance non donnée')
S('dk.ulf', 'dk.estrid')
M('dk.sven2', 'Sven II Estridsen', 1019, 1076, 'Roi de Danemark', 'h', approx='naissance vers 1019')
kids(['dk.ulf', 'dk.estrid'], ['dk.sven2'])
L = [('harald3', 'Harald III Hen', 1041, 1080, 'naissance vers 1041'), ('knud4', 'Knud IV le Saint', 1042, 1086, 'naissance vers 1042'),
     ('olaf1', 'Olaf Ier la Famine', 1050, 1095, 'naissance vers 1050'), ('erik1', 'Éric Ier Ejegod', 1056, 1103, 'naissance vers 1056'),
     ('niels', 'Niels', 1064, 1134, 'naissance vers 1064')]
for c, n, b, d, a in L:
    M('dk.' + c, n, b, d, 'Roi de Danemark', 'h', approx=a)
    P('dk.sven2', 'dk.' + c)
M('dk.erik2', 'Éric II Emune', 1090, 1137, 'Roi de Danemark', 'h', approx='naissance vers 1090')
M('dk.knud_lavard', 'Knud Lavard', 1096, 1131, 'Duc de Slesvig, père de Valdemar Ier', 'h', leader=False)
kids(['dk.erik1'], ['dk.erik2', 'dk.knud_lavard'])
M('dk.valdemar1', 'Valdemar Ier le Grand', 1131, 1182, 'Roi de Danemark', 'h')
P('dk.knud_lavard', 'dk.valdemar1')
W('dk.sophia', 'Sophie de Minsk', 1140, 1198, 'Reine de Danemark', 'Minsk (Riourikides)', approx='naissance vers 1140')
S('dk.valdemar1', 'dk.sophia')
M('dk.knud6', 'Knud VI', 1162, 1202, 'Roi de Danemark', 'h')
M('dk.valdemar2', 'Valdemar II le Victorieux', 1170, 1241, 'Roi de Danemark', 'h')
kids(['dk.valdemar1', 'dk.sophia'], ['dk.knud6', 'dk.valdemar2', R('328018bd')])
M('dk.dagmar', 'Dagmar de Bohême (Marguerite)', 1186, 1212, 'Reine de Danemark', 'f', 'CZ_PRE', False, 'naissance vers 1186', 'Přemyslides')
P(R('86690abf'), 'dk.dagmar'); S('dk.valdemar2', 'dk.dagmar'); g.pin('dk.dagmar', T)
W('dk.berengaria', 'Bérengère de Portugal', 1194, 1221, 'Reine de Danemark', 'Portugal (Bourgogne)', approx='naissance vers 1194')
S('dk.valdemar2', 'dk.berengaria')
M('dk.valdemar_y', 'Valdemar le Jeune', 1209, 1231, 'Co-roi, fils de Valdemar II', 'h', leader=False)
P('dk.valdemar2', 'dk.valdemar_y'); P('dk.dagmar', 'dk.valdemar_y')
M('dk.erik4', 'Éric IV Plovpenning', 1216, 1250, 'Roi de Danemark', 'h')
M('dk.abel', 'Abel', 1218, 1252, 'Roi de Danemark', 'h')
M('dk.christopher1', 'Christophe Ier', 1219, 1259, 'Roi de Danemark', 'h')
kids(['dk.valdemar2', 'dk.berengaria'], ['dk.erik4', 'dk.abel', 'dk.christopher1'])
M('dk.erik5', 'Éric V Klipping', 1249, 1286, 'Roi de Danemark', 'h')
P('dk.christopher1', 'dk.erik5')
W('dk.agnes_br', 'Agnès de Brandebourg', 1257, 1304, 'Reine de Danemark, régente', 'Brandebourg (Ascaniens)')
S('dk.erik5', 'dk.agnes_br')
M('dk.erik6', 'Éric VI Menved', 1274, 1319, 'Roi de Danemark', 'h')
M('dk.christopher2', 'Christophe II', 1276, 1332, 'Roi de Danemark', 'h')
kids(['dk.erik5', 'dk.agnes_br'], ['dk.erik6', 'dk.christopher2'])
P('dk.christopher2', R('59229f89'))
W('dk.helvig', 'Helvig de Slesvig', 1327, 1375, 'Reine de Danemark', 'Slesvig')
S(R('59229f89'), 'dk.helvig'); P('dk.helvig', R('ef4df279'))
# Sophie et Märta (créées en v76, signalées « Estridsen : sans arbre ») sont rattachées à leurs pères
P('dk.erik4', 'sm.sophia_dk'); P('dk.erik5', 'sm.marta'); g.pin('sm.sophia_dk', 'DK_EST'); g.pin('sm.marta', 'DK_EST')
REG['flags'] = [f for f in REG['flags'] if f['name'] not in ('Sophie de Danemark', 'Märta de Danemark')]
g.reposition = {'DK_EST'}
g.write()
