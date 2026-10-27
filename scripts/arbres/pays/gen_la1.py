import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(136, "Laos (Luang Prabang, Champassak)")
g.notes = ["Nouvel arbre « Maisons royales du Laos » (Laos) : 6 personnes (Luang Prabang : Kham Souk, Sisavang Vong, Sisavang Vatthana ; Champassak : un Kham Souk, Ratsadanay, Boun Oum). Chaque fiche porte l'adresse de la page Wikipédia (anglais) « List of monarchs of Laos » dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Les deux Kham Souk sont deux personnes : celui de Luang Prabang (1840-1904) et celui de Champassak (1839-1900, dates tirées de la ligne de son fils). Aucun lien entre les deux branches n'est saisi (non indiqué par la page). Anouvong (Vientiane) non saisi : son père Ong Boun n'a pas de page lue.", 'Sisavang Vong : fin du règne de Luang Prabang 1945 ou 1946 selon les tableaux. Dates en année chrétienne.']
g.tree('LA_ROY', 'LAO', 'Maisons royales du Laos', section_title='Maisons royales du Laos')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None, gnd=None):
    return g.m('la.' + code, name, b, d, title, 'Maisons royales du Laos', 'LA_ROY', (gnd or 'h'), True, src=W + page + (' - ' + note if note else ''))
K('khamsouk', 'Kham Souk (Luang Prabang)', 1840, 1904, 'Roi de Luang Prabang (1895-1904)', 'List_of_monarchs_of_Laos')
K('sisavangvong', 'Sisavang Vong', 1885, 1959, 'Roi de Luang Prabang puis du Laos (1904-1959)', 'List_of_monarchs_of_Laos')
K('vatthana', 'Sisavang Vatthana', 1907, 1978, 'Dernier roi du Laos (1959-1975)', 'List_of_monarchs_of_Laos')
K('khamsouk2', 'Kham Souk (Champassak)', 1839, 1900, 'Prince de Champassak, père de Ratsadanay', 'List_of_monarchs_of_Laos', 'dates tirées de la ligne de son fils Ratsadanay')
K('ratsadanay', 'Ratsadanay', 1874, 1945, 'Roi de Champassak (1900-1904)', 'List_of_monarchs_of_Laos')
K('bounoum', 'Boun Oum', 1912, 1980, 'Prince de Champassak, renonce à ses droits en 1946', 'List_of_monarchs_of_Laos')
for a, b in [('khamsouk', 'sisavangvong'), ('sisavangvong', 'vatthana'), ('khamsouk2', 'ratsadanay'), ('ratsadanay', 'bounoum')]:
    g.par('la.' + a, 'la.' + b)
g.write()
