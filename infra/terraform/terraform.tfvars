# Terraform Variables
# This file contains your specific configuration values

# AWS Configuration
aws_region = "us-east-1"

# Your admin IP/CIDR for SSH access (e.g., your public IP)
# IMPORTANT: Replace with your actual public IP address
# Example: "203.0.113.4/32" for a single IP
# Example: "203.0.113.0/24" for a subnet
admin_cidr = "YOUR_IP_ADDRESS/32"

# EC2 Instance Types
instance_type_app    = "t3.small"
instance_type_nagios = "t3.small"

# AWS Key Pair Name
key_name = "INT333"

# AMI ID
ami_id = "ami-0c398cb65a93047f2"

# S3 prefix for React app build artifacts (optional)
react_s3_prefix = "react-app"

