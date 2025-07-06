# Local Kubernetes Testing Guide

## Quick Start (3 Steps)

### Option 1: Using PowerShell (Recommended)
```powershell
# Navigate to the directory
cd "C:\Users\hp\Desktop\AWS\DevOps_Project\kubernetes-application\local-development"

# Run setup script
.\setup-local-k8s.ps1

# Follow the prompts
```

### Option 2: Using Command Prompt
```cmd
cd "C:\Users\hp\Desktop\AWS\DevOps_Project\kubernetes-application\local-development"
setup-local.bat
```

### Option 3: Manual Kubectl
```powershell
# Build image
docker build -t flask-ecommerce:local "../flask web application"

# Deploy
kubectl apply -f local-manifests.yaml

# Port forward
kubectl port-forward -n flask-ecommerce service/flask-ecommerce-service 8080:80
```

## Testing Scenarios

### 1. Basic Functionality Test
```powershell
# Access the application
Start-Process "http://localhost:8080"

# Test health endpoint
curl http://localhost:8080/health

# Test API endpoints
curl http://localhost:8080/api/products
```

### 2. Auto-scaling Test
```powershell
# Run load test
.\load-test.ps1 -Duration 120 -Threads 10

# In another terminal, watch scaling
kubectl get hpa -n flask-ecommerce -w
kubectl get pods -n flask-ecommerce -w
```

### 3. Persistence Test
```powershell
# Create some data in the app (register user, add products)
# Then delete the pod
kubectl delete pod -l app=flask-ecommerce -n flask-ecommerce

# Wait for new pod
kubectl wait --for=condition=ready pod -l app=flask-ecommerce -n flask-ecommerce

# Verify data persists
```

### 4. Rolling Update Test
```powershell
# Build new image version
docker build -t flask-ecommerce:v2 "../flask web application"

# Update deployment
kubectl set image deployment/flask-ecommerce flask-ecommerce=flask-ecommerce:v2 -n flask-ecommerce

# Watch rollout
kubectl rollout status deployment/flask-ecommerce -n flask-ecommerce
```

## Monitoring Commands

### View Application Status
```powershell
# All resources
kubectl get all -n flask-ecommerce

# Pod details
kubectl describe pods -l app=flask-ecommerce -n flask-ecommerce

# Application logs
kubectl logs -f deployment/flask-ecommerce -n flask-ecommerce

# Events
kubectl get events -n flask-ecommerce --sort-by='.lastTimestamp'
```

### Performance Monitoring
```powershell
# Resource usage
kubectl top pods -n flask-ecommerce
kubectl top nodes

# HPA status
kubectl get hpa -n flask-ecommerce
kubectl describe hpa flask-ecommerce-hpa -n flask-ecommerce
```

## Troubleshooting

### Common Issues

1. **Image not found**
   ```powershell
   # Ensure image is built locally
   docker images | findstr flask-ecommerce
   
   # Rebuild if needed
   docker build -t flask-ecommerce:local "../flask web application"
   ```

2. **Pod not starting**
   ```powershell
   # Check pod status
   kubectl describe pod -l app=flask-ecommerce -n flask-ecommerce
   
   # Check logs
   kubectl logs -l app=flask-ecommerce -n flask-ecommerce
   ```

3. **Service not accessible**
   ```powershell
   # Check service
   kubectl get svc -n flask-ecommerce
   
   # Test internal connectivity
   kubectl run debug --image=busybox -it --rm -- wget -O- flask-ecommerce-service.flask-ecommerce.svc.cluster.local
   ```

4. **Database connection issues**
   ```powershell
   # Check if PostgreSQL is running
   kubectl get pods -l app.kubernetes.io/name=postgresql -n flask-ecommerce
   
   # Check database logs
   kubectl logs -l app.kubernetes.io/name=postgresql -n flask-ecommerce
   ```

## Clean Up

```powershell
# Remove everything
kubectl delete namespace flask-ecommerce

# Or use the clean script
.\setup-local-k8s.ps1 -Clean
```

## Performance Tips

1. **Increase Docker Desktop Resources**:
   - Memory: 8GB+
   - CPU: 4+ cores
   - Swap: 2GB+

2. **Enable Kubernetes Dashboard** (optional):
   ```powershell
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
   kubectl proxy
   # Access at: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
   ```

3. **Monitor Resource Usage**:
   ```powershell
   # Install metrics server if not present
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   
   # View metrics
   kubectl top nodes
   kubectl top pods -A
   ```

This local setup gives you a complete Kubernetes environment to test all the features before deploying to AWS EKS!
