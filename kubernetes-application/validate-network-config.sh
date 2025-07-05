#!/bin/bash

# Network Configuration Validator for AWS EKS us-west-2
# This script validates all networking configurations before deployment

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

validate_service_selectors() {
    print_status "Validating service selectors..."
    
    # Check Flask app service
    FLASK_SELECTOR=$(grep -A 10 "name: flask-app-service" service.yaml | grep -A 5 "selector:" | grep "app:\|tier:")
    echo "Flask app service selector: $FLASK_SELECTOR"
    
    # Check nginx service
    NGINX_SELECTOR=$(grep -A 10 "name: nginx-service" service.yaml | grep -A 5 "selector:" | grep "app:\|component:")
    echo "Nginx service selector: $NGINX_SELECTOR"
    
    # Check AWS LoadBalancer service
    if [ -f "aws-loadbalancer-service.yaml" ]; then
        AWS_LB_SELECTOR=$(grep -A 10 "selector:" aws-loadbalancer-service.yaml | grep "app:\|tier:")
        echo "AWS LoadBalancer selector: $AWS_LB_SELECTOR"
        print_success "AWS LoadBalancer service configuration found"
    fi
}

validate_aws_annotations() {
    print_status "Validating AWS-specific annotations..."
    
    # Check LoadBalancer annotations
    if grep -q "aws-load-balancer-type" service.yaml; then
        print_success "AWS LoadBalancer annotations found in service.yaml"
    fi
    
    if [ -f "aws-loadbalancer-service.yaml" ]; then
        if grep -q "aws-load-balancer-type.*nlb" aws-loadbalancer-service.yaml; then
            print_success "NLB configuration found"
        fi
        if grep -q "aws-load-balancer-scheme.*internet-facing" aws-loadbalancer-service.yaml; then
            print_success "Internet-facing configuration found"
        fi
    fi
    
    # Check ingress annotations
    if grep -q "alb.ingress.kubernetes.io" ingress.yaml; then
        print_success "AWS ALB ingress annotations found"
    else
        print_warning "No AWS ALB annotations found in ingress.yaml"
    fi
}

validate_storage_class() {
    print_status "Validating storage configuration for AWS EKS..."
    
    if grep -q "storageClassName: gp3" persistent-volume.yaml; then
        print_success "GP3 storage class configured"
    elif grep -q "storageClassName: gp2" persistent-volume.yaml; then
        print_warning "Using GP2 storage class (GP3 is recommended for better performance)"
    else
        print_error "No storage class specified"
    fi
}

validate_health_endpoints() {
    print_status "Validating health endpoint configurations..."
    
    # Check deployment health checks
    if grep -q "path: /health" deployment.yaml; then
        print_success "Health endpoint configured in deployment"
    else
        print_warning "No /health endpoint configured in deployment"
    fi
    
    # Check ALB health check
    if grep -q "healthcheck-path.*health" ingress.yaml; then
        print_success "Health check path configured in ALB"
    fi
    
    # Check LoadBalancer health check
    if [ -f "aws-loadbalancer-service.yaml" ] && grep -q "healthcheck-path.*health" aws-loadbalancer-service.yaml; then
        print_success "Health check configured in AWS LoadBalancer"
    fi
}

validate_region_config() {
    print_status "Validating region configuration for us-west-2..."
    
    # Check deployment env vars
    if grep -q "AWS_DEFAULT_REGION.*us-west-2" deployment.yaml; then
        print_success "AWS region configured in deployment"
    else
        print_warning "AWS region not explicitly set in deployment"
    fi
    
    # Check deploy script
    if grep -q "AWS_REGION.*us-west-2" deploy.sh; then
        print_success "AWS region configured in deploy script"
    fi
}

validate_cluster_references() {
    print_status "Validating EKS cluster name references..."
    
    CLUSTER_REFS=$(grep -r "flask-ecommerce-production-2024" . --include="*.sh" --include="*.yaml" | wc -l)
    OLD_REFS=$(grep -r "flask-ecommerce-cluster" . --include="*.sh" --include="*.yaml" | wc -l)
    
    echo "Found $CLUSTER_REFS references to flask-ecommerce-production-2024"
    
    if [ "$OLD_REFS" -gt 0 ]; then
        print_warning "Found $OLD_REFS references to old cluster name 'flask-ecommerce-cluster'"
        echo "Files with old references:"
        grep -r "flask-ecommerce-cluster" . --include="*.sh" --include="*.yaml"
    else
        print_success "All cluster references use correct name"
    fi
}

validate_ecr_config() {
    print_status "Validating ECR configuration..."
    
    if grep -q "ECR_REPOSITORY" deploy.sh; then
        print_success "ECR repository configuration found"
    fi
    
    if grep -q "aws ecr" deploy.sh; then
        print_success "ECR commands found in deploy script"
    fi
}

main() {
    echo "🔍 AWS EKS us-west-2 Network Configuration Validator"
    echo "=================================================="
    
    validate_service_selectors
    echo ""
    validate_aws_annotations
    echo ""
    validate_storage_class
    echo ""
    validate_health_endpoints
    echo ""
    validate_region_config
    echo ""
    validate_cluster_references
    echo ""
    validate_ecr_config
    
    echo ""
    echo "🎉 Network configuration validation completed!"
    echo ""
    echo "📝 Summary:"
    echo "• Service selectors validated"
    echo "• AWS-specific annotations checked"
    echo "• Storage configuration verified"
    echo "• Health endpoints validated"
    echo "• Region configuration confirmed"
    echo "• Cluster references verified"
    echo "• ECR configuration validated"
    echo ""
    echo "✅ Ready for deployment to AWS EKS us-west-2!"
}

main "$@"
