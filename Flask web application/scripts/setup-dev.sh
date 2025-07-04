#!/bin/bash

# Environment Setup Script for Flask E-commerce Application
# This script sets up the development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

log "Setting up Flask E-commerce Development Environment..."

# Check Python version
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    log "Python version: $PYTHON_VERSION"
    
    # Check if Python version is 3.8 or higher
    if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)"; then
        error "Python 3.8 or higher is required"
    fi
else
    error "Python 3 is not installed"
fi

# Create virtual environment
if [ ! -d "venv" ]; then
    log "Creating virtual environment..."
    python3 -m venv venv
else
    log "Virtual environment already exists"
fi

# Activate virtual environment
log "Activating virtual environment..."
source venv/bin/activate || source venv/Scripts/activate

# Upgrade pip
log "Upgrading pip..."
pip install --upgrade pip

# Install dependencies
log "Installing Python dependencies..."
pip install -r requirements.txt

# Install development dependencies
log "Installing development dependencies..."
pip install flake8 black isort pre-commit bandit safety

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    log "Creating environment configuration file..."
    cat > .env << 'EOF'
# Flask Configuration
FLASK_APP=app.py
FLASK_ENV=development
FLASK_DEBUG=1
SECRET_KEY=dev-secret-key-change-in-production

# Database Configuration
DATABASE_URL=sqlite:///ecommerce.db

# Email Configuration (for notifications)
EMAIL_RECIPIENTS=developer@localhost

# Optional: External services
# STRIPE_PUBLISHABLE_KEY=your_stripe_key
# STRIPE_SECRET_KEY=your_stripe_secret
# SMTP_SERVER=smtp.gmail.com
# SMTP_PORT=587
# SMTP_USERNAME=your_email@gmail.com
# SMTP_PASSWORD=your_app_password
EOF
    log "Environment file created: .env"
else
    log "Environment file already exists"
fi

# Initialize database
log "Initializing database..."
python -c "from app import init_db; init_db()"

# Set up pre-commit hooks
log "Setting up pre-commit hooks..."
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
  
  - repo: https://github.com/psf/black
    rev: 23.7.0
    hooks:
      - id: black
        language_version: python3
  
  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: ["--profile", "black"]
  
  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
        args: ["--max-line-length=120", "--ignore=E203,W503"]
  
  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ["-c", "pyproject.toml"]
EOF

pre-commit install

# Create pytest configuration
log "Creating pytest configuration..."
cat > pytest.ini << 'EOF'
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = 
    --verbose
    --tb=short
    --strict-markers
    --disable-warnings
    --cov=app
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=80
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
    unit: marks tests as unit tests
EOF

# Create development configuration
log "Creating development configuration..."
cat > config.py << 'EOF'
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key'
    DATABASE_URL = os.environ.get('DATABASE_URL') or 'sqlite:///ecommerce.db'
    
class DevelopmentConfig(Config):
    DEBUG = True
    TESTING = False

class TestingConfig(Config):
    TESTING = True
    DATABASE_URL = 'sqlite:///:memory:'

class ProductionConfig(Config):
    DEBUG = False
    TESTING = False

config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
EOF

# Create run script
log "Creating run script..."
cat > run.py << 'EOF'
#!/usr/bin/env python3
import os
from app import app, init_db

if __name__ == '__main__':
    # Initialize database
    init_db()
    
    # Run the application
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_DEBUG', 'True').lower() == 'true'
    
    print(f"Starting Flask E-commerce Application...")
    print(f"Environment: {os.environ.get('FLASK_ENV', 'development')}")
    print(f"Debug mode: {debug}")
    print(f"Port: {port}")
    print(f"URL: http://localhost:{port}")
    
    app.run(host='0.0.0.0', port=port, debug=debug)
EOF

chmod +x run.py

# Create Makefile for common tasks
log "Creating Makefile..."
cat > Makefile << 'EOF'
.PHONY: help install run test lint format clean docker-build docker-run

help:  ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install:  ## Install dependencies
	pip install -r requirements.txt
	pip install flake8 black isort pre-commit bandit safety

run:  ## Run the application
	python run.py

test:  ## Run tests
	python -m pytest tests/ -v

test-cov:  ## Run tests with coverage
	python -m pytest tests/ -v --cov=app --cov-report=html --cov-report=term

lint:  ## Run linting
	flake8 app.py tests/
	bandit -r . -f json || true
	safety check || true

format:  ## Format code
	black .
	isort .

clean:  ## Clean up temporary files
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf .coverage htmlcov/ .pytest_cache/
	docker system prune -f

docker-build:  ## Build Docker image
	docker build -t flask-ecommerce .

docker-run:  ## Run Docker container
	docker run -d --name flask-ecommerce-dev -p 5000:5000 flask-ecommerce

docker-stop:  ## Stop Docker container
	docker stop flask-ecommerce-dev && docker rm flask-ecommerce-dev

init-db:  ## Initialize database
	python -c "from app import init_db; init_db()"

dev-setup:  ## Complete development setup
	make install
	make init-db
	pre-commit install
	@echo "Development environment setup complete!"
	@echo "Run 'make run' to start the application"
EOF

# Make scripts executable
chmod +x scripts/*.sh

log "Development environment setup completed successfully!"
info "To get started:"
info "1. Activate the virtual environment: source venv/bin/activate (Linux/Mac) or venv\\Scripts\\activate (Windows)"
info "2. Run the application: python run.py"
info "3. Or use make commands: make run"
info "4. Visit: http://localhost:5000"
info ""
info "Available make commands:"
info "- make run      : Start the application"
info "- make test     : Run tests"
info "- make lint     : Run code linting"
info "- make format   : Format code"
info "- make clean    : Clean temporary files"
info ""
info "Environment file created: .env (modify as needed)"
info "Database will be created automatically on first run"
