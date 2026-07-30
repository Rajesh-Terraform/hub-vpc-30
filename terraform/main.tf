resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Hub-VPC"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Hub-IGW"
  }
}


resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1
  availability_zone       = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet1"
  }
}


resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2
  availability_zone       = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet2"
  }
}


resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1
  availability_zone = var.az1

  tags = {
    Name = "Private-Subnet-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2
  availability_zone = var.az2

  tags = {
    Name = "Private-Subnet2"
  }
}

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public1.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "NAT-Gateway-AZ1"
  }
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public2.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "NAT-Gateway-AZ2"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Public-RT"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private-RT-AZ1"
  }
}

resource "aws_route" "private1_nat" {
  route_table_id         = aws_route_table.private1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat1.id
}  

#########################
# Elastic IPs
#########################

resource "aws_eip" "nat1" {
  domain = "vpc"

  tags = {
    Name = "nat1-eip"
  }
}

resource "aws_eip" "nat2" {
  domain = "vpc"

  tags = {
    Name = "nat2-eip"
  }
}
   





