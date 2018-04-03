
variable "initials" {}

variable "public_key" {}

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

variable "authorized_ips" {
  type = "list"
}

variable "instance" {
  type = "map"
}

data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["379101102735"] # Debian Project
}

data "template_file" "user-data" {
  template = <<EOF
#cloud-config
runcmd:
  - '/bin/mkdir /mnt/data'
  - '/sbin/mkfs -t ext4 /dev/xvdb'
  - '/bin/mount /dev/xvdb /mnt/data/'
EOF
}
