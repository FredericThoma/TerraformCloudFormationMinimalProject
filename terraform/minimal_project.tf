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

resource "aws_subnet" "dev_subnet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.1.0/24"

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

