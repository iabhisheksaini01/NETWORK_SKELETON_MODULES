# *************************************************VPC*********************************************

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = var.vpc_cidr
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy   = var.instance_tenancy
  env                = var.env
  project_name       = var.project_name
  owner              = var.owner
  common_tags        = var.common_tags
}

# *************************************************Subnets*************************************************

module "subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id

  public_subnet_names = var.public_subnet_names
  public_subnet_cidrs = var.public_subnet_cidrs
  public_subnet_azs   = var.public_subnet_azs

  private_subnet_names = var.private_subnet_names
  private_subnet_cidrs = var.private_subnet_cidrs
  private_subnet_azs   = var.private_subnet_azs

  env         = var.env
  project_name = var.project_name
  common_tags  = var.common_tags
}

# *************************************************Internet Gateway*************************************************

module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
  env    = var.env
  project_name = var.project_name
  common_tags  = var.common_tags
}

# *************************************************NAT Gateway*************************************************

module "nat_gateway" {
  source            = "./modules/nat_gateway"
  public_subnet_ids = [module.subnet.public_subnet_ids[0]]
  eip_domain        = var.eip_domain
  igw_id            = module.igw.igw_id
  env               = var.env
  project_name      = var.project_name
  common_tags       = var.common_tags
}

# *************************************************Route Tables*************************************************

module "route_table" {
  source = "./modules/route_table"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.subnet.public_subnet_ids
  private_subnet_ids = module.subnet.private_subnet_ids
  igw_id = module.igw.igw_id
  nat_gateway_id = module.nat_gateway.nat_gateway_id
  env = var.env
  project_name = var.project_name
  common_tags = var.common_tags
}

# *************************************************Security Groups*************************************************

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  create_sg = var.create_sg
  sg_names = var.sg_names
  security_groups_rule = var.security_groups_rule
  env = var.env
  common_tags = var.common_tags
}

# *************************************************NACLs - Local Config*************************************************

locals {
  nacl_config = var.create_nacl ? {
    for name in var.nacl_names : "${var.env}-${name}-nacl" => {
      subnet_indexes = lookup(var.nacl_rules[name], "subnet_indexes", [])
      ingress_rules  = lookup(var.nacl_rules[name], "ingress_rules", [])
      egress_rules   = lookup(var.nacl_rules[name], "egress_rules", [])
      subnet_type    = lookup(var.nacl_rules[name], "subnet_type", "private")
    }
  } : {}

  nacl_association_map = var.create_nacl ? merge([
    for nacl_name, config in local.nacl_config : {
      for idx in config.subnet_indexes : 
      "${nacl_name}-${idx}" => {
        nacl_name   = nacl_name
        index       = idx
        subnet_type = config.subnet_type
      }
    }
  ]...) : {}
}

# *************************************************NACLs*************************************************

module "nacl" {
  source = "./modules/nacl"
  vpc_id = module.vpc.vpc_id
  create_nacl = var.create_nacl
  nacl_config = local.nacl_config
  nacl_assoc_map = local.nacl_association_map
  public_subnet_ids  = module.subnet.public_subnet_ids
  private_subnet_ids = module.subnet.private_subnet_ids
  common_tags = var.common_tags
}

# *************************************************ALB*************************************************

module "alb" {
  source = "./modules/alb"
  create_alb = var.create_alb
  alb_name = var.alb_name
  lb_internal = var.lb_internal
  lb_type = var.lb_type
  lb_enable_deletion = var.lb_enable_deletion
  alb_sg_ids = var.create_alb && var.create_sg ? [module.security_group.all_sg_ids["alb"]] : []
  public_subnet_ids = module.subnet.public_subnet_ids
  env = var.env
  common_tags = var.common_tags
}

# *************************************************Route53*************************************************

module "route53" {
  source = "./modules/route53"
  create_record = var.create_route53_record
  create_alb = var.create_alb
  domain_name = var.domain_name
  subdomain_name = var.subdomain_name
  alb_dns = module.alb.alb_dns
  alb_zone_id = var.create_alb ? module.alb.alb_zone_id : null
}

# *************************************************VPC Peering*************************************************

module "vpc_peering" {
  source = "./modules/vpc_peering"
  enable_vpc_peering = var.enable_vpc_peering
  vpc_id = module.vpc.vpc_id
  peer_vpc_id = var.peer_vpc_id
  peer_vpc_cidr = var.peer_vpc_cidr
  peer_route_table_ids = var.peer_route_table_ids
  public_rt_id = module.route_table.public_rt_id
  private_rt_id = module.route_table.private_rt_id
  vpc_cidr = var.vpc_cidr
  env = var.env
  project_name = var.project_name
  common_tags = var.common_tags
}

# ********************** SSH Key Module *************************

module "ssh_key" {
  source = "./modules/ssh_key"
}

