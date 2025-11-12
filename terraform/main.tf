terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
  # Credentials are loaded automatically from (in order):
  # 1. Environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
  # 2. AWS credentials file: ~/.aws/credentials
  # 3. IAM instance profile (if running on EC2)
  # 
  # To use variables instead, uncomment and set values in terraform.tfvars:
  # access_key = var.aws_access_key_id
  # secret_key = var.aws_secret_access_key
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  primary_subnet_id = data.aws_subnets.default.ids[0]
}
resource "aws_security_group" "project_sg" {
  name        = "project-sg"
  description = "Allow SSH, HTTP, Puppet, Nagios web"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Puppet"
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # tighten later
  }
  ingress {
    description = "React app"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ICMP (Ping)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# puppetserver - Using larger instance type for better performance
resource "aws_instance" "puppet" {
  ami                    = var.ami_id
  instance_type          = var.puppet_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.project_sg.id]
  subnet_id              = local.primary_subnet_id
  tags = { Name = "puppetserver" }

  user_data = file("${path.module}/bootstrap/puppetserver.sh")
}

# app node (puppet agent + will host React)
resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.project_sg.id]
  subnet_id              = local.primary_subnet_id
  tags = { Name = "app-node" }

  user_data = file("${path.module}/bootstrap/appnode.sh")
}

# nagios node
resource "aws_instance" "nagios" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.project_sg.id]
  subnet_id              = local.primary_subnet_id
  tags = { Name = "nagios-node" }

  user_data = file("${path.module}/bootstrap/nagios.sh")
}

output "puppet_public_ip" {
  value = aws_instance.puppet.public_ip
}

output "app_public_ip" {
  value = aws_instance.app.public_ip
}

output "nagios_public_ip" {
  value = aws_instance.nagios.public_ip
}
