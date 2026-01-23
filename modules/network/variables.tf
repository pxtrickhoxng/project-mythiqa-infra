variable "vpc_cidr" {
  type = string
}

variable "alb_subnet_cidr_az1" {
  type = string
}
variable "alb_subnet_cidr_az2" {
  type = string
}

variable "backend_subnet_cidr_az1" {
  type = string
}
variable "backend_subnet_cidr_az2" {
  type = string
}

variable "rds_subnet_cidr_az1" {
  type = string
}
variable "rds_subnet_cidr_az2" {
  type = string
}

variable "availability_zone_1" {
  type = string
}
variable "availability_zone_2" {
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