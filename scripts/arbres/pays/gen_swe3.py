import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(76, "Suède médiévale — Stenkil, Sverker, Erik, Folkung (Bjälbo), Mecklembourg, Poméranie, Bonde")
g.notes = [
    "Nouvel arbre « Rois de Suède (Moyen Âge) » (aucun n'existait pour cette période). Rien n'est supprimé.",
    "Sources : Wikipédia en anglais (Inge l'Ancien, Sverker Ier, Charles VII, Éric IX, Birger Jarl, Magnus Ladulås, Birger, Valdemar, Éric XI, Albert de Mecklembourg, Éric de Poméranie, Charles VIII). Dates non données = vides. Les filiations médiévales sont parfois contestées.",
    "Éric Magnusson, Ingeborg, Magnus VII, Magnus III de Norvège et Mstislav Ier sont affichés ici depuis leurs arbres. Philippa d'Angleterre est créée dans l'arbre Lancastre.",
    "Épouses de familles sans arbre (Danemark ancien, Holstein, Poméranie, noblesse suédoise…) : placées ici et signalées.",
    "Non fait : enfants et petits-enfants secondaires des Bonde ; autres fils de Sverker Ier.",
]
g.tree('SE_MED', 'SWE', 'Rois de Suède (Moyen Âge)', section_title='Rois de Suède (Moyen Âge)')
g.tree('NO_KIN', 'NOR', 'Rois de Norvège')
g.tree('RU_RUR', 'RUS', 'Riourikides')
g.tree('GB_LAN', 'GBR', 'Lancastre', entry=[k for k in ENT if k.startswith('a393c0e9')][0])
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
T = 'SE_MED'
def M(code, name, b, d, title, g_, tree=T, leader=False, approx=None, dyn='Suède', flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, approx=None):
    return M(code, name, b, d, title, 'f', T, dyn=house, approx=approx, flag='Maison %s : sans arbre' % house)

# --- Munsö
M('sm.stenkil', 'Stenkil', None, 1066, 'Roi de Suède', 'h', leader=True, approx='naissance non donnée, mort vers 1066')
W('sm.ingamoder', 'Ingamoder', None, None, 'Reine de Suède', 'Ingamoder', approx='dates non données')
S('sm.stenkil', 'sm.ingamoder')
M('sm.inge1', 'Inge l\'Ancien', 1040, 1105, 'Roi de Suède', 'h', leader=True, approx='naissance vers 1040, mort entre 1105 et 1110')
kids(['sm.stenkil', 'sm.ingamoder'], ['sm.inge1'])
W('sm.helena', 'Hélène', None, None, 'Reine de Suède, épouse d\'Inge', 'Helena', approx='dates non données')
S('sm.inge1', 'sm.helena')
M('sm.christina_i', 'Christine Ingesdotter', None, None, 'Princesse de Suède, épouse de Mstislav Ier', 'f', approx='dates non données')
M('sm.ragnvald', 'Ragnvald Ingesson', None, None, 'Fils d\'Inge', 'h', approx='dates non données')
M('sm.margaret_i', 'Marguerite Ingesdotter', None, None, 'Princesse de Suède, épouse de Magnus III de Norvège', 'f', approx='dates non données')
M('sm.katarina_i', 'Catherine Ingesdotter', None, None, 'Princesse de Suède', 'f', approx='dates non données')
kids(['sm.inge1', 'sm.helena'], ['sm.christina_i', 'sm.ragnvald', 'sm.margaret_i', 'sm.katarina_i'])
S(R('19820453'), 'sm.christina_i'); g.pin(R('19820453'), T)
S('no.magnus3', 'sm.margaret_i'); g.pin('no.magnus3', T)

# --- Sverker
M('sm.sverker1', 'Sverker Ier', 1100, 1156, 'Roi de Suède', 'h', leader=True, approx='naissance vers 1100')
W('sm.ulvhild', 'Ulvhild Håkansdotter', None, None, 'Reine de Suède', 'Håkan', approx='dates non données')
W('sm.richeza', 'Richeza', None, None, 'Reine de Suède', 'Richeza', approx='dates non données, origine non précisée')
S('sm.sverker1', 'sm.ulvhild'); S('sm.sverker1', 'sm.richeza')
M('sm.karl7', 'Charles VII (Karl Sverkersson)', 1130, 1167, 'Roi de Suède', 'h', leader=True, approx='naissance vers 1130')
M('sm.johan_s', 'Johan Sverkersson', None, None, 'Fils de Sverker Ier', 'h', approx='dates non données')
M('sm.ingegard', 'Ingegärd Sverkersdotter', None, None, 'Fille de Sverker Ier', 'f', approx='dates non données')
M('sm.helena_s', 'Hélène Sverkersdotter', None, None, 'Fille de Sverker Ier', 'f', approx='dates non données')
M('sm.boleslaw', 'Boleslaw Sverkersson', None, None, 'Fils de Sverker Ier', 'h', approx='dates non données')
kids(['sm.sverker1', 'sm.ulvhild'], ['sm.karl7', 'sm.johan_s', 'sm.ingegard', 'sm.helena_s', 'sm.boleslaw'])
W('sm.christina_h', 'Christine Hvide', None, None, 'Reine de Suède', 'Hvide', approx='dates non données')
S('sm.karl7', 'sm.christina_h')
M('sm.sverker2', 'Sverker II', None, None, 'Roi de Suède (1195-1208)', 'h', leader=True, approx='règne 1195-1208 ; naissance et mort non données')
kids(['sm.karl7', 'sm.christina_h'], ['sm.sverker2'])

# --- Erik
M('sm.erik9', 'Éric IX le Saint', None, 1160, 'Roi de Suède', 'h', leader=True, approx='naissance vers 1120-1125')
W('sm.christina_b', 'Christine Björnsdotter', None, None, 'Reine de Suède', 'Björn', approx='dates non données')
S('sm.erik9', 'sm.christina_b')
M('sm.knut1', 'Knut Ier Eriksson', None, 1196, 'Roi de Suède', 'h', leader=True, approx='règne dès 1167 ; naissance non donnée')
M('sm.filip_e', 'Filip Eriksson', None, None, 'Fils d\'Éric IX', 'h', approx='dates non données')
M('sm.katarina_e', 'Catherine Eriksdotter', None, None, 'Fille d\'Éric IX', 'f', approx='dates non données')
M('sm.margaret_e', 'Marguerite Eriksdotter', None, None, 'Fille d\'Éric IX, épouse de Sverre', 'f', approx='dates non données')
kids(['sm.erik9', 'sm.christina_b'], ['sm.knut1', 'sm.filip_e', 'sm.katarina_e', 'sm.margaret_e'])
S('no.sverre', 'sm.margaret_e'); g.pin('no.sverre', T)
M('sm.erik10', 'Éric X Knutsson', 1180, 1216, 'Roi de Suède', 'h', leader=True, approx='naissance vers 1180, dates connues par ailleurs')
P('sm.knut1', 'sm.erik10')
M('sm.erik11', 'Éric XI Eriksson', 1216, 1250, 'Roi de Suède', 'h', leader=True)
M('sm.ingeborg_e', 'Ingeborg Eriksdotter', None, 1254, 'Épouse de Birger Jarl', 'f', approx='naissance non donnée')
kids(['sm.erik10'], ['sm.erik11', 'sm.ingeborg_e'])
W('sm.catherine_s', 'Catherine Sunesdotter', None, None, 'Reine de Suède', 'Sune', approx='dates non données')
S('sm.erik11', 'sm.catherine_s')

# --- Folkung
M('sm.magnus_m', 'Magnus Minniskiöld', None, None, 'Noble de Bjälbo', 'h', dyn='Folkung', approx='dates non données')
W('sm.ingrid_ylva', 'Ingrid Ylva', None, None, 'Mère de Birger Jarl', 'Ylva', approx='dates non données')
S('sm.magnus_m', 'sm.ingrid_ylva')
M('sm.birger_jarl', 'Birger Jarl', 1210, 1266, 'Jarl, régent de Suède', 'h', dyn='Folkung', approx='naissance vers 1210')
kids(['sm.magnus_m', 'sm.ingrid_ylva'], ['sm.birger_jarl'])
S('sm.birger_jarl', 'sm.ingeborg_e')
W('sm.mechtilde', 'Mechtilde de Holstein', None, None, 'Seconde épouse de Birger Jarl', 'Holstein', approx='dates non données')
S('sm.birger_jarl', 'sm.mechtilde')
M('sm.rikissa_b', 'Rikissa Birgersdotter', 1238, None, 'Fille de Birger Jarl', 'f', dyn='Folkung')
M('sm.valdemar', 'Valdemar Birgersson', 1239, 1302, 'Roi de Suède', 'h', leader=True, dyn='Folkung', approx='naissance vers 1238-1239')
M('sm.magnus_l', 'Magnus Ladulås', 1240, 1290, 'Roi de Suède', 'h', leader=True, dyn='Folkung', approx='naissance vers 1240')
M('sm.catharina_b', 'Catherine Birgersdotter', 1245, None, 'Fille de Birger Jarl', 'f', dyn='Folkung')
M('sm.erik_b', 'Éric Birgersson', 1250, None, 'Fils de Birger Jarl', 'h', dyn='Folkung')
M('sm.ingeborg_b', 'Ingeborg Birgersdotter', 1254, 1302, 'Fille de Birger Jarl', 'f', dyn='Folkung', approx='naissance vers 1254')
M('sm.bengt_b', 'Bengt Birgersson', 1254, None, 'Fils de Birger Jarl', 'h', dyn='Folkung')
kids(['sm.birger_jarl', 'sm.ingeborg_e'], ['sm.rikissa_b', 'sm.valdemar', 'sm.magnus_l', 'sm.catharina_b', 'sm.erik_b', 'sm.ingeborg_b', 'sm.bengt_b'])
W('sm.sophia_dk', 'Sophie de Danemark', None, None, 'Reine de Suède, épouse de Valdemar', 'Estridsen', approx='dates non données')
S('sm.valdemar', 'sm.sophia_dk')
for c, n, b, d, gg in [('ing', 'Ingeborg Valdemarsdotter', 1263, 1292, 'f'), ('erik', 'Éric Valdemarsson', 1272, 1330, 'h'),
                       ('marina', 'Marina Valdemarsdotter', None, None, 'f'), ('richeza', 'Richeza Valdemarsdotter', None, None, 'f'),
                       ('kat', 'Catherine Valdemarsdotter', None, None, 'f'), ('mar', 'Marguerite Valdemarsdotter', None, None, 'f')]:
    M('sm.v_' + c, n, b, d, 'Enfant de Valdemar', gg, dyn='Folkung')
    kids(['sm.valdemar', 'sm.sophia_dk'], ['sm.v_' + c])
W('sm.helvig', 'Helvig de Holstein', None, None, 'Reine de Suède', 'Holstein', approx='dates non données')
S('sm.magnus_l', 'sm.helvig')
M('sm.ingeborg_m', 'Ingeborg Magnusdotter', 1277, 1319, 'Fille de Magnus Ladulås', 'f', dyn='Folkung')
M('sm.birger', 'Birger Magnusson', 1280, 1321, 'Roi de Suède', 'h', leader=True, dyn='Folkung')
M('sm.valdemar_m', 'Valdemar Magnusson', 1282, 1318, 'Duc de Finlande', 'h', dyn='Folkung', approx='naissance après 1282')
M('sm.rikissa_m', 'Rikissa Magnusdotter', 1285, 1347, 'Fille de Magnus Ladulås', 'f', dyn='Folkung', approx='naissance vers 1285, mort après 1347')
kids(['sm.magnus_l', 'sm.helvig'], ['sm.ingeborg_m', 'sm.birger', 'sm.valdemar_m', 'sm.rikissa_m', 'no.eric_magnusson'])
g.pin('no.eric_magnusson', T)
W('sm.marta', 'Märta de Danemark', None, None, 'Reine de Suède, épouse de Birger', 'Estridsen', approx='mariage 1298 ; dates non données')
S('sm.birger', 'sm.marta')
for c, n, b, d, gg in [('mag', 'Magnus Birgersson', 1300, 1320, 'h'), ('erik', 'Éric, fils du roi Birger', None, 1319, 'h'),
                       ('agnes', 'Agnès Birgersdotter', None, None, 'f'), ('kat', 'Catherine, fille du roi Birger', None, None, 'f')]:
    M('sm.b_' + c, n, b, d, 'Enfant de Birger', gg, dyn='Folkung')
    kids(['sm.birger', 'sm.marta'], ['sm.b_' + c])

# --- Eric Magnusson -> Mecklembourg
g.pin('no.ingeborg_h', T); S('no.eric_magnusson', 'no.ingeborg_h'); g.pin('no.magnus7', T)
M('sm.euphemia', 'Euphémie de Suède', None, None, 'Duchesse de Mecklembourg', 'f', dyn='Folkung', approx='dates non données')
kids(['no.eric_magnusson', 'no.ingeborg_h'], ['sm.euphemia'])
M('sm.albert2m', 'Albert II de Mecklembourg', 1318, 1379, 'Duc de Mecklembourg', 'h', dyn='Mecklembourg', approx='dates connues par ailleurs')
S('sm.albert2m', 'sm.euphemia')
M('sm.albert_m', 'Albert de Mecklembourg', 1338, 1412, 'Roi de Suède (1364-1389)', 'h', leader=True, dyn='Mecklembourg', approx='naissance vers 1338')
kids(['sm.albert2m', 'sm.euphemia'], ['sm.albert_m'])
W('sm.richardis', 'Richardis de Schwerin', None, 1377, 'Reine de Suède', 'Schwerin', approx='naissance non donnée')
W('sm.agnes_b', 'Agnès de Brunswick-Lunebourg', None, 1432, 'Reine de Suède', 'Brunswick-Lunebourg', approx='mort entre 1430 et 1434')
S('sm.albert_m', 'sm.richardis'); S('sm.albert_m', 'sm.agnes_b')
M('sm.erik_m', 'Éric de Mecklembourg', None, 1397, 'Prince de Suède', 'h', dyn='Mecklembourg')
M('sm.richardis_k', 'Richardis Catherine de Mecklembourg', None, 1400, 'Princesse', 'f', dyn='Mecklembourg')
M('sm.albert5', 'Albert V de Mecklembourg', None, 1423, 'Duc de Mecklembourg', 'h', dyn='Mecklembourg')
kids(['sm.albert_m'], ['sm.erik_m', 'sm.richardis_k', 'sm.albert5'])
P('sm.richardis', 'sm.erik_m')

# --- Poméranie
M('sm.wartislaw7', 'Wartislaw VII de Poméranie', None, None, 'Duc de Poméranie', 'h', dyn='Poméranie', approx='dates non données', flag='Maison de Poméranie : sans arbre')
W('sm.maria_m', 'Marie de Mecklembourg-Schwerin', None, None, 'Duchesse de Poméranie', 'Mecklembourg-Schwerin', approx='dates non données')
S('sm.wartislaw7', 'sm.maria_m')
M('sm.erik_p', 'Éric de Poméranie', 1382, 1459, 'Roi de Danemark, de Norvège et de Suède', 'h', leader=True, dyn='Poméranie', approx='naissance 1381 ou 1382')
kids(['sm.wartislaw7', 'sm.maria_m'], ['sm.erik_p'])
g.pin('no.margaret1', T)
g.fam('no.margaret1', 'sm.erik_p')
M('sm.philippa', 'Philippe d\'Angleterre', 1394, 1430, 'Reine de Danemark, de Norvège et de Suède', 'f', 'GB_LAN', dyn='Lancastre', approx='naissance 1394 connue par ailleurs')
P(R('5353d1e7'), 'sm.philippa'); P(R('36732847'), 'sm.philippa')
S('sm.erik_p', 'sm.philippa'); g.pin('sm.philippa', T)

# --- Bonde
M('sm.karl8', 'Charles VIII Knutsson Bonde', 1408, 1470, 'Roi de Suède et de Norvège', 'h', leader=True, dyn='Bonde', approx='naissance vers 1408')
for c, n, d in [('birg', 'Birgitta Turesdotter', 1436), ('cath', 'Catherine Gumsehuvud', 1450), ('chr', 'Christine Abrahamsdotter', None)]:
    W('sm.' + c, n, None, d, 'Reine de Suède', n.split()[-1].replace('dotter', ''), approx='naissance non donnée')
    S('sm.karl8', 'sm.' + c)
for c, n, b, d, gg in [('ture', 'Ture Karlsson', None, None, 'h'), ('chr', 'Christine Karlsdotter', None, None, 'f'),
                       ('mar', 'Marguerite Karlsdotter', 1442, 1462, 'f'), ('mad', 'Madeleine Karlsdotter', 1445, 1495, 'f'),
                       ('ric', 'Richeza Karlsdotter', None, None, 'f'), ('bri', 'Brigitte Karlsdotter', None, None, 'f'),
                       ('ann', 'Anne Karlsdotter', None, None, 'f'), ('karl', 'Karl Karlsson', 1465, 1488, 'h')]:
    M('sm.k_' + c, n, b, d, 'Enfant de Charles VIII', gg, dyn='Bonde')
    kids(['sm.karl8'], ['sm.k_' + c])

g.reposition = {'SE_MED'}
g.write()
