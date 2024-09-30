terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 1.2"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_subnet" "web_app_subnet" {
  vpc_id            = var.network_vpc_id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone
}

# Create the Security Group
resource "aws_security_group" "web_security_group" {
  name        = "web-security-group"
  description = "Allow inbound traffic for the EC2 instance"
  vpc_id      = var.network_vpc_id

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group for assignment1"
  }
}


resource "aws_instance" "web_application_instance" {
  ami                         = var.server_ami
  instance_type               = var.server_instance_type
  key_name                    = aws_key_pair.assignmentkey.key_name
  subnet_id                   = aws_subnet.web_app_subnet.id
  security_groups             = [aws_security_group.web_security_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "Web App for asssignment1"
  }
}


resource "aws_ecr_repository" "mysql_repo" {
  name                 = var.mysql_docker_repo
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_repository" "app_repo" {
  name                 = var.application_docker_repo
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_key_pair" "assignmentkey" {
  key_name   = "assignmentkey"
  public_key = file("assignmentkey.pub")
}
