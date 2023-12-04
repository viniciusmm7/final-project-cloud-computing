resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-vmm"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet1-vmm"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet2-vmm"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = var.availability_zone1

  tags = {
    Name = "priv-subnet1-vmm"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = var.availability_zone2

  tags = {
    Name = "priv-subnet2-vmm"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway-vmm"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "pub-route-table-vmm"
  }
}

resource "aws_route_table_association" "subnet1_route_table" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "subnet2_route_table" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "eip1" {
  vpc = true

  tags = {
    Name = "eip1-vmm"
  }
}

resource "aws_eip" "eip2" {
  vpc = true

  tags = {
    Name = "eip2-vmm"
  }
}

resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "nat-gateway1-vmm"
  }
}

resource "aws_nat_gateway" "nat_gateway2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public_subnet2.id

  tags = {
    Name = "nat-gateway2-vmm"
  }
}

resource "aws_route_table" "private_route_table1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway1.id
  }

  tags = {
    Name = "priv-route-table1-vmm"
  }
}

resource "aws_route_table" "private_route_table2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway2.id
  }

  tags = {
    Name = "priv-route-table2-vmm"
  }
}

resource "aws_route_table_association" "private_subnet1_association" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table1.id
}

resource "aws_route_table_association" "private_subnet2_association" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table2.id
}
