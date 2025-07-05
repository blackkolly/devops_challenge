# Flask E-commerce DevOps Project

A production-ready Flask e-commerce application with complete DevOps pipeline including Docker, Kubernetes, CI/CD, and AWS deployment.

## 🚀 Project Overview

This project demonstrates a complete DevOps implementation with:

- **Flask E-commerce Application** - Full-featured online store
- **Containerization** - Docker with multi-stage builds
- **Kubernetes Orchestration** - Production-ready manifests and Helm charts
- **CI/CD Pipeline** - Jenkins automation
- **Cloud Deployment** - AWS EKS with auto-scaling
- **Local Development** - Docker Compose environment
- **Monitoring** - Prometheus and Grafana integration

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Application   │    │   Database      │
│   (HTML/CSS/JS) │ -> │   (Flask)       │ -> │   (SQLite)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   DevOps Stack  │
                    │                 │
                    │ • Docker        │
                    │ • Kubernetes    │
                    │ • Jenkins       │
                    │ • AWS EKS       │
                    │ • Monitoring    │
                    └─────────────────┘
```

## 📁 Project Structure

```
DevOps_Project/
├── flask web application/          # Flask application source code
│   ├── app.py                     # Main application
│   ├── models.py                  # Database models
│   ├── routes/                    # Route blueprints
│   ├── templates/                 # HTML templates
│   ├── static/                    # CSS, JS, images
│   ├── tests/                     # Test suites
│   ├── Dockerfile                 # Container definition
│   ├── docker-compose.yml         # Local Docker setup
│   └── Jenkinsfile               # CI/CD pipeline
│
├── kubernetes-application/         # Kubernetes deployments
│   ├── manifests/                 # K8s YAML files
│   ├── helm-chart/               # Helm package
│   ├── monitoring/               # Prometheus/Grafana
│   ├── aws-eks/                  # EKS deployment scripts
│   └── local-development/        # Local testing
│
└── Documentation/                 # Project documentation
```

## 🚀 Quick Start

### Local Development

1. **Clone the repository**

   ```bash
   git clone <your-repo-url>
   cd DevOps_Project
   ```

2. **Start local environment**

   ```powershell
   cd "kubernetes-application/local-development"
   .\local-dev.ps1
   ```

3. **Access the application**
   - Application: http://localhost:8080
   - Health Check: http://localhost:8080/health

### Production Deployment (AWS EKS)

1. **Setup EKS cluster**

   ```bash
   cd kubernetes-application/aws-eks
   ./setup-eks.sh
   ```

2. **Deploy application**
   ```bash
   ./deploy-to-eks.sh
   ```

## 🛠️ Technology Stack

### Application

- **Backend**: Python Flask
- **Database**: SQLite (development), PostgreSQL (production)
- **Frontend**: HTML5, CSS3, JavaScript (Bootstrap)
- **Authentication**: Flask-Login, Flask-WTF

### DevOps & Infrastructure

- **Containerization**: Docker, Docker Compose
- **Orchestration**: Kubernetes, Helm
- **CI/CD**: Jenkins
- **Cloud**: AWS EKS, EC2, IAM
- **Monitoring**: Prometheus, Grafana
- **Security**: RBAC, Pod Security Standards

### Development Tools

- **Testing**: pytest, unittest
- **Code Quality**: pylint, black
- **Documentation**: Markdown, Sphinx

## 🌟 Features

### E-commerce Application

- ✅ User registration and authentication
- ✅ Product catalog with search and filtering
- ✅ Shopping cart functionality
- ✅ Secure checkout process
- ✅ Order management system
- ✅ Admin dashboard
- ✅ REST API endpoints
- ✅ Responsive design

### DevOps Features

- ✅ Multi-stage Docker builds
- ✅ Kubernetes auto-scaling (HPA)
- ✅ Load balancing and service discovery
- ✅ Persistent volume management
- ✅ Health checks and monitoring
- ✅ CI/CD automation
- ✅ Blue-green deployment support
- ✅ Rollback capabilities

## 📚 Documentation

- **[Application Guide](flask%20web%20application/README.md)** - Flask app documentation
- **[Kubernetes Deployment](kubernetes-application/README.md)** - K8s setup guide
- **[Local Development](kubernetes-application/local-development/README.md)** - Local setup
- **[AWS EKS Guide](kubernetes-application/aws-eks/README.md)** - Cloud deployment
- **[CI/CD Pipeline](flask%20web%20application/DEPLOYMENT_GUIDE.md)** - Jenkins setup

## 🧪 Testing

### Local Testing

```powershell
# Run application tests
cd "flask web application"
python -m pytest tests/

# Load testing
cd "../kubernetes-application/local-development"
.\load-test.ps1
```

### Production Testing

```bash
# Health check
curl http://your-domain/health

# API testing
curl http://your-domain/api/products
```

## 🔧 Configuration

### Environment Variables

```bash
FLASK_ENV=production
SECRET_KEY=your-secret-key
DATABASE_URL=postgresql://user:pass@host:port/db
```

### Kubernetes Configuration

```yaml
# Custom values for Helm deployment
replicaCount: 3
image:
  tag: "v1.0.0"
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
```

## 🚀 Deployment Options

| Environment           | Method         | Command                       |
| --------------------- | -------------- | ----------------------------- |
| **Local Development** | Docker Compose | `.\local-dev.ps1`             |
| **Local Kubernetes**  | kubectl        | `kubectl apply -f manifests/` |
| **AWS EKS**           | Helm + kubectl | `./deploy-to-eks.sh`          |
| **CI/CD**             | Jenkins        | Automatic on git push         |

## 📊 Monitoring

The project includes comprehensive monitoring:

- **Application Metrics**: Response times, error rates, throughput
- **Infrastructure Metrics**: CPU, memory, network usage
- **Business Metrics**: Orders, revenue, user activity
- **Alerts**: Slack/email notifications for critical issues

Access monitoring dashboards:

- **Prometheus**: http://your-domain:9090
- **Grafana**: http://your-domain:3000

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:

- Create an issue in this repository
- Check the documentation in each component directory
- Review the troubleshooting guides

## 🙏 Acknowledgments

- Flask community for the excellent web framework
- Kubernetes community for orchestration tools
- AWS for cloud infrastructure
- Docker for containerization technology
