output "ec2_sg_id" {
  description = "ec2_sg_id"
  value       = aws_security_group.ec2_sec_group.id
}

output "lb_sg_id" {
  description = "lb_sg_id"
  value       = aws_security_group.lb_sec_group.id
}

output "rds_sg_id" {
  description = "rds_sg_id"
  value       = aws_security_group.rds_sec_group.id
}
