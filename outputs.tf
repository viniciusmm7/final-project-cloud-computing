output "load_balancer_dns" {
  value = "${module.lb.lb_endpoint}/"
}
