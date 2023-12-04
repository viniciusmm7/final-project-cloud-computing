output "lb_endpoint" {
  description = "lb_endpoint"
  value       = aws_lb.load_balancer.dns_name
}
