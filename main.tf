provider "aws" {
  region = "us-east-2"
}

module "network" {
  source = "./modules/network"

  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  backend_subnet_cidr = "10.0.2.0/24"
  rds_subnet_cidr     = "10.0.3.0/24"
  availability_zone   = "us-east-2a"
  project_name        = "mythiqa"
}

/*

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "mythiqa_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano"

  tags = {
    Name = "mythiqa-backend"
  }
}

*/