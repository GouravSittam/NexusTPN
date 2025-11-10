output "instance_id" {
  description = "ID of the created instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the instance (if assigned)"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the instance (if assigned)"
  value       = aws_instance.web.public_dns
}
