import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(50, "Albanie — Kastrioti, Wied, Zogu")
g.notes = [
    "Crée sous Albanie > Dynastie : Kastrioti (Gjon Kastrioti -> Gjon II), Wied (Guillaume de Wied, prince d'Albanie en 1914) et Zogu (Zog Ier -> Leka II).",
    "Jerina Branković (épouse de Gjon II Kastrioti) est créée dans l'arbre Branković.",
    "Naissance de Géraldine Apponyi (1915) et de Leka II (1982) : non données par les pages Wikipédia consultées, ajoutées de mémoire et marquées « à vérifier ».",
    "Prérequis : v49 exécuté.",
]
g.tree('AL_KAS', 'ALB', 'Kastrioti')
g.tree('AL_WIE', 'ALB', 'Wied')
g.tree('AL_ZOG', 'ALB', 'Zogu')
g.tree('SR_BRA', 'SRB', 'Branković')
g.reposition = {'SR_BRA'}
FB = {'al.voisava': 1385, 'al.donika': 1430, 'sr.jerina': 1442, 'al.gjon_k': 1380, 'al.xhemal': 1860, 'al.sadije': 1870,
      'al.susan': 1945, 'al.marie_n': 1841}
Gen.FIXB = {uid('member:' + c): y for c, y in FB.items()}
P, S = g.par, g.sp
KS, WI, ZO = 'Kastrioti', 'Wied', 'Zogu'
g.m('al.gjon_k', 'Gjon Kastrioti', None, 1437, 'Seigneur de Mat, père de Skanderbeg', KS, 'AL_KAS', 'h', approx='naissance non renseignée')
g.m('al.voisava', 'Voisava', None, None, 'Mère de Skanderbeg', 'Origine discutée (Polog slave ou Muzaka)', 'AL_KAS', 'f', flag='Origine discutée (Polog ou famille Muzaka) : sans arbre ; dates non renseignées', approx='dates non renseignées')
S('al.gjon_k', 'al.voisava')
g.m('al.skanderbeg', 'Skanderbeg (Gjergj Kastrioti)', 1405, 1468, 'Prince des Albanais, héros national', KS, 'AL_KAS', 'h', True, approx='naissance « vers 1405 »')
P('al.gjon_k', 'al.skanderbeg'); P('al.voisava', 'al.skanderbeg')
g.m('al.donika', 'Donika Arianiti', None, None, 'Épouse de Skanderbeg', 'Arianiti (Albanie)', 'AL_KAS', 'f', flag='Famille Arianiti (Albanie) : arbre non créé ; dates non renseignées', approx='dates non renseignées ; prénom variable (Andronika)')
S('al.skanderbeg', 'al.donika')
g.m('al.gjon2', 'Gjon II Kastrioti', 1456, 1514, 'Duc de San Pietro in Galatina', KS, 'AL_KAS', 'h', approx='mort 1514 (non donnée par la page sur Skanderbeg, non revérifiée)')
P('al.skanderbeg', 'al.gjon2'); P('al.donika', 'al.gjon2')
g.m('sr.jerina', 'Jerina Branković (épouse de Gjon II Kastrioti)', None, None, 'Princesse, duchesse de Galatina', 'Branković', 'SR_BRA', 'f', approx='dates non renseignées')
P('sr.djurad', 'sr.jerina'); P('sr.irene_k', 'sr.jerina')
S('al.gjon2', 'sr.jerina')
# Wied
g.m('al.wied_p', 'Guillaume de Wied (5e prince de Wied)', 1845, 1907, 'Prince de Wied', WI, 'AL_WIE', 'h', approx='dates 1845-1907 (non revérifiées)')
g.m('al.marie_n', 'Marie des Pays-Bas (princesse de Wied)', 1841, 1910, 'Princesse de Wied', 'Orange-Nassau (Pays-Bas)', 'AL_WIE', 'f', flag='Maison d\'Orange-Nassau (Pays-Bas) : arbre à créer avec les Pays-Bas', approx='dates 1841-1910 (non revérifiées)')
S('al.wied_p', 'al.marie_n')
g.m('al.wilhelm', 'Guillaume de Wied (prince d\'Albanie)', 1876, 1945, 'Prince d\'Albanie (1914)', WI, 'AL_WIE', 'h', True)
P('al.wied_p', 'al.wilhelm'); P('al.marie_n', 'al.wilhelm')
g.m('al.sophie', 'Sophie de Schönburg-Waldenburg', 1885, 1936, 'Princesse d\'Albanie', 'Schönburg-Waldenburg', 'AL_WIE', 'f', flag='Maison de Schönburg-Waldenburg : sans arbre')
S('al.wilhelm', 'al.sophie')
g.m('al.marie_e', 'Marie-Éléonore de Wied', 1909, 1956, 'Princesse', WI, 'AL_WIE', 'f')
g.m('al.carol_v', 'Charles-Victor de Wied', 1913, 1973, 'Prince héréditaire', WI, 'AL_WIE', 'h')
for c in ('al.marie_e', 'al.carol_v'):
    P('al.wilhelm', c); P('al.sophie', c)
# Zogu
g.m('al.xhemal', 'Xhemal Pacha Zogolli', None, 1911, 'Père de Zog Ier', ZO, 'AL_ZOG', 'h', approx='naissance non renseignée ; mort 1911 (non revérifiée)')
g.m('al.sadije', 'Sadije Toptani', None, None, 'Mère de Zog Ier', 'Toptani (Albanie)', 'AL_ZOG', 'f', flag='Famille Toptani (Albanie) : sans arbre ; dates non renseignées', approx='dates non renseignées')
S('al.xhemal', 'al.sadije')
g.m('al.zog', 'Zog Ier d\'Albanie', 1895, 1961, 'Président (1925), puis roi des Albanais (1928-1939)', ZO, 'AL_ZOG', 'h', True)
P('al.xhemal', 'al.zog'); P('al.sadije', 'al.zog')
g.m('al.geraldine', 'Géraldine Apponyi de Nagyappony', 1915, 2002, 'Reine des Albanais', 'Apponyi (Hongrie)', 'AL_ZOG', 'f', flag='Famille Apponyi (noblesse hongroise) : sans arbre', approx='naissance 1915 : non donnée par la page, à vérifier')
S('al.zog', 'al.geraldine')
g.m('al.leka1', 'Leka Ier d\'Albanie', 1939, 2011, 'Prince héritier, prétendant au trône', ZO, 'AL_ZOG', 'h')
P('al.zog', 'al.leka1'); P('al.geraldine', 'al.leka1')
g.m('al.susan', 'Susan Cullen-Ward', None, 2004, 'Épouse de Leka Ier', 'Cullen-Ward (Australie)', 'AL_ZOG', 'f', flag='Famille Cullen-Ward : sans arbre ; naissance non renseignée', approx='naissance non renseignée')
S('al.leka1', 'al.susan')
g.m('al.leka2', 'Leka II d\'Albanie', 1982, None, 'Prétendant au trône d\'Albanie', ZO, 'AL_ZOG', 'h', approx='naissance 1982 : non donnée par la page, à vérifier')
P('al.leka1', 'al.leka2'); P('al.susan', 'al.leka2')
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
