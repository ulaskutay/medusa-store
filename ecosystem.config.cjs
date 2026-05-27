/** PM2: sunucuda kalıcı çalıştırma
 *  Backend:  cd /www/wwwroot/medusa/medusa-store && pm2 start ecosystem.config.cjs --only medusa-api
 *  Storefront (aaPanel kullanmıyorsanız): pm2 start ecosystem.config.cjs --only medusa-storefront
 */
module.exports = {
  apps: [
    {
      name: 'medusa-api',
      cwd: './apps/backend',
      script: 'npm',
      args: 'run start',
      env: {
        NODE_ENV: 'production'
      },
      instances: 1,
      autorestart: true,
      max_memory_restart: '800M'
    },
    {
      name: 'medusa-storefront',
      cwd: './apps/storefront',
      script: 'npm',
      args: 'run start -- -p 3001',
      env: {
        NODE_ENV: 'production',
        PORT: '3001'
      },
      instances: 1,
      autorestart: true,
      max_memory_restart: '600M'
    }
  ]
};
