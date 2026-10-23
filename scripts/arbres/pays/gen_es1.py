import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(100, "Espagne — compléments Habsbourg et Bourbon d'Espagne")
g.notes = [
    "Complète les arbres existants « Union de Castille et d'Aragon » (Habsbourg d'Espagne) et « Les Bourbons » (Bourbon d'Espagne). Rien n'est supprimé.",
    "Dates : connues par ailleurs (histoire d'Espagne), aucune page consultée pour ce lot.",
    "Épouses et princes créés dans l'arbre de leur propre maison puis affichés ici : Marie-Manuelle de Portugal (Aviz), Barbe de Bragance et Marie-Isabelle de Portugal (Bragance), Louise-Élisabeth et Marie-Louise d'Orléans (Bourbon-Orléans), Marie-Josèphe de Saxe (Wettin). Marie-Antoinette de Bourbon-Siciles, Marie-Anne de Neubourg et Anne d'Autriche (reine de France) existaient déjà et sont reliées.",
    "Liens ajoutés : Philippe IV et Élisabeth de France vers Marie-Thérèse (épouse de Louis XIV) ; Charles V vers Don Juan d'Autriche (fils naturel).",
    "Non fait : Carlistes (prétendants), cadets des Bourbons (Montpensier, Cadix…), enfants morts en bas âge hors successions.",
]
g.tree('ES_UNI', 'ESP', "Union de Castille et d'Aragon", entry=E('e6300f83'))
g.tree('ES_BOU', 'ESP', 'Bourbon', entry=E('7195e6c8'))
g.tree('PT_AVI', 'PRT', "Maison d'Aviz", entry=E('efb44952'))
g.tree('PT_BRA', 'PRT', 'Maison de Bragance', entry=E('14db1138'))
g.tree('FR_BOU', 'FRA', 'de Bourbon et Bourbon-Orléans', entry=E('786a379d'))
g.tree('DE_WET', 'DEU', 'Wettin', entry=E('309f20ea'))
P, S = g.par, g.sp
kids = lambda ps, cs: [P(p, c) for c in cs for p in ps]
HB = 'Maison de Habsbourg'; BB = 'Bourbon d\'Espagne'
def H(code, name, b, d, title, g_='h', leader=False, approx=None):
    return g.m('es.' + code, name, b, d, title, HB, 'ES_UNI', g_, leader, approx=approx)
def B(code, name, b, d, title, g_='h', leader=False):
    return g.m('es.' + code, name, b, d, title, BB, 'ES_BOU', g_, leader)
def O(code, name, b, d, title, dyn, tree, to, g_='f'):
    g.m('es.' + code, name, b, d, title, dyn, tree, g_, False)
    g.pin('es.' + code, to)

# Habsbourg d'Espagne
H('carlos', 'Don Carlos d\'Autriche (prince des Asturies)', 1545, 1568, 'Infant, fils de Philippe II, mort en captivité')
H('juan', 'Don Juan d\'Autriche', 1547, 1578, 'Fils naturel de Charles Quint, vainqueur de Lépante')
O('manuela', 'Marie-Manuelle de Portugal', 1527, 1545, 'Première épouse de Philippe II', 'Maison d\'Aviz', 'PT_AVI', 'ES_UNI')
H('carlos2', 'Charles d\'Autriche (infant)', 1607, 1632, 'Infant, fils de Philippe III')
H('fernando', 'Ferdinand d\'Autriche (cardinal-infant)', 1609, 1641, 'Gouverneur des Pays-Bas espagnols')
H('baltasar', 'Balthazar-Charles d\'Autriche', 1629, 1646, 'Prince des Asturies, héritier de Philippe IV')
O('marialouise', 'Marie-Louise d\'Orléans', 1662, 1689, 'Reine d\'Espagne, première épouse de Charles II', 'Bourbon-Orléans', 'FR_BOU', 'ES_UNI')
P(R('13608e16'), 'es.juan')
kids([R('8ee8a84e'), 'es.manuela'], ['es.carlos'])
S(R('8ee8a84e'), 'es.manuela')
P(R('f825ea7a'), 'es.manuela'); P(R('be9529fe'), 'es.manuela')
PH3 = R('29ededbe'); PH4 = R('d1bc8e7a'); MG = R('d5acf03d'); EF = R('99767669'); C2 = R('787d4e3c')
kids([PH3, MG], ['es.carlos2', 'es.fernando', PH4, R('fcfe903c'), R('bea8235e')])
kids([PH4, EF], ['es.baltasar', R('83ead0a6')])
S(C2, 'es.marialouise'); P(R('e3e60e7d'), 'es.marialouise')
S(PH3, MG)
g.pin(R('bea8235e'), 'ES_UNI'); g.pin(R('83ead0a6'), 'ES_UNI'); g.pin(EF, 'ES_UNI')

# Bourbon d'Espagne
B('carlos_is', 'Charles-Marie-Isidore de Bourbon (infant Don Carlos)', 1788, 1855, 'Frère de Ferdinand VII, prétendant carliste')
B('francisco', 'François de Paule de Bourbon', 1794, 1865, 'Infant, frère de Ferdinand VII')
O('barbara', 'Barbe de Bragance', 1711, 1758, 'Reine d\'Espagne, épouse de Ferdinand VI', 'Maison de Bragance', 'PT_BRA', 'ES_BOU')
O('louisa', 'Louise-Élisabeth d\'Orléans', 1709, 1742, 'Reine d\'Espagne, épouse de Louis Ier', 'Bourbon-Orléans', 'FR_BOU', 'ES_BOU')
O('isabel_p', 'Marie-Isabelle de Portugal', 1797, 1818, 'Reine d\'Espagne, deuxième épouse de Ferdinand VII', 'Maison de Bragance', 'PT_BRA', 'ES_BOU')
O('josefa', 'Marie-Josèphe de Saxe (reine d\'Espagne)', 1803, 1829, 'Reine d\'Espagne, troisième épouse de Ferdinand VII', 'Wettin', 'DE_WET', 'ES_BOU')
F6 = R('b4394bc7'); L1 = R('22e076ee'); F7 = R('d51742f7'); C4 = R('4717536a'); MLP = R('a1d8a44a')
S(F6, 'es.barbara'); P(R('8cae7bf6'), 'es.barbara'); P(R('db2f227e'), 'es.barbara')
S(L1, 'es.louisa'); P(R('f11b51af'), 'es.louisa'); P(R('b91a0834'), 'es.louisa')
kids([C4, MLP], ['es.carlos_is', 'es.francisco'])
S(F7, R('4c715634')); g.pin(R('4c715634'), 'ES_BOU')
S(F7, 'es.isabel_p'); P('pb.joao6', 'es.isabel_p'); P('pb.carlota', 'es.isabel_p')
S(F7, 'es.josefa'); P(R('7d231c26'), 'es.josefa')
g.reposition = {'ES_UNI', 'ES_BOU'}
g.write()
