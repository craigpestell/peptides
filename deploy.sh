#!/bin/bash

# PepShop Deployment Script for DigitalOcean
# This script automates the deployment process

set -e  # Exit on any error

# Configuration
APP_DIR="/var/www/pepshop"
DOMAIN="pepshop.ca"  # Update this with your actual domain
API_DOMAIN="api.pepshop.ca"  # Update this with your actual API domain
BACKEND_DIR="$APP_DIR/pepshop-admin"
FRONTEND_DIR="$APP_DIR/pepshop-frontend"

echo "🚀 Starting PepShop deployment..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)"
  exit 1
fi

# Create application directory
echo "📁 Creating application directory..."
mkdir -p $APP_DIR
mkdir -p $APP_DIR/logs
cd $APP_DIR

# Function to install dependencies
install_dependencies() {
    echo "📦 Installing system dependencies..."
    
    # Update system
    apt update && apt upgrade -y
    
    # Install Node.js 18
    # curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    # apt-get install -y nodejs
    
    # Install other dependencies
    # apt install -y nginx mysql-server git ufw
    
    # Install PM2 globally
    # npm install -g pm2
    
    echo "✅ Dependencies installed successfully"
}

# Function to setup MySQL
setup_mysql() {
    echo "🗄️ Setting up MySQL database..."
    
    # Secure MySQL installation (you'll need to run this manually)
    echo "⚠️ Please run 'mysql_secure_installation' manually after this script"
    
    # Create database and user
    mysql -u root -p << EOF
CREATE DATABASE IF NOT EXISTS pepshop_db;
CREATE USER IF NOT EXISTS 'pepshop_user'@'localhost' IDENTIFIED BY 'secure_password_here';
GRANT ALL PRIVILEGES ON pepshop_db.* TO 'pepshop_user'@'localhost';
FLUSH PRIVILEGES;
EOF
    
    echo "✅ MySQL database setup completed"
}

# Function to deploy applications
deploy_applications() {
    echo "🔧 Deploying applications..."
    
    # Deploy backend
    if [ -d "$BACKEND_DIR" ]; then
        echo "📡 Updating backend..."
        cd $BACKEND_DIR
        git pull origin main  # Adjust branch name as needed
    else
        echo "📡 Cloning backend..."
        git clone YOUR_BACKEND_REPO_URL $BACKEND_DIR
        cd $BACKEND_DIR
    fi
    
    npm install --production
    
    # Copy production environment file
    if [ ! -f ".env.production" ]; then
        echo "⚠️ Creating .env.production file..."
        cp .env.production.example .env.production 2>/dev/null || echo "Please create .env.production manually"
    fi
    
    # Deploy frontend
    if [ -d "$FRONTEND_DIR" ]; then
        echo "🖥️ Updating frontend..."
        cd $FRONTEND_DIR
        git pull origin main  # Adjust branch name as needed
    else
        echo "🖥️ Cloning frontend..."
        git clone YOUR_FRONTEND_REPO_URL $FRONTEND_DIR
        cd $FRONTEND_DIR
    fi
    
    npm install
    
    # Copy production environment file
    if [ ! -f ".env.production" ]; then
        echo "⚠️ Creating .env.production file..."
        cp .env.production.example .env.production 2>/dev/null || echo "Please create .env.production manually"
    fi
    
    # Build frontend
    npm run build
    
    echo "✅ Applications deployed successfully"
}

# Function to configure Nginx
configure_nginx() {
    echo "🌐 Configuring Nginx..."
    
    # Remove default site
    rm -f /etc/nginx/sites-enabled/default
    
    # Copy Nginx configuration
    cp $APP_DIR/nginx-subdomain.conf /etc/nginx/sites-available/pepshop
    
    # Update domain names in config
    sed -i "s/pepshop.ca/$DOMAIN/g" /etc/nginx/sites-available/pepshop
    sed -i "s/api.pepshop.ca/$API_DOMAIN/g" /etc/nginx/sites-available/pepshop
    
    # Enable site
    ln -sf /etc/nginx/sites-available/pepshop /etc/nginx/sites-enabled/
    
    # Test Nginx configuration
    nginx -t
    
    # Reload Nginx
    systemctl reload nginx
    
    echo "✅ Nginx configured successfully"
}

# Function to setup PM2
setup_pm2() {
    echo "⚙️ Setting up PM2..."
    
    cd $APP_DIR
    
    # Stop any existing processes
    pm2 delete all 2>/dev/null || true
    
    # Start applications using ecosystem file
    pm2 start ecosystem.config.js
    
    # Save PM2 configuration
    pm2 save
    
    # Setup PM2 startup script
    pm2 startup
    echo "⚠️ Please run the startup command shown above to enable PM2 on system boot"
    
    echo "✅ PM2 setup completed"
}

# Function to setup SSL
setup_ssl() {
    echo "🔒 Setting up SSL certificates..."
    
    # Install Certbot
    apt install -y certbot python3-certbot-nginx
    
    # Get SSL certificates
    certbot --nginx -d $DOMAIN -d www.$DOMAIN -d $API_DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
    
    echo "✅ SSL certificates installed"
}

# Function to setup firewall
setup_firewall() {
    echo "🔥 Configuring firewall..."
    
    # Configure UFW
    ufw allow OpenSSH
    ufw allow 'Nginx Full'
    ufw --force enable
    
    echo "✅ Firewall configured"
}

# Main deployment function
main() {
    echo "🎯 Choose deployment option:"
    echo "1) Full deployment (new server)"
    echo "2) Update applications only"
    echo "3) Update Nginx configuration only"
    echo "4) Setup SSL only"
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            install_dependencies
            deploy_applications
            configure_nginx
            setup_pm2
            setup_firewall
            echo "⚠️ Manual steps required:"
            echo "1. Run 'mysql_secure_installation'"
            echo "2. Update .env.production files with your actual values"
            echo "3. Run 'setup_ssl' function for SSL certificates"
            echo "4. Run the PM2 startup command shown above"
            ;;
        2)
            deploy_applications
            cd $APP_DIR
            pm2 restart all
            ;;
        3)
            configure_nginx
            ;;
        4)
            setup_ssl
            ;;
        *)
            echo "❌ Invalid choice"
            exit 1
            ;;
    esac
    
    echo "🎉 Deployment completed!"
    echo "🌐 Frontend: https://$DOMAIN"
    echo "📡 Backend API: https://$API_DOMAIN"
    echo "🛠️ Admin Dashboard: https://$API_DOMAIN/dashboard"
}

# Run main function
main
