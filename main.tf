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

module "backend_instance" {
  source = "./modules/compute"

  instance_name     = "mythiqa_backend_instance"
  instance_type     = "t3.micro"
  ami               = "ami-06f1fc9ae5ae7f31e"
  subnet_id         = module.network.backend_subnet_id
  security_group_id = module.network.backend_sg_id
}