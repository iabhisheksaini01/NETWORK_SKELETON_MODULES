output "all_nacl_ids" {
  value       = var.create_nacl ? { for name, nacl in aws_network_acl.nacl : name => nacl.id } : null
  description = "Map of all created NACLs"
}

