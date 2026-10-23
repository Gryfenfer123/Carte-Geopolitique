#!/usr/bin/env python3
"""Cherche un membre dans TOUTE la base connue (copie data/db.json + membres créés par les scripts).
Sert à éviter les doublons avant d'ajouter quelqu'un, et à retrouver l'identifiant à réutiliser.

Usage :
  python3 scripts/arbres/outils/chercher.py "Frédéric" 1417          # nom (expression régulière) + année de naissance ±2
  python3 scripts/arbres/outils/chercher.py "Wolfgang|Wilhelm" 1578 3 # tolérance de 3 ans
  python3 scripts/arbres/outils/chercher.py "" 1590 0 DEU             # tous les nés en 1590 dans un pays
Affiche : identifiant (8 premiers caractères) | nom | naissance-mort | pays/arbre | code (si créé par un script)."""
import json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, '..', 'data')
db = json.load(open(os.path.join(DATA, 'db.json')))
reg = json.load(open(os.path.join(DATA, 'registry.json')))
ent = {e[0]: e for e in db['e']}
trees_by_entry = {v['entry']: k for k, v in reg['trees'].items()}

rows = []
for m in db['m']:
    e = ent.get(m[1])
    rows.append((m[0], m[2], m[3], m[4], (e[1] + '/' + e[2][:22]) if e else m[1][:8], ''))
for code, v in reg['members'].items():
    e = ent.get(v['tree']) if v.get('tree') in ent else None
    t = reg['trees'].get(v['tree'])
    where = (t['entry'][:8] + ' ' + v['tree']) if t else v.get('tree', '?')
    rows.append((v['id'], v['name'], v.get('b'), v.get('d'), where, code))

if __name__ == '__main__':
    pat = re.compile(sys.argv[1] if len(sys.argv) > 1 else '', re.I)
    year = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] else None
    tol = int(sys.argv[3]) if len(sys.argv) > 3 else 2
    where = sys.argv[4] if len(sys.argv) > 4 else None
    for i, n, b, d, w, c in sorted(rows, key=lambda r: (r[2] is None, r[2] or 0)):
        if not pat.search(n or ''):
            continue
        if year is not None and (b is None or abs(b - year) > tol):
            continue
        if where and where not in w:
            continue
        print(f'{i[:8]} | {n} | {b if b is not None else "?"}-{d if d is not None else "?"} | {w} | {c}')
