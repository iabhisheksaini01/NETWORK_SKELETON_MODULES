output "vpc_peering_connection_id" {
  value = var.enable_vpc_peering ? aws_vpc_peering_connection.peer[0].id : null
}

