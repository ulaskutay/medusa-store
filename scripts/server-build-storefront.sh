#!/usr/bin/env bash
# Sunucuda storefront build — React sürümü + temiz .next
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> React 19.0.5 (monorepo tek sürüm)"
npm install react@19.0.5 react-dom@19.0.5 --workspace=b2c-storefront --save-exact

echo "==> Storefront build"
rm -rf apps/storefront/.next
cd apps/storefront
export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=2048}"
npm run build
cd "$ROOT"
bash "$ROOT/scripts/prepare-storefront-standalone.sh"

echo "==> Build OK"
