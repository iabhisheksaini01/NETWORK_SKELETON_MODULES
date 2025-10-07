
# ***************************************************************VPC Creation***************************************************************

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy     = var.instance_tenancy

  tags = {
    Name        = "${var.env}-${var.project_name}-vpc"
    Environment = var.env
    Owner       = var.owner
    Project     = var.project_name
  }
}



# ***************************************************************Public Subnets***************************************************************

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.public_subnet_azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.env}-${var.project_name}-public-${count.index + 1}"
    Environment = var.env
    Tier        = "public"
  }
}


# ***************************************************************Private Subnets***************************************************************

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.private_subnet_azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.env}-${var.project_name}-private-${count.index + 1}"
    Environment = var.env
    Tier        = "private"
  }
}



# ***************************************************************Internet Gateway***************************************************************

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.env}-${var.project_name}-igw"
  }
}


# ***************************************************************Elastic IP for NAT***************************************************************

resource "aws_eip" "eip" {
  domain = var.eip_domain

  tags = {
    Name = "${var.env}-${var.project_name}-eip"
  }
}



# ***************************************************************NAT Gateway***************************************************************

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.env}-${var.project_name}-natgw"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}



# ***************************************************************Route Tables***************************************************************

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.env}-${var.project_name}-public-rt"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.env}-${var.project_name}-private-rt"
  }
}


# ***************************************************************Routes added nat and igw***************************************************************

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = var.public_rt_cidr_block
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = var.private_rt_cidr_block
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}


# ***************************************************************Route Table Associations***************************************************************

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# ***************************************************************Security Groups***************************************************************

resource "aws_security_group" "security_group" {
  for_each    = var.create_sg ? { for name in var.sg_names : name => name } : {}
  name        = "${var.env}-${each.value}-sg"
  description = "Security group for ${each.value}"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.env}-${each.value}-sg"
  }
}


# ***************************************************************Security Group Rules***************************************************************

locals {
  flattened_sg_rules = flatten([
    for sg_name, sg_config in var.security_groups_rule : concat(
      [
        for i, ingress in sg_config.ingress_rules : merge(ingress, {
          direction = "ingress"
          sg_name   = sg_name
          index     = i
        })
      ],
      [
        for i, egress in sg_config.egress_rules : merge(egress, {
          direction = "egress"
          sg_name   = sg_name
          index     = i
        })
      ]
    )
  ])
}

resource "aws_security_group_rule" "sg_rule" {
  for_each = {
    for rule in local.flattened_sg_rules :
    "${rule.sg_name}-${rule.direction}-${rule.index}" => rule
  }

  type              = each.value.direction
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.security_group[each.value.sg_name].id

  cidr_blocks = (
    contains(keys(each.value), "cidr_blocks") &&
    !(contains(keys(each.value), "source_sg_names") && each.value.source_sg_names != null && length(each.value.source_sg_names) > 0)
    ? each.value.cidr_blocks
    : null
  )

  source_security_group_id = (
    contains(keys(each.value), "source_sg_names") &&
    each.value.source_sg_names != null &&
    length(each.value.source_sg_names) > 0
    ? aws_security_group.security_group[each.value.source_sg_names[0]].id
    : null
  )
}


# ***************************************************************Network ACLs***************************************************************

resource "aws_network_acl" "network_acl" {
  for_each = var.create_nacl ? local.nacl_config : {}

  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = each.key
  }, var.common_tags)
}

resource "aws_network_acl_association" "nacl_assoc" {
  for_each = var.create_nacl ? local.nacl_association_map : {}

  subnet_id      = aws_subnet.private_subnet[each.value.index].id
  network_acl_id = aws_network_acl.network_acl[each.value.nacl_name].id
}

resource "aws_network_acl_rule" "nacl_ingress" {
  for_each = var.create_nacl ? {
    for pair in flatten([
      for nacl_name, cfg in local.nacl_config : [
        for rule in cfg.ingress_rules : {
          key       = "${nacl_name}-ingress-${rule.rule_no}"
          nacl_name = nacl_name
          rule      = rule
        }
      ]
    ]) : pair.key => pair
  } : {}

  network_acl_id = aws_network_acl.network_acl[each.value.nacl_name].id
  rule_number    = each.value.rule.rule_no
  protocol       = each.value.rule.protocol
  rule_action    = each.value.rule.action
  cidr_block     = each.value.rule.cidr_block
  from_port      = each.value.rule.from_port
  to_port        = each.value.rule.to_port
  egress         = false
}

resource "aws_network_acl_rule" "nacl_egress" {
  for_each = var.create_nacl ? {
    for pair in flatten([
      for nacl_name, cfg in local.nacl_config : [
        for rule in cfg.egress_rules : {
          key       = "${nacl_name}-egress-${rule.rule_no}"
          nacl_name = nacl_name
          rule      = rule
        }
      ]
    ]) : pair.key => pair
  } : {}

  network_acl_id = aws_network_acl.network_acl[each.value.nacl_name].id
  rule_number    = each.value.rule.rule_no
  protocol       = each.value.rule.protocol
  rule_action    = each.value.rule.action
  cidr_block     = each.value.rule.cidr_block
  from_port      = each.value.rule.from_port
  to_port        = each.value.rule.to_port
  egress         = true
}


# ***************************************************************Application Load Balancer***************************************************************

resource "aws_lb" "alb" {
  count                      = var.create_alb ? 1 : 0
  name                       = "${var.env}-${var.alb_name}"
  internal                   = var.lb_internal
  load_balancer_type         = var.lb_type
  security_groups            = [aws_security_group.security_group["alb"].id]
  subnets                    = [for s in aws_subnet.public_subnet : s.id]
  enable_deletion_protection = var.lb_enable_deletion

  tags = {
    Environment = var.env
  }
}


# ***************************************************************Route 53 Record***************************************************************

data "aws_route53_zone" "zone" {
  count        = var.create_route53_record && var.domain_name != null ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "record" {
  count = var.create_alb && var.create_route53_record ? 1 : 0

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = var.subdomain_name
  type    = "A"

  alias {
    name                   = aws_lb.alb[0].dns_name
    zone_id                = aws_lb.alb[0].zone_id
    evaluate_target_health = true
  }
}


# ***************************************************************VPC Peering***************************************************************

resource "aws_vpc_peering_connection" "vpc_peering" {
  count = var.enable_vpc_peering ? 1 : 0

  vpc_id      = aws_vpc.vpc.id
  peer_vpc_id = var.peer_vpc_id
  auto_accept = true

  tags = {
    Name = "${var.env}-${var.project_name}-peer"
  }
}

resource "aws_route" "peer_public" {
  count = var.enable_vpc_peering ? 1 : 0

  route_table_id            = aws_route_table.public_route_table.id
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[0].id
}

resource "aws_route" "peer_private" {
  count = var.enable_vpc_peering ? 1 : 0

  route_table_id            = aws_route_table.private_route_table.id
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[0].id
}

resource "aws_route" "peer_return" {
  for_each = toset(var.enable_vpc_peering ? var.peer_route_table_ids : [])

  route_table_id            = each.key
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[0].id
}

