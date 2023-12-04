resource "aws_lb" "load_balancer" {
  name               = "server-lb-vmm"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg_id]
  subnets            = [var.pub_subnet1_id, var.pub_subnet2_id]

  enable_deletion_protection = false

  tags = {
    Name = "server-lb-vmm"
  }
}

resource "aws_lb_target_group" "vmm_tg" {
  name     = "lb-target-group-vmm"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
  }

  tags = {
    Name = "lb-target-group-vmm"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vmm_tg.arn
  }
}
