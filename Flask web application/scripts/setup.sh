#!/bin/bash

# Setup script for Flask E-Commerce application
# This script sets up the development environment

set -e

echo "🚀 Setting up Flask E-Commerce Development Environment"

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
REQUIRED_VERSION="3.8"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ Python 3.8 or higher is required. Current version: $PYTHON_VERSION"
    exit 1
fi

echo "✅ Python $PYTHON_VERSION detected"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment
echo "🔄 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "📈 Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "📚 Installing dependencies..."
pip install -r requirements.txt

# Create environment file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "⚙️ Creating .env file..."
    cp .env.example .env
    echo "📝 Please edit .env file with your configuration"
else
    echo "✅ .env file already exists"
fi

# Initialize database
echo "🗄️ Initializing database..."
python -c "from app import init_db; init_db()"

# Run tests to ensure everything is working
echo "🧪 Running tests..."
python -m pytest tests/ -v --tb=short

echo "🎉 Setup completed successfully!"
echo ""
echo "To start the development server:"
echo "  source venv/bin/activate"
echo "  python app.py"
echo ""
echo "To run tests:"
echo "  source venv/bin/activate"
echo "  pytest tests/"
echo ""
echo "To build Docker image:"
echo "  docker build -t flask-ecommerce ."
echo ""
echo "Happy coding! 🚀"
