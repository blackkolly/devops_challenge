# Flask E-Commerce DevOps Project - Complete Documentation

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Features](#features)
4. [Technology Stack](#technology-stack)
5. [Project Structure](#project-structure)
6. [Installation & Setup](#installation--setup)
7. [Development Guide](#development-guide)
8. [Testing](#testing)
9. [Docker Deployment](#docker-deployment)
10. [AWS Deployment](#aws-deployment)
11. [CI/CD Pipeline](#cicd-pipeline)
12. [Monitoring & Maintenance](#monitoring--maintenance)
13. [API Documentation](#api-documentation)
14. [Security Considerations](#security-considerations)
15. [Troubleshooting](#troubleshooting)
16. [Contributing](#contributing)

---

## 🚀 Project Overview

This is a **production-ready Flask E-Commerce application** with a complete DevOps pipeline. The project demonstrates modern software development practices including containerization, continuous integration/deployment, cloud deployment, and comprehensive monitoring.

### Key Highlights

- **Full-featured e-commerce platform** with user authentication, product catalog, shopping cart, and order management
- **Complete DevOps pipeline** with Jenkins CI/CD, Docker containerization, and AWS deployment
- **Production-grade security** with proper authentication, input validation, and secure configuration
- **Comprehensive testing** with unit tests, integration tests, and automated validation
- **Real-time monitoring** with health checks, logging, and automated recovery
- **Scalable architecture** designed for cloud deployment and horizontal scaling

---

## 🏗️ Architecture

### High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client Web    │    │   Load Balancer │    │   Application   │
│   Browser       │◄──►│   (Nginx)       │◄──►│   Server        │
└─────────────────┘    └─────────────────┘    │   (Flask)       │
                                               └─────────────────┘
                                                        │
                                               ┌─────────────────┐
                                               │   Database      │
                                               │   (SQLite)      │
                                               └─────────────────┘
```

### Deployment Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │    │   GitHub        │    │   Jenkins       │
│   Local Machine │───►│   Repository    │───►│   CI/CD         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                               ┌─────────────────┐
                                               │   Docker        │
                                               │   Registry      │
                                               └─────────────────┘
                                                        │
                                               ┌─────────────────┐
                                               │   AWS EC2       │
                                               │   Production    │
                                               └─────────────────┘
```

---

## ✨ Features

### E-Commerce Features

- **User Management**

  - User registration and authentication
  - Session management
  - User profile management
  - Secure password handling

- **Product Catalog**

  - Product listing with search and filtering
  - Product detail pages
  - Category-based organization
  - Image management

- **Shopping Cart**

  - Add/remove items from cart
  - Quantity management
  - Session-based cart persistence
  - Cart total calculations

- **Order Management**

  - Checkout process
  - Order confirmation
  - Order history
  - Order status tracking

- **Admin Features**
  - Product management
  - Order management
  - User management
  - System monitoring

### Technical Features

- **RESTful API** for all operations
- **Responsive design** that works on all devices
- **Error handling** with custom error pages
- **Health monitoring** with automated checks
- **Logging** for debugging and monitoring
- **Security** with CSRF protection and input validation

---

## 🛠️ Technology Stack

### Backend

- **Python 3.8+** - Programming language
- **Flask 2.0+** - Web framework
- **SQLAlchemy** - ORM for database operations
- **Flask-Login** - User session management
- **Werkzeug** - WSGI utility library
- **SQLite** - Database (production can use PostgreSQL/MySQL)

### Frontend

- **HTML5** - Markup language
- **CSS3** - Styling with responsive design
- **JavaScript** - Client-side functionality
- **Bootstrap** - CSS framework for responsive design

### DevOps & Infrastructure

- **Docker** - Containerization platform
- **Docker Compose** - Multi-container orchestration
- **Jenkins** - CI/CD automation
- **Nginx** - Reverse proxy and load balancer
- **AWS EC2** - Cloud hosting platform
- **Git** - Version control system

### Development Tools

- **pytest** - Testing framework
- **pytest-cov** - Code coverage reporting
- **Black** - Code formatting
- **Flake8** - Code linting
- **VSCode** - Development environment

---

## 📁 Project Structure

```
flask-web-application/
├── app.py                              # Main Flask application
├── requirements.txt                    # Python dependencies
├── Dockerfile                         # Docker container configuration
├── docker-compose.yml                # Development environment
├── docker-compose.prod.yml           # Production environment
├── Jenkinsfile                       # CI/CD pipeline configuration
├── nginx.conf                        # Nginx configuration
├── .env.example                      # Environment variables template
├── .gitignore                        # Git ignore rules
│
├── templates/                        # HTML templates
│   ├── base.html                    # Base template
│   ├── home.html                    # Homepage
│   ├── products.html                # Product listing
│   ├── product_detail.html          # Product details
│   ├── cart.html                    # Shopping cart
│   ├── checkout.html                # Checkout page
│   ├── login.html                   # User login
│   ├── register.html                # User registration
│   ├── orders.html                  # Order history
│   ├── order_confirmation.html      # Order confirmation
│   ├── 404.html                     # Error page
│   └── 500.html                     # Server error page
│
├── static/                          # Static files
│   ├── css/
│   │   └── style.css               # Custom styles
│   └── js/
│       └── main.js                 # JavaScript functionality
│
├── tests/                           # Test suite
│   ├── conftest.py                 # Test configuration
│   ├── test_app.py                 # Application tests
│   └── test_database.py            # Database tests
│
├── scripts/                         # Deployment scripts
│   ├── deploy.sh                   # Deployment automation
│   ├── setup-ec2.sh               # EC2 setup script
│   ├── setup-dev.sh               # Development setup
│   ├── setup.sh                   # General setup
│   └── rollback.sh                 # Rollback script
│
├── htmlcov/                         # Coverage reports
├── docs/                           # Additional documentation
│   ├── README.md                   # Project overview
│   ├── DEPLOYMENT_GUIDE.md         # Deployment instructions
│   ├── AWS_DEPLOYMENT_GUIDE.md     # AWS-specific deployment
│   ├── QUICK_START.md              # Quick start guide
│   └── IMPLEMENTATION_GUIDE.md     # Implementation details
│
└── deploy-to-aws.sh                 # Automated AWS deployment
```

---

## 🔧 Installation & Setup

### Prerequisites

- **Python 3.8+** installed on your system
- **Git** for version control
- **Docker** and **Docker Compose** (optional, for containerized deployment)
- **AWS CLI** (for cloud deployment)

### Local Development Setup

1. **Clone the Repository**

   ```bash
   git clone https://github.com/blackkolly/devops_projects.git
   cd flask-web-application
   ```

2. **Create Virtual Environment**

   ```bash
   python -m venv .venv

   # Windows
   .venv\Scripts\activate

   # Linux/MacOS
   source .venv/bin/activate
   ```

3. **Install Dependencies**

   ```bash
   pip install -r requirements.txt
   ```

4. **Set Up Environment Variables**

   ```bash
   cp .env.example .env
   # Edit .env file with your configuration
   ```

5. **Initialize Database**

   ```bash
   python app.py
   # Database will be created automatically on first run
   ```

6. **Run the Application**

   ```bash
   python app.py
   ```

   The application will be available at `http://localhost:5000`

### Docker Development Setup

1. **Build and Run with Docker Compose**

   ```bash
   docker-compose up --build
   ```

2. **Run in Development Mode**
   ```bash
   docker-compose -f docker-compose.dev.yml up
   ```

---

## 🧪 Testing

### Running Tests

1. **Install Test Dependencies**

   ```bash
   pip install pytest pytest-cov
   ```

2. **Run All Tests**

   ```bash
   pytest
   ```

3. **Run Tests with Coverage**

   ```bash
   pytest --cov=app --cov-report=html
   ```

4. **View Coverage Report**
   ```bash
   # Open htmlcov/index.html in your browser
   ```

### Test Structure

- **Unit Tests**: Test individual functions and methods
- **Integration Tests**: Test component interactions
- **Functional Tests**: Test complete user workflows
- **API Tests**: Test REST API endpoints

### Test Categories

```python
# Example test file structure
def test_user_registration():
    """Test user registration functionality"""
    pass

def test_product_listing():
    """Test product catalog display"""
    pass

def test_cart_operations():
    """Test shopping cart functionality"""
    pass

def test_order_processing():
    """Test order creation and processing"""
    pass

def test_api_endpoints():
    """Test REST API endpoints"""
    pass
```

---

## 🐳 Docker Deployment

### Development Environment

```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up

# Stop and remove containers
docker-compose -f docker-compose.dev.yml down
```

### Production Environment

```bash
# Build production images
docker-compose -f docker-compose.prod.yml build

# Start production environment
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Stop production environment
docker-compose -f docker-compose.prod.yml down
```

### Docker Configuration Details

**Dockerfile Features:**

- Multi-stage build for optimization
- Non-root user for security
- Health checks for monitoring
- Optimized layer caching

**Docker Compose Features:**

- Environment-specific configurations
- Volume mounts for development
- Network isolation
- Service dependencies

---

## ☁️ AWS Deployment

### Automated Deployment

The project includes an automated deployment script for AWS EC2:

```bash
# Make the script executable
chmod +x deploy-to-aws.sh

# Configure the script with your EC2 details
# Edit the configuration section in deploy-to-aws.sh

# Run the deployment
./deploy-to-aws.sh
```

### Manual Deployment Steps

1. **Launch EC2 Instance**

   - Ubuntu 20.04 LTS or newer
   - t3.micro or larger
   - Security group allowing HTTP (80), HTTPS (443), SSH (22)

2. **Configure EC2 Instance**

   ```bash
   # Connect to your EC2 instance
   ssh -i your-key.pem ubuntu@your-ec2-ip

   # Update system
   sudo apt update && sudo apt upgrade -y

   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker ubuntu

   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. **Deploy Application**

   ```bash
   # Clone repository
   git clone https://github.com/blackkolly/devops_projects.git
   cd flask-web-application

   # Set up environment
   cp .env.example .env.production
   # Edit .env.production with production values

   # Deploy with Docker
   docker-compose -f docker-compose.prod.yml up -d
   ```

### AWS Architecture Details

- **EC2 Instance**: Hosts the application containers
- **Security Groups**: Control network access
- **Elastic IP**: Provides static IP address
- **CloudWatch**: Monitors system metrics
- **EBS Volumes**: Persistent storage for data

---

## 🔄 CI/CD Pipeline

### Jenkins Pipeline Overview

The Jenkins pipeline automates the entire deployment process:

1. **Source Code Management**

   - Pulls latest code from GitHub
   - Triggers on push to main branch

2. **Build Stage**

   - Installs dependencies
   - Runs code quality checks
   - Builds Docker images

3. **Test Stage**

   - Runs unit tests
   - Generates coverage reports
   - Performs security scans

4. **Deploy Stage**

   - Deploys to staging environment
   - Runs integration tests
   - Deploys to production (with approval)

5. **Post-Deployment**
   - Health checks
   - Monitoring setup
   - Notification alerts

### Pipeline Configuration

```groovy
// Example Jenkinsfile stages
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'docker build -t flask-app .'
            }
        }

        stage('Test') {
            steps {
                sh 'pytest --cov=app'
            }
        }

        stage('Deploy') {
            steps {
                sh './deploy-to-aws.sh'
            }
        }
    }
}
```

---

## 📊 Monitoring & Maintenance

### Health Monitoring

The application includes comprehensive health monitoring:

1. **Health Check Endpoint**

   ```
   GET /health
   ```

   Returns system status and database connectivity

2. **Application Metrics**

   - Response times
   - Error rates
   - Database performance
   - Memory usage

3. **Automated Monitoring**
   - Cron job checks health every 5 minutes
   - Automatic restart on failure
   - Log aggregation and analysis

### Logging

```python
# Logging configuration in app.py
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(name)s %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)
```

### Backup Strategy

1. **Database Backups**

   - Daily automated backups
   - Retention policy (30 days)
   - Point-in-time recovery

2. **Application Backups**
   - Version control with Git
   - Docker image versioning
   - Configuration backups

---

## 📡 API Documentation

### Authentication Endpoints

```http
POST /auth/register
Content-Type: application/json

{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "secure_password"
}
```

```http
POST /auth/login
Content-Type: application/json

{
    "username": "john_doe",
    "password": "secure_password"
}
```

### Product Endpoints

```http
GET /api/products
# Returns list of all products

GET /api/products/{id}
# Returns specific product details

POST /api/products
# Creates new product (admin only)

PUT /api/products/{id}
# Updates product (admin only)

DELETE /api/products/{id}
# Deletes product (admin only)
```

### Cart Endpoints

```http
GET /api/cart
# Returns current user's cart

POST /api/cart/add
Content-Type: application/json

{
    "product_id": 1,
    "quantity": 2
}

PUT /api/cart/update
Content-Type: application/json

{
    "product_id": 1,
    "quantity": 3
}

DELETE /api/cart/remove/{product_id}
# Removes item from cart
```

### Order Endpoints

```http
POST /api/orders
Content-Type: application/json

{
    "shipping_address": "123 Main St, City, State 12345",
    "payment_method": "credit_card"
}

GET /api/orders
# Returns user's order history

GET /api/orders/{id}
# Returns specific order details
```

---

## 🔒 Security Considerations

### Security Features Implemented

1. **Authentication & Authorization**

   - Secure password hashing (bcrypt)
   - Session management
   - Role-based access control

2. **Input Validation**

   - SQL injection prevention
   - XSS protection
   - CSRF token validation

3. **Secure Configuration**

   - Environment variable usage
   - Secret key management
   - Secure cookie settings

4. **Infrastructure Security**
   - Firewall configuration
   - SSL/TLS encryption
   - Regular security updates

### Security Best Practices

```python
# Example security configurations
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=1)
```

---

## 🔧 Troubleshooting

### Actual Issues Encountered & Solutions

#### 1. **Database Initialization Issues**

**Problem**: "No such table" errors when accessing the application

```
sqlite3.OperationalError: no such table: user
```

**Root Cause**: Database tables not created on application startup

**Solution Implemented**:

```python
# Added to app.py
def init_db():
    """Initialize database with tables and sample data"""
    with app.app_context():
        db.create_all()

        # Check if tables are empty and populate with sample data
        if User.query.count() == 0:
            create_sample_data()

        logger.info("Database initialized successfully")

# Called in main execution
if __name__ == '__main__':
    init_db()  # Ensure database is initialized
    app.run(debug=False, host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
```

#### 2. **Port Conflicts During Deployment**

**Problem**: Application failing to start due to port conflicts

```
Error: Port 5000 already in use
Error: Port 80 already in use by nginx
```

**Root Cause**: Multiple services trying to use the same ports

**Solution Implemented**:

```bash
# In deploy-to-aws.sh - Added port conflict resolution
# Stop existing containers
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# Stop any conflicting services on port 80
sudo systemctl stop nginx 2>/dev/null || true

# Use different ports for different services
# Flask app: 5000 (internal), 8000 (Docker), 8080 (Nginx proxy)
```

#### 3. **File Organization and Duplicate Folders**

**Problem**: Multiple folders with similar names causing confusion

```
flask web appliation/  (typo - missing 'c')
flask web application/ (correct spelling)
```

**Root Cause**: Typo when creating folder structure

**Solution Implemented**:

```bash
# Moved HTML files from misspelled folder to correct templates directory
mkdir -p "flask web application/templates"
mv "flask web appliation"/*.html "flask web application/templates/"
rmdir "flask web appliation"
```

#### 4. **Git Repository Conflicts**

**Problem**: Git push rejected due to remote conflicts

```
! [rejected] main -> main (fetch first)
error: failed to push some refs to 'https://github.com/blackkolly/devops_projects.git'
hint: Updates were rejected because the remote contains work that you do not have locally
```

**Root Cause**: Remote repository had existing content (devopchalleng folder)

**Solution Implemented**:

```bash
# Pull remote changes first
git pull origin main --allow-unrelated-histories

# Resolve merge conflicts manually
# Then push successfully
git push -u origin main
```

#### 5. **Nested Git Repository Issues**

**Problem**: Git add failing due to nested repository

```
error: 'flask web application/' does not have a commit checked out
fatal: adding files failed
```

**Root Cause**: .git folder existed inside subdirectory

**Solution Implemented**:

```bash
# Remove nested .git repository
rm -rf "flask web application/.git"

# Then add files successfully
git add .
```

#### 6. **Environment Variable and Sensitive File Exposure**

**Problem**: Risk of committing sensitive files like .pem keys and .docx files

**Root Cause**: Inadequate .gitignore configuration

**Solution Implemented**:

```bash
# Enhanced .gitignore with comprehensive exclusions
# AWS
.aws/
*.pem
*.key

# Document files
*.docx
*.doc
*.pdf
~$*.docx
~$*.doc

# Environment variables
.env.*
.env.local
.env.production

# Remove accidentally staged sensitive files
git rm --cached https.docx
git rm --cached .coverage
git rm --cached -r __pycache__/
```

#### 7. **Database File Management**

**Problem**: Database files being committed to Git, causing conflicts

**Root Cause**: Database files not properly excluded

**Solution Implemented**:

```bash
# Added to .gitignore
*.db
*.sqlite
*.sqlite3
ecommerce.db

# For production, create separate database
cat > .env.production << EOF
DATABASE_URL=sqlite:///production.db
EOF
```

#### 8. **Docker File Transfer Issues**

**Problem**: Large file transfers timing out during deployment

**Root Cause**: Inefficient file transfer method

**Solution Implemented**:

```bash
# In deploy-to-aws.sh - Added efficient file transfer with exclusions
if command -v rsync >/dev/null 2>&1; then
    rsync -avz -e "ssh -i $KEY_PATH" \
        --exclude='.git' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='.pytest_cache' \
        --exclude='*.db' \
        --exclude='.venv' \
        ./ "$EC2_USER@$EC2_HOST:$APP_DIR/"
else
    # Fallback to tar with exclusions
    tar -czf deploy-temp.tar.gz \
        --exclude='.git' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='.pytest_cache' \
        --exclude='*.db' \
        .
fi
```

#### 9. **Health Check Implementation Issues**

**Problem**: Application appearing to start but not responding to requests

**Root Cause**: Missing health check endpoints and proper error handling

**Solution Implemented**:

```python
# Added robust health check endpoint
@app.route('/health')
def health_check():
    try:
        # Check database connectivity
        db.session.execute(text('SELECT 1'))
        db.session.commit()

        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'database': 'connected',
            'version': '1.0.0'
        }), 200
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

# Added monitoring script for automated health checks
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
```

#### 10. **Project Structure Reorganization**

**Problem**: Files scattered across multiple directories, making deployment complex

**Root Cause**: Initial project structure not optimized for deployment

**Solution Implemented**:

```bash
# Consolidated all project files into "flask web application" directory
# Moved key folders:
mv htmlcov "flask web application/"
mv scripts "flask web application/"
mv tests "flask web application/"

# Updated deployment scripts to work from single directory
# Simplified Git repository structure
```

### Common Issues & Quick Fixes

1. **Application Won't Start**

   ```bash
   # Check logs
   docker-compose logs app

   # Check port conflicts
   netstat -tulpn | grep :5000
   lsof -i :5000  # On macOS/Linux

   # Kill conflicting processes
   sudo kill -9 $(lsof -t -i:5000)

   # Restart services
   docker-compose restart
   ```

2. **Database Connection Issues**

   ```bash
   # Check database status
   docker-compose exec app python -c "from app import db; db.create_all()"

   # Reset database (development only)
   rm ecommerce.db
   python app.py

   # Check database file permissions
   ls -la *.db
   chmod 664 ecommerce.db
   ```

3. **Permission Errors**

   ```bash
   # Fix script permissions
   chmod +x deploy-to-aws.sh
   chmod +x scripts/*.sh

   # Fix Docker permissions
   sudo usermod -aG docker $USER
   newgrp docker  # Refresh group membership

   # Fix file ownership
   sudo chown -R $USER:$USER .
   ```

4. **Memory and Resource Issues**

   ```bash
   # Check system resources
   free -m
   df -h
   docker system df

   # Clean up Docker resources
   docker system prune -f
   docker volume prune -f
   docker image prune -f

   # Monitor container resource usage
   docker stats
   ```

5. **Network Connectivity Issues**

   ```bash
   # Test AWS EC2 connectivity
   ping your-ec2-ip
   telnet your-ec2-ip 22

   # Check security group settings
   aws ec2 describe-security-groups --group-ids sg-xxxxxxxx

   # Test application endpoints
   curl -I http://your-ec2-ip:5000/health
   curl -I http://your-ec2-ip:8080/
   ```

### Deployment-Specific Troubleshooting

#### AWS EC2 Deployment Issues

1. **SSH Connection Problems**

   ```bash
   # Problem: Permission denied (publickey)
   # Solution: Check key file permissions
   chmod 400 e-commerce.pem

   # Problem: Connection timeout
   # Solution: Check security group rules
   # Ensure port 22 (SSH) is open in security group

   # Problem: Wrong user
   # Solution: Use correct EC2 user
   ssh -i e-commerce.pem ubuntu@your-ec2-ip  # For Ubuntu AMI
   ssh -i e-commerce.pem ec2-user@your-ec2-ip  # For Amazon Linux
   ```

2. **Docker Installation Issues on EC2**

   ```bash
   # Problem: Docker command not found after installation
   # Solution: Logout and login again, or refresh group membership
   sudo usermod -aG docker ubuntu
   newgrp docker

   # Problem: Docker service not starting
   # Solution: Start Docker service
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **Application Deployment Failures**

   ```bash
   # Problem: Container exits immediately
   # Solution: Check application logs
   docker-compose -f docker-compose.prod.yml logs app

   # Problem: Health check failing
   # Solution: Wait for application to fully start
   sleep 15
   curl http://localhost:5000/health

   # Problem: Port 80 already in use
   # Solution: Stop conflicting services
   sudo systemctl stop apache2
   sudo systemctl stop nginx
   ```

#### Git and Version Control Issues

1. **Large File Issues**

   ```bash
   # Problem: Repository size too large
   # Solution: Remove large files from history
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch *.db' \
     --prune-empty --tag-name-filter cat -- --all

   # Problem: .gitignore not working for already tracked files
   # Solution: Remove from tracking first
   git rm --cached filename
   echo "filename" >> .gitignore
   git add .gitignore
   git commit -m "Remove tracked file and update .gitignore"
   ```

2. **Branch Management Issues**

   ```bash
   # Problem: Merge conflicts
   # Solution: Resolve conflicts manually
   git status  # Check conflicted files
   # Edit files to resolve conflicts
   git add .
   git commit -m "Resolve merge conflicts"

   # Problem: Accidental commits
   # Solution: Reset to previous commit
   git reset --soft HEAD~1  # Keep changes staged
   git reset --hard HEAD~1  # Discard changes
   ```

### Environment-Specific Issues

#### Development Environment

```bash
# Problem: Virtual environment activation issues
# Windows
.venv\Scripts\activate  # Use backslashes
# Linux/macOS
source .venv/bin/activate  # Use forward slashes

# Problem: Package installation failures
pip install --upgrade pip  # Upgrade pip first
pip install -r requirements.txt --no-cache-dir

# Problem: Flask app not reloading
export FLASK_ENV=development
export FLASK_DEBUG=1
flask run --reload
```

#### Production Environment

```bash
# Problem: Environment variables not loading
# Solution: Ensure .env.production file exists and is properly formatted
cat > .env.production << EOF
FLASK_ENV=production
FLASK_DEBUG=False
SECRET_KEY=$(openssl rand -base64 32)
DATABASE_URL=sqlite:///production.db
PORT=5000
EOF

# Problem: Static files not serving
# Solution: Configure Nginx properly
sudo nginx -t  # Test configuration
sudo systemctl reload nginx
```

### Monitoring and Maintenance Issues

1. **Application Performance Issues**

   ```bash
   # Problem: High memory usage
   # Solution: Monitor and optimize
   docker stats
   ps aux --sort=-%mem | head

   # Optimize database queries
   # Implement caching
   # Use connection pooling
   ```

2. **Log Management Issues**

   ```bash
   # Problem: Log files growing too large
   # Solution: Implement log rotation
   sudo nano /etc/logrotate.d/flask-app

   # Add log rotation configuration:
   /var/log/flask-app/*.log {
       daily
       rotate 30
       compress
       delaycompress
       missingok
       notifempty
       create 644 root root
   }
   ```

### Quick Diagnostic Commands

```bash
# System health check
df -h                          # Disk usage
free -m                        # Memory usage
top                           # CPU usage
systemctl status docker       # Docker status
docker ps                     # Running containers
docker-compose ps             # Compose services status

# Application health check
curl http://localhost:5000/health     # App health
curl -I http://localhost:5000/        # HTTP headers
netstat -tulpn | grep :5000          # Port status
journalctl -u docker                 # Docker logs

# Network diagnostics
ping google.com               # Internet connectivity
nslookup your-domain.com      # DNS resolution
traceroute your-ec2-ip        # Network path
```

### Emergency Recovery Procedures

1. **Application Crash Recovery**

   ```bash
   # Quick restart
   docker-compose -f docker-compose.prod.yml restart

   # Full rebuild and restart
   docker-compose -f docker-compose.prod.yml down
   docker-compose -f docker-compose.prod.yml up --build -d

   # Rollback to previous version
   ./scripts/rollback.sh
   ```

2. **Database Recovery**

   ```bash
   # Backup current database
   cp ecommerce.db ecommerce.db.backup

   # Restore from backup
   cp ecommerce.db.backup ecommerce.db

   # Reset database (last resort)
   rm ecommerce.db
   python app.py  # Will recreate with sample data
   ```

### Prevention Strategies

1. **Automated Monitoring**

   - Health check endpoint (/health)
   - Cron job monitoring (every 5 minutes)
   - Log aggregation and analysis
   - Resource usage alerts

2. **Backup Strategy**

   - Daily database backups
   - Configuration file backups
   - Docker image versioning
   - Code repository backups

3. **Testing Strategy**
   - Pre-deployment testing
   - Health checks after deployment
   - Integration tests
   - Performance testing

This troubleshooting guide is based on real issues encountered during the development and deployment of this project. Keep this section updated as new issues are discovered and resolved.

---

## 🤝 Contributing

### Development Workflow

1. **Fork the Repository**
2. **Create Feature Branch**

   ```bash
   git checkout -b feature/new-feature
   ```

3. **Make Changes**

   - Follow coding standards
   - Add tests for new features
   - Update documentation

4. **Test Changes**

   ```bash
   pytest
   flake8 app.py
   black app.py
   ```

5. **Submit Pull Request**
   - Describe changes clearly
   - Reference related issues
   - Ensure CI passes

### Coding Standards

- **Python**: Follow PEP 8 style guide
- **HTML**: Use semantic markup
- **CSS**: Follow BEM methodology
- **JavaScript**: Use ES6+ features
- **Documentation**: Write clear, concise docs

### Code Review Process

1. Automated checks (CI/CD)
2. Peer review
3. Security review
4. Performance review
5. Documentation review

---

## 📈 Performance Optimization

### Application Performance

1. **Database Optimization**

   - Index frequently queried columns
   - Optimize query patterns
   - Use connection pooling

2. **Caching Strategy**

   - Implement Redis for session storage
   - Cache frequently accessed data
   - Use CDN for static assets

3. **Code Optimization**
   - Profile application performance
   - Optimize critical paths
   - Minimize database queries

### Infrastructure Performance

1. **Container Optimization**

   - Multi-stage Docker builds
   - Minimize image size
   - Optimize resource allocation

2. **Network Optimization**
   - Use reverse proxy (Nginx)
   - Enable gzip compression
   - Optimize static asset delivery

---

## 🎯 Future Enhancements

### Planned Features

1. **Enhanced Security**

   - Two-factor authentication
   - OAuth integration
   - Advanced threat detection

2. **Scalability Improvements**

   - Kubernetes deployment
   - Microservices architecture
   - Auto-scaling configuration

3. **User Experience**

   - Progressive Web App (PWA)
   - Real-time notifications
   - Advanced search functionality

4. **Analytics & Insights**
   - User behavior tracking
   - Sales analytics dashboard
   - Performance monitoring

### Technical Debt

1. **Code Improvements**

   - Refactor large functions
   - Improve error handling
   - Enhance logging

2. **Infrastructure Upgrades**
   - Move to managed database
   - Implement proper secret management
   - Enhance monitoring stack

---

## 📚 Additional Resources

### Documentation

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

### Tools & Libraries

- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [pytest Documentation](https://docs.pytest.org/)
- [Nginx Documentation](https://nginx.org/en/docs/)

### Best Practices

- [12-Factor App Methodology](https://12factor.net/)
- [DevOps Best Practices](https://aws.amazon.com/devops/what-is-devops/)
- [Security Best Practices](https://owasp.org/www-project-top-ten/)

---

## 📞 Support & Contact

### Getting Help

1. **Documentation**: Check this comprehensive guide first
2. **Issues**: Report bugs and feature requests on GitHub
3. **Discussions**: Join community discussions
4. **Wiki**: Check the project wiki for additional information

### Maintainers

- **Primary Maintainer**: [Your Name]
- **Contributors**: See GitHub contributors page
- **Community**: Active developer community

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flask community for the excellent web framework
- Docker for containerization technology
- AWS for cloud infrastructure
- Jenkins for CI/CD automation
- All contributors who helped improve this project

---

_This documentation is continuously updated. For the latest version, please check the GitHub repository._

**Last Updated**: July 3, 2025
**Version**: 1.0.0
**Status**: Production Ready ✅
