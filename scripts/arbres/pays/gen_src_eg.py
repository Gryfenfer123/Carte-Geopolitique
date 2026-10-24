import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *
from src_outil import appliquer

g = Gen(110, "Sources et corrections de dates — Égypte (v105) et Fawzia (v104)")
g.notes = [
    "Chaque fiche de l'arbre Ptolémées et de l'arbre Méhémet-Ali reçoit, dans « Notes / biographie », l'adresse de la page Wikipédia consultée. Les dates ont été comparées à ces pages ; celles qui étaient fausses sont corrigées (listées dans le journal).",
    "Ajout du lien manquant Ptolémée Ier → Arsinoé II (sa fille, d'après sa page). Rien n'est supprimé.",
]
g.sans_repositionnement = True
g.tree('EG_PTO', 'EGY', 'Ptolémées')
g.tree('EG_ALI', 'EGY', 'Dynastie de Méhémet-Ali')
L = [
 ('eg.p1', -369, '=', 'en:Ptolemy_I_Soter', 'naissance c. 369/368 av. J.-C. ; père Lagos, mère Arsinoé de Macédoine (hors arbre)'),
 ('eg.p2', '=', '=', 'en:Ptolemy_II_Philadelphus', None),
 ('eg.arsinoe2', '=', '=', 'en:Arsinoe_II_of_Egypt', 'mort en 270 ou 268 av. J.-C. ; fille de Ptolémée Ier'),
 ('eg.p3', '=', '=', 'en:Ptolemy_III_Euergetes', 'naissance c. 280 av. J.-C. ; mère Arsinoé Ire (hors arbre)'),
 ('eg.bereniceii', '=', '=', 'en:Berenice_II_of_Egypt', 'naissance 267 ou 266 av. J.-C. ; père Magas de Cyrène (hors arbre)'),
 ('eg.p4', '=', '=', 'en:Ptolemy_IV_Philopator', None),
 ('eg.arsinoe3', '=', '=', 'en:Arsinoe_III_of_Egypt', 'naissance 246 ou 245 av. J.-C.'),
 ('eg.p5', '=', '=', 'en:Ptolemy_V_Epiphanes', None),
 ('eg.cleo1', '=', '=', 'en:Cleopatra_I_of_Egypt', 'naissance c. 204 av. J.-C. ; fille d\'Antiochos III (hors arbre)'),
 ('eg.p6', '=', '=', 'en:Ptolemy_VI_Philometor', None),
 ('eg.p8', -184, '=', 'en:Ptolemy_VIII_Physcon', 'naissance c. 184 av. J.-C.'),
 ('eg.cleo2', '=', '=', 'en:Cleopatra_II_of_Egypt', 'naissance c. 185 ; mort 116 ou 115 av. J.-C. ; mère « probablement » Cléopâtre Ire selon la page'),
 ('eg.cleo3', -160, '=', 'en:Cleopatra_III_of_Egypt', 'naissance c. 160 av. J.-C.'),
 ('eg.p9', '=', '=', 'en:Ptolemy_IX_Lathyros', 'naissance c. 143/142 av. J.-C., date discutée (peut-être 140/139)'),
 ('eg.p10', '=', '=', 'en:Ptolemy_X_Alexander_I', 'naissance c. 140/139 av. J.-C.'),
 ('eg.p12', '=', '=', 'en:Ptolemy_XII_Auletes', 'naissance c. 117 av. J.-C. ; mère inconnue (hypothèse : Cléopâtre IV)'),
 ('eg.cleo7', '=', '=', 'en:Cleopatra', 'naissance 70 ou 69 av. J.-C.'),
 ('eg.p13', '=', '=', 'en:Ptolemy_XIII_Theos_Philopator', 'naissance c. 62 av. J.-C.'),
 ('eg.arsinoe4', '=', '=', 'en:Arsinoe_IV_of_Egypt', 'naissance c. 68-63 av. J.-C.'),
 ('eg.p14', '=', '=', 'en:Ptolemy_XIV_of_Egypt', 'naissance c. 59 av. J.-C. ; la page le dit frère cadet de Cléopâtre VII, sans nommer ses parents'),
 ('eg.caesarion', '=', '=', 'en:Caesarion', None),
 ('eg.selene', '=', -5, 'en:Cleopatra_Selene_II', 'mort c. 5 av. J.-C.'),
 ('eg.mehmet', '=', '=', 'en:Muhammad_Ali_of_Egypt', None),
 ('eg.tusun', '=', '=', 'en:Tusun_Pasha', None),
 ('eg.ibrahim', '=', '=', 'en:Ibrahim_Pasha_of_Egypt', None),
 ('eg.abbas1', 1812, '=', 'en:Abbas_I_of_Egypt', None),
 ('eg.said', '=', '=', 'en:Said_of_Egypt', None),
 ('eg.ismail', '=', '=', 'en:Ismail_Pasha', None),
 ('eg.tewfik', '=', '=', 'en:Tewfik_Pasha', None),
 ('eg.abbas2', '=', '=', 'en:Abbas_II_of_Egypt', None),
 ('eg.hussein', '=', '=', 'en:Hussein_Kamel_of_Egypt', None),
 ('eg.fuad1', '=', '=', 'en:Fuad_I_of_Egypt', None),
 ('eg.nazli', '=', '=', 'en:Nazli_Sabri', None),
 ('eg.farouk', '=', '=', 'en:Farouk_of_Egypt', None),
 ('eg.farida', '=', '=', 'en:Farida_of_Egypt', None),
 ('eg.narriman', 1933, '=', 'en:Narriman_Sadek', None),
 ('eg.fuad2', '=', '=', 'en:Fuad_II_of_Egypt', None),
 ('ir.fawzia', '=', '=', 'en:Princess_Fawzia_of_Egypt', None),
]
appliquer(g, L)
g.par('eg.p1', 'eg.arsinoe2')
g.write()
