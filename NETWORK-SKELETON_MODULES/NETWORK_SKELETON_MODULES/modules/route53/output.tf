output "route53_record_fqdn" {
  value = var.create_record ? aws_route53_record.record[0].fqdn : null
}

