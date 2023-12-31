variable "vpc_id" {
  description = "vpc_id"
  type        = string
}

variable "pub_subnet1_id" {
  description = "pub_subnet1_id"
  type        = string
}

variable "pub_subnet2_id" {
  description = "pub_subnet2_id"
  type        = string
}

variable "ec2_sg_id" {
  description = "ec2_sg_id"
  type        = string
}

variable "ec2_profile_name" {
  description = "ec2_profile_name"
  type        = string
}

variable "db_host" {
  description = "db_host"
  type        = string
}

variable "priv_subnet1_id" {
  description = "pub_subnet1_id"
  type        = string
}

variable "priv_subnet2_id" {
  description = "pub_subnet2_id"
  type        = string
}

variable "lb_sg_id" {
  description = "lb_sg_id"
  type        = string
}
