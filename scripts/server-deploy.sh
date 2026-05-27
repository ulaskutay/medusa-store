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

echo "==> Backend build (admin panel)"
cd apps/backend
npm run build
cd "$ROOT"
bash "$ROOT/scripts/link-admin-public.sh"
bash "$ROOT/scripts/verify-admin-build.sh"

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
admin_js=$(curl -s http://127.0.0.1:9000/app | grep -oE '/app/assets/[^"]+\.js' | head -1)
if [ -n "$admin_js" ]; then
  js_size=$(curl -s "http://127.0.0.1:9000${admin_js}" | wc -c | tr -d ' ')
  if [ "$js_size" -lt 10000 ]; then
    echo "Admin /app: HATA — JS dosyası HTML dönüyor (${js_size} byte). pm2 restart medusa-api deneyin."
  else
    echo "Admin /app: OK (JS ${js_size} byte)"
  fi
fi
code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3001/tr)
echo "Storefront /tr: HTTP $code"
