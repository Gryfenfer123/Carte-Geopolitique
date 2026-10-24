import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(105, "Égypte — Ptolémées et dynastie de Méhémet-Ali")
g.notes = [
    "Deux nouveaux arbres pour l'Égypte (aucun n'existait) : « Ptolémées » et « Dynastie de Méhémet-Ali ». Fawzia d'Égypte (créée en v104 dans l'arbre Pahlavi) est affichée dans l'arbre de Méhémet-Ali et reliée à son père Fouad Ier ; son signalement « arbre à créer » est retiré. Rien n'est supprimé.",
    "Dates : connues par ailleurs (histoire de l'Égypte), aucune page consultée pour ce lot. Années avant J.-C. en négatif ; plusieurs naissances ptolémaïques sont approximatives (signalé).",
    "Particularité des Ptolémées : les mariages frère-sœur sont représentés par des liens « conjoint » ; Ptolémée XII est un fils illégitime de Ptolémée IX. Le père de Césarion (Jules César) n'est pas relié (arbre romain absent) : signalé.",
    "Non fait : Fatimides, Ayyoubides, Mamelouks, Lagides secondaires, enfants cadets.",
]
g.tree('EG_PTO', 'EGY', 'Ptolémées', section_title='Ptolémées')
g.tree('EG_ALI', 'EGY', 'Dynastie de Méhémet-Ali', section_title='Dynastie de Méhémet-Ali')
g.tree('IR_PAH', 'IRN', 'Pahlavi')
REG['flags'] = [f for f in REG['flags'] if f['name'] != "Fawzia d'Égypte"] if 'REG' in globals() else None
P, S = g.par, g.sp
PT = 'Ptolémées'
def M(code, name, b, d, title, g_='h', leader=True, approx=None, dyn=PT, tree='EG_PTO', flag=None):
    return g.m('eg.' + code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
AP = 'Naissance approximative.'
M('p1', 'Ptolémée Ier Sôter', -367, -282, 'Fondateur de la dynastie lagide, roi d\'Égypte (-305 à -283)')
M('p2', 'Ptolémée II Philadelphe', -309, -246, 'Roi d\'Égypte (-283 à -246)')
M('arsinoe2', 'Arsinoé II', -316, -270, 'Reine, épouse de Ptolémée II', 'f', False)
M('p3', 'Ptolémée III Évergète', -280, -222, 'Roi d\'Égypte (-246 à -222)')
M('bereniceii', 'Bérénice II', -267, -221, 'Reine, épouse de Ptolémée III', 'f', False)
M('p4', 'Ptolémée IV Philopator', -244, -204, 'Roi d\'Égypte (-221 à -204)')
M('arsinoe3', 'Arsinoé III', -246, -204, 'Reine, épouse de Ptolémée IV', 'f', False)
M('p5', 'Ptolémée V Épiphane', -210, -180, 'Roi d\'Égypte (-204 à -180)')
M('cleo1', 'Cléopâtre Ire', -204, -176, 'Reine, régente (-180 à -176)', 'f', False)
M('p6', 'Ptolémée VI Philométor', -186, -145, 'Roi d\'Égypte (-180 à -145)')
M('p8', 'Ptolémée VIII Évergète II', -182, -116, 'Roi d\'Égypte (-170 à -116)')
M('cleo2', 'Cléopâtre II', -185, -116, 'Reine, sœur et épouse de Ptolémée VI puis de Ptolémée VIII', 'f', False)
M('cleo3', 'Cléopâtre III', -161, -101, 'Reine, fille de Ptolémée VI, épouse de Ptolémée VIII', 'f', False, approx=AP)
M('p9', 'Ptolémée IX Sôter II (Lathyros)', -143, -81, 'Roi d\'Égypte (-116 à -107, -88 à -81)')
M('p10', 'Ptolémée X Alexandre Ier', -140, -88, 'Roi d\'Égypte (-107 à -88)', approx=AP)
M('p12', 'Ptolémée XII Aulète', -117, -51, 'Roi d\'Égypte (-80 à -51), fils illégitime de Ptolémée IX')
M('cleo7', 'Cléopâtre VII', -69, -30, 'Dernière reine d\'Égypte (-51 à -30)', 'f', True)
M('p13', 'Ptolémée XIII', -62, -47, 'Roi d\'Égypte (-51 à -47), frère et époux de Cléopâtre VII', approx=AP)
M('arsinoe4', 'Arsinoé IV', -68, -41, 'Sœur de Cléopâtre VII, reine rivale (-48 à -47)', 'f', False, approx=AP)
M('p14', 'Ptolémée XIV', -59, -44, 'Roi d\'Égypte (-47 à -44), frère et époux de Cléopâtre VII', approx=AP)
M('caesarion', 'Ptolémée XV Césarion', -47, -30, 'Co-roi d\'Égypte (-44 à -30), fils de Jules César', flag='Père : Jules César, arbre romain absent')
M('selene', 'Cléopâtre Séléné II', -40, -6, 'Fille de Cléopâtre VII et d\'Antoine, reine de Maurétanie', 'f', False)
for a, b in [('p1', 'p2'), ('p2', 'p3'), ('p3', 'p4'), ('p4', 'p5'), ('p5', 'p6'), ('p5', 'p8'), ('p5', 'cleo2'), ('cleo1', 'p6'), ('cleo1', 'p8'), ('cleo1', 'cleo2'),
             ('p3', 'arsinoe3'), ('bereniceii', 'p4'), ('bereniceii', 'arsinoe3'), ('p6', 'cleo3'), ('cleo2', 'cleo3'),
             ('p8', 'p9'), ('p8', 'p10'), ('cleo3', 'p9'), ('cleo3', 'p10'), ('p9', 'p12'), ('p12', 'cleo7'), ('p12', 'p13'), ('p12', 'arsinoe4'), ('p12', 'p14'),
             ('cleo7', 'caesarion'), ('cleo7', 'selene')]:
    P('eg.' + a, 'eg.' + b)
for a, b in [('p2', 'arsinoe2'), ('p3', 'bereniceii'), ('p4', 'arsinoe3'), ('p5', 'cleo1'), ('p6', 'cleo2'), ('p8', 'cleo2'), ('p8', 'cleo3'), ('p9', 'cleo3'),
             ('cleo7', 'p13'), ('cleo7', 'p14')]:
    S('eg.' + a, 'eg.' + b)
# les liens parent ci-dessus pour arsinoe3 (p3 -> arsinoe3) sont corrects ; 'p4' = fils de p3 et de bereniceii.
AL = 'Dynastie de Méhémet-Ali'
def A(code, name, b, d, title, g_='h', leader=True, approx=None, flag=None):
    return g.m('eg.' + code, name, b, d, title, AL, 'EG_ALI', g_, leader, approx=approx, flag=flag)
A('mehmet', 'Méhémet-Ali', 1769, 1849, 'Wali d\'Égypte (1805-1848), fondateur de la dynastie')
A('tusun', 'Toussoun Pacha', 1794, 1816, 'Fils de Méhémet-Ali, père d\'Abbas Ier', leader=False)
A('ibrahim', 'Ibrahim Pacha', 1789, 1848, 'Wali d\'Égypte (1848), conquérant de la Syrie')
A('abbas1', 'Abbas Ier', 1813, 1854, 'Wali d\'Égypte (1848-1854)')
A('said', 'Saïd Pacha', 1822, 1863, 'Wali d\'Égypte (1854-1863), concède le canal de Suez')
A('ismail', 'Ismaïl Pacha', 1830, 1895, 'Khédive d\'Égypte (1863-1879)')
A('tewfik', 'Tewfik Pacha', 1852, 1892, 'Khédive d\'Égypte (1879-1892)')
A('abbas2', 'Abbas II Hilmi', 1874, 1944, 'Dernier khédive d\'Égypte (1892-1914)')
A('hussein', 'Hussein Kamel', 1853, 1917, 'Sultan d\'Égypte (1914-1917)')
A('fuad1', 'Fouad Ier', 1868, 1936, 'Sultan puis premier roi d\'Égypte (1917-1936)')
A('nazli', 'Nazli Sabri', 1894, 1978, 'Reine d\'Égypte, épouse de Fouad Ier', 'f', False, flag='Famille Sabri : sans arbre')
A('farouk', 'Farouk Ier', 1920, 1965, 'Roi d\'Égypte (1936-1952), déposé')
A('farida', 'Farida Zulfikar', 1921, 1988, 'Première épouse de Farouk Ier', 'f', False, flag='Famille Zulficar : sans arbre')
A('narriman', 'Narriman Sadek', 1934, 2005, 'Seconde épouse de Farouk Ier', 'f', False, flag='Famille Sadek : sans arbre')
A('fuad2', 'Fouad II', 1952, None, 'Dernier roi d\'Égypte (1952-1953)')
for a, b in [('mehmet', 'tusun'), ('mehmet', 'ibrahim'), ('mehmet', 'said'), ('tusun', 'abbas1'), ('ibrahim', 'ismail'), ('ismail', 'tewfik'),
             ('tewfik', 'abbas2'), ('ismail', 'hussein'), ('ismail', 'fuad1'), ('fuad1', 'farouk'), ('nazli', 'farouk'), ('farouk', 'fuad2'), ('narriman', 'fuad2')]:
    P('eg.' + a, 'eg.' + b)
S('eg.fuad1', 'eg.nazli'); S('eg.farouk', 'eg.farida'); S('eg.farouk', 'eg.narriman')
FZ = 'ir.fawzia'
g.pin(FZ, 'EG_ALI'); P('eg.fuad1', FZ); P('eg.nazli', FZ)
g.reposition = {'EG_PTO', 'EG_ALI'}
g.write()
