import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(104, "Iran — Achéménides, Sassanides, Safavides, Qajars et Pahlavi")
g.notes = [
    "Cinq nouveaux arbres pour l'Iran (aucun n'existait) : « Achéménides », « Sassanides », « Safavides », « Qajars », « Pahlavi ». Rien n'est supprimé.",
    "Dates : connues par ailleurs (histoire de l'Iran), aucune page consultée pour ce lot. Années avant J.-C. en négatif ; naissances des Achéménides et Sassanides anciens laissées vides quand elles sont inconnues (signalé).",
    "Succession : les liens père-fils suivent les listes classiques ; les passages par un autre rameau (Darius Ier, Darius III, Yazdgard III, Fath Ali Shah) sont des liens « famille ».",
    "Épouses des Pahlavi (Fawzia d'Égypte, Soraya, Farah Diba) : familles sans arbre pour l'instant, signalées ; Fawzia sera liée quand l'arbre égyptien existera.",
    "Non fait : Parthes, Afsharides, Zands, Buyides, Seldjoukides, Ghaznévides, épouses et cadets.",
]
for k, n in [('IR_ACH', 'Achéménides'), ('IR_SAS', 'Sassanides'), ('IR_SAF', 'Safavides'), ('IR_QAJ', 'Qajars'), ('IR_PAH', 'Pahlavi')]:
    g.tree(k, 'IRN', n, section_title=n)
P, S = g.par, g.sp
def M(code, name, b, d, title, dyn, tree, g_='h', leader=True, approx=None, flag=None):
    return g.m('ir.' + code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
NB = 'Naissance inconnue.'
A = 'Achéménides'
M('cyrus', 'Cyrus II le Grand', None, -530, 'Fondateur de l\'Empire achéménide (-559 à -530)', A, 'IR_ACH', approx=NB)
M('cambyse', 'Cambyse II', None, -522, 'Roi des rois (-530 à -522), conquiert l\'Égypte', A, 'IR_ACH', approx=NB)
M('darius1', 'Darius Ier', -550, -486, 'Roi des rois (-522 à -486)', A, 'IR_ACH')
M('xerxes1', 'Xerxès Ier', -518, -465, 'Roi des rois (-486 à -465), guerres médiques', A, 'IR_ACH')
M('artax1', 'Artaxerxès Ier', None, -424, 'Roi des rois (-465 à -424)', A, 'IR_ACH', approx=NB)
M('darius2', 'Darius II', None, -404, 'Roi des rois (-423 à -404)', A, 'IR_ACH', approx=NB)
M('artax2', 'Artaxerxès II', -445, -358, 'Roi des rois (-404 à -358)', A, 'IR_ACH', approx='Naissance vers -445 (certaines sources donnent -436).')
M('artax3', 'Artaxerxès III', -425, -338, 'Roi des rois (-358 à -338)', A, 'IR_ACH')
M('arses', 'Arsès (Artaxerxès IV)', None, -336, 'Roi des rois (-338 à -336)', A, 'IR_ACH', approx=NB)
M('darius3', 'Darius III', -380, -330, 'Dernier roi des rois (-336 à -330), vaincu par Alexandre', A, 'IR_ACH')
P('ir.cyrus', 'ir.cambyse'); g.fam('ir.cyrus', 'ir.darius1'); P('ir.darius1', 'ir.xerxes1'); P('ir.xerxes1', 'ir.artax1')
P('ir.artax1', 'ir.darius2'); P('ir.darius2', 'ir.artax2'); P('ir.artax2', 'ir.artax3'); P('ir.artax3', 'ir.arses')
g.fam('ir.darius2', 'ir.darius3')
SS = 'Sassanides'
M('ardashir', 'Ardachîr Ier', None, 242, 'Fondateur de l\'Empire sassanide (224-242)', SS, 'IR_SAS', approx=NB)
M('shapur1', 'Shapur Ier', None, 270, 'Roi des rois (240-270), capture l\'empereur Valérien', SS, 'IR_SAS', approx=NB)
M('narseh', 'Narsès', None, 302, 'Roi des rois (293-302)', SS, 'IR_SAS', approx=NB)
M('hormizd2', 'Hormizd II', None, 309, 'Roi des rois (302-309)', SS, 'IR_SAS', approx=NB)
M('shapur2', 'Shapur II le Grand', 309, 379, 'Roi des rois (309-379), roi dès sa naissance', SS, 'IR_SAS')
M('kavad1', 'Kavadh Ier', 473, 531, 'Roi des rois (488-531)', SS, 'IR_SAS')
M('khosrow1', 'Khosro Ier Anushirvan', 501, 579, 'Roi des rois (531-579)', SS, 'IR_SAS', approx='Naissance vers 501.')
M('hormizd4', 'Hormizd IV', None, 590, 'Roi des rois (579-590)', SS, 'IR_SAS', approx=NB)
M('khosrow2', 'Khosro II Parviz', 570, 628, 'Roi des rois (590-628), dernière grande guerre contre Byzance', SS, 'IR_SAS', approx='Naissance vers 570.')
M('kavad2', 'Kavadh II', None, 628, 'Roi des rois (628)', SS, 'IR_SAS', approx=NB)
M('yazdegerd3', 'Yazdgard III', 624, 651, 'Dernier roi des rois (632-651), vaincu par les Arabes', SS, 'IR_SAS', approx='Naissance vers 624.')
for a, b in [('ardashir', 'shapur1'), ('shapur1', 'narseh'), ('narseh', 'hormizd2'), ('hormizd2', 'shapur2'), ('kavad1', 'khosrow1'),
             ('khosrow1', 'hormizd4'), ('hormizd4', 'khosrow2'), ('khosrow2', 'kavad2')]:
    P('ir.' + a, 'ir.' + b)
g.fam('ir.shapur2', 'ir.kavad1'); g.fam('ir.khosrow2', 'ir.yazdegerd3')
SF = 'Safavides'
M('haydar', 'Cheikh Haydar', 1459, 1488, 'Chef de l\'ordre safavide, père d\'Ismaïl Ier', SF, 'IR_SAF', leader=False)
M('ismail1', 'Ismaïl Ier', 1487, 1524, 'Fondateur de l\'Empire safavide (1501-1524)', SF, 'IR_SAF')
M('tahmasp1', 'Tahmasp Ier', 1514, 1576, 'Shah (1524-1576)', SF, 'IR_SAF')
M('ismail2', 'Ismaïl II', 1537, 1577, 'Shah (1576-1577)', SF, 'IR_SAF')
M('khoda', 'Mohammad Khodabanda', 1531, 1595, 'Shah (1578-1587)', SF, 'IR_SAF')
M('abbas1', 'Abbas Ier le Grand', 1571, 1629, 'Shah (1588-1629)', SF, 'IR_SAF')
M('baqir', 'Mohammad Baqir Mirza', 1587, 1615, 'Prince héritier, père de Safi Ier', SF, 'IR_SAF', leader=False, approx='Naissance vers 1587, exécuté par son père.')
M('safi', 'Safi Ier', 1611, 1642, 'Shah (1629-1642)', SF, 'IR_SAF')
M('abbas2', 'Abbas II', 1632, 1666, 'Shah (1642-1666)', SF, 'IR_SAF')
M('suleiman', 'Soleiman Ier', 1647, 1694, 'Shah (1666-1694)', SF, 'IR_SAF')
M('husayn', 'Soltan Hosein', 1668, 1726, 'Shah (1694-1722), renversé par les Afghans', SF, 'IR_SAF')
M('tahmasp2', 'Tahmasp II', 1704, 1740, 'Shah (1722-1732)', SF, 'IR_SAF')
M('abbas3', 'Abbas III', 1732, 1740, 'Shah (1732-1736), enfant déposé par Nader Shah', SF, 'IR_SAF')
for a, b in [('haydar', 'ismail1'), ('ismail1', 'tahmasp1'), ('tahmasp1', 'ismail2'), ('tahmasp1', 'khoda'), ('khoda', 'abbas1'),
             ('abbas1', 'baqir'), ('baqir', 'safi'), ('safi', 'abbas2'), ('abbas2', 'suleiman'), ('suleiman', 'husayn'),
             ('husayn', 'tahmasp2'), ('tahmasp2', 'abbas3')]:
    P('ir.' + a, 'ir.' + b)
QJ = 'Qajars'
M('hosseinqoli', 'Hosein Qoli Khan Qajar', 1722, 1777, 'Chef qajar, père de Fath Ali Shah', QJ, 'IR_QAJ', leader=False, approx='Naissance vers 1722.')
M('agha', 'Agha Mohammad Khan', 1742, 1797, 'Fondateur de la dynastie qajare (1789-1797)', QJ, 'IR_QAJ')
M('fathali', 'Fath Ali Shah', 1772, 1834, 'Shah (1797-1834)', QJ, 'IR_QAJ')
M('abbasm', 'Abbas Mirza', 1789, 1833, 'Prince héritier réformateur', QJ, 'IR_QAJ', leader=False)
M('mohammad', 'Mohammad Shah', 1808, 1848, 'Shah (1834-1848)', QJ, 'IR_QAJ')
M('naser', 'Nasser ed-Din Shah', 1831, 1896, 'Shah (1848-1896), assassiné', QJ, 'IR_QAJ')
M('mozaffar', 'Mozaffar ed-Din Shah', 1853, 1907, 'Shah (1896-1907), accorde la Constitution', QJ, 'IR_QAJ')
M('mohammadali', 'Mohammad Ali Shah', 1872, 1925, 'Shah (1907-1909), déposé', QJ, 'IR_QAJ')
M('ahmad', 'Ahmad Shah', 1898, 1930, 'Dernier shah qajar (1909-1925)', QJ, 'IR_QAJ')
P('ir.hosseinqoli', 'ir.fathali'); g.fam('ir.agha', 'ir.fathali'); g.fam('ir.agha', 'ir.hosseinqoli')
P('ir.fathali', 'ir.abbasm'); P('ir.abbasm', 'ir.mohammad'); P('ir.mohammad', 'ir.naser'); P('ir.naser', 'ir.mozaffar')
P('ir.mozaffar', 'ir.mohammadali'); P('ir.mohammadali', 'ir.ahmad')
PH = 'Pahlavi'
M('reza', 'Reza Shah', 1878, 1944, 'Fondateur de la dynastie Pahlavi (1925-1941)', PH, 'IR_PAH')
M('mreza', 'Mohammad Reza Pahlavi', 1919, 1980, 'Shah d\'Iran (1941-1979), renversé par la révolution', PH, 'IR_PAH')
M('soraya', 'Soraya Esfandiary-Bakhtiari', 1932, 2001, 'Deuxième épouse du shah, répudiée', PH, 'IR_PAH', 'f', False, flag='Famille Bakhtiari : sans arbre')
M('farah', 'Farah Diba', 1938, None, 'Impératrice d\'Iran, troisième épouse du shah', PH, 'IR_PAH', 'f', False, flag='Famille Diba : sans arbre')
M('fawzia', 'Fawzia d\'Égypte', 1921, 2013, 'Première épouse du shah, princesse d\'Égypte', PH, 'IR_PAH', 'f', False, flag='Dynastie de Mehmet Ali (Égypte) : arbre à créer')
M('reza2', 'Reza Pahlavi', 1960, None, 'Prince héritier, prétendant au trône', PH, 'IR_PAH', leader=False)
P('ir.reza', 'ir.mreza'); S('ir.mreza', 'ir.fawzia'); S('ir.mreza', 'ir.soraya'); S('ir.mreza', 'ir.farah')
P('ir.mreza', 'ir.reza2'); P('ir.farah', 'ir.reza2')
g.reposition = {'IR_ACH', 'IR_SAS', 'IR_SAF', 'IR_QAJ', 'IR_PAH'}
g.write()
