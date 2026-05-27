#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

git fetch origin
git reset --hard origin/master

bash "$ROOT/scripts/build-storefront-isolated.sh"
bash "$ROOT/scripts/activate-storefront-standalone.sh"
