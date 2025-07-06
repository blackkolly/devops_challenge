# 🎯 Helm Charts and Monitoring on AWS EKS Guide

## 📋 Overview

This guide explains how to deploy the Flask E-Commerce application using Helm charts and set up comprehensive monitoring with Prometheus and Grafana on AWS EKS.

---

## 🚀 Part 1: Deploying with Helm Charts

### Prerequisites

1. **Install Helm** (if not already installed):
```bash
# On Windows
choco install kubernetes-helm

# On macOS
brew install helm

# On Linux
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
sudo mv linux-amd64/helm /usr/local/bin/
```

2. **Verify Helm Installation**:
```bash
helm version
```

### Step 1: Prepare ECR Image for Helm

Update the Helm values to use your ECR repository:

```bash
# Get your AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/flask-ecommerce"

echo "ECR Repository: $ECR_REPOSITORY"
```

### Step 2: Deploy with Helm

```bash
# Navigate to the helm chart directory
cd helm-chart/

# Add required Helm repositories for dependencies
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install dependencies (PostgreSQL and Redis)
helm dependency build flask-ecommerce/

# Deploy to production with custom values
helm install flask-ecommerce-prod flask-ecommerce/ \
  --namespace flask-ecommerce \
  --create-namespace \
  --values flask-ecommerce/values-production.yaml \
  --set image.repository=${ECR_REPOSITORY} \
  --set image.tag=latest \
  --wait

# Check deployment status
helm status flask-ecommerce-prod -n flask-ecommerce
```

### Step 3: Helm Management Commands

```bash
# List all Helm releases
helm list -A

# Upgrade the application
helm upgrade flask-ecommerce-prod flask-ecommerce/ \
  --namespace flask-ecommerce \
  --values flask-ecommerce/values-production.yaml \
  --set image.tag=v1.1.0

# Rollback to previous version
helm rollback flask-ecommerce-prod 1 -n flask-ecommerce

# Uninstall the release
helm uninstall flask-ecommerce-prod -n flask-ecommerce
```

### Step 4: Customize Helm Values for AWS

Update `values-production.yaml` for AWS-specific configurations:

```yaml
# AWS-specific configurations
image:
  repository: "YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/flask-ecommerce"
  tag: "latest"

service:
  type: LoadBalancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"

ingress:
  enabled: true
  className: "alb"
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip

# Enable PostgreSQL for production
postgresql:
  enabled: true
  auth:
    postgresPassword: "securepassword"
    database: "flask_ecommerce"
  primary:
    persistence:
      enabled: true
      size: 10Gi
      storageClass: "gp3"

# Enable Redis for session management
redis:
  enabled: true
  auth:
    enabled: true
    password: "securepassword"
  master:
    persistence:
      enabled: true
      size: 8Gi
      storageClass: "gp3"
```

---

## 📊 Part 2: Setting Up Monitoring (Prometheus + Grafana)

### Step 1: Install Prometheus Stack with Helm

```bash
# Add Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring

# Install Prometheus Operator (includes Prometheus, Grafana, AlertManager)
helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin123 \
  --set grafana.service.type=LoadBalancer \
  --set prometheus.service.type=LoadBalancer \
  --wait
```

### Step 2: Configure AWS-Specific Monitoring

Install AWS Load Balancer Controller for monitoring services:

```bash
# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Create IAM service account for AWS Load Balancer Controller
eksctl create iamserviceaccount \
  --cluster=flask-ecommerce-production-2024 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess \
  --override-existing-serviceaccounts \
  --approve

# Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=flask-ecommerce-production-2024 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### Step 3: Deploy Application ServiceMonitor

Create ServiceMonitor for your Flask application:

```bash
# Apply the existing monitoring configuration
kubectl apply -f monitoring.yaml
```

### Step 4: Access Monitoring Services

```bash
# Get Grafana LoadBalancer URL
kubectl get svc -n monitoring prometheus-stack-grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Get Prometheus LoadBalancer URL
kubectl get svc -n monitoring prometheus-stack-kube-prom-prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Default Grafana credentials: admin / admin123
```

### Step 5: Configure CloudWatch Integration

For additional AWS monitoring, set up CloudWatch Container Insights:

```bash
# Install CloudWatch agent
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml

# Create CloudWatch ConfigMap
kubectl create configmap cluster-info \
  --from-literal=cluster.name=flask-ecommerce-production-2024 \
  --from-literal=logs.region=us-west-2 -n amazon-cloudwatch

# Deploy CloudWatch agent
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml

# Deploy Fluent Bit for log collection
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml
```

---

## 🔧 Part 3: Enhanced Deployment Script

Let me update your deploy.sh script to include Helm deployment options:

```bash
# Add these functions to your deploy.sh script:

# Function to deploy with Helm
deploy_with_helm() {
    print_status "Deploying Flask application with Helm..."
    
    # Check if Helm is installed
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed. Please install Helm first."
        exit 1
    fi
    
    # Add required repositories
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    
    # Build dependencies
    cd helm-chart/
    helm dependency build flask-ecommerce/
    
    # Deploy with Helm
    helm upgrade --install flask-ecommerce-prod flask-ecommerce/ \
        --namespace $NAMESPACE \
        --create-namespace \
        --values flask-ecommerce/values-production.yaml \
        --set image.repository=${ECR_REPOSITORY} \
        --set image.tag=${IMAGE_TAG} \
        --wait
    
    cd ..
    print_success "Application deployed with Helm"
}

# Function to setup monitoring
setup_monitoring() {
    print_status "Setting up monitoring stack..."
    
    # Add Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Create monitoring namespace
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Install Prometheus stack
    helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
        --set grafana.adminPassword=admin123 \
        --set grafana.service.type=LoadBalancer \
        --set prometheus.service.type=LoadBalancer \
        --wait
    
    # Deploy application monitoring
    kubectl apply -f monitoring.yaml
    
    print_success "Monitoring stack deployed"
    
    # Show access information
    echo ""
    echo "Monitoring Access Information:"
    echo "Grafana URL: http://$(kubectl get svc -n monitoring prometheus-stack-grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
    echo "Prometheus URL: http://$(kubectl get svc -n monitoring prometheus-stack-kube-prom-prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):9090"
    echo "Default Grafana credentials: admin / admin123"
}
```

---

## 📊 Part 4: Grafana Dashboards

### Import Pre-built Dashboards

1. **Kubernetes Cluster Monitoring** (Dashboard ID: 6417)
2. **Kubernetes Pods Monitoring** (Dashboard ID: 6336)
3. **Node Exporter Full** (Dashboard ID: 1860)
4. **Flask Application Metrics** (Custom dashboard)

### Custom Flask Dashboard JSON

```json
{
  "dashboard": {
    "title": "Flask E-Commerce Application",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(flask_http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(flask_http_request_duration_seconds_bucket[5m]))"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(flask_http_requests_total{status=~\"5..\"}[5m])"
          }
        ]
      }
    ]
  }
}
```

---

## 🚨 Part 5: Alerting Setup

### Prometheus AlertManager Rules

```yaml
groups:
- name: flask-ecommerce-alerts
  rules:
  - alert: HighErrorRate
    expr: rate(flask_http_requests_total{status=~"5.."}[5m]) > 0.1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value }} errors per second"
  
  - alert: HighCPUUsage
    expr: rate(container_cpu_usage_seconds_total{pod=~"flask-app.*"}[5m]) > 0.8
    for: 10m
    labels:
      severity: critical
    annotations:
      summary: "High CPU usage"
      description: "CPU usage is above 80%"
```

---

## 💡 Best Practices

### Security
- Use AWS IAM roles for service accounts (IRSA)
- Store secrets in AWS Secrets Manager
- Enable Pod Security Standards
- Use network policies for traffic control

### Performance
- Configure resource requests and limits
- Use horizontal pod autoscaling
- Implement readiness and liveness probes
- Use AWS Application Load Balancer for production

### Monitoring
- Set up proper alerting rules
- Monitor both infrastructure and application metrics
- Use distributed tracing for complex applications
- Implement log aggregation with CloudWatch or ELK stack

---

## 🔄 Maintenance Commands

```bash
# Helm management
helm list -A                           # List all releases
helm history flask-ecommerce-prod -n flask-ecommerce  # View release history
helm rollback flask-ecommerce-prod 1 -n flask-ecommerce  # Rollback

# Monitoring management
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090

# Backup and restore
helm get values flask-ecommerce-prod -n flask-ecommerce > backup-values.yaml
```

---

## 📞 Troubleshooting

### Common Issues

1. **Helm dependency issues**: Run `helm dependency update`
2. **Service not accessible**: Check LoadBalancer provisioning
3. **Monitoring not collecting metrics**: Verify ServiceMonitor labels
4. **High resource usage**: Review resource limits and HPA settings

### Logs and Debugging

```bash
# Check Helm release status
helm status flask-ecommerce-prod -n flask-ecommerce

# View pod logs
kubectl logs -f deployment/flask-ecommerce-prod -n flask-ecommerce

# Check monitoring
kubectl get servicemonitor -n flask-ecommerce
kubectl logs -f -n monitoring prometheus-stack-kube-prom-prometheus-0
```

---

*Last Updated: July 5, 2025*
*AWS EKS Version: 1.27*
*Helm Version: 3.12+*
