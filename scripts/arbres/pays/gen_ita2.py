import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(95, "Italie — Este (Ferrare), Gonzague (Mantoue) et Farnèse (Parme)")
g.notes = [
    "Trois nouveaux arbres : « Este », « Gonzague » et « Farnèse » (aucun n'existait). Béatrice d'Este (arbre Sforza), Éléonore de Gonzague (Habsbourg), Élisabeth Farnèse (Bourbon d'Espagne), Marguerite d'Autriche (Médicis) et Éléonore de Médicis y sont affichées. Rien n'est supprimé.",
    "Dates : connues par ailleurs (histoire d'Italie), aucune page consultée pour ce lot.",
    "Renée de France est créée dans l'arbre Valois, Éléonore d'Autriche dans l'arbre Habsbourg, Marguerite de Médicis dans l'arbre Médicis, Marie de Portugal et son père dans l'arbre Aviz. Autres épouses de familles sans arbre (Aragon-Naples, Borgia, Bretagne, Brandebourg, Aldobrandini…) : signalées.",
    "Non fait : branche de Modène (Este après 1597), Gonzague-Nevers, Montferrat, enfants cadets et cardinaux.",
]
g.tree('IT_EST', 'ITA', 'Este', section_title='Este')
g.tree('IT_GON', 'ITA', 'Gonzague', section_title='Gonzague')
g.tree('IT_FAR', 'ITA', 'Farnèse', section_title='Farnèse')
g.tree('FR_VAL', 'FRA', 'Valois', entry=E('a92b4627'))
g.tree('DE_HAB', 'DEU', 'Habsbourg', entry=E('6b34bc03'))
g.tree('IT_MED', 'ITA', 'Médicis')
g.tree('PT_AVI', 'PRT', "Maison d'Aviz", entry=E('efb44952'))
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
def M(code, name, b, d, title, g_, tree, leader=False, approx=None, dyn=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, tree, g_='f', approx=None):
    return M(code, name, b, d, title, g_, tree, False, approx, house, 'Maison %s : sans arbre' % house)
ES, GO, FA = 'IT_EST', 'IT_GON', 'IT_FAR'
# --- Este
for c, n, b, d, t in [('niccolo3', 'Niccolò III d\'Este', 1383, 1441, 'Marquis de Ferrare'), ('leonello', 'Leonello d\'Este', 1407, 1450, 'Marquis de Ferrare'),
                      ('borso', 'Borso d\'Este', 1413, 1471, 'Premier duc de Ferrare'), ('ercole1', 'Hercule Ier d\'Este', 1431, 1505, 'Duc de Ferrare'),
                      ('alfonso1', 'Alphonse Ier d\'Este', 1476, 1534, 'Duc de Ferrare'), ('ercole2', 'Hercule II d\'Este', 1508, 1559, 'Duc de Ferrare'),
                      ('alfonso2', 'Alphonse II d\'Este', 1533, 1597, 'Dernier duc de Ferrare'), ('cesare', 'César d\'Este', 1562, 1628, 'Premier duc de Modène')]:
    M('es.' + c, n, b, d, t, 'h', ES, True, dyn='Este')
kids(['es.niccolo3'], ['es.leonello', 'es.borso', 'es.ercole1'])
W('es.eleonora', "Éléonore d'Aragon (Naples)", 1450, 1493, 'Duchesse de Ferrare', 'Aragon-Naples', ES)
S('es.ercole1', 'es.eleonora')
M('es.isabella', "Isabelle d'Este", 1474, 1539, 'Marquise de Mantoue', 'f', ES, False, dyn='Este')
BEA = R('f388aa57')
M('es.ippolito', "Hippolyte d'Este (cardinal)", 1479, 1520, 'Cardinal, fils d\'Hercule Ier', 'h', ES, False, dyn='Este')
kids(['es.ercole1', 'es.eleonora'], ['es.isabella', 'es.alfonso1', 'es.ippolito', BEA]); g.pin(BEA, ES)
W('es.lucrezia', 'Lucrèce Borgia', 1480, 1519, 'Duchesse de Ferrare', 'Borgia', ES)
S('es.alfonso1', 'es.lucrezia')
kids(['es.alfonso1', 'es.lucrezia'], ['es.ercole2'])
M('fr.renee', 'Renée de France', 1510, 1574, 'Duchesse de Ferrare', 'f', 'FR_VAL', False, dyn='Valois')
W('fr.anne_bret', 'Anne de Bretagne', 1477, 1514, 'Reine de France, duchesse de Bretagne', 'Bretagne', 'FR_VAL')
S(R('d8bc083b'), 'fr.anne_bret')
kids([R('d8bc083b'), 'fr.anne_bret'], ['fr.renee', R('66e055eb')])
S('es.ercole2', 'fr.renee'); g.pin('fr.renee', ES)
P('es.ercole2', 'es.alfonso2')
g.fam('es.alfonso2', 'es.cesare')
# --- Gonzague
for c, n, b, d, t in [('gianfrancesco', 'Jean-François Ier de Gonzague', 1395, 1444, 'Premier marquis de Mantoue'),
                      ('ludovico3', 'Louis III de Gonzague', 1412, 1478, 'Marquis de Mantoue'),
                      ('federico1', 'Frédéric Ier de Gonzague', 1441, 1484, 'Marquis de Mantoue'),
                      ('francesco2', 'François II de Gonzague', 1466, 1519, 'Marquis de Mantoue'),
                      ('federico2', 'Frédéric II de Gonzague', 1500, 1540, 'Premier duc de Mantoue'),
                      ('guglielmo', 'Guillaume de Gonzague', 1538, 1587, 'Duc de Mantoue'),
                      ('vincenzo1', 'Vincent Ier de Gonzague', 1562, 1612, 'Duc de Mantoue'),
                      ('francesco4', 'François IV de Gonzague', 1586, 1612, 'Duc de Mantoue'),
                      ('ferdinando', 'Ferdinand de Gonzague', 1587, 1626, 'Duc de Mantoue'),
                      ('vincenzo2', 'Vincent II de Gonzague', 1594, 1627, 'Dernier duc de Mantoue de la ligne directe')]:
    M('go.' + c, n, b, d, t, 'h', GO, True, dyn='Gonzague')
for a, b in [('gianfrancesco', 'ludovico3'), ('ludovico3', 'federico1'), ('federico1', 'francesco2'), ('francesco2', 'federico2'),
             ('federico2', 'guglielmo'), ('guglielmo', 'vincenzo1'), ('vincenzo1', 'francesco4'), ('vincenzo1', 'ferdinando'), ('vincenzo1', 'vincenzo2')]:
    P('go.' + a, 'go.' + b)
g.pin('es.isabella', GO); S('go.francesco2', 'es.isabella'); P('es.isabella', 'go.federico2')
W('go.barbara', 'Barbara de Brandebourg', 1423, 1481, 'Marquise de Mantoue', 'Brandebourg-Hohenzollern', GO)
S('go.ludovico3', 'go.barbara'); P('go.barbara', 'go.federico1')
M('md.margherita_f', 'Marguerite de Médicis (Parme)', 1612, 1679, 'Duchesse de Parme', 'f', 'IT_MED', False, dyn='Médicis')
kids(['md.cosimo2', 'md.mm_autriche'], ['md.margherita_f'])
ELM = 'md.eleonora_m'; S('go.vincenzo1', ELM); g.pin(ELM, GO)
kids(['go.vincenzo1', ELM], [R('e2b87c64')]); g.pin(R('e2b87c64'), GO)
M('ha.eleonora_a', "Éléonore d'Autriche", 1534, 1594, 'Duchesse de Mantoue', 'f', 'DE_HAB', False, dyn='Habsbourg')
kids([R('995c8249'), R('f06f9b33')], ['ha.eleonora_a'])
S('go.guglielmo', 'ha.eleonora_a'); g.pin('ha.eleonora_a', GO); P('ha.eleonora_a', 'go.vincenzo1')
# --- Farnèse
for c, n, b, d, t, ld in [('paul3', 'Paul III (Alexandre Farnèse)', 1468, 1549, 'Pape, fondateur de la puissance Farnèse', True),
                          ('pierluigi', 'Pierre-Louis Farnèse', 1503, 1547, 'Premier duc de Parme', True),
                          ('ottavio', 'Octave Farnèse', 1524, 1586, 'Duc de Parme', True),
                          ('alessandro', 'Alexandre Farnèse', 1545, 1592, 'Duc de Parme, gouverneur des Pays-Bas espagnols', True),
                          ('ranuccio1', 'Ranuce Ier Farnèse', 1569, 1622, 'Duc de Parme', True),
                          ('odoardo1', 'Édouard Ier Farnèse', 1612, 1646, 'Duc de Parme', True),
                          ('ranuccio2', 'Ranuce II Farnèse', 1630, 1694, 'Duc de Parme', True),
                          ('odoardo2', 'Édouard II Farnèse', 1666, 1693, 'Prince héréditaire de Parme', False),
                          ('francesco', 'François Farnèse', 1678, 1727, 'Duc de Parme', True),
                          ('antonio', 'Antoine Farnèse', 1679, 1731, 'Dernier duc Farnèse de Parme', True)]:
    M('fa.' + c, n, b, d, t, 'h', FA, ld, dyn='Farnèse')
for a, b in [('paul3', 'pierluigi'), ('pierluigi', 'ottavio'), ('ottavio', 'alessandro'), ('alessandro', 'ranuccio1'),
             ('ranuccio1', 'odoardo1'), ('odoardo1', 'ranuccio2'), ('ranuccio2', 'odoardo2'), ('ranuccio2', 'francesco'), ('ranuccio2', 'antonio')]:
    P('fa.' + a, 'fa.' + b)
MP = 'md.margaret_a'; g.pin(MP, FA); S('fa.ottavio', MP); P(MP, 'fa.alessandro')
M('pt.duarte_g', 'Édouard de Portugal, duc de Guimarães', 1515, 1540, 'Fils de Manuel Ier', 'h', 'PT_AVI', False, dyn='Aviz')
P(R('927ddf7d'), 'pt.duarte_g')
M('pt.maria_g', 'Marie de Portugal (Guimarães)', 1538, 1577, 'Duchesse de Parme', 'f', 'PT_AVI', False, dyn='Aviz')
P('pt.duarte_g', 'pt.maria_g'); S('fa.alessandro', 'pt.maria_g'); g.pin('pt.maria_g', FA); P('pt.maria_g', 'fa.ranuccio1')
W('fa.aldobrandini', 'Marguerite Aldobrandini', 1588, 1646, 'Duchesse de Parme', 'Aldobrandini', FA)
S('fa.ranuccio1', 'fa.aldobrandini'); P('fa.aldobrandini', 'fa.odoardo1')
S('fa.odoardo1', 'md.margherita_f'); g.pin('md.margherita_f', FA); P('md.margherita_f', 'fa.ranuccio2')
DS = R('5539ea53'); S('fa.odoardo2', DS); g.pin(DS, FA)
ELF = R('2df9c2fd'); kids(['fa.odoardo2', DS], [ELF]); g.pin(ELF, FA)
g.reposition = {'IT_EST', 'IT_GON', 'IT_FAR'}
g.write()
