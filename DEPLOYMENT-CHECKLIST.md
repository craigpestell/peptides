# PepShop Deployment Checklist

## Pre-Deployment Setup

### 1. Domain Configuration
- [ ] Purchase domain name
- [ ] Point domain DNS to your DigitalOcean droplet IP
- [ ] Configure subdomains (api.yourdomain.com) if using subdomain approach

### 2. DigitalOcean Droplet Setup
- [ ] Create Ubuntu 20.04+ droplet (minimum 2GB RAM)
- [ ] Add SSH key during creation
- [ ] Note down the droplet IP address
- [ ] Enable backups (recommended)

## Environment Variables Setup

### Backend (.env.production)
- [ ] Update MySQL credentials
- [ ] Add Stripe API keys
- [ ] Add Resend API key for emails
- [ ] Add OpenAI API key (if using AI features)
- [ ] Set correct CORS_ORIGIN to your frontend domain

### Frontend (.env.production)
- [ ] Update NEXT_PUBLIC_API_BASE_URL to your API domain
- [ ] Set NEXT_PUBLIC_SITE_URL to your main domain
- [ ] Add Google Analytics ID (optional)

## Deployment Steps

### 1. Initial Server Setup
```bash
# Connect to your droplet
ssh root@YOUR_DROPLET_IP

# Run the deployment script
./deploy.sh
# Choose option 1 for full deployment
```

### 2. Manual Configuration
```bash
# Secure MySQL installation
mysql_secure_installation

# Update environment files with real values
nano /var/www/pepshop/pepshop-admin/.env.production
nano /var/www/pepshop/pepshop-frontend/.env.production
```

### 3. SSL Certificate Setup
```bash
# Install SSL certificates (update domains)
certbot --nginx -d yourdomain.com -d www.yourdomain.com -d api.yourdomain.com
```

### 4. Start Applications
```bash
cd /var/www/pepshop
pm2 start ecosystem.config.js
pm2 save
pm2 startup  # Follow the instructions shown
```

## Post-Deployment Verification

### 1. Test Applications
- [ ] Frontend accessible at https://yourdomain.com
- [ ] Backend API accessible at https://api.yourdomain.com/api
- [ ] Admin dashboard accessible at https://api.yourdomain.com/dashboard

### 2. Check Services
```bash
# Check PM2 processes
pm2 status

# Check Nginx status
systemctl status nginx

# Check MySQL status
systemctl status mysql

# View application logs
pm2 logs
```

### 3. Test Functionality
- [ ] Product catalog loads correctly
- [ ] Shopping cart works
- [ ] API endpoints respond correctly
- [ ] SSL certificates are working
- [ ] Admin dashboard is accessible

## Monitoring and Maintenance

### Regular Tasks
- [ ] Monitor disk space: `df -h`
- [ ] Check application logs: `pm2 logs`
- [ ] Update applications: `git pull && npm install && pm2 restart all`
- [ ] Renew SSL certificates: `certbot renew` (automatic with cron)
- [ ] Update system packages: `apt update && apt upgrade`

### Backup Strategy
- [ ] Database backups: Setup automated MySQL dumps
- [ ] File backups: Include uploads and configuration files
- [ ] DigitalOcean snapshots: Weekly droplet snapshots

### Security
- [ ] Regular security updates
- [ ] Monitor access logs: `/var/log/nginx/access.log`
- [ ] Check for failed login attempts
- [ ] Keep dependencies updated

## Troubleshooting

### Common Issues
1. **502 Bad Gateway**: Check if backend is running (`pm2 status`)
2. **SSL Certificate Issues**: Check certificate validity (`certbot certificates`)
3. **Database Connection**: Verify MySQL service and credentials
4. **Permission Errors**: Check file ownership (`chown -R www-data:www-data`)
5. **Memory Issues**: Monitor with `htop` and consider upgrading droplet

### Useful Commands
```bash
# Restart all services
pm2 restart all && systemctl reload nginx

# Check Nginx configuration
nginx -t

# View real-time logs
pm2 logs --lines 50

# Check disk usage
du -sh /var/www/pepshop

# Check memory usage
free -h
```

## Contact Information
- [ ] Document server credentials securely
- [ ] Note database passwords
- [ ] Save API keys in secure location
- [ ] Document any custom configurations