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

variable "rds_sg_id" {
  description = "rds_sg_id"
  type        = string
}

variable "priv_subnet1_id" {
  description = "priv_subnet1_id"
  type        = string
}

variable "priv_subnet2_id" {
  description = "priv_subnet2_id"
  type        = string
}
