import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *
from src_outil import appliquer

g = Gen(112, "Sources et corrections — Hachémites, Al Saoud, Alaouites, Senoussi, dynastie salomonide (v106-v107)")
g.sans_repositionnement = True
g.notes = [
    "Les 60 fiches des lots v106 et v107 reçoivent l'adresse de leur page Wikipédia dans « Notes / biographie ». Dates comparées aux pages et corrigées si besoin.",
    "Deux erreurs de ma part corrigées : l'épouse d'Abdallah Ier, mère de Talal, s'appelle Musbah bint Nasser (j'avais écrit « Misha'al bint Fahd », fiche renommée avec dates 1884-1961) ; l'ancêtre « Moulay Ali Chérif » est en réalité Moulay Chérif ben Ali (v. 1589-1659), père de Rachid et d'Ismaïl.",
    "Ajout de Moulay Hicham ben Mohammed (1748-1798), père d'Abd al-Rahman, fils de Mohammed III. Lien « famille » Sahle Selassie → Ras Makonnen (sa mère est Tenagnework Sahle Selassie, d'après la page de Makonnen).",
]
for k, d_, c in [('JO_HAS', 'Hachémites', 'JOR'), ('IQ_HAS', 'Hachémites (Irak)', 'IRQ'), ('SA_SAO', 'Al Saoud', 'SAU'),
                 ('MA_ALA', 'Alaouites', 'MAR'), ('LY_SEN', 'Senoussi', 'LBY'), ('ET_SAL', 'Dynastie salomonide', 'ETH')]:
    g.tree(k, c, d_)
W = 'en:'
g.rename('me.misha', 'Musbah bint Nasser')
g.rename('af.ali', 'Moulay Chérif ben Ali', 'Émir du Tafilalet, père de Rachid et d\'Ismaïl')
L = [
 ('me.hus', 1853, '=', W+'Hussein_bin_Ali,_Sharif_of_Mecca', 'père Ali ibn Mohammed (hors arbre)'),
 ('me.ali', '=', '=', W+'Ali_of_Hejaz', None),
 ('me.abd1', '=', '=', W+'Abdullah_I_of_Jordan', 'épouses : Musbah bint Nasser, Suzdil, Nahda'),
 ('me.misha', 1884, 1961, W+'Musbah_bint_Nasser', 'ancien nom de la fiche, erroné : « Misha\'al bint Fahd »'),
 ('me.talal', '=', '=', W+'Talal_of_Jordan', None),
 ('me.zein', '=', '=', W+'Zein_al-Sharaf_Talal', None),
 ('me.hus2', '=', '=', W+'Hussein_of_Jordan', None),
 ('me.muna', '=', '=', W+'Princess_Muna_al-Hussein', 'née Toni Avril Gardiner ; date de décès non indiquée'),
 ('me.abd2', '=', '=', W+'Abdullah_II_of_Jordan', None),
 ('me.rania', '=', '=', W+'Queen_Rania_of_Jordan', None),
 ('me.husc', '=', '=', W+'Hussein,_Crown_Prince_of_Jordan', None),
 ('me.fay1', '=', '=', W+'Faisal_I_of_Iraq', None),
 ('me.ghazi', '=', '=', W+'Ghazi_of_Iraq', None),
 ('me.aliya', '=', '=', W+'Queen_Aliya_of_Iraq', None),
 ('me.fay2', '=', '=', W+'Faisal_II_of_Iraq', None),
 ('me.abdilah', '=', '=', W+'%27Abd_al-Ilah', None),
 ('me.mohammed', 1687, '=', W+'Muhammad_bin_Saud', 'né en 1687'),
 ('me.abdulaziz1', '=', '=', W+'Abdulaziz_bin_Muhammad_bin_Saud', None),
 ('me.saud1', '=', '=', W+'Saud_bin_Abdulaziz_bin_Muhammad', None),
 ('me.turki', 1755, '=', W+'Turki_bin_Abdullah_bin_Muhammad', 'père Abdallah ibn Mohammed (non saisi) ; donc petit-fils de Mohammed ibn Saoud'),
 ('me.faisal1', 1785, '=', W+'Faisal_bin_Turki_Al_Saud', 'fils : Abdallah, Saoud, Mohammed, Abdul Rahman'),
 ('me.abdrahman', '=', '=', W+'Abdul_Rahman_bin_Faisal_Al_Saud', None),
 ('me.abdulaziz', 1876, '=', W+'Abdulaziz_Al_Saud', None),
 ('me.hassa', 1900, '=', W+'Hassa_bint_Ahmad_Al_Sudairi', None),
 ('me.saud', '=', '=', W+'Saud_of_Saudi_Arabia', 'mère Wadha bint Muhammad Al Orair'),
 ('me.faisal', '=', '=', W+'Faisal_of_Saudi_Arabia', 'mère Tarfa bint Abdullah Al Sheikh'),
 ('me.khalid', '=', '=', W+'Khalid_of_Saudi_Arabia', 'mère Al Jawhara bint Musaed'),
 ('me.fahd', '=', '=', W+'Fahd_of_Saudi_Arabia', 'naissance 1920, 1921 ou 1923 selon la page'),
 ('me.abdullah', '=', '=', W+'Abdullah_of_Saudi_Arabia', 'mère Fahda bint Asi Al Shuraim'),
 ('me.salman', '=', '=', W+'Salman_of_Saudi_Arabia', None),
 ('me.mbs', '=', '=', W+'Mohammed_bin_Salman', 'mère Fahda bint Falah Al Hithlain'),
 ('af.ali', 1589, 1659, W+'Moulay_Ali_Cherif', 'ancien nom de la fiche : « Moulay Ali Chérif » (c\'est le père de ce personnage) ; naissance c. 1589'),
 ('af.rachid', '=', '=', 'fr:Moulay_Rachid', 'père non indiqué sur cette page ; fils de Moulay Chérif d\'après la page https://en.wikipedia.org/wiki/Moulay_Ali_Cherif'),
 ('af.ismail', '=', '=', W+'Ismail_Ibn_Sharif', 'naissance c. 1645 ; père Sharif ibn Ali'),
 ('af.abdallah', '=', '=', W+'Abdallah_of_Morocco', None),
 ('af.mohammed3', '=', '=', W+'Mohammed_III_of_Morocco', 'naissance c. 1710'),
 ('af.yazid', '=', '=', W+'Yazid_of_Morocco', None),
 ('af.slimane', '=', '=', W+'Slimane_of_Morocco', None),
 ('af.abderrahmane', '=', '=', W+'Abd_al-Rahman_of_Morocco', 'père Hicham ben Mohammed'),
 ('af.mohammed4', '=', '=', W+'Muhammad_IV_of_Morocco', None),
 ('af.hassan1', '=', '=', W+'Hassan_I_of_Morocco', 'naissance 1836 ou 1857 selon la page (1836 retenu)'),
 ('af.aziz', '=', '=', W+'Abdelaziz_of_Morocco', None),
 ('af.hafid', '=', '=', W+'Abdelhafid_of_Morocco', 'naissance entre 1875 et 1880 (1875 retenu)'),
 ('af.youssef', 1881, '=', W+'Moulay_Youssef', 'naissance c. 1881'),
 ('af.mohammed5', '=', '=', W+'Mohammed_V_of_Morocco', None),
 ('af.hassan2', '=', '=', W+'Hassan_II_of_Morocco', None),
 ('af.mohammed6', '=', '=', W+'Mohammed_VI_of_Morocco', None),
 ('af.hassanh', '=', '=', W+'Prince_Moulay_Hassan_of_Morocco', None),
 ('af.mohammed', '=', '=', W+'Muhammad_ibn_Ali_as-Senussi', None),
 ('af.mahdi', '=', '=', W+'Muhammad_al-Mahdi_as-Senussi', 'fils de Mohammed ibn Ali as-Senoussi'),
 ('af.idris', 1890, '=', W+'Idris_of_Libya', None),
 ('af.sahle', '=', '=', W+'Sahle_Selassie', None),
 ('af.melekot', '=', '=', W+'Haile_Melekot', None),
 ('af.menelik', '=', '=', W+'Menelik_II', None),
 ('af.zewditu', '=', '=', W+'Zewditu', None),
 ('af.makonnen', '=', '=', W+'Makonnen_Wolde_Mikael', 'père Wolde Mikael Wolde Melekot ; mère Tenagnework, fille de Sahle Selassie'),
 ('af.hailes', '=', '=', W+'Haile_Selassie', None),
 ('af.menen', '=', '=', W+'Menen_Asfaw', None),
 ('af.amha', '=', '=', W+'Amha_Selassie', None),
 ('af.zera', '=', '=', W+'Zera_Yacob_Amha_Selassie', None),
]
appliquer(g, L)
g.m('af.hisham', 'Moulay Hicham ben Mohammed', 1748, 1798, 'Fils de Mohammed III, père d\'Abd al-Rahman', 'Alaouites', 'MA_ALA', 'h', False,
    src='https://en.wikipedia.org/wiki/Hisham_of_Morocco')
g.par('af.mohammed3', 'af.hisham'); g.par('af.hisham', 'af.abderrahmane')
g.fam('af.sahle', 'af.makonnen')
g.write()
