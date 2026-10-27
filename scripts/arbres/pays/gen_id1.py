import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(139, "Indonésie (sultans de Yogyakarta)")
g.notes = ["Nouvel arbre « Sultans de Yogyakarta » (Indonésie) : 10 personnes, de Hamengkubuwono I à X. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Toutes les données viennent de la page « Hamengkubuwono » (liste). Le père de Hamengkubuwono I (Amangkurat IV) n'est pas dans l'arbre. Hamengkubuwono VI : père non indiqué par la page, seulement « frère de Hamengkubuwono V » : lien « famille » (pas de lien parent). La page donne la fin du règne de HB VII en janvier 1921 mais sa mort en décembre 1921 : à vérifier.", 'Le sultan actuel est vivant.']
g.tree('ID_YOG', 'IDN', 'Sultans de Yogyakarta', section_title='Sultans de Yogyakarta')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('id.' + code, name, b, d, title, 'Sultans de Yogyakarta', 'ID_YOG', 'h', True, src=W + page + (' - ' + note if note else ''))
K('hb1', 'Hamengkubuwono I', 1717, 1792, 'Premier sultan de Yogyakarta (1755-1792)', 'Hamengkubuwono')
K('hb2', 'Hamengkubuwono II', 1750, 1828, 'Sultan de Yogyakarta (1792-1810 ; 1811-1812 ; 1826-1828)', 'Hamengkubuwono')
K('hb3', 'Hamengkubuwono III', 1769, 1814, 'Sultan de Yogyakarta (1810-1811 ; 1812-1814)', 'Hamengkubuwono')
K('hb4', 'Hamengkubuwono IV', 1804, 1823, 'Sultan de Yogyakarta (1814-1823)', 'Hamengkubuwono')
K('hb5', 'Hamengkubuwono V', 1820, 1855, 'Sultan de Yogyakarta (1823-1826 ; 1828-1855)', 'Hamengkubuwono')
K('hb6', 'Hamengkubuwono VI', 1821, 1877, 'Sultan de Yogyakarta (1855-1877)', 'Hamengkubuwono', 'père non indiqué : frère de Hamengkubuwono V')
K('hb7', 'Hamengkubuwono VII', 1839, 1921, 'Sultan de Yogyakarta (1877-1921)', 'Hamengkubuwono', 'fin de règne janvier 1921, mort décembre 1921 selon la page')
K('hb8', 'Hamengkubuwono VIII', 1880, 1939, 'Sultan de Yogyakarta (1921-1939)', 'Hamengkubuwono')
K('hb9', 'Hamengkubuwono IX', 1912, 1988, 'Sultan de Yogyakarta (1940-1988)', 'Hamengkubuwono')
K('hb10', 'Hamengkubuwono X', 1946, None, 'Sultan de Yogyakarta (depuis 1989)', 'Hamengkubuwono')
for a, b in [('hb1','hb2'),('hb2','hb3'),('hb3','hb4'),('hb4','hb5'),('hb6','hb7'),('hb7','hb8'),('hb8','hb9'),('hb9','hb10')]:
    g.par('id.' + a, 'id.' + b)
g.fam('id.hb5', 'id.hb6')
g.write()
