variable "ec2_sg_id" {
  description = "ec2_sg_id"
  type        = string
}

variable "ec2_profile_name" {
  description = "ec2_profile_name"
  type        = string
}

variable "db_name" {
  description = "db_name"
  type        = string
}

variable "db_username" {
  description = "db_username"
  type        = string
}

variable "db_password" {
  description = "db_password"
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

variable "alb_target_group_arn" {
  description = "alb_target_group_arn"
  type        = string
}

variable "alb_id" {
  description = "alb_id"
  type        = string
}
