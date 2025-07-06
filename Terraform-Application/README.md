# Terraform-based AWS Infrastructure for Flask E-commerce App

This directory contains a complete Infrastructure-as-Code (IaC) solution to deploy the Flask e-commerce application on AWS using Terraform. It provisions a secure, production-ready environment with VPC, subnets, security groups, EC2 instances, ALB, and S3 for state management.

## Features
- Modular, versioned Terraform code
- Custom VPC with public/private subnets
- Internet Gateway, NAT Gateway
- Security groups for web/app/database
- EC2 auto-scaling group for Flask app
- Application Load Balancer (ALB)
- S3 bucket for static/media files and remote state
- Outputs for endpoints and resources
- Example test (Terratest) for infrastructure validation

## Directory Structure
```
terraform-application/
├── main.tf            # Root module
├── variables.tf       # Input variables
├── outputs.tf         # Outputs
├── providers.tf       # Provider config
├── backend.tf         # Remote state backend (S3)
├── vpc.tf             # VPC, subnets, gateways
├── security.tf        # Security groups
├── ec2.tf             # EC2, launch template, ASG
├── alb.tf             # Application Load Balancer
├── s3.tf              # S3 bucket for app/static
├── versions.tf        # Required provider versions
├── test_infra.go      # Terratest example
└── README.md          # This file
```

## Usage

1. **Configure AWS credentials** (via environment variables or AWS CLI profile).
2. **Edit variables** in `variables.tf` as needed.
3. **Initialize Terraform**
   ```bash
   terraform init
   ```
4. **Plan infrastructure**
   ```bash
   terraform plan
   ```
5. **Apply infrastructure**
   ```bash
   terraform apply
   ```
6. **Deploy Flask app**
   - SSH into EC2 instance(s) and deploy your Dockerized Flask app, or use a user_data script for automated deployment.

## Testing
- See `test_infra.go` for a Terratest example to validate the ALB endpoint.

## Cleanup
```bash
terraform destroy
```

---

For detailed documentation, see comments in each `.tf` file.
