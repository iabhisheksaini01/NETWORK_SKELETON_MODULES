#**********************************************VPC**********************************************
vpc_cidr           = "10.0.0.0/16"
enable_dns_support = true
enable_dns_hostnames = true
instance_tenancy   = "default"
region             = "us-east-1"
project_name       = "network-skeleton"
env                = "dev"
owner              = "abhishek"


# **********************************************Public Subnets**********************************************

public_subnet_names = ["pub-subnet-1", "pub-subnet-2"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_azs   = ["ca-central-1a", "ca-central-1b"]


# **********************************************Private Subnets**********************************************

private_subnet_names = ["priv-subnet-1", "priv-subnet-2"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
private_subnet_azs   = ["ca-central-1a", "ca-central-1a"]


# **********************************************NACLs**********************************************

create_nacl = true
nacl_names  = ["web-nacl", "app-nacl"]
nacl_rules  = {
  "web-nacl" = {
    subnet_type = "public"
    subnet_indexes = [0]
    ingress_rules = [
      { protocol = "tcp", rule_no = 100, action = "allow", cidr_block = "0.0.0.0/0", from_port = 80, to_port = 80 },
      { protocol = "tcp", rule_no = 110, action = "allow", cidr_block = "0.0.0.0/0", from_port = 443, to_port = 443 }
    ]
    egress_rules = [
      { protocol = "-1", rule_no = 100, action = "allow", cidr_block = "0.0.0.0/0", from_port = 0, to_port = 0 }
    ]
  }
  "app-nacl" = {
    subnet_type = "private"
    subnet_indexes = [0]
    ingress_rules = [
      { protocol = "tcp", rule_no = 100, action = "allow", cidr_block = "10.0.1.0/24", from_port = 0, to_port = 65535 }
    ]
    egress_rules = [
      { protocol = "-1", rule_no = 100, action = "allow", cidr_block = "0.0.0.0/0", from_port = 0, to_port = 0 }
    ]
  }
}


# **********************************************Security Groups**********************************************

create_sg = true
sg_names  = ["alb", "app"]
security_groups_rule = {
  "alb" = {
    name = "alb"
    ingress_rules = [
      { protocol = "tcp", from_port = 80, to_port = 80, cidr_blocks = ["0.0.0.0/0"], source_sg_names = null, description = "Allow HTTP" },
      { protocol = "tcp", from_port = 443, to_port = 443, cidr_blocks = ["0.0.0.0/0"], source_sg_names = null, description = "Allow HTTPS" }
    ]
    egress_rules = [
      { protocol = "-1", from_port = 0, to_port = 0, cidr_blocks = ["0.0.0.0/0"], source_sg_names = null, description = "Allow all outbound" }
    ]
  }
  "app" = {
    name = "app"
    ingress_rules = [
      { protocol = "tcp", from_port = 8080, to_port = 8080, cidr_blocks = null, source_sg_names = ["alb"], description = "Allow traffic from ALB" }
    ]
    egress_rules = [
      { protocol = "-1", from_port = 0, to_port = 0, cidr_blocks = ["0.0.0.0/0"], source_sg_names = null, description = "Allow all outbound" }
    ]
  }
}


# **********************************************ALB**********************************************

create_alb = true
alb_name = "my-alb"
lb_internal = false
lb_type = "application"
lb_enable_deletion = false


# **********************************************Route53**********************************************

create_route53_record = false
domain_name           = "example.com"
subdomain_name        = "app"


# **********************************************VPC Peering**********************************************

enable_vpc_peering     = false
peer_vpc_id            = ""
peer_vpc_cidr          = ""
peer_route_table_ids   = []


# **********************************************NAT Gateway / EIP**********************************************

eip_domain = "vpc"


# **********************************************Common Tags**********************************************

common_tags = {
  Owner       = "abhishek"
  Environment = "dev"
  Project     = "network-skeleton"
}

