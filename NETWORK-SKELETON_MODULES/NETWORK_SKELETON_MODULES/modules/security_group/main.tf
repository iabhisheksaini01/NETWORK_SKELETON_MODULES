resource "aws_security_group" "sg" {
  for_each    = var.create_sg ? { for name in var.sg_names : name => name } : {}
  name        = "${var.env}-${each.value}-sg"
  description = "Security group for ${each.value}"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.env}-${each.value}-sg"
  })
}

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

resource "aws_security_group_rule" "rules" {
  for_each = {
    for rule in local.flattened_sg_rules :
    "${rule.sg_name}-${rule.direction}-${rule.index}" => rule
  }

  type              = each.value.direction
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.sg[each.value.sg_name].id

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
    ? aws_security_group.sg[each.value.source_sg_names[0]].id
    : null
  )
}

