import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(96, "Lituanie — Gediminides : de Gediminas à Vytautas et Švitrigaila, jusqu'à Jogaila")
g.notes = [
    "Nouvel arbre « Gediminides » (aucun n'existait). Jogaila (Ladislas II Jagellon), Casimir IV et Sophie de Lituanie (fille de Vytautas, arbre Riourikides) y sont affichés. Rien n'est supprimé.",
    "Dates : connues par ailleurs (histoire de Lituanie), aucune page consultée pour ce lot ; les dates médiévales sont approximatives (notées).",
    "Oulyana de Tver et Birutė viennent de familles sans arbre : placées ici et signalées.",
    "Non fait : Mindaugas (lien avec Gediminas non établi), fils cadets de Gediminas, épouses de Vytautas, descendance de Švitrigaila et de Skirgaila.",
]
g.tree('LT_GED', 'LTU', 'Gediminides', section_title='Gediminides')
P, S = g.par, g.sp
T = 'LT_GED'
def M(code, name, b, d, title, g_='h', leader=True, approx=None, dyn='Gediminides', flag=None):
    return g.m(code, name, b, d, title, dyn, T, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, approx=None):
    return M(code, name, b, d, title, 'f', False, approx, house, 'Maison %s : sans arbre' % house)
M('lt.gediminas', 'Gediminas', 1275, 1341, 'Grand-duc de Lituanie', approx='naissance vers 1275')
M('lt.algirdas', 'Algirdas', 1296, 1377, 'Grand-duc de Lituanie', approx='naissance vers 1296')
M('lt.kestutis', 'Kęstutis', 1297, 1382, 'Grand-duc de Lituanie', approx='naissance vers 1297')
for c in ('algirdas', 'kestutis'):
    P('lt.gediminas', 'lt.' + c)
W('lt.uliana', 'Oulyana de Tver', 1325, 1392, "Seconde épouse d'Algirdas, mère de Jogaila", 'Tver', 'naissance vers 1325')
S('lt.algirdas', 'lt.uliana')
JOG = R('f0684304'); kids = [JOG]
P('lt.algirdas', JOG); P('lt.uliana', JOG); g.pin(JOG, T)
M('lt.skirgaila', 'Skirgaila', 1354, 1397, 'Régent de Lituanie', leader=False, approx='naissance vers 1354')
M('lt.svitrigaila', 'Švitrigaila', 1370, 1452, 'Grand-duc de Lituanie', approx='naissance vers 1370 ; écart de 74 ans avec Algirdas (naissance vers 1296 contestée) : à relire')
for c in ('lt.skirgaila', 'lt.svitrigaila'):
    P('lt.algirdas', c)
W('lt.biruta', 'Birutė', None, None, 'Épouse de Kęstutis, mère de Vytautas', 'Palanga', 'dates non données')
S('lt.kestutis', 'lt.biruta')
M('lt.vytautas', 'Vytautas le Grand', 1350, 1430, 'Grand-duc de Lituanie', approx='naissance vers 1350')
M('lt.zygimantas', 'Žygimantas Kęstutaitis', 1365, 1440, 'Grand-duc de Lituanie', approx='naissance vers 1365')
for c in ('lt.vytautas', 'lt.zygimantas'):
    P('lt.kestutis', c); P('lt.biruta', c)
SOF = R('ba967f1a'); P('lt.vytautas', SOF); g.pin(SOF, T)
CAS = R('a32377f3'); g.pin(CAS, T)
g.reposition = {'LT_GED'}
g.write()
