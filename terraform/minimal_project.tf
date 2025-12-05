resource "aws_vpc" "dev_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

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