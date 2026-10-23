import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(80, "Italie — Visconti et Sforza, seigneurs puis ducs de Milan")
g.notes = [
    "Deux nouveaux arbres : « Visconti » et « Sforza » (aucun n'existait). Rien n'est supprimé.",
    "Dates : connues par ailleurs (histoire de Milan), aucune page consultée pour ce lot ; dates douteuses laissées vides. Filiation d'Élisabeth Visconti (1374-1432) à Bernabò : à vérifier.",
    "Valentine Visconti (arbre Valois), Viridis et Maddalena/Élisabeth Visconti (Habsbourg, Wittelsbach), Bona Sforza (Jagellon) et Marie de Savoie sont affichées ici depuis leurs arbres. Isabelle de Valois, Blanche et Bona de Savoie sont créées dans leurs arbres.",
    "Caterina Sforza (créée en v79 dans l'arbre Médicis, signalée) est désormais aussi rattachée à son père dans l'arbre Sforza.",
    "Non fait : Ascanio, les nombreux enfants naturels, Beatrice di Tenda, branche Visconti de Bernabò au-delà de ses filles mariées.",
]
g.tree('IT_VIS', 'ITA', 'Visconti', section_title='Visconti')
g.tree('IT_SFO', 'ITA', 'Sforza', section_title='Sforza')
g.tree('IT_SAV', 'ITA', 'Maison de Savoie')
g.tree('FR_VAL', 'FRA', 'Valois', entry=E('a92b4627'))
g.tree('DE_WIT', 'DEU', 'Wittelsbach', entry=E('e76d91a3'))
g.tree('DE_HAB', 'DEU', 'Habsbourg', entry=E('6b34bc03'))
g.tree('PL_JAG', 'POL', 'Jagellon', entry=E('2330c043'))
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
def M(code, name, b, d, title, g_, tree, leader=False, approx=None, dyn='Visconti', flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
V = 'IT_VIS'; SF = 'IT_SFO'
def W(code, name, b, d, title, house, tree, approx=None):
    return M(code, name, b, d, title, 'f', tree, dyn=house, approx=approx, flag='Maison %s : sans arbre' % house)

M('vi.matteo1', 'Matteo Ier Visconti', 1250, 1322, 'Seigneur de Milan', 'h', V, leader=True)
M('vi.galeazzo1', 'Galéas Ier Visconti', 1277, 1328, 'Seigneur de Milan', 'h', V, leader=True)
M('vi.stefano', 'Étienne Visconti', 1287, 1327, 'Fils de Matteo Ier', 'h', V)
M('vi.luchino', 'Luchino Visconti', 1292, 1349, 'Seigneur de Milan', 'h', V, leader=True)
M('vi.giovanni', 'Jean Visconti', 1290, 1354, 'Archevêque et seigneur de Milan', 'h', V, leader=True)
kids(['vi.matteo1'], ['vi.galeazzo1', 'vi.stefano', 'vi.luchino', 'vi.giovanni'])
M('vi.azzone', 'Azzon Visconti', 1302, 1339, 'Seigneur de Milan', 'h', V, leader=True)
P('vi.galeazzo1', 'vi.azzone')
M('vi.matteo2', 'Matteo II Visconti', 1319, 1355, 'Seigneur de Milan', 'h', V, leader=True)
M('vi.galeazzo2', 'Galéas II Visconti', 1320, 1378, 'Seigneur de Milan', 'h', V, leader=True)
M('vi.bernabo', 'Bernabò Visconti', 1323, 1385, 'Seigneur de Milan', 'h', V, leader=True)
kids(['vi.stefano'], ['vi.matteo2', 'vi.galeazzo2', 'vi.bernabo'])
M('sv.bianca_sav', 'Blanche de Savoie', 1336, 1387, 'Dame de Milan', 'f', 'IT_SAV', dyn='Savoie')
P(R('1fb2f965'), 'sv.bianca_sav')
S('vi.galeazzo2', 'sv.bianca_sav'); g.pin('sv.bianca_sav', V)
M('vi.gg', 'Jean Galéas Visconti', 1351, 1402, 'Premier duc de Milan', 'h', V, leader=True)
kids(['vi.galeazzo2', 'sv.bianca_sav'], ['vi.gg'])
M('fv.isabelle_v', 'Isabelle de Valois', 1348, 1372, 'Comtesse de Vertus', 'f', 'FR_VAL', dyn='Valois')
P(R('5c72ec7d'), 'fv.isabelle_v')
S('vi.gg', 'fv.isabelle_v'); g.pin('fv.isabelle_v', V)
VAL = R('ab1ad91b')
kids(['vi.gg', 'fv.isabelle_v'], [VAL]); g.pin(VAL, V)
W('vi.regina', 'Béatrice Regina della Scala', 1331, 1384, 'Dame de Milan', 'Della Scala', V)
S('vi.bernabo', 'vi.regina')
M('vi.caterina_v', 'Catherine Visconti', 1360, 1404, 'Duchesse de Milan, régente', 'f', V)
kids(['vi.bernabo', 'vi.regina'], ['vi.caterina_v'])
for r in ['fc3f4f64', 'f3c9aa1a', 'bc2cc2ad']:
    P('vi.bernabo', R(r)); g.pin(R(r), V)
S('vi.gg', 'vi.caterina_v')
M('vi.gm', 'Jean-Marie Visconti', 1388, 1412, 'Duc de Milan', 'h', V, leader=True)
M('vi.fm', 'Philippe-Marie Visconti', 1392, 1447, 'Dernier duc Visconti de Milan', 'h', V, leader=True)
kids(['vi.gg', 'vi.caterina_v'], ['vi.gm', 'vi.fm'])
MS = R('1b01ac01'); g.pin(MS, V); S('vi.fm', MS)
M('vi.bianca_maria', 'Blanche-Marie Visconti', 1425, 1468, 'Duchesse de Milan, épouse de François Sforza', 'f', V, approx='fille naturelle de Philippe-Marie')
P('vi.fm', 'vi.bianca_maria')

# Sforza
M('sf.muzio', 'Muzio Attendolo Sforza', 1369, 1424, 'Condottiere, fondateur des Sforza', 'h', SF, dyn='Sforza')
M('sf.francesco', 'François Ier Sforza', 1401, 1466, 'Duc de Milan', 'h', SF, leader=True, dyn='Sforza')
P('sf.muzio', 'sf.francesco')
g.pin('vi.bianca_maria', SF); S('sf.francesco', 'vi.bianca_maria')
M('sf.galeazzo_m', 'Galéas-Marie Sforza', 1444, 1476, 'Duc de Milan', 'h', SF, leader=True, dyn='Sforza')
M('sf.ludovico', 'Ludovic le More', 1452, 1508, 'Duc de Milan', 'h', SF, leader=True, dyn='Sforza')
kids(['sf.francesco', 'vi.bianca_maria'], ['sf.galeazzo_m', 'sf.ludovico'])
M('sv.bona_sav', 'Bonne de Savoie', 1449, 1503, 'Duchesse de Milan, régente', 'f', 'IT_SAV', dyn='Savoie')
kids([R('2152e3ef'), R('6c0c2f65')], ['sv.bona_sav'])
S('sf.galeazzo_m', 'sv.bona_sav'); g.pin('sv.bona_sav', SF)
M('sf.gian_g', 'Jean-Galéas Sforza', 1469, 1494, 'Duc de Milan', 'h', SF, leader=True, dyn='Sforza')
M('sf.bianca', 'Blanche-Marie Sforza', 1472, 1510, 'Impératrice, épouse de Maximilien Ier', 'f', SF, dyn='Sforza')
kids(['sf.galeazzo_m', 'sv.bona_sav'], ['sf.gian_g', 'sf.bianca'])
MAX = R('22d205d8'); S(MAX, 'sf.bianca'); g.pin(MAX, SF)
CAT = R('387d26db'); P('sf.galeazzo_m', CAT); g.pin(CAT, SF)
REGF_FLAGS = [f for f in REG['flags'] if f['name'] != 'Caterina Sforza']
REG['flags'] = REGF_FLAGS
W('sf.isabella_a', "Isabelle d'Aragon (Naples)", 1470, 1524, 'Duchesse de Milan', 'Aragon-Naples', SF)
S('sf.gian_g', 'sf.isabella_a')
BONA = R('dd0ecce2'); kids(['sf.gian_g', 'sf.isabella_a'], [BONA]); g.pin(BONA, SF)
W('sf.beatrice_e', "Béatrice d'Este", 1475, 1497, 'Duchesse de Milan', 'Este', SF)
S('sf.ludovico', 'sf.beatrice_e')
M('sf.massimiliano', 'Maximilien Sforza', 1493, 1530, 'Duc de Milan', 'h', SF, leader=True, dyn='Sforza')
M('sf.francesco2', 'François II Sforza', 1495, 1535, 'Dernier duc Sforza de Milan', 'h', SF, leader=True, dyn='Sforza')
kids(['sf.ludovico', 'sf.beatrice_e'], ['sf.massimiliano', 'sf.francesco2'])

g.reposition = {'IT_VIS', 'IT_SFO'}
g.write()
