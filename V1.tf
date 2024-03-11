provider "aws"{
    region = "us-east-1"
}


resource "aws_instance" "project_01_server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name = "keypair-nv"
  security_groups = [ "allow_tls" ]
  tags = {
    Name = "project_01_server"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
#   vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # cidr_blocks = aws_vpc.main.cidr_block
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