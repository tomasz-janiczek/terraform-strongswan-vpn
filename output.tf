
output "vpn_instance_id" {
  value       = aws_instance.vpn_server.id
  description = "The ID of the EC2 instance that hosts the strongSwan VPN"
}
