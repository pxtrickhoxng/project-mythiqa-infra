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

module "alb" {
  source = "./modules/alb"

  project_name   = "mythiqa"
  vpc_id         = module.network.vpc_id
  alb_subnet_ids = module.network.alb_subnet_ids
  alb_sg_id      = module.network.alb_sg_id
  backend_port   = 8080
}

data "aws_secretsmanager_secret_version" "mythiqa_secrets" {
  secret_id  = "mythiqa-secrets"
  version_id = "772b7f51-4b0c-4025-9b88-957865d7ca76"
}

module "database" {
  source = "./modules/database"

  project_name      = "mythiqa"
  db_subnet_ids     = module.network.rds_subnet_ids
  security_group_id = module.network.rds_sg_id

  db_name             = "mythiqa_backend"
  db_username         = "postgres"
  db_password         = jsondecode(data.aws_secretsmanager_secret_version.mythiqa_secrets.secret_string)["mythiqa_db_password"]
  db_instance_class   = "db.t3.micro"
  allocated_storage   = 20
  engine_version      = "18.1"
  multi_az            = false
  skip_final_snapshot = true
}

module "backend_instances" {
  source = "./modules/compute"

  project_name      = "mythiqa"
  ami               = "ami-06f1fc9ae5ae7f31e"
  instance_type     = "t3.micro"
  subnet_ids        = module.network.backend_subnet_ids
  security_group_id = module.network.backend_sg_id
  target_group_arns = [module.alb.target_group_arn]

  min_size         = 2
  max_size         = 2
  desired_capacity = 2

  region              = "us-east-2"
  account_id          = "078183418709"
  ecr_repository_name = "mythiqa-backend"
  docker_image_tag    = "latest"
  container_port      = 8080

  db_jdbc_url = module.database.jdbc_connection_string
  db_username = module.database.db_username

  clerk_jwt_issuer = "https://working-leopard-42.clerk.accounts.dev"

  s3_bucket_name = "project-mythiqa-aws-s3"

  secrets_manager_secret_id = "mythiqa-secrets"
}