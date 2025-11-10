variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "admin_cidr" {
  description = "Your admin IP/cidr for SSH access (eg. 203.0.113.4/32)"
  type = string
}

variable "instance_type_app" {
  default = "t3.small"
}

variable "instance_type_nagios" {
  default = "t3.small"
}

variable "key_name" {
  description = "Existing AWS key pair name. Terraform won't create AWS keypair from local pubkey in this example."
  type = string
}

variable "react_s3_prefix" {
  default = "react-app"
}
