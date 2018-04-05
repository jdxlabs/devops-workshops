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
  subnet_id     = "${aws_subnet.public_subnet.id}"
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

resource "aws_security_group" "logstore_ingress" {
  name_prefix = "${var.project_name}-${var.initials}-logstore-ingress"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["${var.bastion_ingress_cidr}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${var.bastion_ingress_cidr}"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
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

resource "aws_security_group" "consul_group" {
  name_prefix = "${var.project_name}-${var.initials}-consul-group"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port       = 5000
    to_port         = 5999
    protocol        = "TCP"
    security_groups = ["${aws_security_group.bastion_realm.id}"]
  }

  ingress {
    from_port       = 8300
    to_port         = 8302
    protocol        = "TCP"
    security_groups = ["${aws_security_group.bastion_realm.id}"]
  }

  ingress {
    from_port       = 8500
    to_port         = 8500
    protocol        = "TCP"
    security_groups = ["${aws_security_group.bastion_realm.id}"]
  }

  ingress {
    from_port       = 8600
    to_port         = 8600
    protocol        = "TCP"
    security_groups = ["${aws_security_group.bastion_realm.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM profile

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.project_name}-${var.initials}-instance-profile"
  role = "${aws_iam_role.instance_role.name}"
}

resource "aws_iam_role" "instance_role" {
  name = "${var.project_name}-${var.initials}-instance-role"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "instance_role_policy" {
  name = "${var.project_name}-${var.initials}-instance-role-policy"
  role = "${aws_iam_role.instance_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    }
  ]
}
EOF
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

resource "aws_instance" "consul_masters" {
  count                = "${var.instances_consul_masters["nb"]}"
  ami                  = "${data.aws_ami.debian.id}"
  instance_type        = "${var.instances_consul_masters["type"]}"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  key_name             = "${aws_key_pair.bastion_keypair.key_name}"

  root_block_device = {
    volume_size = "${var.instances_consul_masters["root_hdd_size"]}"
    volume_type = "${var.instances_consul_masters["root_hdd_type"]}"
  }

  subnet_id = "${aws_subnet.private_subnet.id}"

  vpc_security_group_ids = [
    "${aws_security_group.bastion_realm.id}",
    "${aws_security_group.consul_group.id}"
  ]

  lifecycle {
    ignore_changes = ["instance_type", "user_data", "root_block_device", "ebs_block_device"]
  }

  tags {
    Name = "${var.project_name}-${var.initials}-consul-master-${count.index}"
  }
}


resource "aws_instance" "logstores" {
  count                = "${var.instances_logstores["nb"]}"
  ami                  = "${data.aws_ami.debian.id}"
  instance_type        = "${var.instances_logstores["type"]}"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  key_name             = "${aws_key_pair.bastion_keypair.key_name}"

  root_block_device = {
    volume_size = "${var.instances_logstores["root_hdd_size"]}"
    volume_type = "${var.instances_logstores["root_hdd_type"]}"
  }

  ebs_block_device = {
    volume_size = "${var.instances_logstores["ebs_hdd_size"]}"
    volume_type = "${var.instances_logstores["ebs_hdd_type"]}"
    device_name = "${var.instances_logstores["ebs_hdd_name"]}"
  }

  subnet_id = "${aws_subnet.public_subnet.id}"

  vpc_security_group_ids = [
    "${aws_security_group.logstore_ingress.id}"
  ]

  lifecycle {
    ignore_changes = ["instance_type", "user_data", "root_block_device", "ebs_block_device"]
  }

  tags {
    Name = "${var.project_name}-${var.initials}-logstore-${count.index}"
  }

  associate_public_ip_address = true
}
