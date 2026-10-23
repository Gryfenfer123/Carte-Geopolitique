import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(64, "Allemagne — Welf : de Brunswick-Lunebourg à Hanovre, Wolfenbüttel-Bevern, maison de Hanovre actuelle")
g.notes = [
    "Complète l'arbre Welf (rien n'est supprimé) : chaîne continue d'Albert le Grand (XIIIᵉ s.) à Ernest-Auguste de Hanovre (1629), en passant par Albert le Gros, Magnus Ier et II, Bernard Ier, Frédéric le Pieux, Otton V, Henri le Moyen, Ernest le Confesseur, Guillaume et Georges de Calenberg ; branche de Wolfenbüttel-Bevern jusqu'à Louis-Rodolphe et Ferdinand-Albert II ; maison de Hanovre au XIXᵉ et XXᵉ siècle (rois de Hanovre, duc de Brunswick, chef actuel).",
    "Sources : Wikipédia en anglais (page de chaque duc : parents, épouses, enfants avec dates) ; Wikipédia allemand pour Bernard Ier (naissance incertaine entre 1358 et 1364 : laissée vide).",
    "Les dynasties de Hanovre devenues britanniques (George Ier à Victoria) restent dans l'arbre du Royaume-Uni ; elles apparaissent ici en « étrangers ». Georges-Guillaume de Celle (père de Sophie-Dorothée) n'est pas ajouté : page introuvable.",
    "Épouses de familles sans arbre (Montferrat, Werle, Brandebourg-Stendal, Anhalt, Poméranie, Mecklembourg, Saxe-Lauenbourg, Nassau-Siegen, Hesse-Darmstadt, Hesse-Eschwege, Oettingen…) : placées dans l'arbre Welf et signalées. Marguerite de Saxe (1469) et Madeleine de Brandebourg sont créées dans les arbres Wettin et Hohenzollern.",
    "Prérequis : v62 et v63 exécutés.",
]
g.tree('DE_WEL', 'DEU', 'Welf', entry=E('db5ef554'))
g.tree('DE_WET', 'DEU', 'Wettin', entry=E('309f20ea'))
g.tree('DE_HOH', 'DEU', 'Hohenzollern', entry=E('39895573'))
g.tree('DK_OLD', 'DNK', "Maison d'Oldenbourg", entry=E('7fc4995d'))
g.tree('DK_GLU', 'DNK', 'Schleswig-Holstein-Glücksbourg', entry=E('78bf5e64'))
g.reposition = {'DE_WEL'}
P, S = g.par, g.sp

def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)

def V(code, name, b, d, title, dyn, g_, tree='DE_WEL', leader=False, approx=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)

BL = 'Welf (Brunswick-Lunebourg)'
FL = lambda n: f'Maison {n} : sans arbre'

# ---------- de la branche d'Albert le Grand jusqu'à Ernest le Confesseur ----------
ALB1 = X('132eeb')
V('wf.adelheid', 'Adélaïde de Montferrat', None, None, 'Duchesse de Brunswick-Lunebourg', 'Montferrat', 'f', flag=FL('de Montferrat'), approx='dates non données par la page d\'Albert II')
S(ALB1, 'wf.adelheid')
V('wf.albert2', 'Albert II le Gros', 1268, 1318, 'Duc de Brunswick-Lunebourg', BL, 'h', approx='naissance « vers 1268 » (page d\'Albert II)')
kids([ALB1, 'wf.adelheid'], ['wf.albert2'])
V('wf.rixa', 'Rixa de Werle', None, None, 'Duchesse de Brunswick-Lunebourg', 'Werle', 'f', flag=FL('de Werle (Mecklembourg)'), approx='dates non données par la page d\'Albert II')
S('wf.albert2', 'wf.rixa')
V('wf.magnus1', 'Magnus Ier le Pieux', 1304, 1369, 'Duc de Brunswick-Lunebourg', BL, 'h')
kids(['wf.albert2', 'wf.rixa'], ['wf.magnus1'])
V('wf.sophie_stendal', 'Sophie de Brandebourg-Stendal', None, 1356, 'Duchesse de Brunswick-Lunebourg', 'Ascanie (Brandebourg)', 'f', flag=FL('d\'Ascanie (Brandebourg-Stendal)'), approx='naissance non donnée par la page de Magnus Ier')
S('wf.magnus1', 'wf.sophie_stendal')
V('wf.magnus2', 'Magnus II Torquatus', 1328, 1373, 'Duc de Brunswick-Lunebourg', BL, 'h', approx='naissance 1328 (encadré) ou vers 1324 (texte) selon la page de Magnus II')
kids(['wf.magnus1', 'wf.sophie_stendal'], ['wf.magnus2'])
V('wf.catherine_anhalt', 'Catherine d\'Anhalt-Bernbourg', None, None, 'Duchesse de Brunswick-Lunebourg', 'Anhalt', 'f', flag=FL('d\'Anhalt'), approx='dates non données par la page de Magnus II')
S('wf.magnus2', 'wf.catherine_anhalt')
V('wf.bernard1', 'Bernard Ier de Brunswick-Lunebourg', None, 1434, 'Duc de Brunswick-Lunebourg', BL, 'h', approx='naissance entre 1358 et 1364 (page allemande), laissée vide')
V('wf.henri_doux', 'Henri le Doux', None, 1416, 'Duc de Brunswick-Lunebourg', BL, 'h', approx='naissance non donnée par la page d\'Henri le Doux')
kids(['wf.magnus2', 'wf.catherine_anhalt'], ['wf.bernard1', 'wf.henri_doux'])
V('wf.sophie_pom', 'Sophie de Poméranie', None, 1406, 'Duchesse de Brunswick-Lunebourg', 'Poméranie', 'f', flag=FL('de Poméranie'), approx='naissance non donnée par la page d\'Henri le Doux')
S('wf.henri_doux', 'wf.sophie_pom')
kids(['wf.henri_doux', 'wf.sophie_pom'], [X('578818')])          # Catherine de Brunswick-Lunebourg (épouse de Frédéric Ier de Saxe)
V('wf.marg_saxe_w', 'Marguerite de Saxe-Wittenberg', None, 1429, 'Duchesse de Brunswick-Lunebourg', 'Ascanie (Saxe-Wittenberg)', 'f', flag=FL('d\'Ascanie (Saxe-Wittenberg)'),
  approx='naissance non donnée par la page de Bernard Ier (de.wikipedia)')
S('wf.bernard1', 'wf.marg_saxe_w')
V('wf.frederic2', 'Frédéric II le Pieux de Brunswick-Lunebourg', 1418, 1478, 'Duc de Brunswick-Lunebourg', BL, 'h')
kids(['wf.bernard1', 'wf.marg_saxe_w'], ['wf.frederic2'])
V('wf.magdalene_br', 'Madeleine de Brandebourg', 1412, 1454, 'Duchesse de Brunswick-Lunebourg', 'Hohenzollern', 'f', 'DE_HOH')
kids([X('cc4d49'), X('55bbdc')], ['wf.magdalene_br'])
S('wf.frederic2', 'wf.magdalene_br')
V('wf.otto5', 'Otton V le Victorieux', 1439, 1471, 'Duc de Brunswick-Lunebourg', BL, 'h')
kids(['wf.frederic2', 'wf.magdalene_br'], ['wf.otto5'])
V('wf.anne_nassau', 'Anne de Nassau-Siegen', None, None, 'Duchesse de Brunswick-Lunebourg', 'Nassau-Siegen', 'f', flag=FL('de Nassau-Siegen'), approx='dates non données par la page d\'Otton V')
S('wf.otto5', 'wf.anne_nassau')
V('wf.henri_moyen', 'Henri le Moyen', 1468, 1532, 'Duc de Brunswick-Lunebourg', BL, 'h', approx='naissance 1468 (page d\'Henri le Moyen) ; vers 1467 sur la page d\'Otton V')
kids(['wf.otto5', 'wf.anne_nassau'], ['wf.henri_moyen'])
V('wf.marg_saxe', 'Marguerite de Saxe (1469-1528)', 1469, 1528, 'Duchesse de Brunswick-Lunebourg', 'Wettin', 'f', 'DE_WET')
kids([X('062d7d'), X('d6d007')], ['wf.marg_saxe'])               # Ernest de Saxe + Élisabeth de Bavière
S('wf.henri_moyen', 'wf.marg_saxe')
V('wf.ernest_conf', 'Ernest le Confesseur', 1497, 1546, 'Duc de Brunswick-Lunebourg', BL, 'h', approx='mort 1546 (encadré) ou 1547 (texte) selon les sources')
kids(['wf.henri_moyen', 'wf.marg_saxe'], ['wf.ernest_conf'])
V('wf.sophie_meck', 'Sophie de Mecklembourg-Schwerin', None, 1541, 'Duchesse de Brunswick-Lunebourg', 'Mecklembourg', 'f', flag=FL('de Mecklembourg-Schwerin'), approx='naissance non donnée par la page d\'Ernest')
S('wf.ernest_conf', 'wf.sophie_meck')
V('wf.henri_dann', 'Henri de Brunswick-Dannenberg', 1533, 1598, 'Duc de Brunswick-Dannenberg', BL, 'h')
V('wf.guillaume_lun', 'Guillaume le Jeune de Brunswick-Lunebourg', 1535, 1592, 'Duc de Brunswick-Lunebourg (Celle)', BL, 'h')
kids(['wf.ernest_conf', 'wf.sophie_meck'], ['wf.henri_dann', 'wf.guillaume_lun'])

# ---------- Calenberg : Guillaume -> Georges -> Ernest-Auguste ----------
CDK, DSL = X('cc9ca1'), X('8a2b6b')                            # Christian III de Danemark + Dorothée de Saxe-Lauenbourg
V('wf.dorothee_dk', 'Dorothée de Danemark (1546-1617)', 1546, 1617, 'Duchesse de Brunswick-Lunebourg', "Oldenbourg (Danemark)", 'f', 'DK_OLD')
kids([CDK, DSL], ['wf.dorothee_dk'])
S('wf.guillaume_lun', 'wf.dorothee_dk')
V('wf.georges', 'Georges de Brunswick-Calenberg', 1582, 1641, 'Duc de Brunswick-Calenberg', BL, 'h')
kids(['wf.guillaume_lun', 'wf.dorothee_dk'], ['wf.georges'])
V('wf.anne_eleonore', 'Anne-Éléonore de Hesse-Darmstadt', None, None, 'Duchesse de Brunswick-Calenberg', 'Hesse', 'f', flag='Maison de Hesse : sans arbre', approx='dates non données par la page de Georges')
S('wf.georges', 'wf.anne_eleonore')
kids(['wf.georges', 'wf.anne_eleonore'], [X('84913c'), X('d6e108'), X('9cf848')])   # Ernest-Auguste, Jean-Frédéric, Sophie-Amélie

# ---------- Calenberg : Henri le Doux -> Guillaume le Victorieux -> Guillaume II -> Éric Ier -> Anne-Marie ----------
V('wf.guillaume_vict', 'Guillaume le Victorieux', 1392, 1482, 'Duc de Brunswick-Wolfenbüttel', 'Welf (Brunswick-Calenberg)', 'h', approx='naissance « vers 1392 » (page de Guillaume le Victorieux) ; la page d\'Henri le Doux donne le même âge')
kids(['wf.henri_doux', 'wf.sophie_pom'], ['wf.guillaume_vict'])
V('wf.guillaume2_cal', 'Guillaume II de Brunswick-Calenberg', 1425, 1503, 'Duc de Brunswick-Calenberg-Göttingen', 'Welf (Brunswick-Calenberg)', 'h', approx='naissance « vers 1425 » (page de Guillaume le Victorieux)')
kids(['wf.guillaume_vict'], ['wf.guillaume2_cal'])
V('wf.eric1', 'Éric Ier de Brunswick-Calenberg', 1470, 1540, 'Duc de Brunswick-Calenberg-Göttingen', 'Welf (Brunswick-Calenberg)', 'h')
kids(['wf.guillaume2_cal'], ['wf.eric1'])
V('wf.elisabeth_br', 'Élisabeth de Brandebourg (duchesse de Calenberg)', None, None, 'Duchesse de Brunswick-Calenberg-Göttingen', 'Hohenzollern', 'f', 'DE_HOH',
  flag='Ses parents (probablement Joachim Ier Nestor) ne sont pas donnés par la page d\'Éric Ier : à confirmer', approx='dates non données par la page d\'Éric Ier')
S('wf.eric1', 'wf.elisabeth_br')
kids(['wf.eric1', 'wf.elisabeth_br'], [X('c9a9ae')])             # Anne-Marie de Calenberg-Göttingen

# ---------- Dannenberg -> Wolfenbüttel ----------
V('wf.ursule', 'Ursule de Saxe-Lauenbourg', 1545, 1620, 'Duchesse de Brunswick-Dannenberg', 'Saxe-Lauenbourg', 'f', flag=FL('de Saxe-Lauenbourg'))
S('wf.henri_dann', 'wf.ursule')
V('wf.auguste_jeune', 'Auguste le Jeune de Brunswick-Wolfenbüttel', 1579, 1666, 'Duc de Brunswick-Wolfenbüttel', 'Welf (Brunswick-Wolfenbüttel)', 'h')
kids(['wf.henri_dann', 'wf.ursule'], ['wf.auguste_jeune', 'wi.dorothee_bl'])          # + Dorothée de Brunswick-Lunebourg (1570)
V('wf.dorothea_az', 'Dorothée d\'Anhalt-Zerbst', None, 1634, 'Duchesse de Brunswick-Wolfenbüttel', 'Anhalt', 'f', flag=FL('d\'Anhalt'), approx='naissance non donnée par la page d\'Auguste le Jeune')
S('wf.auguste_jeune', 'wf.dorothea_az')
V('wf.anton_ulrich', 'Antoine-Ulrich de Brunswick-Wolfenbüttel', 1633, 1714, 'Duc de Brunswick-Wolfenbüttel', 'Welf (Brunswick-Wolfenbüttel)', 'h')
kids(['wf.auguste_jeune', 'wf.dorothea_az'], ['wf.anton_ulrich'])
V('wf.elisabeth_juliane', 'Élisabeth-Julienne de Schleswig-Holstein-Norbourg', 1634, 1704, 'Duchesse de Brunswick-Wolfenbüttel', 'Schleswig-Holstein-Sonderbourg', 'f', flag=FL('de Schleswig-Holstein-Sonderbourg'))
S('wf.anton_ulrich', 'wf.elisabeth_juliane')
V('wf.louis_rodolphe', 'Louis-Rodolphe de Brunswick-Wolfenbüttel', 1671, 1735, 'Duc de Brunswick-Wolfenbüttel', 'Welf (Brunswick-Wolfenbüttel)', 'h')
kids(['wf.anton_ulrich', 'wf.elisabeth_juliane'], ['wf.louis_rodolphe'])
V('wf.christine_louise', 'Christine-Louise d\'Oettingen-Oettingen', None, None, 'Duchesse de Brunswick-Wolfenbüttel', 'Oettingen', 'f', flag=FL('d\'Oettingen'), approx='dates non données par la page de Louis-Rodolphe')
S('wf.louis_rodolphe', 'wf.christine_louise')
V('wf.antoinette_amelie', 'Antoinette-Amélie de Brunswick-Wolfenbüttel', 1696, 1762, 'Duchesse de Brunswick-Wolfenbüttel-Bevern', 'Welf (Brunswick-Wolfenbüttel)', 'f')
kids(['wf.louis_rodolphe', 'wf.christine_louise'], ['wf.antoinette_amelie', X('78641e'), 'ru.charlotte_bw'])     # + Élisabeth-Christine (impératrice) + Charlotte (tsarévna)
V('wf.ferdinand_albert1', 'Ferdinand-Albert Ier de Brunswick-Bevern', None, None, 'Duc de Brunswick-Bevern', 'Welf (Brunswick-Bevern)', 'h', approx='dates non données par la page de Ferdinand-Albert II')
V('wf.christine_wilh', 'Christine-Wilhelmine de Hesse-Eschwege', None, None, 'Duchesse de Brunswick-Bevern', 'Hesse', 'f', flag='Maison de Hesse : sans arbre', approx='dates non données par la page de Ferdinand-Albert II')
S('wf.ferdinand_albert1', 'wf.christine_wilh')
V('wf.ferdinand_albert2', 'Ferdinand-Albert II de Brunswick-Wolfenbüttel', 1680, 1735, 'Duc de Brunswick-Wolfenbüttel', 'Welf (Brunswick-Wolfenbüttel)', 'h')
kids(['wf.ferdinand_albert1', 'wf.christine_wilh'], ['wf.ferdinand_albert2'])
S('wf.ferdinand_albert2', 'wf.antoinette_amelie')
V('wf.charles1_bw', 'Charles Ier de Brunswick-Wolfenbüttel', 1713, 1780, 'Duc de Brunswick-Wolfenbüttel', 'Welf (Brunswick-Wolfenbüttel)', 'h')
kids(['wf.ferdinand_albert2', 'wf.antoinette_amelie'], ['wf.charles1_bw', 'ru.anthony_ulrich', X('949222'), X('66143a'), X('433ca5')])   # + Antoine-Ulrich, Élisabeth-Christine, Louise-Amélie, Sophie-Antoinette
V('wf.philippine', 'Philippine-Charlotte de Prusse', 1716, 1801, 'Duchesse de Brunswick-Wolfenbüttel', 'Hohenzollern', 'f', 'DE_HOH')
kids([X('55b81f'), X('f8d7ed')], ['wf.philippine'])              # Frédéric-Guillaume Ier + Sophie-Dorothée de Hanovre
S('wf.charles1_bw', 'wf.philippine')
kids(['wf.charles1_bw', 'wf.philippine'], ['we.anna_amalia'])         # Anne-Amélie (épouse d'Ernest-Auguste II de Saxe-Weimar)

# ---------- Maison de Hanovre aux XIXe-XXIe siècles ----------
HAN = 'Welf (Hanovre)'
V('wf.ernest_auguste_roi', 'Ernest-Auguste Ier de Hanovre (roi)', 1771, 1851, 'Roi de Hanovre (1837-1851)', HAN, 'h', leader=False)
kids([X('c0b6b4'), X('24b3c5')], ['wf.ernest_auguste_roi'])      # George III + Charlotte de Mecklembourg-Strelitz
V('wf.frederica_ms', 'Frédérique de Mecklembourg-Strelitz', None, 1841, 'Reine de Hanovre', 'Mecklembourg-Strelitz', 'f', flag=FL('de Mecklembourg-Strelitz'), approx='naissance non donnée par la page d\'Ernest-Auguste Ier')
S('wf.ernest_auguste_roi', 'wf.frederica_ms')
V('wf.georges5', 'Georges V de Hanovre', 1819, 1878, 'Dernier roi de Hanovre (1851-1866)', HAN, 'h')
kids(['wf.ernest_auguste_roi', 'wf.frederica_ms'], ['wf.georges5'])
V('wf.marie_alt', 'Marie de Saxe-Altenbourg', None, None, 'Reine de Hanovre', 'Wettin (Saxe-Altenbourg)', 'f', 'DE_WET', approx='dates non données par la page de Georges V')
kids(['we.joseph_alt'], ['wf.marie_alt'])
S('wf.georges5', 'wf.marie_alt')
V('wf.ernest_auguste_cp', 'Ernest-Auguste de Hanovre (1845-1923)', 1845, 1923, 'Prince héritier de Hanovre, duc de Cumberland', HAN, 'h')
kids(['wf.georges5', 'wf.marie_alt'], ['wf.ernest_auguste_cp'])
V('wf.thyra', 'Thyra de Danemark', 1853, 1933, 'Princesse héritière de Hanovre', 'Schleswig-Holstein-Glücksbourg', 'f', 'DK_GLU')
kids([X('fd4797'), X('7d1a58')], ['wf.thyra'])                    # Christian IX + Louise de Hesse-Cassel
S('wf.ernest_auguste_cp', 'wf.thyra')
V('wf.ernest_auguste_bs', 'Ernest-Auguste de Brunswick', 1887, 1953, 'Duc de Brunswick (1913-1918)', HAN, 'h')
kids(['wf.ernest_auguste_cp', 'wf.thyra'], ['wf.ernest_auguste_bs'])
S('wf.ernest_auguste_bs', 'ho.viktoria_luise')
FR = 'gr.frederica'
kids(['wf.ernest_auguste_bs', 'ho.viktoria_luise'], [FR])
V('wf.ernest_auguste4', 'Ernest-Auguste de Hanovre (1914-1987)', 1914, 1987, 'Chef de la maison de Hanovre', HAN, 'h')
V('wf.georges_guillaume', 'Georges-Guillaume de Hanovre', 1915, 2006, 'Prince de Hanovre', HAN, 'h')
V('wf.christian_oscar', 'Christian-Oscar de Hanovre', 1919, 1981, 'Prince de Hanovre', HAN, 'h')
V('wf.welf_henri', 'Welf-Henri de Hanovre', 1923, 1997, 'Prince de Hanovre', HAN, 'h')
kids(['wf.ernest_auguste_bs', 'ho.viktoria_luise'], ['wf.ernest_auguste4', 'wf.georges_guillaume', 'wf.christian_oscar', 'wf.welf_henri'])
V('wf.ortrud', 'Ortrud de Schleswig-Holstein-Sonderbourg-Glücksbourg', 1925, 1980, 'Princesse de Hanovre', 'Schleswig-Holstein-Glücksbourg', 'f', 'DK_GLU')
S('wf.ernest_auguste4', 'wf.ortrud')
V('wf.ernest_auguste5', 'Ernest-Auguste de Hanovre (né en 1954)', 1954, None, 'Chef actuel de la maison de Hanovre', HAN, 'h')
kids(['wf.ernest_auguste4', 'wf.ortrud'], ['wf.ernest_auguste5'])
S('wf.ernest_auguste5', 'mc.caroline')                           # Caroline de Monaco (arbre de Monaco)

# ---------- membres britanniques épinglés pour relier la maison de Hanovre à la branche de Calenberg ----------
for pc in (X('275a9d'), X('5c634b'), X('4891ab')):             # George Ier, George II, Frédéric de Galles
    g.pin(pc, 'DE_WEL')
P(X('275a9d'), X('5c634b')) if False else None

if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
