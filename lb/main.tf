resource "aws_security_group" "lb_sec_group" {
  name        = "alb-security-group-vmm"
  description = "app-lb-sec-group-vmm"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "alb-sec-group-vmm"
  }
}

resource "aws_alb" "load_balancer" {
  name               = "server-alb-vmm"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sec_group.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "server-alb-vmm"
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = "alb-target-group-vmm"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    port                = 80
  }

  tags = {
    Name = "alb-target-group-vmm"
  }
}

resource "aws_alb_listener" "lb_listener" {
  load_balancer_arn = aws_alb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.arn
  }
}

output "load_balancer_dns" {
  value = aws_alb.load_balancer.dns_name
}
