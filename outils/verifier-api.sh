#!/usr/bin/env bash
# =============================================================================
# verifier-api.sh — Parcourt l'API du backend avec un compte reel.
#
# Le backend ne compilait pas du tout (imports manquants, champs de depot non
# declares, methode de depot appelee sans exister, entite refactoree sans que le
# controleur suive). Ce script sert de garde-fou : il echoue si une route cesse
# de repondre.
#
#   bash outils/verifier-api.sh [adresse] [email] [mot de passe]
# =============================================================================

BASE="${1:-http://localhost:8082}"
COMPTE="${2:-admin@gmail.com}"
MDP="${3:-admin123}"
echecs=0

printf '\033[1mBackend : %s   compte : %s\033[0m\n\n' "$BASE" "$COMPTE"

reponse=$(curl -s -X POST "$BASE/api/auth/login" -H 'Content-Type: application/json' \
  -d "{\"email\":\"$COMPTE\",\"password\":\"$MDP\"}")
role=$(printf '%s' "$reponse" | grep -o '"role":"[^"]*"' | cut -d'"' -f4)
second=$(printf '%s' "$reponse" | grep -o '"requiresSecondFactor":[a-z]*' | cut -d: -f2)

if [ -n "$role" ]; then
  printf '  \033[32mOK\033[0m   connexion — role %s, second facteur exige : %s\n\n' "$role" "$second"
else
  printf '  \033[31mKO\033[0m   connexion refusee : %s\n\n' "$reponse"
  echecs=$((echecs + 1))
fi

# Les routes metier sont protegees par authentification HTTP basique.
AUTH="-u $COMPTE:$MDP"

for route in "/api/courses" "/api/employees" "/api/progress" "/api/certifications" "/api/analytics"; do
  corps=$(curl -s $AUTH "$BASE$route")
  code=$(curl -s -o /dev/null -w '%{http_code}' $AUTH "$BASE$route")
  n=$(printf '%s' "$corps" | grep -o '"id"' | wc -l | tr -d ' ')
  if [ "$code" = "200" ]; then
    printf '  \033[32mOK\033[0m   %-22s %s   %s enregistrement(s)\n' "$route" "$code" "$n"
  else
    printf '  \033[31mKO\033[0m   %-22s %s\n' "$route" "$code"
    echecs=$((echecs + 1))
  fi
done

printf '\n\033[1mCatalogue des formations :\033[0m\n'
curl -s $AUTH "$BASE/api/courses" | python -c "$(cat <<'PY'
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print('  (reponse illisible)'); raise SystemExit
if not d:
    print('  (catalogue vide)')
for c in d:
    etat = 'active' if c.get('active') else 'inactive'
    titre = (c.get('title') or '')[:44]
    print('  #%-3s %-46s %s' % (c.get('id'), titre, etat))
PY
)"

printf '\n\033[1mProgression enregistree :\033[0m\n'
curl -s $AUTH "$BASE/api/progress" | python -c "$(cat <<'PY'
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print('  (reponse illisible)'); raise SystemExit
if not d:
    print('  (aucune progression)')
for p in d:
    doc = p.get('documentProgress') or 0
    quiz = p.get('quizProgress') or 0
    app = (p.get('learner') or {}).get('fullName', '?')
    cours = (p.get('course') or {}).get('title', '?')[:28]
    print('  %-10s %-30s lecture %2d/50 + quiz %2d/50 = %3d %%'
          % (app, cours, doc, quiz, doc + quiz))
PY
)"

printf '\n'
if [ "$echecs" -eq 0 ]; then
  printf '  \033[32mToutes les routes repondent.\033[0m\n'
else
  printf '  \033[31m%s route(s) en echec.\033[0m\n' "$echecs"
fi
exit "$echecs"
