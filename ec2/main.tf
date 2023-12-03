resource "aws_security_group" "ec2_sec_group" {
  name        = "ec2-security-group-vmm"
  description = "ec2-sec-group-vmm"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sec_group.id]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg-vmm"
  }
}

resource "aws_launch_template" "launch_template" {
  name_prefix = "launch-template-vmm"

  image_id               = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sec_group.id]

  user_data = base64encode(templatefile("user_data.tftpl", {
    db_host     = aws_db_instance.rds_vmm.address,
    db_user     = var.db_username,
    db_password = var.db_password,
    db_name     = var.db_name
  }))

  key_name = "viniciusmm7"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
}

resource "aws_autoscaling_group" "asg_vmm" {
  name              = "asg-vmm"
  desired_capacity  = 2
  min_size          = 2
  max_size          = 5
  health_check_type = "EC2"

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  target_group_arns   = [aws_alb_target_group.alb_target_group.arn]

  tag {
    key                 = "Name"
    value               = "asg-vmm"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy-vmm"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 10
  autoscaling_group_name = aws_autoscaling_group.asg_vmm.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy-vmm"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 10
  autoscaling_group_name = aws_autoscaling_group.asg_vmm.name
}

resource "aws_autoscaling_policy" "tracking" {
  name                      = "tracking-policy-vmm"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 180
  autoscaling_group_name    = aws_autoscaling_group.asg_vmm.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${split("/", aws_alb.load_balancer.id)[1]}/${split("/", aws_alb.load_balancer.id)[2]}/${split("/", aws_alb.load_balancer.id)[3]}/targetgroup/${split("/", aws_alb_target_group.alb_target_group.arn)[1]}/${split("/", aws_alb_target_group.alb_target_group.arn)[2]}"
    }
    target_value = 200
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "high-cpu-usage-vmm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 10
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_vmm.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "low-cpu-alarm-vmm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 10
  statistic           = "Average"
  threshold           = 10

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_vmm.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}

resource "aws_autoscaling_attachment" "as_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg_vmm.name
  lb_target_group_arn    = aws_alb_target_group.alb_target_group.arn
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/flask-app-vmm/logs"
}