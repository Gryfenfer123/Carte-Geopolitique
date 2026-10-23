#!/bin/bash
# Usage : tester.sh N  — reconstruit la base de test (état avant v39) puis applique les migrations d'arbres v39..N dans l'ordre.
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../../.." && pwd)"
P="psql -h /tmp/pg38 -p 5439 -U postgres -d postgres -q -v ON_ERROR_STOP=1"
python3 "$HERE/mock.py" || exit 1
$P -f /tmp/mock.sql >/dev/null 2>&1 || { echo "ECHEC création base de test"; exit 1; }
for i in $(seq 39 $1); do
  f="$REPO/supabase/schema_v$i.sql"; [ -f "$f" ] || f="$REPO/supabase/arbres/arbres_v$i.sql"
  [ -f "$f" ] && { echo "== v$i"; $P -f "$f" 2>&1 | tail -5; }
done
