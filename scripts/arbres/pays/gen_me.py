import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(48, "Monténégro — Petrović-Njegoš")
g.notes = [
    "Crée sous Monténégro > Dynastie : Petrović-Njegoš (Mirko/Stanko -> Danilo Ier -> Nicolas Ier -> Danilo III, Mirko, Pierre ; prétendant Nicolas né en 1944).",
    "Non inclus : les princes-évêques (Pierre Ier, Pierre II) car ils étaient célibataires et la succession passait d'oncle à neveu — filiation avec Danilo Ier non vérifiée sur la source.",
    "Zorka (Ljubica) du Monténégro est déplacée de l'arbre Karađorđević (v47) vers cet arbre.",
    "Créés dans leur arbre d'origine : Nicolas Nikolaïevitch l'Ancien, Nicolas le Jeune, Pierre Nikolaïevitch, Alexandra d'Oldenbourg (Romanov). Victor-Emmanuel III, Georges de Leuchtenberg, François-Joseph de Battenberg et Jutta de Mecklembourg-Strelitz restent dans l'arbre monténégrin, signalés (pas d'arbre).",
    "Victor-Emmanuel III est relié à Jeanne de Savoie (arbre de Bulgarie).",
    "Prérequis : v47 exécuté.",
]
g.tree('ME_PET', 'MNE', 'Petrović-Njegoš')
g.tree('RU_ROM', 'RUS', 'Romanov')
g.tree('SR_KAR', 'SRB', 'Karađorđević')
g.reposition = {'RU_ROM'}
FB = {'me.stanko': 1790, 'me.krstinja': 1795, 'me.milena': 1847, 'me.natalija': 1882, 'me.violet': 1890, 'me.jutta': 1880,
      'me.georg_l': 1872, 'me.franz_b': 1861, 'ru.alexandra_o': 1838, 'me.vitt': 1869}
Gen.FIXB = {uid('member:' + c): y for c, y in FB.items()}
P, S = g.par, g.sp
PN = 'Petrović-Njegoš'
g.m('me.stanko', 'Stanko Petrović-Njegoš', None, None, 'Père de Mirko et de Danilo Ier', PN, 'ME_PET', 'h', approx='dates non renseignées')
g.m('me.krstinja', 'Krstinja Vrbica', None, None, 'Mère de Mirko et de Danilo Ier', 'Vrbica (Monténégro)', 'ME_PET', 'f', flag='Famille Vrbica : sans arbre ; dates non renseignées', approx='dates non renseignées')
S('me.stanko', 'me.krstinja')
g.m('me.mirko_g', 'Mirko Petrović-Njegoš (grand voïvode)', 1820, 1867, 'Grand voïvode de Grahovo', PN, 'ME_PET', 'h', approx='dates 1820-1867 (non revérifiées sur la page)')
g.m('me.anastasija', 'Anastasija Martinović', 1824, 1895, 'Mère de Nicolas Ier', 'Martinović (Monténégro)', 'ME_PET', 'f', flag='Famille Martinović : sans arbre')
for c in ('me.mirko_g',):
    P('me.stanko', c); P('me.krstinja', c)
S('me.mirko_g', 'me.anastasija')
g.m('me.danilo1', 'Danilo Ier du Monténégro', 1826, 1860, 'Prince du Monténégro (1851-1860), premier prince laïc', PN, 'ME_PET', 'h', True)
P('me.stanko', 'me.danilo1'); P('me.krstinja', 'me.danilo1')
g.m('me.darinka', 'Darinka Kvekić', 1838, 1892, 'Princesse du Monténégro', 'Kvekić (Trieste)', 'ME_PET', 'f', flag='Famille Kvekić (négociants serbes de Trieste) : sans arbre', approx='dates 1838-1892 (non revérifiées)')
S('me.danilo1', 'me.darinka')
g.m('me.olga', 'Olga du Monténégro', 1859, 1896, 'Princesse, fille de Danilo Ier', PN, 'ME_PET', 'f')
P('me.danilo1', 'me.olga'); P('me.darinka', 'me.olga')
g.m('me.nikola', 'Nicolas Ier du Monténégro', 1841, 1921, 'Prince (1860) puis roi du Monténégro (1910-1918)', PN, 'ME_PET', 'h', True)
P('me.mirko_g', 'me.nikola'); P('me.anastasija', 'me.nikola')
g.m('me.milena', 'Milena Vukotić', 1847, 1923, 'Princesse puis reine du Monténégro', 'Vukotić (Monténégro)', 'ME_PET', 'f', flag='Famille Vukotić : sans arbre', approx='dates 1847-1923 (non revérifiées ; la page ne les donne pas)')
S('me.nikola', 'me.milena')
g.move('sr.zorka', 'ME_PET', PN)
g.setdates('sr.zorka', 1864, 1890)
kids = [('me.milica', 'Milica du Monténégro', 1866, 1951, 'Grande-duchesse de Russie', 'f'),
        ('me.anastasia', 'Anastasia du Monténégro', 1868, 1935, 'Duchesse de Leuchtenberg puis grande-duchesse de Russie', 'f'),
        ('me.marija', 'Marija du Monténégro', 1869, 1885, 'Princesse', 'f'),
        ('me.danilo3', 'Danilo III du Monténégro', 1871, 1939, 'Prince héritier, roi titulaire (1921)', 'h'),
        ('me.elena', 'Hélène du Monténégro', 1873, 1952, 'Reine d\'Italie', 'f'),
        ('me.anna', 'Anne du Monténégro', 1874, 1971, 'Princesse de Battenberg', 'f'),
        ('me.mirko', 'Mirko du Monténégro', 1879, 1918, 'Prince', 'h'),
        ('me.xenia', 'Xénia du Monténégro', 1881, 1960, 'Princesse', 'f'),
        ('me.vjera', 'Vjera du Monténégro', 1887, 1927, 'Princesse', 'f'),
        ('me.petar', 'Pierre du Monténégro', 1889, 1932, 'Prince', 'h')]
for c, n, b, d, t, s in kids:
    g.m(c, n, b, d, t, PN, 'ME_PET', s)
for c in ['sr.zorka'] + [k[0] for k in kids]:
    P('me.nikola', c); P('me.milena', c)
# Russie : Nicolas Nikolaïevitch l'Ancien et ses fils
g.m('ru.nikolai_e', 'Nicolas Nikolaïevitch de Russie (l\'Ancien)', 1831, 1891, 'Grand-duc, feld-maréchal', 'Romanov', 'RU_ROM', 'h')
g.m('ru.alexandra_o', 'Alexandra d\'Oldenbourg', 1838, 1900, 'Grande-duchesse de Russie', 'Oldenbourg', 'RU_ROM', 'f', flag='Maison d\'Oldenbourg (Allemagne) : sans arbre', approx='dates 1838-1900 (non revérifiées)')
g.m('ru.nikolai_y', 'Nicolas Nikolaïevitch de Russie (le Jeune)', 1856, 1929, 'Grand-duc, généralissime (1914-1915)', 'Romanov', 'RU_ROM', 'h', approx='dates 1856-1929 (non revérifiées)')
g.m('ru.peter_n', 'Pierre Nikolaïevitch de Russie', 1864, 1931, 'Grand-duc', 'Romanov', 'RU_ROM', 'h', approx='dates 1864-1931 (non revérifiées)')
P('ru.nicholas1', 'ru.nikolai_e')
S('ru.nikolai_e', 'ru.alexandra_o')
for c in ('ru.nikolai_y', 'ru.peter_n'):
    P('ru.nikolai_e', c); P('ru.alexandra_o', c)
S('ru.peter_n', 'me.milica')
S('ru.nikolai_y', 'me.anastasia')
g.m('me.georg_l', 'Georges de Leuchtenberg', 1872, 1929, 'Duc de Leuchtenberg', 'Leuchtenberg (Beauharnais)', 'ME_PET', 'h', flag='Maison de Leuchtenberg (Beauharnais) : sans arbre', approx='dates 1872-1929 (non revérifiées)')
S('me.georg_l', 'me.anastasia')
# autres mariages
g.m('me.jutta', 'Jutta de Mecklembourg-Strelitz', 1880, 1946, 'Princesse héritière du Monténégro', 'Mecklembourg-Strelitz', 'ME_PET', 'f', flag='Maison de Mecklembourg-Strelitz (Allemagne) : sans arbre', approx='dates 1880-1946 (non revérifiées ; la page ne les donne pas)')
S('me.danilo3', 'me.jutta')
g.m('me.vitt', 'Victor-Emmanuel III d\'Italie', 1869, 1947, 'Roi d\'Italie (1900-1946)', 'Savoie', 'ME_PET', 'h', flag='Maison de Savoie (Italie) : arbre à créer avec l\'Italie')
S('me.vitt', 'me.elena')
P('me.vitt', 'bg.giovanna'); P('me.elena', 'bg.giovanna')
g.m('me.franz_b', 'François-Joseph de Battenberg', 1861, 1924, 'Prince de Battenberg', 'Battenberg', 'ME_PET', 'h', flag='Maison de Battenberg : sans arbre', approx='dates 1861-1924 (non revérifiées)')
S('me.franz_b', 'me.anna')
g.m('me.natalija', 'Natalija Konstantinović', None, None, 'Princesse du Monténégro', 'Konstantinović (Serbie)', 'ME_PET', 'f', flag='Famille Konstantinović : sans arbre ; dates non renseignées', approx='dates non renseignées')
S('me.mirko', 'me.natalija')
g.m('me.violet', 'Violet Emily Wegner', None, None, 'Princesse du Monténégro', 'Wegner (Royaume-Uni)', 'ME_PET', 'f', flag='Famille Wegner : sans arbre ; dates non renseignées', approx='dates non renseignées')
S('me.petar', 'me.violet')
g.m('me.michael', 'Michel du Monténégro', 1908, 1986, 'Prince, fils de Mirko', PN, 'ME_PET', 'h', approx='dates 1908-1986 (non revérifiées)')
for p in ('me.mirko', 'me.natalija'):
    P(p, 'me.michael')
g.m('me.nikola2', 'Nicolas du Monténégro (né en 1944)', 1944, None, 'Prétendant au trône du Monténégro', PN, 'ME_PET', 'h', approx='naissance 1944 (non revérifiée)')
P('me.michael', 'me.nikola2')
REG['flags'] = [f for f in REG['flags'] if f['name'] not in ('Dragana Lazarević', 'Jelena Branković', 'Zorka du Monténégro')]
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
