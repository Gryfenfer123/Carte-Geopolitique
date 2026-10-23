import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(62, "Allemagne — Wettin : Saxe-Weimar, Saxe-Gotha-Altenbourg, Saxe-Altenbourg, liens des rois de Saxe et de Saxe-Cobourg")
g.notes = [
    "Complète l'arbre Wettin (rien n'est supprimé) : lignée de Saxe-Weimar-Eisenach de Guillaume (1598) à Guillaume-Ernest, lignée de Saxe-Gotha-Altenbourg d'Ernest le Pieux à Louise, parents de Thérèse et Louise de Saxe-Hildburghausen, descendants de Frédéric-Auguste III.",
    "Sources : Wikipédia en anglais (pages de chaque duc/roi : parents, épouses, enfants avec dates). Les dates non données par ces pages sont laissées vides et signalées.",
    "Les liens avec la branche polonaise (Auguste II, Auguste III), la famille royale britannique (Albert, Victoria, Albany, Alfred), la Belgique (Léopold Ier) et la Bulgarie (Ferdinand Ier) existaient déjà : l'arbre est remis en ordre pour que ces membres apparaissent en « étrangers » dans l'arbre Wettin.",
    "Épouses de familles sans arbre (Hesse-Darmstadt, Anhalt, Saxe-Meiningen, Mecklembourg, Thurn et Taxis…) : placées dans l'arbre Wettin et signalées. Sophie des Pays-Bas : créée dans l'arbre Orange-Nassau ; Maria Pavlovna : arbre Romanov.",
    "Corrections de données à faire à la main (hors migration) : Victoire de Saxe-Cobourg-Saalfeld (duchesse de Kent) est notée née en 1768 ; Wikipédia dit 1786.",
    "Correction Wittelsbach (erreur de ma part dans v61) : Madeleine-Catherine de Deux-Ponts (1607) est la fille de Jean II de Deux-Ponts (1584-1635) et de Catherine de Rohan, pas de Jean Ier (mort en 1604). Cette migration ajoute les bons parents ; le mauvais lien Jean Ier -> Madeleine-Catherine est à supprimer dans l'appli (ou par une petite migration si Martin l'autorise).",
    "Prérequis : v61 exécuté.",
]
g.tree('DE_WET', 'DEU', 'Wettin', entry=E('309f20ea'))
g.tree('DE_HOH', 'DEU', 'Hohenzollern', entry=E('39895573'))
g.tree('RU_ROM', 'RUS', 'Romanov')
g.tree('DE_WIT', 'DEU', 'Wittelsbach', entry=E('e76d91a3'))
g.tree('DE_WEL', 'DEU', 'Welf', entry=E('db5ef554'))
g.tree('NL_ORA', 'NLD', "Maison d'Orange Nassau", entry=E('7733ccfd'))
g.tree('LU_NAS', 'LUX', 'Nassau-Weilburg')
g.reposition = {'DE_WET'}
P, S = g.par, g.sp

def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)

def W(code, name, b, d, title, dyn, g_, tree='DE_WET', leader=False, approx=None, flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)

WEI = 'Wettin (Saxe-Weimar)'
GOT = 'Wettin (Saxe-Gotha-Altenbourg)'
ALT = 'Wettin (Saxe-Altenbourg)'
FLAG_ANH = "Maison d'Anhalt : sans arbre"
FLAG_HES = 'Maison de Hesse : sans arbre'

# ---------- Saxe-Weimar ----------
GUIL = X('3aee8a')                                   # Guillaume de Saxe-Weimar (1598-1662)
W('we.eleonore_anhalt', "Éléonore-Dorothée d'Anhalt-Dessau", None, None, 'Duchesse de Saxe-Weimar', 'Anhalt', 'f', flag=FLAG_ANH,
  approx='dates non données par la page de Jean-Ernest II')
S(GUIL, 'we.eleonore_anhalt')
W('we.jean_ernest2', 'Jean-Ernest II de Saxe-Weimar', 1627, 1683, 'Duc de Saxe-Weimar (1662-1683)', WEI, 'h')
kids([GUIL, 'we.eleonore_anhalt'], ['we.jean_ernest2'])
W('we.christine_sb', 'Christine-Élisabeth de Schleswig-Holstein-Sonderbourg', 1638, 1679, 'Duchesse de Saxe-Weimar', 'Schleswig-Holstein-Sonderbourg', 'f',
  flag='Maison de Schleswig-Holstein-Sonderbourg : sans arbre')
S('we.jean_ernest2', 'we.christine_sb')
W('we.jean_ernest3', 'Jean-Ernest III de Saxe-Weimar', 1664, 1707, 'Duc de Saxe-Weimar (1683-1707)', WEI, 'h')
kids(['we.jean_ernest2', 'we.christine_sb'], ['we.jean_ernest3'])
W('we.sophie_auguste_anh', "Sophie-Auguste d'Anhalt-Zerbst", None, None, 'Duchesse de Saxe-Weimar', 'Anhalt', 'f', flag=FLAG_ANH,
  approx='dates non données par la page de Jean-Ernest III')
S('we.jean_ernest3', 'we.sophie_auguste_anh')
W('we.ernest_auguste1', 'Ernest-Auguste Ier de Saxe-Weimar-Eisenach', 1688, 1748, 'Duc de Saxe-Weimar-Eisenach (1728-1748)', WEI, 'h')
kids(['we.jean_ernest3', 'we.sophie_auguste_anh'], ['we.ernest_auguste1'])
W('we.sophie_charlotte_bay', 'Sophie-Charlotte de Brandebourg-Bayreuth', None, 1747, 'Duchesse de Saxe-Weimar-Eisenach', 'Hohenzollern (Brandebourg-Bayreuth)', 'f', 'DE_HOH',
  approx='naissance non donnée par la page d\'Ernest-Auguste Ier')
S('we.ernest_auguste1', 'we.sophie_charlotte_bay')
W('we.ernest_auguste2', 'Ernest-Auguste II Constantin de Saxe-Weimar-Eisenach', 1737, 1758, 'Duc de Saxe-Weimar-Eisenach (1748-1758)', WEI, 'h')
kids(['we.ernest_auguste1', 'we.sophie_charlotte_bay'], ['we.ernest_auguste2'])
W('we.anna_amalia', 'Anne-Amélie de Brunswick-Wolfenbüttel', 1739, 1807, 'Duchesse de Saxe-Weimar-Eisenach, régente', 'Welf (Brunswick-Wolfenbüttel)', 'f', 'DE_WEL')
S('we.ernest_auguste2', 'we.anna_amalia')
W('we.charles_auguste', 'Charles-Auguste de Saxe-Weimar-Eisenach', 1757, 1828, 'Duc puis grand-duc de Saxe-Weimar-Eisenach', WEI, 'h')
kids(['we.ernest_auguste2', 'we.anna_amalia'], ['we.charles_auguste'])
W('we.louise_hesse', 'Louise de Hesse-Darmstadt', 1757, 1830, 'Grande-duchesse de Saxe-Weimar-Eisenach', 'Hesse', 'f', flag=FLAG_HES,
  approx='dates 1757-1830 : titre du lien Wikipédia, à revérifier')
S('we.charles_auguste', 'we.louise_hesse')
W('we.charles_frederic', 'Charles-Frédéric de Saxe-Weimar-Eisenach', 1783, 1853, 'Grand-duc de Saxe-Weimar-Eisenach', WEI, 'h')
kids(['we.charles_auguste', 'we.louise_hesse'], ['we.charles_frederic'])
W('we.maria_pavlovna', 'Maria Pavlovna de Russie', 1786, 1859, 'Grande-duchesse de Saxe-Weimar-Eisenach', 'Romanov', 'f', 'RU_ROM')
kids(['ru.paul1', 'ru.maria_f'], ['we.maria_pavlovna'])
S('we.charles_frederic', 'we.maria_pavlovna')
AUG = X('0128ac')                                    # Augusta (reine de Prusse), déjà placée
kids(['we.charles_frederic', 'we.maria_pavlovna'], [AUG])
W('we.charles_alexandre', 'Charles-Alexandre de Saxe-Weimar-Eisenach', 1818, 1901, 'Grand-duc de Saxe-Weimar-Eisenach', WEI, 'h')
kids(['we.charles_frederic', 'we.maria_pavlovna'], ['we.charles_alexandre'])
W('we.sophie_nl', 'Sophie des Pays-Bas', 1824, 1897, 'Grande-duchesse de Saxe-Weimar-Eisenach', "Orange-Nassau", 'f', 'NL_ORA',
  flag="Ses parents (Guillaume II et Anna Pavlovna) sont à ajouter avec l'arbre des Pays-Bas")
S('we.charles_alexandre', 'we.sophie_nl')
W('we.charles_auguste_h', 'Charles-Auguste, grand-duc héritier de Saxe-Weimar-Eisenach', 1844, 1894, 'Grand-duc héritier', WEI, 'h')
kids(['we.charles_alexandre', 'we.sophie_nl'], ['we.charles_auguste_h'])
W('we.pauline', 'Pauline de Saxe-Weimar-Eisenach', None, None, 'Grande-duchesse héritière', WEI, 'f', approx='dates non données par les pages consultées')
S('we.charles_auguste_h', 'we.pauline')
W('we.guillaume_ernest', 'Guillaume-Ernest de Saxe-Weimar-Eisenach', 1876, 1923, 'Dernier grand-duc de Saxe-Weimar-Eisenach (1901-1918)', WEI, 'h', leader=False)
kids(['we.charles_auguste_h', 'we.pauline'], ['we.guillaume_ernest'])
W('we.caroline_reuss', 'Caroline Reuss de Greiz', None, 1905, 'Grande-duchesse de Saxe-Weimar-Eisenach (1903-1905)', 'Reuss', 'f', flag='Maison Reuss : sans arbre',
  approx='naissance non donnée par la page de Guillaume-Ernest')
W('we.feodora', 'Féodora de Saxe-Meiningen', None, None, 'Grande-duchesse de Saxe-Weimar-Eisenach (1910-1918)', 'Wettin (Saxe-Meiningen)', 'f',
  approx='dates non données par la page de Guillaume-Ernest')
S('we.guillaume_ernest', 'we.caroline_reuss'); S('we.guillaume_ernest', 'we.feodora')

# ---------- Saxe-Hildburghausen / Altenbourg : parents de Thérèse et Louise ----------
ERN3 = 'we.ernest3_hild'
W(ERN3, 'Ernest-Frédéric III Charles de Saxe-Hildburghausen', None, None, 'Duc de Saxe-Hildburghausen', 'Wettin (Saxe-Hildburghausen)', 'h',
  approx='dates non données (page introuvable)')
W('we.ernestine_aug', 'Ernestine-Auguste-Sophie de Saxe-Weimar-Eisenach', 1740, 1786, 'Duchesse de Saxe-Hildburghausen', WEI, 'f')
kids(['we.ernest_auguste1', 'we.sophie_charlotte_bay'], ['we.ernestine_aug'])
S(ERN3, 'we.ernestine_aug')
W('we.frederic_alt', 'Frédéric de Saxe-Altenbourg', 1763, 1834, 'Duc de Saxe-Hildburghausen puis de Saxe-Altenbourg', ALT, 'h')
kids([ERN3, 'we.ernestine_aug'], ['we.frederic_alt'])
W('we.charlotte_meck', 'Charlotte-Georgine de Mecklembourg-Strelitz', None, 1818, 'Duchesse de Saxe-Altenbourg', 'Mecklembourg-Strelitz', 'f', flag='Maison de Mecklembourg-Strelitz : sans arbre',
  approx='naissance non donnée par la page de Frédéric')
S('we.frederic_alt', 'we.charlotte_meck')
THE, LOU = 'gr.therese', 'lu.louise'
kids(['we.frederic_alt', 'we.charlotte_meck'], [THE, LOU])
W('we.joseph_alt', 'Joseph de Saxe-Altenbourg', 1789, 1868, 'Duc de Saxe-Altenbourg (1834-1848)', ALT, 'h')
W('we.georges_alt', 'Georges de Saxe-Altenbourg', 1796, 1853, 'Duc de Saxe-Altenbourg (1848-1853)', ALT, 'h')
kids(['we.frederic_alt', 'we.charlotte_meck'], ['we.joseph_alt', 'we.georges_alt'])

# ---------- Saxe-Gotha-Altenbourg ----------
EP = X('b5dda5')                                     # Ernest Ier le Pieux
W('go.frederic1', 'Frédéric Ier de Saxe-Gotha-Altenbourg', 1646, 1691, 'Duc de Saxe-Gotha-Altenbourg (1675-1691)', GOT, 'h')
P(EP, 'go.frederic1'); P(X('edde5d'), 'go.frederic1')
W('go.magdalene_sw', 'Madeleine-Sibylle de Saxe-Weissenfels', None, 1681, 'Duchesse de Saxe-Gotha-Altenbourg', 'Wettin (Saxe-Weissenfels)', 'f',
  approx='naissance non donnée par la page de Frédéric Ier')
S('go.frederic1', 'go.magdalene_sw')
W('go.frederic2', 'Frédéric II de Saxe-Gotha-Altenbourg', 1676, 1732, 'Duc de Saxe-Gotha-Altenbourg (1691-1732)', GOT, 'h')
kids(['go.frederic1', 'go.magdalene_sw'], ['go.frederic2'])
W('go.magdalene_az', "Madeleine-Augusta d'Anhalt-Zerbst", None, None, 'Duchesse de Saxe-Gotha-Altenbourg', 'Anhalt', 'f', flag=FLAG_ANH,
  approx='dates non données par la page de Frédéric II')
S('go.frederic2', 'go.magdalene_az')
W('go.frederic3', 'Frédéric III de Saxe-Gotha-Altenbourg', 1699, 1772, 'Duc de Saxe-Gotha-Altenbourg (1732-1772)', GOT, 'h')
kids(['go.frederic2', 'go.magdalene_az'], ['go.frederic3', X('9b566a')])             # + Augusta, princesse de Galles (déjà placée)
W('go.luise_dorothea', 'Louise-Dorothée de Saxe-Meiningen', None, 1767, 'Duchesse de Saxe-Gotha-Altenbourg', 'Wettin (Saxe-Meiningen)', 'f',
  approx='naissance non donnée par la page de Frédéric III')
S('go.frederic3', 'go.luise_dorothea')
W('go.ernest2', 'Ernest II de Saxe-Gotha-Altenbourg', 1745, 1804, 'Duc de Saxe-Gotha-Altenbourg (1772-1804)', GOT, 'h')
kids(['go.frederic3', 'go.luise_dorothea'], ['go.ernest2'])
W('go.charlotte_mein', 'Charlotte de Saxe-Meiningen', None, None, 'Duchesse de Saxe-Gotha-Altenbourg', 'Wettin (Saxe-Meiningen)', 'f',
  approx='dates non données par la page d\'Ernest II')
S('go.ernest2', 'go.charlotte_mein')
W('go.auguste', 'Auguste de Saxe-Gotha-Altenbourg', 1772, 1822, 'Duc de Saxe-Gotha-Altenbourg (1804-1822)', GOT, 'h')
W('go.frederic4', 'Frédéric IV de Saxe-Gotha-Altenbourg', 1774, 1825, 'Duc de Saxe-Gotha-Altenbourg (1822-1825), dernier de sa lignée', GOT, 'h')
kids(['go.ernest2', 'go.charlotte_mein'], ['go.auguste', 'go.frederic4'])
W('go.louise_meck', 'Louise-Charlotte de Mecklembourg-Schwerin', None, 1801, 'Duchesse de Saxe-Gotha-Altenbourg', 'Mecklembourg-Schwerin', 'f', flag='Maison de Mecklembourg-Schwerin : sans arbre',
  approx='naissance non donnée par la page d\'Auguste')
S('go.auguste', 'go.louise_meck')
kids(['go.auguste', 'go.louise_meck'], [X('256882')])                                # Louise de Saxe-Gotha-Altenbourg (déjà placée)

# ---------- Saxe-Cobourg : liens de parenté non encore tracés ----------
kids([X('236384'), X('d0b49a')], [X('a1f6258c')])                                    # Léopold Ier de Belgique : fils de François et Augusta Reuss

# ---------- Rois de Saxe : descendants de Frédéric-Auguste III ----------
FA3, LA = X('a13641'), X('7215d7')
W('sa.georges_prince', 'Georges de Saxe (1893-1943)', 1893, 1943, 'Prince héritier de Saxe, jésuite', 'Wettin (Saxe)', 'h')
W('sa.frederic_christian', 'Frédéric-Christian, margrave de Misnie', 1893, 1968, 'Chef de la maison de Wettin (albertine)', 'Wettin (Saxe)', 'h')
W('sa.ernest_henri', 'Ernest-Henri de Saxe', 1896, 1971, 'Prince de Saxe', 'Wettin (Saxe)', 'h')
kids([FA3, LA], ['sa.georges_prince', 'sa.frederic_christian', 'sa.ernest_henri'])
W('sa.elisabeth_tt', 'Élisabeth-Hélène de Thurn et Taxis', 1903, 1976, 'Margravine de Misnie', 'Thurn et Taxis', 'f', flag='Maison de Thurn et Taxis : sans arbre')
S('sa.frederic_christian', 'sa.elisabeth_tt')
W('sa.sophie_lux', 'Sophie de Luxembourg', 1902, 1941, 'Princesse de Saxe, épouse d\'Ernest-Henri', 'Nassau-Weilburg', 'f', 'LU_NAS')
kids(['lu.wilhelm4', 'lu.marie_anne'], ['sa.sophie_lux'])
S('sa.ernest_henri', 'sa.sophie_lux')
# Marie-Josèphe de Saxe, mère de l'empereur Charles Ier d'Autriche
kids(['at.maria_josepha', 'at.otto_franz'], ['at.charles1'])

# ---------- Correction Wittelsbach : parents de Madeleine-Catherine de Deux-Ponts ----------
W('wi.jean2_zw', 'Jean II de Deux-Ponts', 1584, 1635, 'Comte palatin de Deux-Ponts', 'Wittelsbach (Deux-Ponts)', 'h', 'DE_WIT')
kids(['wi.john1_zw', 'wi.mag_jcb'], ['wi.jean2_zw'])
W('wi.catherine_rohan', 'Catherine de Rohan', None, 1607, 'Comtesse palatine de Deux-Ponts', 'Rohan', 'f', 'DE_WIT', flag='Maison de Rohan (France) : sans arbre',
  approx='naissance non donnée par la page de Jean II')
S('wi.jean2_zw', 'wi.catherine_rohan')
kids(['wi.jean2_zw', 'wi.catherine_rohan'], ['wi.mag_cath'])

if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
