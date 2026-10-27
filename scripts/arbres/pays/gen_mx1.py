import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(146, 'Mexique (tlatoani de Tenochtitlan)')
g.notes = ["Nouvel arbre « Tlatoani de Tenochtitlan » (Mexique) : 7 souverains mexicas, d'Itzcoatl à Cuitlahuac. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", 'Toutes les données viennent de la page « Aztec Empire » : elle donne les règnes et des liens de parenté (oncle, neveu, frère) mais aucune date de naissance ou de mort ; seul le lien Moctezuma I → Axayacatl est « père-fils ». Les autres sont des liens « famille ». Acamapichtli, Huitzilihuitl, Chimalpopoca et Cuauhtémoc ne sont pas ajoutés : la page ne les relie pas aux autres.', 'Les dates de règne sont celles de la page.']
g.tree('MX_TEN', 'MEX', 'Tlatoani de Tenochtitlan', section_title='Tlatoani de Tenochtitlan')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('mx.' + code, name, b, d, title, 'Tlatoani de Tenochtitlan', 'MX_TEN', gnd, True, src=W + page + (' - ' + note if note else ''))
K('itz', 'Itzcoatl', None, None, 'Tlatoani de Tenochtitlan (1427-1440)', 'Aztec_Empire', 'oncle de Moctezuma I et de Tlacaelel', 'h')
K('moc1', 'Moctezuma I', None, None, 'Tlatoani de Tenochtitlan (1440-1468)', 'Aztec_Empire', "neveu d'Itzcoatl, père d'Axayacatl", 'h')
K('axa', 'Axayacatl', None, None, 'Tlatoani de Tenochtitlan (1469-1481)', 'Aztec_Empire', 'fils de Moctezuma I', 'h')
K('tizoc', 'Tizoc', None, None, 'Tlatoani de Tenochtitlan (1481-1486)', 'Aztec_Empire', "frère d'Axayacatl", 'h')
K('ahu', 'Ahuitzotl', None, None, 'Tlatoani de Tenochtitlan (1486-1502)', 'Aztec_Empire', 'frère de Tizoc, oncle de Moctezuma II', 'h')
K('moc2', 'Moctezuma II', None, None, 'Tlatoani de Tenochtitlan (1502-1520)', 'Aztec_Empire', "neveu d'Ahuitzotl", 'h')
K('cui', 'Cuitlahuac', None, None, 'Tlatoani de Tenochtitlan (1520)', 'Aztec_Empire', 'frère de Moctezuma II', 'h')
g.par('mx.moc1', 'mx.axa')
g.fam('mx.itz', 'mx.moc1')
g.fam('mx.axa', 'mx.tizoc')
g.fam('mx.tizoc', 'mx.ahu')
g.fam('mx.ahu', 'mx.moc2')
g.fam('mx.moc2', 'mx.cui')
g.write()
