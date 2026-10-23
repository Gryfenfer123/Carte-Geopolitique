import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(41, "Hongrie — Árpád, Anjou-Hongrie, Hunyadi, Zápolya")
g.notes = [
    "Crée sous Hongrie > Dynastie : Árpád, Anjou-Hongrie, Hunyadi, Zápolya.",
    "Rattache à Árpád trois femmes créées plus tôt dans d'autres arbres (Adélaïde et Constance de Hongrie, sainte Kinga) et Barbara Zápolya à Zápolya : elles apparaissent désormais comme membres étrangers dans leur ancien arbre.",
    "Épouses d'autres dynasties : Gisèle (Ottoniens), Marguerite de France (Capétiens), Constance d'Aragon (Barcelone), Clémence et Agnès de Habsbourg, Béatrice de Luxembourg, Richeza et Boleslas le Pieux (Piast), Otton III (Wittelsbach).",
    "Non inclus (décision du 23/10) : Orseolo, Aba, Venceslas III (déjà épinglé en Pologne), Louis II/Jagellon (arbre Jagellon de Bohême, v40), Luxembourg et Habsbourg (arbres allemands).",
    "Prérequis : v39 et v40 exécutés.",
]
g.tree('HU_ARP', 'HUN', 'Árpád')
g.tree('HU_ANJ', 'HUN', 'Anjou-Hongrie')
g.tree('HU_HUN', 'HUN', 'Hunyadi')
g.tree('HU_ZAP', 'HUN', 'Zápolya')
g.tree('PL_PIAST', 'POL', 'Piast')
g.tree('PL_JAG', 'POL', 'Jagellon', entry='2330c043-bc06-4464-92c0-dbc885739729')
g.tree('CZ_PREM', 'CZE', 'Přemyslides', entry='b53dda9c-6240-43c2-8503-91cda7693dd1')
g.tree('DE_HAB', 'DEU', 'Habsbourg', entry='6b34bc03-d0ad-4c48-a485-f541cecafd5d')
g.tree('DE_OTT', 'DEU', 'Ottoniens', entry='99d9527e-fbca-4280-ac55-426024c9ed90')
g.tree('DE_WIT', 'DEU', 'Wittelsbach', entry='e76d91a3-1b9c-4703-85b3-9f711b6d6199')
g.tree('DE_LUX', 'DEU', 'Luxembourg', entry='7c6654ff-ce07-440b-b856-fdfbaeb9a535')
g.tree('FR_CAP', 'FRA', 'Capétiens', entry='6f093aa5-08bc-4b10-ba1f-5755c2819d3d')
g.tree('ES_BAR', 'ESP', 'Maison de Barcelone', entry='5ff35d9f-8f58-458a-93b4-a1fadc1949f9')
g.reposition = {'PL_PIAST', 'PL_JAG', 'CZ_PREM'}
Gen.FIXB = {'1fb35d8e-0c0e-4218-bdfe-02b7e21890a9': 1035, 'a73a4282-9de1-4aca-84e3-7fdf6a5f0f37': 940}

P, S = g.par, g.sp
AR = 'Árpád'
RUR = 'Rurikides (Kiev)'

# ================================================================ ÁRPÁD
g.m('hu.arpad', 'Árpád', 845, 907, 'Grand-prince des Hongrois', AR, 'HU_ARP', 'h', True, approx='naissance « vers 845 », mort « vers 907 »')
g.m('hu.zoltan', 'Zoltán', 880, 947, 'Grand-prince des Hongrois', AR, 'HU_ARP', 'h', True, approx='dates « vers 880 – vers 947 »')
g.m('hu.taksony', 'Taksony', 931, 972, 'Grand-prince des Hongrois', AR, 'HU_ARP', 'h', True, approx='dates « vers 931 – vers 972 »')
g.m('hu.michael', 'Michel (fils de Taksony)', None, None, 'Prince, père de Vazul', AR, 'HU_ARP', 'h', approx='dates inconnues')
g.m('hu.vazul', 'Vazul', None, None, 'Prince, ancêtre des Árpád postérieurs', AR, 'HU_ARP', 'h', approx='dates inconnues')
g.m('hu.geza', 'Géza', 940, 997, 'Grand-prince des Hongrois', AR, 'HU_ARP', 'h', True, approx='dates « vers 940 – 997 » (écart avec Taksony, vers 931, très court : dates approximatives)')
g.m('hu.sarolt', 'Sarolt', None, None, 'Grande-princesse', 'Gyula (Transylvanie)', 'HU_ARP', 'f', flag='Famille des Gyula (Transylvanie) : sans arbre ; dates inconnues', approx='dates inconnues')
g.m('hu.stephen1', 'Étienne Ier (saint Étienne)', 975, 1038, 'Premier roi de Hongrie (1000/1001-1038)', AR, 'HU_ARP', 'h', True, approx='naissance « vers 975 »')
g.m('hu.gisela', 'Gisèle de Bavière', 985, 1065, 'Reine de Hongrie', 'Ottoniens (Bavière)', 'DE_OTT', 'f', approx='naissance « vers 985 »')
g.m('hu.emeric_s', 'Émeric (saint Émeric)', 1007, 1031, 'Prince héritier de Hongrie', AR, 'HU_ARP', 'h')
g.m('hu.andrew1', 'André Ier', 1015, 1060, 'Roi de Hongrie (1046-1060)', AR, 'HU_ARP', 'h', True, approx='naissance « vers 1015 »')
g.m('hu.anastasia', 'Anastasia de Kiev', 1023, None, 'Reine de Hongrie', RUR, 'HU_ARP', 'f', flag='Rurikides (Kiev/Russie) : arbre à créer avec la Russie ; année de mort discordante (1074 ou 1094/1096), non renseignée', approx='mort : sources discordantes, non renseignée')
g.m('hu.bela1', 'Béla Ier', 1016, 1063, 'Roi de Hongrie (1060-1063)', AR, 'HU_ARP', 'h', True, approx='naissance « vers 1016 »')
g.m('hu.richeza', 'Richeza de Pologne (reine de Hongrie)', 1013, 1075, 'Reine de Hongrie', 'Piast', 'PL_PIAST', 'f', approx='naissance « vers 1013 » (certaines sources la nomment Adélaïde)')
g.m('hu.solomon', 'Salomon', 1053, 1087, 'Roi de Hongrie (1063-1074)', AR, 'HU_ARP', 'h', True)
g.m('hu.geza1', 'Géza Ier', 1040, 1077, 'Roi de Hongrie (1074-1077)', AR, 'HU_ARP', 'h', True, approx='naissance « vers 1040 »')
g.m('hu.sophia_g', 'Sophie (épouse de Géza Ier)', None, None, 'Reine de Hongrie', 'Origine inconnue', 'HU_ARP', 'f', flag='Origine inconnue (comtesse allemande ?) : sans arbre ; dates inconnues', approx='dates inconnues')
g.m('hu.ladislas1', 'Ladislas Ier (saint Ladislas)', 1040, 1095, 'Roi de Hongrie (1077-1095)', AR, 'HU_ARP', 'h', True)
g.m('hu.adelaide_r', 'Adélaïde de Rheinfelden', None, None, 'Reine de Hongrie', 'Rheinfelden (Souabe)', 'HU_ARP', 'f', flag='Rheinfelden (Souabe) : sans arbre ; dates non vérifiées', approx='dates non vérifiées')
g.m('hu.coloman', 'Coloman le Savant', 1070, 1116, 'Roi de Hongrie (1095-1116)', AR, 'HU_ARP', 'h', True, approx='naissance « vers 1070 »')
g.m('hu.felicia', 'Félicie de Sicile', None, None, 'Reine de Hongrie', 'Hauteville (Sicile)', 'HU_ARP', 'f', flag='Hauteville (Sicile/Italie) : arbre à créer avec l\'Italie ; dates inconnues', approx='dates inconnues (morte avant 1112)')
g.m('hu.euphemia', 'Euphémie de Kiev', 1096, None, 'Reine de Hongrie', RUR, 'HU_ARP', 'f', flag='Rurikides (Kiev/Russie) : arbre à créer avec la Russie ; mort non renseignée', approx='naissance 1096 ou 1097 ; mort non renseignée')
g.m('hu.almos', 'Álmos', 1070, 1127, 'Duc de Croatie', AR, 'HU_ARP', 'h', approx='dates « vers 1070 – 1127 » (non revérifiées)')
g.m('hu.predslava', 'Predslava de Kiev', None, None, 'Duchesse de Croatie', RUR, 'HU_ARP', 'f', flag='Rurikides (Kiev/Russie) : arbre à créer avec la Russie ; dates inconnues', approx='dates inconnues')
g.m('hu.stephen2', 'Étienne II', 1101, 1131, 'Roi de Hongrie (1116-1131)', AR, 'HU_ARP', 'h', True)
g.m('hu.bela2', 'Béla II l\'Aveugle', 1109, 1141, 'Roi de Hongrie (1131-1141)', AR, 'HU_ARP', 'h', True, approx='naissance entre 1108 et 1110')
g.m('hu.helena_r', 'Hélène de Rascie', None, None, 'Reine de Hongrie, régente', 'Maison de Rascie (Serbie)', 'HU_ARP', 'f', flag='Maison de Rascie (Serbie) : arbre à créer avec la Serbie ; dates non renseignées', approx='dates non renseignées')
g.m('hu.geza2', 'Géza II', 1130, 1162, 'Roi de Hongrie (1141-1162)', AR, 'HU_ARP', 'h', True)
g.m('hu.ladislas2', 'Ladislas II', 1131, 1163, 'Roi de Hongrie (1162-1163)', AR, 'HU_ARP', 'h', True)
g.m('hu.stephen4', 'Étienne IV', 1133, 1165, 'Roi de Hongrie (1163)', AR, 'HU_ARP', 'h', True, approx='naissance « vers 1133 »')
g.m('hu.euphrosyne', 'Euphrosyne de Kiev', 1130, 1193, 'Reine de Hongrie', RUR, 'HU_ARP', 'f', flag='Rurikides (Kiev/Russie) : arbre à créer avec la Russie', approx='dates « vers 1130 – vers 1193 »')
g.m('hu.stephen3', 'Étienne III', 1147, 1172, 'Roi de Hongrie (1162-1172)', AR, 'HU_ARP', 'h', True)
g.m('hu.agnes_aut', 'Agnès d\'Autriche (reine de Hongrie)', 1154, 1182, 'Reine de Hongrie', 'Babenberg (Autriche)', 'HU_ARP', 'f', flag='Babenberg (Autriche) : arbre à créer avec l\'Autriche')
g.m('hu.bela3', 'Béla III', 1148, 1196, 'Roi de Hongrie (1172-1196)', AR, 'HU_ARP', 'h', True, approx='naissance « vers 1148 »')
g.m('hu.agnes_ant', 'Agnès d\'Antioche (Châtillon)', 1154, 1184, 'Reine de Hongrie', 'Châtillon (Antioche)', 'HU_ARP', 'f', flag='Châtillon (principauté d\'Antioche) : sans arbre', approx='dates « vers 1154 – vers 1184 »')
g.m('hu.margaret_fr', 'Marguerite de France (reine de Hongrie)', 1158, 1197, 'Reine de Hongrie', 'Capétiens', 'FR_CAP', 'f')
g.m('hu.emeric', 'Émeric Ier', 1174, 1204, 'Roi de Hongrie (1196-1204)', AR, 'HU_ARP', 'h', True)
g.m('hu.constance_ar', 'Constance d\'Aragon', 1179, 1222, 'Reine de Hongrie, impératrice du Saint-Empire', 'Maison de Barcelone', 'ES_BAR', 'f')
g.m('hu.ladislas3', 'Ladislas III', 1200, 1205, 'Roi de Hongrie (1204-1205), enfant', AR, 'HU_ARP', 'h', True, approx='naissance 1200 ; mort 1205')
g.m('hu.andrew2', 'André II', 1177, 1235, 'Roi de Hongrie (1205-1235)', AR, 'HU_ARP', 'h', True, approx='naissance « vers 1177 »')
g.m('hu.gertrude', 'Gertrude de Méranie', 1185, 1213, 'Reine de Hongrie', 'Andechs-Méranie', 'HU_ARP', 'f', flag='Comtes d\'Andechs-Méranie (Bavière) : sans arbre', approx='naissance « vers 1185 »')
g.m('hu.yolanda_c', 'Yolande de Courtenay', 1200, 1233, 'Reine de Hongrie', 'Courtenay', 'HU_ARP', 'f', flag='Maison de Courtenay (Constantinople) : sans arbre', approx='naissance « vers 1200 » (une source : vers 1198)')
g.m('hu.beatrice_e', 'Béatrice d\'Este', None, None, 'Reine de Hongrie', 'Maison d\'Este', 'HU_ARP', 'f', flag='Maison d\'Este (Italie) : arbre à créer avec l\'Italie ; dates non renseignées', approx='dates non renseignées')
g.m('hu.bela4', 'Béla IV', 1206, 1270, 'Roi de Hongrie (1235-1270)', AR, 'HU_ARP', 'h', True)
g.m('hu.maria_l', 'Marie Lascaris', 1207, 1270, 'Reine de Hongrie', 'Lascaris (Nicée)', 'HU_ARP', 'f', flag='Lascaris (Empire de Nicée/Byzance) : arbre à créer avec la Grèce', approx='naissance 1207 ou 1208')
g.m('hu.elisabeth_s', 'Élisabeth de Hongrie (sainte Élisabeth)', 1207, 1231, 'Landgravine de Thuringe, sainte', AR, 'HU_ARP', 'f')
g.m('hu.stephen_post', 'Étienne le Posthume', None, 1272, 'Duc de Slavonie', AR, 'HU_ARP', 'h', approx='naissance inconnue (posthume : après 1235)')
g.m('hu.tomasina', 'Tomasina Morosini', None, None, 'Duchesse de Slavonie', 'Morosini (Venise)', 'HU_ARP', 'f', flag='Famille Morosini (Venise) : sans arbre ; dates inconnues', approx='dates inconnues')
g.m('hu.yolanda_p', 'Yolande de Hongrie (duchesse de Grande-Pologne)', 1235, 1298, 'Duchesse de Grande-Pologne', AR, 'HU_ARP', 'f', approx='dates « vers 1235 – 1298 »')
g.m('hu.elisabeth_b', 'Élisabeth de Hongrie (duchesse de Bavière)', 1236, 1271, 'Duchesse de Basse-Bavière', AR, 'HU_ARP', 'f')
g.m('hu.stephen5', 'Étienne V', 1239, 1272, 'Roi de Hongrie (1270-1272)', AR, 'HU_ARP', 'h', True)
g.m('hu.elisabeth_cu', 'Élisabeth la Coumane', 1244, 1290, 'Reine de Hongrie', 'Coumans', 'HU_ARP', 'f', flag='Coumans (peuple nomade des steppes) : sans arbre ; origine exacte incertaine')
g.m('hu.mary_n', 'Marie de Hongrie (reine de Naples)', 1257, 1323, 'Reine de Naples', AR, 'HU_ARP', 'f', approx='naissance « vers 1257 » (incohérent avec la naissance de sa mère, 1244 : l\'une des deux dates est approximative)')
g.m('hu.ladislas4', 'Ladislas IV le Coumain', 1262, 1290, 'Roi de Hongrie (1272-1290)', AR, 'HU_ARP', 'h', True)
g.m('hu.elisabeth_sic', 'Élisabeth de Sicile', None, None, 'Reine de Hongrie', 'Anjou-Sicile', 'HU_ARP', 'f', flag='Anjou-Sicile/Naples (Italie) : arbre à créer avec l\'Italie ; dates non renseignées', approx='dates non renseignées')
g.m('hu.andrew3', 'André III le Vénitien', 1265, 1301, 'Roi de Hongrie (1290-1301), dernier Árpád', AR, 'HU_ARP', 'h', True, approx='naissance « vers 1265 »')
g.m('hu.fenenna', 'Fenenna de Couïavie', None, 1295, 'Reine de Hongrie', 'Piast de Couïavie', 'HU_ARP', 'f', flag='Piast de Couïavie : rattacher à l\'arbre Piast quand le lien avec ses parents sera établi ; naissance non renseignée', approx='naissance non renseignée')
g.m('hu.agnes_hab', 'Agnès d\'Autriche (1280, reine de Hongrie)', 1280, 1364, 'Reine de Hongrie', 'Habsbourg', 'DE_HAB', 'f', approx='naissance 1280 ou 1281')
g.m('hu.boles_pieux', 'Boleslas le Pieux', 1221, 1279, 'Duc de Grande-Pologne', 'Piast', 'PL_PIAST', 'h', approx='naissance « vers 1221 »')
g.m('hu.otto3', 'Otton III de Basse-Bavière (Béla V)', 1261, 1312, 'Duc de Basse-Bavière, roi de Hongrie (1305-1307), prétendant', 'Wittelsbach', 'DE_WIT', 'h', approx='règne en Hongrie : 1305-1307 ou 1308 selon les sources')

# --- liens Árpád
P('hu.arpad', 'hu.zoltan'); P('hu.zoltan', 'hu.taksony')
P('hu.taksony', 'hu.geza'); P('hu.taksony', 'hu.michael'); P('hu.michael', 'hu.vazul')
S('hu.geza', 'hu.sarolt')
P('hu.geza', 'hu.stephen1'); P('hu.sarolt', 'hu.stephen1')
S('hu.stephen1', 'hu.gisela')
P(X('b0cf4c02'), 'hu.gisela'); P(X('c4651f24'), 'hu.gisela')
P('hu.stephen1', 'hu.emeric_s'); P('hu.gisela', 'hu.emeric_s')
for c in ('hu.andrew1', 'hu.bela1'):
    P('hu.vazul', c)
S('hu.andrew1', 'hu.anastasia')
for c in ('hu.solomon', 'cz.adelaide_h'):
    P('hu.andrew1', c); P('hu.anastasia', c)
S('hu.solomon', 'pl.judith_sw')
S('hu.bela1', 'hu.richeza')
P('pl.mieszko2', 'hu.richeza'); P('pl.richeza', 'hu.richeza')
for c in ('hu.geza1', 'hu.ladislas1'):
    P('hu.bela1', c); P('hu.richeza', c)
S('hu.geza1', 'hu.sophia_g')
for c in ('hu.coloman', 'hu.almos'):
    P('hu.geza1', c); P('hu.sophia_g', c)
S('hu.ladislas1', 'hu.adelaide_r')
S('hu.coloman', 'hu.felicia'); S('hu.coloman', 'hu.euphemia')
P('hu.coloman', 'hu.stephen2'); P('hu.felicia', 'hu.stephen2')
S('hu.almos', 'hu.predslava')
P('hu.almos', 'hu.bela2'); P('hu.predslava', 'hu.bela2')
S('hu.bela2', 'hu.helena_r')
for c in ('hu.geza2', 'hu.ladislas2', 'hu.stephen4'):
    P('hu.bela2', c); P('hu.helena_r', c)
S('hu.geza2', 'hu.euphrosyne')
for c in ('hu.stephen3', 'hu.bela3'):
    P('hu.geza2', c); P('hu.euphrosyne', c)
S('hu.stephen3', 'hu.agnes_aut')
S('hu.bela3', 'hu.agnes_ant'); S('hu.bela3', 'hu.margaret_fr')
P(X('c6df57e2'), 'hu.margaret_fr')
for c in ('hu.emeric', 'hu.andrew2', 'cz.constance_h'):
    P('hu.bela3', c); P('hu.agnes_ant', c)
S('hu.emeric', 'hu.constance_ar')
P(X('7e363dff'), 'hu.constance_ar'); P(X('fcaf2ed0'), 'hu.constance_ar')
P('hu.emeric', 'hu.ladislas3'); P('hu.constance_ar', 'hu.ladislas3')
S('hu.constance_ar', X('df121566'))                           # Frédéric II (2e mari)
S('hu.andrew2', 'hu.gertrude'); S('hu.andrew2', 'hu.yolanda_c'); S('hu.andrew2', 'hu.beatrice_e')
for c in ('hu.bela4', 'hu.elisabeth_s'):
    P('hu.andrew2', c); P('hu.gertrude', c)
P('hu.andrew2', X('f66e6467')); P('hu.yolanda_c', X('f66e6467'))     # Yolande d'Aragon-Hongrie
P('hu.andrew2', 'hu.stephen_post'); P('hu.beatrice_e', 'hu.stephen_post')
S('hu.stephen_post', 'hu.tomasina')
P('hu.stephen_post', 'hu.andrew3'); P('hu.tomasina', 'hu.andrew3')
S('hu.bela4', 'hu.maria_l')
for c in ('hu.stephen5', 'pl.kinga', 'hu.yolanda_p', 'hu.elisabeth_b'):
    P('hu.bela4', c); P('hu.maria_l', c)
S('hu.yolanda_p', 'hu.boles_pieux')
P('hu.boles_pieux', 'pl.jadwiga_k'); P('hu.yolanda_p', 'pl.jadwiga_k')
S('hu.elisabeth_b', X('ccb61e02'))                          # Henri XIII de Basse-Bavière
P(X('ccb61e02'), 'hu.otto3'); P('hu.elisabeth_b', 'hu.otto3')
S('hu.stephen5', 'hu.elisabeth_cu')
for c in ('hu.ladislas4', 'hu.mary_n'):
    P('hu.stephen5', c); P('hu.elisabeth_cu', c)
S('hu.ladislas4', 'hu.elisabeth_sic')
S('hu.andrew3', 'hu.fenenna'); S('hu.andrew3', 'hu.agnes_hab')
P(X('1c54b243'), 'hu.agnes_hab'); P(X('f0503fd3'), 'hu.agnes_hab')    # Albert Ier et Élisabeth de Tyrol

# ================================================================ ANJOU-HONGRIE
AJ = 'Anjou-Hongrie (Capétiens d\'Anjou)'
g.m('hu.charles2', 'Charles II d\'Anjou (Naples)', 1254, 1309, 'Roi de Naples', 'Anjou-Naples (Capétiens)', 'HU_ANJ', 'h', flag='Anjou-Naples (Italie) : à déplacer dans l\'arbre de l\'Italie quand il sera créé')
g.m('hu.charles_martel', 'Charles Martel d\'Anjou', 1271, 1295, 'Prince de Salerne, prétendant au trône de Hongrie', AJ, 'HU_ANJ', 'h')
g.m('hu.clemence_h', 'Clémence de Habsbourg', 1262, 1293, 'Princesse de Salerne', 'Habsbourg', 'DE_HAB', 'f', approx='mort février 1293 (certaines sources : 1295)')
g.m('hu.charles_robert', 'Charles Ier Robert', 1288, 1342, 'Roi de Hongrie (1308-1342)', AJ, 'HU_ANJ', 'h', True)
g.m('hu.maria_byt', 'Marie de Bytom', None, 1317, 'Reine de Hongrie', 'Piast de Bytom', 'HU_ANJ', 'f', flag='Piast de Bytom (Silésie) : rattacher à l\'arbre Piast quand le lien avec ses parents sera établi ; naissance avant 1295', approx='naissance avant 1295')
g.m('hu.beatrice_l', 'Béatrice de Luxembourg (reine de Hongrie)', 1305, 1319, 'Reine de Hongrie', 'Luxembourg', 'DE_LUX', 'f')
g.m('hu.andrew_cal', 'André de Hongrie, duc de Calabre', 1327, 1345, 'Duc de Calabre, mari de Jeanne Ire de Naples', AJ, 'HU_ANJ', 'h')
g.m('hu.stephen_slav', 'Étienne de Hongrie, duc de Slavonie', 1332, 1354, 'Duc de Slavonie', AJ, 'HU_ANJ', 'h')
P('hu.charles2', 'hu.charles_martel'); P('hu.mary_n', 'hu.charles_martel'); S('hu.charles2', 'hu.mary_n')
S('hu.charles_martel', 'hu.clemence_h')
P(X('1320ad14'), 'hu.clemence_h'); P(X('5b131e5f'), 'hu.clemence_h')
for c in ('hu.charles_robert', X('624bfa0b')):
    P('hu.charles_martel', c); P('hu.clemence_h', c)
S('hu.charles_robert', 'hu.maria_byt'); S('hu.charles_robert', 'hu.beatrice_l'); S('hu.charles_robert', 'pl.elisabeth_pl')
P(X('ca6ed17a'), 'hu.beatrice_l'); P(X('a0bcec6b'), 'hu.beatrice_l')
for c in ('pl.louis1', 'hu.andrew_cal', 'hu.stephen_slav'):
    P('hu.charles_robert', c); P('pl.elisabeth_pl', c)
g.pin(X('8921ecd5'), 'HU_ANJ')                                 # Marie d'Anjou-Hongrie (reine, épouse de Sigismond)

# ================================================================ HUNYADI
HU = 'Hunyadi'
g.m('hu.john_h', 'Jean Hunyadi', 1406, 1456, 'Voïvode de Transylvanie, régent de Hongrie (1446-1453)', HU, 'HU_HUN', 'h', True, approx='naissance entre 1405 et 1407')
g.m('hu.szilagyi', 'Élisabeth Szilágyi', None, None, 'Épouse de Jean Hunyadi', 'Szilágyi (noblesse hongroise)', 'HU_HUN', 'f', flag='Famille Szilágyi (noblesse hongroise) : sans arbre ; dates non renseignées', approx='dates non renseignées')
g.m('hu.ladislas_h', 'Ladislas Hunyadi', 1431, 1457, 'Ban de Croatie', HU, 'HU_HUN', 'h')
g.m('hu.matthias', 'Mathias Corvin', 1443, 1490, 'Roi de Hongrie (1458-1490)', HU, 'HU_HUN', 'h', True)
g.m('hu.elisabeth_celje', 'Élisabeth de Celje (épouse de Mathias Corvin)', None, 1455, 'Reine de Hongrie (fiancée/épouse)', 'Comtes de Celje', 'HU_HUN', 'f', flag='Comtes de Celje (Slovénie) : arbre à créer avec la Slovénie ; naissance non renseignée', approx='naissance non renseignée')
g.m('hu.beatrice_n', 'Béatrice de Naples', 1457, 1508, 'Reine de Hongrie', 'Maison d\'Aragon-Naples', 'HU_HUN', 'f', flag='Maison d\'Aragon-Naples (Italie) : arbre à créer avec l\'Italie')
g.m('hu.john_corv', 'Jean Corvin', 1473, 1504, 'Duc de Slavonie et d\'Opava, fils illégitime de Mathias', HU, 'HU_HUN', 'h')
S('hu.john_h', 'hu.szilagyi')
for c in ('hu.ladislas_h', 'hu.matthias'):
    P('hu.john_h', c); P('hu.szilagyi', c)
S('hu.matthias', 'hu.elisabeth_celje'); S('hu.matthias', 'cz.catherine_pod'); S('hu.matthias', 'hu.beatrice_n')
P('hu.matthias', 'hu.john_corv')

# ================================================================ ZÁPOLYA
ZA = 'Zápolya'
g.m('hu.stephen_z', 'Étienne Zápolya', None, 1499, 'Palatin de Hongrie (1492-1499)', ZA, 'HU_ZAP', 'h', approx='naissance inconnue')
g.m('hu.hedwig_c', 'Hedwige de Cieszyn', None, None, 'Épouse d\'Étienne Zápolya', 'Piast de Cieszyn', 'HU_ZAP', 'f', flag='Piast de Cieszyn (Silésie) : rattacher à l\'arbre Piast ; dates non renseignées', approx='dates non renseignées')
g.m('hu.john_z', 'Jean Ier Zápolya', 1487, 1540, 'Roi de Hongrie (1526-1540), voïvode de Transylvanie', ZA, 'HU_ZAP', 'h', True)
g.m('hu.john_sig', 'Jean-Sigismond Zápolya', 1540, 1571, 'Roi élu de Hongrie, premier prince de Transylvanie', ZA, 'HU_ZAP', 'h', True)
S('hu.stephen_z', 'hu.hedwig_c')
for c in ('hu.john_z', 'pl.barbara_z'):
    P('hu.stephen_z', c); P('hu.hedwig_c', c)
S('hu.john_z', 'pl.isabelle')
P('hu.john_z', 'hu.john_sig'); P('pl.isabelle', 'hu.john_sig')

# ================================================================ rattachements aux bons arbres
g.move('cz.adelaide_h', 'HU_ARP', 'Árpád'); g.setdates('cz.adelaide_h', 1040, 1062)
g.move('cz.constance_h', 'HU_ARP', 'Árpád')
g.move('pl.kinga', 'HU_ARP', 'Árpád')
g.move('pl.barbara_z', 'HU_ZAP', 'Zápolya')

if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
