# Public route table output
output "public_rt_id" {
  value       = aws_route_table.public.id
  description = "Public route table ID"
}

# Private route table output
output "private_rt_id" {
  value       = aws_route_table.private.id
  description = "Private route table ID"
}

