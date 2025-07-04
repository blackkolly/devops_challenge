# Kubernetes Deployment Guide for Flask E-Commerce Application

## Overview

This directory contains Kubernetes manifests and deployment scripts for running the Flask E-Commerce application in a Kubernetes cluster. The setup includes:

- **Multi-tier architecture** with Flask backend and Nginx frontend
- **Auto-scaling** based on CPU and memory usage
- **Persistent storage** for database
- **Service mesh** with proper networking
- **Monitoring and alerting** integration
- **Security** with RBAC and security contexts

## Prerequisites

### For Local Development (Windows Docker Desktop) 🚀
- **Docker Desktop with Kubernetes enabled**
- **kubectl** (included with Docker Desktop)
- **PowerShell** or Command Prompt
- **Helm** (optional, for advanced deployments)

### For AWS EKS Deployment ☁️
- **AWS CLI** configured with appropriate permissions
- **kubectl** installed
- **eksctl** installed
- **Helm** installed
- **Docker** installed

### Required Tools
- `kubectl` (Kubernetes CLI)
- `docker` (for building images)
- Access to a Kubernetes cluster (minikube, EKS, GKE, AKS, etc.)

### Cluster Requirements
- Kubernetes 1.20+
- Ingress controller (nginx-ingress recommended)
- Metrics server (for HPA)
- Prometheus Operator (optional, for monitoring)

## Quick Start

### 🏠 Local Development (Windows Docker Desktop) - EASIEST WAY TO START!

**Perfect for testing and development on your Windows machine!**

1. **Enable Kubernetes in Docker Desktop**
   - Open Docker Desktop → Settings → Kubernetes
   - Check "Enable Kubernetes" → Apply & Restart
   - Wait for Kubernetes to be running (green indicator)

2. **Quick Deploy with PowerShell**
   ```powershell
   cd "C:\Users\hp\Desktop\AWS\DevOps_Project\kubernetes-application\local-development"
   .\setup-local-k8s.ps1
   ```

3. **Or Quick Deploy with Command Prompt**
   ```cmd
   cd "C:\Users\hp\Desktop\AWS\DevOps_Project\kubernetes-application\local-development"
   setup-local.bat
   ```

4. **Access Application**
   ```powershell
   kubectl port-forward -n flask-ecommerce service/flask-ecommerce-service 8080:80
   # Open http://localhost:8080 in your browser
   ```

5. **Test Auto-scaling** (optional)
   ```powershell
   .\load-test.ps1 -Duration 60 -Threads 5
   # In another terminal:
   kubectl get hpa -n flask-ecommerce -w
   ```

6. **Clean Up**
   ```powershell
   kubectl delete namespace flask-ecommerce
   ```

📖 **See [Local Development Guide](local-development/README.md) for detailed instructions and troubleshooting.**

### ☁️ AWS EKS Deployment (Production)

```bash
# Make script executable
chmod +x deploy.sh

# Deploy application
./deploy.sh
```

### 2. Deploy with Custom Image Tag
```bash
./deploy.sh v1.0.0
```

### 3. Build and Deploy
```bash
./deploy.sh --build v1.0.0
```

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Ingress       │    │   LoadBalancer  │    │   NodePort      │
│   Controller    │───►│   Service       │───►│   Service       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │
                       ┌─────────────────┐    ┌─────────────────┐
                       │   Nginx Pods    │    │   Flask Pods    │
                       │   (Frontend)    │───►│   (Backend)     │
                       └─────────────────┘    └─────────────────┘
                                                        │
                                               ┌─────────────────┐
                                               │ Persistent Vol  │
                                               │ (Database)      │
                                               └─────────────────┘
```

## Deployment Components

### 1. Namespace (`namespace.yaml`)
- Creates `flask-ecommerce` namespace for production
- Creates `flask-ecommerce-staging` namespace for staging

### 2. Configuration (`configmap.yaml`, `secret.yaml`)
- **ConfigMap**: Non-sensitive configuration (ports, environment)
- **Secret**: Sensitive data (secret keys, credentials)
- **Nginx Config**: Reverse proxy configuration

### 3. Storage (`persistent-volume.yaml`)
- **PersistentVolume**: Local storage for database
- **PersistentVolumeClaim**: Storage request for Flask pods

### 4. Application (`deployment.yaml`)
- **Flask Deployment**: 3 replicas with health checks
- **Resource limits**: CPU and memory constraints
- **Security context**: Non-root user, dropped capabilities
- **Volume mounts**: Database storage

### 5. Load Balancing (`nginx-deployment.yaml`, `service.yaml`)
- **Nginx Deployment**: 2 replicas for load balancing
- **ClusterIP Service**: Internal Flask service
- **LoadBalancer Service**: External Nginx service
- **NodePort Service**: Alternative external access

### 6. Networking (`ingress.yaml`)
- **Ingress**: External access with custom domain
- **SSL termination**: Ready for HTTPS certificates
- **Path-based routing**: Multiple services support

### 7. Auto-scaling (`hpa.yaml`)
- **Horizontal Pod Autoscaler**: Scale 2-10 pods
- **CPU threshold**: 70% average utilization
- **Memory threshold**: 80% average utilization
- **Scale policies**: Controlled scaling behavior

### 8. High Availability (`pod-disruption-budget.yaml`)
- **Pod Disruption Budget**: Minimum available pods
- **Rolling updates**: Zero-downtime deployments
- **Node maintenance**: Service continuity

### 9. Security (`rbac.yaml`)
- **ServiceAccount**: Dedicated service account
- **Role**: Minimal required permissions
- **RoleBinding**: Account-to-role binding

### 10. Monitoring (`monitoring.yaml`)
- **ServiceMonitor**: Prometheus scraping configuration
- **PrometheusRule**: Alerting rules for critical metrics
- **Health checks**: Application and infrastructure monitoring

## Configuration Options

### Environment Variables

Set these before deployment:

```bash
# Docker registry (optional)
export DOCKER_REGISTRY="your-registry.com"

# Application secret key (optional, will be generated)
export SECRET_KEY="your-secret-key"

# Kubeconfig path (optional)
export KUBECONFIG="/path/to/your/kubeconfig"
```

### Image Configuration

Update `deployment.yaml` to use your image:

```yaml
containers:
- name: flask-app
  image: your-registry/flask-ecommerce:v1.0.0
```

### Domain Configuration

Update `ingress.yaml` for your domain:

```yaml
spec:
  rules:
  - host: your-domain.com
    http:
      paths:
      - path: /
```

## Deployment Commands

### Deploy Application
```bash
# Basic deployment
./deploy.sh

# With specific image tag
./deploy.sh v1.0.0

# Build and deploy
./deploy.sh --build v1.0.0
```

### Manual Deployment
```bash
# Create namespace
kubectl apply -f namespace.yaml

# Deploy configurations
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml

# Deploy storage
kubectl apply -f persistent-volume.yaml

# Deploy application
kubectl apply -f deployment.yaml
kubectl apply -f nginx-deployment.yaml

# Deploy services
kubectl apply -f service.yaml

# Deploy networking
kubectl apply -f ingress.yaml

# Deploy autoscaling
kubectl apply -f hpa.yaml
kubectl apply -f pod-disruption-budget.yaml

# Deploy security
kubectl apply -f rbac.yaml

# Deploy monitoring (if Prometheus available)
kubectl apply -f monitoring.yaml
```

### Check Deployment Status
```bash
# Show status
./deploy.sh --status

# Manual status check
kubectl get all -n flask-ecommerce
kubectl get pods -n flask-ecommerce -w
kubectl logs -f deployment/flask-app-deployment -n flask-ecommerce
```

### Access Application
```bash
# Port forward for testing
kubectl port-forward service/nginx-service 8080:80 -n flask-ecommerce

# Access via NodePort
kubectl get service flask-ecommerce-nodeport -n flask-ecommerce

# Access via LoadBalancer
kubectl get service nginx-service -n flask-ecommerce

# Access via Ingress
kubectl get ingress flask-ecommerce-ingress -n flask-ecommerce
```

## Scaling and Management

### Manual Scaling
```bash
# Scale Flask pods
kubectl scale deployment flask-app-deployment --replicas=5 -n flask-ecommerce

# Scale Nginx pods
kubectl scale deployment nginx-deployment --replicas=3 -n flask-ecommerce
```

### Auto-scaling Configuration
```bash
# Check HPA status
kubectl get hpa -n flask-ecommerce

# Describe HPA
kubectl describe hpa flask-app-hpa -n flask-ecommerce

# Update HPA
kubectl patch hpa flask-app-hpa -n flask-ecommerce -p '{"spec":{"maxReplicas":15}}'
```

### Rolling Updates
```bash
# Update image
kubectl set image deployment/flask-app-deployment flask-app=flask-ecommerce:v2.0.0 -n flask-ecommerce

# Check rollout status
kubectl rollout status deployment/flask-app-deployment -n flask-ecommerce

# Rollback if needed
kubectl rollout undo deployment/flask-app-deployment -n flask-ecommerce
```

## Monitoring and Troubleshooting

### Health Checks
```bash
# Check pod health
kubectl get pods -n flask-ecommerce

# Check pod details
kubectl describe pod <pod-name> -n flask-ecommerce

# Check logs
kubectl logs <pod-name> -n flask-ecommerce -f

# Execute commands in pod
kubectl exec -it <pod-name> -n flask-ecommerce -- /bin/bash
```

### Performance Monitoring
```bash
# Check resource usage
kubectl top pods -n flask-ecommerce
kubectl top nodes

# Check HPA metrics
kubectl get hpa -n flask-ecommerce -w

# Check service endpoints
kubectl get endpoints -n flask-ecommerce
```

### Common Issues

1. **Pods not starting**
   ```bash
   kubectl describe pod <pod-name> -n flask-ecommerce
   kubectl logs <pod-name> -n flask-ecommerce
   ```

2. **Service not accessible**
   ```bash
   kubectl get svc -n flask-ecommerce
   kubectl describe svc nginx-service -n flask-ecommerce
   ```

3. **PVC not binding**
   ```bash
   kubectl get pv,pvc -n flask-ecommerce
   kubectl describe pvc flask-db-pvc -n flask-ecommerce
   ```

4. **Ingress not working**
   ```bash
   kubectl get ingress -n flask-ecommerce
   kubectl describe ingress flask-ecommerce-ingress -n flask-ecommerce
   ```

## Security Considerations

### Pod Security
- Non-root user execution
- Read-only root filesystem
- Dropped Linux capabilities
- Security context constraints

### Network Security
- Network policies (implement as needed)
- Service mesh integration (Istio/Linkerd)
- TLS encryption for inter-service communication

### Secrets Management
- Kubernetes secrets for sensitive data
- External secret management (Vault, AWS Secrets Manager)
- Secret rotation policies

## Cleanup

### Remove Application
```bash
# Automated cleanup
./deploy.sh --cleanup

# Manual cleanup
kubectl delete namespace flask-ecommerce
kubectl delete pv flask-db-pv
```

## Production Considerations

### High Availability
- Multi-zone deployment
- Pod anti-affinity rules
- Multiple ingress controllers
- Database clustering

### Performance
- Resource requests/limits tuning
- JVM/Python optimization
- Database connection pooling
- Caching layer (Redis)

### Security
- Network policies
- Pod security policies
- Image scanning
- Runtime security monitoring

### Monitoring
- Prometheus + Grafana
- Application metrics
- Log aggregation (ELK stack)
- Distributed tracing

### Disaster Recovery
- Regular backups
- Cross-region replication
- Disaster recovery procedures
- Backup testing

## Advanced Features

### Blue-Green Deployment
```bash
# Create blue environment
kubectl apply -f deployment-blue.yaml

# Switch traffic
kubectl patch service nginx-service -p '{"spec":{"selector":{"version":"blue"}}}'

# Create green environment
kubectl apply -f deployment-green.yaml

# Switch traffic to green
kubectl patch service nginx-service -p '{"spec":{"selector":{"version":"green"}}}'
```

### Canary Deployment
- Use Flagger or Argo Rollouts
- Gradual traffic shifting
- Automated rollback on errors

### Service Mesh Integration
- Istio for advanced traffic management
- Mutual TLS between services
- Circuit breaker patterns
- Observability and tracing

## Support

For issues and questions:
1. Check logs: `kubectl logs -f deployment/flask-app-deployment -n flask-ecommerce`
2. Verify configuration: `kubectl get all -n flask-ecommerce`
3. Check resource usage: `kubectl top pods -n flask-ecommerce`
4. Review this documentation
5. Submit issues to the project repository

---

*This Kubernetes deployment provides a production-ready, scalable, and secure environment for the Flask E-Commerce application.*
