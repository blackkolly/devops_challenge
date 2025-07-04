#!/bin/bash

# Kubernetes Deployment Script for Flask E-Commerce Application
# This script deploys the Flask application to a Kubernetes cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
NAMESPACE="flask-ecommerce"
IMAGE_NAME="flask-ecommerce"
IMAGE_TAG="${1:-latest}"
KUBECONFIG_PATH="${KUBECONFIG:-~/.kube/config}"

# Function to print colored output
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

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to build Docker image
build_image() {
    print_status "Building Docker image..."
    
    cd ../flask\ web\ application
    
    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
    
    # Tag for registry if needed
    if [ ! -z "$DOCKER_REGISTRY" ]; then
        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
        print_status "Pushing image to registry..."
        docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
    fi
    
    cd ../kubernetes-application
    
    print_success "Docker image built successfully"
}

# Function to create namespace
create_namespace() {
    print_status "Creating namespace..."
    
    kubectl apply -f namespace.yaml
    
    print_success "Namespace created/updated"
}

# Function to deploy secrets and configmaps
deploy_configs() {
    print_status "Deploying configurations..."
    
    # Generate secret key if not provided
    if [ -z "$SECRET_KEY" ]; then
        SECRET_KEY=$(openssl rand -base64 32)
        print_warning "Generated random SECRET_KEY. Store this safely: $SECRET_KEY"
    fi
    
    # Create secret with generated key
    kubectl create secret generic flask-app-secrets \
        --from-literal=SECRET_KEY="$SECRET_KEY" \
        --namespace=$NAMESPACE \
        --dry-run=client -o yaml | kubectl apply -f -
    
    kubectl apply -f configmap.yaml
    kubectl apply -f secret.yaml
    
    print_success "Configurations deployed"
}

# Function to deploy storage
deploy_storage() {
    print_status "Deploying storage..."
    
    kubectl apply -f persistent-volume.yaml
    
    # Wait for PVC to be bound
    kubectl wait --for=condition=Bound pvc/flask-db-pvc --namespace=$NAMESPACE --timeout=60s
    
    print_success "Storage deployed"
}

# Function to deploy application
deploy_app() {
    print_status "Deploying Flask application..."
    
    # Update image in deployment
    sed "s|image: flask-ecommerce:latest|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" deployment.yaml | kubectl apply -f -
    
    kubectl apply -f nginx-deployment.yaml
    kubectl apply -f service.yaml
    kubectl apply -f rbac.yaml
    
    print_success "Application deployed"
}

# Function to deploy ingress
deploy_ingress() {
    print_status "Deploying ingress..."
    
    kubectl apply -f ingress.yaml
    
    print_success "Ingress deployed"
}

# Function to deploy autoscaling
deploy_autoscaling() {
    print_status "Deploying autoscaling..."
    
    kubectl apply -f hpa.yaml
    kubectl apply -f pod-disruption-budget.yaml
    
    print_success "Autoscaling deployed"
}

# Function to deploy monitoring
deploy_monitoring() {
    print_status "Deploying monitoring..."
    
    if kubectl get crd servicemonitors.monitoring.coreos.com &> /dev/null; then
        kubectl apply -f monitoring.yaml
        print_success "Monitoring deployed"
    else
        print_warning "Prometheus Operator not found. Skipping monitoring deployment."
    fi
}

# Function to wait for deployment
wait_for_deployment() {
    print_status "Waiting for deployment to be ready..."
    
    kubectl wait --for=condition=available --timeout=300s deployment/flask-app-deployment --namespace=$NAMESPACE
    kubectl wait --for=condition=available --timeout=300s deployment/nginx-deployment --namespace=$NAMESPACE
    
    print_success "Deployment is ready"
}

# Function to show status
show_status() {
    print_status "Deployment status:"
    
    echo ""
    echo "Pods:"
    kubectl get pods --namespace=$NAMESPACE
    
    echo ""
    echo "Services:"
    kubectl get services --namespace=$NAMESPACE
    
    echo ""
    echo "Ingress:"
    kubectl get ingress --namespace=$NAMESPACE
    
    # Get service URL
    if kubectl get service nginx-service --namespace=$NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' &> /dev/null; then
        EXTERNAL_IP=$(kubectl get service nginx-service --namespace=$NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        if [ ! -z "$EXTERNAL_IP" ]; then
            echo ""
            echo "🌐 Application URL: http://$EXTERNAL_IP"
        fi
    fi
    
    # Check NodePort
    NODEPORT=$(kubectl get service flask-ecommerce-nodeport --namespace=$NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
    if [ ! -z "$NODEPORT" ]; then
        echo "🌐 NodePort URL: http://<node-ip>:$NODEPORT"
    fi
    
    echo ""
    echo "🎉 Flask E-Commerce application deployed successfully!"
}

# Function to cleanup deployment
cleanup() {
    print_warning "Cleaning up deployment..."
    
    kubectl delete -f . --ignore-not-found=true
    kubectl delete namespace $NAMESPACE --ignore-not-found=true
    
    print_success "Cleanup completed"
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS] [IMAGE_TAG]"
    echo ""
    echo "Deploy Flask E-Commerce application to Kubernetes"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -c, --cleanup  Clean up the deployment"
    echo "  -b, --build    Build Docker image before deployment"
    echo "  -s, --status   Show deployment status only"
    echo ""
    echo "Environment Variables:"
    echo "  DOCKER_REGISTRY  Docker registry URL (optional)"
    echo "  SECRET_KEY       Application secret key (optional, will be generated)"
    echo "  KUBECONFIG       Path to kubeconfig file (default: ~/.kube/config)"
    echo ""
    echo "Examples:"
    echo "  $0                     # Deploy with latest tag"
    echo "  $0 v1.0.0             # Deploy with specific tag"
    echo "  $0 --build v1.0.0     # Build and deploy"
    echo "  $0 --cleanup          # Clean up deployment"
    echo "  $0 --status           # Show status only"
}

# Main function
main() {
    echo "🚀 Flask E-Commerce Kubernetes Deployment"
    echo "=========================================="
    
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--cleanup)
            cleanup
            exit 0
            ;;
        -s|--status)
            show_status
            exit 0
            ;;
        -b|--build)
            IMAGE_TAG="${2:-latest}"
            check_prerequisites
            build_image
            ;;
        *)
            check_prerequisites
            ;;
    esac
    
    # Deploy application
    create_namespace
    deploy_configs
    deploy_storage
    deploy_app
    deploy_ingress
    deploy_autoscaling
    deploy_monitoring
    wait_for_deployment
    show_status
}

# Run main function with all arguments
main "$@"
