import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *
from src_outil import appliquer

g = Gen(114, "Sources et corrections — Bagrationi, Arménie, Hasmonéens et Hérodiens (v109)")
g.sans_repositionnement = True
g.notes = [
    "Les 40 fiches du lot v109 reçoivent l'adresse de leur page Wikipédia dans « Notes / biographie ». Dates comparées aux pages et corrigées si besoin.",
    "ERREUR DE MA PART À SIGNALER : David VII Oulou est le fils de Georges IV Lacha (page de David VII), pas de Rousoudan. J'ajoute le lien Georges IV → David VII ; l'ancien lien Rousoudan → David VII reste en base, car je ne supprime rien sans ton accord (à supprimer, voir la liste « à faire »).",
    "Deux naissances que j'avais inventées sont retirées (Georges II et Georges III de Géorgie : la page n'en donne pas), ainsi que celles d'Aristobule II et de Mariamne l'Hasmonéenne.",
]
for k, d_, c in [('GE_BAG', 'Bagrationi', 'GEO'), ('AM_DYN', 'Dynasties d\'Arménie', 'ARM'), ('IL_HAS', 'Hasmonéens et Hérodiens', 'ISR')]:
    g.tree(k, c, d_)
W = 'en:'
L = [
 ('cx.bagrat3', '=', '=', W+'Bagrat_III_of_Georgia', 'naissance c. 960 ; père Gurgen d\'Ibérie, mère Gurandukht d\'Abkhazie (hors arbre)'),
 ('cx.george1', '=', '=', W+'George_I_of_Georgia', 'naissance 998 ou 1002 (998 retenu)'),
 ('cx.bagrat4', '=', '=', W+'Bagrat_IV_of_Georgia', None),
 ('cx.george2', None, '=', W+'George_II_of_Georgia', 'naissance inconnue (la page n\'en donne pas)'),
 ('cx.david4', '=', '=', W+'David_IV_of_Georgia', None),
 ('cx.demetre1', '=', '=', W+'Demetrius_I_of_Georgia', 'naissance c. 1093'),
 ('cx.george3', None, '=', W+'George_III_of_Georgia', 'naissance inconnue (la page n\'en donne pas)'),
 ('cx.tamar', '=', '=', W+'Tamar_of_Georgia', 'naissance c. 1160 ou c. 1166 (1160 retenu)'),
 ('cx.lasha', '=', '=', W+'George_IV_of_Georgia', 'père David Soslan (hors arbre), mère Tamar'),
 ('cx.rusudan', '=', '=', W+'Rusudan_of_Georgia', 'père David Soslan (hors arbre), mère Tamar'),
 ('cx.david7', '=', '=', W+'David_VII_of_Georgia', 'fils de Georges IV Lacha (pas de Rousoudan)'),
 ('cx.teimuraz2', 1695, '=', W+'Teimuraz_II_of_Kakheti', 'père Héraclius Ier de Kakhétie (hors arbre)'),
 ('cx.erekle2', '=', '=', W+'Heraclius_II_of_Georgia', None),
 ('cx.george12', '=', '=', W+'George_XII_of_Georgia', None),
 ('cx.tigrane', '=', '=', W+'Tigranes_the_Great', 'naissance 140 av. J.-C. ; père Artavazde Ier ou Tigrane Ier, mère probablement Cléopâtre du Pont (hors arbre)'),
 ('cx.artavazde', '=', '=', W+'Artavasdes_II_of_Armenia', 'fils de Tigrane II'),
 ('cx.ashot1', '=', '=', W+'Ashot_I_of_Armenia', 'naissance c. 820 ; père Smbat VIII le Confesseur (hors arbre)'),
 ('cx.smbat1', '=', '=', W+'Smbat_I_of_Armenia', 'naissance c. 850 ; mort en 912 ou 914 (914 retenu)'),
 ('cx.ashot2', '=', '=', W+'Ashot_II_of_Armenia', 'fils de Smbat Ier'),
 ('cx.gagik1', '=', '=', W+'Gagik_I_of_Armenia', 'père Ashot III (hors arbre) ; mort c. 1017/1020'),
 ('cx.mattathias', '=', '=', W+'Mattathias', None),
 ('cx.judas', '=', '=', W+'Judas_Maccabeus', None),
 ('cx.simon', -184, '=', W+'Simon_Thassi', 'mort en 135 ou 134 av. J.-C.'),
 ('cx.hyrcan1', '=', '=', W+'John_Hyrcanus', None),
 ('cx.aristobule1', '=', '=', W+'Aristobulus_I', None),
 ('cx.jannee', -130, '=', W+'Alexander_Jannaeus', 'naissance c. 130 av. J.-C.'),
 ('cx.salome', -141, '=', W+'Salome_Alexandra', None),
 ('cx.hyrcan2', '=', '=', W+'Hyrcanus_II', 'naissance c. 110 av. J.-C.'),
 ('cx.aristobule2', None, '=', W+'Aristobulus_II', 'naissance inconnue (la page n\'en donne pas)'),
 ('cx.antigone', '=', '=', W+'Antigonus_II_Mattathias', None),
 ('cx.alexandra', '=', -28, W+'Alexandra_the_Maccabee', 'mort c. 28 av. J.-C. ; fille d\'Hyrcan II'),
 ('cx.mariamne', None, '=', W+'Mariamne_I', 'naissance inconnue ; père Alexandre de Judée (hors arbre), mère Alexandra la Hasmonéenne'),
 ('cx.herode', -72, '=', W+'Herod_the_Great', 'naissance c. 72 av. J.-C. ; mort en 4 ou 1 av. J.-C. ; père Antipater l\'Iduméen, mère Cypros (hors arbre)'),
 ('cx.aristobule4', -31, -7, W+'Aristobulus_IV', None),
 ('cx.antipas', '=', '=', W+'Herod_Antipas', 'mère Malthace'),
 ('cx.archelaus', '=', '=', W+'Herod_Archelaus', 'mère Malthace'),
 ('cx.philippe', '=', '=', W+'Philip_the_Tetrarch', 'mère Cléopâtre de Jérusalem'),
 ('cx.agrippa1', -11, '=', W+'Herod_Agrippa', 'naissance c. 11 av. J.-C. ; père Aristobule IV'),
 ('cx.agrippa2', '=', '=', W+'Agrippa_II', 'mort c. 92 ou 100 (100 retenu)'),
 ('cx.berenice', '=', '=', W+'Berenice_(daughter_of_Herod_Agrippa)', 'morte après 81 ; mère Cypros'),
]
appliquer(g, L)
g.par('cx.lasha', 'cx.david7')
g.write()
