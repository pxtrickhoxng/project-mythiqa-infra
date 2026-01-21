terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-mythiqa"
    key          = "global/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = "true"
    encrypt      = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}
