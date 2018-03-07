
variable "initials" {}

variable "project_name" {
  default = "sandbox"
}

variable "region" {
  default = "us-east-1"
}

variable "zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "availability_zone" {
  default = "us-east-1a"
}