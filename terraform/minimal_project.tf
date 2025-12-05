resource "aws_vpc" "dev_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "project1_dev_vpc"
    Environment = "dev"
    Project = "project1"
  }
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "project1_dev_igw"
    Environment = "dev"
    Project = "project1"
  }
}

resource "aws_route_table" "dev_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "project1_dev_route_table"
    Environment = "dev"
    Project = "project1"
  }
}

resource "aws_subnet" "dev_subnet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "project1_dev_subnet"
    Environment = "dev"
    Project = "project1"
  }
}

resource "aws_route_table_association" "dev_rta" {
  subnet_id      = aws_subnet.dev_subnet.id
  route_table_id = aws_route_table.dev_route_table.id
}

resource "aws_security_group" "dev_allow_web" {
  name        = "project1_dev_allow_web_traffic"
  description = "Allow web + SSH access"
  vpc_id      = aws_vpc.dev_vpc.id

  tags = {
    Name = "project1_dev_allow_web"
    Environment = "dev"
    Project = "project1"
  }
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "CIDR block allowed to SSH into instances"
  # project1_dev.auto.tfvars
}

locals {
  dev_ingress_rules = {
    ssh = {
      port = 22
      cidr = var.ssh_allowed_cidr
    }
    http = {
      port = 80
      cidr = "0.0.0.0/0"
    }
    https = {
      port = 443
      cidr = "0.0.0.0/0"
    }
  }
}

resource "aws_vpc_security_group_ingress_rule" "dev_allow_ingress_ipv4" {
  for_each = local.dev_ingress_rules

  security_group_id = aws_security_group.dev_allow_web.id
  cidr_ipv4         = each.value.cidr
  from_port         = each.value.port
  to_port           = each.value.port
  ip_protocol       = "tcp"
  description       = each.key
}

resource "aws_vpc_security_group_egress_rule" "dev_allow_all_egress_ipv4" {
  security_group_id = aws_security_group.dev_allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_network_interface" "dev_network_interface" {
  subnet_id       = aws_subnet.dev_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.dev_allow_web.id]
}

resource "aws_eip" "dev_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.dev_network_interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.dev_igw]
}

resource "aws_instance" "dev_web_server" {
  ami           = "ami-0a6793a25df710b06"
  instance_type = "t3.micro"
  key_name = "my-key-pair"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.dev_network_interface.id
  }

    user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "hello world - greetings from terraform!" > /var/www/html/index.html
              EOF

  tags = {
    Name = "project1_dev_web_server"
    Environment = "dev"
    Project = "project1"
  }
}