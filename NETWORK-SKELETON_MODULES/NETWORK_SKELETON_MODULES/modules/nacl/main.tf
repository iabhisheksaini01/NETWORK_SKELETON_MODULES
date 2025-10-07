# ******************************** Create NACLs *************************************
resource "aws_network_acl" "nacl" {
  for_each = var.create_nacl ? var.nacl_config : {}

  vpc_id = var.vpc_id

  tags = merge(var.common_tags, { 
    Name = each.key
  })
}

# ******************************** Associate NACLs with correct subnets *************************************
resource "aws_network_acl_association" "assoc" {
  for_each = var.create_nacl ? var.nacl_assoc_map : {}

  subnet_id      = each.value.subnet_type == "public" ? var.public_subnet_ids[each.value.index] : var.private_subnet_ids[each.value.index]
  network_acl_id = aws_network_acl.nacl[each.value.nacl_name].id
}

# ************************************************* Ingress rules ************************************************
resource "aws_network_acl_rule" "ingress" {
  for_each = var.create_nacl ? {
    for pair in flatten([
      for nacl_name, cfg in var.nacl_config : [
        for rule in cfg.ingress_rules : {
          key       = "${nacl_name}-ingress-${rule.rule_no}"
          nacl_name = nacl_name
          rule      = rule
        }
      ]
    ]) : pair.key => pair
  } : {}

  network_acl_id = aws_network_acl.nacl[each.value.nacl_name].id
  rule_number    = each.value.rule.rule_no
  protocol       = each.value.rule.protocol
  rule_action    = each.value.rule.action
  cidr_block     = each.value.rule.cidr_block
  from_port      = each.value.rule.from_port
  to_port        = each.value.rule.to_port
  egress         = false
}

# ************************************************* Egress rules ************************************************
resource "aws_network_acl_rule" "egress" {
  for_each = var.create_nacl ? {
    for pair in flatten([
      for nacl_name, cfg in var.nacl_config : [
        for rule in cfg.egress_rules : {
          key       = "${nacl_name}-egress-${rule.rule_no}"
          nacl_name = nacl_name
          rule      = rule
        }
      ]
    ]) : pair.key => pair
  } : {}

  network_acl_id = aws_network_acl.nacl[each.value.nacl_name].id
  rule_number    = each.value.rule.rule_no
  protocol       = each.value.rule.protocol
  rule_action    = each.value.rule.action
  cidr_block     = each.value.rule.cidr_block
  from_port      = each.value.rule.from_port
  to_port        = each.value.rule.to_port
  egress         = true
}

