output "nat_gateway_id" {
  value       = aws_nat_gateway.nat.id
  description = "NAT Gateway ID"
}

output "nat_gateway_eip" {
  value       = aws_eip.nat_eip.public_ip
  description = "Elastic IP associated with the NAT Gateway"
}

