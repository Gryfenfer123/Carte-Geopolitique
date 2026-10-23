import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(67, "Allemagne — Luxembourg (ascendance de Henri VI, enfants de Charles IV) et Carolingiens de Germanie (enfants de Louis le Germanique, Zwentibold)")
g.notes = [
    "Complète les arbres Luxembourg et Carolingiens (rien n'est supprimé).",
    "Sources : Wikipédia en anglais (Henri V de Luxembourg, Henri VI, Charles IV, Jean de Görlitz, Louis le Germanique, Zwentibold, Arnulf). Dates non données = vides et signalées.",
    "Marguerite de Bar, Richarde de Mecklembourg : familles sans arbre, placées dans l'arbre Luxembourg et signalées.",
    "Oda de Saxe (épouse de Zwentibold, fille d'Otton Ier de Saxe) est créée dans l'arbre Ottoniens puis reliée.",
]
g.tree('DE_LUX', 'DEU', 'Luxembourg', entry=E('7c6654ff'))
g.tree('DE_CAR', 'DEU', 'Carolingiens', entry=E('fbb1f258'))
g.tree('DE_OTT', 'DEU', 'Ottoniens', entry=E('99d9527e'))
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
T = 'DE_LUX'
g.m('lx.henri5', "Henri V de Luxembourg", 1216, 1281, 'Comte de Luxembourg', 'Luxembourg', T, 'h')
g.m('lx.marg_bar', 'Marguerite de Bar', None, None, 'Comtesse de Luxembourg', 'Bar', T, 'f', flag='Maison de Bar : sans arbre', approx='dates non données par la page de Henri V')
S('lx.henri5', 'lx.marg_bar')
kids(['lx.henri5', 'lx.marg_bar'], [X('22e11696')])
g.m('lx.marg_hu', 'Marguerite de Bohême (reine de Hongrie)', 1335, 1349, 'Reine de Hongrie', 'Luxembourg', T, 'f')
kids([X('233cbc8c'), X('c4b5e199')], ['lx.marg_hu'])
S('lx.marg_hu', 'pl.louis1')
g.m('lx.jean_gor', 'Jean de Görlitz', 1370, 1396, 'Duc de Görlitz', 'Luxembourg', T, 'h')
kids([X('233cbc8c'), X('eaa833a2')], ['lx.jean_gor'])
g.m('lx.richarde', 'Richarde de Mecklembourg', None, 1400, 'Duchesse de Görlitz', 'Mecklembourg', T, 'f', flag='Maison de Mecklembourg : sans arbre', approx='naissance non donnée')
S('lx.jean_gor', 'lx.richarde')
g.m('lx.elis_gor', 'Élisabeth de Görlitz', 1390, 1451, 'Duchesse de Luxembourg', 'Luxembourg', T, 'f')
kids(['lx.jean_gor', 'lx.richarde'], ['lx.elis_gor'])
g.m('lx.marg_nur', 'Marguerite de Bohême (burgravine de Nuremberg)', 1373, 1410, 'Burgravine de Nuremberg', 'Luxembourg', T, 'f')
kids([X('233cbc8c'), X('eaa833a2')], ['lx.marg_nur'])

C = 'DE_CAR'
g.m('ca.hildegard', 'Hildegarde de Germanie', 828, 856, 'Abbesse du Fraumünster', 'Carolingiens', C, 'f')
g.m('ca.bertha', 'Berthe de Germanie', None, 877, 'Abbesse du Fraumünster', 'Carolingiens', C, 'f', approx='naissance non donnée')
g.m('ca.irmgard', 'Irmengarde de Chiemsee', None, 866, 'Abbesse de Chiemsee', 'Carolingiens', C, 'f', approx='naissance non donnée')
kids([X('914f0473'), X('06f449')], ['ca.hildegard', 'ca.bertha', 'ca.irmgard'])
g.m('ca.zwent', 'Zwentibold', 870, 900, 'Roi de Lotharingie', 'Carolingiens', C, 'h', approx='naissance vers 870')
kids([X('f20ba802')], ['ca.zwent'])
g.m('ca.oda_sax', 'Oda de Saxe', None, None, 'Reine de Lotharingie', 'Ottoniens', 'DE_OTT', 'f', approx='dates non données')
kids([X('bf39b729')], ['ca.oda_sax'])
S('ca.zwent', 'ca.oda_sax')
g.write()
