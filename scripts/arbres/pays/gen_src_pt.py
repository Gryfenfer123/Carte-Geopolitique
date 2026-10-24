import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *
from src_outil import appliquer

g = Gen(116, "Sources et corrections — Portugal (Bourgogne, Bragance), Brésil et ajouts Espagne (v98-v100)")
g.sans_repositionnement = True
g.notes = [
    "Les 57 fiches des lots v98, v99 et v100 reçoivent l'adresse de leur page Wikipédia dans « Notes / biographie ». Dates comparées aux pages et corrigées si besoin (Sanche II 1207, Constance Manuel 1318-1349, Béatrice de Portugal 1373-v. 1420).",
    "Thérèse Lourenço : naissance 1330 ajoutée.",
]
W = 'en:'
L = [
 ('pb.henri', '=', '=', W+'Henry,_Count_of_Portugal', None),
 ('pb.teresa', '=', '=', W+'Teresa,_Countess_of_Portugal', 'père Alphonse VI de León'),
 ('pb.afonso1', '=', '=', W+'Afonso_I_of_Portugal', 'naissance 1106, 1109 ou 1111 selon la page (1109 retenu)'),
 ('pb.mafalda', '=', '=', W+'Matilda_of_Savoy,_Queen_of_Portugal', 'naissance c. 1125 ; mort 1157 ou 1158'),
 ('pb.sancho1', '=', '=', W+'Sancho_I_of_Portugal', None),
 ('pb.dulce', '=', '=', W+'Dulce_of_Aragon', None),
 ('pb.afonso2', '=', '=', W+'Afonso_II_of_Portugal', None),
 ('pb.urraca', '=', '=', W+'Urraca_of_Castile,_Queen_of_Portugal', 'naissance 1186 ou 1187'),
 ('pb.sancho2', 1207, '=', W+'Sancho_II_of_Portugal', None),
 ('pb.afonso3', '=', '=', W+'Afonso_III_of_Portugal', None),
 ('pb.mathilde', '=', '=', W+'Matilda_II,_Countess_of_Boulogne', None),
 ('pb.beatriz_c', '=', '=', W+'Beatrice_of_Castile,_Queen_of_Portugal', 'la page mêle deux personnes (1242-1303 et 1293-1359) ; parents non indiqués'),
 ('pb.dinis', '=', '=', W+'Denis_of_Portugal', None),
 ('pb.isabel', '=', '=', W+'Elizabeth_of_Portugal', None),
 ('pb.pedro1', '=', '=', W+'Peter_I_of_Portugal', None),
 ('pb.constanza', 1318, 1349, W+'Constance_Manuel_of_Castile', 'naissance c. 1318'),
 ('pb.ines', '=', '=', W+'In%C3%AAs_de_Castro', None),
 ('pb.teresa_l', 1330, None, W+'Teresa_Louren%C3%A7o', 'naissance 1330 ; mort inconnue'),
 ('pb.fernando', '=', '=', W+'Ferdinand_I_of_Portugal', None),
 ('pb.leonor', '=', '=', W+'Leonor_Teles_de_Menezes', 'naissance et mort c. 1350 et c. 1405'),
 ('pb.beatriz', 1373, 1420, W+'Beatrice_of_Portugal', 'naissance 7-13 février 1373 ; mort c. 1420'),
 ('pb.pedro_c', '=', '=', W+'Infante_Peter,_Duke_of_Coimbra', None),
 ('pb.henri_n', '=', '=', W+'Prince_Henry_the_Navigator', None),
 ('pb.catherine', '=', '=', W+'Catherine_of_Braganza', None),
 ('pb.pedro3', '=', '=', W+'Peter_III_of_Portugal', None),
 ('pb.mariana', '=', '=', W+'Mariana_Victoria_of_Spain', "doublon de la fiche « Marie-Anne-Victoire d'Espagne » (v77), voir liste à faire de Martin"),
 ('pb.joao6', '=', '=', W+'John_VI_of_Portugal', None),
 ('pb.carlota', '=', '=', W+'Carlota_Joaquina_of_Spain', None),
 ('pb.pedro4', '=', '=', W+'Pedro_I_of_Brazil', None),
 ('pb.leopoldina', '=', '=', W+'Maria_Leopoldina_of_Austria', None),
 ('pb.miguel', '=', '=', W+'Miguel_I_of_Portugal', None),
 ('pb.adelaide', '=', '=', W+'Adelaide_of_L%C3%B6wenstein-Wertheim-Rosenberg', None),
 ('pb.maria2', '=', '=', W+'Maria_II_of_Portugal', None),
 ('pb.fernando2', '=', '=', W+'Ferdinand_II_of_Portugal', None),
 ('pb.pedro2br', '=', '=', W+'Pedro_II_of_Brazil', None),
 ('pb.pedro5', '=', '=', W+'Pedro_V_of_Portugal', None),
 ('pb.luis1', '=', '=', W+'Luis_I_of_Portugal', None),
 ('pb.carlos1', '=', '=', W+'Carlos_I_of_Portugal', None),
 ('pb.amelie', '=', '=', W+'Am%C3%A9lie_of_Orl%C3%A9ans', None),
 ('pb.isabelle_o', '=', '=', W+'Princess_Marie_Isabelle_of_Orl%C3%A9ans', None),
 ('pb.luispf', '=', '=', W+'Lu%C3%ADs_Filipe,_Prince_Royal_of_Portugal', None),
 ('pb.manuel2', '=', '=', W+'Manuel_II_of_Portugal', None),
 ('pb.wilhelm', '=', '=', W+'Wilhelm,_Prince_of_Hohenzollern', None),
 ('pb.augusta', '=', '=', W+'Augusta_Victoria_of_Hohenzollern', None),
 ('es.carlos', '=', '=', W+'Carlos,_Prince_of_Asturias', None),
 ('es.juan', '=', '=', W+'John_of_Austria', 'le vainqueur de Lépante ; père Charles Quint, mère Barbara Blomberg'),
 ('es.manuela', '=', '=', W+'Maria_Manuela,_Princess_of_Portugal', None),
 ('es.carlos2', '=', '=', W+'Infante_Carlos_of_Spain_(1607%E2%80%931632)', None),
 ('es.fernando', '=', '=', W+'Cardinal-Infante_Ferdinand_of_Austria', None),
 ('es.baltasar', '=', '=', W+'Balthasar_Charles,_Prince_of_Asturias', None),
 ('es.marialouise', '=', '=', W+'Marie_Louise_d%27Orl%C3%A9ans', None),
 ('es.carlos_is', '=', '=', W+'Infante_Carlos,_Count_of_Molina', None),
 ('es.francisco', '=', '=', W+'Infante_Francisco_de_Paula_of_Spain', None),
 ('es.barbara', '=', '=', W+'Barbara_of_Portugal', None),
 ('es.louisa', '=', '=', W+'Louise_%C3%89lisabeth_d%27Orl%C3%A9ans', None),
 ('es.isabel_p', '=', '=', W+'Maria_Isabel_of_Braganza', None),
 ('es.josefa', '=', '=', W+'Maria_Josepha_Amalia_of_Saxony', None),
]
appliquer(g, L)
g.write()
