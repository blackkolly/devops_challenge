#!/bin/bash

# Complete EKS Deployment Script for Flask E-commerce Application
# This script handles the entire deployment process from cluster creation to application deployment

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="${CLUSTER_NAME:-flask-ecommerce-production-2024}"
REGION="${AWS_REGION:-us-west-2}"
NAMESPACE="${NAMESPACE:-flask-ecommerce}"
RELEASE_NAME="${RELEASE_NAME:-flask-ecommerce}"
APP_VERSION="${APP_VERSION:-latest}"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing_tools=()
    
    if ! command -v aws &> /dev/null; then
        missing_tools+=("aws-cli")
    fi
    
    if ! command -v eksctl &> /dev/null; then
        missing_tools+=("eksctl")
    fi
    
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi
    
    if ! command -v helm &> /dev/null; then
        missing_tools+=("helm")
    fi
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install missing tools and try again"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured"
        log_info "Run 'aws configure' to set up credentials"
        exit 1
    fi
    
    log_success "All prerequisites are satisfied"
}

create_eks_cluster() {
    log_info "Creating EKS cluster: $CLUSTER_NAME"
    
    # Check if cluster already exists
    if eksctl get cluster --name $CLUSTER_NAME --region $REGION &> /dev/null; then
        log_warning "Cluster $CLUSTER_NAME already exists"
        log_info "Updating kubeconfig..."
        aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
        return 0
    fi
    
    # Create cluster with Kubernetes version 1.28
    eksctl create cluster \
        --name=$CLUSTER_NAME \
        --region=$REGION \
        --version=1.28 \
        --nodegroup-name=flask-ecommerce-nodes \
        --node-type=t3.medium \
        --nodes-min=2 \
        --nodes-max=10 \
        --nodes=3 \
        --managed \
        --enable-ssm \
        --asg-access \
        --external-dns-access \
        --full-ecr-access \
        --appmesh-access \
        --alb-ingress-access \
        --with-oidc \
        --spot
    
    log_success "EKS cluster created successfully"
}

setup_cluster_components() {
    log_info "Setting up cluster components..."
    
    # Update kubeconfig
    aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
    
    # Install AWS Load Balancer Controller
    log_info "Installing AWS Load Balancer Controller..."
    
    # Download IAM policy
    curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
    
    # Create IAM policy
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam_policy.json || true
    
    # Create service account
    eksctl create iamserviceaccount \
        --cluster=$CLUSTER_NAME \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name=AmazonEKSLoadBalancerControllerRole \
        --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy \
        --approve \
        --region=$REGION \
        --override-existing-serviceaccounts || true
    
    # Add Helm repository and install controller
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    
    helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$CLUSTER_NAME \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller
    
    # Install EBS CSI Driver
    log_info "Installing EBS CSI Driver..."
    eksctl create iamserviceaccount \
        --name ebs-csi-controller-sa \
        --namespace kube-system \
        --cluster $CLUSTER_NAME \
        --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
        --approve \
        --override-existing-serviceaccounts \
        --region=$REGION || true
    
    eksctl create addon --name aws-ebs-csi-driver --cluster $CLUSTER_NAME --force || true
    
    # Create GP3 storage class
    kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  fsType: ext4
  encrypted: "true"
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
EOF
    
    # Install Metrics Server
    log_info "Installing Metrics Server..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    # Install Cluster Autoscaler
    log_info "Installing Cluster Autoscaler..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
    
    # Configure Cluster Autoscaler
    kubectl patch deployment cluster-autoscaler \
        -n kube-system \
        -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict":"false"}}}}}'
    
    kubectl patch deployment cluster-autoscaler \
        -n kube-system \
        -p '{"spec":{"template":{"spec":{"containers":[{"name":"cluster-autoscaler","command":["./cluster-autoscaler","--v=4","--stderrthreshold=info","--cloud-provider=aws","--skip-nodes-with-local-storage=false","--expander=least-waste","--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/'$CLUSTER_NAME'"]}]}}}}'
    
    # Clean up temporary files
    rm -f iam_policy.json
    
    log_success "Cluster components installed successfully"
}

build_and_push_image() {
    log_info "Building and pushing Docker image..."
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    ECR_REGISTRY="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
    IMAGE_NAME="flask-ecommerce"
    
    # Create ECR repository if it doesn't exist
    aws ecr describe-repositories --repository-names $IMAGE_NAME --region $REGION 2>/dev/null || \
    aws ecr create-repository --repository-name $IMAGE_NAME --region $REGION
    
    # Get ECR login token
    aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
    
    # Build and push image
    cd ../flask\ web\ application
    docker build -t $IMAGE_NAME:$APP_VERSION .
    docker tag $IMAGE_NAME:$APP_VERSION $ECR_REGISTRY/$IMAGE_NAME:$APP_VERSION
    docker push $ECR_REGISTRY/$IMAGE_NAME:$APP_VERSION
    cd ../kubernetes-application
    
    log_success "Docker image built and pushed successfully"
}

install_monitoring() {
    log_info "Installing monitoring stack..."
    
    # Add Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    
    # Install Prometheus and Grafana
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --set grafana.adminPassword=admin123 \
        --set grafana.service.type=LoadBalancer \
        --set prometheus.prometheusSpec.retention=30d \
        --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=20Gi \
        --wait
    
    log_success "Monitoring stack installed successfully"
}

deploy_application() {
    log_info "Deploying Flask E-commerce application..."
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    ECR_REGISTRY="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
    IMAGE_NAME="flask-ecommerce"
    
    # Create namespace
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    # Deploy using Helm
    helm upgrade --install $RELEASE_NAME ./helm-chart/flask-ecommerce \
        --namespace $NAMESPACE \
        --set image.repository=$ECR_REGISTRY/$IMAGE_NAME \
        --set image.tag=$APP_VERSION \
        --set ingress.hosts[0].host=flask-ecommerce-$(openssl rand -hex 4).example.com \
        --wait \
        --timeout=10m
    
    log_success "Application deployed successfully"
}

wait_for_deployment() {
    log_info "Waiting for deployment to be ready..."
    
    # Wait for deployment
    kubectl wait --for=condition=available --timeout=600s deployment/$RELEASE_NAME -n $NAMESPACE
    
    # Wait for HPA to be ready
    kubectl wait --for=condition=Ready --timeout=300s hpa/$RELEASE_NAME -n $NAMESPACE || true
    
    log_success "Deployment is ready"
}

display_access_info() {
    log_info "Getting access information..."
    
    # Get ALB URL
    ALB_DNS=$(kubectl get ingress $RELEASE_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")
    
    # Get Grafana URL
    GRAFANA_URL=$(kubectl get svc prometheus-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")
    
    echo ""
    echo "=========================================="
    echo "🚀 Deployment Completed Successfully! 🚀"
    echo "=========================================="
    echo ""
    echo "📊 Application Information:"
    echo "  Cluster: $CLUSTER_NAME"
    echo "  Region: $REGION"
    echo "  Namespace: $NAMESPACE"
    echo "  Release: $RELEASE_NAME"
    echo ""
    echo "🌐 Access URLs:"
    echo "  Application: http://$ALB_DNS"
    echo "  Grafana: http://$GRAFANA_URL (admin/admin123)"
    echo ""
    echo "📋 Useful Commands:"
    echo "  kubectl get pods -n $NAMESPACE"
    echo "  kubectl logs -f deployment/$RELEASE_NAME -n $NAMESPACE"
    echo "  kubectl get hpa -n $NAMESPACE -w"
    echo "  helm status $RELEASE_NAME -n $NAMESPACE"
    echo ""
    echo "🔧 Monitoring:"
    echo "  kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring"
    echo "  kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring"
    echo ""
    echo "🧪 Load Testing:"
    echo "  kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh"
    echo "  # In the pod: while true; do wget -q -O- http://$RELEASE_NAME.$NAMESPACE/; done"
    echo ""
    echo "⚠️  Note: It may take 3-5 minutes for the ALB to be fully provisioned"
    echo "=========================================="
}

run_health_checks() {
    log_info "Running health checks..."
    
    # Check cluster health
    kubectl cluster-info
    
    # Check node status
    kubectl get nodes
    
    # Check system pods
    kubectl get pods -n kube-system --field-selector=status.phase!=Running 2>/dev/null | grep -v "No resources found" || true
    
    # Check application pods
    kubectl get pods -n $NAMESPACE
    
    # Check HPA status
    kubectl get hpa -n $NAMESPACE
    
    # Check services
    kubectl get svc -n $NAMESPACE
    
    log_success "Health checks completed"
}

# Main execution
main() {
    log_info "Starting EKS deployment for Flask E-commerce application"
    
    check_prerequisites
    create_eks_cluster
    setup_cluster_components
    build_and_push_image
    install_monitoring
    deploy_application
    wait_for_deployment
    run_health_checks
    display_access_info
    
    log_success "Deployment completed successfully!"
}

# Handle script interruption
trap 'log_error "Script interrupted"; exit 1' INT TERM

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
