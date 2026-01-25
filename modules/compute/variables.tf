variable "project_name" {
  type = string
}

# Launch template variables
variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ASG to span across multiple AZs"
}

variable "security_group_id" {
  type = string
}

# ASG Variables
variable "min_size" {
  type        = number
  default     = 2
  description = "Minimum number of instances"
}

variable "max_size" {
  type        = number
  default     = 2
  description = "Maximum number of instances"
}

variable "desired_capacity" {
  type        = number
  default     = 2
  description = "Desired number of instances"
}

variable "target_group_arns" {
  type = list(string)
}

# ECR Variables
variable "region" {
  description = "AWS region for ECR"
  type        = string
}


variable "account_id" {
  description = "ECR user account id"
  type = string
}

variable "ecr_repository_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "docker_image_tag" {
  type        = string
  default     = "latest"
  description = "Docker image tag to deploy"
}

variable "container_port" {
  type        = number
  default     = 8080
  description = "Port the backend container listens on"
}

# Database Configuration
variable "db_jdbc_url" {
  type        = string
  description = "JDBC connection string for database"
}

variable "db_username" {
  type        = string
  description = "Database username"
}

# Clerk Configuration
variable "clerk_jwt_issuer" {
  type        = string
  description = "Clerk JWT issuer URL"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name"
}

# Secrets Manager
variable "secrets_manager_secret_id" {
  type        = string
  description = "Secrets Manager secret ID containing sensitive values"
}
