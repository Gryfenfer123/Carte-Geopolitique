import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

def E(p):
    return [k for k in ENT if k.startswith(p)][0]

g = Gen(45, "Grèce — Wittelsbach (Othon) et Glücksbourg (Georges Ier → Constantin II)")
g.notes = [
    "Crée sous Grèce > Dynastie : Wittelsbach (Othon Ier et Amélie) et Glücksbourg (Georges Ier -> Constantin II), à partir des fiches Wikipédia.",
    "Pas de dynastie byzantine ici (cas douteux : Grèce/Turquie, décision de Martin à prendre).",
    "Épouses d'autres dynasties créées dans leur arbre : Thérèse de Saxe-Hildburghausen (Wettin), Olga Constantinovna et son père (Romanov), Sophie de Prusse (Hohenzollern), Frédérique de Hanovre (Welf), Anne-Marie de Danemark + Christian X, Frédéric IX et Ingrid (Glücksbourg danois, seulement les membres nécessaires).",
    "Hélène de Grèce (créée par v44 dans l'arbre roumain) est rattachée à Glücksbourg ; Sophie d'Espagne et Philip Mountbatten (déjà en base) sont reliés.",
    "Prérequis : v43 et v44 exécutés.",
]
g.tree('GR_WIT', 'GRC', 'Wittelsbach')
g.tree('GR_GLU', 'GRC', 'Glücksbourg')
g.tree('DE_WIT', 'DEU', 'Wittelsbach', entry='e76d91a3-1b9c-4703-85b3-9f711b6d6199')
g.tree('DE_WET', 'DEU', 'Wettin', entry='309f20ea-3b5d-453b-87f9-286b7f1e6c60')
g.tree('RU_ROM', 'RUS', 'Romanov')
g.tree('DE_HZ', 'DEU', 'Hohenzollern', entry='39895573-27f3-4112-905b-c9ba7e3c95a1')
g.tree('DE_WELF', 'DEU', 'Welf', entry='db5ef554-cbb9-448f-89fa-b656bf1d1147')
g.tree('DK_GLU', 'DNK', 'Glücksbourg', entry=E('78bf5e64'))
g.tree('RO_HOH', 'ROU', 'Hohenzollern-Sigmaringen')
P, S = g.par, g.sp
WI = 'Wittelsbach'
GL = 'Glücksbourg (Grèce)'

g.m('gr.otto', 'Othon Ier de Grèce', 1815, 1867, 'Premier roi de Grèce (1832-1862)', WI, 'GR_WIT', 'h', True)
g.m('gr.amalia', 'Amélie d\'Oldenbourg', 1818, 1875, 'Reine de Grèce', 'Oldenbourg (grand-duché)', 'GR_WIT', 'f', flag='Maison d\'Oldenbourg (grand-duché d\'Oldenbourg, Allemagne) : sans arbre propre')
g.m('gr.therese', 'Thérèse de Saxe-Hildburghausen', 1792, 1854, 'Reine de Bavière', 'Wettin (Saxe-Hildburghausen)', 'DE_WET', 'f')
S(X('e62118c0'), 'gr.therese')
P(X('e62118c0'), 'gr.otto'); P('gr.therese', 'gr.otto')
S('gr.otto', 'gr.amalia')

g.m('gr.george1', 'Georges Ier de Grèce', 1845, 1913, 'Roi des Hellènes (1863-1913)', GL, 'GR_GLU', 'h', True)
g.m('gr.olga', 'Olga Constantinovna de Russie', 1851, 1926, 'Reine des Hellènes', 'Romanov', 'RU_ROM', 'f')
g.m('gr.konstantin_n', 'Constantin Nikolaïevitch de Russie', 1827, 1892, 'Grand-duc, père d\'Olga', 'Romanov', 'RU_ROM', 'h')
P('ru.nicholas1', 'gr.konstantin_n'); P('ru.charlotte_p', 'gr.konstantin_n')
P('gr.konstantin_n', 'gr.olga')
P(X('fd479735'), 'gr.george1'); P(X('7d1a58e1'), 'gr.george1')
S('gr.george1', 'gr.olga')
g.m('gr.constantine1', 'Constantin Ier de Grèce', 1868, 1923, 'Roi des Hellènes (1913-1917, 1920-1922)', GL, 'GR_GLU', 'h', True)
g.m('gr.sophia', 'Sophie de Prusse', 1870, 1932, 'Reine des Hellènes', 'Hohenzollern', 'DE_HZ', 'f')
P(X('90ba7484'), 'gr.sophia'); P(X('1cf3b0d0'), 'gr.sophia')
for c in ('gr.constantine1', 'gr.andrew'):
    pass
g.m('gr.andrew', 'André de Grèce et de Danemark', 1882, 1944, 'Prince, père de Philip Mountbatten', GL, 'GR_GLU', 'h')
g.m('gr.alice', 'Alice de Battenberg', 1885, 1969, 'Princesse de Grèce et de Danemark', 'Battenberg', 'GR_GLU', 'f', flag='Maison de Battenberg (Mountbatten) : sans arbre propre ; parents non reliés')
for c in ('gr.constantine1', 'gr.andrew'):
    P('gr.george1', c); P('gr.olga', c)
S('gr.constantine1', 'gr.sophia')
g.m('gr.george2', 'Georges II de Grèce', 1890, 1947, 'Roi des Hellènes (1922-1924, 1935-1947)', GL, 'GR_GLU', 'h', True)
g.m('gr.alexander', 'Alexandre Ier de Grèce', 1893, 1920, 'Roi des Hellènes (1917-1920)', GL, 'GR_GLU', 'h', True)
g.m('gr.aspasia', 'Aspasia Manos', 1896, 1972, 'Épouse morganatique d\'Alexandre Ier', 'Manos (noblesse grecque)', 'GR_GLU', 'f', flag='Famille Manos (noblesse grecque) : sans arbre')
g.m('gr.paul', 'Paul Ier de Grèce', 1901, 1964, 'Roi des Hellènes (1947-1964)', GL, 'GR_GLU', 'h', True)
for c in ('gr.george2', 'gr.alexander', 'gr.paul', 'ro.helen'):
    P('gr.constantine1', c); P('gr.sophia', c)
S('gr.george2', 'ro.elisabeth_r')
S('gr.alexander', 'gr.aspasia')
S('gr.andrew', 'gr.alice')
P('gr.andrew', X('c01b6fc3')); P('gr.alice', X('c01b6fc3'))                # Philip Mountbatten
g.m('gr.frederica', 'Frédérique de Hanovre', 1917, 1981, 'Reine des Hellènes', 'Hanovre (Welf)', 'DE_WELF', 'f')
S('gr.paul', 'gr.frederica')
g.m('gr.constantine2', 'Constantin II de Grèce', 1940, 2023, 'Dernier roi des Hellènes (1964-1973)', GL, 'GR_GLU', 'h', True)
P('gr.paul', 'gr.constantine2'); P('gr.frederica', 'gr.constantine2')
P('gr.paul', X('3a00d791')); P('gr.frederica', X('3a00d791'))              # Sophie de Grèce, reine d'Espagne
g.m('dk.christian10', 'Christian X de Danemark', 1870, 1947, 'Roi de Danemark (1912-1947)', 'Glücksbourg', 'DK_GLU', 'h', True)
g.m('dk.frederik9', 'Frédéric IX de Danemark', 1899, 1972, 'Roi de Danemark (1947-1972)', 'Glücksbourg', 'DK_GLU', 'h', True)
g.m('dk.ingrid', 'Ingrid de Suède', 1910, 2000, 'Reine de Danemark', 'Bernadotte (Suède)', 'DK_GLU', 'f', flag='Maison Bernadotte (Suède) : arbre à créer avec la Suède')
g.m('dk.annemarie', 'Anne-Marie de Danemark', 1946, None, 'Reine des Hellènes', 'Glücksbourg', 'DK_GLU', 'f')
P(X('8b34e776'), 'dk.christian10'); P('dk.christian10', 'dk.frederik9')
S('dk.frederik9', 'dk.ingrid')
P('dk.frederik9', 'dk.annemarie'); P('dk.ingrid', 'dk.annemarie')
S('gr.constantine2', 'dk.annemarie')
g.move('ro.helen', 'GR_GLU', GL)
if __name__ == '__main__':
    print(g.write()); print(len(g.M), len(g.R))
