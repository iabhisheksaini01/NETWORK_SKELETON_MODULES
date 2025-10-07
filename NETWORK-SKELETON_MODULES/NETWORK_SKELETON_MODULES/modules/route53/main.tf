data "aws_route53_zone" "existing" {
  count        = var.create_record && var.domain_name != null ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "record" {
  count   = var.create_record && var.create_alb ? 1 : 0
  zone_id = data.aws_route53_zone.existing[0].zone_id
  name    = var.subdomain_name
  type    = "A"

  alias {
    name                   = var.alb_dns
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

