#!/bin/bash

# EKS Cluster Setup Script
# This script creates an EKS cluster with all necessary components for the Flask e-commerce application

set -e

# Configuration
CLUSTER_NAME="${CLUSTER_NAME:-flask-ecommerce-production-2024}"
REGION="${AWS_REGION:-us-west-2}"
NODE_GROUP_NAME="${NODE_GROUP_NAME:-flask-ecommerce-nodes}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.medium}"
MIN_NODES="${MIN_NODES:-2}"
MAX_NODES="${MAX_NODES:-10}"
DESIRED_NODES="${DESIRED_NODES:-3}"

echo "Creating EKS cluster: $CLUSTER_NAME in region: $REGION"

# Check if eksctl is installed
if ! command -v eksctl &> /dev/null; then
    echo "eksctl is not installed. Please install it first."
    echo "Visit: https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install it first."
    echo "Visit: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "helm is not installed. Please install it first."
    echo "Visit: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Create EKS cluster
echo "Creating EKS cluster..."
eksctl create cluster \
  --name=$CLUSTER_NAME \
  --region=$REGION \
  --version=1.28 \
  --nodegroup-name=$NODE_GROUP_NAME \
  --node-type=$INSTANCE_TYPE \
  --nodes-min=$MIN_NODES \
  --nodes-max=$MAX_NODES \
  --nodes=$DESIRED_NODES \
  --managed \
  --enable-ssm \
  --asg-access \
  --external-dns-access \
  --full-ecr-access \
  --appmesh-access \
  --alb-ingress-access \
  --with-oidc

# Update kubeconfig
echo "Updating kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Install AWS Load Balancer Controller
echo "Installing AWS Load Balancer Controller..."
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json || true

# Get cluster OIDC issuer URL
OIDC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

# Create service account for AWS Load Balancer Controller
eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name=AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy \
  --approve \
  --region=$REGION

# Add eks-charts repository
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# Install EBS CSI Driver
echo "Installing EBS CSI Driver..."
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster $CLUSTER_NAME \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --override-existing-serviceaccounts \
  --region=$REGION

eksctl create addon --name aws-ebs-csi-driver --cluster $CLUSTER_NAME --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/AmazonEKS_EBS_CSI_DriverRole --force

# Create storage class for GP3
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
echo "Installing Metrics Server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Install Cluster Autoscaler
echo "Installing Cluster Autoscaler..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict":"false"}}}}}'

kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"cluster-autoscaler","command":["./cluster-autoscaler","--v=4","--stderrthreshold=info","--cloud-provider=aws","--skip-nodes-with-local-storage=false","--expander=least-waste","--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/'$CLUSTER_NAME'"]}]}}}}'

kubectl annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false" -n kube-system

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "EKS cluster setup completed successfully!"
echo "Cluster name: $CLUSTER_NAME"
echo "Region: $REGION"
echo "You can now deploy your application using Helm or kubectl"

# Clean up temporary files
rm -f iam_policy.json
