#!/bin/bash

# Deploy Flask E-commerce Application to EKS using Helm
# This script deploys the application with all necessary components

set -e

# Configuration
CLUSTER_NAME="${CLUSTER_NAME:-flask-ecommerce-production-2024}"
REGION="${AWS_REGION:-us-west-2}"
NAMESPACE="${NAMESPACE:-flask-ecommerce}"
RELEASE_NAME="${RELEASE_NAME:-flask-ecommerce}"
CHART_PATH="${CHART_PATH:-./helm-chart/flask-ecommerce}"
VALUES_FILE="${VALUES_FILE:-./helm-chart/flask-ecommerce/values.yaml}"

echo "Deploying Flask E-commerce application to EKS..."

# Check if cluster context is set
CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "none")
if [[ $CURRENT_CONTEXT != *"$CLUSTER_NAME"* ]]; then
    echo "Setting up cluster context..."
    aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
fi

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Add required Helm repositories
echo "Adding Helm repositories..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Build and push Docker image (if ECR repository exists)
echo "Building and pushing Docker image..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
IMAGE_NAME="flask-ecommerce"
IMAGE_TAG="${IMAGE_TAG:-latest}"

# Create ECR repository if it doesn't exist
aws ecr describe-repositories --repository-names $IMAGE_NAME --region $REGION 2>/dev/null || \
aws ecr create-repository --repository-name $IMAGE_NAME --region $REGION

# Get ECR login token
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Build and push image
cd ../flask\ web\ application
docker build -t $IMAGE_NAME:$IMAGE_TAG .
docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG
docker push $ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG
cd ../kubernetes-application

# Install monitoring stack (Prometheus and Grafana)
echo "Installing monitoring stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin123 \
  --set grafana.service.type=LoadBalancer \
  --wait

# Deploy the Flask application
echo "Deploying Flask E-commerce application..."
helm upgrade --install $RELEASE_NAME $CHART_PATH \
  --namespace $NAMESPACE \
  --set image.repository=$ECR_REGISTRY/$IMAGE_NAME \
  --set image.tag=$IMAGE_TAG \
  --set ingress.hosts[0].host=flask-ecommerce-$(openssl rand -hex 4).elb.amazonaws.com \
  --values $VALUES_FILE \
  --wait \
  --timeout=10m

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/$RELEASE_NAME -n $NAMESPACE

# Get application URL
echo "Getting application URL..."
ALB_DNS=$(kubectl get ingress $RELEASE_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")

echo "=================================="
echo "Deployment completed successfully!"
echo "=================================="
echo "Namespace: $NAMESPACE"
echo "Release: $RELEASE_NAME"
echo "Application URL: http://$ALB_DNS"
echo ""
echo "Monitoring URLs:"
GRAFANA_URL=$(kubectl get svc prometheus-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")
echo "Grafana: http://$GRAFANA_URL (admin/admin123)"
echo ""
echo "Useful commands:"
echo "  kubectl get pods -n $NAMESPACE"
echo "  kubectl logs -f deployment/$RELEASE_NAME -n $NAMESPACE"
echo "  helm status $RELEASE_NAME -n $NAMESPACE"
echo "  kubectl describe ingress $RELEASE_NAME -n $NAMESPACE"
