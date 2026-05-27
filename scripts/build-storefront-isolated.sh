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

# Monorepo outputFileTracingRoot kullanma
cat > "$BUILD_DIR/next.config.deploy.ts" <<'EOF'
import type { NextConfig } from 'next'
import path from 'path'
import { createRequire } from 'module'

const require = createRequire(import.meta.url)
const checkEnvVariables = require('./check-env-variables')
checkEnvVariables()

const nextConfig: NextConfig = {
  output: 'standalone',
  trailingSlash: false,
  reactStrictMode: true,
  transpilePackages: ['@medusajs/ui'],
  eslint: { ignoreDuringBuilds: true },
  typescript: { ignoreBuildErrors: true },
  images: { unoptimized: true, remotePatterns: [{ protocol: 'https', hostname: '**' }] }
}

export default nextConfig
EOF

mv "$BUILD_DIR/next.config.ts" "$BUILD_DIR/next.config.monorepo.ts.bak" 2>/dev/null || true
mv "$BUILD_DIR/next.config.deploy.ts" "$BUILD_DIR/next.config.ts"

if [ -f "$SRC/.env.local" ]; then
  cp "$SRC/.env.local" "$BUILD_DIR/.env.local"
fi

echo "==> npm install (izole, monorepo yok)"
cd "$BUILD_DIR"
npm install

echo "==> npm run build"
export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=2048}"
npm run build

if [ -f "$BUILD_DIR/.next/standalone/server.js" ]; then
  STANDALONE="$BUILD_DIR/.next/standalone"
else
  STANDALONE="$BUILD_DIR/.next/standalone/apps/storefront"
fi

cp -r public "$STANDALONE/"
mkdir -p "$STANDALONE/.next"
cp -r .next/static "$STANDALONE/.next/"

echo "$STANDALONE" > "$ROOT/.storefront-standalone-path"
echo "==> İzole build tamam: $STANDALONE"
