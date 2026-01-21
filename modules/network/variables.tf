variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}
variable "backend_subnet_cidr" {
  type = string
}
variable "rds_subnet_cidr" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "project_name" {
  type = string
}

variable "backend_port" {
  type    = number
  default = 8080
}

variable "db_port" {
  type    = number
  default = 5432
}