output "load_balancer_dns" {
  value = "${module.ec2.lb_endpoint}/"
}
