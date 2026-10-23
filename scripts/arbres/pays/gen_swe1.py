import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(72, "Suède — Maison Vasa (Gustave Ier à Christine) et lien avec les Palatins de Deux-Ponts (Charles X à Charles XII, Ulrique-Éléonore)")
g.notes = [
    "Complète l'arbre Vasa (déjà présent pour la Pologne) avec la branche suédoise ; rien n'est supprimé.",
    "Sources : Wikipédia en anglais (Gustave Ier, Éric XIV, Jean III, Charles IX, Gustave-Adolphe, Christine, Charles X, Charles XI, Ulrique-Éléonore, Sigismond III). Dates non données = vides.",
    "Marie de Simmern est créée dans Wittelsbach, Marie-Éléonore de Brandebourg dans Hohenzollern, Christine de Holstein-Gottorp et son père dans Oldenbourg, Ulrique-Éléonore de Danemark dans Oldenbourg : familles qui ont un arbre.",
    "Katarina Stenbock, Margareta Leijonhufvud, Karin Månsdotter, Gunilla Bielke (noblesse suédoise), Catherine de Saxe-Lauenbourg, Christine de Hesse : placées dans l'arbre et signalées.",
    "Les filles de Gustave Ier (mariées en Allemagne) ne sont pas incluses.",
]
g.tree('PL_VASA', 'POL', 'Vasa')
g.tree('SE_PAL', 'SWE', 'Palatinat-Deux-Ponts (Suède)')
g.tree('DE_WIT', 'DEU', 'Wittelsbach')
g.tree('DE_HOH', 'DEU', 'Hohenzollern')
g.tree('DK_OLD', 'DNK', "Maison d'Oldenbourg")
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
T = 'PL_VASA'
def M(code, name, b, d, title, g_, leader=False, approx=None, dyn='Vasa', tree=T, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, approx=None, tree=T):
    return M(code, name, b, d, title, 'f', dyn=house, approx=approx, flag='Maison %s : sans arbre' % house, tree=tree)

M('se.erik_johansson', 'Erik Johansson Vasa', None, 1520, 'Noble suédois, exécuté lors du bain de sang de Stockholm', 'h', approx='naissance non donnée')
W('se.cecilia', 'Cécile Månsdotter Eka', None, None, 'Noble suédoise', 'Eka', approx='dates non données')
S('se.erik_johansson', 'se.cecilia')
M('se.gustav1', 'Gustave Ier Vasa', 1496, 1560, 'Roi de Suède', 'h', True, approx='dates connues par ailleurs, non données par la page')
kids(['se.erik_johansson', 'se.cecilia'], ['se.gustav1'])
W('se.catherine_sl', 'Catherine de Saxe-Lauenbourg', 1513, 1535, 'Reine de Suède', 'Saxe-Lauenbourg')
W('se.margareta', 'Marguerite Leijonhufvud', 1514, 1551, 'Reine de Suède', 'Leijonhufvud')
W('se.katarina_st', 'Catherine Stenbock', 1535, 1621, 'Reine de Suède', 'Stenbock')
S('se.gustav1', 'se.catherine_sl'); S('se.gustav1', 'se.margareta'); S('se.gustav1', 'se.katarina_st')
M('se.erik14', 'Éric XIV', 1533, 1577, 'Roi de Suède', 'h', True)
M('se.magnus', 'Magnus de Suède', 1542, 1595, "Duc d'Östergötland", 'h')
M('se.charles9', 'Charles IX', 1550, 1611, 'Roi de Suède', 'h', True)
P('se.gustav1', 'se.erik14'); P('se.catherine_sl', 'se.erik14')
kids(['se.gustav1', 'se.margareta'], [R('3161e73d'), 'se.magnus', 'se.charles9'])
W('se.karin', 'Karin Månsdotter', 1550, 1612, 'Reine de Suède', 'Månsdotter')
S('se.erik14', 'se.karin')
M('se.gustav_e', 'Gustave Eriksson', 1568, 1607, "Fils d'Éric XIV", 'h')
kids(['se.erik14', 'se.karin'], ['se.gustav_e'])
W('se.gunilla', 'Gunilla Bielke', 1568, 1597, 'Reine de Suède', 'Bielke', approx='mort 1597 (un autre passage de la page donne 1592)')
S(R('3161e73d'), 'se.gunilla')
M('se.john_oster', "Jean, duc d'Östergötland", 1589, 1618, "Duc d'Östergötland", 'h')
kids([R('3161e73d')], ['se.john_oster'])
M('se.anna_vasa', 'Anne Vasa (1568)', 1568, None, 'Princesse de Suède', 'f', approx='mort non donnée')
kids([R('3161e73d'), R('5fbd94f4')], ['se.anna_vasa'])
# Charles IX
M('se.marie_simmern', 'Marie de Palatinat-Simmern', 1561, 1589, 'Duchesse de Södermanland', 'f', dyn='Wittelsbach', tree='DE_WIT')
kids([R('62b68c62'), R('76ae7223')], ['se.marie_simmern'])
S('se.charles9', 'se.marie_simmern')
M('se.adolf_gott', 'Adolphe de Holstein-Gottorp', 1526, 1586, 'Duc de Holstein-Gottorp', 'h', dyn='Oldenbourg (Holstein-Gottorp)', tree='DK_OLD', approx='dates connues par ailleurs')
P(R('7c5d6558'), 'se.adolf_gott')
W('se.christine_hesse', 'Christine de Hesse', 1543, 1604, 'Duchesse de Holstein-Gottorp', 'Hesse', approx='dates connues par ailleurs', tree='DK_OLD')
S('se.adolf_gott', 'se.christine_hesse')
M('se.christina_gott', 'Christine de Holstein-Gottorp (1573-1625)', 1573, 1625, 'Reine de Suède', 'f', dyn='Oldenbourg (Holstein-Gottorp)', tree='DK_OLD')
kids(['se.adolf_gott', 'se.christine_hesse'], ['se.christina_gott'])
S('se.charles9', 'se.christina_gott')
M('se.catherine_pal', 'Catherine de Suède (1584-1638)', 1584, 1638, 'Comtesse palatine de Kleebourg', 'f')
kids(['se.charles9', 'se.marie_simmern'], ['se.catherine_pal'])
S('se.catherine_pal', R('5feee699')); g.pin(R('5feee699'), T)
kids([R('5feee699'), 'se.catherine_pal'], [R('0ff1c7fc')]); g.pin(R('0ff1c7fc'), T)
M('se.gustav2', 'Gustave II Adolphe', 1594, 1632, 'Roi de Suède', 'h', True)
M('se.marie_elis', 'Marie-Élisabeth de Suède', 1596, 1618, 'Duchesse d\'Östergötland', 'f')
M('se.charles_philip', 'Charles-Philippe de Suède', 1601, 1622, 'Duc de Södermanland', 'h')
kids(['se.charles9', 'se.christina_gott'], ['se.gustav2', 'se.marie_elis', 'se.charles_philip'])
S('se.john_oster', 'se.marie_elis')
M('se.marie_eleonora', 'Marie-Éléonore de Brandebourg', 1599, 1655, 'Reine de Suède', 'f', dyn='Hohenzollern', tree='DE_HOH', approx='dates connues par ailleurs, non données par la page')
P(R('67571e4c'), 'se.marie_eleonora')
S('se.gustav2', 'se.marie_eleonora')
M('se.christina', 'Christine de Suède', 1626, 1689, 'Reine de Suède', 'f', True)
kids(['se.gustav2', 'se.marie_eleonora'], ['se.christina'])
# Palatins de Deux-Ponts -> Charles X, XI, XII
W('se.hedwig_eleonora', 'Hedwige-Éléonore de Holstein-Gottorp', 1636, 1715, 'Reine de Suède', 'Holstein-Gottorp', approx='dates connues par ailleurs', tree=T)
S(R('0ff1c7fc'), 'se.hedwig_eleonora')
kids([R('0ff1c7fc'), 'se.hedwig_eleonora'], [R('a09fa1dd')])
M('se.ulrika_dk', 'Ulrique-Éléonore de Danemark', 1656, 1693, 'Reine de Suède', 'f', dyn="Oldenbourg", tree='DK_OLD')
P(R('555a36dc'), 'se.ulrika_dk')
S(R('a09fa1dd'), 'se.ulrika_dk')
kids([R('a09fa1dd'), 'se.ulrika_dk'], [R('841eb365'), R('36ca6e33')])
M('se.hedvig_sophia', 'Hedvige-Sophie de Suède', 1681, 1708, 'Duchesse de Holstein-Gottorp', 'f', dyn='Palatinat-Deux-Ponts', tree='SE_PAL')
kids([R('a09fa1dd'), 'se.ulrika_dk'], ['se.hedvig_sophia'])
for c in [R('a09fa1dd'), R('841eb365'), R('36ca6e33'), R('5feee699')]:
    g.pin(c, T)
g.reposition = {'PL_VASA'}
g.write()
