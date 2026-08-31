#!/usr/bin/env bash
# =============================================================================
# etat-frontend.sh — Etat de compilation du frontend Flutter.
#
# Le backend a ete repare et repond ; le frontend, lui, ne compile toujours pas.
# Ce script affiche les erreurs restantes plutot que de les taire : un depot qui
# annonce une application complete alors que l'interface ne se construit pas
# fait perdre son temps a quiconque le clone.
#
#   bash outils/etat-frontend.sh
# =============================================================================

cd "$(dirname "$0")/../frontend" || exit 1

printf '\033[1mflutter build web --release\033[0m\n\n'

sortie=$(flutter build web --release 2>&1)

if printf '%s' "$sortie" | grep -q 'Compilation failed'; then
  printf '%s' "$sortie" | grep -E '^lib/|^Error' | sed 's/^/  /'
  n=$(printf '%s' "$sortie" | grep -c '^Error: ')
  printf '\n  \033[31m%s erreur(s) de compilation — l interface ne peut pas etre construite.\033[0m\n' "$n"
  exit 1
else
  printf '  \033[32mLe frontend compile.\033[0m\n'
  exit 0
fi
