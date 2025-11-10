# Nagios server outputs
output "nagios_instance_id" {
  description = "ID of the Nagios server instance"
  value       = aws_instance.nagios.id
}

output "nagios_public_ip" {
  description = "Public IP of the Nagios server"
  value       = aws_instance.nagios.public_ip
}

output "nagios_public_dns" {
  description = "Public DNS name of the Nagios server"
  value       = aws_instance.nagios.public_dns
}

# App server outputs
output "app_instance_ids" {
  description = "IDs of the app server instances"
  value       = [for i in aws_instance.app : i.id]
}

output "app_public_ips" {
  description = "Public IPs of the app server instances"
  value       = [for i in aws_instance.app : i.public_ip]
}

output "app_public_dns" {
  description = "Public DNS names of the app server instances"
  value       = [for i in aws_instance.app : i.public_dns]
}

# S3 bucket output
output "s3_bucket_name" {
  description = "Name of the S3 bucket for Puppet manifests and React build"
  value       = aws_s3_bucket.puppet_bucket.bucket
}
