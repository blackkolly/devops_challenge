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
AWS_REGION="${AWS_REGION:-us-west-2}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text 2>/dev/null)}"
ECR_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"

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
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to build Docker image
build_image() {
    print_status "Building Docker image for AWS ECR..."
    
    # Check if AWS CLI is configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Get AWS account ID if not set
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        ECR_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
    fi
    
    print_status "Using ECR repository: $ECR_REPOSITORY"
    
    # Create ECR repository if it doesn't exist
    aws ecr describe-repositories --repository-names $IMAGE_NAME --region $AWS_REGION &> /dev/null || {
        print_status "Creating ECR repository: $IMAGE_NAME"
        aws ecr create-repository --repository-name $IMAGE_NAME --region $AWS_REGION
    }
    
    # Login to ECR
    print_status "Logging into Amazon ECR..."
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY
    
    cd ../flask\ web\ application
    
    # Build image with ECR tag
    print_status "Building Docker image..."
    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
    
    # Tag for ECR
    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_REPOSITORY}:${IMAGE_TAG}
    
    # Push to ECR
    print_status "Pushing image to Amazon ECR..."
    docker push ${ECR_REPOSITORY}:${IMAGE_TAG}
    
    cd ../kubernetes-application
    
    print_success "Docker image built and pushed to ECR successfully"
    echo "Image URI: ${ECR_REPOSITORY}:${IMAGE_TAG}"
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
    
    # Note: PVC will bind when first pod uses it (WaitForFirstConsumer mode)
    print_status "PVC created successfully (will bind when first pod uses it)"
    
    print_success "Storage deployed"
}

# Function to deploy application
deploy_app() {
    print_status "Deploying Flask application for AWS EKS..."
    
    # Set the ECR image URI
    ECR_IMAGE_URI="${ECR_REPOSITORY}:${IMAGE_TAG}"
    
    # Update image in deployment with ECR URI
    sed "s|image: flask-ecommerce:latest|image: ${ECR_IMAGE_URI}|g" deployment.yaml | kubectl apply -f -
    
    kubectl apply -f nginx-deployment.yaml
    kubectl apply -f service.yaml
    kubectl apply -f aws-loadbalancer-service.yaml
    kubectl apply -f rbac.yaml
    
    print_success "Application deployed with ECR image: ${ECR_IMAGE_URI}"
    print_status "AWS-optimized LoadBalancer service created for us-west-2"
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
    
    # Get AWS LoadBalancer URL
    echo ""
    echo "Checking AWS LoadBalancer status..."
    LB_HOSTNAME=$(kubectl get service flask-app-loadbalancer-aws --namespace=$NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    if [ ! -z "$LB_HOSTNAME" ]; then
        echo "🌐 AWS LoadBalancer URL: http://$LB_HOSTNAME"
    else
        echo "⏳ AWS LoadBalancer is provisioning... (this may take 2-5 minutes)"
    fi
    
    # Get nginx service URL
    NGINX_LB=$(kubectl get service nginx-service --namespace=$NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    if [ ! -z "$NGINX_LB" ]; then
        echo "🌐 Nginx LoadBalancer URL: http://$NGINX_LB"
    fi
    
    # Check NodePort
    NODEPORT=$(kubectl get service flask-ecommerce-nodeport --namespace=$NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    if [ ! -z "$NODEPORT" ]; then
        echo "🌐 NodePort URL: http://<node-ip>:$NODEPORT"
        
        # Get actual node IPs
        NODE_IPS=($(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'))
        if [ ${#NODE_IPS[@]} -gt 0 ]; then
            echo "Available node URLs:"
            for NODE_IP in "${NODE_IPS[@]}"; do
                echo "  http://$NODE_IP:$NODEPORT"
            done
        fi
    fi
    
    echo ""
    echo "🎉 Flask E-Commerce application deployed successfully to AWS EKS us-west-2!"
    echo ""
    echo "📝 Note: AWS LoadBalancers may take 2-5 minutes to become fully available"
}

# Function to cleanup deployment
cleanup() {
    print_warning "Cleaning up deployment..."
    
    kubectl delete -f . --ignore-not-found=true
    kubectl delete namespace $NAMESPACE --ignore-not-found=true
    
    print_success "Cleanup completed"
}

# Function to completely cleanup all AWS resources
aws_cleanup() {
    print_warning "🗑️  COMPLETE AWS CLEANUP - This will delete ALL AWS resources!"
    echo ""
    echo "This will delete:"
    echo "• EKS Cluster: flask-ecommerce-production-2024"
    echo "• ECR Repository: flask-ecommerce"
    echo "• All associated VPCs, Security Groups, Load Balancers"
    echo "• All EBS volumes and network interfaces"
    echo ""
    read -p "Are you sure you want to proceed? Type 'DELETE' to confirm: " confirm
    
    if [ "$confirm" != "DELETE" ]; then
        print_warning "Cleanup cancelled"
        return 0
    fi
    
    print_status "Starting complete AWS cleanup..."
    
    # 1. Delete Kubernetes resources first
    print_status "1. Deleting Kubernetes resources..."
    kubectl delete -f . --ignore-not-found=true --timeout=60s || true
    kubectl delete namespace $NAMESPACE --ignore-not-found=true --timeout=60s || true
    
    # 2. Delete any LoadBalancer services to clean up ELBs
    print_status "2. Cleaning up LoadBalancer services..."
    kubectl get svc --all-namespaces -o json | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "\(.metadata.namespace) \(.metadata.name)"' | while read ns name; do
        if [ ! -z "$name" ]; then
            echo "Deleting LoadBalancer service: $name in namespace: $ns"
            kubectl delete svc "$name" -n "$ns" --ignore-not-found=true || true
        fi
    done
    
    # 3. Delete ECR repository
    print_status "3. Deleting ECR repository..."
    aws ecr describe-repositories --region us-west-2 --repository-names flask-ecommerce >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        print_status "Deleting ECR repository: flask-ecommerce"
        aws ecr delete-repository --region us-west-2 --repository-name flask-ecommerce --force || print_warning "Failed to delete ECR repository"
    else
        print_status "ECR repository flask-ecommerce not found or already deleted"
    fi
    
    # 4. Delete EKS cluster (this will also delete node groups)
    print_status "4. Deleting EKS cluster..."
    aws eks describe-cluster --name flask-ecommerce-production-2024 --region us-west-2 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        print_status "Deleting EKS cluster: flask-ecommerce-production-2024 (this may take 10-15 minutes)"
        
        # Delete any remaining node groups first
        NODE_GROUPS=$(aws eks list-nodegroups --cluster-name flask-ecommerce-production-2024 --region us-west-2 --query 'nodegroups' --output text 2>/dev/null)
        for ng in $NODE_GROUPS; do
            if [ "$ng" != "None" ] && [ ! -z "$ng" ]; then
                print_status "Deleting node group: $ng"
                aws eks delete-nodegroup --cluster-name flask-ecommerce-production-2024 --nodegroup-name "$ng" --region us-west-2 || true
            fi
        done
        
        # Wait for node groups to be deleted
        print_status "Waiting for node groups to be deleted..."
        sleep 30
        
        # Delete the cluster
        eksctl delete cluster --name flask-ecommerce-production-2024 --region us-west-2 --wait || print_warning "Failed to delete EKS cluster with eksctl, trying AWS CLI"
        
        # Fallback to AWS CLI if eksctl fails
        aws eks delete-cluster --name flask-ecommerce-production-2024 --region us-west-2 || print_warning "Failed to delete EKS cluster"
    else
        print_status "EKS cluster flask-ecommerce-production-2024 not found or already deleted"
    fi
    
    # 5. Clean up any remaining EBS volumes
    print_status "5. Cleaning up EBS volumes..."
    EBS_VOLUMES=$(aws ec2 describe-volumes --region us-west-2 --filters "Name=tag:kubernetes.io/cluster/flask-ecommerce-production-2024,Values=owned" --query 'Volumes[?State==`available`].VolumeId' --output text 2>/dev/null)
    for volume in $EBS_VOLUMES; do
        if [ "$volume" != "None" ] && [ ! -z "$volume" ]; then
            print_status "Deleting EBS volume: $volume"
            aws ec2 delete-volume --volume-id "$volume" --region us-west-2 || true
        fi
    done
    
    # 6. Clean up security groups (after a delay to ensure everything is detached)
    print_status "6. Cleaning up security groups (waiting 60 seconds for resources to detach)..."
    sleep 60
    
    # Get security groups for the cluster
    SECURITY_GROUPS=$(aws ec2 describe-security-groups --region us-west-2 --filters "Name=tag:kubernetes.io/cluster/flask-ecommerce-production-2024,Values=owned" --query 'SecurityGroups[].GroupId' --output text 2>/dev/null)
    for sg in $SECURITY_GROUPS; do
        if [ "$sg" != "None" ] && [ ! -z "$sg" ]; then
            print_status "Deleting security group: $sg"
            aws ec2 delete-security-group --group-id "$sg" --region us-west-2 || print_warning "Could not delete security group $sg (may still be in use)"
        fi
    done
    
    # 7. Clean up any remaining network interfaces
    print_status "7. Cleaning up network interfaces..."
    ENI_IDS=$(aws ec2 describe-network-interfaces --region us-west-2 --filters "Name=tag:kubernetes.io/cluster/flask-ecommerce-production-2024,Values=owned" --query 'NetworkInterfaces[?Status==`available`].NetworkInterfaceId' --output text 2>/dev/null)
    for eni in $ENI_IDS; do
        if [ "$eni" != "None" ] && [ ! -z "$eni" ]; then
            print_status "Deleting network interface: $eni"
            aws ec2 delete-network-interface --network-interface-id "$eni" --region us-west-2 || true
        fi
    done
    
    # 8. List any remaining resources for manual cleanup
    print_status "8. Checking for any remaining resources..."
    
    echo ""
    echo "Checking for any remaining resources that may need manual cleanup:"
    
    # Check for remaining Load Balancers
    LBS=$(aws elbv2 describe-load-balancers --region us-west-2 --query 'LoadBalancers[?contains(LoadBalancerName, `flask`) || contains(LoadBalancerName, `k8s`)].LoadBalancerArn' --output text 2>/dev/null)
    if [ ! -z "$LBS" ] && [ "$LBS" != "None" ]; then
        echo "⚠️  Remaining Load Balancers found:"
        echo "$LBS"
    fi
    
    # Check for remaining VPCs
    VPCS=$(aws ec2 describe-vpcs --region us-west-2 --filters "Name=tag:Name,Values=*eks*" --query 'Vpcs[].VpcId' --output text 2>/dev/null)
    if [ ! -z "$VPCS" ] && [ "$VPCS" != "None" ]; then
        echo "⚠️  Remaining EKS VPCs found:"
        echo "$VPCS"
    fi
    
    # 9. Clean up kubeconfig
    print_status "9. Cleaning up kubeconfig..."
    kubectl config delete-context arn:aws:eks:us-west-2:*:cluster/flask-ecommerce-production-2024 2>/dev/null || true
    kubectl config delete-cluster arn:aws:eks:us-west-2:*:cluster/flask-ecommerce-production-2024 2>/dev/null || true
    
    print_success "🎉 AWS cleanup completed!"
    echo ""
    echo "✅ Deleted:"
    echo "• Kubernetes resources and namespace"
    echo "• ECR repository: flask-ecommerce"
    echo "• EKS cluster: flask-ecommerce-production-2024"
    echo "• Associated EBS volumes"
    echo "• Security groups and network interfaces"
    echo "• Kubeconfig entries"
    echo ""
    echo "Note: If you see any warnings above, some resources may need to be deleted manually"
    echo "from the AWS Console due to dependencies or timing issues."
}

# Function to setup ECR repository
setup_ecr() {
    print_status "Setting up Amazon ECR repository..."
    
    # Get AWS account ID if not set
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        ECR_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
    fi
    
    # Create ECR repository if it doesn't exist
    if ! aws ecr describe-repositories --repository-names $IMAGE_NAME --region $AWS_REGION &> /dev/null; then
        print_status "Creating ECR repository: $IMAGE_NAME"
        aws ecr create-repository --repository-name $IMAGE_NAME --region $AWS_REGION
        
        # Set lifecycle policy to manage old images
        aws ecr put-lifecycle-policy --repository-name $IMAGE_NAME --region $AWS_REGION \
            --lifecycle-policy-text '{
                "rules": [
                    {
                        "rulePriority": 1,
                        "description": "Keep last 10 images",
                        "selection": {
                            "tagStatus": "any",
                            "countType": "imageCountMoreThan",
                            "countNumber": 10
                        },
                        "action": {
                            "type": "expire"
                        }
                    }
                ]
            }' > /dev/null 2>&1 || print_warning "Could not set lifecycle policy"
        
        print_success "ECR repository created with lifecycle policy"
    else
        print_status "ECR repository already exists: $IMAGE_NAME"
    fi
    
    print_success "ECR setup completed"
    echo "Repository URI: ${ECR_REPOSITORY}"
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS] [IMAGE_TAG]"
    echo ""
    echo "Deploy Flask E-Commerce application to Kubernetes"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -c, --cleanup     Clean up the deployment"
    echo "  --aws-cleanup     Delete ALL AWS resources (EKS, ECR, etc.)"
    echo "  -b, --build       Build Docker image before deployment"
    echo "  -s, --status      Show deployment status only"
    echo "  -t, --troubleshoot Run network troubleshooting"
    echo "  -f, --fix         Attempt to fix networking issues"
    echo "  -T, --test        Test external access to the application"
    echo "  --final-help      Show final troubleshooting recommendations"
    echo ""
    echo "Environment Variables:"
    echo "  AWS_REGION       AWS region (default: us-west-2)"
    echo "  AWS_ACCOUNT_ID   AWS account ID (auto-detected if not set)"
    echo "  SECRET_KEY       Application secret key (optional, will be generated)"
    echo "  KUBECONFIG       Path to kubeconfig file (default: ~/.kube/config)"
    echo ""
    echo "Examples:"
    echo "  $0                     # Deploy with latest tag from ECR"
    echo "  $0 v1.0.0             # Deploy with specific tag from ECR"
    echo "  $0 --build v1.0.0     # Build, push to ECR, and deploy"
    echo "  $0 --cleanup          # Clean up deployment"
    echo "  $0 --aws-cleanup      # Delete ALL AWS resources (EKS, ECR, etc.)"
    echo "  $0 --status           # Show status only"
    echo "  $0 --troubleshoot     # Run network diagnostics"
    echo "  $0 --fix              # Fix networking issues"
    echo "  $0 --test             # Test external access"
    echo ""
    echo "Prerequisites:"
    echo "  • AWS CLI configured with proper credentials"
    echo "  • kubectl configured for EKS cluster"
    echo "  • Docker installed and running"
    echo "  • eksctl installed (for cluster management)"
}

# Function to troubleshoot network connectivity
troubleshoot_network() {
    print_status "Running network troubleshooting..."
    
    echo ""
    echo "=== EKS Cluster Network Diagnostics ==="
    
    # Check node details
    echo ""
    echo "1. EKS Nodes with External IPs:"
    kubectl get nodes -o wide | grep -E "NAME|Ready"
    
    # Check services
    echo ""
    echo "2. Services in flask-ecommerce namespace:"
    kubectl get svc -n $NAMESPACE -o wide
    
    # Check endpoints
    echo ""
    echo "3. Service Endpoints:"
    kubectl get endpoints -n $NAMESPACE
    
    # Check pods
    echo ""
    echo "4. Running Pods:"
    kubectl get pods -n $NAMESPACE -o wide
    
    # Check security groups
    echo ""
    echo "5. Checking EKS Security Groups..."
    NODE_GROUP_NAME=$(aws eks describe-cluster --name flask-ecommerce-production-2024 --query 'cluster.nodegroup' --output text 2>/dev/null || echo "unknown")
    
    # Get VPC and security group info
    VPC_ID=$(aws eks describe-cluster --name flask-ecommerce-production-2024 --query 'cluster.resourcesVpcConfig.vpcId' --output text 2>/dev/null)
    if [ "$VPC_ID" != "None" ] && [ ! -z "$VPC_ID" ]; then
        echo "VPC ID: $VPC_ID"
        
        # Check security groups
        echo ""
        echo "Security Groups for EKS cluster:"
        aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[*].[GroupId,GroupName,Description]' --output table 2>/dev/null || echo "Cannot retrieve security groups"
    fi
    
    # Test internal connectivity
    echo ""
    echo "6. Testing Internal Pod Connectivity:"
    FLASK_POD=$(kubectl get pods -n $NAMESPACE -l app=flask-ecommerce -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ ! -z "$FLASK_POD" ]; then
        echo "Testing connectivity to Flask pod: $FLASK_POD"
        kubectl exec -n $NAMESPACE $FLASK_POD -- curl -s http://localhost:5000/ | head -c 100 || echo "Internal connectivity test failed"
    fi
    
    # Check AWS Load Balancer Controller
    echo ""
    echo "7. Checking AWS Load Balancer Controller:"
    kubectl get pods -n kube-system | grep aws-load-balancer-controller || echo "AWS Load Balancer Controller not found"
    
    print_success "Network troubleshooting completed"
}

# Function to fix common EKS networking issues
fix_networking() {
    print_status "Attempting to fix common EKS networking issues..."
    
    # Install AWS Load Balancer Controller if not present
    if ! kubectl get pods -n kube-system | grep aws-load-balancer-controller &> /dev/null; then
        print_status "Installing AWS Load Balancer Controller..."
        
        # Create IAM OIDC provider
        aws eks describe-cluster --name flask-ecommerce-production-2024 --query "cluster.identity.oidc.issuer" --output text 2>/dev/null || print_warning "Cannot get OIDC issuer"
        
        # Download and apply AWS Load Balancer Controller
        kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master" || print_warning "Failed to install LB controller CRDs"
    fi
    
    # Create a proper LoadBalancer service with annotations
    print_status "Creating optimized LoadBalancer service..."
    
    cat > flask-loadbalancer-fixed.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: flask-app-loadbalancer
  namespace: $NAMESPACE
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 5000
    protocol: TCP
  selector:
    app: flask-ecommerce
    tier: backend
EOF
    
    kubectl apply -f flask-loadbalancer-fixed.yaml
    
    # Update security group rules more comprehensively
    print_status "Updating security group rules..."
    
    # Get the worker node security group
    CLUSTER_SG=$(aws eks describe-cluster --name flask-ecommerce-production-2024 --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text 2>/dev/null)
    NODE_SG=$(aws ec2 describe-instances --filters "Name=tag:kubernetes.io/cluster/flask-ecommerce-production-2024,Values=owned" --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' --output text 2>/dev/null | tr '\t' '\n' | sort -u)
    
    # Add rules to all relevant security groups
    for SG in $CLUSTER_SG $NODE_SG; do
        if [ ! -z "$SG" ] && [ "$SG" != "None" ]; then
            print_status "Adding rules to security group: $SG"
            
            # Add comprehensive port rules
            aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port 30000-32767 --cidr 0.0.0.0/0 2>/dev/null || echo "Rule already exists or failed"
            aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port 80 --cidr 0.0.0.0/0 2>/dev/null || echo "Rule already exists or failed"
            aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port 443 --cidr 0.0.0.0/0 2>/dev/null || echo "Rule already exists or failed"
            aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port 5000 --cidr 0.0.0.0/0 2>/dev/null || echo "Rule already exists or failed"
        fi
    done
    
    print_success "Networking fixes applied"
}

# Function to test external connectivity
test_external_access() {
    print_status "Testing external access to the application on AWS EKS us-west-2..."
    
    # Get node IPs
    NODE_IPS=($(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'))
    
    # Get NodePort services
    NODEPORTS=$(kubectl get svc -n $NAMESPACE -o jsonpath='{.items[?(@.spec.type=="NodePort")].spec.ports[*].nodePort}')
    
    echo ""
    echo "Available test URLs:"
    for NODE_IP in "${NODE_IPS[@]}"; do
        for PORT in $NODEPORTS; do
            echo "http://$NODE_IP:$PORT"
        done
    done
    
    echo ""
    echo "Testing connectivity (this may take a moment)..."
    
    # Test AWS LoadBalancer first
    AWS_LB_HOSTNAME=$(kubectl get svc -n $NAMESPACE flask-app-loadbalancer-aws -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    if [ ! -z "$AWS_LB_HOSTNAME" ]; then
        echo -n "Testing AWS LoadBalancer http://$AWS_LB_HOSTNAME ... "
        if curl -s --connect-timeout 10 --max-time 15 "http://$AWS_LB_HOSTNAME" > /dev/null 2>&1; then
            print_success "✅ AWS LoadBalancer ACCESSIBLE"
            echo "🎉 SUCCESS: Your application is accessible at http://$AWS_LB_HOSTNAME"
            return 0
        else
            echo "❌ AWS LoadBalancer not accessible yet (may take a few minutes)"
        fi
    else
        echo "⏳ AWS LoadBalancer still provisioning..."
    fi
    
    # Test each NodePort combination
    for NODE_IP in "${NODE_IPS[@]}"; do
        for PORT in $NODEPORTS; do
            echo -n "Testing http://$NODE_IP:$PORT ... "
            if curl -s --connect-timeout 5 --max-time 10 "http://$NODE_IP:$PORT" > /dev/null 2>&1; then
                print_success "✅ ACCESSIBLE"
                echo "🎉 SUCCESS: Your application is accessible at http://$NODE_IP:$PORT"
                return 0
            else
                echo "❌ Not accessible"
            fi
        done
    done
    
    # Test Nginx LoadBalancer if available
    NGINX_LB_HOSTNAME=$(kubectl get svc -n $NAMESPACE nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    if [ ! -z "$NGINX_LB_HOSTNAME" ]; then
        echo -n "Testing Nginx LoadBalancer http://$NGINX_LB_HOSTNAME ... "
        if curl -s --connect-timeout 10 --max-time 15 "http://$NGINX_LB_HOSTNAME" > /dev/null 2>&1; then
            print_success "✅ Nginx LoadBalancer ACCESSIBLE"
            echo "🎉 SUCCESS: Your application is accessible at http://$NGINX_LB_HOSTNAME"
            return 0
        else
            echo "❌ Nginx LoadBalancer not accessible yet"
        fi
    fi
    
    print_warning "External access test completed - no accessible URLs found yet"
    echo "💡 AWS LoadBalancers in us-west-2 typically take 2-5 minutes to become available"
    return 1
}

# Function to provide final troubleshooting steps
provide_final_steps() {
    print_status "Providing final troubleshooting recommendations..."
    
    echo ""
    echo "=== FINAL TROUBLESHOOTING STEPS ==="
    echo ""
    echo "1. Check if your ISP or firewall blocks high ports (30000-32767)"
    echo "2. Wait 5-10 minutes for LoadBalancer to provision"
    echo "3. Try accessing from a different network/device"
    echo "4. Use port-forward as alternative: kubectl port-forward -n $NAMESPACE svc/flask-app-service 8080:5000"
    echo "5. Check AWS VPC Route Tables and NACLs"
    echo ""
    echo "If still not working, the issue may be:"
    echo "• Network ACLs blocking traffic"
    echo "• ISP/Corporate firewall restrictions"
    echo "• AWS region-specific networking issues"
    echo "• EKS cluster networking misconfiguration"
    echo ""
    echo "Alternative access method:"
    echo "kubectl port-forward -n $NAMESPACE svc/flask-app-service 8080:5000"
    echo "Then visit: http://localhost:8080"
    
    print_success "Final troubleshooting guide provided"
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
        --aws-cleanup)
            aws_cleanup
            exit 0
            ;;
        -s|--status)
            show_status
            exit 0
            ;;
        -t|--troubleshoot)
            troubleshoot_network
            exit 0
            ;;
        -f|--fix)
            fix_networking
            exit 0
            ;;
        -T|--test)
            test_external_access
            exit 0
            ;;
        --final-help)
            provide_final_steps
            exit 0
            ;;
        -b|--build)
            IMAGE_TAG="${2:-latest}"
            check_prerequisites
            setup_ecr
            build_image
            ;;
        *)
            check_prerequisites
            setup_ecr
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
