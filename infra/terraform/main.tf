# ---------- data: latest Ubuntu LTS 22.04 (fallback if ami_id not provided) ----------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Local value for AMI ID (use provided or fallback to data source)
locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
}

# ---------- VPC ----------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "terraform-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = { Name = "public-subnet" }
}

data "aws_availability_zones" "available" {}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------- Security groups ----------
# Nagios SG (allow SSH from admin, allow http checks to app servers, allow NRPE to access app servers)
resource "aws_security_group" "nagios_sg" {
  name        = "nagios-sg"
  description = "Nagios server SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "Nagios Web UI"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "nagios-sg" }
}

# App SG (minimal: allow HTTP from internet, SSH from admin, NRPE only from Nagios SG)
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "App servers SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # NRPE (5666) from Nagios only
  ingress {
    description      = "NRPE from nagios"
    from_port        = 5666
    to_port          = 5666
    protocol         = "tcp"
    security_groups  = [aws_security_group.nagios_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "app-sg" }
}

# ---------- IAM role for EC2 to read S3 (Puppet manifests, React build) ----------
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2_s3_read_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "s3_read_policy" {
  name = "ec2-s3-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:GetObject","s3:ListBucket"]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.puppet_bucket.arn,
          "${aws_s3_bucket.puppet_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}

# ---------- S3 bucket for puppet manifests and react build ----------
resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "puppet_bucket" {
  bucket = "${replace(var.aws_region, "-", "")}-infra-puppet-${random_id.bucket_id.hex}"
  force_destroy = true
  tags = { Name = "infra-artifacts" }
}

resource "aws_s3_bucket_acl" "puppet_bucket_acl" {
  bucket = aws_s3_bucket.puppet_bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket.puppet_bucket]
}

# upload puppet manifests & optional react build via aws_s3_object (you can also upload manually)
resource "aws_s3_object" "puppet_site" {
  bucket = aws_s3_bucket.puppet_bucket.id
  key    = "puppet/manifests/site.pp"
  source = "${path.module}/../puppet/manifests/site.pp"
  etag   = filemd5("${path.module}/../puppet/manifests/site.pp")
}

# ---------- Key pair (we expect key already in AWS) ----------
# Note: If key pair doesn't exist, create it in AWS EC2 console first
# Make sure the key pair exists in the same region as specified in aws_region
data "aws_key_pair" "kp" {
  key_name = var.key_name
}

# ---------- EC2 instances ----------
# Nagios server
resource "aws_instance" "nagios" {
  ami                         = local.ami_id
  instance_type               = var.instance_type_nagios
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.nagios_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.kp.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  tags = { Name = "nagios-server" }

  user_data = templatefile("${path.module}/userdata/nagios_userdata.sh", {
    s3_bucket = aws_s3_bucket.puppet_bucket.bucket,
    aws_region = var.aws_region
  })
}

# App server (example: count=1, scale by adjusting count)
resource "aws_instance" "app" {
  count                       = 1
  ami                         = local.ami_id
  instance_type               = var.instance_type_app
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.kp.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  tags = { Name = "app-server-${count.index}" }

  user_data = templatefile("${path.module}/userdata/app_userdata.sh", {
    s3_bucket        = aws_s3_bucket.puppet_bucket.bucket,
    s3_prefix        = var.react_s3_prefix,
    nagios_server_ip = aws_instance.nagios.private_ip,
    aws_region       = var.aws_region
  })
}

# ---------- outputs are defined in outputs.tf ----------
