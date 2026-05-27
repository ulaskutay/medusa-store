const path = require('path');
const fs = require('fs');

/** Parse .env.local so PM2 passes vars to Next.js at runtime (not only at build). */
function loadEnvFile(relativePath) {
  const envPath = path.join(__dirname, relativePath);
  const vars = {};
  if (!fs.existsSync(envPath)) {
    console.warn(`[ecosystem] Missing env file: ${envPath}`);
    return vars;
  }
  for (const line of fs.readFileSync(envPath, 'utf8').split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eq = trimmed.indexOf('=');
    if (eq === -1) continue;
    const key = trimmed.slice(0, eq).trim();
    let val = trimmed.slice(eq + 1).trim();
    if (
      (val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))
    ) {
      val = val.slice(1, -1);
    }
    vars[key] = val;
  }
  return vars;
}

const storefrontEnv = {
  NODE_ENV: 'production',
  PORT: '3001',
  ...loadEnvFile('apps/storefront/.env.local'),
  // Ensure server-side fetches hit local API when .env uses localhost
  MEDUSA_BACKEND_URL:
    loadEnvFile('apps/storefront/.env.local').MEDUSA_BACKEND_URL ||
    'http://127.0.0.1:9000'
};

const backendEnv = {
  NODE_ENV: 'production',
  ...loadEnvFile('apps/backend/.env')
};

module.exports = {
  apps: [
    {
      name: 'medusa-api',
      cwd: './apps/backend',
      script: 'npm',
      args: 'run start',
      env: backendEnv,
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      max_memory_restart: '800M'
    },
    {
      name: 'medusa-storefront',
      cwd: './apps/storefront/.next/standalone/apps/storefront',
      script: 'server.js',
      env: {
        ...storefrontEnv,
        PORT: '3001',
        HOSTNAME: '0.0.0.0'
      },
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      max_memory_restart: '600M'
    }
  ]
};
