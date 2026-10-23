import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *


def E(p):
    return [k for k in ENT if k.startswith(p)][0]


g = Gen(43, "Russie — Riourikides, Godounov, Romanov")
g.notes = [
    "Crée sous Russie > Dynastie : Riourikides (Rurik -> Fiodor Ier, branche de Kiev, Vladimir-Souzdal et Moscou), Godounov, Romanov (des Zakharine-Iouriev à Nicolas II).",
    "Décision : la branche de Halicz-Volhynie des Riourikides ira dans l'arbre de l'Ukraine (pas dupliquée ici) ; les princes de Polotsk (Biélorussie) idem.",
    "Rattache à Riourikides : Anastasia de Kiev, Euphémie de Kiev, Predslava, Euphrosyne (ex-Árpád), Marie Dobroniega et Zbyslava (ex-Piast), Hélène de Moscou (ex-Jagellon), Euphraxie de Kiev (ex-Saliens).",
    "Épouses d'autres dynasties créées dans leur arbre : Charlotte de Prusse (Hohenzollern), Dagmar de Danemark (Glücksbourg), Charlotte et Antoine-Ulrich de Brunswick (Welf).",
    "Marie-Louise d'Autriche (impératrice des Français) est déplacée de l'arbre Bonaparte vers Habsbourg-Lorraine (Autriche), comme Martin l'avait noté sur sa fiche.",
    "Maria Alexandrovna de Russie (créée dans l'arbre Wettin par v38) est reliée à Alexandre II et Marie de Hesse.",
    "Prérequis : v41 et v42 exécutés (et v38 pour Maria Alexandrovna ; sinon ce seul lien est ignoré avec un avertissement).",
]
g.tree('RU_RUR', 'RUS', 'Riourikides')
g.tree('RU_GOD', 'RUS', 'Godounov')
g.tree('RU_ROM', 'RUS', 'Romanov')
g.tree('HU_ARP', 'HUN', 'Árpád')
g.tree('PL_PIAST', 'POL', 'Piast')
g.tree('PL_JAG', 'POL', 'Jagellon', entry='2330c043-bc06-4464-92c0-dbc885739729')
g.tree('AT_HL', 'AUT', 'Habsbourg-Lorraine')
g.tree('DE_HZ', 'DEU', 'Hohenzollern', entry='39895573-27f3-4112-905b-c9ba7e3c95a1')
g.tree('DK_GLU', 'DNK', 'Glücksbourg', entry=E('78bf5e64'))
g.tree('DE_WELF', 'DEU', 'Welf', entry='db5ef554-cbb9-448f-89fa-b656bf1d1147')
g.reposition = {'HU_ARP', 'PL_PIAST', 'PL_JAG'}
Gen.FIXB = {uid('member:ru.roman_z'): 1495, uid('member:ru.shemyaka'): 1420, '1fb35d8e-0c0e-4218-bdfe-02b7e21890a9': 1035, 'a73a4282-9de1-4aca-84e3-7fdf6a5f0f37': 940}

P, S = g.par, g.sp
RR = 'Riourikides'
UK = 'Ukraine/Russie : voir note'


def R(code, name, b, d, title, sex, leader=False, approx=None, tree='RU_RUR', dyn=RR, flag=None):
    g.m(code, name, b, d, title, dyn, tree, sex, leader, approx=approx, flag=flag)


def W(code, name, b, d, title, dyn, flag, approx=None, tree='RU_RUR'):
    g.m(code, name, b, d, title, dyn, tree, 'f', False, flag=flag, approx=approx)


# ================================================================ RIOURIKIDES — Kiev
R('ru.rurik', 'Riourik', 830, 879, 'Prince de Novgorod, fondateur de la dynastie', 'h', True, 'dates « vers 830 – 879 » (semi-légendaire)')
R('ru.igor', 'Igor Ier de Kiev', 878, 945, 'Grand-prince de Kiev (912-945)', 'h', True, 'naissance « vers 878 »')
W('ru.olga', 'Olga de Kiev (sainte)', None, 969, 'Régente de Kiev, sainte', 'Origine incertaine (Pskov ?)', 'Origine incertaine : sans arbre ; naissance très incertaine (entre 890 et 925)', 'naissance incertaine (890-925), non renseignée')
R('ru.svyat1', 'Sviatoslav Ier', 942, 972, 'Grand-prince de Kiev (945-972)', 'h', True, 'naissance « vers 942 »')
W('ru.malusha', 'Malouscha', None, None, 'Intendante, mère de Vladimir Ier', 'Origine modeste', 'Origine modeste : sans arbre ; dates inconnues', 'dates inconnues')
R('ru.yaropolk1', 'Iaropolk Ier', 950, 980, 'Grand-prince de Kiev (972-980)', 'h', True, 'naissance « vers 950 » (très proche de celle de son père, vers 942 : dates approximatives)')
R('ru.vladimir1', 'Vladimir Ier le Grand', 958, 1015, 'Grand-prince de Kiev (980-1015), baptisé en 988', 'h', True, 'naissance « vers 958 »')
W('ru.rogneda', 'Rogneda de Polotsk', None, None, 'Princesse de Polotsk, épouse de Vladimir Ier', 'Polotsk (Biélorussie)', 'Famille de Polotsk (Biélorussie) : à rattacher à l\'arbre de la Biélorussie ; dates inconnues', 'dates inconnues')
W('ru.anna_p', 'Anne Porphyrogénète', 963, 1011, 'Princesse byzantine, épouse de Vladimir Ier', 'Macédoniens (Byzance)', 'Dynastie macédonienne (Byzance) : arbre à créer avec la Grèce/Turquie', 'naissance 963 ; mort 1011')
R('ru.svyatopolk1', 'Sviatopolk Ier le Maudit', 980, 1019, 'Grand-prince de Kiev (1015-1019)', 'h', True, 'naissance « vers 979/980 »')
R('ru.yaroslav1', 'Iaroslav Ier le Sage', 978, 1054, 'Grand-prince de Kiev (1019-1054)', 'h', True, 'naissance « vers 978 »')
W('ru.ingegerd', 'Ingegerd de Suède (Irène)', 1001, 1050, 'Grande-princesse de Kiev', 'Munsö (Suède)', 'Maison de Munsö (Suède) : arbre à créer avec la Suède')
R('ru.izyaslav1', 'Iziaslav Ier', 1024, 1078, 'Grand-prince de Kiev (1054-1078)', 'h', True)
R('ru.svyat2', 'Sviatoslav II', 1027, 1076, 'Grand-prince de Kiev (1073-1076)', 'h', True)
R('ru.vsevolod1', 'Vsevolod Ier', 1030, 1093, 'Grand-prince de Kiev (1078-1093)', 'h', True, 'naissance « vers 1030 »')
W('ru.byz_vs', 'Princesse byzantine (1re épouse de Vsevolod Ier)', None, 1067, 'Grande-princesse de Kiev', 'Byzance (Monomaque ?)', 'Princesse byzantine à l\'identité incertaine (Anastasia ou Marie) : arbre à créer avec la Grèce ; naissance inconnue', 'identité et naissance inconnues')
W('ru.polov_vs', 'Anne la Polovtsienne', None, 1111, 'Grande-princesse de Kiev', 'Coumans (Polovtses)', 'Princesse coumane : sans arbre ; naissance inconnue', 'naissance inconnue')
R('ru.svyatopolk2', 'Sviatopolk II', 1050, 1113, 'Grand-prince de Kiev (1093-1113)', 'h', True)
R('ru.vladimir2', 'Vladimir II Monomaque', 1053, 1125, 'Grand-prince de Kiev (1113-1125)', 'h', True)
W('ru.gytha', 'Gytha de Wessex (épouse supposée de Monomaque)', None, None, 'Princesse de Wessex (mariage attesté seulement par Saxo Grammaticus)', 'Godwine (Wessex)', 'Maison de Godwine (Angleterre) : mariage douteux ; dates inconnues ; à rattacher à l\'arbre Wessex/Godwine si Martin le valide', 'identité du mariage incertaine, dates inconnues')
R('ru.mstislav1', 'Mstislav Ier le Grand', 1076, 1132, 'Grand-prince de Kiev (1125-1132)', 'h', True, 'naissance février 1076 (une source : juin)')
W('ru.christina', 'Christine de Suède', None, 1122, 'Grande-princesse de Kiev', 'Stenkil (Suède)', 'Maison de Stenkil (Suède) : arbre à créer avec la Suède ; naissance inconnue', 'naissance inconnue')
W('ru.liubava', 'Lioubava Zavidich', None, None, 'Grande-princesse de Kiev', 'Zavidich (Novgorod)', 'Famille Zavidich (boyards de Novgorod) : sans arbre ; dates inconnues', 'dates inconnues')
R('ru.yaropolk2', 'Iaropolk II', 1082, 1139, 'Grand-prince de Kiev (1132-1139)', 'h', True)
R('ru.vyacheslav', 'Viatcheslav Ier', 1083, 1154, 'Grand-prince de Kiev (1139, 1150)', 'h', True)
R('ru.yuri_d', 'Iouri Dolgorouki', 1099, 1157, 'Prince de Souzdal, grand-prince de Kiev (1149-1157), fondateur de Moscou (légende)', 'h', True, 'naissance « vers 1099 »')
W('ru.helene_yd', 'Hélène (épouse d\'Iouri Dolgorouki)', None, None, 'Princesse, mère de Vsevolod III', 'Origine incertaine (byzantine ?)', 'Origine incertaine : sans arbre ; dates inconnues', 'dates inconnues')
R('ru.izyaslav2', 'Iziaslav II', 1097, 1154, 'Grand-prince de Kiev (1146-1154)', 'h', True)
R('ru.rostislav', 'Rostislav Mstislavitch', 1110, 1167, 'Grand-prince de Kiev (1154-1167)', 'h', True)
R('ru.andrei_b', 'André Ier Bogoliouvski', 1111, 1174, 'Grand-prince de Vladimir et de Kiev (1157-1174)', 'h', True, 'naissance « vers 1111 » (écart faible avec son père, vers 1099 : dates approximatives)')
R('ru.vsevolod3', 'Vsevolod III « Gros-Nid »', 1154, 1212, 'Grand-prince de Vladimir (1176-1212)', 'h', True, 'mort 12 ou 15 avril 1212')
W('ru.maria_sh', 'Maria Chvarnovna', None, 1206, 'Grande-princesse de Vladimir', 'Jotvingiens (Yatvag/Tchèque ?)', 'Origine incertaine (Yatvag ou Tchèque) : sans arbre ; naissance inconnue ; mort 1205 ou 1206', 'naissance inconnue ; mort 1205 ou 1206')
R('ru.yuri2', 'Iouri II de Vladimir', 1189, 1238, 'Grand-prince de Vladimir (1212-1238)', 'h', True)
R('ru.yaroslav2', 'Iaroslav II de Vladimir', 1191, 1246, 'Grand-prince de Vladimir (1238-1246)', 'h', True)
W('ru.theodosia', 'Théodosie Mstislavna (Rostislava)', None, None, 'Grande-princesse de Vladimir', 'Rurikides de Smolensk', 'Rurikides (branche de Smolensk, fille de Mstislav le Hardi) : sans arbre propre ; dates inconnues', 'dates inconnues', tree='RU_RUR')
R('ru.svyat3', 'Sviatoslav III de Vladimir', 1196, 1252, 'Grand-prince de Vladimir (1246-1247)', 'h', True)
R('ru.nevsky', 'Alexandre Nevski (saint)', 1221, 1263, 'Prince de Novgorod, grand-prince de Vladimir (1252-1263)', 'h', True, 'naissance 1221 (tradition ancienne : 1220)')
W('ru.alexandra_p', 'Alexandra de Polotsk', None, None, 'Épouse d\'Alexandre Nevski', 'Polotsk (Biélorussie)', 'Famille de Polotsk (Biélorussie) : à rattacher à l\'arbre de la Biélorussie ; dates inconnues', 'dates inconnues')
R('ru.andrei2', 'André II de Vladimir', 1222, 1264, 'Grand-prince de Vladimir (1248-1252)', 'h', True)
R('ru.yaroslav3', 'Iaroslav III de Tver', 1230, 1272, 'Grand-prince de Vladimir (1264-1272)', 'h', True)
R('ru.vasily_k', 'Vassili de Kostroma', 1241, 1276, 'Grand-prince de Vladimir (1272-1276)', 'h', True)
R('ru.dmitry_p', 'Dmitri de Pereslavl', 1250, 1294, 'Grand-prince de Vladimir (1276-1294)', 'h', True, 'naissance « vers 1250 »')
R('ru.andrei3', 'André III de Gorodets', 1255, 1304, 'Grand-prince de Vladimir (1294-1304)', 'h', True, 'naissance « vers 1255 »')
R('ru.mikhail_t', 'Mikhaïl de Tver', 1271, 1318, 'Grand-prince de Vladimir (1304-1318)', 'h', True)
R('ru.dmitry_t', 'Dmitri de Tver', 1299, 1326, 'Prince de Tver (« aux yeux terribles »)', 'h', False)
R('ru.alexander_t', 'Alexandre de Tver', 1301, 1339, 'Grand-prince de Vladimir (1326-1327)', 'h', True)

P('ru.rurik', 'ru.igor'); S('ru.igor', 'ru.olga'); P('ru.igor', 'ru.svyat1'); P('ru.olga', 'ru.svyat1')
P('ru.svyat1', 'ru.yaropolk1'); P('ru.svyat1', 'ru.vladimir1'); P('ru.malusha', 'ru.vladimir1')
S('ru.svyat1', 'ru.malusha')
S('ru.vladimir1', 'ru.rogneda'); S('ru.vladimir1', 'ru.anna_p')
P('ru.yaropolk1', 'ru.svyatopolk1')
P('ru.vladimir1', 'ru.yaroslav1'); P('ru.rogneda', 'ru.yaroslav1')
S('ru.yaroslav1', 'ru.ingegerd')
for c in ('ru.izyaslav1', 'ru.svyat2', 'ru.vsevolod1', X('3dc7c91c')):                    # Anne de Kiev (reine de France)
    P('ru.yaroslav1', c); P('ru.ingegerd', c)
S('ru.vsevolod1', 'ru.byz_vs'); S('ru.vsevolod1', 'ru.polov_vs')
for c in ('ru.vladimir2', X('8314f6aa')):                                                 # Euphraxie de Kiev
    P('ru.vsevolod1', c)
P('ru.byz_vs', 'ru.vladimir2')
P('ru.polov_vs', X('8314f6aa'))
P('ru.izyaslav1', 'ru.svyatopolk2')
S('ru.vladimir2', 'ru.gytha')
for c in ('ru.mstislav1', 'ru.yaropolk2', 'ru.vyacheslav', 'ru.yuri_d', 'hu.euphemia'):
    P('ru.vladimir2', c)
for c in ('ru.mstislav1', 'ru.yuri_d'):
    P('ru.gytha', c)
S('ru.mstislav1', 'ru.christina'); S('ru.mstislav1', 'ru.liubava')
for c in ('ru.izyaslav2', 'ru.rostislav'):
    P('ru.mstislav1', c); P('ru.christina', c)
P('ru.mstislav1', 'hu.euphrosyne'); P('ru.liubava', 'hu.euphrosyne')
P('ru.svyatopolk2', 'pl.zbyslava'); P('ru.svyatopolk2', 'hu.predslava')
P('ru.vladimir1', 'pl.dobroniega')
S('ru.yuri_d', 'ru.helene_yd')
for c in ('ru.andrei_b', 'ru.vsevolod3'):
    P('ru.yuri_d', c)
P('ru.helene_yd', 'ru.vsevolod3')
S('ru.vsevolod3', 'ru.maria_sh')
for c in ('ru.yuri2', 'ru.yaroslav2', 'ru.svyat3'):
    P('ru.vsevolod3', c); P('ru.maria_sh', c)
S('ru.yaroslav2', 'ru.theodosia')
for c in ('ru.nevsky', 'ru.andrei2', 'ru.yaroslav3', 'ru.vasily_k'):
    P('ru.yaroslav2', c); P('ru.theodosia', c)
S('ru.nevsky', 'ru.alexandra_p')
for c in ('ru.dmitry_p', 'ru.andrei3'):
    P('ru.nevsky', c); P('ru.alexandra_p', c)
P('ru.yaroslav3', 'ru.mikhail_t')
for c in ('ru.dmitry_t', 'ru.alexander_t'):
    P('ru.mikhail_t', c)

# ================================================================ RIOURIKIDES — Moscou
R('ru.daniel', 'Daniel de Moscou', 1261, 1303, 'Premier prince de Moscou', 'h', True)
W('ru.maria_bel', 'Maria Gleboevna de Biélozersk', None, None, 'Princesse de Moscou', 'Rurikides de Biélozersk', 'Rurikides (Biélozersk) : sans arbre propre ; dates inconnues', 'dates inconnues')
R('ru.yuri3', 'Iouri III de Moscou', 1281, 1325, 'Grand-prince de Vladimir (1318-1322)', 'h', True)
R('ru.ivan1', 'Ivan Ier Kalita', 1288, 1340, 'Grand-prince de Moscou et de Vladimir', 'h', True, 'naissance « vers 1288 »')
W('ru.elena_i1', 'Hélène (1re épouse d\'Ivan Ier)', None, 1331, 'Grande-princesse de Moscou', 'Origine inconnue', 'Origine inconnue : sans arbre ; naissance inconnue', 'naissance inconnue')
R('ru.simeon', 'Siméon le Superbe', 1317, 1353, 'Grand-prince de Moscou et de toute la Russie (1340-1353)', 'h', True)
R('ru.ivan2', 'Ivan II le Beau', 1326, 1359, 'Grand-prince de Moscou (1353-1359)', 'h', True)
W('ru.velyaminova', 'Alexandra Veliaminova', None, None, 'Grande-princesse de Moscou', 'Veliaminov (boyards)', 'Famille Veliaminov (boyards) : sans arbre ; dates inconnues', 'dates inconnues')
R('ru.dmitry_d', 'Dimitri Donskoï', 1350, 1389, 'Grand-prince de Moscou (1359-1389), vainqueur à Koulikovo', 'h', True)
W('ru.eudoxia_d', 'Eudoxie de Souzdal', None, None, 'Grande-princesse de Moscou', 'Rurikides de Souzdal-Nijni-Novgorod', 'Rurikides (Souzdal) : sans arbre propre ; dates non renseignées', 'dates non renseignées')
R('ru.vasily1', 'Vassili Ier', 1371, 1425, 'Grand-prince de Moscou (1389-1425)', 'h', True, 'naissance 30 décembre 1371 (ou 30 septembre)')
W('ru.sophia_l', 'Sophie de Lituanie (fille de Vytautas)', None, None, 'Grande-princesse de Moscou', 'Gediminides (Lituanie)', 'Gediminides (Lituanie) : arbre à créer avec la Lituanie ; dates non renseignées', 'dates non renseignées')
R('ru.yuri_z', 'Iouri de Zvenigorod', 1374, 1434, 'Grand-prince de Moscou (1433-1434)', 'h', True)
W('ru.anastasia_sm', 'Anastasia de Smolensk', None, None, 'Princesse de Zvenigorod', 'Rurikides de Smolensk', 'Rurikides (Smolensk) : sans arbre propre ; dates inconnues', 'dates inconnues')
R('ru.vasily_kosoy', 'Vassili le Louche', 1421, 1448, 'Grand-prince de Moscou (1434)', 'h', True)
R('ru.shemyaka', 'Dimitri Chemiaka', None, 1453, 'Grand-prince de Moscou (1445, 1446-1447)', 'h', True, 'naissance inconnue')
R('ru.vasily2', 'Vassili II l\'Aveugle', 1415, 1462, 'Grand-prince de Moscou (1425-1462)', 'h', True)
W('ru.maria_yar', 'Maria Iaroslavna de Borovsk', None, None, 'Grande-princesse de Moscou', 'Rurikides de Borovsk-Serpoukhov', 'Rurikides (Borovsk) : sans arbre propre ; dates non renseignées', 'dates non renseignées')
R('ru.ivan3', 'Ivan III le Grand', 1440, 1505, 'Grand-prince de Moscou (1462-1505), « rassembleur des terres russes »', 'h', True)
W('ru.maria_tver', 'Marie de Tver', None, 1467, 'Grande-princesse de Moscou', 'Rurikides de Tver', 'Rurikides (Tver) : sans arbre propre ; naissance non renseignée', 'naissance non renseignée')
W('ru.sophia_pal', 'Sophie Paléologue', 1455, 1503, 'Grande-princesse de Moscou', 'Paléologue (Byzance)', 'Paléologue (Byzance) : arbre à créer avec la Grèce/Turquie', 'dates « vers 1455 – 1503 » (non revérifiées)')
R('ru.ivan_young', 'Ivan le Jeune', 1458, 1490, 'Corégent, prince héritier', 'h', False)
R('ru.vasily3', 'Vassili III', 1479, 1533, 'Grand-prince de Moscou (1505-1533)', 'h', True)
W('ru.solomonia', 'Solomonia Saburova', None, 1542, 'Grande-princesse de Moscou (répudiée en 1525)', 'Saburov (boyards)', 'Famille Saburov (boyards) : sans arbre ; naissance inconnue ; mort 1542 (non revérifiée)', 'naissance inconnue')
W('ru.glinskaya', 'Hélène Glinskaïa', 1508, 1538, 'Grande-princesse de Moscou, régente', 'Glinski (Lituanie)', 'Famille Glinski (noblesse lituanienne) : sans arbre', 'dates « vers 1508 – 1538 » (non revérifiées)')
R('ru.ivan4', 'Ivan IV le Terrible', 1530, 1584, 'Grand-prince (1533), premier tsar de Russie (1547-1584)', 'h', True)
W('ru.maria_tem', 'Maria Temrioukovna', None, 1569, 'Tsarine', 'Kabardes (Caucase)', 'Princesse kabarde : sans arbre ; naissance inconnue', 'naissance inconnue')
W('ru.marfa_sob', 'Marfa Sobakina', None, 1571, 'Tsarine', 'Sobakine (marchands)', 'Famille de marchands : sans arbre ; naissance inconnue', 'naissance inconnue')
W('ru.maria_nag', 'Maria Nagaïa', None, None, 'Tsarine, mère de Dimitri d\'Ouglitch', 'Nagoï (boyards)', 'Famille Nagoï (boyards) : sans arbre ; dates non renseignées', 'dates non renseignées')
R('ru.ivan_ivanovich', 'Ivan Ivanovitch', 1554, 1581, 'Tsarévitch, héritier d\'Ivan IV', 'h', False)
R('ru.feodor1', 'Fiodor Ier le Bienheureux', 1557, 1598, 'Tsar de Russie (1584-1598), dernier Riourikide', 'h', True)
R('ru.dmitry_u', 'Dimitri d\'Ouglitch', 1582, 1591, 'Tsarévitch, mort à Ouglitch', 'h', False)
R('ru.shuisky', 'Vassili IV Chouïski', 1552, 1612, 'Tsar de Russie (1606-1610)', 'h', True, flag='Maison Chouïski (branche des Riourikides de Souzdal) : ses parents ne sont pas reliés à cet arbre (lien généalogique non établi ici)', approx='naissance 1552')

P('ru.daniel', 'ru.yuri3'); P('ru.daniel', 'ru.ivan1'); S('ru.daniel', 'ru.maria_bel')
P('ru.maria_bel', 'ru.yuri3'); P('ru.maria_bel', 'ru.ivan1')
P('ru.nevsky', 'ru.daniel'); P('ru.alexandra_p', 'ru.daniel')
S('ru.ivan1', 'ru.elena_i1')
for c in ('ru.simeon', 'ru.ivan2'):
    P('ru.ivan1', c); P('ru.elena_i1', c)
S('ru.ivan2', 'ru.velyaminova')
P('ru.ivan2', 'ru.dmitry_d'); P('ru.velyaminova', 'ru.dmitry_d')
S('ru.dmitry_d', 'ru.eudoxia_d')
for c in ('ru.vasily1', 'ru.yuri_z'):
    P('ru.dmitry_d', c); P('ru.eudoxia_d', c)
S('ru.vasily1', 'ru.sophia_l')
P('ru.vasily1', 'ru.vasily2'); P('ru.sophia_l', 'ru.vasily2')
S('ru.yuri_z', 'ru.anastasia_sm')
for c in ('ru.vasily_kosoy', 'ru.shemyaka'):
    P('ru.yuri_z', c); P('ru.anastasia_sm', c)
S('ru.vasily2', 'ru.maria_yar')
P('ru.vasily2', 'ru.ivan3'); P('ru.maria_yar', 'ru.ivan3')
S('ru.ivan3', 'ru.maria_tver'); S('ru.ivan3', 'ru.sophia_pal')
P('ru.ivan3', 'ru.ivan_young'); P('ru.maria_tver', 'ru.ivan_young')
for c in ('ru.vasily3', 'pl.helene_mosc'):
    P('ru.ivan3', c); P('ru.sophia_pal', c)
S('ru.vasily3', 'ru.solomonia'); S('ru.vasily3', 'ru.glinskaya')
P('ru.vasily3', 'ru.ivan4'); P('ru.glinskaya', 'ru.ivan4')
for w in ('ru.maria_tem', 'ru.marfa_sob', 'ru.maria_nag'):
    S('ru.ivan4', w)
for c in ('ru.ivan_ivanovich', 'ru.feodor1'):
    P('ru.ivan4', c)
P('ru.ivan4', 'ru.dmitry_u'); P('ru.maria_nag', 'ru.dmitry_u')

# ================================================================ GODOUNOV
GD = 'Godounov'
g.m('ru.boris', 'Boris Godounov', 1552, 1605, 'Régent puis tsar de Russie (1598-1605)', GD, 'RU_GOD', 'h', True)
g.m('ru.maria_sk', 'Maria Skouratova-Bielskaïa', None, 1605, 'Tsarine', 'Skouratov-Bielski (boyards)', 'RU_GOD', 'f', flag='Famille Skouratov-Bielski (boyards) : sans arbre ; naissance inconnue', approx='naissance inconnue')
g.m('ru.feodor2', 'Fiodor II Godounov', 1589, 1605, 'Tsar de Russie (1605)', GD, 'RU_GOD', 'h', True)
g.m('ru.irina', 'Irina Godounova', 1557, 1603, 'Tsarine, épouse de Fiodor Ier', GD, 'RU_GOD', 'f')
S('ru.boris', 'ru.maria_sk')
P('ru.boris', 'ru.feodor2'); P('ru.maria_sk', 'ru.feodor2')
g.fam('ru.boris', 'ru.irina')                                                            # frère et sœur (parents hors arbre)
S('ru.feodor1', 'ru.irina')

# ================================================================ ROMANOV
RM = 'Romanov'
g.m('ru.roman_z', 'Roman Iourievitch Zakharine-Iouriev', None, 1543, 'Boyard, ancêtre des Romanov', RM, 'RU_ROM', 'h', approx='naissance inconnue')
g.m('ru.anastasia_r', 'Anastasia Romanovna', 1530, 1560, 'Première tsarine, épouse d\'Ivan IV', RM, 'RU_ROM', 'f')
g.m('ru.nikita_r', 'Nikita Romanovitch', 1522, 1586, 'Boyard, grand-père de Michel Ier', RM, 'RU_ROM', 'h', approx='naissance « vers 1522 »')
g.m('ru.filaret', 'Philarète (Fiodor Romanov)', 1553, 1633, 'Patriarche de Moscou, père de Michel Ier', RM, 'RU_ROM', 'h', approx='naissance « vers 1553 »')
g.m('ru.xenia_sh', 'Xénia Chestova (Marfa)', 1560, 1631, 'Mère de Michel Ier', 'Chestov (boyards)', 'RU_ROM', 'f', flag='Famille Chestov (boyards) : sans arbre', approx='naissance « vers 1560 »')
g.m('ru.michael', 'Michel Ier Romanov', 1596, 1645, 'Premier tsar Romanov (1613-1645)', RM, 'RU_ROM', 'h', True)
g.m('ru.streshneva', 'Eudoxie Strechneva', 1608, 1645, 'Tsarine', 'Strechnev (noblesse)', 'RU_ROM', 'f', flag='Famille Strechnev (noblesse) : sans arbre')
g.m('ru.alexis', 'Alexis Ier le Très-Doux', 1629, 1676, 'Tsar de Russie (1645-1676)', RM, 'RU_ROM', 'h', True)
g.m('ru.miloslav', 'Maria Miloslavskaïa', 1625, 1669, 'Tsarine', 'Miloslavski (boyards)', 'RU_ROM', 'f', flag='Famille Miloslavski (boyards) : sans arbre')
g.m('ru.naryshkina', 'Nathalie Narychkina', 1651, 1694, 'Tsarine, mère de Pierre le Grand', 'Narychkine (noblesse)', 'RU_ROM', 'f', flag='Famille Narychkine (noblesse) : sans arbre')
g.m('ru.feodor3', 'Fiodor III', 1661, 1682, 'Tsar de Russie (1676-1682)', RM, 'RU_ROM', 'h', True)
g.m('ru.sophia_a', 'Sophie Alexeïevna', 1657, 1704, 'Régente de Russie (1682-1689)', RM, 'RU_ROM', 'f', True)
g.m('ru.ivan5', 'Ivan V', 1666, 1696, 'Tsar de Russie, corégent (1682-1696)', RM, 'RU_ROM', 'h', True)
g.m('ru.praskovia', 'Praskovia Saltykova', 1664, 1723, 'Tsarine, épouse d\'Ivan V', 'Saltykov (boyards)', 'RU_ROM', 'f', flag='Famille Saltykov (boyards) : sans arbre')
g.m('ru.peter1', 'Pierre Ier le Grand', 1672, 1725, 'Tsar (1682-1721), premier empereur de Russie (1721-1725)', RM, 'RU_ROM', 'h', True)
g.m('ru.lopukhina', 'Eudoxie Lopoukhina', 1669, 1731, 'Tsarine (répudiée en 1698)', 'Lopoukhine (boyards)', 'RU_ROM', 'f', flag='Famille Lopoukhine (boyards) : sans arbre')
g.m('ru.catherine1', 'Catherine Ire', 1684, 1727, 'Impératrice de Russie (1725-1727)', 'Skavronski (origine modeste)', 'RU_ROM', 'f', True, flag='Origine modeste (Marta Skavronskaïa) : sans arbre', approx='naissance 1684 (15 avril)')
g.m('ru.alexei_p', 'Alexis Petrovitch', 1690, 1718, 'Tsarévitch', RM, 'RU_ROM', 'h')
g.m('ru.charlotte_bw', 'Charlotte de Brunswick-Wolfenbüttel', 1694, 1715, 'Tsarévna', 'Welf (Brunswick-Wolfenbüttel)', 'DE_WELF', 'f')
g.m('ru.peter2', 'Pierre II', 1715, 1730, 'Empereur de Russie (1727-1730)', RM, 'RU_ROM', 'h', True)
g.m('ru.anna_iv', 'Anne Ivanovna', 1693, 1740, 'Impératrice de Russie (1730-1740)', RM, 'RU_ROM', 'f', True)
g.m('ru.catherine_iv', 'Catherine Ivanovna', 1691, 1733, 'Duchesse de Mecklembourg', RM, 'RU_ROM', 'f')
g.m('ru.charles_leopold', 'Charles-Léopold de Mecklembourg', 1678, 1747, 'Duc de Mecklembourg-Schwerin', 'Mecklembourg', 'RU_ROM', 'h', flag='Maison de Mecklembourg (Allemagne) : sans arbre')
g.m('ru.anna_leop', 'Anna Léopoldovna', 1718, 1746, 'Régente de Russie (1740-1741)', RM, 'RU_ROM', 'f', True)
g.m('ru.anthony_ulrich', 'Antoine-Ulrich de Brunswick-Bevern', 1714, 1774, 'Prince de Brunswick, père d\'Ivan VI', 'Welf (Brunswick-Bevern)', 'DE_WELF', 'h')
g.m('ru.ivan6', 'Ivan VI', 1740, 1764, 'Empereur de Russie (1740-1741)', RM, 'RU_ROM', 'h', True)
g.m('ru.elizabeth', 'Élisabeth Ire', 1709, 1762, 'Impératrice de Russie (1741-1762)', RM, 'RU_ROM', 'f', True)
g.m('ru.anna_pet', 'Anna Petrovna', 1708, 1728, 'Duchesse de Holstein-Gottorp', RM, 'RU_ROM', 'f')
g.m('ru.charles_fred', 'Charles-Frédéric de Holstein-Gottorp', 1700, 1739, 'Duc de Holstein-Gottorp', 'Holstein-Gottorp', 'RU_ROM', 'h', flag='Maison de Holstein-Gottorp (Danemark/Allemagne) : sans arbre propre')
g.m('ru.peter3', 'Pierre III', 1728, 1762, 'Empereur de Russie (1762)', 'Holstein-Gottorp-Romanov', 'RU_ROM', 'h', True)
g.m('ru.catherine2', 'Catherine II la Grande', 1729, 1796, 'Impératrice de Russie (1762-1796)', 'Anhalt-Zerbst', 'RU_ROM', 'f', True, flag='Maison d\'Anhalt-Zerbst (Allemagne) : sans arbre')
g.m('ru.paul1', 'Paul Ier', 1754, 1801, 'Empereur de Russie (1796-1801)', 'Holstein-Gottorp-Romanov', 'RU_ROM', 'h', True)
g.m('ru.maria_f', 'Marie Feodorovna (Sophie-Dorothée de Wurtemberg)', 1759, 1828, 'Impératrice de Russie', 'Wurtemberg', 'RU_ROM', 'f', flag='Maison de Wurtemberg (Allemagne) : sans arbre')
g.m('ru.alexander1', 'Alexandre Ier', 1777, 1825, 'Empereur de Russie (1801-1825)', 'Holstein-Gottorp-Romanov', 'RU_ROM', 'h', True)
g.m('ru.elisabeth_a', 'Élisabeth Alexeïevna (Louise de Bade)', 1779, 1826, 'Impératrice de Russie', 'Zähringen (Bade)', 'RU_ROM', 'f', flag='Maison de Bade (Allemagne) : sans arbre')
g.m('ru.nicholas1', 'Nicolas Ier', 1796, 1855, 'Empereur de Russie (1825-1855)', 'Holstein-Gottorp-Romanov', 'RU_ROM', 'h', True)
g.m('ru.charlotte_p', 'Alexandra Feodorovna (Charlotte de Prusse)', 1798, 1860, 'Impératrice de Russie', 'Hohenzollern', 'DE_HZ', 'f')
g.m('ru.alexander2', 'Alexandre II', 1818, 1881, 'Empereur de Russie (1855-1881)', 'Holstein-Gottorp-Romanov', 'RU_ROM', 'h', True)
g.m('ru.marie_hesse', 'Marie de Hesse (Maria Alexandrovna)', 1824, 1880, 'Impératrice de Russie', 'Hesse-Darmstadt', 'RU_ROM', 'f', flag='Maison de Hesse-Darmstadt (Allemagne) : sans arbre')
g.m('ru.alexander3', 'Alexandre III', 1845, 1894, 'Empereur de Russie (1881-1894)', 'Holstein-Gottorp-Romanov', 'RU_ROM', 'h', True)
g.m('ru.dagmar', 'Dagmar de Danemark (Marie Feodorovna)', 1847, 1928, 'Impératrice de Russie', 'Glücksbourg', 'DK_GLU', 'f')
g.m('ru.nicholas2', 'Nicolas II', 1868, 1918, 'Dernier empereur de Russie (1894-1917)', 'Holstein-Gottorp-Romanov', 'RU_ROM', 'h', True)
g.m('ru.alix', 'Alexandra Feodorovna (Alix de Hesse)', 1872, 1918, 'Impératrice de Russie', 'Hesse-Darmstadt', 'RU_ROM', 'f', flag='Maison de Hesse-Darmstadt (Allemagne) : sans arbre')
g.m('ru.alexei_n', 'Alexis Nikolaïevitch', 1904, 1918, 'Tsarévitch', 'Holstein-Gottorp-Romanov', 'RU_ROM', 'h')
g.m('ru.michael_a', 'Michel Alexandrovitch', 1878, 1918, 'Grand-duc, désigné successeur de Nicolas II (1917)', 'Holstein-Gottorp-Romanov', 'RU_ROM', 'h')

P('ru.roman_z', 'ru.anastasia_r'); P('ru.roman_z', 'ru.nikita_r')
S('ru.ivan4', 'ru.anastasia_r')
P('ru.anastasia_r', 'ru.feodor1');
P('ru.nikita_r', 'ru.filaret')
S('ru.filaret', 'ru.xenia_sh')
P('ru.filaret', 'ru.michael'); P('ru.xenia_sh', 'ru.michael')
S('ru.michael', 'ru.streshneva')
P('ru.michael', 'ru.alexis'); P('ru.streshneva', 'ru.alexis')
S('ru.alexis', 'ru.miloslav'); S('ru.alexis', 'ru.naryshkina')
for c in ('ru.feodor3', 'ru.sophia_a', 'ru.ivan5'):
    P('ru.alexis', c); P('ru.miloslav', c)
P('ru.alexis', 'ru.peter1'); P('ru.naryshkina', 'ru.peter1')
S('ru.ivan5', 'ru.praskovia')
for c in ('ru.anna_iv', 'ru.catherine_iv'):
    P('ru.ivan5', c); P('ru.praskovia', c)
S('ru.peter1', 'ru.lopukhina'); S('ru.peter1', 'ru.catherine1')
P('ru.peter1', 'ru.alexei_p'); P('ru.lopukhina', 'ru.alexei_p')
S('ru.alexei_p', 'ru.charlotte_bw')
P('ru.alexei_p', 'ru.peter2'); P('ru.charlotte_bw', 'ru.peter2')
for c in ('ru.elizabeth', 'ru.anna_pet'):
    P('ru.peter1', c); P('ru.catherine1', c)
S('ru.catherine_iv', 'ru.charles_leopold')
P('ru.catherine_iv', 'ru.anna_leop'); P('ru.charles_leopold', 'ru.anna_leop')
S('ru.anna_leop', 'ru.anthony_ulrich')
P('ru.anna_leop', 'ru.ivan6'); P('ru.anthony_ulrich', 'ru.ivan6')
S('ru.anna_pet', 'ru.charles_fred')
P('ru.anna_pet', 'ru.peter3'); P('ru.charles_fred', 'ru.peter3')
S('ru.peter3', 'ru.catherine2')
P('ru.peter3', 'ru.paul1'); P('ru.catherine2', 'ru.paul1')
S('ru.paul1', 'ru.maria_f')
for c in ('ru.alexander1', 'ru.nicholas1'):
    P('ru.paul1', c); P('ru.maria_f', c)
S('ru.alexander1', 'ru.elisabeth_a')
S('ru.nicholas1', 'ru.charlotte_p')
P(X('6f21be7b'), 'ru.charlotte_p'); P(X('d5cfc762'), 'ru.charlotte_p')                    # Frédéric-Guillaume III, Louise de Mecklembourg-Strelitz
P('ru.nicholas1', 'ru.alexander2'); P('ru.charlotte_p', 'ru.alexander2')
S('ru.alexander2', 'ru.marie_hesse')
P('ru.alexander2', 'ru.alexander3'); P('ru.marie_hesse', 'ru.alexander3')
S('ru.alexander3', 'ru.dagmar')
P(X('fd479735'), 'ru.dagmar'); P(X('7d1a58e1'), 'ru.dagmar')                              # Christian IX, Louise de Hesse-Cassel
P('ru.alexander3', 'ru.nicholas2'); P('ru.dagmar', 'ru.nicholas2')
P('ru.alexander3', 'ru.michael_a'); P('ru.dagmar', 'ru.michael_a')
S('ru.nicholas2', 'ru.alix')
P('ru.nicholas2', 'ru.alexei_n'); P('ru.alix', 'ru.alexei_n')
g.link_named('ru.alexander2', 'Maria Alexandrovna de Russie', 1853)
g.link_named('ru.marie_hesse', 'Maria Alexandrovna de Russie', 1853)

# ================================================================ rattachements
g.move('hu.anastasia', 'RU_RUR', RR); g.setdates('hu.anastasia', 1023, None)
g.move('hu.euphemia', 'RU_RUR', RR); g.setdates('hu.euphemia', 1096, 1139)
g.move('hu.predslava', 'RU_RUR', RR)
g.move('hu.euphrosyne', 'RU_RUR', RR)
g.move('pl.dobroniega', 'RU_RUR', RR)
g.move('pl.zbyslava', 'RU_RUR', RR)
g.move('pl.helene_mosc', 'RU_RUR', RR)
g.movex(X('8314f6aa'), 'RU_RUR', RR)                                                   # Euphraxie de Kiev (Saliens -> Riourikides)
g.movex(X('5a2dc471'), 'AT_HL', 'Habsbourg-Lorraine')                                  # Marie-Louise d'Autriche (Bonaparte -> Habsbourg-Lorraine)

if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
