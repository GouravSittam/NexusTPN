output "puppet_public_ip" {
  value = aws_instance.puppet.public_ip
}
output "nagios_public_ip" {
  value = aws_instance.nagios.public_ip
}
