import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(66, "Allemagne — petites dynasties : Hohenstaufen (enfants de Barberousse, Conradin, Manfred), Ottoniens, Saliens")
g.notes = [
    "Complète les arbres Hohenstaufen, Ottoniens et Saliens (rien n'est supprimé).",
    "Sources : Wikipédia en anglais (Frédéric Barberousse, Conradin, Henri IV, Otton Ier). Dates non données = vides et signalées.",
    "Bianca Lancia (famille sans arbre) est placée dans l'arbre Hohenstaufen et signalée.",
    "Remarque : Liutgarde (fille d'Otton Ier) est reliée en base à Adélaïde, mais Wikipédia la dit fille d'Édith ; non modifié (suppression d'un lien = à décider par Martin).",
]
g.tree('DE_HST', 'DEU', 'Hohenstaufen', entry=E('19aed0d5'))
g.tree('DE_OTT', 'DEU', 'Ottoniens', entry=E('99d9527e'))
g.tree('DE_SAL', 'DEU', 'Saliens', entry=E('bd5ca9f3'))
P, S = g.par, g.sp

def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)

BAR = [X('4409e2'), X('7d2f8e')]
T = 'DE_HST'
g.m('hs.fred5', 'Frédéric V de Souabe', 1164, 1170, 'Duc de Souabe', 'Hohenstaufen', T, 'h')
g.m('hs.fred6', 'Conrad (Frédéric VI) de Souabe', 1167, 1191, 'Duc de Souabe', 'Hohenstaufen', T, 'h')
g.m('hs.judith', 'Judith de Hohenstaufen', 1168, 1184, '', 'Hohenstaufen', T, 'f')
g.m('hs.otto_bg', 'Otton Ier de Bourgogne', 1170, 1200, 'Comte de Bourgogne', 'Hohenstaufen', T, 'h')
g.m('hs.conrad2', 'Conrad II de Souabe', 1172, 1196, 'Duc de Souabe et de Rothenburg', 'Hohenstaufen', T, 'h')
g.m('hs.agnes', 'Agnès de Hohenstaufen (1179-1184)', 1179, 1184, '', 'Hohenstaufen', T, 'f')
kids(BAR, ['hs.fred5', 'hs.fred6', 'hs.judith', 'hs.otto_bg', 'hs.conrad2', 'hs.agnes'])
g.m('hs.conradin', 'Conradin', 1252, 1268, 'Duc de Souabe, roi de Jérusalem et de Sicile (dernier Hohenstaufen)', 'Hohenstaufen', T, 'h')
kids([X('8bc0cd'), X('1f955b05')], ['hs.conradin'])
g.m('hs.bianca', 'Bianca Lancia', None, None, 'Épouse de Frédéric II', 'Lancia', T, 'f', flag='Famille Lancia : sans arbre', approx='dates non données par la page de Conradin')
g.m('hs.manfred', 'Manfred de Sicile', 1232, 1266, 'Roi de Sicile', 'Hohenstaufen', T, 'h')
S(X('df1215'), 'hs.bianca')
kids([X('df1215'), 'hs.bianca'], ['hs.manfred'])

g.m('ot.liudolf', 'Liudolf de Souabe', 930, 957, 'Duc de Souabe', 'Ottoniens', 'DE_OTT', 'h')
g.m('ot.edith', "Édith d'Angleterre", 910, 946, 'Reine de Germanie', 'Wessex', 'DE_OTT', 'f', flag='Maison de Wessex : sans arbre ici', approx='dates : mariage 930, mort 29 janvier 946 à 35 ans (page Otton Ier)')
g.m('ot.william', 'Guillaume de Mayence', 929, 968, 'Archevêque de Mayence', 'Ottoniens', 'DE_OTT', 'h')
S(X('ff146d'), 'ot.edith')
kids([X('ff146d'), 'ot.edith'], ['ot.liudolf'])
kids([X('ff146d')], ['ot.william'])

g.m('sa.conrad_it', "Conrad II d'Italie", None, None, 'Roi d\'Italie', 'Saliens', 'DE_SAL', 'h', approx='page Henri IV ne donne pas les dates')
kids([X('50dba0'), X('04dd1d')], ['sa.conrad_it'])
g.write()
