output "lb_endpoint" {
  value = aws_lb.load_balancer.dns_name
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.vmm_tg.arn
}

output "lb_id" {
  value = aws_lb.load_balancer.id
}
