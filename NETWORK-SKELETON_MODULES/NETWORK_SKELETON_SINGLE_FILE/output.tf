
# *************************************************************** Networking Outputs***************************************************************


output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "List of all public subnet IDs"
  value       = [for s in aws_subnet.public_subnet : s.id]
}

output "private_subnet_ids" {
  description = "List of all private subnet IDs"
  value       = [for s in aws_subnet.private_subnet : s.id]
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.internet_gateway.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.nat_gateway.id
}

output "public_rt_id" {
  description = "Public Route Table ID"
  value       = aws_route_table.public_route_table.id
}

output "private_rt_id" {
  description = "Private Route Table ID"
  value       = aws_route_table.private_route_table.id
}

output "all_route_table_ids" {
  description = "List of all route table IDs"
  value = [
    aws_route_table.public_route_table.id,
    aws_route_table.private_route_table.id
  ]
}


# ***************************************************************Security Group Outputs***************************************************************


output "all_sg_ids" {
  description = "Map of security group names to IDs"
  value       = var.create_sg ? { for name, sg in aws_security_group.security_group : name => sg.id } : null
}


# ***************************************************************ALB Outputs***************************************************************


output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = var.create_alb ? aws_lb.alb[0].arn : null
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = var.create_alb ? aws_lb.alb[0].dns_name : null
}


# ***************************************************************NACL Outputs***************************************************************


output "all_nacl_ids" {
  description = "Map of all created NACLs"
  value       = var.create_nacl ? { for name, nacl in aws_network_acl.network_acl : name => nacl.id } : null
}


# ***************************************************************Route 53 Outputs***************************************************************


output "route53_record_fqdn" {
  description = "Fully qualified domain name (FQDN) of the created Route 53 record"
  value       = var.create_route53_record ? aws_route53_record.record[0].fqdn : null
}


# ***************************************************************VPC Peering Outputs***************************************************************


output "vpc_peering_connection_id" {
  description = "ID of the VPC Peering Connection"
  value       = var.enable_vpc_peering ? aws_vpc_peering_connection.vpc_peering[0].id : null
}

