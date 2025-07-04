# 🚀 Flask E-Commerce AWS EC2 Deployment - Step by Step Commands

## 📋 Pre-Deployment Checklist

Before you begin, make sure you have:
- [ ] AWS Account with EC2 access
- [ ] SSH Key Pair downloaded (.pem file)
- [ ] Your Flask E-Commerce project code ready

---

## Step 1: Launch EC2 Instance

### 1.1 Create EC2 Instance via AWS Console

1. **Go to AWS Console** → EC2 Dashboard → "Launch Instance"

2. **Configure Instance**:
   ```
   Name: Flask-Ecommerce-Server
   AMI: Ubuntu Server 22.04 LTS (Free tier eligible)
   Instance Type: t2.micro (free tier) or t3.medium (recommended)
   Key Pair: Create new or select existing
   ```

3. **Security Group Settings**:
   ```
   SSH (22): Your IP
   HTTP (80): Anywhere (0.0.0.0/0)
   HTTPS (443): Anywhere (0.0.0.0/0)
   Custom TCP (5000): Anywhere (0.0.0.0/0) - For Flask app
   Custom TCP (8000): Anywhere (0.0.0.0/0) - For Docker
   ```

4. **Storage**: 20 GB GP2 (default is fine)

5. **Launch Instance**

### 1.2 Get Instance Details

Once launched, note down:
- **Public IP Address**: `54.123.45.67` (example)
- **Key Pair Location**: `~/Downloads/my-key.pem`

---

## Step 2: Connect to EC2 Instance

### 2.1 Set Key Permissions (Linux/Mac)

```bash
# Make key file secure
chmod 400 ~/Downloads/my-key.pem
```

### 2.2 Connect via SSH

```bash
# Connect to your EC2 instance
ssh -i "~/Downloads/my-key.pem" ubuntu@54.123.45.67

# You should see Ubuntu welcome message
```

---

## Step 3: Setup EC2 Environment

### 3.1 Update System

```bash
# Update package lists
sudo apt update && sudo apt upgrade -y

# Install basic utilities
sudo apt install -y curl wget git nano htop
```

### 3.2 Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login to apply group changes
exit
```

### 3.3 Reconnect and Verify

```bash
# Connect again
ssh -i "~/Downloads/my-key.pem" ubuntu@54.123.45.67

# Verify Docker installation
docker --version
docker-compose --version

# Test Docker (should work without sudo)
docker run hello-world
```

---

## Step 4: Deploy Application

### 4.1 Clone Your Repository

```bash
# Clone the project (replace with your repository URL)
git clone https://github.com/your-username/DevOps_Project.git
cd DevOps_Project

# Or if you have the code locally, copy it using SCP:
# scp -i "~/Downloads/my-key.pem" -r /path/to/DevOps_Project ubuntu@54.123.45.67:~/
```

### 4.2 Setup Environment Variables

```bash
# Create production environment file
nano .env.production

# Add the following content:
FLASK_ENV=production
FLASK_DEBUG=False
SECRET_KEY=your-super-secret-production-key-change-this-now
DATABASE_URL=sqlite:///production.db
PORT=5000
DOMAIN=your-domain.com
```

### 4.3 Build and Run Application

```bash
# Build the Docker image
docker build -t flask-ecommerce:latest .

# Run with Docker Compose (production configuration)
docker-compose -f docker-compose.prod.yml up -d

# Check if containers are running
docker-compose -f docker-compose.prod.yml ps

# Check application logs
docker-compose -f docker-compose.prod.yml logs -f app
```

### 4.4 Test Application

```bash
# Test health endpoint
curl http://localhost:5000/health

# Test main page
curl -I http://localhost:5000

# If both return successful responses, your app is running!
```

---

## Step 5: Configure Nginx (Reverse Proxy)

### 5.1 Install Nginx

```bash
# Install Nginx
sudo apt install nginx -y

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 5.2 Configure Nginx

```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/flask-ecommerce

# Add the following configuration:
```

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com 54.123.45.67;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /home/ubuntu/DevOps_Project/static/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
```

### 5.3 Enable Nginx Site

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/flask-ecommerce /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Check Nginx status
sudo systemctl status nginx
```

---

## Step 6: Test Your Deployment

### 6.1 Access Your Application

Open your browser and go to:
- `http://54.123.45.67` (replace with your EC2 public IP)
- You should see your Flask E-Commerce application!

### 6.2 Test All Features

1. **Home Page**: Should load with products
2. **Register**: Create a new user account
3. **Login**: Login with your account
4. **Add to Cart**: Add products to cart
5. **Checkout**: Complete a test order

### 6.3 API Testing

```bash
# Test API endpoints
curl http://54.123.45.67/api/products
curl http://54.123.45.67/health
```

---

## Step 7: Setup SSL (Optional but Recommended)

### 7.1 Get a Domain Name (Optional)

If you have a domain name:
1. Point your domain's A record to your EC2 public IP
2. Wait for DNS propagation (can take up to 24 hours)

### 7.2 Install SSL Certificate

```bash
# Install Certbot
sudo snap install --classic certbot

# Create symlink
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Test automatic renewal
sudo certbot renew --dry-run
```

---

## Step 8: Setup Monitoring and Maintenance

### 8.1 Create Monitoring Script

```bash
# Create monitoring script
nano ~/monitor.sh

# Add this content:
#!/bin/bash
APP_URL="http://localhost:5000/health"
EXPECTED_STATUS="healthy"

response=$(curl -s $APP_URL | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

if [ "$response" = "$EXPECTED_STATUS" ]; then
    echo "$(date): App is healthy"
else
    echo "$(date): App is unhealthy, restarting..."
    cd ~/DevOps_Project
    docker-compose -f docker-compose.prod.yml restart
fi

# Make executable
chmod +x ~/monitor.sh

# Add to crontab (check every 5 minutes)
crontab -e
# Add this line:
# */5 * * * * /home/ubuntu/monitor.sh >> /var/log/app-monitor.log 2>&1
```

### 8.2 Setup Log Rotation

```bash
# View application logs
docker-compose -f docker-compose.prod.yml logs app

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

## Step 9: Backup Strategy

### 9.1 Database Backup

```bash
# Create backup script
nano ~/backup.sh

# Add this content:
#!/bin/bash
BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup database
docker exec flask-ecommerce-app-1 sqlite3 /app/ecommerce.db ".dump" > $BACKUP_DIR/db_backup_$DATE.sql

echo "$(date): Backup completed - db_backup_$DATE.sql"

# Make executable
chmod +x ~/backup.sh

# Test backup
./backup.sh

# Add to crontab for daily backups at 2 AM
crontab -e
# Add this line:
# 0 2 * * * /home/ubuntu/backup.sh >> /var/log/backup.log 2>&1
```

---

## Step 10: Application Updates

### 10.1 Update Application Code

```bash
# Pull latest changes
cd ~/DevOps_Project
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.prod.yml down
docker build -t flask-ecommerce:latest .
docker-compose -f docker-compose.prod.yml up -d

# Check if update was successful
curl http://localhost:5000/health
```

### 10.2 Rollback if Needed

```bash
# If something goes wrong, rollback to previous version
git log --oneline -5  # See recent commits
git checkout <previous-commit-hash>
docker-compose -f docker-compose.prod.yml down
docker build -t flask-ecommerce:latest .
docker-compose -f docker-compose.prod.yml up -d
```

---

## 🎉 Congratulations!

Your Flask E-Commerce application is now running on AWS EC2!

### Access URLs:
- **Application**: `http://your-ec2-ip` or `https://your-domain.com`
- **Health Check**: `http://your-ec2-ip/health`
- **API**: `http://your-ec2-ip/api/products`

### Important Commands to Remember:

```bash
# Check application status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f app

# Restart application
docker-compose -f docker-compose.prod.yml restart

# Stop application
docker-compose -f docker-compose.prod.yml down

# Start application
docker-compose -f docker-compose.prod.yml up -d

# Check Nginx status
sudo systemctl status nginx

# Restart Nginx
sudo systemctl restart nginx
```

### Security Reminders:
1. Change the SECRET_KEY in production
2. Update your security groups to restrict access
3. Regularly update your system: `sudo apt update && sudo apt upgrade`
4. Monitor your logs regularly
5. Set up automated backups

Your Flask E-Commerce application is now live and ready for users! 🚀
