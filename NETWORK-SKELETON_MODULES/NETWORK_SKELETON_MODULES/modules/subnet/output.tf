# Public subnet outputs
output "public_subnet_ids" {
  value       = aws_subnet.public_subnet[*].id
  description = "List of public subnet IDs"
}

output "public_subnet_name_to_id_map" {
  value       = { for i, name in var.public_subnet_names : name => aws_subnet.public_subnet[i].id }
  description = "Map of public subnet names to IDs"
}

# Private subnet outputs
output "private_subnet_ids" {
  value       = aws_subnet.private_subnet[*].id
  description = "List of private subnet IDs"
}

output "private_subnet_name_to_id_map" {
  value       = { for i, name in var.private_subnet_names : name => aws_subnet.private_subnet[i].id }
  description = "Map of private subnet names to IDs"
}

# Combined all subnets
output "all_subnet_ids" {
  value       = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnet[*].id)
  description = "List of all subnet IDs"
}

