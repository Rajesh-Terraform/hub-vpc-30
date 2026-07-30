data "aws_availability_zones" "available" {}


# VPC


resource "aws_vpc" "hub" {

  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Hub-VPC"
  }
}


# Internet Gateway


resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.hub.id

  tags = {
    Name = "Hub-IGW"
  }
}


# Public Subnets


resource "aws_subnet" "public1" {

  vpc_id = aws_vpc.hub.id

  cidr_block = "10.0.0.0/24"

  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "Public1"
  }
}

resource "aws_subnet" "public2" {

  vpc_id = aws_vpc.hub.id

  cidr_block = "10.0.1.0/24"

  availability_zone = data.aws_availability_zones.available.names[1]

  map_public_ip_on_launch = true

  tags = {
    Name = "Public2"
  }
}


# Private Subnets

resource "aws_subnet" "private1" {

  vpc_id = aws_vpc.hub.id

  cidr_block = "10.0.10.0/24"

  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Private1"
  }
}

resource "aws_subnet" "private2" {

  vpc_id = aws_vpc.hub.id

  cidr_block = "10.0.11.0/24"

  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Private2"
  }
}


# Elastic IPs


resource "aws_eip" "nat1" {

  domain = "vpc"

}

resource "aws_eip" "nat2" {

  domain = "vpc"

}


# NAT Gateway

resource "aws_nat_gateway" "nat1" {

  subnet_id = aws_subnet.public1.id

  allocation_id = aws_eip.nat1.id

  depends_on = [aws_internet_gateway.igw]

}

resource "aws_nat_gateway" "nat2" {

  subnet_id = aws_subnet.public2.id

  allocation_id = aws_eip.nat2.id

  depends_on = [aws_internet_gateway.igw]

}



resource "aws_route_table" "public" {

  vpc_id = aws_vpc.hub.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id

  }

}

resource "aws_route_table" "private1" {

  vpc_id = aws_vpc.hub.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.nat1.id

  }

}

resource "aws_route_table" "private2" {

  vpc_id = aws_vpc.hub.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.nat2.id

  }

}




resource "aws_route_table_association" "pub1" {

  subnet_id = aws_subnet.public1.id

  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "pub2" {

  subnet_id = aws_subnet.public2.id

  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "pri1" {

  subnet_id = aws_subnet.private1.id

  route_table_id = aws_route_table.private1.id

}

resource "aws_route_table_association" "pri2" {

  subnet_id = aws_subnet.private2.id

  route_table_id = aws_route_table.private2.id

}    