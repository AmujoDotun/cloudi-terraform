provider "aws" {
  region     = "us-west-1"
  access_key = 
  secret_key = 
}

# Creating VPC

resource "aws_vpc" "cloudivpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "cloudi"
  }
}

#Creating Subnet

resource "aws_subnet" "cloudi_sub" {
  vpc_id     = aws_vpc.cloudivpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "cloudi"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "cloudi_gw" {
  vpc_id = aws_vpc.cloudivpc.id

  tags = {
    Name = "Cloudi"
  }
}

resource "aws_route_table" "cloudi_route" {
  vpc_id = aws_vpc.cloudivpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudi_gw.id
  }

  tags = {
    Name = "Cloudi"
  }
}

#Security group

resource "aws_security_group" "cloudi_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.cloudivpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.cloudivpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_network_interface" "cloudi_ni" {
  subnet_id       = aws_subnet.cloudi_sub.id
  security_groups = [aws_security_group.cloudi_sg.id]

  

}

resource "aws_instance" "cloudi_web" {
  ami           = "ami-0a1a70369f0fce06a"
  instance_type = "t3.micro"

  tags = {
    Name = "Cloudi"
  }
}