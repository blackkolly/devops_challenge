# Flask E-Commerce Implementation Guide

This document provides a complete step-by-step guide to implement and deploy the Flask e-commerce application with CI/CD pipeline.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [Testing](#testing)
4. [Docker Containerization](#docker-containerization)
5. [AWS EC2 Setup](#aws-ec2-setup)
6. [Jenkins CI/CD Setup](#jenkins-cicd-setup)
7. [Deployment](#deployment)
8. [Monitoring and Maintenance](#monitoring-and-maintenance)
9. [Troubleshooting](#troubleshooting)

## Prerequisites

### Local Development
- Python 3.8 or higher
- Git
- Docker (optional for local development)
- Code editor (VS Code recommended)

### AWS Account Requirements
- AWS Account with EC2 access
- Key pair for EC2 instances
- Security groups configured
- Basic understanding of AWS services

### CI/CD Requirements
- GitHub account
- Docker Hub account
- Basic understanding of Jenkins

## Local Development Setup

### 1. Clone and Setup

```bash
# Clone the repository
git clone <your-repository-url>
cd flask-ecommerce

# Make scripts executable
chmod +x scripts/*.sh

# Run setup script
./scripts/setup.sh
```

### 2. Manual Setup (Alternative)

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create environment file
cp .env.example .env

# Edit .env file with your configuration
nano .env

# Initialize database
python -c "from app import init_db; init_db()"

# Run the application
python app.py
```

### 3. Access the Application

Open your browser and navigate to:
- **Application**: http://localhost:5000
- **Health Check**: http://localhost:5000/health
- **API**: http://localhost:5000/api/products

### 4. Default Sample Data

The application comes with sample products:
- Laptop ($999.99)
- Smartphone ($699.99)
- Headphones ($199.99)
- Coffee Mug ($19.99)
- T-Shirt ($29.99)

## Testing

### Run All Tests

```bash
# Activate virtual environment
source venv/bin/activate

# Run tests
pytest tests/ -v

# Run tests with coverage
pytest tests/ -v --cov=app --cov-report=html

# View coverage report
open htmlcov/index.html
```

### Test Categories

1. **Unit Tests** (`test_app.py`)
   - Route testing
   - Authentication
   - Cart functionality
   - Order processing

2. **Database Tests** (`test_database.py`)
   - Database initialization
   - CRUD operations
   - Data integrity

### Expected Test Results

- All tests should pass
- Coverage should be above 80%
- No critical security issues

## Docker Containerization

### 1. Build Docker Image

```bash
# Build image
docker build -t flask-ecommerce:latest .

# Run container
docker run -p 5000:5000 flask-ecommerce:latest
```

### 2. Docker Compose

```bash
# Build and run with Docker Compose
docker-compose up --build

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### 3. Docker Image Optimization

The Dockerfile includes:
- Multi-stage build optimization
- Non-root user for security
- Health checks
- Proper dependency caching

## AWS EC2 Setup

### 1. Launch EC2 Instance

1. **Choose AMI**: Ubuntu Server 20.04 LTS
2. **Instance Type**: t2.micro or t3.small (minimum)
3. **Security Group**: 
   - SSH (22) - Your IP
   - HTTP (80) - 0.0.0.0/0
   - HTTPS (443) - 0.0.0.0/0
   - Custom (5000) - 0.0.0.0/0 (for testing)
4. **Storage**: 8GB minimum
5. **Key Pair**: Create or use existing

### 2. Connect to Instance

```bash
# Connect via SSH
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

### 3. Run EC2 Setup Script

```bash
# Upload and run the setup script
scp -i your-key.pem scripts/setup-ec2.sh ubuntu@your-ec2-public-ip:~/
ssh -i your-key.pem ubuntu@your-ec2-public-ip
chmod +x setup-ec2.sh
./setup-ec2.sh
```

The script will:
- Update system packages
- Install Docker and Docker Compose
- Configure firewall
- Install monitoring tools
- Setup application directories
- Optionally install Jenkins

### 4. Manual EC2 Setup (Alternative)

```bash
# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Reboot to apply changes
sudo reboot
```

## Jenkins CI/CD Setup

### 1. Jenkins Installation on EC2

If you chose to install Jenkins during EC2 setup:

```bash
# Access Jenkins
http://your-ec2-public-ip:8080

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 2. Jenkins Configuration

1. **Install Suggested Plugins**
2. **Create Admin User**
3. **Install Additional Plugins**:
   - Docker Pipeline
   - GitHub Integration
   - Slack Notification
   - HTML Publisher

### 3. Configure Jenkins Pipeline

1. **Create New Pipeline Job**
2. **Configure GitHub Repository**
3. **Set up Webhooks** (optional)
4. **Configure Credentials**:
   - Docker Hub credentials
   - EC2 SSH key
   - GitHub token

### 4. Pipeline Features

The Jenkinsfile includes:
- Code checkout
- Python environment setup
- Linting (flake8)
- Unit testing (pytest)
- Security scanning (bandit, safety)
- Docker image building
- Staging deployment
- Integration testing
- Production deployment
- Automated rollback

### 5. Required Jenkins Credentials

Add these credentials in Jenkins:
- `dockerhub-credentials`: Docker Hub username/password
- `ec2-ssh-key`: EC2 private key
- `github-token`: GitHub personal access token

## Deployment

### 1. Manual Deployment

```bash
# On EC2 instance
cd /opt/flask-ecommerce

# Clone repository
git clone <your-repository-url> .

# Run deployment script
./scripts/deploy.sh
```

### 2. Automated Deployment via Jenkins

1. **Push code to GitHub**
2. **Jenkins pipeline triggers automatically**
3. **Monitor pipeline progress**
4. **Approve production deployment**

### 3. Deployment Verification

```bash
# Health check
curl http://your-ec2-public-ip/health

# Application access
curl http://your-ec2-public-ip/

# API check
curl http://your-ec2-public-ip/api/products
```

### 4. SSL/HTTPS Setup (Optional)

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## Monitoring and Maintenance

### 1. Application Monitoring

```bash
# View application logs
docker logs flask-ecommerce-app -f

# Monitor system resources
htop

# Check application status
curl http://localhost:5000/health
```

### 2. Database Backup

```bash
# Backup database
docker exec flask-ecommerce-app sqlite3 /app/instance/ecommerce.db ".backup /app/instance/backup_$(date +%Y%m%d).db"

# Copy backup to host
docker cp flask-ecommerce-app:/app/instance/backup_$(date +%Y%m%d).db ./
```

### 3. Log Management

```bash
# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# View application logs
docker logs flask-ecommerce-app --tail 100
```

### 4. Updates and Patches

```bash
# Update application
git pull origin main
docker build -t flask-ecommerce:latest .
docker restart flask-ecommerce-app

# Update system packages
sudo apt-get update && sudo apt-get upgrade -y
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Application Won't Start

```bash
# Check container status
docker ps -a

# View container logs
docker logs flask-ecommerce-app

# Check if port is in use
sudo netstat -tulpn | grep :5000
```

#### 2. Database Issues

```bash
# Reset database
docker exec flask-ecommerce-app python -c "from app import init_db; init_db()"

# Check database file
docker exec flask-ecommerce-app ls -la /app/instance/
```

#### 3. Permission Issues

```bash
# Fix ownership
sudo chown -R ubuntu:ubuntu /opt/flask-ecommerce
sudo chown -R ubuntu:ubuntu /var/lib/ecommerce
```

#### 4. Jenkins Pipeline Failures

- Check Jenkins logs
- Verify credentials
- Ensure Docker is running
- Check GitHub webhook configuration

#### 5. Network Issues

```bash
# Check firewall
sudo ufw status

# Test connectivity
curl -I http://localhost:5000
telnet localhost 5000
```

### Performance Optimization

1. **Database Indexing**
   - Add indexes to frequently queried fields
   - Consider PostgreSQL for production

2. **Caching**
   - Implement Redis for session storage
   - Add application-level caching

3. **Load Balancing**
   - Use multiple application instances
   - Configure Nginx load balancing

4. **CDN**
   - Use CloudFront for static assets
   - Optimize image delivery

### Security Checklist

- [ ] Change default secret keys
- [ ] Enable HTTPS/SSL
- [ ] Configure proper firewall rules
- [ ] Regular security updates
- [ ] Monitor application logs
- [ ] Implement rate limiting
- [ ] Add CSRF protection
- [ ] Validate all inputs
- [ ] Use environment variables for secrets

## Conclusion

This implementation provides a complete e-commerce solution with:
- Modern web application framework
- Comprehensive testing
- Containerization
- Automated CI/CD pipeline
- Production-ready deployment
- Monitoring and maintenance tools

The architecture is scalable and can be extended with additional features as needed.

For support and questions, please refer to the README.md or create an issue in the repository.
