import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(118, "Égypte — XVIIIe et XIXe dynasties, Fatimides, Ayyoubides")
g.notes = [
    "Quatre nouveaux arbres égyptiens : « Dynastie XVIII », « Dynastie XIX », « Fatimides », « Ayyoubides ». Chaque fiche porte, dans « Notes / biographie », l'adresse de sa page Wikipédia (anglais) ; sources aussi dans docs/sources/arbres.md.",
    "Dates : uniquement celles que la page donne. Pour beaucoup de pharaons la page ne donne que le règne (chronologie incertaine) : naissance et mort laissées vides, règne écrit dans le titre. Dates approximatives (« c. ») signalées. Années avant J.-C. en négatif.",
    "Non fait (volontairement, faute de sources fiables saisies) : autres pharaons et dynasties, Fatimides après al-Mustansir, Ayyoubides après as-Salih Ayyub, Mamelouks, pères/mères hors arbre.",
]
g.tree('EG_18', 'EGY', 'Dynastie XVIII', section_title='Dynastie XVIII')
g.tree('EG_19', 'EGY', 'Dynastie XIX', section_title='Dynastie XIX')
g.tree('EG_FAT', 'EGY', 'Fatimides', section_title='Fatimides')
g.tree('EG_AYY', 'EGY', 'Ayyoubides', section_title='Ayyoubides')
P, S = g.par, g.sp
W = 'https://en.wikipedia.org/wiki/'
def M(code, name, b, d, title, page, dyn=None, tree=None, gnd='h', leader=True, approx=None, flag=None, note=None):
    return g.m('eg2.' + code, name, b, d, title, dyn, tree, gnd, leader, approx=approx, flag=flag, src=W + page + (' — ' + note if note else ''))
D18 = 'Dynastie XVIII'
A = lambda *a, **k: M(*a, dyn=D18, tree='EG_18', **k)
A('ahmose1', 'Ahmôsis Ier', None, None, 'Pharaon, fondateur de la XVIIIe dynastie (règne : 1570-1546 av. J.-C., chronologie « haute »)', 'Ahmose_I', note='dates de vie non données, règne seul ; parents : Séqénenrê Taa et Ahhotep Ire (hors arbre)')
A('ahmosen', 'Ahmès-Néfertary', None, None, 'Grande épouse royale, épouse de son frère Ahmôsis Ier', 'Ahmose-Nefertari', gnd='f', leader=False, note='dates non données')
A('amenhotep1', 'Amenhotep Ier', None, None, 'Pharaon (règne : c. 1526-1506 av. J.-C., chronologie « basse »)', 'Amenhotep_I', note='dates de vie non données, règne seul')
A('thutmose1', 'Thoutmôsis Ier', None, -1493, 'Pharaon (règne : c. 1505-1493 av. J.-C.)', 'Thutmose_I', note='père inconnu, mère Senseneb', flag='Père inconnu (non saisi)', approx='Mort c. 1493 av. J.-C.')
A('thutmose2', 'Thoutmôsis II', None, -1479, 'Pharaon (règne : 1493-1479 av. J.-C.)', 'Thutmose_II', note='naissance incertaine (c. 1502 ou c. 1492) donc laissée vide ; mère Moutnofret (hors arbre)')
A('hatshepsut', 'Hatchepsout', -1505, -1458, 'Reine puis pharaon (règne c. 1479-1458 av. J.-C.)', 'Hatshepsut', gnd='f', approx='Naissance et mort c.')
A('thutmose3', 'Thoutmôsis III', None, None, 'Pharaon (règne : 1479-1425 av. J.-C.)', 'Thutmose_III', note='dates de vie non données, règne seul ; mère Iset (hors arbre)')
A('amenhotep2', 'Amenhotep II', -1443, -1401, 'Pharaon', 'Amenhotep_II', approx='Dates c.', note='mère Merytre-Hatchepsout (hors arbre)')
A('thutmose4', 'Thoutmôsis IV', None, -1391, 'Pharaon', 'Thutmose_IV', note='mort en 1391 ou 1388 av. J.-C. (1391 retenu) ; naissance non donnée ; mère Tiaa (hors arbre)')
A('amenhotep3', 'Amenhotep III', -1401, -1353, 'Pharaon', 'Amenhotep_III', approx='Dates c. ; mort 1353 ou 1351', note='mère Moutemouia (hors arbre)')
A('tiye', 'Tiyi', -1398, -1338, 'Grande épouse royale d\'Amenhotep III', 'Tiye', gnd='f', leader=False, approx='Dates c.', note='parents Youya et Touya (hors arbre)')
A('akhenaten', 'Akhénaton', None, None, 'Pharaon (règne : c. 1353-1336 av. J.-C.)', 'Akhenaten', note='dates de vie non données, règne seul')
A('nefertiti', 'Néfertiti', -1370, -1330, 'Grande épouse royale d\'Akhénaton', 'Nefertiti', gnd='f', leader=False, approx='Dates c. ; parents non confirmés')
A('tut', 'Toutânkhamon', -1342, -1323, 'Pharaon', 'Tutankhamun', approx='Dates c.', note='père : Akhénaton ou Smenkhkarê selon la page ; mère « la Jeune Dame » (hors arbre)')
A('ankh', 'Ânkhesenamon', -1348, None, 'Grande épouse royale de Toutânkhamon', 'Ankhesenamun', gnd='f', leader=False, approx='Naissance c. 1348 ou c. 1342 ; morte après 1322')
for a, b in [('ahmose1', 'amenhotep1'), ('ahmosen', 'amenhotep1'), ('thutmose1', 'thutmose2'), ('thutmose1', 'hatshepsut'), ('thutmose2', 'thutmose3'),
             ('thutmose3', 'amenhotep2'), ('amenhotep2', 'thutmose4'), ('thutmose4', 'amenhotep3'), ('amenhotep3', 'akhenaten'), ('tiye', 'akhenaten'),
             ('akhenaten', 'tut'), ('akhenaten', 'ankh'), ('nefertiti', 'ankh')]:
    P('eg2.' + a, 'eg2.' + b)
S('eg2.ahmose1', 'eg2.ahmosen'); S('eg2.thutmose2', 'eg2.hatshepsut'); S('eg2.amenhotep3', 'eg2.tiye'); S('eg2.akhenaten', 'eg2.nefertiti'); S('eg2.tut', 'eg2.ankh')
D19 = 'Dynastie XIX'
B = lambda *a, **k: M(*a, dyn=D19, tree='EG_19', **k)
B('ramses1', 'Ramsès Ier', None, -1290, 'Pharaon, fondateur de la XIXe dynastie (règne : 1292-1290 ou 1295-1294 av. J.-C.)', 'Ramesses_I', note='mort en 1290 ou 1294 av. J.-C. (1290 retenu) ; père Séti, mère inconnue')
B('seti1', 'Séthi Ier', None, None, 'Pharaon (règne : 1290-1279 av. J.-C.)', 'Seti_I', note='dates de vie non données, règne seul ; mère Sitrê (hors arbre)')
B('tuya', 'Touya', None, -1257, 'Grande épouse royale de Séthi Ier, mère de Ramsès II', 'Tuya_(queen)', gnd='f', leader=False, approx='Mort c. 1257', note='parents Raia et Rouia (hors arbre)')
B('ramses2', 'Ramsès II', -1303, -1213, 'Pharaon (règne : 1279-1213 av. J.-C.)', 'Ramesses_II', approx='Naissance c. 1303')
B('nefertari', 'Néfertari', None, -1255, 'Grande épouse royale de Ramsès II', 'Nefertari', gnd='f', leader=False, approx='Mort c. 1255 ; naissance et parents inconnus')
B('merneptah', 'Mérenptah', -1263, -1203, 'Pharaon (règne : 1213-1203 av. J.-C.)', 'Merneptah', approx='Dates c.', note='mère Isetnofret (hors arbre)')
for a, b in [('ramses1', 'seti1'), ('seti1', 'ramses2'), ('tuya', 'ramses2'), ('ramses2', 'merneptah')]:
    P('eg2.' + a, 'eg2.' + b)
S('eg2.seti1', 'eg2.tuya'); S('eg2.ramses2', 'eg2.nefertari')
F = lambda *a, **k: M(*a, dyn='Fatimides', tree='EG_FAT', **k)
F('mahdi', 'Al-Mahdi Billah', 874, 934, 'Premier calife fatimide (909-934)', 'Abdallah_al-Mahdi_Billah', note='père al-Husayn')
F('qaim', 'Al-Qaïm bi-Amr Allah', 893, 946, 'Calife fatimide (934-946)', 'Al-Qa%27im_(Fatimid_caliph)', approx='Naissance mars/avril 893')
F('mansur', 'Al-Mansur Billah', 914, 953, 'Calife fatimide (946-953)', 'Al-Mansur_Billah')
F('muizz', 'Al-Mouizz li-Din Allah', 931, 975, 'Calife fatimide (953-975), conquiert l\'Égypte', 'Al-Mu%27izz_li-Din_Allah')
F('aziz', 'Al-Aziz Billah', 955, 996, 'Calife fatimide (975-996)', 'Al-Aziz_Billah')
F('hakim', 'Al-Hakim bi-Amr Allah', 985, 1021, 'Calife fatimide (996-1021)', 'Al-Hakim_bi-Amr_Allah')
F('zahir', 'Az-Zahir li-Izaz Din Allah', 1005, 1036, 'Calife fatimide (1021-1036)', 'Al-Zahir_li-I%27zaz_Din_Allah')
F('mustansir', 'Al-Moustansir Billah', 1029, 1094, 'Calife fatimide (1036-1094)', 'Al-Mustansir_Billah')
for a, b in [('mahdi', 'qaim'), ('qaim', 'mansur'), ('mansur', 'muizz'), ('muizz', 'aziz'), ('aziz', 'hakim'), ('hakim', 'zahir'), ('zahir', 'mustansir')]:
    P('eg2.' + a, 'eg2.' + b)
Y = lambda *a, **k: M(*a, dyn='Ayyoubides', tree='EG_AYY', **k)
Y('ayyub', 'Najm ad-Din Ayyub', None, 1173, 'Père de Saladin et d\'al-Adil, gouverneur de Damas', 'Najm_ad-Din_Ayyub', leader=False, note='père Shadhi ibn Marwan (hors arbre) ; naissance inconnue')
Y('saladin', 'Saladin', 1137, 1193, 'Sultan d\'Égypte et de Syrie, fondateur des Ayyoubides', 'Saladin', approx='Naissance c. 1137')
Y('adil1', 'Al-Adil Ier', 1145, 1218, 'Sultan d\'Égypte (1200-1218), frère de Saladin', 'Al-Adil_I')
Y('kamil', 'Al-Kamil', 1177, 1238, 'Sultan d\'Égypte (1218-1238)', 'Al-Kamil')
Y('salih', 'As-Salih Ayyub', 1205, 1249, 'Sultan d\'Égypte (1240-1249)', 'As-Salih_Ayyub', note='mère Ward al-Muna')
for a, b in [('ayyub', 'saladin'), ('ayyub', 'adil1'), ('adil1', 'kamil'), ('kamil', 'salih')]:
    P('eg2.' + a, 'eg2.' + b)
g.write()
