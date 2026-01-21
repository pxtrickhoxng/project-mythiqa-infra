provider "aws" {
  region = "us-east-2"
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