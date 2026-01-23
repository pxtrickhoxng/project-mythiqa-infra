provider "aws" {
  region = "us-east-2"
}

module "network" {
  source = "./modules/network"

  vpc_cidr                = "10.0.0.0/16"
  alb_subnet_cidr_az1     = "10.0.1.0/24"
  alb_subnet_cidr_az2     = "10.0.2.0/24"
  backend_subnet_cidr_az1 = "10.0.11.0/24"
  backend_subnet_cidr_az2 = "10.0.12.0/24"
  rds_subnet_cidr_az1     = "10.0.21.0/24"
  rds_subnet_cidr_az2     = "10.0.22.0/24"
  availability_zone_1     = "us-east-2a"
  availability_zone_2     = "us-east-2b"
  project_name            = "mythiqa"
}

module "backend_asg" {
  source = "./modules/compute"

  project_name      = "mythiqa"
  ami               = "ami-06f1fc9ae5ae7f31e"
  instance_type     = "t3.micro"
  subnet_ids        = module.network.backend_subnet_ids
  security_group_id = module.network.backend_sg_id

  min_size         = 2
  max_size         = 2
  desired_capacity = 2
}