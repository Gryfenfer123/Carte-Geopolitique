import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(119, "Syrie (Omeyyades) et Irak (Abbassides)")
g.notes = [
    "Deux nouveaux arbres : « Omeyyades » (Syrie) et « Abbassides » (Irak). Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.",
    "Dates en année chrétienne, telles que la page les donne ; quand la page propose plusieurs années (« 623 ou 626 »), la première est retenue et la fiche le dit. Date approximative signalée par « c. ».",
    "Liens « famille » (et non parent-enfant direct) quand un chaînon n'est pas saisi : Marwan Ier → Omar II et Marwan II ; Ali ibn Abdallah → al-Saffah et al-Mansur (leur père Muhammad ibn Ali n'a pas pu être lu) ; al-Mansur → Zubayda (sa petite-fille). Abou Soufyane et Marwan Ier appartiennent à la même famille Omeyya mais ne sont pas reliés.",
    "Non fait : autres califes omeyyades et abbassides, califes de Cordoue, califat du Caire.",
]
g.tree('SY_OME', 'SYR', 'Omeyyades', section_title='Omeyyades')
g.tree('IQ_ABB', 'IRQ', 'Abbassides', section_title='Abbassides')
P, S = g.par, g.sp
W = 'https://en.wikipedia.org/wiki/'
def M(code, name, b, d, title, page, dyn, tree, gnd='h', leader=True, note=None):
    return g.m('sy.' + code, name, b, d, title, dyn, tree, gnd, leader, src=W + page + (' — ' + note if note else ''))
U = lambda *a, **k: M(*a, dyn='Omeyyades', tree='SY_OME', **k)
U('sufyan', 'Abou Soufyane ibn Harb', 560, 653, 'Chef de La Mecque, père de Muawiya Ier', 'Abu_Sufyan_ibn_Harb', leader=False, note='naissance c. 560 ; mort 652 ou 653 (653 retenu)')
U('muawiya1', 'Muawiya Ier', 597, 680, 'Premier calife omeyyade (661-680)', 'Muawiya_I', note='naissance c. 597, 603 ou 605 (597 retenu)')
U('yazid1', 'Yazid Ier', 646, 683, 'Calife omeyyade (680-683)', 'Yazid_I', note='naissance c. 646')
U('muawiya2', 'Muawiya II', 664, 684, 'Calife omeyyade (683-684)', 'Muawiya_II', note='naissance c. 664')
U('marwan1', 'Marwan Ier', 623, 685, 'Calife omeyyade (684-685), fondateur de la branche marwanide', 'Marwan_I', note='naissance 623 ou 626 (623 retenu) ; père al-Hakam ibn Abi al-As')
U('abdmalik', 'Abd al-Malik', 644, 705, 'Calife omeyyade (685-705)', 'Abd_al-Malik_ibn_Marwan', note='naissance 644 ou 647 (644 retenu)')
U('walid1', 'Al-Walid Ier', 674, 715, 'Calife omeyyade (705-715)', 'Al-Walid_I', note='naissance c. 674')
U('sulayman', 'Sulayman ibn Abd al-Malik', 675, 717, 'Calife omeyyade (715-717)', 'Sulayman_ibn_Abd_al-Malik', note='naissance c. 675')
U('umar2', 'Omar II', 680, 720, 'Calife omeyyade (717-720)', 'Umar_ibn_Abd_al-Aziz', note='naissance c. 680 ; père Abd al-Aziz ibn Marwan (hors arbre)')
U('yazid2', 'Yazid II', 690, 724, 'Calife omeyyade (720-724)', 'Yazid_II', note='naissance c. 690/691')
U('hisham', 'Hicham ibn Abd al-Malik', 691, 743, 'Calife omeyyade (724-743)', 'Hisham_ibn_Abd_al-Malik')
U('marwan2', 'Marwan II', 691, 750, 'Dernier calife omeyyade (744-750)', 'Marwan_II', note='naissance c. 691 ; père Muhammad ibn Marwan (hors arbre)')
for a, b in [('sufyan', 'muawiya1'), ('muawiya1', 'yazid1'), ('yazid1', 'muawiya2'), ('marwan1', 'abdmalik'), ('abdmalik', 'walid1'), ('abdmalik', 'sulayman'), ('abdmalik', 'yazid2'), ('abdmalik', 'hisham')]:
    P('sy.' + a, 'sy.' + b)
g.fam('sy.marwan1', 'sy.umar2'); g.fam('sy.marwan1', 'sy.marwan2')
Ab = lambda *a, **k: M(*a, dyn='Abbassides', tree='IQ_ABB', **k)
Ab('abbas', 'Al-Abbas ibn Abd al-Muttalib', 566, 653, 'Oncle du prophète Mahomet, ancêtre des Abbassides', 'Al-Abbas_ibn_Abd_al-Muttalib', leader=False, note='dates c.')
Ab('abdullah', 'Abdallah ibn Abbas', 619, 687, 'Compagnon du prophète, ancêtre des Abbassides', 'Abdullah_ibn_Abbas', leader=False, note='naissance c. 619')
Ab('ali', 'Ali ibn Abdallah ibn Abbas', 661, 736, 'Ancêtre des califes abbassides', 'Ali_ibn_Abd_Allah_ibn_al-Abbas', leader=False, note='naissance c. 661')
Ab('saffah', 'Al-Saffah', 721, 754, 'Premier calife abbasside (750-754)', 'Al-Saffah', note='naissance 721 ou 722 (721 retenu) ; père Muhammad ibn Ali (non saisi)')
Ab('mansur', 'Al-Mansour', 714, 775, 'Calife abbasside (754-775), fondateur de Bagdad', 'Al-Mansur', note='père Muhammad ibn Ali (non saisi)')
Ab('mahdi', 'Al-Mahdi', 744, 785, 'Calife abbasside (775-785)', 'Al-Mahdi', note='naissance 744 ou 745 (744 retenu)')
Ab('hadi', 'Al-Hadi', 759, 786, 'Calife abbasside (785-786)', 'Al-Hadi', note='naissance 759 ou 762 (759 retenu)')
Ab('harun', 'Haroun al-Rachid', 763, 809, 'Calife abbasside (786-809)', 'Harun_al-Rashid', note='naissance c. 763 ou 766 (763 retenu)')
Ab('zubayda', 'Zubayda bint Jafar', 765, 831, 'Épouse de Haroun al-Rachid, mère d\'al-Amin', 'Zubaidah_bint_Ja%27far', gnd='f', leader=False, note='naissance 765 ou 766 (765 retenu) ; père Jafar ibn al-Mansour (hors arbre)')
Ab('amin', 'Al-Amin', 787, 813, 'Calife abbasside (809-813)', 'Al-Amin')
Ab('mamun', 'Al-Mamoun', 786, 833, 'Calife abbasside (813-833)', 'Al-Ma%27mun')
Ab('mutasim', 'Al-Moutassim', 796, 842, 'Calife abbasside (833-842)', 'Al-Mu%27tasim')
Ab('wathiq', 'Al-Wathiq', 812, 847, 'Calife abbasside (842-847)', 'Al-Wathiq')
Ab('mutawakkil', 'Al-Moutawakkil', 822, 861, 'Calife abbasside (847-861)', 'Al-Mutawakkil')
for a, b in [('abbas', 'abdullah'), ('abdullah', 'ali'), ('mansur', 'mahdi'), ('mahdi', 'hadi'), ('mahdi', 'harun'), ('harun', 'amin'), ('zubayda', 'amin'),
             ('harun', 'mamun'), ('harun', 'mutasim'), ('mutasim', 'wathiq'), ('mutasim', 'mutawakkil')]:
    P('sy.' + a, 'sy.' + b)
g.fam('sy.ali', 'sy.saffah'); g.fam('sy.ali', 'sy.mansur'); g.fam('sy.mansur', 'sy.zubayda')
S('sy.harun', 'sy.zubayda')
g.write()
