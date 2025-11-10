variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "admin_cidr" {
  description = "Your admin IP/cidr for SSH access (eg. 203.0.113.4/32)"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && !strcontains(var.admin_cidr, "YOUR_IP_ADDRESS")
    error_message = "admin_cidr must be a valid CIDR block (e.g., '203.0.113.4/32') and not contain 'YOUR_IP_ADDRESS' placeholder. Please update terraform.tfvars with your actual IP address."
  }
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

variable "ami_id" {
  description = "AMI ID to use for EC2 instances. If not provided, will use latest Ubuntu 22.04 LTS"
  type        = string
  default     = ""
}