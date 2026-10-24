import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(109, "Géorgie (Bagrationi), Arménie, Israël (Hasmonéens et Hérodiens)")
g.notes = [
    "Trois nouveaux arbres : « Bagrationi » (Géorgie), « Dynasties d'Arménie » (Artaxiades et Bagratides), « Hasmonéens et Hérodiens » (Israël). Aucun n'existait.",
    "Dates : connues par ailleurs, aucune page consultée pour ce lot. Années avant J.-C. en négatif ; naissances inconnues laissées vides, approximations signalées. Plusieurs dates antiques et médiévales sont incertaines dans les sources : à vérifier.",
    "Arménie : version volontairement courte. Ashot III et ses fils, Abas Ier et le reste des Bagratides ne sont pas saisis. Gagik Ier est saisi sans parent (signalé).",
    "Géorgie : Bagrat III est saisi sans parent (Gurgen). Les deux lignes (royaume uni médiéval, Kartli-Kakhétie) ne sont pas reliées entre elles.",
    "Non fait : Azerbaïdjan, Séleucides, Nabatéens, Hérodiens secondaires, nombreux cadets.",
]
g.tree('GE_BAG', 'GEO', 'Bagrationi', section_title='Bagrationi')
g.tree('AM_DYN', 'ARM', 'Dynasties d\'Arménie', section_title='Dynasties d\'Arménie')
g.tree('IL_HAS', 'ISR', 'Hasmonéens et Hérodiens', section_title='Hasmonéens et Hérodiens')
P, S = g.par, g.sp
def M(code, name, b, d, title, dyn, tree, g_='h', leader=True, approx=None, flag=None):
    return g.m('cx.' + code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
AP = 'Naissance approximative.'
B = lambda *a, **k: M(*a, dyn='Bagrationi', tree='GE_BAG', **k)
B('bagrat3', 'Bagrat III de Géorgie', 960, 1014, 'Premier roi de la Géorgie unifiée (1008-1014)', flag='Ascendance non saisie')
B('george1', 'Georges Ier de Géorgie', 998, 1027, 'Roi de Géorgie (1014-1027)')
B('bagrat4', 'Bagrat IV de Géorgie', 1018, 1072, 'Roi de Géorgie (1027-1072)')
B('george2', 'Georges II de Géorgie', 1042, 1112, 'Roi de Géorgie (1072-1089)')
B('david4', 'David IV le Bâtisseur', 1073, 1125, 'Roi de Géorgie (1089-1125)')
B('demetre1', 'Dimitri Ier de Géorgie', 1093, 1156, 'Roi de Géorgie (1125-1156)')
B('george3', 'Georges III de Géorgie', 1133, 1184, 'Roi de Géorgie (1156-1184)')
B('tamar', 'Tamar de Géorgie', 1160, 1213, 'Reine de Géorgie (1184-1213), âge d\'or', g_='f')
B('lasha', 'Georges IV Lacha', 1192, 1223, 'Roi de Géorgie (1213-1223)')
B('rusudan', 'Rousoudan de Géorgie', 1194, 1245, 'Reine de Géorgie (1223-1245)', g_='f')
B('david7', 'David VII Oulou', 1215, 1270, 'Roi de Géorgie (1247-1270)')
B('teimuraz2', 'Téïmouraz II de Kakhétie', 1700, 1762, 'Roi de Kakhétie puis de Kartli (1744-1762)')
B('erekle2', 'Héraclius II de Géorgie', 1720, 1798, 'Roi de Kartli-Kakhétie (1762-1798)')
B('george12', 'Georges XII de Géorgie', 1746, 1800, 'Dernier roi de Kartli-Kakhétie (1798-1800)')
for a, b in [('bagrat3', 'george1'), ('george1', 'bagrat4'), ('bagrat4', 'george2'), ('george2', 'david4'), ('david4', 'demetre1'), ('demetre1', 'george3'),
             ('george3', 'tamar'), ('tamar', 'lasha'), ('tamar', 'rusudan'), ('rusudan', 'david7'), ('teimuraz2', 'erekle2'), ('erekle2', 'george12')]:
    P('cx.' + a, 'cx.' + b)
R_ = lambda *a, **k: M(*a, dyn='Dynasties d\'Arménie', tree='AM_DYN', **k)
R_('tigrane', 'Tigrane II le Grand', -140, -55, 'Roi d\'Arménie (-95 à -55)', approx=AP)
R_('artavazde', 'Artavazde II d\'Arménie', None, -31, 'Roi d\'Arménie (-55 à -34)')
R_('ashot1', 'Ashot Ier d\'Arménie', None, 890, 'Premier roi bagratide d\'Arménie (884-890)')
R_('smbat1', 'Smbat Ier d\'Arménie', None, 914, 'Roi d\'Arménie (890-914)')
R_('ashot2', 'Ashot II d\'Arménie', None, 929, 'Roi d\'Arménie (914-928)')
R_('gagik1', 'Gagik Ier d\'Arménie', None, 1020, 'Roi d\'Arménie (989-1020)', flag='Ascendance non saisie')
P('cx.tigrane', 'cx.artavazde'); P('cx.ashot1', 'cx.smbat1'); P('cx.smbat1', 'cx.ashot2')
H = lambda *a, **k: M(*a, dyn='Hasmonéens et Hérodiens', tree='IL_HAS', **k)
H('mattathias', 'Mattathias', None, -166, 'Prêtre de Modiin, initiateur de la révolte des Maccabées', leader=False)
H('judas', 'Judas Maccabée', -190, -160, 'Chef de la révolte des Maccabées', approx=AP)
H('simon', 'Simon Maccabée', None, -135, 'Grand prêtre et ethnarque (-142 à -135)')
H('hyrcan1', 'Jean Hyrcan Ier', -164, -104, 'Grand prêtre et ethnarque de Judée (-134 à -104)')
H('aristobule1', 'Aristobule Ier', None, -103, 'Roi de Judée (-104 à -103)')
H('jannee', 'Alexandre Jannée', -126, -76, 'Roi de Judée (-103 à -76)')
H('salome', 'Alexandra Salomé', -139, -67, 'Reine de Judée (-76 à -67)', g_='f')
H('hyrcan2', 'Hyrcan II', -110, -30, 'Grand prêtre et ethnarque de Judée')
H('aristobule2', 'Aristobule II', -100, -49, 'Roi de Judée (-66 à -63)', approx=AP)
H('antigone', 'Antigone Mattathias', None, -37, 'Dernier roi hasmonéen (-40 à -37)')
H('alexandra', 'Alexandra la Jeune', None, None, 'Fille d\'Hyrcan II, mère de Mariamne', g_='f', leader=False, flag='Naissance et décès inconnus')
H('mariamne', 'Mariamne l\'Hasmonéenne', -54, -29, 'Épouse d\'Hérode le Grand', g_='f', leader=False, approx=AP)
H('herode', 'Hérode le Grand', -73, -4, 'Roi de Judée (-37 à -4)')
H('aristobule4', 'Aristobule IV', None, -6, 'Fils d\'Hérode le Grand et de Mariamne', leader=False)
H('antipas', 'Hérode Antipas', -20, 39, 'Tétrarque de Galilée et de Pérée', approx=AP)
H('archelaus', 'Hérode Archélaüs', -23, 18, 'Ethnarque de Judée (-4 à 6)', approx=AP)
H('philippe', 'Hérode Philippe II', -26, 34, 'Tétrarque d\'Iturée et de Trachonitide', approx=AP)
H('agrippa1', 'Hérode Agrippa Ier', -10, 44, 'Roi de Judée (41-44)', approx=AP)
H('agrippa2', 'Hérode Agrippa II', 27, 100, 'Roi de Chalcis puis de Batanée (50-92/100)', approx=AP)
H('berenice', 'Bérénice (princesse hérodienne)', 28, None, 'Fille d\'Agrippa Ier, compagne de Titus', g_='f', leader=False)
for a, b in [('mattathias', 'judas'), ('mattathias', 'simon'), ('simon', 'hyrcan1'), ('hyrcan1', 'aristobule1'), ('hyrcan1', 'jannee'), ('jannee', 'hyrcan2'), ('jannee', 'aristobule2'),
             ('salome', 'hyrcan2'), ('salome', 'aristobule2'), ('aristobule2', 'antigone'), ('hyrcan2', 'alexandra'), ('alexandra', 'mariamne'),
             ('herode', 'aristobule4'), ('mariamne', 'aristobule4'), ('herode', 'antipas'), ('herode', 'archelaus'), ('herode', 'philippe'),
             ('aristobule4', 'agrippa1'), ('agrippa1', 'agrippa2'), ('agrippa1', 'berenice')]:
    P('cx.' + a, 'cx.' + b)
S('cx.jannee', 'cx.salome'); S('cx.herode', 'cx.mariamne')
g.reposition = {'GE_BAG', 'AM_DYN', 'IL_HAS'}
g.write()
