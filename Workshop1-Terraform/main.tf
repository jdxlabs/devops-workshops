

# landscape

provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    Name = "${var.project_name}-${var.region}-${var.initials}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.zones[0]}"
  tags {
    Name = "${aws_vpc.vpc.tags.Name}-${var.zones[0]}-public"
    Description = "${aws_vpc.vpc.tags.Name} public subnet in AZ ${var.zones[0]}"
  }
}

# nat gateway

# ec2