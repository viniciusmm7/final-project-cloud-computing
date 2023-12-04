resource "aws_alb" "load_balancer" {
  name               = "server-alb-vmm"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.pub_subnet1_id, var.pub_subnet2_id]

  # enable_cross_zone_load_balancing = true
  enable_deletion_protection = false

  tags = {
    Name = "server-alb-vmm"
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = "alb-target-group-vmm"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
  }

  tags = {
    Name = "alb-target-group-vmm"
  }
}

resource "aws_alb_listener" "server_listener" {
  load_balancer_arn = aws_alb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.arn
  }
}
