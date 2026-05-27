#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

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

echo "Starting storefront on :3001..."
pm2 start ecosystem.config.cjs --only medusa-storefront
pm2 save
pm2 list
