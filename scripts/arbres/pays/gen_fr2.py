import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(78, "France — Bonaparte : fratrie de Napoléon Ier, Beauharnais, enfants de Louis et de Jérôme, Prince impérial")
g.notes = [
    "Complète l'arbre « Bonaparte » (13 membres au départ ; rien n'est supprimé).",
    "Dates : connues par ailleurs (histoire de France), aucune page consultée pour ce lot ; dates douteuses laissées vides.",
    "Augusta de Bavière est créée dans l'arbre Wittelsbach. Maisons sans arbre (Beauharnais, Murat, Baciocchi, Clary, Wurtemberg…) : signalées.",
    "Non fait : enfants de Joseph, Lucien, Murat ; branche américaine de Jérôme ; Amélie de Leuchtenberg n'est pas reliée à son mari (Pierre Ier du Brésil absent de la base).",
]
g.tree('FR_BON', 'FRA', 'Bonaparte', entry=E('ae0dd55b'))
g.tree('DE_WIT', 'DEU', 'Wittelsbach', entry=E('e76d91a3'))
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
T = 'FR_BON'
def M(code, name, b, d, title, g_, tree=T, leader=False, approx=None, dyn='Bonaparte', flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, g_='f', approx=None):
    return M(code, name, b, d, title, g_, T, dyn=house, approx=approx, flag='Maison %s : sans arbre' % house)

CM, LET = R('2cafb38a'), R('3fe14ec2')
N1, JOS, JER, LOU, HOR, N3, EUG = R('66d515fd'), R('e96686c9'), R('276d911e'), R('580cda52'), R('39dd3223'), R('1488e049'), R('23c92a87')
JOSEPH = R('969467e8')
# fratrie
M('bo.elisa', 'Élisa Bonaparte', 1777, 1820, 'Grande-duchesse de Toscane', 'f')
M('bo.pauline', 'Pauline Bonaparte', 1780, 1825, 'Princesse Borghèse', 'f')
M('bo.caroline', 'Caroline Bonaparte', 1782, 1839, 'Reine de Naples', 'f')
kids([CM, LET], ['bo.elisa', 'bo.pauline', 'bo.caroline'])
W('bo.murat', 'Joachim Murat', 1767, 1815, 'Roi de Naples', 'Murat', 'h')
S('bo.caroline', 'bo.murat')
W('bo.baciocchi', 'Félix Baciocchi', 1762, 1841, "Prince de Lucques, époux d'Élisa", 'Baciocchi', 'h')
S('bo.elisa', 'bo.baciocchi')
W('bo.clary', 'Julie Clary', 1771, 1845, "Reine de Naples puis d'Espagne, épouse de Joseph", 'Clary')
S(JOSEPH, 'bo.clary')
# Beauharnais
W('bo.alexandre_b', 'Alexandre de Beauharnais', 1760, 1794, 'Premier mari de Joséphine', 'Beauharnais', 'h')
S('bo.alexandre_b', JOS)
M('bo.eugene', 'Eugène de Beauharnais', 1781, 1824, "Vice-roi d'Italie, duc de Leuchtenberg", 'h', dyn='Beauharnais')
kids(['bo.alexandre_b', JOS], ['bo.eugene', HOR])
M('wi.augusta_b', 'Augusta de Bavière', 1788, 1851, 'Duchesse de Leuchtenberg', 'f', 'DE_WIT', dyn='Wittelsbach')
P(R('bb2ceff8'), 'wi.augusta_b')
S('bo.eugene', 'wi.augusta_b')
JL = R('b47f1c54')
M('bo.auguste_l', 'Auguste de Beauharnais, duc de Leuchtenberg', 1810, 1835, 'Prince consort du Portugal (époux de Marie II)', 'h', dyn='Beauharnais')
M('bo.amelie_l', 'Amélie de Leuchtenberg', 1812, 1873, 'Impératrice du Brésil', 'f', dyn='Beauharnais')
M('bo.theodolinde', 'Théodolinde de Leuchtenberg', 1814, 1857, 'Comtesse de Wurtemberg', 'f', dyn='Beauharnais')
M('bo.max_l', 'Maximilien de Beauharnais, duc de Leuchtenberg', 1817, 1852, 'Gendre de Nicolas Ier', 'h', dyn='Beauharnais')
kids(['bo.eugene', 'wi.augusta_b'], [JL, 'bo.auguste_l', 'bo.amelie_l', 'bo.theodolinde', 'bo.max_l'])
# Louis, Jérôme, Napoléon III
M('bo.napoleon_louis', 'Napoléon-Louis Bonaparte', 1804, 1831, 'Fils de Louis et Hortense', 'h')
kids([LOU, HOR], ['bo.napoleon_louis'])
M('bo.prince_imp', 'Napoléon Eugène, prince impérial', 1856, 1879, 'Fils de Napoléon III', 'h')
kids([N3, EUG], ['bo.prince_imp'])
W('bo.catherine_w', 'Catherine de Wurtemberg', 1783, 1835, 'Reine de Westphalie', 'Wurtemberg')
S(JER, 'bo.catherine_w')
M('bo.mathilde', 'Mathilde Bonaparte', 1820, 1904, 'Princesse, salonnière', 'f')
M('bo.plonplon', 'Napoléon-Jérôme Bonaparte (Plon-Plon)', 1822, 1891, 'Prince Napoléon, héritier bonapartiste', 'h')
kids([JER, 'bo.catherine_w'], ['bo.mathilde', 'bo.plonplon'])
CL = R('e414da9b')
S('bo.plonplon', CL)
kids(['bo.plonplon', CL], [R('e74c9a1b')])

g.reposition = {'FR_BON'}
g.write()
