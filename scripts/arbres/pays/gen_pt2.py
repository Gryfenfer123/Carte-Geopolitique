import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(99, "Portugal — maison de Bragance, de Pierre III à Manuel II (et Brésil impérial)")
g.notes = [
    "Complète l'arbre « Maison de Bragance » existant (Jean IV à Marie Ire) avec la suite des rois jusqu'à Manuel II, Pierre IV (Pierre Ier du Brésil), Pierre II du Brésil et Michel Ier. Rien n'est supprimé.",
    "Dates : connues par ailleurs (histoire du Portugal et du Brésil), aucune page consultée pour ce lot.",
    "Épouses créées dans l'arbre de leur maison puis affichées dans Bragance : Mariana Victoria d'Espagne, Charlotte-Joachime (Carlota Joaquina) (Bourbon d'Espagne), Marie-Léopoldine (Habsbourg-Lorraine), Maria Pia (déjà en base, Savoie), Amélie d'Orléans et sa mère (Bourbon-Orléans), Ferdinand II de Saxe-Cobourg-Kohary (Wettin), Augusta-Victoria de Hohenzollern et son père (Hohenzollern-Sigmaringen), Catherine de Bragance affichée chez les Stuart. Adélaïde de Löwenstein : famille sans arbre, signalée.",
    "Non fait : branche miguéliste après Michel Ier, enfants cadets, suite du Brésil après Pierre II.",
]
g.tree('PT_BRA', 'PRT', 'Maison de Bragance', entry=E('14db1138'))
g.tree('ES_BOU', 'ESP', 'Bourbon', entry=E('7195e6c8'))
g.tree('AT_HL', 'AUT', 'Habsbourg-Lorraine')
g.tree('IT_SAV', 'ITA', 'Maison de Savoie')
g.tree('FR_BOU', 'FRA', 'de Bourbon et Bourbon-Orléans', entry=E('786a379d'))
g.tree('DE_WET', 'DEU', 'Wettin', entry=E('309f20ea'))
g.tree('DE_HZ', 'DEU', 'Hohenzollern-Sigmaringen', entry=E('39895573'))
g.tree('GB_STU', 'GBR', 'Maison Stuart')
P, S = g.par, g.sp
BR = 'Maison de Bragance'
def M(code, name, b, d, title, g_='h', leader=False, approx=None, flag=None):
    return g.m('pb.' + code, name, b, d, title, BR, 'PT_BRA', g_, leader, approx=approx, flag=flag)
def O(code, name, b, d, title, dyn, tree, to=None, g_='f'):
    g.m('pb.' + code, name, b, d, title, dyn, tree, g_, False)
    g.pin('pb.' + code, to or 'PT_BRA')
kids = lambda ps, cs: [P(p, c) for c in cs for p in ps]

M('catherine', 'Catherine de Bragance', 1638, 1705, 'Reine d\'Angleterre, épouse de Charles II', 'f')
g.pin('pb.catherine', 'GB_STU'); S(R('381c7d0d'), 'pb.catherine')
kids([R('f8703b72'), R('e5d50143')], ['pb.catherine'])
M('pedro3', 'Pierre III', 1717, 1786, 'Roi consort du Portugal (1777-1786)', leader=False)
O('mariana', 'Mariana Victoria d\'Espagne', 1718, 1781, 'Reine du Portugal, épouse de Joseph Ier', 'Bourbon d\'Espagne', 'ES_BOU')
M('joao6', 'Jean VI', 1767, 1826, 'Roi du Portugal (1816-1826)', leader=True)
O('carlota', 'Charlotte-Joachime d\'Espagne (Carlota Joaquina)', 1775, 1830, 'Reine du Portugal, épouse de Jean VI', 'Bourbon d\'Espagne', 'ES_BOU')
M('pedro4', 'Pierre IV (Pierre Ier du Brésil)', 1798, 1834, 'Empereur du Brésil (1822-1831), roi du Portugal (1826)', leader=True)
O('leopoldina', 'Marie-Léopoldine d\'Autriche', 1797, 1826, 'Impératrice du Brésil, première épouse de Pierre Ier', 'Habsbourg-Lorraine', 'AT_HL')
M('miguel', 'Michel Ier', 1802, 1866, 'Roi du Portugal (1828-1834), usurpateur', leader=True)
M('adelaide', 'Adélaïde de Löwenstein-Wertheim-Rosenberg', 1831, 1909, 'Épouse de Michel Ier', 'f', flag='Maison de Löwenstein : sans arbre')
M('maria2', 'Marie II', 1819, 1853, 'Reine du Portugal (1826-1853)', 'f', True)
O('fernando2', 'Ferdinand II de Saxe-Cobourg-Kohary', 1816, 1885, 'Roi consort du Portugal', 'Saxe-Cobourg-Kohary', 'DE_WET', g_='h')
M('pedro2br', 'Pierre II du Brésil', 1825, 1891, 'Empereur du Brésil (1831-1889)', leader=True)
M('pedro5', 'Pierre V', 1837, 1861, 'Roi du Portugal (1853-1861)', leader=True)
M('luis1', 'Louis Ier', 1838, 1889, 'Roi du Portugal (1861-1889)', leader=True)
MP = R('b5d7c420'); g.pin(MP, 'PT_BRA')
M('carlos1', 'Charles Ier', 1863, 1908, 'Roi du Portugal (1889-1908), assassiné', leader=True)
O('amelie', 'Amélie d\'Orléans', 1865, 1951, 'Dernière reine du Portugal', 'Bourbon-Orléans', 'FR_BOU')
O('isabelle_o', 'Marie-Isabelle d\'Orléans (comtesse de Paris)', 1848, 1919, 'Mère de la reine Amélie', 'Bourbon-Orléans', 'FR_BOU')
M('luispf', 'Louis-Philippe de Bragance (prince royal)', 1887, 1908, 'Prince royal, assassiné avec son père')
M('manuel2', 'Manuel II', 1889, 1932, 'Dernier roi du Portugal (1908-1910)', leader=True)
O('wilhelm', 'Guillaume de Hohenzollern-Sigmaringen', 1864, 1927, 'Prince de Hohenzollern, père de la reine Augusta-Victoria', 'Hohenzollern-Sigmaringen', 'DE_HZ', g_='h')
O('augusta', 'Augusta-Victoria de Hohenzollern', 1890, 1966, 'Épouse de Manuel II', 'Hohenzollern-Sigmaringen', 'DE_HZ')

JV = R('8cae7bf6'); MA = R('db2f227e'); JI = R('94ace5f9'); MI = R('0d7fee76')
kids([JV, MA], ['pb.pedro3']); S(JV, MA)
S(JI, 'pb.mariana'); P(R('0890d048'), 'pb.mariana'); P(R('2df9c2fd'), 'pb.mariana')
S('pb.pedro3', MI)
kids(['pb.pedro3', MI], ['pb.joao6'])
S('pb.joao6', 'pb.carlota'); P(R('4717536a'), 'pb.carlota'); P(R('a1d8a44a'), 'pb.carlota')
kids(['pb.joao6', 'pb.carlota'], ['pb.pedro4', 'pb.miguel'])
S('pb.pedro4', 'pb.leopoldina'); P(R('02b3e287'), 'pb.leopoldina')
S('pb.pedro4', R('db85428a'))
kids(['pb.pedro4', 'pb.leopoldina'], ['pb.maria2', 'pb.pedro2br'])
S('pb.miguel', 'pb.adelaide')
kids(['pb.miguel', 'pb.adelaide'], [R('cc35611b'), R('3b4a908a')])
S('pb.maria2', 'pb.fernando2'); P(R('c7175bc4'), 'pb.fernando2')
kids(['pb.maria2', 'pb.fernando2'], ['pb.pedro5', 'pb.luis1', R('26f73795'), R('7ad31217')])
S('pb.luis1', MP)
kids(['pb.luis1', MP], ['pb.carlos1'])
P(R('1fcbccbb'), 'pb.amelie'); S(R('1fcbccbb'), 'pb.isabelle_o'); P('pb.isabelle_o', 'pb.amelie')
S('pb.carlos1', 'pb.amelie')
kids(['pb.carlos1', 'pb.amelie'], ['pb.luispf', 'pb.manuel2'])
P(R('ccf2b88a'), 'pb.wilhelm'); P(R('7ad31217'), 'pb.wilhelm')
P('pb.wilhelm', 'pb.augusta')
S('pb.manuel2', 'pb.augusta')
for x in ['pb.pedro4', 'pb.miguel']:
    pass
g.pin(R('db85428a'), 'PT_BRA')
g.reposition = {'PT_BRA'}
g.write()
