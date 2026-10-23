import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(51, "Chypre — Lusignan")
g.notes = [
    "Crée sous Chypre > Dynastie : Lusignan (Guy de Lusignan -> Jacques III), à partir de Wikipédia anglais. La branche d'origine (Poitou, France) n'est pas créée : l'arbre démarre au premier roi de Chypre.",
    "Dates : la page ne donne presque aucune naissance ; celles saisies viennent de ma connaissance générale et sont toutes marquées « non revérifiées sur la page » dans le rapport.",
    "Épouses/époux sans arbre, signalés : Sibylle et Isabelle de Jérusalem, Alix de Champagne, Hélène Paléologue, Amédée de Montferrat, Charlotte de Bourbon, Helvis de Brunswick-Grubenhagen, Éléonore d'Aragon, Louis de Savoie, Catherine Cornaro.",
    "Hors périmètre ici : la période vénitienne, puis ottomane et britannique.",
    "Prérequis : v50 exécuté.",
]
g.tree('CY_LUS', 'CYP', 'Lusignan')
FB = {'cy.eschiva': 1150, 'cy.isabella_h': 1215, 'cy.henry_ant': 1210, 'cy.guy_c': 1265, 'cy.alice_ib': 1300, 'cy.amadea': 1400,
      'cy.charlotte_b': 1380, 'cy.helvis': 1350, 'cy.eleanor': 1333, 'cy.marietta': 1420, 'cy.janus_w1': 1375}
Gen.FIXB = {uid('member:' + c): y for c, y in FB.items()}
P, S = g.par, g.sp
LU = 'Lusignan'
A = 'dates non revérifiées sur la page'
def M(c, n, b, d, t, s, ld=False, ap=None, dyn=LU, fl=None):
    g.m(c, n, b, d, t, dyn, 'CY_LUS', s, ld, flag=fl, approx=ap)
M('cy.guy', 'Guy de Lusignan', 1150, 1194, 'Roi de Jérusalem, premier seigneur de Chypre (1192-1194)', 'h', True, 'naissance « vers 1150 »')
M('cy.sibylla', 'Sibylle de Jérusalem', None, 1190, 'Reine de Jérusalem', 'f', ap='naissance non renseignée', dyn='Anjou (Jérusalem)', fl='Royaume de Jérusalem (maison d\'Anjou) : sans arbre')
S('cy.guy', 'cy.sibylla')
M('cy.aimery', 'Aimery de Lusignan', 1145, 1205, 'Roi de Chypre (1196-1205) et de Jérusalem', 'h', True, 'naissance « vers 1145 »')
g.fam('cy.guy', 'cy.aimery')
M('cy.eschiva', 'Échive d\'Ibelin', None, None, 'Reine de Chypre', 'f', ap='dates non renseignées', dyn='Ibelin', fl='Maison d\'Ibelin (Outremer) : sans arbre')
M('cy.isabella1', 'Isabelle Ire de Jérusalem', 1172, 1205, 'Reine de Jérusalem, épouse d\'Aimery', 'f', ap=A, dyn='Anjou (Jérusalem)', fl='Royaume de Jérusalem : sans arbre')
S('cy.aimery', 'cy.eschiva'); S('cy.aimery', 'cy.isabella1')
M('cy.hugh1', 'Hugues Ier de Chypre', 1194, 1218, 'Roi de Chypre (1205-1218)', 'h', True, A)
P('cy.aimery', 'cy.hugh1'); P('cy.eschiva', 'cy.hugh1')
M('cy.alice', 'Alix de Champagne', 1195, 1246, 'Reine de Chypre, régente', 'f', ap=A, dyn='Champagne', fl='Maison de Champagne : sans arbre')
S('cy.hugh1', 'cy.alice')
M('cy.henry1', 'Henri Ier de Chypre', 1217, 1253, 'Roi de Chypre (1218-1253)', 'h', True, A)
P('cy.hugh1', 'cy.henry1'); P('cy.alice', 'cy.henry1')
M('cy.hugh2', 'Hugues II de Chypre', 1252, 1267, 'Roi de Chypre (1253-1267), mort à 14 ans', 'h', True, A)
P('cy.henry1', 'cy.hugh2')
M('cy.isabella_h', 'Isabelle de Lusignan (fille d\'Hugues Ier)', None, None, 'Princesse d\'Antioche', 'f', ap='dates non renseignées')
P('cy.hugh1', 'cy.isabella_h'); P('cy.alice', 'cy.isabella_h')
M('cy.henry_ant', 'Henri d\'Antioche', None, None, 'Prince d\'Antioche, père d\'Hugues III', 'h', ap='dates non renseignées', dyn='Poitiers-Antioche', fl='Maison de Poitiers-Antioche : sans arbre')
S('cy.henry_ant', 'cy.isabella_h')
M('cy.hugh3', 'Hugues III de Chypre (d\'Antioche-Lusignan)', 1235, 1284, 'Roi de Chypre (1267-1284), roi de Jérusalem', 'h', True, A)
P('cy.henry_ant', 'cy.hugh3'); P('cy.isabella_h', 'cy.hugh3')
M('cy.john1', 'Jean Ier de Chypre', 1259, 1285, 'Roi de Chypre (1284-1285)', 'h', True, A)
M('cy.henry2', 'Henri II de Chypre', 1270, 1324, 'Roi de Chypre (1285-1324), roi de Jérusalem', 'h', True, A)
M('cy.amalric', 'Amaury de Lusignan (seigneur de Tyr)', 1272, 1310, 'Gouverneur de Chypre (1306-1310)', 'h', False, A)
M('cy.guy_c', 'Guy de Lusignan (connétable de Chypre)', None, 1308, 'Connétable de Chypre', 'h', ap='naissance non renseignée ; mort 1308 non revérifiée')
for c in ('cy.john1', 'cy.henry2', 'cy.amalric', 'cy.guy_c'):
    P('cy.hugh3', c)
M('cy.hugh4', 'Hugues IV de Chypre', 1295, 1359, 'Roi de Chypre (1324-1359)', 'h', True, A)
P('cy.guy_c', 'cy.hugh4')
M('cy.alice_ib', 'Alix d\'Ibelin (épouse d\'Hugues IV)', None, None, 'Reine de Chypre', 'f', ap='dates non renseignées', dyn='Ibelin', fl='Maison d\'Ibelin : sans arbre')
S('cy.hugh4', 'cy.alice_ib')
M('cy.peter1', 'Pierre Ier de Chypre', 1328, 1369, 'Roi de Chypre (1359-1369), assassiné', 'h', True, A)
M('cy.james1', 'Jacques Ier de Chypre', 1334, 1398, 'Roi de Chypre (1382-1398)', 'h', True, A)
for c in ('cy.peter1', 'cy.james1'):
    P('cy.hugh4', c); P('cy.alice_ib', c)
M('cy.eleanor', 'Éléonore d\'Aragon (reine de Chypre)', 1333, 1417, 'Reine de Chypre', 'f', ap=A, dyn='Aragon (Gandie)', fl='Maison d\'Aragon (branche de Gandie) : à relier à l\'arbre de Barcelone si pertinent')
S('cy.peter1', 'cy.eleanor')
M('cy.peter2', 'Pierre II de Chypre', 1354, 1382, 'Roi de Chypre (1369-1382)', 'h', True, A)
P('cy.peter1', 'cy.peter2'); P('cy.eleanor', 'cy.peter2')
M('cy.helvis', 'Helvis de Brunswick-Grubenhagen', None, None, 'Reine de Chypre', 'f', ap='dates non renseignées', dyn='Welf (Brunswick-Grubenhagen)', fl='Maison de Brunswick-Grubenhagen (Welf) : à relier à l\'arbre Welf si pertinent')
S('cy.james1', 'cy.helvis')
M('cy.janus', 'Janus de Chypre', 1375, 1432, 'Roi de Chypre (1398-1432)', 'h', True, A)
P('cy.james1', 'cy.janus'); P('cy.helvis', 'cy.janus')
M('cy.charlotte_b', 'Charlotte de Bourbon (reine de Chypre)', None, 1422, 'Reine de Chypre', 'f', ap='naissance non renseignée', dyn='Bourbon-La Marche', fl='Maison de Bourbon (branche La Marche) : sans arbre')
S('cy.janus', 'cy.charlotte_b')
M('cy.john2', 'Jean II de Chypre', 1418, 1458, 'Roi de Chypre (1432-1458)', 'h', True, A)
P('cy.janus', 'cy.john2'); P('cy.charlotte_b', 'cy.john2')
M('cy.amadea', 'Amadée de Montferrat', None, 1440, 'Reine de Chypre', 'f', ap='naissance non renseignée', dyn='Paléologue de Montferrat', fl='Maison Paléologue de Montferrat : sans arbre')
M('cy.helena', 'Hélène Paléologue (reine de Chypre)', 1428, 1458, 'Reine de Chypre', 'f', ap=A, dyn='Paléologue (Byzance)', fl='Maison Paléologue (Byzance) : arbre à créer avec la Grèce/Turquie')
S('cy.john2', 'cy.amadea'); S('cy.john2', 'cy.helena')
M('cy.charlotte', 'Charlotte de Chypre', 1444, 1487, 'Reine de Chypre (1458-1464), prétendante', 'f', True, A)
P('cy.john2', 'cy.charlotte'); P('cy.helena', 'cy.charlotte')
M('cy.louis_s', 'Louis de Savoie (roi consort de Chypre)', 1436, 1482, 'Comte de Genève, roi consort de Chypre', 'h', ap=A, dyn='Savoie', fl='Maison de Savoie (Italie) : arbre à créer avec l\'Italie')
S('cy.charlotte', 'cy.louis_s')
M('cy.marietta', 'Marietta de Patras', None, None, 'Mère de Jacques II', 'f', ap='dates non renseignées', dyn='Origine : Patras', fl='Origine : Patras (Grèce), sans arbre')
M('cy.james2', 'Jacques II de Chypre (le Bâtard)', 1440, 1473, 'Roi de Chypre (1460-1473)', 'h', True, A)
P('cy.john2', 'cy.james2'); P('cy.marietta', 'cy.james2')
M('cy.cornaro', 'Catherine Cornaro', 1454, 1510, 'Reine de Chypre (1474-1489)', 'f', True, A, dyn='Cornaro (Venise)', fl='Famille Cornaro (Venise) : sans arbre')
S('cy.james2', 'cy.cornaro')
M('cy.james3', 'Jacques III de Chypre', 1473, 1474, 'Roi de Chypre (1473-1474), mort en bas âge', 'h', True, A)
P('cy.james2', 'cy.james3'); P('cy.cornaro', 'cy.james3')
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
