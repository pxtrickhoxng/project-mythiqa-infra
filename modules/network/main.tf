resource "aws_vpc" "mythiqa_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = { Name = "mythiqa_vpc" }
}

# Public Subnet for Next.js frontend
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.mythiqa_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"
  tags = { Name = "public-frontend-subnet" }
}

# Private Subnet for Spring Boot backend
resource "aws_subnet" "private_backend" {
  vpc_id            = aws_vpc.mythiqa_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2a"
  tags = { Name = "private-backend-subnet" }
}

# Private Subnet for RDS
resource "aws_subnet" "private_rds" {
  vpc_id            = aws_vpc.mythiqa_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-2a"
  tags = { Name = "private-rds-subnet" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mythiqa_vpc.id
  tags = { Name = "mythiqa_vpc-gw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mythiqa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# -------------------
# Security Groups
# Note: Port 80 == HTTP; Port 443 == HTTPS

resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Allow HTTP/HTTPS from internet"
  vpc_id      = aws_vpc.mythiqa_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Allow traffic from frontend SG only"
  vpc_id      = aws_vpc.mythiqa_vpc.id

  ingress {
    from_port       = 8080 # backend port
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL traffic from backend only"
  vpc_id      = aws_vpc.mythiqa_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }
}
