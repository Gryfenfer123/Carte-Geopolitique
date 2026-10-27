import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(132, "Cambodge (Norodom / Sisowath)")
g.notes = ["Nouvel arbre « Norodom / Sisowath » (Cambodge) : 8 personnes de Ang Duong à Sihamoni. Chaque fiche porte l'adresse de la page Wikipédia (anglais) « List of heads of state of Cambodia » dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Ang Duong : père de Norodom d'après la liste, sans dates (page non lue). Sisowath est le frère de Norodom (lien « famille »). Sihanouk est le fils de Suramarit et de Kossamak (fille de Monivong) ; la mère de Sihamoni n'est pas saisie.", 'Sihamoni : né en 1953, vivant. Dates en année chrétienne.']
g.tree('KH_NOR', 'KHM', 'Norodom / Sisowath', section_title='Norodom / Sisowath')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('kh.' + code, name, b, d, title, 'Norodom / Sisowath', 'KH_NOR', 'h', True, src=W + page + (' - ' + note if note else ''))
K('angduong', 'Ang Duong', None, None, 'Roi du Cambodge, père de Norodom', 'List_of_heads_of_state_of_Cambodia')
K('norodom', 'Norodom', 1834, 1904, 'Roi du Cambodge (1860-1904)', 'List_of_heads_of_state_of_Cambodia')
K('sisowath', 'Sisowath', 1840, 1927, 'Roi du Cambodge (1904-1927)', 'List_of_heads_of_state_of_Cambodia')
K('monivong', 'Sisowath Monivong', 1875, 1941, 'Roi du Cambodge (1927-1941)', 'List_of_heads_of_state_of_Cambodia')
K('suramarit', 'Norodom Suramarit', 1896, 1960, 'Roi du Cambodge (1955-1960)', 'List_of_heads_of_state_of_Cambodia')
K('kossamak', 'Sisowath Kossamak', 1904, 1975, 'Reine, mère de Norodom Sihanouk', 'List_of_heads_of_state_of_Cambodia', 'monarque honorifique 1960-1970')
K('sihanouk', 'Norodom Sihanouk', 1922, 2012, "Roi (1941-1955 ; 1993-2004), chef de l'État", 'List_of_heads_of_state_of_Cambodia')
K('sihamoni', 'Norodom Sihamoni', 1953, None, 'Roi du Cambodge (depuis 2004)', 'List_of_heads_of_state_of_Cambodia')
for a, b in [('angduong', 'norodom'), ('sisowath', 'monivong'), ('monivong', 'kossamak'), ('suramarit', 'sihanouk'), ('kossamak', 'sihanouk'), ('sihanouk', 'sihamoni')]:
    g.par('kh.' + a, 'kh.' + b)
g.fam('kh.norodom', 'kh.sisowath')
g.sp('kh.suramarit', 'kh.kossamak')
g.write()
