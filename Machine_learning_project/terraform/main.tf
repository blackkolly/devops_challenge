# main.tf
# Example: EKS cluster resource (simplified)
provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "mlops-eks-cluster"
  cluster_version = "1.21"
  subnets         = ["subnet-xxxxxx"]
  vpc_id          = "vpc-xxxxxx"
}
