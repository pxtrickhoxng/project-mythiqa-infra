variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "instance_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "ami" {
  type = string
  default = "ami-06f1fc9ae5ae7f31e"
}