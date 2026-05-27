#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck source=lib/load-env.sh
source "$ROOT/scripts/lib/load-env.sh"

resolve_standalone_dir() {
  local candidates=(
    "$ROOT/storefront-build/.next/standalone/server.js"
    "$ROOT/storefront-build/.next/standalone/apps/storefront/server.js"
    "$ROOT/apps/storefront/.next/standalone/apps/storefront/server.js"
    "$ROOT/apps/storefront/.next/standalone/server.js"
  )
  local c
  for c in "${candidates[@]}"; do
    if [ -f "$c" ]; then
      dirname "$c"
      return 0
    fi
  done
  return 1
}

STANDALONE=$(resolve_standalone_dir) || {
  echo "HATA: Next.js standalone server.js bulunamadı."
  echo "Çalıştırın: bash scripts/build-storefront-isolated.sh"
  exit 1
}

# public + static
BUILD_SRC="$ROOT/storefront-build"
[ -d "$BUILD_SRC/public" ] || BUILD_SRC="$ROOT/apps/storefront"
cp -r "$BUILD_SRC/public" "$STANDALONE/"
mkdir -p "$STANDALONE/.next"
cp -r "$BUILD_SRC/.next/static" "$STANDALONE/.next/"

echo "$STANDALONE" > "$ROOT/.storefront-standalone-path"
echo "Standalone: $STANDALONE"

pm2 delete medusa-storefront 2>/dev/null || true

ENV_FILE="$ROOT/apps/storefront/.env.local"
load_env_file "$ENV_FILE"

export NODE_ENV=production
export PORT=3001
export HOSTNAME=0.0.0.0
export MEDUSA_BACKEND_URL="${MEDUSA_BACKEND_URL:-http://127.0.0.1:9000}"
export NEXT_PUBLIC_BASE_URL="${NEXT_PUBLIC_BASE_URL:-http://91.98.120.228:3001}"
export NEXT_PUBLIC_DEFAULT_REGION="${NEXT_PUBLIC_DEFAULT_REGION:-dk}"

pm2 start "$STANDALONE/server.js" --name medusa-storefront --cwd "$STANDALONE"
pm2 save

echo ""
pm2 describe medusa-storefront | grep -E "script path|exec cwd"
curl -s -o /dev/null -w "HTTP /dk: %{http_code}\n" http://127.0.0.1:3001/dk
