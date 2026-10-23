import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(102, "Italie du Sud — Anjou-Naples et Aragon-Naples")
g.notes = [
    "Deux nouveaux arbres : « Anjou-Naples » (Charles Ier à René, avec les Anjou-Durazzo et les ducs d'Anjou Valois qui ont régné ou revendiqué Naples) et « Aragon-Naples » (Ferrante Ier à Frédéric IV). Charles II, Charles Martel, Marie de Hongrie, André de Hongrie, Marie d'Anjou, Marguerite d'Anjou, Alphonse V, Isabelle, Béatrice et Éléonore d'Aragon y sont affichés (ils restent dans leur arbre). Rien n'est supprimé.",
    "Dates : connues par ailleurs (histoire de Naples), aucune page consultée pour ce lot.",
    "Liens ajoutés : Charles III d'Espagne (Charles VII de Naples) était déjà relié à Ferdinand Ier des Deux-Siciles ; rien à ajouter côté Bourbon-Siciles.",
    "Épouses créées dans leur propre arbre puis affichées : Hippolyte Sforza (Sforza), Yolande d'Aragon (Barcelone). Béatrice de Provence, Isabelle de Clermont et Sancie de Majorque : familles sans arbre, signalées.",
    "Non fait : épouses des Anjou-Durazzo, branche de Tarente après Louis, cadets d'Aragon-Naples (princes de Rossano…).",
]
g.tree('IT_ANJ', 'ITA', 'Anjou-Naples', section_title='Anjou-Naples')
g.tree('IT_ARN', 'ITA', 'Aragon-Naples', section_title='Aragon-Naples')
g.tree('IT_SFO', 'ITA', 'Sforza')
g.tree('ES_BAR', 'ESP', 'Maison de Barcelone')
P, S = g.par, g.sp
kids = lambda ps, cs: [P(p, c) for c in cs for p in ps]
AN = 'Anjou-Naples'; AR = 'Aragon-Naples'
def A(code, name, b, d, title, g_='h', leader=False, flag=None, approx=None, dyn=AN, tree='IT_ANJ'):
    return g.m('nap.' + code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def O(code, name, b, d, title, dyn, tree, to):
    g.m('nap.' + code, name, b, d, title, dyn, tree, 'f', False)
    g.pin('nap.' + code, to)

A('charles1', 'Charles Ier d\'Anjou', 1226, 1285, 'Roi de Sicile puis de Naples, comte de Provence', leader=True)
A('beatrice', 'Béatrice de Provence', 1234, 1267, 'Reine de Sicile, épouse de Charles Ier', 'f', flag='Maison de Provence (Barcelone-Provence) : sans arbre')
A('robert', 'Robert le Sage', 1278, 1343, 'Roi de Naples (1309-1343)', leader=True)
A('sancia', 'Sancie de Majorque', 1285, 1345, 'Reine de Naples, épouse de Robert', 'f', flag='Maison de Majorque : sans arbre')
A('philippe_t', 'Philippe Ier de Tarente', 1278, 1332, 'Prince de Tarente, frère de Robert')
A('louis_t', 'Louis de Tarente', 1320, 1362, 'Prince de Tarente, roi de Naples par mariage (1352-1362)', leader=True)
A('jean_g', 'Jean de Durazzo (de Gravina)', 1294, 1336, 'Duc de Durazzo, frère de Robert')
A('charles_d', 'Charles de Durazzo', 1323, 1348, 'Duc de Durazzo, exécuté par le roi de Hongrie')
A('charles_c', 'Charles de Calabre', 1298, 1328, 'Duc de Calabre, fils de Robert')
A('jeanne1', 'Jeanne Ire de Naples', 1325, 1382, 'Reine de Naples (1343-1382), comtesse de Provence', 'f', True)
A('charles3', 'Charles III de Durazzo', 1345, 1386, 'Roi de Naples (1382-1386), roi de Hongrie (1385-1386)', leader=True)
A('margherita', 'Marguerite de Durazzo', 1347, 1412, 'Reine de Naples, épouse de Charles III, régente', 'f')
A('ladislas', 'Ladislas Ier de Naples', 1377, 1414, 'Roi de Naples (1386-1414)', leader=True)
A('jeanne2', 'Jeanne II de Naples', 1373, 1435, 'Reine de Naples (1414-1435)', 'f', True)
A('louis1a', 'Louis Ier d\'Anjou', 1339, 1384, 'Duc d\'Anjou, héritier désigné de Jeanne Ire', leader=True)
A('louis2a', 'Louis II d\'Anjou', 1377, 1417, 'Duc d\'Anjou, roi de Naples titulaire', leader=True)
A('louis3a', 'Louis III d\'Anjou', 1403, 1434, 'Duc d\'Anjou, héritier de Jeanne II', leader=True)
A('rene', 'René d\'Anjou (le bon roi René)', 1409, 1480, 'Roi de Naples (1435-1442), duc d\'Anjou et de Lorraine', leader=True)
O('yolande', 'Yolande d\'Aragon', 1384, 1442, 'Duchesse d\'Anjou, belle-mère de Charles VII', 'Maison de Barcelone', 'ES_BAR', 'IT_ANJ')

C1 = 'nap.charles1'; C2 = R('78d0b5aa'); MH = R('bac0a74b'); CMART = R('963424ff')
P(R('579590ed'), C1); S(C1, 'nap.beatrice')
kids([C1, 'nap.beatrice'], [C2]); kids([C2, MH], [CMART, 'nap.robert', 'nap.philippe_t', 'nap.jean_g'])
for x in [C2, MH, CMART, R('ace83db1'), R('716152f7'), R('44a442af'), R('07589e84'), R('e268c95a')]:
    g.pin(x, 'IT_ANJ')
P(CMART, R('ace83db1')); P(C2, R('44a442af')); P(C2, R('07589e84')); P(C2, R('e268c95a'))
S('nap.robert', 'nap.sancia'); P('nap.robert', 'nap.charles_c'); P('nap.charles_c', 'nap.jeanne1')
S('nap.jeanne1', R('716152f7')); S('nap.jeanne1', 'nap.louis_t')
P('nap.philippe_t', 'nap.louis_t')
P('nap.jean_g', 'nap.charles_d'); P('nap.charles_d', 'nap.charles3')
S('nap.charles3', 'nap.margherita'); kids(['nap.charles3', 'nap.margherita'], ['nap.ladislas', 'nap.jeanne2'])
g.fam('nap.jeanne1', 'nap.charles3'); g.fam('nap.jeanne1', 'nap.louis1a')
g.fam('nap.jeanne2', 'nap.louis3a'); g.fam('nap.jeanne2', 'nap.rene'); g.fam('nap.jeanne2', R('bbbe49d7'))
P(R('5c72ec7d'), 'nap.louis1a'); P(R('7010ac16'), 'nap.louis1a')
P('nap.louis1a', 'nap.louis2a')
S('nap.louis2a', 'nap.yolande'); P(R('69d0a891'), 'nap.yolande')
kids(['nap.louis2a', 'nap.yolande'], ['nap.louis3a', 'nap.rene', R('6df9addc')])
P('nap.rene', R('6fb37332'))
g.pin(R('6df9addc'), 'IT_ANJ'); g.pin(R('6fb37332'), 'IT_ANJ')

# Aragon-Naples
def R_(code, name, b, d, title, g_='h', leader=False, flag=None, approx=None):
    return g.m('nap.' + code, name, b, d, title, AR, 'IT_ARN', g_, leader, approx=approx, flag=flag)
AV = R('bbbe49d7'); g.pin(AV, 'IT_ARN')
R_('ferrante', 'Ferrante Ier de Naples', 1431, 1494, 'Roi de Naples (1458-1494), fils naturel d\'Alphonse V', leader=True)
R_('isabelle_c', 'Isabelle de Clermont-Tarente', 1424, 1465, 'Reine de Naples, épouse de Ferrante Ier', 'f', flag='Maison de Clermont-Tarente : sans arbre')
R_('juana', 'Jeanne d\'Aragon (reine de Naples)', 1454, 1517, 'Seconde épouse de Ferrante Ier', 'f')
R_('alfonso2', 'Alphonse II de Naples', 1448, 1495, 'Roi de Naples (1494-1495)', leader=True)
R_('ferrandino', 'Ferdinand II de Naples (Ferrandino)', 1469, 1496, 'Roi de Naples (1495-1496)', leader=True)
R_('giovanna', 'Jeanne de Naples (reine, épouse de Ferrandino)', 1478, 1518, 'Reine de Naples', 'f')
R_('federico', 'Frédéric IV de Naples', 1451, 1504, 'Roi de Naples (1496-1501), dernier roi aragonais', leader=True)
O('ippolita', 'Hippolyte Marie Sforza', 1446, 1484, 'Duchesse de Calabre, épouse d\'Alphonse II', 'Sforza', 'IT_SFO', 'IT_ARN')
P(AV, 'nap.ferrante'); S('nap.ferrante', 'nap.isabelle_c'); S('nap.ferrante', 'nap.juana')
P(R('ab28690e'), 'nap.juana')
kids(['nap.ferrante', 'nap.isabelle_c'], ['nap.alfonso2', 'nap.federico', R('a810968f'), R('8c899e6e')])
for x in [R('a810968f'), R('8c899e6e'), R('90cd1f76')]:
    g.pin(x, 'IT_ARN')
S('nap.alfonso2', 'nap.ippolita'); P(R('7b2839f1'), 'nap.ippolita'); P(R('8fbc7d6a'), 'nap.ippolita')
kids(['nap.alfonso2', 'nap.ippolita'], ['nap.ferrandino', R('90cd1f76')])
kids(['nap.ferrante', 'nap.juana'], ['nap.giovanna'])
S('nap.ferrandino', 'nap.giovanna')
g.reposition = {'IT_ANJ', 'IT_ARN'}
g.write()
