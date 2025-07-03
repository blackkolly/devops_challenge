#!/bin/bash

# AWS EC2 Instance Setup Script
# Run this script on a fresh Ubuntu 20.04 EC2 instance

set -e

echo "🚀 Setting up AWS EC2 instance for Flask E-Commerce"

# Update system packages
echo "📦 Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install essential packages
echo "📦 Installing essential packages..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw \
    htop \
    tree \
    vim

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 5000
sudo ufw --force enable

# Install Docker
echo "🐳 Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
echo "📦 Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Python and pip (for running scripts)
echo "🐍 Installing Python..."
sudo apt-get install -y python3 python3-pip python3-venv

# Install AWS CLI
echo "☁️ Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# Install Node.js (for any future frontend needs)
echo "📗 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Create application user
echo "👤 Creating application user..."
sudo useradd -m -s /bin/bash appuser || true
sudo usermod -aG docker appuser

# Create application directories
echo "📁 Creating application directories..."
sudo mkdir -p /opt/flask-ecommerce
sudo mkdir -p /var/lib/ecommerce
sudo chown appuser:appuser /opt/flask-ecommerce
sudo chown appuser:appuser /var/lib/ecommerce

# Install Jenkins (optional)
read -p "Do you want to install Jenkins for CI/CD? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔧 Installing Jenkins..."
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt-get update -y
    sudo apt-get install -y openjdk-11-jdk jenkins
    
    # Add jenkins user to docker group
    sudo usermod -aG docker jenkins
    
    # Start Jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    
    echo "✅ Jenkins installed and started"
    echo "🔑 Jenkins initial admin password:"
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    echo "🌐 Access Jenkins at: http://$(curl -s http://checkip.amazonaws.com):8080"
fi

# Install monitoring tools
echo "📊 Installing monitoring tools..."
sudo apt-get install -y htop iotop nethogs

# Setup log rotation
echo "📝 Setting up log rotation..."
sudo tee /etc/logrotate.d/flask-ecommerce > /dev/null <<EOF
/var/log/flask-ecommerce/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 appuser appuser
}
EOF

# Create monitoring script
echo "📊 Creating monitoring script..."
sudo tee /usr/local/bin/monitor-app.sh > /dev/null <<'EOF'
#!/bin/bash
echo "=== System Information ==="
echo "Date: $(date)"
echo "Uptime: $(uptime)"
echo "Load Average: $(cat /proc/loadavg)"
echo ""

echo "=== Memory Usage ==="
free -h
echo ""

echo "=== Disk Usage ==="
df -h
echo ""

echo "=== Docker Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "=== Application Health ==="
if curl -f http://localhost:5000/health &>/dev/null; then
    echo "✅ Application is healthy"
else
    echo "❌ Application health check failed"
fi
EOF

sudo chmod +x /usr/local/bin/monitor-app.sh

# Setup cron job for monitoring
echo "⏰ Setting up monitoring cron job..."
echo "*/5 * * * * /usr/local/bin/monitor-app.sh >> /var/log/monitor.log 2>&1" | sudo tee -a /etc/crontab

# Create useful aliases
echo "🔧 Creating useful aliases..."
cat >> ~/.bashrc << 'EOF'

# Flask E-Commerce aliases
alias app-logs='docker logs flask-ecommerce-app -f'
alias app-restart='docker restart flask-ecommerce-app'
alias app-status='docker ps | grep flask-ecommerce'
alias app-monitor='/usr/local/bin/monitor-app.sh'
alias app-update='cd /opt/flask-ecommerce && git pull && docker build -t flask-ecommerce:latest . && docker restart flask-ecommerce-app'
EOF

# Setup automatic security updates
echo "🔒 Setting up automatic security updates..."
sudo apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "false";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades

# Clean up
echo "🧹 Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get autoclean

echo ""
echo "🎉 AWS EC2 setup completed successfully!"
echo ""
echo "📋 Setup Summary:"
echo "  - Docker and Docker Compose installed"
echo "  - Python 3 and pip installed"
echo "  - AWS CLI installed"
echo "  - Firewall configured (ports 22, 80, 443, 5000 open)"
echo "  - Application directories created"
echo "  - Monitoring tools installed"
echo ""
echo "🔄 Next Steps:"
echo "  1. Log out and log back in to use Docker without sudo"
echo "  2. Clone your application repository to /opt/flask-ecommerce"
echo "  3. Run the deployment script: ./scripts/deploy.sh"
echo ""
echo "📊 Useful Commands:"
echo "  - Monitor application: app-monitor"
echo "  - View logs: app-logs"
echo "  - Restart app: app-restart"
echo "  - Check status: app-status"
echo ""
echo "Happy deploying! 🚀"
