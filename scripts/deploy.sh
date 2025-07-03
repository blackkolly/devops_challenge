#!/bin/bash

# Deployment script for AWS EC2
# Run this script on your EC2 instance

set -e

echo "🚀 Deploying Flask E-Commerce to AWS EC2"

# Configuration
APP_NAME="flask-ecommerce"
DOCKER_IMAGE="flask-ecommerce:latest"
CONTAINER_NAME="flask-ecommerce-app"
PORT="5000"
VOLUME_PATH="/var/lib/ecommerce"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "✅ Docker installed. Please log out and log back in to use Docker without sudo."
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
fi

# Create application directory
APP_DIR="/opt/$APP_NAME"
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# Create data directory
sudo mkdir -p $VOLUME_PATH
sudo chown $USER:$USER $VOLUME_PATH

# Pull latest code (if using git)
if [ -d "$APP_DIR/.git" ]; then
    echo "🔄 Updating application code..."
    cd $APP_DIR
    git pull origin main
else
    echo "📥 This script assumes the code is already present in $APP_DIR"
    echo "   Please ensure your application files are in $APP_DIR"
fi

cd $APP_DIR

# Build Docker image
echo "🏗️ Building Docker image..."
docker build -t $DOCKER_IMAGE .

# Stop existing container
echo "🛑 Stopping existing container..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

# Start new container
echo "🚀 Starting new container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:5000 \
    --restart unless-stopped \
    -v $VOLUME_PATH:/app/instance \
    -e SECRET_KEY="$(openssl rand -hex 32)" \
    -e FLASK_ENV=production \
    $DOCKER_IMAGE

# Wait for container to start
echo "⏳ Waiting for application to start..."
sleep 10

# Health check
echo "🏥 Performing health check..."
if curl -f http://localhost:$PORT/health; then
    echo "✅ Application is healthy and running!"
    echo "🌐 Application is available at: http://$(curl -s http://checkip.amazonaws.com):$PORT"
else
    echo "❌ Health check failed!"
    echo "📋 Container logs:"
    docker logs $CONTAINER_NAME --tail 50
    exit 1
fi

# Setup Nginx (optional)
read -p "Do you want to setup Nginx reverse proxy? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📦 Installing Nginx..."
    sudo apt-get update
    sudo apt-get install -y nginx
    
    # Create Nginx configuration
    sudo tee /etc/nginx/sites-available/$APP_NAME > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /static/ {
        proxy_pass http://localhost:$PORT;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF
    
    # Enable site
    sudo ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test and reload Nginx
    sudo nginx -t && sudo systemctl reload nginx
    echo "✅ Nginx configured and reloaded"
    echo "🌐 Application is now available at: http://$(curl -s http://checkip.amazonaws.com)"
fi

# Setup systemd service for auto-start
read -p "Do you want to create a systemd service for auto-start? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo tee /etc/systemd/system/$APP_NAME.service > /dev/null <<EOF
[Unit]
Description=Flask E-Commerce Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start $CONTAINER_NAME
ExecStop=/usr/bin/docker stop $CONTAINER_NAME
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable $APP_NAME
    echo "✅ Systemd service created and enabled"
fi

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📊 Deployment Summary:"
echo "  - Application: $APP_NAME"
echo "  - Container: $CONTAINER_NAME"
echo "  - Port: $PORT"
echo "  - Data Volume: $VOLUME_PATH"
echo ""
echo "🔧 Management Commands:"
echo "  - View logs: docker logs $CONTAINER_NAME"
echo "  - Restart app: docker restart $CONTAINER_NAME"
echo "  - Stop app: docker stop $CONTAINER_NAME"
echo "  - Update app: ./deploy.sh"
echo ""
echo "Happy deploying! 🚀"
