
output "instance_ip" {
  value       = aws_instance.web_server.public_ip
  description = "The public IP address of the main server instance."
}