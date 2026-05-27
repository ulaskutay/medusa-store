#!/usr/bin/env bash
# Sunucu: git sıfırla + install + storefront build + pm2
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Git: origin/master"
git fetch origin
git reset --hard origin/master

echo "==> Temiz kurulum"
rm -rf node_modules apps/storefront/node_modules apps/storefront/.next
npm install

echo "==> React 19.0.5"
npm install react@19.0.5 react-dom@19.0.5 --workspace=b2c-storefront --save-exact

echo "==> Storefront build"
rm -rf apps/storefront/.next
cd apps/storefront
export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=2048}"
npm run build
cd "$ROOT"

bash "$ROOT/scripts/prepare-storefront-standalone.sh"

if [ ! -f apps/storefront/.next/BUILD_ID ]; then
  echo "HATA: Build tamamlanmadı (.next/BUILD_ID yok)"
  exit 1
fi

echo "==> PM2"
bash "$ROOT/scripts/pm2-start.sh"

echo "==> Kontrol"
curl -sf http://127.0.0.1:9000/health >/dev/null && echo "API: OK" || echo "API: FAIL"
code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3001/dk)
echo "Storefront /dk: HTTP $code"
