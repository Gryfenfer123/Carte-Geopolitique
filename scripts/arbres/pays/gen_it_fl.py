import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(164, 'Italie (Flaviens)')
g.notes = ["Nouvel arbre « Flaviens » (Rome antique, rattaché à l'Italie). Source : page « Flavian dynasty » (anglais).", "Domitille l'Aînée est citée sans lien de parenté sur la page : non ajoutée. Julia Flavia : « peut-être » fille de Titus selon la page → lien « famille »."]
g.tree('IT_FLA', 'ITA', 'Flaviens', section_title='Flaviens')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('fl.' + code, name, b, d, title, 'Flaviens', 'IT_FLA', gnd, True, src=W + page + (' - ' + note if note else ''))
K('pet', 'Titus Flavius Petro', None, None, 'Père de Titus Flavius Sabinus Ier', 'Flavian_dynasty', None, 'h')
K('sa1', 'Titus Flavius Sabinus Ier', None, None, 'Père de Vespasien et de Sabinus II', 'Flavian_dynasty', None, 'h')
K('sa2', 'Titus Flavius Sabinus II', None, 69, 'Exécuté le 19 décembre 69', 'Flavian_dynasty', None, 'h')
K('ves', 'Vespasien', None, 79, 'Empereur romain (69-79)', 'Flavian_dynasty', 'mort le 23 juin 79', 'h')
K('tit', 'Titus', 39, 81, 'Empereur romain (79-81)', 'Flavian_dynasty', 'mort le 13 septembre 81', 'h')
K('dom', 'Domitien', 51, 96, 'Empereur romain (81-96)', 'Flavian_dynasty', 'mort le 18 septembre 96', 'h')
K('dmy', 'Domitille la Jeune', 45, None, 'Fille de Vespasien', 'Flavian_dynasty', None, 'f')
K('juf', 'Julia Flavia', None, None, 'Fille de Titus (peut-être)', 'Flavian_dynasty', 'filiation incertaine selon la page', 'f')
g.par('fl.pet', 'fl.sa1')
g.par('fl.sa1', 'fl.sa2')
g.par('fl.sa1', 'fl.ves')
g.par('fl.ves', 'fl.tit')
g.par('fl.ves', 'fl.dom')
g.par('fl.ves', 'fl.dmy')
g.fam('fl.tit', 'fl.juf')
g.write()
