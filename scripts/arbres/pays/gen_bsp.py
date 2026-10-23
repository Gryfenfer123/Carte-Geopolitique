import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(69, "Italie — Deux-Siciles et Parme : Ferdinand Ier et ses enfants, François Ier, Ferdinand II, François II ; Parme de Philippe à Élie")
g.notes = [
    "Complète les arbres Bourbon-Siciles et Bourbon-Parme (rien n'est supprimé).",
    "Sources : Wikipédia en anglais (Ferdinand Ier, François Ier, Ferdinand II, François II des Deux-Siciles ; Charles III d'Espagne ; Philippe, Ferdinand, Charles III, Robert Ier, Élie de Parme). Dates non données = vides.",
    "Marie-Sophie et Mathilde-Louise de Bavière sont créées dans l'arbre Wittelsbach (leurs parents y sont déjà) puis reliées à leurs maris.",
    "Louise d'Artois (Bourbon de France) est placée dans l'arbre Parme et signalée (son père, le duc de Berry, n'est pas encore en base).",
    "Marie-Antonia des Deux-Siciles (grande-duchesse de Toscane) : dates 1814-1898 complétées (étaient vides).",
]
g.tree('IT_BS', 'ITA', 'Maison de Bourbon-Siciles', entry=E('8c602f56'))
g.tree('IT_PAR', 'ITA', 'Maison de Bourbon-Parme', entry=E('84c9f117'))
g.tree('DE_WIT', 'DEU', 'Wittelsbach', entry=E('e76d91a3'))
g.tree('IT_SAV', 'ITA', 'Maison de Savoie')
P, S = g.par, g.sp
def kids(parents, children):
    for c in children:
        for p in parents:
            P(p, c)
B = 'IT_BS'
def M(code, name, b, d, title, g_, leader=False, approx=None, tree=B, dyn='Bourbon-Siciles', flag=None):
    return g.m(code, name, b, d, title, dyn, tree, g_, leader, approx=approx, flag=flag)

FI = R('8b9e281c')
kids([R('0cf75cb7'), R('0cd7f2c2')], [FI])
S(FI, R('4ec820bc'))
M('bs.francois1', 'François Ier des Deux-Siciles', 1777, 1830, 'Roi des Deux-Siciles', 'h', True)
M('bs.mchristine', 'Marie-Christine de Bourbon-Siciles (reine de Sardaigne)', 1779, 1849, 'Reine de Sardaigne', 'f')
M('bs.mamelie', 'Marie-Amélie de Bourbon-Siciles', 1782, 1866, 'Reine des Français', 'f')
M('bs.mantoinette', 'Marie-Antoinette de Bourbon-Siciles', 1784, 1806, 'Princesse des Asturies', 'f')
M('bs.leopold_sal', 'Léopold de Bourbon-Siciles, prince de Salerne', 1790, 1851, 'Prince de Salerne', 'h')
kids([FI, R('4ec820bc')], ['bs.francois1', 'bs.mchristine', 'bs.mamelie', 'bs.mantoinette', 'bs.leopold_sal', R('9dba805e'), R('05377808')])
S('bs.mchristine', 'sv.cf'); g.pin('sv.cf', B)
S('bs.mamelie', R('86246879')); g.pin(R('86246879'), B)
M('bs.clementine', 'Marie-Clémentine d\'Autriche', 1777, 1801, 'Reine des Deux-Siciles', 'f', dyn='Habsbourg-Lorraine', approx='archiduchesse, fille de Léopold II')
S('bs.francois1', 'bs.clementine')
M('bs.isabelle_esp', "Marie-Isabelle d'Espagne", 1789, 1848, 'Reine des Deux-Siciles', 'f', dyn='Bourbon d\'Espagne', flag="Bourbon d'Espagne : voir arbre Bourbons", approx='dates connues par ailleurs, non données par la page de François Ier')
S('bs.francois1', 'bs.isabelle_esp')
M('bs.mcaroline', 'Marie-Caroline de Bourbon-Siciles (duchesse de Berry)', 1798, 1870, 'Duchesse de Berry', 'f')
M('bs.luisa_carlotta', 'Louise-Charlotte de Bourbon-Siciles', 1804, 1844, 'Infante d\'Espagne', 'f')
M('bs.ferdinand2', 'Ferdinand II des Deux-Siciles', 1810, 1859, 'Roi des Deux-Siciles', 'h', True)
M('bs.carlo_capua', 'Charles de Bourbon-Siciles, prince de Capoue', 1811, 1862, 'Prince de Capoue', 'h')
M('bs.leopold_syr', 'Léopold de Bourbon-Siciles, comte de Syracuse', 1813, 1860, 'Comte de Syracuse', 'h')
M('bs.antonio', 'Antoine de Bourbon-Siciles, comte de Lecce', 1816, 1843, 'Comte de Lecce', 'h')
M('bs.mamalia', 'Marie-Amélie de Bourbon-Siciles (infante)', 1818, 1857, 'Infante d\'Espagne et du Portugal', 'f')
M('bs.mcarolina2', 'Marie-Caroline de Bourbon-Siciles (1820-1861)', 1820, 1861, 'Comtesse de Montemolín', 'f')
M('bs.teresa', 'Thérèse-Christine de Bourbon-Siciles', 1822, 1889, 'Impératrice du Brésil', 'f')
M('bs.aquila', "Louis de Bourbon-Siciles, comte d'Aquila", 1824, 1897, "Comte d'Aquila", 'h')
M('bs.trapani', 'François de Bourbon-Siciles, comte de Trapani', 1827, 1892, 'Comte de Trapani', 'h')
kids(['bs.francois1', 'bs.isabelle_esp'], ['bs.luisa_carlotta', R('c18e5e5e'), 'bs.ferdinand2', 'bs.carlo_capua', 'bs.leopold_syr', R('bc82232b'), 'bs.antonio', 'bs.mamalia', 'bs.mcarolina2', 'bs.teresa', 'bs.aquila', 'bs.trapani'])
kids(['bs.francois1', 'bs.clementine'], ['bs.mcaroline'])
_c = R('bc82232b')
(g.xsetdates if _c.startswith('x:') else g.setdates)(_c, 1814, 1898)
M('bs.louise_artois', "Louise d'Artois", 1819, 1864, 'Duchesse de Parme', 'f', dyn='Bourbon (France)', tree='IT_PAR', flag='Bourbon de France : père (duc de Berry) non encore en base', approx='dates connues par ailleurs, non données par la page de Charles III de Parme')
P('bs.mcaroline', 'bs.louise_artois')
M('bs.mcristina_savoie', 'Marie-Christine de Savoie (reine des Deux-Siciles)', 1812, 1836, 'Reine des Deux-Siciles', 'f', dyn='Maison de Savoie', tree='IT_SAV', approx='naissance connue par ailleurs, non donnée par la page de Ferdinand II')
kids(['sv.ve1', 'sv.maria_teresa_este'], ['bs.mcristina_savoie'])
M('bs.mtheresa_aut', "Marie-Thérèse d'Autriche-Teschen", 1816, 1867, 'Reine des Deux-Siciles', 'f', dyn='Habsbourg-Lorraine', approx='naissance connue par ailleurs')
S('bs.ferdinand2', 'bs.mcristina_savoie'); S('bs.ferdinand2', 'bs.mtheresa_aut')
M('bs.francois2', 'François II des Deux-Siciles', 1836, 1894, 'Dernier roi des Deux-Siciles', 'h', True)
kids(['bs.ferdinand2', 'bs.mcristina_savoie'], ['bs.francois2'])
M('bs.marie_sophie', 'Marie-Sophie de Bavière', 1841, 1925, 'Reine des Deux-Siciles', 'f', dyn='Wittelsbach', tree='DE_WIT')
kids([R('f4f8b4c2'), R('58271324')], ['bs.marie_sophie'])
S('bs.francois2', 'bs.marie_sophie')
M('bs.mat_louise', 'Mathilde-Louise de Bavière', 1843, 1925, 'Comtesse de Trani', 'f', dyn='Wittelsbach', tree='DE_WIT')
kids([R('f4f8b4c2'), R('58271324')], ['bs.mat_louise'])
M('bs.trani', 'Louis de Bourbon-Siciles, comte de Trani', 1838, 1886, 'Comte de Trani', 'h')
M('bs.caserte', 'Alphonse de Bourbon-Siciles, comte de Caserte', 1841, 1934, 'Comte de Caserte, chef de la maison', 'h')
M('bs.girgenti', 'Gaétan de Bourbon-Siciles, comte de Girgenti', 1846, 1871, 'Comte de Girgenti', 'h')
M('bs.pasquale', 'Pascal de Bourbon-Siciles, comte de Bari', 1852, 1904, 'Comte de Bari', 'h')
M('bs.mimmacolata', 'Marie-Immaculée de Bourbon-Siciles', 1844, 1899, 'Archiduchesse d\'Autriche', 'f')
M('bs.mpia', 'Marie-Pie de Bourbon-Siciles', 1849, 1882, 'Duchesse de Parme', 'f')
M('bs.mluisa', 'Marie-Louise de Bourbon-Siciles', 1855, 1874, 'Comtesse de Bardi', 'f')
kids(['bs.ferdinand2', 'bs.mtheresa_aut'], ['bs.trani', 'bs.caserte', R('cc7fdc37'), 'bs.mimmacolata', 'bs.girgenti', 'bs.mpia', 'bs.pasquale', 'bs.mluisa'])
S('bs.trani', 'bs.mat_louise')
S(R('cc7fdc37'), R('67be1780')); g.pin(R('67be1780'), B)
# --- Parme
T = 'IT_PAR'
PH = R('3757589a')
kids([R('0890d048'), R('2df9c2fd')], [PH]); g.pin(R('0890d048'), T); g.pin(R('2df9c2fd'), T)
S(PH, R('fa488603')); g.pin(R('fa488603'), T)
kids([PH, R('fa488603')], [R('281354f9'), R('9a0cd092'), R('a1d8a44a')]); g.pin(R('a1d8a44a'), T)
FE = R('9a0cd092')
S(FE, R('2cb1bbdb')); g.pin(R('2cb1bbdb'), T)
kids([FE, R('2cb1bbdb')], [R('be02f650')])
M('pa.louis_et', "Louis Ier d'Étrurie", 1773, 1803, "Roi d'Étrurie", 'h', True, dyn='Bourbon-Parme', tree=T)
kids([FE, R('2cb1bbdb')], ['pa.louis_et'])
M('pa.ml_esp', "Marie-Louise d'Espagne (reine d'Étrurie)", 1782, 1824, "Reine d'Étrurie, duchesse de Lucques", 'f', dyn="Bourbon d'Espagne", tree=T, flag="Bourbon d'Espagne : voir arbre Bourbons", approx='dates connues par ailleurs')
S('pa.louis_et', 'pa.ml_esp')
M('pa.charles2', 'Charles II de Parme', 1799, 1883, 'Duc de Lucques puis de Parme', 'h', True, dyn='Bourbon-Parme', tree=T, approx='dates connues par ailleurs, non données par la page de Charles III')
kids(['pa.louis_et', 'pa.ml_esp'], ['pa.charles2'])
M('pa.mt_savoie', 'Marie-Thérèse de Savoie (duchesse de Parme)', 1803, 1879, 'Duchesse de Parme', 'f', dyn='Maison de Savoie', tree='IT_SAV', approx='dates connues par ailleurs')
kids(['sv.ve1', 'sv.maria_teresa_este'], ['pa.mt_savoie'])
S('pa.charles2', 'pa.mt_savoie')
M('pa.charles3', 'Charles III de Parme', 1823, 1854, 'Duc de Parme', 'h', True, dyn='Bourbon-Parme', tree=T)
kids(['pa.charles2', 'pa.mt_savoie'], ['pa.charles3'])
S('pa.charles3', 'bs.louise_artois')
M('pa.marguerite', 'Marguerite de Bourbon-Parme', 1847, 1893, 'Duchesse de Madrid', 'f', dyn='Bourbon-Parme', tree=T)
M('pa.henri_bardi', 'Henri de Bourbon-Parme, comte de Bardi', 1851, 1905, 'Comte de Bardi', 'h', dyn='Bourbon-Parme', tree=T)
R1 = R('28ec5941')
kids(['pa.charles3', 'bs.louise_artois'], ['pa.marguerite', R1, R('e16532e2'), 'pa.henri_bardi'])
S(R1, 'bs.mpia'); S(R1, R('3b4a908a'))
S('pa.henri_bardi', 'bs.mimmacolata')
kids([R1, 'bs.mpia'], [R('c419e705')])
for code, nm, b, d, t in [('pa.henri', 'Henri de Bourbon-Parme, duc de Parme', 1873, 1939, 'Duc de Parme (titulaire)'),
                          ('pa.joseph', 'Joseph de Bourbon-Parme, duc de Parme', 1875, 1950, 'Duc de Parme (titulaire)'),
                          ('pa.elie', 'Élie de Bourbon-Parme', 1880, 1959, 'Duc de Parme (titulaire)'),
                          ('pa.sixte', 'Sixte de Bourbon-Parme', 1886, 1934, 'Prince de Bourbon-Parme'),
                          ('pa.xavier', 'Xavier de Bourbon-Parme', 1889, 1977, 'Duc de Parme (titulaire), prétendant carliste'),
                          ('pa.louis', 'Louis de Bourbon-Parme', 1899, 1967, 'Prince de Bourbon-Parme'),
                          ('pa.gaetan', 'Gaétan de Bourbon-Parme', 1905, 1958, 'Prince de Bourbon-Parme')]:
    M(code, nm, b, d, t, 'h', dyn='Bourbon-Parme', tree=T)
kids([R1, 'bs.mpia'], ['pa.henri', 'pa.joseph', 'pa.elie'])
kids([R1, R('3b4a908a')], ['pa.sixte', 'pa.xavier', R('e53ccc75'), R('f65f36f4'), R('4d570f58'), 'pa.louis', 'pa.gaetan'])
M('pa.marie_anne', "Marie-Anne d'Autriche (duchesse de Parme)", 1882, 1940, 'Duchesse de Parme', 'f', dyn='Habsbourg-Lorraine', tree=T, flag='Archiduchesse (Autriche-Teschen) : à relier à Habsbourg', approx=None)
S('pa.elie', 'pa.marie_anne')
M('pa.robert_hugues', 'Robert-Hugues de Bourbon-Parme', 1909, 1974, 'Duc de Parme (titulaire)', 'h', dyn='Bourbon-Parme', tree=T)
M('pa.alicia', 'Alice de Bourbon-Parme (1917-2017)', 1917, 2017, 'Duchesse de Calabre', 'f', dyn='Bourbon-Parme', tree=T)
kids(['pa.elie', 'pa.marie_anne'], ['pa.robert_hugues', 'pa.alicia'])
S('pa.louis', 'sv.mariafr'); g.pin('sv.mariafr', T)
g.reposition = {'IT_BS', 'IT_PAR'}
g.write()
