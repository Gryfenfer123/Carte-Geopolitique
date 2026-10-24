import sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from lib import *

g = Gen(124, "Oman (Al Said)")
g.notes = ["Nouvel arbre « Al Said » (Oman) : 15 sultans et princes. Chaque fiche porte l'adresse de sa page Wikipédia (anglais) dans « Notes / biographie » ; sources aussi dans docs/sources/arbres.md.", "Pages individuelles lues : Taimur, Said bin Taimur, Qaboos, Tariq, Haitham ; les autres fiches viennent de la liste des dirigeants d'Oman.", 'Non saisi : Azzan ben Qays (1868-1871, usurpateur hors de la lignée directe, père non indiqué). Dans la liste, les règnes de Said ben Sultan et Salim ben Sultan se chevauchent (tous deux 1804).', 'Dates en année chrétienne telles que la page les donne.']
g.tree('OM_SAI', 'OMN', 'Al Said', section_title='Al Said')
W = 'https://en.wikipedia.org/wiki/'
def K(code, name, b, d, title, page, note=None):
    return g.m('om.' + code, name, b, d, title, 'Al Said', 'OM_SAI', 'h', True, src=W + page + (' - ' + note if note else ''))
K('ahmad', 'Ahmad ben Said', 1694, 1783, 'Fondateur de la dynastie, imam puis sultan (1749-1783)', 'List_of_rulers_of_Oman')
K('saidA', 'Said ben Ahmad', 1741, 1811, "Imam d'Oman (1783-1786)", 'List_of_rulers_of_Oman')
K('hamad', 'Hamad ben Said', None, 1792, "Dirigeant d'Oman (1786-1792)", 'List_of_rulers_of_Oman')
K('sultanA', 'Sultan ben Ahmad', 1755, 1804, "Sultan d'Oman (1792-1804)", 'List_of_rulers_of_Oman')
K('salimS', 'Salim ben Sultan', 1790, 1821, "Co-dirigeant d'Oman (1804-1806)", 'List_of_rulers_of_Oman')
K('saidS', 'Saïd ben Sultan', 1791, 1856, "Sultan d'Oman et de Zanzibar (1804-1856)", 'List_of_rulers_of_Oman')
K('thuwaini', 'Thuwaini ben Said', 1821, 1866, "Sultan d'Oman (1856-1866)", 'List_of_rulers_of_Oman')
K('salimT', 'Salim ben Thuwaini', 1839, 1876, "Sultan d'Oman (1866-1868)", 'List_of_rulers_of_Oman')
K('turki', 'Turki ben Said', 1832, 1888, "Sultan d'Oman (1871-1888)", 'List_of_rulers_of_Oman')
K('faisal', 'Fayçal ben Turki', 1864, 1913, "Sultan d'Oman (1888-1913)", 'List_of_rulers_of_Oman')
K('taimur', 'Taimur ben Fayçal', 1886, 1965, "Sultan d'Oman (1913-1932)", 'Taimur_bin_Feisal')
K('saidT', 'Saïd ben Taimur', 1910, 1972, "Sultan d'Oman (1932-1970)", 'Said_bin_Taimur')
K('tariq', 'Tariq ben Taimur', 1921, 1980, "Premier ministre d'Oman, père du sultan Haïtham", 'Tariq_bin_Taimur')
K('qaboos', 'Qabous ben Saïd', 1940, 2020, "Sultan d'Oman (1970-2020)", 'Qaboos_bin_Said')
K('haitham', 'Haïtham ben Tariq', 1955, None, "Sultan d'Oman (depuis 2020)", 'Haitham_bin_Tariq')
for a, b in [('ahmad', 'saidA'), ('saidA', 'hamad'), ('ahmad', 'sultanA'), ('sultanA', 'salimS'), ('sultanA', 'saidS'), ('saidS', 'thuwaini'), ('thuwaini', 'salimT'), ('saidS', 'turki'), ('turki', 'faisal'), ('faisal', 'taimur'), ('taimur', 'saidT'), ('taimur', 'tariq'), ('saidT', 'qaboos'), ('tariq', 'haitham')]:
    g.par('om.' + a, 'om.' + b)
g.write()
