#!/usr/bin/env bash
# Admin paneli build doğrulama (boş sayfa = public/admin symlink eksik)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND="$ROOT/apps/backend"
ADMIN_BUILD="$BACKEND/.medusa/server/public/admin"
ADMIN_LINK="$BACKEND/public/admin"
HTML=""

if [ -f "$ADMIN_LINK/index.html" ]; then
  HTML="$ADMIN_LINK/index.html"
elif [ -f "$ADMIN_BUILD/index.html" ]; then
  HTML="$ADMIN_BUILD/index.html"
  echo "UYARI: public/admin symlink yok. Çalıştırın: bash scripts/link-admin-public.sh"
else
  echo "HATA: Admin build yok. Önce: cd apps/backend && npm run build"
  exit 1
fi

JS=$(grep -oE 'src="/app/assets/[^"]+\.js"' "$HTML" | head -1 | sed 's|src="/app/assets/||;s|"||')
if [ -z "$JS" ]; then
  echo "HATA: index.html içinde JS asset bulunamadı"
  exit 1
fi

ASSET_DIR="$(dirname "$HTML")/assets"
ASSET="$ASSET_DIR/$JS"
if [ ! -f "$ASSET" ]; then
  echo "HATA: Asset dosyası yok: $ASSET"
  exit 1
fi

SIZE=$(wc -c < "$ASSET" | tr -d ' ')
if [ "$SIZE" -lt 10000 ]; then
  echo "HATA: Asset çok küçük ($SIZE byte): $ASSET"
  exit 1
fi

echo "OK: Admin build hazır ($JS, ${SIZE} byte)"
echo "Admin URL: http://127.0.0.1:9000/app"
