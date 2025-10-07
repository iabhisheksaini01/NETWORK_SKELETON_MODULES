
resource "aws_lb" "alb" {
  count = var.create_alb ? 1 : 0

  name                       = "${var.env}-${var.alb_name}"
  internal                   = var.lb_internal
  load_balancer_type         = var.lb_type
  security_groups            = var.alb_sg_ids
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.lb_enable_deletion

  tags = merge(var.common_tags, {
    Environment = var.env
  })
}


