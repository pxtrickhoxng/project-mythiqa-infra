variable "project_name" {
  type = string
}

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