/*
  The keypair is expected to already exist in AWS and its name is provided
  via the `key_name` variable. Removing the creation of a key pair from the
  configuration avoids relying on a local public key file (e.g. "~/.ssh/id_rsa.pub").
  If you need to import/create a key pair from a local public key file later,
  we can add a stable, repo-contained public key file or handle creation
  differently (see notes).
*/

resource "aws_security_group" "common_sg" {
  name        = "common-sg"
  description = "Allow SSH, HTTP (nagios), Puppet (8140) between hosts"

  ingress {
    description = "SSH from your IP (set in CLI env or adjust)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP for Nagios"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Puppet Server port"
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "puppet" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name != "" ? var.key_name : null
  vpc_security_group_ids = [aws_security_group.common_sg.id]
  tags = { Name = "Puppet-Server" }
  user_data = file("${path.module}/user_data/puppet_server.sh")
}

resource "aws_instance" "nagios" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name != "" ? var.key_name : null
  vpc_security_group_ids = [aws_security_group.common_sg.id]
  tags = { Name = "Nagios-Server" }
  user_data = file("${path.module}/user_data/nagios_server.sh")
}

/* outputs moved to outputs.tf */
