terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket = "terraform-bucket-viniciusmm7"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_secretsmanager_secret" "db_credentials" {
  name = "prod/beta/mysql/vmm_credentials"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)
}

module "vpc" {
  source = "./modules/vpc"

  availability_zone1 = data.aws_availability_zones.available.names[0]
  availability_zone2 = data.aws_availability_zones.available.names[1]
}

module "sg" {
  source = "./modules/security_groups"

  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source = "./modules/rds"

  db_name         = local.db_credentials.name
  db_username     = local.db_credentials.username
  db_password     = local.db_credentials.password
  rds_sg_id       = module.sg.rds_sg_id
  priv_subnet1_id = module.vpc.priv_subnet1_id
  priv_subnet2_id = module.vpc.priv_subnet2_id
}

module "ec2" {
  source = "./modules/ec2"

  ec2_profile_name     = module.iam.ec2_profile_name
  ec2_sg_id            = module.sg.ec2_sg_id
  db_host              = module.rds.db_host
  db_username          = local.db_credentials.username
  db_password          = local.db_credentials.password
  db_name              = local.db_credentials.name
  priv_subnet1_id      = module.vpc.priv_subnet1_id
  priv_subnet2_id      = module.vpc.priv_subnet2_id
  alb_target_group_arn = module.lb.alb_target_group_arn
  alb_id               = module.lb.alb_id
}

module "lb" {
  source = "./modules/lb"

  vpc_id         = module.vpc.vpc_id
  alb_sg_id      = module.sg.alb_sg_id
  pub_subnet1_id = module.vpc.pub_subnet1_id
  pub_subnet2_id = module.vpc.pub_subnet2_id
}

module "iam" {
  source = "./modules/iam"
}

module "locust" {
  source = "./modules/locust"

  ami            = "ami-0fc5d935ebf8bc3bc"
  instance_type  = "t2.micro"
  pub_subnet1_id = module.vpc.pub_subnet1_id
  loc_sg_id      = module.sg.loc_sg_id
  lb_endpoint    = module.lb.lb_endpoint
}
