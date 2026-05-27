#!/usr/bin/env bash
# PM2 hâlâ "next start" kullanıyorsa — standalone'a geç
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

git fetch origin
git reset --hard origin/master

echo "==> Standalone build"
cd apps/storefront
rm -rf .next
export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=2048}"
npm run build
cd "$ROOT"

bash "$ROOT/scripts/prepare-storefront-standalone.sh"

echo "==> PM2 (server.js, NOT next start)"
pm2 delete medusa-storefront 2>/dev/null || true
pm2 start ecosystem.config.cjs --only medusa-storefront
pm2 save

echo ""
pm2 describe medusa-storefront | grep -E "script path|exec cwd|status"
echo ""
curl -s -o /dev/null -w "HTTP /dk: %{http_code}\n" http://127.0.0.1:3001/dk
