import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(97, "Corée — dynastie Goryeo (Wang) de Taejo à Gongyang")
g.notes = [
    "Nouvel arbre « Goryeo » (aucun n'existait). Rien n'est supprimé.",
    "Source : pages Wikipédia en anglais de chaque roi (dates de vie et père) ; pour quelques rois (Gyeongjong, Mokjong, Munjong et fils, Sukjong, Yejong, Injong et fils, Huijong, Wonjong, Chungnyeol à Chungmok) les pages ont été lues une par une.",
    "Daejong et Anjong (fils de Taejo, rois à titre posthume) s'appellent tous deux Wang Uk : nommés avec leur titre pour les distinguer. Dates de naissance incertaines (Anjong : vers 920/937) : laissées vides.",
    "Gongyang (dernier roi) descend de Sinjong par une branche éloignée (père : prince Wang Kyun) : père ajouté sans lien avec les rois précédents faute de chaîne sourcée.",
    "Non fait : épouses des rois (familles sans arbre), Silla et les Trois Royaumes.",
]
g.tree('KR_GOR', 'KOR', 'Goryeo', section_title='Goryeo')
P = g.par
W = 'Goryeo (Wang)'; T = 'KR_GOR'
def M(code, name, b, d, title, leader=True, approx=None):
    return g.m('kg.' + code, name, b, d, title, W, T, 'h', leader, approx=approx)
L = [('taejo', 'Taejo (Wang Geon)', 877, 943, 'Fondateur de Goryeo (918-943)'),
     ('hyejong', 'Hyejong (Goryeo)', 912, 945, 'Roi (943-945)'),
     ('jeongjong1', 'Jeongjong I (Goryeo)', 923, 949, 'Roi (945-949)'),
     ('gwangjong', 'Gwangjong (Goryeo)', 925, 975, 'Roi (949-975)'),
     ('gyeongjong', 'Gyeongjong (Goryeo)', 955, 981, 'Roi (975-981)'),
     ('seongjong', 'Seongjong (Goryeo)', 961, 997, 'Roi (981-997)'),
     ('mokjong', 'Mokjong (Goryeo)', 980, 1009, 'Roi (997-1009)'),
     ('hyeonjong', 'Hyeonjong (Goryeo)', 992, 1031, 'Roi (1009-1031)'),
     ('deokjong', 'Deokjong (Goryeo)', 1016, 1034, 'Roi (1031-1034)'),
     ('jeongjong2', 'Jeongjong II (Goryeo)', 1018, 1046, 'Roi (1034-1046)'),
     ('munjong', 'Munjong (Goryeo)', 1019, 1083, 'Roi (1046-1083)'),
     ('sunjong', 'Sunjong (Goryeo)', 1047, 1083, 'Roi (1083)'),
     ('seonjong', 'Seonjong (Goryeo)', 1049, 1094, 'Roi (1083-1094)'),
     ('heonjong', 'Heonjong (Goryeo)', 1084, 1097, 'Roi (1094-1095)'),
     ('sukjong', 'Sukjong (Goryeo)', 1054, 1105, 'Roi (1095-1105)'),
     ('yejong', 'Yejong (Goryeo)', 1079, 1122, 'Roi (1105-1122)'),
     ('injong', 'Injong (Goryeo)', 1109, 1146, 'Roi (1122-1146)'),
     ('uijong', 'Uijong (Goryeo)', 1127, 1173, 'Roi (1146-1170), détrôné'),
     ('myeongjong', 'Myeongjong (Goryeo)', 1131, 1202, 'Roi (1170-1197), mis sur le trône par les généraux'),
     ('sinjong', 'Sinjong (Goryeo)', 1144, 1204, 'Roi (1197-1204)'),
     ('huijong', 'Huijong (Goryeo)', 1181, 1237, 'Roi (1204-1211)'),
     ('gangjong', 'Gangjong (Goryeo)', 1152, 1213, 'Roi (1211-1213)'),
     ('gojong', 'Gojong (Goryeo)', 1192, 1259, 'Roi (1213-1259), invasions mongoles'),
     ('wonjong', 'Wonjong (Goryeo)', 1219, 1274, 'Roi (1259-1274), paix avec les Mongols'),
     ('chungnyeol', 'Chungnyeol (Goryeo)', 1236, 1308, 'Roi (1274-1308), gendre de Kubilai'),
     ('chungseon', 'Chungseon (Goryeo)', 1275, 1325, 'Roi (1298, 1308-1313)'),
     ('chungsuk', 'Chungsuk (Goryeo)', 1294, 1339, 'Roi (1313-1330, 1332-1339)'),
     ('chunghye', 'Chunghye (Goryeo)', 1315, 1344, 'Roi (1330-1332, 1339-1344)'),
     ('chungmok', 'Chungmok (Goryeo)', 1337, 1348, 'Roi (1344-1348)'),
     ('chungjeong', 'Chungjeong (Goryeo)', 1338, 1352, 'Roi (1349-1351)'),
     ('gongmin', 'Gongmin (Goryeo)', 1330, 1374, 'Roi (1351-1374), libère Goryeo des Yuan'),
     ('u', 'U (Goryeo)', 1365, 1389, 'Roi (1374-1388), détrôné'),
     ('chang', 'Chang (Goryeo)', 1380, 1389, 'Roi (1388-1389), détrôné'),
     ('gongyang', 'Gongyang (Goryeo)', 1345, 1394, 'Dernier roi de Goryeo (1389-1392)')]
for c, n, b, d, t in L:
    M(c, n, b, d, t)
M('daejong', 'Daejong (Wang Uk, fils de Taejo)', None, 969, 'Père de Seongjong, roi à titre posthume', leader=False)
M('anjong', 'Anjong (Wang Uk, fils de Taejo)', None, 996, 'Père de Hyeonjong, roi à titre posthume', leader=False)
M('kyun', 'Prince Wang Kyun (Jeongwon)', None, None, 'Père de Gongyang', leader=False)
for a, b in [('taejo', 'hyejong'), ('taejo', 'jeongjong1'), ('taejo', 'gwangjong'), ('taejo', 'daejong'), ('taejo', 'anjong'),
             ('gwangjong', 'gyeongjong'), ('daejong', 'seongjong'), ('gyeongjong', 'mokjong'), ('anjong', 'hyeonjong'),
             ('hyeonjong', 'deokjong'), ('hyeonjong', 'jeongjong2'), ('hyeonjong', 'munjong'),
             ('munjong', 'sunjong'), ('munjong', 'seonjong'), ('munjong', 'sukjong'), ('seonjong', 'heonjong'),
             ('sukjong', 'yejong'), ('yejong', 'injong'), ('injong', 'uijong'), ('injong', 'myeongjong'), ('injong', 'sinjong'),
             ('sinjong', 'huijong'), ('myeongjong', 'gangjong'), ('gangjong', 'gojong'), ('gojong', 'wonjong'),
             ('wonjong', 'chungnyeol'), ('chungnyeol', 'chungseon'), ('chungseon', 'chungsuk'), ('chungsuk', 'chunghye'),
             ('chungsuk', 'gongmin'), ('chunghye', 'chungmok'), ('chunghye', 'chungjeong'), ('gongmin', 'u'), ('u', 'chang'),
             ('kyun', 'gongyang')]:
    P('kg.' + a, 'kg.' + b)
g.reposition = {'KR_GOR'}
g.write()
