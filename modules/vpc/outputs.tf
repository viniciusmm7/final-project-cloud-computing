output "vpc_id" {
  description = "vpc_id"
  value       = aws_vpc.vpc.id
}

output "pub_subnet1_id" {
  description = "pub_subnet1_id"
  value       = aws_subnet.public_subnet1.id
}

output "pub_subnet2_id" {
  description = "pub_subnet2_id"
  value       = aws_subnet.public_subnet2.id
}

output "priv_subnet1_id" {
  description = "priv_subnet1_id"
  value       = aws_subnet.private_subnet1.id
}

output "priv_subnet2_id" {
  description = "priv_subnet2_id"
  value       = aws_subnet.private_subnet2.id
}
