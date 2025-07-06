variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "eu-north-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name."
  type        = string
  default     = "default"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for Flask app."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access."
  type        = string
  default     = ""
}

variable "app_ami" {
  description = "AMI ID for Flask app EC2 instances."
  type        = string
  default     = "ami-0da6daf5e3e5ea2a8" # Amazon Linux 2
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in ASG."
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in ASG."
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in ASG."
  type        = number
  default     = 1
}

variable "tf_state_bucket" {
  description = "S3 bucket for Terraform remote state."
  type        = string
}

variable "tf_state_lock_table" {
  description = "DynamoDB table for Terraform state locking."
  type        = string
}
