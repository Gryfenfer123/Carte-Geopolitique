import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(40, "Tchéquie — Přemyslides complétés, Jagellon de Bohême, Poděbrady")
g.notes = [
    "Complète l'arbre Přemyslides existant (de Bořivoj Ier à Venceslas III : épouses, frères et fils manquants) ; crée « Jagellon » (Vladislas II, Louis II) et « Poděbrady » sous Tchéquie > Dynastie.",
    "Les Luxembourg (rois de Bohême : Jean l'Aveugle, Charles IV, Venceslas IV, Sigismond) sont DÉJÀ dans l'arbre Luxembourg d'Allemagne : pas de doublon ici (décision du 23/10).",
    "Les Habsbourg de Bohême sont déjà dans l'arbre Habsbourg : pas de doublon non plus.",
    "L'arbre Přemyslides est entièrement remis en page (échelle de dates) : c'est un petit arbre.",
    "Prérequis : v39 exécuté (Dobrawa, Judith de Bohême, Anne de Bohême, Hélène de Znojmo, Élisabeth Richeza, Casimir IV… y sont créées).",
]
g.tree('CZ_PREM', 'CZE', 'Přemyslides', entry='b53dda9c-6240-43c2-8503-91cda7693dd1')
g.tree('PL_PIAST', 'POL', 'Piast')
g.tree('PL_JAG', 'POL', 'Jagellon', entry='2330c043-bc06-4464-92c0-dbc885739729')
g.tree('CZ_JAG', 'CZE', 'Jagellon')
g.tree('CZ_POD', 'CZE', 'Poděbrady')
g.tree('DE_HAB', 'DEU', 'Habsbourg', entry='6b34bc03-d0ad-4c48-a485-f541cecafd5d')
g.tree('DE_HOH', 'DEU', 'Hohenstaufen', entry='19aed0d5-8c4a-4125-b821-8fc6bc357dab')
g.reposition = {'CZ_PREM', 'PL_JAG'}
# erreurs de date constatées dans la base (laissées telles quelles, signalées) : on place la carte à la vraie date
Gen.FIXB = {'1fb35d8e-0c0e-4218-bdfe-02b7e21890a9': 1035, 'a73a4282-9de1-4aca-84e3-7fdf6a5f0f37': 940}

PR = 'Přemyslides'
P, S = g.par, g.sp

# ---------------------------------------------------------- Přemyslides
g.m('cz.ludmila', 'Ludmila de Bohême (sainte)', 860, 921, 'Duchesse de Bohême', 'Pšované (Bohême)', 'CZ_PREM', 'f', flag='Famille des Pšovani (noblesse tchèque ancienne) : sans arbre', approx='naissance « vers 860 »')
g.m('cz.drahomira', 'Drahomíra', None, None, 'Duchesse de Bohême, régente', 'Stodorans (Hévelles)', 'CZ_PREM', 'f', flag='Famille slave des Hévelles : sans arbre ; dates incertaines (vers 877 ou 890 — vers 936)', approx='dates incertaines, non renseignées')
g.m('cz.jaromir', 'Jaromír', 970, 1038, 'Duc de Bohême (1004-1012, 1034-1035)', PR, 'CZ_PREM', 'h', True, approx='naissance « vers 970 »')
g.m('cz.oldrich', 'Oldřich', 975, 1034, 'Duc de Bohême (1012-1034)', PR, 'CZ_PREM', 'h', True, approx='naissance « vers 975 », mort 1034 ou 1042')
g.m('cz.bozena', 'Božena', None, None, 'Épouse d\'Oldřich, mère de Bretislav Ier', 'Noblesse tchèque', 'CZ_PREM', 'f', flag='Origine de Božena incertaine (roturière ?) : sans arbre ; dates inconnues', approx='dates inconnues')
g.m('cz.judith_sch', 'Judith de Schweinfurt', 1003, 1058, 'Duchesse de Bohême', 'Schweinfurt (Bavière)', 'CZ_PREM', 'f', flag='Comtes de Schweinfurt (Bavière) : sans arbre', approx='naissance « avant/vers 1003 »')
g.m('cz.spyti2', 'Spytihněv II', 1031, 1061, 'Duc de Bohême (1055-1061)', PR, 'CZ_PREM', 'h', True)
g.m('cz.adelaide_h', 'Adélaïde de Hongrie (duchesse de Bohême)', None, None, 'Duchesse de Bohême', 'Árpád (Hongrie)', 'CZ_PREM', 'f', flag='Árpád (Hongrie) : arbre à créer avec la Hongrie ; dates non vérifiées', approx='dates non vérifiées')
g.m('cz.bretislav2', 'Bretislav II', 1060, 1100, 'Duc de Bohême (1092-1100)', PR, 'CZ_PREM', 'h', True, approx='naissance « vers 1060 »')
g.m('cz.borivoj2', 'Bořivoj II', 1064, 1124, 'Duc de Bohême (1101-1107, 1117-1120)', PR, 'CZ_PREM', 'h', True, approx='naissance « vers 1064 »')
g.m('cz.vlad1', 'Vladislav Ier', 1065, 1125, 'Duc de Bohême (1109-1117, 1120-1125)', PR, 'CZ_PREM', 'h', True, approx='naissance « vers 1065 »')
g.m('cz.sobeslav1', 'Soběslav Ier', 1075, 1140, 'Duc de Bohême (1125-1140)', PR, 'CZ_PREM', 'h', True, approx='naissance « vers 1075 »')
g.m('cz.richeza_berg', 'Richeza de Berg', None, None, 'Duchesse de Bohême', 'Berg', 'CZ_PREM', 'f', flag='Comtes de Berg (Allemagne) : sans arbre ; dates non renseignées', approx='dates non renseignées')
g.m('cz.sobeslav2', 'Soběslav II', 1128, 1180, 'Duc de Bohême (1173-1178)', PR, 'CZ_PREM', 'h', True)
g.m('cz.vlad2', 'Vladislav II', 1110, 1174, 'Duc (1140-1158), puis premier roi de Bohême (1158-1172)', PR, 'CZ_PREM', 'h', True, approx='naissance « vers 1110 »')
g.m('cz.gertrude', 'Gertrude de Babenberg', None, 1150, 'Duchesse de Bohême', 'Babenberg (Autriche)', 'CZ_PREM', 'f', flag='Babenberg (Autriche) : arbre à créer avec l\'Autriche ; naissance non renseignée', approx='naissance non renseignée')
g.m('cz.judith_thu', 'Judith de Thuringe', 1135, 1210, 'Reine de Bohême', 'Ludowingiens (Thuringe)', 'CZ_PREM', 'f', flag='Ludowingiens (landgraves de Thuringe) : sans arbre', approx='naissance vers 1135 ; mort « vers 1210 » (incertain)')
g.m('cz.frederic', 'Frédéric de Bohême', 1142, 1189, 'Duc de Bohême (1172-1173, 1178-1189)', PR, 'CZ_PREM', 'h', True)
g.m('cz.vlad3', 'Vladislav III Henri', 1160, 1222, 'Duc de Bohême (1197), margrave de Moravie', PR, 'CZ_PREM', 'h', False, approx='naissance « vers 1160 »')
g.m('cz.constance_h', 'Constance de Hongrie', 1180, 1240, 'Reine de Bohême', 'Árpád (Hongrie)', 'CZ_PREM', 'f', flag='Árpád (Hongrie) : arbre à créer avec la Hongrie', approx='naissance « vers 1180 »')
g.m('cz.agnes_prague', 'Agnès de Bohême (sainte)', 1211, 1282, 'Abbesse des Clarisses de Prague, sainte', PR, 'CZ_PREM', 'f')
g.m('cz.kunigunde_hs', 'Cunégonde de Hohenstaufen', 1202, 1248, 'Reine de Bohême', 'Hohenstaufen', 'DE_HOH', 'f', approx='naissance février/mars 1202')
g.m('cz.margaret_bab', 'Marguerite de Babenberg', 1204, 1266, 'Reine des Romains, reine de Bohême', 'Babenberg (Autriche)', 'CZ_PREM', 'f', flag='Babenberg (Autriche) : arbre à créer avec l\'Autriche', approx='mort 1266 (d\'autres sources : 1267) ; naissance vers 1204')
g.m('cz.kunigunda_h', 'Cunégonde de Halicz', 1245, 1285, 'Reine de Bohême', 'Rurikides (Halicz)', 'CZ_PREM', 'f', flag='Rurikides (Halicz/Ukraine) : arbre à créer avec l\'Ukraine', approx='naissance « vers 1245 »')
g.m('cz.judith_hab', 'Judith de Habsbourg', 1271, 1297, 'Reine de Bohême', 'Habsbourg', 'DE_HAB', 'f', approx='mort 1297 (date exacte discordante entre 21 mai et 18 juin)')
g.m('cz.swiet', 'Świętosława de Pologne', 1047, 1126, 'Duchesse de Bohême', 'Piast', 'PL_PIAST', 'f', approx='naissance 1046-1048')

# codes existants (arbre Přemyslides)
BOR1 = X('05931282'); SPY1 = X('648f26d3'); VRA1 = X('88c542ca'); VEN = X('083f6562'); BOL1 = X('4ef7904b')
BOL2 = X('a73a4282'); BOL3 = X('6a885dbe'); BRE1 = X('9925d640'); VRA2 = X('1fb35d8e'); OTT1 = X('86690abf')
VEN1 = X('a8fe33f6'); OTT2 = X('26287556'); VEN2 = X('59b7e461'); VEN3 = X('ff7a1a6f'); ELI = X('760da691')

S(BOR1, 'cz.ludmila'); P(BOR1, SPY1); P('cz.ludmila', SPY1); P(BOR1, VRA1); P('cz.ludmila', VRA1)
S(VRA1, 'cz.drahomira'); P('cz.drahomira', VEN); P('cz.drahomira', BOL1)
P(BOL2, 'cz.jaromir'); P(BOL2, 'cz.oldrich'); P(BOL2, BOL3)      # fils de Boleslas II (Wikipédia)
S('cz.oldrich', 'cz.bozena')
P('cz.oldrich', BRE1); P('cz.bozena', BRE1)
S(BRE1, 'cz.judith_sch')
P(BRE1, 'cz.spyti2'); P('cz.judith_sch', 'cz.spyti2')
P('cz.judith_sch', VRA2)
S(VRA2, 'cz.adelaide_h'); S(VRA2, 'cz.swiet')
P('cz.adelaide_h', 'pl.judith_boh'); P(VRA2, 'pl.judith_boh')
P('pl.casimir1', 'cz.swiet'); P('pl.dobroniega', 'cz.swiet')
P('cz.adelaide_h', 'cz.bretislav2'); P(VRA2, 'cz.bretislav2')
for c in ('cz.borivoj2', 'cz.vlad1', 'cz.sobeslav1'):
    P(VRA2, c); P('cz.swiet', c)
S('cz.vlad1', 'cz.richeza_berg')
P('cz.vlad1', 'cz.vlad2'); P('cz.richeza_berg', 'cz.vlad2')
P('cz.sobeslav1', 'cz.sobeslav2')
S('cz.vlad2', 'cz.gertrude'); S('cz.vlad2', 'cz.judith_thu')
P('cz.vlad2', 'cz.frederic'); P('cz.gertrude', 'cz.frederic')
for c in (OTT1, 'cz.vlad3'):
    P('cz.vlad2', c); P('cz.judith_thu', c)
S(OTT1, 'cz.constance_h')
for c in (VEN1, 'pl.anne_boh', 'cz.agnes_prague'):
    P(OTT1, c); P('cz.constance_h', c)
S(VEN1, 'cz.kunigunde_hs')
P(X('d0a73ff3'), 'cz.kunigunde_hs'); P(X('2318d4a8'), 'cz.kunigunde_hs')   # Philippe de Souabe, Irène Ange
P(VEN1, OTT2); P('cz.kunigunde_hs', OTT2)
S(OTT2, 'cz.margaret_bab'); S(OTT2, 'cz.kunigunda_h')
P(OTT2, VEN2); P('cz.kunigunda_h', VEN2)
S(VEN2, 'cz.judith_hab')
P(X('1320ad14'), 'cz.judith_hab')                                          # Rodolphe Ier de Habsbourg
for c in (VEN3, ELI):
    P(VEN2, c); P('cz.judith_hab', c)
S(VEN2, 'pl.elisabeth_rich')
S('pl.elisabeth_rich', X('703a9fa0'))                                     # Rodolphe III de Habsbourg
# Vratislav II : rattaché au même parent que dans la base (Bretislav Ier) — déjà présent

# ---------------------------------------------------------- Jagellon de Bohême et de Hongrie
JB = 'Jagellon'
g.m('cz.vladislas2', 'Vladislas II Jagellon', 1456, 1516, 'Roi de Bohême (1471-1516) et de Hongrie (1490-1516)', JB, 'CZ_JAG', 'h', True)
g.m('cz.anne_foix', 'Anne de Foix-Candale', None, 1506, 'Reine de Hongrie et de Bohême', 'Foix (France)', 'CZ_JAG', 'f', flag='Maison de Foix (France) : sans arbre ; naissance non vérifiée', approx='naissance non vérifiée')
g.m('cz.louis2', 'Louis II Jagellon', 1506, 1526, 'Roi de Bohême et de Hongrie (1516-1526)', JB, 'CZ_JAG', 'h', True)
g.m('cz.marie_aut', 'Marie d\'Autriche (reine de Hongrie et de Bohême)', 1505, 1558, 'Reine de Hongrie et de Bohême, gouvernante des Pays-Bas', 'Habsbourg', 'DE_HAB', 'f')
P('pl.casimir4', 'cz.vladislas2'); P('pl.elis_aut', 'cz.vladislas2')
S('cz.vladislas2', 'cz.anne_foix')
P('cz.vladislas2', 'cz.louis2'); P('cz.anne_foix', 'cz.louis2')
anneJ = X('f06f9b33')
P('cz.vladislas2', anneJ); P('cz.anne_foix', anneJ)
S('cz.louis2', 'cz.marie_aut')
P(X('b3f4e145'), 'cz.marie_aut'); P(X('c9a60a57'), 'cz.marie_aut')           # Philippe le Beau, Jeanne la Folle

# ---------------------------------------------------------- Poděbrady
PD = 'Poděbrady'
g.m('cz.georges', 'Georges de Poděbrady', 1420, 1471, 'Roi de Bohême (1458-1471)', PD, 'CZ_POD', 'h', True)
g.m('cz.kunhuta', 'Cunégonde de Šternberk', None, 1449, 'Reine de Bohême (épouse de Georges)', 'Šternberk (Bohême)', 'CZ_POD', 'f', flag='Famille Šternberk (noblesse tchèque) : sans arbre ; naissance inconnue', approx='naissance inconnue')
g.m('cz.johana', 'Jeanne de Rožmitál', None, 1475, 'Reine de Bohême', 'Rožmitál (Bohême)', 'CZ_POD', 'f', flag='Famille de Rožmitál (noblesse tchèque) : sans arbre ; dates non vérifiées', approx='dates non vérifiées')
g.m('cz.victorin', 'Victorin de Poděbrady', 1443, 1500, 'Duc de Münsterberg', PD, 'CZ_POD', 'h', False)
g.m('cz.henri_pod', 'Henri l\'Ancien de Poděbrady', 1448, 1498, 'Duc de Münsterberg et d\'Oels', PD, 'CZ_POD', 'h', False)
g.m('cz.catherine_pod', 'Catherine de Poděbrady', 1449, 1464, 'Reine de Hongrie (épouse de Matthias Corvin)', PD, 'CZ_POD', 'f', False)
g.m('cz.sidonie', 'Sidonie de Poděbrady', 1449, 1510, 'Duchesse de Saxe', PD, 'CZ_POD', 'f', False)
S('cz.georges', 'cz.kunhuta'); S('cz.georges', 'cz.johana')
for c in ('cz.victorin', 'cz.henri_pod', 'cz.catherine_pod', 'cz.sidonie'):
    P('cz.georges', c); P('cz.kunhuta', c)
S('cz.sidonie', X('6ae40ca0'))                                           # Albert III le Courageux (Wettin)

if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
