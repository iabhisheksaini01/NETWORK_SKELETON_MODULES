output "vpc_id" { value = module.vpc.vpc_id }

# Subnets
output "public_subnet_ids" { value = module.subnet.public_subnet_ids }
output "private_subnet_ids" { value = module.subnet.private_subnet_ids }
output "all_subnet_ids" { value = module.subnet.all_subnet_ids }

# Gateways
output "igw_id" { value = module.igw.igw_id }
output "nat_gateway_id" { value = module.nat_gateway.nat_gateway_id }

# Route tables
output "public_rt_id" { value = module.route_table.public_rt_id }
output "private_rt_id" { value = module.route_table.private_rt_id }

# Security Groups & NACLs
output "all_sg_ids" { value = module.security_group.all_sg_ids }
output "all_nacl_ids" { value = module.nacl.all_nacl_ids }

# ALB
output "alb_arn" { value = module.alb.alb_arn }
output "alb_dns" { value = module.alb.alb_dns }

# Route53
output "route53_record_fqdn" { value = module.route53.route53_record_fqdn }

# VPC Peering
output "vpc_peering_connection_id" { value = module.vpc_peering.vpc_peering_connection_id }

