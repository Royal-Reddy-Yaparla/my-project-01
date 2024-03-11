provider "aws"{
    region = "us-east-1"
}

# create ec2 instances
resource "aws_instance" "project_01_server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name = "keypair-nv"
  # security_groups = [ "allow_tls" ]
  vpc_security_group_ids = [ aws_security_group.allow_tls.id ]
  subnet_id = aws_subnet.project-public_subent_01.id
for_each = toset([ "Jenkins_Master","Build_Slave","Ansible" ])
  tags = {
    Name = "${each.key}"
  }  
}

# create security group 
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.project-vpc.id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Port Access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

# create VPC
resource "aws_vpc" "project-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "project-vpc"
  }
}
# create subnet
resource "aws_subnet" "project-public_subent_01" {
    vpc_id = aws_vpc.project-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      Name = "project-public_subent_01"
    }
}


# create internet gateway
resource "aws_internet_gateway" "project-igw" {
    vpc_id = aws_vpc.project-vpc.id
    tags = {
      Name = "project-igw"
    }
}

#  create route table
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

# assocaiate route table for public
resource "aws_route_table_association" "project-rta-public-subent-1" {
    subnet_id = aws_subnet.project-public_subent_01.id
    route_table_id = aws_route_table.project-public-rt.id
}