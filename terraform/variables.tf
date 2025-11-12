variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID (leave empty to use environment variables or AWS credentials file)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key (leave empty to use environment variables or AWS credentials file)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type for app and nagios nodes"
  default     = "t3.small"
}

variable "puppet_instance_type" {
  description = "EC2 instance type for Puppet Server (needs more resources)"
  default     = "t3.medium"
}

variable "key_name" {
  description = "AWS Key Pair name"
  type        = string
  default     = "projectkey"
}

variable "ami_id" {
  description = "AMI ID to use for instances"
  default     = "ami-087d1c9a513324697"
}
