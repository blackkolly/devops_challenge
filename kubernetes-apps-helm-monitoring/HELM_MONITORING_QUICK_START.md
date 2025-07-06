# 🎯 Complete Guide: Helm Charts and Monitoring on AWS EKS

## 📋 Quick Reference

### 🚀 Helm Deployment Commands
```bash
# Basic Helm deployment
./deploy.sh --helm v1.0.0

# Build and deploy with Helm
./deploy.sh --helm-build v1.0.0

# Upgrade Helm deployment
./deploy.sh --helm-upgrade v1.1.0

# Check Helm status
./deploy.sh --helm-status

# Clean up Helm deployments
./deploy.sh --helm-cleanup
```

### 📊 Monitoring Commands
```bash
# Deploy monitoring stack
./deploy.sh --monitoring

# Deploy CloudWatch integration
./deploy.sh --cloudwatch

# Deploy complete stack (app + monitoring)
./deploy.sh --full-stack v1.0.0
```

### 🎮 Demo Commands
```bash
# Run interactive demos
./helm-monitoring-demo.sh helm-demo        # Helm deployment demo
./helm-monitoring-demo.sh monitoring-demo  # Monitoring setup demo
./helm-monitoring-demo.sh full-demo        # Complete stack demo
./helm-monitoring-demo.sh status          # Check deployment status
./helm-monitoring-demo.sh cleanup         # Clean up demos
```

---

## 🏗️ Architecture Overview

### Helm Chart Structure
```
helm-chart/flask-ecommerce/
├── Chart.yaml                 # Chart metadata and dependencies
├── values.yaml               # Default values
├── values-production-clean.yaml # Production-optimized values
└── templates/                # Kubernetes manifests templates
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── configmap.yaml
    ├── secret.yaml
    └── hpa.yaml
```

### Monitoring Stack Components
```
Monitoring Namespace:
├── Prometheus Server         # Metrics collection
├── Grafana                  # Visualization dashboards
├── AlertManager             # Alert handling
├── Node Exporter            # Node metrics
├── Kube State Metrics       # Kubernetes metrics
└── Prometheus Operator      # Manages Prometheus instances
```

---

## 🎯 Deployment Scenarios

### Scenario 1: Development/Testing
```bash
# Quick deployment for testing
./deploy.sh --helm latest

# Or use the demo
./helm-monitoring-demo.sh helm-demo
```

### Scenario 2: Production with Monitoring
```bash
# Complete production stack
./deploy.sh --full-stack v1.0.0

# Or step by step
./deploy.sh --helm-build v1.0.0
./deploy.sh --monitoring
./deploy.sh --cloudwatch
```

### Scenario 3: Monitoring Only
```bash
# Just monitoring stack
./deploy.sh --monitoring
./deploy.sh --cloudwatch

# Or use demo
./helm-monitoring-demo.sh monitoring-demo
```

---

## 📊 Monitoring Features

### What You Get

1. **Prometheus Metrics Collection**
   - Kubernetes cluster metrics
   - Node performance metrics
   - Application metrics (Flask)
   - Custom business metrics

2. **Grafana Dashboards**
   - Pre-configured Kubernetes dashboards
   - Custom Flask application dashboard
   - Real-time monitoring
   - Historical data analysis

3. **AWS CloudWatch Integration**
   - Container Insights
   - Log aggregation
   - AWS-native monitoring
   - Integration with AWS services

4. **Alerting (AlertManager)**
   - CPU/Memory alerts
   - Application error rate alerts
   - Infrastructure health alerts
   - Custom alert rules

### Key Metrics Monitored

- **Application Metrics**: Response time, error rate, request rate
- **Infrastructure Metrics**: CPU, memory, disk, network
- **Kubernetes Metrics**: Pod status, deployments, services
- **Business Metrics**: User sessions, transactions, performance

---

## 🔧 Configuration Options

### Helm Values Customization

Edit `helm-chart/flask-ecommerce/values-production-clean.yaml`:

```yaml
# Scale settings
replicaCount: 3
autoscaling:
  minReplicas: 3
  maxReplicas: 10

# AWS-specific settings
service:
  type: LoadBalancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"

# Resource limits
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

### Monitoring Customization

The monitoring stack can be customized during deployment:

```bash
# Custom Grafana password
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --set grafana.adminPassword=your-password
```

---

## 🚨 Production Recommendations

### Security
- [ ] Use AWS IAM roles for service accounts (IRSA)
- [ ] Enable SSL/TLS with AWS Certificate Manager
- [ ] Configure network policies
- [ ] Use AWS Secrets Manager for sensitive data
- [ ] Enable pod security policies

### Performance
- [ ] Configure resource requests and limits
- [ ] Set up horizontal pod autoscaling
- [ ] Use multiple availability zones
- [ ] Configure persistent storage with EBS
- [ ] Optimize Docker images

### Monitoring
- [ ] Set up custom alerts for your application
- [ ] Configure log retention policies
- [ ] Set up notification channels (Slack, email)
- [ ] Create custom Grafana dashboards
- [ ] Monitor business metrics

### High Availability
- [ ] Use pod anti-affinity rules
- [ ] Configure pod disruption budgets
- [ ] Set up backup strategies
- [ ] Test disaster recovery procedures
- [ ] Monitor across multiple regions

---

## 🔍 Troubleshooting

### Common Helm Issues

```bash
# Helm deployment failed
helm status flask-ecommerce-prod -n flask-ecommerce
helm get logs flask-ecommerce-prod -n flask-ecommerce

# Update dependencies
cd helm-chart/
helm dependency update flask-ecommerce/

# Validate chart
helm lint flask-ecommerce/
```

### Monitoring Issues

```bash
# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090
# Visit http://localhost:9090/targets

# Check Grafana
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80
# Visit http://localhost:3000

# Check ServiceMonitor
kubectl get servicemonitor -n flask-ecommerce
```

### AWS Integration Issues

```bash
# Check CloudWatch agents
kubectl get pods -n amazon-cloudwatch

# Check AWS Load Balancer Controller
kubectl get pods -n kube-system | grep aws-load-balancer-controller

# Check service annotations
kubectl describe svc flask-ecommerce-prod -n flask-ecommerce
```

---

## 📈 Scaling Guide

### Horizontal Scaling
```bash
# Scale application pods
kubectl scale deployment flask-ecommerce-prod --replicas=5 -n flask-ecommerce

# Or update Helm values
helm upgrade flask-ecommerce-prod helm-chart/flask-ecommerce/ \
    --set replicaCount=5 \
    --namespace flask-ecommerce
```

### Vertical Scaling
```bash
# Update resource limits
helm upgrade flask-ecommerce-prod helm-chart/flask-ecommerce/ \
    --set resources.limits.cpu=1000m \
    --set resources.limits.memory=1Gi \
    --namespace flask-ecommerce
```

### Auto Scaling
```bash
# Configure HPA
helm upgrade flask-ecommerce-prod helm-chart/flask-ecommerce/ \
    --set autoscaling.enabled=true \
    --set autoscaling.minReplicas=3 \
    --set autoscaling.maxReplicas=20 \
    --namespace flask-ecommerce
```

---

## 🧹 Cleanup Procedures

### Partial Cleanup
```bash
# Remove application only
./deploy.sh --helm-cleanup

# Remove monitoring only
helm uninstall prometheus-stack -n monitoring
kubectl delete namespace monitoring
```

### Complete Cleanup
```bash
# Remove everything
./helm-monitoring-demo.sh cleanup

# Or complete AWS cleanup
./deploy.sh --aws-cleanup
```

---

## 📚 Additional Resources

### Documentation
- [HELM_AND_MONITORING_GUIDE.md](./HELM_AND_MONITORING_GUIDE.md) - Detailed setup guide
- [README.md](./README.md) - Main project documentation
- [DEPLOYMENT_CHALLENGES_AND_SOLUTIONS.md](./DEPLOYMENT_CHALLENGES_AND_SOLUTIONS.md) - Troubleshooting

### External Resources
- [Helm Documentation](https://helm.sh/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)

---

**🎉 You're all set! Use the commands above to deploy and monitor your Flask E-Commerce application on AWS EKS with Helm charts.**

*Last Updated: July 5, 2025*
*Version: 2.0*
