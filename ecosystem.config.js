module.exports = {
  apps: [
    {
      name: 'pepshop-backend',
      script: './pepshop-admin/index.js',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 8000,
        HOST: '127.0.0.1'
      },
      env_file: './pepshop-admin/.env.production',
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_file: './logs/backend-combined.log',
      time: true,
      watch: false,
      max_memory_restart: '1G',
      restart_delay: 4000,
      max_restarts: 5,
      min_uptime: '10s'
    },
    {
      name: 'pepshop-frontend',
      script: 'npm',
      args: 'run dev',
      cwd: './pepshop-frontend',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        HOST: '127.0.0.1'
      },
      env_file: './pepshop-frontend/.env.production',
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      log_file: './logs/frontend-combined.log',
      time: true,
      watch: false,
      max_memory_restart: '512M',
      restart_delay: 4000,
      max_restarts: 5,
      min_uptime: '10s'
    }
  ]
};
