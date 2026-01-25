resource "aws_vpc" "mythiqa_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags             = { Name = "${var.project_name}_vpc" }
}

# -- Subnets --
# ALB
resource "aws_subnet" "alb_public_az1" {
  vpc_id                  = aws_vpc.mythiqa_vpc.id
  cidr_block              = var.alb_subnet_cidr_az1
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_1
  tags                    = { Name = "${var.project_name}-alb-public-az1" }
}

resource "aws_subnet" "alb_public_az2" {
  vpc_id                  = aws_vpc.mythiqa_vpc.id
  cidr_block              = var.alb_subnet_cidr_az2
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_2
  tags                    = { Name = "${var.project_name}-alb-public-az2" }
}

# Backend
resource "aws_subnet" "private_backend_az1" {
  vpc_id            = aws_vpc.mythiqa_vpc.id
  cidr_block        = var.backend_subnet_cidr_az1
  availability_zone = var.availability_zone_1
  tags              = { Name = "${var.project_name}-private-backend-az1" }
}

resource "aws_subnet" "private_backend_az2" {
  vpc_id            = aws_vpc.mythiqa_vpc.id
  cidr_block        = var.backend_subnet_cidr_az2
  availability_zone = var.availability_zone_2
  tags              = { Name = "${var.project_name}-private-backend-az2" }
}

# RDS
resource "aws_subnet" "private_rds_az1" {
  vpc_id            = aws_vpc.mythiqa_vpc.id
  cidr_block        = var.rds_subnet_cidr_az1
  availability_zone = var.availability_zone_1
  tags              = { Name = "${var.project_name}-private-rds-az1" }
}

resource "aws_subnet" "private_rds_az2" {
  vpc_id            = aws_vpc.mythiqa_vpc.id
  cidr_block        = var.rds_subnet_cidr_az2
  availability_zone = var.availability_zone_2
  tags              = { Name = "${var.project_name}-private-rds-az2" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mythiqa_vpc.id
  tags   = { Name = "${var.project_name}_vpc-gw" }
}

# Public Route Table for ALB subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mythiqa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route_table_association" "public_assoc_az1" {
  subnet_id      = aws_subnet.alb_public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc_az2" {
  subnet_id      = aws_subnet.alb_public_az2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.alb_public_az1.id

  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  depends_on = [aws_eip.nat_eip, aws_internet_gateway.gw]
}

# Private Route Table for Backend subnets
resource "aws_route_table" "private_backend_rt" {
  vpc_id = aws_vpc.mythiqa_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.project_name}-private-backend-rt"
  }
}

resource "aws_route_table_association" "private_assoc_backend_az1" {
  subnet_id      = aws_subnet.private_backend_az1.id
  route_table_id = aws_route_table.private_backend_rt.id
}

resource "aws_route_table_association" "private_assoc_backend_az2" {
  subnet_id      = aws_subnet.private_backend_az2.id
  route_table_id = aws_route_table.private_backend_rt.id
}

resource "aws_route_table" "private_rds_rt" {
  vpc_id = aws_vpc.mythiqa_vpc.id
  tags = {
    Name = "${var.project_name}-private-rds-rt"
  }
}

resource "aws_route_table_association" "private_assoc_rds_az1" {
  subnet_id      = aws_subnet.private_rds_az1.id
  route_table_id = aws_route_table.private_rds_rt.id
}

resource "aws_route_table_association" "private_assoc_rds_az2" {
  subnet_id      = aws_subnet.private_rds_az2.id
  route_table_id = aws_route_table.private_rds_rt.id
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for public-facing ALB"
  vpc_id      = aws_vpc.mythiqa_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "${var.project_name}-backend-sg"
  description = "Accepts traffic from ALB only"
  vpc_id      = aws_vpc.mythiqa_vpc.id

  ingress {
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow traffic from ALB on backend port"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-backend-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Accepts traffic from backend only"
  vpc_id      = aws_vpc.mythiqa_vpc.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
    description     = "Allow PostgreSQL traffic from backend"
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}