#!/usr/bin/env bash
# medusa build → .medusa/server/public/admin
# medusa start → public/admin (symlink gerekli)
set -euo pipefail

BACKEND="$(cd "$(dirname "$0")/../apps/backend" && pwd)"
ADMIN_BUILD="$BACKEND/.medusa/server/public/admin"
ADMIN_LINK="$BACKEND/public/admin"

if [ ! -f "$ADMIN_BUILD/index.html" ]; then
  echo "HATA: Admin build yok: $ADMIN_BUILD"
  echo "Önce: cd apps/backend && npm run build"
  exit 1
fi

mkdir -p "$BACKEND/public"
ln -sfn ../.medusa/server/public/admin "$ADMIN_LINK"
echo "OK: $ADMIN_LINK → .medusa/server/public/admin"
