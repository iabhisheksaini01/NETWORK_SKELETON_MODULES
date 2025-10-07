############################
# General
############################
region       = "ap-southeast-1"
project_name = "otms"
env          = "dev"
owner        = "cloudops_crew"

############################
# VPC
############################
vpc_cidr             = "192.168.0.0/24"
enable_dns_support   = true
enable_dns_hostnames = true
instance_tenancy     = "default"

############################
# Public Subnets
############################
public_subnet_cidrs = ["192.168.0.0/28", "192.168.0.32/28"]
public_subnet_azs   = ["ap-southeast-1a", "ap-southeast-1b"]

############################
# Private Subnets
############################
private_subnet_cidrs = ["192.168.0.16/28", "192.168.0.48/28", "192.168.0.64/27"]
private_subnet_azs   = ["ap-southeast-1b", "ap-southeast-1b", "ap-southeast-1b"]

############################
# Route Tables
############################
public_rt_cidr_block  = "0.0.0.0/0"
private_rt_cidr_block = "0.0.0.0/0"

############################
# NAT Gateway
############################
eip_domain = "vpc"

############################
# Security Groups
############################
create_sg = true
sg_names  = ["bastion", "alb", "frontend", "attendance", "employee", "salary", "notification", "postgresql", "redis", "scylla"]

security_groups_rule = {
  bastion = {
    ingress_rules = [
      { from_port = 1194, to_port = 1194, protocol = "udp", description = "Allow bastion", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 80, to_port = 80, protocol = "tcp", description = "Allow bastion", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 22, to_port = 22, protocol = "tcp", description = "Allow bastion", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", description = "Allow bastion", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 943, to_port = 943, protocol = "tcp", description = "Allow bastion", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 945, to_port = 945, protocol = "tcp", description = "Allow bastion", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 0, to_port = 0, protocol = "-1", description = "Allow all traffic", cidr_blocks = ["0.0.0.0/0"] }
    ]
    egress_rules = [
      { from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }

  alb = {
    ingress_rules = [
      { from_port = 80, to_port = 80, protocol = "tcp", description = "HTTP access", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", description = "HTTPS access", cidr_blocks = ["0.0.0.0/0"] }
    ]
    egress_rules = [
      { from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }

  frontend = {
    ingress_rules = [
      { from_port = 22, to_port = 22, protocol = "tcp", description = "SSH from bastion", source_sg_names = ["bastion"] },
      { from_port = 3000, to_port = 3000, protocol = "tcp", description = "HTTP from alb", source_sg_names = ["alb"] }
    ]
    egress_rules = [
      { from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }
}

############################
# Network ACLs
############################
create_nacl = true
nacl_config = {
  public = {
    subnet_indexes = [0]
    ingress_rules = [
      { rule_no=100, protocol="-1", action="allow", cidr_block="0.0.0.0/0", from_port=0, to_port=0 }
    ]
    egress_rules = [
      { rule_no=100, protocol="-1", action="allow", cidr_block="0.0.0.0/0", from_port=0, to_port=0 }
    ]
  }
  frontend = {
    subnet_indexes = [1]
    ingress_rules = [
      { rule_no=100, protocol="tcp", action="allow", cidr_block="192.168.0.0/28", from_port=22, to_port=22 },
      { rule_no=200, protocol="tcp", action="allow", cidr_block="192.168.0.0/28", from_port=80, to_port=80 }
    ]
    egress_rules = [
      { rule_no=100, protocol="-1", action="allow", cidr_block="0.0.0.0/0", from_port=0, to_port=0 }
    ]
  }
}

nacl_association_map = {
  public    = { nacl_name="public", index=0 }
  frontend  = { nacl_name="frontend", index=1 }
}

############################
# ALB
############################
create_alb         = true
alb_name           = "alb"
lb_internal        = false
lb_type            = "application"
lb_enable_deletion = false

############################
# Route 53
############################
create_route53_record = false
domain_name           = "cloudopscrew.site"
subdomain_name        = "www"

############################
# VPC Peering
############################
enable_vpc_peering  = false
peer_vpc_id         = "vpc-010d6fe605aa50854"
peer_vpc_cidr       = "10.0.0.0/16"
peer_route_table_ids = ["rtb-0a4ff7060411fd91d","rtb-09436748e6215da42"]

############################
# Common Tags
############################
common_tags = {
  app_name   = "networkskeleton"
  costcenter = "otms"
}

