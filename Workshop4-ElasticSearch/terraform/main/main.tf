# landscape

provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "${var.project_name}-${var.region}-${var.initials}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.public_subnet_cidr}"
  availability_zone = "${var.zones[0]}"

  tags {
    Name        = "${aws_vpc.vpc.tags.Name}-${var.zones[0]}-public"
    Description = "${aws_vpc.vpc.tags.Name} public subnet in AZ ${var.zones[0]}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "${var.zones[0]}"

  tags {
    Name        = "${aws_vpc.vpc.tags.Name}-${var.zones[0]}-private"
    Description = "${aws_vpc.vpc.tags.Name} private subnet in AZ ${var.zones[0]}"
  }
}

# Internet gateway

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }

  tags {
    Name = "Main route table for ${var.project_name}-${var.initials}"
  }
}

resource "aws_main_route_table_association" "main" {
  route_table_id = "${aws_route_table.main.id}"
  vpc_id         = "${aws_vpc.vpc.id}"
}

# NAT Gateway

resource "aws_eip" "nat_instance" {
  vpc = true
}

resource "aws_nat_gateway" "nat_instance" {
  allocation_id = "${aws_eip.nat_instance.id}"
  subnet_id     = "${aws_subnet.private_subnet.id}"
}

resource "aws_route_table" "private_subnet_route" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_instance.id}"
  }

  tags {
    Name = "${aws_vpc.vpc.tags.Name}-${var.zones[0]}-private"
  }
}

resource "aws_route_table_association" "private_subnet_to_nat" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_subnet_route.id}"
}

resource "aws_route_table_association" "public_subnet_to_gateway" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.main.id}"
}

# Security groups

resource "aws_security_group" "bastion_ingress" {
  name_prefix = "${var.project_name}-${var.initials}-bastion-ingress"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["${var.bastion_ingress_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_realm" {
  name_prefix = "${var.project_name}-${var.initials}-bastion-realm"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = ["${aws_security_group.bastion_ingress.id}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2

resource "aws_key_pair" "bastion_keypair" {
  key_name   = "${var.project_name}-${var.initials}"
  public_key = "${var.public_key}"
}

resource "aws_instance" "bastion" {
  count         = "1"
  ami           = "${data.aws_ami.debian.id}"
  instance_type = "t2.medium"
  key_name      = "${aws_key_pair.bastion_keypair.key_name}"

  root_block_device = {
    volume_size = "8"
    volume_type = "gp2"
  }

  subnet_id = "${aws_subnet.public_subnet.id}"

  vpc_security_group_ids = [
    "${aws_security_group.bastion_ingress.id}",
  ]

  tags {
    Name = "${var.project_name}-${var.initials}-bastion"
  }

  associate_public_ip_address = true
}

resource "aws_instance" "nodejs_server" {
  count         = "${var.instance["nb"]}"
  ami           = "${data.aws_ami.debian.id}"
  instance_type = "${var.instance["type"]}"
  key_name      = "${aws_key_pair.bastion_keypair.key_name}"

  root_block_device = {
    volume_size = "${var.instance["root_hdd_size"]}"
    volume_type = "${var.instance["root_hdd_type"]}"
  }

  ebs_block_device = {
    volume_size = "${var.instance["ebs_hdd_size"]}"
    volume_type = "${var.instance["ebs_hdd_type"]}"
    device_name = "${var.instance["ebs_hdd_name"]}"
  }

  subnet_id = "${aws_subnet.public_subnet.id}"

  vpc_security_group_ids = [
    "${aws_security_group.bastion_realm.id}",
  ]

  user_data = "${data.template_file.user-data.rendered}"

  lifecycle {
    ignore_changes = ["ami", "instance_type", "user_data", "root_block_device", "ebs_block_device"]
  }

  tags {
    Name = "${var.project_name}-${var.initials}-nodejs-server-${count.index}"
  }
}
