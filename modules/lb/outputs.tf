output "lb_endpoint" {
  value = aws_alb.load_balancer.dns_name
}

output "alb_target_group_arn" {
  value = aws_alb_target_group.alb_target_group.arn
}

output "alb_id" {
  value = aws_alb.load_balancer.id
}
