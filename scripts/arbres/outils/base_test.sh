#!/bin/bash
# Démarre (ou crée) une petite base PostgreSQL de TEST locale pour essayer les migrations avant de les envoyer à Martin.
# Usage : bash base_test.sh      puis      bash tester.sh N
D=/tmp/pg38
if ! pg_isready -h $D -p 5439 >/dev/null 2>&1; then
  if [ ! -d $D/data ]; then mkdir -p $D && chown postgres $D && su postgres -c "/usr/lib/postgresql/16/bin/initdb -D $D/data" >/dev/null; fi
  su postgres -c "/usr/lib/postgresql/16/bin/pg_ctl -D $D/data -o '-k $D -p 5439' -l $D/log start" >/dev/null
  sleep 3
fi
pg_isready -h $D -p 5439
