#!/usr/bin/env bash
set -euo pipefail

# Rebuild e sobe apenas o frontend do seletor, com diagnóstico opcional.
# Uso:
#   ./scripts/refresh-frontend.sh
#   ./scripts/refresh-frontend.sh --no-cache
#   ./scripts/refresh-frontend.sh --no-cache --url https://varzeaprime.com.br

NO_CACHE=""
TARGET_URL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-cache)
      NO_CACHE="--no-cache"
      shift
      ;;
    --url)
      TARGET_URL="${2:-}"
      shift 2
      ;;
    *)
      echo "Parâmetro inválido: $1"
      echo "Uso: $0 [--no-cache] [--url <http(s)://host>]"
      exit 1
      ;;
  esac
done

echo "[1/7] Conferindo serviços compose..."
docker compose ps >/dev/null

echo "[2/7] Build do frontend (web) ${NO_CACHE}"
docker compose build ${NO_CACHE} web

echo "[3/7] Subindo container web"
docker compose up -d web

echo "[4/7] Estado dos containers"
docker compose ps web api

echo "[5/7] Hash do bundle dentro do container web"
WEB_CONTAINER_ID="$(docker compose ps -q web)"
if [[ -n "$WEB_CONTAINER_ID" ]]; then
  docker exec "$WEB_CONTAINER_ID" sh -lc 'ls -1 /usr/share/nginx/html/assets/index-*.js | sed "s#.*/##"'
else
  echo "Não foi possível identificar o container web."
fi

echo "[6/7] Headers locais (web + api)"
curl -sI "http://localhost:${SELETOR_WEB_PORT:-22011}/dashboard" | sed -n '1,12p'
curl -sI "http://localhost:${SELETOR_API_PORT:-22012}/health" | sed -n '1,12p'

echo "[7/7] Dicas para eliminar cache e validar alvo"
echo "- Faça hard reload (Ctrl+Shift+R) ou teste em aba anônima"
echo "- Se houver CDN/reverse-proxy, faça purge do cache"
echo "- No DevTools > Network, habilite 'Disable cache'"
echo "- /dashboard é frontend do seletor (React SPA); backend só responde /api/* e /health"

if [[ -n "$TARGET_URL" ]]; then
  echo
  echo "Checando URL externa: ${TARGET_URL%/}"
  curl -sI "${TARGET_URL%/}/dashboard" | sed -n '1,14p'
  echo "Se os headers diferirem do localhost:${SELETOR_WEB_PORT:-22011}, você pode estar batendo em outro proxy/servidor."
fi
