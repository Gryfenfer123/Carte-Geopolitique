#!/usr/bin/env python3
"""Cherche des doublons possibles pour les membres NOUVEAUX d'un script gen_*.py (sans rien écrire).
Usage : python3 scripts/arbres/outils/doublons.py scripts/arbres/pays/gen_xx.py
Affiche, pour chaque nouveau membre, les membres déjà en base nés à ±1 an avec un prénom proche, ou de même nom si pas de date."""
import sys, unicodedata, runpy, os
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE); sys.path.insert(0, os.path.join(HERE, '..'))
f = sys.argv[1]
sys.argv = ['x']
import chercher
ns = runpy.run_path(f, run_name='x')
g = ns['g']
def norm(t): return unicodedata.normalize('NFD', (t or '').lower()).encode('ascii', 'ignore').decode()
for m in g.M:
    b = m['b']; first = norm(m['name']).split(' ')[0][:5]
    if b is None:
        c = [r for r in chercher.rows if norm(m['name']) == norm(r[1])]
    else:
        c = [r for r in chercher.rows if r[2] and abs(r[2] - b) <= 1 and first == norm(r[1]).split(' ')[0][:5]]
    for r in c:
        print(m['code'], '|', m['name'], b, '<->', r[0][:8], r[1], r[2], r[4][:30], r[5])
