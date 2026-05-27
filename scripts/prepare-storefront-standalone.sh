#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SF="$ROOT/apps/storefront"

if [ -f "$SF/.next/standalone/apps/storefront/server.js" ]; then
  TARGET="$SF/.next/standalone/apps/storefront"
elif [ -f "$SF/.next/standalone/server.js" ]; then
  TARGET="$SF/.next/standalone"
else
  echo "HATA: standalone server.js bulunamadı — önce npm run build"
  exit 1
fi

cp -r "$SF/public" "$TARGET/"
mkdir -p "$TARGET/.next"
cp -r "$SF/.next/static" "$TARGET/.next/"
echo "Standalone hazır: $TARGET"
