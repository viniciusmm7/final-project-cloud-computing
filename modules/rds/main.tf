resource "aws_db_instance" "rds_vmm" {
  identifier           = "rds-instance-vmm"
  engine               = "mysql"
  engine_version       = "8.0"
  allocated_storage    = 20
  storage_type         = "gp2"
  instance_class       = "db.t2.micro"
  parameter_group_name = "default.mysql8.0"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  multi_az            = true
  publicly_accessible = false

  backup_retention_period = 7
  backup_window           = "03:00-03:59"
  maintenance_window      = "Sun:04:00-Sun:04:59"

  final_snapshot_identifier = "final-rds-snapshot-vmm-${formatdate("YYYYMMDDHHmmss", timestamp())}"

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  vpc_security_group_ids = [var.rds_sg_id]

  tags = {
    Name = "rds-instance-vmm"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group-vmm"
  subnet_ids = [var.priv_subnet1_id, var.priv_subnet2_id]

  tags = {
    Name = "db-subnet-group-vmm"
  }
}
