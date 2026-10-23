import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(47, "Serbie — Nemanjić, Lazarević, Branković, Obrenović, Karađorđević")
g.notes = [
    "Crée sous Serbie > Dynastie : Nemanjić (Stefan Nemanja -> Uroš V), Lazarević (Lazar -> Stefan), Branković (Vuk -> Jovan), Obrenović (Miloš -> Alexandre), Karađorđević (Karađorđe -> Pierre II -> Alexandre). La Yougoslavie est incluse dans l'arbre Karađorđević (même dynastie).",
    "Dates : seules celles figurant sur Wikipédia ou connues avec certitude sont saisies ; les autres sont vides ou notées « environ » dans le rapport.",
    "Filiation de Dragana (épouse d'Ivan Chichman) : la page Wikipédia « Lazarević » la donne fille de Lazar ; point discuté entre historiens — à vérifier.",
    "Déplacés dans leur vrai arbre : Dragana (Chichman -> Lazarević) et Jelena Branković (Mușat -> Branković).",
    "Créés dans l'arbre d'origine : Catherine de Hongrie (Árpád), Hélène de Bulgarie (Chichman), Anne de Valachie (Basarab), Alexandra et Olga de Grèce + Nicolas (Glücksbourg).",
    "Zorka du Monténégro (épouse de Pierre Ier) est placée provisoirement dans l'arbre Karađorđević, signalée : à déplacer vers l'arbre Petrović-Njegoš.",
    "Prérequis : v46 exécuté.",
]
g.tree('SR_NEM', 'SRB', 'Nemanjić')
g.tree('SR_LAZ', 'SRB', 'Lazarević')
g.tree('SR_BRA', 'SRB', 'Branković')
g.tree('SR_OBR', 'SRB', 'Obrenović')
g.tree('SR_KAR', 'SRB', 'Karađorđević')
g.tree('HU_ARP', 'HUN', 'Árpád')
g.tree('BG_CHI', 'BGR', 'Chichman')
g.tree('RO_BAS', 'ROU', 'Basarab')
g.tree('RO_HOH', 'ROU', 'Hohenzollern-Sigmaringen')
g.tree('RO_MUS', 'ROU', 'Mușat')
g.tree('GR_GLU', 'GRC', 'Glücksbourg')
g.tree('RU_ROM', 'RUS', 'Romanov')
g.reposition = {'HU_ARP', 'BG_CHI', 'RO_BAS', 'RO_MUS', 'GR_GLU', 'RU_ROM', 'RO_HOH'}
FB = {'sr.anastasia': 1120, 'sr.vukan': 1160, 'sr.eudokia': 1170, 'sr.dandolo': 1180, 'sr.radoslav': 1192, 'sr.vladislav': 1195,
      'sr.helen': 1224, 'sr.anna_terter': 1260, 'sr.simonida': 1294, 'sr.theodora_s': 1290, 'sr.maria_pal': 1295,
      'sr.constance': 1275, 'hu.catherine': 1256, 'bg.helena': 1313, 'ro.anna_w': 1340, 'sr.vladislav2': 1270,
      'sr.sava': 1171, 'bg.dragana': 1360, 'sr.mara_l': 1370, 'sr.vuk_l': 1375, 'sr.jelena_l': 1365,
      'sr.helena_g': 1385, 'sr.irene_k': 1400, 'sr.angelina': 1440, 'sr.helena_pal': 1428, 'sr.jakšić': 1470,
      'sr.jelena_j': 1470, 'sr.jelena_kar': 1770, 'sr.persida': 1813,
      'sr.arsen_aurora': 1873, 'sr.elena_c': 1835, 'sr.katherine': 1949}
Gen.FIXB = {uid('member:' + c): y for c, y in FB.items()}
P, S = g.par, g.sp
NE, LA, BR, OB, KA = 'Nemanjić', 'Lazarević', 'Branković', 'Obrenović', 'Karađorđević'

# ---------- Nemanjić
g.m('sr.nemanja', 'Stefan Nemanja', 1113, 1199, 'Grand-župan de Rascie (1166-1196), fondateur de la dynastie', NE, 'SR_NEM', 'h', True, approx='naissance 1113 ou 1114')
g.m('sr.anastasia', 'Ana (Anastasia), épouse de Stefan Nemanja', None, None, 'Grande-župane', 'Origine serbe (sans précision)', 'SR_NEM', 'f', flag='Origine serbe non précisée : sans arbre', approx='dates non renseignées')
g.m('sr.vukan', 'Vukan Nemanjić', None, None, 'Prince de Dioclée, grand-prince (1202-1204)', NE, 'SR_NEM', 'h', True, approx='naissance non renseignée')
g.m('sr.sava', 'Rastko Nemanjić (saint Sava)', 1171, 1236, 'Premier archevêque de Serbie, saint', NE, 'SR_NEM', 'h', approx='naissance 1171 selon Wikipédia anglais ; d\'autres sources donnent 1174')
g.m('sr.stefan1', 'Stefan le Premier Couronné', 1165, 1228, 'Grand-prince puis premier roi de Serbie (1196-1228)', NE, 'SR_NEM', 'h', True, approx='naissance « vers 1165 »')
P('sr.nemanja', 'sr.vukan'); P('sr.anastasia', 'sr.vukan')
P('sr.nemanja', 'sr.sava'); P('sr.anastasia', 'sr.sava')
P('sr.nemanja', 'sr.stefan1'); P('sr.anastasia', 'sr.stefan1')
S('sr.nemanja', 'sr.anastasia')
g.m('sr.eudokia', 'Eudokia Angelina', None, None, 'Reine de Serbie', 'Ange (Byzance)', 'SR_NEM', 'f', flag='Maison Ange (Empire byzantin) : arbre à créer avec la Grèce/Turquie ; dates non renseignées', approx='dates non renseignées')
g.m('sr.dandolo', 'Anna Dandolo', None, None, 'Reine de Serbie', 'Dandolo (Venise)', 'SR_NEM', 'f', flag='Famille Dandolo (Venise) : sans arbre ; dates non renseignées', approx='dates non renseignées')
S('sr.stefan1', 'sr.eudokia'); S('sr.stefan1', 'sr.dandolo')
g.m('sr.radoslav', 'Stefan Radoslav', None, None, 'Roi de Serbie (1228-1233)', NE, 'SR_NEM', 'h', True, approx='naissance non renseignée')
g.m('sr.vladislav', 'Stefan Vladislav Ier', None, None, 'Roi de Serbie (1233-1243)', NE, 'SR_NEM', 'h', True, approx='naissance non renseignée')
g.m('sr.uros1', 'Stefan Uroš Ier', 1223, 1277, 'Roi de Serbie (1243-1276)', NE, 'SR_NEM', 'h', True, approx='naissance « vers 1223 »')
for c in ('sr.radoslav', 'sr.vladislav'):
    P('sr.stefan1', c); P('sr.eudokia', c)
P('sr.stefan1', 'sr.uros1'); P('sr.dandolo', 'sr.uros1')
g.m('sr.helen', 'Hélène (sainte Hélène de Serbie)', None, 1314, 'Reine de Serbie', 'Origine incertaine (longtemps dite d\'Anjou)', 'SR_NEM', 'f', flag='Ascendance non établie (longtemps dite « d\'Anjou ») : sans arbre', approx='naissance non renseignée')
S('sr.uros1', 'sr.helen')
g.m('sr.dragutin', 'Stefan Dragutin', 1244, 1316, 'Roi de Serbie (1276-1282), roi de Syrmie', NE, 'SR_NEM', 'h', True, approx='naissance estimée vers 1244 (historien Purković) ; inconnue')
g.m('sr.milutin', 'Stefan Uroš II Milutin', 1253, 1321, 'Roi de Serbie (1282-1321)', NE, 'SR_NEM', 'h', True, approx='naissance « vers 1253 » (non revérifiée sur la page)')
for c in ('sr.dragutin', 'sr.milutin'):
    P('sr.uros1', c); P('sr.helen', c)
g.m('hu.catherine', 'Catherine de Hongrie (reine de Serbie)', None, None, 'Reine de Serbie et de Syrmie', 'Árpád', 'HU_ARP', 'f', approx='naissance et mort non renseignées')
P('hu.stephen5', 'hu.catherine'); P('hu.elisabeth_cu', 'hu.catherine')
S('sr.dragutin', 'hu.catherine')
g.m('sr.vladislav2', 'Stefan Vladislav II', None, None, 'Roi de Syrmie (1316-1325)', NE, 'SR_NEM', 'h', approx='naissance non renseignée')
g.m('sr.constance', 'Constance Morosini', None, None, 'Reine de Syrmie', 'Morosini (Venise)', 'SR_NEM', 'f', flag='Famille Morosini (Venise) : sans arbre ; dates non renseignées', approx='dates non renseignées')
P('sr.dragutin', 'sr.vladislav2'); P('hu.catherine', 'sr.vladislav2')
S('sr.vladislav2', 'sr.constance')
g.m('sr.anna_terter', 'Anna Terter', None, None, 'Reine de Serbie', 'Terter (Bulgarie)', 'SR_NEM', 'f', flag='Maison Terter (Bulgarie) : sans arbre ; dates non renseignées', approx='dates non renseignées')
g.m('sr.simonida', 'Simonide Paléologue', None, None, 'Reine de Serbie', 'Paléologue (Byzance)', 'SR_NEM', 'f', flag='Maison Paléologue (Byzance) : arbre à créer avec la Grèce/Turquie ; dates non renseignées', approx='dates non renseignées')
S('sr.milutin', 'sr.anna_terter'); S('sr.milutin', 'sr.simonida')
g.m('sr.decanski', 'Stefan Uroš III Dečanski', 1285, 1331, 'Roi de Serbie (1322-1331)', NE, 'SR_NEM', 'h', True, approx='naissance « vers 1285 » (non revérifiée sur la page)')
P('sr.milutin', 'sr.decanski'); P('sr.anna_terter', 'sr.decanski')
g.m('sr.theodora_s', 'Théodora Smilets', None, None, 'Reine de Serbie', 'Smilets (Bulgarie)', 'SR_NEM', 'f', flag='Maison Smilets (Bulgarie) : sans arbre ; dates non renseignées', approx='dates non renseignées')
g.m('sr.maria_pal', 'Marie Paléologue (épouse de Dečanski)', None, None, 'Reine de Serbie', 'Paléologue (Byzance)', 'SR_NEM', 'f', flag='Maison Paléologue (Byzance) : arbre à créer avec la Grèce/Turquie ; dates non renseignées', approx='dates non renseignées')
S('sr.decanski', 'sr.theodora_s'); S('sr.decanski', 'sr.maria_pal')
g.m('sr.dusan', 'Stefan Dušan', 1308, 1355, 'Roi (1331) puis empereur des Serbes et des Romains (1346-1355)', NE, 'SR_NEM', 'h', True, approx='naissance « vers 1308 » (certains historiens serbes : 1312)')
P('sr.decanski', 'sr.dusan'); P('sr.theodora_s', 'sr.dusan')
g.m('bg.helena', 'Hélène de Bulgarie (impératrice des Serbes)', None, None, 'Impératrice des Serbes', 'Chichman (Bulgarie)', 'BG_CHI', 'f', approx='dates non renseignées')
g.fam('bg.ivan_alex', 'bg.helena')
S('sr.dusan', 'bg.helena')
g.m('sr.uros5', 'Stefan Uroš V', 1336, 1371, 'Empereur des Serbes (1355-1371)', NE, 'SR_NEM', 'h', True, approx='naissance « vers 1336 » ; mort 2 ou 4 décembre 1371')
P('sr.dusan', 'sr.uros5'); P('bg.helena', 'sr.uros5')
g.m('ro.anna_w', 'Anne de Valachie (impératrice des Serbes)', None, None, 'Impératrice des Serbes', 'Basarab', 'RO_BAS', 'f', approx='dates non renseignées')
P('ro.nicholas_a', 'ro.anna_w')
S('sr.uros5', 'ro.anna_w')

# ---------- Lazarević
g.m('sr.lazar', 'Lazar Hrebeljanović', 1329, 1389, 'Prince de Serbie (1371-1389), tué à Kosovo Polje', LA, 'SR_LAZ', 'h', True, approx='naissance « vers 1329 » (non revérifiée sur la page)')
g.m('sr.milica', 'Milica Nemanjić', 1335, 1405, 'Princesse de Serbie, régente', 'Nemanjić (descendante de Vukan)', 'SR_LAZ', 'f', approx='naissance « vers 1335 » (non revérifiée sur la page)')
S('sr.lazar', 'sr.milica')
g.m('sr.stefan_l', 'Stefan Lazarević', 1377, 1427, 'Prince (1389-1402) puis despote de Serbie (1402-1427)', LA, 'SR_LAZ', 'h', True, approx='naissance « vers 1377 »')
g.m('sr.helena_g', 'Hélène Gattilusio', None, None, 'Despotesse de Serbie', 'Gattilusio (Lesbos)', 'SR_LAZ', 'f', flag='Famille Gattilusio (Lesbos) : sans arbre ; dates non renseignées', approx='dates non renseignées')
g.m('sr.vuk_l', 'Vuk Lazarević', None, 1410, 'Prince, exécuté en 1410', LA, 'SR_LAZ', 'h', approx='naissance non renseignée')
g.m('sr.mara_l', 'Mara Lazarević', None, None, 'Princesse, épouse de Vuk Branković', LA, 'SR_LAZ', 'f', approx='dates non renseignées')
g.m('sr.jelena_l', 'Jelena Lazarević', None, 1443, 'Princesse, épouse de Đurađ Stracimirović puis de Sandalj Hranić', LA, 'SR_LAZ', 'f', approx='naissance non renseignée')
g.move('bg.dragana', 'SR_LAZ', LA)
for c in ('sr.stefan_l', 'sr.vuk_l', 'sr.mara_l', 'sr.jelena_l', 'bg.dragana'):
    P('sr.lazar', c); P('sr.milica', c)
S('sr.stefan_l', 'sr.helena_g')

# ---------- Branković
g.m('sr.vuk_b', 'Vuk Branković', 1345, 1397, 'Seigneur de Kosovo', BR, 'SR_BRA', 'h', True, approx='naissance « vers 1345 » (non revérifiée sur la page)')
S('sr.vuk_b', 'sr.mara_l')
g.m('sr.djurad', 'Đurađ Branković', 1377, 1456, 'Despote de Serbie (1427-1456)', BR, 'SR_BRA', 'h', True, approx='naissance « vers 1377 » (non revérifiée sur la page)')
P('sr.vuk_b', 'sr.djurad'); P('sr.mara_l', 'sr.djurad')
g.m('sr.irene_k', 'Irène Cantacuzène', 1400, 1457, 'Despotesse de Serbie', 'Cantacuzène (Byzance)', 'SR_BRA', 'f', flag='Maison Cantacuzène (Byzance) : arbre à créer avec la Grèce/Turquie', approx='naissance « vers 1400 » (non revérifiée)')
S('sr.djurad', 'sr.irene_k')
g.m('sr.grgur', 'Grgur Branković', None, 1459, 'Fils aîné d\'Đurađ, aveuglé par les Ottomans', BR, 'SR_BRA', 'h', approx='naissance non renseignée')
g.m('sr.stefan_b', 'Stefan Branković', None, 1476, 'Despote de Serbie (1458-1459)', BR, 'SR_BRA', 'h', True, approx='naissance non renseignée')
g.m('sr.lazar_b', 'Lazar Branković', None, 1458, 'Despote de Serbie (1456-1458)', BR, 'SR_BRA', 'h', True, approx='naissance non renseignée')
for c in ('sr.grgur', 'sr.stefan_b', 'sr.lazar_b'):
    P('sr.djurad', c); P('sr.irene_k', c)
g.m('sr.angelina', 'Angelina Arianiti', None, 1520, 'Despotesse de Serbie, sainte', 'Arianiti (Albanie)', 'SR_BRA', 'f', flag='Famille Arianiti (Albanie) : arbre à créer avec l\'Albanie', approx='naissance non renseignée')
S('sr.stefan_b', 'sr.angelina')
g.m('sr.helena_pal', 'Hélène Paléologue (épouse de Lazar Branković)', None, 1473, 'Despotesse de Serbie', 'Paléologue (Morée)', 'SR_BRA', 'f', flag='Maison Paléologue (Byzance) : arbre à créer avec la Grèce/Turquie', approx='naissance non renseignée')
S('sr.lazar_b', 'sr.helena_pal')
g.m('sr.jovan_b', 'Jovan Branković', None, 1502, 'Despote titulaire de Serbie (1493-1502)', BR, 'SR_BRA', 'h', approx='naissance non renseignée')
P('sr.stefan_b', 'sr.jovan_b'); P('sr.angelina', 'sr.jovan_b')
g.m('sr.jelena_j', 'Jelena Jakšić', None, None, 'Despotesse titulaire de Serbie', 'Jakšić (Serbie-Hongrie)', 'SR_BRA', 'f', flag='Famille Jakšić : sans arbre', approx='dates non renseignées')
S('sr.jovan_b', 'sr.jelena_j')
g.move('ro.jelena', 'SR_BRA', BR)
P('sr.jovan_b', 'ro.jelena'); P('sr.jelena_j', 'ro.jelena')
g.m('sr.djordje_b', 'Đorđe Branković (moine Maksim)', None, 1516, 'Despote titulaire (1486-1497), métropolite de Belgrade', BR, 'SR_BRA', 'h', approx='naissance non renseignée')
P('sr.stefan_b', 'sr.djordje_b'); P('sr.angelina', 'sr.djordje_b')

# ---------- Obrenović
g.m('sr.milos', 'Miloš Ier Obrenović', 1780, 1860, 'Prince de Serbie (1815-1839, 1858-1860)', OB, 'SR_OBR', 'h', True, approx='naissance 1780 ou 1783')
g.m('sr.ljubica', 'Ljubica Vukomanović', 1788, 1843, 'Princesse de Serbie', 'Vukomanović (Serbie)', 'SR_OBR', 'f', flag='Famille Vukomanović : sans arbre', approx='naissance 1788 (non revérifiée sur la page)')
S('sr.milos', 'sr.ljubica')
g.m('sr.milan2', 'Milan II Obrenović', 1819, 1839, 'Prince de Serbie (1839)', OB, 'SR_OBR', 'h', True)
g.m('sr.mihailo', 'Michel III Obrenović', 1823, 1868, 'Prince de Serbie (1839-1842, 1860-1868)', OB, 'SR_OBR', 'h', True)
for c in ('sr.milan2', 'sr.mihailo'):
    P('sr.milos', c); P('sr.ljubica', c)
g.m('sr.julia', 'Júlia Hunyady de Kéthely', 1831, 1919, 'Princesse de Serbie', 'Hunyady (Hongrie)', 'SR_OBR', 'f', flag='Famille Hunyady de Kéthely (noblesse hongroise) : sans arbre', approx='dates 1831-1919 (non revérifiées sur la page)')
S('sr.mihailo', 'sr.julia')
g.m('sr.jevrem', 'Jevrem Obrenović', 1790, 1856, 'Frère de Miloš Ier, chef de la maison', OB, 'SR_OBR', 'h', approx='dates 1790-1856 (non revérifiées sur la page)')
g.fam('sr.milos', 'sr.jevrem')
g.m('sr.milos_j', 'Miloš Obrenović (fils de Jevrem)', 1829, 1861, 'Père de Milan Ier', OB, 'SR_OBR', 'h')
P('sr.jevrem', 'sr.milos_j')
g.m('sr.elena_c', 'Elena Maria Catargiu', None, None, 'Mère de Milan Ier', 'Catargiu (Moldavie)', 'SR_OBR', 'f', flag='Famille Catargiu (boyards moldaves, Roumanie) : sans arbre ; dates non renseignées', approx='dates non renseignées')
S('sr.milos_j', 'sr.elena_c')
g.m('sr.milan1', 'Milan Ier Obrenović', 1854, 1901, 'Prince (1868) puis premier roi de Serbie (1882-1889)', OB, 'SR_OBR', 'h', True)
P('sr.milos_j', 'sr.milan1'); P('sr.elena_c', 'sr.milan1')
g.m('sr.natalie', 'Nathalie Keshko', 1859, 1941, 'Reine de Serbie', 'Keshko (Bessarabie)', 'SR_OBR', 'f', flag='Famille Keshko (noblesse moldave/bessarabienne) : sans arbre', approx='dates 1859-1941 (non revérifiées sur la page)')
S('sr.milan1', 'sr.natalie')
g.m('sr.alex_o', 'Alexandre Ier Obrenović', 1876, 1903, 'Roi de Serbie (1889-1903), assassiné', OB, 'SR_OBR', 'h', True)
P('sr.milan1', 'sr.alex_o'); P('sr.natalie', 'sr.alex_o')
g.m('sr.draga', 'Draga Mašin', 1864, 1903, 'Reine de Serbie, assassinée', 'Mašin (Serbie)', 'SR_OBR', 'f', flag='Famille Mašin : sans arbre', approx='dates 1864-1903 (non revérifiées sur la page)')
S('sr.alex_o', 'sr.draga')

# ---------- Karađorđević
g.m('sr.karadjordje', 'Karađorđe Petrović', 1768, 1817, 'Chef du premier soulèvement serbe, fondateur de la dynastie', KA, 'SR_KAR', 'h', True, approx='naissance 1768 (non revérifiée sur la page)')
g.m('sr.jelena_kar', 'Jelena Jovanović (épouse de Karađorđe)', None, None, 'Épouse de Karađorđe', 'Jovanović (Serbie)', 'SR_KAR', 'f', flag='Famille Jovanović : sans arbre ; dates non renseignées', approx='dates non renseignées')
S('sr.karadjordje', 'sr.jelena_kar')
g.m('sr.alex_k', 'Alexandre Karađorđević', 1806, 1885, 'Prince de Serbie (1842-1858)', KA, 'SR_KAR', 'h', True)
P('sr.karadjordje', 'sr.alex_k'); P('sr.jelena_kar', 'sr.alex_k')
g.m('sr.persida', 'Persida Nenadović', 1813, 1873, 'Princesse de Serbie', 'Nenadović (Serbie)', 'SR_KAR', 'f', flag='Famille Nenadović : sans arbre', approx='dates 1813-1873 (non revérifiées)')
S('sr.alex_k', 'sr.persida')
g.m('sr.peter1', 'Pierre Ier de Serbie', 1844, 1921, 'Roi de Serbie (1903-1918), puis roi des Serbes, Croates et Slovènes (1918-1921)', KA, 'SR_KAR', 'h', True)
P('sr.alex_k', 'sr.peter1'); P('sr.persida', 'sr.peter1')
g.m('sr.zorka', 'Zorka du Monténégro', 1864, 1890, 'Princesse de Serbie', 'Petrović-Njegoš (Monténégro)', 'SR_KAR', 'f', flag='Maison Petrović-Njegoš (Monténégro) : à déplacer dans son arbre quand il sera créé')
S('sr.peter1', 'sr.zorka')
g.m('sr.george', 'Georges de Serbie', 1887, 1972, 'Prince héritier de Serbie (renonce en 1909)', KA, 'SR_KAR', 'h')
g.m('sr.alex1', 'Alexandre Ier de Yougoslavie', 1888, 1934, 'Roi des Serbes, Croates et Slovènes puis de Yougoslavie (1921-1934)', KA, 'SR_KAR', 'h', True)
for c in ('sr.george', 'sr.alex1'):
    P('sr.peter1', c); P('sr.zorka', c)
S('sr.alex1', 'ro.maria_r')
g.m('sr.peter2', 'Pierre II de Yougoslavie', 1923, 1970, 'Roi de Yougoslavie (1934-1945)', KA, 'SR_KAR', 'h', True)
g.m('sr.tomislav', 'Tomislav de Yougoslavie', 1928, 2000, 'Prince', KA, 'SR_KAR', 'h')
g.m('sr.andrew', 'André de Yougoslavie', 1929, 1990, 'Prince', KA, 'SR_KAR', 'h')
for c in ('sr.peter2', 'sr.tomislav', 'sr.andrew'):
    P('sr.alex1', c); P('ro.maria_r', c)
g.m('gr.alexandra', 'Alexandra de Grèce', 1921, 1993, 'Reine de Yougoslavie', 'Glücksbourg', 'GR_GLU', 'f')
P('gr.alexander', 'gr.alexandra'); P('gr.aspasia', 'gr.alexandra')
S('sr.peter2', 'gr.alexandra')
g.m('sr.alex_b', 'Alexandre de Yougoslavie', 1945, None, 'Prince héritier, chef de la maison royale', KA, 'SR_KAR', 'h')
P('sr.peter2', 'sr.alex_b'); P('gr.alexandra', 'sr.alex_b')
g.m('sr.arsen', 'Arsène Karađorđević', 1859, 1938, 'Prince', KA, 'SR_KAR', 'h')
P('sr.alex_k', 'sr.arsen'); P('sr.persida', 'sr.arsen')
g.m('sr.aurora', 'Aurore Demidova', 1873, 1904, 'Princesse', 'Demidov (Russie)', 'SR_KAR', 'f', flag='Famille Demidov (Russie) : sans arbre', approx='dates 1873-1904 (non revérifiées)')
S('sr.arsen', 'sr.aurora')
g.m('sr.paul', 'Paul de Yougoslavie', 1893, 1976, 'Prince-régent de Yougoslavie (1934-1941)', KA, 'SR_KAR', 'h', True)
P('sr.arsen', 'sr.paul'); P('sr.aurora', 'sr.paul')
g.m('gr.nicholas', 'Nicolas de Grèce', 1872, 1938, 'Prince', 'Glücksbourg', 'GR_GLU', 'h')
P('gr.george1', 'gr.nicholas'); P('gr.olga', 'gr.nicholas')
g.m('gr.olga_g', 'Olga de Grèce', 1903, 1997, 'Princesse de Yougoslavie', 'Glücksbourg', 'GR_GLU', 'f')
P('gr.nicholas', 'gr.olga_g')
S('sr.paul', 'gr.olga_g')
g.m('sr.maria_gloria', 'Maria da Glória d\'Orléans-Bragance', 1946, None, 'Princesse héritière de Yougoslavie (1972-1985)', 'Orléans-Bragance (Brésil)', 'SR_KAR', 'f', flag='Maison d\'Orléans-Bragance (Brésil) : arbre à créer avec le Brésil', approx='naissance 1946 (non revérifiée)')
S('sr.alex_b', 'sr.maria_gloria')
g.m('sr.peter_k', 'Pierre de Yougoslavie', 1980, None, 'Prince', KA, 'SR_KAR', 'h', approx='naissance 1980 (non revérifiée)')
g.m('sr.philip_k', 'Philippe de Yougoslavie', 1982, None, 'Prince', KA, 'SR_KAR', 'h', approx='naissance 1982 (non revérifiée)')
g.m('sr.alex_k2', 'Alexandre de Yougoslavie (fils d\'Alexandre)', 1982, None, 'Prince', KA, 'SR_KAR', 'h', approx='naissance 1982 (non revérifiée)')
for c in ('sr.peter_k', 'sr.philip_k', 'sr.alex_k2'):
    P('sr.alex_b', c); P('sr.maria_gloria', c)
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
