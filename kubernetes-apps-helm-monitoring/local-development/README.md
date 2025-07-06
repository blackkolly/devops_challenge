# Local Development Environment

This directory contains everything you need for local development and testing of the Flask e-commerce application using Docker Compose.

## 🚀 Quick Start

```powershell
# Start the application
.\local-dev.ps1

# Access at: http://localhost:8080
```

## 📁 Files in this Directory

### Core Files
- **`docker-compose-local.yml`** - Docker Compose configuration for local development
- **`local-dev.ps1`** - PowerShell script to manage the local environment

### Documentation
- **`README.md`** - This file
- **`LOCAL_COMMANDS.md`** - Useful Docker Compose commands reference
- **`TESTING_GUIDE.md`** - Guide for testing the application

### Testing
- **`load-test.ps1`** - Performance testing script

## 🛠️ Usage

### Start Development Environment
```powershell
.\local-dev.ps1                # Start with existing image
.\local-dev.ps1 -Build         # Rebuild and start
```

### Stop Development Environment
```powershell
.\local-dev.ps1 -Down          # Stop and remove containers
```

### View Logs
```powershell
docker-compose -f docker-compose-local.yml logs -f
```

## 🌐 Access Points

- **Application**: http://localhost:8080
- **Health Check**: http://localhost:8080/health

## 📋 What This Environment Provides

✅ **Flask E-commerce Application** running in container  
✅ **SQLite Database** with persistent storage  
✅ **Development Configuration** optimized for local testing  
✅ **Health Checks** for monitoring  
✅ **Fast Startup/Shutdown** for development iteration  

## 🔧 Troubleshooting

If you encounter issues:

1. **Port conflicts**: Make sure port 8080 is not in use
2. **Build issues**: Run `.\local-dev.ps1 -Build` to rebuild
3. **Data issues**: Check `docker volume ls` for persistent data

## 📚 Related Documentation

- **Production Deployment**: See `../README.md` for Kubernetes deployment
- **CI/CD**: See `../../flask web application/Jenkinsfile`
- **AWS Deployment**: See `../aws-eks/` directory