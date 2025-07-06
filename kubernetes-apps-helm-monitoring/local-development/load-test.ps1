# Load Testing Script for Local Kubernetes
# This script helps test auto-scaling functionality

param(
    [int]$Duration = 60,
    [int]$Threads = 5,
    [string]$Namespace = "flask-ecommerce"
)

Write-Host "=== Load Testing Flask E-commerce Application ===" -ForegroundColor Green
Write-Host "Duration: $Duration seconds" -ForegroundColor Blue
Write-Host "Threads: $Threads" -ForegroundColor Blue

# Check if app is running
$pods = kubectl get pods -n $Namespace -l app=flask-ecommerce -o jsonpath='{.items[*].metadata.name}' 2>$null
if (-not $pods) {
    Write-Error "Flask application is not running in namespace $Namespace"
}

Write-Host "Found running pods: $pods" -ForegroundColor Green

# Get service name
$serviceName = "flask-ecommerce-service"
$serviceExists = kubectl get service $serviceName -n $Namespace 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Service $serviceName not found in namespace $Namespace"
}

# Start load testing
Write-Host "Starting load test..." -ForegroundColor Yellow
Write-Host "Watch HPA scaling with: kubectl get hpa -n $Namespace -w" -ForegroundColor Cyan
Write-Host "Watch pods scaling with: kubectl get pods -n $Namespace -w" -ForegroundColor Cyan
Write-Host ""

# Create load testing job
$loadTestJob = @"
apiVersion: batch/v1
kind: Job
metadata:
  name: load-test-$(Get-Date -Format 'yyyyMMdd-HHmmss')
  namespace: $Namespace
spec:
  parallelism: $Threads
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: load-test
        image: busybox
        command:
        - /bin/sh
        - -c
        - |
          echo "Starting load test for $Duration seconds..."
          end_time=`$((`$(date +%s) + $Duration))
          while [ `$(date +%s) -lt `$end_time ]; do
            wget -q -O- http://$serviceName.$Namespace.svc.cluster.local/ || true
            wget -q -O- http://$serviceName.$Namespace.svc.cluster.local/health || true
            wget -q -O- http://$serviceName.$Namespace.svc.cluster.local/products || true
            sleep 0.1
          done
          echo "Load test completed"
"@

# Apply load test job
$loadTestJob | kubectl apply -f -

Write-Host "Load test job created. Monitor with:" -ForegroundColor Green
Write-Host "kubectl get jobs -n $Namespace" -ForegroundColor Yellow
Write-Host "kubectl logs -f job/load-test-$(Get-Date -Format 'yyyyMMdd-HHmmss') -n $Namespace" -ForegroundColor Yellow

# Monitor HPA in real-time
Start-Sleep 5
Write-Host "Monitoring HPA status..." -ForegroundColor Blue
kubectl get hpa -n $Namespace -w
