#!/usr/bin/env bash
# next build (standalone) sonrası public + static kopyala
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SF="$ROOT/apps/storefront"
TARGET="$SF/.next/standalone/apps/storefront"

if [ ! -f "$TARGET/server.js" ]; then
  echo "HATA: $TARGET/server.js yok — önce 'npm run build' çalıştırın"
  exit 1
fi

cp -r "$SF/public" "$TARGET/"
mkdir -p "$TARGET/.next"
cp -r "$SF/.next/static" "$TARGET/.next/"
echo "Standalone hazır: $TARGET"
