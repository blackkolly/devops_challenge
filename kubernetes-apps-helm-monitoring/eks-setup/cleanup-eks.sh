#!/bin/bash

# Cleanup EKS Cluster and Resources
# This script safely removes the EKS cluster and associated resources

set -e

# Configuration
CLUSTER_NAME="${CLUSTER_NAME:-flask-ecommerce-production-2024}"
REGION="${AWS_REGION:-us-west-2}"
NAMESPACE="${NAMESPACE:-flask-ecommerce}"
RELEASE_NAME="${RELEASE_NAME:-flask-ecommerce}"

echo "Cleaning up EKS cluster: $CLUSTER_NAME"

# Check if cluster exists
if ! eksctl get cluster --name $CLUSTER_NAME --region $REGION &>/dev/null; then
    echo "Cluster $CLUSTER_NAME not found in region $REGION"
    exit 1
fi

# Update kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Delete Helm releases
echo "Removing Helm releases..."
helm uninstall $RELEASE_NAME -n $NAMESPACE --ignore-not-found
helm uninstall prometheus -n monitoring --ignore-not-found

# Delete namespaces
echo "Deleting namespaces..."
kubectl delete namespace $NAMESPACE --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found

# Delete Load Balancer Controller
echo "Removing AWS Load Balancer Controller..."
helm uninstall aws-load-balancer-controller -n kube-system --ignore-not-found

# Delete service accounts
echo "Deleting service accounts..."
eksctl delete iamserviceaccount --cluster=$CLUSTER_NAME --name=aws-load-balancer-controller --namespace=kube-system --region=$REGION --wait || true
eksctl delete iamserviceaccount --cluster=$CLUSTER_NAME --name=ebs-csi-controller-sa --namespace=kube-system --region=$REGION --wait || true

# Delete IAM policies
echo "Deleting IAM policies..."
aws iam delete-policy --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy || true

# Delete ECR repository (optional - uncomment if you want to delete it)
# echo "Deleting ECR repository..."
# aws ecr delete-repository --repository-name flask-ecommerce --region $REGION --force || true

# Delete EKS cluster
echo "Deleting EKS cluster..."
eksctl delete cluster --name $CLUSTER_NAME --region $REGION --wait

echo "Cleanup completed successfully!"
echo "All resources for cluster $CLUSTER_NAME have been removed."
