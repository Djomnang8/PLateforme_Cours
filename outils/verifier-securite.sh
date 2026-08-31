#!/usr/bin/env bash
# =============================================================================
# verifier-securite.sh — Verrouille les corrections de securite du backend.
#
# Trois defauts ont ete trouves en relisant AuthController :
#
#   1. les mots de passe etaient stockes et compares en clair
#      (le bean PasswordEncoder existait, mais renvoyait NoOpPasswordEncoder) ;
#   2. /forgot-password changeait le mot de passe de n'importe quel compte a
#      partir de la seule adresse e-mail, sans aucune preuve ;
#   3. une adresse inconnue renvoyait 500 la ou un mot de passe errone renvoyait
#      401 : la difference suffisait a savoir quelles adresses ont un compte.
#
# Ce script echoue si l'un des trois revient.
#
#   bash outils/verifier-securite.sh [adresse]
# =============================================================================

BASE="${1:-http://localhost:8082}"
COMPTE="${2:-admin@gmail.com}"
MDP="${3:-admin123}"
echecs=0

ok()  { printf '  \033[32mOK\033[0m   %s\n' "$1"; }
ko()  { printf '  \033[31mKO\033[0m   %s\n' "$1"; echecs=$((echecs + 1)); }
titre() { printf '\n\033[1m%s\033[0m\n' "$1"; }

json() { curl -s -X POST "$BASE$1" -H 'Content-Type: application/json' -d "$2"; }
code() { curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE$1" -H 'Content-Type: application/json' -d "$2"; }

titre "1. Connexion valide"
c=$(code /api/auth/login "{\"email\":\"$COMPTE\",\"password\":\"$MDP\"}")
[ "$c" = "200" ] && ok "HTTP 200" || ko "HTTP $c, attendu 200"

titre "2. Mot de passe errone"
c=$(code /api/auth/login "{\"email\":\"$COMPTE\",\"password\":\"pas-le-bon\"}")
[ "$c" = "401" ] && ok "HTTP 401" || ko "HTTP $c, attendu 401"

titre "3. Adresse inconnue — meme reponse, pas d'enumeration des comptes"
c=$(code /api/auth/login '{"email":"inconnu@nulle-part.test","password":"peu-importe"}')
if [ "$c" = "401" ]; then
  ok "HTTP 401, identique au cas precedent"
else
  ko "HTTP $c : la reponse revele si le compte existe"
fi

titre "4. Reinitialisation sans le matricule — doit etre refusee"
c=$(code /api/auth/forgot-password "{\"email\":\"$COMPTE\",\"newPassword\":\"pirate\"}")
if [ "$c" = "401" ]; then
  ok "HTTP 401 : l'adresse seule ne suffit plus a prendre le compte"
else
  ko "HTTP $c : le compte peut etre pris avec la seule adresse e-mail"
fi

titre "5. Le mot de passe n'a pas ete change par la tentative precedente"
c=$(code /api/auth/login "{\"email\":\"$COMPTE\",\"password\":\"$MDP\"}")
[ "$c" = "200" ] && ok "le compte repond toujours avec son mot de passe d'origine" \
                 || ko "HTTP $c : le mot de passe a ete modifie"

titre "6. Empreinte stockee en base"
if command -v mysql >/dev/null 2>&1; then
  MYSQL=mysql
elif [ -x "/c/xampp/mysql/bin/mysql.exe" ]; then
  MYSQL=/c/xampp/mysql/bin/mysql.exe
else
  MYSQL=""
fi
if [ -n "$MYSQL" ]; then
  emp=$("$MYSQL" -u root -N -B -e \
    "use gestion_cours; select password from users where email='$COMPTE';" 2>/dev/null)
  case "$emp" in
    \$2a\$*|\$2b\$*|\$2y\$*) ok "empreinte BCrypt : ${emp:0:7}… (${#emp} caracteres)" ;;
    "")  ko "compte introuvable en base" ;;
    *)   ko "mot de passe encore lisible en clair : $emp" ;;
  esac
else
  printf '  \033[33m--\033[0m   client mysql introuvable, verification ignoree\n'
fi

printf '\n'
if [ "$echecs" -eq 0 ]; then
  printf '  \033[32mLes trois defauts de securite restent corriges.\033[0m\n'
else
  printf '  \033[31m%s verification(s) en echec.\033[0m\n' "$echecs"
fi
exit "$echecs"
