output "all_sg_ids" {
  value       = var.create_sg ? { for name, sg in aws_security_group.sg : name => sg.id } : null
  description = "Map of security group names to IDs"
}

