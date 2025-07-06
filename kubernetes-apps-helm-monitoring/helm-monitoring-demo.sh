#!/bin/bash

# Flask E-Commerce Helm and Monitoring Demo Script
# This script demonstrates how to deploy the application using Helm charts and monitoring

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    echo "🎯 Flask E-Commerce Helm and Monitoring Demo"
    echo "============================================="
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  helm-demo        Deploy application using Helm charts"
    echo "  monitoring-demo  Deploy monitoring stack (Prometheus + Grafana)"
    echo "  full-demo        Deploy complete stack (App + Monitoring)"
    echo "  status          Show current deployment status"
    echo "  cleanup         Clean up demo deployments"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 helm-demo        # Deploy Flask app with Helm"
    echo "  $0 monitoring-demo  # Deploy monitoring only"
    echo "  $0 full-demo        # Deploy everything"
    echo "  $0 status          # Check what's running"
    echo "  $0 cleanup         # Remove demo deployments"
}

helm_demo() {
    print_status "🎯 Starting Helm Deployment Demo..."
    echo ""
    
    print_status "Step 1: Checking prerequisites..."
    ./deploy.sh --help > /dev/null 2>&1 || {
        print_error "deploy.sh script not found or not executable"
        exit 1
    }
    
    print_status "Step 2: Deploying Flask E-Commerce with Helm..."
    ./deploy.sh --helm latest
    
    print_success "🎉 Helm deployment completed!"
    echo ""
    
    print_status "Helm deployment information:"
    ./deploy.sh --helm-status
    
    echo ""
    print_status "🌐 To access your application:"
    echo "1. Wait for LoadBalancer to provision (2-5 minutes)"
    echo "2. Check service status: kubectl get svc -n flask-ecommerce"
    echo "3. Get external IP and visit the application"
}

monitoring_demo() {
    print_status "📊 Starting Monitoring Stack Demo..."
    echo ""
    
    print_status "Step 1: Deploying Prometheus and Grafana..."
    ./deploy.sh --monitoring
    
    print_status "Step 2: Setting up AWS CloudWatch integration..."
    ./deploy.sh --cloudwatch
    
    print_success "🎉 Monitoring stack deployed!"
    echo ""
    
    print_status "📊 Monitoring access information:"
    echo ""
    echo "Grafana Dashboard:"
    GRAFANA_LB=$(kubectl get svc -n monitoring prometheus-stack-grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "provisioning...")
    echo "  URL: http://$GRAFANA_LB"
    echo "  Username: admin"
    echo "  Password: admin123"
    echo ""
    
    echo "Prometheus:"
    PROMETHEUS_LB=$(kubectl get svc -n monitoring prometheus-stack-kube-prom-prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "provisioning...")
    echo "  URL: http://$PROMETHEUS_LB:9090"
    echo ""
    
    echo "Alternative (Port Forwarding):"
    echo "  Grafana: kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80"
    echo "  Prometheus: kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090"
    
    echo ""
    print_status "📊 Recommended Grafana Dashboards to import:"
    echo "  • 6417 - Kubernetes Cluster Monitoring"
    echo "  • 6336 - Kubernetes Pods Monitoring"
    echo "  • 1860 - Node Exporter Full"
    echo "  • 315 - Kubernetes cluster monitoring"
}

full_demo() {
    print_status "🚀 Starting Complete Stack Demo..."
    echo ""
    
    print_status "This will deploy:"
    echo "• Flask E-Commerce application (Helm)"
    echo "• Prometheus monitoring"
    echo "• Grafana dashboards" 
    echo "• AWS CloudWatch integration"
    echo ""
    
    read -p "Continue? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        print_warning "Demo cancelled"
        exit 0
    fi
    
    print_status "Deploying complete stack..."
    ./deploy.sh --full-stack latest
    
    print_success "🎉 Complete stack deployment finished!"
    echo ""
    
    # Show status
    status_demo
}

status_demo() {
    print_status "📋 Current Deployment Status"
    echo ""
    
    print_status "Flask E-Commerce Application:"
    if kubectl get namespace flask-ecommerce &> /dev/null; then
        kubectl get pods,svc -n flask-ecommerce
        echo ""
        
        # Check if Helm deployment exists
        if helm status flask-ecommerce-prod -n flask-ecommerce &> /dev/null; then
            echo "Helm deployment status:"
            helm status flask-ecommerce-prod -n flask-ecommerce
        fi
    else
        echo "  Not deployed"
    fi
    
    echo ""
    print_status "Monitoring Stack:"
    if kubectl get namespace monitoring &> /dev/null; then
        kubectl get pods -n monitoring | grep -E "prometheus|grafana|alertmanager"
        echo ""
        
        # Get service URLs
        echo "Service URLs:"
        kubectl get svc -n monitoring | grep -E "prometheus|grafana"
    else
        echo "  Not deployed"
    fi
    
    echo ""
    print_status "AWS CloudWatch:"
    if kubectl get namespace amazon-cloudwatch &> /dev/null; then
        kubectl get pods -n amazon-cloudwatch
    else
        echo "  Not deployed"
    fi
}

cleanup_demo() {
    print_warning "🗑️  Cleaning up demo deployments..."
    echo ""
    echo "This will remove:"
    echo "• Flask E-Commerce Helm deployment"
    echo "• Monitoring stack (Prometheus/Grafana)"
    echo "• CloudWatch agents"
    echo ""
    
    read -p "Are you sure? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        print_warning "Cleanup cancelled"
        exit 0
    fi
    
    print_status "Cleaning up Helm deployments..."
    ./deploy.sh --helm-cleanup
    
    print_status "Cleaning up monitoring stack..."
    if helm status prometheus-stack -n monitoring &> /dev/null; then
        helm uninstall prometheus-stack -n monitoring
    fi
    kubectl delete namespace monitoring --ignore-not-found=true
    
    print_status "Cleaning up CloudWatch..."
    kubectl delete namespace amazon-cloudwatch --ignore-not-found=true
    
    print_success "🎉 Cleanup completed!"
}

# Main execution
case "$1" in
    helm-demo)
        helm_demo
        ;;
    monitoring-demo)
        monitoring_demo
        ;;
    full-demo)
        full_demo
        ;;
    status)
        status_demo
        ;;
    cleanup)
        cleanup_demo
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        print_error "Unknown option: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
