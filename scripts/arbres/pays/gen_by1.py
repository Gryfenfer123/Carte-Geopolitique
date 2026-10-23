import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(91, "Empire byzantin — dynasties macédonienne, Doukas, Comnène, Ange, Laskaris et Paléologue (867-1453)")
g.notes = [
    "Nouvel arbre « Empire byzantin » (aucun n'existait). Rien n'est supprimé.",
    "Source : Wikipédia en anglais, « List of Byzantine emperors » (noms, naissances et liens imprimés) ; morts : connues par ailleurs, la page ne les donne pas. Naissances non imprimées = vides.",
    "Les successions par adoption, gendre ou neveu sont reliées par un lien « famille » (pas par une filiation). Début : Basile Ier (867) ; la période avant 867 n'est pas faite.",
    "Non fait : épouses autres que Zoé/Théodora et leurs maris, co-empereurs qui n'ont jamais régné seuls, princes non empereurs.",
]
g.tree('BY_EMP', 'GRC', 'Empire byzantin', section_title='Empire byzantin')
P, S = g.par, g.sp
T = 'BY_EMP'
def M(code, name, b, d, title, dyn, g_='h', approx=None):
    return g.m(code, name, b, d, title, dyn, T, g_, True, approx=approx)
MA, DO, KO, AN, LA, PA = 'Macédonienne', 'Doukas', 'Comnène', 'Ange', 'Laskaris', 'Paléologue'
L = [('basil1', 'Basile Ier', 811, 886, MA, 'naissance vers 811'), ('leo6', 'Léon VI', 866, 912, MA, None),
     ('alexander', 'Alexandre', 870, 913, MA, None), ('const7', 'Constantin VII Porphyrogénète', 905, 959, MA, None),
     ('romanos1', 'Romain Ier Lécapène', None, 948, MA, 'naissance non imprimée'), ('romanos2', 'Romain II', 938, 963, MA, None),
     ('nikephoros2', 'Nicéphore II Phocas', 912, 969, MA, 'naissance vers 912'), ('john1', 'Jean Ier Tzimiskès', 925, 976, MA, 'naissance vers 925'),
     ('basil2', 'Basile II', 958, 1025, MA, None), ('const8', 'Constantin VIII', 960, 1028, MA, None),
     ('romanos3', 'Romain III Argyre', 968, 1034, MA, None), ('michael4', 'Michel IV le Paphlagonien', 1010, 1041, MA, None),
     ('michael5', 'Michel V Calaphate', 1015, 1042, MA, None), ('const9', 'Constantin IX Monomaque', 1000, 1055, MA, 'naissance vers 1000'),
     ('michael6', 'Michel VI Stratiotikos', None, None, MA, 'dates non imprimées'),
     ('isaac1', 'Isaac Ier Comnène', 1005, 1061, KO, 'naissance vers 1005'),
     ('const10', 'Constantin X Doukas', 1006, 1067, DO, None), ('romanos4', 'Romain IV Diogène', 1032, 1072, DO, None),
     ('michael7', 'Michel VII Doukas', 1050, 1090, DO, 'mort vers 1090'), ('nikephoros3', 'Nicéphore III Botaniatès', 1001, 1081, DO, None),
     ('alexios1', 'Alexis Ier Comnène', 1056, 1118, KO, None), ('john2', 'Jean II Comnène', 1087, 1143, KO, None),
     ('manuel1', 'Manuel Ier Comnène', 1118, 1180, KO, None), ('alexios2', 'Alexis II Comnène', 1169, 1183, KO, None),
     ('andronikos1', 'Andronic Ier Comnène', 1118, 1185, KO, 'naissance vers 1118'),
     ('isaac2', 'Isaac II Ange', 1156, 1204, AN, None), ('alexios3', 'Alexis III Ange', 1153, 1211, AN, None),
     ('alexios4', 'Alexis IV Ange', 1182, 1204, AN, None), ('alexios5', 'Alexis V Doukas', 1140, 1204, AN, None),
     ('theodore1', 'Théodore Ier Lascaris', 1174, 1221, LA, 'naissance vers 1174'), ('john3', 'Jean III Vatatzès', 1192, 1254, LA, 'naissance vers 1192'),
     ('theodore2', 'Théodore II Lascaris', 1221, 1258, LA, None), ('john4', 'Jean IV Lascaris', 1250, 1305, LA, None),
     ('michael8', 'Michel VIII Paléologue', 1223, 1282, PA, None), ('andronikos2', 'Andronic II Paléologue', 1259, 1332, PA, None),
     ('michael9', 'Michel IX Paléologue', 1277, 1320, PA, None), ('andronikos3', 'Andronic III Paléologue', 1297, 1341, PA, None),
     ('john5', 'Jean V Paléologue', 1332, 1391, PA, None), ('john6', 'Jean VI Cantacuzène', 1292, 1383, 'Cantacuzène', None),
     ('andronikos4', 'Andronic IV Paléologue', 1348, 1385, PA, None), ('john7', 'Jean VII Paléologue', 1370, 1408, PA, None),
     ('manuel2', 'Manuel II Paléologue', 1350, 1425, PA, None), ('john8', 'Jean VIII Paléologue', 1392, 1448, PA, None),
     ('const11', 'Constantin XI Paléologue', 1405, 1453, PA, 'dernier empereur byzantin')]
for c, n, b, d, dy, a in L:
    M('by.' + c, n, b, d, 'Empereur byzantin', dy, 'h', a)
M('by.zoe', 'Zoé Porphyrogénète', 978, 1050, 'Impératrice byzantine', MA, 'f', 'naissance vers 978')
M('by.theodora', 'Théodora Porphyrogénète', 984, 1056, 'Impératrice byzantine', MA, 'f')
M('by.eudokia', 'Eudocie Macrembolitissa', 1021, 1096, 'Impératrice byzantine, régente', DO, 'f', 'naissance vers 1021')
M('by.irene_l', 'Irène Lascaris', 1196, 1239, 'Impératrice de Nicée, épouse de Jean III', LA, 'f', 'dates vers 1196-1239')
for a, b in [('basil1', 'leo6'), ('basil1', 'alexander'), ('leo6', 'const7'), ('const7', 'romanos2'), ('romanos2', 'basil2'),
             ('romanos2', 'const8'), ('const8', 'zoe'), ('const8', 'theodora'), ('const10', 'michael7'), ('alexios1', 'john2'),
             ('john2', 'manuel1'), ('manuel1', 'alexios2'), ('isaac2', 'alexios4'), ('theodore1', 'irene_l'), ('john3', 'theodore2'),
             ('theodore2', 'john4'), ('michael8', 'andronikos2'), ('andronikos2', 'michael9'), ('michael9', 'andronikos3'),
             ('andronikos3', 'john5'), ('john5', 'andronikos4'), ('john5', 'manuel2'), ('andronikos4', 'john7'),
             ('manuel2', 'john8'), ('manuel2', 'const11')]:
    P('by.' + a, 'by.' + b)
for a, b in [('zoe', 'romanos3'), ('zoe', 'michael4'), ('zoe', 'const9'), ('const10', 'eudokia'), ('eudokia', 'romanos4'), ('john3', 'irene_l')]:
    S('by.' + a, 'by.' + b)
for a, b in [('nikephoros2', 'john1'), ('michael4', 'michael5'), ('isaac1', 'alexios1'), ('john2', 'andronikos1'),
             ('isaac2', 'alexios3'), ('alexios3', 'alexios5'), ('alexios3', 'theodore1'), ('alexios3', 'michael8'),
             ('theodora', 'michael6'), ('isaac1', 'const10')]:
    g.fam('by.' + a, 'by.' + b)
g.fam('by.romanos1', 'by.const7'); g.fam('by.michael7', 'by.nikephoros3'); g.fam('by.nikephoros2', 'by.zoe'); g.fam('by.john5', 'by.john6')
g.reposition = {'BY_EMP'}
g.write()
