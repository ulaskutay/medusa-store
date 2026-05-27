#!/usr/bin/env bash
# Monorepo dışında tek React ile storefront build (useContext fix)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/apps/storefront"
BUILD_DIR="$ROOT/storefront-build"

echo "==> İzole build dizini: $BUILD_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

rsync -a "$SRC/" "$BUILD_DIR/" \
  --exclude node_modules \
  --exclude .next \
  --exclude '.turbo'

cat > "$BUILD_DIR/next.config.ts" <<'EOF'
import type { NextConfig } from 'next'
import path from 'path'
import { createRequire } from 'module'

const require = createRequire(import.meta.url)
const checkEnvVariables = require('./check-env-variables')
checkEnvVariables()

const nextConfig: NextConfig = {
  output: 'standalone',
  outputFileTracingRoot: path.join(__dirname),
  trailingSlash: false,
  reactStrictMode: true,
  transpilePackages: ['@medusajs/ui'],
  eslint: { ignoreDuringBuilds: true },
  typescript: { ignoreBuildErrors: true },
  images: { unoptimized: true, remotePatterns: [{ protocol: 'https', hostname: '**' }] }
}

export default nextConfig
EOF

if [ -f "$SRC/.env.local" ]; then
  cp "$SRC/.env.local" "$BUILD_DIR/.env.local"
fi

echo "==> npm install (izole)"
cd "$BUILD_DIR"
npm install

echo "==> npm run build"
export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=2048}"
npm run build

SERVER_JS=$(find "$BUILD_DIR/.next/standalone" -name server.js -type f 2>/dev/null | head -1)
if [ -z "$SERVER_JS" ]; then
  echo "HATA: standalone server.js bulunamadı"
  find "$BUILD_DIR/.next" -maxdepth 4 -type f 2>/dev/null | head -20
  exit 1
fi

STANDALONE="$(dirname "$SERVER_JS")"
echo "==> Standalone: $STANDALONE"

cp -r "$BUILD_DIR/public" "$STANDALONE/"
mkdir -p "$STANDALONE/.next"
cp -r "$BUILD_DIR/.next/static" "$STANDALONE/.next/"

echo "$STANDALONE" > "$ROOT/.storefront-standalone-path"
echo "==> İzole build tamam"
