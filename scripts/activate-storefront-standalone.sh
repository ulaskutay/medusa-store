#!/usr/bin/env bash
# Build bittikten sonra PM2'yi doğru standalone klasörüne bağla
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ -f "$ROOT/.storefront-standalone-path" ]; then
  STANDALONE=$(cat "$ROOT/.storefront-standalone-path")
else
  SERVER_JS=$(find "$ROOT/storefront-build/.next/standalone" -name server.js -type f 2>/dev/null | head -1)
  if [ -z "$SERVER_JS" ]; then
    echo "HATA: standalone bulunamadı. Önce: bash scripts/build-storefront-isolated.sh"
    exit 1
  fi
  STANDALONE=$(dirname "$SERVER_JS")
  # public/static eksikse tamamla
  cp -r "$ROOT/storefront-build/public" "$STANDALONE/" 2>/dev/null || true
  mkdir -p "$STANDALONE/.next"
  cp -r "$ROOT/storefront-build/.next/static" "$STANDALONE/.next/" 2>/dev/null || true
  echo "$STANDALONE" > "$ROOT/.storefront-standalone-path"
fi

echo "Standalone: $STANDALONE"

pm2 delete medusa-storefront 2>/dev/null || true

# .env.local değerlerini yükle
ENV_FILE="$ROOT/apps/storefront/.env.local"
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

PORT=3001 HOSTNAME=0.0.0.0 NODE_ENV=production \
  MEDUSA_BACKEND_URL="${MEDUSA_BACKEND_URL:-http://127.0.0.1:9000}" \
  NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY="${NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY:-}" \
  NEXT_PUBLIC_BASE_URL="${NEXT_PUBLIC_BASE_URL:-http://91.98.120.228:3001}" \
  NEXT_PUBLIC_DEFAULT_REGION="${NEXT_PUBLIC_DEFAULT_REGION:-dk}" \
  pm2 start "$STANDALONE/server.js" --name medusa-storefront --cwd "$STANDALONE"

pm2 save
pm2 describe medusa-storefront | grep -E "script path|exec cwd"
curl -s -o /dev/null -w "HTTP /dk: %{http_code}\n" http://127.0.0.1:3001/dk
