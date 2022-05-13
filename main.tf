provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "bookstore" {
  ami             = "ami-02e136e904f3da870"
  instance_type   = "t2.micro"
  key_name        = "firstkey"
  security_groups = ["bookstore-sec-group"]
  tags = {
    Name = "bookstore-instance"
  }
  user_data = <<-EOF
              #! /bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              # install docker-compose
              curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
              -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              yum install git -y
              hostnamectl set-hostname "docker-compose-server"
              export HOME=/root
              git clone https://github.com/T1kcan/SMG-Sample-Showcase-Project.git
              cd /SMG-Sample-Showcase-Project
              docker-compose up
              EOF
}

resource "aws_security_group" "sec-group" {
  name = "bookstore-sec-group"
  tags = {
    Name = "bookstore-sec-group"
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "bookstore-public-ip" {
  value = aws_instance.bookstore.public_ip
}