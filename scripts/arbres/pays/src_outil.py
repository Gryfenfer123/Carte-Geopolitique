"""Outil commun des lots « sources » : pour chaque membre déjà en base, on écrit la source consultée
dans le champ Notes / biographie et on corrige les dates si la source les contredit.
Ligne = (code, naissance, mort, page, remarque). page = « en:Nom_de_la_page » ou « fr:Nom ».
naissance/mort = None → on garde les dates actuelles du registre."""
from lib import *

def appliquer(g, lignes):
    for code, b, d, page, rem in lignes:
        m = REG['members'][code]
        nb = m['b'] if b == '=' else b
        nd = m['d'] if d == '=' else d
        if (nb, nd) != (m['b'], m['d']):
            g.setdates(code, nb, nd)
        langue, titre = page.split(':', 1)
        url = f"https://{langue}.wikipedia.org/wiki/{titre}"
        g.setbio(code, url + (' — ' + rem if rem else ''))
