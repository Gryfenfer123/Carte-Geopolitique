#!/bin/bash
# Usage : livrer.sh N "ligne de doc" "titre du commit" "pourquoi"
# Ajoute la ligne dans docs/BASE_DE_DONNEES.md, lance les contrôles (check:repo + build), commit et pousse.
# (Le numéro N est celui de l'arbre : fichier supabase/arbres/arbres_vN.sql, ou schema_vN.sql si N <= 60.)
N=$1; ROW="$2"; T="$3"; W="$4"
cd "$(dirname "$0")/../../.." || exit 1
git pull -q --rebase || exit 1
NOM="arbres_v$N"; [ "$N" -le 60 ] && NOM="schema_v$N"
python3 - "$NOM" "$ROW" <<'PY'
import sys
nom,row=sys.argv[1],sys.argv[2]
p='docs/BASE_DE_DONNEES.md'; s=open(p).read()
m="| `data_owid_load.sql`"
s=s.replace(m,f"| {nom} | {row} |\n"+m,1); open(p,'w').write(s)
PY
npm run check:repo 2>&1 | tail -1 && npm run build 2>&1 | tail -1 || exit 1
git add -A && git commit -q -m "$T

$W" && git push -q 2>&1 | tail -1
git log --oneline | head -1
