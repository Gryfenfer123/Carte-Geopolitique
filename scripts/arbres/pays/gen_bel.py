import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(71, "Belgique — Couronne belge : Léopold Ier et ses enfants, Philippe de Flandre, Albert Ier, Léopold III, Baudouin, Albert II, Philippe et ses enfants")
g.notes = [
    "Complète l'arbre de la Couronne belge (rien n'est supprimé).",
    "Sources : Wikipédia en anglais (Léopold Ier, Léopold II, Albert Ier, Léopold III, Albert II, Philippe, Baudouin). Dates non données = vides ; dates connues ailleurs : notées.",
    "Charlotte de Galles est créée dans l'arbre Stuart/Hanovre ; Marie de Hohenzollern-Sigmaringen dans Hohenzollern-Sigmaringen ; Marie-Henriette d'Autriche et Maximilien du Mexique dans Habsbourg-Lorraine ; Napoléon-Victor Bonaparte dans Bonaparte : familles qui ont un arbre.",
    "Fabiola de Mora (famille sans arbre) : placée dans l'arbre belge et signalée.",
]
g.tree('BE_COB', 'BEL', 'Couronne belge', entry=E('b4e42a0f'))
g.tree('GB_HAN', 'GBR', 'Maison Stuart et Maison de Hanovre', entry=E('a874f93b'))
g.tree('DE_HZ', 'DEU', 'Hohenzollern-Sigmaringen')
g.tree('AT_HL', 'AUT', 'Habsbourg-Lorraine')
g.tree('FR_BON', 'FRA', 'Bonaparte', entry=E('ae0dd55b'))
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
T = 'BE_COB'
def M(code, name, b, d, title, g_, leader=False, approx=None, dyn='Saxe-Cobourg (Belgique)', tree=T, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)

L1 = R('a1f6258c'); L2 = R('166bd086'); PH = R('e9030656'); AL1 = R('df7a3a33'); L3 = R('348b2f89'); AL2 = R('cc43f756'); PHI = R('8bda1831')
M('be.charlotte_gb', 'Charlotte de Galles', 1796, 1817, 'Princesse héritière du Royaume-Uni', 'f', dyn='Hanovre', tree='GB_HAN', approx='naissance connue par ailleurs, non donnée par la page de Léopold Ier')
P(R('98453508'), 'be.charlotte_gb')
S(L1, 'be.charlotte_gb')
M('be.louis_philippe', 'Louis-Philippe de Belgique', 1833, 1834, 'Prince héritier de Belgique', 'h')
M('be.charlotte_mex', 'Charlotte de Belgique', 1840, 1927, 'Impératrice du Mexique', 'f')
kids([L1, R('e277dca4')], ['be.louis_philippe', 'be.charlotte_mex'])
M('be.maximilien', 'Maximilien Ier du Mexique', 1832, 1867, 'Empereur du Mexique', 'h', True, dyn='Habsbourg-Lorraine', tree='AT_HL', approx='dates connues par ailleurs')
kids([R('9aa90ed2'), R('43f54261')], ['be.maximilien'])
S('be.maximilien', 'be.charlotte_mex')
M('be.marie_henriette', "Marie-Henriette d'Autriche", 1836, 1902, 'Reine des Belges', 'f', dyn='Habsbourg-Lorraine', tree='AT_HL')
S(L2, 'be.marie_henriette')
M('be.louise_bel', 'Louise de Belgique', 1858, 1924, 'Princesse de Saxe-Cobourg et Gotha', 'f')
M('be.leopold_brabant', 'Léopold de Belgique, duc de Brabant', 1859, 1869, 'Prince héritier', 'h')
M('be.clementine', 'Clémentine de Belgique', 1872, 1955, 'Princesse Napoléon', 'f')
kids([L2, 'be.marie_henriette'], ['be.louise_bel', 'be.leopold_brabant', R('33cdc1df'), 'be.clementine'])
S(R('33cdc1df'), R('527f3213')); g.pin(R('527f3213'), T)
M('be.victor_bonaparte', 'Napoléon-Victor Bonaparte', 1862, 1926, 'Prince Napoléon', 'h', dyn='Bonaparte', tree='FR_BON', approx='dates connues par ailleurs')
S('be.clementine', 'be.victor_bonaparte')
M('be.marie_hz', 'Marie de Hohenzollern-Sigmaringen', 1845, 1912, 'Comtesse de Flandre', 'f', dyn='Hohenzollern-Sigmaringen', tree='DE_HZ', approx='dates connues par ailleurs')
kids(['ro.karl_anton', R('05120133')], ['be.marie_hz'])
S(PH, 'be.marie_hz')
M('be.baudouin_fl', 'Baudouin de Belgique, prince de Belgique', 1869, 1891, 'Prince', 'h')
M('be.henriette', 'Henriette de Belgique', 1870, 1948, 'Duchesse de Vendôme', 'f')
M('be.josephine', 'Joséphine de Belgique', 1872, 1958, 'Princesse de Hohenzollern', 'f')
kids([PH, 'be.marie_hz'], ['be.baudouin_fl', 'be.henriette', 'be.josephine', AL1])
M('be.charles_fl', 'Charles de Belgique, comte de Flandre', 1903, 1983, 'Régent de Belgique', 'h')
kids([AL1, R('faf70fc6')], ['be.charles_fl'])
kids([AL1, R('faf70fc6')], ['sv.marie_jose']); g.pin('sv.marie_jose', T)
M('be.lilian', 'Lilian Baels', 1916, 2002, 'Princesse de Réthy', 'f', dyn='Baels', flag='Famille Baels : sans arbre', approx='dates connues par ailleurs')
S(L3, 'be.lilian')
M('be.alexandre', 'Alexandre de Belgique', 1942, 2009, 'Prince de Belgique', 'h')
M('be.mchristine', 'Marie-Christine de Belgique', 1951, None, 'Princesse de Belgique', 'f')
M('be.mesmeralda', 'Marie-Esméralda de Belgique', 1956, None, 'Princesse de Belgique', 'f')
kids([L3, 'be.lilian'], ['be.alexandre', 'be.mchristine', 'be.mesmeralda'])
M('be.fabiola', 'Fabiola de Mora y Aragón', 1928, 2014, 'Reine des Belges', 'f', dyn='Mora y Aragón', flag='Famille Mora : sans arbre', approx='dates connues par ailleurs')
S(R('aa41d937'), 'be.fabiola')
S(AL2, R('31c3f188'))
M('be.astrid', 'Astrid de Belgique', 1962, None, 'Archiduchesse d\'Autriche-Este', 'f')
M('be.laurent', 'Laurent de Belgique', 1963, None, 'Prince de Belgique', 'h')
M('be.delphine', 'Delphine de Saxe-Cobourg', 1968, None, 'Princesse de Belgique', 'f')
kids([AL2, R('31c3f188')], ['be.astrid', 'be.laurent', PHI])
P(AL2, 'be.delphine')
S(PHI, R('00f7295a'))
M('be.gabriel', 'Gabriel de Belgique', 2003, None, 'Prince de Belgique', 'h')
M('be.emmanuel', 'Emmanuel de Belgique', 2005, None, 'Prince de Belgique', 'h')
M('be.eleonore', 'Éléonore de Belgique', 2008, None, 'Princesse de Belgique', 'f')
kids([PHI, R('00f7295a')], [R('fc2f6e10'), 'be.gabriel', 'be.emmanuel', 'be.eleonore'])
g.reposition = {'BE_COB'}
g.write()
