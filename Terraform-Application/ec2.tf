resource "aws_launch_template" "app" {
  name_prefix   = "flask-app-lt-"
  image_id      = var.app_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = base64encode(templatefile("${path.module}/user_data.sh.tmpl", {
    alb_dns = aws_lb.app_alb.dns_name,
    region  = var.aws_region
  }))
  iam_instance_profile {
    name = "ec2-ecr-access"
  }
  tag_specifications {
    resource_type = "instance"
    tags = { Name = "flask-app-instance" }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "flask-app-asg"
  vpc_zone_identifier       = aws_subnet.private[*].id
  desired_capacity          = var.asg_desired_capacity
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 60
  tag {
    key                 = "Name"
    value               = "flask-app-asg"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
