#!/usr/bin/env bash
# Lance les tests de la logique pure de l'outil de croquis (aucun navigateur, aucun réseau).
# Le fichier de test est empaqueté dans un dossier temporaire puis exécuté par node.
set -euo pipefail
cd "$(dirname "$0")/../.."
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT
npx rolldown scripts/croquis/test-sketch.ts --file "$OUT/test.mjs" --format esm --platform node >/dev/null
node "$OUT/test.mjs"
