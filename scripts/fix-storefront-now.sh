#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

git fetch origin
git reset --hard origin/master

echo "==> İzole storefront build"
bash "$ROOT/scripts/build-storefront-isolated.sh"

echo "==> PM2"
pm2 delete medusa-storefront 2>/dev/null || true
pm2 start ecosystem.config.cjs --only medusa-storefront
pm2 save

echo ""
pm2 describe medusa-storefront | grep -E "script path|exec cwd"
curl -s -o /dev/null -w "HTTP /dk: %{http_code}\n" http://127.0.0.1:3001/dk
