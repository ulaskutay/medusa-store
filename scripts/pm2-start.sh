#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Checking single React install..."
npm ls react --workspace=b2c-storefront 2>/dev/null | head -5 || true

echo "Verifying admin build..."
bash "$ROOT/scripts/verify-admin-build.sh"

echo "Starting Medusa API..."
pm2 delete medusa-api medusa-storefront 2>/dev/null || true
pm2 start ecosystem.config.cjs --only medusa-api

echo "Waiting for backend on :9000..."
for i in $(seq 1 30); do
  if curl -sf http://127.0.0.1:9000/health >/dev/null; then
    echo "Backend is ready."
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "ERROR: Backend did not start on port 9000. Check: pm2 logs medusa-api"
    exit 1
  fi
  sleep 2
done

STANDALONE_SERVER="$ROOT/apps/storefront/.next/standalone/apps/storefront/server.js"
if [ ! -f "$STANDALONE_SERVER" ]; then
  echo "HATA: Standalone build yok: $STANDALONE_SERVER"
  echo "Çalıştırın: bash scripts/server-deploy.sh"
  exit 1
fi

echo "Starting storefront (standalone server.js) on :3001..."
pm2 start ecosystem.config.cjs --only medusa-storefront
pm2 save
pm2 list
