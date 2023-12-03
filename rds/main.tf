resource "aws_security_group" "rds_sec_group" {
  name        = "rds-security-group-vmm"
  description = "rds-sec-group-vmm"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sec_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg-vmm"
  }
}

resource "aws_db_instance" "rds_vmm" {
  identifier           = "rds-instance-vmm"
  engine               = "mysql"
  engine_version       = "8.0"
  allocated_storage    = 20
  storage_type         = "gp2"
  instance_class       = "db.t2.micro"
  parameter_group_name = "default.mysql8.0"

  db_name  = var.DB_NAME
  username = var.DB_USER
  password = var.DB_PASSWORD

  multi_az            = true
  publicly_accessible = false

  backup_retention_period = 7
  backup_window           = "03:00-03:59"
  maintenance_window      = "Sun:04:00-Sun:04:59"

  final_snapshot_identifier = "final-rds-snapshot-vmm-${formatdate("YYYYMMDDHHmmss", timestamp())}"

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  vpc_security_group_ids = [aws_security_group.rds_sec_group.id]

  tags = {
    Name = "rds-instance-vmm"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group-vmm"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  tags = {
    Name = "db-subnet-group-vmm"
  }
}

output "database_dns" {
  value = aws_db_instance.rds_vmm.address
}
