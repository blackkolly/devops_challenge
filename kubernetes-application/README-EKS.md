# Flask E-commerce Kubernetes Application

This directory contains Kubernetes manifests and Helm charts for deploying the Flask E-commerce application on Kubernetes, specifically optimized for AWS EKS with auto-scaling, load balancing, persistent volumes, and comprehensive monitoring.

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **eksctl** - EKS cluster management tool
3. **kubectl** - Kubernetes command-line tool
4. **Helm 3** - Package manager for Kubernetes
5. **Docker** - For building container images

### Installation Commands

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

## 🏗️ Architecture Overview

### EKS Cluster Components

```
┌─────────────────────────────────────────────────────────────────┐
│                          AWS EKS Cluster                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Worker Node   │  │   Worker Node   │  │   Worker Node   │  │
│  │   (t3.medium)   │  │   (t3.medium)   │  │   (t3.medium)   │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  Flask App Pod  │  │  Flask App Pod  │  │  Flask App Pod  │  │
│  │  (HPA: 3-20)    │  │  (HPA: 3-20)    │  │  (HPA: 3-20)    │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   PostgreSQL    │  │     Redis       │  │   Monitoring    │  │
│  │   (Persistent)  │  │   (Session)     │  │ (Prometheus +   │  │
│  │                 │  │                 │  │   Grafana)      │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                │
                        ┌─────────────────┐
                        │  AWS ALB        │
                        │  (Load Balancer)│
                        └─────────────────┘
                                │
                          ┌─────────────┐
                          │   Internet  │
                          └─────────────┘
```

### Key Features

- **Auto-scaling**: Horizontal Pod Autoscaler (HPA) scales from 3 to 20 pods based on CPU/Memory
- **Load Balancing**: AWS Application Load Balancer with health checks
- **Persistent Storage**: EBS volumes with GP3 storage class
- **High Availability**: Multi-AZ deployment with pod anti-affinity rules
- **Security**: Network policies, RBAC, security contexts, and secrets management
- **Monitoring**: Prometheus + Grafana stack with custom dashboards and alerts
- **Zero-downtime Deployments**: Rolling updates with health checks

## 📁 Directory Structure

```
kubernetes-application/
├── helm-chart/                    # Helm chart for the application
│   └── flask-ecommerce/
│       ├── Chart.yaml            # Chart metadata
│       ├── values.yaml           # Default values
│       └── templates/            # Kubernetes templates
│           ├── deployment.yaml   # Application deployment
│           ├── service.yaml      # Kubernetes service
│           ├── ingress.yaml      # ALB ingress
│           ├── hpa.yaml         # Horizontal Pod Autoscaler
│           ├── configmap.yaml   # Configuration
│           ├── secret.yaml      # Secrets
│           └── ...
├── eks-setup/                    # EKS cluster setup scripts
│   ├── setup-eks-cluster.sh     # Create EKS cluster
│   ├── deploy-to-eks.sh         # Deploy application
│   └── cleanup-eks.sh           # Cleanup resources
├── monitoring/                   # Monitoring configurations
│   ├── prometheus-config.yaml   # Prometheus configuration
│   └── grafana-dashboard.yaml   # Grafana dashboard
├── overlays/                     # Kustomize overlays
│   ├── development/             # Dev environment
│   └── production/              # Prod environment
└── manifests/                    # Raw Kubernetes manifests
    ├── deployment-eks.yaml      # EKS-optimized deployment
    ├── ingress-alb.yaml         # AWS ALB ingress
    ├── hpa-eks.yaml            # Enhanced HPA
    └── ...
```

## 🛠️ Deployment Guide

### Step 1: Create EKS Cluster

```bash
# Configure AWS credentials
aws configure

# Create EKS cluster (takes 15-20 minutes)
cd eks-setup
chmod +x setup-eks-cluster.sh
./setup-eks-cluster.sh

# Verify cluster
kubectl get nodes
kubectl get pods -A
```

### Step 2: Deploy Application using Helm

```bash
# Deploy the application
chmod +x deploy-to-eks.sh
./deploy-to-eks.sh

# Check deployment status
helm list -n flask-ecommerce
kubectl get pods -n flask-ecommerce
kubectl get hpa -n flask-ecommerce
```

### Step 3: Access the Application

```bash
# Get the Application Load Balancer URL
kubectl get ingress flask-ecommerce -n flask-ecommerce

# Wait for ALB to be provisioned (3-5 minutes)
# Access your application at the ALB DNS name
```

### Step 4: Monitor the Application

```bash
# Get Grafana URL
kubectl get svc prometheus-grafana -n monitoring

# Default credentials: admin/admin123
# Access Grafana dashboard for monitoring
```

## ⚙️ Configuration

### Environment Variables

The application uses the following configuration sources:

1. **ConfigMap** (`flask-ecommerce-config`):
   ```yaml
   FLASK_ENV: production
   FLASK_DEBUG: false
   LOG_LEVEL: INFO
   SESSION_TIMEOUT: "3600"
   ```

2. **Secrets** (`flask-ecommerce-secret`):
   ```yaml
   secret-key: <auto-generated>
   database-url: <postgresql-connection-string>
   redis-url: <redis-connection-string>
   ```

### Resource Requests and Limits

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Auto-scaling Configuration

```yaml
minReplicas: 3
maxReplicas: 20
targetCPUUtilizationPercentage: 70
targetMemoryUtilizationPercentage: 80
```

## 🔄 Auto-scaling and Load Balancing

### Horizontal Pod Autoscaler (HPA)

The HPA automatically scales the application based on:

- **CPU Utilization**: Target 70%
- **Memory Utilization**: Target 80%
- **Scale Up**: Fast scaling (50% increase every 30s)
- **Scale Down**: Conservative scaling (25% decrease every 60s)

```bash
# Monitor HPA status
kubectl get hpa flask-ecommerce-hpa -n flask-ecommerce -w

# View HPA events
kubectl describe hpa flask-ecommerce-hpa -n flask-ecommerce
```

### Cluster Autoscaler

The cluster automatically adds/removes nodes based on pod scheduling needs:

```bash
# Check cluster autoscaler status
kubectl get pods -n kube-system | grep cluster-autoscaler

# View autoscaler logs
kubectl logs -f deployment/cluster-autoscaler -n kube-system
```

### Load Balancing

AWS Application Load Balancer (ALB) provides:

- **Health Checks**: `/health` endpoint monitoring
- **SSL Termination**: Automatic HTTPS redirection
- **Target Groups**: IP-based routing to pods
- **Sticky Sessions**: Session affinity support

## 💾 Persistent Volumes

### Storage Configuration

- **Storage Class**: `gp3` (AWS EBS GP3 volumes)
- **Volume Size**: 10Gi (configurable)
- **Access Mode**: ReadWriteOnce
- **Encryption**: Enabled

```bash
# Check persistent volumes
kubectl get pv
kubectl get pvc -n flask-ecommerce

# View storage class
kubectl get storageclass
```

### Database Persistence

PostgreSQL uses persistent storage with:

- **Volume Size**: 20Gi
- **Backup**: Automated daily backups
- **Encryption**: At-rest encryption enabled

## 📊 Monitoring and Alerting

### Prometheus Metrics

The application exposes metrics at `/metrics`:

- `flask_request_total` - Total number of requests
- `flask_request_duration_seconds` - Request duration histogram
- `flask_active_connections` - Active database connections
- Standard Kubernetes metrics (CPU, memory, etc.)

### Grafana Dashboards

Access Grafana for monitoring:

```bash
# Get Grafana URL
kubectl get svc prometheus-grafana -n monitoring

# Default login: admin/admin123
```

### Built-in Alerts

- **Application Down**: Triggers after 5 minutes
- **High Response Time**: 95th percentile > 2 seconds
- **High Error Rate**: 5xx errors > 10%
- **High Resource Usage**: CPU/Memory > 80%
- **Pod Crash Looping**: Frequent restarts

## 🔒 Security

### Network Security

- **Network Policies**: Restrict pod-to-pod communication
- **Security Groups**: Control traffic at the node level
- **HTTPS**: SSL/TLS encryption via ALB

### Pod Security

- **Security Context**: Non-root user, read-only filesystem
- **RBAC**: Role-based access control
- **Secrets Management**: Kubernetes secrets for sensitive data
- **Image Security**: Regular vulnerability scanning

### RBAC Configuration

```bash
# View service accounts
kubectl get sa -n flask-ecommerce

# Check RBAC permissions
kubectl auth can-i --list --as=system:serviceaccount:flask-ecommerce:flask-ecommerce-sa
```

## 🧪 Testing

### Health Checks

```bash
# Test application health
kubectl port-forward svc/flask-ecommerce-service 8080:80 -n flask-ecommerce
curl http://localhost:8080/health

# Test auto-scaling
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# In the pod: while true; do wget -q -O- http://flask-ecommerce-service.flask-ecommerce/; done
```

### Load Testing

```bash
# Install hey for load testing
go install github.com/rakyll/hey@latest

# Get ALB URL
ALB_URL=$(kubectl get ingress flask-ecommerce-ingress -n flask-ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Run load test
hey -z 300s -c 50 http://$ALB_URL/
```

## 🚨 Troubleshooting

### Common Issues

1. **Pods not starting**:
   ```bash
   kubectl describe pod <pod-name> -n flask-ecommerce
   kubectl logs <pod-name> -n flask-ecommerce
   ```

2. **HPA not scaling**:
   ```bash
   kubectl get hpa -n flask-ecommerce
   kubectl describe hpa flask-ecommerce-hpa -n flask-ecommerce
   kubectl top pods -n flask-ecommerce
   ```

3. **ALB not accessible**:
   ```bash
   kubectl describe ingress flask-ecommerce-ingress -n flask-ecommerce
   kubectl get events -n flask-ecommerce
   ```

4. **Database connectivity**:
   ```bash
   kubectl exec -it <flask-pod> -n flask-ecommerce -- python -c "
   import psycopg2
   import os
   conn = psycopg2.connect(os.environ['DATABASE_URL'])
   print('Database connection successful')
   "
   ```

### Debugging Commands

```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system

# View resource usage
kubectl top nodes
kubectl top pods -n flask-ecommerce

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp -n flask-ecommerce

# Port forward for local testing
kubectl port-forward svc/flask-ecommerce-service 8080:80 -n flask-ecommerce
```

## 🔄 Updates and Rollbacks

### Rolling Updates

```bash
# Update application image
helm upgrade flask-ecommerce ./helm-chart/flask-ecommerce \
  --namespace flask-ecommerce \
  --set image.tag=v1.1.0

# Monitor rollout
kubectl rollout status deployment/flask-ecommerce-app -n flask-ecommerce
```

### Rollbacks

```bash
# View rollout history
kubectl rollout history deployment/flask-ecommerce-app -n flask-ecommerce

# Rollback to previous version
kubectl rollout undo deployment/flask-ecommerce-app -n flask-ecommerce

# Rollback to specific revision
kubectl rollout undo deployment/flask-ecommerce-app --to-revision=2 -n flask-ecommerce
```

## 🧹 Cleanup

### Remove Application

```bash
# Remove Helm releases
helm uninstall flask-ecommerce -n flask-ecommerce
helm uninstall prometheus -n monitoring

# Delete namespaces
kubectl delete namespace flask-ecommerce
kubectl delete namespace monitoring
```

### Remove EKS Cluster

```bash
# Run cleanup script
cd eks-setup
./cleanup-eks.sh

# Verify cleanup
eksctl get clusters
```

## 📚 Additional Resources

### AWS EKS Documentation
- [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)

### Kubernetes Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [HPA Documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

### Monitoring
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Kubernetes Monitoring Best Practices](https://prometheus.io/docs/practices/monitoring/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Last Updated**: July 4, 2025  
**Version**: 2.0.0  
**Kubernetes Version**: 1.28+  
**EKS Support**: ✅
