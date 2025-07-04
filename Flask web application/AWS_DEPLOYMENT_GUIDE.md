# 🚀 AWS EC2 Deployment Guide for Flask E-Commerce Application

## Prerequisites

Before deploying to AWS, ensure you have:

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **SSH Key Pair** created in your target AWS region
4. **Docker** installed locally (for testing)
5. **Git repository** with your code

## Step 1: Setup AWS Infrastructure

### 1.1 Create EC2 Instance

1. **Launch EC2 Instance**:
   - Go to AWS Console → EC2 → Launch Instance
   - Choose **Ubuntu Server 22.04 LTS (x64)**
   - Instance type: **t3.medium** (recommended for production)
   - Key pair: Select or create a new key pair
   - Security group: Create with the following rules:

```bash
# Security Group Rules
Type            Protocol    Port Range    Source
SSH             TCP         22           Your IP
HTTP            TCP         80           0.0.0.0/0
HTTPS           TCP         443          0.0.0.0/0
Custom TCP      TCP         5000         0.0.0.0/0  (for development)
Custom TCP      TCP         8000         0.0.0.0/0  (for Docker)
```

2. **Allocate Elastic IP** (Optional but recommended):
   - Go to EC2 → Elastic IPs
   - Allocate new address
   - Associate with your instance

### 1.2 Configure Domain (Optional)

If you have a domain name:
1. Point your domain's A record to your Elastic IP
2. Update the deployment scripts with your domain name

## Step 2: Prepare Local Environment

### 2.1 Update Deployment Configuration

1. **Edit the deployment script** with your AWS details:

```bash
# Edit scripts/deploy.sh
nano scripts/deploy.sh

# Update these variables:
EC2_HOST="your-ec2-public-ip"
EC2_USER="ubuntu"
KEY_PATH="path/to/your/key.pem"
DOMAIN_NAME="your-domain.com"  # Optional
```

2. **Set environment variables** (create `.env.production`):

```bash
# Create production environment file
cat > .env.production << EOF
FLASK_ENV=production
FLASK_DEBUG=False
SECRET_KEY=your-super-secret-production-key-change-this
DATABASE_URL=sqlite:///production.db
PORT=5000
EOF
```

## Step 3: Deploy to AWS EC2

### 3.1 Automated Deployment (Recommended)

Use the provided deployment script:

```bash
# Make the script executable
chmod +x scripts/deploy.sh

# Run deployment
./scripts/deploy.sh
```

### 3.2 Manual Deployment Steps

If you prefer manual deployment:

#### Step 3.2.1: Connect to EC2 Instance

```bash
# Connect via SSH
ssh -i "your-key.pem" ubuntu@your-ec2-public-ip
```

#### Step 3.2.2: Install Dependencies on EC2

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y docker.io docker-compose nginx git python3 python3-pip

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Logout and login again to apply group changes
exit
ssh -i "your-key.pem" ubuntu@your-ec2-public-ip
```

#### Step 3.2.3: Clone and Setup Application

```bash
# Clone your repository
git clone https://github.com/your-username/your-repo.git
cd your-repo

# Create production environment file
sudo nano .env.production
# Add your production environment variables

# Build and run with Docker Compose
docker-compose -f docker-compose.prod.yml up -d
```

#### Step 3.2.4: Configure Nginx

```bash
# Copy nginx configuration
sudo cp nginx.conf /etc/nginx/sites-available/flask-ecommerce

# Enable the site
sudo ln -s /etc/nginx/sites-available/flask-ecommerce /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
```

## Step 4: SSL/HTTPS Setup (Recommended)

### 4.1 Install Certbot

```bash
# Install snapd
sudo apt install snapd

# Install certbot
sudo snap install --classic certbot

# Create symlink
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

### 4.2 Obtain SSL Certificate

```bash
# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Test automatic renewal
sudo certbot renew --dry-run
```

## Step 5: Configure CI/CD with Jenkins (Optional)

### 5.1 Install Jenkins on EC2

```bash
# Install Java
sudo apt install openjdk-11-jdk -y

# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Install Jenkins
sudo apt update
sudo apt install jenkins -y

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 5.2 Configure Jenkins Pipeline

1. Access Jenkins at `http://your-ec2-ip:8080`
2. Setup admin user and install suggested plugins
3. Create new pipeline job
4. Point to your Jenkinsfile in the repository
5. Configure webhook for automatic deployments

## Step 6: Monitoring and Maintenance

### 6.1 Setup Application Monitoring

```bash
# Check application status
docker-compose -f docker-compose.prod.yml ps

# View application logs
docker-compose -f docker-compose.prod.yml logs -f app

# Check nginx status
sudo systemctl status nginx

# Check nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 6.2 Setup Health Checks

Create a monitoring script:

```bash
# Create monitoring script
cat > /home/ubuntu/monitor.sh << 'EOF'
#!/bin/bash
APP_URL="http://localhost:5000/health"
EXPECTED_STATUS="healthy"

response=$(curl -s $APP_URL | jq -r '.status' 2>/dev/null)

if [ "$response" = "$EXPECTED_STATUS" ]; then
    echo "$(date): App is healthy"
else
    echo "$(date): App is unhealthy, restarting..."
    cd /home/ubuntu/your-repo
    docker-compose -f docker-compose.prod.yml restart
fi
EOF

# Make executable
chmod +x /home/ubuntu/monitor.sh

# Add to crontab (check every 5 minutes)
echo "*/5 * * * * /home/ubuntu/monitor.sh >> /var/log/app-monitor.log 2>&1" | crontab -
```

## Step 7: Backup Strategy

### 7.1 Database Backup

```bash
# Create backup script
cat > /home/ubuntu/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup database
docker exec flask-ecommerce_app_1 sqlite3 /app/ecommerce.db ".dump" > $BACKUP_DIR/db_backup_$DATE.sql

# Keep only last 7 days of backups
find $BACKUP_DIR -name "db_backup_*.sql" -mtime +7 -delete

echo "$(date): Backup completed - db_backup_$DATE.sql"
EOF

# Make executable
chmod +x /home/ubuntu/backup.sh

# Add to crontab (daily backup at 2 AM)
echo "0 2 * * * /home/ubuntu/backup.sh >> /var/log/backup.log 2>&1" | crontab -
```

## Step 8: Security Hardening

### 8.1 Firewall Configuration

```bash
# Enable UFW firewall
sudo ufw enable

# Allow required ports
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check firewall status
sudo ufw status
```

### 8.2 Update Security Groups

In AWS Console, update your security group to:
- Remove port 5000 and 8000 from public access (only allow through nginx)
- Restrict SSH access to your IP only

## Step 9: Testing Deployment

### 9.1 Functional Testing

```bash
# Test application endpoints
curl -I http://your-domain.com
curl -I http://your-domain.com/health
curl -I http://your-domain.com/api/products

# Test HTTPS (if configured)
curl -I https://your-domain.com
```

### 9.2 Performance Testing

```bash
# Install Apache Bench
sudo apt install apache2-utils -y

# Test performance
ab -n 100 -c 10 http://your-domain.com/
```

## Step 10: Rollback Procedure

If something goes wrong:

```bash
# Use the rollback script
./scripts/rollback.sh

# Or manual rollback
cd /home/ubuntu/your-repo
docker-compose -f docker-compose.prod.yml down
git checkout previous-working-commit
docker-compose -f docker-compose.prod.yml up -d
```

## Common Issues and Troubleshooting

### Issue 1: Application Not Starting

```bash
# Check Docker logs
docker-compose -f docker-compose.prod.yml logs app

# Check if port is in use
sudo netstat -tulpn | grep :5000

# Restart application
docker-compose -f docker-compose.prod.yml restart
```

### Issue 2: Nginx Error 502

```bash
# Check nginx configuration
sudo nginx -t

# Check if application is running
curl http://localhost:5000/health

# Restart nginx
sudo systemctl restart nginx
```

### Issue 3: SSL Certificate Issues

```bash
# Check certificate status
sudo certbot certificates

# Renew certificate
sudo certbot renew

# Restart nginx
sudo systemctl restart nginx
```

## Costs Estimation

**Monthly AWS costs (approximate)**:
- t3.medium EC2 instance: $30-40/month
- Elastic IP: $3.65/month (if not attached)
- EBS storage (20GB): $2/month
- Data transfer: Variable

**Total estimated cost**: $35-45/month

## Next Steps

1. **Domain Setup**: Configure your custom domain
2. **CDN**: Setup CloudFront for better performance
3. **Database**: Migrate to RDS for production scalability
4. **Load Balancer**: Setup Application Load Balancer for high availability
5. **Auto Scaling**: Configure auto-scaling groups
6. **Monitoring**: Setup CloudWatch alarms

---

## Quick Deployment Checklist

- [ ] EC2 instance launched with proper security groups
- [ ] SSH key pair created and accessible
- [ ] Domain name configured (optional)
- [ ] Local deployment script updated with EC2 details
- [ ] Production environment variables configured
- [ ] Application deployed and running
- [ ] Nginx configured and running
- [ ] SSL certificate installed (if using domain)
- [ ] Health checks working
- [ ] Backup strategy implemented
- [ ] Monitoring setup
- [ ] Security hardening completed

Your Flask E-Commerce application is now ready for production on AWS EC2! 🚀
