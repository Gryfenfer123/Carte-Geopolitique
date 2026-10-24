import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *
from src_outil import appliquer

g = Gen(113, "Sources et corrections — Moghols, Chakri, Nguyen, Durrani/Barakzaï (v108)")
g.sans_repositionnement = True
g.notes = [
    "Les 50 fiches du lot v108 reçoivent l'adresse de leur page Wikipédia dans « Notes / biographie ». Dates comparées aux pages et corrigées si besoin (Timur Shah 1746, Zaman Shah 1767-1845, Dost Mohammad 1792, Afzal Khan né en 1815).",
    "Sirikit : la page donne 1932-2025 (le décès n'était pas vérifié, c'est maintenant le cas).",
    "Vietnam : les pères biologiques de Duc Duc (Nguyen Phuc Hong Y) et de Dong Khanh (Nguyen Phuc Hong Cai) sont notés dans les fiches ; ils ne sont pas saisis comme membres.",
]
for k, d_, c in [('IN_MOG', 'Empire moghol', 'IND'), ('TH_CHA', 'Dynastie Chakri', 'THA'), ('VN_NGU', 'Dynastie des Nguyen', 'VNM'), ('AF_DUR', 'Durrani et Barakzaï', 'AFG')]:
    g.tree(k, c, d_)
W = 'en:'
L = [
 ('as.babur', '=', '=', W+'Babur', 'père Omar Cheikh Mirza II, mère Qutlugh Nigar Khanum (hors arbre)'),
 ('as.humayun', '=', '=', W+'Humayun', None),
 ('as.akbar', '=', '=', W+'Akbar', None),
 ('as.jahangir', '=', '=', W+'Jahangir', None),
 ('as.nurjahan', '=', '=', W+'Nur_Jahan', None),
 ('as.shahjahan', '=', '=', W+'Shah_Jahan', None),
 ('as.mumtaz', '=', '=', W+'Mumtaz_Mahal', None),
 ('as.dara', '=', '=', W+'Dara_Shikoh', None),
 ('as.aurangzeb', '=', '=', W+'Aurangzeb', None),
 ('as.bahadur1', '=', '=', W+'Bahadur_Shah_I', None),
 ('as.jahandar', '=', '=', W+'Jahandar_Shah', None),
 ('as.alamgir2', '=', '=', W+'Alamgir_II', None),
 ('as.shahalam2', '=', '=', W+'Shah_Alam_II', None),
 ('as.akbar2', '=', '=', W+'Akbar_II', None),
 ('as.bahadur2', '=', '=', W+'Bahadur_Shah_Zafar', None),
 ('as.r1', '=', '=', W+'Rama_I', None),
 ('as.r2', '=', '=', W+'Rama_II', None),
 ('as.r3', '=', '=', W+'Nangklao', None),
 ('as.r4', '=', '=', W+'Mongkut', None),
 ('as.r5', '=', '=', W+'Chulalongkorn', None),
 ('as.r6', '=', '=', W+'Vajiravudh', None),
 ('as.r7', '=', '=', W+'Prajadhipok', None),
 ('as.mahidol', '=', '=', W+'Mahidol_Adulyadej', 'père Chulalongkorn (Rama V), mère Savang Vadhana'),
 ('as.srina', '=', '=', W+'Srinagarindra', None),
 ('as.r8', '=', '=', W+'Ananda_Mahidol', None),
 ('as.r9', '=', '=', W+'Bhumibol_Adulyadej', None),
 ('as.sirikit', '=', 2025, W+'Sirikit', 'décès en 2025 selon la page'),
 ('as.r10', '=', '=', W+'Vajiralongkorn', None),
 ('as.gialong', '=', '=', W+'Gia_Long', None),
 ('as.minhmang', '=', '=', W+'Minh_M%E1%BA%A1ng', None),
 ('as.thieutri', '=', '=', W+'Thi%E1%BB%87u_Tr%E1%BB%8B', None),
 ('as.tuduc', '=', '=', W+'T%E1%BB%B1_%C4%90%E1%BB%A9c', None),
 ('as.ducduc', '=', '=', W+'D%E1%BB%A5c_%C4%90%E1%BB%A9c', 'fils adoptif de Tu Duc ; père biologique Nguyen Phuc Hong Y, mère Tran Thi Nga'),
 ('as.dongkhanh', '=', '=', W+'%C4%90%E1%BB%93ng_Kh%C3%A1nh', 'fils adoptif de Tu Duc ; père biologique Nguyen Phuc Hong Cai, mère Bui Thi Thanh'),
 ('as.thanhthai', '=', '=', W+'Th%C3%A0nh_Th%C3%A1i', 'fils de Duc Duc'),
 ('as.duytan', '=', '=', W+'Duy_T%C3%A2n', None),
 ('as.khaidinh', '=', '=', W+'Kh%E1%BA%A3i_%C4%90%E1%BB%8Bnh', 'fils de Dong Khanh'),
 ('as.baodai', '=', '=', W+'B%E1%BA%A3o_%C4%90%E1%BA%A1i', None),
 ('as.ahmad', '=', '=', W+'Ahmad_Shah_Durrani', 'naissance entre 1720 et 1722 ; père Mohammad Zaman Khan (hors arbre)'),
 ('as.timur', 1746, '=', W+'Timur_Shah_Durrani', None),
 ('as.zaman', 1767, 1845, W+'Zaman_Shah_Durrani', None),
 ('as.shuja', '=', '=', W+'Shah_Shuja_Durrani', None),
 ('as.dost', 1792, '=', W+'Dost_Mohammad_Khan', 'père Payandah Khan (hors arbre, pas un Durrani)'),
 ('as.afzal', 1815, '=', W+'Mohammad_Afzal_Khan', None),
 ('as.sher', '=', '=', W+'Sher_Ali_Khan', 'naissance c. 1825'),
 ('as.abdur', '=', '=', W+'Abdur_Rahman_Khan', 'naissance 1840 ou 1844 selon la page (1844 retenu) ; père Mohammad Afzal Khan'),
 ('as.habib', '=', '=', W+'Habibullah_Khan', None),
 ('as.aman', '=', '=', W+'Amanullah_Khan', None),
 ('as.nadir', '=', '=', W+'Mohammed_Nadir_Shah', 'père Mohammad Yusuf Khan (hors arbre)'),
 ('as.zahir', '=', '=', W+'Mohammed_Zahir_Shah', None),
]
appliquer(g, L)
g.write()
