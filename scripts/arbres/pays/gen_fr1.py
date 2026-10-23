import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(77, "France — Bourbons : enfants d'Henri IV, de Louis XIV, de Louis XV, du Dauphin, de Louis XVI, de Charles X et de Louis-Philippe ; Orléans de la Régence à Louis-Philippe")
g.notes = [
    "Complète l'arbre « de Bourbon et Bourbon-Orléans » (rien n'est supprimé).",
    "Sources : Wikipédia en anglais (Henri IV, Louis XIV, Louis XV, Louis XVI) pour les filiations ; dates de naissance/mort des princes : connues par ailleurs (histoire de France) car les pages ne les donnent pas toutes. Dates incertaines = vides.",
    "Marguerite de Valois est créée dans l'arbre Valois ; les princesses de Savoie (Marie-Joséphine, Marie-Thérèse) dans l'arbre Savoie. Mmes de Montespan, de La Vallière, de Maintenon, Marie de Montpensier, Hélène de Mecklembourg : maisons sans arbre, signalées.",
    "Non fait : les enfants naturels d'Henri IV, les Condé/Conti, les enfants de Philippe V et Louis-Philippe au-delà des petits-fils (comte de Paris).",
]
g.tree('FR_BOU', 'FRA', 'de Bourbon et Bourbon-Orléans', entry=E('786a379d'))
g.tree('FR_VAL', 'FRA', 'Valois', entry=E('a92b4627'))
g.tree('IT_SAV', 'ITA', 'Maison de Savoie')
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
T = 'FR_BOU'
def M(code, name, b, d, title, g_, tree=T, leader=False, approx=None, dyn='Bourbon', flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)
def W(code, name, b, d, title, house, approx=None):
    return M(code, name, b, d, title, 'f', T, dyn=house, approx=approx, flag='Maison %s : sans arbre' % house)

HIV, MED, LXIII, LXIV, PH, ELC = R('14b4e7b7'), R('2b61583b'), R('38901a91'), R('95edb437'), R('e3e60e7d'), R('8ab9ac1e')
# Henri IV
M('fr.marguerite_v', 'Marguerite de Valois (reine Margot)', 1553, 1615, 'Reine de France et de Navarre', 'f', 'FR_VAL', dyn='Valois')
kids([R('aa7a9081'), R('401b55d7')], ['fr.marguerite_v'])
S(HIV, 'fr.marguerite_v')
M('fr.elisabeth_f', 'Élisabeth de France', 1602, 1644, "Reine d'Espagne", 'f')
M('fr.christine_f', 'Christine de France', 1606, 1663, 'Duchesse de Savoie, régente', 'f')
M('fr.gaston', "Gaston d'Orléans", 1608, 1660, 'Duc d\'Orléans, frère de Louis XIII', 'h')
kids([HIV, MED], ['fr.elisabeth_f', 'fr.christine_f', 'fr.gaston'])
S('fr.elisabeth_f', R('d1bc8e7a')); S('fr.christine_f', R('074bdb6b'))
W('fr.marie_mpensier', 'Marie de Bourbon-Montpensier', 1605, 1627, "Duchesse d'Orléans", 'Montpensier')
S('fr.gaston', 'fr.marie_mpensier')
M('fr.grande_mlle', "Anne-Marie-Louise d'Orléans (la Grande Mademoiselle)", 1627, 1693, 'Duchesse de Montpensier', 'f')
kids(['fr.gaston', 'fr.marie_mpensier'], ['fr.grande_mlle'])

# Louis XIV : enfants légitimés
W('fr.montespan', 'Françoise-Athénaïs de Rochechouart (Mme de Montespan)', 1640, 1707, 'Maîtresse de Louis XIV', 'Rochechouart-Mortemart')
W('fr.lavalliere', 'Louise de La Vallière', 1644, 1710, 'Maîtresse de Louis XIV', 'La Baume Le Blanc')
W('fr.maintenon', "Françoise d'Aubigné (Mme de Maintenon)", 1635, 1719, 'Seconde épouse secrète de Louis XIV (1683)', "Aubigné")
S(LXIV, 'fr.maintenon')
M('fr.maine', 'Louis-Auguste de Bourbon, duc du Maine', 1670, 1736, 'Fils légitimé de Louis XIV', 'h')
M('fr.toulouse', 'Louis-Alexandre de Bourbon, comte de Toulouse', 1678, 1737, 'Fils légitimé de Louis XIV', 'h')
M('fr.lf_condé', 'Louise-Françoise de Bourbon (Mlle de Nantes)', 1673, 1743, 'Fille légitimée de Louis XIV, princesse de Condé', 'f')
M('fr.fm_orl', 'Françoise-Marie de Bourbon (Mlle de Blois)', 1677, 1749, "Fille légitimée de Louis XIV, duchesse d'Orléans", 'f')
M('fr.ma_conti', 'Marie-Anne de Bourbon (Mlle de Blois)', 1666, 1739, 'Fille légitimée de Louis XIV, princesse de Conti', 'f')
kids([LXIV, 'fr.montespan'], ['fr.maine', 'fr.toulouse', 'fr.lf_condé', 'fr.fm_orl'])
kids([LXIV, 'fr.lavalliere'], ['fr.ma_conti'])
# Régence et Orléans
M('fr.philippe2', "Philippe II, duc d'Orléans (le Régent)", 1674, 1723, 'Régent de France', 'h', leader=True, dyn='Orléans')
kids([PH, ELC], ['fr.philippe2'])
S('fr.philippe2', 'fr.fm_orl')
M('fr.louis_orl', "Louis d'Orléans (le Pieux)", 1703, 1752, "Duc d'Orléans", 'h', dyn='Orléans')
kids(['fr.philippe2', 'fr.fm_orl'], ['fr.louis_orl'])
M('fr.louis_philippe1', "Louis-Philippe Ier d'Orléans (le Gros)", 1725, 1785, "Duc d'Orléans", 'h', dyn='Orléans')
W('fr.auguste_bade', 'Auguste de Bade-Bade', 1704, 1726, "Duchesse d'Orléans", 'Bade-Bade')
S('fr.louis_orl', 'fr.auguste_bade')
kids(['fr.louis_orl', 'fr.auguste_bade'], ['fr.louis_philippe1'])
W('fr.lh_conti', 'Louise-Henriette de Bourbon-Conti', 1726, 1759, "Duchesse d'Orléans", 'Bourbon-Conti')
S('fr.louis_philippe1', 'fr.lh_conti')
kids(['fr.louis_philippe1', 'fr.lh_conti'], [R('83e63185')])
# Grand Dauphin et descendance
GD, BG = R('0f4548b6'), R('b1288c42')
P(GD, R('0890d048'))
M('fr.berry1', 'Charles, duc de Berry', 1686, 1714, 'Fils du Grand Dauphin', 'h')
P(GD, 'fr.berry1')
M('fr.bretagne', 'Louis, duc de Bretagne', 1707, 1712, 'Dauphin, frère aîné de Louis XV', 'h')
P(BG, 'fr.bretagne')
# Louis XV
LXV, ML = R('3a3c29b4'), R('05d39234')
P(BG, LXV)
DAU = R('7827da90')
for c, n, b, d, gg, t in [('henriette', 'Henriette de France', 1727, 1752, 'f', 'Fille de Louis XV'),
                          ('mlouise', 'Marie-Louise de France', 1728, 1733, 'f', 'Fille de Louis XV'),
                          ('philippe_a', "Philippe, duc d'Anjou", 1730, 1733, 'h', 'Fils de Louis XV'),
                          ('adelaide', 'Adélaïde de France', 1732, 1800, 'f', 'Fille de Louis XV (Mesdames)'),
                          ('victoire', 'Victoire de France', 1733, 1799, 'f', 'Fille de Louis XV (Mesdames)'),
                          ('sophie', 'Sophie de France', 1734, 1782, 'f', 'Fille de Louis XV (Mesdames)'),
                          ('therese', 'Thérèse de France', 1736, 1744, 'f', 'Fille de Louis XV'),
                          ('louise_f', 'Louise de France (carmélite)', 1737, 1787, 'f', 'Fille de Louis XV, carmélite')]:
    M('fr.' + c, n, b, d, t, gg)
    kids([LXV, ML], ['fr.' + c])
kids([LXV, ML], [R('fa488603')])
# Dauphin et ses enfants
MJS = R('a9d7aa31')
for c, n, b, d, gg, t in [('zephyrine', 'Marie-Zéphyrine de France', 1750, 1755, 'f', 'Fille du Dauphin'),
                          ('bourgogne', 'Louis, duc de Bourgogne', 1751, 1761, 'h', 'Fils du Dauphin'),
                          ('xavier', "Xavier, duc d'Aquitaine", 1753, 1754, 'h', 'Fils du Dauphin'),
                          ('clotilde', 'Clotilde de France', 1759, 1802, 'f', 'Reine de Sardaigne'),
                          ('elisabeth_m', 'Élisabeth de France (Madame Élisabeth)', 1764, 1794, 'f', 'Sœur de Louis XVI')]:
    M('fr.' + c, n, b, d, t, gg)
    kids([DAU, MJS], ['fr.' + c])
S('fr.clotilde', R('c4222ad8'))
# Louis XVI
LXVI, MA = R('b2c7c0b2'), R('53e820ef')
P(MA, R('2d133797'))
for c, n, b, d, gg, t in [('mtc', 'Marie-Thérèse-Charlotte de France (Madame Royale)', 1778, 1851, 'f', 'Fille de Louis XVI, duchesse d\'Angoulême'),
                          ('lj', 'Louis-Joseph, dauphin de France', 1781, 1789, 'h', 'Fils de Louis XVI'),
                          ('sophie_b', 'Sophie-Hélène-Béatrice de France', 1786, 1787, 'f', 'Fille de Louis XVI')]:
    M('fr.' + c, n, b, d, t, gg)
    kids([LXVI, MA], ['fr.' + c])
# Louis XVIII, Charles X
LXVIII, CX = R('57100256'), R('05099a12')
M('sv.mj_savoie', 'Marie-Joséphine de Savoie', 1753, 1810, 'Comtesse de Provence', 'f', 'IT_SAV', dyn='Savoie')
M('sv.mt_savoie', 'Marie-Thérèse de Savoie', 1756, 1805, "Comtesse d'Artois", 'f', 'IT_SAV', dyn='Savoie')
kids([R('10c905d8'), R('865cb59f')], ['sv.mj_savoie', 'sv.mt_savoie'])
S(LXVIII, 'sv.mj_savoie'); S(CX, 'sv.mt_savoie')
M('fr.angouleme', "Louis-Antoine, duc d'Angoulême", 1775, 1844, 'Dauphin (« Louis XIX »), fils de Charles X', 'h')
M('fr.berry2', 'Charles-Ferdinand, duc de Berry', 1778, 1820, 'Fils de Charles X', 'h')
kids([CX, 'sv.mt_savoie'], ['fr.angouleme', 'fr.berry2'])
S('fr.angouleme', 'fr.mtc')
S('fr.berry2', R('51aa896d'))
LB = R('c732d411')
M('fr.chambord', "Henri d'Artois, comte de Chambord", 1820, 1883, 'Prétendant légitimiste (« Henri V »)', 'h')
kids(['fr.berry2', R('51aa896d')], [LB, 'fr.chambord'])
# Louis-Philippe
LP, MAM = R('86246879'), R('49e31bcc')
kids([LP, MAM], [R('54141293'), R('e277dca4')])
M('fr.fp', "Ferdinand-Philippe, duc d'Orléans", 1810, 1842, 'Prince royal, fils aîné de Louis-Philippe', 'h', dyn='Orléans')
M('fr.marie_o', "Marie d'Orléans", 1813, 1839, 'Fille de Louis-Philippe', 'f', dyn='Orléans')
M('fr.nemours', "Louis, duc de Nemours", 1814, 1896, 'Fils de Louis-Philippe', 'h', dyn='Orléans')
M('fr.joinville', "François, prince de Joinville", 1818, 1900, 'Amiral, fils de Louis-Philippe', 'h', dyn='Orléans')
M('fr.aumale', "Henri, duc d'Aumale", 1822, 1897, 'Fils de Louis-Philippe', 'h', dyn='Orléans')
M('fr.montpensier', "Antoine, duc de Montpensier", 1824, 1890, 'Fils de Louis-Philippe', 'h', dyn='Orléans')
kids([LP, MAM], ['fr.fp', 'fr.marie_o', 'fr.nemours', 'fr.joinville', 'fr.aumale', 'fr.montpensier'])
W('fr.helene_m', 'Hélène de Mecklembourg-Schwerin', 1814, 1858, "Duchesse d'Orléans", 'Mecklembourg-Schwerin')
S('fr.fp', 'fr.helene_m')
M('fr.comte_paris', 'Philippe, comte de Paris', 1838, 1894, "Prétendant orléaniste (« Philippe VII »)", 'h', dyn='Orléans')
M('fr.chartres', 'Robert, duc de Chartres', 1840, 1910, 'Petit-fils de Louis-Philippe', 'h', dyn='Orléans')
kids(['fr.fp', 'fr.helene_m'], ['fr.comte_paris', 'fr.chartres'])

g.reposition = {'FR_BOU'}
g.write()
