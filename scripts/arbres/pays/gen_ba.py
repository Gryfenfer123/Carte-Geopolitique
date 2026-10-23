import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(49, "Bosnie — Kotromanić")
g.notes = [
    "Crée sous Bosnie-Herzégovine > Dynastie : Kotromanić (Prijezda Ier -> Étienne Tomašević), à partir de Wikipédia anglais.",
    "Dates : la page ne donne pas de naissance pour la plupart ; elles sont laissées vides (pas d'invention). Filiations discutées marquées : Tvrtko II (fils de Tvrtko Ier ? contesté), Dabiša et Ostoja (parenté exacte avec Tvrtko Ier incertaine, reliés par un lien « famille »).",
    "Élisabeth de Bosnie (reine de Hongrie), créée par v39 dans Anjou-Hongrie, est déplacée dans l'arbre Kotromanić.",
    "Créés dans leur arbre : Élisabeth de Serbie (Nemanjić), Dorothée de Bulgarie (Chichman), Hélène Branković (Branković), Élisabeth de Gniewkowo (Piast).",
    "Prérequis : v48 exécuté.",
]
g.tree('BA_KOT', 'BIH', 'Kotromanić')
g.tree('SR_NEM', 'SRB', 'Nemanjić')
g.tree('SR_BRA', 'SRB', 'Branković')
g.tree('BG_CHI', 'BGR', 'Chichman')
g.tree('PL_PIAST', 'POL', 'Piast')
g.tree('PL_ANJ', 'POL', 'Anjou-Hongrie')
g.reposition = {'SR_NEM', 'SR_BRA', 'BG_CHI', 'PL_PIAST', 'PL_ANJ'}
FB = {'ba.stephen1': 1265, 'ba.stephen2': 1292, 'ba.vladislav': 1295, 'ba.jelena_s': 1310, 'ba.prijezda': 1230,
      'sr.elizabeth_d': 1270, 'pl.elisabeth_gn': 1315, 'ba.catherine': 1336, 'ba.hermann': 1333, 'bg.dorothea': 1345,
      'ba.tvrtko2': 1370, 'ba.dabisa': 1340, 'ba.ostoja': 1350, 'ba.thomas': 1380, 'ba.vojaca': 1415, 'ba.catherine_k': 1425,
      'sr.helen_b': 1445}
Gen.FIXB = {uid('member:' + c): y for c, y in FB.items()}
P, S = g.par, g.sp
KO = 'Kotromanić'
g.m('ba.prijezda', 'Prijezda Ier', None, 1287, 'Ban de Bosnie (v. 1250-1287)', KO, 'BA_KOT', 'h', True, approx='naissance non renseignée')
g.m('ba.stephen1', 'Étienne Ier Kotromanić', None, None, 'Ban de Bosnie', KO, 'BA_KOT', 'h', True, approx='dates non renseignées')
P('ba.prijezda', 'ba.stephen1')
g.m('sr.elizabeth_d', 'Élisabeth de Serbie (épouse d\'Étienne Ier Kotromanić)', None, None, 'Banesse de Bosnie', 'Nemanjić', 'SR_NEM', 'f', approx='dates non renseignées')
P('sr.dragutin', 'sr.elizabeth_d'); P('hu.catherine', 'sr.elizabeth_d')
S('ba.stephen1', 'sr.elizabeth_d')
g.m('ba.stephen2', 'Étienne II Kotromanić', None, 1353, 'Ban de Bosnie (1322-1353)', KO, 'BA_KOT', 'h', True, approx='naissance non renseignée (XIVe siècle)')
g.m('ba.vladislav', 'Vladislav Kotromanić', None, None, 'Frère d\'Étienne II, régent', KO, 'BA_KOT', 'h', approx='dates non renseignées')
for c in ('ba.stephen2', 'ba.vladislav'):
    P('ba.stephen1', c); P('sr.elizabeth_d', c)
g.m('pl.elisabeth_gn', 'Élisabeth de Gniewkowo (Couïavie)', None, None, 'Banesse de Bosnie', 'Piast (Couïavie-Gniewkowo)', 'PL_PIAST', 'f', approx='dates non renseignées ; fille de Casimir III de Gniewkowo (non créé)')
S('ba.stephen2', 'pl.elisabeth_gn')
g.move('pl.elisabeth_bos', 'BA_KOT', KO)
P('ba.stephen2', 'pl.elisabeth_bos'); P('pl.elisabeth_gn', 'pl.elisabeth_bos')
g.m('ba.catherine', 'Catherine Kotromanić (comtesse de Celje)', 1336, 1385, 'Comtesse de Celje', KO, 'BA_KOT', 'f')
g.m('ba.hermann', 'Hermann Ier de Celje', None, None, 'Comte de Celje', 'Comtes de Celje', 'BA_KOT', 'h', flag='Comtes de Celje (Slovénie) : arbre à créer avec la Slovénie ; dates non renseignées', approx='dates non renseignées')
P('ba.stephen2', 'ba.catherine')
S('ba.hermann', 'ba.catherine')
g.m('ba.jelena_s', 'Jelena Šubić', None, None, 'Mère de Tvrtko Ier', 'Šubić de Bribir (Croatie)', 'BA_KOT', 'f', flag='Famille Šubić de Bribir (Croatie) : arbre à créer avec la Croatie', approx='dates non renseignées')
g.m('ba.tvrtko1', 'Tvrtko Ier de Bosnie', 1338, 1391, 'Ban (1353) puis premier roi de Bosnie (1377-1391)', KO, 'BA_KOT', 'h', True, approx='naissance « vers 1338 »')
P('ba.vladislav', 'ba.tvrtko1'); P('ba.jelena_s', 'ba.tvrtko1')
S('ba.vladislav', 'ba.jelena_s')
g.m('bg.dorothea', 'Dorothée de Bulgarie (reine de Bosnie)', None, None, 'Reine de Bosnie', 'Chichman', 'BG_CHI', 'f', approx='dates non renseignées')
P('bg.sratsimir', 'bg.dorothea')
S('ba.tvrtko1', 'bg.dorothea')
g.m('ba.tvrtko2', 'Tvrtko II de Bosnie', None, 1443, 'Roi de Bosnie (1404-1409, 1420-1443)', KO, 'BA_KOT', 'h', True, approx='naissance non renseignée ; filiation avec Tvrtko Ier discutée (légitimité contestée)')
P('ba.tvrtko1', 'ba.tvrtko2')
g.m('ba.dabisa', 'Étienne Dabiša', None, 1395, 'Roi de Bosnie (1391-1395)', KO, 'BA_KOT', 'h', True, approx='naissance non renseignée ; parenté avec Tvrtko Ier incertaine')
g.m('ba.ostoja', 'Étienne Ostoja', None, 1418, 'Roi de Bosnie (1398-1404, 1409-1418)', KO, 'BA_KOT', 'h', True, approx='naissance non renseignée ; parenté avec Tvrtko Ier incertaine (fils ou demi-frère illégitime)')
g.fam('ba.tvrtko1', 'ba.dabisa'); g.fam('ba.tvrtko1', 'ba.ostoja')
g.m('ba.thomas', 'Étienne Thomas', None, 1461, 'Roi de Bosnie (1443-1461)', KO, 'BA_KOT', 'h', True, approx='naissance non renseignée')
P('ba.ostoja', 'ba.thomas')
g.m('ba.vojaca', 'Vojača', None, None, 'Première épouse d\'Étienne Thomas', 'Roturière', 'BA_KOT', 'f', flag='Origine roturière : sans arbre ; dates non renseignées', approx='dates non renseignées')
g.m('ba.catherine_k', 'Catherine Kosača', None, None, 'Reine de Bosnie', 'Kosača (Herzégovine)', 'BA_KOT', 'f', flag='Famille Kosača (Herzégovine) : sans arbre ; dates non renseignées', approx='dates non renseignées')
S('ba.thomas', 'ba.vojaca'); S('ba.thomas', 'ba.catherine_k')
g.m('ba.tomasevic', 'Étienne Tomašević', 1438, 1463, 'Despote de Serbie (1459), dernier roi de Bosnie (1461-1463)', KO, 'BA_KOT', 'h', True, approx='naissance « vers 1438 »')
P('ba.thomas', 'ba.tomasevic'); P('ba.vojaca', 'ba.tomasevic')
g.m('sr.helen_b', 'Hélène Branković (Marie de Serbie), reine de Bosnie', None, None, 'Reine de Bosnie', 'Branković', 'SR_BRA', 'f', approx='dates non renseignées ; fille de Lazar Branković et d\'Hélène Paléologue')
P('sr.lazar_b', 'sr.helen_b'); P('sr.helena_pal', 'sr.helen_b')
S('ba.tomasevic', 'sr.helen_b')
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
