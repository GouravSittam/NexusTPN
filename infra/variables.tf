variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "key_name" {
  description = "Existing EC2 key pair name in AWS. Leave empty to create instances without an SSH key."
  type        = string
  default     = ""
}

variable "public_key_path" {
  description = "Path to your public key (for import if needed)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami" {
  type    = string
  # Example Ubuntu 22.04 AMI can vary by region — replace if needed
  default = "ami-0c398cb65a93047f2"
}

variable "aws_access_key" {
  description = "AWS access key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}
