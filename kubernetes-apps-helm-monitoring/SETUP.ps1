# Final Setup and Summary Script
# This script prepares all scripts and provides a summary of available options

Write-Host "=== Flask E-commerce Kubernetes Application Setup ===" -ForegroundColor Green
Write-Host ""

# Check if we're in the right directory
$currentDir = Get-Location
if (-not ($currentDir.Path -like "*kubernetes-application*")) {
    Write-Host "Please run this script from the kubernetes-application directory" -ForegroundColor Red
    Write-Host "Current directory: $currentDir" -ForegroundColor Yellow
    exit 1
}

Write-Host "📁 Current directory: $currentDir" -ForegroundColor Blue
Write-Host ""

# Check Docker Desktop
Write-Host "🔍 Checking Docker Desktop..." -ForegroundColor Blue
try {
    $dockerVersion = docker version --format "{{.Client.Version}}" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker Desktop is running (Version: $dockerVersion)" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker Desktop is not running" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Docker Desktop is not installed or not in PATH" -ForegroundColor Red
}

# Check Kubernetes
Write-Host "🔍 Checking Kubernetes..." -ForegroundColor Blue
try {
    $k8sVersion = kubectl version --client --short 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ kubectl is available" -ForegroundColor Green
        
        # Check if cluster is accessible
        $clusterInfo = kubectl cluster-info 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Kubernetes cluster is accessible" -ForegroundColor Green
        } else {
            Write-Host "⚠️  kubectl available but no cluster connection" -ForegroundColor Yellow
            Write-Host "   Enable Kubernetes in Docker Desktop Settings" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ kubectl is not available" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ kubectl is not installed or not in PATH" -ForegroundColor Red
}

Write-Host ""
Write-Host "🚀 Available Deployment Options:" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. 🏠 LOCAL DEVELOPMENT (Windows Docker Desktop) - RECOMMENDED FOR TESTING" -ForegroundColor Green
Write-Host "   Perfect for: Learning, testing, development" -ForegroundColor White
Write-Host "   Requirements: Docker Desktop with Kubernetes enabled" -ForegroundColor White
Write-Host ""
Write-Host "   Quick Start:" -ForegroundColor Yellow
Write-Host "   cd local-development" -ForegroundColor Gray
Write-Host "   .\setup-local-k8s.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "   Or simple version:" -ForegroundColor Yellow
Write-Host "   .\quick-deploy.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "2. ☁️ AWS EKS DEPLOYMENT (Production)" -ForegroundColor Blue
Write-Host "   Perfect for: Production, scalability, cloud deployment" -ForegroundColor White
Write-Host "   Requirements: AWS CLI, eksctl, helm" -ForegroundColor White
Write-Host ""
Write-Host "   Setup EKS Cluster:" -ForegroundColor Yellow
Write-Host "   cd eks-setup" -ForegroundColor Gray
Write-Host "   .\setup-eks-cluster.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "   Deploy Application:" -ForegroundColor Yellow
Write-Host "   .\deploy-to-eks.sh" -ForegroundColor Gray
Write-Host ""

Write-Host "3. 📦 HELM CHART DEPLOYMENT (Advanced)" -ForegroundColor Magenta
Write-Host "   Perfect for: Complex configurations, multiple environments" -ForegroundColor White
Write-Host "   Requirements: Helm installed" -ForegroundColor White
Write-Host ""
Write-Host "   Deploy with Helm:" -ForegroundColor Yellow
Write-Host "   helm install flask-ecommerce ./helm-chart/flask-ecommerce" -ForegroundColor Gray
Write-Host ""

Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "   • README.md - Main documentation" -ForegroundColor White
Write-Host "   • local-development/README.md - Local setup guide" -ForegroundColor White
Write-Host "   • local-development/TESTING_GUIDE.md - Testing instructions" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Troubleshooting:" -ForegroundColor Cyan
Write-Host "   • Check Docker Desktop is running and Kubernetes is enabled" -ForegroundColor White
Write-Host "   • Run: kubectl cluster-info" -ForegroundColor White
Write-Host "   • View logs: kubectl logs -f deployment/flask-ecommerce -n flask-ecommerce" -ForegroundColor White
Write-Host "   • Clean up: kubectl delete namespace flask-ecommerce" -ForegroundColor White
Write-Host ""

Write-Host "🎯 Recommended Next Steps:" -ForegroundColor Green
Write-Host "1. Start with local development to test the application" -ForegroundColor White
Write-Host "2. Try auto-scaling and persistence features" -ForegroundColor White
Write-Host "3. When ready, deploy to AWS EKS for production" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Would you like to start local development now? (y/n)"
if ($choice -eq "y" -or $choice -eq "Y") {
    Write-Host ""
    Write-Host "Starting local development setup..." -ForegroundColor Green
    Set-Location "local-development"
    .\setup-local-k8s.ps1
} else {
    Write-Host ""
    Write-Host "Setup complete! Choose your deployment option above." -ForegroundColor Green
    Write-Host "Documentation is available in the respective directories." -ForegroundColor Blue
}
