import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(145, 'Ghana (Asante)')
g.notes = ["Nouvel arbre « Asantehene » (Ghana) : 3 personnes seulement. Chaque fiche porte l'adresse de la page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "La page « List of rulers of Asante » ne donne ni dates de naissance/mort ni parents, sauf deux liens de parenté : Opoku Ware I est « petit-neveu et successeur désigné » de son prédécesseur (Osei Tutu I) et Kusi Oboadum est l'« oncle » de son prédécesseur (Opoku Ware I). Les autres Asantehene ne sont pas ajoutés (aucun lien sourcé). À compléter avec une meilleure source."]
g.tree('GH_ASA', 'GHA', 'Asantehene', section_title='Asantehene')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd='h'):
    return g.m('gh.' + code, name, b, d, title, 'Asantehene', 'GH_ASA', gnd, True, src=W + page + (' - ' + note if note else ''))
K('osei', 'Osei Tutu I', None, None, 'Asantehene (1701-vers 1717)', 'List_of_rulers_of_Asante', 'dates de naissance et de mort non données', 'h')
K('opoku', 'Opoku Ware I', None, None, 'Asantehene (1720-1750)', 'List_of_rulers_of_Asante', 'petit-neveu et successeur désigné de son prédécesseur (Osei Tutu I)', 'h')
K('kusi', 'Kusi Oboadum', None, None, 'Asantehene (1750-1764)', 'List_of_rulers_of_Asante', "oncle de son prédécesseur (Opoku Ware I) ; forcé d'abdiquer", 'h')
g.fam('gh.osei', 'gh.opoku')
g.fam('gh.opoku', 'gh.kusi')
g.write()
