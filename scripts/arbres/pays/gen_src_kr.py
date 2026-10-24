import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *
from src_outil import appliquer

g = Gen(115, "Sources — Goryeo (v97)")
g.sans_repositionnement = True
g.notes = [
    "Les 37 fiches du Goryeo reçoivent l'adresse de leur page Wikipédia dans « Notes / biographie ». Toutes les dates saisies en v97 sont confirmées par ces pages ; aucune correction.",
]
g.tree('KR_GOR', 'KOR', 'Goryeo')
W = 'en:'
L = [
 ('kg.taejo', '=', '=', W+'Taejo_of_Goryeo', None),
 ('kg.hyejong', '=', '=', W+'Hyejong_of_Goryeo', None),
 ('kg.jeongjong1', '=', '=', W+'Jeongjong_of_Goryeo', 'la page regroupe plusieurs rois du même nom ; Jeongjong Ier : 923-949'),
 ('kg.gwangjong', '=', '=', W+'Gwangjong_of_Goryeo', None),
 ('kg.gyeongjong', '=', '=', W+'Gyeongjong_of_Goryeo', None),
 ('kg.seongjong', '=', '=', W+'Seongjong_of_Goryeo', None),
 ('kg.mokjong', '=', '=', W+'Mokjong_of_Goryeo', None),
 ('kg.hyeonjong', '=', '=', W+'Hyeonjong_of_Goryeo', None),
 ('kg.deokjong', '=', '=', W+'Deokjong_of_Goryeo', None),
 ('kg.jeongjong2', '=', '=', W+'Jeongjong_II_of_Goryeo', None),
 ('kg.munjong', '=', '=', W+'Munjong_of_Goryeo', None),
 ('kg.sunjong', '=', '=', W+'Sunjong_of_Goryeo', None),
 ('kg.seonjong', '=', '=', W+'Seonjong_of_Goryeo', None),
 ('kg.heonjong', '=', '=', W+'Heonjong_of_Goryeo', None),
 ('kg.sukjong', '=', '=', W+'Sukjong_of_Goryeo', None),
 ('kg.yejong', '=', '=', W+'Yejong_of_Goryeo', None),
 ('kg.injong', '=', '=', W+'Injong_of_Goryeo', None),
 ('kg.uijong', '=', '=', W+'Uijong_of_Goryeo', None),
 ('kg.myeongjong', '=', '=', W+'Myeongjong_of_Goryeo', None),
 ('kg.sinjong', '=', '=', W+'Sinjong_of_Goryeo', None),
 ('kg.huijong', '=', '=', W+'Huijong_of_Goryeo', None),
 ('kg.gangjong', '=', '=', W+'Gangjong_of_Goryeo', None),
 ('kg.gojong', '=', '=', W+'Gojong_of_Goryeo', None),
 ('kg.wonjong', '=', '=', W+'Wonjong_of_Goryeo', None),
 ('kg.chungnyeol', '=', '=', W+'Chungnyeol_of_Goryeo', None),
 ('kg.chungseon', '=', '=', W+'Chungseon_of_Goryeo', None),
 ('kg.chungsuk', '=', '=', W+'Chungsuk_of_Goryeo', None),
 ('kg.chunghye', '=', '=', W+'Chunghye_of_Goryeo', None),
 ('kg.chungmok', '=', '=', W+'Chungmok_of_Goryeo', None),
 ('kg.chungjeong', '=', '=', W+'Chungjeong_of_Goryeo', None),
 ('kg.gongmin', '=', '=', W+'Gongmin_of_Goryeo', None),
 ('kg.u', '=', '=', W+'U_of_Goryeo', None),
 ('kg.chang', '=', '=', W+'Chang_of_Goryeo', None),
 ('kg.gongyang', '=', '=', W+'Gongyang_of_Goryeo', 'père Wang Kyun (prince Jeongwon), pas de page propre'),
 ('kg.daejong', '=', '=', W+'Daejong_of_Goryeo', None),
 ('kg.anjong', '=', '=', W+'Anjong_of_Goryeo', 'naissance c. 920 ou 937 (non retenue) ; père Taejo'),
 ('kg.kyun', '=', '=', 'en:Gongyang_of_Goryeo', 'sa fiche n\'a pas de page propre ; il est cité comme père de Gongyang (Wang Yo) sur cette page'),
]
appliquer(g, L)
g.write()
