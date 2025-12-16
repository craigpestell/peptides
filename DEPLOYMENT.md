# Production Deployment Guide for DigitalOcean

This guide will help you deploy both the PepShop backend (Storecraft) and frontend (Next.js) on a single DigitalOcean droplet using Nginx virtual hosts.

## Server Requirements

- Ubuntu 20.04+ LTS
- 2GB RAM minimum (4GB recommended)
- 25GB+ SSD storage
- Node.js 18+
- Nginx
- PM2 for process management
- MySQL (for Storecraft backend)

## 1. Initial Server Setup

### Create DigitalOcean Droplet
```bash
# Choose Ubuntu 20.04+ LTS
# Select appropriate size (2GB+ RAM recommended)
# Add your SSH key
# Enable backups (optional)
```

### Connect to your droplet
```bash
ssh root@your-droplet-ip
```

### Update system packages
```bash
apt update && apt upgrade -y
```

### Install Node.js 18+
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs
node --version
npm --version
```

### Install Nginx
```bash
apt install nginx -y
systemctl start nginx
systemctl enable nginx
```

### Install PM2 (Process Manager)
```bash
npm install -g pm2
```

### Install MySQL
```bash
apt install mysql-server -y
mysql_secure_installation
```

### Setup MySQL database
```bash
mysql -u root -p
CREATE DATABASE pepshop_db;
CREATE USER 'pepshop_user'@'localhost' IDENTIFIED BY 'secure_password_here';
GRANT ALL PRIVILEGES ON pepshop_db.* TO 'pepshop_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

## 2. Domain Configuration

You have several options for virtual hosts:

### Option A: Subdomain-based (Recommended)
- Backend API: `api.yourdomain.com`
- Frontend: `yourdomain.com` or `www.yourdomain.com`

### Option B: Path-based
- Backend API: `yourdomain.com/api`
- Frontend: `yourdomain.com`

### Option C: Port-based (Development)
- Backend API: `yourdomain.com:8000`
- Frontend: `yourdomain.com:3000`

## 3. Application Deployment

### Create application directory
```bash
mkdir -p /var/www/pepshop
cd /var/www/pepshop
```

### Deploy Backend (Storecraft)
```bash
# Clone or upload your backend code
git clone your-repo-url backend
# Or upload via SCP:
# scp -r ./pepshop-admin root@your-droplet-ip:/var/www/pepshop/backend

cd backend
npm install --production
```

### Deploy Frontend (Next.js)
```bash
# Clone or upload your frontend code
git clone your-repo-url frontend
# Or upload via SCP:
# scp -r ./pepshop-frontend root@your-droplet-ip:/var/www/pepshop/frontend

cd frontend
npm install
npm run build
```

## 4. Environment Configuration

See the respective .env files for backend and frontend configuration.

## 5. Nginx Configuration

See nginx configuration files for virtual host setup.

## 6. Process Management with PM2

See PM2 ecosystem file for process configuration.

## 7. SSL Certificate with Let's Encrypt

```bash
apt install certbot python3-certbot-nginx -y

# For subdomain setup
certbot --nginx -d yourdomain.com -d api.yourdomain.com

# For single domain
certbot --nginx -d yourdomain.com
```

## 8. Firewall Configuration

```bash
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw enable
```

## 9. Monitoring and Maintenance

### PM2 Commands
```bash
pm2 list                    # View running processes
pm2 restart all            # Restart all processes
pm2 logs                   # View logs
pm2 monit                  # Monitor processes
pm2 save                   # Save current process list
pm2 startup                # Enable startup script
```

### Nginx Commands
```bash
nginx -t                   # Test configuration
systemctl reload nginx     # Reload configuration
systemctl restart nginx    # Restart nginx
```

## 10. Deployment Automation

For future deployments, you can use the deploy script provided.

## Troubleshooting

### Common Issues
1. **Port conflicts**: Ensure applications run on different ports
2. **Permission issues**: Check file ownership and permissions
3. **Database connection**: Verify MySQL credentials and connection
4. **Nginx 502 errors**: Check if backend services are running
5. **SSL issues**: Verify domain DNS pointing to your droplet

### Logs
- Nginx: `/var/log/nginx/`
- PM2: `pm2 logs`
- System: `journalctl -f`