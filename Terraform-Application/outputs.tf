output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "app_bucket_name" {
  description = "S3 bucket for app static/media files"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.app_asg.name
}
