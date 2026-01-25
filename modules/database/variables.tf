variable "project_name" {
  type        = string
  description = "Project name for resource naming"
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for RDS subnet group (requires 2+ in different AZs)"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for RDS instance"
}

variable "db_name" {
  type        = string
  default     = "mythiqa_backend"
  description = "Name of the database to create"
}

variable "db_username" {
  type        = string
  default     = "postgres"
  description = "Master username for the database"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Master password for the database (store in Secrets Manager or tfvars)"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class"
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage in GB"
}

variable "engine_version" {
  type        = string
  default     = "16.3"
  description = "PostgreSQL engine version"
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ deployment for high availability"
}

variable "backup_retention_period" {
  type        = number
  default     = 1
  description = "Number of days to retain backups (0 to disable, 1 for minimal)"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Skip final snapshot when destroying (true for dev/test, false for prod)"
}
