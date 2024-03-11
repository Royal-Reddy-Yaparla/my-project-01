provider "aws"{
    region = "us-east-1"
}


resource "aws_instance" "project_01_server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name = "keypair-nv"
  # security_groups = [ "allow_tls" ]
  vpc_security_group_ids = [ aws_security_group.allow_tls.id ]
  subnet_id = aws_subnet.project-public_subent_01.id
  tags = {
    Name = "project_01_server"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.project-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc" "project-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "project-vpc"
  }
}

resource "aws_subnet" "project-public_subent_01" {
    vpc_id = aws_vpc.project-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      Name = "project-public_subent_01"
    }
}


resource "aws_internet_gateway" "project-igw" {
    vpc_id = aws_vpc.project-vpc.id
    tags = {
      Name = "project-igw"
    }
}

resource "aws_route_table" "project-public-rt" {
    vpc_id = aws_vpc.project-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.project-igw.id
    }
    tags = {
      Name = "project-public-rt"
    }
}

resource "aws_route_table_association" "project-rta-public-subent-1" {
    subnet_id = aws_subnet.project-public_subent_01.id
    route_table_id = aws_route_table.project-public-rt.id
}