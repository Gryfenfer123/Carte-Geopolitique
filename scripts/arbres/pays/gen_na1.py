import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(101, "Navarre — royaume de Navarre : Jiménez, Champagne, Capet, Évreux, Trastamare, Foix, Albret")
g.notes = [
    "Nouvel arbre « Royaume de Navarre » (aucun n'existait) : il suit la couronne à travers ses maisons successives. Sanche V, Pierre Ier, Alphonse Ier (Aragon), Jeanne Ire, Philippe IV, Louis X, Jean Ier, Philippe V, Charles IV (Capétiens), Jean II d'Aragon, Bérengère d'Angleterre, Jeanne d'Albret, Antoine de Bourbon et Henri III de Navarre (Henri IV) y sont affichés. Rien n'est supprimé.",
    "Sources : pages Wikipédia en anglais (François Fébus, Catherine, Jean III, Henri II, Charles de Viane, Gaston IV, Philippe III d'Évreux, Charles III) pour dates et parents ; autres dates de connaissance générale.",
    "Épouses créées dans l'arbre de leur maison puis affichées : Isabelle de France et Marguerite de Bourgogne (Capétiens), Jeanne de France (Valois), Éléonore de Castille (Castille), Madeleine de France (Valois), Marguerite d'Angoulême (Valois). Familles sans arbre (Champagne-Blois, Foix, Albret, Évreux avant la couronne) : placées ici et signalées.",
    "García IV Ramírez : naissance laissée vide (incertaine) ; Ramire Sánchez de Monzón : naissance inconnue.",
    "Non fait : branche des Foix-Béarn avant Gaston IV, enfants cadets de Gaston IV, descendance d'Alain d'Albret hors Jean III.",
]
g.tree('NA_ROY', 'ESP', 'Royaume de Navarre', section_title='Royaume de Navarre')
g.tree('FR_CAP', 'FRA', 'Capétiens', entry=E('6f093aa5'))
g.tree('FR_VAL', 'FRA', 'Valois', entry=E('a92b4627'))
g.tree('FR_BOU', 'FRA', 'de Bourbon et Bourbon-Orléans', entry=E('786a379d'))
g.tree('ES_CAS', 'ESP', "Maison d'Ivrée", entry=E('4b5cbfc8'))
g.tree('ES_AR', 'ESP', "Maison d'Aragon", entry=E('58a47142'))
g.tree('ES_TRA', 'ESP', 'Maison de Trastamare', entry=E('512e1a72'))
P, S = g.par, g.sp
kids = lambda ps, cs: [P(p, c) for c in cs for p in ps]
def N(code, name, b, d, title, dyn, g_='h', leader=False, approx=None, flag=None):
    return g.m('na.' + code, name, b, d, title, dyn, 'NA_ROY', g_, leader, approx=approx, flag=flag)
def O(code, name, b, d, title, dyn, tree, g_='f'):
    g.m('na.' + code, name, b, d, title, dyn, tree, g_, False)
    g.pin('na.' + code, 'NA_ROY')

JI = 'Maison Jiménez (Navarre)'; CH = 'Blois-Champagne (Navarre)'; EV = 'Évreux (Navarre)'; FX = 'Foix (Navarre)'; AL = 'Albret (Navarre)'
N('garcia3', 'García Sánchez III le Trembleur', 1012, 1054, 'Roi de Navarre (1035-1054)', JI, leader=True)
N('sancho4', 'Sanche IV de Peñalén', 1039, 1076, 'Roi de Navarre (1054-1076), assassiné', JI, leader=True)
N('ramiro_m', 'Ramire Sánchez de Monzón', None, 1116, 'Seigneur de Monzón, petit-fils de García III', JI, approx='Naissance inconnue.')
N('garcia4', 'García IV Ramírez le Restaurateur', None, 1150, 'Roi de Navarre (1134-1150)', JI, leader=True, approx='Naissance incertaine, laissée vide.')
N('sancho6', 'Sanche VI le Sage', 1132, 1194, 'Roi de Navarre (1150-1194)', JI, leader=True)
N('sancho7', 'Sanche VII le Fort', 1157, 1234, 'Roi de Navarre (1194-1234), dernier Jiménez', JI, leader=True)
N('blanche_c', 'Blanche de Navarre (comtesse de Champagne)', 1177, 1229, 'Régente de Champagne, sœur de Sanche VII', CH, 'f', flag='Maison de Champagne-Blois : sans arbre')
N('thibaut3', 'Thibaut III de Champagne', 1179, 1201, 'Comte de Champagne, père de Thibaut Ier de Navarre', CH, flag='Maison de Champagne-Blois : sans arbre')
N('thibaut1', 'Thibaut Ier de Navarre (Thibaut IV de Champagne)', 1201, 1253, 'Roi de Navarre (1234-1253), trouvère', CH, leader=True)
N('thibaut2', 'Thibaut II de Navarre', 1238, 1270, 'Roi de Navarre (1253-1270)', CH, leader=True)
N('henri1', 'Henri Ier le Gros', 1244, 1274, 'Roi de Navarre (1270-1274)', CH, leader=True, approx='Naissance vers 1244.')
O('isabelle_f', 'Isabelle de France (reine de Navarre)', 1242, 1271, 'Reine de Navarre, épouse de Thibaut II', 'Capétiens', 'FR_CAP')
O('blanche_a', 'Blanche d\'Artois', 1248, 1302, 'Reine de Navarre, épouse d\'Henri Ier', 'Capétiens', 'FR_CAP')
O('marguerite_b', 'Marguerite de Bourgogne (reine de France et de Navarre)', 1290, 1315, 'Première épouse de Louis X, morte en prison', 'Capétiens', 'FR_CAP')
N('louis_e', 'Louis d\'Évreux', 1276, 1319, 'Comte d\'Évreux, père de Philippe III de Navarre', EV, flag='Maison d\'Évreux : sans arbre avant la couronne')
N('philippe3', 'Philippe III d\'Évreux', 1306, 1343, 'Roi de Navarre par mariage (1328-1343)', EV, leader=True)
N('jeanne2', 'Jeanne II de Navarre', 1312, 1349, 'Reine de Navarre (1328-1349)', EV, 'f', True)
N('charles2', 'Charles II le Mauvais', 1332, 1387, 'Roi de Navarre (1349-1387)', EV, leader=True)
O('jeanne_v', 'Jeanne de France (reine de Navarre)', 1343, 1373, 'Reine de Navarre, épouse de Charles II', 'Valois', 'FR_VAL')
N('charles3', 'Charles III le Noble', 1361, 1425, 'Roi de Navarre (1387-1425)', EV, leader=True)
O('eleonore_c', 'Éléonore de Castille (reine de Navarre)', 1363, 1415, 'Reine de Navarre, épouse de Charles III', "Maison d'Ivrée", 'ES_CAS')
N('blanche1', 'Blanche Ire de Navarre', 1385, 1441, 'Reine de Navarre (1425-1441)', EV, 'f', True)
N('carlos_v', 'Charles de Viane', 1421, 1461, 'Prince de Viane, héritier de Navarre', 'Trastamare (Navarre)')
N('blanche2', 'Blanche II de Navarre', 1424, 1464, 'Héritière de Navarre, répudiée par Henri IV de Castille', 'Trastamare (Navarre)', 'f', approx='Naissance vers 1424.')
N('leonor', 'Éléonore Ire de Navarre', 1426, 1479, 'Reine de Navarre (1479), comtesse de Foix', 'Trastamare (Navarre)', 'f', True)
N('gaston4', 'Gaston IV de Foix', 1422, 1472, 'Comte de Foix, époux d\'Éléonore', FX, flag='Maison de Foix : sans arbre')
N('gaston_v', 'Gaston de Foix, prince de Viane', 1444, 1470, 'Père de François Fébus et de Catherine', FX)
O('madeleine', 'Madeleine de France (princesse de Viane)', 1443, 1495, 'Régente de Navarre, fille de Charles VII', 'Valois', 'FR_VAL')
N('febus', 'François Fébus', 1467, 1483, 'Roi de Navarre (1479-1483)', FX, leader=True)
N('catherine', 'Catherine de Foix', 1468, 1517, 'Reine de Navarre (1483-1517)', FX, 'f', True)
N('alain', 'Alain Ier d\'Albret', 1440, 1522, 'Sire d\'Albret, père de Jean III', AL, flag='Maison d\'Albret : sans arbre')
N('jean3', 'Jean III d\'Albret', 1469, 1516, 'Roi de Navarre par mariage (1484-1516)', AL, leader=True)
N('henri2', 'Henri II d\'Albret', 1503, 1555, 'Roi de Navarre (1517-1555)', AL, leader=True)
O('marguerite_a', 'Marguerite d\'Angoulême (reine de Navarre)', 1492, 1549, 'Reine de Navarre, sœur de François Ier, écrivaine', 'Valois', 'FR_VAL')

# liens
SA3 = R('6c7bbade'); SA5 = R('7ab44e3e'); PI = R('4e9f6c9b'); AL1 = R('d705a0ce')
P(SA3, 'na.garcia3'); P('na.garcia3', 'na.sancho4'); P('na.sancho4', 'na.ramiro_m'); P('na.ramiro_m', 'na.garcia4')
g.fam('na.sancho4', SA5)
for x in [SA5, PI, AL1]:
    g.pin(x, 'NA_ROY')
P('na.garcia4', 'na.sancho6'); P('na.sancho6', 'na.sancho7'); P('na.sancho6', 'na.blanche_c')
BER = R('5b5ddf13'); P('na.sancho6', BER); g.pin(BER, 'NA_ROY')
S('na.blanche_c', 'na.thibaut3'); kids(['na.blanche_c', 'na.thibaut3'], ['na.thibaut1'])
kids(['na.thibaut1'], ['na.thibaut2', 'na.henri1'])
S('na.thibaut2', 'na.isabelle_f'); P(R('da46a1b7'), 'na.isabelle_f'); P(R('6dbff916'), 'na.isabelle_f')
S('na.henri1', 'na.blanche_a')
JE1 = R('44a43b3a'); PIV = R('d60fe239'); LX = R('6e723508'); JOH = R('f3313dab'); PV = R('aaf4eda5'); C4 = R('9269a040')
kids(['na.henri1', 'na.blanche_a'], [JE1])
S(JE1, PIV); kids([JE1, PIV], [LX, PV, C4])
for x in [JE1, PIV, LX, JOH, PV, C4]:
    g.pin(x, 'NA_ROY')
S(LX, 'na.marguerite_b'); kids([LX, 'na.marguerite_b'], ['na.jeanne2'])
PH3 = R('d52e8bf8'); MB = R('74e6ef51')
kids([PH3, MB], ['na.louis_e']); P('na.louis_e', 'na.philippe3')
S('na.philippe3', 'na.jeanne2'); kids(['na.philippe3', 'na.jeanne2'], ['na.charles2'])
S('na.charles2', 'na.jeanne_v'); P(R('5c72ec7d'), 'na.jeanne_v')
kids(['na.charles2', 'na.jeanne_v'], ['na.charles3'])
S('na.charles3', 'na.eleonore_c'); P(R('ce21005e'), 'na.eleonore_c'); P(R('2905cc98'), 'na.eleonore_c')
kids(['na.charles3', 'na.eleonore_c'], ['na.blanche1'])
JA = R('ab28690e'); g.pin(JA, 'NA_ROY')
S('na.blanche1', JA); kids(['na.blanche1', JA], ['na.carlos_v', 'na.blanche2', 'na.leonor'])
S('na.leonor', 'na.gaston4'); kids(['na.leonor', 'na.gaston4'], ['na.gaston_v'])
S('na.gaston_v', 'na.madeleine'); P(R('50d03330'), 'na.madeleine')
kids(['na.gaston_v', 'na.madeleine'], ['na.febus', 'na.catherine'])
P('na.alain', 'na.jean3'); S('na.catherine', 'na.jean3'); kids(['na.catherine', 'na.jean3'], ['na.henri2'])
S('na.henri2', 'na.marguerite_a'); P(R('97ad334e'), 'na.marguerite_a')
JA3 = R('800e8f67'); AB = R('773c19a5'); H3 = R('14b4e7b7')
kids(['na.henri2', 'na.marguerite_a'], [JA3]); S(JA3, AB); kids([JA3, AB], [H3])
for x in [JA3, AB, H3]:
    g.pin(x, 'NA_ROY')
g.reposition = {'NA_ROY'}
g.write()
