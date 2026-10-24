import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *
from src_outil import appliquer

g = Gen(111, "Sources et corrections de dates — Iran (v104)")
g.sans_repositionnement = True
g.notes = [
    "Les 48 fiches de l'Iran (hors Fawzia, traitée en v110) reçoivent l'adresse de leur page Wikipédia dans « Notes / biographie ». Dates comparées aux pages ; corrigées quand elles divergeaient.",
    "Ajout de Mohammad Hasan Khan Qajar (père d'Agha Mohammad Khan et de Hossein Qoli Khan, d'après leurs pages) avec ses deux liens parent-enfant. Les anciens liens « famille » sont conservés (rien n'est supprimé).",
]
for k, d_ in [('IR_ACH', 'Achéménides'), ('IR_SAS', 'Sassanides'), ('IR_SAF', 'Safavides'), ('IR_QAJ', 'Qajars'), ('IR_PAH', 'Pahlavi')]:
    g.tree(k, 'IRN', d_)
W = 'en:'
L = [
 ('ir.cyrus', -600, '=', W+'Cyrus_the_Great', 'naissance c. 600 av. J.-C. ; père Cambyse Ier, mère Mandane de Médie (hors arbre)'),
 ('ir.cambyse', '=', '=', W+'Cambyses_II', 'naissance inconnue ; fils de Cyrus II et de Cassandane'),
 ('ir.darius1', '=', '=', W+'Darius_the_Great', 'naissance c. 550 ; père Hystaspe (hors arbre), donc pas fils de Cyrus : lien « famille » seulement'),
 ('ir.xerxes1', '=', '=', W+'Xerxes_I', 'naissance c. 518 av. J.-C.'),
 ('ir.artax1', '=', '=', W+'Artaxerxes_I', 'naissance inconnue'),
 ('ir.darius2', '=', '=', W+'Darius_II', 'naissance inconnue'),
 ('ir.artax2', -436, '=', W+'Artaxerxes_II', 'naissance c. 436 av. J.-C.'),
 ('ir.artax3', None, '=', W+'Artaxerxes_III', 'naissance inconnue (la page n\'en donne pas)'),
 ('ir.arses', '=', '=', W+'Artaxerxes_IV_Arses', 'naissance non indiquée'),
 ('ir.darius3', '=', '=', W+'Darius_III', 'naissance c. 380 ; père Arsamès (hors arbre) : lien « famille » seulement'),
 ('ir.ardashir', 180, '=', W+'Ardashir_I', 'né en 180'),
 ('ir.shapur1', '=', '=', W+'Shapur_I', 'naissance inconnue'),
 ('ir.narseh', '=', 303, W+'Narseh', 'naissance entre 228 et 233 ; mort en 303'),
 ('ir.hormizd2', '=', '=', W+'Hormizd_II', 'naissance inconnue'),
 ('ir.shapur2', '=', '=', W+'Shapur_II', None),
 ('ir.kavad1', '=', '=', W+'Kavad_I', 'père Péroz Ier (hors arbre) : lien avec Shapur II seulement « famille »'),
 ('ir.khosrow1', 512, '=', W+'Khosrow_I', 'naissance entre 512 et 514'),
 ('ir.hormizd4', 540, '=', W+'Hormizd_IV', 'naissance c. 540'),
 ('ir.khosrow2', '=', '=', W+'Khosrow_II', 'naissance c. 570'),
 ('ir.kavad2', '=', '=', W+'Kavad_II', 'né après 590'),
 ('ir.yazdegerd3', '=', '=', W+'Yazdegerd_III', 'père Shahriyar (hors arbre)'),
 ('ir.haydar', '=', '=', W+'Sheikh_Haydar', None),
 ('ir.ismail1', '=', '=', W+'Ismail_I', None),
 ('ir.tahmasp1', '=', '=', W+'Tahmasp_I', None),
 ('ir.ismail2', '=', '=', W+'Ismail_II', None),
 ('ir.khoda', 1532, '=', W+'Mohammad_Khodabanda', None),
 ('ir.abbas1', '=', '=', W+'Abbas_the_Great', None),
 ('ir.baqir', '=', '=', W+'Mohammad_Baqer_Mirza', None),
 ('ir.safi', '=', '=', W+'Safi_of_Persia', None),
 ('ir.abbas2', '=', '=', W+'Abbas_II_of_Persia', None),
 ('ir.suleiman', 1648, '=', W+'Suleiman_I_of_Persia', None),
 ('ir.husayn', '=', 1727, W+'Sultan_Husayn', None),
 ('ir.tahmasp2', '=', '=', W+'Tahmasp_II', None),
 ('ir.abbas3', '=', '=', W+'Abbas_III_of_Persia', None),
 ('ir.hosseinqoli', 1751, '=', W+'Hossein_Qoli_Khan_Qajar', 'né en 1751, mort c. 1777 ; frère d\'Agha Mohammad Khan ; père de Fath Ali Shah'),
 ('ir.agha', '=', '=', W+'Agha_Mohammad_Khan_Qajar', None),
 ('ir.fathali', '=', '=', W+'Fath-Ali_Shah_Qajar', None),
 ('ir.abbasm', '=', '=', W+'Abbas_Mirza', None),
 ('ir.mohammad', '=', '=', W+'Mohammad_Shah_Qajar', None),
 ('ir.naser', '=', '=', W+'Naser_al-Din_Shah_Qajar', None),
 ('ir.mozaffar', '=', '=', W+'Mozaffar_ad-Din_Shah_Qajar', None),
 ('ir.mohammadali', '=', '=', W+'Mohammad_Ali_Shah_Qajar', None),
 ('ir.ahmad', '=', '=', W+'Ahmad_Shah_Qajar', None),
 ('ir.reza', '=', '=', W+'Reza_Shah', None),
 ('ir.mreza', '=', '=', W+'Mohammad_Reza_Pahlavi', None),
 ('ir.soraya', '=', '=', W+'Soraya_Esfandiary-Bakhtiari', None),
 ('ir.farah', '=', '=', W+'Farah_Pahlavi', None),
 ('ir.reza2', '=', '=', W+'Reza_Pahlavi', None),
]
appliquer(g, L)
g.m('ir.mhasan', 'Mohammad Hasan Khan Qajar', 1715, 1759, 'Chef qajar, père d\'Agha Mohammad Khan', 'Qajars', 'IR_QAJ', 'h', False,
    src='https://en.wikipedia.org/wiki/Mohammad_Hasan_Khan_Qajar')
g.par('ir.mhasan', 'ir.agha'); g.par('ir.mhasan', 'ir.hosseinqoli')
g.write()
