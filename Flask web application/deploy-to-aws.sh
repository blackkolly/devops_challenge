#!/bin/bash

# Automated deployment script for Flask E-Commerce to AWS EC2
# Run this script from your local machine

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - UPDATE THESE VALUES
EC2_HOST="13.60.249.80"                    # Your EC2 public IP (e.g., "54.123.45.67")
EC2_USER="ubuntu"              # Default EC2 user for Ubuntu
KEY_PATH="C:/Users/hp/Desktop/AWS/DevOps_Project/e-commerce.pem"                    # Path to your .pem key file (e.g., "~/Downloads/my-key.pem")
APP_DIR="DevOps_Project"       # Directory name on EC2
DOMAIN_NAME=""                 # Your domain name (optional, e.g., "myapp.com")

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if required variables are set
check_config() {
    if [ -z "$EC2_HOST" ]; then
        print_error "EC2_HOST is not set. Please update the configuration section in this script."
        exit 1
    fi
    
    if [ -z "$KEY_PATH" ]; then
        print_error "KEY_PATH is not set. Please update the configuration section in this script."
        exit 1
    fi
    
    if [ ! -f "$KEY_PATH" ]; then
        print_error "Key file not found at $KEY_PATH"
        exit 1
    fi
}

# Function to check if we can connect to EC2
check_connection() {
    print_status "Testing connection to EC2 instance..."
    if ssh -i "$KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_HOST" "echo 'Connection successful'" >/dev/null 2>&1; then
        print_success "Successfully connected to EC2 instance"
    else
        print_error "Cannot connect to EC2 instance. Please check your EC2_HOST and KEY_PATH"
        exit 1
    fi
}

# Function to copy files to EC2
copy_files() {
    print_status "Copying application files to EC2..."
    
    # Create directory on EC2
    ssh -i "$KEY_PATH" "$EC2_USER@$EC2_HOST" "mkdir -p $APP_DIR"
    
    # Check if rsync is available, if not use scp
    if command -v rsync >/dev/null 2>&1; then
        print_status "Using rsync for file transfer..."
        # Copy all files except .git, __pycache__, etc.
        rsync -avz -e "ssh -i $KEY_PATH" \
            --exclude='.git' \
            --exclude='__pycache__' \
            --exclude='*.pyc' \
            --exclude='.pytest_cache' \
            --exclude='htmlcov' \
            --exclude='.coverage' \
            --exclude='ecommerce.db' \
            --exclude='.venv' \
            --exclude='node_modules' \
            ./ "$EC2_USER@$EC2_HOST:$APP_DIR/"
    else
        print_status "Using scp for file transfer (rsync not available)..."
        
        # Create a temporary tar file with excluded files
        print_status "Creating temporary archive..."
        
        # Create a list of files to include
        find . -type f \
            ! -path "./.git/*" \
            ! -path "./__pycache__/*" \
            ! -name "*.pyc" \
            ! -path "./.pytest_cache/*" \
            ! -path "./htmlcov/*" \
            ! -name ".coverage" \
            ! -name "ecommerce.db" \
            ! -path "./.venv/*" \
            ! -path "./node_modules/*" \
            ! -name "deploy-temp.tar.gz" \
            ! -name ".env*" \
            ! -name "*.log" \
            ! -name "*.tmp" \
            > /tmp/file_list.txt 2>/dev/null || true
            
        # Create archive from file list
        if [ -s /tmp/file_list.txt ]; then
            tar -czf deploy-temp.tar.gz -T /tmp/file_list.txt
            rm -f /tmp/file_list.txt
        else
            # Fallback: basic tar with common exclusions
            tar -czf deploy-temp.tar.gz \
                --exclude='.git' \
                --exclude='__pycache__' \
                --exclude='*.pyc' \
                --exclude='.pytest_cache' \
                --exclude='ecommerce.db' \
                . 2>/dev/null || true
        fi
        
        # Copy tar file to EC2
        print_status "Uploading files to EC2..."
        scp -i "$KEY_PATH" deploy-temp.tar.gz "$EC2_USER@$EC2_HOST:~/"
        
        # Extract on EC2 and cleanup
        ssh -i "$KEY_PATH" "$EC2_USER@$EC2_HOST" << ENDSSH
            cd $APP_DIR
            tar -xzf ~/deploy-temp.tar.gz
            rm ~/deploy-temp.tar.gz
            echo "Files extracted successfully"
ENDSSH
        
        # Remove local temp file
        rm -f deploy-temp.tar.gz
        print_status "Temporary files cleaned up"
    fi
    
    print_success "Files copied successfully"
}

# Function to setup EC2 environment
setup_environment() {
    print_status "Setting up EC2 environment..."
    
    ssh -i "$KEY_PATH" "$EC2_USER@$EC2_HOST" << 'ENDSSH'
        # Update system
        sudo apt update
        
        # Install Docker if not installed
        if ! command -v docker &> /dev/null; then
            echo "Installing Docker..."
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo usermod -aG docker ubuntu
            rm get-docker.sh
        fi
        
        # Install Docker Compose if not installed
        if ! command -v docker-compose &> /dev/null; then
            echo "Installing Docker Compose..."
            sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
        fi
        
        # Install Nginx if not installed
        if ! command -v nginx &> /dev/null; then
            echo "Installing Nginx..."
            sudo apt install -y nginx
            sudo systemctl enable nginx
        fi
        
        echo "Environment setup completed"
ENDSSH
    
    print_success "Environment setup completed"
}

# Function to create production environment file
create_env_file() {
    print_status "Creating production environment file..."
    
    # Generate a random secret key
    SECRET_KEY=$(openssl rand -base64 32)
    
    ssh -i "$KEY_PATH" "$EC2_USER@$EC2_HOST" << ENDSSH
        cd $APP_DIR
        cat > .env.production << EOF
FLASK_ENV=production
FLASK_DEBUG=False
SECRET_KEY=$SECRET_KEY
DATABASE_URL=sqlite:///production.db
PORT=5000
DOMAIN=$DOMAIN_NAME
EOF
        echo "Production environment file created"
ENDSSH
    
    print_success "Environment file created with secure secret key"
}

# Function to deploy application
deploy_application() {
    print_status "Deploying application with Docker..."
    
    ssh -i "$KEY_PATH" "$EC2_USER@$EC2_HOST" << ENDSSH
        cd $APP_DIR
        
        # Stop existing containers
        docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
        
        # Stop any conflicting services on port 80
        sudo systemctl stop nginx 2>/dev/null || true
        
        # Load environment variables
        export \$(cat .env.production | xargs)
        
        # Build new image
        docker build -t flask-ecommerce:latest .
        
        # Start application
        docker-compose -f docker-compose.prod.yml up -d
        
        # Wait for application to start
        sleep 15
        
        # Check if application is running
        if curl -f http://localhost:5000/health >/dev/null 2>&1; then
            echo "Application is running successfully"
        else
            echo "Application failed to start, checking logs..."
            docker-compose -f docker-compose.prod.yml logs
            echo "Trying to restart..."
            docker-compose -f docker-compose.prod.yml restart
            sleep 10
            if curl -f http://localhost:5000/health >/dev/null 2>&1; then
                echo "Application restarted successfully"
            else
                echo "Application still failing, manual intervention required"
                exit 1
            fi
        fi
ENDSSH
    
    print_success "Application deployed successfully"
}

# Function to configure Nginx
configure_nginx() {
    print_status "Configuring Nginx..."
    
    # Create Nginx configuration
    NGINX_CONFIG="server {
    listen 8080;
    server_name $DOMAIN_NAME $EC2_HOST;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /static/ {
        alias /home/ubuntu/$APP_DIR/static/;
        expires 30d;
        add_header Cache-Control \"public, no-transform\";
    }
}"

    ssh -i "$KEY_PATH" "$EC2_USER@$EC2_HOST" << ENDSSH
        # Create Nginx configuration
        echo '$NGINX_CONFIG' | sudo tee /etc/nginx/sites-available/flask-ecommerce
        
        # Enable site
        sudo ln -sf /etc/nginx/sites-available/flask-ecommerce /etc/nginx/sites-enabled/
        
        # Remove default site
        sudo rm -f /etc/nginx/sites-enabled/default
        
        # Test configuration
        sudo nginx -t
        
        # Restart Nginx
        sudo systemctl restart nginx
        
        echo "Nginx configured successfully"
ENDSSH
    
    print_success "Nginx configured and restarted"
}

# Function to setup monitoring
setup_monitoring() {
    print_status "Setting up monitoring..."
    
    ssh -i "$KEY_PATH" "$EC2_USER@$EC2_HOST" << 'ENDSSH'
        # Create monitoring script
        cat > ~/monitor.sh << 'EOF'
#!/bin/bash
APP_URL="http://localhost:5000/health"
EXPECTED_STATUS="healthy"

response=$(curl -s $APP_URL | grep -o '"status":"[^"]*"' | cut -d'"' -f4 2>/dev/null)

if [ "$response" = "$EXPECTED_STATUS" ]; then
    echo "$(date): App is healthy"
else
    echo "$(date): App is unhealthy, restarting..."
    cd ~/DevOps_Project
    docker-compose -f docker-compose.prod.yml restart
fi
EOF
        
        chmod +x ~/monitor.sh
        
        # Add to crontab if not already present
        (crontab -l 2>/dev/null | grep -v "monitor.sh"; echo "*/5 * * * * /home/ubuntu/monitor.sh >> /var/log/app-monitor.log 2>&1") | crontab -
        
        echo "Monitoring setup completed"
ENDSSH
    
    print_success "Monitoring script installed and scheduled"
}

# Function to test deployment
test_deployment() {
    print_status "Testing deployment..."
    
    # Test health endpoint
    if curl -f "http://$EC2_HOST:5000/health" >/dev/null 2>&1; then
        print_success "Health check passed"
    else
        print_warning "Health check failed - application might still be starting"
    fi
    
    # Test main page
    if curl -f "http://$EC2_HOST:5000/" >/dev/null 2>&1; then
        print_success "Main page accessible"
    else
        print_warning "Main page not accessible"
    fi
    
    print_success "Deployment testing completed"
}

# Function to show deployment summary
show_summary() {
    echo ""
    echo "=========================================="
    echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉"
    echo "=========================================="
    echo ""
    echo "Your Flask E-Commerce application is now running on:"
    echo "  🌐 Application (Direct): http://$EC2_HOST:5000"
    echo "  🌐 Application (Nginx): http://$EC2_HOST:8080"
    echo "  ❤️  Health Check: http://$EC2_HOST:5000/health"
    echo "  📊 API: http://$EC2_HOST:5000/api/products"
    echo ""
    if [ -n "$DOMAIN_NAME" ]; then
        echo "  🔗 Custom Domain: http://$DOMAIN_NAME (if DNS is configured)"
        echo ""
    fi
    echo "Useful commands to manage your deployment:"
    echo "  🔧 Connect to server: ssh -i \"$KEY_PATH\" $EC2_USER@$EC2_HOST"
    echo "  📄 View logs: docker-compose -f docker-compose.prod.yml logs -f app"
    echo "  🔄 Restart app: docker-compose -f docker-compose.prod.yml restart"
    echo "  🛑 Stop app: docker-compose -f docker-compose.prod.yml down"
    echo ""
    echo "Next steps:"
    echo "  1. Test your application thoroughly"
    echo "  2. Configure SSL certificate (if you have a domain)"
    echo "  3. Setup automated backups"
    echo "  4. Configure monitoring alerts"
    echo ""
    echo "🚀 Your application is ready for production use!"
    echo "=========================================="
}

# Main deployment function
main() {
    echo "🚀 Starting Flask E-Commerce deployment to AWS EC2..."
    echo ""
    
    # Check configuration
    check_config
    
    # Check connection
    check_connection
    
    # Copy files
    copy_files
    
    # Setup environment
    setup_environment
    
    # Create environment file
    create_env_file
    
    # Deploy application
    deploy_application
    
    # Configure Nginx
    configure_nginx
    
    # Setup monitoring
    setup_monitoring
    
    # Test deployment
    test_deployment
    
    # Show summary
    show_summary
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Check if configuration is set
    if [ -z "$EC2_HOST" ] || [ -z "$KEY_PATH" ]; then
        echo "⚠️  CONFIGURATION REQUIRED"
        echo "Please edit this script and set the following variables:"
        echo "  - EC2_HOST: Your EC2 instance public IP"
        echo "  - KEY_PATH: Path to your .pem key file"
        echo "  - DOMAIN_NAME: Your domain name (optional)"
        echo ""
        echo "Example:"
        echo '  EC2_HOST="54.123.45.67"'
        echo '  KEY_PATH="~/Downloads/my-key.pem"'
        echo '  DOMAIN_NAME="myapp.com"'
        exit 1
    fi
    
    main "$@"
fi
