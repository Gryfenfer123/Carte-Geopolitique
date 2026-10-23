import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(94, "Italie — Hauteville : Normands d'Italie du Sud, comtes puis rois de Sicile, et princes d'Antioche")
g.notes = [
    "Nouvel arbre « Hauteville » (aucun n'existait). Constance de Hauteville (arbre Hohenstaufen) y est affichée. Rien n'est supprimé.",
    "Dates : connues par ailleurs (histoire de la Sicile), aucune page consultée pour ce lot ; les dates anciennes sont approximatives (notées).",
    "Jeanne d'Angleterre est créée dans l'arbre Plantagenêts. Autres épouses de familles sans arbre (Salerne, Buonalbergo, Aleramici, Bourgogne, Navarre…) : signalées.",
    "Non fait : les nombreux frères et enfants cadets, Tancrède de Galilée, ducs de Pouille au-delà de Roger Borsa.",
]
g.tree('IT_HAU', 'ITA', 'Hauteville', section_title='Hauteville')
g.tree('GB_PLA', 'GBR', 'Les Plantagenêts', entry=E('177fd0be'))
g.tree('DE_HST', 'DEU', 'Hohenstaufen', entry=E('19aed0d5'))
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
T = 'IT_HAU'
def M(code, name, b, d, title, g_, tree=T, leader=False, approx=None, dyn='Hauteville', flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, g_='f', approx=None):
    return M(code, name, b, d, title, g_, T, False, approx, house, 'Maison %s : sans arbre' % house)
M('ha.tancred', 'Tancrède de Hauteville', 980, 1041, 'Seigneur normand, père des Hauteville d\'Italie', 'h', approx='naissance vers 980')
for c, n, b, d, t in [('wia', 'Guillaume Bras-de-Fer', 1010, 1046, "Premier comte d'Apulie"), ('drogo', 'Drogon de Hauteville', 1010, 1051, "Comte d'Apulie"),
                      ('humphrey', 'Onfroi de Hauteville', 1010, 1057, "Comte d'Apulie"), ('guiscard', 'Robert Guiscard', 1015, 1085, 'Duc de Pouille et de Calabre'),
                      ('roger1', 'Roger Ier de Sicile', 1031, 1101, 'Grand comte de Sicile')]:
    M('ha.' + c, n, b, d, t, 'h', leader=(c in ('guiscard', 'roger1')), approx='naissance vers %d' % b)
    P('ha.tancred', 'ha.' + c)
W('ha.alberada', 'Alberade de Buonalbergo', None, None, 'Première épouse de Robert Guiscard', 'Buonalbergo', approx='dates non données')
W('ha.sichelgaita', 'Sikelgaïta de Salerne', 1040, 1090, 'Seconde épouse de Robert Guiscard', 'Salerne (Lombards)', approx='naissance vers 1040')
S('ha.guiscard', 'ha.alberada'); S('ha.guiscard', 'ha.sichelgaita')
M('ha.bohemond1', 'Bohémond Ier de Tarente', 1058, 1111, "Prince d'Antioche, chef de la 1re croisade", 'h', leader=True, approx='naissance vers 1058')
M('ha.borsa', 'Roger Borsa', 1060, 1111, 'Duc de Pouille', 'h', leader=True, approx='naissance vers 1060')
P('ha.guiscard', 'ha.bohemond1'); P('ha.alberada', 'ha.bohemond1')
P('ha.guiscard', 'ha.borsa'); P('ha.sichelgaita', 'ha.borsa')
M('ha.bohemond2', 'Bohémond II d\'Antioche', 1108, 1130, "Prince d'Antioche", 'h', leader=True)
P('ha.bohemond1', 'ha.bohemond2')
W('ha.adelaide', 'Adélaïde del Vasto', 1075, 1118, 'Comtesse de Sicile, reine de Jérusalem', 'Aleramici', approx='naissance vers 1075')
S('ha.roger1', 'ha.adelaide')
M('ha.roger2', 'Roger II de Sicile', 1095, 1154, 'Premier roi de Sicile', 'h', leader=True)
kids(['ha.roger1', 'ha.adelaide'], ['ha.roger2'])
W('ha.elvira', 'Elvire de Castille', 1100, 1135, 'Reine de Sicile', 'Castille-León', approx='naissance vers 1100')
S('ha.roger2', 'ha.elvira')
M('ha.william1', 'Guillaume Ier le Mauvais', 1131, 1166, 'Roi de Sicile', 'h', leader=True)
M('ha.roger_apulia', 'Roger, duc de Pouille', 1118, 1148, 'Fils de Roger II', 'h')
kids(['ha.roger2', 'ha.elvira'], ['ha.william1', 'ha.roger_apulia'])
M('ha.tancred_l', 'Tancrède de Lecce', 1138, 1194, 'Roi de Sicile', 'h', leader=True, approx='naissance vers 1138 ; fils naturel de Roger de Pouille')
P('ha.roger_apulia', 'ha.tancred_l')
W('ha.margaret_nav', 'Marguerite de Navarre', 1128, 1183, 'Reine de Sicile, régente', 'Navarre', approx='naissance vers 1128')
S('ha.william1', 'ha.margaret_nav')
M('ha.william2', 'Guillaume II le Bon', 1153, 1189, 'Roi de Sicile', 'h', leader=True)
kids(['ha.william1', 'ha.margaret_nav'], ['ha.william2'])
M('pl.joan_eng', "Jeanne d'Angleterre (1165-1199)", 1165, 1199, 'Reine de Sicile, comtesse de Toulouse', 'f', 'GB_PLA', dyn='Plantagenêts')
kids([R('4433a65f'), R('ba3d69dd')], ['pl.joan_eng'])
S('ha.william2', 'pl.joan_eng'); g.pin('pl.joan_eng', T)
W('ha.sibylla', 'Sibylle d\'Acerra', None, None, 'Reine de Sicile, épouse de Tancrède', 'Acerra', approx='dates non données')
S('ha.tancred_l', 'ha.sibylla')
M('ha.william3', 'Guillaume III de Sicile', 1185, 1198, 'Roi de Sicile (1194)', 'h', leader=True, approx='naissance vers 1185')
kids(['ha.tancred_l', 'ha.sibylla'], ['ha.william3'])
W('ha.beatrice_rethel', 'Béatrice de Rethel', 1130, 1185, 'Reine de Sicile, 3e épouse de Roger II', 'Rethel', approx='naissance vers 1130')
S('ha.roger2', 'ha.beatrice_rethel')
CON = R('5bb15ac8')
kids(['ha.roger2', 'ha.beatrice_rethel'], [CON]); g.pin(CON, T)
g.reposition = {'IT_HAU'}
g.write()
